# TensorCorePTX — PTX-first Tensor Core GEMM Exploration

This repository collects findings, experiments, and design notes for implementing high-performance PTX GEMM kernels using cp.async, ldmatrix, and mma.sync on modern NVIDIA architectures (Ada/L4/SM89). The focus is a clean PTX-first path: FP16 baseline, then expand per-precision (FP8, INT8, INT4).

## Table of Contents
- [Overview](#overview)
- [Data Movement](#data-movement)
- [Shared Memory Layout](#shared-memory-layout)
- [mma.sync Tile Shapes](#mmasync-tile-shapes)
- [Async Pipeline Stages](#async-pipeline-stages)
- [Per-Precision Investigation](#per-precision-investigation)
- [Advanced Topics](#advanced-topics)
- [Profiling Checkpoints](#profiling-checkpoints)
- [Natural Build Order](#natural-build-order)

## Overview

Goal: implement a production-grade GEMM entirely in PTX using `cp.async` → `ldmatrix` → `mma.sync` primitives, minimizing host-side transformations and avoiding legacy WMMA paths. Evaluate trade-offs across precisions and pipeline depths.

## Data Movement

- Global → SRAM
	- `cp.async` transaction sizes: 4B, 8B, 16B — trade instruction count vs conflict exposure.
	- Coalescing patterns: investigate cases where global layout forces sub-optimal packing.
	- Manual `ld.global.v4` + `st.shared` vs `cp.async`: compare latency and instruction count.

- SRAM → Registers
	- `ldmatrix.sync.aligned.m8n8.x1|x2|x4`: load 1, 2, or 4 matrix fragments per instruction.
	- `ldmatrix.sync.aligned.m8n8.x4.trans`: transposed load for B operand — removes explicit SRAM transpose.
	- Manual register packing vs `ldmatrix`: determine when manual packing is preferable.

## Shared Memory Layout

- Derive conflict-free layouts from the lane→bank mapping (build on SparseMoE analytical results).
- Chunk/row-size recommendations:
	- FP16: 16B chunks
	- FP8 / INT8: 16B chunks at 32-element rows
	- INT4: 32B rows
- Padding (row stride) vs swizzle: both are orthogonal; profile both solutions.

## mma.sync Tile Shapes

Available shapes (L4 / SM89) by precision:

| Precision | Typical mma.sync shapes |
|-----------|-------------------------|
| FP16      | m16n8k8, m16n8k16      |
| FP8 (e4m3, e5m2) | m16n8k32         |
| INT8      | m16n8k16, m16n8k32      |
| INT4      | m16n8k32, m16n8k64      |

Notes:
- Larger K reduces `mma.sync` call count but increases register pressure; find the crossover empirically.
- Accumulator type choices (f32 vs f16 for FP16) affect precision and register pressure.

## Async Pipeline Stages

- Compare 2-stage (double buffer) vs 3-stage (triple buffer) pipelines: does an extra stage hide latency or only increase register usage?
- `cp.async.commit_group` + `cp.async.wait_group N`: profile different `N` values to understand their effect.
- `bar.sync` vs `__syncthreads()`: measure PTX-level overhead differences.

## Per-Precision Investigation

### FP16
- Clean PTX GEMM pipeline: `cp.async` → `ldmatrix` → `mma.sync.m16n8k16` → epilogue (no WMMA).
- Consider `ldmatrix.trans` for B — compare to storing B transposed in SRAM.
- Epilogue: accumulate in F32 registers; pack stores with `st.global.v4`.

### FP8 (e4m3, e5m2)
- Native Ada support: evaluate conversion and packing sequences such as `cvt.rn.satfinite.e4m3x2.f32`.
- Example PTX opcode: `mma.sync.aligned.m16n8k32.row.col.f32.e4m3.e4m3.f32`.
- Trade-offs: `e4m3` vs `e5m2` (range vs precision). SparseMoE observed FP8 slower than FP16 due to conversion overhead — investigate whether end-to-end FP8 inputs avoid that penalty.

### INT8
- Compare `dp4a` (vadd4 family) vs `mma.sync` for INT8 workloads: `dp4a` is flexible; `mma.sync` offers higher Tensor Core throughput.
- Byte packing / unpacking: `prmt` instructions enable efficient 4×INT8 → INT32 packing.
- Watch for INT32 accumulator overflow for typical activation ranges using `mma.sync.m16n8k32`.

### INT4
- Nibble packing: two INT4 values per byte using `prmt` + shift/mask idioms.
- High-density arithmetic: `mma.sync.m16n8k64` performs 64 INT4 MACs per MMA instruction.
- Examine quantization error vs INT8; consider an accuracy appendix for findings.

## Advanced Topics

- Warp Specialization
	- Split warps into producer (runs `cp.async`, feeds SRAM) and consumer (runs `ldmatrix` + `mma.sync`).
	- Explore named-barrier (`bar.arrive` / `bar.wait`) synchronization vs `__syncthreads()`.
	- Determine whether warp specialization yields benefits on Ada or only at larger architectures.

- Instruction-Level Parallelism (ILP)
	- Issue multiple independent `mma.sync` operations before synchronization; analyze scoreboard stalls with NCU.
	- Evaluate register-file pressure: how many live fragments before occupancy drops?
	- Derive occupancy vs ILP tradeoffs per precision.

- Warp-Level Reductions (Epilogue)
	- Use `__shfl_xor_sync` for inter-thread reductions and compare to shared-memory reductions.

## Instruction Counts & Predication

- Predication: cost of `@p` guards on `mma.sync` for irregular tiles vs non-predicated paths.
- Loop unrolling: manual unroll vs `#pragma unroll N` — verify PTX output to confirm unrolling.

## Profiling Checkpoints

- Roofline: observe whether kernels move toward compute-bound as precision decreases.
- NCU counters: `sm__sass_thread_inst_executed_op_hmma_pred_on` for Tensor Core utilization.
- Memory: track L2 hit rate and DRAM traffic; quantization should reduce bandwidth and footprint.
- Occupancy: compare achieved vs theoretical — expect register pressure to be the limiter.

## Natural Build Order

1. FP16 PTX GEMM (clean baseline)
2. Tune async pipeline depth
3. Evaluate warp specialization
4. Add FP8 experiments
5. Add INT8 and INT4 experiments

Where practical, derive the shared-memory swizzle analytically per precision before profiling (lesson from SparseMoE).

---

If you want, I can also:
- add a short usage section with build/test commands,
- extract this into a formal project roadmap issue list,
- or run a quick formatting pass to wrap long lines at 80/100 columns.
