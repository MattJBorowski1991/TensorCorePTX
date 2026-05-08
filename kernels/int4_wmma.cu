// int4_wmma.cu
// ── What this kernel does ─────────────────────────────────────────────────────
//  Integer GEMM using CUDA WMMA intrinsics with signed 4-bit inputs:  C = A * B
//    A  : M×K  row-major  INT4  (packed 2 nibbles/byte, low nibble first)
//    B_T: N×K  row-major  INT4  (B stored transposed — col_major matrix_b)
//    C  : M×N  row-major  int32 (full-precision accumulator, no dequant)
//
// ── WMMA shape ────────────────────────────────────────────────────────────────
//  m8n8k32 with experimental::precision::s4. Requires SM72+.
//  Shape differs from INT8 (m16n16k16): tile is smaller in M/N but wider in K.
//  Two nibbles are packed into one byte → K INT4 elements occupy K/2 bytes.
//
// ── Shared memory layout ──────────────────────────────────────────────────────
//  As [2][WARPS][WMMA_M][WMMA_K/2]  int8  — tile of A, packed nibbles, row-major
//  Bs [2][WARPS][WMMA_N][WMMA_K/2]  int8  — tile of B_T, packed nibbles, row-major
//  Row width = WMMA_K/2 = 16 bytes.
//
// ── cp.async transaction size ─────────────────────────────────────────────────
//  16 bytes = 32 INT4 elements = one full row of the tile.
//  WMMA_M=8 rows → 8 transactions per A tile, 8 per B tile.
//
// ── load_matrix_sync stride ───────────────────────────────────────────────────
//  Stride is in INT4 elements (nibbles): WMMA_K = 32.
//
// ── Pipeline ──────────────────────────────────────────────────────────────────
//  2-stage double-buffer (same pattern as int8_wmma.cu).
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <mma.h>
#include <stdint.h>
using namespace nvcuda;
#include "include/config.h"
#include "include/cuda_utils.h"

// Override tile dimensions for INT4 WMMA m8n8k32.
#undef WMMA_M
#define WMMA_M 8
#undef WMMA_N
#define WMMA_N 8
#undef WMMA_K
#define WMMA_K 32

// Byte-width of one row of the tile in packed INT4 storage.
#define K_BYTES (WMMA_K / 2)

__global__ void int4_wmma_db(
    const int8_t* __restrict__ A,    // M×K row-major, packed INT4 (M×K/2 bytes)
    const int8_t* __restrict__ BT,   // N×K row-major, packed INT4 (N×K/2 bytes)
    int32_t*      __restrict__ C,    // M×N row-major int32
    int M, int N, int K
){
    const int batch = blockIdx.z;

    const int8_t* __restrict__ A_b  = A  + batch * M * (K / 2);
    const int8_t* __restrict__ BT_b = BT + batch * N * (K / 2);
    int32_t*      __restrict__ C_b  = C  + batch * M * N;

    const int tid     = threadIdx.x;
    const int warp_id = tid / THREADS_PER_WARP;
    const int lane_id = tid % THREADS_PER_WARP;

    const int warp_tile_row = warp_id / WARP_TILES_X;
    const int warp_tile_col = warp_id % WARP_TILES_X;

    const int tile_row = blockIdx.y * (WMMA_M * WARP_TILES_Y) + warp_tile_row * WMMA_M;
    const int tile_col = blockIdx.x * (WMMA_N * WARP_TILES_X) + warp_tile_col * WMMA_N;
    if (tile_row >= M || tile_col >= N) return;

    // Double-buffered SMEM: rows are K_BYTES bytes wide (packed INT4).
    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][K_BYTES];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][K_BYTES];

    wmma::fragment<wmma::matrix_a, WMMA_M, WMMA_N, WMMA_K,
                   wmma::experimental::precision::s4, wmma::row_major> a_frag;
    // col_major: load_matrix_sync reads element(k, n) as ptr[n * stride + k].
    // Bs is N×K row-major → ptr[n * stride + k] == Bs[n][k]. ✓
    wmma::fragment<wmma::matrix_b, WMMA_M, WMMA_N, WMMA_K,
                   wmma::experimental::precision::s4, wmma::col_major> b_frag;
    wmma::fragment<wmma::accumulator, WMMA_M, WMMA_N, WMMA_K, int32_t> c_frag;
    wmma::fill_fragment(c_frag, 0);

    int buf = 0;

    // ── Prolog: scalar load, tile k=0 ─────────────────────────────────────────
    // Each row of the tile is K_BYTES=16 bytes.  stride by WMMA_M=8 rows → 8 iters,
    // lanes 0-7 each handle one row.
    for (int i = lane_id; i < WMMA_M * K_BYTES; i += THREADS_PER_WARP) {
        const int row      = i / K_BYTES;
        const int byte_col = i % K_BYTES;
        As[buf][warp_id][row][byte_col] = A_b[(tile_row + row) * (K / 2) + byte_col];
    }
    for (int i = lane_id; i < WMMA_N * K_BYTES; i += THREADS_PER_WARP) {
        const int row      = i / K_BYTES;
        const int byte_col = i % K_BYTES;
        Bs[buf][warp_id][row][byte_col] = BT_b[(tile_col + row) * (K / 2) + byte_col];
    }
    __syncthreads();

    // Stride for load_matrix_sync is in INT4 elements = WMMA_K = 32.
    wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K);
    wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_K);

    // ── K loop ────────────────────────────────────────────────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        const int next = 1 - buf;

        // cp.async A: 16 bytes per row = one transaction per row.
        for (int i = lane_id; i < (WMMA_M * K_BYTES) / 16; i += THREADS_PER_WARP) {
            const int row      = (i * 16) / K_BYTES;
            const int byte_col = (i * 16) % K_BYTES;
            char*       dst      = (char*)&As[next][warp_id][row][byte_col];
            const char* src      = (const char*)&A_b[(tile_row + row) * (K / 2) + byte_col + (k / 2)];
            const unsigned dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        for (int i = lane_id; i < (WMMA_N * K_BYTES) / 16; i += THREADS_PER_WARP) {
            const int row      = (i * 16) / K_BYTES;
            const int byte_col = (i * 16) % K_BYTES;
            char*       dst      = (char*)&Bs[next][warp_id][row][byte_col];
            const char* src      = (const char*)&BT_b[(tile_col + row) * (K / 2) + byte_col + (k / 2)];
            const unsigned dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        wmma::mma_sync(c_frag, a_frag, b_frag, c_frag);

        asm volatile("cp.async.wait_group 0;");
        __syncthreads();

        buf = next;
        wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K);
        wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_K);
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
    int4_wmma_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
