#include <cuda_runtime.h>
#include <mma.h>
using namespace nvcuda;
#include "include/config.h"
#include "include/cuda_utils.h"


__global__ void wmma_db(
    const half* __restrict__ A,
    const half* __restrict__ B,
    float* __restrict__ C,
    int M, int N, int K
){
    int batch = blockIdx.z;

    const half* __restrict__ A_b = A + batch * M * K;
    const half* __restrict__ B_b = B + batch * K * N;
    float* __restrict__ C_b = C + batch * M * N;

    const int tid = threadIdx.x;
    const int warp_id = tid / THREADS_PER_WARP;
    const int lane_id = tid % THREADS_PER_WARP;

    const int warp_tile_row = warp_id / WARP_TILES_X;
    const int warp_tile_col = warp_id % WARP_TILES_X;

    const int tile_row = blockIdx.y * (WMMA_M * WARP_TILES_Y) + warp_tile_row * WMMA_M;
    const int tile_col = blockIdx.x * (WMMA_N * WARP_TILES_X) + warp_tile_col * WMMA_N;
    if(tile_row >= M || tile_col >= N) return;

    __shared__ __align__(16) half As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) half Bs[2][WARPS_PER_BLOCK][WMMA_K][WMMA_N + PAD];

    wmma::fragment<wmma::matrix_a, WMMA_M, WMMA_N, WMMA_K, half, wmma::row_major> a_frag;
    wmma::fragment<wmma::matrix_b, WMMA_M, WMMA_N, WMMA_K, half, wmma::row_major> b_frag;
    wmma::fragment<wmma::accumulator, WMMA_M, WMMA_N, WMMA_K, float> c_frag;
    wmma::fill_fragment(c_frag, 0.0f);

    int buf = 0;

    for(int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP){
        int row = i / WMMA_K, col = i % WMMA_K;
            As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for(int i = lane_id; i < WMMA_K * WMMA_N; i += THREADS_PER_WARP){
        int row = i / WMMA_N, col = i % WMMA_N;
            Bs[buf][warp_id][row][col] = B_b[row * N + (tile_col + col)];
    }
    __syncthreads();

    wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K + PAD);
    wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_N + PAD);

    for(int k = WMMA_K; k < K; k += WMMA_K){
        int next = 1 - buf;

        for(int i = 8* lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP){
            int row = i / WMMA_K, col = i % WMMA_K;
            char* dst = (char*)&As[next][warp_id][row][col];
            const char* src = (const char*)&A_b[(tile_row + row) * K + (col + k)];
            unsigned dst_smem_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_smem_addr), "l"(src));
        }

        for(int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP){
            int row = i / WMMA_N, col = i % WMMA_N;
            char* dst = (char*)&Bs[next][warp_id][row][col];
            const char* src = (const char*)&B_b[(row + k) * N + tile_col + col];
            unsigned dst_smem_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_smem_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        wmma::mma_sync(c_frag, a_frag, b_frag, c_frag);
        asm volatile("cp.async.wait_group 0;");

        buf = next;
        wmma::load_matrix_sync(a_frag, &As[buf][warp_id][0][0], WMMA_K + PAD);
        wmma::load_matrix_sync(b_frag, &Bs[buf][warp_id][0][0], WMMA_N + PAD);
    }

    wmma::mma_sync(c_frag, a_frag, b_frag, c_frag);

    float* c_dst = C_b + tile_row * N + tile_col;

    wmma::store_matrix_sync(c_dst, c_frag, N, wmma::mem_row_major);
}

// ── Kernel launch wrapper ─────────────────────────────────────────────────────
// Called by Solver::run(); one definition per build target.
void launch_kernel(const half* A, const half* B, float* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    wmma_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
