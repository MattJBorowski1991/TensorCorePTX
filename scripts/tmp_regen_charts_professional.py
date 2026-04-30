import os
import re
from collections import OrderedDict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.lines import Line2D
import numpy as np

ROOT = r"c:\MattBorowski1991\CUDA\TensorCorePTX"
IN_MD = os.path.join(ROOT, "prof", "txt", "run2", "ncu_txt_profiles_comparison.md")
OUT_MD = os.path.join(ROOT, "prof", "charts", "run2", "CHARTS.md")
OUT_DIR = os.path.join(ROOT, "prof", "charts", "run2")

KERNELS = [
    "int8_wmma",
    "int8_ptx_mma_k32",
    "int8_ptx_mma_k16",
    "int8_ptx_manual_pack",
    "int8_ptx_3stage",
]
SIZES = ["512", "1024", "2048", "4096", "8192"]

PALETTE = ["#0B3A63", "#1F77B4", "#2A9D8F", "#E9C46A", "#F4A261"]
MARKERS = ["o", "s", "^", "D", "v"]

FACET_LOCAL_SCALE_METRICS = {
    "gpu_and_memory_workload_distribution__average_dram_active_cycles_cycle",
    "gpu_and_memory_workload_distribution__average_l1_active_cycles_cycle",
    "gpu_and_memory_workload_distribution__average_l2_active_cycles_cycle",
    "gpu_and_memory_workload_distribution__average_sm_active_cycles_cycle",
    "gpu_and_memory_workload_distribution__average_smsp_active_cycles_cycle",
    "gpu_and_memory_workload_distribution__total_dram_elapsed_cycles_cycle",
    "gpu_and_memory_workload_distribution__total_l1_elapsed_cycles_cycle",
    "gpu_and_memory_workload_distribution__total_l2_elapsed_cycles_cycle",
    "gpu_and_memory_workload_distribution__total_sm_elapsed_cycles_cycle",
    "gpu_and_memory_workload_distribution__total_smsp_elapsed_cycles_cycle",
    "gpu_speed_of_light_throughput__elapsed_cycles_cycle",
    "gpu_speed_of_light_throughput__sm_active_cycles_cycle",
    "instruction_statistics__executed_instructions_inst",
    "instruction_statistics__issued_instructions_inst",
    "source_counters__avg_divergent_branches_branches",
    "source_counters__branch_instructions_inst",
}

TIGHT_ZOOM_METRICS = {
    "gpu_speed_of_light_throughput__dram_frequency_ghz",
    "gpu_speed_of_light_throughput__sm_frequency_mhz",
    "gpu_speed_of_light_throughput__dram_throughput",
    "instruction_statistics__avg_executed_instructions_per_scheduler_inst",
    "instruction_statistics__avg_issued_instructions_per_scheduler_inst",
    "pm_sampling__maximum_sampling_interval_us",
}


def slugify(text: str) -> str:
    t = text.lower()
    t = re.sub(r"[^a-z0-9]+", "_", t).strip("_")
    return t[:140]


def parse_combined_md(path: str):
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    data = OrderedDict()  # section -> (metric_name, metric_unit) -> size -> kernel -> raw value

    cur_size = None
    cur_section = None
    in_table = False
    table_header_seen = False

    for raw in lines:
        line = raw.rstrip("\n")

        m_size = re.match(r"^##\s+Matrix Size\s+(\d+)x\1x\1\s*$", line)
        if m_size:
            cur_size = m_size.group(1)
            cur_section = None
            in_table = False
            table_header_seen = False
            continue

        m_sec = re.match(r"^###\s+(.+?)\s*$", line)
        if m_sec:
            cur_section = m_sec.group(1).strip()
            in_table = False
            table_header_seen = False
            continue

        if not cur_size or not cur_section:
            continue

        if re.match(r"^\|\s*Metric Name\s*\|\s*Metric Unit\s*\|", line):
            table_header_seen = True
            continue

        if table_header_seen and re.match(r"^\|[-\s|]+\|$", line):
            in_table = True
            table_header_seen = False
            continue

        if in_table:
            if not line.startswith("|"):
                in_table = False
                continue

            parts = [p.strip() for p in line.strip("|").split("|")]
            if len(parts) < 8:
                continue

            metric_name = parts[0]
            metric_unit = parts[1]
            metric_key = (metric_name, metric_unit)

            data.setdefault(cur_section, OrderedDict())
            data[cur_section].setdefault(metric_key, OrderedDict())
            data[cur_section][metric_key].setdefault(cur_size, OrderedDict())

            for i, k in enumerate(KERNELS):
                val = parts[2 + i]
                if val != "":
                    data[cur_section][metric_key][cur_size][k] = val

    return data


def parse_float(v: str):
    try:
        return float(v)
    except Exception:
        return None


def build_duration_seconds(data):
    section = "GPU Speed Of Light Throughput"
    duration_rows = {
        ("Duration", "us"): 1e-6,
        ("Duration", "ms"): 1e-3,
        ("Duration", "s"): 1.0,
    }

    duration_sec = {s: {} for s in SIZES}

    if section not in data:
        return duration_sec

    for metric_key, by_size in data[section].items():
        if metric_key not in duration_rows:
            continue
        mul = duration_rows[metric_key]
        for size in SIZES:
            size_vals = by_size.get(size, {})
            for k in KERNELS:
                if k in size_vals:
                    f = parse_float(size_vals[k])
                    if f is not None:
                        duration_sec[size][k] = f * mul

    return duration_sec


def build_slowdown_percent(duration_sec):
    slowdown = {s: {} for s in SIZES}
    for s in SIZES:
        base = duration_sec.get(s, {}).get("int8_wmma")
        for k in KERNELS:
            d = duration_sec.get(s, {}).get(k)
            if base is None or d is None or base == 0:
                slowdown[s][k] = None
            else:
                slowdown[s][k] = (d / base - 1.0) * 100.0
    return slowdown


def style():
    plt.rcParams.update(
        {
            "font.family": "sans-serif",
            "font.sans-serif": ["DejaVu Sans", "Arial", "Liberation Sans"],
            "font.size": 10,
            "axes.titlesize": 12,
            "axes.titleweight": "bold",
            "axes.labelsize": 10,
            "axes.facecolor": "#FBFCFE",
            "figure.facecolor": "white",
            "axes.grid": True,
            "grid.alpha": 0.22,
            "grid.linestyle": "--",
            "axes.spines.top": False,
            "axes.spines.right": False,
            "legend.framealpha": 0.95,
            "legend.edgecolor": "#D9DFE7",
        }
    )


def metric_slug(section: str, metric_name: str, metric_unit: str) -> str:
    return f"{slugify(section)}__{slugify(metric_name + '_' + metric_unit)}"


def get_metric_mode(metric_id: str) -> str:
    if metric_id in FACET_LOCAL_SCALE_METRICS:
        return "facet_local"
    if metric_id in TIGHT_ZOOM_METRICS:
        return "tight_zoom"
    return "default"


def compute_slowdown_limits(slowdown):
    all_sd = [
        slowdown[s][k]
        for s in SIZES
        for k in KERNELS
        if slowdown[s].get(k) is not None
    ]
    if not all_sd:
        return (-5.0, 5.0)

    lo = min(all_sd)
    hi = max(all_sd)
    span = hi - lo if hi != lo else abs(hi) + 1.0
    pad = max(2.0, 0.12 * span)
    return (lo - pad, hi + pad)


def build_legend_handles():
    return [
        Line2D(
            [0],
            [0],
            marker=MARKERS[j],
            color=PALETTE[j],
            linestyle="None",
            markerfacecolor=PALETTE[j],
            markeredgecolor="white",
            markeredgewidth=0.8,
            markersize=8,
            label=KERNELS[j],
        )
        for j in range(len(KERNELS))
    ]


def render_default_chart(fig, ax, values, metric_unit, section, metric_title, slowdown, x, width, offsets):
    for j, _ in enumerate(KERNELS):
        col = values[:, j]
        # only plot bars where data is present (skip NaN = missing NCU data)
        mask = ~np.isnan(col)
        if mask.any():
            ax.bar(
                (x + offsets[j])[mask],
                col[mask],
                width=width * 0.92,
                color=PALETTE[j],
                alpha=0.92,
                zorder=3,
            )

    ax.set_xticks(x)
    ax.set_xticklabels(SIZES)
    ax.set_xlabel("Matrix size (N x N)")
    ax.set_ylabel(metric_unit if metric_unit else "Value")
    ax.set_title(f"{section} - {metric_title}")

    finite_vals = values[np.isfinite(values)]
    ymax = float(np.max(finite_vals)) if finite_vals.size else 0.0
    ax.set_ylim(0, (1.0 if ymax <= 0 else ymax * 1.20))

    ax_r = ax.twinx()
    ax_r.spines["top"].set_visible(False)
    ax_r.spines["right"].set_color("#AAB4C0")
    ax_r.tick_params(axis="y", colors="#5A6675", labelsize=9)
    ax_r.set_ylabel("Duration vs int8_wmma (%)", color="#5A6675")
    ax_r.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.0f}%"))
    ax_r.axhline(0.0, color="#5A6675", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)
    ax_r.set_ylim(*compute_slowdown_limits(slowdown))

    for j, k in enumerate(KERNELS):
        xs = []
        ys = []
        for i, s in enumerate(SIZES):
            sd = slowdown[s].get(k)
            if sd is None:
                continue
            xs.append(x[i] + offsets[j])
            ys.append(sd)
        if xs:
            ax_r.scatter(
                xs,
                ys,
                marker=MARKERS[j],
                color=PALETTE[j],
                s=62,
                edgecolors="white",
                linewidths=0.8,
                zorder=6,
            )

    ax.legend(
        handles=build_legend_handles(),
        title="Kernel / slowdown marker",
        loc="upper center",
        bbox_to_anchor=(0.5, -0.21),
        ncol=3,
        fontsize=9,
        title_fontsize=10,
        frameon=True,
    )
    fig.tight_layout(rect=(0, 0.06, 1, 1))


def render_tight_zoom_chart(fig, ax, values, metric_unit, section, metric_title, slowdown, x, width, offsets):
    for j, _ in enumerate(KERNELS):
        col = values[:, j]
        mask = ~np.isnan(col)
        if mask.any():
            ax.bar(
                (x + offsets[j])[mask],
                col[mask],
                width=width * 0.92,
                color=PALETTE[j],
                alpha=0.92,
                zorder=3,
            )

    ax.set_xticks(x)
    ax.set_xticklabels(SIZES)
    ax.set_xlabel("Matrix size (N x N)")
    ax.set_ylabel(metric_unit if metric_unit else "Value")
    ax.set_title(f"{section} - {metric_title}")

    positive_vals = values[np.isfinite(values)]
    vmin = float(np.min(positive_vals)) if positive_vals.size else 0.0
    vmax = float(np.max(positive_vals)) if positive_vals.size else 1.0
    span = vmax - vmin
    if span <= 0:
        pad = max(abs(vmax) * 0.05, 1.0)
    else:
        pad = max(span * 0.15, abs(vmax) * 0.01)
    ymin = max(0.0, vmin - pad)
    ymax = vmax + pad
    if ymin == ymax:
        ymax = ymin + 1.0
    ax.set_ylim(ymin, ymax)

    ax_r = ax.twinx()
    ax_r.spines["top"].set_visible(False)
    ax_r.spines["right"].set_color("#AAB4C0")
    ax_r.tick_params(axis="y", colors="#5A6675", labelsize=9)
    ax_r.set_ylabel("Duration vs int8_wmma (%)", color="#5A6675")
    ax_r.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.0f}%"))
    ax_r.axhline(0.0, color="#5A6675", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)
    ax_r.set_ylim(*compute_slowdown_limits(slowdown))

    for j, k in enumerate(KERNELS):
        xs = []
        ys = []
        for i, s in enumerate(SIZES):
            sd = slowdown[s].get(k)
            if sd is None:
                continue
            xs.append(x[i] + offsets[j])
            ys.append(sd)
        if xs:
            ax_r.scatter(
                xs,
                ys,
                marker=MARKERS[j],
                color=PALETTE[j],
                s=62,
                edgecolors="white",
                linewidths=0.8,
                zorder=6,
            )

    ax.legend(
        handles=build_legend_handles(),
        title="Kernel / slowdown marker",
        loc="upper center",
        bbox_to_anchor=(0.5, -0.21),
        ncol=3,
        fontsize=9,
        title_fontsize=10,
        frameon=True,
    )
    fig.tight_layout(rect=(0, 0.06, 1, 1))


def render_facet_local_chart(fig, axes, values, metric_unit, section, metric_title, slowdown):
    slow_lo, slow_hi = compute_slowdown_limits(slowdown)
    x_local = np.arange(len(KERNELS), dtype=float)

    for i, size in enumerate(SIZES):
        ax_top = axes[0, i]
        ax_bot = axes[1, i]
        row_vals = values[i, :]

        ax_top.bar(
            x_local,
            np.where(np.isfinite(row_vals), row_vals, 0.0),
            color=PALETTE,
            alpha=0.92,
            width=0.78,
            zorder=3,
        )
        ax_top.set_title(f"N={size}")
        ax_top.set_xticks(x_local)
        ax_top.set_xticklabels([])
        finite_row = row_vals[np.isfinite(row_vals)]
        ymax = float(np.max(finite_row)) if finite_row.size else 0.0
        ax_top.set_ylim(0, (1.0 if ymax <= 0 else ymax * 1.18))

        if i == 0:
            ax_top.set_ylabel(metric_unit if metric_unit else "Value")

        sd_vals = [slowdown[size].get(k) for k in KERNELS]
        xs = [j for j, sd in enumerate(sd_vals) if sd is not None]
        ys = [sd for sd in sd_vals if sd is not None]
        ax_bot.axhline(0.0, color="#5A6675", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)
        if xs:
            for j, y in zip(xs, ys):
                ax_bot.scatter(
                    j,
                    y,
                    marker=MARKERS[j],
                    color=PALETTE[j],
                    s=70,
                    edgecolors="white",
                    linewidths=0.8,
                    zorder=5,
                )
        ax_bot.set_ylim(slow_lo, slow_hi)
        ax_bot.set_xticks(x_local)
        ax_bot.set_xticklabels([k.replace("int8_", "") for k in KERNELS], rotation=35, ha="right", fontsize=8)
        if i == 0:
            ax_bot.set_ylabel("vs wmma (%)")
            ax_bot.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.0f}%"))
        else:
            ax_bot.set_yticklabels([])

    fig.suptitle(f"{section} - {metric_title}", y=0.98, fontsize=12, fontweight="bold")
    fig.legend(
        handles=build_legend_handles(),
        title="Kernel / slowdown marker",
        loc="lower center",
        bbox_to_anchor=(0.5, -0.01),
        ncol=3,
        fontsize=9,
        title_fontsize=10,
        frameon=True,
    )
    fig.tight_layout(rect=(0, 0.07, 1, 0.95))


def make_png_charts(data, slowdown, output_dir=None):
    if output_dir is None:
        output_dir = OUT_DIR
    os.makedirs(output_dir, exist_ok=True)
    print(f"Chart output directory: {output_dir}")
    print(f"Directory exists: {os.path.isdir(output_dir)}")
    print(f"Directory writable: {os.access(output_dir, os.W_OK)}")
    style()

    generated = OrderedDict()  # section -> [(metric title, rel path)]
    skipped = []
    failed = []

    for section, metrics in data.items():
        generated[section] = []

        for (metric_name, metric_unit), by_size in metrics.items():
            values = np.full((len(SIZES), len(KERNELS)), np.nan, dtype=float)
            has_any_numeric = False
            all_non_numeric = False

            for i, s in enumerate(SIZES):
                row = by_size.get(s, {})
                for j, k in enumerate(KERNELS):
                    raw = row.get(k, "")
                    if raw == "":
                        continue  # stays NaN = missing data gap
                    f = parse_float(raw)
                    if f is None:
                        all_non_numeric = True  # non-parseable string value
                    else:
                        values[i, j] = f
                        has_any_numeric = True

            metric_title = metric_name + (f" ({metric_unit})" if metric_unit else "")
            if not has_any_numeric or all_non_numeric:
                skipped.append(f"{section} :: {metric_title}")
                continue

            metric_id = metric_slug(section, metric_name, metric_unit)
            mode = get_metric_mode(metric_id)

            x = np.arange(len(SIZES), dtype=float)
            width = 0.12
            offsets = np.linspace(-2.5 * width, 2.5 * width, len(KERNELS))

            if mode == "facet_local":
                fig, axes = plt.subplots(
                    2,
                    len(SIZES),
                    figsize=(18.5, 7.8),
                    dpi=150,
                    gridspec_kw={"height_ratios": [4.2, 1.6]},
                    sharex=False,
                )
                render_facet_local_chart(fig, axes, values, metric_unit, section, metric_title, slowdown)
            else:
                fig, ax = plt.subplots(figsize=(14.5, 6.6), dpi=150)
                if mode == "tight_zoom":
                    render_tight_zoom_chart(fig, ax, values, metric_unit, section, metric_title, slowdown, x, width, offsets)
                else:
                    render_default_chart(fig, ax, values, metric_unit, section, metric_title, slowdown, x, width, offsets)

            fname = f"{metric_id}.png"
            fpath = os.path.join(output_dir, fname)
            try:
                fig.savefig(fpath, dpi=150, bbox_inches="tight")
                plt.close(fig)
                rel = fname  # Just use the filename since it's in the same directory
                generated[section].append((metric_title, rel))
                print(f"  ✓ {metric_id}")
            except Exception as e:
                plt.close(fig)
                failed.append((metric_id, str(e)))
                print(f"  ✗ {metric_id}: {e}")

    return generated, skipped, failed


def write_charts_md(generated, skipped, failed, output_dir=None):
    if output_dir is None:
        output_dir = OUT_DIR
    
    out_md_path = os.path.join(output_dir, "CHARTS.md")
    
    lines = []
    lines.append("# NCU Charts")
    lines.append("")
    lines.append("Source: ncu_txt_profiles_comparison.md")
    lines.append("")
    lines.append("Each metric has one PNG chart with grouped bars by matrix size and kernel order fixed left-to-right.")
    lines.append("")
    lines.append("Kernel order: int8_wmma, int8_ptx_mma_k32, int8_ptx_mma_k16, int8_ptx_manual_pack, int8_ptx_3stage.")
    lines.append("")
    lines.append("Overlay symbols indicate duration speedup/slowdown (%) vs int8_wmma for the same matrix size (right axis).")
    lines.append("")

    for section, items in generated.items():
        if not items:
            continue
        lines.append(f"## {section}")
        lines.append("")
        for metric_title, rel in items:
            lines.append(f"### {metric_title}")
            lines.append("")
            lines.append(f"![{metric_title}]({rel})")
            lines.append("")

    if skipped:
        lines.append("## Non-Numeric Metrics (No PNG)")
        lines.append("")
        for s in skipped:
            lines.append(f"- {s}")
        lines.append("")

    if failed:
        lines.append("## Failed to Render (Errors)")
        lines.append("")
        for metric_id, error in failed:
            lines.append(f"- {metric_id}: {error}")
        lines.append("")

    with open(out_md_path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))


def main():
    # For run2, use prof/txt/run2/ncu_txt_profiles_comparison.md
    # For future runs, argument could accept input path
    input_file = 'prof/txt/run2/ncu_txt_profiles_comparison.md'
    output_dir = 'prof/charts/run2/'
    
    from pathlib import Path
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    data = parse_combined_md(input_file)
    duration_sec = build_duration_seconds(data)
    slowdown = build_slowdown_percent(duration_sec)
    generated, skipped, failed = make_png_charts(data, slowdown, output_dir)
    write_charts_md(generated, skipped, failed, output_dir)

    png_count = sum(len(v) for v in generated.values())
    print(f"\nGenerated PNG charts: {png_count}")
    print(f"Skipped non-numeric metrics: {len(skipped)}")
    if failed:
        print(f"Failed to render: {len(failed)}")
        for metric_id, error in failed[:5]:
            print(f"  - {metric_id}: {error}")


if __name__ == "__main__":
    main()
