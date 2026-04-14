// fp16_ptx_k8.cu
// ── What changed vs fp16_ptx_mma.cu (k16) ────────────────────────────────────
//  Global→SRAM  : identical  (same cp.async double-buffer, same 16×16 SRAM tiles)
//  SRAM→regs    : ldmatrix.x4 (k16)  →  ldmatrix.x2 per k8-slice of A
//                 ldmatrix.x2.trans  →  ldmatrix.x1.trans per 8×8 B quad
//  Compute      : 2× mma.sync.m16n8k16  →  4× mma.sync.m16n8k8 per K-step
//                 Each 16×16 SRAM tile is decomposed into two k=8 sub-slices,
//                 each paired with both N-halves of B → 2 k-slices × 2 N-halves
//  Epilogue     : identical to fp16_ptx_mma (D-layout unchanged for m16n8 f32)
//
// ── Why compare k8 vs k16? ───────────────────────────────────────────────────
//  k8 : smaller fragments → fewer live registers per fragment, potentially higher
//       occupancy; but 4 MMA calls per K-step vs 2 → more instruction overhead.
//  k16: fewer MMA calls → better ILP / scheduling; higher per-call register count.
//  The crossover is empirical; NCU sm__sass_thread_inst_executed_op_hmma_pred_on
//  + achieved_occupancy will tell the story.
//
// ── PTX fragment sizes (per thread, mma.sync.m16n8k8) ────────────────────────
//  A  (m16 × k8):   2 × uint32  (each uint32 = 2 × FP16)
//  B  (k8  × n8):   1 × uint32
//  D  (m16 × n8):   4 × float   (identical to k16 — same output shape)
//
// ── D-layout identical to k16 (mma.sync.m16n8, f32 accumulator) ──────────────
//  Thread t: d[0]@(t/4, (t%4)*2)  d[1]@(t/4, (t%4)*2+1)
//            d[2]@(t/4+8,(t%4)*2) d[3]@(t/4+8,(t%4)*2+1)
// ─────────────────────────────────────────────────────────────────────────────
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── ldmatrix helpers ──────────────────────────────────────────────────────────

// Load a 16×8 A sub-tile (rows 0-15, k_col..k_col+7) using ldmatrix.x2.
// Two stacked 8×8 b16 matrices; threads 0-15 each provide one row address,
// threads 16-31 mirror them via lane%16 (don't-care lanes safely in-bounds).
// Produces 2 × uint32 in ra[0..1].
#define LDMATRIX_A_K8(ra, smem_ptr, lane, k_col)                                \
    do {                                                                        \
        int      _r    = (lane) % 16;                                           \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][(k_col)]);    \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x2.shared.b16 {%0,%1}, [%2];"         \
            : "=r"((ra)[0]), "=r"((ra)[1])                                     \
            : "r"(_addr));                                                      \
    } while(0)

// Load an 8×8 B sub-tile (rows k_row..k_row+7, cols n_col..n_col+7) transposed.
// ldmatrix.x1.trans loads one 8×8 b16 matrix and transposes it in-place,
// giving the col-major layout that mma.sync expects for the B operand.
// Threads 0-7 provide row addresses; threads 8-31 are don't-care (lane%8 safe).
// Produces 1 × uint32 in rb[0].
#define LDMATRIX_B_K8(rb, smem_ptr, lane, k_row, n_col)                         \
    do {                                                                        \
        int      _r    = (k_row) + (lane) % 8;                                  \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][(n_col)]);    \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x1.trans.shared.b16 {%0}, [%1];"      \
            : "=r"((rb)[0])                                                    \
            : "r"(_addr));                                                      \
    } while(0)

// ── mma.sync.m16n8k8 macro ────────────────────────────────────────────────────
// rd[4] = ra[2] * rb[1] + rc[4]  (in-place: rc is both C input and D output)
#define MMA_K8(rc, ra, rb)                                                      \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k8.row.col.f32.f16.f16.f32 "                    \
        "{%0,%1,%2,%3}, {%4,%5}, {%6}, {%7,%8,%9,%10};"                        \
        : "=f"((rc)[0]), "=f"((rc)[1]), "=f"((rc)[2]), "=f"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),                                          \
          "r"((rb)[0]),                                                         \
          "f"((rc)[0]),  "f"((rc)[1]),  "f"((rc)[2]),  "f"((rc)[3]))

__global__ void ptx_k8_db(
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

    // ── Shared memory — identical to fp16_ptx_mma ─────────────────────────────
    __shared__ __align__(16) half As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) half Bs[2][WARPS_PER_BLOCK][WMMA_K][WMMA_N + PAD];

    // ── Accumulators ──────────────────────────────────────────────────────────
    float rc0[4] = {0.f, 0.f, 0.f, 0.f};   // output cols 0-7
    float rc1[4] = {0.f, 0.f, 0.f, 0.f};   // output cols 8-15

    int buf = 0;

    // ── Prolog scalar load — identical to fp16_ptx_mma ────────────────────────
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_K * WMMA_N; i += THREADS_PER_WARP) {
        int row = i / WMMA_N, col = i % WMMA_N;
        Bs[buf][warp_id][row][col] = B_b[row * N + (tile_col + col)];
    }
    __syncthreads();

    // ── Load first k8 fragments ───────────────────────────────────────────────
    // A: two k=8 slices of the 16×16 tile
    uint32_t ra_k0[2], ra_k1[2];
    LDMATRIX_A_K8(ra_k0, As[buf][warp_id], lane_id, 0);   // A cols 0-7
    LDMATRIX_A_K8(ra_k1, As[buf][warp_id], lane_id, 8);   // A cols 8-15

    // B: four 8×8 quads (2 k-slices × 2 N-halves)
    uint32_t rb0_k0[1], rb0_k1[1];   // N-half 0 (cols 0-7),  k-slices 0 and 1
    uint32_t rb1_k0[1], rb1_k1[1];   // N-half 1 (cols 8-15), k-slices 0 and 1
    LDMATRIX_B_K8(rb0_k0, Bs[buf][warp_id], lane_id, 0, 0);   // rows 0-7,  cols 0-7
    LDMATRIX_B_K8(rb0_k1, Bs[buf][warp_id], lane_id, 8, 0);   // rows 8-15, cols 0-7
    LDMATRIX_B_K8(rb1_k0, Bs[buf][warp_id], lane_id, 0, 8);   // rows 0-7,  cols 8-15
    LDMATRIX_B_K8(rb1_k1, Bs[buf][warp_id], lane_id, 8, 8);   // rows 8-15, cols 8-15

    // ── Main K loop ───────────────────────────────────────────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // Prefetch — identical to fp16_ptx_mma
        for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_K, col = i % WMMA_K;
            char*       dst      = (char*)&As[next][warp_id][row][col];
            const char* src      = (const char*)&A_b[(tile_row + row) * K + (col + k)];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }
        for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_N, col = i % WMMA_N;
            char*       dst      = (char*)&Bs[next][warp_id][row][col];
            const char* src      = (const char*)&B_b[(row + k) * N + tile_col + col];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }
        asm volatile("cp.async.commit_group;");

        // ── 4× mma.sync.m16n8k8 (replaces 2× mma.sync.m16n8k16) ─────────────
        // Decompose: C[m16,n16] += A[m16,k16] * B[k16,n16]
        //          = A[m16,k0..7] * B[k0..7, n0..7]   → rc0
        //          + A[m16,k0..7] * B[k0..7, n8..15]  → rc1
        //          + A[m16,k8..15] * B[k8..15, n0..7] → rc0
        //          + A[m16,k8..15] * B[k8..15, n8..15]→ rc1
        MMA_K8(rc0, ra_k0, rb0_k0);
        MMA_K8(rc1, ra_k0, rb1_k0);
        MMA_K8(rc0, ra_k1, rb0_k1);
        MMA_K8(rc1, ra_k1, rb1_k1);

        asm volatile("cp.async.wait_group 0;");

        buf = next;
        LDMATRIX_A_K8(ra_k0, As[buf][warp_id], lane_id, 0);
        LDMATRIX_A_K8(ra_k1, As[buf][warp_id], lane_id, 8);
        LDMATRIX_B_K8(rb0_k0, Bs[buf][warp_id], lane_id, 0, 0);
        LDMATRIX_B_K8(rb0_k1, Bs[buf][warp_id], lane_id, 8, 0);
        LDMATRIX_B_K8(rb1_k0, Bs[buf][warp_id], lane_id, 0, 8);
        LDMATRIX_B_K8(rb1_k1, Bs[buf][warp_id], lane_id, 8, 8);
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    MMA_K8(rc0, ra_k0, rb0_k0);
    MMA_K8(rc1, ra_k0, rb1_k0);
    MMA_K8(rc0, ra_k1, rb0_k1);
    MMA_K8(rc1, ra_k1, rb1_k1);

    // ── Epilogue — identical to fp16_ptx_mma (D-layout unchanged) ────────────
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
    ptx_k8_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
