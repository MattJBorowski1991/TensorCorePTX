# Run3 NCU Analysis Outline

## Part 1: Base INT4 Kernel Comparison

### Goal

Identify the best core kernel family before any micro-tuning.

### Kernels to Compare

- int4_wmma
- int4_ptx_mma_k32
- int4_ptx_mma_k64
- int4_ptx_manual_pack
- int4_ptx_3stage

### Metrics to Report

- End-to-end runtime (ms)
- Throughput (TOPS)
- Key NCU signals (pick 2 to 4 and keep consistent):
	- Compute throughput percent
	- Memory throughput percent
	- Eligible warps per scheduler
	- Top warp stall reason
	- Shared/global access efficiency


## Part 2: Deep Dive on Best Kernel (k64)

### Goal

Tune only the winning kernel variant family and quantify relative deltas.

### Factor Space

- A loader (xi): x4, x2, x1
- B loader (xj): x2, x1
- B layout mode: nontrans, trans
- cp.async policy: ca, cg

### Baseline for Deltas

- Baseline variant: int4_ptx_mma_k64_x4_x2nontrans_ca
- All results in this section should be reported as delta versus baseline.

### NCU Deep-Dive Fields per Variant

- Compute throughput percent
- Memory throughput percent
- Eligible warps per scheduler
- Top 1 to 2 warp stall reasons
- Shared load/store efficiency and bank conflict indicators

