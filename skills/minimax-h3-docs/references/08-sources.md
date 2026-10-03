# 来源清单与抓取状态

- **抓取日期**：2026-10-03（Asia/Shanghai）
- **抓取工具**：`web_fetch` / `web_search` / `advanced_search` / 本机 ComfyUI 模板目录查询
- **说明**：本文件记录每个来源的真实抓取结果，供后续核对与增量更新。**抓取失败的条目如实标注，并保留 URL。**

---

## 1. 成功抓取的 URL

### 1.1 MiniMax 官方

| # | URL | 状态 | 取到的内容 |
| --- | --- | --- | --- |
| 1 | https://www.minimax.io/blog/minimax-h3 | HTTP 200 | 发布博客全文：模型定位、设计哲学、预训练范式、四项核心技术（Contextual Omni Representation / H3-VAE / H3-Omni Transformer / In-context Regeneration）、能力不足与未来计划 |
| 2 | https://design.minimaxi.com/h3 | HTTP 200 | H3 开源生态页：官方资源链接（HF / ModelScope / GitHub / 飞书使用手册）、社区评价、社区教程列表、FAQ 主题清单、许可要点 |
| 3 | https://huggingface.co/MiniMaxAI/MiniMax-H3/raw/main/README.md | ⚠️ 直连 huggingface.co **失败**，改走镜像 **成功**：https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/README.md | 官方模型卡全文：输出规格表、两个变体的输入规格、三模块系统、H3-Encoder / VisualVAE / AudioVAE / Omni-Transformer 架构、稀疏注意力说明、SGLang 部署示例、许可与联系方式 |
| 4 | https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md | ⚠️ 直连 **失败**，镜像 **成功**：https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md | 官方基座模式提示词指南全文（T2VA / I2VA / FL2VA / L2VA）：指令行、三核心字段、关键帧写法、运镜词表、说话人与对白规则、画面文字、两个音频字段、四个完整案例 |
| 5 | https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md | ⚠️ 直连 **失败**，镜像 **成功**：https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md | 官方全参考模式（R2V）指南全文：六个 section、四种引用标签、summary 任务类型、retention_analysis 关系标记、detailed_description 篇幅要求、说话人与音频关系、完整示例 |

### 1.2 ComfyUI 官方

| # | URL | 状态 | 取到的内容 |
| --- | --- | --- | --- |
| 6 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3 | HTTP 200（以 `.md` 取正文） | 总览：768p 原生画布与 2K 说明、六页文档索引、商用许可、版本门槛、LoRA 与 checkpoint 匹配规则、30 步/8 步/4 步、分辨率设置、采样器与调度器、shift 值、Sage Attention、INT8 质量问题、稀疏注意力 |
| 7 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native | HTTP 200（`.md`） | T2V / I2V / R2V 三个基础模板的完整模型下载清单与目录树、提示词要点、`MiniMaxH3AddGuide` 任意帧锚定、per-token latent noise mask 局部重绘 |
| 8 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3-multiframe | HTTP 200（`.md`） | 多帧参考工作流：四个参考帧锚定在 0s / 1.5s / 3.0s / 5.0s、`frame_idx` 计算、时间锚点与参考的区别、图集用法 |
| 9 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fun-controlnet | HTTP 200（`.md`） | Fun ControlNet Union：支持的 5 种控制类型、inpainting、完整文件清单（含 SDPose）、`guidance_scale` 保持 1.0、控制视频长度行为、预处理节点链接 |
| 10 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide | HTTP 200（`.md`） | 官方提示词指南的 ComfyUI 整理版：固定结构、字段顺序、对白与说话人规则、**负向提示词无效**的完整解释、R2V 音频复用标记、10 个风格 embedding 表 |
| 11 | https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fastvideo | HTTP 200（`.md`） | FastH3 两个模板：8 步固定、仅支持 T2V 与首尾帧 I2V、Ref2VA 未蒸馏、模型文件、节点结构（BlockSparseAttention / MiniMaxH3SigmaShift / ComfyMathExpression / Sampler） |
| 12 | https://docs.comfy.org/installation/system_requirements.md | HTTP 200 | ComfyUI 通用系统要求。**注意：该页不含 MiniMax H3 或视频模型的显存要求**，只说明支持的 OS / Python 版本 / 硬件种类 / PyTorch 要求 |
| 13 | https://blog.comfy.org/p/minimax-h3-day-0-support-in-comfyui | HTTP 200 | **ComfyUI 官方博客**（2026-08-03）：Day-0 支持、四项模型亮点、四条示例提示词、本地优化官方说明（**调制权重约 40% 被剪成查找表、总体积从 123.6 GB 降至 42.5 GB、配合动态显存卸载可在 RTX 3060 上跑**）、上手步骤 |

### 1.3 模型文件与体积

| # | URL | 状态 | 取到的内容 |
| --- | --- | --- | --- |
| 14 | https://hf-mirror.com/api/models/Comfy-Org/MiniMax-H3?blobs=true | HTTP 200 | **官方文件体积精确字节数**（全部 DiT 变体、三个文本编码器、三个 VAE、三个 turbo LoRA、四个 controlnet patch、十个 embedding）、仓库元数据（下载 22,813,102、likes 2,100、usedStorage 535.6 GB、lastModified 2026-09-29T11:11:09Z） |
| 15 | https://hf-mirror.com/Comfy-Org/MiniMax-H3/raw/main/README.md | HTTP 200 | **Comfy-Org 官方仓库 README**：完整目录结构、量化选择建议（**优先 int8_convrot 需 cu130；用不了才退 fp8_scaled**；**nvfp4 文本编码器不需要 Blackwell**）、embedding 用法、六个工作流链接 |
| 16 | https://huggingface.co/Comfy-Org/MiniMax-H3 | ⚠️ 页面直连未单独抓取，内容经 #14 与 #15 取得 | — |

### 1.4 FastH3 / 蒸馏版

| # | URL | 状态 | 取到的内容 |
| --- | --- | --- | --- |
| 17 | https://haoailab.com/blogs/fasth3-preview/ | HTTP 200 | **FastVideo 官方博客**（2026-08-27）：FastH3 Preview v1 的 4 步 VSA / Data-Free 推荐检查点、三个 checkpoint 的消融表、**完整官方性能表（B200 1×/4×/8×，Base H3 5s = 132.5s、10s = 377.4s、15s = 678.7s）**、加速倍数、DMD2 + VSA 90% 稀疏原理、帧数与分辨率样本规格、What's Next（含面向 RTX 的本地优化与显存缩减） |
| 18 | https://hf-mirror.com/FastVideo/FastVideo-FastH3-8-Step-V2/raw/main/README.md | HTTP 200 | **FastVideo-FastH3-8-Step-V2 官方模型卡**：step-1300、data-free DMD2 + VSA-H3 **80% 稀疏**、**需要 VSA-H3 注意力后端且 dense 不能替代**、**video scheduler shift 是 10 而非基座的 12**、实测默认用 4 张 B200、GPU 数需整除 H3 的 56 个注意力头、Scope 说明（支持 T2VA，FL2VA 与 Ref2VA 未蒸馏） |
| 19 | https://huggingface.co/FastVideo/FastVideo-FastH3-Comfy | ⚠️ 未单独抓取；其 Comfy 重打包说明经 ComfyUI 文档 #11 取得 | — |

### 1.5 第三方（已明确标注为非官方）

| # | URL | 状态 | 取到的内容 |
| --- | --- | --- | --- |
| 20 | https://modelvram.com/minimax-h3-vram-calculator/ | HTTP 200 | 第三方 VRAM 计算器与实测汇总：**14 条实测记录**（RTX PRO 6000 / 5090 / 4090 / 3090 / 5070 Ti 16GB / 4060 Laptop 8GB / **3060 12GB**），引用 HF discussion #59 与 ComfyUI GitHub issues #15665 / #16150 / #16148；11 种量化组合的权重体积、全部文件体积与峰值区间；「Fits / Tight / Streams / Risky」定义；系统内存与 `--disable-pinned-memory` 的 OOM 记录。**非官方，仅作规划参考。** |
| 21 | https://github.com/Comfy-Org/ComfyUI/issues/15529 | ⚠️ 仅由 ComfyUI 官方文档引用，**未直接抓取** | Comfy Kitchen attention 与 int8-convrot 检查点冲突（对齐错误）的官方 issue 编号 |
| 22 | https://github.com/Comfy-Org/ComfyUI/pull/15439 | ⚠️ 仅由官方文档引用，**未直接抓取** | `MiniMaxH3AddGuide` 节点的 PR |
| 23 | https://github.com/Comfy-Org/ComfyUI/pull/15375 | ⚠️ 仅由官方文档引用，**未直接抓取** | per-token latent noise mask 的 PR |
| 24 | https://github.com/Comfy-Org/ComfyUI/pull/15697 | ⚠️ 仅由官方文档引用，**未直接抓取** | H3 提示词 embedding 支持的 PR |

### 1.6 本机数据

| # | 来源 | 取到的内容 |
| --- | --- | --- |
| 25 | 本机 ComfyUI 模板目录查询（`search_templates query="minimax h3"`） | `total: 17`，与背景信息一致。8 个免费本地模板 + 9 个 API 模板的 name / title / description / tags / `api` 字段。详见 `02-comfyui-workflows.md` |
| 26 | 本机硬件快照 | GPU：NVIDIA GeForce RTX 5070，显存 12,820,938,752 字节（12 GB）；RAM 137,345,376,256 字节（128 GB）；OS Windows 10，arch AMD64 |

---

## 2. 抓取失败的 URL（如实记录）

| URL | 失败形态 | 处理方式 |
| --- | --- | --- |
| https://raw.githubusercontent.com/MiniMax-AI/MiniMax-H3/main/README.md | `Error: web fetch failed: TypeError: fetch failed`（**多次重试均失败**） | 同一份内容已通过 HF 官方模型卡镜像完整取得（#3）。**GitHub README 的正文本次未直接抓到。** |
| https://huggingface.co/MiniMaxAI/MiniMax-H3 | `Error: web fetch failed: TypeError: fetch failed`（**多次**） | 改走 `https://hf-mirror.com/` 镜像成功（#3、#4、#5） |
| https://huggingface.co/MiniMaxAI/MiniMax-H3/raw/main/README.md | `TypeError: fetch failed` | 同上，镜像成功 |
| https://cdn.jsdelivr.net/gh/MiniMax-AI/MiniMax-H3@main/README.md | `Error: cross-origin redirect to https://raw.githubusercontent.com is not followed automatically; retry against that URL directly` | 未继续（目标地址本身也不可达） |
| https://github.com/MiniMax-AI/MiniMax-H3 | HTTP 200，但返回的是 GitHub 导航壳 HTML，**正文被截断在 README 之前** | 内容以 HF 模型卡为准（#3） |
| https://www.minimaxh3tutorial.com/ | `Error: cross-origin redirect to https://www.genvidkit.com is not followed automatically` | 未重试，该站为第三方 SEO 站点，价值低 |
| `fetch_template`（`video_minimax_h3_t2v`） | `Error: Request timed out` | 模板参数信息全部以 ComfyUI 官方文档（#6–#11）为准，**未使用本机模板 JSON** |

**关于 `docs.comfy.org` 的抓取技巧（重要）**：这些页面是 Mintlify 托管的，直接抓 HTML 会得到大量导航壳并被截断。**在 URL 后加 `.md` 即可取到干净的完整 Markdown 正文**（例如 `https://docs.comfy.org/tutorials/video/minimax/minimax-h3.md`）。本文件所有 ComfyUI 文档内容均以此方式取得。

**关于 Hugging Face 的抓取技巧**：本环境下 `huggingface.co` 直连失败。可用镜像替代：
- 模型卡/文档：`https://hf-mirror.com/<owner>/<repo>/raw/main/<path>`
- 仓库 API（含文件体积）：`https://hf-mirror.com/api/models/<owner>/<repo>?blobs=true`

---

## 3. 已核实但本次未纳入知识正文的来源

| URL | 为什么不纳入 |
| --- | --- |
| https://platform.minimax.io/docs/api-reference/video-generation-v2-create 等官方 API 文档 | **付费 API / 云端路线不在本项目范围**（本项目只做本地免费能力） |
| https://comfy.org/minimax/license | 商业授权办理页，只引用其结论（Comfy 是本地商用许可唯一官方经销商），不展开 |
| https://platform.minimax.io/h3-license | 地区申请表单，只引用其存在与适用范围 |
| 飞书上的 H3 使用手册 / 开源资源 / 版本更新 / 本地部署指南文档 | 链接在生态页上确实存在，但为飞书托管文档，**本次未抓取**，正文不含其内容 |
| 一批 Bilibili 视频与知乎文章（标题多含「8G 显存可玩」「整合包」「破限制」等） | 社区内容，非权威来源；且部分涉及规避官方限制，**不作为知识依据** |
| `design.minimaxi.com/h3` 的 FAQ 折叠答案 | 页面为折叠组件，本次抓取只拿到 FAQ **问题清单**，**逐条答案未取到** |

---

## 4. 未取到答案的公开问题（后续可补）

1. **官方最低显存数字**：官方模型卡与 ComfyUI 官方教程**都没有**。目前只能引用 ComfyUI 博客的「42.5 GB 最小组合 + 动态卸载可在 RTX 3060 上跑」这一句定性结论。见 `06-vram-performance.md`。
2. **官方 FAQ 的「我需要什么硬件配置？」答案**：在 `design.minimaxi.com/h3` 上是折叠的，未取到。
3. **seed 参数**：所有已抓到的官方页面都未提及 H3 专属 seed 规格。
4. **H3 Technical Report**：官方博客称「即将分享」，本次抓取时未见发布。
5. **官方稀疏注意力实现**：官方称会「在后续更新中单独发布」，本次未发布。
6. **H3-Regenerate-2K 开源**：官方称「准备好后会发布」，本次未发布。
7. **FastH3 的 FL2VA / Ref2VA 蒸馏版**：FastVideo 称「未来几周」，本次未见。
8. **ComfyUI 官方是否修正了模板默认分辨率（1344×768）在低显存卡上的可用性说明**：官方只给了「模板自带快速预览尺寸」这一句，没有给出针对 12 GB 档的推荐配置。本 skill 的 12 GB 降级方案（见 `06-vram-performance.md` 第 7.2 节）是**基于已抓到的官方体积数据 + 第三方实测汇总的推断**，不是官方建议，已在正文标注。
