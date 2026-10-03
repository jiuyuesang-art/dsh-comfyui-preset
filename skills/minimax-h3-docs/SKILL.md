---
name: minimax-h3-docs
description: MiniMax H3 官方文档离线快照（ComfyUI 本地免费路线）。当用户要用 MiniMax H3 生成视频（文生视频/图生视频/参考生视频/首尾帧/多帧参考）、需要该模型的时长与分辨率上限、采样步数与推荐参数、显存要求、提示词写法、原生音频能力，或问「本机 12GB 显存能不能跑 H3」时使用。
---

# MiniMax H3 离线知识快照

面向**本地免费路线**（ComfyUI + 开放权重）。付费 API / 云端（H3 Max 等）路线存在但**不在本项目范围**。
所有数字来自官方文档，来源与抓取状态见 `references/08-sources.md`。官方未公布的项一律标注，不推测。

## 🚨 硬告警：本机 12GB 显存是硬约束

**本机 GPU = NVIDIA RTX 5070 / 12GB 显存 + 128GB 内存。**

- **官方模板的默认配置在这台机器上不可行。** 默认是 1344×768 / 124 帧 / 20 步，而模板默认权重组合（pruned int8 DiT 20.97GB + nvfp4 文本编码器 15.69GB + 视频 VAE 2.81GB + 音频 VAE 0.61GB）**合计约 40GB**。12GB 装不下任何一套权重，**全程只能靠动态显存卸载经 PCIe 逐步搬运**。
- **实测参照**：24GB 的 RTX 3090 跑 832×480 / 124 帧 / 20 步峰值就要 **23,716 MiB**；16GB 的 RTX 5070 Ti 跑 1280×736 / 362 帧实测 **26 分 20 秒（约 79 s/步）**，换版本后恶化到 **341+ s/步（约 2 小时）后被取消**。
- **结论**：12GB 上 H3 是「**慢速草稿机**」，不是「出片机」。舒适档需 24–32GB。**长片段（10 秒以上）跑得动但等不起；1344×768 高分辨率大概率 OOM 或慢到不可用。** 官方只说过「配合动态显存卸载可在 RTX 3060 这类 GPU 上跑」，**从未给出最低显存数字**。

**可执行降级方案（按优先级）：**

1. **一律走蒸馏路线**：优先 `video_fastvideo_fasth3_t2v` / `..._i2v`（**8 步固定，不要改步数**），或在基座模板打开 `turbo_mode`（T2V/I2V 用 8 步，R2V 系列用 4 步 turbo LoRA）。
2. **分辨率降到 864×480 或 640×480**：Resolution Selector 的 Megapixels 设 **0.4 或更低**，`Multiple` 保持 **32**。**不要去够 1344×768。**
3. **时长压到 5 秒**（`length` = **124 帧**）。这是 12GB 上唯一现实的档位。
4. **换更小的权重**：官方最小 DiT 是 `minimax_h3_fl2va_pruned_w6a8.safetensors`（**15.98GB**，比模板默认的 pruned int8 小 5GB）。
5. **打开 Sage Attention**（约 2× 提速），接受「片段末尾形变 / 画面文字乱码」的风险。**不要**开 `--use-ck-attention`：它不支持模板自带的 int8-convrot 检查点（**采样会崩，issue #15529**），换 bf16 又放不下（40.23GB）。
6. **先跑一次 640×480 / 124 帧 / 8 步试探**，确认链路与真实耗时，再决定是否加码。
7. **跑不动就直说不行。** 用户要 1344×768 或 10 秒以上时，明确告知本机 12GB 不适合，**不要硬试**；出路是 Comfy Cloud 或伙伴节点（付费，不在本项目范围）。

> 耗时量级（**推算，非官方、非实测**）：FastH3 8 步 / 864×480 / 5 秒在 12GB 上是**数分钟到十几分钟**量级。最接近的可比实测是 **RTX 3060 12GB + 8 步 Turbo LoRA + INT8 视频 VAE 跑 864×480 / 5s = 4.5 分钟**。真实耗时必须实测。

> 📌 **重要补充：本机走的不是上面这套官方权重，而是更轻的 GGUF 路线。**
> 上面的 40GB / 23,716 MiB 等数字针对**官方模板默认组合**（pruned int8 DiT 20.97GB + nvfp4 文本编码器 15.69GB …）。
> **本机实际装的是 4-bit GGUF**：`unet_gguf/MiniMax-H3-Ref2VA-Pruned-Q4_K_M.gguf`（及 FL2VA 版、Q6_K 版）+ `clip_gguf/qwen3vl_32b_minimax_h3-Q4_K_M.gguf` + 双 VAE + turbo LoRA，**权重体积比官方 int8 组合小一个数量级**。
> 用户已为这套配置备好工作流（`…\ComfyUI\user\default\workflows\宗主跳舞替换_Ref2VA官方规范版.json`）。
> ⚠️ **但 H3 在本机尚未有成功产出的证据**：该工作流文件存在，可 `ComfyUI\output\` 下**找不到任何 H3 产物**（`output\video\` 为空，全盘无 H3 / Ref2VA / bomu 命名的文件），说明它要么没跑过、要么跑失败或被取消。与之对比，Qwen Image 2.1 侧有明确产出证据。
> **结论校准：本机权重齐全、链路可行，但 H3 的真实耗时与成功率仍需你亲自跑一次才能确认。** 请从上面的降级方案 ① ② ③（蒸馏步数 + 0.4 MP + 5 秒）起步实测，不要一上来就按官方默认配置。实际出图请以 `comfyui-mcp-ops` 手册 §3.2 的配方为准。

## 主题索引

| 主题 | references 文件 |
| --- | --- |
| 模型概述：omni-modal 定位、Hailuo 三代关系、H3 vs H3 Max vs FastH3、架构、规格表、许可 | `references/01-model-overview.md` |
| ComfyUI 使用方式：17 个模板（8 免费 / 9 API）、各模板模型文件与存放目录、进阶节点 | `references/02-comfyui-workflows.md` |
| 参数与限制：时长、分辨率、帧率、帧数网格、步数、采样器、shift、guidance、seed | `references/03-parameters-limits.md` |
| 提示词指南：固定结构、运镜词表、对白与说话人、全参考六段结构、官方案例 | `references/04-prompt-guide.md` |
| 音频能力：原生立体声、音频收敛时机、对白/音效/环境音控制、音频参考 | `references/05-audio.md` |
| 显存与性能：官方优化说明、文件体积、实测数据、本机 12GB 可行性判断 | `references/06-vram-performance.md` |
| 能力边界与已知问题：口型、文字、长镜头、失败模式、未来计划、合规限制 | `references/07-limits-and-issues.md` |
| 来源清单与抓取状态：成功/失败 URL、抓取技巧、未解问题 | `references/08-sources.md` |

## 关键规格速查（官方）

| 项 | 值 |
| --- | --- |
| 时长 | **4–15 秒**（ComfyUI 模板表述 5–15 秒） |
| 帧率 | **24 FPS**（模型固定） |
| 帧数网格 | `length` 是帧数，**吸附到 17k+5 网格**；默认 **124 帧 ≈ 5 秒**；5/10/15 秒 = 124/243/345 帧 |
| 分辨率 | 短边默认 **768**；16:9 原生画布 **1344×768**（约 1 兆像素，**面积上限 768×1344**）；对齐到 **32 的倍数** |
| 2K | 靠 **H3-Regenerate-2K**，**未开源**；本地只能出 768p，2K 需另走一趟上采样 |
| 音频 | **32 kHz 立体声**，与视频同一次前向联合生成 |
| 对话语言 | 稳定支持 **11 种**（含中/英/日/韩/法/德/意/葡/俄/西/阿） |
| 采样器 / 调度器 | `res_multistep` + `simple`（所有本地 H3 工作流） |
| 步数 | 基座 **20**；turbo T2V/I2V **8**、R2V 系列 **4**；**FastH3 固定 8**；简单镜头 12–16；高频细节可达约 50 |
| shift | 基座 `shift` **12** / `audio_shift` **3**；FastH3 `shift_video` **10** / `shift_audio` **3** |
| guidance | `guidance_scale` **1.0**；走 `BasicGuider`，`cfg` = 1 |
| 模型变体 | `fl2va`（T2V/I2V/首尾帧）与 `ref2va`（参考）是**两套不同权重**，不能混用 |
| 参考上限（R2V） | 图 **≤9**、视频 **≤3**（各 2–15s，总 ≤15s）、音频 **≤3**（各 2–15s，总 ≤15s）、**文件总数 ≤12** |
| 引擎 | H3-Encoder 用 **Qwen3-VL-32B** 第 50 层；H3-Omni-Transformer **33B** 稠密（约 13B 在 AdaLN，推理可不加载） |
| ComfyUI 版本 | 基础模板 ≥**0.30.0**；Multiframe ≥**0.34.0**；ControlNet/稀疏注意力 ≥**0.35.0**；FastH3 ≥**0.36.0** |

## 提示词要点

- **三段固定结构**：`integrated_multimodal_description:` / `overall_soundscape:` / `non_diegetic_music:`（全参考模式主字段改叫 `detailed_description`，且有六段结构）。
- **用英文写**；只有 `<d>` 内的对白歌词、以及画面可见文字保留原语言，**逐字照抄**。
- **画面文字用英文双引号**（`A red neon sign reading "营业中" glows above the doorway.`）；**对白用 `<d>` 标签**，两者不混用。
- **镜头写法**：`[Shot 1]` 不加时间戳；后续 `[Shot 2] At 00:03.500, the camera cuts to...`。**只是想换景别或角度时优先用运镜，不要切镜。**
- **运镜 = 运动类型 + 幅度 + 速度**（`Push In` / `Pan Right` / `Arc Shot` / `Static Shot`… + `with small amplitude` + `at slow speed`），写成自然英文动作句，不要堆标签。
- **说话人用稳定 ID** `(S1)`/`(S2)`（**编号的是说话人不是主体**，不发声的角色不给 ID）；`<d>` 外放识别描述+ID+动作+念白方式，`<d>` 内只放语言标签+台词。
- **画外音**用 `says in an off-screen voiceover`，并紧跟一句说明画内角色嘴唇保持闭合。
- **R2V 按标签引用**：`<Picture 1>` / `<Video 1>` / `<Audio 1>`，编号顺序 = 连接顺序；**给每个参考明确分工**（身份/风格/运动/镜头/声音）。
- **禁止写成正面描述**：写「门上方的招牌是空白的」，**不要**写「不要有字幕」。
- 官方完整指南：`docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md`（T2VA/I2VA/FL2VA/L2VA）与 `..._ref_en.md`（R2V）。

## 最容易踩的三个坑

1. **负向提示词完全无效**：H3 走 `BasicGuider`（单一条件输入，`cfg` = 1，ComfyUI 跳过无条件 pass）。点名不想要的东西**反而会把它加进模型读到的描述里**。必须把禁令改写成正面描述。
2. **LoRA 与 checkpoint build 必须匹配**：在完整版上蒸馏的 LoRA 带 adaln 权重，pruned 检查点里没有对应张量，ComfyUI **静默跳过**（只报 shape mismatch），效果不对但看不到报错。**仓库同时发布 full 与 pruned 时取 pruned。**
3. **音频比画面收敛晚**：8 步时语音与音色是**输出里最弱的部分**，**12 步及以上音轨才可用**；短调度（4 步）下参考可能几乎没被应用，姿态与面部角度会随片段推进漂离参考。
