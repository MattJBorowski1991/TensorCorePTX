// fp16_ptx_mma.cu
// ── What changed vs fp16_wmma.cu ─────────────────────────────────────────────
//  Global→SRAM  : identical  (same cp.async double-buffer loop)
//  SRAM→regs    : wmma::load_matrix_sync  →  ldmatrix.sync PTX
//  Compute      : wmma::mma_sync          →  mma.sync.aligned.m16n8k16 PTX
//                 mma.sync N=8, so 2 calls per K-step to cover the 16-col warp tile
//  Epilogue     : wmma::store_matrix_sync →  direct scatter to global using
//                 the D-fragment lane layout of mma.sync.m16n8k16
// ── PTX fragment sizes (per thread) ──────────────────────────────────────────
//  A  (m16 x k16):  4 x uint32  (each uint32 = 2 x FP16)
//  B  (k16 x n8) :  2 x uint32
//  D  (m16 x n8) :  4 x float
// ── D-layout (mma.sync.m16n8k16, f32 accumulator) ────────────────────────────
//  Thread lane t owns:
//    d[0] → row = t/4,     col = (t%4)*2
//    d[1] → row = t/4,     col = (t%4)*2 + 1
//    d[2] → row = t/4 + 8, col = (t%4)*2
//    d[3] → row = t/4 + 8, col = (t%4)*2 + 1
// ─────────────────────────────────────────────────────────────────────────────
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

#define DBG_TRACE_TILES 16

#define DBG_PRINT_TILE_FRAG(tag, tile_idx, lane, ra, rb0)                          \
    do {                                                                            \
        half _ra0_lo  = __ushort_as_half((uint16_t)((ra)[0] & 0xFFFF));            \
        half _ra0_hi  = __ushort_as_half((uint16_t)((ra)[0] >> 16));               \
        half _rb0_lo  = __ushort_as_half((uint16_t)((rb0)[0] & 0xFFFF));           \
        half _rb0_hi  = __ushort_as_half((uint16_t)((rb0)[0] >> 16));              \
        half _rb0b_lo = __ushort_as_half((uint16_t)((rb0)[1] & 0xFFFF));           \
        half _rb0b_hi = __ushort_as_half((uint16_t)((rb0)[1] >> 16));              \
        printf("[DBG-LOAD] %s tile=%d lane=%d ra[0]={%.6f,%.6f} rb0[0]={%.6f,%.6f} rb0[1]={%.6f,%.6f}\n", \
            tag, tile_idx, lane,                                                    \
            __half2float(_ra0_lo), __half2float(_ra0_hi),                          \
            __half2float(_rb0_lo), __half2float(_rb0_hi),                          \
            __half2float(_rb0b_lo), __half2float(_rb0b_hi));                       \
    } while (0)

#define DBG_PRINT_TILE_HEADER(tag, tile_idx, lane)                                  \
    do {                                                                            \
        if ((lane) == 0) {                                                         \
            printf("\n[DBG-TILE] %s tile=%d\n", tag, tile_idx);                 \
        }                                                                           \
    } while (0)

#define DBG_PRINT_TILE_ALL_LANES(tag, tile_idx, lane, ra, rb0)                      \
    do {                                                                            \
        DBG_PRINT_TILE_HEADER(tag, tile_idx, lane);                                 \
        for (int _dbg_lane = 0; _dbg_lane < THREADS_PER_WARP; ++_dbg_lane) {       \
            if ((lane) == _dbg_lane) {                                              \
                DBG_PRINT_TILE_FRAG(tag, tile_idx, lane, ra, rb0);                  \
            }                                                                       \
            __syncwarp();                                                           \
        }                                                                           \
    } while (0)

// ── ldmatrix helper macros ────────────────────────────────────────────────────
// Load A: ldmatrix.x4 for a 16×16 FP16 tile (row-major in SRAM).
// Thread lane t → points to As[row = t%16][col = (t/16)*8].
// Produces 4 × uint32 in ra[0..3].
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

// Load B half: ldmatrix.x2.trans for a 16×8 FP16 tile stored [K=16][N=8].
// .trans transposes during load → gives col-major layout expected by mma.sync B.
// Thread lane t → K-row = t%16, N-col = n_base.
// Threads 16-31 provide don't-care addresses (t%16 keeps them safely in-bounds).
// Produces 2 × uint32 in rb[0..1].
#define LDMATRIX_B(rb, smem_ptr, lane, n_base)                                  \
    do {                                                                        \
        int _r = (lane) % 16;                                                   \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][(n_base)]);   \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x2.trans.shared.b16 {%0,%1}, [%2];"   \
            : "=r"((rb)[0]), "=r"((rb)[1])                                     \
            : "r"(_addr));                                                      \
    } while(0)

// ── mma.sync helper macro ─────────────────────────────────────────────────────
// mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32
// rd[4] = ra[4] * rb[2] + rc[4]   (all in-place: rc → rd writes back to rc)
#define MMA_SYNC(rc, ra, rb)                                                    \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32 "                   \
        "{%0,%1,%2,%3}, {%4,%5,%6,%7}, {%8,%9}, {%10,%11,%12,%13};"            \
        : "=f"((rc)[0]), "=f"((rc)[1]), "=f"((rc)[2]), "=f"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),  "r"((ra)[2]),  "r"((ra)[3]),           \
          "r"((rb)[0]),  "r"((rb)[1]),                                          \
          "f"((rc)[0]),  "f"((rc)[1]),  "f"((rc)[2]),  "f"((rc)[3]))

__global__ void ptx_mma_db(
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

    // ── Shared memory — layout identical to fp16_wmma ─────────────────────────
    __shared__ __align__(16) half As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) half Bs[2][WARPS_PER_BLOCK][WMMA_K][WMMA_N + PAD];

    // ── Accumulators — two mma tiles cover the 16×16 warp output ─────────────
    // rc0: output cols 0..7  (first  mma.sync, N=8)
    // rc1: output cols 8..15 (second mma.sync, N=8)
    float rc0[4] = {0.f, 0.f, 0.f, 0.f};
    float rc1[4] = {0.f, 0.f, 0.f, 0.f};

    int buf = 0;

    // ── Prolog scalar load (identical to fp16_wmma) ───────────────────────────
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_K * WMMA_N; i += THREADS_PER_WARP) {
        int row = i / WMMA_N, col = i % WMMA_N;
        Bs[buf][warp_id][row][col] = B_b[row * N + (tile_col + col)];
    }

    // ── Load first fragments via ldmatrix (replaces wmma::load_matrix_sync)
    uint32_t ra[4], rb0[2], rb1[2];
    LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
    LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);   // B cols 0-7
    LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);   // B cols 8-15

    // ── DEBUG: print loaded fragments for first DBG_TRACE_TILES tiles, all lanes
    if (blockIdx.x == 0 && blockIdx.y == 0 && blockIdx.z == 0 && warp_id == 0) {
        DBG_PRINT_TILE_ALL_LANES("ldmatrix", 0, lane_id, ra, rb0);
    }

    // ── Main K loop — structure identical to fp16_wmma ────────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // Prefetch A tile (identical to fp16_wmma)
        for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_K, col = i % WMMA_K;
            char*       dst      = (char*)&As[next][warp_id][row][col];
            const char* src      = (const char*)&A_b[(tile_row + row) * K + (col + k)];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        // Prefetch B tile (identical to fp16_wmma)
        for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_N, col = i % WMMA_N;
            char*       dst      = (char*)&Bs[next][warp_id][row][col];
            const char* src      = (const char*)&B_b[(row + k) * N + tile_col + col];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        // Compute on current fragments (replaces wmma::mma_sync)
        MMA_SYNC(rc0, ra, rb0);   // cols 0-7
        MMA_SYNC(rc1, ra, rb1);   // cols 8-15

        (void)0;

        asm volatile("cp.async.wait_group 0;");

        // Swap buffer and reload fragments (replaces wmma::load_matrix_sync)
        buf = next;
        LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
        LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
        LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);
        int loaded_tile = k / WMMA_K;
        if (loaded_tile < DBG_TRACE_TILES &&
            blockIdx.x == 0 && blockIdx.y == 0 && blockIdx.z == 0 && warp_id == 0) {
            DBG_PRINT_TILE_ALL_LANES("ldmatrix", loaded_tile, lane_id, ra, rb0);
        }
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    MMA_SYNC(rc0, ra, rb0);
    MMA_SYNC(rc1, ra, rb1);

    // ── Epilogue: scatter D-fragment to global ────────────────────────────────
    // mma.sync.m16n8k16 D-layout (f32):
    //   thread t → d[0] @ (t/4, (t%4)*2)      d[1] @ (t/4,   (t%4)*2+1)
    //              d[2] @ (t/4+8, (t%4)*2)     d[3] @ (t/4+8, (t%4)*2+1)
    float* c_dst  = C_b + tile_row * N + tile_col;
    int out_row0  = lane_id / 4;
    int out_row1  = out_row0 + 8;
    int out_col0  = (lane_id % 4) * 2;
    int out_col1  = out_col0 + 1;

    // rc0 covers cols 0-7
    c_dst[out_row0 * N + out_col0]     = rc0[0];
    c_dst[out_row0 * N + out_col1]     = rc0[1];
    c_dst[out_row1 * N + out_col0]     = rc0[2];
    c_dst[out_row1 * N + out_col1]     = rc0[3];

    // rc1 covers cols 8-15
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
    ptx_mma_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}


// cmake -B build -DKERNEL=fp16_ptx_mma -DCUDA_ARCH=89
// cmake --build build
// ./build/profile_fp16_ptx_mma