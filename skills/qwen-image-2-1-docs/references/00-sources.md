# 来源清单与抓取状态

抓取日期：**2026-10-03**（所有条目）。

## 成功抓取

| # | 来源 | 实际抓取 URL | 说明 |
| --- | --- | --- | --- |
| S1 | ComfyUI 官方文档：Qwen-Image-2.1 原生工作流示例 | `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（Markdown 版：`https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1.md`） | 最详细的一手来源：模板、模型文件、目录、参数、分辨率语义、KV cache、提示词增强 |
| S2 | Qwen 官方 GitHub 仓库 README | `https://github.com/QwenLM/Qwen-Image-2.1`（blob 视图 `https://github.com/QwenLM/Qwen-Image-2.1/blob/main/README.md`） | 架构章节、News、官方 diffusers 用法、量化/并行生态 |
| S3 | Qwen 官方 HuggingFace 模型卡 | `https://huggingface.co/Qwen/Qwen-Image-2.1`（经镜像 `https://hf-mirror.com/Qwen/Qwen-Image-2.1`，原始 Markdown：`https://hf-mirror.com/Qwen/Qwen-Image-2.1/raw/main/README.md`） | 官方权重、宽高比表、RGBA 推荐提示词、许可证 |
| S4 | Comfy-Org 重打包模型卡 | `https://huggingface.co/Comfy-Org/Qwen-Image-2.1`（经镜像 `https://hf-mirror.com/Comfy-Org/Qwen-Image-2.1`） | ComfyUI 文件清单与目录、工作流链接、PE 模型出处 |
| S5 | ComfyUI 官方博客 | `https://blog.comfy.org/p/qwen-image-21-in-comfyui-open-weight` | 面向用户的定位介绍（"优化的 MMDiT 架构"、消费级显卡可跑） |
| S6 | ModelScope 官方模型页 API | `https://modelscope.cn/models/Qwen/Qwen-Image-2.1`（数据接口 `https://modelscope.cn/api/v1/models/Qwen/Qwen-Image-2.1`） | 国内镜像；给出各分片 safetensors 的**精确字节数**与 sha256 |
| S7 | 社区精选索引：awesome-qwen-image | `https://github.com/wildminder/awesome-qwen-image` | ComfyUI 官方文件的精确体积、量化谱系、显存计算器链接、六条实用坑位 |
| S8 | ModelVRAM 显存计算器（Qwen-Image-2.1 专用） | `https://modelvram.com/qwen-image-2-1-vram-calculator/` | 各精度文件体积 + 8/12/16/24/32GB 实测峰值区间（字节数读自 HF API，2026-09-29） |

## 抓取失败 / 无法使用

| 来源 | URL | 状态 |
| --- | --- | --- |
| Qwen 官方博客（发布公告） | `https://qwen.ai/blog?id=qwen-image-2.1` | **抓取失败**——返回 HTTP 200 但页面为纯前端渲染 SPA，正文取不到（只拿到站点标题 "Qwen"）。该 URL 由官方模型卡与 README 共同指向，确认存在。方式上也尝试过 `web.archive.org` 快照，网络不可达。**本包中凡涉及"官方博客数字"的内容均未采信，因为没有拿到正文。** |
| Qwen 旧 GitHub Pages 博客 | `https://qwenlm.github.io/blog/qwen-image-2.1/` | **404**（该站已迁移到 qwen.ai，页面自身提示 "We have a new blog at qwen.ai"） |
| GitHub raw 直链 | `https://raw.githubusercontent.com/QwenLM/Qwen-Image-2.1/main/README.md` | **抓取失败**（该域名在本环境不可达）。已改用 github.com blob 视图 + `ghproxy.net` 代理取得同一份内容（见 S2） |
| HuggingFace 直链 | `https://huggingface.co/...` | **抓取失败**（该域名在本环境不可达）。已改用 `hf-mirror.com` 镜像取得同一份内容（见 S3、S4） |
| ComfyUI 博客（猜测路径） | `https://blog.comfy.org/p/qwen-image-21` | **404**（正确路径见 S5） |
| 第三方中文教程 | `https://yololab.net/archives/qwen-image-2-1-comfyui-local-guide` | **正文未取到**（HTTP 200 但只返回标题）。未采信其任何内容 |

## 采信原则

- **只用官方与可核实的来源**（S1–S6 为官方/一手，S7–S8 为社区可复核数据，且明确标注来源）。
- 凡本包出现的具体数字，都能在对应 references 文件中看到它是从哪个来源来的。
- 未抓到的页面（官方博客）**不推测其内容**；如后续需要博客里的 benchmark 数字，需重新抓取。
