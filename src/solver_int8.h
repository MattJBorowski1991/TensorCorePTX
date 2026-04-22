#pragma once
#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"

// Defined in each INT8 kernel file (one per build target).
void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream);

class SolverInt8 {
public:
    void configure(const GemmConfig& cfg);
    // Returns average kernel time in milliseconds over cfg.runs timed iterations.
    float run(const int8_t* d_A, const int8_t* d_BT, int32_t* d_C);
private:
    GemmConfig cfg_{};
};
