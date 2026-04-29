// int8_ptx_3stage.cu
// ── What changed vs int8_ptx_mma_k16.cu (2-stage) ────────────────────────────
//  Shared mem  : As/Bs[2][...] → As/Bs[3][...]  (third SRAM buffer)
//  Prolog      : scalar store + __syncthreads for buf=0
//              → cp.async for buf=0 AND buf=1, commit each, wait_group 1
//  Main loop   : prefetch k → commit → compute → wait_group 0 (2-stage)
//              → prefetch k → commit → compute → wait_group 1 (3-stage)
//                (allows 1 group still in-flight during compute)
//  Epilogue    : 1 compute + drain (wait_group 0) + reload + 1 compute
//
// ── What changed vs fp16_ptx_3stage.cu ───────────────────────────────────────
//  Types       : half → int8_t (A, BT); float → int32_t (C/D)
//  SMEM B      : half[K][N] → int8_t[N][K]  (BT layout: N×K row-major)
//  ldmatrix A  : x4 → x2 (ra[2] for int8 16×16 = 2 m8n8 b16 tiles)
//  ldmatrix B  : x2.trans → x1.trans (rb[1] for int8 8×16)
//  MMA opcode  : m16n8k16.f32.f16.f16.f32 → m16n8k16.s32.s8.s8.s32
//  Accumulators: float rc[4] → int32_t rc[4]
//  Prolog cp.async loop: 8*lane stride (fp16, 512B) → lane stride (int8, 256B)
//
// ── Shared memory size (INT8) ─────────────────────────────────────────────────
//  WARPS_PER_BLOCK=8, WMMA_M/K/N=16, PAD=0, dtype=int8_t (1B)
//  As: 3 * 8 * 16 * 16 * 1 =  6144 B
//  Bs: 3 * 8 * 16 * 16 * 1 =  6144 B  →  ~12 KB total (vs 24 KB for FP16)
//
// ── Group accounting (identical to fp16_ptx_3stage) ──────────────────────────
//  Prolog:   commit(0) → commit(1) → wait_group 1  → ≤1 group in flight
//  Loop:     commit(k) → compute → wait_group 1    → ≤1 group in flight
//  Epilogue: compute penultimate → wait_group 0 → reload+compute last
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── ldmatrix / mma helpers — identical to int8_ptx_mma_k16.cu ─────────────────

__device__ __forceinline__
void ldmatrix_a(uint32_t ra[2], const int8_t smem[][WMMA_K + PAD], int lane) {
    int r = lane % 16;
    uint32_t addr = __cvta_generic_to_shared(&smem[r][0]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x2.shared.b16 {%0,%1}, [%2];"
        : "=r"(ra[0]), "=r"(ra[1])
        : "r"(addr));
}

__device__ __forceinline__
void ldmatrix_b(uint32_t rb[1], const int8_t smem[][WMMA_K + PAD], int lane, int n_base) {
    int r = n_base + (lane % 8);
    uint32_t addr = __cvta_generic_to_shared(&smem[r][0]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x1.shared.b16 {%0}, [%1];"
        : "=r"(rb[0])
        : "r"(addr));
}

__device__ __forceinline__
void mma_int8(int32_t rc[4], const uint32_t ra[2], const uint32_t rb[1]) {
    int c0 = rc[0], c1 = rc[1], c2 = rc[2], c3 = rc[3];
    asm volatile(
        "mma.sync.aligned.m16n8k16.row.col.s32.s8.s8.s32 "
                "{%0,%1,%2,%3}, {%4,%5}, {%6}, {%7,%8,%9,%10};"
                : "=r"(c0), "=r"(c1), "=r"(c2), "=r"(c3)
        : "r"(ra[0]),  "r"(ra[1]),
                    "r"(rb[0]),
                    "r"(c0),  "r"(c1),  "r"(c2),  "r"(c3));
    rc[0] = c0; rc[1] = c1; rc[2] = c2; rc[3] = c3;
}

// ── cp_async16 helper — identical to fp16_ptx_3stage.cu ─────────────────────
__device__ __forceinline__ void cp_async16(void* dst, const void* src) {
    unsigned dst_addr = __cvta_generic_to_shared(dst);
    asm volatile("cp.async.ca.shared.global [%0], [%1], 16;"
                 :: "r"(dst_addr), "l"(src));
}

__global__ void int8_ptx_3stage(
    const int8_t* __restrict__ A,    // M×K  row-major int8
    const int8_t* __restrict__ BT,   // N×K  row-major int8 (B transposed)
    int32_t*      __restrict__ C,    // M×N  row-major int32
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

    // ── 3 shared memory buffers ───────────────────────────────────────────────
    // As: int8_t M×K tile.  Bs: int8_t BT N×K tile (N rows, K cols).
    __shared__ __align__(16) int8_t As[3][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) int8_t Bs[3][WARPS_PER_BLOCK][WMMA_N][WMMA_K + PAD];

    int32_t rc0[4] = {0, 0, 0, 0};   // output cols 0-7
    int32_t rc1[4] = {0, 0, 0, 0};   // output cols 8-15

    // ── Prolog: async-fill stages 0 and 1 ────────────────────────────────────
    // INT8 tile = 16×16×1 = 256 bytes = 16 × 16B transactions.
    // Stride = THREADS_PER_WARP = 32 → lanes 0-15 each issue 1 transaction.

    // Stage 0: k-offset = 0
    for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP)
        cp_async16(&As[0][warp_id][i][0], &A_b[(tile_row + i) * K + 0]);
    for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP)
        cp_async16(&Bs[0][warp_id][i][0], &BT_b[(tile_col + i) * K + 0]);
    asm volatile("cp.async.commit_group;");   // group 0 in flight

    // Stage 1: k-offset = WMMA_K
    for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP)
        cp_async16(&As[1][warp_id][i][0], &A_b[(tile_row + i) * K + WMMA_K]);
    for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP)
        cp_async16(&Bs[1][warp_id][i][0], &BT_b[(tile_col + i) * K + WMMA_K]);
    asm volatile("cp.async.commit_group;");   // group 1 in flight (2 total)

    // Wait for group 0; group 1 may remain in flight — this is the 3-stage slack.
    asm volatile("cp.async.wait_group 1;");

    // Load fragments from stage 0
    uint32_t ra[2], rb0[1], rb1[1];
    ldmatrix_a(ra,  As[0][warp_id], lane_id);
    ldmatrix_b(rb0, Bs[0][warp_id], lane_id, 0);
    ldmatrix_b(rb1, Bs[0][warp_id], lane_id, 8);

    int buf = 0;

    // ── Main K loop ───────────────────────────────────────────────────────────
    // Invariant entering each iteration:
    //   fragments = tile `buf`, 1 group in-flight for tile `(buf+1)%3`.
    //   `(buf+2)%3` is free to write (its last load is being computed).
    for (int k = 2 * WMMA_K; k < K; k += WMMA_K) {
        int next         = (buf + 1) % 3;
        int prefetch_buf = (buf + 2) % 3;

        // Prefetch tile k into prefetch_buf
        for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP)
            cp_async16(&As[prefetch_buf][warp_id][i][0], &A_b[(tile_row + i) * K + k]);
        for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP)
            cp_async16(&Bs[prefetch_buf][warp_id][i][0], &BT_b[(tile_col + i) * K + k]);
        asm volatile("cp.async.commit_group;");   // now 2 groups in flight

        // Compute on current fragments (tile buf)
        mma_int8(rc0, ra, rb0);
        mma_int8(rc1, ra, rb1);

        // Wait until ≤1 group in flight — guarantees `next` is ready.
        // prefetch_buf (just committed) may still be loading.
        asm volatile("cp.async.wait_group 1;");

        buf = next;
        ldmatrix_a(ra,  As[buf][warp_id], lane_id);
        ldmatrix_b(rb0, Bs[buf][warp_id], lane_id, 0);
        ldmatrix_b(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    // ── Epilogue ──────────────────────────────────────────────────────────────
    // Fragments = second-to-last tile, 1 group in flight (last tile).

    // Compute second-to-last tile
    mma_int8(rc0, ra, rb0);
    mma_int8(rc1, ra, rb1);

    // Drain the last in-flight group
    asm volatile("cp.async.wait_group 0;");

    // Load and compute last tile
    buf = (buf + 1) % 3;
    ldmatrix_a(ra,  As[buf][warp_id], lane_id);
    ldmatrix_b(rb0, Bs[buf][warp_id], lane_id, 0);
    ldmatrix_b(rb1, Bs[buf][warp_id], lane_id, 8);
    mma_int8(rc0, ra, rb0);
    mma_int8(rc1, ra, rb1);

    // ── Epilogue scatter — identical to int8_ptx_mma_k16 ─────────────────────
    int32_t* c_dst = C_b + tile_row * N + tile_col;
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

// ── Launch wrapper ────────────────────────────────────────────────────────────
void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    int8_ptx_3stage<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
