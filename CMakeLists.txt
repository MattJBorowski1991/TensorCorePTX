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

set(KERNEL       "fp16_wmma" CACHE STRING "Kernel variant (maps to kernels/<KERNEL>.cu). Prefix int8_ → INT8 build, fp16_ → FP16 build.")
set(MAXRREGCOUNT ""          CACHE STRING "Optional max registers per thread (e.g. 128)")

set(CUDA_FLAGS -O3 --use_fast_math -lineinfo -Xcompiler=-Wall)
if(MAXRREGCOUNT)
    list(APPEND CUDA_FLAGS -maxrregcount=${MAXRREGCOUNT})
endif()

# Route sources automatically:
#   int4_ prefix → INT4 pipeline (main_int4.cu / solver_int4.cu / data_int4.cu)
#   int8_ prefix → INT8 pipeline (main_int8.cu / solver_int8.cu / data_int8.cu)
#   everything else → FP16 pipeline
string(FIND "${KERNEL}" "int4_" _int4_prefix)
string(FIND "${KERNEL}" "int8_" _int8_prefix)
if(_int4_prefix EQUAL 0)
    message(STATUS "INT4 build: profile_${KERNEL}")
    add_executable(profile_${KERNEL}
        src/main_int4.cu
        src/solver_int4.cu
        src/data_int4.cu
        kernels/${KERNEL}.cu
    )
elseif(_int8_prefix EQUAL 0)
    message(STATUS "INT8 build: profile_${KERNEL}")
    add_executable(profile_${KERNEL}
        src/main_int8.cu
        src/solver_int8.cu
        src/data_int8.cu
        kernels/${KERNEL}.cu
    )
else()
    message(STATUS "FP16 build: profile_${KERNEL}")
    add_executable(profile_${KERNEL}
        src/main.cu
        src/solver.cu
        src/data.cu
        kernels/${KERNEL}.cu
    )
endif()

# Project root as include path — all headers used as "include/config.h", "src/solver.h", etc.
target_include_directories(profile_${KERNEL} PRIVATE ${CMAKE_SOURCE_DIR})
target_compile_options(profile_${KERNEL} PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:${CUDA_FLAGS}>)
target_compile_definitions(profile_${KERNEL} PRIVATE KERNEL_VARIANT="${KERNEL}")
