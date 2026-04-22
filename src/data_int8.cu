#include "src/data_int8.h"
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

void generate_int8(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches) {
    srand(42);
    for (int b = 0; b < num_batches; ++b) {
        for (int i = 0; i < M * K; ++i)
            h_A[b * M * K + i] = (int8_t)(rand() % 255 - 127);   // [-127, 127]
        for (int i = 0; i < N * K; ++i)
            h_BT[b * N * K + i] = (int8_t)(rand() % 255 - 127);
    }
}

// C[m][n] = sum_k  A[m][k] * B[k][n]
//          = sum_k  A[m*K+k] * BT[n*K+k]   (BT is B stored transposed as N×K)
void cpu_gemm_int8(const int8_t* A, const int8_t* BT, int32_t* C, int M, int N, int K) {
    for (int m = 0; m < M; ++m)
        for (int n = 0; n < N; ++n) {
            int32_t acc = 0;
            for (int k = 0; k < K; ++k)
                acc += (int32_t)A[m * K + k] * (int32_t)BT[n * K + k];
            C[m * N + n] = acc;
        }
}

AccuracyResultI32 measure_accuracy_int8(const int32_t* ref, const int32_t* out, int M, int N) {
    int64_t max_abs = 0;
    double  sse     = 0.0;
    for (int i = 0; i < M * N; ++i) {
        int64_t diff = (int64_t)ref[i] - (int64_t)out[i];
        int64_t abs_diff = diff < 0 ? -diff : diff;
        if (abs_diff > max_abs) max_abs = abs_diff;
        sse += (double)diff * (double)diff;
    }
    AccuracyResultI32 r;
    r.max_abs_err = (int32_t)max_abs;
    r.rmse        = (float)sqrt(sse / (M * N));
    r.pass        = (max_abs == 0);   // INT8 mma.sync accumulates exactly into int32
    return r;
}

// ── Quantization precision-loss path ─────────────────────────────────────────

// Box-Muller: produces one N(0,1) sample from two uniform draws.
// u1 offset by 1 to avoid log(0).
static float randn() {
    float u1 = ((float)rand() + 1.f) / ((float)RAND_MAX + 2.f);
    float u2 = (float)rand() / ((float)RAND_MAX + 1.f);
    return sqrtf(-2.f * logf(u1)) * cosf(2.f * 3.14159265f * u2);
}

// Fills arrays with N(0,1) values — approximates real activation distributions
// which are Gaussian with occasional outliers, giving realistic absmax quantization error.
void generate_fp32(float* h_A_fp32, float* h_BT_fp32, int M, int N, int K, int num_batches) {
    srand(43);
    for (int b = 0; b < num_batches; ++b) {
        for (int i = 0; i < M * K; ++i)
            h_A_fp32[b * M * K + i] = randn();
        for (int i = 0; i < N * K; ++i)
            h_BT_fp32[b * N * K + i] = randn();
    }
}

float quantize_absmax(const float* src, int8_t* dst, int n) {
    float absmax = 0.f;
    for (int i = 0; i < n; ++i) {
        float v = src[i] < 0.f ? -src[i] : src[i];
        if (v > absmax) absmax = v;
    }
    float scale = absmax / 127.f;
    float inv   = (scale > 0.f) ? (1.f / scale) : 0.f;
    for (int i = 0; i < n; ++i) {
        float q = src[i] * inv;
        if (q >  127.f) q =  127.f;
        if (q < -127.f) q = -127.f;
        dst[i] = (int8_t)(int)( q >= 0.f ? q + 0.5f : q - 0.5f );  // round-to-nearest
    }
    return scale;
}

void dequantize(const int32_t* src, float* dst, int n, float scale_A, float scale_BT) {
    float combined = scale_A * scale_BT;
    for (int i = 0; i < n; ++i)
        dst[i] = (float)src[i] * combined;
}

void cpu_gemm_fp32(const float* A, const float* BT, float* C, int M, int N, int K) {
    for (int m = 0; m < M; ++m)
        for (int n = 0; n < N; ++n) {
            double acc = 0.0;
            for (int k = 0; k < K; ++k)
                acc += (double)A[m * K + k] * (double)BT[n * K + k];
            C[m * N + n] = (float)acc;
        }
}

AccuracyResultQuant measure_accuracy_quant(const float* ref, const float* out, int M, int N,
                                           float pass_tol) {
    double max_abs = 0.0, sse = 0.0, sum_rel = 0.0;
    for (int i = 0; i < M * N; ++i) {
        double diff = (double)ref[i] - (double)out[i];
        double abs_diff = diff < 0.0 ? -diff : diff;
        if (abs_diff > max_abs) max_abs = abs_diff;
        sse     += diff * diff;
        sum_rel += abs_diff / ((double)(ref[i] < 0.f ? -ref[i] : ref[i]) + 1e-6);
    }
    AccuracyResultQuant r;
    r.max_abs_err  = (float)max_abs;
    r.rmse         = (float)sqrt(sse / (M * N));
    r.real_err_pct = (float)(sum_rel / (M * N) * 100.0);
    r.pass         = (r.max_abs_err < pass_tol);
    return r;
}
