// bindings_fp16.cpp
// PyTorch binding for FP16 GEMM kernels.
// Built by setup.py with one kernel .cu file per target.
// Usage (Python):
//   import tensor_core_fp16
//   C = tensor_core_fp16.gemm_fp16(A, B)     # A: [M,K] fp16, B: [K,N] fp16 → C: [M,N] fp32

#include <torch/extension.h>
#include <ATen/cuda/CUDAContext.h>
#include "include/config.h"
#include "src/solver.h"

// Declared in each kernel .cu file assembled into this build target.
void launch_kernel(const half* A, const half* B, float* C,
                   const GemmConfig& cfg, cudaStream_t stream);

torch::Tensor gemm_fp16(torch::Tensor A, torch::Tensor B) {
    TORCH_CHECK(A.is_cuda() && B.is_cuda(),    "A and B must be CUDA tensors");
    TORCH_CHECK(A.dtype() == torch::kFloat16,   "A must be fp16");
    TORCH_CHECK(B.dtype() == torch::kFloat16,   "B must be fp16");
    TORCH_CHECK(A.dim() == 2 && B.dim() == 2,  "A and B must be 2-D");
    TORCH_CHECK(A.size(1) == B.size(0),         "A cols must equal B rows");
    TORCH_CHECK(A.is_contiguous() && B.is_contiguous(), "A and B must be contiguous");

    int M = A.size(0), K = A.size(1), N = B.size(1);
    auto C = torch::zeros({M, N}, A.options().dtype(torch::kFloat32));

    GemmConfig cfg{M, N, K, /*num_batches=*/1, /*warmups=*/0, /*runs=*/1};
    cudaStream_t stream = at::cuda::getCurrentCUDAStream();

    launch_kernel(reinterpret_cast<const half*>(A.data_ptr()),
                  reinterpret_cast<const half*>(B.data_ptr()),
                  C.data_ptr<float>(),
                  cfg, stream);

    return C;
}

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    m.def("gemm_fp16", &gemm_fp16,
          "FP16 GEMM: A [M,K] fp16 × B [K,N] fp16 → C [M,N] fp32");
}
