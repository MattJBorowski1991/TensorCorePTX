// fp16_ptx_3stage.cu

// In double buffering, you overlap GMEM→SMEM (async global load of tile N+1) with compute on tile N.
// In triple buffering, you add a third stage and overlap all three simultaneously:
// GMEM→SMEM: loading tile N+2 from global memory
// SMEM→registers: pre-fetching tile N+1 operands into registers
// Compute (MMA): executing on tile N
// The new overlap is register pre-fetch (SMEM→reg) of the next tile 
// while the current tile is computing — hiding the latency of shared memory
// reads on top of global memory latency.


// ── What changed vs fp16_ptx_mma.cu (2-stage) ────────────────────────────────
//  Shared mem    : As/Bs[2][...] → As/Bs[3][...]  (third buffer)
//  Prolog        : scalar store + __syncthreads for buf=0
//                → cp.async for buf=0 AND buf=1, commit each, wait_group 1
//  Main loop     : prefetch k → commit → compute → wait_group 0
//                → prefetch k → commit → compute → wait_group 1
//                  (allows 1 group still in flight during compute)
//  Epilogue      : 1 compute + drain (wait_group 0) + reload + 1 compute
//
// ── Why this might help ───────────────────────────────────────────────────────
//  wait_group 1 means the MMA overlaps with the in-flight cp.async → the SM
//  memory system has a full MMA latency window to complete the next transfer.
//  On Ada (L4) L2 latency ~200 cycles; 2-stage exposes this stall if MMA
//  finishes before the next tile arrives. 3-stage hides it.
//  If L2 is already fast enough, 3-stage just wastes 512 extra bytes of SRAM.
//  NCU l2_hit_rate + sm__stall_wait_group will tell the story. 
//  If sm__stall_wait_group is high in 2-stage, 3-stage will help. If it's near zero, 2-stage is already hiding everything
//
// ── Shared memory size ────────────────────────────────────────────────────────
//  WARPS_PER_BLOCK=8, WMMA_M/K/N=16, PAD=0, dtype=half (2B)
//  As: 3 * 8 * 16 * 16 * 2 = 12288 B
//  Bs: 3 * 8 * 16 * 16 * 2 = 12288 B  →  ~24 KB total  (SM89 has ~100 KB)
//
// ── Group accounting ─────────────────────────────────────────────────────────
//  Prolog:   commit(stage 0) → commit(stage 1) → wait_group 1
//            → at most 1 group in flight (stage 1 may still load)
//  Loop iter: commit(stage k) → compute current → wait_group 1
//            → at most 1 group in flight (just-committed stage)
//  Epilogue: compute second-to-last → wait_group 0 → load+compute last
// ─────────────────────────────────────────────────────────────────────────────
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── ldmatrix helpers — identical to fp16_ptx_mma.cu ──────────────────────────
#define LDMATRIX_A(ra, smem_ptr, lane)                                          \
    do {                                                                        \
        int _r = (lane) % 16;                                                   \
        int _c = ((lane) / 16) * 8;                                             \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][_c]);         \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x4.shared.b16 {%0,%1,%2,%3}, [%4];"   \
            : "=r"((ra)[0]), "=r"((ra)[1]), "=r"((ra)[2]), "=r"((ra)[3])       \
            : "r"(_addr));                                                      \
    } while(0)

#define LDMATRIX_B(rb, smem_ptr, lane, n_base)                                  \
    do {                                                                        \
        int _r = (lane) % 16;                                                   \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][(n_base)]);   \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x2.trans.shared.b16 {%0,%1}, [%2];"   \
            : "=r"((rb)[0]), "=r"((rb)[1])                                     \
            : "r"(_addr));                                                      \
    } while(0)

// ── mma.sync macro — identical to fp16_ptx_mma.cu ────────────────────────────
#define MMA_SYNC(rc, ra, rb)                                                    \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32 "                   \
        "{%0,%1,%2,%3}, {%4,%5,%6,%7}, {%8,%9}, {%10,%11,%12,%13};"            \
        : "=f"((rc)[0]), "=f"((rc)[1]), "=f"((rc)[2]), "=f"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),  "r"((ra)[2]),  "r"((ra)[3]),           \
          "r"((rb)[0]),  "r"((rb)[1]),                                          \
          "f"((rc)[0]),  "f"((rc)[1]),  "f"((rc)[2]),  "f"((rc)[3]))

// ── cp.async helper — issues one 16B async copy ───────────────────────────────
// Avoids repeating the asm line at every call site.
__device__ __forceinline__ void cp_async16(void* dst, const void* src) {
    unsigned dst_addr = __cvta_generic_to_shared(dst);
    asm volatile("cp.async.ca.shared.global [%0], [%1], 16;"
                 :: "r"(dst_addr), "l"(src));
}

__global__ void ptx_3stage_db(
    const half* __restrict__ A,
    const half* __restrict__ B,
    float* __restrict__ C,
    int M, int N, int K
){
    int batch = blockIdx.z;

    const half* __restrict__ A_b = A + batch * M * K;
    const half* __restrict__ B_b = B + batch * K * N;
    float* __restrict__ C_b = C + batch * M * N;

    const int tid     = threadIdx.x;
    const int warp_id = tid / THREADS_PER_WARP;
    const int lane_id = tid % THREADS_PER_WARP;

    const int warp_tile_row = warp_id / WARP_TILES_X;
    const int warp_tile_col = warp_id % WARP_TILES_X;

    const int tile_row = blockIdx.y * (WMMA_M * WARP_TILES_Y) + warp_tile_row * WMMA_M;
    const int tile_col = blockIdx.x * (WMMA_N * WARP_TILES_X) + warp_tile_col * WMMA_N;
    if (tile_row >= M || tile_col >= N) return;

    // ── 3 shared memory buffers (was 2 in fp16_ptx_mma) ──────────────────────
    __shared__ __align__(16) half As[3][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) half Bs[3][WARPS_PER_BLOCK][WMMA_K][WMMA_N + PAD];

    float rc0[4] = {0.f, 0.f, 0.f, 0.f};
    float rc1[4] = {0.f, 0.f, 0.f, 0.f};

    // ── Prolog: async-fill stages 0 and 1 ────────────────────────────────────

    // Stage 0: global k-offset = 0
    for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        cp_async16(&As[0][warp_id][row][col], &A_b[(tile_row + row) * K + col]);
    }
    for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
        int row = i / WMMA_N, col = i % WMMA_N;
        cp_async16(&Bs[0][warp_id][row][col], &B_b[row * N + (tile_col + col)]);
    }
    asm volatile("cp.async.commit_group;");   // group 0 in flight = 
    // = The cp.async instructions issued so far have been bundled into a named 
    // group (group 0) that is now executing asynchronously in the background 
    // — the GPU's DMA engine is copying data from global memory to shared memory without the warp waiting for it.

    // Stage 1: global k-offset = WMMA_K
    for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        cp_async16(&As[1][warp_id][row][col], &A_b[(tile_row + row) * K + (col + WMMA_K)]);
    }
    for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
        int row = i / WMMA_N, col = i % WMMA_N;
        cp_async16(&Bs[1][warp_id][row][col], &B_b[(row + WMMA_K) * N + tile_col + col]);
    }
    asm volatile("cp.async.commit_group;");   // group 1 in flight (2 total)

    // Wait for group 0; group 1 may remain in flight — this is the extra slack
    // that 3-stage adds vs 2-stage (where we would wait_group 0 here).
    asm volatile("cp.async.wait_group 1;"); 
    // wait_group N = wait until at most 1 group is in flight. Drains oldest groups first

    // Load fragments from stage 0
    uint32_t ra[4], rb0[2], rb1[2];
    LDMATRIX_A(ra,  As[0][warp_id], lane_id);
    LDMATRIX_B(rb0, Bs[0][warp_id], lane_id, 0);
    LDMATRIX_B(rb1, Bs[0][warp_id], lane_id, 8);

    int buf = 0;

    // ── Main K loop ───────────────────────────────────────────────────────────
    // Invariant entering iteration: fragments hold tile `buf`, 1 group in flight
    // for tile `(buf+1)%3` (committed last iteration or in prolog).
    // prefetch_buf = (buf+2)%3 is free to write.
    for (int k = 2 * WMMA_K; k < K; k += WMMA_K) {
        int next         = (buf + 1) % 3;
        int prefetch_buf = (buf + 2) % 3;

        // Prefetch tile k into prefetch_buf
        for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_K, col = i % WMMA_K;
            cp_async16(&As[prefetch_buf][warp_id][row][col],
                       &A_b[(tile_row + row) * K + (col + k)]);
        }
        for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_N, col = i % WMMA_N;
            cp_async16(&Bs[prefetch_buf][warp_id][row][col],
                       &B_b[(row + k) * N + tile_col + col]);
        }
        asm volatile("cp.async.commit_group;");  // now 2 groups in flight

        // Compute on current fragments (buf)
        MMA_SYNC(rc0, ra, rb0);
        MMA_SYNC(rc1, ra, rb1);

        // Wait until at most 1 group in flight — guarantees `next` is ready.
        // The just-committed prefetch_buf may still be loading (that's the point).
        asm volatile("cp.async.wait_group 1;");

        // Reload from next stage
        buf = next;
        LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
        LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
        LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    // ── Epilogue ──────────────────────────────────────────────────────────────
    // After the loop: fragments = second-to-last tile, 1 group in flight (last tile).

    // Compute second-to-last tile
    MMA_SYNC(rc0, ra, rb0);
    MMA_SYNC(rc1, ra, rb1);

    // Drain the last in-flight group (last tile)
    asm volatile("cp.async.wait_group 0;");

    // Load and compute last tile
    buf = (buf + 1) % 3;
    LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
    LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
    LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);
    MMA_SYNC(rc0, ra, rb0);
    MMA_SYNC(rc1, ra, rb1);

    // ── Epilogue scatter — identical to fp16_ptx_mma ─────────────────────────
    float* c_dst = C_b + tile_row * N + tile_col;
    int out_row0 = lane_id / 4;
    int out_row1 = out_row0 + 8;
    int out_col0 = (lane_id % 4) * 2;
    int out_col1 = out_col0 + 1;

    c_dst[out_row0 * N + out_col0]     = rc0[0];
    c_dst[out_row0 * N + out_col1]     = rc0[1];
    c_dst[out_row1 * N + out_col0]     = rc0[2];
    c_dst[out_row1 * N + out_col1]     = rc0[3];

    c_dst[out_row0 * N + out_col0 + 8] = rc1[0];
    c_dst[out_row0 * N + out_col1 + 8] = rc1[1];
    c_dst[out_row1 * N + out_col0 + 8] = rc1[2];
    c_dst[out_row1 * N + out_col1 + 8] = rc1[3];
}

// ── Kernel launch wrapper ─────────────────────────────────────────────────────
void launch_kernel(const half* A, const half* B, float* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    ptx_3stage_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
