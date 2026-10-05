---
name: comfyui-docs
description: ComfyUI 官方文档离线快照 + 全站索引。要查节点、工作流、模型下载、报错含义、官方教程时加载。含 docs.comfy.org 全站目录，按需取具体页。
---

# ComfyUI 官方文档离线快照

本技能包是 **docs.comfy.org 的离线知识快照 + 全站索引**，全部中文撰写，保留官方英文术语原文以便检索。
每条内容都标注了**来源官方 URL**，抓取日期统一为 **2026-10-03**。只覆盖**本地免费能力**；云端/付费路线（Comfy Cloud、partner 模型、Cloud API key）一律只做一句提示，不在范围内。

## 主题索引

| 主题 | 文件 | 讲什么 |
|---|---|---|
| **全站索引** | [00-site-index.md](references/00-site-index.md) | **1957 条**官方页面链接，按 6 大栏目分组（入门/开发/自定义节点/内置节点/Router schema/OpenAPI），每条含官方中文标题 + 一句话说明 + 行号定位；是「找一个页面」的入口 |
| **Agent 工具 / MCP** | [01-mcp-agent-tools.md](references/01-mcp-agent-tools.md) | 两条官方路线（本地 `comfy-mcp` 走 stdio / 云端走远程 HTTP+OAuth）、安装、`COMFY_BIN`、各家客户端配置、本地工具清单、计费、硬件建议、已知限制 |
| **核心概念** | [02-core-concepts.md](references/02-core-concepts.md) | 工作流=节点图、节点四种状态、Mode（Always/Never/Bypass）、连线与颜色类型表、properties 与 widget/input slot、依赖四分类与冲突解法 |
| **工作流 JSON** | [03-workflow-json.md](references/03-workflow-json.md) | **API format** vs UI 保存格式逐字段对照、官方完整示例、手写/改法、`class_type` / `inputs` / `["id", slot]` 连线、v1.0 与 v0.4 schema、嵌入文件的 workflow metadata |
| **自定义节点与 Manager** | [04-custom-nodes-and-manager.md](references/04-custom-nodes-and-manager.md) | 自定义节点四类、三种安装方式、依赖必须装进哪个 Python 环境、ComfyUI-Manager 启用/新 UI/配置项/故障排查 |
| **模型与目录** | [05-models-and-directories.md](references/05-models-and-directories.md) | `models/` 各子目录归属、`extra_model_paths.yaml` 写法、系统要求与 GPU 支持、模型架构不匹配等报错 |
| **报错排查** | [06-troubleshooting.md](references/06-troubleshooting.md) | 官方排查方法论、缺失节点/缺失模型原文报错、OOM 递进式降显存、CUDA/Blackwell/AMD/Apple/Intel 专项、上报 bug 所需信息 |
| **官方模板库** | [07-templates.md](references/07-templates.md) | 模板怎么打开/使用、内嵌模型直链机制、缺失模型检测规则、`example_workflows` 写法、模板包更新 |

## 最关键结论（不展开 references 也有用）

1. **工作流就是一张节点图**：节点是点（做一件事），连线（link）是数据流，属性（properties）控制怎么做。**属性可在 widget 与 input slot 之间互转**——这就是同一个参数有时是输入框、有时是输入点的原因。
2. **程序化提交必须用 `API format`**：顶层是「**节点 id 字符串 → 节点对象**」；节点对象形如 `{"class_type": "KSampler", "inputs": {...}, "_meta": {"title": "..."}}`。**连线写法 = 把输入值写成 `["上游节点id", 输出槽序号]` 两元素数组**（序号从 0 起，按上游输出顺序）；常量直接写值。UI 保存格式完全不同，用顶层 `nodes[]` + `links[]`（`origin_id`/`origin_slot`/`target_id`/`target_slot`）。导出路径：`File → Export Workflow (API)`。
3. **本地免费接 agent 用 `comfy-mcp`**：`pip install comfy-mcp`（**stdio**，需 Python 3.10+、`comfy-cli>=1.14.0`、一个工作区、以及**自己先 `comfy launch` 保持 ComfyUI 运行**）；客户端若找不到 `comfy` 就设 `COMFY_BIN` 绝对路径。**任何操作前先调 `server_info()`**。
4. **「缺失节点」先分清两种**：**Comfy Core 节点**缺失 = ComfyUI 版本旧 → **升级 ComfyUI**；**自定义节点**缺失 = 用 ComfyUI Manager 安装。
5. **「缺失模型」的官方报错长这样**：`Value not in list: ckpt_name: 'xxx.safetensors' not in []`（`[]` 说明该类型目录里一个文件都没看到）。模型要放 `ComfyUI/models/<类型>/`；换目录用 `extra_model_paths.yaml`，**改完必须重启 ComfyUI**。
6. **自定义节点装完仍报 `import failed` / 节点仍缺失，多半是依赖装错了环境**：依赖**必须装进 ComfyUI 自己的 Python 环境**。Portable 版用 `python_embeded\python.exe -m pip install -r ComfyUI\custom_nodes\<节点>\requirements.txt`；在系统级 Python 里 `pip install` 会导致 ComfyUI 环境依然缺依赖。
7. **排查顺序（官方方法论）**：**先用 `--disable-all-custom-nodes` 启动** → 问题消失 = 自定义节点引起 → 用**二分法**（或 `comfy-cli node bisect start/good/bad/reset`）定位到单个节点。**带前端扩展的节点最容易出问题**，且禁用/启用它们**只需 reload 前端、不用反复重启**。
8. **OOM / 显存不足的递进手段**：`--lowvram` → `--novram` → `--cpu`（最后手段）；配合 `--force-fp16`、`--use-pytorch-cross-attention`，并**降分辨率 / 降 batch size**。
9. **模板由独立依赖 `comfyui-workflow-templates` 管理**（不是 ComfyUI 本体）——「更新后没有新模板」先升这个包。模板**内嵌模型下载直链**（只支持 Hugging Face / Civitai，且只接受 `.safetensors`、`.sft` 这类安全格式，`.gguf` 会被标记不安全且不显示链接）；**缺模型检测只看顶层目录的同名文件**，所以模型放在子目录时**可以忽略弹窗**，只要在 loader 节点里选对即可。
10. ⚠️ **任何需要客户端-服务端通信的自定义节点，都无法通过 API 使用**（官方原文）。走 MCP / API 提交工作流时，这类「Connected」节点不可用，选节点优先纯服务端节点。

## 怎么读这些文件

- **先查本页的主题索引定位文件，再读那一个 references 文件**——不要一次性全读。
- **取正文的诀窍**：官方文档站是 Mintlify，**在任意文档 URL 末尾加 `.md` 就能拿到无导航栏的干净 Markdown**，比抓 HTML 省很多 token。例：`https://docs.comfy.org/basic-concepts/nodes.md`。本快照的 references 就是这么抓的。
- **需要官方中文正文时**：官方有 `/zh/`、`/ja/`、`/ko/` 三套完整镜像（各约 1700 页，路径与英文一一对应），在域名后插入 `/zh` 即可，例：`https://docs.comfy.org/zh/basic-concepts/nodes.md`。

## 本快照没覆盖时怎么办

**用 `web_fetch` 去抓官方页面。** 步骤如下：

1. 在 [00-site-index.md](references/00-site-index.md) 里按栏目或关键词找到目标 URL（该文件 3369 行，**用 grep 定位，不要整文件读入**——文件头有栏目行号表）。
2. 抓取时**在 URL 末尾加 `.md`** 取纯正文；要中文就在域名后加 `/zh`。
3. 常见的官方入口：
   - 全站索引（机器可读）：`https://docs.comfy.org/llms.txt`，以及各语言 `https://docs.comfy.org/_llms/zh/tab.md`、`/_llms/zh/api.md`
   - 页面清单（原始）：`https://docs.comfy.org/sitemap.xml`
   - Agent 工具总览：`https://docs.comfy.org/agent-tools`
   - 内置节点参考：`https://docs.comfy.org/built-in-nodes/<节点类名>`
   - 故障排查：`https://docs.comfy.org/troubleshooting/overview`
   - 模板库相关：`https://docs.comfy.org/interface/features/template`
4. 若某页抓取失败，**如实保留 URL 并说明「该页抓取失败」**，不要凭记忆补内容。

## 边界

- 本项目**只做本地免费能力**：本地 ComfyUI、本地模型、本地模板、本地 MCP（`comfy-mcp`）。
- **不涉及**：Comfy Cloud 订阅与计费、Cloud API key、partner 模型（Flux/Grok/Gemini/OpenAI/Ideogram/Seedance 等托管模型）、Comfy Router 的调用方式。这些在索引里只作完整性收录。
- API format 的**程序化提交**请走本地 MCP 的 `run_workflow`；本快照不提供云端 API 的调用教学。
