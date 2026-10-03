#!/usr/bin/env python3
"""视觉审查工具：视频抽帧 / 前后对比图 / 多图接触表。

配套 comfyui-review 规范使用。只依赖 Pillow + ffmpeg/ffprobe。

用法：
    python review.py frames  <视频> <输出目录> [--count 9] [--cols 3] [--sheet 路径]
    python review.py compare <前> <后> --out <路径> [--label-before X --label-after Y] [--mode side|diff|both]
    python review.py sheet   <图片...> --out <路径> [--cols 3] [--title 标题] [--max-width 1600]

设计约束（写在前面，避免踩坑）：
  * 只写文件到磁盘，不通过管道抓子进程输出 —— 规避沙箱下 stdio 管道受限的问题。
  * 所有图片统一转 RGB，并限制单张与总输出尺寸，避免拼出上百 MB 的巨图。
  * 中文字体找不到时自动降级到 Pillow 内置字体（不报错，只标签变难看）。
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFont
except ImportError:
    sys.exit("缺少 Pillow。请先 pip install pillow，或用 load_workspace_dependencies 取捆绑 Python。")

# Windows 上 Python 默认按控制台代码页（cp936 等）输出，而 DSH 的 pwsh 工具按 UTF-8 读取，
# 结果就是中文全变乱码、审查结论不可读。这里强制 UTF-8，不依赖外部环境变量。
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

IMG_EXT = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"}

# 优先中文字体，逐个试；都没有就用内置位图字体
FONT_CANDIDATES = [
    r"C:\Windows\Fonts\msyh.ttc",      # 微软雅黑
    r"C:\Windows\Fonts\msyhl.ttc",
    r"C:\Windows\Fonts\simhei.ttf",    # 黑体
    r"C:\Windows\Fonts\arial.ttf",
    "/System/Library/Fonts/PingFang.ttc",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]


def load_font(size: int):
    for p in FONT_CANDIDATES:
        if Path(p).exists():
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()


def require(tool: str) -> str:
    p = shutil.which(tool)
    if not p:
        sys.exit(f"找不到 {tool}。视频相关操作需要 ffmpeg/ffprobe 在 PATH 上。")
    return p


def probe(video: Path) -> dict:
    ffprobe = require("ffprobe")
    out = subprocess.run(
        [ffprobe, "-v", "error", "-print_format", "json",
         "-show_format", "-show_streams", str(video)],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    if out.returncode != 0:
        sys.exit(f"ffprobe 读取失败：{out.stderr.strip()[:400]}")
    return json.loads(out.stdout or "{}")


def open_rgb(p: Path) -> Image.Image:
    if not p.exists():
        sys.exit(f"文件不存在：{p}")
    im = Image.open(p)
    if getattr(im, "is_animated", False):
        im.seek(0)
    return im.convert("RGB")


def fit(im: Image.Image, box_w: int, box_h: int) -> Image.Image:
    """等比缩放到不超过 box，不放大。"""
    r = min(box_w / im.width, box_h / im.height, 1.0)
    if r < 1.0:
        im = im.resize((max(1, int(im.width * r)), max(1, int(im.height * r))), Image.LANCZOS)
    return im


def band(width: int, height: int, text: str, size: int = 28) -> Image.Image:
    b = Image.new("RGB", (width, height), (24, 24, 28))
    d = ImageDraw.Draw(b)
    d.text((14, max(2, (height - size) // 2 - 2)), text, font=load_font(size), fill=(238, 238, 240))
    return b


# ── frames ──────────────────────────────────────────────────────────────────
def cmd_frames(a) -> None:
    video = Path(a.video)
    if not video.exists():
        sys.exit(f"视频不存在：{video}")
    require("ffmpeg")
    meta = probe(video)
    dur = float(meta.get("format", {}).get("duration") or 0)
    if dur <= 0:
        vs = next((s for s in meta.get("streams", []) if s.get("codec_type") == "video"), {})
        dur = float(vs.get("duration") or 0)
    if dur <= 0:
        sys.exit("无法确定视频时长，无法均匀抽帧。")

    vstream = next((s for s in meta.get("streams", []) if s.get("codec_type") == "video"), {})
    astream = next((s for s in meta.get("streams", []) if s.get("codec_type") == "audio"), None)

    outdir = Path(a.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    n = max(1, a.count)
    stamps = [dur * (i + 0.5) / n for i in range(n)]      # 均匀取每段中点，避开首尾黑帧
    frames = []
    for i, t in enumerate(stamps, 1):
        dst = outdir / f"frame_{i:03d}_{t:07.2f}s.png"
        r = subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-ss", f"{t:.3f}",
             "-i", str(video), "-frames:v", "1", "-y", str(dst)],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        if r.returncode == 0 and dst.exists():
            frames.append(dst)
        else:
            print(f"  ⚠️ {t:.2f}s 抽帧失败：{(r.stderr or '').strip()[:160]}", file=sys.stderr)

    print(f"视频: {video.name}")
    print(f"  时长 {dur:.2f}s | {vstream.get('width')}x{vstream.get('height')} | "
          f"{eval_fps(vstream):.2f} fps | 编码 {vstream.get('codec_name')}")
    if astream:
        print(f"  音频轨: {astream.get('codec_name')} / {astream.get('channels')} 声道 / "
              f"{astream.get('sample_rate')} Hz")
    else:
        print("  音频轨: 无")
    print(f"  抽出 {len(frames)} 帧 → {outdir}")

    if a.sheet and frames:
        sheet = build_sheet(frames, cols=a.cols, title=f"{video.name} · {dur:.2f}s · {len(frames)} 帧", max_w=a.max_width)
        sheet.save(a.sheet)
        print(f"  接触表 → {a.sheet}")

    # 机器可读摘要，便于报告引用
    print("META " + json.dumps({
        "file": video.name, "duration": round(dur, 3),
        "width": vstream.get("width"), "height": vstream.get("height"),
        "fps": round(eval_fps(vstream), 3), "video_codec": vstream.get("codec_name"),
        "audio": ({"codec": astream.get("codec_name"), "channels": astream.get("channels"),
                   "sample_rate": astream.get("sample_rate")} if astream else None),
        "frames": [f.name for f in frames],
    }, ensure_ascii=False))


def eval_fps(s: dict) -> float:
    raw = s.get("avg_frame_rate") or s.get("r_frame_rate") or "0/0"
    try:
        num, den = raw.split("/")
        den = float(den)
        return float(num) / den if den else 0.0
    except Exception:
        return 0.0


# ── compare ─────────────────────────────────────────────────────────────────
def cmd_compare(a) -> None:
    before, after = Path(a.before), Path(a.after)
    b_im, a_im = open_rgb(before), open_rgb(after)

    # 差异图：先统一尺寸（以 after 为准）
    diff_im = None
    if a.mode in ("diff", "both"):
        b2 = b_im.resize(a_im.size, Image.LANCZOS) if b_im.size != a_im.size else b_im
        diff = ImageChops.difference(b2, a_im)
        # 放大差异，否则几乎全黑看不出东西
        diff_im = diff.point(lambda v: min(255, v * 4))

    panels, labels = [], []
    if a.mode in ("side", "both"):
        panels += [b_im, a_im]
        labels += [a.label_before, a.label_after]
    if a.mode in ("diff", "both"):
        if not panels:                     # 纯 diff 模式也要有个参照
            panels += [a_im]
            labels += [a.label_after]
        panels += [diff_im]
        labels += ["差异（×4 增强）"]

    cell_w = a.cell_width
    cell_h = int(cell_w * 1.4)
    fitted = [fit(p, cell_w, cell_h) for p in panels]
    row_h = max(p.height for p in fitted)
    head_h, gap, pad = 40, 8, 12
    total_w = pad * 2 + sum(p.width for p in fitted) + gap * (len(fitted) - 1)
    total_h = pad * 2 + head_h + gap + row_h

    canvas = Image.new("RGB", (total_w, total_h), (16, 16, 18))
    d = ImageDraw.Draw(canvas)
    d.text((pad, pad // 2), a.title, font=load_font(24), fill=(240, 240, 245))

    x = pad
    y = pad + head_h + gap
    for p, lab in zip(fitted, labels):
        canvas.paste(p, (x, y))
        d.rectangle([x, y, x + p.width - 1, y + p.height - 1], outline=(70, 70, 78))
        lb = band(p.width, 30, lab, 20)
        canvas.paste(lb, (x, y - 30))
        x += p.width + gap

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, quality=92)
    print(f"前后对比图 → {out}  ({canvas.width}x{canvas.height})")
    print(f"  前: {before.name}  {b_im.width}x{b_im.height}")
    print(f"  后: {after.name}  {a_im.width}x{a_im.height}")
    if diff_im is not None:
        ext = diff_im.getextrema()
        changed = sum(1 for ch in ext if ch[1] > 8)
        print(f"  差异通道数（有可见变化的通道）: {changed}/3")


# ── sheet ───────────────────────────────────────────────────────────────────
def build_sheet(paths, cols: int, title: str, max_w: int) -> Image.Image:
    ims = [open_rgb(Path(p)) for p in paths]
    cols = max(1, min(cols, len(ims)))
    rows = (len(ims) + cols - 1) // cols
    cell = max(200, (max_w - 12 * (cols + 1)) // cols)
    cell_h = int(cell * 1.2)
    fitted = [fit(i, cell, cell_h) for i in ims]
    row_h = [max((fitted[r * cols + c].height for c in range(cols) if r * cols + c < len(fitted)), default=0)
             for r in range(rows)]
    head_h, pad, gap = (46 if title else 0), 12, 6
    total_w = pad * 2 + cell * cols + gap * (cols - 1)
    total_h = pad * 2 + head_h + sum(row_h) + gap * (rows - 1)

    canvas = Image.new("RGB", (total_w, total_h), (16, 16, 18))
    d = ImageDraw.Draw(canvas)
    if title:
        d.text((pad, pad // 2), title, font=load_font(24), fill=(240, 240, 245))

    y = pad + head_h
    for r in range(rows):
        x = pad
        for c in range(cols):
            i = r * cols + c
            if i >= len(fitted):
                break
            canvas.paste(fitted[i], (x, y))
            d.rectangle([x, y, x + fitted[i].width - 1, y + fitted[i].height - 1], outline=(64, 64, 72))
            x += cell + gap
        y += row_h[r] + gap
    return canvas


def cmd_sheet(a) -> None:
    paths = []
    for it in a.images:
        p = Path(it)
        if p.is_dir():
            paths += sorted(x for x in p.iterdir() if x.suffix.lower() in IMG_EXT)
        elif p.exists():
            paths.append(p)
        else:
            print(f"  ⚠️ 跳过不存在的路径：{p}", file=sys.stderr)
    if not paths:
        sys.exit("没有可用的图片。")
    sheet = build_sheet(paths, cols=a.cols, title=a.title or f"接触表 · {len(paths)} 张", max_w=a.max_width)
    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out, quality=92)
    print(f"接触表 → {out}  ({sheet.width}x{sheet.height}, {len(paths)} 张)")


def main() -> None:
    ap = argparse.ArgumentParser(description="视觉审查工具")
    sub = ap.add_subparsers(dest="cmd", required=True)

    f = sub.add_parser("frames", help="视频抽帧（+可选接触表）")
    f.add_argument("video")
    f.add_argument("outdir")
    f.add_argument("--count", type=int, default=9)
    f.add_argument("--cols", type=int, default=3)
    f.add_argument("--max-width", type=int, default=1600, dest="max_width")
    f.add_argument("--sheet", default=None)
    f.set_defaults(func=cmd_frames)

    c = sub.add_parser("compare", help="前后对比图")
    c.add_argument("before")
    c.add_argument("after")
    c.add_argument("--out", required=True)
    c.add_argument("--label-before", default="前（基准）", dest="label_before")
    c.add_argument("--label-after", default="后（本次）", dest="label_after")
    c.add_argument("--title", default="前后对比")
    c.add_argument("--mode", choices=["side", "diff", "both"], default="both")
    c.add_argument("--cell-width", type=int, default=620, dest="cell_width")
    c.set_defaults(func=cmd_compare)

    s = sub.add_parser("sheet", help="多图接触表")
    s.add_argument("images", nargs="+")
    s.add_argument("--out", required=True)
    s.add_argument("--cols", type=int, default=3)
    s.add_argument("--title", default=None)
    s.add_argument("--max-width", type=int, default=1600, dest="max_width")
    s.set_defaults(func=cmd_sheet)

    a = ap.parse_args()
    a.func(a)


if __name__ == "__main__":
    main()
