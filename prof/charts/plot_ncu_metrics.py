"""
Generate a single professional figure (2x2 subplots) from the NCU multiple-sizes table.
Output: prof/md/run1/ncu_metrics_chart.png
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

# ── Data ─────────────────────────────────────────────────────────────────────
sizes = [512, 1024, 2048, 4096, 8192, 16384]

kernels = [
    "fp16_wmma",
    "fp16_ptx_mma",
    "fp16_ptx_k8",
    "fp16_ptx_fp16acc",
    "fp16_ptx_3stage",
    "fp16_ptx_manual_pack",
]

duration = {
    "fp16_wmma":           [0.000185, 0.001430, 0.011850, 0.102350, 1.650000, 13.640000],
    "fp16_ptx_mma":        [0.000188, 0.001450, 0.012210, 0.104300, 1.660000, 13.670000],
    "fp16_ptx_k8":         [0.000193, 0.001470, 0.012000, 0.103170, 1.660000, 13.660000],
    "fp16_ptx_fp16acc":    [0.000188, 0.001440, 0.011930, 0.103410, 1.710000, 13.940000],
    "fp16_ptx_3stage":     [0.000185, 0.001430, 0.012190, 0.106630, 1.740000, 14.170000],
    "fp16_ptx_manual_pack":[0.000226, 0.001720, 0.013470, 0.107560, 1.680000, 13.810000],
}

gflops = {
    "fp16_wmma":           [1451.00, 1501.06, 1450.64, 1342.53,  666.37,  644.72],
    "fp16_ptx_mma":        [1428.28, 1480.34, 1407.53, 1317.88,  662.37,  643.53],
    "fp16_ptx_k8":         [1391.03, 1460.20, 1431.66, 1332.59,  662.37,  643.93],
    "fp16_ptx_fp16acc":    [1428.28, 1491.77, 1440.15, 1329.40,  642.66,  631.05],
    "fp16_ptx_3stage":     [1451.00, 1501.06, 1409.43, 1288.98,  631.71,  620.58],
    "fp16_ptx_manual_pack":[1188.59, 1248.54, 1275.13, 1277.41,  654.10,  636.65],
}

compute_pct = {
    "fp16_wmma":           [37.13, 36.69, 34.48, 31.65, 15.59, 15.07],
    "fp16_ptx_mma":        [39.87, 39.43, 36.61, 33.89, 16.94, 16.41],
    "fp16_ptx_k8":         [47.49, 48.30, 46.53, 42.78, 21.17, 20.50],
    "fp16_ptx_fp16acc":    [39.78, 39.62, 37.36, 34.16, 16.45, 16.09],
    "fp16_ptx_3stage":     [37.86, 38.67, 35.54, 32.86, 16.06, 15.79],
    "fp16_ptx_manual_pack":[56.07, 57.04, 57.50, 57.18, 29.20, 28.37],
}

occupancy_pct = {
    "fp16_wmma":           [59.45, 63.81, 64.72, 65.59, 66.19, 66.33],
    "fp16_ptx_mma":        [58.85, 63.47, 65.02, 65.59, 66.20, 66.33],
    "fp16_ptx_k8":         [58.06, 63.61, 64.73, 65.38, 66.18, 66.31],
    "fp16_ptx_fp16acc":    [70.60, 79.05, 82.34, 82.09, 82.48, 82.72],
    "fp16_ptx_3stage":     [56.60, 63.18, 64.27, 64.29, 64.40, 64.40],
    "fp16_ptx_manual_pack":[57.58, 63.39, 64.83, 65.19, 66.14, 66.29],
}

l1_pct = {
    "fp16_wmma":           [92.74, 94.26, 88.02, 81.26, 39.28, 38.08],
    "fp16_ptx_mma":        [93.07, 93.16, 85.93, 80.70, 39.20, 38.02],
    "fp16_ptx_k8":         [90.02, 92.96, 87.67, 80.78, 39.22, 38.03],
    "fp16_ptx_fp16acc":    [93.03, 94.22, 88.40, 80.93, 38.08, 37.30],
    "fp16_ptx_3stage":     [94.50, 94.44, 84.73, 81.53, 38.04, 38.69],
    "fp16_ptx_manual_pack":[87.82, 89.90, 89.57, 88.67, 44.23, 43.02],
}

# ── Style ─────────────────────────────────────────────────────────────────────
PALETTE = [
    "#2196F3",  # blue
    "#4CAF50",  # green
    "#FF5722",  # deep orange
    "#9C27B0",  # purple
    "#FF9800",  # amber
    "#00BCD4",  # cyan
]

MARKERS = ["o", "s", "^", "D", "v", "P"]
LINEWIDTH = 2.0
MARKERSIZE = 7

plt.rcParams.update({
    "font.family": "sans-serif",
    "font.size": 11,
    "axes.titlesize": 12,
    "axes.titleweight": "bold",
    "axes.labelsize": 11,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.grid": True,
    "grid.alpha": 0.35,
    "grid.linestyle": "--",
    "legend.framealpha": 0.9,
    "legend.edgecolor": "#cccccc",
    "figure.facecolor": "white",
    "axes.facecolor": "#f9f9f9",
})

# ── Figure ────────────────────────────────────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(16, 11), sharex=True)
fig.suptitle(
    "FP16 GEMM Kernels — Nsight Compute Comparison across Matrix Sizes",
    fontsize=15, fontweight="bold", y=1.01,
)

x = np.array(sizes)

def _plot(ax, data_dict, ylabel, title, logy=False, ylim=None):
    for i, k in enumerate(kernels):
        label = k.replace("fp16_", "")
        ax.plot(x, data_dict[k], color=PALETTE[i], marker=MARKERS[i],
                linewidth=LINEWIDTH, markersize=MARKERSIZE, label=label)
    ax.set_xscale("log", base=2)
    ax.set_xticks(sizes)
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{int(v):,}"))
    if logy:
        ax.set_yscale("log")
        ax.yaxis.set_major_formatter(ticker.FuncFormatter(
            lambda v, _: f"{v:.2e}" if v < 0.001 else f"{v:.4f}" if v < 1 else f"{v:.2f}"
        ))
    if ylim:
        ax.set_ylim(ylim)
    ax.set_ylabel(ylabel)
    ax.set_title(title)

# Subplot 1 — GFLOPS
_plot(axes[0, 0], gflops, "GFLOPS", "Peak GFLOPS")
axes[0, 0].set_xlabel("")

# Subplot 2 — Relative speedup vs fp16_wmma (baseline = 1.0×)
baseline_k = "fp16_wmma"
speedup = {
    k: [duration[baseline_k][i] / duration[k][i] for i in range(len(sizes))]
    for k in kernels
}
_plot(axes[0, 1], speedup, "Speedup vs fp16_wmma  (×)", "Kernel Speedup  [baseline = fp16_wmma = 1.0×]")
axes[0, 1].axhline(1.0, color="black", linewidth=1.0, linestyle=":", alpha=0.6)
axes[0, 1].set_xlabel("")

# Subplot 3 — Compute % and Occupancy %
for i, k in enumerate(kernels):
    label = k.replace("fp16_", "")
    axes[1, 0].plot(x, compute_pct[k], color=PALETTE[i], marker=MARKERS[i],
                    linewidth=LINEWIDTH, markersize=MARKERSIZE, label=label)
    axes[1, 0].plot(x, occupancy_pct[k], color=PALETTE[i], marker=MARKERS[i],
                    linewidth=LINEWIDTH * 0.6, markersize=MARKERSIZE * 0.7,
                    linestyle="--", alpha=0.6)
axes[1, 0].set_xscale("log", base=2)
axes[1, 0].set_xticks(sizes)
axes[1, 0].xaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{int(v):,}"))
axes[1, 0].set_ylim(0, 105)
axes[1, 0].set_ylabel("Utilization (%)")
axes[1, 0].set_xlabel("Matrix Size (N×N)")
axes[1, 0].set_title("Compute SM Throughput (solid) & Achieved Occupancy (dashed)")

# Subplot 4 — L1/TEX %
_plot(axes[1, 1], l1_pct, "L1/TEX Cache Throughput (%)", "L1/TEX Cache Throughput", ylim=(0, 105))
axes[1, 1].set_xlabel("Matrix Size (N×N)")

# ── Shared legend ─────────────────────────────────────────────────────────────
handles, labels = axes[0, 0].get_legend_handles_labels()
fig.legend(
    handles, labels,
    title="Kernel",
    loc="lower center",
    ncol=6,
    bbox_to_anchor=(0.5, -0.04),
    fontsize=10,
    title_fontsize=11,
)

fig.tight_layout()
fig.savefig(
    r"c:\MattBorowski1991\CUDA\TensorCorePTX\prof\md\run1\ncu_metrics_chart.png",
    dpi=150, bbox_inches="tight",
)
print("Saved: prof/md/run1/ncu_metrics_chart.png")
