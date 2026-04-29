// int8_ptx_mma_k16.cu
// ── What changed vs int8_wmma.cu ─────────────────────────────────────────────
//  SRAM→regs    : wmma::load_matrix_sync  →  ldmatrix.sync PTX
//  Compute      : wmma::mma_sync          →  mma.sync.aligned.m16n8k16 PTX
//                 mma.sync N=8; 2 calls per K-step to cover the 16-col warp tile
//  Epilogue     : wmma::store_matrix_sync →  direct scatter using D-fragment layout
//
// ── What changed vs fp16_ptx_mma.cu ─────────────────────────────────────────
//  Types        : half → int8_t (A, B); float → int32_t (C)
//  SMEM B layout: half As[K][N] (B row-major) → int8_t Bs[N][K] (BT row-major)
//                 This is required because WMMA/mma.sync INT8 B must be col-major.
//                 BT stored as N×K row-major == K×N col-major in memory.
//  Accumulators : float rc[4]  →  int32_t rc[4] (exact integer, no rounding)
//  Framents     : A: ldmatrix.x4 (fp16) → ldmatrix.x2 (int8, half the data)
//                 B: ldmatrix.x2.trans  → ldmatrix.x1.trans
//  MMA opcode   : m16n8k16.row.col.f32.f16.f16.f32
//              →  m16n8k16.row.col.s32.s8.s8.s32
//  Epilogue     : float store → int32 store (no dequant in kernel)
//
// ── PTX fragment sizes (per thread, mma.sync.m16n8k16 s32 acc) ───────────────
//  A  (m16 × k16):  2 × uint32  (each uint32 packs 4 × int8)
//  B  (k16 × n8) :  1 × uint32  (4 × int8 packed)
//  D  (m16 × n8) :  4 × int32
//
// ── D-layout (mma.sync.m16n8k16, s32 accumulator) ────────────────────────────
//  Identical spatial mapping to the f32 accumulator variant:
//  Thread t owns:
//    rc[0] → row = t/4,     col = (t%4)*2
//    rc[1] → row = t/4,     col = (t%4)*2 + 1
//    rc[2] → row = t/4 + 8, col = (t%4)*2
//    rc[3] → row = t/4 + 8, col = (t%4)*2 + 1
//
// ── ldmatrix addressing (INT8) ───────────────────────────────────────────────
//  ldmatrix always operates on b16 units (2 bytes). For int8 tiles, adjacent
//  int8 pairs are treated as one b16 element. Each m8n8 tile = 8 rows × 8 b16
//  elements = 128 bytes. Fragment sizes halve vs FP16 since int8 is half as wide.
//
//  LDMATRIX_A (ldmatrix.x2, 2 m8n8 b16 tiles = 256 bytes = 16×16 int8 tile):
//    Lanes 0-15 each supply one row address; lanes 16-31 are don't-care (mirrored).
//    _r = lane%16,  _c = 0
//
//  LDMATRIX_B (ldmatrix.x1.trans, 1 m8n8 b16 tile = 128 bytes = 8×16 int8 chunk):
//    Loads one n8 half of BT stored as SMEM[n8_row][k16_col].
//    Lanes 0-7 supply row addresses; lanes 8-31 are don't-care.
//    _r = n_base + lane%8,  _c = 0
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── ldmatrix macros ───────────────────────────────────────────────────────────

// ── ldmatrix / mma helpers ──────────────────────────────────────────────────────

// Load A: 16×16 int8 tile from SMEM into 2 uint32 registers (ldmatrix.x2).
// Lanes 0-15 each supply one row address; lanes 16-31 are don't-care (mirrored).
__device__ __forceinline__
void ldmatrix_a(uint32_t ra[2], const int8_t smem[][WMMA_K + PAD], int lane) {
    int r = lane % 16;
    uint32_t addr = __cvta_generic_to_shared(&smem[r][0]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x2.shared.b16 {%0,%1}, [%2];"
        : "=r"(ra[0]), "=r"(ra[1])
        : "r"(addr));
}

// Load one n8 half of BT: 8×16 int8 chunk into 1 uint32 (ldmatrix.x1.trans).
// Lanes 0-7 supply row addresses; lanes 8-31 are don't-care.
__device__ __forceinline__
void ldmatrix_b(uint32_t rb[1], const int8_t smem[][WMMA_K + PAD], int lane, int n_base) {
    int r = n_base + (lane % 8);
    uint32_t addr = __cvta_generic_to_shared(&smem[r][0]);
    asm volatile(
        "ldmatrix.sync.aligned.m8n8.x1.shared.b16 {%0}, [%1];"
        : "=r"(rb[0])
        : "r"(addr));
}

// D[4] += A[2] * B[1]  (mma.sync.m16n8k16, INT8→INT32 accumulation, in-place)
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

__global__ void int8_ptx_mma_k16_db(
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

    // ── Shared memory ─────────────────────────────────────────────────────────
    // As: M×K int8 tile (row-major).
    // Bs: BT tile stored as N×K int8 (row-major), = K×N col-major for mma.sync B.
    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][WMMA_K + PAD];

    // ── Accumulators: 2 mma tiles cover the 16×16 warp output ────────────────
    // rc0: output cols 0..7,  rc1: output cols 8..15
    int32_t rc0[4] = {0, 0, 0, 0};
    int32_t rc1[4] = {0, 0, 0, 0};

    int buf = 0;

    // ── Prolog: scalar load, tile k=0 ─────────────────────────────────────────
    // A tile: M×K = 16×16 int8 = 256 bytes. 16 transactions of 16 bytes.
    // Lanes 0-15 each load one full row (16 int8 = 16 bytes).
    for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP) {
        int row = i, col = 0;   // WMMA_K=16, so each i is one full row
        for (int j = 0; j < WMMA_K; ++j)
            As[buf][warp_id][row][j] = A_b[(tile_row + row) * K + col + j];
    }
    // BT tile: N×K = 16×16 int8 = 256 bytes. Same 16-lane pattern.
    for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP) {
        int n = i, k = 0;
        for (int j = 0; j < WMMA_K; ++j)
            Bs[buf][warp_id][n][j] = BT_b[(tile_col + n) * K + k + j];
    }
    __syncthreads();

    // ── Load first fragments via ldmatrix ─────────────────────────────────────
    uint32_t ra[2], rb0[1], rb1[1];
    ldmatrix_a(ra,  As[buf][warp_id], lane_id);
    ldmatrix_b(rb0, Bs[buf][warp_id], lane_id, 0);   // BT rows 0-7  → B cols 0-7
    ldmatrix_b(rb1, Bs[buf][warp_id], lane_id, 8);   // BT rows 8-15 → B cols 8-15
    if (M == 16 && N == 16 && K == 16 && blockIdx.x == 0 && blockIdx.y == 0 && blockIdx.z == 0 &&
        warp_id == 0 && lane_id < 16) {
        printf("[ldm] lane=%2d ra0=%08x ra1=%08x rb0=%08x rb1=%08x\n",
               lane_id, ra[0], ra[1], rb0[0], rb1[0]);
    }

    // ── Main K loop ───────────────────────────────────────────────────────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // cp.async A: 16 bytes per transaction = one full int8 row (WMMA_K=16).
        for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP) {
            char*       dst      = (char*)&As[next][warp_id][i][0];
            const char* src      = (const char*)&A_b[(tile_row + i) * K + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        // cp.async BT: 16 bytes per transaction = one full BT row.
        for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP) {
            char*       dst      = (char*)&Bs[next][warp_id][i][0];
            const char* src      = (const char*)&BT_b[(tile_col + i) * K + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        mma_int8(rc0, ra, rb0);   // cols 0-7
        mma_int8(rc1, ra, rb1);   // cols 8-15

        asm volatile("cp.async.wait_group 0;");
        __syncthreads();  // Ensure SMEM visibility across warps before ldmatrix

        buf = next;
        ldmatrix_a(ra,  As[buf][warp_id], lane_id);
        ldmatrix_b(rb0, Bs[buf][warp_id], lane_id, 0);
        ldmatrix_b(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    mma_int8(rc0, ra, rb0);
    mma_int8(rc1, ra, rb1);

    // ── Epilogue: scatter D-fragment to global (int32, no dequant) ───────────
    // D-layout identical to fp32 accumulator: thread t owns 4 elements:
    //   rc[0] → (t/4,   (t%4)*2)      rc[1] → (t/4,   (t%4)*2+1)
    //   rc[2] → (t/4+8, (t%4)*2)      rc[3] → (t/4+8, (t%4)*2+1)
    int32_t* c_dst = C_b + tile_row * N + tile_col;
    int out_row0 = lane_id / 4;
    int out_row1 = out_row0 + 8;
    int out_col0 = (lane_id % 4) * 2;
    int out_col1 = out_col0 + 1;

    // rc0 → cols 0-7
    c_dst[out_row0 * N + out_col0]     = rc0[0];
    c_dst[out_row0 * N + out_col1]     = rc0[1];
    c_dst[out_row1 * N + out_col0]     = rc0[2];
    c_dst[out_row1 * N + out_col1]     = rc0[3];

    // rc1 → cols 8-15
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
    int8_ptx_mma_k16_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
