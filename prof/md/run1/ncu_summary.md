3 most important metrics to focus on: 

Compute (SM) Throughput % — ranges from 15% to 29% across kernels; this is the primary indicator of how well each PTX injection is actually utilizing the tensor cores. Higher = better PTX.


Achieved Occupancy % — reveals whether the PTX register pressure and shared memory footprint are limiting active warps. Low occupancy (32–37%) masks latency that better PTX layout could hide; fp16acc's 82% full-grid occupancy is the outlier worth explaining.

L1/TEX Cache Throughput % — actual bottleneck metric the OPT notes point directly at ("Start by analyzing L1"). Across the PTX variants, differences in how operands are staged through shared memory (via ldmatrix vs. manual scalar loads vs. triple-buffered cp.async) directly show up here. If L1/TEX is saturated, adding more pipeline stages or wider loads won't help — you need better coalescing or layout changes. It's more actionable than cycle counts and more specific to the shared-memory access patterns your PTX variants are testing.