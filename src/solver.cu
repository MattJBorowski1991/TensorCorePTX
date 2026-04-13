#include "src/solver.h"
#include "include/cuda_utils.h"
#include <stdio.h>

// Implemented in kernels/*.cu — one definition per build target.
void launch_kernel(const half* A, const half* B, float* C,
                   const GemmConfig& cfg, cudaStream_t stream);

void Solver::configure(const GemmConfig& cfg) { cfg_ = cfg; }

float Solver::run(const half* d_A, const half* d_B, float* d_C) {
    CudaStream stream;

    for (int i = 0; i < cfg_.warmups; ++i)
        launch_kernel(d_A, d_B, d_C, cfg_, stream);
    CHECK_CUDA(cudaStreamSynchronize(stream));

    CudaEvent ev_start, ev_stop;
    CHECK_CUDA(cudaEventRecord(ev_start, stream));
    for (int i = 0; i < cfg_.runs; ++i)
        launch_kernel(d_A, d_B, d_C, cfg_, stream);
    CHECK_CUDA(cudaEventRecord(ev_stop, stream));
    CHECK_CUDA(cudaEventSynchronize(ev_stop));

    float ms = 0.f;
    CHECK_CUDA(cudaEventElapsedTime(&ms, ev_start, ev_stop));
    return ms / cfg_.runs;
}