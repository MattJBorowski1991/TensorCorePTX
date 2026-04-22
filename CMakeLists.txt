# Build with:
#   cmake -B build -DKERNEL=fp16_wmma -DCUDA_ARCH=89
#   cmake --build build
#   ./build/profile_fp16_wmma
#
# Optional overrides:
#   -DMAXRREGCOUNT=128   cap registers per thread
#   -DKERNEL=fp16_ptx    switch kernel variant

cmake_minimum_required(VERSION 3.24)
project(TensorCorePTX LANGUAGES CXX CUDA)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CXX_STANDARD  20)

set(CUDA_ARCH "89" CACHE STRING "Target SM architecture (e.g. 89 for Ada/L4)")
set(CMAKE_CUDA_ARCHITECTURES ${CUDA_ARCH})

set(KERNEL       "fp16_wmma" CACHE STRING "Kernel variant (maps to kernels/<KERNEL>.cu)")
set(MAXRREGCOUNT ""          CACHE STRING "Optional max registers per thread (e.g. 128)")

set(CUDA_FLAGS -O3 --use_fast_math -lineinfo -Xcompiler=-Wall)
if(MAXRREGCOUNT)
    list(APPEND CUDA_FLAGS -maxrregcount=${MAXRREGCOUNT})
endif()

add_executable(profile_${KERNEL}
    src/main.cu
    src/solver.cu
    src/data.cu
    kernels/${KERNEL}.cu
)

# Project root as include path — all headers used as "include/config.h", "src/solver.h", etc.
target_include_directories(profile_${KERNEL} PRIVATE ${CMAKE_SOURCE_DIR})
target_compile_options(profile_${KERNEL} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:${CUDA_FLAGS}>)
target_compile_definitions(profile_${KERNEL} PRIVATE KERNEL_VARIANT="${KERNEL}")

# ── INT8 kernel targets ───────────────────────────────────────────────────────
set(INT8_KERNEL "int8_wmma" CACHE STRING "INT8 kernel variant (maps to kernels/<INT8_KERNEL>.cu)")

add_executable(profile_${INT8_KERNEL}
    src/main_int8.cu
    src/solver_int8.cu
    src/data_int8.cu
    kernels/${INT8_KERNEL}.cu
)
target_include_directories(profile_${INT8_KERNEL} PRIVATE ${CMAKE_SOURCE_DIR})
target_compile_options(profile_${INT8_KERNEL} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:${CUDA_FLAGS}>)
target_compile_definitions(profile_${INT8_KERNEL} PRIVATE KERNEL_VARIANT="${INT8_KERNEL}")
