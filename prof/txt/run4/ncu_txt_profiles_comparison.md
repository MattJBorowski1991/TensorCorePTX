# NCU Profile Comparison - int4_ptx_mma_k64 Kernel Variants

**Source:** NCU profiling results from run4 directory  
**Kernels:** **x4_x2nontrans_ca (baseline)**, x1_x2nontrans_ca, x2_x2nontrans_ca, x4_x1nontrans_ca, x4_x2nontrans_cg, x4_x2trans_ca  
**Matrix Sizes:** 512, 1024, 2048, 4096, 8192  

---

## Matrix Size: 512x512x512

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.23 | 6.22 | 6.22 | 6.22 | 6.22 | 6.24 |
| SM Frequency | Mhz | 806.45 | 791.70 | 792.11 | 792.30 | 792.35 | 794.17 |
| Elapsed Cycles | cycle | 22247 | 21687 | 21700 | 22065 | 23308 | 73551 |
| Memory Throughput | % | 42.90 | 43.76 | 43.75 | 43.04 | 49.17 | 59.63 |
| DRAM Throughput | % | 5.63 | 5.68 | 5.69 | 5.53 | 5.44 | 1.67 |
| Duration | us | 27.46 | 27.39 | 27.39 | 27.84 | 29.41 | 92.61 |
| L1/TEX Cache Throughput | % | 56.71 | 57.50 | 57.06 | 57.35 | 31.27 | 79.92 |
| L2 Cache Throughput | % | 25.65 | 25.45 | 25.50 | 24.77 | 49.17 | 7.98 |
| SM Active Cycles | cycle | 16749.41 | 16502.86 | 16636.81 | 16554.98 | 18517.12 | 54871.86 |
| Compute (SM) Throughput | % | 26.15 | 30.61 | 27.99 | 28.81 | 24.85 | 14.02 |

**Notes:**
- **[OPT] (x1_x2nontrans_ca):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.
- **[OPT] (x2_x2nontrans_ca):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.
- **[OPT] (x4_x1nontrans_ca):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.
- **[OPT] (x4_x2nontrans_ca):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.
- **[OPT] (x4_x2nontrans_cg):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.
- **[OPT] (x4_x2trans_ca):** This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full waves across all SMs. Look at Launch Statistics for more details.

### Compute Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.32 | 1.33 | 1.33 | 1.35 | 1.20 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 1.00 | 1.01 | 1.02 | 1.01 | 0.95 | 0.47 |
| Issue Slots Busy | % | 25.24 | 25.47 | 25.76 | 25.49 | 23.98 | 11.78 |
| Issued Ipc Active | inst/cycle | 1.33 | 1.34 | 1.34 | 1.36 | 1.21 | 0.63 |
| SM Busy | % | 25.24 | 25.47 | 25.76 | 25.49 | 23.98 | 11.78 |

**Notes:**
- **[OPT] (x1_x2nontrans_ca):** Est. Local Speedup: 80.91%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **[OPT] (x2_x2nontrans_ca):** Est. Local Speedup: 80.92%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **[OPT] (x4_x1nontrans_ca):** Est. Local Speedup: 80.87%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **[OPT] (x4_x2nontrans_ca):** Est. Local Speedup: 80.94%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **[OPT] (x4_x2nontrans_cg):** Est. Local Speedup: 81.89%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **[OPT] (x4_x2trans_ca):** Est. Local Speedup: 88.37%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.

### Memory Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | - | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 16.84 | 16.96 | 16.99 | 16.51 | 16.26 | 5.01 |
| Mem Busy | % | 42.90 | 43.76 | 43.75 | 43.04 | 48.42 | 59.63 |
| Max Bandwidth | % | 26.15 | 30.61 | 27.99 | 28.81 | 49.17 | 14.02 |
| L1/TEX Hit Rate | % | 63.96 | 63.07 | 64.02 | 63.97 | 20.34 | 94.59 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | - | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 93.19 | 94.80 | 93.41 | 94.56 | 97.03 | 95.11 |
| Mem Pipes Busy | % | 26.15 | 30.61 | 27.99 | 28.81 | 24.85 | 14.02 |

### Scheduler Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 34.09 | 33.09 | 33.36 | 34.28 | 30.18 | 15.78 |
| Issued Warp Per Scheduler | - | 0.34 | 0.33 | 0.33 | 0.34 | 0.30 | 0.16 |
| No Eligible | % | 65.91 | 66.91 | 66.64 | 65.72 | 69.82 | 84.22 |
| Active Warps Per Scheduler | warp | 4.23 | 4.19 | 4.18 | 4.21 | 4.13 | 4.35 |
| Eligible Warps Per Scheduler | warp | 0.57 | 0.59 | 0.59 | 0.58 | 0.50 | 0.20 |

### Warp State Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 12.41 | 12.65 | 12.52 | 12.29 | 13.70 | 27.56 |
| Warp Cycles Per Executed Instruction | cycle | 12.52 | 12.77 | 12.63 | 12.40 | 13.82 | 27.73 |
| Avg. Active Threads Per Warp | - | 32 | 32 | 32 | 32 | 32 | 32 |
| Avg. Not Predicated Off Threads Per Warp | - | 29.68 | 29.65 | 29.68 | 29.69 | 29.68 | 31.15 |

### Instruction Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 5539.31 | 5473.10 | 5539.31 | 5574.62 | 5539.31 | 8611.31 |
| Executed Instructions | inst | 1285120 | 1269760 | 1285120 | 1293312 | 1285120 | 1997824 |
| Avg. Issued Instructions Per Scheduler | inst | 5587.88 | 5522.72 | 5588.93 | 5623.33 | 5587.56 | 8664.11 |
| Issued Instructions | inst | 1296388 | 1281270 | 1296632 | 1304612 | 1296314 | 2010073 |

### Launch Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Size | - | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | - | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | - | 128 | 128 | 128 | 128 | 128 | 128 |
| Registers Per Thread | register/thread | 54 | 55 | 55 | 54 | 54 | 64 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size | - | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 32768 | 32768 | 32768 | 32768 | 32768 | 32768 |
| # TPCs | - | 29 | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM | - | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 |

### Occupancy

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 4 | 4 | 4 | 4 | 4 | 4 |
| Block Limit Shared Mem | block | 5 | 5 | 5 | 5 | 5 | 5 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 32 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 |
| Achieved Occupancy | % | 34.97 | 35.57 | 34.93 | 34.53 | 34.91 | 36.33 |
| Achieved Active Warps Per SM | warp | 16.79 | 17.08 | 16.76 | 16.58 | 16.76 | 17.44 |

### Source Counters

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.08 | 0.08 | 0.08 | 0.08 | 0.08 | 0.06 |
| Branch Instructions | inst | 100352 | 100352 | 100352 | 100352 | 100352 | 121856 |
| Branch Efficiency | % | 100 | 100 | 100 | 100 | 100 | 100 |
| Avg. Divergent Branches | branches | 0 | 0 | 0 | 0 | 0 | 0 |

---

## Matrix Size: 1024x1024x1024

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.23 | 6.22 | 6.22 | 6.22 | 6.22 | 6.24 |
| SM Frequency | Mhz | 806.45 | 791.70 | 792.11 | 792.30 | 792.35 | 794.17 |
| Elapsed Cycles | cycle | 22247 | 21687 | 21700 | 22065 | 23308 | 73551 |
| Memory Throughput | % | 42.90 | 43.76 | 43.75 | 43.04 | 49.17 | 59.63 |
| DRAM Throughput | % | 5.63 | 5.68 | 5.69 | 5.53 | 5.44 | 1.67 |
| Duration | us | 27.46 | 27.39 | 27.39 | 27.84 | 29.41 | 92.61 |
| L1/TEX Cache Throughput | % | 56.71 | 57.50 | 57.06 | 57.35 | 31.27 | 79.92 |
| L2 Cache Throughput | % | 25.65 | 25.45 | 25.50 | 24.77 | 49.17 | 7.98 |
| SM Active Cycles | cycle | 16749.41 | 16502.86 | 16636.81 | 16554.98 | 18517.12 | 54871.86 |
| Compute (SM) Throughput | % | 26.15 | 30.61 | 27.99 | 28.81 | 24.85 | 14.02 |

### Compute Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.32 | 1.33 | 1.33 | 1.35 | 1.20 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 1.00 | 1.01 | 1.02 | 1.01 | 0.95 | 0.47 |
| Issue Slots Busy | % | 25.24 | 25.47 | 25.76 | 25.49 | 23.98 | 11.78 |
| Issued Ipc Active | inst/cycle | 1.33 | 1.34 | 1.34 | 1.36 | 1.21 | 0.63 |
| SM Busy | % | 25.24 | 25.47 | 25.76 | 25.49 | 23.98 | 11.78 |

### Memory Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | - | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 16.84 | 16.96 | 16.99 | 16.51 | 16.26 | 5.01 |
| Mem Busy | % | 42.90 | 43.76 | 43.75 | 43.04 | 48.42 | 59.63 |
| Max Bandwidth | % | 26.15 | 30.61 | 27.99 | 28.81 | 49.17 | 14.02 |
| L1/TEX Hit Rate | % | 63.96 | 63.07 | 64.02 | 63.97 | 20.34 | 94.59 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | - | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 93.19 | 94.80 | 93.41 | 94.56 | 97.03 | 95.11 |
| Mem Pipes Busy | % | 26.15 | 30.61 | 27.99 | 28.81 | 24.85 | 14.02 |

### Scheduler Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 34.09 | 33.09 | 33.36 | 34.28 | 30.18 | 15.78 |
| Issued Warp Per Scheduler | - | 0.34 | 0.33 | 0.33 | 0.34 | 0.30 | 0.16 |
| No Eligible | % | 65.91 | 66.91 | 66.64 | 65.72 | 69.82 | 84.22 |
| Active Warps Per Scheduler | warp | 4.23 | 4.19 | 4.18 | 4.21 | 4.13 | 4.35 |
| Eligible Warps Per Scheduler | warp | 0.57 | 0.59 | 0.59 | 0.58 | 0.50 | 0.20 |

### Warp State Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 12.41 | 12.65 | 12.52 | 12.29 | 13.70 | 27.56 |
| Warp Cycles Per Executed Instruction | cycle | 12.52 | 12.77 | 12.63 | 12.40 | 13.82 | 27.73 |
| Avg. Active Threads Per Warp | - | 32 | 32 | 32 | 32 | 32 | 32 |
| Avg. Not Predicated Off Threads Per Warp | - | 29.68 | 29.65 | 29.68 | 29.69 | 29.68 | 31.15 |

### Instruction Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 5539.31 | 5473.10 | 5539.31 | 5574.62 | 5539.31 | 8611.31 |
| Executed Instructions | inst | 1285120 | 1269760 | 1285120 | 1293312 | 1285120 | 1997824 |
| Avg. Issued Instructions Per Scheduler | inst | 5587.88 | 5522.72 | 5588.93 | 5623.33 | 5587.56 | 8664.11 |
| Issued Instructions | inst | 1296388 | 1281270 | 1296632 | 1304612 | 1296314 | 2010073 |

### Launch Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Size | - | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | - | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | - | 128 | 128 | 128 | 128 | 128 | 128 |
| Registers Per Thread | register/thread | 54 | 55 | 55 | 54 | 54 | 64 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size | - | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 32768 | 32768 | 32768 | 32768 | 32768 | 32768 |
| # TPCs | - | 29 | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM | - | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 |

### Occupancy

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 4 | 4 | 4 | 4 | 4 | 4 |
| Block Limit Shared Mem | block | 5 | 5 | 5 | 5 | 5 | 5 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 32 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 |
| Achieved Occupancy | % | 34.97 | 35.57 | 34.93 | 34.53 | 34.91 | 36.33 |
| Achieved Active Warps Per SM | warp | 16.79 | 17.08 | 16.76 | 16.58 | 16.76 | 17.44 |

### Source Counters

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.08 | 0.08 | 0.08 | 0.08 | 0.08 | 0.06 |
| Branch Instructions | inst | 100352 | 100352 | 100352 | 100352 | 100352 | 121856 |
| Branch Efficiency | % | 100 | 100 | 100 | 100 | 100 | 100 |
| Avg. Divergent Branches | branches | 0 | 0 | 0 | 0 | 0 | 0 |

---

## Matrix Size: 2048x2048x2048

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.22 | 6.22 | 6.22 | 6.23 | 6.22 | 6.24 |
| SM Frequency | Mhz | 805.38 | 791.81 | 791.26 | 792.82 | 792.74 | 794.18 |
| Elapsed Cycles | cycle | 21981 | 21742 | 21677 | 22404 | 23040 | 73321 |
| Memory Throughput | % | 43.41 | 43.67 | 43.82 | 42.37 | 50.58 | 59.81 |
| DRAM Throughput | % | 5.68 | 5.67 | 5.71 | 5.48 | 5.54 | 1.68 |
| Duration | us | 27.17 | 27.46 | 27.39 | 28.26 | 29.06 | 92.32 |
| L1/TEX Cache Throughput | % | 57.18 | 56.35 | 56.57 | 57.15 | 31.48 | 79.75 |
| L2 Cache Throughput | % | 25.84 | 24.98 | 25.70 | 24.41 | 50.58 | 8.05 |
| SM Active Cycles | cycle | 16613.48 | 16848.72 | 16789 | 16607.91 | 18396.71 | 54991.55 |
| Compute (SM) Throughput | % | 26.46 | 30.54 | 28.02 | 28.37 | 25.14 | 14.06 |

### Compute Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.33 | 1.30 | 1.32 | 1.34 | 1.20 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 1.01 | 1.01 | 1.02 | 1.00 | 0.96 | 0.47 |
| Issue Slots Busy | % | 25.54 | 25.40 | 25.79 | 25.10 | 24.26 | 11.82 |
| Issued Ipc Active | inst/cycle | 1.35 | 1.31 | 1.33 | 1.35 | 1.21 | 0.63 |
| SM Busy | % | 25.54 | 25.40 | 25.79 | 25.10 | 24.26 | 11.82 |

### Memory Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | - | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 16.96 | 16.92 | 17.07 | 16.39 | 16.55 | 5.02 |
| Mem Busy | % | 43.41 | 43.67 | 43.82 | 42.37 | 49.06 | 59.81 |
| Max Bandwidth | % | 26.46 | 30.54 | 28.02 | 28.37 | 50.58 | 14.06 |
| L1/TEX Hit Rate | % | 64.01 | 63.27 | 63.49 | 64.52 | 20.22 | 94.53 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | - | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 93.95 | 95.44 | 93.75 | 91.83 | 96.85 | 95.22 |
| Mem Pipes Busy | % | 26.46 | 30.54 | 28.02 | 28.37 | 25.14 | 14.06 |

### Scheduler Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 33.20 | 33.07 | 33.49 | 34.47 | 30.17 | 15.79 |
| Issued Warp Per Scheduler | - | 0.33 | 0.33 | 0.33 | 0.34 | 0.30 | 0.16 |
| No Eligible | % | 66.80 | 66.93 | 66.51 | 65.53 | 69.83 | 84.21 |
| Active Warps Per Scheduler | warp | 4.12 | 4.20 | 4.18 | 4.17 | 4.13 | 4.37 |
| Eligible Warps Per Scheduler | warp | 0.56 | 0.59 | 0.59 | 0.60 | 0.49 | 0.20 |

### Warp State Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 12.42 | 12.69 | 12.49 | 12.10 | 13.68 | 27.70 |
| Warp Cycles Per Executed Instruction | cycle | 12.53 | 12.80 | 12.60 | 12.21 | 13.80 | 27.87 |
| Avg. Active Threads Per Warp | - | 32 | 32 | 32 | 32 | 32 | 32 |
| Avg. Not Predicated Off Threads Per Warp | - | 29.68 | 29.65 | 29.68 | 29.69 | 29.68 | 31.15 |

### Instruction Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 5539.31 | 5473.10 | 5539.31 | 5574.62 | 5539.31 | 8611.31 |
| Executed Instructions | inst | 1285120 | 1269760 | 1285120 | 1293312 | 1285120 | 1997824 |
| Avg. Issued Instructions Per Scheduler | inst | 5587.88 | 5522.69 | 5588.86 | 5623.08 | 5587.77 | 8664.24 |
| Issued Instructions | inst | 1296387 | 1281263 | 1296615 | 1304555 | 1296362 | 2010103 |

### Launch Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Size | - | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | - | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | - | 128 | 128 | 128 | 128 | 128 | 128 |
| Registers Per Thread | register/thread | 54 | 55 | 55 | 54 | 54 | 64 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size | - | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 32768 | 32768 | 32768 | 32768 | 32768 | 32768 |
| # TPCs | - | 29 | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM | - | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 |

### Occupancy

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 4 | 4 | 4 | 4 | 4 | 4 |
| Block Limit Shared Mem | block | 5 | 5 | 5 | 5 | 5 | 5 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 32 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 |
| Achieved Occupancy | % | 35.06 | 34.42 | 34.64 | 34.20 | 34.61 | 36.31 |
| Achieved Active Warps Per SM | warp | 16.83 | 16.52 | 16.63 | 16.42 | 16.61 | 17.43 |

### Source Counters

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.08 | 0.08 | 0.08 | 0.08 | 0.08 | 0.06 |
| Branch Instructions | inst | 100352 | 100352 | 100352 | 100352 | 100352 | 121856 |
| Branch Efficiency | % | 100 | 100 | 100 | 100 | 100 | 100 |
| Avg. Divergent Branches | branches | 0 | 0 | 0 | 0 | 0 | 0 |

---

## Matrix Size: 4096x4096x4096

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.22 | 6.22 | 6.22 | 6.22 | 6.22 | 6.24 |
| SM Frequency | Mhz | 828.34 | 791.95 | 791.41 | 792.14 | 793.10 | 794.18 |
| Elapsed Cycles | cycle | 22385 | 22050 | 21781 | 22160 | 23358 | 73244 |
| Memory Throughput | % | 42.71 | 43.04 | 43.60 | 42.86 | 49.96 | 59.88 |
| DRAM Throughput | % | 5.72 | 5.59 | 5.65 | 5.53 | 5.48 | 1.68 |
| Duration | us | 26.85 | 27.84 | 27.52 | 27.97 | 29.44 | 92.22 |
| L1/TEX Cache Throughput | % | 56.01 | 56.45 | 57.01 | 57.68 | 31.56 | 80.10 |
| L2 Cache Throughput | % | 25.93 | 24.92 | 25.61 | 24.22 | 49.96 | 8.03 |
| SM Active Cycles | cycle | 16958.84 | 16811.24 | 16655.55 | 16461.67 | 18349.50 | 54754.67 |
| Compute (SM) Throughput | % | 26.04 | 30.11 | 27.89 | 28.69 | 24.80 | 14.08 |

### Compute Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.31 | 1.30 | 1.33 | 1.35 | 1.21 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 1.00 | 0.99 | 1.02 | 1.01 | 0.95 | 0.47 |
| Issue Slots Busy | % | 25.13 | 25.05 | 25.66 | 25.38 | 23.93 | 11.83 |
| Issued Ipc Active | inst/cycle | 1.32 | 1.31 | 1.34 | 1.37 | 1.22 | 0.63 |
| SM Busy | % | 25.13 | 25.05 | 25.66 | 25.38 | 23.93 | 11.83 |

### Memory Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | - | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 17.08 | 16.67 | 16.87 | 16.52 | 16.36 | 5.03 |
| Mem Busy | % | 42.71 | 43.04 | 43.60 | 42.86 | 48.45 | 59.88 |
| Max Bandwidth | % | 26.04 | 30.11 | 27.89 | 28.69 | 49.96 | 14.08 |
| L1/TEX Hit Rate | % | 63.75 | 63.81 | 64.60 | 64.15 | 20.23 | 94.57 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | - | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 95.26 | 93.48 | 93.58 | 94.00 | 96.97 | 94.98 |
| Mem Pipes Busy | % | 26.04 | 30.11 | 27.89 | 28.69 | 24.80 | 14.08 |

### Scheduler Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 33.52 | 33.03 | 33.08 | 34.67 | 30.46 | 15.81 |
| Issued Warp Per Scheduler | - | 0.34 | 0.33 | 0.33 | 0.35 | 0.30 | 0.16 |
| No Eligible | % | 66.48 | 66.97 | 66.92 | 65.33 | 69.54 | 84.19 |
| Active Warps Per Scheduler | warp | 4.18 | 4.19 | 4.14 | 4.20 | 4.15 | 4.37 |
| Eligible Warps Per Scheduler | warp | 0.57 | 0.58 | 0.59 | 0.60 | 0.51 | 0.20 |

### Warp State Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 12.47 | 12.69 | 12.53 | 12.12 | 13.61 | 27.64 |
| Warp Cycles Per Executed Instruction | cycle | 12.58 | 12.81 | 12.64 | 12.22 | 13.73 | 27.81 |
| Avg. Active Threads Per Warp | - | 32 | 32 | 32 | 32 | 32 | 32 |
| Avg. Not Predicated Off Threads Per Warp | - | 29.68 | 29.65 | 29.68 | 29.69 | 29.68 | 31.15 |

### Instruction Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 5539.31 | 5473.10 | 5539.31 | 5574.62 | 5539.31 | 8611.31 |
| Executed Instructions | inst | 1285120 | 1269760 | 1285120 | 1293312 | 1285120 | 1997824 |
| Avg. Issued Instructions Per Scheduler | inst | 5588.06 | 5522.75 | 5588.90 | 5623.24 | 5587.62 | 8664.22 |
| Issued Instructions | inst | 1296430 | 1281279 | 1296625 | 1304591 | 1296329 | 2010100 |

### Launch Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Size | - | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | - | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | - | 128 | 128 | 128 | 128 | 128 | 128 |
| Registers Per Thread | register/thread | 54 | 55 | 55 | 54 | 54 | 64 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size | - | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 32768 | 32768 | 32768 | 32768 | 32768 | 32768 |
| # TPCs | - | 29 | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM | - | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 |

### Occupancy

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 4 | 4 | 4 | 4 | 4 | 4 |
| Block Limit Shared Mem | block | 5 | 5 | 5 | 5 | 5 | 5 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 32 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 |
| Achieved Occupancy | % | 34.16 | 34.57 | 34.95 | 34.31 | 34.77 | 36.41 |
| Achieved Active Warps Per SM | warp | 16.40 | 16.60 | 16.78 | 16.47 | 16.69 | 17.48 |

### Source Counters

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.08 | 0.08 | 0.08 | 0.08 | 0.08 | 0.06 |
| Branch Instructions | inst | 100352 | 100352 | 100352 | 100352 | 100352 | 121856 |
| Branch Efficiency | % | 100 | 100 | 100 | 100 | 100 | 100 |
| Avg. Divergent Branches | branches | 0 | 0 | 0 | 0 | 0 | 0 |

---

## Matrix Size: 8192x8192x8192

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.22 | 6.22 | 6.22 | 6.22 | 6.22 | 6.24 |
| SM Frequency | Mhz | 814.12 | 793.63 | 792.01 | 792.06 | 792.55 | 794.34 |
| Elapsed Cycles | cycle | 22171 | 22365 | 21900 | 22080 | 22703 | 73540 |
| Memory Throughput | % | 43.14 | 42.55 | 43.38 | 43.00 | 49.82 | 59.65 |
| DRAM Throughput | % | 5.69 | 5.58 | 5.59 | 5.57 | 5.60 | 1.67 |
| Duration | us | 27.04 | 28.10 | 27.65 | 27.87 | 28.64 | 92.54 |
| L1/TEX Cache Throughput | % | 56.85 | 55.97 | 56.12 | 57.48 | 31.77 | 80.01 |
| L2 Cache Throughput | % | 26.17 | 24.86 | 25.79 | 24.60 | 49.82 | 8.05 |
| SM Active Cycles | cycle | 16707.86 | 16953.72 | 16929.34 | 16516.53 | 18526.84 | 54807.14 |
| Compute (SM) Throughput | % | 26.30 | 29.77 | 27.74 | 28.79 | 25.51 | 14.03 |

### Compute Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.33 | 1.29 | 1.31 | 1.35 | 1.20 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 1.01 | 0.98 | 1.01 | 1.01 | 0.98 | 0.47 |
| Issue Slots Busy | % | 25.38 | 24.77 | 25.52 | 25.47 | 24.62 | 11.79 |
| Issued Ipc Active | inst/cycle | 1.34 | 1.30 | 1.32 | 1.36 | 1.21 | 0.63 |
| SM Busy | % | 25.38 | 24.77 | 25.52 | 25.47 | 24.62 | 11.79 |

### Memory Workload Analysis

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | - | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 17.01 | 16.66 | 16.68 | 16.63 | 16.72 | 5.00 |
| Mem Busy | % | 43.14 | 42.55 | 43.38 | 43.00 | 49.82 | 59.65 |
| Max Bandwidth | % | 26.30 | 29.77 | 27.74 | 28.79 | 49.60 | 14.03 |
| L1/TEX Hit Rate | % | 64.08 | 63.37 | 63.55 | 63.98 | 20.23 | 94.58 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | - | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 93.28 | 94.18 | 92.23 | 94.73 | 96.79 | 94.62 |
| Mem Pipes Busy | % | 26.30 | 29.77 | 27.74 | 28.79 | 25.51 | 14.03 |

### Scheduler Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 33.64 | 33.17 | 33.07 | 34.38 | 30.53 | 15.80 |
| Issued Warp Per Scheduler | - | 0.34 | 0.33 | 0.33 | 0.34 | 0.31 | 0.16 |
| No Eligible | % | 66.36 | 66.83 | 66.93 | 65.62 | 69.47 | 84.20 |
| Active Warps Per Scheduler | warp | 4.18 | 4.19 | 4.14 | 4.23 | 4.19 | 4.36 |
| Eligible Warps Per Scheduler | warp | 0.57 | 0.58 | 0.58 | 0.59 | 0.51 | 0.20 |

### Warp State Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 12.44 | 12.62 | 12.51 | 12.29 | 13.74 | 27.62 |
| Warp Cycles Per Executed Instruction | cycle | 12.55 | 12.73 | 12.62 | 12.40 | 13.86 | 27.79 |
| Avg. Active Threads Per Warp | - | 32 | 32 | 32 | 32 | 32 | 32 |
| Avg. Not Predicated Off Threads Per Warp | - | 29.68 | 29.65 | 29.68 | 29.69 | 29.68 | 31.15 |

### Instruction Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 5539.31 | 5473.10 | 5539.31 | 5574.62 | 5539.31 | 8611.31 |
| Executed Instructions | inst | 1285120 | 1269760 | 1285120 | 1293312 | 1285120 | 1997824 |
| Avg. Issued Instructions Per Scheduler | inst | 5587.96 | 5522.68 | 5588.95 | 5623.12 | 5587.49 | 8664.16 |
| Issued Instructions | inst | 1296407 | 1281262 | 1296637 | 1304563 | 1296297 | 2010084 |

### Launch Statistics

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Size | - | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | - | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | - | 128 | 128 | 128 | 128 | 128 | 128 |
| Registers Per Thread | register/thread | 54 | 55 | 55 | 54 | 54 | 64 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size | - | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 32768 | 32768 | 32768 | 32768 | 32768 | 32768 |
| # TPCs | - | 29 | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM | - | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 | 0.55 |

### Occupancy

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 4 | 4 | 4 | 4 | 4 | 4 |
| Block Limit Shared Mem | block | 5 | 5 | 5 | 5 | 5 | 5 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 32 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 | 66.67 |
| Achieved Occupancy | % | 34.63 | 34.07 | 34.21 | 34.62 | 34.34 | 36.45 |
| Achieved Active Warps Per SM | warp | 16.62 | 16.36 | 16.42 | 16.62 | 16.49 | 17.50 |

### Source Counters

| Metric Name | Metric Unit | **x4_x2nontrans_ca (baseline)** | x1_x2nontrans_ca | x2_x2nontrans_ca | x4_x1nontrans_ca | x4_x2nontrans_cg | x4_x2trans_ca |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.08 | 0.08 | 0.08 | 0.08 | 0.08 | 0.06 |
| Branch Instructions | inst | 100352 | 100352 | 100352 | 100352 | 100352 | 121856 |
| Branch Efficiency | % | 100 | 100 | 100 | 100 | 100 | 100 |
| Avg. Divergent Branches | branches | 0 | 0 | 0 | 0 | 0 | 0 |

---
