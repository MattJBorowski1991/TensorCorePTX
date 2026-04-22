#include "src/solver_int8.h"
#include "include/cuda_utils.h"
#include <stdio.h>

void SolverInt8::configure(const GemmConfig& cfg) { cfg_ = cfg; }

float SolverInt8::run(const int8_t* d_A, const int8_t* d_BT, int32_t* d_C) {
    CudaStream stream;

    for (int i = 0; i < cfg_.warmups; ++i)
        launch_kernel(d_A, d_BT, d_C, cfg_, stream);
    CHECK_CUDA(cudaStreamSynchronize(stream));

    CudaEvent ev_start, ev_stop;
    CHECK_CUDA(cudaEventRecord(ev_start, stream));
    for (int i = 0; i < cfg_.runs; ++i)
        launch_kernel(d_A, d_BT, d_C, cfg_, stream);
    CHECK_CUDA(cudaEventRecord(ev_stop, stream));
    CHECK_CUDA(cudaEventSynchronize(ev_stop));

    float ms = 0.f;
    CHECK_CUDA(cudaEventElapsedTime(&ms, ev_start, ev_stop));
    return ms / cfg_.runs;
}
