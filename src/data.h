#pragma once
#include <cuda_fp16.h>

// Fill h_A [num_batches * M * K] and h_B [num_batches * K * N] with small
// random FP16 values (seeded to 42 for reproducibility).
void generate_fp16(half* h_A, half* h_B, int M, int N, int K, int num_batches);

// Naive CPU GEMM for a single batch: C [M x N] = A [M x K] * B [K x N].
void cpu_gemm_fp16(const half* A, const half* B, float* C, int M, int N, int K);

// Element-wise comparison of two M x N float matrices.
// Uses mixed absolute+relative tolerance: |ref - out| <= tol * |ref| + tol.
bool verify(const float* ref, const float* out, int M, int N, float tol = 1e-2f);

struct AccuracyResult {
    float max_abs_err;
    float rmse;
    float real_err_pct; // mean relative error %
    bool pass;
};

AccuracyResult measure_accuracy(const float* ref, const float* out, int M, int N, float pass_tol = 1e-2f);