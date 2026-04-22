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

// ── Precision-loss measurement (512³, always runs) ───────────────────────────
// Full round-trip: FP32 → quantize → INT8 GEMM → dequantize → compare vs FP32 ref.
static void run_precision_loss() {
    constexpr int M = 512, N = 512, K = 512;

    std::vector<float>   h_A_fp32(M * K), h_BT_fp32(N * K);
    std::vector<float>   h_C_ref(M * N, 0.f), h_C_dequant(M * N, 0.f);
    std::vector<int8_t>  h_A_q(M * K), h_BT_q(N * K);
    std::vector<int32_t> h_C_int32(M * N, 0);

    // 1. Generate FP32 inputs.
    generate_fp32(h_A_fp32.data(), h_BT_fp32.data(), M, N, K, 1);

    // 2. CPU FP32 reference on original inputs.
    cpu_gemm_fp32(h_A_fp32.data(), h_BT_fp32.data(), h_C_ref.data(), M, N, K);

    // 3. Quantize: FP32 → INT8, per-tensor absmax. Save scales.
    float scale_A  = quantize_absmax(h_A_fp32.data(),  h_A_q.data(),  M * K);
    float scale_BT = quantize_absmax(h_BT_fp32.data(), h_BT_q.data(), N * K);

    // 4. Upload INT8 matrices and run GPU kernel.
    DeviceBuffer<int8_t>  d_A(M * K);
    DeviceBuffer<int8_t>  d_BT(N * K);
    DeviceBuffer<int32_t> d_C(M * N);

    CHECK_CUDA(cudaMemcpy(d_A.get(),  h_A_q.data(),  M * K * sizeof(int8_t), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(d_BT.get(), h_BT_q.data(), N * K * sizeof(int8_t), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemset(d_C.get(), 0, M * N * sizeof(int32_t)));

    GemmConfig vcfg{.M=M, .N=N, .K=K, .num_batches=1, .warmups=0, .runs=1};
    SolverInt8 solver;
    solver.configure(vcfg);
    solver.run(d_A.get(), d_BT.get(), d_C.get());

    // 5. Download INT32 output.
    CHECK_CUDA(cudaMemcpy(h_C_int32.data(), d_C.get(), M * N * sizeof(int32_t), cudaMemcpyDeviceToHost));

    // 6. Dequantize on CPU: C_fp32[i] = scale_A * scale_BT * C_int32[i].
    dequantize(h_C_int32.data(), h_C_dequant.data(), M * N, scale_A, scale_BT);

    // 7. Measure and print precision loss vs FP32 reference.
    AccuracyResultQuant acc = measure_accuracy_quant(h_C_ref.data(), h_C_dequant.data(), M, N);
    printf("[quant]   M=%d N=%d K=%d  scale_A=%.4e scale_BT=%.4e  "
           "max_abs=%.4e  rmse=%.4e  rel=%.3f%%  %s\n",
           M, N, K, scale_A, scale_BT,
           acc.max_abs_err, acc.rmse, acc.real_err_pct,
           acc.pass ? "PASS" : "FAIL");
}

// ── Main ──────────────────────────────────────────────────────────────────────
int main() {
    run_verify();
    run_precision_loss();

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
