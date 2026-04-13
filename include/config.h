#pragma once

// ── Warp / tile constants (compile-time) ────────────────────────────────────
constexpr int THREADS_PER_WARP = 32;

#define WMMA_M 16
#define WMMA_N 16
#define WMMA_K 16
#define PAD    0

#define WARP_TILES_X    4
#define WARP_TILES_Y    2
#define WARPS_PER_BLOCK (WARP_TILES_X * WARP_TILES_Y)

// ── Runtime problem / benchmark configuration ────────────────────────────────
struct GemmConfig {
    int M, N, K;
    int num_batches;
    int warmups, runs;
};