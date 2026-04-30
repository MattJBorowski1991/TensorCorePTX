# NCU Charts

Source: ncu_txt_profiles_comparison.md

Each metric has one PNG chart with grouped bars by matrix size and kernel order fixed left-to-right.

Kernel order: int8_wmma, int8_ptx_mma_k32, int8_ptx_mma_k16, int8_ptx_manual_pack, int8_ptx_3stage.

Overlay symbols indicate duration speedup/slowdown (%) vs int8_wmma for the same matrix size (right axis).

## GPU Speed Of Light Throughput

### DRAM Frequency (Ghz)

![DRAM Frequency (Ghz)](gpu_speed_of_light_throughput__dram_frequency_ghz.png)

### SM Frequency (Mhz)

![SM Frequency (Mhz)](gpu_speed_of_light_throughput__sm_frequency_mhz.png)

### Elapsed Cycles (cycle)

![Elapsed Cycles (cycle)](gpu_speed_of_light_throughput__elapsed_cycles_cycle.png)

### Memory Throughput (%)

![Memory Throughput (%)](gpu_speed_of_light_throughput__memory_throughput.png)

### DRAM Throughput (%)

![DRAM Throughput (%)](gpu_speed_of_light_throughput__dram_throughput.png)

### Duration (us)

![Duration (us)](gpu_speed_of_light_throughput__duration_us.png)

### L1/TEX Cache Throughput (%)

![L1/TEX Cache Throughput (%)](gpu_speed_of_light_throughput__l1_tex_cache_throughput.png)

### L2 Cache Throughput (%)

![L2 Cache Throughput (%)](gpu_speed_of_light_throughput__l2_cache_throughput.png)

### SM Active Cycles (cycle)

![SM Active Cycles (cycle)](gpu_speed_of_light_throughput__sm_active_cycles_cycle.png)

### Compute (SM) Throughput (%)

![Compute (SM) Throughput (%)](gpu_speed_of_light_throughput__compute_sm_throughput.png)

### Duration (ms)

![Duration (ms)](gpu_speed_of_light_throughput__duration_ms.png)

## PM Sampling

### Maximum Buffer Size (Mbyte)

![Maximum Buffer Size (Mbyte)](pm_sampling__maximum_buffer_size_mbyte.png)

### Maximum Sampling Interval (us)

![Maximum Sampling Interval (us)](pm_sampling__maximum_sampling_interval_us.png)

### # Pass Groups

![# Pass Groups](pm_sampling__pass_groups.png)

## Compute Workload Analysis

### Executed Ipc Active (inst/cycle)

![Executed Ipc Active (inst/cycle)](compute_workload_analysis__executed_ipc_active_inst_cycle.png)

### Executed Ipc Elapsed (inst/cycle)

![Executed Ipc Elapsed (inst/cycle)](compute_workload_analysis__executed_ipc_elapsed_inst_cycle.png)

### Issue Slots Busy (%)

![Issue Slots Busy (%)](compute_workload_analysis__issue_slots_busy.png)

### Issued Ipc Active (inst/cycle)

![Issued Ipc Active (inst/cycle)](compute_workload_analysis__issued_ipc_active_inst_cycle.png)

### SM Busy (%)

![SM Busy (%)](compute_workload_analysis__sm_busy.png)

## Memory Workload Analysis

### Local Memory Spilling Requests

![Local Memory Spilling Requests](memory_workload_analysis__local_memory_spilling_requests.png)

### Local Memory Spilling Request Overhead (%)

![Local Memory Spilling Request Overhead (%)](memory_workload_analysis__local_memory_spilling_request_overhead.png)

### Memory Throughput (Gbyte/s)

![Memory Throughput (Gbyte/s)](memory_workload_analysis__memory_throughput_gbyte_s.png)

### Mem Busy (%)

![Mem Busy (%)](memory_workload_analysis__mem_busy.png)

### Max Bandwidth (%)

![Max Bandwidth (%)](memory_workload_analysis__max_bandwidth.png)

### L1/TEX Hit Rate (%)

![L1/TEX Hit Rate (%)](memory_workload_analysis__l1_tex_hit_rate.png)

### L2 Persisting Size (Mbyte)

![L2 Persisting Size (Mbyte)](memory_workload_analysis__l2_persisting_size_mbyte.png)

### L2 Compression Success Rate (%)

![L2 Compression Success Rate (%)](memory_workload_analysis__l2_compression_success_rate.png)

### L2 Compression Ratio

![L2 Compression Ratio](memory_workload_analysis__l2_compression_ratio.png)

### L2 Compression Input Sectors (sector)

![L2 Compression Input Sectors (sector)](memory_workload_analysis__l2_compression_input_sectors_sector.png)

### L2 Hit Rate (%)

![L2 Hit Rate (%)](memory_workload_analysis__l2_hit_rate.png)

### Mem Pipes Busy (%)

![Mem Pipes Busy (%)](memory_workload_analysis__mem_pipes_busy.png)

## Scheduler Statistics

### One or More Eligible (%)

![One or More Eligible (%)](scheduler_statistics__one_or_more_eligible.png)

### Issued Warp Per Scheduler

![Issued Warp Per Scheduler](scheduler_statistics__issued_warp_per_scheduler.png)

### No Eligible (%)

![No Eligible (%)](scheduler_statistics__no_eligible.png)

### Active Warps Per Scheduler (warp)

![Active Warps Per Scheduler (warp)](scheduler_statistics__active_warps_per_scheduler_warp.png)

### Eligible Warps Per Scheduler (warp)

![Eligible Warps Per Scheduler (warp)](scheduler_statistics__eligible_warps_per_scheduler_warp.png)

## Warp State Statistics

### Warp Cycles Per Issued Instruction (cycle)

![Warp Cycles Per Issued Instruction (cycle)](warp_state_statistics__warp_cycles_per_issued_instruction_cycle.png)

### Warp Cycles Per Executed Instruction (cycle)

![Warp Cycles Per Executed Instruction (cycle)](warp_state_statistics__warp_cycles_per_executed_instruction_cycle.png)

### Avg. Active Threads Per Warp

![Avg. Active Threads Per Warp](warp_state_statistics__avg_active_threads_per_warp.png)

### Avg. Not Predicated Off Threads Per Warp

![Avg. Not Predicated Off Threads Per Warp](warp_state_statistics__avg_not_predicated_off_threads_per_warp.png)

## Instruction Statistics

### Avg. Executed Instructions Per Scheduler (inst)

![Avg. Executed Instructions Per Scheduler (inst)](instruction_statistics__avg_executed_instructions_per_scheduler_inst.png)

### Executed Instructions (inst)

![Executed Instructions (inst)](instruction_statistics__executed_instructions_inst.png)

### Avg. Issued Instructions Per Scheduler (inst)

![Avg. Issued Instructions Per Scheduler (inst)](instruction_statistics__avg_issued_instructions_per_scheduler_inst.png)

### Issued Instructions (inst)

![Issued Instructions (inst)](instruction_statistics__issued_instructions_inst.png)

## Launch Statistics

### Block Size

![Block Size](launch_statistics__block_size.png)

### Grid Size

![Grid Size](launch_statistics__grid_size.png)

### Registers Per Thread (register/thread)

![Registers Per Thread (register/thread)](launch_statistics__registers_per_thread_register_thread.png)

### Shared Memory Configuration Size (Kbyte)

![Shared Memory Configuration Size (Kbyte)](launch_statistics__shared_memory_configuration_size_kbyte.png)

### Driver Shared Memory Per Block (Kbyte/block)

![Driver Shared Memory Per Block (Kbyte/block)](launch_statistics__driver_shared_memory_per_block_kbyte_block.png)

### Dynamic Shared Memory Per Block (byte/block)

![Dynamic Shared Memory Per Block (byte/block)](launch_statistics__dynamic_shared_memory_per_block_byte_block.png)

### # SMs (SM)

![# SMs (SM)](launch_statistics__sms_sm.png)

### Stack Size

![Stack Size](launch_statistics__stack_size.png)

### Threads (thread)

![Threads (thread)](launch_statistics__threads_thread.png)

### # TPCs

![# TPCs](launch_statistics__tpcs.png)

### Uses Green Context

![Uses Green Context](launch_statistics__uses_green_context.png)

### Waves Per SM

![Waves Per SM](launch_statistics__waves_per_sm.png)

### Static Shared Memory Per Block (Kbyte/block)

![Static Shared Memory Per Block (Kbyte/block)](launch_statistics__static_shared_memory_per_block_kbyte_block.png)

## Occupancy

### Block Limit SM (block)

![Block Limit SM (block)](occupancy__block_limit_sm_block.png)

### Block Limit Registers (block)

![Block Limit Registers (block)](occupancy__block_limit_registers_block.png)

### Block Limit Shared Mem (block)

![Block Limit Shared Mem (block)](occupancy__block_limit_shared_mem_block.png)

### Block Limit Warps (block)

![Block Limit Warps (block)](occupancy__block_limit_warps_block.png)

### Theoretical Active Warps per SM (warp)

![Theoretical Active Warps per SM (warp)](occupancy__theoretical_active_warps_per_sm_warp.png)

### Theoretical Occupancy (%)

![Theoretical Occupancy (%)](occupancy__theoretical_occupancy.png)

### Achieved Occupancy (%)

![Achieved Occupancy (%)](occupancy__achieved_occupancy.png)

### Achieved Active Warps Per SM (warp)

![Achieved Active Warps Per SM (warp)](occupancy__achieved_active_warps_per_sm_warp.png)

## GPU and Memory Workload Distribution

### Average DRAM Active Cycles (cycle)

![Average DRAM Active Cycles (cycle)](gpu_and_memory_workload_distribution__average_dram_active_cycles_cycle.png)

### Total DRAM Elapsed Cycles (cycle)

![Total DRAM Elapsed Cycles (cycle)](gpu_and_memory_workload_distribution__total_dram_elapsed_cycles_cycle.png)

### Average L1 Active Cycles (cycle)

![Average L1 Active Cycles (cycle)](gpu_and_memory_workload_distribution__average_l1_active_cycles_cycle.png)

### Total L1 Elapsed Cycles (cycle)

![Total L1 Elapsed Cycles (cycle)](gpu_and_memory_workload_distribution__total_l1_elapsed_cycles_cycle.png)

### Average L2 Active Cycles (cycle)

![Average L2 Active Cycles (cycle)](gpu_and_memory_workload_distribution__average_l2_active_cycles_cycle.png)

### Total L2 Elapsed Cycles (cycle)

![Total L2 Elapsed Cycles (cycle)](gpu_and_memory_workload_distribution__total_l2_elapsed_cycles_cycle.png)

### Average SM Active Cycles (cycle)

![Average SM Active Cycles (cycle)](gpu_and_memory_workload_distribution__average_sm_active_cycles_cycle.png)

### Total SM Elapsed Cycles (cycle)

![Total SM Elapsed Cycles (cycle)](gpu_and_memory_workload_distribution__total_sm_elapsed_cycles_cycle.png)

### Average SMSP Active Cycles (cycle)

![Average SMSP Active Cycles (cycle)](gpu_and_memory_workload_distribution__average_smsp_active_cycles_cycle.png)

### Total SMSP Elapsed Cycles (cycle)

![Total SMSP Elapsed Cycles (cycle)](gpu_and_memory_workload_distribution__total_smsp_elapsed_cycles_cycle.png)

## Source Counters

### Branch Instructions Ratio (%)

![Branch Instructions Ratio (%)](source_counters__branch_instructions_ratio.png)

### Branch Instructions (inst)

![Branch Instructions (inst)](source_counters__branch_instructions_inst.png)

### Branch Efficiency (%)

![Branch Efficiency (%)](source_counters__branch_efficiency.png)

### Avg. Divergent Branches (branches)

![Avg. Divergent Branches (branches)](source_counters__avg_divergent_branches_branches.png)

## Non-Numeric Metrics (No PNG)

- GPU Speed Of Light Throughput :: Duration (s)
- Launch Statistics :: Function Cache Configuration
- Launch Statistics :: Static Shared Memory Per Block (byte/block)
- Launch Statistics :: Enabled TPC IDs
