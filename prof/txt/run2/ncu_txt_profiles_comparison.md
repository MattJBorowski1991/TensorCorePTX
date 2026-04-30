# NCU TXT Profiles Comparison (run2)

Combined Nsight Compute high-level sections for six int8 kernels and five matrix sizes.
Metric names, metric units, metric values, and comments are copied from source txt reports.

## Matrix Size 512x512x512

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 795.87 | 798.45 | 804.14 | 805.05 | 803.02 | 801.76 |
| Elapsed Cycles | cycle | 121418 | 93542 | 165614 | 129159 | 122639 | 474808 |
| Memory Throughput | % | 83.54 | 75.98 | 83.03 | 80.28 | 86.70 | 92.63 |
| DRAM Throughput | % | 8.14 | 10.65 | 6.04 | 7.76 | 8.19 | 2.09 |
| Duration | us | 152 | 116.58 | 204.54 | 159.55 | 151.87 | 588.80 |
| L1/TEX Cache Throughput | % | 87.13 | 80.33 | 86.37 | 84.02 | 90.60 | 93.73 |
| L2 Cache Throughput | % | 33.83 | 40.17 | 24.38 | 30.28 | 63.67 | 17.30 |
| SM Active Cycles | cycle | 115989.07 | 88041.86 | 158121.90 | 122713.38 | 116686.60 | 466540.59 |
| Compute (SM) Throughput | % | 45.07 | 46.74 | 35.90 | 49.71 | 45.52 | 92.63 |

Comments:
- **int8_dp4a** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Compute Workload Analysis section.
- **int8_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k16** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k32** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.
- **int8_wmma** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k16** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.

### PM Sampling

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 16.25 | 16.25 | 16.25 | 16.25 | 16.25 | 16.32 |
| Maximum Sampling Interval | us | 1 | 1 | 1 | 1 | 1 | 1 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.47 | 1.46 | 1.11 | 1.93 | 1.46 | 1.11 |
| Executed Ipc Elapsed | inst/cycle | 1.41 | 1.38 | 1.07 | 1.84 | 1.40 | 1.09 |
| Issue Slots Busy | % | 35.34 | 34.57 | 26.81 | 46.10 | 34.99 | 27.35 |
| Issued Ipc Active | inst/cycle | 1.47 | 1.46 | 1.12 | 1.93 | 1.46 | 1.11 |
| SM Busy | % | 35.34 | 34.57 | 26.81 | 46.10 | 34.99 | 36.22 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.83% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 83.99% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (45.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 81.21% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_mma_k32** [INF]: ALU is the highest-utilized pipeline (21.1%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_wmma** [OPT]: Est. Local Speedup: 80.91% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 24.40 | 31.88 | 18.09 | 23.26 | 24.54 | 6.27 |
| Mem Busy | % | 83.54 | 75.98 | 83.03 | 80.28 | 86.70 | 57.21 |
| Max Bandwidth | % | 45.07 | 46.74 | 35.90 | 49.71 | 45.52 | 92.63 |
| L1/TEX Hit Rate | % | 77.60 | 63.64 | 85.98 | 79.98 | 58.74 | 52.28 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 95.53 | 93.40 | 92.89 | 93.58 | 97.60 | 96.09 |
| Mem Pipes Busy | % | 45.07 | 46.74 | 35.90 | 49.71 | 45.52 | 92.63 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 46.32% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 43.35% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 40.14% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 40.14% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 80.44% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 1.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 41.52% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 37.99% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 40.28% The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 393216 shared load requests.This results in 527338 bank conflicts,  which represent 50.14% of the overall 1051711 wavefronts for shared loads. Check the Source Counters section for uncoalesced shared loads.
- **int8_wmma** [OPT]: Est. Speedup: 41.77% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 37.09 | 36.60 | 27.89 | 48.41 | 36.69 | 27.68 |
| Issued Warp Per Scheduler |  | 0.37 | 0.37 | 0.28 | 0.48 | 0.37 | 0.28 |
| No Eligible | % | 62.91 | 63.40 | 72.11 | 51.59 | 63.31 | 72.32 |
| Active Warps Per Scheduler | warp | 9.68 | 6.93 | 8.86 | 8.29 | 8.06 | 11.57 |
| Eligible Warps Per Scheduler | warp | 0.99 | 0.85 | 0.59 | 1.39 | 1.12 | 1.31 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 7.367% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.57 active warps per scheduler, but only an average of 1.31 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 13.3% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.06 active warps per scheduler, but only an average of 1.12 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 19.72% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.29 active warps per scheduler, but only an average of 1.39 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 16.97% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.86 active warps per scheduler, but only an average of 0.59 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 24.02% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 6.93 active warps per scheduler, but only an average of 0.85 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 16.46% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.68 active warps per scheduler, but only an average of 0.99 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 26.11 | 18.95 | 31.75 | 17.12 | 21.97 | 41.80 |
| Warp Cycles Per Executed Instruction | cycle | 26.16 | 19.00 | 31.81 | 17.15 | 22.01 | 41.84 |
| Avg. Active Threads Per Warp |  | 23.38 | 32 | 23.26 | 25.93 | 22.93 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 21.07 | 29.27 | 21.41 | 24.26 | 20.99 | 31.86 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 7.367% On average, each warp of this workload spends 20.8 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 49.8% of the total average of 41.8 cycles between issuing two instructions.
- **int8_dp4a** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 13.3% On average, each warp of this workload spends 13.7 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 62.4% of the total average of 22.0 cycles between issuing two instructions.
- **int8_ptx_3stage** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 15.66% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.9 threads being active per cycle. This is further reduced to 21.0 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 19.72% On average, each warp of this workload spends 6.4 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 37.5% of the total average of 17.1 cycles between issuing two instructions.
- **int8_ptx_manual_pack** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 16.97% On average, each warp of this workload spends 9.8 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 31.0% of the total average of 31.8 cycles between issuing two instructions.
- **int8_ptx_mma_k16** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 11.88% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.3 threads being active per cycle. This is further reduced to 21.4 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_wmma** [OPT]: Est. Speedup: 16.46% On average, each warp of this workload spends 8.8 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 33.8% of the total average of 26.1 cycles between issuing two instructions.
- **int8_wmma** [OPT]: Est. Speedup: 16.46% On average, each warp of this workload spends 8.6 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 33.0% of the total average of 26.1 cycles between issuing two instructions.
- **int8_wmma** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 15.4% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.4 threads being active per cycle. This is further reduced to 21.1 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.

### Instruction Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 42654.90 | 32097.10 | 44014.34 | 59127.17 | 42584.28 | 128953.38 |
| Executed Instructions | inst | 9895936 | 7446528 | 10211328 | 13717504 | 9879552 | 29917184 |
| Avg. Issued Instructions Per Scheduler | inst | 42751.85 | 32179.87 | 44094.47 | 59213.79 | 42668.74 | 129087.65 |
| Issued Instructions | inst | 9918430 | 7465730 | 10229918 | 13737600 | 9899147 | 29948334 |

### Launch Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 512 | 512 | 512 | 512 | 512 | 4096 |
| Registers Per Thread | register/thread | 39 | 54 | 48 | 48 | 48 | 40 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 102.40 | 65.54 | 65.54 | 102.40 | 32.77 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block |  |  |  |  |  | 640 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 131072 | 131072 | 131072 | 131072 | 131072 | 1048576 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 1.47 | 2.21 | 1.77 | 1.77 | 1.77 | 11.77 |
| Static Shared Memory Per Block | Kbyte/block | 8.19 | 16.38 | 8.19 | 8.19 | 12.29 |  |

Comments:
- **int8_ptx_3stage** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.33% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 2 full waves and a partial wave of 48 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 33.3% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_wmma** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 164 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.

### Occupancy

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 4 | 5 | 5 | 5 | 6 |
| Block Limit Shared Mem | block | 7 | 5 | 7 | 7 | 7 | 19 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 32 | 40 | 40 | 40 | 48 |
| Theoretical Occupancy | % | 100 | 66.67 | 83.33 | 83.33 | 83.33 | 100 |
| Achieved Occupancy | % | 80.22 | 57.77 | 73.77 | 68.91 | 66.94 | 96.43 |
| Achieved Active Warps Per SM | warp | 38.50 | 27.73 | 35.41 | 33.08 | 32.13 | 46.28 |

Comments:
- **int8_ptx_3stage** [OPT]: Est. Speedup: 13.3% The difference between calculated theoretical (83.3%) and measured achieved occupancy (66.9%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 17.31% The difference between calculated theoretical (83.3%) and measured achieved occupancy (68.9%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 24.02% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.
- **int8_wmma** [OPT]: Est. Speedup: 16.46% The difference between calculated theoretical (100.0%) and measured achieved occupancy (80.2%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 77269.33 | 77416 | 77072 | 77317.33 | 77642.67 | 76952 |
| Total DRAM Elapsed Cycles | cycle | 5692416 | 4363264 | 7657472 | 5975040 | 5687296 | 22056960 |
| Average L1 Active Cycles | cycle | 115989.07 | 88041.86 | 158121.90 | 122713.38 | 116686.60 | 466540.59 |
| Total L1 Elapsed Cycles | cycle | 7016324 | 5398376 | 9539160 | 7449468 | 7072818 | 27379366 |
| Average L2 Active Cycles | cycle | 120888.08 | 91590.04 | 156559.12 | 127685.96 | 122199.29 | 441688.58 |
| Total L2 Elapsed Cycles | cycle | 3008040 | 2306832 | 4053528 | 3176040 | 3015024 | 11674368 |
| Average SM Active Cycles | cycle | 115989.07 | 88041.86 | 158121.90 | 122713.38 | 116686.60 | 466540.59 |
| Total SM Elapsed Cycles | cycle | 7016324 | 5398376 | 9539160 | 7449468 | 7072818 | 27379366 |
| Average SMSP Active Cycles | cycle | 115273.86 | 87925.10 | 158091.97 | 122309.28 | 116284.22 | 466300.07 |
| Total SMSP Elapsed Cycles | cycle | 28065296 | 21593504 | 38156640 | 29797872 | 28291272 | 109517464 |

### Source Counters

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.17 | 0.10 | 0.18 | 0.14 | 0.17 | 0.01 |
| Branch Instructions | inst | 1720320 | 761856 | 1826816 | 1859584 | 1708032 | 425984 |
| Branch Efficiency | % | 87.94 | 100 | 87.35 | 87.98 | 87.35 | 100 |
| Avg. Divergent Branches | branches | 547.31 | 0 | 564.97 | 547.31 | 564.97 | 0 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 44.03% This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (48% of the total 4325376 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 48.64% This kernel has uncoalesced global accesses resulting in a total of 2228224 excessive sectors (50% of the total 4456448 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 74.42% This kernel has uncoalesced shared accesses resulting in a total of 3670016 excessive wavefronts (78% of the total 4718592 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 48.24% This kernel has uncoalesced global accesses resulting in a total of 2228224 excessive sectors (50% of the total 4456448 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 73% This kernel has uncoalesced shared accesses resulting in a total of 3555328 excessive wavefronts (76% of the total 4653056 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 59.59% This kernel has uncoalesced global accesses resulting in a total of 4128768 excessive sectors (64% of the total 6422528 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 74.24% This kernel has uncoalesced shared accesses resulting in a total of 3555328 excessive wavefronts (77% of the total 4603904 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 5.294% This kernel has uncoalesced global accesses resulting in a total of 131072 excessive sectors (6% of the total 2359296 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 60.11% This kernel has uncoalesced shared accesses resulting in a total of 1998848 excessive wavefronts (64% of the total 3145728 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 46.76% This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (48% of the total 4325376 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 73.26% This kernel has uncoalesced shared accesses resulting in a total of 3555328 excessive wavefronts (76% of the total 4653056 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.

## Matrix Size 1024x1024x1024

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 801.79 | 800.78 | 809.15 | 797.81 | 808.03 | 797.86 |
| Elapsed Cycles | cycle | 889297 | 635020 | 1087000 | 938693 | 934381 | 3715954 |
| Memory Throughput | % | 89.64 | 86.21 | 86.97 | 85.65 | 89.30 | 94.00 |
| DRAM Throughput | % | 5.14 | 7.21 | 4.26 | 4.83 | 4.94 | 1.21 |
| Duration | ms | 1.11 |  | 1.33 | 1.17 | 1.15 | 4.65 |
| L1/TEX Cache Throughput | % | 91.93 | 88.16 | 88.76 | 87.56 | 90.84 | 94.21 |
| L2 Cache Throughput | % | 64.83 | 47.35 | 33.24 | 37.75 | 84.14 | 17.68 |
| SM Active Cycles | cycle | 863883.81 | 617689.88 | 1057492.14 | 915557.84 | 912240.24 | 3698740.91 |
| Compute (SM) Throughput | % | 47.06 | 49.02 | 41.99 | 52.40 | 47.31 | 94.00 |
| Duration | us |  | 788.83 |  |  |  |  |

Comments:
- **int8_dp4a** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Compute Workload Analysis section.
- **int8_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k16** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k32** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_wmma** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k16** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.

### PM Sampling

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 16.32 | 16.32 | 32.51 | 16.32 | 16.32 | 19.79 |
| Maximum Sampling Interval | us | 1 | 1 | 1 | 1 | 1 | 2 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.46 | 1.35 | 1.29 | 1.94 | 1.46 | 1.09 |
| Executed Ipc Elapsed | inst/cycle | 1.42 | 1.32 | 1.26 | 1.90 | 1.44 | 1.08 |
| Issue Slots Busy | % | 35.59 | 33.04 | 31.61 | 47.49 | 35.90 | 27.08 |
| Issued Ipc Active | inst/cycle | 1.46 | 1.35 | 1.29 | 1.94 | 1.46 | 1.09 |
| SM Busy | % | 35.59 | 33.04 | 31.61 | 47.49 | 35.90 | 36.66 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.96% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 84.28% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (46.7%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (21.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 83.63% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 82.43% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 15.42 | 21.62 | 12.78 | 14.48 | 14.80 | 3.64 |
| Mem Busy | % | 89.64 | 86.21 | 86.97 | 85.65 | 89.30 | 57.96 |
| Max Bandwidth | % | 63.93 | 49.02 | 41.99 | 52.40 | 82.82 | 94.00 |
| L1/TEX Hit Rate | % | 58.72 | 61.82 | 81.05 | 75.76 | 44.59 | 52.20 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 97.82 | 96.41 | 96.99 | 96.77 | 97.30 | 98.32 |
| Mem Pipes Busy | % | 47.06 | 49.02 | 41.99 | 52.40 | 47.31 | 94.00 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 47% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 44.65% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 42.83% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 42.83% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 84.26% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 1.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 43.49% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 43.11% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 44.22% The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 3145728 shared load requests.This results in 4221469 bank conflicts,  which represent 50.16% of the overall 8416558 wavefronts for shared loads. Check the Source Counters section for uncoalesced shared loads.
- **int8_wmma** [OPT]: Est. Speedup: 44.82% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 36.52 | 33.75 | 32.26 | 48.60 | 36.50 | 27.15 |
| Issued Warp Per Scheduler |  | 0.37 | 0.34 | 0.32 | 0.49 | 0.36 | 0.27 |
| No Eligible | % | 63.48 | 66.25 | 67.74 | 51.40 | 63.50 | 72.85 |
| Active Warps Per Scheduler | warp | 11.42 | 7.70 | 9.65 | 9.45 | 9.40 | 11.87 |
| Eligible Warps Per Scheduler | warp | 0.66 | 0.72 | 0.69 | 1.47 | 1.29 | 1.34 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 6.001% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.87 active warps per scheduler, but only an average of 1.34 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 10.7% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.40 active warps per scheduler, but only an average of 1.29 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 14.35% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.45 active warps per scheduler, but only an average of 1.47 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 13.03% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.65 active warps per scheduler, but only an average of 0.69 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 13.79% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.70 active warps per scheduler, but only an average of 0.72 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 10.36% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.42 active warps per scheduler, but only an average of 0.66 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 31.28 | 22.80 | 29.92 | 19.45 | 25.76 | 43.74 |
| Warp Cycles Per Executed Instruction | cycle | 31.29 | 22.81 | 29.92 | 19.45 | 25.76 | 43.74 |
| Avg. Active Threads Per Warp |  | 22.52 | 32 | 23.14 | 25.43 | 22.80 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 20.23 | 28.93 | 21.23 | 23.81 | 20.83 | 31.93 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 6.001% On average, each warp of this workload spends 22.4 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 51.2% of the total average of 43.7 cycles between issuing two instructions.
- **int8_dp4a** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 10.7% On average, each warp of this workload spends 17.4 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 67.4% of the total average of 25.8 cycles between issuing two instructions.
- **int8_ptx_3stage** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 16.51% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.8 threads being active per cycle. This is further reduced to 20.8 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 14.35% On average, each warp of this workload spends 8.7 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 44.5% of the total average of 19.4 cycles between issuing two instructions.
- **int8_ptx_manual_pack** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 13.41% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 25.4 threads being active per cycle. This is further reduced to 23.8 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 13.03% On average, each warp of this workload spends 10.6 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 35.3% of the total average of 29.9 cycles between issuing two instructions.
- **int8_ptx_mma_k16** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 14.13% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.1 threads being active per cycle. This is further reduced to 21.2 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 13.79% On average, each warp of this workload spends 7.5 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 33.1% of the total average of 22.8 cycles between issuing two instructions.
- **int8_ptx_mma_k32** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 10.36% On average, each warp of this workload spends 20.5 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 65.6% of the total average of 31.3 cycles between issuing two instructions.
- **int8_wmma** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 17.3% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.5 threads being active per cycle. This is further reduced to 20.2 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.

### Instruction Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 315250.76 | 208613.52 | 341027.31 | 444416 | 333047.17 | 1003943.72 |
| Executed Instructions | inst | 73138176 | 48398336 | 79118336 | 103104512 | 77266944 | 232914944 |
| Avg. Issued Instructions Per Scheduler | inst | 315347.44 | 208696.19 | 341107.45 | 444502.69 | 333131.31 | 1004078.39 |
| Issued Instructions | inst | 73160607 | 48417517 | 79136929 | 103124624 | 77286464 | 232946187 |

### Launch Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 2048 | 2048 | 2048 | 2048 | 2048 | 16384 |
| Registers Per Thread | register/thread | 39 | 54 | 48 | 48 | 48 | 40 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 102.40 | 65.54 | 65.54 | 102.40 | 32.77 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block |  |  |  |  |  | 640 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 524288 | 524288 | 524288 | 524288 | 524288 | 4194304 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 5.89 | 8.83 | 7.06 | 7.06 | 7.06 | 47.08 |
| Static Shared Memory Per Block | Kbyte/block | 8.19 | 16.38 | 8.19 | 8.19 | 12.29 |  |

### Occupancy

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 4 | 5 | 5 | 5 | 6 |
| Block Limit Shared Mem | block | 7 | 5 | 7 | 7 | 7 | 19 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 32 | 40 | 40 | 40 | 48 |
| Theoretical Occupancy | % | 100 | 66.67 | 83.33 | 83.33 | 83.33 | 100 |
| Achieved Occupancy | % | 95.22 | 64.22 | 80.44 | 78.76 | 78.00 | 98.97 |
| Achieved Active Warps Per SM | warp | 45.71 | 30.82 | 38.61 | 37.80 | 37.44 | 47.51 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 13.79% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 354984 | 355232 | 355074.67 | 353856 | 354178.67 | 352477.33 |
| Total DRAM Elapsed Cycles | cycle | 41400320 | 29550592 | 49973248 | 43951104 | 43030528 | 174091264 |
| Average L1 Active Cycles | cycle | 863883.81 | 617689.88 | 1057492.14 | 915557.84 | 912240.24 | 3698740.91 |
| Total L1 Elapsed Cycles | cycle | 51387322 | 36634982 | 62592260 | 54283280 | 53822238 | 215015034 |
| Average L2 Active Cycles | cycle | 906727.83 | 646369.08 | 1091805.92 | 956946.54 | 942900 | 3801874.46 |
| Total L2 Elapsed Cycles | cycle | 21945792 | 15630312 | 26553888 | 23234520 | 22876128 | 92071008 |
| Average SM Active Cycles | cycle | 863883.81 | 617689.88 | 1057492.14 | 915557.84 | 912240.24 | 3698740.91 |
| Total SM Elapsed Cycles | cycle | 51387322 | 36634982 | 62592260 | 54283280 | 53822238 | 215015034 |
| Average SMSP Active Cycles | cycle | 863601.30 | 618389.19 | 1057337.64 | 914665.85 | 912712.73 | 3698456.34 |
| Total SMSP Elapsed Cycles | cycle | 205549288 | 146539928 | 250369040 | 217133120 | 215288952 | 860060136 |

### Source Counters

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.19 | 0.12 | 0.19 | 0.14 | 0.18 | 0.01 |
| Branch Instructions | inst | 13697024 | 5931008 | 14647296 | 14778368 | 13647872 | 2752512 |
| Branch Efficiency | % | 87.72 | 100 | 87.43 | 87.74 | 87.43 | 100 |
| Avg. Divergent Branches | branches | 4449.10 | 0 | 4519.72 | 4449.10 | 4519.72 | 0 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 48.79% This kernel has uncoalesced global accesses resulting in a total of 16777216 excessive sectors (49% of the total 34078720 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 49.46% This kernel has uncoalesced global accesses resulting in a total of 17301504 excessive sectors (50% of the total 34603008 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 76.46% This kernel has uncoalesced shared accesses resulting in a total of 29360128 excessive wavefronts (78% of the total 37748736 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 49.42% This kernel has uncoalesced global accesses resulting in a total of 17301504 excessive sectors (50% of the total 34603008 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 75.42% This kernel has uncoalesced shared accesses resulting in a total of 28901376 excessive wavefronts (77% of the total 37486592 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 57.87% This kernel has uncoalesced global accesses resulting in a total of 24903680 excessive sectors (59% of the total 42467328 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 75.95% This kernel has uncoalesced shared accesses resulting in a total of 28901376 excessive wavefronts (78% of the total 37289984 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 2.919% This kernel has uncoalesced global accesses resulting in a total of 524288 excessive sectors (3% of the total 17825792 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 63.67% This kernel has uncoalesced shared accesses resulting in a total of 16384000 excessive wavefronts (65% of the total 25165824 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 48.82% This kernel has uncoalesced global accesses resulting in a total of 16777216 excessive sectors (49% of the total 34078720 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 75.17% This kernel has uncoalesced shared accesses resulting in a total of 28901376 excessive wavefronts (77% of the total 37486592 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.

## Matrix Size 2048x2048x2048

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 797.36 | 798.37 | 804.82 | 797.75 | 800.94 | 796.07 |
| Elapsed Cycles | cycle | 6831783 | 4768959 | 7786894 | 7139230 | 8220400 | 29322720 |
| Memory Throughput | % | 92.29 | 89.38 | 89.07 | 88.68 | 95.39 | 95.10 |
| DRAM Throughput | % | 4.89 | 6.96 | 4.32 | 4.69 | 4.10 | 1.14 |
| Duration | ms | 8.55 | 5.96 | 9.61 | 8.93 | 10.22 | 36.75 |
| L1/TEX Cache Throughput | % | 92.69 | 89.78 | 89.42 | 89.01 | 80.41 | 95.14 |
| L2 Cache Throughput | % | 80.81 | 47.50 | 35.75 | 45.37 | 95.39 | 14.53 |
| SM Active Cycles | cycle | 6786233.60 | 4732894.76 | 7706847.91 | 7097133.90 | 8144326.64 | 29243869.10 |
| Compute (SM) Throughput | % | 47.81 | 48.87 | 45.86 | 53.93 | 42.64 | 95.10 |

Comments:
- **int8_dp4a** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Compute Workload Analysis section.
- **int8_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Memory Workload Analysis section.
- **int8_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k16** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k32** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_wmma** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k16** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.

### PM Sampling

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 33.23 | 24.31 | 18.42 | 17.30 | 19.46 | 32.44 |
| Maximum Sampling Interval | us | 2 | 2 | 4 | 4 | 4 | 8 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.43 | 1.25 | 1.39 | 1.94 | 1.29 | 1.08 |
| Executed Ipc Elapsed | inst/cycle | 1.42 | 1.24 | 1.39 | 1.93 | 1.29 | 1.08 |
| Issue Slots Busy | % | 35.48 | 31.05 | 34.69 | 48.30 | 32.16 | 27.07 |
| Issued Ipc Active | inst/cycle | 1.43 | 1.25 | 1.39 | 1.94 | 1.29 | 1.08 |
| SM Busy | % | 35.48 | 31.05 | 34.69 | 48.30 | 32.16 | 37.03 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.96% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 86.25% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (47.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (23.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 87.12% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 83.44% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 14.66 | 20.87 | 12.94 | 14.06 | 12.30 | 3.42 |
| Mem Busy | % | 92.29 | 89.38 | 89.07 | 88.68 | 95.39 | 58.57 |
| Max Bandwidth | % | 77.86 | 48.87 | 45.86 | 53.93 | 91.02 | 95.10 |
| L1/TEX Hit Rate | % | 49.58 | 60.85 | 78.44 | 71.24 | 29.99 | 60.86 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.22 | 98.15 | 98.40 | 98.25 | 99.99 | 99.04 |
| Mem Pipes Busy | % | 47.81 | 48.87 | 45.86 | 53.93 | 42.64 | 95.10 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 47.55% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 39.98% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 44.34% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 44.34% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 86.29% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 1.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 44.54% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 44.69% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 44.97% The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 25165824 shared load requests.This results in 33673823 bank conflicts,  which represent 50.09% of the overall 67230976 wavefronts for shared loads. Check the Source Counters section for uncoalesced shared loads.
- **int8_wmma** [OPT]: Est. Speedup: 46.15% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 35.64 | 31.19 | 34.83 | 48.47 | 31.82 | 27.09 |
| Issued Warp Per Scheduler |  | 0.36 | 0.31 | 0.35 | 0.48 | 0.32 | 0.27 |
| No Eligible | % | 64.36 | 68.81 | 65.17 | 51.53 | 68.18 | 72.91 |
| Active Warps Per Scheduler | warp | 11.77 | 7.91 | 9.90 | 9.78 | 9.51 | 11.96 |
| Eligible Warps Per Scheduler | warp | 0.63 | 0.65 | 0.75 | 1.46 | 1.16 | 1.35 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 4.905% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.96 active warps per scheduler, but only an average of 1.35 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 4.609% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.51 active warps per scheduler, but only an average of 1.16 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 11.32% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.78 active warps per scheduler, but only an average of 1.46 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 10.93% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.90 active warps per scheduler, but only an average of 0.75 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 10.62% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.2 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.91 active warps per scheduler, but only an average of 0.65 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 7.708% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.77 active warps per scheduler, but only an average of 0.63 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 33.02 | 25.37 | 28.43 | 20.17 | 29.90 | 44.15 |
| Warp Cycles Per Executed Instruction | cycle | 33.02 | 25.37 | 28.43 | 20.17 | 29.90 | 44.15 |
| Avg. Active Threads Per Warp |  | 22.03 | 32 | 23.08 | 25.16 | 22.73 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 19.76 | 28.70 | 21.14 | 23.57 | 20.75 | 31.96 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 4.905% On average, each warp of this workload spends 22.7 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 51.4% of the total average of 44.2 cycles between issuing two instructions.
- **int8_dp4a** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 4.609% On average, each warp of this workload spends 22.0 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 73.5% of the total average of 29.9 cycles between issuing two instructions.
- **int8_ptx_3stage** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 14.99% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.7 threads being active per cycle. This is further reduced to 20.7 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 11.32% On average, each warp of this workload spends 9.3 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 46.2% of the total average of 20.2 cycles between issuing two instructions.
- **int8_ptx_manual_pack** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 14.21% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 25.2 threads being active per cycle. This is further reduced to 23.6 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 10.93% On average, each warp of this workload spends 10.0 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 35.0% of the total average of 28.4 cycles between issuing two instructions.
- **int8_ptx_mma_k16** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 15.57% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.1 threads being active per cycle. This is further reduced to 21.1 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 10.62% On average, each warp of this workload spends 9.0 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 35.3% of the total average of 25.4 cycles between issuing two instructions.
- **int8_ptx_mma_k32** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 7.708% On average, each warp of this workload spends 21.8 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 66.1% of the total average of 33.0 cycles between issuing two instructions.
- **int8_wmma** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 18.28% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.0 threads being active per cycle. This is further reduced to 19.8 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.

### Instruction Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 2418052.41 | 1476254.90 | 2683868.69 | 3440922.48 | 2633869.24 | 7920816.55 |
| Executed Instructions | inst | 560988160 | 342491136 | 622657536 | 798294016 | 611057664 | 1837629440 |
| Avg. Issued Instructions Per Scheduler | inst | 2418149.25 | 1476337.65 | 2683948.64 | 3441009.31 | 2633953.53 | 7920951.25 |
| Issued Instructions | inst | 561010627 | 342510334 | 622676085 | 798314161 | 611077219 | 1837660689 |

### Launch Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 8192 | 8192 | 8192 | 8192 | 8192 | 65536 |
| Registers Per Thread | register/thread | 39 | 54 | 48 | 48 | 48 | 40 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 102.40 | 65.54 | 65.54 | 102.40 | 32.77 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block |  |  |  |  |  | 640 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 2097152 | 2097152 | 2097152 | 2097152 | 2097152 | 16777216 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 23.54 | 35.31 | 28.25 | 28.25 | 28.25 | 188.32 |
| Static Shared Memory Per Block | Kbyte/block | 8.19 | 16.38 | 8.19 | 8.19 | 12.29 |  |

### Occupancy

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 4 | 5 | 5 | 5 | 6 |
| Block Limit Shared Mem | block | 7 | 5 | 7 | 7 | 7 | 19 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 32 | 40 | 40 | 40 | 48 |
| Theoretical Occupancy | % | 100 | 66.67 | 83.33 | 83.33 | 83.33 | 100 |
| Achieved Occupancy | % | 98.04 | 65.94 | 82.51 | 81.52 | 81.75 | 99.67 |
| Achieved Active Warps Per SM | warp | 47.06 | 31.65 | 39.60 | 39.13 | 39.24 | 47.84 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 10.62% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 2611349.33 | 2588986.67 | 2591048 | 2615098.67 | 2619690.67 | 2618677.33 |
| Total DRAM Elapsed Cycles | cycle | 320268288 | 223122432 | 360218624 | 334589952 | 383098880 | 1377097728 |
| Average L1 Active Cycles | cycle | 6786233.60 | 4732894.76 | 7706847.91 | 7097133.90 | 8144326.64 | 29243869.10 |
| Total L1 Elapsed Cycles | cycle | 395297356 | 275741850 | 448739432 | 413174428 | 474955706 | 1696995058 |
| Average L2 Active Cycles | cycle | 7043885.38 | 4908174.17 | 7946696.79 | 7363688.21 | 8493262.25 | 29948420.04 |
| Total L2 Elapsed Cycles | cycle | 169311312 | 117969192 | 190935432 | 176914920 | 202890264 | 727830000 |
| Average SM Active Cycles | cycle | 6786233.60 | 4732894.76 | 7706847.91 | 7097133.90 | 8144326.64 | 29243869.10 |
| Total SM Elapsed Cycles | cycle | 395297356 | 275741850 | 448739432 | 413174428 | 474955706 | 1696995058 |
| Average SMSP Active Cycles | cycle | 6785638.56 | 4733379.12 | 7706332.86 | 7099437.25 | 8278897.96 | 29244119.52 |
| Total SMSP Elapsed Cycles | cycle | 1581189424 | 1102967400 | 1794957728 | 1652697712 | 1899822824 | 6787980232 |

### Source Counters

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.19 | 0.14 | 0.19 | 0.15 | 0.18 | 0.01 |
| Branch Instructions | inst | 109314048 | 46792704 | 117309440 | 117833728 | 109117440 | 19398656 |
| Branch Efficiency | % | 87.61 | 100 | 87.46 | 87.62 | 87.46 | 100 |
| Avg. Divergent Branches | branches | 35875.31 | 0 | 36157.79 | 35875.31 | 36157.79 | 0 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 48.99% This kernel has uncoalesced global accesses resulting in a total of 134217728 excessive sectors (50% of the total 270532608 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 50.23% This kernel has uncoalesced global accesses resulting in a total of 136314880 excessive sectors (50% of the total 272629760 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 77.35% This kernel has uncoalesced shared accesses resulting in a total of 234881024 excessive wavefronts (78% of the total 301989888 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 49.95% This kernel has uncoalesced global accesses resulting in a total of 136314880 excessive sectors (50% of the total 272629760 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 77.15% This kernel has uncoalesced shared accesses resulting in a total of 233046016 excessive wavefronts (77% of the total 300941312 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 54.77% This kernel has uncoalesced global accesses resulting in a total of 166723584 excessive sectors (55% of the total 304087040 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 77.34% This kernel has uncoalesced shared accesses resulting in a total of 233046016 excessive wavefronts (78% of the total 300154880 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 1.513% This kernel has uncoalesced global accesses resulting in a total of 2097152 excessive sectors (2% of the total 138412032 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 65.59% This kernel has uncoalesced shared accesses resulting in a total of 132644864 excessive wavefronts (66% of the total 201326592 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 49.54% This kernel has uncoalesced global accesses resulting in a total of 134217728 excessive sectors (50% of the total 270532608 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 77.11% This kernel has uncoalesced shared accesses resulting in a total of 233046016 excessive wavefronts (77% of the total 300941312 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.

## Matrix Size 4096x4096x4096

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 795.53 | 804.17 | 808.89 | 796.20 | 797.92 | 796.21 |
| Elapsed Cycles | cycle | 54493221 | 37385672 | 59474411 | 55428773 | 75213504 | 237319405 |
| Memory Throughput | % | 94.58 | 90.08 | 89.28 | 90.59 | 95.96 | 94.08 |
| DRAM Throughput | % | 2.82 | 4.16 | 2.64 | 2.78 | 2.07 | 0.65 |
| Duration | ms | 68.47 | 46.19 | 72.93 | 69.54 | 93.88 | 296.86 |
| L1/TEX Cache Throughput | % | 92.02 | 90.19 | 89.38 | 90.69 | 81.95 | 94.09 |
| L2 Cache Throughput | % | 94.58 | 47.78 | 36.28 | 62.33 | 95.96 | 17.70 |
| Compute (SM) Throughput | % | 47.30 | 48.38 | 47.60 | 54.92 | 37.18 | 94.08 |
| SM Active Cycles | cycle | 54415000.97 | 37099824.48 | 58918146.47 | 55312771.33 | 74811455.50 |  |

Comments:
- **int8_dp4a** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Compute Workload Analysis section.
- **int8_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L2 in the Memory Workload Analysis section.
- **int8_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k16** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k32** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_wmma** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L2 in the Memory Workload Analysis section.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k16** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.

### PM Sampling

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 29.75 | 20.32 | 31.65 | 30.28 | 20.38 | 31.92 |
| Maximum Sampling Interval | us | 16 | 16 | 16 | 16 | 32 | 64 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.39 | 1.19 | 1.45 | 1.96 | 1.12 | 1.06 |
| Executed Ipc Elapsed | inst/cycle | 1.39 | 1.19 | 1.44 | 1.96 | 1.12 | 1.06 |
| Issue Slots Busy | % | 34.75 | 29.72 | 36.10 | 48.89 | 27.97 | 26.62 |
| Issued Ipc Active | inst/cycle | 1.39 | 1.19 | 1.45 | 1.96 | 1.12 | 1.06 |
| SM Busy | % | 34.75 | 29.72 | 36.10 | 48.89 | 27.97 | 36.61 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 83.24% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 88.19% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (47.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (24.8%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 87.54% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 84.28% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 8.46 | 12.46 | 7.90 | 8.35 | 6.19 | 1.95 |
| Mem Busy | % | 94.58 | 90.08 | 89.28 | 90.59 | 95.96 | 57.94 |
| Max Bandwidth | % | 86.60 | 48.38 | 47.60 | 61.52 | 92.76 | 94.08 |
| L1/TEX Hit Rate | % | 40.19 | 60.33 | 77.42 | 60.59 | 17.26 | 51.70 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.69 | 99.04 | 99.21 | 99.26 | 100.36 | 99.59 |
| Mem Pipes Busy | % | 47.30 | 48.38 | 47.60 | 54.92 | 37.18 | 94.08 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 47.04% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 40.97% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 45.3% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 45.3% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 86.49% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 1.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 44.64% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 45.04% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 45.13% The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 201326592 shared load requests.This results in 268906527 bank conflicts,  which represent 50.04% of the overall 537353115 wavefronts for shared loads. Check the Source Counters section for uncoalesced shared loads.
- **int8_wmma** [OPT]: Est. Speedup: 45.96% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 34.75 | 29.76 | 36.14 | 48.94 | 28.07 | 26.62 |
| Issued Warp Per Scheduler |  | 0.35 | 0.30 | 0.36 | 0.49 | 0.28 | 0.27 |
| No Eligible | % | 65.25 | 70.24 | 63.86 | 51.06 | 71.93 | 73.38 |
| Active Warps Per Scheduler | warp | 11.84 | 7.97 | 9.97 | 9.87 | 9.71 | 11.99 |
| Eligible Warps Per Scheduler | warp | 0.73 | 0.61 | 0.78 | 1.41 | 1.01 | 1.33 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 5.921% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.99 active warps per scheduler, but only an average of 1.33 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 4.041% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.71 active warps per scheduler, but only an average of 1.01 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 9.406% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.87 active warps per scheduler, but only an average of 1.41 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 10.72% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.97 active warps per scheduler, but only an average of 0.78 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 9.924% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.4 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.97 active warps per scheduler, but only an average of 0.61 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 5.416% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.84 active warps per scheduler, but only an average of 0.73 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 34.08 | 26.79 | 27.58 | 20.18 | 34.61 | 45.01 |
| Warp Cycles Per Executed Instruction | cycle | 34.08 | 26.79 | 27.58 | 20.18 | 34.61 | 45.01 |
| Avg. Active Threads Per Warp |  | 21.77 | 32 | 23.05 | 25.02 | 22.70 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 19.51 | 28.56 | 21.09 | 23.44 | 20.71 | 31.98 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 5.921% On average, each warp of this workload spends 23.4 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 51.9% of the total average of 45.0 cycles between issuing two instructions.
- **int8_dp4a** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 4.041% On average, each warp of this workload spends 26.4 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 76.3% of the total average of 34.6 cycles between issuing two instructions.
- **int8_ptx_3stage** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 13.12% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.7 threads being active per cycle. This is further reduced to 20.7 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 9.406% On average, each warp of this workload spends 8.8 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 43.6% of the total average of 20.2 cycles between issuing two instructions.
- **int8_ptx_manual_pack** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 14.69% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 25.0 threads being active per cycle. This is further reduced to 23.4 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 10.72% On average, each warp of this workload spends 9.4 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 34.1% of the total average of 27.6 cycles between issuing two instructions.
- **int8_ptx_mma_k16** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 16.23% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.0 threads being active per cycle. This is further reduced to 21.1 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 9.924% On average, each warp of this workload spends 9.6 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 36.0% of the total average of 26.8 cycles between issuing two instructions.
- **int8_ptx_mma_k32** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 5.416% On average, each warp of this workload spends 19.1 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 56.2% of the total average of 34.1 cycles between issuing two instructions.
- **int8_wmma** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 18.46% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 21.8 threads being active per cycle. This is further reduced to 19.5 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.

### Instruction Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 18928604.69 | 11039426.21 | 21293550.34 | 27069757.79 | 20948921.38 | 62923599.45 |
| Executed Instructions | inst | 4391436288 | 2561146880 | 4940103680 | 6280183808 | 4860149760 | 14598275072 |
| Avg. Issued Instructions Per Scheduler | inst | 18928701.57 | 11039508.99 | 21293630.30 | 27069844.52 | 20949005.44 | 62923734.17 |
| Issued Instructions | inst | 4391458765 | 2561166086 | 4940122230 | 6280203928 | 4860169262 | 14598306328 |

### Launch Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 32768 | 32768 | 32768 | 32768 | 32768 | 262144 |
| Registers Per Thread | register/thread | 39 | 54 | 48 | 48 | 48 | 40 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 102.40 | 65.54 | 65.54 | 102.40 | 32.77 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block |  |  |  |  |  | 640 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 8388608 | 8388608 | 8388608 | 8388608 | 8388608 | 67108864 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 94.16 | 141.24 | 112.99 | 112.99 | 112.99 | 753.29 |
| Static Shared Memory Per Block | Kbyte/block | 8.19 | 16.38 | 8.19 | 8.19 | 12.29 |  |

### Occupancy

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 4 | 5 | 5 | 5 | 6 |
| Block Limit Shared Mem | block | 7 | 5 | 7 | 7 | 7 | 19 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 32 | 40 | 40 | 40 | 48 |
| Theoretical Occupancy | % | 100 | 66.67 | 83.33 | 83.33 | 83.33 | 100 |
| Achieved Occupancy | % | 98.77 | 66.43 | 83.08 | 82.31 | 80.93 | 99.88 |
| Achieved Active Warps Per SM | warp | 47.41 | 31.88 | 39.88 | 39.51 | 38.84 | 47.94 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 9.924% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 12074896 | 11988533.33 | 12004962.67 | 12092413.33 | 12107290.67 | 12057986.67 |
| Total DRAM Elapsed Cycles | cycle | 2565492736 | 1730811904 | 2732504064 | 2605691904 | 3517541376 | 11122804736 |
| Total L1 Elapsed Cycles | cycle | 3159274468 | 2154410518 | 3421099736 | 3211466138 | 4344618554 | 13709218844 |
| Total L2 Elapsed Cycles | cycle | 1355931096 | 916839960 | 1450985448 | 1377284400 | 1859584104 | 5878335984 |
| Total SM Elapsed Cycles | cycle | 3159274468 | 2154410518 | 3421099736 | 3211466138 | 4344618554 | 13709218844 |
| Total SMSP Elapsed Cycles | cycle | 12637097872 | 8617642072 | 13684398944 | 12845864552 | 17378474216 | 54836875376 |
| Average L1 Active Cycles | cycle | 54415000.97 | 37099824.48 | 58918146.47 | 55312771.33 | 74811455.50 |  |
| Average L2 Active Cycles | cycle | 56465759.96 | 38190387.25 | 60361307.29 | 57316526.96 | 77565302.62 |  |
| Average SM Active Cycles | cycle | 54415000.97 | 37099824.48 | 58918146.47 | 55312771.33 | 74811455.50 |  |
| Average SMSP Active Cycles | cycle | 54466821.71 | 37099573.44 | 58918039.12 | 55311976.17 | 74630553.47 |  |

### Source Counters

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.20 | 0.15 | 0.19 | 0.15 | 0.18 | 0.01 |
| Branch Instructions | inst | 873463808 | 371720192 | 938999808 | 941096960 | 872677376 | 144703488 |
| Branch Efficiency | % | 87.55 | 100 | 87.48 | 87.56 | 87.48 | 100 |
| Avg. Divergent Branches | branches | 288132.41 | 0 | 289262.34 | 288132.41 | 289262.34 | 0 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 49.55% This kernel has uncoalesced global accesses resulting in a total of 1073741824 excessive sectors (50% of the total 2155872256 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 50.05% This kernel has uncoalesced global accesses resulting in a total of 1082130432 excessive sectors (50% of the total 2164260864 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 77.68% This kernel has uncoalesced shared accesses resulting in a total of 1879048192 excessive wavefronts (78% of the total 2415919104 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 49.94% This kernel has uncoalesced global accesses resulting in a total of 1082130432 excessive sectors (50% of the total 2164260864 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 77.53% This kernel has uncoalesced shared accesses resulting in a total of 1871708160 excessive wavefronts (78% of the total 2411724800 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 52.48% This kernel has uncoalesced global accesses resulting in a total of 1203765248 excessive sectors (53% of the total 2290089984 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 77.62% This kernel has uncoalesced shared accesses resulting in a total of 1871708160 excessive wavefronts (78% of the total 2408579072 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 0.769% This kernel has uncoalesced global accesses resulting in a total of 8388608 excessive sectors (1% of the total 1090519040 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 66.2% This kernel has uncoalesced shared accesses resulting in a total of 1067450368 excessive wavefronts (66% of the total 1610612736 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 49.78% This kernel has uncoalesced global accesses resulting in a total of 1073741824 excessive sectors (50% of the total 2155872256 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 77.53% This kernel has uncoalesced shared accesses resulting in a total of 1871708160 excessive wavefronts (78% of the total 2411724800 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.

## Matrix Size 8192x8192x8192

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 799.76 | 799.59 | 804.79 | 807.82 | 806.80 | 797.70 |
| Elapsed Cycles | cycle | 689414888 | 390675202 | 471921869 | 502956946 | 667548493 | 1897534980 |
| Memory Throughput | % | 69.38 | 66.95 | 87.84 | 92.80 | 80.89 | 94.40 |
| DRAM Throughput | % | 52.16 | 51.55 | 50.12 | 48.84 | 51.09 | 38.52 |
| Duration | s |  |  |  |  |  | 2.36 |
| L1/TEX Cache Throughput | % | 58.20 | 66.97 | 87.86 | 80.18 | 68.64 | 94.40 |
| L2 Cache Throughput | % | 69.38 | 36.85 | 37.49 | 92.80 | 80.89 | 18.43 |
| Compute (SM) Throughput | % | 29.85 | 36.25 | 47.70 | 48.50 | 33.62 | 94.40 |
| Duration | ms | 858.30 | 487.57 | 582.00 | 617.68 | 820.32 |  |

Comments:
- **int8_dp4a** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing workloads in the Compute Workload Analysis section.
- **int8_ptx_3stage** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L2 in the Memory Workload Analysis section.
- **int8_ptx_manual_pack** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L2 in the Memory Workload Analysis section.
- **int8_ptx_mma_k16** [INF]: This workload is utilizing greater than 80.0% of the available compute or memory performance of the device. To further improve performance, work will likely need to be shifted from the most utilized to another unit. Start by analyzing L1 in the Memory Workload Analysis section.
- **int8_ptx_mma_k32** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.
- **int8_wmma** [OPT]: Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to see where the memory system bottleneck is. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or whether there are values you can (re)compute.

### GPU Speed Of Light Roofline Chart

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_3stage** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_manual_pack** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k16** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_ptx_mma_k32** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.
- **int8_wmma** [INF]: The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0% of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline analysis.

### PM Sampling

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 23.00 | 25.95 | 31.13 | 33.10 | 22.22 | 31.65 |
| Maximum Sampling Interval | us | 256 | 128 | 128 | 128 | 256 | 512 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 0.87 | 0.87 | 1.45 | 1.72 | 1.01 | 1.07 |
| Executed Ipc Elapsed | inst/cycle | 0.87 | 0.87 | 1.45 | 1.72 | 1.01 | 1.07 |
| Issue Slots Busy | % | 21.82 | 21.86 | 36.22 | 43.04 | 25.25 | 26.63 |
| Issued Ipc Active | inst/cycle | 0.87 | 0.87 | 1.45 | 1.72 | 1.01 | 1.07 |
| SM Busy | % | 21.82 | 21.86 | 36.22 | 43.04 | 25.25 | 36.72 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 83.23% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 89.41% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (42.1%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (24.8%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 90.5% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 90.29% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 156.34 | 154.51 | 150.24 | 146.39 | 153.14 | 115.48 |
| Mem Busy | % | 69.38 | 66.95 | 87.84 | 92.80 | 80.89 | 58.13 |
| Max Bandwidth | % | 60.73 | 51.55 | 50.12 | 79.10 | 79.17 | 94.40 |
| L1/TEX Hit Rate | % | 33.56 | 61.17 | 75.90 | 37.22 | 23.68 | 49.89 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 81.86 | 65.84 | 68.75 | 87.87 | 84.46 | 50.12 |
| Mem Pipes Busy | % | 29.85 | 36.25 | 47.70 | 48.50 | 33.62 | 94.40 |

### Memory Workload Analysis Tables

_No metric table in this section for this matrix size._

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 47.2% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 34.32% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 40.08% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 40.08% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 85.1% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 1.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 43.92% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.48% The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.49% The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 1610612736 shared load requests.This results in 2148946153 bank conflicts,  which represent 50.02% of the overall 4296592062 wavefronts for shared loads. Check the Source Counters section for uncoalesced shared loads.
- **int8_wmma** [OPT]: Est. Speedup: 29.09% The memory access pattern for global loads from L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global loads.

### Scheduler Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 21.73 | 21.93 | 36.23 | 34.34 | 24.86 | 26.63 |
| Issued Warp Per Scheduler |  | 0.22 | 0.22 | 0.36 | 0.34 | 0.25 | 0.27 |
| No Eligible | % | 78.27 | 78.07 | 63.77 | 65.66 | 75.14 | 73.37 |
| Active Warps Per Scheduler | warp | 11.82 | 7.99 | 9.98 | 7.26 | 9.70 | 11.99 |
| Eligible Warps Per Scheduler | warp | 0.53 | 0.34 | 0.69 | 0.73 | 0.89 | 1.31 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 5.604% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.99 active warps per scheduler, but only an average of 1.31 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 19.11% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.70 active warps per scheduler, but only an average of 0.89 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 7.203% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.26 active warps per scheduler, but only an average of 0.73 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, reduce the time the active warps are stalled by inspecting the top stall reasons on the Warp State Statistics and Source Counters sections.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 12.16% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.98 active warps per scheduler, but only an average of 0.69 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 33.05% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.99 active warps per scheduler, but only an average of 0.34 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 30.62% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.82 active warps per scheduler, but only an average of 0.53 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 54.40 | 36.44 | 27.55 | 21.13 | 39.00 | 45.04 |
| Warp Cycles Per Executed Instruction | cycle | 54.40 | 36.44 | 27.55 | 21.13 | 39.00 | 45.04 |
| Avg. Active Threads Per Warp |  | 21.64 | 32 | 23.03 | 24.94 | 22.68 | 32 |
| Avg. Not Predicated Off Threads Per Warp |  | 19.38 | 28.48 | 21.07 | 23.37 | 20.69 | 31.99 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 5.604% On average, each warp of this workload spends 23.0 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 51.2% of the total average of 45.0 cycles between issuing two instructions.
- **int8_dp4a** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 19.11% On average, each warp of this workload spends 28.9 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 74.0% of the total average of 39.0 cycles between issuing two instructions.
- **int8_ptx_3stage** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 11.88% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 22.7 threads being active per cycle. This is further reduced to 20.7 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 7.203% On average, each warp of this workload spends 17.7 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 83.9% of the total average of 21.1 cycles between issuing two instructions.
- **int8_ptx_manual_pack** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 13.08% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 24.9 threads being active per cycle. This is further reduced to 23.4 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 12.16% On average, each warp of this workload spends 13.0 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 47.3% of the total average of 27.5 cycles between issuing two instructions.
- **int8_ptx_mma_k16** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 16.3% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 23.0 threads being active per cycle. This is further reduced to 21.1 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.05% On average, each warp of this workload spends 18.7 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 51.4% of the total average of 36.4 cycles between issuing two instructions.
- **int8_ptx_mma_k32** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 30.62% On average, each warp of this workload spends 27.5 cycles being stalled waiting for a scoreboard dependency on a L1TEX (local, global, surface, texture) operation. Find the instruction producing the data being waited upon to identify the culprit. To reduce the number of cycles waiting on L1TEX data accesses verify the memory access patterns are optimal for the target architecture, attempt to increase cache hit rates by increasing data locality (coalescing), or by changing the cache configuration. Consider moving frequently used data to shared memory. This stall type represents about 50.6% of the total average of 54.4 cycles between issuing two instructions.
- **int8_wmma** [OPT]: Est. Speedup: 30.62% On average, each warp of this workload spends 19.2 cycles being stalled waiting for the MIO (memory input/output) instruction queue to be not full. This stall reason is high in cases of extreme utilization of the MIO pipelines, which include special math instructions, dynamic branches, as well as shared memory instructions. When caused by shared memory accesses, trying to use fewer but wider loads can reduce pipeline pressure. This stall type represents about 35.3% of the total average of 54.4 cycles between issuing two instructions.
- **int8_wmma** [INF]: Check the Warp Stall Sampling (All Samples) table for the top stall locations in your source based on sampling data. The Profiling Guide (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-reference) provides more details on each stall reason.
- **int8_wmma** [OPT]: Est. Speedup: 11.77% Instructions are executed in warps, which are groups of 32 threads. Optimal instruction throughput is achieved if all 32 threads of a warp execute the same instruction. The chosen launch configuration, early thread completion, and divergent flow control can significantly lower the number of active threads in a warp per cycle. This workload achieves an average of 21.6 threads being active per cycle. This is further reduced to 19.4 threads per warp due to predication. The compiler may use predication to avoid an actual branch. Instead, all instructions are scheduled, but a per-thread condition code or predicate controls which threads execute the instructions. Try to avoid different execution paths within a warp when possible.

### Instruction Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Avg. Issued Instructions Per Scheduler | inst |  | 85233040.44 |  |  |  | 501617198 |
| Executed Instructions | inst | 34745614336 | 19774046208 | 39356203008 | 49816797184 | 38767951872 |  |
| Issued Instructions | inst | 34745636793 | 19774065381 | 39356221603 | 49816817330 | 38767971417 |  |
| Avg. Executed Instructions Per Scheduler | inst |  | 85232957.79 |  |  |  |  |

### Launch Statistics

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 131072 | 131072 | 131072 | 131072 | 131072 | 1048576 |
| Registers Per Thread | register/thread | 39 | 54 | 48 | 48 | 48 | 40 |
| Shared Memory Configuration Size | Kbyte | 65.54 | 102.40 | 65.54 | 65.54 | 102.40 | 32.77 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block |  |  |  |  |  | 640 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 33554432 | 33554432 | 33554432 | 33554432 | 33554432 | 268435456 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 376.64 | 564.97 | 451.97 | 451.97 | 451.97 | 3013.15 |
| Static Shared Memory Per Block | Kbyte/block | 8.19 | 16.38 | 8.19 | 8.19 | 12.29 |  |

### Occupancy

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 4 | 5 | 5 | 5 | 6 |
| Block Limit Shared Mem | block | 7 | 5 | 7 | 7 | 7 | 19 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 32 | 40 | 40 | 40 | 48 |
| Theoretical Occupancy | % | 100 | 66.67 | 83.33 | 83.33 | 83.33 | 100 |
| Achieved Occupancy | % | 98.66 | 66.40 | 82.92 | 97.28 | 82.07 | 99.95 |
| Achieved Active Warps Per SM | warp | 47.36 | 31.87 | 39.80 | 46.69 | 39.40 | 47.98 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.05% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Total DRAM Elapsed Cycles | cycle | 32159330304 | 18268452864 | 21806853120 | 23143433216 | 30736189440 | 88481901568 |
| Total L1 Elapsed Cycles | cycle | 39811947716 | 22610726802 | 27164187152 | 28936962628 | 38381994908 | 109252390212 |
| Total L2 Elapsed Cycles | cycle | 17011646232 | 9673158192 | 11559239040 | 12291414000 | 16311382704 | 46763238360 |
| Total SM Elapsed Cycles | cycle | 39811947716 | 22610726802 | 27164187152 | 28936962628 | 38381994908 | 109252390212 |
| Total SMSP Elapsed Cycles | cycle |  | 90442907208 | 108656748608 | 115747850512 | 153527979632 | 437009560848 |
| Average L1 Active Cycles | cycle |  | 389738480.03 | 468226612.12 | 498798218.09 | 661621010.41 |  |
| Average L2 Active Cycles | cycle |  | 403437887.96 | 479847893.21 | 657125464 | 696935813.08 |  |
| Average SM Active Cycles | cycle |  | 389738480.03 | 468226612.12 | 498798218.09 | 661621010.41 |  |
| Average SMSP Active Cycles | cycle |  | 388673723.45 | 468242607.74 | 625305017.12 | 672183198.10 |  |
| Average DRAM Active Cycles | cycle | 2795572312 |  |  |  |  |  |

### Source Counters

| Metric Name | Metric Unit | int8_wmma | int8_ptx_mma_k32 | int8_ptx_mma_k16 | int8_ptx_manual_pack | int8_ptx_3stage | int8_dp4a |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.20 | 0.15 | 0.19 | 0.15 | 0.18 | 0.01 |
| Branch Instructions | inst | 6983516160 | 2963275776 | 7514095616 | 7522484224 | 6980370432 | 1115684864 |
| Branch Efficiency | % | 87.53 | 100 | 87.49 | 87.53 | 87.49 | 100 |
| Avg. Divergent Branches | branches | 2309579.03 | 0 | 2314098.76 | 2309579.03 | 2314098.76 | 0 |

Comments:
- **int8_dp4a** [OPT]: Est. Speedup: 49.85% This kernel has uncoalesced global accesses resulting in a total of 8589934592 excessive sectors (50% of the total 17213423616 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 51.27% This kernel has uncoalesced global accesses resulting in a total of 8623489024 excessive sectors (50% of the total 17246978048 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_3stage** [OPT]: Est. Speedup: 77.76% This kernel has uncoalesced shared accesses resulting in a total of 15032385536 excessive wavefronts (78% of the total 19327352832 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 64.15% This kernel has uncoalesced global accesses resulting in a total of 8623489024 excessive sectors (50% of the total 17246978048 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 77.68% This kernel has uncoalesced shared accesses resulting in a total of 15003025408 excessive wavefronts (78% of the total 19310575616 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 51.13% This kernel has uncoalesced global accesses resulting in a total of 9110028288 excessive sectors (51% of the total 17750294528 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 77.72% This kernel has uncoalesced shared accesses resulting in a total of 15003025408 excessive wavefronts (78% of the total 19297992704 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 0.388% This kernel has uncoalesced global accesses resulting in a total of 33554432 excessive sectors (0% of the total 8657043456 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 66.45% This kernel has uncoalesced shared accesses resulting in a total of 8564768768 excessive wavefronts (66% of the total 12884901888 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 49.91% This kernel has uncoalesced global accesses resulting in a total of 8589934592 excessive sectors (50% of the total 17213423616 sectors). Check the L2 Theoretical Sectors Global Excessive table for the primary source locations. The CUDA Programming Guide (https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html#device-memory-accesses) has additional information on reducing uncoalesced device memory accesses.
- **int8_wmma** [OPT]: Est. Speedup: 77.68% This kernel has uncoalesced shared accesses resulting in a total of 15003025408 excessive wavefronts (78% of the total 19310575616 wavefronts). Check the L1 Wavefronts Shared Excessive table for the primary source locations. The CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#shared-memory-in-matrix-multiplication-c -ab) has an example on optimizing shared memory accesses.

