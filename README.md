# TensorCorePTX — PTX-first Tensor Core GEMM Exploration

This repository collects findings, experiments, and design notes for implementing high-performance PTX GEMM kernels using `cp.async`, `ldmatrix` and `mma.sync` on Nvidia L4 (Ada/SM89). The focus is a PTX-first path across three precisions (`fp16`, `int8`, `int4`): for each precision we run a multi-variant deep dive over key PTX instruction choices and compare against a double-buffered WMMA-API kernel used as the baseline.

## Table of Contents
- [Overview](#overview)
- [Run 1 — fp16 - Profiling Results](#run-1--fp16---profiling-results)
- [Run 2 — int8 - Profiling Results](#run-2--int8---profiling-results)
- [Run 3 — int4 - Profiling Results for Base Kernels](#run-3--int4---profiling-results-for-base-kernels)
- [Run 4 — int4 - Profiling Results for the optimal k64 kernel family](#run-4--int4---profiling-results-for-the-optimal-k64-kernel-family)

## Overview

Most kernels in this project follow the same core pattern: overlap DRAM->SRAM prefetch (`cp.async`) with tile-level compute in registers (`ldmatrix` + `mma.sync`) to hide memory latency. Additional variants include manual SRAM->register packing paths (no `ldmatrix`) and an INT8 `dp4a` path; for each precision family, the baseline is always the WMMA-API kernel (`*_wmma`), and PTX variants are evaluated relative to that baseline.

**Run 1 (`fp16`)** benchmarks the FP16 PTX design space against `fp16_wmma` and establishes the first compute-bound vs memory-bound split. Main result: PTX variants are competitive, but no FP16 PTX variant clearly beats the WMMA baseline across all sizes.

**Run 2 (`int8`)** compares several INT8 PTX formulations against `int8_wmma`, including `k16`, `k32`, `3stage`, manual packing, and `dp4a`. Main result: `int8_ptx_mma_k32` is consistently best, with instruction-count efficiency and better coalescing driving the win, especially at large N.

**Run 3 (`int4`)** is the base INT4 comparison that identifies the winning family before fine-grained tuning. Main result: `int4_ptx_mma_k64` and `int4_ptx_3stage` dominate by avoiding WMMA INT4 emulation overhead; `3stage` leads at small sizes, while `k64` scales better at large sizes.

**Run 4 (`int4 k64 deep dive`)** isolates the `int4_ptx_mma_k64*` family and sweeps loader split (`x1/x2/x4`), cache policy (`ca/cg`), and B layout (`nontrans/trans`). Main result: non-trans `ca` variants form a tight optimum basin, `cg` is a mild regression, and `trans` is a structural outlier with severe coalescing and throughput collapse.



## mma.sync Tile Shapes

Available shapes (L4 / SM89) by precision:

| Precision | mma.sync shapes         |
|-----------|-------------------------|
| FP16      | m16n8k8, m16n8k16       |
| INT8      | m16n8k16, m16n8k32      |
| INT4      | m16n8k32, m16n8k64      |

---

## Run 1 — fp16 - Profiling Results

> Full Summary: [`prof/md/run1/ncu_summary.md`](prof/md/run1/ncu_summary.md)

![NCU Metrics Chart](prof/md/run1/ncu_metrics_chart.png)

Six FP16 GEMM kernels were profiled with Nsight Compute across matrix sizes N = 512 → 16384 (square, FP16 inputs, FP32 accumulation). The four tracked metrics — GFLOPS, Compute (SM) Throughput %, Achieved Occupancy %, and L1/TEX Cache Throughput % — reveal two distinct operating regimes separated by an L2 capacity cliff between N = 4096 and N = 8192.

**Compute-bound regime (N ≤ 4096):** All kernels sustain 1,280–1,500 GFLOPS. `fp16_ptx_manual_pack` has the highest Compute (SM) % (~57%) and `fp16_ptx_k8` is second (~47%), but both are still slower than `fp16_wmma` — the baseline WMMA intrinsic path. The penalty ranges from +1% (`ptx_mma`, `ptx_k8`) up to +22% (`ptx_manual_pack`) at N = 512 due to unrecovered packing overhead at small tile counts. No hand-written PTX variant outperforms the compiler-optimised WMMA path in this regime.

**Memory-bound regime (N ≥ 8192):** Once the matrices (~537 MB combined at N = 8192, FP16 A/B + FP32 C) exceed L2 capacity, every kernel stalls on DRAM. L1/TEX throughput collapses from ~90% to ~38%, GFLOPS halves to 620–666, and all slowdown differences shrink to < 1%. The instruction mix becomes irrelevant — bandwidth is the sole bottleneck.

**`fp16_ptx_fp16acc` occupancy anomaly:** Using FP16 accumulators halves the accumulator register count, lifting Achieved Occupancy to 70–82% vs 56–66% for all other kernels. Despite this, GFLOPS are not higher — confirming that occupancy alone does not drive throughput when the kernel is not latency-limited by a warp-count shortage.

**Next steps:** (1) verify tensor-core `mma` instructions are actually being issued via `inst_executed_pipe_tensor`; (2) profile DRAM bandwidth to quantify saturation at large sizes; (3) improve shared-memory tiling to recover L1/TEX utilisation in the compute-bound region; (4) extend triple-buffered `cp.async` pipeline (`ptx_3stage`) more aggressively to mask L2 latency at the cliff boundary.

| Kernel | SRAM→Regs | mma.sync shape | Acc type | Pipeline | Notes |
|---|---|---|---|---|---|
| `fp16_wmma` | `wmma::load_matrix_sync` | m16n16k16 (WMMA) | f32 | 2-stage cp.async | WMMA baseline; no explicit PTX |
| `fp16_ptx_mma` | `ldmatrix.x4` / `.x2.trans` | m16n8k16 × 2 | f32 | 2-stage cp.async | First pure-PTX kernel |
| `fp16_ptx_k8` | `ldmatrix.x2` / `.x1.trans` | m16n8k8 × 4 | f32 | 2-stage cp.async | Narrower K tile; 4 MMA calls per K-step |
| `fp16_ptx_fp16acc` | `ldmatrix.x4` / `.x2.trans` | m16n8k16 × 2 | f16 (packed) | 2-stage cp.async | Half the accumulator registers vs f32 |
| `fp16_ptx_3stage` | `ldmatrix.x4` / `.x2.trans` | m16n8k16 × 2 | f32 | **3-stage** cp.async | `wait_group 1`; one extra SRAM buffer to hide L2 latency |
| `fp16_ptx_manual_pack` | 4+2 scalar `ld.shared` + `mov.b32` | m16n8k16 × 2 | f32 | 2-stage cp.async | No `ldmatrix`; exposes its instruction-count cost |

---

## Run 2 — int8 - Profiling Results

> Full Analysis: [`prof/md/run2/ncu_details.md`](prof/md/run2/ncu_details.md)

Six INT8 GEMM kernels were profiled with Nsight Compute across matrix sizes N = 512 → 8192 (square, INT8 A/B inputs, INT32 accumulation, no in-kernel dequant). Performance is measured relative to `int8_wmma` (the WMMA-API baseline).

![Average DRAM Active Cycles — flat at N≤4096 (compute-bound), diverges at N=8192 mirroring the speedup ranking](prof/charts/run2/gpu_and_memory_workload_distribution__average_dram_active_cycles_cycle.png)

**Speedup / slowdown vs `int8_wmma` (negative = faster):**

| Size | k32 | k16 | manual_pack | 3stage |
|---|---|---|---|---|
| 512 | **−23%** | +35% | +5% | ~0% |
| 1024 | **−29%** | +20% | +5% | +4% |
| 2048 | **−30%** | +12% | +4% | +20% |
| 4096 | **−33%** | +7% | +2% | +37% |
| 8192 | **−43%** | −32% | −28% | −4% |

**`int8_ptx_mma_k32` is the fastest kernel at every size**, ranging from 23% faster than `int8_wmma` at N=512 up to 43% faster at N=8192. Its advantage is rooted in instruction count: it executes 25–43% fewer instructions than wmma by decomposing each K=32 tile step into two tightly unrolled `m16n8k16` MMA calls, eliminating most of the overhead present in the other kernels. Its coalescing is also exceptional — only 0.4% wasted global sectors at N=8192, vs ~50% for every other kernel.

**`int8_ptx_mma_k16` is *slower* than `int8_wmma` at small–medium sizes** (+7% to +35% at N=512–4096) but overtakes it at N=8192 (−32%). Its uncoalesced global load pattern (1 of 32 bytes used per sector) generates enormous excess traffic; at large sizes a 76% L1 hit rate absorbs this and the kernel recovers. NCU estimates an 80–85% potential speedup from fixing the access pattern alone.

**`int8_ptx_3stage` degrades sharply at N=4096** (+37% vs wmma) due to MIO queue saturation — its triple-buffer prefetch schedule generates heavy shared-memory pressure that the scheduler cannot hide. It recovers at N=8192 (−4% vs wmma) but never leads the field.

**`int8_ptx_manual_pack`** (scalar `ld.shared` + `prmt.b32` packing, no `ldmatrix`) **is within 2–5% of `int8_wmma`** across all sizes and achieves the highest IPC of all kernels (1.93 at N=512, 1.72 at N=8192). Its dense ALU packing sequence keeps the scheduler fed consistently.

**`int8_dp4a` is never competitive** — even at N=8192 it is 175% slower than wmma (4.8×). Scalar DP4A instructions emit 3–5× more instructions per unit of arithmetic work than MMA, saturate the MIO queue, and cannot exploit tensor cores.

**Occupancy is not the performance predictor.** `int8_wmma` achieves the highest occupancy at every size yet is consistently outrun by `k32` (which is register-capped at 66.7% theoretical). The bottleneck is instruction efficiency and memory latency, not warp count.

**Average DRAM Active Cycles is the N=8192 performance fingerprint.** At N ≤ 4096 all kernels show essentially identical DRAM active cycle counts (within ~1% of each other), confirming the compute-bound regime. At N=8192 the spread becomes enormous: `k32` logs 1.57B DRAM-active cycles vs `wmma`'s 2.80B — a −43.9% reduction that tracks almost exactly with its −43% wall-clock speedup. The same correspondence holds for every kernel (k16: −34.8% DRAM / −32% wall-clock; manual_pack: −32.6% / −28%; 3stage: −6.4% / −4%). This is the clearest evidence that N=8192 is purely DRAM-latency-bound and that the performance ranking is entirely explained by coalescing quality: `k32` wastes only 0.4% of global sectors vs ~50% for the others.

| Kernel | SRAM→Regs | mma.sync shape | Acc type | Pipeline | Notes |
|---|---|---|---|---|---|
| `int8_wmma` | `wmma::load_matrix_sync` | m16n16k16 (WMMA) | int32 | 2-stage cp.async | WMMA baseline |
| `int8_ptx_mma_k16` | `ldmatrix.x2` / `.x1.trans` | m16n8k16 × 2 | int32 | 2-stage cp.async | Fastest at N=8192 behind k32; poor coalescing |
| `int8_ptx_mma_k32` | 2×`ldmatrix.x2` / 4×`.x1.trans` | m16n8k16 × 4 (k32 decomposed) | int32 | 2-stage cp.async | **Fastest overall**; fewest instructions; best coalescing |
| `int8_ptx_manual_pack` | 4+4 scalar `ld.shared` + `prmt.b32` | m16n8k16 × 2 | int32 | 2-stage cp.async | Highest IPC; no `ldmatrix`; within 5% of wmma |
| `int8_ptx_3stage` | `ldmatrix.x2` / `.x1.trans` | m16n8k16 × 2 | int32 | **3-stage** cp.async | MIO-saturated at mid sizes; recovers at N=8192 |
| `int8_dp4a` | scalar `ld.shared` | `dp4a.s32.s32` × K/4 | int32 | none | Scalar only; no tensor cores; 4.8× slower than wmma at N=8192 |

---

## Run 3 — int4 - Profiling Results for Base Kernels

> Full Analysis: [`prof/md/run3/ncu_details.md`](prof/md/run3/ncu_details.md)

Five INT4 kernels were profiled across N = 512 -> 8192 with `int4_wmma` as baseline. The two top kernels are `int4_ptx_mma_k64` and `int4_ptx_3stage`: `3stage` is fastest at very small sizes (512/1024), while `k64` becomes fastest from 2048 onward and widens the lead at large N.

![Avg. Active Threads Per Warp](prof/charts/run3/Warp_State_Statistics_Avg._Active_Threads_Per_Warp.png)

**Wall-time speedup vs `int4_wmma` (from run3 profile):**

| Size | `int4_ptx_3stage` | `int4_ptx_mma_k64` |
|---|---|---|
| 512 | **+248%** | +187% |
| 1024 | **+280%** | +267% |
| 2048 | +292% | **+306%** |
| 4096 | +271% | **+319%** |
| 8192 | +261% | **+327%** |

At N=8192, the top-2 separation from the middle pack is large in both wall time and instruction pressure: `int4_ptx_mma_k64` / `int4_ptx_3stage` run at 167.10 / 197.63 ms, while `int4_ptx_mma_k32` / `int4_ptx_manual_pack` are 269.35 / 277.13 ms. The same ordering appears in average executed instructions per scheduler (~45-46M for k64/3stage vs ~79-81M for k32/manual_pack), confirming that arithmetic-density and instruction footprint are dominant differentiators once WMMA emulation is removed.

The key crossover mechanism between the two winners is memory hierarchy behavior, not tensor-core utilization: `3stage` is best at small sizes due to deeper prefetch overlap, but as N grows it becomes strongly L2-driven. By N=8192, `3stage` reaches ~95.6% L2 throughput with L1 hit rate collapsed to ~14.5%, while `k64` retains ~61.6% L1 hit rate and therefore better large-size latency.

**Run 3 key metrics at N=8192:**

| Metric | int4_wmma | int4_ptx_mma_k64 | int4_ptx_3stage |
|---|---:|---:|---:|
| Duration (ms) | 712.96 | **167.10** | 197.63 |
| Avg active threads/warp | 16.89 | **32** | **32** |
| Avg divergent branches | 4,610,118 | **0** | **0** |
| Avg executed instr/scheduler | ~295M | **~45M** | **~46M** |
| L1/TEX hit rate (%) | 80.34 | **61.56** | 14.49 |
| L2 throughput (%) | lower | moderate | **95.6** |

**Condensed takeaways:**

- `int4_wmma` underperforms mainly because WMMA INT4 (`wmma::experimental::precision::s4`) is software-expanded, which inflates instruction count and introduces heavy lane-dependent divergence.
- The winning PTX kernels call native INT4 Tensor Core MMA directly (`mma.sync...m16n8k64.s4`) and avoid that expansion cost.
- Warp efficiency is the biggest separator: winners keep ~32 active threads/warp with zero divergent branches, while `int4_wmma` runs with partial warp activity and millions of divergent branches at large sizes.
- Instruction pressure tracks performance closely: winners execute roughly 6-7x fewer instructions per scheduler than `int4_wmma` at large N.
- `k64` sustains stronger large-size behavior than `3stage` because `3stage` becomes more L2-bound as N grows (L1 hit-rate collapse), while `k64` keeps much higher L1 locality at N=8192 (~62% vs ~14% for `3stage`).

---

## Run 4 — int4 - Profiling Results for the optimal k64 kernel family

> Full Analysis: [`prof/md/run4/ncu_details.md`](prof/md/run4/ncu_details.md)

This run isolates the `int4_ptx_mma_k64*` family to test loader split (`x1/x2/x4`), cache policy (`ca` vs `cg`), and B layout (`nontrans` vs `trans`) while keeping the core MMA strategy fixed.

![Memory Throughput (GB/s)](prof/charts/run4/Memory_Workload_Analysis_Memory_Throughput_Gbyte_s.png)

**Duration delta vs baseline `x4_x2nontrans_ca`:**

| Size | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---:|---:|---:|---:|---:|
| 512 | -0.3% | -0.3% | +1.4% | +7.1% | +237.3% |
| 1024 | -0.3% | -0.3% | +1.4% | +7.1% | +237.3% |
| 2048 | +1.1% | +0.8% | +4.0% | +7.0% | +239.8% |
| 4096 | +3.7% | +2.5% | +4.2% | +9.6% | +243.5% |
| 8192 | +3.9% | +2.3% | +3.1% | +5.9% | +242.2% |

Run4 shows that the chosen k64 baseline sits inside a tight local optimum basin: non-trans `ca` variants (`x1/x2/x4`) move only a few percent because they do not change the bottleneck class. Their occupancy, scheduler eligibility class, and memory-throughput range remain similar, so tuning these knobs mostly redistributes pressure between L1/L2 and instruction issue rather than changing end-to-end throughput.

By contrast, the `cg` and `trans` variants reveal two distinct failure modes. `cg` causes a mild latency regression by shifting too much traffic to L2 (lower L1 hit, higher L2 pressure), while `trans` causes a structural collapse from poor coalescing: very low useful bytes per sector, large excessive-sector counts, reduced eligible warps, and much higher warp cycles per instruction. This is why `trans` is not just "slower" but qualitatively off the optimal path.

**Run4 diagnostic snapshot (baseline vs key variants):**

| Metric | x4_x2nontrans_ca (baseline) | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---:|---:|---:|
| Duration delta vs baseline | 0% | ~+6% to +10% | ~+237% to +244% |
| L1/TEX hit rate (%) | ~64 | ~20 | very low utility |
| L2 throughput (%) | ~26 | ~50 | high-pressure, low-efficiency |
| Eligible warps/scheduler | ~0.57 | ~0.50 | ~0.20 |
| Warp cycles/executed instruction | ~12.5 | ~13.8 | ~27.8 |
| Useful global-load payload | healthy | moderate | ~2.2 / 32 bytes per sector |
| Memory throughput (Gbyte/s) | ~16-17 | slightly lower | ~5 |
| Excessive global sectors (N=2048) | 32,768 / 327,680 (10%) | higher than baseline | 1,998,848 / 2,293,760 (87%) |

**Condensed takeaways:**

- Non-trans `ca` variants are effectively tied: changing `x1/x2/x4` shifts only second-order metrics (L1/L2 mix, eligible warps, few-percent latency), not the dominant bottleneck.
- `x4_x2nontrans_cg` is consistently slightly worse because it pushes traffic from L1 to L2 (L1 hit/throughput down, L2 throughput up), increasing latency without compute-side benefit.
- `x4_x2trans_ca` is structurally worse (~3.4x slower): severe uncoalesced global loads and shared bank conflicts drive scheduler starvation.
- As a direct result, `x4_x2trans_ca` shows a collapse in effective memory throughput (Gbyte/s) versus the non-trans baseline.
- Trans evidence is direct in NCU: only ~2.2/32 bytes per global-load sector utilized, eligible warps/scheduler ~0.20 vs ~0.57 baseline, and warp cycles/instruction ~27.8 vs ~12.5 baseline.
- Baseline remains optimal because none of the tested knobs changed the bottleneck class; they only redistributed pressure inside the same bound.

---

#### Precision Loss Measurement

Quantization error is measured via the full round-trip pipeline, fixed at 512³ (single batch):

1. **Generate FP32 inputs** A (M×K) and B_T (N×K) with uniform values in [−1, 1].
2. **CPU FP32 reference GEMM** on the original inputs — this is the ground truth.
3. **Quantize per-tensor (absmax)**: `scale = max(|x|) / 127`, `x_int8 = round(x / scale)`, clamped to [−127, 127]. Separate scales for A and B.
4. **Upload** int8 matrices to GPU. Scales are scalar floats kept on the host.
5. **Run INT8 GEMM** → INT32 accumulator. No dequant inside the kernel — the kernel stays a pure integer compute unit so throughput measurements are not skewed.
6. **Download** INT32 output; **dequantize on host**: `C_fp32[i] = scale_A × scale_B × C_int32[i]`.
7. **Compare** dequantized vs FP32 reference: `max_abs_err`, `rmse`, `mean relative error %`.

Measuring at a single size is sufficient — quantization error is driven by the value distribution and K depth (accumulation length), not matrix dimension.

## PyTorch Bindings

Each kernel can be installed as a standalone Python extension via `setup.py`. One extension = one kernel; the module name matches the kernel name.

```bash
# Install an INT8 kernel (B must be passed pre-transposed as [N,K])
INT8_KERNEL=int8_ptx_mma_k16 pip install -e .

# Install an FP16 kernel
KERNEL=fp16_ptx_3stage pip install -e .

# Rebuild after editing a kernel (editable install re-compiles automatically)
INT8_KERNEL=int8_ptx_mma_k16 pip install -e . --no-build-isolation
```

```python
import torch
import int8_ptx_mma_k16

M, K, N = 4096, 4096, 4096
A  = torch.randint(-127, 127, (M, K), dtype=torch.int8,  device="cuda")
B  = torch.randint(-127, 127, (K, N), dtype=torch.int8,  device="cuda")
BT = B.t().contiguous()                           # kernel expects B transposed: [N, K]

C  = int8_ptx_mma_k16.gemm_int8(A, BT)           # → [M, N] int32, no dequant inside kernel
C_fp32 = C.float() * scale_A * scale_B            # dequantize on host if needed
```

```python
import torch
import fp16_ptx_3stage

A = torch.randn(4096, 4096, dtype=torch.float16, device="cuda")
B = torch.randn(4096, 4096, dtype=torch.float16, device="cuda")
C = fp16_ptx_3stage.gemm_fp16(A, B)              # → [M, N] float32
```

The `CUDA_ARCH` env var (default `89`) selects the SM target. For an A100 use `CUDA_ARCH=80`.
Bindings live in `bindings/bindings_fp16.cpp` and `bindings/bindings_int8.cpp`; `setup.py` wires them to the correct kernel sources.

---

## Compile & Run
```
rm -rf build && cmake -B build -DKERNEL=fp16_ptx_fp16acc -DCUDA_ARCH=89 && cmake --build build -j$(nproc)
./build/profile_fp16_ptx_fp16acc > fp16_ptx_fp16acc.txt

# Run NVIDIA Nsight Compute (`ncu`) across a set of 2^N sizes.
# This invokes the same executable repeatedly while setting `PROFILE_SIZE`.
for S in 512 1024 2048 4096 8192 16384; do
	echo "Profiling size=$S"
	SKIP_VERIFY=1 PROFILE_SIZE=$S ncu --set full --target-processes all ./build/profile_fp16_ptx_fp16acc \
		> fp16_ptx_fp16acc_ncu_${S}.txt 2>&1
done


# Full NCU report

ncu --import-source yes --set full --export prof/int4_wmma ./build/profile_int4_wmma
```