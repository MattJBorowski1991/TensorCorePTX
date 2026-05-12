// int4_ptx_mma_k64.cu
// True-k64 INT4 PTX kernel:
// - Uses native ldmatrix.x4 for A (16x64 int4 tile packed as 16x16 b16)
// - Uses native ldmatrix.x1 x2 for each B n8-half (8x64 int4 tile packed as 8x16 b16)
// - Uses native mma.sync.aligned.m16n8k64.row.col.s32.s4.s4.s32

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"

// Extend K tile from 16 -> 64 for this variant.
#undef WMMA_K
#define WMMA_K 64

#include "include/cuda_utils.h"

// Packed INT4 row width in bytes.
#define K_BYTES (WMMA_K / 2)

__device__ __forceinline__
void ldmatrix_a_k64(uint32_t ra[4], const int8_t smem[][K_BYTES + PAD], int lane) {
    const int r = (lane % 8) + (lane / 16) * 8;
    const int c = ((lane / 8) % 2) * 16;
    uint32_t t0, t1, t2, t3;
    const uint32_t addr = __cvta_generic_to_shared(&smem[r][c]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x4.shared.b16 {%0,%1,%2,%3}, [%4];"
        : "=r"(t0), "=r"(t1), "=r"(t2), "=r"(t3)
        : "r"(addr));
    // Keep the same x4 re-order used by the proven int8 true-k32 path.
    ra[0] = t0;
    ra[1] = t2;
    ra[2] = t1;
    ra[3] = t3;
}

__device__ __forceinline__
void ldmatrix_b_k64(uint32_t rb[2], const int8_t smem[][K_BYTES + PAD], int lane, int n_base) {
    const int r = n_base + (lane % 8);
    const uint32_t addr_l = __cvta_generic_to_shared(&smem[r][0]);
    const uint32_t addr_r = __cvta_generic_to_shared(&smem[r][16]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x1.shared.b16 {%0}, [%1];"
        : "=r"(rb[0])
        : "r"(addr_l));
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x1.shared.b16 {%0}, [%1];"
        : "=r"(rb[1])
        : "r"(addr_r));
}

__device__ __forceinline__
void mma_int4_k64(int32_t rc[4], const uint32_t ra[4], const uint32_t rb[2]) {
    int c0 = rc[0], c1 = rc[1], c2 = rc[2], c3 = rc[3];
    asm volatile(
        "mma.sync.aligned.m16n8k64.row.col.s32.s4.s4.s32 "
        "{%0,%1,%2,%3}, {%4,%5,%6,%7}, {%8,%9}, {%0,%1,%2,%3};"
        : "+r"(c0), "+r"(c1), "+r"(c2), "+r"(c3)
        : "r"(ra[0]), "r"(ra[1]), "r"(ra[2]), "r"(ra[3]),
          "r"(rb[0]), "r"(rb[1]));
    rc[0] = c0;
    rc[1] = c1;
    rc[2] = c2;
    rc[3] = c3;
}

__global__ void int4_ptx_mma_k64_db(
    const int8_t* __restrict__ A,    // MxK packed INT4 (MxK/2 bytes)
    const int8_t* __restrict__ BT,   // NxK packed INT4 (NxK/2 bytes)
    int32_t*      __restrict__ C,    // MxN int32
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

    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][K_BYTES + PAD];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][K_BYTES + PAD];

    int32_t rc0[4] = {0, 0, 0, 0};
    int32_t rc1[4] = {0, 0, 0, 0};
    int buf = 0;

    // Prolog: scalar load first K-slice (64 int4 = 32 bytes per row).
    for (int i = lane_id; i < WMMA_M * K_BYTES; i += THREADS_PER_WARP) {
        const int row = i / K_BYTES;
        const int byte_col = i % K_BYTES;
        As[buf][warp_id][row][byte_col] = A_b[(tile_row + row) * (K / 2) + byte_col];
    }
    for (int i = lane_id; i < WMMA_N * K_BYTES; i += THREADS_PER_WARP) {
        const int n = i / K_BYTES;
        const int byte_col = i % K_BYTES;
        Bs[buf][warp_id][n][byte_col] = BT_b[(tile_col + n) * (K / 2) + byte_col];
    }
    __syncthreads();

    uint32_t ra[4], rb0[2], rb1[2];
    ldmatrix_a_k64(ra,  As[buf][warp_id], lane_id);
    ldmatrix_b_k64(rb0, Bs[buf][warp_id], lane_id, 0);
    ldmatrix_b_k64(rb1, Bs[buf][warp_id], lane_id, 8);

    // K loop: step by 64 int4 elements => 32 bytes per row.
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        const int next = 1 - buf;

        for (int i = lane_id; i < (WMMA_M * K_BYTES) / 16; i += THREADS_PER_WARP) {
            const int row = (i * 16) / K_BYTES;
            const int byte_col = (i * 16) % K_BYTES;
            char*       dst      = (char*)&As[next][warp_id][row][byte_col];
            const char* src      = (const char*)&A_b[(tile_row + row) * (K / 2) + byte_col + (k / 2)];
            const unsigned dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        for (int i = lane_id; i < (WMMA_N * K_BYTES) / 16; i += THREADS_PER_WARP) {
            const int n = (i * 16) / K_BYTES;
            const int byte_col = (i * 16) % K_BYTES;
            char*       dst      = (char*)&Bs[next][warp_id][n][byte_col];
            const char* src      = (const char*)&BT_b[(tile_col + n) * (K / 2) + byte_col + (k / 2)];
            const unsigned dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        mma_int4_k64(rc0, ra, rb0);
        mma_int4_k64(rc1, ra, rb1);

        asm volatile("cp.async.wait_group 0;");
        __syncthreads();

        buf = next;
        ldmatrix_a_k64(ra,  As[buf][warp_id], lane_id);
        ldmatrix_b_k64(rb0, Bs[buf][warp_id], lane_id, 0);
        ldmatrix_b_k64(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    mma_int4_k64(rc0, ra, rb0);
    mma_int4_k64(rc1, ra, rb1);

    // D-fragment scatter for m16n8 shape; rc0 is cols 0..7, rc1 is cols 8..15.
    int32_t* c_dst = C_b + tile_row * N + tile_col;
    const int out_row0 = lane_id / 4;
    const int out_row1 = out_row0 + 8;
    const int out_col0 = (lane_id % 4) * 2;
    const int out_col1 = out_col0 + 1;

    c_dst[out_row0 * N + out_col0]     = rc0[0];
    c_dst[out_row0 * N + out_col1]     = rc0[1];
    c_dst[out_row1 * N + out_col0]     = rc0[2];
    c_dst[out_row1 * N + out_col1]     = rc0[3];

    c_dst[out_row0 * N + out_col0 + 8] = rc1[0];
    c_dst[out_row0 * N + out_col1 + 8] = rc1[1];
    c_dst[out_row1 * N + out_col0 + 8] = rc1[2];
    c_dst[out_row1 * N + out_col1 + 8] = rc1[3];
}

void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    int4_ptx_mma_k64_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
