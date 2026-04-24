// bindings_int8.cpp
// PyTorch binding for INT8 GEMM kernels.
// Built by setup.py with one kernel .cu file per target.
// Usage (Python):
//   import tensor_core_int8
//   C = tensor_core_int8.gemm_int8(A, BT)    # A: [M,K] int8, BT: [N,K] int8 → C: [M,N] int32
//
// Note: B must be passed already transposed (BT layout: N×K row-major), matching the
// convention used throughout this project — the kernel expects the transposed matrix.

#include <torch/extension.h>
#include <ATen/cuda/CUDAContext.h>
#include "include/config.h"
#include "src/solver_int8.h"

torch::Tensor gemm_int8(torch::Tensor A, torch::Tensor BT) {
    TORCH_CHECK(A.is_cuda() && BT.is_cuda(),   "A and BT must be CUDA tensors");
    TORCH_CHECK(A.dtype() == torch::kInt8,      "A must be int8");
    TORCH_CHECK(BT.dtype() == torch::kInt8,     "BT must be int8");
    TORCH_CHECK(A.dim() == 2 && BT.dim() == 2, "A and BT must be 2-D");
    TORCH_CHECK(A.size(1) == BT.size(1),        "A cols must equal BT cols (both = K)");
    TORCH_CHECK(A.is_contiguous() && BT.is_contiguous(), "A and BT must be contiguous");

    int M = A.size(0), K = A.size(1), N = BT.size(0);
    auto C = torch::zeros({M, N}, A.options().dtype(torch::kInt32));

    GemmConfig cfg{M, N, K, /*num_batches=*/1, /*warmups=*/0, /*runs=*/1};
    cudaStream_t stream = at::cuda::getCurrentCUDAStream();

    launch_kernel(A.data_ptr<int8_t>(), BT.data_ptr<int8_t>(),
                  C.data_ptr<int32_t>(), cfg, stream);

    return C;
}

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    m.def("gemm_int8", &gemm_int8,
          "INT8 GEMM: A [M,K] int8 × BT [N,K] int8 → C [M,N] int32  (BT = B transposed)");
}
