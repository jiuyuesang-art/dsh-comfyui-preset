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
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageStat
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


# ── audit ───────────────────────────────────────────────────────────────────
#
# 为什么要有这一步：审查报告里的每一行结论都必须能指向**看得见的证据**（§0 红线②）。
# 但"主体漂移 / 风格不一致 / 视频跳变"这类判断，只靠肉眼看图很容易写成印象。
# 这里把它们先变成**数字**（哈希 / 差异百分比 / 变化区域 / 灰度与熵 / 调色板偏移 /
# 相邻帧差），模型再据此下判定 —— 数字和画面互相印证，两头都能对得上。
#
# 设计约束同前：只写文件、不做交互；任何单项失败都不影响其它项（防御式）。

def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _blank_flags(gray_std: float, entropy: float, uniq: int,
                 near_black: float, near_white: float) -> list:
    why = []
    if gray_std < 3.0:
        why.append(f"灰度标准差 {gray_std:.2f} < 3（几乎无起伏）")
    if entropy < 1.5:
        why.append(f"熵 {entropy:.2f} < 1.5（信息量极低）")
    if uniq <= 4:
        why.append(f"采样唯一色 {uniq} ≤ 4（纯色/近纯色）")
    if near_black > 97.0:
        why.append(f"近黑像素 {near_black:.1f}% > 97%（疑似黑帧）")
    if near_white > 97.0:
        why.append(f"近白像素 {near_white:.1f}% > 97%（疑似白帧）")
    return why


def image_facts(p: Path) -> dict:
    st = p.stat()
    f = {
        "path": str(p), "name": p.name, "ext": p.suffix.lower(),
        "bytes": st.st_size, "sha256": sha256_of(p),
        "mtime": datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
    }
    with Image.open(p) as raw:
        f["format"] = raw.format
        f["mode"] = raw.mode
        f["width"], f["height"] = raw.size
        has_a = raw.mode in ("RGBA", "LA") or (raw.mode == "P" and "transparency" in raw.info)
        f["has_alpha"] = bool(has_a)
        if has_a:
            al = raw.convert("RGBA").getchannel("A")
            mn, _mx = al.getextrema()
            hist = al.histogram()
            total = max(1, raw.size[0] * raw.size[1])
            f["alpha_min"] = int(mn)
            f["alpha_transparent_pct"] = round(100.0 * sum(hist[:250]) / total, 2)
            f["alpha_used"] = bool(mn < 250)

    im = open_rgb(p)
    g = im.convert("L")
    st_l = ImageStat.Stat(g)
    f["gray_mean"] = round(st_l.mean[0], 2)
    f["gray_std"] = round(st_l.stddev[0], 2)
    _ent = g.entropy()
    f["entropy"] = round(_ent, 3) if _ent > 1e-9 else 0.0

    N = 160
    small = im.resize((N, N), Image.BILINEAR)
    cols = small.getcolors(maxcolors=N * N) or []
    f["unique_colors_sampled"] = len(cols)
    total_px = max(1, N * N)
    if cols:
        top = max(cols, key=lambda c: c[0])
        f["dominant_rgb"] = [int(v) for v in top[1]]
        f["dominant_pct"] = round(100.0 * top[0] / total_px, 2)
    dark = sum(n for n, px in cols if sum(px[:3]) / 3.0 < 16)
    light = sum(n for n, px in cols if sum(px[:3]) / 3.0 > 239)
    f["near_black_pct"] = round(100.0 * dark / total_px, 2)
    f["near_white_pct"] = round(100.0 * light / total_px, 2)

    why = _blank_flags(f["gray_std"], f["entropy"], f["unique_colors_sampled"],
                       f["near_black_pct"], f["near_white_pct"])
    f["looks_blank"] = bool(why)
    f["looks_blank_reason"] = why
    return f


def compare_facts(base: Path, cur: Path) -> dict:
    """把"改了哪儿、改了多少"变成数字 + 定位到 3×3 区域，便于逐条指认。"""
    b_im, c_im = open_rgb(base), open_rgb(cur)
    out = {"baseline": str(base), "compared": str(cur)}
    if b_im.size != c_im.size:
        out["size_mismatch"] = True
        out["baseline_size"] = list(b_im.size)
        b_im = b_im.resize(c_im.size, Image.LANCZOS)

    diff = ImageChops.difference(b_im, c_im).convert("L")
    st = ImageStat.Stat(diff)
    out["mean_abs_diff"] = round(st.mean[0], 2)
    out["max_abs_diff"] = int(diff.getextrema()[1])

    mask = diff.point(lambda v: 255 if v > 8 else 0)
    hist = mask.histogram()
    w, h = c_im.size
    total = max(1, w * h)
    out["changed_pct"] = round(100.0 * hist[255] / total, 2)

    bbox = mask.getbbox()
    if bbox:
        out["changed_bbox_pct"] = [
            round(100.0 * bbox[0] / w, 1), round(100.0 * bbox[1] / h, 1),
            round(100.0 * bbox[2] / w, 1), round(100.0 * bbox[3] / h, 1),
        ]
        out["changed_bbox_note"] = "上 左 下 右（占画面百分比）"

    grid = {}
    for r in range(3):
        row = []
        for q in range(3):
            sub = mask.crop((q * w // 3, r * h // 3, (q + 1) * w // 3, (r + 1) * h // 3))
            sh = sub.histogram()
            tot = max(1, sub.size[0] * sub.size[1])
            row.append(round(100.0 * sh[255] / tot, 1))
        grid[f"row{r + 1}"] = row
    out["changed_by_region_pct"] = grid
    out["region_note"] = "3×3 网格，row1=上排；每行左→右。主体漂移看这里"

    sb, sc = ImageStat.Stat(b_im.convert("RGB")), ImageStat.Stat(c_im.convert("RGB"))
    out["palette_delta_rgb"] = [round(sc.mean[i] - sb.mean[i], 1) for i in range(3)]
    out["palette_note"] = "整体配色偏移（本次 - 基准），每通道 ±255；风格一致性看这里"
    return out


def video_facts(p: Path, count: int, workdir: Path) -> dict:
    meta = probe(p)
    vstream = next((s for s in meta.get("streams", []) if s.get("codec_type") == "video"), {})
    astream = next((s for s in meta.get("streams", []) if s.get("codec_type") == "audio"), None)
    dur = float(meta.get("format", {}).get("duration") or vstream.get("duration") or 0)

    out = {
        "path": str(p), "name": p.name, "bytes": p.stat().st_size, "sha256": sha256_of(p),
        "duration": round(dur, 3), "width": vstream.get("width"), "height": vstream.get("height"),
        "fps": round(eval_fps(vstream), 3), "video_codec": vstream.get("codec_name"),
        "audio": ({"codec": astream.get("codec_name"), "channels": astream.get("channels"),
                   "sample_rate": astream.get("sample_rate")} if astream else None),
    }
    if dur <= 0:
        out["error"] = "无法确定时长，跳过抽帧与帧间分析"
        return out

    require("ffmpeg")
    workdir.mkdir(parents=True, exist_ok=True)
    n = max(2, count)
    stamps = [dur * (i + 0.5) / n for i in range(n)]
    frames = []
    for i, t in enumerate(stamps, 1):
        dst = workdir / f"audit_{i:03d}_{t:07.2f}s.png"
        r = subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-ss", f"{t:.3f}",
             "-i", str(p), "-frames:v", "1", "-y", str(dst)],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
        if r.returncode == 0 and dst.exists():
            frames.append(dst)
    if not frames:
        out["error"] = "抽帧全部失败"
        return out

    out["frames"] = [str(x) for x in frames]
    hashes = [sha256_of(x) for x in frames]
    out["unique_frames"] = len(set(hashes))
    out["duplicate_frame_groups"] = sorted(
        [hashes.count(h) for h in set(hashes) if hashes.count(h) > 1], reverse=True)

    gs = [open_rgb(x).convert("L").resize((160, 160), Image.BILINEAR) for x in frames]
    diffs = [round(ImageStat.Stat(ImageChops.difference(gs[i], gs[i + 1])).mean[0], 2)
             for i in range(len(gs) - 1)]
    out["adjacent_mean_diff"] = diffs
    if diffs:
        idx = diffs.index(max(diffs))
        out["max_jump"] = {"between": f"帧{idx + 1}→帧{idx + 2}", "value": max(diffs)}
        out["frozen_pairs"] = [i + 1 for i, d in enumerate(diffs) if d < 1.0]
    # 首尾帧是否黑帧/白帧
    for tag, im in (("first", frames[0]), ("last", frames[-1])):
        g = open_rgb(im).convert("L")
        s = ImageStat.Stat(g)
        out[f"{tag}_frame_gray_std"] = round(s.stddev[0], 2)
        out[f"{tag}_frame_blank"] = bool(s.stddev[0] < 3.0)
    return out


def _fmt_facts(f: dict) -> str:
    if "frames" in f and "width" in f and "fps" in f:      # 视频
        lines = [
            f"{f['name']}  视频 {f['width']}x{f['height']} {f['duration']}s "
            f"{f['fps']}fps {f['video_codec']}  {f['bytes'] / 1024:.0f} KB",
            f"    sha256 {f['sha256'][:12]} · 音频 "
            f"{'无' if not f['audio'] else f['audio']['codec'] + '/' + str(f['audio']['channels']) + 'ch/' + str(f['audio']['sample_rate']) + 'Hz'}",
            f"    抽帧 {len(f.get('frames', []))} 帧 → 唯一 {f.get('unique_frames')} 帧"
            + (f"（有重复：{f['duplicate_frame_groups']}）" if f.get("duplicate_frame_groups") else ""),
            f"    相邻帧差 {f.get('adjacent_mean_diff')}（>8 视为可见跳变；<1 视为冻结）",
            f"    最大跳变 {f.get('max_jump')} · 冻结帧对 {f.get('frozen_pairs')}",
            f"    首帧 blank={f.get('first_frame_blank')} · 尾帧 blank={f.get('last_frame_blank')}",
        ]
        for x in f.get("frames", []):
            lines.append(f"      frame → {x}")
        return "\n".join(lines)
    if "width" in f:                                       # 图片
        lines = [
            f"{f['name']}  {f['width']}x{f['height']} {f.get('format')}/{f.get('mode')}  "
            f"{f['bytes'] / 1024:.0f} KB  sha256 {f['sha256'][:12]}  改动时间 {f['mtime']}",
            f"    灰度 均值{f['gray_mean']} 标准差{f['gray_std']} · 熵{f['entropy']} · "
            f"采样唯一色{f['unique_colors_sampled']} · 主色 rgb{tuple(f['dominant_rgb'])} {f['dominant_pct']}%",
            f"    近黑{f['near_black_pct']}% 近白{f['near_white_pct']}% · alpha "
            + (f"有(min={f['alpha_min']}, 透明{f['alpha_transparent_pct']}%)" if f.get("has_alpha") else "无"),
        ]
        if f["looks_blank"]:
            lines.append("    🔴 looks_blank=True —— " + "；".join(f["looks_blank_reason"]))
        return "\n".join(lines)
    return json.dumps(f, ensure_ascii=False)


def cmd_audit(a) -> None:
    files, missing = [], []
    for it in a.files:
        p = Path(it)
        if p.is_dir():
            files += sorted(x for x in p.iterdir() if x.suffix.lower() in IMG_EXT | {".mp4", ".mov", ".webm", ".mkv"})
        elif p.exists():
            files.append(p)
        else:
            missing.append(str(p))
    for m in missing:
        print(f"  ⚠️ 跳过不存在的路径：{m}", file=sys.stderr)
    if not files:
        sys.exit("没有可审计的产物。")

    video_ext = {".mp4", ".mov", ".webm", ".mkv", ".avi"}
    workdir = Path(tempfile.mkdtemp(prefix="review-audit-"))
    facts = []
    for p in files:
        try:
            facts.append(video_facts(p, a.count, workdir) if p.suffix.lower() in video_ext
                         else image_facts(p))
        except SystemExit:
            raise
        except Exception as e:                              # 单项失败不影响其它项
            facts.append({"path": str(p), "name": p.name, "error": f"{type(e).__name__}: {e}"})

    # 重复产物：内容完全相同 = 你以为有两个候选，其实是一个
    byhash = {}
    for f in facts:
        if f.get("sha256"):
            byhash.setdefault(f["sha256"], []).append(f["name"])
    dups = [v for v in byhash.values() if len(v) > 1]

    baseline = None
    if a.baseline:
        bp = Path(a.baseline)
        if not bp.exists():
            print(f"  ⚠️ 基准不存在，跳过对比：{bp}", file=sys.stderr)
        else:
            first_img = next((f for f in facts if "width" in f and "fps" not in f), None)
            if first_img:
                try:
                    baseline = compare_facts(bp, Path(first_img["path"]))
                except Exception as e:
                    print(f"  ⚠️ 对比失败：{type(e).__name__}: {e}", file=sys.stderr)

    if a.as_json:
        print(json.dumps({"files": facts, "duplicates": dups, "baseline_compare": baseline},
                         ensure_ascii=False, indent=2))
        return

    print("== 产物事实审计（写进报告的证据栏，不要凭印象）==")
    for i, f in enumerate(facts, 1):
        print(f"[{i}] " + (f.get("error") and f"{f['name']}  🔴 审计失败：{f['error']}" or _fmt_facts(f)))
    if dups:
        print("\n🔴 内容完全相同的产物（同一张图被当成两个候选？）：")
        for group in dups:
            print("    " + "  ==  ".join(group))
    if baseline:
        print("\n== 与基准的差异（digits 可直接抄进报告）==")
        print(f"  基准：{baseline['baseline']}"
              + ("  ⚠️ 尺寸不同，已缩放对齐" if baseline.get("size_mismatch") else ""))
        print(f"  变化像素 {baseline['changed_pct']}% · 平均绝对差 {baseline['mean_abs_diff']} "
              f"· 峰值差 {baseline['max_abs_diff']}")
        if baseline.get("changed_bbox_pct"):
            print(f"  变化范围（上左下右 %）：{baseline['changed_bbox_pct']}")
        print(f"  分区变化率 {baseline['changed_by_region_pct']}   ← 主体漂移看这里")
        print(f"  配色偏移 {baseline['palette_delta_rgb']}   ← 风格一致性看这里")
    print("\n判据提示：变化 <1% 且配色偏移 <2 → 基本没变（可能没生效，先查参数是否真的传进去了）")
    print("         变化集中在某一格、其余为 0 → 只动了局部，逐条对照画面确认是不是你要的那块")

    payload = {"files": facts, "duplicates": dups, "baseline_compare": baseline}
    print("FACTS " + json.dumps(payload, ensure_ascii=False))
    if a.out:
        op = Path(a.out)
        op.parent.mkdir(parents=True, exist_ok=True)
        op.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"事实 JSON → {op}")


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

    d = sub.add_parser("audit", help="产物事实审计：哈希 / 空白 / 重复 / 与基准的差异数字")
    d.add_argument("files", nargs="+")
    d.add_argument("--baseline", default=None, help="基准图（上一版 / 输入参考图）")
    d.add_argument("--count", type=int, default=9, help="视频抽帧数（默认 9）")
    d.add_argument("--json", action="store_true", dest="as_json", help="只输出 JSON")
    d.add_argument("--out", default=None, help="把事实 JSON 落盘到该路径")
    d.set_defaults(func=cmd_audit)

    a = ap.parse_args()
    a.func(a)


if __name__ == "__main__":
    main()
