#pragma once
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include "include/config.h"

class Solver {
public:
    void configure(const GemmConfig& cfg);
    // Returns average kernel time in milliseconds over cfg.runs timed iterations.
    float run(const half* d_A, const half* d_B, float* d_C);
private:
    GemmConfig cfg_{};
};