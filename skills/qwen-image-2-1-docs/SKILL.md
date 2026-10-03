---
name: qwen-image-2-1-docs
description: Qwen Image 2.1（Qwen-Image-2.1）官方文档离线快照。当用户要求用 Qwen Image 2.1 / Qwen-Image 出图、做图像编辑/换装/抠图/生成透明底 PNG、写 Qwen 提示词，或需要该模型的参数量、推荐步数与 CFG、显存占用、ComfyUI 模板与模型文件放置位置时使用。
---

# Qwen Image 2.1 离线文档快照

> 快照日期：**2026-10-03**。内容取自官方与权威来源，逐条 URL 见 `references/00-sources.md`。
> 本包只覆盖**本地免费**能力。Qwen Image 3.0 Pro 等云端/付费路线存在，但不在本项目范围。

> ⚠️ **本机已装好，别照着下面的"官方模板"从零下载！**
> 本文档 §「在 ComfyUI 里怎么用」写的是**官方模板的默认组合**，需要 `qwen_image_2.1_int8_convrot.safetensors` 等全精度/INT8 权重。
> **但本机走的是 GGUF 量化路线**，模型文件是：
> `unet_gguf/qwen_image_2.1_Q6_K.gguf` · `text_encoders/qwen3vl_8b_int8_convrot.safetensors` · `vae/qwen_image_2.1_vae_bf16.safetensors`
> **要实际出图，请以 `comfyui-mcp-ops` 的 [`references/recipes.md`](../comfyui-mcp-ops/references/recipes.md) 里的可跑配方为准**（已用 `validate_workflow` 实测 `valid: true`），本文件用于查证原理、参数含义与能力边界。
> 盘上已有成品工作流：`…\ComfyUI\user\default\workflows\zcode\Qwen2.1图片能力\脚本版\*.json`。

## 一句话结论

Qwen-Image-2.1 是阿里 Qwen 团队 **2026-09-20** 开源的**统一「文生图 + 指令式图像编辑」**模型：
同一份权重同时干两件事，原生 2K 输出，原生 **RGBA 透明通道**，最多 **10 张参考图**，
视觉生成部分 **7B 参数（32 层 Single-Stream DiT）**。

## 关键数字速查

| 项目 | 数值 |
| --- | --- |
| 视觉生成组件参数 | **7B**（32 层 Single-Stream DiT，单流架构） |
| 文本编码器 | **Qwen3-VL 8B**（BF16 约 17.53 GB，整条链路最大的单个文件） |
| VAE | 64 通道 RGBA 自编码器，16× 空间压缩 |
| 原生分辨率 | **2K**（1:1 = 2048×2048） |
| 官方默认步数 | **40** 步（`num_inference_steps`） |
| ComfyUI 模板步数 | **25** 步 |
| CFG / guidance | **1**（= 不跑负向条件，负向提示词**无效**；SGLang 示例 `--guidance-scale 1`） |
| 采样器 / 调度器 | `euler` + `simple` |
| 最大参考图 | 官方 **10 张**；`Text Encode Qwen Image 2.1` 节点开到 **16 槽**（`image_1`…`image_16`） |
| 官方推荐宽高 | 32 的倍数，**最大边 2048** |
| 许可证 | Qwen Research License Agreement |

## 主题索引

| 主题 | 文件 |
| --- | --- |
| 全部来源 URL 与抓取状态 | `references/00-sources.md` |
| 模型概述与规格：架构、参数量、语言、文字渲染 | `references/01-model-overview.md` |
| ComfyUI 使用方式：三个模板、模型文件、目录结构 | `references/02-comfyui-usage.md` |
| 参数与推荐值：步数、CFG、shift、分辨率、KV cache | `references/03-parameters.md` |
| 提示词指南：官方写法、文字渲染、RGBA 模板句 | `references/04-prompt-guide.md` |
| 图像编辑玩法：多图参考、局部编辑、抠图 | `references/05-image-editing.md` |
| 显存与性能：各精度体积、实测峰值、12GB 可行性 | `references/06-vram-performance.md` |
| 能力边界与已知问题 | `references/07-limitations.md` |

## 在 ComfyUI 里怎么用（最短路径）

1. **更新 ComfyUI 到最新版** —— 模板和原生节点需要新版，找不到模板通常就是版本旧了。
2. 从 HuggingFace `Comfy-Org/Qwen-Image-2.1` 下载文件，按目录放：

   | 文件 | 放到 |
   | --- | --- |
   | `diffusion_models/qwen_image_2.1_int8_convrot.safetensors`（模板默认，省显存）<br>`diffusion_models/qwen_image_2.1_bf16.safetensors`（全精度，吃显存） | `ComfyUI/models/diffusion_models/` |
   | `text_encoders/qwen3vl_8b_int8_convrot.safetensors`（模板默认）<br>`text_encoders/qwen3vl_8b_bf16.safetensors`、`qwen3vl_8b_w4a8.safetensors` | `ComfyUI/models/text_encoders/` |
   | `vae/qwen_image_2.1_vae_bf16.safetensors` | `ComfyUI/models/vae/` |
   | `qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors`（文生图提示词增强）<br>`qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors`（编辑提示词增强） | `ComfyUI/models/text_encoders/` |

   `*_convrot` 是 ComfyUI 原生的旋转通道整数格式，用普通 diffusion-model / text-encoder 加载器即可，**不需要自定义节点**。

3. 模板面板搜 **"Qwen-Image-2.1"**，共三个模板：
   - `image_qwen_image_2_1_t2i` —— 文生图
   - `image_qwen_image_2_1_image_edit` —— 图像编辑（双参考图，`LoadImage` 470 / 475）
   - `image_qwen_image_2_1_background_removal` —— 抠图（复用编辑子图 + 固定提示词）

4. 直接跑：**25 步 / CFG 1 / euler / simple**。文生图把 Resolution Selector 的兆像素目标设到约 **4.0 MP** 得 2048×2048。

## 最容易踩的五个坑

1. **CFG 1 时负向提示词不起作用** —— 这是官方发布路径，别浪费精力写负向词。想让负向词生效才提高到 2 以上。
2. **CFG 别乱调**：2 更贴合密集文字但边缘过锐；5 画质明显崩坏；**0.5 直接出废图**。一次只改一个值，固定种子对比。
3. **编辑慢通常是画布太大**，不是步数问题。看编辑子图的 `resolution` 和参考图实际像素尺寸。
4. **12GB 显存要选对组合**：INT8 DiT + INT8 文本编码器全驻留显存峰值 18.2–20.8 GB 跑不动；把文本编码器卸载后约 11.4–14.0 GB 属于"紧张但能跑"。
5. **Windows 上"能跑"可能是假的** —— NVIDIA 驱动的系统内存回退会让超显存的任务改用内存跑完，速度极慢，但不会报错。
