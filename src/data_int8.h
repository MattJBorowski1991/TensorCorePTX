#pragma once
#include <stdint.h>

// A  : M×K row-major int8
// B_T: N×K row-major int8  (transposed B, required for WMMA col_major B fragment)
// Seeded to 42 for reproducibility; values in [-10, 10].
void generate_int8(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches);

// Exact integer reference: C[M×N] = A[M×K] * B[K×N], where B is supplied as B_T[N×K].
void cpu_gemm_int8(const int8_t* A, const int8_t* BT, int32_t* C, int M, int N, int K);

struct AccuracyResultI32 {
    int32_t max_abs_err;  // 0 means bit-exact match
    float   rmse;
    bool    pass;         // true iff max_abs_err == 0
};

AccuracyResultI32 measure_accuracy_int8(const int32_t* ref, const int32_t* out, int M, int N);
