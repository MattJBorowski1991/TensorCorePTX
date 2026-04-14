// fp16_manual_pack.cu
// ── What changed vs fp16_ptx_mma.cu ──────────────────────────────────────────
//  SRAM→regs    : ldmatrix.x4 / ldmatrix.x2.trans  →  4 / 2 direct smem reads
//                 each read is a scalar ld.shared + pack_half2 into uint32
//  Everything else is IDENTICAL: same cp.async double-buffer, same mma.sync,
//  same epilogue scatter
//
// ── Why this is interesting ───────────────────────────────────────────────────
//  ldmatrix is a warp-collective instruction: one warp-level hardware rearrange.
//  Manual pack replaces it with 4+2 scalar shared-memory loads + register moves
//  per fragment per K-step.  The comparison reveals:
//    • ldmatrix advantage: lower instruction count, coalesced warp-level access
//    • manual pack cost:   6 independent ld.shared.b32 per fragment set vs 2
//      ldmatrix instructions;  bank-conflict pattern depends on the tile layout
//      (identical Bs[warp][k][n] row-major → no extra conflicts vs ldmatrix)
//  Use NCU sm__inst_executed_pipe_lsu to count the difference.
//
// ── mma.sync.m16n8k16 fragment element mapping (A, row-major 16×16 FP16) ────
//  Lane t (0-31) holds:
//    ra[0] = {A[t/4][(t%4)*2],       A[t/4][(t%4)*2+1]}      rows 0-7,  k 0-7
//    ra[1] = {A[t/4][(t%4)*2+8],     A[t/4][(t%4)*2+9]}      rows 0-7,  k 8-15
//    ra[2] = {A[t/4+8][(t%4)*2],     A[t/4+8][(t%4)*2+1]}    rows 8-15, k 0-7
//    ra[3] = {A[t/4+8][(t%4)*2+8],   A[t/4+8][(t%4)*2+9]}    rows 8-15, k 8-15
//
// ── mma.sync.m16n8k16 fragment element mapping (B, col-major 16×8 FP16) ─────
//  Stored in smem as Bs[k][n] (row-major); col n_base selects the N=8 half.
//  Lane t (0-31) holds:
//    rb[0] = {Bs[(t%4)*2][n+t/4],    Bs[(t%4)*2+1][n+t/4]}   k rows 0-7
//    rb[1] = {Bs[(t%4)*2+8][n+t/4],  Bs[(t%4)*2+9][n+t/4]}   k rows 8-15
//  where n = n_base (0 or 8)
//
// ── D-layout — identical to fp16_ptx_mma ─────────────────────────────────────
//  Thread t: d[0]@(t/4,(t%4)*2)  d[1]@(t/4,(t%4)*2+1)
//            d[2]@(t/4+8,(t%4)*2) d[3]@(t/4+8,(t%4)*2+1)
// ─────────────────────────────────────────────────────────────────────────────
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"

#define DBG_TRACE_TILES 16

#define DBG_PRINT_TILE_FRAG(tag, tile_idx, lane, ra, rb0)                          \
    do {                                                                            \
        half _ra0_lo  = __ushort_as_half((uint16_t)((ra)[0] & 0xFFFF));            \
        half _ra0_hi  = __ushort_as_half((uint16_t)((ra)[0] >> 16));               \
        half _rb0_lo  = __ushort_as_half((uint16_t)((rb0)[0] & 0xFFFF));           \
        half _rb0_hi  = __ushort_as_half((uint16_t)((rb0)[0] >> 16));              \
        half _rb0b_lo = __ushort_as_half((uint16_t)((rb0)[1] & 0xFFFF));           \
        half _rb0b_hi = __ushort_as_half((uint16_t)((rb0)[1] >> 16));              \
        printf("[DBG-LOAD] %s tile=%d lane=%d ra[0]={%.6f,%.6f} rb0[0]={%.6f,%.6f} rb0[1]={%.6f,%.6f}\n", \
            tag, tile_idx, lane,                                                    \
            __half2float(_ra0_lo), __half2float(_ra0_hi),                          \
            __half2float(_rb0_lo), __half2float(_rb0_hi),                          \
            __half2float(_rb0b_lo), __half2float(_rb0b_hi));                       \
    } while (0)

#define DBG_PRINT_TILE_HEADER(tag, tile_idx, lane)                                  \
    do {                                                                            \
        if ((lane) == 0) {                                                         \
            printf("\n[DBG-TILE] %s tile=%d\n", tag, tile_idx);                 \
        }                                                                           \
    } while (0)

#define DBG_PRINT_TILE_ALL_LANES(tag, tile_idx, lane, ra, rb0)                      \
    do {                                                                            \
        DBG_PRINT_TILE_HEADER(tag, tile_idx, lane);                                 \
        for (int _dbg_lane = 0; _dbg_lane < THREADS_PER_WARP; ++_dbg_lane) {       \
            if ((lane) == _dbg_lane) {                                              \
                DBG_PRINT_TILE_FRAG(tag, tile_idx, lane, ra, rb0);                  \
            }                                                                       \
            __syncwarp();                                                           \
        }                                                                           \
    } while (0)

// ── pack_half2: pack two adjacent FP16 values into a uint32 register ─────────
// Uses PTX mov.b32 so the compiler cannot split it into two 16-bit moves.
// lo occupies bits [15:0], hi occupies bits [31:16] — matches the mma operand
// register packing convention used by all sm80+ mma.sync variants.
__device__ __forceinline__ uint32_t pack_half2(half lo, half hi) {
    uint32_t v;
    asm("mov.b32 %0, {%1, %2};"
        : "=r"(v)
        : "h"(__half_as_ushort(lo)), "h"(__half_as_ushort(hi)));
    return v;
}

// ── MANUAL_PACK_A ─────────────────────────────────────────────────────────────
// Fills ra[4] for mma.sync.m16n8k16 A operand from smem_tile[WMMA_M][WMMA_K].
// Replaces ldmatrix.x4 with 4 scalar ld.shared reads.
//
//  smem_tile is As[buf][warp_id][0..WMMA_M-1][0..WMMA_K-1]
#define MANUAL_PACK_A(ra, smem_tile, lane)                                      \
    do {                                                                        \
        const int _rl  = (lane) / 4;           /* row 0-7 (low half)  */       \
        const int _rh  = _rl + 8;              /* row 8-15 (high half)*/       \
        const int _cl  = ((lane) % 4) * 2;    /* k-col 0,2,4,6       */       \
        const int _ch  = _cl + 8;             /* k-col 8,10,12,14    */       \
        (ra)[0] = pack_half2((smem_tile)[_rl][_cl],   (smem_tile)[_rl][_cl+1]);  \
        (ra)[1] = pack_half2((smem_tile)[_rl][_ch],   (smem_tile)[_rl][_ch+1]);  \
        (ra)[2] = pack_half2((smem_tile)[_rh][_cl],   (smem_tile)[_rh][_cl+1]);  \
        (ra)[3] = pack_half2((smem_tile)[_rh][_ch],   (smem_tile)[_rh][_ch+1]);  \
    } while(0)

// ── MANUAL_PACK_B ─────────────────────────────────────────────────────────────
// Fills rb[2] for mma.sync.m16n8k16 B operand from smem_tile[WMMA_K][WMMA_N].
// Replaces ldmatrix.x2.trans with 2 scalar ld.shared reads.
// n_base selects which N=8 half (0 → cols 0-7, 8 → cols 8-15).
//
//  smem_tile is Bs[buf][warp_id][0..WMMA_K-1][0..WMMA_N-1]
#define MANUAL_PACK_B(rb, smem_tile, lane, n_base)                              \
    do {                                                                        \
        const int _kl = ((lane) % 4) * 2;     /* k-row 0,2,4,6       */       \
        const int _kh = _kl + 8;              /* k-row 8,10,12,14    */       \
        const int _ni = (lane) / 4 + (n_base);/* n-col 0-7 + n_base  */       \
        (rb)[0] = pack_half2((smem_tile)[_kl][_ni],   (smem_tile)[_kl+1][_ni]); \
        (rb)[1] = pack_half2((smem_tile)[_kh][_ni],   (smem_tile)[_kh+1][_ni]); \
    } while(0)

// ── mma.sync macro — identical to fp16_ptx_mma ────────────────────────────────
#define MMA_SYNC(rc, ra, rb)                                                    \
    asm volatile(                                                               \
        "mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32 "                   \
        "{%0,%1,%2,%3}, {%4,%5,%6,%7}, {%8,%9}, {%10,%11,%12,%13};"            \
        : "=f"((rc)[0]), "=f"((rc)[1]), "=f"((rc)[2]), "=f"((rc)[3])           \
        : "r"((ra)[0]),  "r"((ra)[1]),  "r"((ra)[2]),  "r"((ra)[3]),           \
          "r"((rb)[0]),  "r"((rb)[1]),                                          \
          "f"((rc)[0]),  "f"((rc)[1]),  "f"((rc)[2]),  "f"((rc)[3]))

__global__ void manual_pack_db(
    const half* __restrict__ A,
    const half* __restrict__ B,
    float* __restrict__ C,
    int M, int N, int K
){
    int batch = blockIdx.z;

    const half* __restrict__ A_b = A + batch * M * K;
    const half* __restrict__ B_b = B + batch * K * N;
    float* __restrict__ C_b = C + batch * M * N;

    const int tid     = threadIdx.x;
    const int warp_id = tid / THREADS_PER_WARP;
    const int lane_id = tid % THREADS_PER_WARP;

    const int warp_tile_row = warp_id / WARP_TILES_X;
    const int warp_tile_col = warp_id % WARP_TILES_X;

    const int tile_row = blockIdx.y * (WMMA_M * WARP_TILES_Y) + warp_tile_row * WMMA_M;
    const int tile_col = blockIdx.x * (WMMA_N * WARP_TILES_X) + warp_tile_col * WMMA_N;
    if (tile_row >= M || tile_col >= N) return;

    // ── Shared memory — layout identical to fp16_ptx_mma ─────────────────────
    __shared__ __align__(16) half As[2][WARPS_PER_BLOCK][WMMA_M][WMMA_K + PAD];
    __shared__ __align__(16) half Bs[2][WARPS_PER_BLOCK][WMMA_K][WMMA_N + PAD];

    float rc0[4] = {0.f, 0.f, 0.f, 0.f};  // accumulator: N cols 0-7
    float rc1[4] = {0.f, 0.f, 0.f, 0.f};  // accumulator: N cols 8-15

    int buf = 0;

    // ── Prolog: scalar store — identical to fp16_ptx_mma ─────────────────────
    // scalar stores require __syncthreads() for cross-thread visibility;
    // the subsequent MANUAL_PACK loads read data written by all 32 warp threads.
    for (int i = lane_id; i < WMMA_M * WMMA_K; i += THREADS_PER_WARP) {
        int row = i / WMMA_K, col = i % WMMA_K;
        As[buf][warp_id][row][col] = A_b[(tile_row + row) * K + col];
    }
    for (int i = lane_id; i < WMMA_K * WMMA_N; i += THREADS_PER_WARP) {
        int row = i / WMMA_N, col = i % WMMA_N;
        Bs[buf][warp_id][row][col] = B_b[row * N + (tile_col + col)];
    }
    __syncthreads();

    // ── Load first fragments — MANUAL_PACK replaces ldmatrix ─────────────────
    uint32_t ra[4], rb0[2], rb1[2];
    MANUAL_PACK_A(ra,  As[buf][warp_id], lane_id);
    MANUAL_PACK_B(rb0, Bs[buf][warp_id], lane_id, 0);   // B cols 0-7
    MANUAL_PACK_B(rb1, Bs[buf][warp_id], lane_id, 8);   // B cols 8-15

    // ── DEBUG: print loaded fragments for first DBG_TRACE_TILES tiles, all lanes
    if (blockIdx.x == 0 && blockIdx.y == 0 && blockIdx.z == 0 && warp_id == 0) {
        DBG_PRINT_TILE_ALL_LANES("manual_pack", 0, lane_id, ra, rb0);
    }
    // ── Main K loop — cp.async double-buffer identical to fp16_ptx_mma ───────
    for (int k = WMMA_K; k < K; k += WMMA_K) {
        int next = 1 - buf;

        // Prefetch next A tile via cp.async (16B transactions)
        for (int i = 8 * lane_id; i < WMMA_M * WMMA_K; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_K, col = i % WMMA_K;
            unsigned dst_addr = __cvta_generic_to_shared(&As[next][warp_id][row][col]);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;"
                         :: "r"(dst_addr), "l"(&A_b[(tile_row + row) * K + (col + k)]));
        }

        // Prefetch next B tile via cp.async
        for (int i = 8 * lane_id; i < WMMA_K * WMMA_N; i += 8 * THREADS_PER_WARP) {
            int row = i / WMMA_N, col = i % WMMA_N;
            unsigned dst_addr = __cvta_generic_to_shared(&Bs[next][warp_id][row][col]);
            asm volatile("cp.async.ca.shared.global [%0], [%1], 16;"
                         :: "r"(dst_addr), "l"(&B_b[(row + k) * N + tile_col + col]));
        }

        asm volatile("cp.async.commit_group;");

        // Compute on current fragments
        MMA_SYNC(rc0, ra, rb0);   // N cols 0-7
        MMA_SYNC(rc1, ra, rb1);   // N cols 8-15

        (void)0;
        // Drain — cp.async.wait_group 0 ensures this thread's smem writes are
        // complete. Because all 32 threads in the warp execute wait_group 0
        // before any can reach MANUAL_PACK (warp convergence), ALL threads'
        // cp.async writes to As[next] and Bs[next] are committed by the time
        // the subsequent reads occur.
        asm volatile("cp.async.wait_group 0;");

        buf = next;
        MANUAL_PACK_A(ra,  As[buf][warp_id], lane_id);
        MANUAL_PACK_B(rb0, Bs[buf][warp_id], lane_id, 0);
        MANUAL_PACK_B(rb1, Bs[buf][warp_id], lane_id, 8);
        int loaded_tile = k / WMMA_K;
        if (loaded_tile < DBG_TRACE_TILES &&
            blockIdx.x == 0 && blockIdx.y == 0 && blockIdx.z == 0 && warp_id == 0) {
            DBG_PRINT_TILE_ALL_LANES("manual_pack", loaded_tile, lane_id, ra, rb0);
        }
    }

    // ── Tail compute ──────────────────────────────────────────────────────────
    MMA_SYNC(rc0, ra, rb0);
    MMA_SYNC(rc1, ra, rb1);

    (void)0;

    // ── Epilogue: scatter D-fragment to global — identical to fp16_ptx_mma ───
    float* c_dst  = C_b + tile_row * N + tile_col;
    int out_row0  = lane_id / 4;
    int out_row1  = out_row0 + 8;
    int out_col0  = (lane_id % 4) * 2;
    int out_col1  = out_col0 + 1;

    c_dst[out_row0 * N + out_col0]     = rc0[0];
    c_dst[out_row0 * N + out_col1]     = rc0[1];
    c_dst[out_row1 * N + out_col0]     = rc0[2];
    c_dst[out_row1 * N + out_col1]     = rc0[3];

    c_dst[out_row0 * N + out_col0 + 8] = rc1[0];
    c_dst[out_row0 * N + out_col1 + 8] = rc1[1];
    c_dst[out_row1 * N + out_col0 + 8] = rc1[2];
    c_dst[out_row1 * N + out_col1 + 8] = rc1[3];
}


// ── Kernel launch wrapper ─────────────────────────────────────────────────────
void launch_kernel(const half* A, const half* B, float* C,
                   const GemmConfig& cfg, cudaStream_t stream) {
    dim3 threads(THREADS_PER_WARP * WARPS_PER_BLOCK);
    dim3 blocks(
        (cfg.N + WARP_TILES_X * WMMA_N - 1) / (WARP_TILES_X * WMMA_N),
        (cfg.M + WARP_TILES_Y * WMMA_M - 1) / (WARP_TILES_Y * WMMA_M),
        cfg.num_batches
    );
    manual_pack_db<<<blocks, threads, 0, stream>>>(A, B, C, cfg.M, cfg.N, cfg.K);
    CHECK_CUDA(cudaGetLastError());
}


// cmake -B build -DKERNEL=fp16_manual_pack -DCUDA_ARCH=89
// cmake --build build
// ./build/profile_fp16_manual_pack
