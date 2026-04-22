#pragma once
#include <stdint.h>

// ── Integer correctness path ──────────────────────────────────────────────────
// A  : M×K row-major int8, values in [-127, 127].
// B_T: N×K row-major int8 (transposed B, required for WMMA col_major B fragment).
// Seeded to 42 for reproducibility.
void generate_int8(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches);

// Exact integer reference: C[M×N] = A[M×K] × B[K×N], B supplied as B_T[N×K].
void cpu_gemm_int8(const int8_t* A, const int8_t* BT, int32_t* C, int M, int N, int K);

struct AccuracyResultI32 {
    int32_t max_abs_err;  // 0 = bit-exact match
    float   rmse;
    bool    pass;         // true iff max_abs_err == 0
};

AccuracyResultI32 measure_accuracy_int8(const int32_t* ref, const int32_t* out, int M, int N);

// ── Quantization precision-loss path ─────────────────────────────────────────
// Fills h_A_fp32 [M×K] and h_BT_fp32 [N×K] with uniform FP32 values in [-1, 1].
// Seeded to 43 (distinct from the int8 correctness path).
void generate_fp32(float* h_A_fp32, float* h_BT_fp32, int M, int N, int K, int num_batches);

// Per-tensor absmax quantization: scale = max(|src[i]|) / 127.
// Writes clamped round(src[i] / scale) into dst[n] as int8. Returns scale.
float quantize_absmax(const float* src, int8_t* dst, int n);

// Dequantize INT32 accumulator → FP32: out[i] = scale_A * scale_BT * src[i].
void dequantize(const int32_t* src, float* dst, int n, float scale_A, float scale_BT);

// CPU FP32 reference GEMM (B supplied transposed as B_T[N×K]).
// C[m][n] = sum_k  A[m*K+k] * BT[n*K+k]
void cpu_gemm_fp32(const float* A, const float* BT, float* C, int M, int N, int K);

struct AccuracyResultQuant {
    float max_abs_err;
    float rmse;
    float real_err_pct;  // mean relative error %
    bool  pass;
};

AccuracyResultQuant measure_accuracy_quant(const float* ref, const float* out, int M, int N,
                                           float pass_tol = 1e-1f);
