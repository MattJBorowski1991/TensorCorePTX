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
OUT_MD = os.path.join(ROOT, "prof", "txt", "run2", "charts.md")
OUT_DIR = os.path.join(ROOT, "prof", "txt", "run2", "charts_png")

KERNELS = [
    "int8_wmma",
    "int8_ptx_mma_k32",
    "int8_ptx_mma_k16",
    "int8_ptx_manual_pack",
    "int8_ptx_3stage",
    "int8_dp4a",
]
SIZES = ["512", "1024", "2048", "4096", "8192"]

PALETTE = ["#0B3A63", "#1F77B4", "#2A9D8F", "#E9C46A", "#F4A261", "#E76F51"]
MARKERS = ["o", "s", "^", "D", "v", "P"]


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


def make_png_charts(data, slowdown):
    os.makedirs(OUT_DIR, exist_ok=True)
    style()

    generated = OrderedDict()  # section -> [(metric title, rel path)]
    skipped = []

    for section, metrics in data.items():
        generated[section] = []

        for (metric_name, metric_unit), by_size in metrics.items():
            values = np.zeros((len(SIZES), len(KERNELS)), dtype=float)
            numeric = True

            for i, s in enumerate(SIZES):
                row = by_size.get(s, {})
                for j, k in enumerate(KERNELS):
                    raw = row.get(k, "")
                    if raw == "":
                        values[i, j] = 0.0
                        continue
                    f = parse_float(raw)
                    if f is None:
                        numeric = False
                        values[i, j] = 0.0
                    else:
                        values[i, j] = f

            metric_title = metric_name + (f" ({metric_unit})" if metric_unit else "")
            if not numeric:
                skipped.append(f"{section} :: {metric_title}")
                continue

            x = np.arange(len(SIZES), dtype=float)
            width = 0.12
            offsets = np.linspace(-2.5 * width, 2.5 * width, len(KERNELS))

            fig, ax = plt.subplots(figsize=(14.5, 6.6), dpi=150)

            # Bars
            for j, k in enumerate(KERNELS):
                ax.bar(
                    x + offsets[j],
                    values[:, j],
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

            ymax = float(np.max(values)) if values.size else 0.0
            if ymax <= 0:
                ymax = 1.0
            ax.set_ylim(0, ymax * 1.20)

            # Right axis for slowdown/speedup markers
            ax_r = ax.twinx()
            ax_r.spines["top"].set_visible(False)
            ax_r.spines["right"].set_color("#AAB4C0")
            ax_r.tick_params(axis="y", colors="#5A6675", labelsize=9)
            ax_r.set_ylabel("Duration vs int8_wmma (%)", color="#5A6675")
            ax_r.yaxis.set_major_formatter(ticker.FuncFormatter(lambda v, _: f"{v:+.0f}%"))
            ax_r.axhline(0.0, color="#5A6675", linewidth=1.0, linestyle=":", alpha=0.7, zorder=1)

            # Determine slowdown y-range from available values
            all_sd = [
                slowdown[s][k]
                for s in SIZES
                for k in KERNELS
                if slowdown[s].get(k) is not None
            ]
            if all_sd:
                lo = min(all_sd)
                hi = max(all_sd)
                pad = max(2.0, 0.12 * (hi - lo if hi != lo else abs(hi) + 1.0))
                ax_r.set_ylim(lo - pad, hi + pad)
            else:
                ax_r.set_ylim(-5, 5)

            # Marker overlays at each bar position
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

            # Legend below chart
            handles = [
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
            ax.legend(
                handles=handles,
                title="Kernel / slowdown marker",
                loc="upper center",
                bbox_to_anchor=(0.5, -0.21),
                ncol=3,
                fontsize=9,
                title_fontsize=10,
                frameon=True,
            )

            fig.tight_layout(rect=(0, 0.06, 1, 1))

            fname = f"{slugify(section)}__{slugify(metric_name + '_' + metric_unit)}.png"
            fpath = os.path.join(OUT_DIR, fname)
            fig.savefig(fpath, dpi=150, bbox_inches="tight")
            plt.close(fig)

            rel = os.path.join("charts_png", fname).replace("\\", "/")
            generated[section].append((metric_title, rel))

    return generated, skipped


def write_charts_md(generated, skipped):
    lines = []
    lines.append("# NCU Charts")
    lines.append("")
    lines.append("Source: ncu_txt_profiles_comparison.md")
    lines.append("")
    lines.append("Each metric has one PNG chart with grouped bars by matrix size and kernel order fixed left-to-right.")
    lines.append("")
    lines.append("Kernel order: int8_wmma, int8_ptx_mma_k32, int8_ptx_mma_k16, int8_ptx_manual_pack, int8_ptx_3stage, int8_dp4a.")
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

    with open(OUT_MD, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))


def main():
    data = parse_combined_md(IN_MD)
    duration_sec = build_duration_seconds(data)
    slowdown = build_slowdown_percent(duration_sec)
    generated, skipped = make_png_charts(data, slowdown)
    write_charts_md(generated, skipped)

    png_count = sum(len(v) for v in generated.values())
    print(f"Generated PNG charts: {png_count}")
    print(f"Skipped non-numeric metrics: {len(skipped)}")


if __name__ == "__main__":
    main()
