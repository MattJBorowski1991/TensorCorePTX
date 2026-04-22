// int8_ptx_manual_pack.cu
// ── What changed vs int8_ptx_mma_k16.cu ──────────────────────────────────────
//  SRAM→regs  : ldmatrix.x2 / ldmatrix.x1.trans  →  4 / 1 individual byte reads
//               + prmt.b32 to pack 4 int8 values into one uint32 operand
//  Everything else is IDENTICAL: same cp.async double-buffer, same
//  mma.sync.m16n8k16.s32.s8.s8.s32, same int32 epilogue scatter.
//
// ── Why this is interesting ───────────────────────────────────────────────────
//  ldmatrix is a warp-collective: one hardware rearrange covers all 32 lanes.
//  Manual pack replaces it with per-lane scalar ld.shared accesses + prmt.
//  prmt is the INT8 equivalent of mov.b32 {h1,h2} used in fp16_ptx_manual_pack:
//    FP16: pack 2 × half → uint32   via  mov.b32 {%h, %h}
//    INT8: pack 4 × int8 → uint32   via  3 × prmt.b32
//  The comparison reveals ldmatrix's warp-cooperative advantage:
//    A fragment: ldmatrix.x2 (2 PTX args) vs 2 × 4 byte reads + 2 × 3 prmt = 14 instr
//    B fragment: ldmatrix.x1.trans     vs 1 × 4 byte reads + 3 prmt = 7 instr
//  Use NCU sm__inst_executed_pipe_lsu to count the ld.shared difference.
//
// ── mma.sync.m16n8k16 INT8 A fragment element mapping (row-major 16×16) ─────
//  Lane t (0-31) holds:
//    ra[0] bits[ 7: 0] → A[t/4][(t%4)*4]     ra[0] bits[15: 8] → A[t/4][(t%4)*4+1]
//    ra[0] bits[23:16] → A[t/4][(t%4)*4+2]   ra[0] bits[31:24] → A[t/4][(t%4)*4+3]
//    ra[1] bits[ 7: 0] → A[t/4+8][(t%4)*4]   ra[1] bits[15: 8] → A[t/4+8][(t%4)*4+1]
//    ra[1] bits[23:16] → A[t/4+8][(t%4)*4+2] ra[1] bits[31:24] → A[t/4+8][(t%4)*4+3]
//
// ── mma.sync.m16n8k16 INT8 B fragment element mapping (col-major k16×n8) ────
//  BT stored in SMEM as int8_t[N][K] (BT[n][k] = B[k][n]).
//  Lane t, selecting n8 half at n_base:
//    rb[0] bits[ 7: 0] → BT[n_base+t/4][(t%4)*4]
//    rb[0] bits[15: 8] → BT[n_base+t/4][(t%4)*4+1]
//    rb[0] bits[23:16] → BT[n_base+t/4][(t%4)*4+2]
//    rb[0] bits[31:24] → BT[n_base+t/4][(t%4)*4+3]
//
// ── prmt.b32 selector arithmetic ─────────────────────────────────────────────
//  prmt.b32 d, a, b, sel: nibble i of sel picks byte for d[i*8+7 : i*8].
//  Values 0-3 pick bytes from a, 4-7 pick bytes from b.
//  prmt d, r0, r1, 0x0040 → d[15:0] = {r1[7:0], r0[7:0]}  (b1 in hi, b0 in lo)
//  prmt d, t01, t23, 0x5410 → d = {t23[15:8], t23[7:0], t01[15:8], t01[7:0]}
//                            = {b3, b2, b1, b0}  ✓
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

// ── pack_int8x4 ───────────────────────────────────────────────────────────────
// Pack four int8 values (each in the low byte of a separate register) into one
// uint32 via three prmt.b32 instructions.  Byte order: b0 at [7:0], b3 at [31:24].
__device__ __forceinline__ uint32_t pack_int8x4(int8_t b0, int8_t b1, int8_t b2, int8_t b3) {
    uint32_t r0 = (uint32_t)(uint8_t)b0;   // zero-extend to avoid sign pollution
    uint32_t r1 = (uint32_t)(uint8_t)b1;
    uint32_t r2 = (uint32_t)(uint8_t)b2;
    uint32_t r3 = (uint32_t)(uint8_t)b3;
    uint32_t t01, t23, out;
    // 0x0040: d[7:0]=a[7:0]=b0, d[15:8]=b[7:0]=b1
    asm("prmt.b32 %0, %1, %2, 0x0040;" : "=r"(t01) : "r"(r0), "r"(r1));
    asm("prmt.b32 %0, %1, %2, 0x0040;" : "=r"(t23) : "r"(r2), "r"(r3));
    // 0x5410: d[7:0]=t01[7:0]=b0, d[15:8]=t01[15:8]=b1,
    //         d[23:16]=t23[7:0]=b2, d[31:24]=t23[15:8]=b3
    asm("prmt.b32 %0, %1, %2, 0x5410;" : "=r"(out) : "r"(t01), "r"(t23));
    return out;
}

// ── MANUAL_PACK_A ─────────────────────────────────────────────────────────────
// Fills ra[2] for mma.sync.m16n8k16 A operand from smem_tile[M][K] (int8 M×K).
// Each ra element packs 4 int8 values at 4 consecutive k-columns.
// Replaces ldmatrix.x2 with 2 × 4 scalar ld.shared + 2 × pack_int8x4.
//
//   smem_tile is As[buf][warp_id]
#define MANUAL_PACK_A(ra, smem_tile, lane)                                      \
    do {                                                                        \
        const int _row0 = (lane) / 4;           /* rows 0-7               */   \
        const int _row1 = _row0 + 8;            /* rows 8-15              */   \
        const int _col  = ((lane) % 4) * 4;    /* k-col: 0,4,8,12        */   \
        (ra)[0] = pack_int8x4(                                                 \
            (smem_tile)[_row0][_col],   (smem_tile)[_row0][_col+1],            \
            (smem_tile)[_row0][_col+2], (smem_tile)[_row0][_col+3]);           \
        (ra)[1] = pack_int8x4(                                                 \
            (smem_tile)[_row1][_col],   (smem_tile)[_row1][_col+1],            \
            (smem_tile)[_row1][_col+2], (smem_tile)[_row1][_col+3]);           \
    } while(0)

// ── MANUAL_PACK_B ─────────────────────────────────────────────────────────────
// Fills rb[1] for mma.sync.m16n8k16 B operand from smem_tile[N][K] (BT int8 N×K).
// Replaces ldmatrix.x1.trans with 1 × 4 scalar ld.shared + pack_int8x4.
// n_base selects which n8 half: 0 → output cols 0-7, 8 → output cols 8-15.
//
//   smem_tile is Bs[buf][warp_id]
#define MANUAL_PACK_B(rb, smem_tile, lane, n_base)                              \
    do {                                                                        \
        const int _n   = (n_base) + (lane) / 4;  /* n-row 0-7 within BT  */   \
        const int _col = ((lane) % 4) * 4;       /* k-col: 0,4,8,12      */   \
        (rb)[0] = pack_int8x4(                                                 \
            (smem_tile)[_n][_col],   (smem_tile)[_n][_col+1],                  \
            (smem_tile)[_n][_col+2], (smem_tile)[_n][_col+3]);                 \
    } while(0)

// ── mma.sync.m16n8k16 INT8→INT32 — identical to int8_ptx_mma_k16 ─────────────
#define MMA_INT8(rc, ra, rb)                                                    \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k16.row.col.s32.s8.s8.s32 "                     \
        "{%0,%1,%2,%3}, {%4,%5}, {%6}, {%7,%8,%9,%10};"                        \
        : "=r"((rc)[0]), "=r"((rc)[1]), "=r"((rc)[2]), "=r"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),                                          \
          "r"((rb)[0]),                                                         \
          "r"((rc)[0]),  "r"((rc)[1]),  "r"((rc)[2]),  "r"((rc)[3]))

__global__ void int8_manual_pack_db(
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

    // ── Shared memory — layout identical to int8_ptx_mma_k16 ─────────────────
    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][WMMA_K + PAD];

    int32_t rc0[4] = {0, 0, 0, 0};   // output cols 0-7
    int32_t rc1[4] = {0, 0, 0, 0};   // output cols 8-15

    int buf = 0;

    // ── Prolog: scalar load — identical to int8_ptx_mma_k16 ──────────────────
    // (scalar stores require __syncthreads for cross-thread visibility;
    //  the subsequent MANUAL_PACK reads see data from all 32 warp threads.)
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_N * WMMA_K; i += THREADS_PER_WARP) {
        int n = i / WMMA_K, col = i % WMMA_K;
        Bs[buf][warp_id][n][col] = BT_b[(tile_col + n) * K + col];
    }
    __syncthreads();

    // ── Load first fragments — MANUAL_PACK replaces ldmatrix ─────────────────
    uint32_t ra[2], rb0[1], rb1[1];
    MANUAL_PACK_A(ra,  As[buf][warp_id], lane_id);
    MANUAL_PACK_B(rb0, Bs[buf][warp_id], lane_id, 0);   // BT rows 0-7  → B cols 0-7
    MANUAL_PACK_B(rb1, Bs[buf][warp_id], lane_id, 8);   // BT rows 8-15 → B cols 8-15

    // ── Main K loop — cp.async double-buffer identical to int8_ptx_mma_k16 ───
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // cp.async A: 16 bytes per transaction = one full row of the 16×16 int8 tile.
        for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP) {
            char*       dst      = (char*)&As[next][warp_id][i][0];
            const char* src      = (const char*)&A_b[(tile_row + i) * K + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        // cp.async BT
        for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP) {
            char*       dst      = (char*)&Bs[next][warp_id][i][0];
            const char* src      = (const char*)&BT_b[(tile_col + i) * K + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        MMA_INT8(rc0, ra, rb0);   // cols 0-7
        MMA_INT8(rc1, ra, rb1);   // cols 8-15

        // wait_group 0 ensures all 32 warp threads' cp.async writes are visible
        // before MANUAL_PACK reads from the next buffer.
        asm volatile("cp.async.wait_group 0;");

        buf = next;
        MANUAL_PACK_A(ra,  As[buf][warp_id], lane_id);
        MANUAL_PACK_B(rb0, Bs[buf][warp_id], lane_id, 0);
        MANUAL_PACK_B(rb1, Bs[buf][warp_id], lane_id, 8);
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    MMA_INT8(rc0, ra, rb0);
    MMA_INT8(rc1, ra, rb1);

    // ── Epilogue: scatter D-fragment to global (int32, no dequant) ───────────
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
    int8_manual_pack_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
