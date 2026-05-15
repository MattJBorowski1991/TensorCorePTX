# INT8 Kernel Summaries — FP16 vs INT8 Differences

Each section covers one (FP16, INT8) pair and lists what changed.
`int8_dp4a` has no FP16 counterpart and is documented at the end.

---

## 1. `fp16_wmma` ↔ `int8_wmma`

**Summary.** WMMA-API double-buffered GEMM. INT8 keeps the same m16n16k16 tile shape and
double-buffer structure but switches element types, flips B's storage layout, and uses an
integer accumulator.

| Aspect | `fp16_wmma` | `int8_wmma` |
|---|---|---|
| A element type | `half` | `int8_t` |
| B element type | `half` | `int8_t` |
| SMEM B layout | `half Bs[2][WARPS][K][N]` — B stored K×N row-major | `int8_t Bs[2][WARPS][N][K]` — BT stored N×K row-major |
| WMMA B fragment layout | `row_major` | `col_major` (N×K row-major == K×N col-major in memory) |
| Accumulator type | `float` (`wmma::accumulator<float>`) | `int32_t` (`wmma::accumulator<int32_t>`) |
| cp.async transactions per tile | 32 (512 B tile, 16 B each) | 16 (256 B tile, 16 B each) |
| SMEM per buffer (As + Bs) | 8 × 16 × 16 × 2B × 2 = 8 KB | 8 × 16 × 16 × 1B × 2 = 4 KB |
| Epilogue | `wmma::store_matrix_sync` (float) | `wmma::store_matrix_sync` (int32_t) |

---

## 2. `fp16_ptx_mma` ↔ `int8_ptx_mma_k16`

**Summary.** Drop WMMA API in favor of explicit PTX: `ldmatrix` for SMEM→register, `mma.sync`
for the tensor core call, manual D-fragment scatter for the epilogue. INT8 halves the ldmatrix
width and switches every numeric type.

| Aspect | `fp16_ptx_mma` | `int8_ptx_mma_k16` |
|---|---|---|
| A element type | `half` | `int8_t` |
| SMEM B layout | `half Bs[WARPS][K][N]` (K×N row-major) | `int8_t Bs[WARPS][N][K]` (BT, N×K row-major) |
| ldmatrix A | `x4` → `ra[4]` (4 m8n8 b16 tiles, 512 B) | `x2` → `ra[2]` (2 m8n8 b16 tiles, 256 B) |
| ldmatrix B (per N-half) | `x2.trans` → `rb[2]` (2 m8n8 b16 tiles) | `x1.trans` → `rb[1]` (1 m8n8 b16 tile) |
| Lane addressing A | `_r = lane%16, _c = (lane/16)*8` | `_r = lane%16, _c = 0` |
| Lane addressing B | `_r = n_base + lane%8, _c = (lane/8%2)*8` | `_r = n_base + lane%8, _c = 0` |
| MMA opcode | `m16n8k16.row.col.f32.f16.f16.f32` | `m16n8k16.row.col.s32.s8.s8.s32` |
| Accumulator registers | `float rc0[4], rc1[4]` | `int32_t rc0[4], rc1[4]` |
| cp.async iterations per tile | 32 (512 B / 16 B) | 16 (256 B / 16 B) |
| Epilogue stores | `float` scatter | `int32_t` scatter, no dequant |

---

## 3. `fp16_ptx_k8` ↔ `int8_ptx_mma_k32`

**Summary.** Both explore an alternative K-extent for the mma.sync opcode.
`fp16_ptx_k8` steps *down* to k8 (m16n8k8 exists in FP16, not in INT8).
`int8_ptx_mma_k32` steps *up* to a 32-wide K tile (m16n8k32 exists in INT8, not in FP16).
Neither k8 (INT8) nor k32 (FP16) shapes exist in hardware — that asymmetry is why
the two files go in opposite K directions.

> **Implementation note.** The k32 kernel (`int8_ptx_mma_k32`) uses the
> native k32 path: `ldmatrix.x4` for A, `ldmatrix.x2` for each B n8-half, and
> `mma.sync.aligned.m16n8k32.row.col.s32.s8.s8.s32`.

| Aspect | `fp16_ptx_k8` | `int8_ptx_mma_k32` |
|---|---|---|
| K tile (WMMA_K) | 8 | 32 (`#undef WMMA_K` / `#define WMMA_K 32` after config.h) |
| MMA opcode | `m16n8k8.row.col.f32.f16.f16.f32` | `m16n8k32.row.col.s32.s8.s8.s32` |
| MMA calls per K-step | 4 (2 k-slices × 2 N-halves of the 16-wide tile) | 2 (one per N-half: n=0..7 and n=8..15) |
| ldmatrix A per K-step | 2 × `x2` (one per k8 sub-slice) → `ra[2]` each | 1 × `x4` → `ra[4]` |
| ldmatrix B per K-step | 4 × `x1.trans` (2 k-slices × 2 N-halves) | 2 × `x2` (one per N-half) → `rb0[2]`, `rb1[2]` |
| Lane addressing A | `_r = lane%16, _c = k_off` per x2 call (k_off ∈ {0,16}) | `_r = lane%16, _c = (lane/16)*16` |
| Lane addressing B | `_r = n_base + lane%8, _c = k_off` per x1.trans call (k_off ∈ {0,16}) | `_r = n_base + lane%8, _c = (lane/8)*16` |
| A element type | `half` | `int8_t` |
| SMEM tile (As or Bs) | `half[16][16]` = 512 B | `int8_t[16][32]` = 512 B (same size) |
| Register pressure | `ra[2]` live per sub-slice (lower, lower occupancy cost) | `ra[4]` + two `rb[2]` fragments live for native k32 MMA |
| Accumulator | `float rc[4]` | `int32_t rc[4]` |

---

## 4. `fp16_ptx_manual_pack` ↔ `int8_ptx_manual_pack`

**Summary.** Replace `ldmatrix` with explicit scalar shared-memory reads plus register packing.
For FP16 each pack combines 2 half values with a single `mov.b32 {h,h}`. For INT8 each pack
combines 4 int8 values requiring 3 `prmt.b32` instructions. Everything else — double-buffer
cp.async, the mma.sync call, the D-fragment epilogue scatter — is identical to the respective
k16 PTX baseline.

| Aspect | `fp16_ptx_manual_pack` | `int8_ptx_manual_pack` |
|---|---|---|
| Element type (A, B) | `half` | `int8_t` |
| SMEM B layout | `half Bs[WARPS][K][N]` | `int8_t Bs[WARPS][N][K]` (BT layout) |
| Pack function | `pack_half2(lo, hi)`: 1 × `mov.b32 {%h, %h}` | `pack_int8x4(b0,b1,b2,b3)`: 3 × `prmt.b32` (selectors 0x0040, 0x0040, 0x5410) |
| Scalar reads for ra[0] | 2 (each grabs one FP16 pair = 4 B consec.) | 4 (one int8 each) |
| Scalar reads for ra[1] | 2 | 4 |
| Scalar reads for rb[0] | 2 (k-strides for FP16 pairs) | 4 (one int8 each) |
| Total ld.shared per K-step | 6 per N-half (vs 2 ldmatrix instr for ldmatrix path) | 12 per N-half (vs 2 ldmatrix instr for ldmatrix path) |
| MMA opcode | `m16n8k16.f32.f16.f16.f32` | `m16n8k16.s32.s8.s8.s32` |
| Accumulator | `float rc[4]` | `int32_t rc[4]` |

---

## 5. `fp16_ptx_3stage` ↔ `int8_ptx_3stage`

**Summary.** Triple-buffered async pipeline: one cp.async group can still be in-flight while
the warp executes MMA on the previous buffer, hiding L2 latency beyond what the 2-stage
double-buffer achieves. The pipeline structure — prolog (2 commits + wait_group 1), main loop
(prefetch → commit → MMA → wait_group 1), epilogue (MMA + wait_group 0 + reload + MMA) — is
**identical** between FP16 and INT8. Only types and fragment widths change.

| Aspect | `fp16_ptx_3stage` | `int8_ptx_3stage` |
|---|---|---|
| A element type | `half` | `int8_t` |
| SMEM B layout | `half Bs[3][WARPS][K][N]` | `int8_t Bs[3][WARPS][N][K]` (BT, N×K row-major) |
| SMEM total (As + Bs combined) | 3 × 8 × 16 × 16 × 2B × 2 = **24 KB** | 3 × 8 × 16 × 16 × 1B × 2 = **12 KB** |
| ldmatrix A | `x4` → `ra[4]` | `x2` → `ra[2]` |
| ldmatrix B (per N-half) | `x2.trans` → `rb[2]` | `x1.trans` → `rb[1]` |
| cp.async loop iterations per stage | `i < M*K/8 = 32` (FP16: 2B/elem, 16B tx covers 8 elem) | `i < M*K/16 = 16` (INT8: 1B/elem, 16B tx covers 16 elem) |
| MMA opcode | `m16n8k16.row.col.f32.f16.f16.f32` | `m16n8k16.row.col.s32.s8.s8.s32` |
| Accumulator registers | `float rc0[4], rc1[4]` | `int32_t rc0[4], rc1[4]` |
| Pipeline structure | 3-stage (unchanged) | 3-stage (unchanged) |
| SMEM pressure benefit vs FP16 | — | 12 KB freed → more headroom for L1 cache or other stages |

---

## 6. `int8_dp4a` (no FP16 counterpart)

**Summary.** Scalar INT8 dot-product kernel using the `dp4a.s32.s32` PTX instruction. No
tensor cores. Each thread independently computes one output element `C[row][col]` by
accumulating `K/4` dot-products of 4-wide int8 packed registers. Intended as the baseline
above which all `mma.sync` / WMMA kernels should demonstrate speed-up.

| Aspect | Value |
|---|---|
| Instruction | `dp4a.s32.s32` — 4-way signed int8 dot product, int32 accumulator |
| Thread-to-output mapping | 1 thread → 1 output element |
| Block shape | 16 × 16 threads (256 total) |
| SMEM: A tile | `int8_t As[16][16+4]` (+4 columns pad, unused for A reads which broadcast) |
| SMEM: BT tile | `int8_t Bs[16][16+4]` (+4 pad → row stride 20 B, bank stride 5 → conflict-free on `Bs[tx][j]`) |
| Inner loop | 4 × `dp4a` per K-tile (BLOCK_K=16, 4 elements per dp4a) |
| No FP16 pair | `dp4a` is INT8-specific hardware (SM61+); FP16 equivalent would be scalar FFMA which exists but is not a separate kernel here |
