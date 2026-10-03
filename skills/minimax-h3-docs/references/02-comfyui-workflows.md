# ComfyUI 使用方式：模板、模型文件与目录

- **来源 URL**（ComfyUI 官方文档，全部 HTTP 200，正文以 `.md` 后缀取得）：
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3 （总览）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native （T2V / I2V / R2V）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-multiframe （多帧参考）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fun-controlnet （Fun ControlNet Union）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide （提示词指南）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fastvideo （FastH3）
- **模型仓库**：https://huggingface.co/Comfy-Org/MiniMax-H3
- **抓取日期**：2026-10-03

---

## 1. ComfyUI 版本门槛（官方文档明确列出）

| 功能 | 最低 ComfyUI 版本 |
| --- | --- |
| 基础 Text to Video / Image to Video / Reference to Video 模板 | **0.30.0** |
| Multiframe Reference | **0.34.0** |
| Fun ControlNet Union、稀疏注意力节点、Model Attention Backend 节点 | **0.35.0** |
| FastH3 | **0.36.0** |
| `--use-ck-attention` 开关（Comfy Kitchen attention） | 0.32.0 |

官方提示：模板库里找不到工作流 = ComfyUI 版本过旧。

## 2. 本机已确认的 17 个 MiniMax H3 相关模板

通过本机 ComfyUI 模板目录查询得到 `total: 17`，与背景信息完全一致。按 `api` 字段分为免费本地模板与付费 API 模板。

### 免费本地模板（8 个，`api: false`）

| 模板 name | 标题 | 说明 |
| --- | --- | --- |
| `video_minimax_h3_t2v` | MiniMax H3: Text to Video | 文生视频，直接由文本生成带原生立体声音频的视频 |
| `video_minimax_h3_i2v` | MiniMax H3: Image to Video | 图生视频，可选首帧/尾帧控制 |
| `video_minimax_h3_i2v_continuation` | Image to Video（续写变体） | 从一张图 + 空提示词起步，描述想要的运动、镜头与音频 |
| `video_minimax_h3_r2v` | MiniMax H3: Reference to Video | 参考生视频，可喂参考图、视频、音频组合 |
| `video_minimax_h3_multiframe_reference` | MiniMax H3: Multiframe Reference | 沿时间轴在任意位置锚定最多 4 个参考帧 |
| `video_minimax_h3_fun_controlnet_union` | MiniMax H3 Fun ControlNet Union | 用姿态/深度/Canny 等控制视频驱动，并支持 mask 局部重绘 |
| `video_fastvideo_fasth3_t2v` | FastVideo FastH3: Text to Video | 蒸馏 8 步版文生视频 |
| `video_fastvideo_fasth3_i2v` | FastVideo FastH3: Image to Video | 蒸馏 8 步版图生视频 |

### 付费 API 模板（9 个，`api: true`，本项目不涉及）

`api_minimax_h3_t2v`、`api_minimax_h3_i2v`、`api_minimax_h3_r2v`、`api_minimax_h3_flf2v`、`api_minimax_h3_max_t2v`、`api_minimax_h3_max_i2v`、`api_minimax_h3_max_r2v`、`api_minimax_h3_max_flf2v`、`api_minimax_h3_max_turbo_t2v`、`api_minimax_h3_max_turbo_i2v`。

> 付费 API / 云端（H3 Max 等）路线确实存在，但**不在本项目范围**，本项目只做本地免费能力。

## 3. 底层节点模式（官方文档原文）

- **MiniMax H3 Image to Video** 节点：覆盖 `t2va` 与 `fl2va`。
- **MiniMax H3 Reference to Video** 节点：覆盖 `ref2va`。
- 模板库给的 6 个（+1 个续写变体）只是**示例模板，不是穷尽列表**；模型支持更多生成模式，可以用原生节点自行搭建。

## 4. 各模板需要的模型文件与存放目录

### 磁盘目录结构（官方文档给出的原文结构）

```
ComfyUI/
├── 📂 models/
│   ├── 📂 diffusion_models/
│   │   └── minimax_h3_fl2va_pruned_int8_convrot.safetensors   # R2V 模板换成 ref2va 版
│   ├── 📂 text_encoders/
│   │   └── qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors
│   ├── 📂 vae/
│   │   ├── minimax_h3_video_vae_int8_convrot.safetensors
│   │   └── minimax_h3_audio_vae_fp32.safetensors
│   ├── 📂 loras/
│   │   └── minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors
│   └── 📂 embeddings/
│       └── minimaxh3_art_is_explosion.safetensors
```

### 逐个模板的文件清单

| 模板 | diffusion_models | loras | 额外 |
| --- | --- | --- | --- |
| T2V (`video_minimax_h3_t2v`) | `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | `minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors`（工作流 model scan 要求存在） | text encoder + 两个 VAE |
| I2V (`video_minimax_h3_i2v`) | `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | `minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors`（`turbo_mode` 开启时用） | text encoder + 两个 VAE |
| R2V (`video_minimax_h3_r2v`) | **`minimax_h3_ref2va_pruned_int8_convrot.safetensors`** | `minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors` | text encoder + 两个 VAE |
| Multiframe Reference | `minimax_h3_ref2va_pruned_int8_convrot.safetensors` | `minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors` | text encoder + 两个 VAE |
| Fun ControlNet Union | `minimax_h3_ref2va_pruned_int8_convrot.safetensors` + `rt_detr_v4-x-hgnet_fp16.safetensors` | `minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors` | `model_patches/minimax_h3_fun_controlnet_union_pruned_int8_convrot.safetensors`、`checkpoints/sdpose_wholebody_fp16.safetensors` |
| FastH3 T2V / I2V | `fastvideo_fasth3_8step_v2_pruned_int8_convrot.safetensors`（来自 https://huggingface.co/FastVideo/FastVideo-FastH3-Comfy） | 无（不需要 turbo LoRA） | text encoder + 两个 VAE（与基座共用） |

**所有模板共用的两个文件**：
- Text Encoder：`qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` → `ComfyUI/models/text_encoders/`
- 两个 VAE：`minimax_h3_video_vae_int8_convrot.safetensors`、`minimax_h3_audio_vae_fp32.safetensors` → `ComfyUI/models/vae/`

下载体积警告（官方文档原文）：**"The download is tens of gigabytes depending on the template"**，要预留磁盘空间与时间。实测文件体积见 `06-vram-performance.md`。

### LoRA 与 checkpoint 的匹配规则（官方文档重点提示）

- H3 的 LoRA **必须与它蒸馏时所用的 checkpoint 版本匹配**；当仓库同时发布 `pruned` 与完整版时，**取 `pruned` 版**。
- pruned 检查点用一条**短的共享曲线基**替换了 time embedder 与全宽 adaln 权重（`adaln_t_table`，**1025 个曲线采样 × 8 个基列**），ComfyUI 直接从 checkpoint 里读。
- 如果 LoRA 是在**完整版**上蒸馏的（`minimax_h3_fl2va_int8_convrot.safetensors` / `minimax_h3_ref2va_int8_convrot.safetensors`），它会带 adaln 权重，而 pruned 版里**没有对应张量** → ComfyUI 报 **shape mismatch 且不合并**，那部分 LoRA 被跳过。
- 工作流下载的 **turbo LoRA 不含 adaln 张量**，所以在两种 build 上都能加载。

## 5. FastVideo FastH3 模板结构（官方文档）

两个 FastH3 工作流与基座共用以下节点，但带蒸馏专属设置：

- **BlockSparseAttention**：跑 Video Sparse Attention（VSA），`keep_percent` **10**，从调度的 **20%** 处开始。
- **MiniMaxH3SigmaShift**：应用与蒸馏调度匹配的 H3 sigma shift（视频 **10**、音频 **3**）。
- **ComfyMathExpression**：把 duration 输入换算成 24fps 下符合 **17k+5** 网格的帧数 `length`。
- **Sampler**：`res_multistep` + `simple` 调度器，**8 步**。

## 6. 进阶原生节点用法（官方文档）

### 6.1 任意帧锚定参考 —— `MiniMaxH3AddGuide`

来源：Comfy-Org/ComfyUI PR **#15439**。

- 在它之前，关键帧**只能**锚在首帧和尾帧；该节点把限制去掉了，参考可以锚在**连续时间轴上的任意帧**。
- 接法：把 MiniMax H3 节点的 `positive` 与 latent 输出接到 `MiniMaxH3AddGuide`，然后至少提供一个 guide 输入：
  - **image**：静帧或片段。多帧 batch 会作为一个 clip 锚定，并被裁剪到模型合法的 clip 长度 **5、22、39… 帧（17k+5）**；**少于 5 帧的 batch 只取第一张图**。
  - **audio**：锚在同一 frame index 上的音轨，会裁到视频剩余时长。
  - **frame_idx**：锚定帧号，**负值从视频末尾倒数**。
  - **vae**：提供 image 时接视频 VAE；**audio_vae**：提供 audio 时接音频 VAE。
- 多个 `MiniMaxH3AddGuide` **串联**即可锚多个帧。
- ⚠️ **锚定 ≠ video-to-video**：生成仍从工作流的**空 latent** 起步并正常去噪；该节点只是把 guide 做 VAE 编码后**追加到 `positive` 条件**上，因此 **`denoise` 不会像图生视频那样缩放 guide 的强度**。
- 想「重绘风格」用 R2V 的参考视频；想「重绘片段」用 Fun ControlNet Union 的 mask 路线。
- 首尾帧锚定产生的坐标与之前一致，**旧工作流无需修改**。

### 6.2 局部重绘与延长 —— per-token latent noise mask

来源：Comfy-Org/ComfyUI PR **#15375**，为 MiniMax H3 增加了 **video 与 audio latent 都覆盖**的 per-token noise mask。

- 把 mask 接到采样器的 `denoise_mask` 输入：**0 = 保留该 latent 区域，1 = 重生成**。
- 视频 mask 会对齐到模型的 **2×2 latent patch 网格**，音频 mask 对齐到**整个 latent 帧**。
- 用途：局部 inpainting、物体移除、在保持既有内容稳定的前提下延长片段。

## 7. 官方文档给出的提示词粘贴位置与运行要点

- ConfyUI 的 H3 工作流把提示词写进文本编码节点；`integrated_multimodal_description` / `overall_soundscape` / `non_diegetic_music` 三段结构照抄官方格式（见 `04-prompt-guide.md`）。
- **负向提示词无效**（见 `03-parameters-limits.md` 第 5 节）——这是最容易踩的坑。
- 参考图/视频/音频用 `<Picture N>` / `<Video N>` / `<Audio N>` 标签在提示词里引用，编号顺序 = 连接顺序。

## 8. 官方给出的示例输入素材（便于复现）

| 模板 | 素材 |
| --- | --- |
| I2V | `transparent_rgb_gaming_mouse.png` |
| R2V | `red_superboy_on_city_roof.png`（角色参考）、`mecha_dragon_lightning.png`（风格与主体参考） |
| Multiframe Reference | `h3_frame_ref_1.png` ~ `h3_frame_ref_4.png`（分别锚在 0s / 1.5s / 3.0s / 5.0s） |
| Fun ControlNet Union | `dancer_field_pose.mp4`（姿态控制视频） |
| FastH3 I2V | `red_line_barrier.png` |

素材均可在 `https://raw.githubusercontent.com/Comfy-Org/workflow_templates/main/input/` 下取到。
