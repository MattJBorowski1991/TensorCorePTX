#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define CHECK_CUDA(call)\
    do {\
        cudaError_t err = call;\
        if(err != cudaSuccess){\
            fprintf(stderr, "CUDA Error at %s - %d: %s", __FILE__, __LINE__, cudaGetErrorString(err));\
            exit(1);\
        } \
    } while(0);

template<typename T>
struct DeviceBuffer {
    T* ptr = nullptr;
    explicit DeviceBuffer(size_t n){ cudaMalloc(&ptr, n * sizeof(T));} // explicit = block implicit conversion
    ~DeviceBuffer() {cudaFree(ptr); }
    DeviceBuffer(const DeviceBuffer&) = delete; // disable the copy constructor (eg DeviceBuffer<float> buf2 = buf1;) = force unique memory ownership
    DeviceBuffer& operator=(const DeviceBuffer&) = delete; // disable copy assignment operator (eg bufA = bufB;)
    DeviceBuffer(DeviceBuffer&& other) noexcept : ptr(other.ptr) {other.ptr = nullptr; }
    DeviceBuffer& operator=(DeviceBuffer&& other) noexcept {
        if(this != other) { cudaFree(ptr); ptr = other.ptr; other.ptr = nullptr; }
        return *this;
    }
    T* get() const {return ptr; } // allow to use .get() also on const objects
};

struct CudaEvent{
    cudaEvent_t ev;
    CudaEvent() { cudaEventCreate(&ev); }
    ~CudaEvent() { cudaEventDestroy(ev); }
    operator cudaEvent_t() const { return ev; }
};

struct CudaStream {
    cudaStream_t s;
    CudaStream() {CHECK_CUDA(cudaStreamCreate(&s)); }
    ~CudaStream() { CHECK_CUDA(cudaStreamDestroy(s)); }
    operator cudaStream_t() const {return s; }
};  