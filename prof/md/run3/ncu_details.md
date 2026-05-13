# Run 3 - Int4 base kernels - comparison

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

---

## Performance Analysis — Why k64 and 3stage Win

### TLDR

**`int4_ptx_mma_k64`** and **`int4_ptx_3stage`** are the fastest kernels across all profiled sizes. At **512 and 1024**, `3stage` holds a narrow lead (56 µs vs 68 µs at N=512); from **2048 onward**, `k64` takes over decisively and extends its margin with problem size (167 ms vs 198 ms at N=8192 — a 15% gap that represents 30 ms of wall time).

The three root causes of `int4_wmma`'s 3.3–4.3× underperformance are:

| Root Cause | wmma | k64 / 3stage |
|---|---|---|
| Active threads/warp (N=8192) | **16.89** (53% fill) | **32** (100% fill) |
| Divergent branches (N=8192) | **4,610,118** | **0** |
| Avg. instructions/scheduler (N=8192) | **~295M** | **~45–46M** |

k64 and 3stage win because:
1. Every warp runs with all 32 threads active — no SIMT lane is ever idle.
2. Zero conditional branches → zero divergence → no serialized execution paths.
3. 6–7× fewer executed instructions compress the critical path across all units.
4. 54 registers/thread (vs 40 for wmma) enable larger tiled computation with less memory round-tripping.
5. **Root cause of points 2 and 3:** `wmma::experimental::precision::s4` is **software-emulated** — the compiler expands `load_matrix_sync`/`mma_sync` into dozens of per-lane nibble-extraction PTX instructions with lane-indexed conditionals (e.g. predicates on `lane_id % 2`, `lane_id / 8`). These conditionals diverge across the warp, simultaneously inflating the instruction count and creating the divergent branches. k64 and 3stage bypass the WMMA abstraction entirely and emit three native hardware instructions per K-step: `ldmatrix.sync.aligned.m8n8.x4.shared.b16`, and `mma.sync.aligned.m16n8k64.row.col.s32.s4.s4.s32` (×2 for two n8 halves) — each a single-cycle hardware operation with no per-lane conditionals.

![Avg. Active Threads Per Warp](../../charts/run3/Warp_State_Statistics_Avg._Active_Threads_Per_Warp.png)
![Avg. Divergent Branches](../../charts/run3/Source_Counters_Avg._Divergent_Branches_branches.png)
![Avg. Executed Instructions Per Scheduler](../../charts/run3/Instruction_Statistics_Avg._Executed_Instructions_Per_Scheduler_inst.png)

The **crossover from 3stage-wins to k64-wins at N≈2048** is driven by the memory hierarchy: 3stage's explicit prefetching pipeline exhausts L1 capacity at large sizes (L1 hit rate collapses to 14% at N=8192), forcing all traffic to L2. k64's balanced cache reuse keeps ~62% of L1 requests hitting locally, which becomes the deciding factor at scale.

---

### Detailed Analysis

#### 1. Kernel Duration

| Kernel | 512 (µs) | 1024 (ms) | 2048 (ms) | 4096 (ms) | 8192 (ms) |
|--------|----------|-----------|-----------|-----------|-----------|
| int4_wmma | 195.42 | 1.450 | 11.40 | 90.11 | 712.96 |
| int4_ptx_mma_k32 | 87.01 | 0.579 | 4.32 | 33.99 | 269.35 |
| int4_ptx_mma_k64 | 68.19 | 0.395 | **2.81** | **21.52** | **167.10** |
| int4_ptx_manual_pack | 87.84 | 0.611 | 4.61 | 35.55 | 277.13 |
| int4_ptx_3stage | **56.16** | **0.382** | 2.91 | 24.26 | 197.63 |

The performance gap between the top two kernels and the rest widens with problem size: at N=512, k64 is 2.9× faster than wmma; at N=8192 it is 4.3× faster — the relative speedup keeps growing.

---

#### 2. Warp Utilization — Active Threads Per Warp

![Avg. Active Threads Per Warp](../../charts/run3/Warp_State_Statistics_Avg._Active_Threads_Per_Warp.png)

The CUDA execution model groups 32 threads into a warp. If fewer than 32 are active, functional units sit idle. `int4_wmma` activates only **16–20 threads/warp** across all sizes — meaning 38–47% of compute capacity is wasted every single cycle.

k64 and 3stage maintain full warp occupancy regardless of problem size. wmma's active thread count actually *decreases* as N grows — suggesting its divergence-inducing control flow becomes a larger fraction of execution at scale.

---

#### 3. Warp Divergence

![Avg. Divergent Branches](../../charts/run3/Source_Counters_Avg._Divergent_Branches_branches.png)
![Branch Instructions Ratio](../../charts/run3/Source_Counters_Branch_Instructions_Ratio.png)

Divergent branches force the warp scheduler to serialize two or more execution paths — active thread count drops, and compute throughput collapses to a fraction of peak. At N=8192:

| Kernel | Avg. Divergent Branches |
|--------|------------------------|
| int4_wmma | 4,610,118 |
| int4_ptx_mma_k32 | 1,152,529 |
| int4_ptx_mma_k64 | **0** |
| int4_ptx_manual_pack | 1,152,529 |
| int4_ptx_3stage | **0** |

k64 and 3stage contain **zero divergent branches at every problem size**. The origin of wmma's divergence is architectural: `wmma::experimental::precision::s4` does not map to a single native hardware instruction. The PTX assembler emits a software-emulation path for `load_matrix_sync`/`mma_sync` that extracts nibbles from packed bytes using per-lane conditionals indexed by `lane_id % 2` and `lane_id / 8`. Because different lanes take different branches in the same warp, the warp scheduler must serialize those paths — this is the divergence NCU measures.

k64 and 3stage avoid this entirely by calling the native hardware instruction directly via inline PTX (`mma.sync.aligned.m16n8k64.row.col.s32.s4.s4.s32`), which has no per-lane branching. This is the single most impactful structural difference between the winning and losing kernels.

---

#### 4. Instruction Count

![Avg. Executed Instructions Per Scheduler](../../charts/run3/Instruction_Statistics_Avg._Executed_Instructions_Per_Scheduler_inst.png)
![Total Executed Instructions](../../charts/run3/Instruction_Statistics_Executed_Instructions_inst.png)

Fewer instructions reduce pressure on every downstream unit: the scheduler, the dispatch logic, the register file, and the memory subsystem. At N=8192 (average executed instructions per scheduler slot):

| Kernel | ~Avg Instrs/Scheduler |
|--------|-----------------------|
| int4_wmma | ~295M |
| int4_ptx_mma_k32 | ~81M |
| int4_ptx_mma_k64 | **~45M** |
| int4_ptx_manual_pack | ~79M |
| int4_ptx_3stage | **~46M** |

k64 and 3stage execute roughly **6.5× fewer instructions than wmma**. The instruction explosion in wmma shares the same root cause as its divergence (see §3): `wmma::experimental::precision::s4` is software-emulated. For each K-step, the compiler expands `load_matrix_sync` + `mma_sync` into tens of scalar PTX instructions per lane — byte loads, shifts, masks, and predicated moves — to unpack nibbles and feed the underlying hardware MMA unit.

In contrast, k64 and 3stage issue three native hardware instructions per K-step:

```ptx
ldmatrix.sync.aligned.m8n8.x4.shared.b16  {ra0,ra1,ra2,ra3}, [addr];  // load A tile
ldmatrix.sync.aligned.m8n8.x2.shared.b16  {rb0,rb1},         [addr];  // load B half
mma.sync.aligned.m16n8k64.row.col.s32.s4.s4.s32  {c0..c3}, {ra..}, {rb..}, {c0..c3};
```

Each is a single-cycle hardware operation with no per-lane branching. The SMEM-to-register loads and the tensor-core MMA fire in unison across all 32 lanes without any nibble-unpacking overhead.

---

#### 5. Warp Cycles Per Executed Instruction

![Warp Cycles Per Executed Instruction](../../charts/run3/Warp_State_Statistics_Warp_Cycles_Per_Executed_Instruction_cycle.png)

This metric counts how many cycles a warp stalls between consecutive issued instructions — a direct measure of pipeline stall depth. k64 is consistently the best or co-best across all sizes. 3stage is similarly low. wmma's cycle-per-instruction ratio improves at scale (because its long-latency stalls are increasingly hidden by its larger warp count) but never overcomes the damage done by its 6.5× higher instruction count.

---

#### 6. Register Allocation and Launch Geometry

![Registers Per Thread](../../charts/run3/Launch_Statistics_Registers_Per_Thread_register_thread.png)
![Waves Per SM](../../charts/run3/Launch_Statistics_Waves_Per_SM.png)

k64 and 3stage allocate **54 registers/thread**, versus 40 for wmma and 48 for k32/manual_pack. More registers allow the compiler to keep all MMA accumulator tiles and prefetch buffers live in the register file, eliminating shared-memory round-trips for intermediate results and enabling larger outer-product tiles per block.

The occupancy tradeoff is visible in **Waves Per SM** — more registers per thread means fewer concurrent blocks per SM, which increases the total wave count needed to drain the grid:

| Kernel | Waves/SM at N=8192 |
|--------|-------------------|
| int4_wmma | 1506.57 |
| int4_ptx_mma_k32 | ~530 |
| int4_ptx_mma_k64 | **564.97** |
| int4_ptx_manual_pack | ~530 |
| int4_ptx_3stage | **564.97** |

wmma's grid is launched with much smaller thread blocks — each computing a smaller tile — resulting in a 2.7× higher wave count. Each new wave pays cold-start costs (L1 miss on shared memory load, scheduler warm-up), compounding the overhead across 1500+ waves.

---

#### 7. Scheduler Efficiency

![No-Eligible Cycles](../../charts/run3/Scheduler_Statistics_No_Eligible.png)
![One-or-More Eligible](../../charts/run3/Scheduler_Statistics_One_or_More_Eligible.png)
![Issued Warp Per Scheduler](../../charts/run3/Scheduler_Statistics_Issued_Warp_Per_Scheduler.png)

The warp scheduler issues one instruction per eligible warp per cycle. The No-Eligible metric here is **counterintuitive**: wmma actually has the *lowest* No-Eligible fraction (45–51%), while k64 and 3stage have the *highest* (57–71%). This is a direct consequence of wmma's much larger active warp count per SM (11.3 vs 6.8 for k64 at N=512) — with more warps in flight, the scheduler can almost always find one that is ready, hiding latency through warp switching. k64 and 3stage deliberately run fewer warps per SM to support larger tiles and more registers, so the scheduler stalls more often. Yet they are still faster: the No-Eligible cycles are spent waiting on short, predictable memory latencies, whereas wmma's lower No-Eligible rate is sustained by burning through 6.5× more instructions per unit of useful work. Scheduler busyness is not throughput.

---

#### 8. Memory Hierarchy

![L1/TEX Hit Rate](../../charts/run3/Memory_Workload_Analysis_L1_TEX_Hit_Rate.png)
![L2 Hit Rate](../../charts/run3/Memory_Workload_Analysis_L2_Hit_Rate.png)
![L2 Cache Throughput](../../charts/run3/GPU_Speed_Of_Light_Throughput_L2_Cache_Throughput.png)
![Max Bandwidth](../../charts/run3/Memory_Workload_Analysis_Max_Bandwidth.png)

The memory behavior of k64 and 3stage diverges at large sizes, explaining the crossover in their relative performance.

**L1 Hit Rate at N=8192:**

| Kernel | L1 Hit Rate |
|--------|-------------|
| int4_wmma | 80.34% |
| int4_ptx_mma_k32 | 76.15% |
| int4_ptx_mma_k64 | 61.56% |
| int4_ptx_manual_pack | 66.06% |
| int4_ptx_3stage | **14.49%** |

3stage's explicit three-stage prefetch pipeline — while highly effective at small N — writes so many in-flight tiles into L1 at large N that the cache is saturated and hit rates collapse. The kernel compensates by saturating L2: its **L2 throughput grows from 19.5% utilization at N=512 to 95.6% at N=8192**, making 3stage an L2-bound kernel at scale.

k64 avoids this by maintaining better spatial locality in its access pattern: L1 hit rate stays at ~62% at N=8192, reducing L2 traffic and keeping more data close to the compute units. This L1/L2 balance is the decisive factor that pushes k64 ahead of 3stage at large problem sizes.

wmma maintains the highest L1 hit rate (~80%) because its small tile footprint fits comfortably in L1 — but this is a symptom of its *less ambitious* tiling strategy, not a strength. The tile is small *because* there are fewer registers available (40 vs 54), forcing more frequent global memory reloads that wmma partially hides behind its high warp count.

---

#### 9. Compute Throughput

![SM Busy](../../charts/run3/Compute_Workload_Analysis_SM_Busy.png)
![Issue Slots Busy](../../charts/run3/Compute_Workload_Analysis_Issue_Slots_Busy.png)
![Compute SM Throughput](../../charts/run3/GPU_Speed_Of_Light_Throughput_Compute_SM_Throughput.png)

k64 and 3stage achieve higher effective SM utilization via the compounding effect of all the factors above: full warp occupancy, zero divergence, low instruction overhead, and efficient register usage mean that issue slots are productive rather than wasted serializing divergent paths or waiting on stalled warps.

---

#### 10. Occupancy

![Achieved Occupancy](../../charts/run3/Occupancy_Achieved_Occupancy.png)
![Theoretical Occupancy](../../charts/run3/Occupancy_Theoretical_Occupancy.png)

The 54-register allocation of k64 and 3stage reduces theoretical occupancy compared to wmma's 40-register count. This is a **deliberate architectural tradeoff**: despite running fewer concurrent warps per SM, the combination of full-warp execution, zero divergence, and optimized tiling delivers 3–4× higher throughput. This result is a textbook illustration of the fact that **maximizing occupancy is not the optimization target — maximizing throughput is**. Occupancy is only a proxy for throughput when warps are otherwise identical; here they are not.

---

### Summary of Key Takeaways

| # | Finding |
|---|---------|
| 1 | **Warp efficiency beats raw occupancy.** wmma has higher occupancy but consistently loses because its warps run at 50–63% thread fill with heavy divergence. |
| 2 | **`wmma::experimental::precision::s4` is software-emulated — this is the root cause of both the divergent branches and the 6.5× instruction count.** The PTX assembler expands `load_matrix_sync`/`mma_sync` into per-lane nibble-extraction code with `lane_id`-indexed conditionals. k64/3stage call the native `mma.sync.aligned.m16n8k64.s4` instruction directly, bypassing the abstraction entirely. |
| 3 | **Zero divergence is a prerequisite for peak MMA throughput.** Every divergent branch serializes warp execution paths, destroying the SIMT model that tensor cores depend on. |
| 4 | **Register investment pays off.** The extra 14 registers in k64/3stage (54 vs 40) enable larger tiles and register-blocked computation, reducing memory traffic at the cost of a tolerable occupancy reduction. |
| 5 | **3stage wins at small sizes; k64's cache balance wins at large sizes.** The crossover is L1 capacity exhaustion: 3stage's aggressive prefetching exceeds the L1 footprint beyond N≈1024, driving all traffic to L2 and erasing its advantage over k64. |
| 6 | **Launch geometry amplifies the gap.** k64/3stage's 2.7× smaller wave count reduces amortized block launch and cold-start costs, benefiting every size. |
| 7 | **Instruction count dominates wall time.** k32 and manual_pack improve on wmma in warp utilization and divergence, yet still execute 1.7–1.8× more instructions than k64/3stage — confirming that raw arithmetic density, not memory or scheduler effects, is the primary differentiator at the top. |
