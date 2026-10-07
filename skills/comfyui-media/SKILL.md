---
name: comfyui-media
description: 媒体处理工具集（视频抽帧 / 图像编辑 / 音频处理）。要看视频内容、抽帧做审查、裁切缩放拼图转格式、或处理音频（裁剪/归一化/拼接/混音）时加载。基于本机 ffmpeg 与 Pillow，三个脚本全部实测通过。
whenToUse: 用户提到 抽帧 / 看视频 / 联系表 / 缩略图 / 裁切 / 缩放 / 转格式 / 拼图 / 对比图 / 音频 / 裁剪音频 / 混音 / 归一化 时
---

# 媒体处理工具集

> **本机实测环境**：ffmpeg **8.1.1** + ffprobe（`C:\ffmpeg\bin`）·
> ComfyUI venv Python **3.10** 带 `PIL / numpy / cv2 / imageio / soundfile / librosa / scipy`（最全）。
>
> 三个脚本的**每个动作都跑过测试**（含拒绝覆盖守卫），不是写完就交。

**为什么要有这套工具**：本模式全程在处理图 / 视频 / 音频 ——
看视频必须抽帧、交付前要做前后对比图、H3 出的音轨常有前后静音要裁。
**这些不该每次现写脚本**，那是纯浪费。

---

## 0. 三条纪律

**① 不要现写一次性脚本。** 先看这里有没有现成的。
本手册覆盖的需求，**一律用这里的脚本** —— 现写要花时间、还可能写错。

**② 产物更新前先归档。** 这些脚本**默认拒绝覆盖**（要 `-Force` / `--force`）。
要更新已有产物 → **先跑 `comfyui-project-layout` 的 `safe-write.ps1`**，再覆盖。

**③ Python 走 `run-python.ps1`，不要直接敲 `python`。**
`media.py` 需要 Pillow —— 用 **ComfyUI venv 的 python**（它装了 PIL）：
```powershell
& "<bundle>/tools/run-python.ps1" <本skill>/scripts/media.py ...
```
（`run-python.ps1` 设 `PYTHONUTF8=1`，避免中文输出乱码与写坏文件）

---

## 1. 视频：`scripts/frames.ps1`

```powershell
# 探测：时长 / 分辨率 / 帧率 / 编码 / 音轨
& frames.ps1 info   -Source <视频>

# 🔴 看视频内容的标准做法 —— 联系表（缩略图总览，一屏看清整段）
& frames.ps1 sheet  -Source <视频> -OutDir <60_review> -Count 12 -Cols 4

# 按间隔抽帧（要逐帧细看时）
& frames.ps1 frames -Source <视频> -OutDir <临时目录> -Every 1.0

# 取某个时间点的单帧
& frames.ps1 frame  -Source <视频> -OutDir <目录> -At 3.5

# 提取音轨
& frames.ps1 audio  -Source <视频> -OutDir <50_audio> -Format wav
```

| 动作 | 用途 |
|---|---|
| `info` | 先看时长与规格，决定抽多少帧 |
| **`sheet`** | **审查首选** —— 均匀抽 N 帧拼一张，`comfyui-review` 要求的就是这个 |
| `frames` | 需要逐帧比对时 |
| `frame` | 取关键瞬间（如"第 3 秒那个形变"） |
| `audio` | 把音轨交给 `audio.ps1` 处理 |

> ⚠️ **`sheet` 的帧是均匀抽的**（每 `时长/Count` 秒一帧）——
> 审查报告里必须声明"**这是抽样，不代表每一帧都看了**"（见 `comfyui-review` 底线④）。

---

## 2. 图像：`scripts/media.py`

```powershell
$PY = "C:\easyaiforcomfyui\ComfyUI-EasyManager\win\envs\comfyui\python.exe"   # 或 run-python.ps1

# 看尺寸/模式/体积
& $PY media.py info    <图...>

# 缩放（cover=裁满 / contain=补边 / stretch=拉伸）
& $PY media.py resize  <图> -o <出> --width 1024 --height 1024 --fit cover

# 裁切 / 补边到宽高比
& $PY media.py crop    <图> -o <出> --box 左,上,右,下
& $PY media.py pad     <图> -o <出> --aspect 16:9

# 批量转格式
& $PY media.py convert <图...> -o <目录> --format webp --quality 90

# 🔴 联系表 / 左右对比 —— 审查报告要的就是这两个
& $PY media.py grid    <图...> -o <出> --cols 4 --cell 384 --label
& $PY media.py side    <图A> <图B> -o <出> --cell 768 --label

# 画框标注（审查时指出问题位置）
& $PY media.py mark    <图> -o <出> --rect 左,上,右,下 --text "这里手指数不对"
```

| 动作 | 典型场景 |
|---|---|
| **`side`** | **前后对比图** —— `comfyui-review` 的报告模板要求 |
| **`mark`** | **指出缺陷位置** —— 比文字描述"左下角"精确得多 |
| `grid` | 一批产物的总览（如 20 张角色图拼一张） |
| `resize`/`pad` | 对齐尺寸、做参考图 |
| `convert` | 转 webp 省空间、转 png 要透明 |

> ⚠️ **`--box` / `--rect` 用的是「左,上,右,下」**（左上角为原点），**不是宽高**。
> 写 `40,40,200,160` = 从 (40,40) 到 (200,160)。

---

## 3. 音频：`scripts/audio.ps1`

```powershell
# 探测：时长/采样率/声道/编码 + 峰值电平（看有没有削波）
& audio.ps1 info      -Source <音频>

# 裁剪（H3 出的片段常有前后静音，交付前必裁）
& audio.ps1 trim      -Source <音频> -Output <出> -Start 1.2 -End 4.8

# 响度归一化（EBU R128，目标 -16 LUFS）
& audio.ps1 normalize -Source <音频> -Output <出>

# 拼接 / 混音（多输入用逗号分隔）
& audio.ps1 concat    -Source "a.wav,b.wav,c.wav" -Output <出>
& audio.ps1 mix       -Source "bgm.wav,vo.wav" -Output <出> -Volume 0.3,1.0

# 变速（音高不变）
& audio.ps1 speed     -Source <音频> -Output <出> -Rate 1.25

# 转码
& audio.ps1 convert   -Source <音频> -Output <出> -Format mp3
```

| 动作 | 典型场景 |
|---|---|
| **`trim`** | **H3 音轨前后静音** —— 几乎每次都要 |
| **`normalize`** | **交付前统一响度** —— 多个镜头音量不一致时 |
| `mix` | BGM + 对白 + 音效 |
| `concat` | 多段拼成一条 |
| `info` | 看峰值，判断有没有削波（≥ -0.1 dB 会警告） |

> ⚠️ **`concat` 会先把各段统一成 48 kHz / 双声道再拼** ——
> 采样率或声道数不一致时直接 concat 会失败或声音错乱，这一步是必要的。

---

## 4. 与其它手册的衔接

| 场景 | 用哪个工具 | 配合哪个手册 |
|---|---|---|
| **审查视频** | `frames.ps1 sheet` | `comfyui-review`（抽帧看是它的硬要求） |
| **做前后对比图** | `media.py side` | `comfyui-review`（报告模板第一段） |
| **标出缺陷位置** | `media.py mark` | `comfyui-review`（结论要指向画面可见位置） |
| **裁 H3 音轨** | `audio.ps1 trim` | `study/minimax-h3`（音频章节） |
| **产物落盘前归档** | —— | `comfyui-project-layout` 的 `safe-write.ps1` |
| **显存不足想降分辨率** | `media.py resize` | `comfyui-perf`（参考图可以降规格） |
