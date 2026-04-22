// int8_wmma.cu
// ── What this kernel does ──────────────────────────────────────────────────────
//  Integer GEMM using CUDA WMMA intrinsics:  C = A * B
//    A  : M×K row-major  int8  (unchanged layout vs FP16 variant)
//    B_T: N×K row-major  int8  (B stored transposed — required because WMMA
//                               matrix_b for INT8 must be col_major, and a
//                               K×N matrix stored col-major == N×K row-major)
//    C  : M×N row-major  int32 (full-precision accumulator)
//
// ── WMMA shape ────────────────────────────────────────────────────────────────
//  m16n16k16 with int8_t A (row_major), int8_t B (col_major=B_T), int32 acc.
//  Same tile dimensions as the FP16 WMMA baseline — WMMA_M/N/K stay 16.
//
// ── Shared memory layout ──────────────────────────────────────────────────────
//  As [2][WARPS][16][16]  int8   —  tile of A (M×K), row-major
//  Bs [2][WARPS][16][16]  int8   —  tile of B_T (N×K), row-major
//  B_T stored N×K in SMEM → same memory order as a K×N col-major matrix
//  with leading_dim = K, matching the col_major load_matrix_sync stride.
//
// ── cp.async transaction size ─────────────────────────────────────────────────
//  16 bytes = 16 int8 elements.  One 16×16 int8 tile = 256 bytes = 16 transactions.
//  With WMMA_K=16, each row of the tile is exactly 16 bytes → one transaction
//  per row, col offset is always 0 inside the loop.
//
// ── Pipeline ──────────────────────────────────────────────────────────────────
//  2-stage double-buffer (identical structure to fp16_wmma.cu):
//    prolog scalar load → ldmatrix → K-loop { cp.async | mma | wait | ldmatrix }
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <mma.h>
#include <stdint.h>
using namespace nvcuda;
#include "include/config.h"
#include "include/cuda_utils.h"

__global__ void int8_wmma_db(
    const int8_t* __restrict__ A,    // M×K row-major
    const int8_t* __restrict__ BT,   // N×K row-major  (transposed B)
    int32_t*      __restrict__ C,    // M×N row-major
    int M, int N, int K
){
    int batch = blockIdx.z;

    const int8_t* __restrict__ A_b  = A  + batch * M * K;
    const int8_t* __restrict__ BT_b = BT + batch * N * K;
    int32_t*      __restrict__ C_b  = C  + batch * M * N;

    const int tid     = threadIdx.x;
    const int warp_id = tid / THREADS_PER_WARP;
    const int lane_id = tid % THREADS_PER_WARP;

    const int warp_tile_row = warp_id / WARP_TILES_X;
    const int warp_tile_col = warp_id % WARP_TILES_X;

    const int tile_row = blockIdx.y * (WMMA_M * WARP_TILES_Y) + warp_tile_row * WMMA_M;
    const int tile_col = blockIdx.x * (WMMA_N * WARP_TILES_X) + warp_tile_col * WMMA_N;
    if (tile_row >= M || tile_col >= N) return;

    // Double-buffered SMEM.
    // As: M×K int8 tile (row-major, stride = WMMA_K + PAD).
    // Bs: N×K int8 tile (row-major for BT, same memory order as K×N col-major
    //     with ld = WMMA_K + PAD — matches the col_major load_matrix_sync stride).
    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][WMMA_K + PAD];

    wmma::fragment<wmma::matrix_a, WMMA_M, WMMA_N, WMMA_K, int8_t, wmma::row_major> a_frag;
    // col_major: load_matrix_sync(b_frag, ptr, stride) reads element(k, n) from ptr[n*stride + k].
    // Our Bs is N×K row-major → element(n, k) = ptr[n*stride + k]. Identical memory order. ✓
    wmma::fragment<wmma::matrix_b, WMMA_M, WMMA_N, WMMA_K, int8_t, wmma::col_major> b_frag;
    wmma::fragment<wmma::accumulator, WMMA_M, WMMA_N, WMMA_K, int32_t> c_frag;
    wmma::fill_fragment(c_frag, 0);

    int buf = 0;

    // ── Prolog: scalar load, tile k=0 ─────────────────────────────────────────
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_N * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        Bs[buf][warp_id][row][col] = BT_b[(tile_col + row) * K + col];
    }
    __syncthreads();

    wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K + PAD);
    wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_K + PAD);

    // ── K loop ────────────────────────────────────────────────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // cp.async A: 16 bytes = 16 int8 elements = one full row of the 16×16 tile.
        // With WMMA_K=16, col is always 0 in this loop.
        for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP) {
            int elem     = i * 16;
            int row      = elem / WMMA_K, col = elem % WMMA_K;
            char*       dst      = (char*)&As[next][warp_id][row][col];
            const char* src      = (const char*)&A_b[(tile_row + row) * K + (col + k)];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        // cp.async BT: same, loading rows of the N×K BT tile.
        for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP) {
            int elem     = i * 16;
            int row      = elem / WMMA_K, col = elem % WMMA_K;
            char*       dst      = (char*)&Bs[next][warp_id][row][col];
            const char* src      = (const char*)&BT_b[(tile_col + row) * K + (col + k)];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        wmma::mma_sync(c_frag, a_frag, b_frag, c_frag);

        asm volatile("cp.async.wait_group 0;");

        buf = next;
        wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K + PAD);
        wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_K + PAD);
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    wmma::mma_sync(c_frag, a_frag, b_frag, c_frag);

    // ── Store ─────────────────────────────────────────────────────────────────
    int32_t* c_dst = C_b + tile_row * N + tile_col;
    wmma::store_matrix_sync(c_dst, c_frag, N, wmma::mem_row_major);
}

// ── Launch wrapper ────────────────────────────────────────────────────────────
void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    int8_wmma_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
