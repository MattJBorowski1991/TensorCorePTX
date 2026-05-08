#include "src/data_int4.h"
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

// ── Nibble pack/unpack helpers ────────────────────────────────────────────────

// Pack two INT4 values into one byte: low nibble first.
static inline int8_t pack_nibbles(int8_t lo, int8_t hi) {
    return (int8_t)((lo & 0x0F) | ((hi & 0x0F) << 4));
}

// Sign-extend low nibble of a byte.
static inline int8_t unpack_lo(int8_t packed) {
    return (int8_t)((int8_t)(packed << 4) >> 4);
}

// Sign-extend high nibble of a byte.
static inline int8_t unpack_hi(int8_t packed) {
    return (int8_t)((int8_t)packed >> 4);
}

// ── Data generation ───────────────────────────────────────────────────────────

void generate_int4_packed(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches) {
    srand(42);
    for (int b = 0; b < num_batches; ++b) {
        // A: M × K INT4 packed into M × K/2 bytes
        for (int i = 0; i < M * (K / 2); ++i) {
            int8_t lo = (int8_t)((rand() % 15) - 7);  // [-7, 7]
            int8_t hi = (int8_t)((rand() % 15) - 7);
            h_A[b * M * (K / 2) + i] = pack_nibbles(lo, hi);
        }
        // BT: N × K INT4 packed into N × K/2 bytes
        for (int i = 0; i < N * (K / 2); ++i) {
            int8_t lo = (int8_t)((rand() % 15) - 7);
            int8_t hi = (int8_t)((rand() % 15) - 7);
            h_BT[b * N * (K / 2) + i] = pack_nibbles(lo, hi);
        }
    }
}

// ── CPU reference GEMM (exact int32 accumulation) ────────────────────────────

void cpu_gemm_int4(const int8_t* A_packed, const int8_t* BT_packed,
                   int32_t* C, int M, int N, int K) {
    memset(C, 0, M * N * sizeof(int32_t));
    for (int m = 0; m < M; ++m) {
        for (int n = 0; n < N; ++n) {
            int32_t acc = 0;
            for (int k = 0; k < K; k += 2) {
                int8_t byte_a  = A_packed[m  * (K / 2) + k / 2];
                int8_t byte_bt = BT_packed[n * (K / 2) + k / 2];
                acc += (int32_t)unpack_lo(byte_a) * (int32_t)unpack_lo(byte_bt);
                acc += (int32_t)unpack_hi(byte_a) * (int32_t)unpack_hi(byte_bt);
            }
            C[m * N + n] = acc;
        }
    }
}

// ── Accuracy measurement ──────────────────────────────────────────────────────

AccuracyResultI32 measure_accuracy_int4(const int32_t* ref, const int32_t* out, int M, int N) {
    int64_t max_abs = 0;
    double  sse     = 0.0;
    int     max_i   = 0;
    for (int i = 0; i < M * N; ++i) {
        int64_t diff     = (int64_t)ref[i] - (int64_t)out[i];
        int64_t abs_diff = diff < 0 ? -diff : diff;
        if (abs_diff > max_abs) { max_abs = abs_diff; max_i = i; }
        sse += (double)diff * (double)diff;
    }
    AccuracyResultI32 r;
    r.max_abs_err = (int32_t)max_abs;
    r.rmse        = (float)sqrt(sse / (M * N));
    r.max_row     = max_i / N;
    r.max_col     = max_i % N;
    r.ref_at_max  = ref[max_i];
    r.out_at_max  = out[max_i];
    r.pass        = (max_abs == 0);   // Integer MMA accumulates exactly into int32
    return r;
}

// ── Quantization / precision-loss path ───────────────────────────────────────

static float randn() {
    float u1 = ((float)rand() + 1.f) / ((float)RAND_MAX + 2.f);
    float u2 = (float)rand() / ((float)RAND_MAX + 1.f);
    return sqrtf(-2.f * logf(u1)) * cosf(2.f * 3.14159265f * u2);
}

void generate_fp32(float* h_A_fp32, float* h_BT_fp32, int M, int N, int K, int num_batches) {
    srand(43);
    for (int b = 0; b < num_batches; ++b) {
        for (int i = 0; i < M * K; ++i) h_A_fp32[b  * M * K + i] = randn();
        for (int i = 0; i < N * K; ++i) h_BT_fp32[b * N * K + i] = randn();
    }
}

// scale = max(|x|) / 7.  Quantizes K elements at a time (K must be even),
// packs pairs into output bytes, returns the scale used.
float quantize_absmax_int4(const float* src, int8_t* dst_packed, int rows, int cols_k) {
    int n = rows * cols_k;
    float absmax = 0.f;
    for (int i = 0; i < n; ++i) {
        float v = src[i] < 0.f ? -src[i] : src[i];
        if (v > absmax) absmax = v;
    }
    float scale = absmax / 7.f;
    float inv   = (scale > 0.f) ? (1.f / scale) : 0.f;
    for (int r = 0; r < rows; ++r) {
        for (int k = 0; k < cols_k; k += 2) {
            auto quant = [&](float x) -> int8_t {
                float q = x * inv;
                if (q >  7.f) q =  7.f;
                if (q < -7.f) q = -7.f;
                return (int8_t)(int)(q >= 0.f ? q + 0.5f : q - 0.5f);
            };
            int8_t lo = quant(src[r * cols_k + k]);
            int8_t hi = quant(src[r * cols_k + k + 1]);
            dst_packed[r * (cols_k / 2) + k / 2] = pack_nibbles(lo, hi);
        }
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
    double max_abs = 0.0, sse = 0.0, sum_rel = 0.0, sig_sq = 0.0;
    for (int i = 0; i < M * N; ++i) {
        double diff    = (double)ref[i] - (double)out[i];
        double abs_d   = diff < 0.0 ? -diff : diff;
        if (abs_d > max_abs) max_abs = abs_d;
        sse    += diff * diff;
        sig_sq += (double)ref[i] * (double)ref[i];
        sum_rel += abs_d / ((double)(ref[i] < 0.f ? -ref[i] : ref[i]) + 1e-6);
    }
    AccuracyResultQuant r;
    r.max_abs_err  = (float)max_abs;
    r.rmse         = (float)sqrt(sse / (M * N));
    r.real_err_pct = (float)(sum_rel / (M * N) * 100.0);
    r.snr_db       = (sse > 0.0) ? (float)(10.0 * log10(sig_sq / sse)) : 999.f;
    r.pass         = (r.max_abs_err < pass_tol);
    return r;
}
