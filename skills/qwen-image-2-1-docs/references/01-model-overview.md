# 模型概述与规格

来源：
- `https://github.com/QwenLM/Qwen-Image-2.1`（Qwen 官方仓库 README，Architecture / News 章节）
- `https://huggingface.co/Qwen/Qwen-Image-2.1`（Qwen 官方 HuggingFace 模型卡）
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档）
- `https://blog.comfy.org/p/qwen-image-21-in-comfyui-open-weight`（ComfyUI 官方博客）
- `https://modelscope.cn/models/Qwen/Qwen-Image-2.1`（ModelScope 官方模型页）

抓取日期：2026-10-03

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 全名 | **Qwen-Image-2.1**（中文语境常写作 Qwen Image 2.1） |
| 发布方 | 阿里 Qwen 团队（Alibaba Qwen team） |
| 发布日 | **2026-09-20**（README News 首条） |
| 定位 | Qwen-Image 系列最新的**开源权重**模型；单一模型统一「文生图」与「指令式图像编辑」 |
| 许可证 | **Qwen Research License Agreement**（HuggingFace 上 `license_name: qwen-research`） |
| 权重来源 | HuggingFace `Qwen/Qwen-Image-2.1`（官方）、`Comfy-Org/Qwen-Image-2.1`（ComfyUI 重打包）、ModelScope `Qwen/Qwen-Image-2.1`（国内镜像） |

## 参数量

- **视觉生成组件 7B 参数**，**32 层 Single-Stream DiT**（官方模型卡与 README 原文一致）。
- 注意：7B 只是 **DiT 部分**。整条推理链路还包含一个 **Qwen3-VL 8B 文本编码器**和一个 VAE，
  所以**实际显存/磁盘开销远大于 7B**——文本编码器 BF16 就有约 17.53 GB（见 `06-vram-performance.md`）。

## 架构（README「Architecture」章节原文要点）

Qwen-Image-2.1 是一个 **single-stream DiT**，设计如下：

- **Transformer**：32 层，7B 参数，单流架构，采用 **block-causal attention**。
  注意力掩码规则原文：`(q_idx >= kv_idx) or same_image_block`。
  具体而言：**文本部分用 token 级 causal mask，图像部分用 chunk 级 bidirectional mask**。
- **Text Encoder**：**Qwen3-VL 8B**（一个 vision-language 模型）——
  把**文本指令和条件图像**一起编码成统一表示。
- **VAE**：**64 通道 RGBA 自编码器**，**16× 空间压缩**，原生支持透明度。
- **Scheduler**：**Flow Matching**，采用 **Euler discrete scheduling + dynamic shifting**。

### 架构带来的关键能力：混合粒度注意力 + prefix KV cache 复用

"mixed-granularity attention" 让模型可以做 **prefix KV cache 复用**：
输入图像和文本指令**只在第一步去噪时算一次**，之后所有去噪步直接复用缓存。
官方说明：当 checkpoint 带 `causal_condition: true`（默认值）时，transformer 会自动缓存
text + condition-image prefix；**对多条件图的图像编辑提速尤其明显**。

→ ComfyUI 侧对应 `Qwen Image 2.1 Cache` 节点，详见 `03-parameters.md`。

## 官方列出的四项主要改进

摘自模型卡 Introduction：

1. **Compact and Efficient（紧凑高效）** —— 轻量架构 + mixed-granularity attention + prefix KV cache 复用，
   在低算力开销下取得较强画质。
2. **Native Transparency, Unified Creation and Editing（原生透明，创作与编辑统一）** ——
   可直接从文本生成普通或透明（**RGBA**）图像，编辑透明图层，从照片中提取主体，全部在一个模型内完成。
3. **Versatile Editing（编辑能力全面)** —— 支持**最多 10 张参考图**，
   可通过**圈选、涂鸦标注、独立 mask** 指定局部编辑，并保持人物与商品的**身份一致性**。
4. **Realistic Textures and Refined Aesthetics（质感与美学）** ——
   改进排版（typography）、人像光影与细节。

## 分辨率与支持的宽高比（官方推荐值）

Qwen-Image-2.1 **原生 2K**，官方模型卡给出以下推荐尺寸（宽 × 高）：

| 比例 | 尺寸 |
| --- | --- |
| 1:1 | 2048 × 2048 |
| 4:3 | 2400 × 1792 |
| 3:4 | 1792 × 2400 |
| 3:2 | 2528 × 1696 |
| 2:3 | 1696 × 2528 |
| 16:9 | 2752 × 1536 |
| 9:16 | 1536 × 2752 |

其他约束（来自官方/社区实践，见 `07-limitations.md`）：
- **宽高必须是 32 的倍数**；
- **最大边 2048**（与上面 16:9 的 2752 存在张力，见边界章节说明）。

## 语言与文字渲染

- **中文提示词可原生使用**；官方的 prompt rewriter（PE）模型负责把中文短句改写成详细英文提示词。
  （来源：awesome-qwen-image 的 "Gotchas" 第 6 条：`Chinese prompts work natively — the PE models are what rewrite them into English.`）
- **专业排版 / 文字渲染**是官方强调的强项：
  - ComfyUI 官方文档描述为 "professional typography: dense small text and complex layouts hold up,
    for infographics, slides, UI mockups, posters, and packaging designs"。
  - 官方 README 的 Showcase 单列 "Text Rendering" 一节。
  - 官方示例提示词本身就含文字渲染用例：
    `A neon shop sign that reads "QWEN IMAGE 2.1", rainy night, reflections on wet pavement`。

## 透明通道（RGBA）

- VAE 携带 **4 个通道**，可直接生成与编辑透明底图像，**不需要事后抠图**。
- ComfyUI 博客原话："Sprites, logos, icons, and product cutouts come out of the sampler ready to composite.
  No background removal node, no matting model, no edge cleanup."
- 官方推荐的透明图提示词模板句见 `04-prompt-guide.md`。

## 生态与 Day-0 支持（README News）

2026-09-20 当天即获以下框架原生支持：

| 框架 | 支持形式 |
| --- | --- |
| **ComfyUI** | 原生支持；兼容权重在 `Comfy-Org/Qwen-Image-2.1`，含文生图与图像编辑示例工作流 |
| **Diffusers** | `QwenImage21Pipeline`（PR #14804） |
| **vLLM-Omni** | step-wise execution、prefix KV caching、CUDA Graph decode、FP8 量化、TP/Ulysses 并行 |
| **SGLang** | prefix caching、Cache-DiT、CUDA graphs、TP/Ulysses/Ring/CFG 并行、component offload（PR #39983） |
| **LightX2V** | Day-0 加速 |
| **ModelScope** | 基于 DiffSynth-Studio，支持下载、在线生成与 **LoRA 训练** |

其他硬件路线（README「Hardware Support」）：AMD Radeon（ROCm）、
以及通过 **FlagOS** 支持的多款国产芯片（含 T-Head zhenwu、Arm 等预构建镜像）。

## 文件体积（官方原始权重）

ModelScope 官方模型页给出的分片精确字节数：

| 部分 | 分片 | 字节数 | 约 |
| --- | --- | --- | --- |
| transformer (DiT) | `diffusion_pytorch_model-00001-of-00002` | 9,968,332,504 | 9.28 GiB |
| transformer (DiT) | `diffusion_pytorch_model-00002-of-00002` | 4,261,951,904 | 3.97 GiB |
| text_encoder (Qwen3-VL 8B) | `model-00001-of-00004` | 4,998,056,552 | 4.65 GiB |
| text_encoder | `model-00002-of-00004` | 4,915,962,464 | 4.58 GiB |
| text_encoder | `model-00003-of-00004` | 4,915,962,496 | 4.58 GiB |
| text_encoder | `model-00004-of-00004` | 2,704,357,976 | 2.52 GiB |
| vae | `diffusion_pytorch_model` | 1,350,989,512 | 1.26 GiB |

汇总（社区整理）：**DiT 14.23 GB + 文本编码器 17.53 GB + VAE 1.35 GB**。
张量类型标注为 `BF16` / `F32`。
