# NCU TXT Profiles Comparison (run2)

Combined Nsight Compute high-level sections for six int8 kernels and five matrix sizes.
Metric names, metric units, metric values, and comments are copied from source txt reports.

## Matrix Size 512x512x512

### GPU Speed Of Light Throughput

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 801.76 | 803.02 | 805.05 | 804.14 | 798.45 | 795.87 |
| Elapsed Cycles | cycle | 474808 | 122639 | 129159 | 165614 | 93542 | 121418 |
| Memory Throughput | % | 92.63 | 86.70 | 80.28 | 83.03 | 75.98 | 83.54 |
| DRAM Throughput | % | 2.09 | 8.19 | 7.76 | 6.04 | 10.65 | 8.14 |
| Duration | us | 588.80 | 151.87 | 159.55 | 204.54 | 116.58 | 152 |
| L1/TEX Cache Throughput | % | 93.73 | 90.60 | 84.02 | 86.37 | 80.33 | 87.13 |
| L2 Cache Throughput | % | 17.30 | 63.67 | 30.28 | 24.38 | 40.17 | 33.83 |
| SM Active Cycles | cycle | 466540.59 | 116686.60 | 122713.38 | 158121.90 | 88041.86 | 115989.07 |
| Compute (SM) Throughput | % | 92.63 | 45.52 | 49.71 | 35.90 | 46.74 | 45.07 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 16.32 | 16.25 | 16.25 | 16.25 | 16.25 | 16.25 |
| Maximum Sampling Interval | us | 1 | 1 | 1 | 1 | 1 | 1 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.11 | 1.46 | 1.93 | 1.11 | 1.46 | 1.47 |
| Executed Ipc Elapsed | inst/cycle | 1.09 | 1.40 | 1.84 | 1.07 | 1.38 | 1.41 |
| Issue Slots Busy | % | 27.35 | 34.99 | 46.10 | 26.81 | 34.57 | 35.34 |
| Issued Ipc Active | inst/cycle | 1.11 | 1.46 | 1.93 | 1.12 | 1.46 | 1.47 |
| SM Busy | % | 36.22 | 34.99 | 46.10 | 26.81 | 34.57 | 35.34 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.83% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 83.99% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (45.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 81.21% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_mma_k32** [INF]: ALU is the highest-utilized pipeline (21.1%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_wmma** [OPT]: Est. Local Speedup: 80.91% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 6.27 | 24.54 | 23.26 | 18.09 | 31.88 | 24.40 |
| Mem Busy | % | 57.21 | 86.70 | 80.28 | 83.03 | 75.98 | 83.54 |
| Max Bandwidth | % | 92.63 | 45.52 | 49.71 | 35.90 | 46.74 | 45.07 |
| L1/TEX Hit Rate | % | 52.28 | 58.74 | 79.98 | 85.98 | 63.64 | 77.60 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 96.09 | 97.60 | 93.58 | 92.89 | 93.40 | 95.53 |
| Mem Pipes Busy | % | 92.63 | 45.52 | 49.71 | 35.90 | 46.74 | 45.07 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 27.68 | 36.69 | 48.41 | 27.89 | 36.60 | 37.09 |
| Issued Warp Per Scheduler |  | 0.28 | 0.37 | 0.48 | 0.28 | 0.37 | 0.37 |
| No Eligible | % | 72.32 | 63.31 | 51.59 | 72.11 | 63.40 | 62.91 |
| Active Warps Per Scheduler | warp | 11.57 | 8.06 | 8.29 | 8.86 | 6.93 | 9.68 |
| Eligible Warps Per Scheduler | warp | 1.31 | 1.12 | 1.39 | 0.59 | 0.85 | 0.99 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 7.367% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.57 active warps per scheduler, but only an average of 1.31 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 13.3% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.06 active warps per scheduler, but only an average of 1.12 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 19.72% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.29 active warps per scheduler, but only an average of 1.39 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 16.97% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 8.86 active warps per scheduler, but only an average of 0.59 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 24.02% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 6.93 active warps per scheduler, but only an average of 0.85 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 16.46% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.68 active warps per scheduler, but only an average of 0.99 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 41.80 | 21.97 | 17.12 | 31.75 | 18.95 | 26.11 |
| Warp Cycles Per Executed Instruction | cycle | 41.84 | 22.01 | 17.15 | 31.81 | 19.00 | 26.16 |
| Avg. Active Threads Per Warp |  | 32 | 22.93 | 25.93 | 23.26 | 32 | 23.38 |
| Avg. Not Predicated Off Threads Per Warp |  | 31.86 | 20.99 | 24.26 | 21.41 | 29.27 | 21.07 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 128953.38 | 42584.28 | 59127.17 | 44014.34 | 32097.10 | 42654.90 |
| Executed Instructions | inst | 29917184 | 9879552 | 13717504 | 10211328 | 7446528 | 9895936 |
| Avg. Issued Instructions Per Scheduler | inst | 129087.65 | 42668.74 | 59213.79 | 44094.47 | 32179.87 | 42751.85 |
| Issued Instructions | inst | 29948334 | 9899147 | 13737600 | 10229918 | 7465730 | 9918430 |

### Launch Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 4096 | 512 | 512 | 512 | 512 | 512 |
| Registers Per Thread | register/thread | 40 | 48 | 48 | 48 | 54 | 39 |
| Shared Memory Configuration Size | Kbyte | 32.77 | 102.40 | 65.54 | 65.54 | 102.40 | 65.54 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block | 640 |  |  |  |  |  |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 1048576 | 131072 | 131072 | 131072 | 131072 | 131072 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 11.77 | 1.77 | 1.77 | 1.77 | 2.21 | 1.47 |
| Static Shared Memory Per Block | Kbyte/block |  | 12.29 | 8.19 | 8.19 | 16.38 | 8.19 |

Comments:
- **int8_ptx_3stage** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_mma_k16** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 222 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.33% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 2 full waves and a partial wave of 48 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 33.3% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.
- **int8_wmma** [OPT]: Est. Speedup: 50% A wave of thread blocks is defined as the maximum number of blocks that can be executed in parallel on the target GPU. The number of blocks in a wave depends on the number of multiprocessors and the theoretical occupancy of the kernel. This kernel launch results in 1 full waves and a partial wave of 164 thread blocks. Under the assumption of a uniform execution duration of all thread blocks, this partial wave may account for up to 50.0% of the total runtime of this kernel. Try launching a grid with no partial wave. The overall impact of this tail effect also lessens with the number of full waves executed for a grid. See the Hardware Model (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#metrics-hw-model) description for more details on launch configurations.

### Occupancy

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 5 | 5 | 4 | 6 |
| Block Limit Shared Mem | block | 19 | 7 | 7 | 7 | 5 | 7 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 40 | 40 | 32 | 48 |
| Theoretical Occupancy | % | 100 | 83.33 | 83.33 | 83.33 | 66.67 | 100 |
| Achieved Occupancy | % | 96.43 | 66.94 | 68.91 | 73.77 | 57.77 | 80.22 |
| Achieved Active Warps Per SM | warp | 46.28 | 32.13 | 33.08 | 35.41 | 27.73 | 38.50 |

Comments:
- **int8_ptx_3stage** [OPT]: Est. Speedup: 13.3% The difference between calculated theoretical (83.3%) and measured achieved occupancy (66.9%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.
- **int8_ptx_manual_pack** [OPT]: Est. Speedup: 17.31% The difference between calculated theoretical (83.3%) and measured achieved occupancy (68.9%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 24.02% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.
- **int8_wmma** [OPT]: Est. Speedup: 16.46% The difference between calculated theoretical (100.0%) and measured achieved occupancy (80.2%) can be the result of warp scheduling overheads or workload imbalances during the kernel execution. Load imbalances can occur between warps within a block as well as across blocks of the same kernel. See the CUDA Best Practices Guide (https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#occupancy) for more details on optimizing occupancy.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 76952 | 77642.67 | 77317.33 | 77072 | 77416 | 77269.33 |
| Total DRAM Elapsed Cycles | cycle | 22056960 | 5687296 | 5975040 | 7657472 | 4363264 | 5692416 |
| Average L1 Active Cycles | cycle | 466540.59 | 116686.60 | 122713.38 | 158121.90 | 88041.86 | 115989.07 |
| Total L1 Elapsed Cycles | cycle | 27379366 | 7072818 | 7449468 | 9539160 | 5398376 | 7016324 |
| Average L2 Active Cycles | cycle | 441688.58 | 122199.29 | 127685.96 | 156559.12 | 91590.04 | 120888.08 |
| Total L2 Elapsed Cycles | cycle | 11674368 | 3015024 | 3176040 | 4053528 | 2306832 | 3008040 |
| Average SM Active Cycles | cycle | 466540.59 | 116686.60 | 122713.38 | 158121.90 | 88041.86 | 115989.07 |
| Total SM Elapsed Cycles | cycle | 27379366 | 7072818 | 7449468 | 9539160 | 5398376 | 7016324 |
| Average SMSP Active Cycles | cycle | 466300.07 | 116284.22 | 122309.28 | 158091.97 | 87925.10 | 115273.86 |
| Total SMSP Elapsed Cycles | cycle | 109517464 | 28291272 | 29797872 | 38156640 | 21593504 | 28065296 |

### Source Counters

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.01 | 0.17 | 0.14 | 0.18 | 0.10 | 0.17 |
| Branch Instructions | inst | 425984 | 1708032 | 1859584 | 1826816 | 761856 | 1720320 |
| Branch Efficiency | % | 100 | 87.35 | 87.98 | 87.35 | 100 | 87.94 |
| Avg. Divergent Branches | branches | 0 | 564.97 | 547.31 | 564.97 | 0 | 547.31 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 797.86 | 808.03 | 797.81 | 809.15 | 800.78 | 801.79 |
| Elapsed Cycles | cycle | 3715954 | 934381 | 938693 | 1087000 | 635020 | 889297 |
| Memory Throughput | % | 94.00 | 89.30 | 85.65 | 86.97 | 86.21 | 89.64 |
| DRAM Throughput | % | 1.21 | 4.94 | 4.83 | 4.26 | 7.21 | 5.14 |
| Duration | ms | 4.65 | 1.15 | 1.17 | 1.33 |  | 1.11 |
| L1/TEX Cache Throughput | % | 94.21 | 90.84 | 87.56 | 88.76 | 88.16 | 91.93 |
| L2 Cache Throughput | % | 17.68 | 84.14 | 37.75 | 33.24 | 47.35 | 64.83 |
| SM Active Cycles | cycle | 3698740.91 | 912240.24 | 915557.84 | 1057492.14 | 617689.88 | 863883.81 |
| Compute (SM) Throughput | % | 94.00 | 47.31 | 52.40 | 41.99 | 49.02 | 47.06 |
| Duration | us |  |  |  |  | 788.83 |  |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 19.79 | 16.32 | 16.32 | 32.51 | 16.32 | 16.32 |
| Maximum Sampling Interval | us | 2 | 1 | 1 | 1 | 1 | 1 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.09 | 1.46 | 1.94 | 1.29 | 1.35 | 1.46 |
| Executed Ipc Elapsed | inst/cycle | 1.08 | 1.44 | 1.90 | 1.26 | 1.32 | 1.42 |
| Issue Slots Busy | % | 27.08 | 35.90 | 47.49 | 31.61 | 33.04 | 35.59 |
| Issued Ipc Active | inst/cycle | 1.09 | 1.46 | 1.94 | 1.29 | 1.35 | 1.46 |
| SM Busy | % | 36.66 | 35.90 | 47.49 | 31.61 | 33.04 | 35.59 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.96% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 84.28% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (46.7%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (21.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 83.63% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 82.43% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 3.64 | 14.80 | 14.48 | 12.78 | 21.62 | 15.42 |
| Mem Busy | % | 57.96 | 89.30 | 85.65 | 86.97 | 86.21 | 89.64 |
| Max Bandwidth | % | 94.00 | 82.82 | 52.40 | 41.99 | 49.02 | 63.93 |
| L1/TEX Hit Rate | % | 52.20 | 44.59 | 75.76 | 81.05 | 61.82 | 58.72 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 98.32 | 97.30 | 96.77 | 96.99 | 96.41 | 97.82 |
| Mem Pipes Busy | % | 94.00 | 47.31 | 52.40 | 41.99 | 49.02 | 47.06 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 27.15 | 36.50 | 48.60 | 32.26 | 33.75 | 36.52 |
| Issued Warp Per Scheduler |  | 0.27 | 0.36 | 0.49 | 0.32 | 0.34 | 0.37 |
| No Eligible | % | 72.85 | 63.50 | 51.40 | 67.74 | 66.25 | 63.48 |
| Active Warps Per Scheduler | warp | 11.87 | 9.40 | 9.45 | 9.65 | 7.70 | 11.42 |
| Eligible Warps Per Scheduler | warp | 1.34 | 1.29 | 1.47 | 0.69 | 0.72 | 0.66 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 6.001% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.87 active warps per scheduler, but only an average of 1.34 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 10.7% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.40 active warps per scheduler, but only an average of 1.29 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 14.35% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.45 active warps per scheduler, but only an average of 1.47 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 13.03% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.65 active warps per scheduler, but only an average of 0.69 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 13.79% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.70 active warps per scheduler, but only an average of 0.72 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 10.36% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.42 active warps per scheduler, but only an average of 0.66 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 43.74 | 25.76 | 19.45 | 29.92 | 22.80 | 31.28 |
| Warp Cycles Per Executed Instruction | cycle | 43.74 | 25.76 | 19.45 | 29.92 | 22.81 | 31.29 |
| Avg. Active Threads Per Warp |  | 32 | 22.80 | 25.43 | 23.14 | 32 | 22.52 |
| Avg. Not Predicated Off Threads Per Warp |  | 31.93 | 20.83 | 23.81 | 21.23 | 28.93 | 20.23 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 1003943.72 | 333047.17 | 444416 | 341027.31 | 208613.52 | 315250.76 |
| Executed Instructions | inst | 232914944 | 77266944 | 103104512 | 79118336 | 48398336 | 73138176 |
| Avg. Issued Instructions Per Scheduler | inst | 1004078.39 | 333131.31 | 444502.69 | 341107.45 | 208696.19 | 315347.44 |
| Issued Instructions | inst | 232946187 | 77286464 | 103124624 | 79136929 | 48417517 | 73160607 |

### Launch Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 16384 | 2048 | 2048 | 2048 | 2048 | 2048 |
| Registers Per Thread | register/thread | 40 | 48 | 48 | 48 | 54 | 39 |
| Shared Memory Configuration Size | Kbyte | 32.77 | 102.40 | 65.54 | 65.54 | 102.40 | 65.54 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block | 640 |  |  |  |  |  |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 4194304 | 524288 | 524288 | 524288 | 524288 | 524288 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 47.08 | 7.06 | 7.06 | 7.06 | 8.83 | 5.89 |
| Static Shared Memory Per Block | Kbyte/block |  | 12.29 | 8.19 | 8.19 | 16.38 | 8.19 |

### Occupancy

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 5 | 5 | 4 | 6 |
| Block Limit Shared Mem | block | 19 | 7 | 7 | 7 | 5 | 7 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 40 | 40 | 32 | 48 |
| Theoretical Occupancy | % | 100 | 83.33 | 83.33 | 83.33 | 66.67 | 100 |
| Achieved Occupancy | % | 98.97 | 78.00 | 78.76 | 80.44 | 64.22 | 95.22 |
| Achieved Active Warps Per SM | warp | 47.51 | 37.44 | 37.80 | 38.61 | 30.82 | 45.71 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 13.79% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 352477.33 | 354178.67 | 353856 | 355074.67 | 355232 | 354984 |
| Total DRAM Elapsed Cycles | cycle | 174091264 | 43030528 | 43951104 | 49973248 | 29550592 | 41400320 |
| Average L1 Active Cycles | cycle | 3698740.91 | 912240.24 | 915557.84 | 1057492.14 | 617689.88 | 863883.81 |
| Total L1 Elapsed Cycles | cycle | 215015034 | 53822238 | 54283280 | 62592260 | 36634982 | 51387322 |
| Average L2 Active Cycles | cycle | 3801874.46 | 942900 | 956946.54 | 1091805.92 | 646369.08 | 906727.83 |
| Total L2 Elapsed Cycles | cycle | 92071008 | 22876128 | 23234520 | 26553888 | 15630312 | 21945792 |
| Average SM Active Cycles | cycle | 3698740.91 | 912240.24 | 915557.84 | 1057492.14 | 617689.88 | 863883.81 |
| Total SM Elapsed Cycles | cycle | 215015034 | 53822238 | 54283280 | 62592260 | 36634982 | 51387322 |
| Average SMSP Active Cycles | cycle | 3698456.34 | 912712.73 | 914665.85 | 1057337.64 | 618389.19 | 863601.30 |
| Total SMSP Elapsed Cycles | cycle | 860060136 | 215288952 | 217133120 | 250369040 | 146539928 | 205549288 |

### Source Counters

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.01 | 0.18 | 0.14 | 0.19 | 0.12 | 0.19 |
| Branch Instructions | inst | 2752512 | 13647872 | 14778368 | 14647296 | 5931008 | 13697024 |
| Branch Efficiency | % | 100 | 87.43 | 87.74 | 87.43 | 100 | 87.72 |
| Avg. Divergent Branches | branches | 0 | 4519.72 | 4449.10 | 4519.72 | 0 | 4449.10 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 796.07 | 800.94 | 797.75 | 804.82 | 798.37 | 797.36 |
| Elapsed Cycles | cycle | 29322720 | 8220400 | 7139230 | 7786894 | 4768959 | 6831783 |
| Memory Throughput | % | 95.10 | 95.39 | 88.68 | 89.07 | 89.38 | 92.29 |
| DRAM Throughput | % | 1.14 | 4.10 | 4.69 | 4.32 | 6.96 | 4.89 |
| Duration | ms | 36.75 | 10.22 | 8.93 | 9.61 | 5.96 | 8.55 |
| L1/TEX Cache Throughput | % | 95.14 | 80.41 | 89.01 | 89.42 | 89.78 | 92.69 |
| L2 Cache Throughput | % | 14.53 | 95.39 | 45.37 | 35.75 | 47.50 | 80.81 |
| SM Active Cycles | cycle | 29243869.10 | 8144326.64 | 7097133.90 | 7706847.91 | 4732894.76 | 6786233.60 |
| Compute (SM) Throughput | % | 95.10 | 42.64 | 53.93 | 45.86 | 48.87 | 47.81 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 32.44 | 19.46 | 17.30 | 18.42 | 24.31 | 33.23 |
| Maximum Sampling Interval | us | 8 | 4 | 4 | 4 | 2 | 2 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.08 | 1.29 | 1.94 | 1.39 | 1.25 | 1.43 |
| Executed Ipc Elapsed | inst/cycle | 1.08 | 1.29 | 1.93 | 1.39 | 1.24 | 1.42 |
| Issue Slots Busy | % | 27.07 | 32.16 | 48.30 | 34.69 | 31.05 | 35.48 |
| Issued Ipc Active | inst/cycle | 1.08 | 1.29 | 1.94 | 1.39 | 1.25 | 1.43 |
| SM Busy | % | 37.03 | 32.16 | 48.30 | 34.69 | 31.05 | 35.48 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 82.96% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 86.25% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (47.4%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (23.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 87.12% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 83.44% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 3.42 | 12.30 | 14.06 | 12.94 | 20.87 | 14.66 |
| Mem Busy | % | 58.57 | 95.39 | 88.68 | 89.07 | 89.38 | 92.29 |
| Max Bandwidth | % | 95.10 | 91.02 | 53.93 | 45.86 | 48.87 | 77.86 |
| L1/TEX Hit Rate | % | 60.86 | 29.99 | 71.24 | 78.44 | 60.85 | 49.58 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.04 | 99.99 | 98.25 | 98.40 | 98.15 | 99.22 |
| Mem Pipes Busy | % | 95.10 | 42.64 | 53.93 | 45.86 | 48.87 | 47.81 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 27.09 | 31.82 | 48.47 | 34.83 | 31.19 | 35.64 |
| Issued Warp Per Scheduler |  | 0.27 | 0.32 | 0.48 | 0.35 | 0.31 | 0.36 |
| No Eligible | % | 72.91 | 68.18 | 51.53 | 65.17 | 68.81 | 64.36 |
| Active Warps Per Scheduler | warp | 11.96 | 9.51 | 9.78 | 9.90 | 7.91 | 11.77 |
| Eligible Warps Per Scheduler | warp | 1.35 | 1.16 | 1.46 | 0.75 | 0.65 | 0.63 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 4.905% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.7 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.96 active warps per scheduler, but only an average of 1.35 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 4.609% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.51 active warps per scheduler, but only an average of 1.16 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 11.32% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.1 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.78 active warps per scheduler, but only an average of 1.46 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 10.93% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.90 active warps per scheduler, but only an average of 0.75 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 10.62% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.2 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.91 active warps per scheduler, but only an average of 0.65 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 7.708% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.77 active warps per scheduler, but only an average of 0.63 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 44.15 | 29.90 | 20.17 | 28.43 | 25.37 | 33.02 |
| Warp Cycles Per Executed Instruction | cycle | 44.15 | 29.90 | 20.17 | 28.43 | 25.37 | 33.02 |
| Avg. Active Threads Per Warp |  | 32 | 22.73 | 25.16 | 23.08 | 32 | 22.03 |
| Avg. Not Predicated Off Threads Per Warp |  | 31.96 | 20.75 | 23.57 | 21.14 | 28.70 | 19.76 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 7920816.55 | 2633869.24 | 3440922.48 | 2683868.69 | 1476254.90 | 2418052.41 |
| Executed Instructions | inst | 1837629440 | 611057664 | 798294016 | 622657536 | 342491136 | 560988160 |
| Avg. Issued Instructions Per Scheduler | inst | 7920951.25 | 2633953.53 | 3441009.31 | 2683948.64 | 1476337.65 | 2418149.25 |
| Issued Instructions | inst | 1837660689 | 611077219 | 798314161 | 622676085 | 342510334 | 561010627 |

### Launch Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 65536 | 8192 | 8192 | 8192 | 8192 | 8192 |
| Registers Per Thread | register/thread | 40 | 48 | 48 | 48 | 54 | 39 |
| Shared Memory Configuration Size | Kbyte | 32.77 | 102.40 | 65.54 | 65.54 | 102.40 | 65.54 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block | 640 |  |  |  |  |  |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 16777216 | 2097152 | 2097152 | 2097152 | 2097152 | 2097152 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 188.32 | 28.25 | 28.25 | 28.25 | 35.31 | 23.54 |
| Static Shared Memory Per Block | Kbyte/block |  | 12.29 | 8.19 | 8.19 | 16.38 | 8.19 |

### Occupancy

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 5 | 5 | 4 | 6 |
| Block Limit Shared Mem | block | 19 | 7 | 7 | 7 | 5 | 7 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 40 | 40 | 32 | 48 |
| Theoretical Occupancy | % | 100 | 83.33 | 83.33 | 83.33 | 66.67 | 100 |
| Achieved Occupancy | % | 99.67 | 81.75 | 81.52 | 82.51 | 65.94 | 98.04 |
| Achieved Active Warps Per SM | warp | 47.84 | 39.24 | 39.13 | 39.60 | 31.65 | 47.06 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 10.62% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 2618677.33 | 2619690.67 | 2615098.67 | 2591048 | 2588986.67 | 2611349.33 |
| Total DRAM Elapsed Cycles | cycle | 1377097728 | 383098880 | 334589952 | 360218624 | 223122432 | 320268288 |
| Average L1 Active Cycles | cycle | 29243869.10 | 8144326.64 | 7097133.90 | 7706847.91 | 4732894.76 | 6786233.60 |
| Total L1 Elapsed Cycles | cycle | 1696995058 | 474955706 | 413174428 | 448739432 | 275741850 | 395297356 |
| Average L2 Active Cycles | cycle | 29948420.04 | 8493262.25 | 7363688.21 | 7946696.79 | 4908174.17 | 7043885.38 |
| Total L2 Elapsed Cycles | cycle | 727830000 | 202890264 | 176914920 | 190935432 | 117969192 | 169311312 |
| Average SM Active Cycles | cycle | 29243869.10 | 8144326.64 | 7097133.90 | 7706847.91 | 4732894.76 | 6786233.60 |
| Total SM Elapsed Cycles | cycle | 1696995058 | 474955706 | 413174428 | 448739432 | 275741850 | 395297356 |
| Average SMSP Active Cycles | cycle | 29244119.52 | 8278897.96 | 7099437.25 | 7706332.86 | 4733379.12 | 6785638.56 |
| Total SMSP Elapsed Cycles | cycle | 6787980232 | 1899822824 | 1652697712 | 1794957728 | 1102967400 | 1581189424 |

### Source Counters

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.01 | 0.18 | 0.15 | 0.19 | 0.14 | 0.19 |
| Branch Instructions | inst | 19398656 | 109117440 | 117833728 | 117309440 | 46792704 | 109314048 |
| Branch Efficiency | % | 100 | 87.46 | 87.62 | 87.46 | 100 | 87.61 |
| Avg. Divergent Branches | branches | 0 | 36157.79 | 35875.31 | 36157.79 | 0 | 35875.31 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 796.21 | 797.92 | 796.20 | 808.89 | 804.17 | 795.53 |
| Elapsed Cycles | cycle | 237319405 | 75213504 | 55428773 | 59474411 | 37385672 | 54493221 |
| Memory Throughput | % | 94.08 | 95.96 | 90.59 | 89.28 | 90.08 | 94.58 |
| DRAM Throughput | % | 0.65 | 2.07 | 2.78 | 2.64 | 4.16 | 2.82 |
| Duration | ms | 296.86 | 93.88 | 69.54 | 72.93 | 46.19 | 68.47 |
| L1/TEX Cache Throughput | % | 94.09 | 81.95 | 90.69 | 89.38 | 90.19 | 92.02 |
| L2 Cache Throughput | % | 17.70 | 95.96 | 62.33 | 36.28 | 47.78 | 94.58 |
| Compute (SM) Throughput | % | 94.08 | 37.18 | 54.92 | 47.60 | 48.38 | 47.30 |
| SM Active Cycles | cycle |  | 74811455.50 | 55312771.33 | 58918146.47 | 37099824.48 | 54415000.97 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 31.92 | 20.38 | 30.28 | 31.65 | 20.32 | 29.75 |
| Maximum Sampling Interval | us | 64 | 32 | 16 | 16 | 16 | 16 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.06 | 1.12 | 1.96 | 1.45 | 1.19 | 1.39 |
| Executed Ipc Elapsed | inst/cycle | 1.06 | 1.12 | 1.96 | 1.44 | 1.19 | 1.39 |
| Issue Slots Busy | % | 26.62 | 27.97 | 48.89 | 36.10 | 29.72 | 34.75 |
| Issued Ipc Active | inst/cycle | 1.06 | 1.12 | 1.96 | 1.45 | 1.19 | 1.39 |
| SM Busy | % | 36.61 | 27.97 | 48.89 | 36.10 | 29.72 | 34.75 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 83.24% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 88.19% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (47.9%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (24.8%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 87.54% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 84.28% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 1.95 | 6.19 | 8.35 | 7.90 | 12.46 | 8.46 |
| Mem Busy | % | 57.94 | 95.96 | 90.59 | 89.28 | 90.08 | 94.58 |
| Max Bandwidth | % | 94.08 | 92.76 | 61.52 | 47.60 | 48.38 | 86.60 |
| L1/TEX Hit Rate | % | 51.70 | 17.26 | 60.59 | 77.42 | 60.33 | 40.19 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 99.59 | 100.36 | 99.26 | 99.21 | 99.04 | 99.69 |
| Mem Pipes Busy | % | 94.08 | 37.18 | 54.92 | 47.60 | 48.38 | 47.30 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 26.62 | 28.07 | 48.94 | 36.14 | 29.76 | 34.75 |
| Issued Warp Per Scheduler |  | 0.27 | 0.28 | 0.49 | 0.36 | 0.30 | 0.35 |
| No Eligible | % | 73.38 | 71.93 | 51.06 | 63.86 | 70.24 | 65.25 |
| Active Warps Per Scheduler | warp | 11.99 | 9.71 | 9.87 | 9.97 | 7.97 | 11.84 |
| Eligible Warps Per Scheduler | warp | 1.33 | 1.01 | 1.41 | 0.78 | 0.61 | 0.73 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 5.921% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.99 active warps per scheduler, but only an average of 1.33 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 4.041% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.71 active warps per scheduler, but only an average of 1.01 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 9.406% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.87 active warps per scheduler, but only an average of 1.41 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 10.72% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.97 active warps per scheduler, but only an average of 0.78 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 9.924% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.4 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.97 active warps per scheduler, but only an average of 0.61 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 5.416% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.84 active warps per scheduler, but only an average of 0.73 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 45.01 | 34.61 | 20.18 | 27.58 | 26.79 | 34.08 |
| Warp Cycles Per Executed Instruction | cycle | 45.01 | 34.61 | 20.18 | 27.58 | 26.79 | 34.08 |
| Avg. Active Threads Per Warp |  | 32 | 22.70 | 25.02 | 23.05 | 32 | 21.77 |
| Avg. Not Predicated Off Threads Per Warp |  | 31.98 | 20.71 | 23.44 | 21.09 | 28.56 | 19.51 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Avg. Executed Instructions Per Scheduler | inst | 62923599.45 | 20948921.38 | 27069757.79 | 21293550.34 | 11039426.21 | 18928604.69 |
| Executed Instructions | inst | 14598275072 | 4860149760 | 6280183808 | 4940103680 | 2561146880 | 4391436288 |
| Avg. Issued Instructions Per Scheduler | inst | 62923734.17 | 20949005.44 | 27069844.52 | 21293630.30 | 11039508.99 | 18928701.57 |
| Issued Instructions | inst | 14598306328 | 4860169262 | 6280203928 | 4940122230 | 2561166086 | 4391458765 |

### Launch Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 262144 | 32768 | 32768 | 32768 | 32768 | 32768 |
| Registers Per Thread | register/thread | 40 | 48 | 48 | 48 | 54 | 39 |
| Shared Memory Configuration Size | Kbyte | 32.77 | 102.40 | 65.54 | 65.54 | 102.40 | 65.54 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block | 640 |  |  |  |  |  |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 67108864 | 8388608 | 8388608 | 8388608 | 8388608 | 8388608 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 753.29 | 112.99 | 112.99 | 112.99 | 141.24 | 94.16 |
| Static Shared Memory Per Block | Kbyte/block |  | 12.29 | 8.19 | 8.19 | 16.38 | 8.19 |

### Occupancy

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 5 | 5 | 4 | 6 |
| Block Limit Shared Mem | block | 19 | 7 | 7 | 7 | 5 | 7 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 40 | 40 | 32 | 48 |
| Theoretical Occupancy | % | 100 | 83.33 | 83.33 | 83.33 | 66.67 | 100 |
| Achieved Occupancy | % | 99.88 | 80.93 | 82.31 | 83.08 | 66.43 | 98.77 |
| Achieved Active Warps Per SM | warp | 47.94 | 38.84 | 39.51 | 39.88 | 31.88 | 47.41 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 9.924% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Average DRAM Active Cycles | cycle | 12057986.67 | 12107290.67 | 12092413.33 | 12004962.67 | 11988533.33 | 12074896 |
| Total DRAM Elapsed Cycles | cycle | 11122804736 | 3517541376 | 2605691904 | 2732504064 | 1730811904 | 2565492736 |
| Total L1 Elapsed Cycles | cycle | 13709218844 | 4344618554 | 3211466138 | 3421099736 | 2154410518 | 3159274468 |
| Total L2 Elapsed Cycles | cycle | 5878335984 | 1859584104 | 1377284400 | 1450985448 | 916839960 | 1355931096 |
| Total SM Elapsed Cycles | cycle | 13709218844 | 4344618554 | 3211466138 | 3421099736 | 2154410518 | 3159274468 |
| Total SMSP Elapsed Cycles | cycle | 54836875376 | 17378474216 | 12845864552 | 13684398944 | 8617642072 | 12637097872 |
| Average L1 Active Cycles | cycle |  | 74811455.50 | 55312771.33 | 58918146.47 | 37099824.48 | 54415000.97 |
| Average L2 Active Cycles | cycle |  | 77565302.62 | 57316526.96 | 60361307.29 | 38190387.25 | 56465759.96 |
| Average SM Active Cycles | cycle |  | 74811455.50 | 55312771.33 | 58918146.47 | 37099824.48 | 54415000.97 |
| Average SMSP Active Cycles | cycle |  | 74630553.47 | 55311976.17 | 58918039.12 | 37099573.44 | 54466821.71 |

### Source Counters

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.01 | 0.18 | 0.15 | 0.19 | 0.15 | 0.20 |
| Branch Instructions | inst | 144703488 | 872677376 | 941096960 | 938999808 | 371720192 | 873463808 |
| Branch Efficiency | % | 100 | 87.48 | 87.56 | 87.48 | 100 | 87.55 |
| Avg. Divergent Branches | branches | 0 | 289262.34 | 288132.41 | 289262.34 | 0 | 288132.41 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 797.70 | 806.80 | 807.82 | 804.79 | 799.59 | 799.76 |
| Elapsed Cycles | cycle | 1897534980 | 667548493 | 502956946 | 471921869 | 390675202 | 689414888 |
| Memory Throughput | % | 94.40 | 80.89 | 92.80 | 87.84 | 66.95 | 69.38 |
| DRAM Throughput | % | 38.52 | 51.09 | 48.84 | 50.12 | 51.55 | 52.16 |
| Duration | s | 2.36 |  |  |  |  |  |
| L1/TEX Cache Throughput | % | 94.40 | 68.64 | 80.18 | 87.86 | 66.97 | 58.20 |
| L2 Cache Throughput | % | 18.43 | 80.89 | 92.80 | 37.49 | 36.85 | 69.38 |
| Compute (SM) Throughput | % | 94.40 | 33.62 | 48.50 | 47.70 | 36.25 | 29.85 |
| Duration | ms |  | 820.32 | 617.68 | 582.00 | 487.57 | 858.30 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Maximum Buffer Size | Mbyte | 31.65 | 22.22 | 33.10 | 31.13 | 25.95 | 23.00 |
| Maximum Sampling Interval | us | 512 | 256 | 128 | 128 | 128 | 256 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

### Compute Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Executed Ipc Active | inst/cycle | 1.07 | 1.01 | 1.72 | 1.45 | 0.87 | 0.87 |
| Executed Ipc Elapsed | inst/cycle | 1.07 | 1.01 | 1.72 | 1.45 | 0.87 | 0.87 |
| Issue Slots Busy | % | 26.63 | 25.25 | 43.04 | 36.22 | 21.86 | 21.82 |
| Issued Ipc Active | inst/cycle | 1.07 | 1.01 | 1.72 | 1.45 | 0.87 | 0.87 |
| SM Busy | % | 36.72 | 25.25 | 43.04 | 36.22 | 21.86 | 21.82 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 83.23% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 89.41% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_ptx_manual_pack** [INF]: ALU is the highest-utilized pipeline (42.1%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k16** [INF]: ALU is the highest-utilized pipeline (24.8%) based on elapsed cycles in the workload, taking into account the rates of its different instructions. It executes integer and logic operations. It is well-utilized, but should not be a bottleneck.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 90.5% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.
- **int8_wmma** [OPT]: Est. Local Speedup: 90.29% All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

### Memory Workload Analysis

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 115.48 | 153.14 | 146.39 | 150.24 | 154.51 | 156.34 |
| Mem Busy | % | 58.13 | 80.89 | 92.80 | 87.84 | 66.95 | 69.38 |
| Max Bandwidth | % | 94.40 | 79.17 | 79.10 | 50.12 | 51.55 | 60.73 |
| L1/TEX Hit Rate | % | 49.89 | 23.68 | 37.22 | 75.90 | 61.17 | 33.56 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 50.12 | 84.46 | 87.87 | 68.75 | 65.84 | 81.86 |
| Mem Pipes Busy | % | 94.40 | 33.62 | 48.50 | 47.70 | 36.25 | 29.85 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| One or More Eligible | % | 26.63 | 24.86 | 34.34 | 36.23 | 21.93 | 21.73 |
| Issued Warp Per Scheduler |  | 0.27 | 0.25 | 0.34 | 0.36 | 0.22 | 0.22 |
| No Eligible | % | 73.37 | 75.14 | 65.66 | 63.77 | 78.07 | 78.27 |
| Active Warps Per Scheduler | warp | 11.99 | 9.70 | 7.26 | 9.98 | 7.99 | 11.82 |
| Eligible Warps Per Scheduler | warp | 1.31 | 0.89 | 0.73 | 0.69 | 0.34 | 0.53 |

Comments:
- **int8_dp4a** [OPT]: Est. Local Speedup: 5.604% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 3.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.99 active warps per scheduler, but only an average of 1.31 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_3stage** [OPT]: Est. Local Speedup: 19.11% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.0 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.70 active warps per scheduler, but only an average of 0.89 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_manual_pack** [OPT]: Est. Local Speedup: 7.203% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.9 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.26 active warps per scheduler, but only an average of 0.73 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, reduce the time the active warps are stalled by inspecting the top stall reasons on the Warp State Statistics and Source Counters sections.
- **int8_ptx_mma_k16** [OPT]: Est. Local Speedup: 12.16% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 2.8 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 9.98 active warps per scheduler, but only an average of 0.69 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_ptx_mma_k32** [OPT]: Est. Local Speedup: 33.05% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 7.99 active warps per scheduler, but only an average of 0.34 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.
- **int8_wmma** [OPT]: Est. Local Speedup: 30.62% Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only issues an instruction every 4.6 cycles. This might leave hardware resources underutilized and may lead to less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average of 11.82 active warps per scheduler, but only an average of 0.53 warps were eligible per cycle. Eligible warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no eligible warp results in no instruction being issued and the issue slot remains unused. To increase the number of eligible warps, avoid possible load imbalances due to highly different execution durations per warp. Reducing stalls indicated on the Warp State Statistics and Source Counters sections can help, too.

### Warp State Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Warp Cycles Per Issued Instruction | cycle | 45.04 | 39.00 | 21.13 | 27.55 | 36.44 | 54.40 |
| Warp Cycles Per Executed Instruction | cycle | 45.04 | 39.00 | 21.13 | 27.55 | 36.44 | 54.40 |
| Avg. Active Threads Per Warp |  | 32 | 22.68 | 24.94 | 23.03 | 32 | 21.64 |
| Avg. Not Predicated Off Threads Per Warp |  | 31.99 | 20.69 | 23.37 | 21.07 | 28.48 | 19.38 |

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

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Avg. Issued Instructions Per Scheduler | inst | 501617198 |  |  |  | 85233040.44 |  |
| Executed Instructions | inst |  | 38767951872 | 49816797184 | 39356203008 | 19774046208 | 34745614336 |
| Issued Instructions | inst |  | 38767971417 | 49816817330 | 39356221603 | 19774065381 | 34745636793 |
| Avg. Executed Instructions Per Scheduler | inst |  |  |  |  | 85232957.79 |  |

### Launch Statistics

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 1048576 | 131072 | 131072 | 131072 | 131072 | 131072 |
| Registers Per Thread | register/thread | 40 | 48 | 48 | 48 | 54 | 39 |
| Shared Memory Configuration Size | Kbyte | 32.77 | 102.40 | 65.54 | 65.54 | 102.40 | 65.54 |
| Driver Shared Memory Per Block | Kbyte/block | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 | 1.02 |
| Dynamic Shared Memory Per Block | byte/block | 0 | 0 | 0 | 0 | 0 | 0 |
| Static Shared Memory Per Block | byte/block | 640 |  |  |  |  |  |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Stack Size |  | 1024 | 1024 | 1024 | 1024 | 1024 | 1024 |
| Threads | thread | 268435456 | 33554432 | 33554432 | 33554432 | 33554432 | 33554432 |
| # TPCs |  | 29 | 29 | 29 | 29 | 29 | 29 |
| Enabled TPC IDs |  | all | all | all | all | all | all |
| Uses Green Context |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Waves Per SM |  | 3013.15 | 451.97 | 451.97 | 451.97 | 564.97 | 376.64 |
| Static Shared Memory Per Block | Kbyte/block |  | 12.29 | 8.19 | 8.19 | 16.38 | 8.19 |

### Occupancy

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Block Limit SM | block | 24 | 24 | 24 | 24 | 24 | 24 |
| Block Limit Registers | block | 6 | 5 | 5 | 5 | 4 | 6 |
| Block Limit Shared Mem | block | 19 | 7 | 7 | 7 | 5 | 7 |
| Block Limit Warps | block | 6 | 6 | 6 | 6 | 6 | 6 |
| Theoretical Active Warps per SM | warp | 48 | 40 | 40 | 40 | 32 | 48 |
| Theoretical Occupancy | % | 100 | 83.33 | 83.33 | 83.33 | 66.67 | 100 |
| Achieved Occupancy | % | 99.95 | 82.07 | 97.28 | 82.92 | 66.40 | 98.66 |
| Achieved Active Warps Per SM | warp | 47.98 | 39.40 | 46.69 | 39.80 | 31.87 | 47.36 |

Comments:
- **int8_ptx_mma_k32** [OPT]: Est. Speedup: 33.05% The 8.00 theoretical warps per scheduler this kernel can issue according to its occupancy are below the hardware maximum of 12. This kernel's theoretical occupancy (66.7%) is limited by the number of required registers.

### GPU and Memory Workload Distribution

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Total DRAM Elapsed Cycles | cycle | 88481901568 | 30736189440 | 23143433216 | 21806853120 | 18268452864 | 32159330304 |
| Total L1 Elapsed Cycles | cycle | 109252390212 | 38381994908 | 28936962628 | 27164187152 | 22610726802 | 39811947716 |
| Total L2 Elapsed Cycles | cycle | 46763238360 | 16311382704 | 12291414000 | 11559239040 | 9673158192 | 17011646232 |
| Total SM Elapsed Cycles | cycle | 109252390212 | 38381994908 | 28936962628 | 27164187152 | 22610726802 | 39811947716 |
| Total SMSP Elapsed Cycles | cycle | 437009560848 | 153527979632 | 115747850512 | 108656748608 | 90442907208 |  |
| Average L1 Active Cycles | cycle |  | 661621010.41 | 498798218.09 | 468226612.12 | 389738480.03 |  |
| Average L2 Active Cycles | cycle |  | 696935813.08 | 657125464 | 479847893.21 | 403437887.96 |  |
| Average SM Active Cycles | cycle |  | 661621010.41 | 498798218.09 | 468226612.12 | 389738480.03 |  |
| Average SMSP Active Cycles | cycle |  | 672183198.10 | 625305017.12 | 468242607.74 | 388673723.45 |  |
| Average DRAM Active Cycles | cycle |  |  |  |  |  | 2795572312 |

### Source Counters

| Metric Name | Metric Unit | int8_dp4a | int8_ptx_3stage | int8_ptx_manual_pack | int8_ptx_mma_k16 | int8_ptx_mma_k32 | int8_wmma |
|---|---|---|---|---|---|---|---|
| Branch Instructions Ratio | % | 0.01 | 0.18 | 0.15 | 0.19 | 0.15 | 0.20 |
| Branch Instructions | inst | 1115684864 | 6980370432 | 7522484224 | 7514095616 | 2963275776 | 6983516160 |
| Branch Efficiency | % | 100 | 87.49 | 87.53 | 87.49 | 100 | 87.53 |
| Avg. Divergent Branches | branches | 0 | 2314098.76 | 2309579.03 | 2314098.76 | 0 | 2309579.03 |

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

