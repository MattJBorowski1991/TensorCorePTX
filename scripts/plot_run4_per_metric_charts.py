"""
Generate per-metric charts for run4 (int4_ptx_mma_k64 variants).
- 5 matrix sizes as x-axis clusters
- 6 kernels per cluster as bars (baseline: x4_x2nontrans_ca)
- Right axis: per-kernel markers showing % duration change vs baseline
- Auto-detect metrics needing normalization (non-comparable across sizes)
- Color palette and markers match run1 style
"""

from __future__ import annotations

import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D
import numpy as np


KERNELS = [
    "x4_x2nontrans_ca",
    "x1_x2nontrans_ca",
    "x2_x2nontrans_ca",
    "x4_x1nontrans_ca",
    "x4_x2nontrans_cg",
    "x4_x2trans_ca",
]
SIZES = ["512", "1024", "2048", "4096", "8192"]

# Run1 palette for consistency
PALETTE = {
    "x4_x2nontrans_ca": "#2196F3",    # blue
    "x1_x2nontrans_ca": "#4CAF50",    # green
    "x2_x2nontrans_ca": "#FF5722",    # orange
    "x4_x1nontrans_ca": "#9C27B0",    # purple
    "x4_x2nontrans_cg": "#FF9800",    # orange-ish
    "x4_x2trans_ca": "#00BCD4",       # cyan
}

MARKERS = {
    "x4_x2nontrans_ca": "o",
    "x1_x2nontrans_ca": "s",
    "x2_x2nontrans_ca": "^",
    "x4_x1nontrans_ca": "D",
    "x4_x2nontrans_cg": "v",
    "x4_x2trans_ca": "P",
}


@dataclass
class MetricTable:
    section: str
    metric_unit_by_name: Dict[str, str]
    values: Dict[str, Dict[str, str]]


def safe_float(value: str) -> float | None:
    if value is None:
        return None
    raw = value.strip()
    if not raw:
        return None
    # Markdown table cells for baseline values are bolded: **value**
    raw = raw.replace("**", "")
    raw = raw.replace(",", "")
    try:
        return float(raw)
    except ValueError:
        return None


def sanitize_filename(text: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "_", text)
    return re.sub(r"_+", "_", cleaned).strip("_")


def clean_kernel_name(name: str) -> str:
    return name.replace("**", "").strip()


def parse_tables(md_path: Path) -> Dict[str, Dict[str, MetricTable]]:
    """Parse markdown table structure per matrix size and section."""
    lines = md_path.read_text(encoding="utf-8").splitlines()
    matrix_data: Dict[str, Dict[str, MetricTable]] = {}

    current_size = None
    current_section = None
    i = 0
    while i < len(lines):
        line = lines[i].strip()

        m_size = re.match(r"^##\s+Matrix Size:\s+(\d+)x\1x\1$", line)
        if m_size:
            current_size = m_size.group(1)
            matrix_data.setdefault(current_size, {})
            current_section = None
            i += 1
            continue

        m_section = re.match(r"^###\s+(.+)$", line)
        if m_section and current_size:
            current_section = m_section.group(1).strip()
            i += 1
            continue

        if (
            current_size
            and current_section
            and line.startswith("| Metric Name | Metric Unit |")
        ):
            header_cells = [c.strip() for c in line.strip("|").split("|")]
            kernels = [clean_kernel_name(k) for k in header_cells[2:]]
            i += 2

            metric_unit_by_name: Dict[str, str] = {}
            values: Dict[str, Dict[str, str]] = {}

            while i < len(lines):
                row = lines[i].strip()
                if not row.startswith("|"):
                    break
                cells = [c.strip() for c in row.strip("|").split("|")]
                if len(cells) < 2:
                    i += 1
                    continue
                metric = cells[0]
                unit = cells[1]
                metric_unit_by_name[metric] = unit
                values.setdefault(metric, {})
                for idx, kernel in enumerate(kernels):
                    val = cells[idx + 2] if idx + 2 < len(cells) else ""
                    values[metric][kernel] = val
                i += 1

            matrix_data[current_size][current_section] = MetricTable(
                section=current_section,
                metric_unit_by_name=metric_unit_by_name,
                values=values,
            )
            continue

        i += 1

    return matrix_data


def collect_duration_change(
    matrix_data: Dict[str, Dict[str, MetricTable]],
) -> Dict[str, Dict[str, float]]:
    """Compute % duration change vs x4_x2nontrans_ca baseline for each kernel/size."""
    out: Dict[str, Dict[str, float]] = {}
    sol_section = "GPU Speed Of Light Throughput"
    baseline_kernel = "x4_x2nontrans_ca"
    
    for size in SIZES:
        out[size] = {}
        table = matrix_data.get(size, {}).get(sol_section)
        if not table or "Duration" not in table.values:
            for k in KERNELS:
                out[size][k] = math.nan
            continue

        duration_vals = {
            k: safe_float(table.values["Duration"].get(k, "")) for k in KERNELS
        }
        base = duration_vals.get(baseline_kernel)
        for k in KERNELS:
            v = duration_vals.get(k)
            if base is None or base == 0 or v is None:
                out[size][k] = math.nan
            else:
                out[size][k] = (v / base - 1.0) * 100.0

    return out


def all_metric_keys(
    matrix_data: Dict[str, Dict[str, MetricTable]],
) -> List[Tuple[str, str, str]]:
    """Collect all (section, metric, unit) tuples."""
    keys = []
    seen = set()
    for size in SIZES:
        sections = matrix_data.get(size, {})
        for section, table in sections.items():
            for metric, unit in table.metric_unit_by_name.items():
                key = (section, metric, unit)
                if key not in seen:
                    seen.add(key)
                    keys.append(key)
    return keys


def average_change_str(duration_change: Dict[str, Dict[str, float]], kernel: str) -> str:
    vals = [duration_change[s].get(kernel, math.nan) for s in SIZES]
    vals = [v for v in vals if not math.isnan(v)]
    if not vals:
        return "n/a"
    return f"{(sum(vals) / len(vals)):+.1f}%"


def should_normalize_metric(metric: str, unit: str, vals: np.ndarray) -> bool:
    """Detect if metric has non-comparable values across matrix sizes."""
    unit_l = (unit or "").strip().lower()
    metric_l = metric.strip().lower()

    # Metrics already in % or comparable units don't need normalization
    comparable_unit_keywords = {
        "%",
        "ghz",
        "mhz",
        "inst/cycle",
        "register/thread",
        "kbyte",
        "kbyte/block",
        "byte/block",
        "mbyte",
        "warp",
        "block",
        "sector",
    }
    if unit_l in comparable_unit_keywords:
        return False

    # Explicit metrics that scale wildly
    explicit_scale_metrics = (
        "elapsed cycles",
        "duration",
        "executed instructions",
        "issued instructions",
        "branch instructions",
        "threads",
        "total ",
        "average ",
    )
    if unit_l in {"cycle", "inst", "thread"}:
        return True
    if any(token in metric_l for token in explicit_scale_metrics):
        return True

    # Heuristic: if span across matrix sizes is large, normalize
    base_vals = vals[:, 0]
    finite = base_vals[np.isfinite(base_vals) & (base_vals > 0)]
    if finite.size >= 2:
        ratio = float(np.max(finite) / np.min(finite))
        if ratio >= 20.0:
            return True

    return False


def plot_all(
    matrix_data: Dict[str, Dict[str, MetricTable]],
    out_dir: Path,
) -> int:
    """Generate PNG for each metric with normalized/unnormalized bars + duration markers."""
    out_dir.mkdir(parents=True, exist_ok=True)
    duration_change = collect_duration_change(matrix_data)
    baseline_kernel = "x4_x2nontrans_ca"

    plt.rcParams.update({
        "font.family": "sans-serif",
        "font.sans-serif": ["DejaVu Sans", "Arial", "Liberation Sans"],
        "font.size": 9,
        "axes.titlesize": 11,
        "axes.titleweight": "bold",
        "axes.labelsize": 9,
        "axes.facecolor": "#FBFCFE",
        "figure.facecolor": "white",
        "axes.grid": True,
        "grid.alpha": 0.22,
        "grid.linestyle": "--",
        "axes.spines.top": False,
        "axes.spines.right": False,
        "legend.framealpha": 0.95,
        "legend.edgecolor": "#D9DFE7",
    })

    chart_count = 0
    normalized_count = 0

    for section, metric, unit in all_metric_keys(matrix_data):
        vals = np.full((len(SIZES), len(KERNELS)), np.nan, dtype=float)
        for si, size in enumerate(SIZES):
            table = matrix_data.get(size, {}).get(section)
            if not table:
                continue
            row = table.values.get(metric)
            if not row:
                continue
            for ki, kernel in enumerate(KERNELS):
                vals[si, ki] = safe_float(row.get(kernel, "")) or np.nan

        if np.isnan(vals).all():
            continue

        # Detect normalization need
        normalize_bars = should_normalize_metric(metric, unit, vals)
        plot_vals = vals.copy()
        
        if normalize_bars:
            normalized_count += 1
            for si in range(plot_vals.shape[0]):
                base = plot_vals[si, 0]
                if np.isfinite(base) and base != 0:
                    plot_vals[si, :] = (plot_vals[si, :] / base) * 100.0
                else:
                    plot_vals[si, :] = np.nan

        # Create figure
        fig, ax = plt.subplots(figsize=(16, 8))
        
        x = np.arange(len(SIZES))
        width = 0.13
        n_kernels = len(KERNELS)

        # Plot bars
        for ki, kernel in enumerate(KERNELS):
            offsets = x + (ki - n_kernels / 2 + 0.5) * width
            col = plot_vals[:, ki]
            mask = ~np.isnan(col)
            if mask.any():
                ax.bar(
                    (offsets)[mask],
                    col[mask],
                    width=width * 0.92,
                    color=PALETTE[kernel],
                    alpha=0.88,
                    label=kernel,
                    zorder=3,
                )

        ax.set_xticks(x)
        ax.set_xticklabels(SIZES)
        ax.set_xlabel("Matrix Size", fontsize=10, fontweight="bold")
        
        if normalize_bars:
            ax.set_ylabel(f"Relative to {baseline_kernel} (%)", fontsize=10, fontweight="bold")
        else:
            ax.set_ylabel(f"{metric} ({unit})", fontsize=10, fontweight="bold")
        
        ax.set_title(f"{section} / {metric} ({unit})", fontsize=12, fontweight="bold", pad=15)
        ax.grid(True, alpha=0.3, axis="y")

        # Right axis: duration change markers
        ax_r = ax.twinx()
        dur_min = []
        dur_max = []
        for si, size in enumerate(SIZES):
            dur_vals_at_size = [duration_change[size][k] for k in KERNELS]
            dur_finite = [d for d in dur_vals_at_size if np.isfinite(d)]
            if dur_finite:
                dur_min.append(min(dur_finite))
                dur_max.append(max(dur_finite))
        
        if dur_min and dur_max:
            dur_lo = min(dur_min)
            dur_hi = max(dur_max)
            dur_span = dur_hi - dur_lo if dur_hi != dur_lo else abs(dur_hi) + 1.0
            dur_pad = max(2.0, 0.12 * dur_span)
            ax_r.set_ylim(dur_lo - dur_pad, dur_hi + dur_pad)
        else:
            ax_r.set_ylim(-5, 5)

        # Plot per-kernel duration markers on the right axis (% vs baseline).
        # Add a faint connecting line plus prominent markers so they are always visible.
        for ki, kernel in enumerate(KERNELS):
            offsets = x + (ki - n_kernels / 2 + 0.5) * width
            dur_col = np.array([duration_change[size][kernel] for size in SIZES])
            mask = ~np.isnan(dur_col)
            if mask.any():
                ax_r.scatter(
                    (offsets)[mask],
                    dur_col[mask],
                    color=PALETTE[kernel],
                    marker=MARKERS[kernel],
                    s=120,
                    zorder=6,
                    edgecolors="#111111",
                    linewidths=0.9,
                )

        ax_r.axhline(0, color="#333333", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)
        ax_r.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.0f}%"))
        ax_r.set_ylabel("Duration change vs baseline (%)", color="#c62828", fontsize=10, fontweight="bold")
        ax_r.tick_params(axis="y", labelcolor="#c62828")
        ax_r.spines["right"].set_color("#e57373")

        # Duration-change legend below the chart.
        legend_labels = []
        for k in KERNELS:
            if k == baseline_kernel:
                legend_labels.append(f"{k} (ref +0.0%)")
            else:
                legend_labels.append(f"{k} (avg {average_change_str(duration_change, k)})")

        legend_lines = [
            Line2D([0], [0], marker=MARKERS[k], color=PALETTE[k], linestyle="None",
                   markerfacecolor=PALETTE[k], markeredgecolor="white", markeredgewidth=0.7,
                   markersize=7, label=legend_labels[i])
            for i, k in enumerate(KERNELS)
        ]

        fig.legend(
            handles=legend_lines,
            loc="lower center",
            bbox_to_anchor=(0.5, 0.06),
            ncol=3,
            fontsize=9,
            title="Kernel duration change vs baseline",
            framealpha=0.95,
        )

        # Add explicit normalization note below legend where applicable.
        if normalize_bars:
            fig.text(
                0.5,
                0.015,
                f"Bars are normalized to {baseline_kernel}=100% at each matrix size. "
                f"Nominal raw values remain in the source markdown table.",
                ha="center",
                va="bottom",
                fontsize=8,
                color="#444444",
            )

        plt.tight_layout(rect=[0, 0.20, 1, 1])

        filename = sanitize_filename(f"{section}_{metric}_{unit}") + ".png"
        filepath = out_dir / filename
        fig.savefig(filepath, dpi=150, bbox_inches="tight")
        plt.close(fig)

        chart_count += 1

    print(f"Generated {chart_count} charts ({normalized_count} normalized)")
    return chart_count


if __name__ == "__main__":
    MD_PATH = Path(r"c:\MattBorowski1991\CUDA\TensorCorePTX\prof\txt\run4\ncu_txt_profiles_comparison.md")
    OUT_DIR = Path(r"c:\MattBorowski1991\CUDA\TensorCorePTX\prof\charts\run4")

    matrix_data = parse_tables(MD_PATH)
    count = plot_all(matrix_data, OUT_DIR)
    print(f"Done: {count} PNG files written to {OUT_DIR}")
