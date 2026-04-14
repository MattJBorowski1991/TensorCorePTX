# NCU Profiling Session — Summary & Takeaways

## Key Metrics

**3 most important metrics identified:**

- **Compute (SM) Throughput %** — primary indicator of tensor-core utilization. Ranges 15–57% across kernels/sizes. Higher = better PTX instruction mix.
- **Achieved Occupancy %** — reveals whether register pressure or shared-memory footprint limits active warps. `fp16_ptx_fp16acc` is the outlier at 82%; all others cluster 56–66%.
- **L1/TEX Cache Throughput %** — the actionable bottleneck. Differences in operand staging (ldmatrix vs. scalar loads vs. cp.async) show up here directly. Saturated L1 = no gain from adding pipeline stages without better coalescing.

---

## Chart Summary

![NCU Metrics Chart](ncu_metrics_chart.png)

The chart is a 2×2 figure. Each panel shows **grouped bars (left axis)** for one metric across all 6 kernels and 6 matrix sizes, and **scatter dots (right axis)** showing % slowdown of each kernel relative to `fp16_wmma` (baseline = +0.0%).

| Panel | Left axis | Key observation |
|---|---|---|
| Top-left | Peak GFLOPS | All kernels reach ~1,450–1,500 GFLOPS at small sizes; drop sharply to ~620–666 GFLOPS at N≥8K due to L2 capacity cliff |
| Top-right | Compute (SM) Throughput % | `ptx_manual_pack` leads at 56–57%; `ptx_k8` is second at 47–48%; others cluster 37–40% |
| Bottom-left | Achieved Occupancy % | `ptx_fp16acc` is uniquely high (70–82%); all others converge to 64–66% at large sizes |
| Bottom-right | L1/TEX Cache Throughput % | All kernels near 90–94% at small sizes; cliff drop to 38–44% at N≥8K when data exceeds L2 |

**Red dashed vertical line** marks the L2 capacity threshold (between N=4K and N=8K).

---

## Slowdown vs fp16_wmma (dots, right axis)

- `ptx_manual_pack` is **+22% slower** than `wmma` at N=512; overhead amortizes to ~+1% at N≥8K.
- All other PTX kernels stay within **+0–5%** of `wmma` across all sizes.
- At N≥8K all kernels converge to near +0% — in the memory-bound regime the instruction mix is irrelevant; every kernel stalls on DRAM equally.

---

## Root Cause: L2 Capacity Cliff

At N=8192 the three matrices (A, B, C) no longer fit in L2 cache:
- Combined footprint: `2 × 8192² × 2 bytes (FP16) + 8192² × 4 bytes (FP32)` ≈ **537 MB** — far beyond any GPU's L2.
- Result: all reads/writes go directly to DRAM → L1/TEX drops from ~90% to ~38%, GFLOPS halves, all kernels equalise.

---

## Key Takeaways

1. **No PTX variant beats `fp16_wmma` on performance.** The WMMA intrinsic path lets `nvcc` optimise scheduling and register allocation better than the hand-written PTX — especially at small, compute-bound sizes.
2. **`ptx_manual_pack` overhead is real but size-dependent.** Its +22% penalty at N=512 disappears at large sizes, suggesting the packing cost is not amortised at small tile counts.
3. **`ptx_fp16acc` occupancy advantage does not translate to GFLOPS.** Higher occupancy is necessary but not sufficient — the compute throughput % and GFLOPS are not higher than other PTX kernels.
4. **`ptx_k8` and `ptx_manual_pack` lead on Compute (SM) %.** Their instruction mix is better at keeping the SM busy, yet the wall-clock time is still equal or worse — indicating the bottleneck is memory bandwidth, not compute issue rate.
5. **Next investigation priorities:**
   - Verify `mma` tensor-core instructions are actually being issued (check `inst_executed_pipe_tensor` in NCU).
   - Profile with DRAM bandwidth metrics to confirm memory-bound saturation at large sizes.
   - Revisit shared-memory tiling/layout to improve L1/TEX beyond 57% in the compute-bound region.
   - Consider using `cp.async` + double-buffering (already in `ptx_3stage`) more aggressively to overlap memory latency.