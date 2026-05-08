#pragma once
#include <stdint.h>
#include "include/config.h"

void launch_kernel(const int8_t* A, const int8_t* BT, int32_t* C,
                   const GemmConfig& cfg, cudaStream_t stream);

class SolverInt4 {
public:
    void  configure(const GemmConfig& cfg);
    float run(const int8_t* d_A, const int8_t* d_BT, int32_t* d_C);
private:
    GemmConfig cfg_;
};
