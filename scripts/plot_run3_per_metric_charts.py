from __future__ import annotations

import math
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np


KERNELS = [
    "int4_wmma",
    "int4_ptx_mma_k32",
    "int4_ptx_mma_k64",
    "int4_ptx_manual_pack",
    "int4_ptx_3stage",
]
SIZES = ["512", "1024", "2048", "4096", "8192"]


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
    raw = raw.replace(",", "")
    try:
        return float(raw)
    except ValueError:
        return None


def sanitize_filename(text: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "_", text)
    return re.sub(r"_+", "_", cleaned).strip("_")


def parse_tables(md_path: Path) -> Dict[str, Dict[str, MetricTable]]:
    lines = md_path.read_text(encoding="utf-8").splitlines()
    matrix_data: Dict[str, Dict[str, MetricTable]] = {}

    current_size = None
    current_section = None
    i = 0
    while i < len(lines):
        line = lines[i].strip()

        m_size = re.match(r"^##\s+Matrix Size\s+(\d+)x\1x\1$", line)
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
            kernels = header_cells[2:]
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
    out: Dict[str, Dict[str, float]] = {}
    sol_section = "GPU Speed Of Light Throughput"
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
        base = duration_vals.get("int4_wmma")
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


def should_normalize_metric(metric: str, unit: str, vals: np.ndarray) -> bool:
    unit_l = (unit or "").strip().lower()
    metric_l = metric.strip().lower()

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
    out_dir.mkdir(parents=True, exist_ok=True)
    duration_change = collect_duration_change(matrix_data)

    # Match run1 script palette order for visual consistency.
    colors = {
        "int4_wmma": "#2196F3",
        "int4_ptx_mma_k32": "#4CAF50",
        "int4_ptx_mma_k64": "#FF5722",
        "int4_ptx_manual_pack": "#9C27B0",
        "int4_ptx_3stage": "#FF9800",
    }
    markers = {
        "int4_wmma": "o",
        "int4_ptx_mma_k32": "s",
        "int4_ptx_mma_k64": "^",
        "int4_ptx_manual_pack": "D",
        "int4_ptx_3stage": "P",
    }

    chart_count = 0
    normalized_metric_count = 0
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

        normalize_bars = should_normalize_metric(metric, unit, vals)
        plot_vals = vals.copy()
        if normalize_bars:
            normalized_metric_count += 1
            for si in range(plot_vals.shape[0]):
                base = plot_vals[si, 0]
                if np.isfinite(base) and base != 0:
                    plot_vals[si, :] = (plot_vals[si, :] / base) * 100.0
                else:
                    plot_vals[si, :] = np.nan

        # Positive values indicate faster-than-baseline runtime.
        dur_vals = np.full((len(SIZES), len(KERNELS)), np.nan, dtype=float)
        for si, s in enumerate(SIZES):
            for ki, k in enumerate(KERNELS):
                dv = duration_change[s][k]
                dur_vals[si, ki] = -dv if not math.isnan(dv) else np.nan
        dur_vals = np.where(np.isfinite(dur_vals), np.maximum(dur_vals, 0.0), np.nan)

        fig, ax1 = plt.subplots(figsize=(16, 8))
        ax2 = ax1.twinx()

        x = np.arange(len(SIZES), dtype=float)
        # Keep bars slimmer and leave a small visible gap within each cluster.
        cluster_step = 0.16
        bar_width = 0.12
        offsets = np.linspace(-2 * cluster_step, 2 * cluster_step, len(KERNELS))

        for ki, kernel in enumerate(KERNELS):
            xpos = x + offsets[ki]
            ax1.bar(
                xpos,
                plot_vals[:, ki],
                width=bar_width,
                label=kernel,
                color=colors[kernel],
                alpha=0.9,
                edgecolor="black",
                linewidth=0.5,
            )

            dvals = dur_vals[:, ki]
            ax2.plot(
                xpos,
                dvals,
                linestyle="None",
                marker=markers[kernel],
                markersize=6,
                color=colors[kernel],
                markeredgecolor="black",
                markeredgewidth=0.6,
            )

        ax1.set_xticks(x)
        ax1.set_xticklabels(SIZES)
        ax1.set_xlabel("Matrix Size")
        if normalize_bars:
            ax1.set_ylabel("Metric Value Relative to int4_wmma (%)")
        else:
            ax1.set_ylabel(f"Metric Value ({unit})" if unit else "Metric Value")
        ax2.set_ylabel("Duration Improvement vs int4_wmma (%)", color="#c62828")
        ax2.tick_params(axis="y", labelcolor="#c62828")
        ax2.spines["right"].set_color("#e57373")
        ax1.grid(axis="y", linestyle="--", alpha=0.25)
        ax2.axhline(0.0, color="#333333", linestyle=":", linewidth=1)

        finite_dur = dur_vals[np.isfinite(dur_vals)]
        if finite_dur.size > 0:
            top = float(np.nanmax(finite_dur))
            top = max(top, 1.0)
            ax2.set_ylim(0.0, top * 1.12)
        else:
            ax2.set_ylim(0.0, 1.0)

        title = f"{section} | {metric}"
        if unit:
            title += f" [{unit}]"
        if normalize_bars:
            title += " | Bars normalized vs int4_wmma (=100)"
        ax1.set_title(title)

        baseline_note = None
        if normalize_bars:
            baseline_chunks = []
            for si, s in enumerate(SIZES):
                base_val = vals[si, 0]
                if np.isfinite(base_val):
                    baseline_chunks.append(f"{s}:{base_val:g}")
                else:
                    baseline_chunks.append(f"{s}:n/a")
            baseline_note = (
                "int4_wmma baseline nominal values by size -> "
                + ", ".join(baseline_chunks)
            )

        handles, labels = ax1.get_legend_handles_labels()
        ax1.legend(
            handles,
            labels,
            loc="upper center",
            bbox_to_anchor=(0.5, -0.08),
            ncol=5,
            frameon=False,
            title="Kernels",
        )

        if baseline_note:
            fig.text(
                0.5,
                0.055,
                baseline_note,
                ha="center",
                va="bottom",
                fontsize=9,
                color="#555555",
            )
            fig.tight_layout(rect=[0, 0.075, 1, 0.98])
        else:
            fig.tight_layout(rect=[0, 0.06, 1, 0.98])

        name = sanitize_filename(f"{section}__{metric}__{unit}")
        out_path = out_dir / f"{name}.png"
        fig.savefig(out_path, dpi=180)
        plt.close(fig)
        chart_count += 1

    print(
        f"Auto-normalized metrics (relative bars vs int4_wmma): {normalized_metric_count}"
    )
    return chart_count


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    md_path = repo_root / "prof" / "md" / "run3" / "ncu_txt_profiles_comparison.md"
    out_dir = repo_root / "prof" / "charts" / "run3"

    matrix_data = parse_tables(md_path)
    count = plot_all(matrix_data, out_dir)
    print(f"Generated {count} charts in: {out_dir}")


if __name__ == "__main__":
    main()