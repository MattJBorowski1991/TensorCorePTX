#include "src/data.h"
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

void generate_fp16(half* h_A, half* h_B, int M, int N, int K, int num_batches) {
    srand(42);
    for (int b = 0; b < num_batches; ++b) {
        for (int i = 0; i < M * K; ++i)
            h_A[b * M * K + i] = __float2half((float)rand() / RAND_MAX * 0.1f - 0.05f);
        for (int i = 0; i < K * N; ++i)
            h_B[b * K * N + i] = __float2half((float)rand() / RAND_MAX * 0.1f - 0.05f);
    }
}

void cpu_gemm_fp16(const half* A, const half* B, float* C, int M, int N, int K) {
    for (int m = 0; m < M; ++m)
        for (int n = 0; n < N; ++n) {
            float acc = 0.f;
            for (int k = 0; k < K; ++k)
                acc += __half2float(A[m * K + k]) * __half2float(B[k * N + n]);
            C[m * N + n] = acc;
        }
}

bool verify(const float* ref, const float* out, int M, int N, float tol) {
    for (int i = 0; i < M * N; ++i) {
        float diff = fabsf(ref[i] - out[i]);
        if (diff > tol * fabsf(ref[i]) + tol) {
            fprintf(stderr, "[verify] mismatch at i=%d: ref=%.6f got=%.6f\n",
                    i, ref[i], out[i]);
            return false;
        }
    }
    return true;
}

AccuracyResult measure_accuracy(const float* ref, const float* out, int M, int N, float pass_tol){
    double sse = 0, sum_rel = 0, max_abs = 0;
    for(int i = 0; i < M * N; ++i){
        double diff = fabs(ref[i] - out[i]);
        max_abs = fmax(max_abs, diff);
        sse += diff * diff;
        sum_rel += diff / (fabs(ref[i]) + 1e-6);
    }
    AccuracyResult r;
    r.max_abs_err = (float)max_abs;
    r.rmse = (float)sqrt(sse / (M * N));
    r.real_err_pct = (float)(sum_rel / (M * N) * 100.0);
    r.pass = r.max_abs_err < pass_tol;
    return r;
}

