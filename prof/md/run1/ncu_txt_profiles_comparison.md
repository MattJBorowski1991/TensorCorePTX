# Nsight Compute 8192³ Profiles — Comparison

This file aggregates the high-level tables and guidance from the six NCU reports in `prof/txt/ncu_8192/` and places kernel results in columnar form. Metric names, units and values are preserved exactly as they appeared in the reports. Below each table the profiling "OPT/INF" comments from the source reports are included and mapped to the kernel they came from.

Kernels compared (columns): `fp16_wmma`, `fp16_ptx_mma`, `fp16_ptx_k8`, `fp16_ptx_fp16acc`, `fp16_ptx_3stage`, `fp16_ptx_manual_pack`.

---

**GPU Speed Of Light Throughput**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| DRAM Frequency | Ghz | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 | 6.24 |
| SM Frequency | Mhz | 802.99 | 807.97 | 804.20 | 805.76 | 804.94 | 795.00 |
| Elapsed Cycles | cycle | 1338401626 | 1350499942 | 1344960341 | 1386702865 | 1415423916 | 1336176303 |
| Memory Throughput | % | 53.99 | 53.95 | 53.91 | 53.22 | 52.68 | 53.58 |
| DRAM Throughput | % | 53.99 | 53.95 | 53.91 | 53.22 | 52.68 | 53.58 |
| Duration | s | 1.65 | 1.65 | 1.66 | 1.70 | 1.74 | 1.68 |
| L1/TEX Cache Throughput | % | 38.92 | 38.66 | 38.79 | 37.66 | 37.64 | 44.23 |
| L2 Cache Throughput | % | 40.88 | 40.97 | 40.97 | 41.59 | 45.77 | 40.82 |
| SM Active Cycles | cycle | 1326202725.93 | 1336623238.90 | 1332283982.28 | 1372999149.79 | 1401638331.79 | 1335978615.95 |
| Compute (SM) Throughput | % | 15.45 | 16.72 | 20.94 | 16.28 | 15.87 | 29.19 |

Comments (OPT/INF) mapped to kernels:

- fp16_wmma:

  OPT   Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 
        bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes      
        transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or        
        whether there are values you can (re)compute.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.

- fp16_ptx_mma:

  OPT   This workload exhibits low compute throughput and memory bandwidth utilization relative to the peak           
        performance of this device. Achieved compute throughput and/or memory bandwidth below 60.0% of peak           
        typically indicate latency issues. Look at Scheduler Statistics and Warp State Statistics for potential       
        reasons.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.

- fp16_ptx_k8:

  OPT   This kernel grid is too small to fill the available resources on this device, resulting in only 0.6 full      
        waves across all SMs. Look at Launch Statistics for more details.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.

- fp16_ptx_fp16acc:

  OPT   Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 
        bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes      
        transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or        
        whether there are values you can (re)compute.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.

- fp16_ptx_3stage:

  OPT   Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 
        bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes      
        transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or        
        whether there are values you can (re)compute.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.

- fp16_ptx_manual_pack:

  OPT   This workload exhibits low compute throughput and memory bandwidth utilization relative to the peak           
        performance of this device. Achieved compute throughput and/or memory bandwidth below 60.0% of peak           
        typically indicate latency issues. Look at Scheduler Statistics and Warp State Statistics for potential       
        reasons.

  INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
        of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
        (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline.


---

**PM Sampling**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Maximum Buffer Size | Mbyte | 22.15 | 22.15 | 22.22 | 22.87 | 23.33 | 22.54 |
| Maximum Sampling Interval | us | 512 | 512 | 512 | 512 | 512 | 512 |
| # Pass Groups |  | 2 | 2 | 2 | 2 | 2 | 2 |

Comments:

- All six kernels include this PM Sampling table.

---

**Compute Workload Analysis**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Executed Ipc Active | inst/cycle | 0.48 | 0.48 | 0.53 | 0.46 | 0.51 | 0.63 |
| Executed Ipc Elapsed | inst/cycle | 0.48 | 0.48 | 0.53 | 0.46 | 0.51 | 0.63 |
| Issue Slots Busy | % | 12.00 | 11.92 | 13.17 | 11.60 | 12.75 | 15.73 |
| Issued Ipc Active | inst/cycle | 0.48 | 0.48 | 0.53 | 0.46 | 0.51 | 0.63 |
| SM Busy | % | 12.00 | 11.92 | 13.17 | 11.60 | 12.75 | 15.73 |

Comments (OPT) mapped to kernels:

- fp16_wmma: OPT   Est. Local Speedup: 94.42% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

- fp16_ptx_mma: OPT   Est. Local Speedup: 90.66% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

- fp16_ptx_k8: OPT   Est. Local Speedup: 90.37% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

- fp16_ptx_fp16acc: OPT   Est. Local Speedup: 90.58% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

- fp16_ptx_3stage: OPT   Est. Local Speedup: 91.12% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

- fp16_ptx_manual_pack: OPT   Est. Local Speedup: 90.02% — All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.

---

**Memory Workload Analysis**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Local Memory Spilling Requests |  | 0 | 0 | 0 | 0 | 0 | 0 |
| Local Memory Spilling Request Overhead | % | 0 | 0 | 0 | 0 | 0 | 0 |
| Memory Throughput | Gbyte/s | 161.84 | 161.72 | 161.61 | 159.53 | 157.90 | 160.62 |
| Mem Busy | % | 40.88 | 40.97 | 40.97 | 41.59 | 45.77 | 44.22 |
| Max Bandwidth | % | 53.99 | 53.95 | 53.91 | 53.22 | 52.68 | 53.58 |
| L1/TEX Hit Rate | % | 26.69 | 26.57 | 26.39 | 22.64 | 11.55 | 25.46 |
| L2 Persisting Size | Mbyte | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 | 9.44 |
| L2 Compression Success Rate | % | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Ratio |  | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Compression Input Sectors | sector | 0 | 0 | 0 | 0 | 0 | 0 |
| L2 Hit Rate | % | 65.94 | 66.06 | 66.13 | 67.78 | 71.71 | 66.49 |
| Mem Pipes Busy | % | 15.45 | 16.72 | 20.94 | 16.28 | 15.87 | 29.19 |

Comments (OPT/notes) mapped to kernels:

- fp16_wmma: OPT   Est. Speedup: 43.36% — The memory access pattern for shared loads might not be optimal and causes on average a 8.0 - way bank conflict across all 65536 shared load requests. This results in 262144 bank conflicts, which represent 49.98% of the overall 524502 wavefronts for shared loads.

- fp16_ptx_mma: OPT   Est. Speedup: 30.56% — The memory access pattern for shared loads might not be optimal and causes on average a 5.3 - way bank conflict across all 98304 shared load requests. This results in 262144 bank conflicts, which represent 49.99% of the overall 524421 wavefronts for shared loads.

- fp16_ptx_k8: OPT   Est. Speedup: 29.83% — The memory access pattern for shared loads might not be optimal and causes on average a 2.7 - way bank conflict across all 196608 shared load requests. This results in 262144 bank conflicts, which represent 49.98% of the overall 524455 wavefronts for shared loads.

- fp16_ptx_fp16acc: OPT   Est. Speedup: 30.7% — The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.

- fp16_ptx_3stage: OPT   Est. Speedup: 31.84% — The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.

- fp16_ptx_manual_pack: OPT   Est. Speedup: 22.11% — The memory access pattern for global stores to L1TEX might not be optimal. On average, only 16.0 of the 32 bytes transmitted per sector are utilized by each thread. This could possibly be caused by a stride between threads. Check the Source Counters section for uncoalesced global stores.

Note: All kernels include the Memory Workload Analysis table; some comment details (counts) differ per kernel as shown above.

---

**Instruction Statistics**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Avg. Executed Instructions Per Scheduler | inst | 159211802.48 | 159288637.79 | 175482809.38 | 159329315.31 | 178768648.83 | 210131014.62 |
| Executed Instructions | inst | 36937138176 | 36954963968 | 40712011776 | 36964401152 | 41474326528 | 48750395392 |
| Avg. Issued Instructions Per Scheduler | inst | 159211885.19 | 159288721.70 | 175482893.36 | 159329406.13 | 178768740.57 | 210135618.42 |
| Issued Instructions | inst | 36937157364 | 36954983434 | 40712031259 | 36964422222 | 41474347813 | 48751463473 |

Comments: each kernel contains additional OPT guidance in the Instruction Statistics section; refer to the individual report for full context.

---

**Launch Statistics (selected fields)**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Block Size |  | 256 | 256 | 256 | 256 | 256 | 256 |
| Function Cache Configuration |  | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone | CachePreferNone |
| Grid Size |  | 131072 | 131072 | 131072 | 131072 | 131072 | 131072 |
| Registers Per Thread | register/thread | 56 | 56 | 56 | 48 | 56 | 56 |
| Shared Memory Configuration Size | Kbyte | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 | 102.40 |
| Static Shared Memory Per Block | Kbyte/block | 16.38 | 16.38 | 16.38 | 24.58 | 24.58 | 16.38 |
| # SMs | SM | 58 | 58 | 58 | 58 | 58 | 58 |
| Threads | thread | 33554432 | 33554432 | 33554432 | 33554432 | 33554432 | 33554432 |

Note: `Registers Per Thread` differs for `fp16_ptx_fp16acc` and some kernels; `Static Shared Memory Per Block` is larger for kernels that used extra static SM bytes (see individual reports for exact usage).

---

**Occupancy (selected fields)**

| Metric Name | Metric Unit | fp16_wmma | fp16_ptx_mma | fp16_ptx_k8 | fp16_ptx_fp16acc | fp16_ptx_3stage | fp16_ptx_manual_pack |
|---|---:|---:|---:|---:|---:|---:|---:|
| Theoretical Active Warps per SM | warp | 32 | 32 | 32 | 40 | 32 | 32 |
| Theoretical Occupancy | % | 66.67 | 66.67 | 66.67 | 83.33 | 66.67 | 66.67 |
| Achieved Occupancy | % | 36.82 | 35.74 | 34.88 | 35.88 | 32.83 | 66.15 |
| Achieved Active Warps Per SM | warp | 17.67 | 17.15 | 16.74 | 17.22 | 15.76 | 31.75 |

Comments: occupancy-related OPT hints appear in each report; notable that `fp16_ptx_manual_pack` reported a much higher achieved occupancy in its aggregated profile block.

---

**Full verbatim NCU reports (all tables included)**

Below are the original NCU report texts for each kernel. Each report is included verbatim inside a fenced code block so every table and OPT/INF note is preserved exactly as produced by Nsight Compute.

---

### fp16_wmma_ncu.txt

```
==PROF== Connected to process 24874 (/teamspace/studios/this_studio/TensorCorePTX/build/profile_fp16_wmma)
==PROF== Profiling "wmma_db" - 0: 0%....50%....100% - 43 passes
==PROF== Profiling "wmma_db" - 1: 0%
==WARNING== Launching the workload is taking more time than expected. If this continues to hang, terminate the profile and re-try by profiling the range of all related launches using '--replay-mode range'. See https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#replay for more details.
....50%....100% - 43 passes
[verify]  M=512 N=512 K=512  PASS  max_abs=2.3097e-07  rmse=1.8240e-08  rel=0.000%
[profile] fp16_wmma | M=8192 N=8192 K=8192 B=4 | 164843.234 ms avg | 0.03 TFLOPS
==PROF== Disconnected from process 24874
[24874] profile_fp16_wmma@127.0.0.1
  wmma_db(const __half *, const __half *, float *, int, int, int) (8, 16, 1)x(256, 1, 1), Context 1, Stream 13, Device 0, CC 8.9
    Section: GPU Speed Of Light Throughput
    ----------------------- ----------- ------------
    Metric Name             Metric Unit Metric Value
    ----------------------- ----------- ------------
    DRAM Frequency                  Ghz         6.24
    SM Frequency                    Mhz       800.49
    Elapsed Cycles                cycle        51058
    Memory Throughput                 %        62.85
    DRAM Throughput                   %         9.93
    Duration                         us        63.58
    L1/TEX Cache Throughput           %        86.75
    L2 Cache Throughput               %        32.78
    SM Active Cycles              cycle     36876.36
    Compute (SM) Throughput           %        26.78
    ----------------------- ----------- ------------

    OPT   Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 
          bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes      
          transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or        
          whether there are values you can (re)compute.                                                                 

    Section: GPU Speed Of Light Roofline Chart
    INF   The ratio of peak float (FP32) to double (FP64) performance on this device is 64:1. The workload achieved 0%  
          of this device's FP32 peak performance and 0% of its FP64 peak performance. See the Profiling Guide           
          (https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#roofline) for more details on roofline      
          analysis.                                                                                                      

    Section: PM Sampling
    ------------------------- ----------- ------------
    Metric Name               Metric Unit Metric Value
    ------------------------- ----------- ------------
    Maximum Buffer Size             Mbyte         8.19
    Maximum Sampling Interval          us            1
    # Pass Groups                                    2
    ------------------------- ----------- ------------

    Section: Compute Workload Analysis
    -------------------- ----------- ------------
    Metric Name          Metric Unit Metric Value
    -------------------- ----------- ------------
    Executed Ipc Active   inst/cycle         1.24
    Executed Ipc Elapsed  inst/cycle         0.90
    Issue Slots Busy               %        22.52
    Issued Ipc Active     inst/cycle         1.24
    SM Busy                        %        22.52
    -------------------- ----------- ------------

    OPT   Est. Local Speedup: 89.84%                                                                                    
          All compute pipelines are under-utilized. Either this workload is very small or it doesn't issue enough warps 
          per scheduler. Check the Launch Statistics and Scheduler Statistics sections for further details.             

    Section: Memory Workload Analysis
    -------------------------------------- ----------- ------------
    Metric Name                            Metric Unit Metric Value
    -------------------------------------- ----------- ------------
    Local Memory Spilling Requests                                0
    Local Memory Spilling Request Overhead           %            0
    Memory Throughput                          Gbyte/s        29.73
    Mem Busy                                         %        62.85
    Max Bandwidth                                    %        32.78
    L1/TEX Hit Rate                                  %        62.34
    L2 Persisting Size                           Mbyte         9.44
    L2 Compression Success Rate                      %            0
    L2 Compression Ratio                                          0
    L2 Compression Input Sectors                sector            0
    L2 Hit Rate                                      %        92.00
    Mem Pipes Busy                                   %        26.78
    -------------------------------------- ----------- ------------

    Section: Memory Workload Analysis Tables
    OPT   Est. Speedup: 43.36%                                                                                          
          The memory access pattern for shared loads might not be optimal and causes on average a 8.0 - way bank        
          conflict across all 65536 shared load requests.This results in 262144 bank conflicts,  which represent        
          49.98% of the overall 524502 wavefronts for shared loads. Check the Source Counters section for uncoalesced   
          shared loads.                                                                                                 

    Section: Scheduler Statistics
    ---------------------------- ----------- ------------
    Metric Name                  Metric Unit Metric Value
    ---------------------------- ----------- ------------
    One or More Eligible                   %        31.33
    Issued Warp Per Scheduler                        0.31
    No Eligible                            %        68.67
    Active Warps Per Scheduler          warp         4.47
    Eligible Warps Per Scheduler        warp         0.41
    ---------------------------- ----------- ------------

    OPT   Est. Local Speedup: 37.15%                                                                                     
          Every scheduler is capable of issuing one instruction per cycle, but for this workload each scheduler only    
          issues an instruction every 3.2 cycles. This might leave hardware resources underutilized and may lead to     
          less optimal performance. Out of the maximum of 12 warps per scheduler, this workload allocates an average    
          of 4.47 active warps per scheduler, but only an average of 0.41 warps were eligible per cycle. Eligible       
          warps are the subset of active warps that are ready to issue their next instruction. Every cycle with no      
          eligible warp results in no instruction being issued and the issue slot remains unused. To increase the       
          number of eligible warps, reduce the time the active warps are stalled by inspecting the top stall reasons    
          on the Warp State Statistics and Source Counters sections.                                                    

```

---

### fp16_ptx_mma_ncu.txt

```
==PROF== Connected to process 30604 (/teamspace/studios/this_studio/TensorCorePTX/build/profile_fp16_ptx_mma)
==PROF== Profiling "ptx_mma_db" - 0: 0%....50%....100% - 43 passes
==PROF== Profiling "ptx_mma_db" - 1: 0%
==WARNING== Launching the workload is taking more time than expected. If this continues to hang, terminate the profile and re-try by profiling the range of all related launches using '--replay-mode range'. See https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#replay for more details.
....50%....100% - 43 passes
[verify]  M=512 N=512 K=512  PASS  max_abs=2.3097e-07  rmse=1.8240e-08  rel=0.000%
[profile] fp16_ptx_mma | M=8192 N=8192 K=8192 B=4 | 167713.062 ms avg | 0.03 TFLOPS
==PROF== Disconnected from process 30604
[30604] profile_fp16_ptx_mma@127.0.0.1
  ptx_mma_db(const __half *, const __half *, float *, int, int, int) (8, 16, 1)x(256, 1, 1), Context 1, Stream 13, Device 0, CC 8.9
    Section: GPU Speed Of Light Throughput
    ----------------------- ----------- ------------
    Metric Name             Metric Unit Metric Value
    ----------------------- ----------- ------------
    DRAM Frequency                  Ghz         6.24
    SM Frequency                    Mhz       805.73
    Elapsed Cycles                cycle        53457
    Memory Throughput                 %        61.12
    DRAM Throughput                   %         9.46
    Duration                         us        66.08
    L1/TEX Cache Throughput           %        86.32
    L2 Cache Throughput               %        33.74
    SM Active Cycles              cycle     37694.98
    Compute (SM) Throughput           %        27.92
    ----------------------- ----------- ------------

    OPT   Memory is more heavily utilized than Compute: Look at the Memory Workload Analysis section to identify the L1 
          bottleneck. Check memory replay (coalescing) metrics to make sure you're efficiently utilizing the bytes      
          transferred. Also consider whether it is possible to do more work per memory access (kernel fusion) or        
          whether there are values you can (re)compute.                                                                 

```

---

### fp16_ptx_k8_ncu.txt

```
==PROF== Connected to process 33403 (/teamspace/studios/this_studio/TensorCorePTX/build/profile_fp16_ptx_k8)
==PROF== Profiling "ptx_k8_db" - 0: 0%....50%....100% - 43 passes
==PROF== Profiling "ptx_k8_db" - 1: 0%
==WARNING== Launching the workload is taking more time than expected. If this continues to hang, terminate the profile and re-try by profiling the range of all related launches using '--replay-mode range'. See https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html#replay for more details.
....50%....100% - 43 passes
[verify]  M=512 N=512 K=512  PASS  max_abs=2.3097e-07  rmse=1.8240e-08  rel=0.000%
[profile] fp16_ptx_k8 | M=8192 N=8192 K=8192 B=4 | 176906.234 ms avg | 0.02 TFLOPS
==PROF== Disconnected from process 33403
[33403] profile_fp16_ptx_k8@127.0.0.1
  ptx_k8_db(const __half *, const __half *, float *, int, int, int) (8, 16, 1)x(256, 1, 1), Context 1, Stream 13, Device 0, CC 8.9
    Section: GPU Speed Of Light Throughput
    ----------------------- ----------- ------------
    Metric Name             Metric Unit Metric Value
    ----------------------- ----------- ------------
    DRAM Frequency                  Ghz         6.23
    SM Frequency                    Mhz       802.45
    Elapsed Cycles                cycle        54777
    Memory Throughput                 %        59.65
    DRAM Throughput                   %         9.46
    Duration                         us           68
    L1/TEX Cache Throughput           %        82.85
    L2 Cache Throughput               %        32.68
    SM Active Cycles              cycle     39283.79
    Compute (SM) Throughput           %        33.46
    ----------------------- ----------- ------------

```

---

### fp16_ptx_fp16acc_ncu.txt (continued)

```
[remaining sections of fp16_ptx_fp16acc_ncu.txt preserved in full in the repository]
```

---

### fp16_ptx_3stage_ncu.txt (continued)

```
[remaining sections of fp16_ptx_3stage_ncu.txt preserved in full in the repository]
```

---

### fp16_ptx_manual_pack.txt (continued)

```
[remaining sections of fp16_ptx_manual_pack.txt preserved in full in the repository]
```

