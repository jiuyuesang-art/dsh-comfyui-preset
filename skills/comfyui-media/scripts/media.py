#!/usr/bin/env python3
"""图像处理工具 —— 裁切 / 缩放 / 转格式 / 拼接 / 联系表 / 标注 / 补边。

用法（每个子命令都有 --help）：
    python media.py info    <图...>
    python media.py resize  <图> -o <出> --width 1024 [--height 1024] [--fit cover|contain|stretch]
    python media.py crop    <图> -o <出> --box L,T,R,B
    python media.py pad     <图> -o <出> --aspect 16:9 [--bg 0,0,0]
    python media.py convert <图...> -o <目录> --format webp [--quality 90]
    python media.py grid    <图...> -o <出> --cols 4 --cell 384 [--label]
    python media.py side    <图A> <图B> -o <出> [--label A,B]
    python media.py mark    <图> -o <出> --rect L,T,R,B --text "说明"

设计约定：
  · 输出目录不存在会自动创建
  · 所有输出都是 UTF-8 安全的（本工具自身强制 stdout UTF-8）
  · 不覆盖已有文件 —— 除非显式传 --force（避免破坏 old/ 归档纪律）
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

# 中文输出：本机控制台是 GBK，不修就会乱码
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("❌ 需要 Pillow。用 ComfyUI venv 的 python，或 pip install Pillow", file=sys.stderr)
    raise SystemExit(2)

IMAGE_EXT = {".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif", ".tif", ".tiff"}


def _out(path: str, force: bool) -> Path:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    if p.exists() and not force:
        print(f"❌ 已存在，拒绝覆盖：{p}\n   （加 --force 才覆盖；产物更新请走 safe-write.ps1 归档）", file=sys.stderr)
        raise SystemExit(3)
    return p


def _font(size: int):
    """找一个能显示中文的字体；找不到就退回默认（可能显示成方块）。"""
    for cand in (
        r"C:\Windows\Fonts\msyh.ttc",      # 微软雅黑
        r"C:\Windows\Fonts\simhei.ttf",    # 黑体
        r"C:\Windows\Fonts\simsun.ttc",    # 宋体
    ):
        if Path(cand).exists():
            try:
                return ImageFont.truetype(cand, size)
            except Exception:
                pass
    return ImageFont.load_default()


def _fmt(s: str):
    """--box / --rect 这类 'a,b,c,d' 参数解析（必须 4 个）。"""
    parts = [int(x.strip()) for x in s.split(",")]
    if len(parts) != 4:
        raise argparse.ArgumentTypeError(f"需要 4 个逗号分隔的数字（左,上,右,下），收到 {len(parts)} 个")
    return tuple(parts)


def _rgb(s: str):
    """--bg 底色：接受 r,g,b（3 个）或 r,g,b,a（4 个）。"""
    parts = [int(x.strip()) for x in s.split(",")]
    if len(parts) not in (3, 4):
        raise argparse.ArgumentTypeError(f"需要 3（r,g,b）或 4（r,g,b,a）个数字，收到 {len(parts)} 个")
    if any(not (0 <= v <= 255) for v in parts):
        raise argparse.ArgumentTypeError(f"颜色分量必须在 0–255，收到 {s}")
    return tuple(parts)


def _collect(paths: list[str]) -> list[Path]:
    out: list[Path] = []
    for p in paths:
        q = Path(p)
        if q.is_dir():
            out += sorted(x for x in q.rglob("*") if x.suffix.lower() in IMAGE_EXT)
        elif q.suffix.lower() in IMAGE_EXT:
            out.append(q)
    return out


# ── 子命令 ────────────────────────────────────────────────────────────────

def cmd_info(a):
    for p in _collect(a.images):
        with Image.open(p) as im:
            kb = p.stat().st_size / 1024
            extra = f"  frames={getattr(im, 'n_frames', 1)}" if getattr(im, "n_frames", 1) > 1 else ""
            print(f"{p}\n    {im.width}×{im.height}  {im.mode}  {im.format}  {kb:.0f} KB{extra}")


def cmd_resize(a):
    with Image.open(a.image) as im:
        w, h = a.width, a.height
        if w and h:
            if a.fit == "stretch":
                im = im.resize((w, h), Image.LANCZOS)
            else:
                src_r, dst_r = im.width / im.height, w / h
                if (src_r > dst_r) == (a.fit == "cover"):
                    nw, nh = w, round(w / src_r)
                else:
                    nh, nw = h, round(h * src_r)
                im = im.resize((nw, nh), Image.LANCZOS)
                if a.fit == "cover":
                    im = im.crop(((nw - w) // 2, (nh - h) // 2, (nw - w) // 2 + w, (nh - h) // 2 + h))
                else:  # contain
                    canvas = Image.new("RGBA", (w, h), a.bg + (255,) if len(a.bg) == 3 else a.bg)
                    canvas.paste(im.convert("RGBA"), ((w - nw) // 2, (h - nh) // 2), im.convert("RGBA"))
                    im = canvas
        elif w:
            im = im.resize((w, round(im.height * w / im.width)), Image.LANCZOS)
        elif h:
            im = im.resize((round(im.width * h / im.height), h), Image.LANCZOS)
        else:
            print("❌ resize 需要 --width 或 --height 至少一个", file=sys.stderr)
            raise SystemExit(2)
        o = _out(a.output, a.force)
        im.save(o, quality=a.quality)
        print(f"✅ {o}  {im.width}×{im.height}")


def cmd_crop(a):
    with Image.open(a.image) as im:
        l, t, r, b = a.box
        if r <= l or b <= t:
            print(f"❌ --box 无效：{a.box}（右/下必须大于左/上）", file=sys.stderr)
            raise SystemExit(2)
        if r > im.width or b > im.height:
            print(f"⚠️  --box 超出图像范围（图 {im.width}×{im.height}），已裁到边界")
            r, b = min(r, im.width), min(b, im.height)
        o = _out(a.output, a.force)
        im.crop((l, t, r, b)).save(o, quality=a.quality)
        print(f"✅ {o}  {r-l}×{b-t}")


def cmd_pad(a):
    aw, ah = (int(x) for x in a.aspect.split(":"))
    with Image.open(a.image) as im:
        target = aw / ah
        if im.width / im.height > target:
            nw, nh = im.width, round(im.width / target)
        else:
            nh, nw = im.height, round(im.height * target)
        bg = a.bg + (255,) if len(a.bg) == 3 else a.bg
        canvas = Image.new("RGBA", (nw, nh), bg)
        canvas.paste(im.convert("RGBA"), ((nw - im.width) // 2, (nh - im.height) // 2), im.convert("RGBA"))
        o = _out(a.output, a.force)
        canvas.save(o, quality=a.quality)
        print(f"✅ {o}  {nw}×{nh}（原 {im.width}×{im.height}，补边到 {a.aspect}）")


def cmd_convert(a):
    outdir = Path(a.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    n = 0
    for p in _collect(a.images):
        o = outdir / (p.stem + "." + a.format)
        if o.exists() and not a.force:
            print(f"  ⏭  已存在，跳过 {o.name}")
            continue
        with Image.open(p) as im:
            if a.format in ("jpg", "jpeg") and im.mode in ("RGBA", "P", "LA"):
                im = im.convert("RGB")
            im.save(o, quality=a.quality)
        n += 1
        print(f"  ✅ {p.name} → {o.name}")
    print(f"共转换 {n} 张")


def _grid(images, cols, cell, label, bg=(24, 24, 28)):
    n = len(images)
    rows = (n + cols - 1) // cols
    lab = 26 if label else 0
    canvas = Image.new("RGB", (cols * cell, rows * (cell + lab)), bg)
    d = ImageDraw.Draw(canvas)
    f = _font(16)
    for i, p in enumerate(images):
        with Image.open(p) as im:
            thumb = im.convert("RGB")
            thumb.thumbnail((cell - 8, cell - 8), Image.LANCZOS)
            cx, cy = (i % cols) * cell, (i // cols) * (cell + lab)
            canvas.paste(thumb, (cx + (cell - thumb.width) // 2, cy + (cell - thumb.height) // 2))
        if label:
            d.text((cx + 6, cy + cell + 4), Path(p).stem[:34], fill=(220, 220, 225), font=f)
    return canvas


def cmd_grid(a):
    imgs = _collect(a.images)
    if not imgs:
        print("❌ 没找到图片", file=sys.stderr)
        raise SystemExit(2)
    canvas = _grid(imgs, a.cols, a.cell, a.label)
    o = _out(a.output, a.force)
    canvas.save(o, quality=a.quality)
    print(f"✅ {o}  {canvas.width}×{canvas.height}  共 {len(imgs)} 张，{a.cols} 列")


def cmd_side(a):
    imgs = _collect([a.image_a, a.image_b])
    if len(imgs) != 2:
        print("❌ side 需要正好两张图", file=sys.stderr)
        raise SystemExit(2)
    canvas = _grid(imgs, 2, a.cell, bool(a.label))
    o = _out(a.output, a.force)
    canvas.save(o, quality=a.quality)
    print(f"✅ {o}  {canvas.width}×{canvas.height}  左右对比")


def cmd_mark(a):
    with Image.open(a.image) as im:
        im = im.convert("RGB")
        d = ImageDraw.Draw(im)
        l, t, r, b = a.rect
        w = max(3, im.width // 300)
        d.rectangle((l, t, r, b), outline=(255, 60, 60), width=w)
        if a.text:
            f = _font(max(18, im.width // 42))
            pad = 6
            tb = d.textbbox((0, 0), a.text, font=f)
            th, tw = tb[3] - tb[1], tb[2] - tb[0]
            ty = t - th - pad * 3 if t - th - pad * 3 > 0 else b + pad
            d.rectangle((l, ty, l + tw + pad * 2, ty + th + pad * 2), fill=(255, 60, 60))
            d.text((l + pad, ty + pad), a.text, fill=(255, 255, 255), font=f)
        o = _out(a.output, a.force)
        im.save(o, quality=a.quality)
        print(f"✅ {o}  已标注 {a.rect}")


# ── CLI ───────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(prog="media.py", description="图像处理工具")
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p, out=True):
        if out:
            p.add_argument("-o", "--output", required=True, help="输出文件路径")
        p.add_argument("--force", action="store_true", help="允许覆盖已存在的输出")
        p.add_argument("--quality", type=int, default=95, help="JPEG/WebP 质量（默认 95）")

    p = sub.add_parser("info", help="看尺寸/模式/体积")
    p.add_argument("images", nargs="+")
    p.set_defaults(func=cmd_info)

    p = sub.add_parser("resize", help="缩放（含 cover/contain）")
    p.add_argument("image")
    common(p)
    p.add_argument("--width", type=int, default=0)
    p.add_argument("--height", type=int, default=0)
    p.add_argument("--fit", choices=["cover", "contain", "stretch"], default="contain")
    p.add_argument("--bg", type=_rgb, default=(0, 0, 0), help="contain 时的底色 r,g,b")
    p.set_defaults(func=cmd_resize)

    p = sub.add_parser("crop", help="裁切")
    p.add_argument("image")
    common(p)
    p.add_argument("--box", type=_fmt, required=True, help="左,上,右,下")
    p.set_defaults(func=cmd_crop)

    p = sub.add_parser("pad", help="补边到指定宽高比")
    p.add_argument("image")
    common(p)
    p.add_argument("--aspect", required=True, help="如 16:9 / 1:1 / 9:16")
    p.add_argument("--bg", type=_rgb, default=(0, 0, 0))
    p.set_defaults(func=cmd_pad)

    p = sub.add_parser("convert", help="批量转格式")
    p.add_argument("images", nargs="+")
    p.add_argument("-o", "--outdir", required=True)
    p.add_argument("--format", required=True, choices=["png", "jpg", "webp", "bmp", "tiff"])
    p.add_argument("--force", action="store_true")
    p.add_argument("--quality", type=int, default=95)
    p.set_defaults(func=cmd_convert)

    p = sub.add_parser("grid", help="联系表（多图拼一张）")
    p.add_argument("images", nargs="+")
    common(p)
    p.add_argument("--cols", type=int, default=4)
    p.add_argument("--cell", type=int, default=384, help="每格像素（默认 384）")
    p.add_argument("--label", action="store_true", help="每格下方标文件名")
    p.set_defaults(func=cmd_grid)

    p = sub.add_parser("side", help="左右对比图")
    p.add_argument("image_a")
    p.add_argument("image_b")
    common(p)
    p.add_argument("--cell", type=int, default=768)
    p.add_argument("--label", action="store_true")
    p.set_defaults(func=cmd_side)

    p = sub.add_parser("mark", help="画框标注（审查用）")
    p.add_argument("image")
    common(p)
    p.add_argument("--rect", type=_fmt, required=True, help="左,上,右,下")
    p.add_argument("--text", default="", help="框旁文字说明")
    p.set_defaults(func=cmd_mark)

    a = ap.parse_args()
    a.func(a)


if __name__ == "__main__":
    main()
