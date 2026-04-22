#include "src/data_int8.h"
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

void generate_int8(int8_t* h_A, int8_t* h_BT, int M, int N, int K, int num_batches) {
    srand(42);
    for (int b = 0; b < num_batches; ++b) {
        for (int i = 0; i < M * K; ++i)
            h_A[b * M * K + i] = (int8_t)(rand() % 21 - 10);   // [-10, 10]
        // B_T stored as N×K (row = n, col = k)
        for (int i = 0; i < N * K; ++i)
            h_BT[b * N * K + i] = (int8_t)(rand() % 21 - 10);
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
