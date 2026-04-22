// int8_ptx_mma_k32.cu
// ── What changed vs int8_ptx_mma_k16.cu ──────────────────────────────────────
//  WMMA_K     : 16 → 32 (larger SMEM tile, K-step doubles; K must be multiple of 32)
//  ldmatrix A : x2 → x4  (4 m8n8 b16 tiles for 16×32 int8 = 16×16 b16)
//  ldmatrix B : x1.trans → x2.trans  (2 m8n8 b16 tiles for 8×32 int8 = 8×16 b16)
//  Fragments A: ra[2] → ra[4]
//  Fragments B: rb[1] → rb[2]
//  MMA opcode : m16n8k16.s32.s8.s8.s32 → m16n8k32.s32.s8.s8.s32
//  MMA calls per K-step: 2 (unchanged — still need both N=8 halves)
//  SMEM per buffer: 16×32 × 2 (As+Bs) = 1024 bytes vs 512 for k16
//
// ── Why k32 over k16 ─────────────────────────────────────────────────────────
//  Halves the number of ldmatrix + commit_group + wait_group + buf-swap sequences
//  per K-step. Each mma.sync.m16n8k32 does twice the work of m16n8k16 in one call.
//  Trade-off: ra[4] + rb[2] live simultaneously → more register pressure.
//  Empirically faster at large K where pipeline overhead dominates over reg pressure.
//
// ── PTX fragment sizes (per thread, mma.sync.m16n8k32 s32 acc) ───────────────
//  A  (m16 × k32):  4 × uint32  (each uint32 packs 4 × int8)
//  B  (k32 × n8) :  2 × uint32  (each uint32 packs 4 × int8)
//  D  (m16 × n8) :  4 × int32   (identical to k16)
//
// ── D-layout: identical to k16/f32 ───────────────────────────────────────────
//  Thread t: rc[0]@(t/4,(t%4)*2)   rc[1]@(t/4,(t%4)*2+1)
//            rc[2]@(t/4+8,(t%4)*2) rc[3]@(t/4+8,(t%4)*2+1)
//
// ── ldmatrix A addressing (k32) ───────────────────────────────────────────────
//  Tile: int8_t[16][32] row-major = 16×16 b16.
//  ldmatrix.x4 loads 4 m8n8 b16 tiles:
//    TL(rows 0-7,  b16-cols 0-7),  TR(rows 0-7,  b16-cols 8-15)
//    BL(rows 8-15, b16-cols 0-7),  BR(rows 8-15, b16-cols 8-15)
//  Lane mapping:
//    Lanes  0-15 → rows 0-15, int8-col  0  (_r = lane%16, _c =  0)
//    Lanes 16-31 → rows 0-15, int8-col 16  (_r = lane%16, _c = 16)
//  Compact: _r = lane%16, _c = (lane/16)*16
//
// ── ldmatrix B addressing (k32) ───────────────────────────────────────────────
//  BT tile: int8_t[16][32] (N×K).  Each n8 call loads 8 rows × 32 cols = 8×16 b16.
//  ldmatrix.x2.trans loads 2 m8n8 b16 tiles within that 8-row chunk:
//    Tile 0 (rows n_base..n_base+7, int8-cols  0-15 = b16-cols 0-7)
//    Tile 1 (rows n_base..n_base+7, int8-cols 16-31 = b16-cols 8-15)
//  Lane mapping:
//    Lanes 0-7  → _r = n_base + lane%8, _c =  0
//    Lanes 8-15 → _r = n_base + lane%8, _c = 16
//    Lanes 16-31 → don't care (mirror safely within WMMA_N/WMMA_K bounds)
//  Compact: _r = n_base + lane%8, _c = ((lane/8)%2)*16
// ─────────────────────────────────────────────────────────────────────────────

#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"

// Extend K tile from 16 → 32 for this variant. Must come after config.h.
#undef WMMA_K
#define WMMA_K 32

#include "include/cuda_utils.h"

// ── ldmatrix macros ───────────────────────────────────────────────────────────

// Load A: 16×32 int8 tile → 4 uint32 registers via ldmatrix.x4.
#define LDMATRIX_A(ra, smem_ptr, lane)                                          \
    do {                                                                        \
        int _r = (lane) % 16;                                                   \
        int _c = ((lane) / 16) * 16;                                            \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][_c]);         \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x4.shared.b16 {%0,%1,%2,%3}, [%4];"   \
            : "=r"((ra)[0]), "=r"((ra)[1]), "=r"((ra)[2]), "=r"((ra)[3])       \
            : "r"(_addr));                                                      \
    } while(0)

// Load one n8 half of BT: 8×32 int8 chunk → 2 uint32 registers via ldmatrix.x2.trans.
// n_base selects which 8-row chunk of BT (0 = cols 0-7, 8 = cols 8-15 of output).
#define LDMATRIX_B(rb, smem_ptr, lane, n_base)                                  \
    do {                                                                        \
        int _r = (n_base) + (lane) % 8;                                         \
        int _c = ((lane) / 8 % 2) * 16;                                         \
        uint32_t _addr = __cvta_generic_to_shared(&(smem_ptr)[_r][_c]);         \
        asm volatile(                                                           \
            "ldmatrix.sync.aligned.m8n8.x2.trans.shared.b16 {%0,%1}, [%2];"   \
            : "=r"((rb)[0]), "=r"((rb)[1])                                     \
            : "r"(_addr));                                                      \
    } while(0)

// ── mma.sync.m16n8k32 INT8→INT32 macro ───────────────────────────────────────
// D[4] = A[4] * B[2] + C[4]   (in-place: C is both input and output)
#define MMA_INT8(rc, ra, rb)                                                    \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k32.row.col.s32.s8.s8.s32 "                     \
        "{%0,%1,%2,%3}, {%4,%5,%6,%7}, {%8,%9}, {%10,%11,%12,%13};"            \
        : "=r"((rc)[0]), "=r"((rc)[1]), "=r"((rc)[2]), "=r"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),  "r"((ra)[2]),  "r"((ra)[3]),           \
          "r"((rb)[0]),  "r"((rb)[1]),                                          \
          "r"((rc)[0]),  "r"((rc)[1]),  "r"((rc)[2]),  "r"((rc)[3]))

__global__ void int8_ptx_mma_k32_db(
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
    // As: M×K int8 = 16×32 per warp slot (512 bytes × 8 warps × 2 stages = 8KB).
    // Bs: BT tile N×K int8 = 16×32 per warp slot (same size).
    __shared__ __align__(16) int8_t As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) int8_t Bs[2][WARPS_PER_BLOCK][WMMA_N][WMMA_K + PAD];

    // rc0: output cols 0-7, rc1: output cols 8-15
    int32_t rc0[4] = {0, 0, 0, 0};
    int32_t rc1[4] = {0, 0, 0, 0};

    int buf = 0;

    // ── Prolog: scalar load, tile k=0 ─────────────────────────────────────────
    // WMMA_M*WMMA_K = 16*32 = 512 elements; 512/32 = 16 iterations per lane.
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_N * WMMA_K; i += THREADS_PER_WARP) {
        int n = i / WMMA_K, col = i % WMMA_K;
        Bs[buf][warp_id][n][col] = BT_b[(tile_col + n) * K + col];
    }
    __syncthreads();

    // ── Load first fragments ───────────────────────────────────────────────────
    uint32_t ra[4], rb0[2], rb1[2];
    LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
    LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);   // BT rows 0-7  → B cols 0-7
    LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);   // BT rows 8-15 → B cols 8-15

    // ── Main K loop (step = WMMA_K = 32; K must be a multiple of 32) ─────────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // cp.async A: 16×32 int8 = 512 bytes = 32 × 16-byte transactions.
        // With THREADS_PER_WARP=32, each lane issues exactly one transaction.
        // lane_id=i: row = (i*16)/32 = i/2, col = (i*16)%32 = (i%2)*16.
        for (int i = lane_id; i < (WMMA_M * WMMA_K) / 16; i += THREADS_PER_WARP) {
            int row = (i * 16) / WMMA_K, col = (i * 16) % WMMA_K;
            char*       dst      = (char*)&As[next][warp_id][row][col];
            const char* src      = (const char*)&A_b[(tile_row + row) * K + col + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        // cp.async BT: same shape, same indexing with n instead of row.
        for (int i = lane_id; i < (WMMA_N * WMMA_K) / 16; i += THREADS_PER_WARP) {
            int n = (i * 16) / WMMA_K, col = (i * 16) % WMMA_K;
            char*       dst      = (char*)&Bs[next][warp_id][n][col];
            const char* src      = (const char*)&BT_b[(tile_col + n) * K + col + k];
            unsigned    dst_addr = __cvta_generic_to_shared(dst);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;" :: "r"(dst_addr), "l"(src));
        }

        asm volatile("cp.async.commit_group;");

        MMA_INT8(rc0, ra, rb0);   // cols 0-7
        MMA_INT8(rc1, ra, rb1);   // cols 8-15

        asm volatile("cp.async.wait_group 0;");

        buf = next;
        LDMATRIX_A(ra,  As[buf][warp_id], lane_id);
        LDMATRIX_B(rb0, Bs[buf][warp_id], lane_id, 0);
        LDMATRIX_B(rb1, Bs[buf][warp_id], lane_id, 8);
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
    int8_ptx_mma_k32_db<<<blocks, threads, 0, stream>>>(A, BT, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}
