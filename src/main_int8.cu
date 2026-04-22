#include <stdio.h>
#include <vector>
#include <cuda_runtime.h>
#include <stdint.h>
#include "include/config.h"
#include "include/cuda_utils.h"
#include "src/solver_int8.h"
#include "src/data_int8.h"

// ── Verification (512³, always runs) ─────────────────────────────────────────
static void run_verify() {
    constexpr int Mv = 512, Nv = 512, Kv = 512;

    std::vector<int8_t>  h_A(Mv * Kv), h_BT(Nv * Kv);
    std::vector<int32_t> h_C_ref(Mv * Nv, 0), h_C_out(Mv * Nv, 0);

    generate_int8(h_A.data(), h_BT.data(), Mv, Nv, Kv, 1);
    cpu_gemm_int8(h_A.data(), h_BT.data(), h_C_ref.data(), Mv, Nv, Kv);

    DeviceBuffer<int8_t>  d_A(Mv * Kv);
    DeviceBuffer<int8_t>  d_BT(Nv * Kv);
    DeviceBuffer<int32_t> d_C(Mv * Nv);

    CHECK_CUDA(cudaMemcpy(d_A.get(),  h_A.data(),  Mv * Kv * sizeof(int8_t),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_BT.get(), h_BT.data(), Nv * Kv * sizeof(int8_t),  cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemset(d_C.get(), 0, Mv * Nv * sizeof(int32_t)));

    GemmConfig vcfg{.M=Mv, .N=Nv, .K=Kv, .num_batches=1, .warmups=0, .runs=1};
    SolverInt8 solver;
    solver.configure(vcfg);
    solver.run(d_A.get(), d_BT.get(), d_C.get());

    CHECK_CUDA(cudaMemcpy(h_C_out.data(), d_C.get(), Mv * Nv * sizeof(int32_t), cudaMemcpyDeviceToHost));

    AccuracyResultI32 acc = measure_accuracy_int8(h_C_ref.data(), h_C_out.data(), Mv, Nv);
    printf("[verify]  M=%d N=%d K=%d  %s  max_abs=%d  rmse=%.4e\n",
           Mv, Nv, Kv, acc.pass ? "PASS" : "FAIL",
           acc.max_abs_err, acc.rmse);
}

// ── Main ──────────────────────────────────────────────────────────────────────
int main() {
    run_verify();

    // ── Profiling run ─────────────────────────────────────────────────────────
    const char* env_sz = getenv("PROFILE_SIZE");
    int ProfilingSize = 8192;
    if (env_sz && env_sz[0] != '\0') {
        int v = atoi(env_sz);
        if (v > 0) ProfilingSize = v;
    }
    GemmConfig cfg{.M=ProfilingSize, .N=ProfilingSize, .K=ProfilingSize, .num_batches=4, .warmups=0, .runs=1};

    size_t szA  = (size_t)cfg.num_batches * cfg.M * cfg.K;
    size_t szBT = (size_t)cfg.num_batches * cfg.N * cfg.K;  // BT is N×K
    size_t szC  = (size_t)cfg.num_batches * cfg.M * cfg.N;

    std::vector<int8_t> h_A(szA), h_BT(szBT);
    generate_int8(h_A.data(), h_BT.data(), cfg.M, cfg.N, cfg.K, cfg.num_batches);

    DeviceBuffer<int8_t>  d_A(szA);
    DeviceBuffer<int8_t>  d_BT(szBT);
    DeviceBuffer<int32_t> d_C(szC);

    CHECK_CUDA(cudaMemcpy(d_A.get(),  h_A.data(),  szA  * sizeof(int8_t), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_BT.get(), h_BT.data(), szBT * sizeof(int8_t), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemset(d_C.get(), 0, szC * sizeof(int32_t)));

    SolverInt8 solver;
    solver.configure(cfg);
    float avg_ms = solver.run(d_A.get(), d_BT.get(), d_C.get());

    // INT8 GEMM: 2*M*N*K MACs (same op-count formula as FP16)
    double tops = 2.0 * cfg.num_batches * (double)cfg.M * cfg.N * cfg.K
                  / (avg_ms * 1e-3) / 1e12;
    printf("[profile] %s | M=%d N=%d K=%d B=%d | %.3f ms avg | %.2f TOPS\n",
           KERNEL_VARIANT, cfg.M, cfg.N, cfg.K, cfg.num_batches, avg_ms, tops);

    return 0;
}
