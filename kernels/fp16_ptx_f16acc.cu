// fp16_ptx_f16acc.cu
// ── What changed vs fp16_ptx_mma.cu ──────────────────────────────────────────
//  Accumulator  : f32 (float rc[4])  →  f16 (uint32_t rc[2], packed FP16 pairs)
//  MMA opcode   : m16n8k16.row.col.f32.f16.f16.f32
//                                   →  m16n8k16.row.col.f16.f16.f16.f16
//  Epilogue     : direct float store →  unpack packed-f16 → float before store
//
//  Everything else (cp.async, ldmatrix, double-buffer, grid/block) is identical.
//
// ── Why this matters ──────────────────────────────────────────────────────────
//  f16 accumulator halves the D-fragment register count: 2×uint32 vs 4×float.
//  Fewer live accumulator regs → potentially higher occupancy.
//  Cost: reduced precision; AccuracyResult will quantify the degradation.
//
// ── PTX fragment sizes (per thread, mma.sync.m16n8k16 f16 acc) ───────────────
//  A  (m16 × k16): 4 × uint32  — identical to f32 variant
//  B  (k16 × n8) : 2 × uint32  — identical to f32 variant
//  D  (m16 × n8) : 2 × uint32  (each uint32 = 2 packed FP16)
//
// ── D-layout (mma.sync.m16n8, f16 accumulator) ───────────────────────────────
//  Thread t, register d[i]:
//    d[0] bits[15: 0]  → row = t/4,     col = (t%4)*2
//    d[0] bits[31:16]  → row = t/4,     col = (t%4)*2 + 1
//    d[1] bits[15: 0]  → row = t/4 + 8, col = (t%4)*2
//    d[1] bits[31:16]  → row = t/4 + 8, col = (t%4)*2 + 1
// ─────────────────────────────────────────────────────────────────────────────
#include <cuda_runtime.h>
#include <cuda_fp16.h>
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

// ── mma.sync with f16 accumulator ────────────────────────────────────────────
// D[2] = A[4] * B[2] + C[2]   (D and C are packed-f16 uint32 pairs)
#define MMA_F16ACC(rc, ra, rb)                                                  \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k16.row.col.f16.f16.f16.f16 "                   \
        "{%0,%1}, {%2,%3,%4,%5}, {%6,%7}, {%8,%9};"                            \
        : "=r"((rc)[0]), "=r"((rc)[1])                                         \
        : "r"((ra)[0]),  "r"((ra)[1]),  "r"((ra)[2]),  "r"((ra)[3]),           \
          "r"((rb)[0]),  "r"((rb)[1]),                                          \
          "r"((rc)[0]),  "r"((rc)[1]))

// ── Unpack helper ─────────────────────────────────────────────────────────────
// Extract the two FP16 values packed in a uint32 and convert to float.
__device__ __forceinline__ void unpack_f16x2(uint32_t packed, float& lo, float& hi) {
    lo = __half2float(__ushort_as_half((unsigned short)(packed & 0xFFFFu)));
    hi = __half2float(__ushort_as_half((unsigned short)(packed >> 16)));
}

__global__ void ptx_f16acc_db(
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

    // ── Accumulators — packed f16 pairs (2 × uint32 per N-half) ──────────────
    // f16 zero: bit pattern 0x0000; two zeros packed = 0x00000000u
    uint32_t rc0[2] = {0u, 0u};   // output cols 0-7
    uint32_t rc1[2] = {0u, 0u};   // output cols 8-15

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

    // ── Load first fragments via ldmatrix — identical to fp16_ptx_mma ─────────
    uint32_t ra[4], rb0[2], rb1[2];
    LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
    LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
    LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);

    // ── Main K loop — identical structure to fp16_ptx_mma ────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

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

        // Compute (f16 accumulator — fewer live registers vs f32)
        MMA_F16ACC(rc0, ra, rb0);
        MMA_F16ACC(rc1, ra, rb1);

        asm volatile("cp.async.wait_group 0;");

        buf = next;
        LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
        LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
        LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    MMA_F16ACC(rc0, ra, rb0);
    MMA_F16ACC(rc1, ra, rb1);

    // ── Epilogue: unpack packed-f16 → float and scatter ───────────────────────
    // D-layout (f16 acc): each uint32 holds 2 FP16 values.
    //   rc[0] bits[15:0]  → (row0, col0)   rc[0] bits[31:16] → (row0, col1)
    //   rc[1] bits[15:0]  → (row1, col0)   rc[1] bits[31:16] → (row1, col1)
    float* c_dst = C_b + tile_row * N + tile_col;
    int out_row0 = lane_id / 4;
    int out_row1 = out_row0 + 8;
    int out_col0 = (lane_id % 4) * 2;
    int out_col1 = out_col0 + 1;

    float v0, v1, v2, v3;

    // rc0 → cols 0-7
    unpack_f16x2(rc0[0], v0, v1);
    unpack_f16x2(rc0[1], v2, v3);
    c_dst[out_row0 * N + out_col0]     = v0;
    c_dst[out_row0 * N + out_col1]     = v1;
    c_dst[out_row1 * N + out_col0]     = v2;
    c_dst[out_row1 * N + out_col1]     = v3;

    // rc1 → cols 8-15
    unpack_f16x2(rc1[0], v0, v1);
    unpack_f16x2(rc1[1], v2, v3);
    c_dst[out_row0 * N + out_col0 + 8] = v0;
    c_dst[out_row0 * N + out_col1 + 8] = v1;
    c_dst[out_row1 * N + out_col0 + 8] = v2;
    c_dst[out_row1 * N + out_col1 + 8] = v3;
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
    ptx_f16acc_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
