## Deep Dive on Best Kernel (k64)

### Goal

Tune only the winning kernel variant family and quantify relative deltas.

### Factor Space

- A loader (xi): x4, x2, x1
- B loader (xj): x2, x1
- B layout mode: nontrans, trans
- cp.async policy: ca, cg

### Baseline for Deltas

- Baseline variant: int4_ptx_mma_k64_x4_x2nontrans_ca, which is the same kernel as int4_ptx_mma_k64 in run3. 
