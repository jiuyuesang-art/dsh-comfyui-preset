# MiniMax H3 模型概述

- **来源 URL**：
  - https://www.minimax.io/blog/minimax-h3 （MiniMax 官方发布博客，2026-07-31）
  - https://huggingface.co/MiniMaxAI/MiniMax-H3 （官方模型卡 README，实际抓取走镜像 https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/README.md）
  - https://design.minimaxi.com/h3 （MiniMax 官方 H3 开源生态页）
  - https://blog.comfy.org/p/minimax-h3-day-0-support-in-comfyui （ComfyUI 官方博客，2026-08-03）
- **抓取日期**：2026-10-03
- **说明**：本文所有规格数字均来自上述官方页面原文，未做推测。凡官方未公布的项，明确标注「官方未公布」。

---

## 1. 定位：omni-modal 通才生成系统

MiniMax 官方对 H3 的定义（模型卡原文）：

> MiniMax H3 is a general-purpose, omni-modal generative system. It supports unified understanding of multimodal contexts composed of text, images, video, and audio, and can generate video with native stereo audio at resolutions up to 2K and durations of up to 15 seconds.

要点拆解：

- **统一多模态上下文理解**：文本 / 图像 / 视频 / 音频四种模态在**同一个上下文**里被联合理解，再由自然语言描述它们之间的关系。
- **原生立体声音频**：音频不是后处理贴上去的，而是与视频在**同一次前向传播**中联合生成，输出为原生 stereo。
- **任务通才**：官方明确设计目标是「打破任务边界」——不再把 T2I / 编辑 / 主体参考 / 运动参考 / 风格参考 / T2V / I2V / 首尾帧 / 视频编辑 拆成不同专家模型。

官方博客给出的标志性例子是这条 prompt：

> "Reference the Hitchcock camera movement from Video 1, have the character in Image 2 sing, with the vocals matching Audio 3."

即：把「运镜来自视频 1、人物来自图像 2、嗓音匹配音频 3」直接用一句话说清楚，模型自己处理跨模态对应。

## 2. 与前代（Hailuo 系列）的关系

ComfyUI 官方博客原文：

> It is MiniMax's third-generation video model, following Hailuo 01 and Hailuo 02, and the first the company has released with open weights.

- **Hailuo 01**：从零搭起整套系统。
- **Hailuo 02**：转向提升架构效率、数据质量与规模等核心组件。
- **H3**：第三代，**首次开放权重**。官方明确说 H3 设计时**放弃了 Hailuo-02 的架构**，因为那套架构对「面向任务泛化的模型」会引入不必要的复杂度。

技术演进（官方博客）：

| 组件 | 作用 |
| --- | --- |
| H3-Contextual Omni Representation | 强化 caption 能力：不只描述目标视频，还要描述「上下文与目标视频的关系」「上下文内部元素之间的关系」；为此官方建了专用多模态理解流水线，多数素材原始推理约 100K tokens，蒸馏到平均约 4K tokens |
| H3-VAE | 彻底重做 tokenizer，重建质量与可学习性全面提升；高压缩比带来**有效序列长度 4 倍增益**，大幅降低训练与推理成本，是**原生 2K 支持的关键技术** |
| H3-Omni Transformer | 理解与生成的工作负载在训练架构上分离，分别调优硬件利用率；端到端训练吞吐提升近 30% |
| H3-In-context Regeneration | 2K 输出不用传统超分模块，而是让 H3 base 自己在上下文中重生成低分辨率结果；能恢复传统超分「只能猜」的小字与细节 |

## 3. H3 / H3 Max / FastH3 的区别

| 名称 | 是什么 | 是否本地方案 | 本项目范围 |
| --- | --- | --- | --- |
| **MiniMax H3**（H3-Base） | 开放权重的基座，两个任务专用 checkpoint：`H3-Base-FL2VA`、`H3-Base-Ref2VA` | ✅ 本地免费，ComfyUI 原生支持 | **本项目主对象** |
| **MiniMax H3 Max** | 托管/后训练版本（ComfyUI 模板标题为 "MiniMax H3 Max"，另有 Max Turbo） | ❌ 走付费 API / 伙伴节点，模板 tags 带 `API` | 付费 API 路线存在但**不在本项目范围** |
| **FastH3（FastVideo FastH3）** | FastVideo 团队基于 H3 做的 DMD2 **蒸馏**加速 checkpoint | ✅ 本地免费 | 本项目**强烈推荐的降级方案**，见 `05-fasth3.md` |

补充：官方规格表里 2K 输出靠 **H3-Regenerate-2K** 模块实现，而该模块**尚未开源**（模型卡原文："Due to the complexity of the system, this module is not yet open-sourced"）。同理 **H3-Context-IR**（官方的提示词预处理/编排系统）也未开源，只提供 API。所以**本地开源权重实际产出 768p**。

## 4. 完整系统由三个模块组成

官方模型卡原文：

- **H3-Context-IR**：托管的预处理与编排系统。包含指令解析、跨模态关联、时间理解、复杂逻辑推理；把理解结果序列化为 H3-Base 能接受的结构化表达（Context Intermediate Representation）。**未包含在本次开源中**。官方强调它对最终输出质量**至关重要**，强烈建议纳入流水线，或参照官方 Prompting Guidance 自建上下文处理系统。
- **H3-Base**：根据 H3-Context-IR 的输出生成音视频，产出 **768p**。
- **H3-Regenerate-2K**：把 768p 结果连同原始上下文再喂回 H3，在 2K 重生成。**未开源**。

> 对本地玩家的含义：本地开源权重 = H3-Base，**只能出 768p**；官方 API 那条链路里的 Context-IR 与 2K 重生成，本地拿不到。ComfyUI 文档也明说 2K 需要「另一趟单独的上采样」。

## 5. 官方输出规格（模型卡原文表格）

| 类别 | 规格 |
| --- | --- |
| 输出时长 | **4–15 秒** |
| 输出宽高比 | 支持多种，包括但不限于 21:9、16:9、4:3、1:1、3:4、9:16 |
| 输出分辨率 | 多种尺寸；**短边默认 768 像素**；2K 需 H3-Regenerate-2K |
| 输出帧率 | **24 FPS** |
| 输出音频 | **32 kHz 立体声** |
| 支持的对话语言 | 稳定支持 **11 种**：阿拉伯语、中文、英语、法语、德语、意大利语、日语、韩语、葡萄牙语、俄语、西班牙语；其他语言也有不同程度支持 |

### 两个模型变体的输入规格

| 变体 | 输入模式 | 规格 |
| --- | --- | --- |
| **H3-Base-FL2VA** | 首尾帧模式 | 支持 0 / 1 / 2 张输入图：无图 = 文生视频；1 张 = 首帧生视频或尾帧生视频；2 张 = 首尾帧生视频 |
| **H3-Base-Ref2VA** | 全模态参考模式 | 图像 **≤ 9 张**；视频 **≤ 3 段**（每段 2–15 秒，总时长 ≤ 15 秒）；音频 **≤ 3 段**（每段 2–15 秒，总时长 ≤ 15 秒）；**跨所有输入类型的文件总数上限 12** |

## 6. 架构细节（模型卡原文）

- **H3-Encoder**：使用 **Qwen3-VL-32B 的完整预训练权重**，把**第 50 层**的 hidden states 提供给 H3-Omni-Transformer。额外往 tokenizer 里加了若干特殊 token（如 `<d>`）；使用时**必须带上 H3 仓库提供的 tokenizer 与配置文件**。
  - ⚠️ 这解释了为什么下载体积里有一个 ~15.7 GB 的 Qwen3-VL-32B 文本编码器——本地跑的「文本编码器」其实是个 32B 的 VL 大模型。
- **H3-VisualVAE**：时间因果视频自编码器，空间压缩 16×、时间压缩 4×、24 个 latent 通道，记作 **f16t4d24**。进入 Transformer 前再按 `1 × 2 × 2`（t, h, w）patchify，所以进 Transformer 的视觉 token **有效空间下采样 32×，时间下采样仍为 4×**。训练完 encoder 后额外训了一个 ViT-based decoder 以降低解码开销并提升重建质量。
- **H3-AudioVAE**：左右声道**共用同一套 encoder/decoder**，各声道独立处理后再合并，从而支持立体声输入输出。每个声道把 **32 kHz 音频压缩成时间率 40 Hz** 的 latent token 序列。
- **H3-Omni-Transformer**：
  - **33B 参数稠密单流 Transformer**，其中**约 13B 参数位于 AdaLN 相关分支**；
  - 因为 AdaLN 调制输出**可预计算并缓存**，**纯推理部署时这 13B 不需要加载**（→ 这是「pruned」检查点能把体积砍下来的原理，见 `06-vram-performance.md`）；
  - 注意力层与 FFN 层**不含模态专用结构**，模态专用参数只集中在输入/输出层与 AdaLN 分支；
  - 位置编码用 **3D 多模态 RoPE（MM-RoPE）**，覆盖 `(t, h, w)`。
- **稀疏注意力**：训练最后阶段引入了 native sparse attention 以降低长序列计算成本，但**初始开源版本只提供 full attention 推理**，稀疏实现官方说会在后续更新中单独发布。
- 放出的两个 checkpoint 都是 **CFG-distilled** 的 Omni Transformer 权重。
- 每个 checkpoint 是自包含的 Hugging Face 风格仓库：`model_index.json` / `processor/` / `tokenizer/` / `text_encoder/` / `transformer/` / `visual_vae/` / `audio_vae/`。

## 7. 官方推荐的推理框架

模型卡列出：**SGLang、vLLM、diffusers、ComfyUI**。官方给的 SGLang 部署示例用的是 **4 张 GPU**（`--num-gpus 4 --ulysses-degree 4`），可作为「官方默认部署门槛不低」的参考。

## 8. 开源生态页提供的资源（design.minimaxi.com/h3）

- Hugging Face 权重：https://huggingface.co/MiniMaxAI/MiniMax-H3
- 魔搭社区：https://modelscope.cn/models/MiniMax/MiniMax-H3
- GitHub：https://github.com/MiniMax-AI/MiniMax-H3
- H3 使用手册（飞书）：https://vrfi1sk8a0.feishu.cn/wiki/FIWjwgL33ipnkekzk30crmKUnIh
- 官方在线体验：https://design.minimaxi.com/
- 该页 FAQ 主题含：「MiniMax H3 是免费的吗？」「我需要什么硬件配置？」「如何编写好的 Prompt？」「哪些内容是不允许生成或使用的？」等（FAQ 正文为折叠内容，本次抓取未能取到逐条答案）。

## 9. 许可（重要）

- 许可是 **MiniMax H3 Community License Agreement**（不是 Apache/MIT 这类标准开源许可）。
- 生态页/社区许可要点：授予免版税商用；但 **商业产品/服务年收入超过 2,000 万美元需另行书面授权**（联系 api@minimax.io）。
- **USA / EU / UK / South Korea 地区下载模型权重受限**，需走申请表：https://platform.minimax.io/h3-license
- **在自有硬件上本地运行生成内容的商用授权，Comfy 是 MiniMax 商业使用许可的唯一官方经销商**：https://comfy.org/minimax/license （ComfyUI 文档与 comfy.org 均如此声明）；Comfy Cloud 上的生成已含商用权利。

## 10. 版本时间线（据本次抓到的来源）

| 日期 | 事件 | 来源 |
| --- | --- | --- |
| 2026-07-31 | MiniMax 官方发布 H3 博客（当时称「未来数日开源权重」） | minimax.io/blog/minimax-h3 |
| 2026-08-03 | ComfyUI 官方博客：Day-0 支持，含本地优化（66% 内存缩减） | blog.comfy.org |
| 2026-08-27 | FastVideo 发布 FastH3 Preview v1（4 步 VSA / Data-Free） | haoailab.com/blogs/fasth3-preview |
| 2026-09-29 | Comfy-Org/MiniMax-H3 仓库最后更新 | HF API |

## 11. 官方未公布 / 本次未取到的项

- **官方最低显存数字：没有。** 官方模型卡与 ComfyUI 官方教程都**没有**给出最低 VRAM 要求。ComfyUI 官方博客只给「最小文件组合总足迹 42.5 GB」与「配合动态显存卸载可在 RTX 3060 这类 GPU 上本地跑」这一句定性结论。详见 `06-vram-performance.md`。
- **种子（seed）参数**：官方页面未记录 H3 专属 seed 参数；ComfyUI 工作流里 seed 由标准采样节点提供，官方文档未给出取值范围说明。
- GitHub README 正文：`raw.githubusercontent.com` 直连抓取失败（见 `08-sources.md`），但同一份内容已通过 HF 模型卡镜像完整取得。
