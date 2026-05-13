"""
Generate a single professional figure (2x2 subplots) from the NCU multiple-sizes table.

Each subplot:  left axis  = grouped bar chart for one metric
               right axis = duration scatter dots (log scale, same kernel colours)

Subplots:
  (0,0) Peak GFLOPS              (0,1) Compute (SM) Throughput %
  (1,0) Achieved Occupancy %     (1,1) L1/TEX Cache Throughput %

Output: prof/md/run1/ncu_metrics_chart.png
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

sizes   = [512, 1024, 2048, 4096, 8192, 16384]
xlabels = ["512", "1K", "2K", "4K", "8K", "16K"]

kernels = [
    "fp16_wmma",
    "fp16_ptx_mma",
    "fp16_ptx_k8",
    "fp16_ptx_fp16acc",
    "fp16_ptx_3stage",
    "fp16_ptx_manual_pack",
]
short = ["wmma", "ptx_mma", "ptx_k8", "ptx_fp16acc", "ptx_3stage", "ptx_pack"]

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

PALETTE = ["#2196F3", "#4CAF50", "#FF5722", "#9C27B0", "#FF9800", "#00BCD4"]
MARKERS = ["o", "s", "^", "D", "v", "P"]
BAR_W   = 0.13

plt.rcParams.update({
    "font.family": "sans-serif",
    "font.size": 10,
    "axes.titlesize": 12,
    "axes.titleweight": "bold",
    "axes.labelsize": 10,
    "axes.spines.top": False,
    "axes.grid": True,
    "grid.alpha": 0.30,
    "grid.linestyle": "--",
    "figure.facecolor": "white",
    "axes.facecolor": "#f9f9f9",
})

# % slowdown of each kernel vs fp16_wmma baseline (positive = slower)
baseline = "fp16_wmma"
slowdown = {
    k: [(duration[k][i] / duration[baseline][i] - 1.0) * 100.0
        for i in range(len(sizes))]
    for k in kernels
}

def make_panel(ax, bar_data, left_ylabel, title, left_ylim=None):
    n      = len(kernels)
    x_base = np.arange(len(sizes))
    for i, (k, s) in enumerate(zip(kernels, short)):
        offsets = x_base + (i - n / 2 + 0.5) * BAR_W
        ax.bar(offsets, bar_data[k], width=BAR_W * 0.88,
               color=PALETTE[i], label=s, zorder=3, alpha=0.88)
    ax.set_xticks(x_base)
    ax.set_xticklabels(xlabels)
    ax.set_ylabel(left_ylabel)
    ax.set_title(title)
    if left_ylim:
        ax.set_ylim(left_ylim)
    ax.spines["right"].set_visible(False)
    ax.axvline(3.5, color="#e53935", linewidth=1.2, linestyle="--", alpha=0.55, zorder=2)
    ax_r = ax.twinx()
    ax_r.set_ylim(-2, 25)
    # baseline zero line
    ax_r.axhline(0, color="#333333", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)
    for i, k in enumerate(kernels):
        offsets = x_base + (i - n / 2 + 0.5) * BAR_W
        ax_r.scatter(offsets, slowdown[k],
                     color=PALETTE[i], marker=MARKERS[i],
                     s=65, zorder=5, edgecolors="white", linewidths=0.7)
    ax_r.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.1f}%"))
    ax_r.set_ylabel("Duration slowdown vs wmma  (right axis)", color="#c62828", fontsize=9)
    ax_r.tick_params(axis="y", labelcolor="#c62828", labelsize=8)
    ax_r.spines["top"].set_visible(False)
    ax_r.spines["right"].set_color("#e57373")
    return ax_r

fig, axes = plt.subplots(2, 2, figsize=(20, 13))
fig.suptitle(
    "FP16 GEMM Kernels - Nsight Compute Profile Comparison\n"
    "Bars = metric value (left axis)  |  Dots = % slowdown vs fp16_wmma (right axis)  |  Red dashed = L2 cliff",
    fontsize=13, fontweight="bold", y=1.02,
)

make_panel(axes[0, 0], gflops,        "GFLOPS",                    "Peak GFLOPS",             left_ylim=(0, 1750))
make_panel(axes[0, 1], compute_pct,   "Compute (SM) Throughput %", "Compute (SM) Throughput", left_ylim=(0, 70))
make_panel(axes[1, 0], occupancy_pct, "Achieved Occupancy %",      "Achieved Occupancy",      left_ylim=(0, 100))
make_panel(axes[1, 1], l1_pct,        "L1/TEX Cache Throughput %", "L1/TEX Cache Throughput", left_ylim=(0, 110))

for ax in axes[1]:
    ax.set_xlabel("Matrix Size (N x N)")

handles, labels = axes[0, 0].get_legend_handles_labels()
fig.legend(handles, labels,
           title="Kernel", loc="lower center", ncol=6,
           bbox_to_anchor=(0.5, -0.03),
           fontsize=10, title_fontsize=11,
           framealpha=0.92, edgecolor="#cccccc")

fig.tight_layout()
fig.savefig(
    r"c:\MattBorowski1991\CUDA\TensorCorePTX\prof\md\run1\ncu_metrics_chart.png",
    dpi=150, bbox_inches="tight",
)
print("Saved: prof/md/run1/ncu_metrics_chart.png")
