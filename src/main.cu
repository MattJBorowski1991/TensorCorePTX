#include <stdio.h>
#include <vector>
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include "include/config.h"
#include "include/cuda_utils.h"
#include "src/solver.h"
#include "src/data.h"

// ── Helpers ──────────────────────────────────────────────────────────────────
static void run_verify() {
    constexpr int Mv = 512, Nv = 512, Kv = 512;

    std::vector<half>  h_A(Mv * Kv), h_B(Kv * Nv);
    std::vector<float> h_C_ref(Mv * Nv, 0.f), h_C_out(Mv * Nv, 0.f);

    generate_fp16(h_A.data(), h_B.data(), Mv, Nv, Kv, 1);
    cpu_gemm_fp16(h_A.data(), h_B.data(), h_C_ref.data(), Mv, Nv, Kv);

    DeviceBuffer<half>  d_A(Mv * Kv);
    DeviceBuffer<half>  d_B(Kv * Nv);
    DeviceBuffer<float> d_C(Mv * Nv);

    CHECK_CUDA(cudaMemcpy(d_A.get(), h_A.data(), Mv * Kv * sizeof(half),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_B.get(), h_B.data(), Kv * Nv * sizeof(half),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemset(d_C.get(), 0, Mv * Nv * sizeof(float)));

    GemmConfig vcfg{.M=Mv, .N=Nv, .K=Kv, .num_batches=1, .warmups=0, .runs=1};
    Solver solver;
    solver.configure(vcfg);
    solver.run(d_A.get(), d_B.get(), d_C.get());

    CHECK_CUDA(cudaMemcpy(h_C_out.data(), d_C.get(), Mv * Nv * sizeof(float), cudaMemcpyDeviceToHost));
    AccuracyResult acc = measure_accuracy(h_C_ref.data(), h_C_out.data(), Mv, Nv);
    printf("[verify]  M=%d N=%d K=%d  %s  max_abs=%.4e  rmse=%.4e  rel=%.3f%%\n",
           Mv, Nv, Kv, acc.pass ? "PASS" : "FAIL",
           acc.max_abs_err, acc.rmse, acc.real_err_pct);
}

// ── Main ─────────────────────────────────────────────────────────────────────
int main() {
    // Allow skipping the small verification run when profiling with Nsight.
    // Set `SKIP_VERIFY=1` in the environment to bypass the verify phase.
    if (!getenv("SKIP_VERIFY")) {
        run_verify();
    }

    // ── Profiling run ─────────────────────────────────────────────────────────
        // Allow overriding the profiling size via environment variable
        // Example: PROFILE_SIZE=4096 ./build/profile_fp16_ptx_fp16acc
        const char* env_sz = getenv("PROFILE_SIZE");
        int ProfilingSize = 8192;
        if (env_sz && env_sz[0] != '\0') {
            int v = atoi(env_sz);
            if (v > 0) ProfilingSize = v;
        }
        GemmConfig cfg{.M=ProfilingSize, .N=ProfilingSize, .K=ProfilingSize, .num_batches=4, .warmups=0, .runs=1};

    size_t szA = (size_t)cfg.num_batches * cfg.M * cfg.K;
    size_t szB = (size_t)cfg.num_batches * cfg.K * cfg.N;
    size_t szC = (size_t)cfg.num_batches * cfg.M * cfg.N;

    std::vector<half> h_A(szA), h_B(szB);
    generate_fp16(h_A.data(), h_B.data(), cfg.M, cfg.N, cfg.K, cfg.num_batches);

    DeviceBuffer<half>  d_A(szA);
    DeviceBuffer<half>  d_B(szB);
    DeviceBuffer<float> d_C(szC);

    CHECK_CUDA(cudaMemcpy(d_A.get(), h_A.data(), szA * sizeof(half),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_B.get(), h_B.data(), szB * sizeof(half),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemset(d_C.get(), 0, szC * sizeof(float)));

    Solver solver;
    solver.configure(cfg);
    float avg_ms = solver.run(d_A.get(), d_B.get(), d_C.get());

    double tflops = 2.0 * cfg.num_batches * (double)cfg.M * cfg.N * cfg.K
                    / (avg_ms * 1e-3) / 1e12;
        printf("[profile] %s | M=%d N=%d K=%d B=%d | %.3f ms avg | %.2f TFLOPS\n",
            KERNEL_VARIANT, cfg.M, cfg.N, cfg.K, cfg.num_batches, avg_ms, tflops);

    return 0;
}
