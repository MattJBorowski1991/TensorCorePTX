# NCU TXT Profiles Comparison (run3)

Combined Nsight Compute high-level sections for five int4 kernels and five matrix sizes.
Metric names, metric units, metric values, and comments are copied from the source txt reports.

## Matrix Size 512x512x512

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.23 | 6.24 | 6.23 |
| SM Frequency | Mhz | 833.30 | 842.67 | 820.36 | 794.21 | 793.62 |
| Elapsed Cycles | cycle | 163863 | 73770 | 56292 | 69766 | 44572 |
| Memory Throughput | % | 73.67 | 74.64 | 69.23 | 78.06 | 83.18 |
| DRAM Throughput | % | 3.18 | 7.04 | 8.99 | 6.95 | 10.85 |
| Duration | us | 195.42 | 87.01 | 68.19 | 87.84 | 56.16 |
| L1/TEX Cache Throughput | % | 76.37 | 79.57 | 74.30 | 82.65 | 90.06 |
| L2 Cache Throughput | % | 19.45 | 30.27 | 39.10 | 29.24 | 56.03 |
| SM Active Cycles | cycle | 157103.16 | 68785.57 | 52123.71 | 65891.95 | 41165 |
| Compute (SM) Throughput | % | 66.26 | 43.92 | 41.41 | 49.40 | 33.27 |

Comments:
- **int4_wmma** [INF]: Compute and Memory are well-balanced: To reduce runtime, both computation and memory traffic must be reduced. Check both the Compute Workload Analysis and Memory Workload Analysis sections.
- **int4_ptx_mma_k32** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.
- **int4_ptx_mma_k64** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.
- **int4_ptx_manual_pack** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.
- **int4_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k64** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.

### PM Sampling

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 16.25 | 16.25 | 8.19 | 16.25 | 8.19 |
| Maximum Sampling Interval | us | 1 | 1 | 1 | 1 | 1 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 2.19 | 1.49 | 1.70 | 1.52 | 1.34 |
| Executed Ipc Elapsed | inst/cycle | 2.11 | 1.40 | 1.58 | 1.44 | 1.23 |
| Issue Slots Busy | % | 52.94 | 35.11 | 39.75 | 36.04 | 31.05 |
| Issued Ipc Active | inst/cycle | 2.19 | 1.50 | 1.71 | 1.53 | 1.34 |
| SM Busy | % | 52.94 | 35.11 | 39.75 | 36.04 | 31.05 |

Comments:
- **int4_wmma** [INF]: ALU is the highest-utilized pipeline (35.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_mma_k32** [INF]: ALU is the highest-utilized pipeline (22.2%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_mma_k64** [INF]: ALU is the highest-utilized pipeline (30.2%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (22.3%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_3stage** [OPT]: Est. Local Speedup: 85.18%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 9.53 | 21.06 | 26.88 | 20.82 | 32.42 |
| Mem Busy | % | 73.67 | 74.64 | 69.23 | 78.06 | 83.18 |
| Max Bandwidth | % | 66.26 | 43.92 | 41.41 | 49.40 | 44.85 |
| L1/TEX Hit Rate | % | 82.78 | 81.06 | 65.68 | 81.55 | 58.07 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 96.97 | 93.36 | 94.42 | 92.24 | 95.13 |
| Mem Pipes Busy | % | 66.26 | 43.92 | 41.41 | 49.40 | 33.27 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 36.84%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 37.32%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 37.32%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 34.62%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 37.24%. The memory access pattern for shared loads might not be optimal and causes on average a 5.3 - way bank conflict. This results in 263457 bank conflicts, which represent 50.12% of the overall 525645 wavefronts for shared loads.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 39.03%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 39.03%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 41.59%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 45.95%. The memory access pattern for shared loads might not be optimal and causes on average a 5.4 - way bank conflict. This results in 273306 bank conflicts, which represent 51.02% of the overall 535706 wavefronts for shared loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| One or More Eligible | % | 54.89 | 37.58 | 42.96 | 38.49 | 33.94 |
| Issued Warp Per Scheduler |  | 0.55 | 0.38 | 0.43 | 0.38 | 0.34 |
| No Eligible | % | 45.11 | 62.42 | 57.04 | 61.51 | 66.06 |
| Active Warps Per Scheduler | warp | 11.28 | 8.40 | 6.83 | 8.24 | 6.75 |
| Eligible Warps Per Scheduler | warp | 1.93 | 0.98 | 1.07 | 1.11 | 0.88 |

### Warp State Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 20.55 | 22.34 | 15.90 | 21.41 | 19.89 |
| Warp Cycles Per Executed Instruction | cycle | 20.58 | 22.44 | 15.96 | 21.51 | 20.02 |
| Avg. Active Threads Per Warp |  | 20.09 | 25.06 | 32 | 24.89 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 18.28 | 22.80 | 29.68 | 22.58 | 29.25 |

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 26.33%. On average, each warp of this workload spends 6.9 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 33.6% of the total average of 20.5 cycles between issuing two instructions.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 12.63%. Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. This workload achieves an average of 25.1 threads being active per cycle.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 30.77%. On average, each warp of this workload spends 5.0 cycles being stalled waiting for a scoreboard dependency on a L1TEX operation. This stall type represents about 31.7% of the total average of 15.9 cycles between issuing two instructions.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 21.94%. On average, each warp of this workload spends 8.6 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 40.3% of the total average of 21.4 cycles between issuing two instructions.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 16.82%. On average, each warp of this workload spends 11.0 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 55.2% of the total average of 19.9 cycles between issuing two instructions.

### Instruction Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 86086.62 | 25635.31 | 22157.24 | 25035.03 | 13753.38 |
| Executed Instructions | inst | 19972096 | 5947392 | 5140480 | 5808128 | 3190784 |
| Avg. Issued Instructions Per Scheduler | inst | 86209.50 | 25745.62 | 22239.49 | 25145.47 | 13837.19 |
| Issued Instructions | inst | 20000603 | 5972984 | 5159562 | 5833750 | 3210227 |

### Launch Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 2048 | 512 | 512 | 512 | 512 |
| Registers Per Thread | register/thread | 40 | 48 | 54 | 48 | 54 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 65.54 | 102.40 | 65.54 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 4.10 | 8.19 | 16.38 | 8.19 | 24.58 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 524288 | 131072 | 131072 | 131072 | 131072 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM |  | 5.89 | 1.77 | 2.21 | 1.77 | 2.21 |

Comments:
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 50%. A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 33.33%. A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. This kernel launch results in 2 full waves and a partial wave of 48 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 33.3% of the total runtime of this kernel.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 50%. A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 33.33%. A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. This kernel launch results in 2 full waves and a partial wave of 48 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 33.3% of the total runtime of this kernel.

### Occupancy

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 4 | 5 | 4 |
| Block Limit Shared Mem | block | 12 | 7 | 5 | 7 | 4 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 32 | 40 | 32 |
| Theoretical Occupancy | % | 100 | 83.33 | 66.67 | 83.33 | 66.67 |
| Achieved Occupancy | % | 93.95 | 69.85 | 56.73 | 68.01 | 55.62 |
| Achieved Active Warps Per SM | warp | 45.09 | 33.53 | 27.23 | 32.65 | 26.70 |

Comments:
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 16.18%. The difference between calculated theoretical (83.3%) and measured achieved occupancy (69.8%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 30.77%. The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 18.38%. The difference between calculated theoretical (83.3%) and measured achieved occupancy (68.0%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 16.57%. The difference between calculated theoretical (66.7%) and measured achieved occupancy (55.6%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 16.82%. The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers, and the required amount of shared memory.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 38797.33 | 38178.67 | 38189.33 | 38101.33 | 37933.33 |
| Total DRAM Elapsed Cycles | cycle | 7317504 | 3255296 | 2549760 | 3287040 | 2098176 |
| Average L1 Active Cycles | cycle | 157103.16 | 68785.57 | 52123.71 | 65891.95 | 41165 |
| Total L1 Elapsed Cycles | cycle | 9445594 | 4252896 | 3244746 | 4046272 | 2585044 |
| Average L2 Active Cycles | cycle | 154452.21 | 68767.67 | 52583.12 | 68021.54 | 42850.38 |
| Total L2 Elapsed Cycles | cycle | 3941280 | 1773000 | 1361352 | 1738896 | 1111176 |
| Average SM Active Cycles | cycle | 157103.16 | 68785.57 | 52123.71 | 65891.95 | 41165 |
| Total SM Elapsed Cycles | cycle | 9445594 | 4252896 | 3244746 | 4046272 | 2585044 |
| Average SMSP Active Cycles | cycle | 157063.90 | 68513.50 | 51768.87 | 65333.66 | 40770.18 |
| Total SMSP Elapsed Cycles | cycle | 37782376 | 17011584 | 12978984 | 16185088 | 10340176 |

### Source Counters

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.17 | 0.15 | 0.08 | 0.15 | 0.10 |
| Branch Instructions | inst | 3440640 | 868352 | 401408 | 868352 | 315392 |
| Branch Efficiency | % | 88.19 | 88.37 | 100 | 88.37 | 100 |
| Avg. Divergent Branches | branches | 1059.31 | 264.83 | 0 | 264.83 | 0 |

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 45.6%. This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (48% of the total 4325376 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations.
- **int4_wmma** [OPT]: Est. Speedup: 72.35%. This kernel has uncoalesced shared accesses resulting in a total of 3440640 excessive wavefronts (75% of the total 4587520 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 46.54%. This kernel has uncoalesced global accesses resulting in a total of 1179648 excessive sectors (50% of the total 2359296 sectors).
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 70.36%. This kernel has uncoalesced shared accesses resulting in a total of 1720320 excessive wavefronts (75% of the total 2293760 wavefronts).
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 9.27%. This kernel has uncoalesced global accesses resulting in a total of 131072 excessive sectors (10% of the total 1310720 sectors).
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 56.29%. This kernel has uncoalesced shared accesses resulting in a total of 950272 excessive wavefronts (60% of the total 1572864 wavefronts).
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 46.94%. This kernel has uncoalesced global accesses resulting in a total of 1179648 excessive sectors (50% of the total 2359296 sectors).
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 70.84%. This kernel has uncoalesced shared accesses resulting in a total of 1720320 excessive wavefronts (75% of the total 2293760 wavefronts).
- **int4_ptx_3stage** [OPT]: Est. Speedup: 9.255%. This kernel has uncoalesced global accesses resulting in a total of 131072 excessive sectors (10% of the total 1310720 sectors).
- **int4_ptx_3stage** [OPT]: Est. Speedup: 61.57%. This kernel has uncoalesced shared accesses resulting in a total of 1048576 excessive wavefronts (67% of the total 1572864 wavefronts).

## Matrix Size 1024x1024x1024

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 833.11 | 845.45 | 840.05 | 794.87 | 794.87 |
| Elapsed Cycles | cycle | 1217044 | 493113 | 333563 | 485649 | 303351 |
| Memory Throughput | % | 77.68 | 84.79 | 86.29 | 84.97 | 91.88 |
| DRAM Throughput | % | 1.74 | 4.34 | 6.56 | 4.14 | 6.70 |
| Duration | ms | 1.45 | 0.58 | 0.39 | 0.61 | 0.38 |
| L1/TEX Cache Throughput | % | 78.09 | 86.52 | 88.46 | 87.04 | 94.35 |
| L2 Cache Throughput | % | 22.68 | 35.91 | 47.55 | 33.82 | 72.46 |
| SM Active Cycles | cycle | 1202287.21 | 480103.59 | 323491.38 | 474075.26 | 295404.19 |
| Compute (SM) Throughput | % | 68.62 | 48.44 | 44.30 | 52.58 | 37.43 |

Comments:
- **int4_wmma** [INF]: Compute and Memory are well-balanced: To reduce runtime, both computation and memory traffic must be reduced. Check both the Compute Workload Analysis and Memory Workload Analysis sections.
- **int4_ptx_mma_k32** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int4_ptx_mma_k64** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int4_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int4_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k64** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.

### PM Sampling

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 32.51 | 16.32 | 16.32 | 16.32 | 16.32 |
| Maximum Sampling Interval | us | 1 | 1 | 1 | 1 | 1 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 2.09 | 1.50 | 1.61 | 1.48 | 1.35 |
| Executed Ipc Elapsed | inst/cycle | 2.08 | 1.47 | 1.57 | 1.45 | 1.31 |
| Issue Slots Busy | % | 52.06 | 36.87 | 39.36 | 36.23 | 32.88 |
| Issued Ipc Active | inst/cycle | 2.09 | 1.50 | 1.61 | 1.48 | 1.35 |
| SM Busy | % | 52.06 | 36.87 | 39.36 | 36.23 | 32.88 |

Comments:
- **int4_wmma** [INF]: ALU is the highest-utilized pipeline (31.8%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_mma_k32** [INF]: ALU is the highest-utilized pipeline (20.2%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_mma_k64** [INF]: ALU is the highest-utilized pipeline (24.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_manual_pack** [OPT]: Est. Local Speedup: 80.69%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int4_ptx_3stage** [OPT]: Est. Local Speedup: 87.2%. All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 5.20 | 13.02 | 19.67 | 12.41 | 20.06 |
| Mem Busy | % | 77.68 | 84.79 | 86.29 | 84.97 | 91.88 |
| Max Bandwidth | % | 68.62 | 48.44 | 44.30 | 52.58 | 52.11 |
| L1/TEX Hit Rate | % | 80.79 | 78.22 | 63.10 | 78.70 | 44.26 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 97.79 | 96.66 | 96.54 | 96.71 | 98.38 |
| Mem Pipes Busy | % | 68.62 | 48.44 | 44.30 | 52.58 | 37.43 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 38.84%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 42.4%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 42.4%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 43.15%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 44.38%. The memory access pattern for shared loads might not be optimal and causes on average a 5.4 - way bank conflict. This results in 2112444 bank conflicts, which represent 50.17% of the overall 4210216 wavefronts for shared loads.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 42.48%. The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 42.48%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 45.94%. The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 47.75%. The memory access pattern for shared loads might not be optimal and causes on average a 5.4 - way bank conflict. This results in 2150264 bank conflicts, which represent 50.60% of the overall 4249150 wavefronts for shared loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| One or More Eligible | % | 52.33 | 37.66 | 40.43 | 37.17 | 33.82 |
| Issued Warp Per Scheduler |  | 0.52 | 0.38 | 0.40 | 0.37 | 0.34 |
| No Eligible | % | 47.67 | 62.34 | 59.57 | 62.83 | 66.18 |
| Active Warps Per Scheduler | warp | 11.78 | 9.56 | 7.65 | 9.41 | 7.40 |
| Eligible Warps Per Scheduler | warp | 1.79 | 0.89 | 0.87 | 1.10 | 0.91 |

### Warp State Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 22.51 | 25.39 | 18.93 | 25.31 | 21.89 |
| Warp Cycles Per Executed Instruction | cycle | 22.51 | 25.40 | 18.94 | 25.33 | 21.91 |
| Avg. Active Threads Per Warp |  | 18.53 | 23.85 | 32 | 23.63 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 17.02 | 21.67 | 29.31 | 21.39 | 29.03 |

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 22.32%. On average, each warp of this workload spends 8.2 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 36.5% of the total average of 22.5 cycles between issuing two instructions.
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 15.64%. Instructions are executed in warps, which are groups of 32 threads. This workload achieves an average of 23.8 threads being active per cycle.
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 13.71%. On average, each warp of this workload spends 6.6 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. This stall type represents about 34.8% of the total average of 18.9 cycles between issuing two instructions.
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 15.03%. On average, each warp of this workload spends 12.0 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 47.6% of the total average of 25.3 cycles between issuing two instructions.
- **int4_ptx_3stage** [OPT]: Est. Speedup: 8.118%. On average, each warp of this workload spends 13.9 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 63.5% of the total average of 21.9 cycles between issuing two instructions.

### Instruction Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 629089.10 | 180506.48 | 130436.41 | 175845.52 | 99645.79 |
| Executed Instructions | inst | 145948672 | 41877504 | 30261248 | 40796160 | 23117824 |
| Avg. Issued Instructions Per Scheduler | inst | 629211.90 | 180617.09 | 130518.63 | 175956.03 | 99729.62 |
| Issued Instructions | inst | 145977160 | 41903164 | 30280322 | 40821799 | 23137273 |

### Launch Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 8192 | 2048 | 2048 | 2048 | 2048 |
| Registers Per Thread | register/thread | 40 | 48 | 54 | 48 | 54 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 65.54 | 102.40 | 65.54 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 4.10 | 8.19 | 16.38 | 8.19 | 24.58 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 2097152 | 524288 | 524288 | 524288 | 524288 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 |
| Waves Per SM |  | 23.54 | 7.06 | 8.83 | 7.06 | 8.83 |

### Occupancy

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 4 | 5 | 4 |
| Block Limit Shared Mem | block | 12 | 7 | 5 | 7 | 4 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 32 | 40 | 32 |
| Theoretical Occupancy | % | 100 | 83.33 | 66.67 | 83.33 | 66.67 |
| Achieved Occupancy | % | 98.19 | 79.60 | 63.70 | 78.32 | 61.56 |
| Achieved Active Warps Per SM | warp | 47.13 | 38.21 | 30.58 | 37.59 | 29.55 |

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 157301.33 | 157130.67 | 161722.67 | 157960 | 159498.67 |
| Total DRAM Elapsed Cycles | cycle | 54350848 | 21703680 | 14785536 | 22886400 | 14294016 |
| Average L1 Active Cycles | cycle | 1202287.21 | 480103.59 | 323491.38 | 474075.26 | 295404.19 |
| Total L1 Elapsed Cycles | cycle | 70100572 | 28411694 | 19233152 | 28167456 | 17594218 |
| Average L2 Active Cycles | cycle | 1188074.79 | 484512.42 | 327471.04 | 495811.92 | 310745.62 |
| Total L2 Elapsed Cycles | cycle | 29118288 | 11818104 | 8013744 | 12102264 | 7564032 |
| Average SM Active Cycles | cycle | 1202287.21 | 480103.59 | 323491.38 | 474075.26 | 295404.19 |
| Total SM Elapsed Cycles | cycle | 70100572 | 28411694 | 19233152 | 28167456 | 17594218 |
| Average SMSP Active Cycles | cycle | 1202320.71 | 479600.69 | 322862.60 | 473359.01 | 294920.88 |
| Total SMSP Elapsed Cycles | cycle | 280402288 | 113646776 | 76932608 | 112669824 | 70376872 |

### Source Counters

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.19 | 0.16 | 0.10 | 0.17 | 0.12 |
| Branch Instructions | inst | 27394048 | 6881280 | 3047424 | 6881280 | 2703360 |
| Branch Efficiency | % | 87.84 | 87.94 | 100 | 87.94 | 100 |
| Avg. Divergent Branches | branches | 8756.97 | 2189.24 | 0 | 2189.24 | 0 |

Comments:
- **int4_wmma** [OPT]: Est. Speedup: 48.21%. This kernel has uncoalesced global accesses resulting in a total of 16777216 excessive sectors (49% of the total 34078720 sectors).
- **int4_wmma** [OPT]: Est. Speedup: 76.01%. This kernel has uncoalesced shared accesses resulting in a total of 28442624 excessive wavefronts (76% of the total 37224448 wavefronts).
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 49.2%. This kernel has uncoalesced global accesses resulting in a total of 8912896 excessive sectors (50% of the total 17825792 sectors).
- **int4_ptx_mma_k32** [OPT]: Est. Speedup: 74.89%. This kernel has uncoalesced shared accesses resulting in a total of 14221312 excessive wavefronts (76% of the total 18612224 wavefronts).
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 5.448%. This kernel has uncoalesced global accesses resulting in a total of 524288 excessive sectors (6% of the total 9437184 sectors).
- **int4_ptx_mma_k64** [OPT]: Est. Speedup: 61.99%. This kernel has uncoalesced shared accesses resulting in a total of 7995392 excessive wavefronts (64% of the total 12582912 wavefronts).
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 49.16%. This kernel has uncoalesced global accesses resulting in a total of 8912896 excessive sectors (50% of the total 17825792 sectors).
- **int4_ptx_manual_pack** [OPT]: Est. Speedup: 74.59%. This kernel has uncoalesced shared accesses resulting in a total of 14221312 excessive wavefronts (76% of the total 18612224 wavefronts).
- **int4_ptx_3stage** [OPT]: Est. Speedup: 5.478%. This kernel has uncoalesced global accesses resulting in a total of 524288 excessive sectors (6% of the total 9437184 sectors).
- **int4_ptx_3stage** [OPT]: Est. Speedup: 64.92%. This kernel has uncoalesced shared accesses resulting in a total of 8388608 excessive wavefronts (67% of the total 12582912 wavefronts).

## Matrix Size 2048x2048x2048

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 830.29 | 846.63 | 843.09 | 794.99 | 794.98 |
| Elapsed Cycles | cycle | 9524046 | 3682236 | 2380594 | 3662175 | 2315100 |
| Memory Throughput | % | 78.44 | 88.31 | 92.02 | 87.56 | 92.72 |
| DRAM Throughput | % | 2.66 | 7.01 | 10.75 | 6.65 | 10.53 |
| Duration | ms | 11.40 | 4.32 | 2.81 | 4.61 | 2.91 |
| L1/TEX Cache Throughput | % | 78.53 | 88.66 | 92.43 | 88.06 | 93.21 |
| L2 Cache Throughput | % | 23.43 | 40.57 | 52.50 | 37.31 | 89.33 |
| SM Active Cycles | cycle | 9455881.21 | 3643719.02 | 2355144.60 | 3641164.53 | 2303000.45 |
| Compute (SM) Throughput | % | 68.66 | 49.67 | 43.18 | 53.56 | 38.36 |

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma**: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k32**: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_mma_k64**: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_manual_pack**: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.
- **int4_ptx_3stage**: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance.

### PM Sampling

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 21.30 | 18.61 | 32.51 | 19.66 | 32.51 |
| Maximum Sampling Interval | us | 4 | 2 | 2 | 2 | 2 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 2.03 | 1.48 | 1.45 | 1.44 | 1.31 |
| Executed Ipc Elapsed | inst/cycle | 2.03 | 1.47 | 1.45 | 1.43 | 1.31 |
| Issue Slots Busy | % | 50.65 | 36.79 | 36.20 | 35.75 | 32.64 |
| Issued Ipc Active | inst/cycle | 2.03 | 1.48 | 1.45 | 1.44 | 1.31 |
| SM Busy | % | 50.65 | 36.79 | 36.20 | 35.75 | 32.64 |

Comments:
- **int4_wmma**: ALU is the highest-utilized pipeline (29.2%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int4_ptx_mma_k32**: All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **int4_ptx_mma_k64**: All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **int4_ptx_manual_pack**: All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.
- **int4_ptx_3stage**: All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler.

### Memory Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 7.98 | 21.00 | 32.23 | 19.93 | 31.57 |
| Mem Busy | % | 78.44 | 88.31 | 92.02 | 87.56 | 92.72 |
| Max Bandwidth | % | 68.66 | 49.67 | 52.50 | 53.56 | 87.47 |
| L1/TEX Hit Rate | % | 80.76 | 76.46 | 62.20 | 76.57 | 29.63 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.00 | 98.43 | 98.19 | 98.67 | 97.37 |
| Mem Pipes Busy | % | 68.66 | 49.67 | 43.18 | 53.56 | 38.36 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma**: Est. Speedup: 39.22% - The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads.
- **int4_ptx_mma_k32**: Est. Speedup: 44.15% - The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Est. Speedup: 44.15% - The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads.
- **int4_ptx_mma_k64**: Est. Speedup: 46.01% - The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Est. Speedup: 46.31% - The memory access pattern for shared loads might not be optimal and causes on average a 5.3 - way bank conflict across all 6291456 shared load requests. This results in 16850660 bank conflicts, which represent 50.10% of the overall 33631637 wavefronts for shared loads.
- **int4_ptx_manual_pack**: Est. Speedup: 43.78% - The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Est. Speedup: 43.78% - The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads.
- **int4_ptx_3stage**: Est. Speedup: 46.36% - The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Est. Speedup: 46.91% - The memory access pattern for shared loads might not be optimal and causes on average a 5.4 - way bank conflict across all 6291456 shared load requests. This results in 17007280 bank conflicts, which represent 50.33% of the overall 33794661 wavefronts for shared loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| One or More Eligible | % | 50.70 | 36.94 | 36.37 | 35.96 | 32.93 |
| Issued Warp Per Scheduler | | 0.51 | 0.37 | 0.36 | 0.36 | 0.33 |
| No Eligible | % | 49.30 | 63.06 | 63.63 | 64.04 | 67.07 |
| Active Warps Per Scheduler | warp | 11.93 | 9.87 | 7.89 | 9.73 | 7.55 |
| Eligible Warps Per Scheduler | warp | 1.70 | 0.83 | 0.71 | 1.09 | 0.91 |

### Warp State Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 23.52 | 26.73 | 21.69 | 27.05 | 22.92 |
| Warp Cycles Per Executed Instruction | cycle | 23.52 | 26.73 | 21.69 | 27.05 | 22.92 |
| Avg. Active Threads Per Warp | | 17.63 | 23.11 | 32 | 22.86 | 32 |
| Avg. Not Predicated Off Threads Per Warp | | 16.29 | 20.97 | 29.01 | 20.66 | 28.90 |

Comments:
- **int4_wmma**: Est. Speedup: 21.56% - On average, each warp of this workload spends 8.7 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines. This stall type represents about 37.0% of the total average of 23.5 cycles between issuing two instructions.
- **int4_ptx_mma_k32**: Est. Speedup: 11.69% - On average, each warp of this workload spends 8.6 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. This stall type represents about 32.1% of the total average of 26.7 cycles between issuing two instructions.
- **int4_ptx_mma_k64**: Est. Speedup: 7.978% - On average, each warp of this workload spends 8.2 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. This stall type represents about 37.6% of the total average of 21.7 cycles between issuing two instructions.
- **int4_ptx_manual_pack**: Est. Speedup: 12.44% - On average, each warp of this workload spends 13.8 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 51.1% of the total average of 27.0 cycles between issuing two instructions.
- **int4_ptx_3stage**: Est. Speedup: 7.276% - On average, each warp of this workload spends 15.3 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall type represents about 66.8% of the total average of 22.9 cycles between issuing two instructions.

### Instruction Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 4794297.38 | 1345747.86 | 856205.24 | 1309025.10 | 755641.38 |
| Executed Instructions | inst | 1112276992 | 312213504 | 198639616 | 303693824 | 175308800 |
| Avg. Issued Instructions Per Scheduler | inst | 4794420.22 | 1345858.33 | 856287.44 | 1309135.65 | 755725.10 |
| Issued Instructions | inst | 1112305492 | 312239133 | 198658687 | 303719470 | 175328223 |

### Launch Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Size | | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | | 32768 | 8192 | 8192 | 8192 | 8192 |
| Registers Per Thread | register/thread | 40 | 48 | 54 | 48 | 54 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 65.54 | 102.40 | 65.54 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 4.10 | 8.19 | 16.38 | 8.19 | 24.58 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 |
| Stack Size | | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 8388608 | 2097152 | 2097152 | 2097152 | 2097152 |
| # TPCs | | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs | | all | all | all | all | all |
| Uses Green Context | | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM | | 94.16 | 28.25 | 35.31 | 28.25 | 35.31 |

### Occupancy

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 4 | 5 | 4 |
| Block Limit Shared Mem | block | 12 | 7 | 5 | 7 | 4 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 32 | 40 | 32 |
| Theoretical Occupancy | % | 100 | 83.33 | 66.67 | 83.33 | 66.67 |
| Achieved Occupancy | % | 99.41 | 82.28 | 65.71 | 81.03 | 62.76 |
| Achieved Active Warps Per SM | warp | 47.72 | 39.49 | 31.54 | 38.89 | 30.12 |

Comments:
- **int4_ptx_mma_k64**: The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.
- **int4_ptx_3stage**: The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers, and the required amount of shared memory.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 1895952 | 1890498.67 | 1883805.33 | 1912749.33 | 1915290.67 |
| Total DRAM Elapsed Cycles | cycle | 427174912 | 161887232 | 105123840 | 172599296 | 109111296 |
| Average L1 Active Cycles | cycle | 9455881.21 | 3643719.02 | 2355144.60 | 3641164.53 | 2303000.45 |
| Total L1 Elapsed Cycles | cycle | 549067094 | 212179562 | 137207080 | 212405954 | 134275576 |
| Average L2 Active Cycles | cycle | 9481549 | 3664223 | 2370167.17 | 3790686.46 | 2399878.58 |
| Total L2 Elapsed Cycles | cycle | 227886264 | 88152840 | 57012072 | 91219560 | 57672744 |
| Average SM Active Cycles | cycle | 9455881.21 | 3643719.02 | 2355144.60 | 3641164.53 | 2303000.45 |
| Total SM Elapsed Cycles | cycle | 549067094 | 212179562 | 137207080 | 212405954 | 134275576 |
| Average SMSP Active Cycles | cycle | 9455823.26 | 3643496.55 | 2354631.44 | 3640270.09 | 2294607.12 |
| Total SMSP Elapsed Cycles | cycle | 2196268376 | 848718248 | 548828320 | 849623816 | 537102304 |

### Source Counters

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.20 | 0.18 | 0.12 | 0.18 | 0.13 |
| Branch Instructions | inst | 218628096 | 54788096 | 23724032 | 54788096 | 22347776 |
| Branch Efficiency | % | 87.67 | 87.72 | 100 | 87.72 | 100 |
| Avg. Divergent Branches | branches | 71185.66 | 17796.41 | 0 | 17796.41 | 0 |

Comments:
- **int4_wmma**: Est. Speedup: 49.54% - This kernel has uncoalesced global accesses resulting in a total of 134217728 excessive sectors (50% of the total 270532608 sectors). Est. Speedup: 77.01% - This kernel has uncoalesced shared accesses resulting in a total of 231211008 excessive wavefronts (77% of the total 299892736 wavefronts).
- **int4_ptx_mma_k32**: Est. Speedup: 49.88% - This kernel has uncoalesced global accesses resulting in a total of 69206016 excessive sectors (50% of the total 138412032 sectors). Est. Speedup: 76.79% - This kernel has uncoalesced shared accesses resulting in a total of 115605504 excessive wavefronts (77% of the total 149946368 wavefronts).
- **int4_ptx_mma_k64**: Est. Speedup: 2.935% - This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (3% of the total 71303168 sectors). Est. Speedup: 64.82% - This kernel has uncoalesced shared accesses resulting in a total of 65536000 excessive wavefronts (65% of the total 100663296 wavefronts).
- **int4_ptx_manual_pack**: Est. Speedup: 49.87% - This kernel has uncoalesced global accesses resulting in a total of 69206016 excessive sectors (50% of the total 138412032 sectors). Est. Speedup: 76.66% - This kernel has uncoalesced shared accesses resulting in a total of 115605504 excessive wavefronts (77% of the total 149946368 wavefronts).
- **int4_ptx_3stage**: Est. Speedup: 2.937% - This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (3% of the total 71303168 sectors). Est. Speedup: 66.32% - This kernel has uncoalesced shared accesses resulting in a total of 67108864 excessive wavefronts (67% of the total 100663296 wavefronts).

## Matrix Size 4096x4096x4096

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 833.83 | 840.61 | 843.84 | 801.17 | 795.00 |
| Elapsed Cycles | cycle | 75620256 | 28757449 | 18278610 | 28758058 | 19283148 |
| Memory Throughput | % | 78.61 | 89.14 | 93.42 | 88.69 | 93.40 |
| DRAM Throughput | % | 1.65 | 4.30 | 6.78 | 4.16 | 6.11 |
| Duration | ms | 90.11 | 33.99 | 21.52 | 35.55 | 24.26 |
| L1/TEX Cache Throughput | % | 78.63 | 89.22 | 93.57 | 88.79 | 87.12 |
| L2 Cache Throughput | % | 23.51 | 39.34 | 50.71 | 41.65 | 93.40 |
| SM Active Cycles | cycle | 75120528.45 | 28545214.52 | 18134168.84 | 28457265.43 | 19258483.59 |
| Compute (SM) Throughput | % | 68.48 | 49.73 | 41.61 | 53.94 | 36.42 |

### PM Sampling

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 19.46 | 29.82 | 19.40 | 31.39 | 21.82 |
| Maximum Sampling Interval | us | 32 | 8 | 8 | 8 | 8 |
| # Pass Groups | | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.99 | 1.45 | 1.35 | 1.42 | 1.22 |
| Executed Ipc Elapsed | inst/cycle | 1.99 | 1.45 | 1.34 | 1.42 | 1.22 |
| Issue Slots Busy | % | 49.78 | 36.30 | 33.59 | 35.39 | 30.49 |
| Issued Ipc Active | inst/cycle | 1.99 | 1.45 | 1.35 | 1.42 | 1.22 |
| SM Busy | % | 49.78 | 36.30 | 33.59 | 35.39 | 30.49 |

### Memory Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Local Memory Spilling Requests | | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 4.94 | 12.88 | 20.32 | 12.48 | 18.31 |
| Mem Busy | % | 78.61 | 89.14 | 93.42 | 88.69 | 93.40 |
| Max Bandwidth | % | 68.48 | 49.73 | 50.71 | 53.94 | 90.52 |
| L1/TEX Hit Rate | % | 80.49 | 76.20 | 61.74 | 73.61 | 20.20 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio | | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.48 | 99.20 | 99.01 | 99.27 | 99.00 |
| Mem Pipes Busy | % | 68.48 | 49.73 | 41.61 | 53.94 | 36.42 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Note: This section contains analysis text and optimization recommendations from the profiler, not metric tables.

### Scheduler Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| One or More Eligible | % | 49.79 | 36.34 | 33.64 | 35.43 | 30.55 |
| Issued Warp Per Scheduler | | 0.50 | 0.36 | 0.34 | 0.35 | 0.31 |
| No Eligible | % | 50.21 | 63.66 | 66.36 | 64.57 | 69.45 |
| Active Warps Per Scheduler | warp | 11.97 | 9.96 | 7.95 | 9.86 | 7.47 |
| Eligible Warps Per Scheduler | warp | 1.65 | 0.79 | 0.62 | 1.10 | 0.84 |

### Warp State Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 24.05 | 27.40 | 23.65 | 27.82 | 24.44 |
| Warp Cycles Per Executed Instruction | cycle | 24.05 | 27.40 | 23.65 | 27.82 | 24.44 |
| Avg. Active Threads Per Warp | | 17.14 | 22.70 | 32 | 22.43 | 32 |
| Avg. Not Predicated Off Threads Per Warp | | 15.90 | 20.59 | 28.81 | 20.26 | 28.83 |

### Instruction Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 37400717.24 | 10372766.90 | 6100497.66 | 10081244.69 | 5879031.17 |
| Executed Instructions | inst | 8676966400 | 2406481920 | 1415315456 | 2338848768 | 1363935232 |
| Avg. Issued Instructions Per Scheduler | inst | 37400840.04 | 10372877.25 | 6100579.84 | 10081355.07 | 5879114.96 |
| Issued Instructions | inst | 8676994889 | 2406507521 | 1415334524 | 2338874376 | 1363954671 |

### Launch Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Size | | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration | | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size | | 131072 | 32768 | 32768 | 32768 | 32768 |
| Registers Per Thread | register/thread | 40 | 48 | 54 | 48 | 54 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 65.54 | 102.40 | 65.54 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 4.10 | 8.19 | 16.38 | 8.19 | 24.58 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 |
| Stack Size | | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 33554432 | 8388608 | 8388608 | 8388608 | 8388608 |
| # TPCs | | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs | | all | all | all | all | all |
| Uses Green Context | | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM | | 376.64 | 112.99 | 141.24 | 112.99 | 141.24 |

### Occupancy

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 4 | 5 | 4 |
| Block Limit Shared Mem | block | 12 | 7 | 5 | 7 | 4 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 32 | 40 | 32 |
| Theoretical Occupancy | % | 100 | 83.33 | 66.67 | 83.33 | 66.67 |
| Achieved Occupancy | % | 99.79 | 82.99 | 66.30 | 82.11 | 62.35 |
| Achieved Active Warps Per SM | warp | 47.90 | 39.83 | 31.82 | 39.41 | 29.93 |

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 9275762.67 | 9120218.67 | 9112141.33 | 9242005.33 | 9252472 |
| Total DRAM Elapsed Cycles | cycle | 3376113664 | 1273535488 | 806407168 | 1331984384 | 908818432 |
| Average L1 Active Cycles | cycle | 75120528.45 | 28545214.52 | 18134168.84 | 28457265.43 | 19258483.59 |
| Total L1 Elapsed Cycles | cycle | 4358011162 | 1657279922 | 1053435728 | 1652342050 | 1118422398 |
| Average L2 Active Cycles | cycle | 75243751.88 | 28633277.92 | 18206130.88 | 29306078.50 | 19997296.83 |
| Total L2 Elapsed Cycles | cycle | 1807380552 | 687890640 | 437556600 | 703879320 | 480280056 |
| Average SM Active Cycles | cycle | 75120528.45 | 28545214.52 | 18134168.84 | 28457265.43 | 19258483.59 |
| Total SM Elapsed Cycles | cycle | 4358011162 | 1657279922 | 1053435728 | 1652342050 | 1118422398 |
| Average SMSP Active Cycles | cycle | 75120212.53 | 28545161.56 | 18134334.26 | 28452053.69 | 19242703.38 |
| Total SMSP Elapsed Cycles | cycle | 17432044648 | 6629119688 | 4213742912 | 6609368200 | 4473689592 |

### Source Counters

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.20 | 0.18 | 0.13 | 0.19 | 0.13 |
| Branch Instructions | inst | 1746927616 | 437256192 | 187170816 | 437256192 | 181665792 |
| Branch Efficiency | % | 87.59 | 87.61 | 100 | 87.61 | 100 |
| Avg. Divergent Branches | branches | 574004.97 | 143501.24 | 0 | 143501.24 | 0 |

## Matrix Size 8192x8192x8192

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 840.44 | 840.52 | 852.84 | 803.82 | 801.70 |
| Elapsed Cycles | cycle | 603029155 | 227846109 | 143401250 | 225139106 | 160000560 |
| Memory Throughput | % | 78.62 | 89.33 | 93.72 | 90.02 | 95.59 |
| DRAM Throughput | % | 0.88 | 2.32 | 3.73 | 2.26 | 3.16 |
| Duration | ms | 712.96 | 269.35 | 167.10 | 277.13 | 197.63 |
| L1/TEX Cache Throughput | % | 78.63 | 89.35 | 93.75 | 90.04 | 83.66 |
| L2 Cache Throughput | % | 23.55 | 38.62 | 49.81 | 53.83 | 95.59 |
| SM Active Cycles | cycle | 599201420.43 | 226359820.03 | 142464870.76 | 222789720.36 | 158442249.24 |
| Compute (SM) Throughput | % | 68.33 | 49.63 | 40.70 | 54.58 | 35.25 |

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

### PM Sampling

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 19.14 | 28.90 | 18.02 | 29.82 | 21.30 |
| Maximum Sampling Interval | us | 256 | 64 | 64 | 64 | 64 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.97 | 1.44 | 1.29 | 1.42 | 1.17 |
| Executed Ipc Elapsed | inst/cycle | 1.97 | 1.44 | 1.29 | 1.42 | 1.17 |
| Issue Slots Busy | % | 49.29 | 35.96 | 32.14 | 35.49 | 29.26 |
| Issued Ipc Active | inst/cycle | 1.97 | 1.44 | 1.29 | 1.42 | 1.17 |
| SM Busy | % | 49.29 | 35.96 | 32.14 | 35.49 | 29.26 |

### Memory Workload Analysis

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 2.65 | 6.96 | 11.19 | 6.77 | 9.47 |
| Mem Busy | % | 78.62 | 89.33 | 93.72 | 90.02 | 95.59 |
| Max Bandwidth | % | 68.33 | 49.63 | 49.81 | 54.58 | 92.32 |
| L1/TEX Hit Rate | % | 80.34 | 76.15 | 61.56 | 66.06 | 14.49 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.74 | 99.60 | 99.50 | 99.89 | 99.78 |
| Mem Pipes Busy | % | 68.33 | 49.63 | 40.70 | 54.58 | 35.25 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int4_wmma**: Est. Speedup: 39.31% for memory access pattern optimization.
- **int4_ptx_mma_k32**: Est. Speedup: 44.66% for both global loads and stores.
- **int4_ptx_mma_k64**: Est. Speedup: 46.86% for global stores and 46.9% for shared loads with 5.3-way bank conflicts.
- **int4_ptx_manual_pack**: Est. Speedup: 45.01% for both global loads and stores.
- **int4_ptx_3stage**: Est. Speedup: 41.82% for global stores and 41.9% for shared loads with 5.3-way bank conflicts.

### Scheduler Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| One or More Eligible | % | 49.30 | 35.96 | 32.16 | 35.51 | 29.26 |
| Issued Warp Per Scheduler |  | 0.49 | 0.36 | 0.32 | 0.36 | 0.29 |
| No Eligible | % | 50.70 | 64.04 | 67.84 | 64.49 | 70.74 |
| Active Warps Per Scheduler | warp | 11.99 | 9.98 | 7.98 | 9.90 | 7.34 |
| Eligible Warps Per Scheduler | warp | 1.63 | 0.77 | 0.57 | 1.08 | 0.79 |

### Warp State Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 24.32 | 27.76 | 24.82 | 27.88 | 25.08 |
| Warp Cycles Per Executed Instruction | cycle | 24.32 | 27.76 | 24.82 | 27.88 | 25.08 |
| Avg. Active Threads Per Warp |  | 16.89 | 22.49 | 32 | 22.21 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 15.70 | 20.39 | 28.68 | 20.04 | 28.80 |

### Instruction Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 295391090.76 | 81409271.17 | 45807404.14 | 79086132.97 | 46367849.93 |
| Executed Instructions | inst | 68530733056 | 18886950912 | 10627317760 | 18347982848 | 10757341184 |
| Avg. Issued Instructions Per Scheduler | inst | 295391213.79 | 81409381.91 | 45807486.40 | 79086243.33 | 46367933.70 |
| Issued Instructions | inst | 68530761600 | 18886976602 | 10627336845 | 18348008452 | 10757360619 |

### Launch Statistics

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 524288 | 131072 | 131072 | 131072 | 131072 |
| Registers Per Thread | register/thread | 40 | 48 | 54 | 48 | 54 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 65.54 | 102.40 | 65.54 | 102.40 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | Kbyte/block | 4.10 | 8.19 | 16.38 | 8.19 | 24.58 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 134217728 | 33554432 | 33554432 | 33554432 | 33554432 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 1506.57 | 451.97 | 564.97 | 451.97 | 564.97 |

### Occupancy

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 4 | 5 | 4 |
| Block Limit Shared Mem | block | 12 | 7 | 5 | 7 | 4 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 32 | 40 | 32 |
| Theoretical Occupancy | % | 100 | 83.33 | 66.67 | 83.33 | 66.67 |
| Achieved Occupancy | % | 99.91 | 83.21 | 66.51 | 82.50 | 61.05 |
| Achieved Active Warps Per SM | warp | 47.96 | 39.94 | 31.92 | 39.60 | 29.31 |

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 39299981.33 | 39041176 | 38960490.67 | 39057976 | 39006762.67 |
| Total DRAM Elapsed Cycles | cycle | 26713610240 | 10092200960 | 6260866048 | 10383587328 | 7404955648 |
| Average L1 Active Cycles | cycle | 599201420.43 | 226359820.03 | 142464870.76 | 222789720.36 | 158442249.24 |
| Total L1 Elapsed Cycles | cycle | 34755818498 | 13131861060 | 8265942324 | 12925073562 | 9192219830 |
| Average L2 Active Cycles | cycle | 600476073.46 | 226934572.29 | 142972028.62 | 228543477.38 | 163005595.58 |
| Total L2 Elapsed Cycles | cycle | 14416510824 | 5447620056 | 3432874392 | 5487141096 | 3913102656 |
| Average SM Active Cycles | cycle | 599201420.43 | 226359820.03 | 142464870.76 | 222789720.36 | 158442249.24 |
| Total SM Elapsed Cycles | cycle | 34755818498 | 13131861060 | 8265942324 | 12925073562 | 9192219830 |
| Average SMSP Active Cycles | cycle | 599205105.50 | 226363210.56 | 142457887.57 | 222743172.35 | 158487861.86 |
| Total SMSP Elapsed Cycles | cycle | 139023273992 | 52527444240 | 33063769296 | 51700294248 | 36768879320 |

### Source Counters

| Metric Name | Metric Unit | int4_wmma | int4_ptx_mma_k32 | int4_ptx_mma_k64 | int4_ptx_manual_pack | int4_ptx_3stage |
|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.20 | 0.18 | 0.14 | 0.19 | 0.14 |
| Branch Instructions | inst | 13967032320 | 3493855232 | 1486880768 | 3493855232 | 1464860672 |
| Branch Efficiency | % | 87.54 | 87.55 | 100 | 87.55 | 100 |
| Avg. Divergent Branches | branches | 4610118.62 | 1152529.66 | 0 | 1152529.66 | 0 |