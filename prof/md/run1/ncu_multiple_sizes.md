# Nsight Compute — Multiple Sizes Summary

This file aggregates the requested metrics from the `prof/txt/multiple_sizes/` NCU outputs into one large table. Kernels are columns; rows are grouped by matrix size and metric.

Kernels (columns): `fp16_wmma`, `fp16_ptx_mma`, `fp16_ptx_k8`, `fp16_ptx_fp16acc`, `fp16_ptx_3stage`, `fp16_ptx_manual_pack`

Metrics collected (per-size): Duration (s), Compute (SM) Throughput (%), Achieved Occupancy (%), L1/TEX Cache Throughput (%).

Kernels profiled for matrix sizes: 512, 1024, 2048, 4096, 8192, 16384.

---

## Aggregated table (single table)

| Metric | Matrix Size | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Duration (s) | 512  | 0.000185 | 0.000188 | 0.000193 | 0.000188 | 0.000185 | 0.000226 |
| Duration (s) | 1024 | 0.001430 | 0.001450 | 0.001470 | 0.001440 | 0.001430 | 0.001720 |
| Duration (s) | 2048 | 0.011850 | 0.012210 | 0.012000 | 0.011930 | 0.012190 | 0.013470 |
| Duration (s) | 4096 | 0.102350 | 0.104300 | 0.103170 | 0.103410 | 0.106630 | 0.107560 |
| Duration (s) | 8192 | 1.650000 | 1.660000 | 1.660000 | 1.710000 | 1.740000 | 1.680000 |
| Duration (s) | 16384 | 13.640000 | 13.670000 | 13.660000 | 13.940000 | 14.170000 | 13.810000 |
| GFLOPS | 512  | 1451.00 | 1428.28 | 1391.03 | 1428.28 | 1451.00 | 1188.59 |
| GFLOPS | 1024 | 1501.06 | 1480.34 | 1460.20 | 1491.77 | 1501.06 | 1248.54 |
| GFLOPS | 2048 | 1450.64 | 1407.53 | 1431.66 | 1440.15 | 1409.43 | 1275.13 |
| GFLOPS | 4096 | 1342.53 | 1317.88 | 1332.59 | 1329.40 | 1288.98 | 1277.41 |
| GFLOPS | 8192 | 666.37 | 662.37 | 662.37 | 642.66 | 631.71 | 654.10 |
| GFLOPS | 16384 | 644.72 | 643.53 | 643.93 | 631.05 | 620.58 | 636.65 |
| Compute (SM) Throughput (%) | 512  | 37.13 | 39.87 | 47.49 | 39.78 | 37.86 | 56.07 |
| Compute (SM) Throughput (%) | 1024 | 36.69 | 39.43 | 48.30 | 39.62 | 38.67 | 57.04 |
| Compute (SM) Throughput (%) | 2048 | 34.48 | 36.61 | 46.53 | 37.36 | 35.54 | 57.50 |
| Compute (SM) Throughput (%) | 4096 | 31.65 | 33.89 | 42.78 | 34.16 | 32.86 | 57.18 |
| Compute (SM) Throughput (%) | 8192 | 15.59 | 16.94 | 21.17 | 16.45 | 16.06 | 29.20 |
| Compute (SM) Throughput (%) | 16384 | 15.07 | 16.41 | 20.50 | 16.09 | 15.79 | 28.37 |
| Achieved Occupancy (%) | 512  | 59.45 | 58.85 | 58.06 | 70.60 | 56.60 | 57.58 |
| Achieved Occupancy (%) | 1024 | 63.81 | 63.47 | 63.61 | 79.05 | 63.18 | 63.39 |
| Achieved Occupancy (%) | 2048 | 64.72 | 65.02 | 64.73 | 82.34 | 64.27 | 64.83 |
| Achieved Occupancy (%) | 4096 | 65.59 | 65.59 | 65.38 | 82.09 | 64.29 | 65.19 |
| Achieved Occupancy (%) | 8192 | 66.19 | 66.20 | 66.18 | 82.48 | 64.40 | 66.14 |
| Achieved Occupancy (%) | 16384 | 66.33 | 66.33 | 66.31 | 82.72 | 64.40 | 66.29 |
| L1/TEX Cache Throughput (%) | 512  | 92.74 | 93.07 | 90.02 | 93.03 | 94.50 | 87.82 |
| L1/TEX Cache Throughput (%) | 1024 | 94.26 | 93.16 | 92.96 | 94.22 | 94.44 | 89.90 |
| L1/TEX Cache Throughput (%) | 2048 | 88.02 | 85.93 | 87.67 | 88.40 | 84.73 | 89.57 |
| L1/TEX Cache Throughput (%) | 4096 | 81.26 | 80.70 | 80.78 | 80.93 | 81.53 | 88.67 |
| L1/TEX Cache Throughput (%) | 8192 | 39.28 | 39.20 | 39.22 | 38.08 | 38.04 | 44.23 |
| L1/TEX Cache Throughput (%) | 16384 | 38.08 | 38.02 | 38.03 | 37.30 | 38.69 | 43.02 |

---

## Notes
- Values will be populated from the TXT reports in `prof/txt/multiple_sizes/`. I can now parse those files and fill the table and produce a CSV if you want.

