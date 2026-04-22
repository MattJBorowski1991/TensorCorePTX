// int8_dp4a.cu
// ── What this is ─────────────────────────────────────────────────────────────
//  Baseline scalar INT8 GEMM using the dp4a (dot-product 4a) instruction.
//  dp4a computes one 4-way int8 dot product per thread per cycle:
//      acc += a[0]*b[0] + a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
//  where a, b are four int8 values packed into one int32 register.
//
//  This is NOT a tensor core kernel.  It is the "baseline" above which all
//  mma.sync / wmma kernels must demonstrate speed-up.  Expected throughput is
//  ~4–20× slower than the mma.sync variants on Ada/L4.
//
// ── What changed vs int8_ptx_mma_k16.cu ─────────────────────────────────────
//  No tensor core    : mma.sync removed entirely; each thread computes its own
//                      single output element C[row][col] independently.
//  No ldmatrix       : A and BT tiles are loaded element-by-element into SMEM.
//  No fragments      : ra[], rb[], rc[] replaced by plain int32 registers.
//  No warp-tile layout: thread (ty, tx) → output (block_row+ty, block_col+tx).
//  MMA → dp4a        : PTX dp4a.s32.s32 (signed int8 × signed int8) per 4 K.
//
// ── Shared memory layout ─────────────────────────────────────────────────────
//  BLOCK_M=16, BLOCK_N=16, BLOCK_K=16, 256 threads in a 16×16 block.
//
//  As[BLOCK_M][BLOCK_K + 4]  (int8_t)   — A row tile, +4 pad unused here
//  Bs[BLOCK_N][BLOCK_K + 4]  (int8_t)   — BT row tile, +4 pad avoids conflicts
//      Bs is loaded as N rows × K cols (BT layout) so that thread (ty,tx)
//      can read its own B column (BT row) via Bs[tx][j].
//      Without padding: row stride = 16 bytes = 4 banks → 2-way conflict on
//      read (tx=0 and tx=8 alias the same bank).  +4 → stride 20 bytes → 5 banks
//      per row → all 16 distinct banks accessed conflict-free.
//
// ── Thread ↔ output mapping ──────────────────────────────────────────────────
//  threadIdx.x (0..15) → column dimension (N).
//  threadIdx.y (0..15) → row dimension (M).
//  SMEM load:
//      As[ty][tx] = A[(block_row+ty)*K + k + tx]
//      Bs[ty][tx] = BT[(block_col+ty)*K + k + tx]   (ty → BT row, tx → K col)
//  Accumulate: dp4a over j=0,4,8,12 → As[ty][j..j+3] · Bs[tx][j..j+3]
//  Output:     C[(block_row+ty)*N + (block_col+tx)] = acc
//
// ── Bank conflict analysis ────────────────────────────────────────────────────
//  As read: all threads in a warp share the same ty → broadcast (no conflict).
//  Bs read: Bs[tx][j], row stride = (BLOCK_K+4) = 20 bytes.
//      bank(tx) = (tx * 20 / 4) % 32 = (tx * 5) % 32.
//      tx=0→0, 1→5, 2→10, 3→15, 4→20, 5→25, 6→30, 7→3, 8→8, ..., 15→11
//      All 16 banks distinct → zero bank conflicts.
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── dp4a PTX helper — signed int8 packed in int32 ────────────────────────────
static __device__ __forceinline__ int32_t dp4a_s32(int32_t a, int32_t b, int32_t c) {
    asm("dp4a.s32.s32 %0, %1, %2, %3;" : "=r"(c) : "r"(a), "r"(b), "r"(c));
    return c;
}

// ── Tile constants ─────────────────────────────────────────────────────────────
static constexpr int BLOCK_M  = 16;
static constexpr int BLOCK_N  = 16;
static constexpr int BLOCK_K  = 16;   // K per shared-memory tile; must be % 4 == 0
static constexpr int SMEM_PAD = 4;    // extra int8 columns per row to prevent conflicts

__global__ void int8_dp4a(
    const int8_t* __restrict__ A,    // M×K  row-major int8
    const int8_t* __restrict__ BT,   // N×K  row-major int8 (B transposed)
    int32_t*      __restrict__ C,    // M×N  row-major int32
    int M, int N, int K
){
    int batch = blockIdx.z;
    const int8_t* A_b  = A  + batch * M * K;
    const int8_t* BT_b = BT + batch * N * K;
    int32_t*      C_b  = C  + batch * M * N;

    const int ty = threadIdx.y;   // local row  [0, BLOCK_M)
    const int tx = threadIdx.x;   // local col  [0, BLOCK_N)

    const int row = blockIdx.y * BLOCK_M + ty;   // global A row
    const int col = blockIdx.x * BLOCK_N + tx;   // global BT row (= B col)

    // Shared memory: A tile and BT tile.
    // Bs has +SMEM_PAD columns per row to eliminate bank conflicts on Bs[tx][j] reads.
    __shared__ __align__(16) int8_t As[BLOCK_M][BLOCK_K + SMEM_PAD];
    __shared__ __align__(16) int8_t Bs[BLOCK_N][BLOCK_K + SMEM_PAD];

    int32_t acc = 0;

    for (int k = 0; k < K; k += BLOCK_K) {
        // ── Load A tile ───────────────────────────────────────────────────────
        // Thread (ty, tx) loads one int8: A[row][k+tx].
        As[ty][tx] = (row < M && k + tx < K) ? A_b[row * K + k + tx] : int8_t(0);

        // ── Load BT tile ──────────────────────────────────────────────────────
        // BT is N×K row-major.  Thread (ty, tx) loads BT[(block_col+ty)][k+tx].
        // After sync, thread (ty, tx) reads Bs[tx][j] which is BT[col][k+j] —
        // the elements of BT row `col` that it needs for its own inner product.
        int bt_row = blockIdx.x * BLOCK_N + ty;
        Bs[ty][tx] = (bt_row < N && k + tx < K) ? BT_b[bt_row * K + k + tx] : int8_t(0);

        __syncthreads();

        // ── Accumulate: BLOCK_K/4 dp4a calls ─────────────────────────────────
        #pragma unroll
        for (int j = 0; j < BLOCK_K; j += 4) {
            int32_t a_pack = *reinterpret_cast<const int32_t*>(&As[ty][j]);
            int32_t b_pack = *reinterpret_cast<const int32_t*>(&Bs[tx][j]);
            acc = dp4a_s32(a_pack, b_pack, acc);
        }

        __syncthreads();
    }

    // ── Write output ──────────────────────────────────────────────────────────
    if (row < M && col < N)
        C_b[row * N + col] = acc;
}

// ── Launch wrapper ────────────────────────────────────────────────────────────
void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(BLOCK_N, BLOCK_M);   // (16, 16) = 256 threads
    dim3 blocks(
        (cfg.N + BLOCK_N - 1) / BLOCK_N,
        (cfg.M + BLOCK_M - 1) / BLOCK_M,
        cfg.num_batches
    );
    int8_dp4a<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
