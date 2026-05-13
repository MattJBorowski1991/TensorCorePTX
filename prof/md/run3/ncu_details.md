# Run3 NCU Analysis Outline

## Part 1: Base INT4 Kernel Comparison

### Profiled Kernels

- [int4_wmma](../../../kernels/int4_wmma.cu)
- [int4_ptx_mma_k32](../../../kernels/int4_ptx_mma_k32.cu)
- [int4_ptx_mma_k64](../../../kernels/int4_ptx_mma_k64_x4_x2nontrans_ca.cu)
- [int4_ptx_manual_pack](../../../kernels/int4_ptx_manual_pack.cu)
- [int4_ptx_3stage](../../../kernels/int4_ptx_3stage.cu)

### Kernel Duration Summary (ms)

[int4_wmma](../../../kernels/int4_wmma.cu) is the baseline for the comparison below.

| Kernel | 512 | 1024 | 2048 | 4096 | 8192 |
|--------|-----|------|------|------|------|
| int4_wmma | 0.1954 | 1.4500 | 11.40 | 90.11 | 712.96 |
| int4_ptx_manual_pack | 0.0878 (+123%) | 0.6110 (+137%) | 4.61 (+147%) | 35.55 (+154%) | 277.13 (+157%) |
| int4_ptx_mma_k32 | 0.0870 (+125%) | 0.5794 (+150%) | 4.32 (+164%) | 33.99 (+165%) | 269.35 (+165%) |
| int4_ptx_3stage | **0.0562** (+248%) | **0.3816** (+280%) | 2.91 (+292%) | 24.26 (+271%) | 197.63 (+261%) |
| int4_ptx_mma_k64 | 0.0682 (+187%) | 0.3947 (+267%) | **2.81 (+306%)** | **21.52 (+319%)** | **167.10 (+327%)** |

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

