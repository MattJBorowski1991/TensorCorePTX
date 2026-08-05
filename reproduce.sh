#!/usr/bin/env bash
# SC26 artifact reproduction driver for TensorCorePTX.
#
# Usage:
#   ./reproduce.sh smoke    # 6 headline kernels, N<=2048, timing only  (~30-45 min)
#   ./reproduce.sh timing   # all 22 kernels, all 5 sizes, timing only  (~2-3 h)
#   ./reproduce.sh full     # timing + `ncu --set full` metric sweep    (many hours)
#
# Environment overrides:
#   CUDA_ARCH=89   target SM architecture (default 89 = Ada/L4)
#   OUT=results    output directory
#
# Requirements: Linux, CUDA toolkit (nvcc), CMake >= 3.24, an NVIDIA GPU;
# `full` mode additionally requires NVIDIA Nsight Compute (ncu) on PATH.
set -euo pipefail

MODE="${1:-smoke}"
CUDA_ARCH="${CUDA_ARCH:-89}"
OUT="${OUT:-results}"
BUILD_ROOT="build-repro"
JOBS="$(nproc 2>/dev/null || echo 4)"

ALL_KERNELS=(
    fp16_wmma
    fp16_ptx_mma_k16
    fp16_ptx_k8
    fp16_ptx_fp16acc
    fp16_ptx_3stage
    fp16_ptx_manual_pack
    int8_wmma
    int8_ptx_mma_k16
    int8_ptx_mma_k32
    int8_ptx_manual_pack
    int8_ptx_3stage
    int8_dp4a
    int4_wmma
    int4_ptx_mma_k32
    int4_ptx_manual_pack
    int4_ptx_3stage
    int4_ptx_mma_k64_x1_x2nontrans_ca
    int4_ptx_mma_k64_x2_x2nontrans_ca
    int4_ptx_mma_k64_x4_x1nontrans_ca
    int4_ptx_mma_k64_x4_x2nontrans_ca
    int4_ptx_mma_k64_x4_x2nontrans_cg
    int4_ptx_mma_k64_x4_x2trans_ca
)
SMOKE_KERNELS=(
    fp16_wmma
    int8_wmma
    int8_ptx_mma_k32
    int4_wmma
    int4_ptx_3stage
    int4_ptx_mma_k64_x4_x2nontrans_ca
)
ALL_SIZES=(512 1024 2048 4096 8192)
SMOKE_SIZES=(512 1024 2048)

case "$MODE" in
    smoke)  KERNELS=("${SMOKE_KERNELS[@]}"); SIZES=("${SMOKE_SIZES[@]}"); USE_NCU=0 ;;
    timing) KERNELS=("${ALL_KERNELS[@]}");   SIZES=("${ALL_SIZES[@]}");   USE_NCU=0 ;;
    full)   KERNELS=("${ALL_KERNELS[@]}");   SIZES=("${ALL_SIZES[@]}");   USE_NCU=1 ;;
    *) echo "usage: $0 [smoke|timing|full]" >&2; exit 1 ;;
esac

if [[ "$USE_NCU" == 1 ]] && ! command -v ncu >/dev/null 2>&1; then
    echo "ERROR: 'full' mode requires NVIDIA Nsight Compute (ncu) on PATH." >&2
    exit 1
fi

mkdir -p "$OUT" "$OUT/ncu"
echo "mode=$MODE  kernels=${#KERNELS[@]}  sizes=${SIZES[*]}  CUDA_ARCH=$CUDA_ARCH"

# ── T1 build + T2 verify + T3 measure ────────────────────────────────────────
for k in "${KERNELS[@]}"; do
    exe="$BUILD_ROOT/$k/profile_$k"

    echo "=== [$k] configure + build"
    cmake -B "$BUILD_ROOT/$k" -DKERNEL="$k" -DCUDA_ARCH="$CUDA_ARCH" \
        > "$OUT/${k}_build.log" 2>&1
    cmake --build "$BUILD_ROOT/$k" -j "$JOBS" >> "$OUT/${k}_build.log" 2>&1

    echo "=== [$k] verify (512^3 vs CPU reference)"
    # SKIP_PROFILE is honored by the int8/int4 binaries; the fp16 binary
    # additionally runs one cheap profiling pass at N=512.
    SKIP_PROFILE=1 PROFILE_SIZE=512 "$exe" > "$OUT/${k}_verify.txt" 2>&1
    grep '\[verify\]' "$OUT/${k}_verify.txt"
    if ! grep -q '\[verify\].*PASS' "$OUT/${k}_verify.txt"; then
        echo "VERIFICATION FAILED for $k — see $OUT/${k}_verify.txt" >&2
        exit 1
    fi

    for S in "${SIZES[@]}"; do
        echo "=== [$k] N=$S timing"
        PROFILE_SIZE="$S" "$exe" > "$OUT/${k}_${S}.txt" 2>&1
        grep '\[profile\]' "$OUT/${k}_${S}.txt" || true
        if [[ "$USE_NCU" == 1 ]]; then
            echo "=== [$k] N=$S ncu --set full"
            PROFILE_SIZE="$S" ncu --set full --target-processes all "$exe" \
                > "$OUT/ncu/${k}_ncu_${S}.txt" 2>&1
        fi
    done
done

# ── T4 analyze: collect [profile] lines and compute per-precision speedups ──
SUMMARY="$OUT/summary.csv"
echo "kernel,N,ms,tflops_or_tops" > "$SUMMARY"
for k in "${KERNELS[@]}"; do
    for S in "${SIZES[@]}"; do
        f="$OUT/${k}_${S}.txt"
        [[ -f "$f" ]] || continue
        ms=$(sed -n 's/.*| *\([0-9.]*\) ms avg.*/\1/p' "$f" | head -1)
        tf=$(sed -n 's/.*ms avg | *\([0-9.]*\) T.*/\1/p' "$f" | head -1)
        [[ -n "$ms" ]] && echo "$k,$S,$ms,$tf" >> "$SUMMARY"
    done
done

awk -F, 'NR==1 { next }
    { ms[$1","$2] = $3; kern[$1] = 1; sz[$2] = 1 }
    END {
        print "kernel,N,ms,baseline,baseline_ms,speedup_vs_baseline,speedup_vs_fp16_wmma"
        for (k in kern) {
            base = (k ~ /^int8_/) ? "int8_wmma" : (k ~ /^int4_/) ? "int4_wmma" : "fp16_wmma"
            for (s in sz) {
                key = k "," s
                if (!(key in ms)) continue
                bm  = (base "," s in ms)        ? ms[base "," s]        : ""
                fm  = ("fp16_wmma," s in ms)    ? ms["fp16_wmma," s]    : ""
                spb = (bm != "") ? sprintf("%.2f", bm / ms[key]) : ""
                spf = (fm != "") ? sprintf("%.2f", fm / ms[key]) : ""
                printf "%s,%s,%s,%s,%s,%s,%s\n", k, s, ms[key], base, bm, spb, spf
            }
        }
    }' "$SUMMARY" | sort -t, -k1,1 -k2,2n > "$OUT/speedups.csv"

echo
echo "Done. Wall-clock summary: $SUMMARY"
echo "Speedups vs per-precision WMMA baseline: $OUT/speedups.csv"
[[ "$USE_NCU" == 1 ]] && echo "NCU reports: $OUT/ncu/"
