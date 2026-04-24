# setup.py — PyTorch C++/CUDA extension build for TensorCorePTX kernels.
#
# Build a specific kernel variant by passing KERNEL or INT8_KERNEL env vars:
#
#   FP16 examples:
#     KERNEL=fp16_wmma          pip install -e .
#     KERNEL=fp16_ptx_mma       pip install -e .
#     KERNEL=fp16_ptx_3stage    pip install -e .
#
#   INT8 examples:
#     INT8_KERNEL=int8_wmma           pip install -e .
#     INT8_KERNEL=int8_ptx_mma_k16   pip install -e .
#     INT8_KERNEL=int8_ptx_3stage    pip install -e .
#     INT8_KERNEL=int8_dp4a          pip install -e .
#
# The installed module name matches the kernel name, e.g.:
#   import fp16_wmma;         fp16_wmma.gemm_fp16(A, B)
#   import int8_ptx_mma_k16;  int8_ptx_mma_k16.gemm_int8(A, BT)

import os
from setuptools import setup
from torch.utils.cpp_extension import CUDAExtension, BuildExtension

CUDA_ARCH  = os.environ.get("CUDA_ARCH",    "89")          # default: Ada/L4 SM89
KERNEL     = os.environ.get("KERNEL",       "")
INT8_KERNEL = os.environ.get("INT8_KERNEL", "")

if not KERNEL and not INT8_KERNEL:
    # Default: build the plain FP16 WMMA baseline
    KERNEL = "fp16_wmma"

if KERNEL and INT8_KERNEL:
    raise ValueError("Set only one of KERNEL or INT8_KERNEL, not both.")

ROOT = os.path.dirname(os.path.abspath(__file__))

nvcc_flags = [
    f"-arch=sm_{CUDA_ARCH}",
    "-O3",
    "--use_fast_math",
    "-lineinfo",
    "-std=c++20",
]

if KERNEL:
    # ── FP16 build ─────────────────────────────────────────────────────────
    ext = CUDAExtension(
        name=KERNEL,
        sources=[
            os.path.join(ROOT, "bindings", "bindings_fp16.cpp"),
            os.path.join(ROOT, "src",      "solver.cu"),
            os.path.join(ROOT, "src",      "data.cu"),
            os.path.join(ROOT, "kernels",  f"{KERNEL}.cu"),
        ],
        include_dirs=[ROOT],
        extra_compile_args={
            "cxx":  ["-O3", "-std=c++20"],
            "nvcc": nvcc_flags,
        },
        define_macros=[("KERNEL_VARIANT", f'\\"{KERNEL}\\"')],
    )
else:
    # ── INT8 build ─────────────────────────────────────────────────────────
    ext = CUDAExtension(
        name=INT8_KERNEL,
        sources=[
            os.path.join(ROOT, "bindings", "bindings_int8.cpp"),
            os.path.join(ROOT, "src",      "solver_int8.cu"),
            os.path.join(ROOT, "src",      "data_int8.cu"),
            os.path.join(ROOT, "kernels",  f"{INT8_KERNEL}.cu"),
        ],
        include_dirs=[ROOT],
        extra_compile_args={
            "cxx":  ["-O3", "-std=c++20"],
            "nvcc": nvcc_flags,
        },
        define_macros=[("KERNEL_VARIANT", f'\\"{INT8_KERNEL}\\"')],
    )

setup(
    name=KERNEL or INT8_KERNEL,
    ext_modules=[ext],
    cmdclass={"build_ext": BuildExtension},
)
