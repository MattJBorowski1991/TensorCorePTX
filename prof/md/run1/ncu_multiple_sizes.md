# Nsight Compute — Multiple Sizes Summary

This file aggregates the requested metrics from the `prof/txt/multiple_sizes/` NCU outputs into one large table. Kernels are columns; rows are grouped by matrix size and metric.

Kernels (columns): `fp16_wmma`, `fp16_ptx_mma`, `fp16_ptx_k8`, `fp16_ptx_fp16acc`, `fp16_ptx_3stage`, `fp16_ptx_manual_pack`

Metrics collected (per-size): Duration (s), Compute (SM) Throughput (%), Achieved Occupancy (%), L1/TEX Cache Throughput (%).

Kernels profiled for matrix sizes: 512, 1024, 2048, 4096, 8192, 16384.

---

## Aggregated table (single table)

| Matrix Size | Metric | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---:|---|---:|---:|---:|---:|---:|---:|
| 512  | Duration (s) | 0.000185 | 0.000188 | 0.000193 | 0.000188 | 0.000185 | 0.000226 |
| 1024 | Duration (s) | 0.001430 | 0.001450 | 0.001470 | 0.001440 | 0.001430 | 0.001720 |
| 2048 | Duration (s) | 0.011850 | 0.012210 | 0.012000 | 0.011930 | 0.012190 | 0.013470 |
| 4096 | Duration (s) | 0.102350 | 0.104300 | 0.103170 | 0.103410 | 0.106630 | 0.107560 |
| 8192 | Duration (s) | 1.650000 | 1.660000 | 1.660000 | 1.710000 | 1.740000 | 1.680000 |
| 16384 | Duration (s) | 13.640000 | 13.670000 | 13.660000 | 13.940000 | 14.170000 | 13.810000 |
| 512  | Compute (SM) Throughput (%) | 37.13 | 39.87 | 47.49 | 39.78 | 37.86 | 56.07 |
| 1024 | Compute (SM) Throughput (%) | 36.69 | 39.43 | 48.30 | 39.62 | 38.67 | 57.04 |
| 2048 | Compute (SM) Throughput (%) | 34.48 | 36.61 | 46.53 | 37.36 | 35.54 | 57.50 |
| 4096 | Compute (SM) Throughput (%) | 31.65 | 33.89 | 42.78 | 34.16 | 32.86 | 57.18 |
| 8192 | Compute (SM) Throughput (%) | 15.59 | 16.94 | 21.17 | 16.45 | 16.06 | 29.20 |
| 16384 | Compute (SM) Throughput (%) | 15.07 | 16.41 | 20.50 | 16.09 | 15.79 | 28.37 |
| 512  | Achieved Occupancy (%) | 59.45 | 58.85 | 58.06 | 70.60 | 56.60 | 57.58 |
| 1024 | Achieved Occupancy (%) | 63.81 | 63.47 | 63.61 | 79.05 | 63.18 | 63.39 |
| 2048 | Achieved Occupancy (%) | 64.72 | 65.02 | 64.73 | 82.34 | 64.27 | 64.83 |
| 4096 | Achieved Occupancy (%) | 65.59 | 65.59 | 65.38 | 82.09 | 64.29 | 65.19 |
| 8192 | Achieved Occupancy (%) | 66.19 | 66.20 | 66.18 | 82.48 | 64.40 | 66.14 |
| 16384 | Achieved Occupancy (%) | 66.33 | 66.33 | 66.31 | 82.72 | 64.40 | 66.29 |
| 512  | L1/TEX Cache Throughput (%) | 92.74 | 93.07 | 90.02 | 93.03 | 94.50 | 87.82 |
| 1024 | L1/TEX Cache Throughput (%) | 94.26 | 93.16 | 92.96 | 94.22 | 94.44 | 89.90 |
| 2048 | L1/TEX Cache Throughput (%) | 88.02 | 85.93 | 87.67 | 88.40 | 84.73 | 89.57 |
| 4096 | L1/TEX Cache Throughput (%) | 81.26 | 80.70 | 80.78 | 80.93 | 81.53 | 88.67 |
| 8192 | L1/TEX Cache Throughput (%) | 39.28 | 39.20 | 39.22 | 38.08 | 38.04 | 44.23 |
| 16384 | L1/TEX Cache Throughput (%) | 38.08 | 38.02 | 38.03 | 37.30 | 38.69 | 43.02 |

---

## Notes
- Values will be populated from the TXT reports in `prof/txt/multiple_sizes/`. I can now parse those files and fill the table and produce a CSV if you want.

