// int4_ptx_manual_pack.cu
// INT4 PTX kernel with manual SRAM->register packing (no ldmatrix):
// - A/B are packed INT4 in bytes (2 nibbles per byte)
// - Scalar shared loads + byte-pack into uint32 MMA operands
// - mma.sync.aligned.m16n8k32.row.col.s32.s4.s4.s32

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"

// Use k32 step so each operand register holds one 4-byte chunk (8 int4 values).
#undef WMMA_K
#define WMMA_K 32

#include "include/cuda_utils.h"

#define K_BYTES (WMMA_K / 2)

__device__ __forceinline__ uint32_t pack_u8x4(int8_t b0, int8_t b1, int8_t b2, int8_t b3) {
    // Preserve byte values exactly (nibbles are interpreted by mma.s4 later).
    uint32_t u0 = (uint32_t)(uint8_t)b0;
    uint32_t u1 = (uint32_t)(uint8_t)b1;
    uint32_t u2 = (uint32_t)(uint8_t)b2;
    uint32_t u3 = (uint32_t)(uint8_t)b3;
    return (u0) | (u1 << 8) | (u2 << 16) | (u3 << 24);
}

// Fill A fragment for mma.m16n8k32.s4 from scalar shared loads.
__device__ __forceinline__
void manual_pack_a_k32(uint32_t ra[2], const int8_t smem[][K_BYTES + PAD], int lane) {
    const int row0 = lane / 4;           // rows 0..7
    const int row1 = row0 + 8;           // rows 8..15
    const int bcol = (lane % 4) * 4;     // 4 bytes = 8 int4 values

    ra[0] = pack_u8x4(smem[row0][bcol + 0], smem[row0][bcol + 1],
                      smem[row0][bcol + 2], smem[row0][bcol + 3]);
    ra[1] = pack_u8x4(smem[row1][bcol + 0], smem[row1][bcol + 1],
                      smem[row1][bcol + 2], smem[row1][bcol + 3]);
}

// Fill B fragment for one n8 half (n_base 0 or 8).
__device__ __forceinline__
void manual_pack_b_k32(uint32_t rb[1], const int8_t smem[][K_BYTES + PAD], int lane, int n_base) {
    const int n    = n_base + (lane / 4);  // rows in BT tile
    const int bcol = (lane % 4) * 4;

    rb[0] = pack_u8x4(smem[n][bcol + 0], smem[n][bcol + 1],
                      smem[n][bcol + 2], smem[n][bcol + 3]);
}

__device__ __forceinline__
void mma_int4_k32(int32_t rc[4], const uint32_t ra[2], const uint32_t rb[1]) {
    int c0 = rc[0], c1 = rc[1], c2 = rc[2], c3 = rc[3];
    asm volatile(
        "mma.sync.aligned.m16n8k32.row.col.s32.s4.s4.s32 "
        "{%0,%1,%2,%3}, {%4,%5}, {%6}, {%0,%1,%2,%3};"
        : "+r"(c0), "+r"(c1), "+r"(c2), "+r"(c3)
        : "r"(ra[0]), "r"(ra[1]), "r"(rb[0]));
    rc[0] = c0;
    rc[1] = c1;
    rc[2] = c2;
    rc[3] = c3;
}

__global__ void int4_manual_pack_db(
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

    // Prolog: scalar load first K-slice (32 int4 = 16 bytes per row).
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

    uint32_t ra[2], rb0[1], rb1[1];
    manual_pack_a_k32(ra,  As[buf][warp_id], lane_id);
    manual_pack_b_k32(rb0, Bs[buf][warp_id], lane_id, 0);
    manual_pack_b_k32(rb1, Bs[buf][warp_id], lane_id, 8);

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

        mma_int4_k32(rc0, ra, rb0);
        mma_int4_k32(rc1, ra, rb1);

        asm volatile("cp.async.wait_group 0;");

        buf = next;
        manual_pack_a_k32(ra,  As[buf][warp_id], lane_id);
        manual_pack_b_k32(rb0, Bs[buf][warp_id], lane_id, 0);
        manual_pack_b_k32(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    mma_int4_k32(rc0, ra, rb0);
    mma_int4_k32(rc1, ra, rb1);

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
    int4_manual_pack_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
