#pragma once
#include <stdint.h>

// Packed INT4 storage: 2 nibbles per byte, low nibble first.
//   byte = (elem[2i] & 0x0F) | ((elem[2i+1] & 0x0F) << 4)
// All functions taking int8_t* pointers treat them as packed INT4 (K/2 bytes per row).

// Fill A (M×K/2 packed) and BT (N×K/2 packed) with random INT4 values in [-7, 7].
void generate_int4_packed(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches);

// C[m][n] = sum_k  A[m][k] * BT[n][k]  (full int32 accumulation, exact reference).
void cpu_gemm_int4(const int8_t* A_packed, const int8_t* BT_packed,
                   int32_t* C, int M, int N, int K);

struct AccuracyResultI32 {
    int32_t max_abs_err;
    float   rmse;
    int     max_row, max_col;
    int32_t ref_at_max, out_at_max;
    bool    pass;
};

AccuracyResultI32 measure_accuracy_int4(const int32_t* ref, const int32_t* out, int M, int N);

// ── Quantization / precision-loss path ───────────────────────────────────────
void generate_fp32(float* h_A_fp32, float* h_BT_fp32, int M, int N, int K, int num_batches);

// scale = max(|x|) / 7.  Returns scale.
float quantize_absmax_int4(const float* src, int8_t* dst_packed, int rows, int cols_k);

void dequantize(const int32_t* src, float* dst, int n, float scale_A, float scale_BT);

void cpu_gemm_fp32(const float* A, const float* BT, float* C, int M, int N, int K);

struct AccuracyResultQuant {
    float max_abs_err, rmse, real_err_pct, snr_db;
    bool  pass;
};

AccuracyResultQuant measure_accuracy_quant(const float* ref, const float* out, int M, int N,
                                           float pass_tol = 1.0f);
