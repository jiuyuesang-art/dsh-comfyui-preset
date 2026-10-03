# ComfyUI 官方文档 · 全站索引（离线快照）

> **来源**：<https://docs.comfy.org> —— 官方 `sitemap.xml`（6828 条 URL，含多语言镜像）、<https://docs.comfy.org/llms.txt>，以及官方中文索引 `/_llms/zh/tab.md`、`/_llms/zh/api.md`、`/_llms/zh.md`、`/_llms/zh/tab-4ef7ed40/group.md`（含 `group/model.md`、`group/partner.md`）
> **抓取日期**：2026-10-03
> **收录**：1957 条链接
> **条目文字来源**：每条条目的**标题与一句话说明都取自官方中文索引原文**（官方自己写的中文，不是机器翻译、不是本项目编造）。链接统一改写为英文规范路径；个别官方只提供中文路径的条目保留原样。

## 怎么用这个索引

1. **按主题找页面**：先看下面的《栏目总览》定位栏目，再按栏目行号用 `read` 的 `offset`/`limit` 分段读取。整文件 3368 行，**不建议整文件读入**。
2. **按关键词找页面**：直接 `grep` 本文件，例如搜 `MCP`、`workflow_json`、`manager/`、`troubleshooting`。
3. **拿到 URL 后取正文**：用 `web_fetch` 抓该 URL。**取纯正文的诀窍**：在任意文档 URL 末尾加 `.md`（例 `https://docs.comfy.org/basic-concepts/nodes.md`）会直接返回**无导航栏的干净 Markdown**，比抓 HTML 页面省很多 token——本快照的 references 就是这么抓的。
4. **要看官方中文正文**：官方有 `/zh/`、`/ja/`、`/ko/` 三套完整镜像（各约 1700 页，路径与英文一一对应）。在本索引的 URL 域名后插入 `/zh` 即可，例如 `https://docs.comfy.org/zh/basic-concepts/nodes.md`。

## 栏目总览

| # | 栏目 | 条数 | 本文件行号 |
|---|------|------|-----------|
| 一 | 入门 · 核心概念 · 界面 · 教程 | 258 | 37 |
| 二 | 开发 · API · 部署 · 规范 | 281 | 620 |
| 三 | 自定义节点 · Registry · 支持 · 社区 | 98 | 1061 |
| 四 | 内置节点参考（built-in-nodes，按官方分类） | 1069 | 1211 |
| 五 | Comfy Router 合作方模型 Schema（JSON） | 247 | 3010 |
| 六 | OpenAPI 规范文件 | 4 | 3363 |
|  | **合计** | **1957** |  |

## 完整性说明（别把本索引当成"站点全部页面"的等价物）

- 官方 `sitemap.xml` 里英文规范页共 **1755** 条，与本索引的 1957 条不可直接比较：**栏目四**的 1069 条是内置节点页、**栏目五**的 247 条是合作方模型的 JSON schema（不是 HTML 页面）、**栏目六**的 3 个 YAML 也不在 HTML sitemap 里。
- 反向也有少量页面**不在** sitemap 里但被官方索引收录，例如 `development/comfy-router/models/.../code`、`development/samples/overview`；它们仍列在本索引中。
- **栏目四（内置节点）里约有 29 条**，官方中文索引未提供中文说明、只返回英文占位串（`Documentation for <Node> node.`），本索引已统一标注为「内置节点参考页（官方暂无中文说明）」。
- 本索引**逐条来自官方索引文件**，没有对每个 URL 单独发请求做可用性校验；校验方式是与英文 `sitemap.xml` 交叉比对，结论见上两条。
- **栏目五**的 Comfy Router / 合作方模型属于**云端付费**能力。本项目只做本地免费能力，不覆盖其调用方法，此处仅为索引完整性收录。
- 索引不含第三方自定义节点包的文档——它们不在 docs.comfy.org 上，见 `references/04-custom-nodes-and-manager.md`。

---
## 一、入门 · 核心概念 · 界面 · 教程

> 来源索引：<https://docs.comfy.org/_llms/zh/tab.md>（英文对应 <https://docs.comfy.org/_llms/en/get-started.md>）

### 开始使用

- [更新日志](https://docs.comfy.org/changelog) — ComfyUI 变更日志：每个版本的最新功能、改进和错误修复，随新版本发布持续更新。

#### 开始使用

- [ComfyUI 官方文档](https://docs.comfy.org) — ComfyUI 官方文档。开源、基于节点的生成式 AI 应用，学习构建图像、视频、音频和 3D 生成工作流。
- [Comfy Cloud - ComfyUI 官方云平台 · RTX 6000 Pro 强力驱动](https://docs.comfy.org/get_started/cloud) — 使用 Comfy Cloud 在线运行 ComfyUI 工作流，ComfyUI 官方云平台，由 NVIDIA RTX 6000 Pro GPU 强力驱动，无需本地安装。
- [开始 ComfyUI 的 AI 绘图之旅](https://docs.comfy.org/get_started/first_generation) — 使用 ComfyUI 生成你的第一张 AI 图片。学习加载示例工作流、安装模型，并完成你的首次文生图生成。

##### 本地 (自托管)

- [系统要求](https://docs.comfy.org/installation/system_requirements) — 安装和运行 ComfyUI 的硬件和软件要求
- [适用于 Windows 的 ComfyUI 便携版](https://docs.comfy.org/installation/comfyui_portable_windows) — 本篇教程将指导你如何下载并运行 ComfyUI Portable（便携版）：它是一個内嵌 Python 与 CUDA 构建、面向 NVIDIA GPU 的獨立套件。解压压缩包后即可启动 ComfyUI。
- [手动安装 ComfyUI（Windows、macOS、Linux）](https://docs.comfy.org/installation/manual_install) — 在 Windows、macOS 或 Linux 上手动安装 ComfyUI：创建虚拟环境、克隆仓库、安装 GPU 依赖并启动应用。
- [如何更新 ComfyUI](https://docs.comfy.org/installation/update_comfyui) — 更新任意安装类型的 ComfyUI：便携版更新脚本、Desktop 更新、手动安装的 git pull，以及常见更新问题的修复。

###### Comfy Desktop

- [Comfy Desktop 概览](https://docs.comfy.org/installation/desktop/overview) — Comfy Desktop 概览：一个安装、管理和启动多个 ComfyUI 实例的桌面应用，ComfyUI 是生成式 AI 的基于节点的引擎。
- [Comfy Desktop 常见问题](https://docs.comfy.org/installation/desktop/faq) — Comfy Desktop 的常见问题与故障排除

###### 安装

- [适用于 Windows 的 Comfy Desktop](https://docs.comfy.org/installation/desktop/windows) — 在 Windows 上安装 Comfy Desktop：系统要求、安装步骤、更新，以及如何在 Windows 10 及更高版本上彻底卸载并本地运行 ComfyUI。
- [适用于 macOS 的 Comfy Desktop](https://docs.comfy.org/installation/desktop/macos) — 在 macOS 上安装 Comfy Desktop：系统要求、安装步骤、更新，以及如何在 Apple 芯片 Mac 上彻底卸载并本地运行 ComfyUI。
- [Linux 上的 Comfy Desktop](https://docs.comfy.org/installation/desktop/linux) — 在 Linux 上安装 Comfy Desktop：使用官方 .deb 或 AppImage 包，或从源码构建。源码构建需要 Ubuntu 22.04+、x64 和 Node.js v22 LTS。

###### 使用指南

- [Comfy Desktop 使用指南](https://docs.comfy.org/installation/desktop/usage/overview) — Comfy Desktop 使用总览 — 创建新安装、管理实例等
- [实例管理](https://docs.comfy.org/installation/desktop/usage/instance-management) — 在 Comfy Desktop 中创建、编辑、重命名和删除 ComfyUI 实例
- [快照管理](https://docs.comfy.org/installation/desktop/usage/snapshots) — 在 Comfy Desktop 中备份、恢复和分享 ComfyUI 实例快照
- [管理安装](https://docs.comfy.org/installation/desktop/usage/manage) — 启动、更新、快照和管理 ComfyUI 安装
- [设置](https://docs.comfy.org/installation/desktop/usage/settings) — 全局设置、主题、代理/镜像配置和数据位置
- [从 Legacy Desktop 迁移](https://docs.comfy.org/installation/desktop/usage/migrate) — 了解如何将您的 Legacy Desktop 安装迁移到 Comfy Desktop

##### 安装自定义节点

- [如何在 ComfyUI 中安装自定义节点](https://docs.comfy.org/installation/install_custom_node) — 使用 ComfyUI Manager、git clone 或 ZIP 下载在 ComfyUI 中安装自定义节点，并安全安装其 Python 依赖。

###### ComfyUI-Manager

- [ComfyUI Manager 简介](https://docs.comfy.org/manager/overview) — 用于管理 ComfyUI 中自定义节点、模型等的扩展
- [ComfyUI-Manager 安装](https://docs.comfy.org/manager/install) — 在 Desktop、便携版或手动安装的 ComfyUI 上安装 ComfyUI-Manager，在应用内搜索、安装和更新自定义节点。
- [ComfyUI-Manager 配置](https://docs.comfy.org/manager/configuration) — ComfyUI-Manager 配置参考：config.ini 路径与选项、安全级别，以及 V3.38 引入的保护系统路径。
- [ComfyUI Manager 故障排除](https://docs.comfy.org/manager/troubleshooting) — 解决常见的 ComfyUI-Manager 问题，包括自定义 git 可执行文件路径、数据库错误、更新失败等。

###### 自定义节点管理

- [ComfyUI Manager 自定义节点（新版 UI）管理](https://docs.comfy.org/manager/pack-management) — 使用 ComfyUI-Manager 新界面安装、更新和管理自定义节点
- [使用 ComfyUI-Manager 进行自定义节点管理（旧版 UI）](https://docs.comfy.org/manager/legacy-ui) — 使用 ComfyUI-Manager 旧版界面安装、更新和管理自定义节点

#### Agent Tools / MCP

- [Agent 工具](https://docs.comfy.org/agent-tools) — 通过 Comfy MCP、Comfy CLI 和 Comfy Agent 将 ComfyUI 与 AI 代理配合使用。
- [Comfy MCP：将 AI 智能体连接到 ComfyUI](https://docs.comfy.org/agent-tools/mcp) — 通过模型上下文协议（MCP）将 AI 智能体连接到 ComfyUI。可生成图像、视频、音频和 3D，并在 Comfy Cloud 或本机运行真实工作流。
- [Comfy CLI](https://docs.comfy.org/agent-tools/cli) — 从终端驱动 Comfy：本地 ComfyUI、合作伙伴生成调用以及 Comfy Cloud 上的完整工作流。与 MCP 互补，适用于脚本、CI 和自动化。
- [Comfy Agent](https://docs.comfy.org/agent-tools/in-app-agent) — 使用 Comfy Agent 理解、构建、编辑和运行 ComfyUI 工作流。已在 Comfy Cloud 中正式可用；Comfy Desktop 的本地支持即将推出。
- [开始使用 Comfy Agent](https://docs.comfy.org/agent-tools/in-app-agent-installation) — 在 Comfy Cloud 或 Comfy Desktop 中打开 Comfy Agent。
- [Comfy Agent 技能](https://docs.comfy.org/agent-tools/in-app-agent-skills) — 使用个人技能和公共技能，为 Comfy Agent 提供可复用的工作指令。
- [Comfy Agent 数据与隐私](https://docs.comfy.org/agent-tools/in-app-agent-data-privacy) — 了解 Comfy Agent 用于回答请求的信息,以及本地与云端使用的区别。
- [技能](https://docs.comfy.org/agent-tools/skills) — 面向 Comfy 的智能体技能与插件，通过 Comfy Skills 仓库发布。

#### 基础概念

- [ComfyUI 工作流：节点、链接与可视化编程](https://docs.comfy.org/basic-concepts/workflow) — 了解 ComfyUI 中工作流的含义：由相连节点组成的图，可生成图像、视频、音频和 3D 内容。涵盖节点、链接以及如何将工作流保存为 JSON。
- [节点](https://docs.comfy.org/basic-concepts/nodes) — 节点是 ComfyUI 的基本构建块：通过连线连接的独立 Comfy Core 或自定义模块，用来组装复杂工作流。
- [自定义节点](https://docs.comfy.org/basic-concepts/custom-nodes) — ComfyUI 自定义节点：与 Comfy Core 节点的区别，以及安装、更新、启用依赖、禁用和卸载方法。
- [属性](https://docs.comfy.org/basic-concepts/properties) — 通过官方开发文档了解 ComfyUI 节点属性。掌握核心概念，更高效地构建自定义节点。
- [ComfyUI 连线：节点连接工作原理](https://docs.comfy.org/basic-concepts/links) — 了解 ComfyUI 中节点之间的连线如何工作、如何更改连线渲染样式，以及如何使用 Reroute 节点保持复杂工作流的清晰整洁。
- [模型](https://docs.comfy.org/basic-concepts/models) — ComfyUI 中的模型文件：放在哪里、如何在节点里使用，以及常见问题。
- [依赖关系](https://docs.comfy.org/basic-concepts/dependencies) — 了解 ComfyUI 工作流运行所依赖的内容：媒体素材、自定义节点、Python 依赖包和模型。

#### 界面指南

- [界面概览](https://docs.comfy.org/interface/overview) — ComfyUI 界面导览：介绍在可视化节点编辑器中构建、组织、调试工作流所用的各个工作区部分。
- [ComfyUI APP 模式指南](https://docs.comfy.org/interface/app-mode) — 了解如何在 ComfyUI 中构建和使用 APP 模式，通过定义自定义输入/输出界面来简化工作流交互。
- [Nodes 2.0](https://docs.comfy.org/interface/nodes-2) — Nodes 2.0 将 ComfyUI 节点渲染从 LiteGraph Canvas 迁移到基于 Vue 的系统以加快迭代：变更内容与启用方法。
- [遮罩编辑器 - 在 ComfyUI 中创建和编辑遮罩](https://docs.comfy.org/interface/maskeditor) — 讲解 ComfyUI 中遮罩编辑器（Mask Editor）的使用方法，包括工具、图层、设置和快捷键
- [工作流模板 - ComfyUI 内置工作流模板](https://docs.comfy.org/interface/features/template) — 浏览 ComfyUI 工作流模板：原生支持的模型工作流与自定义节点示例工作流，以及打开、加载模板和下载所需模型的方法。
- [子图功能 - ComfyUI 中的工作流组织工具](https://docs.comfy.org/interface/features/subgraph) — 讲解 ComfyUI 中子图（Subgraph）功能的使用方法，包括创建、导航和管理子图
- [部分执行 - 在 ComfyUI 中只运行工作流的一部分](https://docs.comfy.org/interface/features/partial-execution) — ComfyUI 中部分执行（Partial Execution）功能的使用方法和条件
- [节点文档 - 查看任何节点的文档](https://docs.comfy.org/interface/features/node-docs) — 了解如何在 ComfyUI 中访问节点的内置文档,包括内置节点和自定义节点。

##### ComfyUI 设置

- [ComfyUI 设置概览](https://docs.comfy.org/interface/settings/overview) — ComfyUI 设置概览的详细说明
- [ComfyUI 账号管理](https://docs.comfy.org/interface/user) — 在本篇中我们将介绍 ComfyUI 的账号管理功能，包括账号的登录、注册、注销等操作。
- [积分管理](https://docs.comfy.org/interface/credits) — ComfyUI 中 Partner Nodes 的积分：如何购买积分、查看使用历史，以及从 设置 > 积分 中监控余额。
- [Comfy 设置](https://docs.comfy.org/interface/settings/comfy) — ComfyUI 核心设置选项的详细说明
- [ComfyUI 画面(LiteGraph)设置](https://docs.comfy.org/interface/settings/lite-graph) — ComfyUI 图形渲染引擎 LiteGraph 的设置选项详细说明
- [ComfyUI 外观设置](https://docs.comfy.org/interface/appearance) — ComfyUI 外观设置选项的详细说明
- [ComfyUI 3D 设置](https://docs.comfy.org/interface/settings/3d) — ComfyUI 3D 设置选项的详细说明
- [ComfyUI 遮罩编辑器设置](https://docs.comfy.org/interface/settings/mask-editor) — ComfyUI 遮罩编辑器设置选项的详细说明
- [键盘和鼠标快捷键](https://docs.comfy.org/interface/shortcuts) — ComfyUI 键盘和鼠标快捷键：完整的默认列表，以及如何在应用内设置菜单中查看和自定义键位绑定。
- [扩展设置](https://docs.comfy.org/interface/settings/extension) — ComfyUI 扩展管理和设置选项的详细说明
- [关于页面](https://docs.comfy.org/interface/settings/about) — ComfyUI 关于设置页详细说明

##### Cloud 专属功能

- [Comfy Cloud 工作区：团队与成员](https://docs.comfy.org/cloud/workspace) — 创建和管理 Comfy Cloud 工作区：创建团队工作区、邀请成员、设置角色和权限，并共享文件、工作流和积分。
- [分享工作流](https://docs.comfy.org/cloud/share-workflow) — 了解如何通过分享链接将你的 Comfy Cloud 工作流分享给他人
- [导入模型到 Comfy Cloud](https://docs.comfy.org/cloud/import-models) — 了解如何从 Civitai 和 Hugging Face 导入模型到 Comfy Cloud

#### 教程


##### 基础示例

- [ComfyUI 文生图工作流](https://docs.comfy.org/tutorials/basic/text-to-image) — 在 ComfyUI 中构建文生图工作流：加载默认工作流、安装 SD1.5 检查点、编写提示词，并了解每个节点的作用。
- [ComfyUI 图生图工作流](https://docs.comfy.org/tutorials/basic/image-to-image) — 本篇将引导了解并完成图生图工作流
- [ComfyUI 局部重绘工作流](https://docs.comfy.org/tutorials/basic/inpaint) — ComfyUI 局部重绘教程：编辑图像的部分区域、用遮罩编辑器绘制蒙版，并在工作流中连接 VAE Encode (for Inpainting) 节点。
- [扩图工作流示例](https://docs.comfy.org/tutorials/basic/outpaint) — ComfyUI 中的扩图工作流：使用 Pad Image for Outpainting 节点和局部重绘模型技术，将图像扩展到边界之外。
- [ComfyUI 图像放大工作流](https://docs.comfy.org/tutorials/basic/upscale) — 在 ComfyUI 中放大图像：加载放大模型、构建工作流，并将其接在文生图之后以获得更高分辨率的输出。
- [ComfyUI LoRA 使用示例](https://docs.comfy.org/tutorials/basic/lora) — 在 ComfyUI 中使用 LoRA 模型：安装 LoRA、用 Load LoRA 节点加载，并在检查点之上运行应用其风格的工作流。
- [ComfyUI 应用多个 LoRA 示例](https://docs.comfy.org/tutorials/basic/multiple-loras) — 本篇将引导你了解并完成在 ComfyUI 中同时应用多个 LoRA 模型

##### ControlNet

- [ComfyUI ControlNet 使用示例](https://docs.comfy.org/tutorials/controlnet/controlnet) — ComfyUI 中的 ControlNet：用条件图像控制图像生成，代替反复试错的提示词，并附带分步工作流示例。
- [ComfyUI Pose ControlNet 使用示例](https://docs.comfy.org/tutorials/controlnet/pose-controlnet-2-pass) — 在 ComfyUI 中学习 Pose ControlNet。使用 OpenPose 骨骼图控制角色姿态，并通过两次生成的工作流创建大尺寸图像。
- [深度 ControlNet 工作流示例](https://docs.comfy.org/tutorials/controlnet/depth-controlnet) — ComfyUI 中的深度 ControlNet 工作流：深度图如何编码距离信息，以及如何用它控制图像生成时的场景结构。
- [ComfyUI Depth T2I Adapter 使用示例](https://docs.comfy.org/tutorials/controlnet/depth-t2i-adapter) — 本篇将引导了解基础的 Depth T2I Adapter ，并在 ComfyUI 中完成对应的图像生成
- [ComfyUI ControlNet 混合使用示例](https://docs.comfy.org/tutorials/controlnet/mixing-controlnets) — 我们将在本篇示例中，完成多个 ControlNet 混合使用，学会使用多个 ControlNet 模型来控制图像生成

##### 图像

- [Cosmos Predict2 文生图 ComfyUI 官方示例](https://docs.comfy.org/tutorials/image/cosmos/cosmos-predict2-t2i) — 本文介绍了如何在 ComfyUI 中完成 Cosmos-Predict2 文生图的工作流
- [ComfyUI OmniGen2 原生工作流示例](https://docs.comfy.org/tutorials/image/omnigen/omnigen2) — ComfyUI OmniGen2 原生工作流示例 - 统一的文生图、图像编辑和多图像合成模型。

###### Flux

- [ComfyUI Flux.2 Dev 示例](https://docs.comfy.org/tutorials/flux/flux-2-dev) — 本文将简要介绍 Flux.2 模型，并指导你在 ComfyUI 中使用 Flux.2 Dev 模型进行文生图。
- [ComfyUI Flux.2 Klein 4B 指南](https://docs.comfy.org/tutorials/flux/flux-2-klein) — 快速了解 FLUX.2 [klein] 4B，并在 ComfyUI 中运行文生图与图像编辑工作流。
- [Flux.1 Krea Dev ComfyUI 工作流教程](https://docs.comfy.org/tutorials/flux/flux1-krea-dev) — 在 ComfyUI 中使用 Black Forest Labs 与 Krea 联合打造的开源 Flux.1 Krea Dev 模型生成图像，呈现自然细节与独特美学风格。
- [ComfyUI Flux Kontext Dev 原生工作流示例](https://docs.comfy.org/tutorials/flux/flux-1-kontext-dev) — ComfyUI 的 FLUX.1 Kontext Dev 工作流：使用 Black Forest Labs 开源 12B 多模态编辑模型，通过文本和图像输入编辑图片。
- [ComfyUI Flux 文生图工作示例](https://docs.comfy.org/tutorials/flux/flux-1-text-to-image) — 在 ComfyUI 中使用开源的 Flux.1 模型进行文生图，支持完整版和 FP8 Checkpoint 版本，并附逐步工作流配置说明。
- [字节跳动 USO ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/flux/flux-1-uso) — 使用字节跳动 USO 模型实现统一风格和主体驱动生成
- [ComfyUI Flux.1 fill dev 示例](https://docs.comfy.org/tutorials/flux/flux-1-fill-dev) — 本文将使用Flux.1 fill dev 来完成 Inpainting 和 Outpainting 的工作流示例。
- [ComfyUI Flux.1 ControlNet 示例](https://docs.comfy.org/tutorials/flux/flux-1-controlnet) — ComfyUI 的 FLUX.1 Canny 和 Depth 工作流示例：使用 Black Forest Labs 的 FLUX.1 Tools 为 FLUX.1 添加 ControlNet 式结构控制。

###### Qwen

- [Qwen-Image ComfyUI原生工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image) — Qwen-Image 是一个拥有 20B 参数的 MMDiT（多模态扩散变换器）模型，基于 Apache 2.0 许可证开源。
- [Qwen-Image-2512 ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image-2512) — 在 ComfyUI 中使用 Qwen-Image-2512 生成图像。它是 Qwen-Image 的 12 月更新版本，人物真实感、自然细节和文字渲染能力均有提升。
- [Qwen-Image-Edit ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit) — Qwen-Image-Edit 是 Qwen-Image 的图像编辑版本，基于20B模型进一步训练，支持精准文字编辑和语义/外观双重编辑能力。
- [Qwen-Image-Edit-2511 ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511) — 在 ComfyUI 中使用 Qwen-Image-Edit-2511 编辑图像，角色一致性更强，支持多人编辑、LoRA 集成与更强大的几何推理能力。
- [Qwen-Image-Layered ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image-layered) — Qwen-Image-Layered 是一个能够将图像分解为多个 RGBA 图层的模型，通过图层分解实现固有的可编辑性。
- [Qwen-Image-2.1 ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1) — 在 ComfyUI 中运行 Qwen-Image-2.1：一个模型即可完成图像生成与编辑，原生 2K 输出，专业级文字排版，并支持透明度通道。

###### Z-Image

- [Z-Image ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/z-image/z-image) — Z-Image 是阿里通义实验室推出的 6B 高效图像生成基础模型，采用单流 DiT 架构，适合微调和自定义开发。
- [Z-Image-Turbo ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/z-image/z-image-turbo) — Z-Image-Turbo 是一个蒸馏版 6B 参数高效图像生成模型，可实现亚秒级推理延迟。

###### Boogu

- [Boogu-Image-0.1 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/boogu/boogu-image-0.1) — Boogu-Image-0.1 是采用 Apache-2.0 许可证的 10B 参数统一图像生成与编辑模型系列，包含文生图变体和指令驱动编辑变体。

###### HiDream

- [ComfyUI 原生版本 HiDream-I1 文生图工作流示例](https://docs.comfy.org/tutorials/image/hidream/hidream-i1) — 本篇将引导了解并完成 ComfyUI 原生版本 HiDream-I1 文生图工作流实例
- [ComfyUI 原生版本 HiDream-E1, E1.1 工作流示例](https://docs.comfy.org/tutorials/image/hidream/hidream-e1) — 本篇将引导了解并完成 ComfyUI 原生版本 HiDream-I1 文生图工作流实例
- [ComfyUI 原生 HiDream-O1-Image 工作流示例](https://docs.comfy.org/tutorials/image/hidream/hidream-o1) — 本文档将引导你完成 ComfyUI 原生 HiDream-O1-Image 文生图和图像编辑工作流

###### Ovis

- [Ovis-Image ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/ovis/ovis-image) — Ovis-Image 是一个 7B 文生图模型，专注于高质量文本渲染，可在 ComfyUI 中生成海报、横幅、UI 原型上的清晰双语文字。

###### NewBie-image

- [ComfyUI NewBie-image-Exp0.1 工作流示例](https://docs.comfy.org/tutorials/image/newbie-image/newbie-image-exp-0-1) — NewBie-image-Exp0.1 是一个基于 Next-DiT 架构的 35 亿参数动漫风格文生图模型，支持 XML 结构化提示词，在 ComfyUI 中生成高质量动漫图像。

###### ERNIE-Image

- [ERNIE-Image ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/ernie-image/ernie-image) — ERNIE-Image 是百度开源的 8B 扩散变换器文生图模型，可在 ComfyUI 中使用，具备精准文字渲染和内置提示词增强器。

###### Anima

- [Anima Base v1 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/anima/anima) — Anima 是 CircleStone Labs / Comfy Org 推出的 2B 参数文生图模型，针对动漫和非照片级插画生成进行了优化。

###### Lens

- [Lens ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/lens/lens) — 在 ComfyUI 中使用微软开源的 3.8B 文生图模型 Lens：双流 MMDiT 骨干网络、GPT-OSS-20B 文本特征，以及 FLUX.2 语义 VAE。

###### PixelDiT

- [PixelDiT ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/pixeldit/pixeldit) — PixelDiT 是 NVIDIA 的像素空间扩散变换器，用于生成 1024px 文本到图像。它直接在像素空间生成图像，无需 VAE 编解码。

###### Krea 2

- [Krea-2 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/krea/krea-2) — Krea 2 是一款专为高美学质量和风格多样性设计的文生图模型，提供 RAW（基础版）和 Turbo（蒸馏版）两个版本。

###### Ideogram

- [ComfyUI Ideogram 4.0 开源模型教程](https://docs.comfy.org/tutorials/image/ideogram/ideogram-v4) — ComfyUI 中的 Ideogram 4.0：在本地运行 Ideogram 的开源文生图模型，支持准确的文字渲染和 JSON 或自然语言风格提示词。

###### Mage-Flow

- [Mage-Flow：ComfyUI 工作流示例](https://docs.comfy.org/tutorials/image/mage-flow/mage-flow) — Mage-Flow 是微软推出的紧凑型 4B 模型，用于在 ComfyUI 中进行文生图和基于指令的图像编辑，支持最高 2K 的原生分辨率。

##### 3D

- [TripoSplat 图片转高斯泼溅 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/3d/triposplat) — 使用 TripoSplat 从单张 2D 图片生成高质量 3D 高斯泼溅表示，支持可控密度和渲染预算。
- [ComfyUI Hunyuan3D-2 示例](https://docs.comfy.org/tutorials/3d/hunyuan3D-2) — ComfyUI 中的 Hunyuan3D 2.0：使用腾讯开源的 Two-Stage 模型从文本或图像生成带纹理的 3D 模型，先生成几何，再生成纹理。
- [Pixal3D 图像到3D模型 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/3d/pixal3d) — 使用 Pixal3D（腾讯 ARC 推出的像素对齐图像到3D模型），从单张图像生成具有完整 PBR 纹理的高保真 3D 模型。
- [TRELLIS.2 图像到3D模型 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/3d/trellis2) — 使用 TRELLIS.2（微软的开源 4B 参数图像到 3D 模型），从单个图像生成具有完整 PBR 纹理的高保真 3D 模型。

##### LLM

- [Gemma 4 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/llm/gemma4/gemma4) — 在 ComfyUI 中运行 Google 轻量级开源 Gemma 4 LLM，支持文本生成、图像理解、视频分析和音频转录，上下文窗口最高 256K。
- [Qwen 3.0 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/llm/qwen/qwen3) — Qwen 3.0 是阿里巴巴云推出的强大开源大语言模型，具备强推理能力，提供 4B 参数版本，适用于文本生成和结构化推理任务。
- [Qwen3.5 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/llm/qwen/qwen3_5) — 在 ComfyUI 中运行阿里云 4B 多模态大语言模型 Qwen3.5，用于图像描述、反向提示词工程和视觉问答。

##### 视频


###### MiniMax H3

- [ComfyUI MiniMax H3 视频生成指南](https://docs.comfy.org/tutorials/video/minimax/minimax-h3) — 如何在 ComfyUI 中使用开放权重的 MiniMax H3：文生视频、图生视频、参考生视频工作流，支持原生立体声音频，附提示词编写技巧与 Sage Attention 加速方法。
- [ComfyUI MiniMax H3 文生视频、图生视频与参考生视频工作流](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native) — 在 ComfyUI 中运行 MiniMax H3 文生视频（T2V）、图生视频（I2V）和参考生视频（R2V）工作流，并了解帧锚定与潜在噪声蒙版等原生节点高级技巧。
- [ComfyUI MiniMax H3 多帧参考工作流](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-multiframe) — 在 ComfyUI 中用 Add Guide 节点把参考帧固定到时间线的指定位置，生成 MiniMax H3 视频续写与多镜头场景。
- [ComfyUI MiniMax H3 Fun ControlNet Union：Pose、Depth 与 Canny 控制视频](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fun-controlnet) — 使用 Canny、Depth、HED、MLSD 或 Pose 控制视频引导 ComfyUI 中 MiniMax H3 视频的运动，并用 Fun ControlNet Union 补丁进行基于蒙版的视频修补。
- [ComfyUI MiniMax H3 提示词指南：官方指南、技巧与提示词嵌入](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide) — 在 ComfyUI 中写出更好的 MiniMax H3 提示词：MiniMax 官方提示词编写指南、通用提示词技巧、对白与说话人规则，以及风格嵌入。
- [FastVideo FastH3：ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fastvideo) — FastVideo FastH3 在 ComfyUI 中以 8 个采样步数生成带同步音频的 MiniMax H3 视频，支持文生视频与首尾帧工作流。

###### LTX

- [LTX-0.9.5 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/ltxv) — 学习如何在 ComfyUI 中使用 LTX-Video 0.9.5 高效生成视频
- [LTX-2.0 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/ltx/ltx-2) — 学习如何在 ComfyUI 中使用 LTX-2 实现同步音视频生成
- [LTX-2.3：ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/ltx/ltx-2-3) — 在 ComfyUI 中使用 LTX-2.3 原生工作流，涵盖文本转视频、图像转视频、FLF2V、音频驱动视频、IC-LoRA 控制和 ID-LoRA 个性化。
- [LTX-2.5：ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/ltx/ltx-2-5) — 在 ComfyUI 中使用 LTX-2.5，通过原生工作流实现文生视频、图生视频和首尾帧生视频，支持同步音频和原生多镜头场景。

###### Wan 视频

- [Wan Animate 2：动作迁移](https://docs.comfy.org/tutorials/video/wan/wan-animate-2) — 在 ComfyUI 中使用 Wan Animate 2 让静态角色动起来：直接从驱动视频迁移动作，无需姿态提取或骨骼预处理。
- [Wan2.2 视频生成ComfyUI 官方原生工作流示例](https://docs.comfy.org/tutorials/video/wan/wan2_2) — 在 ComfyUI 中运行 Wan2.2 视频工作流：5B 混合 TI2V 模型，以及 14B 文生视频、图生视频和首尾帧示例，附下载链接。
- [Wan2.2 Animate ComfyUI 原生工作流](https://docs.comfy.org/tutorials/video/wan/wan2-2-animate) — 统一的人物动画和替换框架，具有精确的运动和表情复制。
- [Wan Dancer：从音乐生成舞蹈视频](https://docs.comfy.org/tutorials/video/wan/wan-dancer) — 在 ComfyUI 中使用 Wan Dancer 从音乐生成同步舞蹈视频。输入参考图像和音频，即可生成连贯且富有表现力的舞蹈动作。
- [Wan2.2-S2V 音频驱动视频生成 ComfyUI 原生工作流示例](https://docs.comfy.org/tutorials/video/wan/wan2-2-s2v) — 这是一个原生工作流示例，用于在 ComfyUI 中使用 Wan2.2-S2V 进行音频驱动视频生成。
- [ComfyUI Wan2.2 Fun Inp 首尾帧视频生成示例](https://docs.comfy.org/tutorials/video/wan/wan2-2-fun-inp) — 本文介绍了如何在 ComfyUI 中完成 Wan2.2 Fun Inp 首尾帧视频生成示例
- [ComfyUI Wan2.2 Fun Control 视频控制生成示例](https://docs.comfy.org/tutorials/video/wan/wan2-2-fun-control) — 本文介绍了如何在 ComfyUI 中完成 Wan2.2 Fun Control 使用控制视频来完成视频生成的示例
- [ComfyUI Wan2.2 Fun Camera Control：视频生成工作流示例](https://docs.comfy.org/tutorials/video/wan/wan2-2-fun-camera) — 本文演示了如何在 ComfyUI 中使用 Wan2.2 Fun Camera Control 的相机控制进行视频生成。

###### Wan2.1

- [ComfyUI Wan2.1 Video 示例](https://docs.comfy.org/tutorials/video/wan/wan-video) — 在 ComfyUI 中运行 Wan2.1 视频工作流：使用 1.3B 模型进行文生视频、使用 14B 模型进行图生视频，包括模型安装。
- [Causal Forcing 图生视频 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/video/wan/wan-causal-forcing) — 使用 Wan2.1 的 Causal Forcing 或 Causal Forcing++ 从图片生成视频——只需 1 步推理即可获得流畅、时序一致的视频。
- [ComfyUI Wan2.1 VACE 视频示例](https://docs.comfy.org/tutorials/video/wan/vace) — 本文介绍了如何在 ComfyUI 中完成 Wan2.1 VACE 视频生成示例
- [ComfyUI Wan-Move 工作流示例](https://docs.comfy.org/tutorials/video/wan/wan-move) — 在 ComfyUI 中使用 Wan-Move 生成运动可控视频：在图像上指定点轨迹即可引导物体运动，实现精确的图生视频。
- [Wan-Alpha 教程](https://docs.comfy.org/tutorials/video/wan/wan-alpha) — 学习如何在 ComfyUI 中使用 Wan-Alpha 生成带有 Alpha 通道透明度的视频
- [Wan ATI 原生工作流](https://docs.comfy.org/tutorials/video/wan/wan-ati) — ComfyUI 中的 Wan ATI 轨迹控制：绘制轨迹来控制生成视频中的对象、区域和相机运动，基于 Wan2.1 构建。
- [ComfyUI Wan2.1 Fun Control 视频示例](https://docs.comfy.org/tutorials/video/wan/fun-control) — 本文介绍了如何在 ComfyUI 中完成 Wan2.1 Fun Control 使用控制视频来完成视频生成的示例
- [ComfyUI Wan2.1 Fun Camera 官方原生示例](https://docs.comfy.org/tutorials/video/wan/fun-camera) — 本文介绍了如何在 ComfyUI 中使用 Wan2.1 Fun Camera 完成视频生成
- [ComfyUI Wan2.1 Fun InP 视频示例](https://docs.comfy.org/tutorials/video/wan/fun-inp) — 本文介绍了如何在 ComfyUI 中完成 Wan2.1 Fun InP 视频首尾帧视频生成示例
- [ComfyUI Wan2.1 FLF2V 原生示例](https://docs.comfy.org/tutorials/video/wan/wan-flf) — 本文介绍了如何在 ComfyUI 中完成 Wan2.1 FLF2V 视频生成示例

###### ByteDance

- [ComfyUI Bernini-R 官方示例](https://docs.comfy.org/tutorials/video/bytedance/bernini-r) — 了解如何在 ComfyUI 中使用 Bernini-R 进行图像和视频编辑——重光照、风格转换、主体插入等。

###### Hunyuan

- [ComfyUI 混元视频示例](https://docs.comfy.org/tutorials/video/hunyuan/hunyuan-video) — 本文介绍了如何在 ComfyUI 中完成混元文生视频及图生视频的工作流
- [混元视频 1.5 ComfyUI 教程](https://docs.comfy.org/tutorials/video/hunyuan/hunyuan-video-1-5) — 了解如何使用混元视频 1.5，一个轻量级的 8.3B 参数模型，可在消费级 GPU 上生成高质量视频

###### Cosmos

- [Cosmos Predict2 视频到世界 ComfyUI 官方示例](https://docs.comfy.org/tutorials/video/cosmos/cosmos-predict2-video2world) — 本指南演示了如何在 ComfyUI 中完成 Cosmos-Predict2 视频到世界工作流

###### Kandinsky

- [Kandinsky 5.0](https://docs.comfy.org/tutorials/video/kandinsky/kandinsky-5) — 本指南介绍如何在 ComfyUI 中使用 Kandinsky 5.0 视频生成工作流

###### ZAI

- [ComfyUI SCAIL-2 角色替换工作流教程](https://docs.comfy.org/tutorials/video/zai/scail2) — 使用 SCAIL-2 模型，让参考角色图像跟随驱动视频运动，实现角色动画或视频内角色替换。

##### 音频


###### YuE2

- [ComfyUI YuE2 音乐生成指南](https://docs.comfy.org/tutorials/audio/yue2/yue2) — 使用开源 YuE2 模型在 ComfyUI 中生成带人声的完整歌曲：通过 ABC 规划实现文本转音乐，以及使用 SheetSage2 生成保留旋律的翻唱。

###### MiniMax Music 3

- [ComfyUI 中的 MiniMax Music 3：AI 音乐生成](https://docs.comfy.org/tutorials/audio/minimax/minimax-music-3) — 了解如何在 ComfyUI 中使用 MiniMax Music 3，根据结构化的音乐描述和歌词生成最长 5 分钟的完整歌曲。

###### Stable Audio

- [Stable Audio 1.0 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/audio/stable-audio/stable-audio-1) — 在 ComfyUI 中使用 Stability AI 的开源 Stable Audio 1.0 模型进行文生音频生成的指南。
- [Stable Audio 3 ComfyUI 工作流示例](https://docs.comfy.org/tutorials/audio/stable-audio/stable-audio-3) — 在 ComfyUI 中运行 Stability AI 开源模型 Stable Audio 3 进行文本转音频生成，支持 Qwen 提示词扩展与分类感知重新提示。

###### ACE-Step

- [ComfyUI ACE-Step 原生示例](https://docs.comfy.org/tutorials/audio/ace-step/ace-step-v1) — ComfyUI 中的 ACE-Step 音乐生成：使用 StepFun 和 ACE Studio 的 Apache-2.0 开源模型进行文生音乐和音乐编辑工作流。
- [ComfyUI ACE-Step 1.5 AI 音乐生成指南](https://docs.comfy.org/tutorials/audio/ace-step/ace-step-v1-5) — 学习如何在 ComfyUI 中使用 ACE-Step 1.5 进行 AI 音乐生成。包含 ComfyUI 工作流、模型下载和设置说明的完整指南。

##### 实用工具

- [ComfyUI 预处理器工作流](https://docs.comfy.org/tutorials/utility/preprocessors) — 学习如何在 ComfyUI 中使用深度估计、线稿转换、姿态检测和法线提取预处理器

###### 放大与修复

- [ComfyUI 图像放大](https://docs.comfy.org/tutorials/utility/image-upscale) — 学习如何在 ComfyUI 中使用本地模型和合作伙伴节点进行图像放大
- [ComfyUI 视频放大](https://docs.comfy.org/tutorials/utility/video-upscale) — 学习如何在 ComfyUI 中使用本地模型和合作伙伴节点进行视频放大
- [SeedVR2: ComfyUI 中的图像和视频放大](https://docs.comfy.org/tutorials/utility/seedvr2) — 学习如何使用 SeedVR2（字节跳动 Seed 开发的一步扩散修复模型）对图像和视频进行放大

###### 分割与抠图

- [SAM 3.1：ComfyUI 通用分割工作流](https://docs.comfy.org/tutorials/utility/video-segment-sam3) — 学习使用 Meta 的 SAM 3.1 模型在 ComfyUI 中通过文本提示对图像和视频进行分割
- [BiRefNet：ComfyUI 图像背景移除工作流](https://docs.comfy.org/tutorials/utility/remove-background-birefnet) — 学习使用 BiRefNet 模型在 ComfyUI 中移除图像背景

###### 姿态与检测

- [SDPose：ComfyUI 中的姿态检测](https://docs.comfy.org/tutorials/utility/pose-detection-sdpose) — 学习如何使用 ComfyUI 原生支持的 SDPose 从图像和视频中提取姿态关键点和姿态图
- [SAM 3D Body：在 ComfyUI 中从视频提取 3D 人体网格](https://docs.comfy.org/tutorials/utility/sam3d-body) — 使用 SAM 3D Body 从视频中提取全身 3D 人体网格，包含姿态与形状估计、面部表情以及渲染的网格叠加视频。

###### 人脸检测

- [MediaPipe：ComfyUI 人脸检测](https://docs.comfy.org/tutorials/utility/face-detection/mediapipe) — 了解如何在 ComfyUI 中使用 MediaPipe Face Detection 检测人脸，提取面部关键点、边界框和区域遮罩

###### 深度与 3D

- [ComfyUI Depth Anything 3 官方示例](https://docs.comfy.org/tutorials/utility/depth-anything-3) — 在 ComfyUI 中使用 Depth Anything 3 进行单目和多视角深度估计、相机位姿恢复，以及基于图像和视频的 3D 重建。
- [ComfyUI Marigold V2 深度、法线与反照率估计指南](https://docs.comfy.org/tutorials/utility/marigold-v2) — 使用 Marigold V2 在 ComfyUI 中从单张图像估计深度、表面法线与反照率：基于 Qwen-Image Edit 的扩散 transformer，并配备专用 LoRA。
- [ComfyUI MoGe 使用示例](https://docs.comfy.org/tutorials/utility/moge) — 本指南演示如何在 ComfyUI 中使用 MoGe 进行单目几何估计：公尺度点云、深度图、法线图和网格生成。

###### 视频处理

- [ComfyUI 帧插值工作流](https://docs.comfy.org/tutorials/utility/frame-interpolation) — 学习如何在 ComfyUI 视频工作流中使用帧插值来平滑运动和提高帧率
- [VOID：ComfyUI 视频物体移除工作流](https://docs.comfy.org/tutorials/utility/void-video-inpainting) — 学习使用 Netflix 的 VOID 视频修复模型在 ComfyUI 中移除视频中的物体

#### Comfy Cloud 节点

- [Comfy Cloud 节点](https://docs.comfy.org/cloud-nodes/overview) — 从本地 ComfyUI 安装运行 Comfy Cloud GPU 上的精选工作流，无需订阅

#### 合作伙伴节点

- [Partner Nodes](https://docs.comfy.org/tutorials/partner-nodes/overview) — Partner Nodes 通过 ComfyUI 内的 API 请求调用 OpenAI、Kling、Luma 等闭源模型：它们是什么、积分机制以及使用方法。
- [Partner Node 定价](https://docs.comfy.org/tutorials/partner-nodes/pricing) — 各提供商（包括 Anthropic、OpenAI、Kling 和 Luma）的 Partner Node 积分定价，按模型、Token 类型和生成类型细分。
- [并发限制](https://docs.comfy.org/tutorials/partner-nodes/concurrency-limits) — 了解并发限制如何控制您账户上同时进行的 Partner Node 请求数量。
- [合作节点常见问题](https://docs.comfy.org/tutorials/partner-nodes/faq) — 在使用合作节点时你可能遇到的常见问题。
- [合作伙伴节点数据保留](https://docs.comfy.org/tutorials/partner-nodes/data-retention) — Comfy 如何存储和删除合作伙伴节点的输入和输出，以及媒体文件的保留时长。
- [模型提供商](https://docs.comfy.org/tutorials/partner-nodes/model-providers) — Comfy 合作节点背后模型提供商的验证状态、商业许可与数据驻留。

##### 合作伙伴模型


###### 图像

- [图像模型](https://docs.comfy.org/tutorials/partner-nodes/image/overview) — 根据你的使用场景选择合适的图像模型：文生图、编辑、图像放大、背景移除等

###### Black Forest Labs

- [Flux 1.1 Pro Ultra Image 合作伙伴节点 ComfyUI 官方示例工作流](https://docs.comfy.org/tutorials/partner-nodes/black-forest-labs/flux-1-1-pro-ultra-image) — 本文将介绍在 ComfyUI 中使用 Flux 1.1 Pro Ultra Image 合作伙伴节点的相关功能
- [ComfyUI Flux.1 Kontext Pro Image 合作伙伴节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/black-forest-labs/flux-1-kontext) — 本文将介绍如何在 ComfyUI 中使用 Flux.1 Kontext Pro Image 合作伙伴节点来完成图像编辑功能

###### Beeble

- [Beeble SwitchX Partner Nodes ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/beeble/beeble-switchx) — 本指南介绍如何在 ComfyUI 中使用 Beeble SwitchX Partner Nodes 进行 AI 图像和视频重打光与环境替换

###### Bria

- [ComfyUI 中的 Bria 背景移除](https://docs.comfy.org/tutorials/partner-nodes/bria/background-removal) — 学习如何在 ComfyUI 中使用 Bria 合作节点进行图像和视频背景移除、绿幕和背景替换。
- [Bria FIBO Edit 合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/bria/fibo) — 了解如何在 ComfyUI 中使用 Bria FIBO Edit 合作节点进行精准图像编辑
- [ComfyUI 中的 Bria Eraser、Expand Image 和 GenFill](https://docs.comfy.org/tutorials/partner-nodes/bria/image-editing) — 使用 ComfyUI 中的 Bria Eraser、Expand Image 和 Generative Fill 合作节点移除对象、扩展图像，并在遮罩区域内生成内容。

###### ByteDance

- [字节跳动 Seedream 5.0 Pro - 专业级 AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedream-5-pro) — 在 ComfyUI 中使用 Seedream 5.0 Pro，生成高质量图像，具备更强的指令遵循能力、精确编辑和专业级输出
- [字节跳动 Seedream 5.0 Lite - 智能 AI 图像创作](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedream-5-lite) — 在 ComfyUI 中使用 Seedream 5.0 lite 进行联网检索和增强指令跟随的图像生成

###### Google

- [Nano Banana Pro：工作室级 AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/google/nano-banana-pro) — 使用 ComfyUI 中的 Nano Banana Pro（Gemini 3 Pro Image）生成和编辑适合生产环境的 4K 图像，具备高级文本渲染和角色一致性。
- [Nano Banana 2 - 快速 AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/google/nano-banana-2) — 在 ComfyUI 中使用 Nano Banana 2 以 Flash 速度生成 Pro 级别质量的图像
- [Nano Banana 2 Lite：快速 AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/google/nano-banana-2-lite) — 使用 Nano Banana 2 Lite（ComfyUI 中的 Gemini 3.1 Flash-Lite Image 模型）以谷歌最快速度和最低成本生成图像

###### Grok

- [ComfyUI 中的 Grok：AI 图像与视频生成](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-overview) — 在 ComfyUI 中使用 xAI 的 Grok 模型：Grok Imagine Image 用于文生图和图像编辑，Grok Imagine Video 用于视频生成、编辑和扩展
- [ComfyUI 中的 Grok Imagine Image：AI 图像生成与编辑](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-image) — 使用 ComfyUI 中的 Grok Imagine Image 模型生成和编辑图像：文生图和自然语言图像编辑
- [在 ComfyUI 中使用 Grok Imagine Image 2.0：AI 图像生成与编辑](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-image-2-0) — 使用 ComfyUI 中的 Grok Imagine Image 2.0 生成和编辑图像：Aurora 引擎、清晰短文本渲染、1K/2K 输出，以及最多 3 张参考图像
- [在 ComfyUI 中使用 Grok Imagine Image Quality：AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-image-quality) — 使用 ComfyUI 中的 Grok Imagine Image Quality 生成增强图像：更精细的细节、更好的文本渲染和更强的创意控制

###### Ideogram

- [ComfyUI Ideogram 4.0 节点教程](https://docs.comfy.org/tutorials/partner-nodes/ideogram/ideogram-v4) — 了解如何在 ComfyUI 中使用 Ideogram 4.0 API Partner Node
- [ComfyUI 中的 Ideogram 4.5：文生图与图像编辑](https://docs.comfy.org/tutorials/partner-nodes/ideogram/ideogram-4-5) — 在 ComfyUI 中运行 Ideogram 4.5 合作伙伴节点，完成文生图、图像编辑与精确编辑，精确编辑可保持未改动的像素完全一致
- [Ideogram P-Image - 快速文生图](https://docs.comfy.org/tutorials/partner-nodes/ideogram/ideogram-p-image) — 在 ComfyUI 中使用 Ideogram 的快速 P-Image 模型，从文本描述生成图像，以更低的成本和延迟提供与领先模型相当的质量

###### Krea

- [ComfyUI Krea 2 Partner Nodes 官方示例](https://docs.comfy.org/tutorials/partner-nodes/krea2/krea2-t2i) — 本指南介绍如何在 ComfyUI 中使用 Krea 2 文生图 Partner Node

###### Luma

- [Luma Uni-1 使用指南](https://docs.comfy.org/tutorials/partner-nodes/luma/luma-uni-1) — 在 ComfyUI 中使用 Luma Uni-1 合作伙伴节点进行图像创建与编辑。
- [Luma 文生图合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/luma/luma-text-to-image) — 本文介绍如何在 ComfyUI 中使用 Luma 文生图合作节点
- [Luma Image to Image 合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/luma/luma-image-to-image) — 本指南介绍如何在 ComfyUI 中使用 Luma Image to Image 合作节点

###### Meta

- [在 ComfyUI 中使用 Meta Muse Image：文生图与图像编辑](https://docs.comfy.org/tutorials/partner-nodes/meta/muse-image) — 使用 ComfyUI 中的 Meta Muse Image 1.0 合作节点生成和编辑图像。内置网络搜索、图像搜索和代码执行功能，支持智能体式图像生成，并可基于指令对最多 10 张参考图像进行编辑。

###### OpenAI

- [ComfyUI OpenAI GPT Image 2.5 节点：Flare 与 Sunburst 工作流](https://docs.comfy.org/tutorials/partner-nodes/openai/gpt-image-2-5) — 在 ComfyUI 中使用 OpenAI GPT Image 2.5 Flare 与 Sunburst 合作伙伴节点生成和编辑图像：快速预览、高保真图像编辑与工作流模板。
- [OpenAI GPT-Image-2 节点](https://docs.comfy.org/tutorials/partner-nodes/openai/gpt-image-2) — 了解如何在 ComfyUI 中使用 OpenAI GPT-Image-2 合作伙伴节点生成图像
- [OpenAI GPT-Image-1 节点](https://docs.comfy.org/tutorials/partner-nodes/openai/gpt-image-1) — 了解如何在 ComfyUI 中使用 OpenAI GPT-Image-1 合作伙伴节点生成图像

###### Qwen

- [Qwen Image 3.0 Pro - 高级 AI 图像生成](https://docs.comfy.org/tutorials/partner-nodes/qwen/qwen-image-3-0-pro) — 在 ComfyUI 中使用 Qwen Image 3.0 Pro 生成生产就绪图像，并凭借精确的指令遵循能力编辑最多 3 张参考图像

###### Recraft

- [Recraft V4 图像与矢量生成教程](https://docs.comfy.org/tutorials/partner-nodes/recraft/recraft-v4) — 在 ComfyUI 中使用 Recraft V4 生成专业图像和可用于生产的矢量图
- [Recraft Text to Image 合作伙伴节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/recraft/recraft-text-to-image) — 了解如何在 ComfyUI 中使用 Recraft Text to Image 合作伙伴节点

###### Reve

- [Reve 图像创建、编辑和混合 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/reve/reve-image) — 了解如何在 ComfyUI 中使用 Reve 合作伙伴节点进行高质量图像生成、编辑和混合，支持最高 4K 分辨率

###### Runway

- [Runway 合作伙伴节点 图像生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/runway/image-generation) — 本文将介绍如何在 ComfyUI 中使用 Runway 节点进行文生图和参考生图功能

###### Tencent

- [ComfyUI 中的腾讯混元图像 3.5 Preview：文生图与图像编辑工作流](https://docs.comfy.org/tutorials/partner-nodes/tencent/hy-image-3-5) — 在 ComfyUI 中使用腾讯混元图像 3.5 Preview 生成与编辑图像：多语言文字渲染、最多 5 张参考图，以及由 2K 放大得到的 4K 输出。

###### Topaz

- [Topaz Image Enhance Wonder 3.5 - AI 图像增强](https://docs.comfy.org/tutorials/partner-nodes/topaz/image-enhance-wonder-3-5) — 在 ComfyUI 中使用 Topaz Image Enhance Wonder 3.5 放大和增强图像：生成式细节恢复、噪波降低和文本锐化
- [Topaz 图像增强 Bloom 2 - AI 创意图像放大](https://docs.comfy.org/tutorials/partner-nodes/topaz/image-enhance-bloom-2) — 在 ComfyUI 中使用 Topaz 图像增强 Bloom 2 放大并增强图像：创意图像放大可添加新的细节、纹理和视觉元素

###### 视频

- [视频模型](https://docs.comfy.org/tutorials/partner-nodes/video/overview) — 根据你的使用场景选择合适的视频模型：文生视频、图生视频、视频增强等

###### Black Forest Labs

- [Flux 3 Video：支持原生音频的 AI 视频生成](https://docs.comfy.org/tutorials/partner-nodes/black-forest-labs/flux-3-video) — 使用 ComfyUI 中的 Flux 3，从文本或图像生成带有同步音频的视频，单次生成时长最长可达 20 秒
- [FLUX Video Edit：在 ComfyUI 中通过文本提示编辑视频](https://docs.comfy.org/tutorials/partner-nodes/black-forest-labs/flux-video-edit) — 使用 ComfyUI 中的 FLUX Video Edit 合作伙伴节点编辑现有视频片段：替换物体、重绘画面风格，或通过文本提示更改画面上的文字与对白。
- [FLUX Video Upscale：AI 视频放大，将 AI 生成视频高清化至 4K](https://docs.comfy.org/tutorials/partner-nodes/black-forest-labs/flux-video-upscale) — 使用 ComfyUI 中的 FLUX Video Upscale 合作伙伴节点，可将视频放大至 1080p、2K 或 4K。精确模式保留原始画面，创意模式添加新的细节。

###### ByteDance

- [Seedance 2.5：带音频的 AI 视频生成](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedance-2-5) — 使用 ComfyUI 中的 Seedance 2.5 生成 30 秒视频，支持同步音频、多模态参考控制与精确编辑
- [Seedance 2.5 草稿模式：先以 480p 预览，再渲染 1080p](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedance-2-5-draft) — 在 ComfyUI 中使用 Seedance 2.5 草稿模式低成本迭代：通过 draft_task_id 渲染 480p 预览，再根据该 ID 渲染 1080p 最终成品。
- [Seedance 2.0 - AI 视频生成](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedance-2-0) — 在 ComfyUI 中使用 Seedance 2.0 从文本、图片、视频和音频生成视频，支持音画同步、角色一致性和电影级运镜控制。
- [Seedance 2.0 真人支持 - 真人一致性视频生成](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seedance-2-0-real-human) — 在 ComfyUI 中完成一次真人活体验证后，用 Seedance 2.0 生成人物一致、音画同步的真人视频。
- [在 ComfyUI 中使用字节跳动 vCube 视频增强](https://docs.comfy.org/tutorials/partner-nodes/bytedance/vcube) — 使用 ComfyUI 中的字节跳动 vCube 放大和修复视频：高达 8K 的超分辨率、伪影去除、颜色增强以及帧插值。

###### Google

- [Gemini Omni Flash：对话式视频生成](https://docs.comfy.org/tutorials/partner-nodes/google/gemini-omni-flash) — 通过合作节点在 ComfyUI 中使用 Google 的多模态视频模型 Gemini Omni Flash 1.1，以自然语言生成和编辑视频

###### Grok

- [在 ComfyUI 中使用 Grok Imagine Video：AI 视频生成、编辑与扩展](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-video) — 在 ComfyUI 中使用 Grok Imagine 生成、编辑和扩展视频：文本/图像到视频、视频编辑、视频扩展和参考生视频工作流
- [Grok Imagine Video 1.5 图生视频 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/grok/grok-imagine-video-1-5) — 本指南介绍如何在 ComfyUI 中使用 Grok Imagine Video 1.5 Partner Node，从图像生成带原生音频的高质量视频

###### HappyHorse

- [在 ComfyUI 中使用 HappyHorse 1.1 生成视频](https://docs.comfy.org/tutorials/partner-nodes/happyhorse/happyhorse1-1) — 通过 ComfyUI 合作节点使用 HappyHorse 1.1 进行图生视频、文生视频和参考生视频，支持原生同步音频和多镜头场景。
- [ComfyUI 中的 HappyHorse 1.0 视频生成](https://docs.comfy.org/tutorials/partner-nodes/happyhorse/happyhorse1-0) — 了解如何在 ComfyUI 中通过合作伙伴节点使用 HappyHorse 1.0 进行图生视频、文生视频、参考生成视频和视频编辑，享受电影级美学与多镜头一致性

###### HeyGen

- [HeyGen Video 1.0：在 ComfyUI 中通过文本、图像与参考生成视频](https://docs.comfy.org/tutorials/partner-nodes/heygen/heygen-video-1) — 在 ComfyUI 中通过提示词、首帧图像，或最多 12 个参考图像、视频和音频片段，生成 5 到 15 秒带同步对白的视频

###### Kling

- [Kling 3.0 视频和图像生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/kling/kling-3-0) — 本文将介绍如何在 ComfyUI 中使用 Kling 3.0 模型，实现多镜头视频生成、主体一致性、多语言音频和原生文字渲染
- [Kling 2.6 Motion Control 合作伙伴节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/kling/kling-motion-control) — 本文将介绍如何在 ComfyUI 中使用 Kling 2.6 Motion Control 合作伙伴节点，实现从参考视频到角色图像的精准动作迁移

###### Lightricks

- [在 ComfyUI 中使用 LTX-2.5 API 生成视频](https://docs.comfy.org/tutorials/partner-nodes/lightricks/ltx-2-5) — 在 ComfyUI 中使用 LTX-2.5 API 节点，通过云端工作流进行文生视频、图生视频和首尾帧生视频，提供 Fast 与 Pro 两种模型档位。

###### Luma

- [Luma 文本转视频合作节点 ComfyUI 官方指南](https://docs.comfy.org/tutorials/partner-nodes/luma/luma-text-to-video) — 学习如何在 ComfyUI 中使用 Luma 文本转视频合作节点
- [Luma 图像转视频合作伙伴节点](https://docs.comfy.org/tutorials/partner-nodes/luma/luma-image-to-video) — Luma 图像转视频合作伙伴节点工作流：在 ComfyUI 中将静态图像转换为视频，包括所需积分和节点参数。

###### MiniMax

- [在 ComfyUI 中使用 MiniMax H3 API 进行视频生成](https://docs.comfy.org/tutorials/partner-nodes/minimax/minimax-h3) — 在 ComfyUI 中使用 MiniMax H3 API 节点，通过云端工作流进行文生视频、首尾帧视频和参考生视频，支持原生立体声音频。

###### Moonvalley

- [Moonvalley 合作伙伴节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/moonvalley/moonvalley-video-generation) — 本文将介绍如何在 ComfyUI 中使用 Moonvalley 合作伙伴节点的文生视频、图生视频、视频转绘等能力

###### Pruna

- [Pruna P-Video-2：在 ComfyUI 中进行文本和图像生成视频](https://docs.comfy.org/tutorials/partner-nodes/pruna/p-video-2) — 使用 ComfyUI 中的 Pruna P-Video-2 合作节点生成视频：支持 720p 和 1080p 输出、1 至 20 秒的片段、原生音频、草稿模式以及音频驱动的运动。

###### Runway

- [Runway 合作节点视频生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/runway/video-generation) — 本文将介绍如何在 ComfyUI 中使用 Runway 节点进行视频生成的工作流

###### Topaz

- [Topaz Starlight Precise 2.5 - AI 视频放大](https://docs.comfy.org/tutorials/partner-nodes/topaz/video-enhance-starlight-precise-2-5) — 在 ComfyUI 中使用 Topaz Starlight Precise 2.5 放大视频：4K 输出更清晰，真人实拍素材的伪影更少
- [Topaz Astra 视频创意放大 - AI 视频放大](https://docs.comfy.org/tutorials/partner-nodes/topaz/video-enhance-astra) — 在 ComfyUI 中使用 Topaz Astra 放大和增强视频：Starlight (Astra) Fast 放大，可选 apo-8 帧插值
- [Astra 2 - 创意扩散视频放大](https://docs.comfy.org/tutorials/partner-nodes/topaz/astra-2) — Astra 2 在 ComfyUI 中的功能，以及对细节和风格的可控创意放大。

###### Wan

- [在 ComfyUI 中使用 Wan 3.0 生成视频](https://docs.comfy.org/tutorials/partner-nodes/wan/wan3-0) — 了解如何通过 ComfyUI 中的合作节点使用 Wan 3.0，进行文生视频、图生视频和参考生视频生成，并支持同步音频
- [ComfyUI 中的 Wan2.7 视频生成](https://docs.comfy.org/tutorials/partner-nodes/wan/wan2-7) — 了解如何在 ComfyUI 中通过合作伙伴节点使用 Wan2.7 进行图生视频、文生视频、参考生成视频、视频续写和视频编辑

###### 3D

- [3D 模型](https://docs.comfy.org/tutorials/partner-nodes/3d/overview) — 通过 ComfyUI 合作节点使用最先进的 3D 模型，从文字提示词或图像生成带纹理的 3D 资产

###### Hunyuan 3D

- [Hunyuan 3D API 节点模型生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/hunyuan3d/hunyuan3d-3-0) — 本文将介绍如何在 ComfyUI 中使用 Hunyuan 3D 节点的 API 进行 3D 模型生成

###### Meshy

- [ComfyUI 中的 Meshy 7：文本转 3D 与图像转 3D 工作流](https://docs.comfy.org/tutorials/partner-nodes/meshy/meshy-7) — 使用 ComfyUI 中的 Meshy 7 生成生产就绪的 3D 模型：支持 Ultra 模式、PBR 纹理、骨骼绑定和动画的文本转 3D 与图像转 3D 工作流
- [Meshy 6 API 节点 3D 模型生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/meshy/meshy-6) — 本文将介绍如何在 ComfyUI 中使用 Meshy 6 节点的 API 进行 3D 模型生成

###### Rodin

- [Rodin 合作伙伴节点模型生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/rodin/model-generation) — 本文将介绍如何在 ComfyUI 中使用 Rodin 节点的 API 来进行模型生成

###### Tripo

- [Tripo P2：在 ComfyUI 中生成四边形拓扑 3D 模型](https://docs.comfy.org/tutorials/partner-nodes/tripo/tripo-p2) — 使用 ComfyUI 中的 Tripo P2 合作节点生成可直接投入生产的 3D 模型：原生四边形拓扑，面数预算最高可达 50,000，纹理级别从 2K 到 8K。
- [Tripo P1 3D 模型生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/tripo/tripo-p1) — 本指南介绍如何在 ComfyUI 中使用 Tripo P1 Partner Nodes，从文本、图片或多视图参考生成可直接用于游戏的 3D 模型
- [Tripo 3.1 — 高细节 3D 资产生成 ComfyUI 官方指南](https://docs.comfy.org/tutorials/partner-nodes/tripo/tripo-3-1) — 了解如何在 ComfyUI 中通过合作伙伴节点使用 Tripo 3.1 生成高细节 3D 资产：几何密度更高、表面质量更好，并提供 PBR 就绪材质。
- [Tripo 合作伙伴节点模型生成 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/tripo/model-generation) — 本文将介绍如何在 ComfyUI 中使用 Tripo 节点的 API 来进行模型生成

###### 音频

- [音频模型](https://docs.comfy.org/tutorials/partner-nodes/audio/overview) — 通过 ComfyUI 合作节点使用最先进的音频模型生成语音、音乐和音效

###### Fish Audio

- [Fish Audio：文本转语音、声音克隆与语音转文本](https://docs.comfy.org/tutorials/partner-nodes/fishaudio/fish-audio) — 在 ComfyUI 中运行 Fish Audio TTS、声音克隆和语音转文本工作流：模板教程、节点连接与 Cloud 链接
- [Fish Audio 提示词指南：在 ComfyUI 中撰写 Fish Audio TTS 提示词](https://docs.comfy.org/tutorials/partner-nodes/fishaudio/prompt-guide) — 为 ComfyUI 中的 Fish Audio 合作伙伴节点撰写提示词：情绪标签、语气标记、音频效果、停顿、音素控制和多说话人对话。

###### ByteDance

- [字节跳动 Seed Audio 1.0 - 通用音频生成](https://docs.comfy.org/tutorials/partner-nodes/bytedance/seed-audio-1-0) — 使用 ComfyUI 中的 Seed Audio 1.0，通过单一提示词生成语音、音乐、音效和多说话人对话，支持声音克隆与预设音色。

###### Sonilo

- [Sonilo 合作伙伴节点 ComfyUI 官方工作流示例](https://docs.comfy.org/tutorials/partner-nodes/sonilo/video-to-music) — 本文将介绍如何在 ComfyUI 中使用 Sonilo 合作伙伴节点的视频转音乐和文本转音频功能

###### LLM

- [LLM](https://docs.comfy.org/tutorials/partner-nodes/language/overview) — 通过 ComfyUI 合作节点在工作流中使用大语言模型（LLM）进行对话、提示词撰写和视觉理解

###### Anthropic

- [Anthropic Claude 合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/anthropic/claude) — 本文将介绍如何在 ComfyUI 中使用 Anthropic Claude 合作节点来完成对话功能

###### Google

- [Google Gemini 合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/google/gemini) — 本文将介绍如何在 ComfyUI 中使用 Google Gemini 合作节点来完成对话功能

###### OpenAI

- [OpenAI Chat 合作节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/openai/chat) — 本文将介绍如何在 ComfyUI 中使用 OpenAI Chat 合作节点来完成对话功能
- [GPT-6 Astra ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/openai/gpt-6-astra) — 通过 OpenAI Chat 合作节点使用 OpenAI GPT-6 Astra，完成复杂推理、图像分析、提示词生成等 LLM 驱动的工作流

###### OpenRouter

- [OpenRouter LLM 合作伙伴节点 ComfyUI 官方示例](https://docs.comfy.org/tutorials/partner-nodes/openrouter/llm) — 在 ComfyUI 中使用 OpenRouter LLM 合作伙伴节点，通过同一节点调用多种前沿大模型，完成对话、推理、视觉理解与联网搜索。

## 二、开发 · API · 部署 · 规范

> 来源索引：<https://docs.comfy.org/_llms/zh/api.md>（英文对应 <https://docs.comfy.org/_llms/en/developers.md>）

### API 开发


#### 使用 Comfy 开发

- [ComfyUI 开发者指南：SDK、服务器 API 与云端](https://docs.comfy.org/development/overview) — 使用官方 Python 和 TypeScript SDK 基于 ComfyUI 构建，将其作为服务器运行，调用 Cloud API，或通过 MCP 连接 AI 代理。
- [部署 ComfyUI](https://docs.comfy.org/development/deploy/overview) — 对比 Comfy Cloud、托管式 Comfy API 部署与自托管，选择运行 ComfyUI 的方式。
- [Comfy Cloud 快速开始](https://docs.comfy.org/development/deploy/cloud) — 使用付费订阅、API 密钥和 Comfy SDK 在 Comfy Cloud 上运行 API 格式的工作流。
- [Comfy API 和 Router 示例](https://docs.comfy.org/development/examples) — 介绍如何通过 Comfy Router 调用模型、部署 ComfyUI 工作流，并浏览社区应用。

##### Comfy Cloud

- [v1 Cloud API 概述](https://docs.comfy.org/development/cloud/overview) — 已弃用的 v1 Cloud API 范围：认证以及 Comfy API v2 尚未提供的 Cloud 专属端点
- [Cloud API 参考](https://docs.comfy.org/development/cloud/api-reference) — Comfy Cloud 的完整 API 参考及代码示例
- [OpenAPI 规范](https://docs.comfy.org/development/cloud/openapi) — Comfy Cloud API 的机器可读的 OpenAPI 规范

##### 自托管服务器

- [服务器概述](https://docs.comfy.org/development/comfyui-server/comms_overview) — 将 ComfyUI 作为服务器运行，通过 REST 和 WebSocket API 编程交互
- [API 示例](https://docs.comfy.org/development/comfyui-server/api-examples) — 调用 ComfyUI Server API 的三种常见方式
- [ComfyUI 服务器路由（HTTP 和 WebSocket API）](https://docs.comfy.org/development/comfyui-server/comms_routes) — ComfyUI Server API 路由：内置 GET、POST 和 WebSocket 端点，涵盖 prompt、队列、历史、模型和用户数据，以及如何添加自定义路由。
- [ComfyUI 服务器消息（WebSocket API）](https://docs.comfy.org/development/comfyui-server/comms_messages) — 了解 ComfyUI 的 PromptExecutor 如何通过 WebSocket 向客户端发送消息，包括 execution_start、progress 等内置消息类型，以及如何注册自定义消息类型。
- [启动参数](https://docs.comfy.org/development/comfyui-server/startup-flags) — ComfyUI 启动参数参考：comfy/cli_args.py 中的全部 main.py 命令行参数，以及如何在 Windows 便携版 .bat 启动器中添加参数。
- [自托管选项](https://docs.comfy.org/development/deploy/self-hosting) — 运行你自己的 ComfyUI 部署：裸金属、Runpod 和 Vast.ai 等 GPU 云服务提供商，或社区 Docker 镜像

#### 运行工作流

- [运行工作流](https://docs.comfy.org/development/run-workflows/overview) — 如何针对线上部署运行 ComfyUI 工作流，以及哪种客户端适用于哪种部署
- [运行你的第一个工作流](https://docs.comfy.org/development/api-development/quickstart) — 在 Comfy Cloud 上运行示例工作流,并使用 Python 或 TypeScript 下载其输出。
- [Comfy SDKs](https://docs.comfy.org/development/api-development/sdks) — 用 Python 或 TypeScript 对 Comfy Cloud、自建部署或自有 ComfyUI 运行 ComfyUI 工作流，并处理资产、任务、实时事件和幂等重试。
- [自托管 ComfyUI 的 API 代理](https://docs.comfy.org/development/comfyui-server/api-proxy) — 在你自己的 ComfyUI 前面提供 Comfy API v2 服务，让官方 SDK 能够针对它运行工作流
- [Comfy API：Serverless 部署](https://docs.comfy.org/development/serverless/overview) — 构建版本化的 ComfyUI 环境，将其部署为托管端点，并通过 API 运行工作流。
- [获取 API Key](https://docs.comfy.org/development/api-development/getting-an-api-key) — 了解如何创建和管理你的 Comfy Platform API Key，用于访问 Cloud API、Partner Nodes 等。
- [Comfy API v2 概览](https://docs.comfy.org/api-reference/v2/overview) — 官方 Comfy API v2 参考：从外部应用上传输入、提交工作流任务并轮询获取结果，在 ComfyUI 中运行工作流。
- [设计说明](https://docs.comfy.org/development/api-development/sdks-design) — Comfy API v2 存在的原因、它与现有 ComfyUI API 的关系，以及后续的规划
- [工作流 API 格式](https://docs.comfy.org/development/api-development/workflow-api-format) — 理解 ComfyUI 工作流的 API 格式以及如何导出
- [工作流元数据](https://docs.comfy.org/development/api-development/workflow-metadata) — 了解 ComfyUI 如何将工作流嵌入已生成的文件中，以及如何读取嵌入的元数据
- [ComfyUI 账户 API 密钥集成](https://docs.comfy.org/development/comfyui-server/api-key-integration) — 本文介绍了如何在无头模式下使用 ComfyUI 账户 API 密钥调用付费合作节点

##### Comfy API v2 参考文档


###### assets

- [Upload an asset (single-call multipart)](https://docs.comfy.org/api-reference/v2/assets/upload-an-asset-single-call-multipart) — Single-call `multipart/form-data` upload. The platform streams the bytes through its trusted byte-path, dedups by the server-computed hash, and mints the asset record.
- [Mint an asset over existing bytes (dedup fast-path)](https://docs.comfy.org/api-reference/v2/assets/mint-an-asset-over-existing-bytes-dedup-fast-path) — Zero-byte fast-path: mints a new asset UUID over a blob the platform already has, identified by its blake3 hash.
- [Existence check for a blob by blake3 hash](https://docs.comfy.org/api-reference/v2/assets/existence-check-for-a-blob-by-blake3-hash) — `200` if the calling account can mint from this blob, `404` otherwise. Same account-scoping as `from-hash`; lets a client decide between the dedup fast-path and a full upload before sending bytes.
- [Asset metadata](https://docs.comfy.org/api-reference/v2/assets/asset-metadata) — Returns the asset object with a fresh short-lived `url` for the content. Re-fetching always yields fresh URLs.
- [Delete an asset record](https://docs.comfy.org/api-reference/v2/assets/delete-an-asset-record) — Deletes the asset RECORD. The underlying content-addressed blob is untouched while any other asset still references it (hash dedup means blobs are shared) — deleting an asset never destroys another asset's bytes.
- [Asset bytes](https://docs.comfy.org/api-reference/v2/assets/asset-bytes) — Serves the bytes directly on surfaces where the platform stores blobs itself (self-hosted); on Cloud and serverless issues a `302` to a fresh signed URL. Range requests are supported for resumable downloads of large outputs.

###### jobs

- [Submit a workflow for execution](https://docs.comfy.org/api-reference/v2/jobs/submit-a-workflow-for-execution) — Accepts the API-format workflow graph verbatim. Validation is synchronous: graph structure, unknown node classes, and asset references (`core/ASSET` objects — every referenced `id` must exist and be owned by the caller). A `201` means the job is durably recorded and queued.
- [Job status (the polling workhorse)](https://docs.comfy.org/api-reference/v2/jobs/job-status-the-polling-workhorse) — Returns the full job object: current status, the latest progress snapshot, and every output committed so far (`outputs` populates incrementally while the job runs). This is the authoritative, resumable view of a job; everything on the SSE stream is derived from it.
- [The workflow behind a job — authoring version if pinned, executed graph otherwise](https://docs.comfy.org/api-reference/v2/jobs/the-workflow-behind-a-job-—-authoring-version-if-pinned-executed-graph-otherwise) — Returns the workflow behind a job. The response's `format` field says which of two different shapes `workflow` is in:
- [What the run printed](https://docs.comfy.org/api-reference/v2/jobs/what-the-run-printed) — Returns the job's captured execution log. Fetched on demand: a log is a debugging artifact a caller wants occasionally, while `GET /api/v2/jobs/{id}` is polled to terminal on every run, so the log is a resource of its own rather than a field that would ride every one of those polls to be read at mos…
- [Live event stream (SSE)](https://docs.comfy.org/api-reference/v2/jobs/live-event-stream-sse) — Server-Sent Events stream of the job's live state. On connect the client receives the current snapshot (a `status` event, the latest `progress`, and the most recent `preview` if any), then future updates. The stream ends after either the terminal `status` event or a terminal `error` event (see the `…
- [Request cancellation](https://docs.comfy.org/api-reference/v2/jobs/request-cancellation) — Requests cancellation and returns the current job object — `canceling` (interruption takes effect at node/step boundaries), `canceled` where the provider's record already shows the interrupt, or already-terminal. Idempotent: canceling a finished job is a no-op returning the terminal state. On server…

##### Comfy API Reference

- [Comfy API](https://docs.comfy.org/development/comfy-api/overview) — 用于无界面运行 ComfyUI 工作流的公开 API

#### Comfy Router

- [Comfy Router 快速入门](https://docs.comfy.org/development/comfy-router/quickstart) — 在几分钟内使用最新前沿媒体模型生成图像和视频。
- [Comfy Router API 概览](https://docs.comfy.org/development/comfy-router/api) — Comfy Router API 的工作方式：每个模型 ID 对应一个路由，并提供关于发现模型、schema、排队请求、错误和计费的指南。
- [发现 Comfy Router 模型](https://docs.comfy.org/development/comfy-router/discover-models) — 使用 GET /v2/models 列出 Comfy Router 目录，通过游标分页浏览，并按 ID 获取单个模型的条目。
- [Comfy Router 模型 schema 与结果](https://docs.comfy.org/development/comfy-router/schemas) — 获取 Router 模型的 OpenAPI 输入与输出 schema，用 ETag 缓存它，并读取模型的原生结果形状。
- [Comfy Router 请求排队](https://docs.comfy.org/development/comfy-router/queue) — 提交一次 Comfy Router 运行并轮询其状态，稍后用队列路由或 Python 和 TypeScript SDK 收集或取消该运行。
- [Comfy Router 错误与重试](https://docs.comfy.org/development/comfy-router/errors) — 了解 Comfy Router 的错误响应与验证详情，使用相同的 Idempotency-Key 重试，并在超时之后恢复。
- [Comfy Router 计费](https://docs.comfy.org/development/comfy-router/billing) — Comfy Router 如何对模型调用收费、目录中的 policy-refusal billing 字段的含义，以及如何对账用量。
- [Comfy Router 请求头](https://docs.comfy.org/development/comfy-router/headers) — 你可以向 Comfy Router 发送的请求头，以及它会返回的响应头，适用于所有模型：身份验证、幂等性、请求 ID、错误分桶、重试节奏和支出限额。
- [Comfy Router API 参考](https://docs.comfy.org/development/comfy-router/reference) — 每个 Comfy Router 端点、参数、响应体和错误分类，均由 Comfy API 契约生成。
- [Comfy Router 的能力与限制](https://docs.comfy.org/development/comfy-router/limitations) — 选择 Comfy Router 还是合作伙伴代理，为长时间运行的调用做好规划，并了解恢复、速率限制与资产存储。

##### Comfy Router API 参考文档


###### Comfy Router

- [List the models Comfy Router can run.](https://docs.comfy.org/api-reference/router/comfy-router/list-the-models-comfy-router-can-run) — Comfy Router's model catalog - one page of the canonical model IDs that `POST /v2/models/{provider}/{model}` accepts. An SDK calls this on cold start to discover what is runnable, and the `model_not_found` suggestions come from the same catalog, so an ID listed here that then 404s on invocation woul…
- [Read one partner model's catalog entry by canonical model ID.](https://docs.comfy.org/api-reference/router/comfy-router/read-one-partner-models-catalog-entry-by-canonical-model-id) — Per-model detail for a single Comfy Router model, so a caller can check one model without walking the whole paginated catalog. The SDKs use it to look a model up immediately before invoking it.
- [Run a partner model synchronously by canonical model ID.](https://docs.comfy.org/api-reference/router/comfy-router/run-a-partner-model-synchronously-by-canonical-model-id) — Comfy Router's canonical, model-ID-addressed entry point. The request body is the partner model's own native JSON input and the success response is that model's own native JSON output: Router forwards both unchanged instead of imposing a Comfy-shaped envelope, so a caller can move between the partne…
- [Read one partner model's input and output schemas as an OpenAPI document.](https://docs.comfy.org/api-reference/router/comfy-router/read-one-partner-models-input-and-output-schemas-as-an-openapi-document) — The per-model input and output schemas for a single Comfy Router model, served as a standalone OpenAPI document, so a caller - an SDK, a codegen tool, or an agent - can discover a model's arguments, and the shape of what it returns, without reading Comfy's prose docs. It is the discovery mechanism t…
- [Submit a partner model run to the queue and return immediately.](https://docs.comfy.org/api-reference/router/comfy-router/submit-a-partner-model-run-to-the-queue-and-return-immediately) — Comfy Router's queued delivery mode. The request body is the same partner-native JSON input `POST /v2/models/{provider}/{model}` accepts for this model - one body shape, one per-model schema, two delivery modes - but this route does not hold the connection for the result. It admits the run, answers…
- [Collect the result of one submitted request.](https://docs.comfy.org/api-reference/router/comfy-router/collect-the-result-of-one-submitted-request) — The collect endpoint. On a request that has finished successfully it returns the partner model's own native output, byte for byte what the synchronous route's `200` carries for the same model and the same input - so the two delivery modes produce one result shape and a caller can move between them w…
- [Ask for one submitted request to be cancelled.](https://docs.comfy.org/api-reference/router/comfy-router/ask-for-one-submitted-request-to-be-cancelled) — Asks Comfy to stop a request that has not finished. It is a request, not a guarantee, and the `202` says exactly that: `CANCELLATION_REQUESTED` means the ask was accepted, not that the run has stopped. A run already on the wire at a partner may complete anyway - and a partner generation that complet…
- [Read the queue state of one submitted request.](https://docs.comfy.org/api-reference/router/comfy-router/read-the-queue-state-of-one-submitted-request) — The poll endpoint. It answers with the request's current state and never with the result, so a client can watch a long generation without transferring its output on every poll - the result is collected once, from the read below, when this says `COMPLETED`.

##### Models

- [Comfy Router 模型](https://docs.comfy.org/development/comfy-router/models) — Comfy Router 提供的全部模型，按提供方分组，并列出每个模型的输入和输出模态。
- [Comfy Router 服务提供商](https://docs.comfy.org/development/comfy-router/providers) — 查看每个 Comfy Router 模型可由哪些提供商提供服务，以及如何选择备用提供商。

###### Anthropic

- [将 Claude Fable 5.1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-fable-5-1/code) — 通过 Comfy Router 调用 anthropic/claude-fable-5-1：endpoint、请求结构以及 Router 返回的响应。
- [将 Claude Fable 5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-fable-5/code) — 通过 Comfy Router 调用 anthropic/claude-fable-5：端点、请求结构与 Router 返回的响应。
- [将 Claude Haiku 4.5 20251001 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-haiku-4-5-20251001/code) — 通过 Comfy Router 调用 anthropic/claude-haiku-4-5-20251001：端点、请求结构以及 Router 返回的响应。
- [将 Claude Opus 4.6 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-opus-4-6/code) — 通过 Comfy Router 调用 anthropic/claude-opus-4-6：endpoint、请求结构以及 Router 返回的响应。
- [将 Claude Opus 4.7 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-opus-4-7/code) — 通过 Comfy Router 调用 anthropic/claude-opus-4-7：端点、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Claude Opus 4.8](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-opus-4-8/code) — 通过 Comfy Router 调用 anthropic/claude-opus-4-8：端点、请求结构以及 Router 返回的响应。
- [使用 Claude Opus 5.5 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-opus-5-5/code) — 通过 Comfy Router 调用 anthropic/claude-opus-5-5：端点、请求形状以及 Router 返回的响应。
- [将 Claude Opus 5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-opus-5/code) — 通过 Comfy Router 调用 anthropic/claude-opus-5：端点、请求形状以及 Router 返回的响应。
- [将 Claude Sonnet 4.5 20250929 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-sonnet-4-5-20250929/code) — 通过 Comfy Router 调用 anthropic/claude-sonnet-4-5-20250929：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Claude Sonnet 4.6](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-sonnet-4-6/code) — 通过 Comfy Router 调用 anthropic/claude-sonnet-4-6：端点、请求形状以及 Router 返回的响应。
- [结合 Comfy Router 使用 Claude Sonnet 5.5](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-sonnet-5-5/code) — 通过 Comfy Router 调用 anthropic/claude-sonnet-5-5：端点、请求结构与 Router 返回的响应。
- [将 Claude Sonnet 5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/anthropic/claude-sonnet-5/code) — 通过 Comfy Router 调用 anthropic/claude-sonnet-5：端点、请求结构与 Router 返回的响应。

###### Beeble

- [将 SwitchX 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/beeble/switchx/code) — 通过 Comfy Router 调用 beeble/switchx：端点、请求结构以及 Router 返回的响应。

###### Black Forest Labs

- [搭配 Comfy Router 使用 Erase V1](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/erase-v1/code) — 通过 Comfy Router 调用 bfl/erase-v1：端点、请求形状以及 Router 返回的响应。
- [使用 Flux 1.1 Pro Ultra Image 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-1-1-pro-ultra-image/code) — 通过 Comfy Router 调用 FLUX 1.1 [pro] Ultra 和 FLUX 1.1 [pro] 的 Python、TypeScript 与 cURL 代码片段，以及请求字段和结果结构
- [通过 Comfy Router 使用 FLUX.1 Kontext](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-1-kontext/code) — 通过 Comfy Router 调用 FLUX.1 Kontext Pro 和 Kontext Max 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [使用 Comfy Router 调用 FLUX 2 Max](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-2-max/code) — 通过 Comfy Router 调用 bfl/flux-2-max：端点、请求形状以及 Router 返回的响应。
- [将 FLUX 2 Pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-2-pro/code) — 通过 Comfy Router 调用 bfl/flux-2-pro：端点、请求结构，以及 Router 返回的响应。
- [使用 Comfy Router 调用 FLUX 3 Video](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-3-video/code) — 通过 Comfy Router 以 HTTP 方式调用 FLUX 3 生成带同步音频的视频，包含 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果结构
- [使用 FLUX Pro 1.0 Canny 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-pro-1-0-canny/code) — 通过 Comfy Router 调用 bfl/flux-pro-1.0-canny：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 FLUX Pro 1.0 Depth](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-pro-1-0-depth/code) — 通过 Comfy Router 调用 bfl/flux-pro-1.0-depth：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 FLUX Pro 1.0 Expand](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-pro-1-0-expand/code) — 通过 Comfy Router 调用 bfl/flux-pro-1.0-expand：端点、请求结构与 Router 返回的响应。
- [使用 Comfy Router 调用 FLUX Pro 1.0 Fill](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-pro-1-0-fill/code) — 通过 Comfy Router 调用 bfl/flux-pro-1.0-fill：endpoint、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 FLUX Video Upscale](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/flux-video-upscale/code) — 使用 Python、TypeScript 和 cURL 代码片段，通过 Comfy Router 以 HTTP 方式调用 FLUX Video Upscale 对视频进行放大，并说明请求字段与结果结构
- [将 Video Edit V1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/video-edit-v1/code) — 通过 Comfy Router 调用 bfl/video-edit-v1：端点、请求结构以及 Router 返回的响应。
- [将 VTO V1 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/black-forest-labs/vto-v1/code) — 通过 Comfy Router 调用 bfl/vto-v1：端点、请求结构以及 Router 返回的响应。

###### Bria

- [将 Fibo 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/bria/fibo/code) — 通过 Comfy Router 调用 bria/fibo：端点、请求结构以及 Router 返回的响应。
- [将 Image Edit Add Object By Text 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-add-object-by-text/code) — 通过 Comfy Router 调用 bria/image-edit-add-object-by-text：端点、请求形状以及 Router 返回的响应。
- [结合 Comfy Router 使用 Image Edit Erase By Text](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-erase-by-text/code) — 通过 Comfy Router 调用 bria/image-edit-erase-by-text：端点、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Image Edit Erase Foreground](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-erase-foreground/code) — 通过 Comfy Router 调用 bria/image-edit-erase-foreground：endpoint、请求结构以及 Router 返回的响应。
- [在 Comfy Router 中使用 Image Edit Erase](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-erase/code) — 通过 Comfy Router 调用 bria/image-edit-erase：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Image Edit Expand](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-expand/code) — 通过 Comfy Router 调用 bria/image-edit-expand：端点、请求结构以及 Router 返回的响应。
- [将 Image Edit Gen Fill 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-gen-fill/code) — 通过 Comfy Router 调用 bria/image-edit-gen-fill：endpoint、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Image Edit Increase Resolution](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-increase-resolution/code) — 通过 Comfy Router 调用 bria/image-edit-increase-resolution：端点、请求结构以及 Router 返回的响应。
- [将 Image Edit Relight 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-relight/code) — 通过 Comfy Router 调用 bria/image-edit-relight：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 Image Edit Remove Background](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-remove-background/code) — 通过 Comfy Router 调用 bria/image-edit-remove-background：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 Image Edit Replace Background](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-replace-background/code) — 通过 Comfy Router 调用 bria/image-edit-replace-background：端点、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Image Edit Replace Object By Text](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-replace-object-by-text/code) — 通过 Comfy Router 调用 bria/image-edit-replace-object-by-text：endpoint、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Image Edit Reseason](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-reseason/code) — 通过 Comfy Router 调用 bria/image-edit-reseason：端点、请求结构以及 Router 返回的响应。
- [在 Comfy Router 中使用 Image Edit Restore](https://docs.comfy.org/development/comfy-router/models/bria/image-edit-restore/code) — 通过 Comfy Router 调用 bria/image-edit-restore：endpoint、请求形状以及 Router 返回的响应。
- [搭配 Comfy Router 使用结构化指令](https://docs.comfy.org/development/comfy-router/models/bria/structured-instruction/code) — 通过 Comfy Router 调用 bria/structured-instruction：端点、请求形状以及 Router 返回的响应。
- [将 Video Edit Erase 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/bria/video-edit-erase/code) — 通过 Comfy Router 调用 bria/video-edit-erase：端点、请求形状以及 Router 返回的响应。
- [配合 Comfy Router 使用 Video Edit Green Screen](https://docs.comfy.org/development/comfy-router/models/bria/video-edit-green-screen/code) — 通过 Comfy Router 调用 bria/video-edit-green-screen：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 进行视频编辑移除背景](https://docs.comfy.org/development/comfy-router/models/bria/video-edit-remove-background/code) — 通过 Comfy Router 调用 bria/video-edit-remove-background：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 进行视频编辑替换背景](https://docs.comfy.org/development/comfy-router/models/bria/video-edit-replace-background/code) — 通过 Comfy Router 调用 bria/video-edit-replace-background：端点、请求形状以及 Router 返回的响应。

###### BytePlus

- [使用 Dreamina Seedance 2.0 260128 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/byteplus/dreamina-seedance-2-0-260128/code) — 通过 Comfy Router 调用 byteplus/dreamina-seedance-2-0-260128：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 Dreamina Seedance 2.0 Fast 260128](https://docs.comfy.org/development/comfy-router/models/byteplus/dreamina-seedance-2-0-fast-260128/code) — 通过 Comfy Router 调用 byteplus/dreamina-seedance-2-0-fast-260128：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Dreamina Seedance 2.0 Mini](https://docs.comfy.org/development/comfy-router/models/byteplus/dreamina-seedance-2-0-mini/code) — 通过 Comfy Router 调用 byteplus/dreamina-seedance-2-0-mini：endpoint、请求结构以及 Router 返回的响应。
- [使用 Dreamina Seedance 2.5 260628 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/byteplus/dreamina-seedance-2-5-260628/code) — 通过 Comfy Router 调用 byteplus/dreamina-seedance-2-5-260628:端点、请求形状以及 Router 返回的响应。
- [将 Seed 2.0 Lite 260228 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seed-2-0-lite-260228/code) — 通过 Comfy Router 调用 byteplus/seed-2-0-lite-260228：endpoint、请求结构以及 Router 返回的响应。
- [将 Seed 2.0 Mini 260215 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seed-2-0-mini-260215/code) — 通过 Comfy Router 调用 byteplus/seed-2-0-mini-260215：端点、请求结构与 Router 返回的响应。
- [将 Seed 2.0 Pro 260328 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seed-2-0-pro-260328/code) — 通过 Comfy Router 调用 byteplus/seed-2-0-pro-260328：端点、请求结构以及 Router 返回的响应。
- [将 Seed Audio 1.0 Multilingual 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seed-audio-1-0-multilingual/code) — 通过 Comfy Router 调用 byteplus/seed-audio-1.0-multilingual：端点、请求结构以及 Router 返回的响应。
- [结合 Comfy Router 使用 Seed Audio 1.0](https://docs.comfy.org/development/comfy-router/models/byteplus/seed-audio-1-0/code) — 通过 Comfy Router 调用 byteplus/seed-audio-1.0：端点、请求形状以及 Router 返回的响应。
- [将 Seedance 1.0 Pro 250528 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seedance-1-0-pro-250528/code) — 通过 Comfy Router 调用 byteplus/seedance-1-0-pro-250528：endpoint、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 Seedance 1.0 Pro Fast 251015](https://docs.comfy.org/development/comfy-router/models/byteplus/seedance-1-0-pro-fast-251015/code) — 通过 Comfy Router 调用 byteplus/seedance-1-0-pro-fast-251015：endpoint、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Seedance 1.5 Pro 251215](https://docs.comfy.org/development/comfy-router/models/byteplus/seedance-1-5-pro-251215/code) — 通过 Comfy Router 调用 byteplus/seedance-1-5-pro-251215：endpoint、请求形状以及 Router 返回的响应。
- [将 Seedream 4.0 250828 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seedream-4-0-250828/code) — 通过 Comfy Router 调用 byteplus/seedream-4-0-250828：端点、请求形状以及 Router 返回的响应。
- [将 Seedream 4.5 251128 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seedream-4-5-251128/code) — 通过 Comfy Router 调用 byteplus/seedream-4-5-251128：端点、请求结构以及 Router 返回的响应。
- [结合 Comfy Router 使用 Seedream 5.0 260128](https://docs.comfy.org/development/comfy-router/models/byteplus/seedream-5-0-260128/code) — 通过 Comfy Router 调用 byteplus/seedream-5-0-260128：端点、请求形状以及 Router 返回的响应。
- [将 Seedream 5.0 Flash 260915 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/byteplus/seedream-5-0-flash-260915/code) — 通过 Comfy Router 调用 byteplus/seedream-5-0-flash-260915：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 Seedream 5.0 Pro 260628](https://docs.comfy.org/development/comfy-router/models/byteplus/seedream-5-0-pro-260628/code) — 通过 Comfy Router 调用 byteplus/seedream-5-0-pro-260628：端点、请求格式以及 Router 返回的响应。

###### Elevenlabs

- [将 Eleven Sfx V2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/elevenlabs/eleven-sfx-v2/code) — 通过 Comfy Router 调用 elevenlabs/eleven_sfx_v2：endpoint、请求结构以及 Router 返回的响应。
- [将 Eleven V3 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/elevenlabs/eleven-v3/code) — 通过 Comfy Router 调用 elevenlabs/eleven_v3：端点、请求结构以及 Router 返回的响应。

###### fal

- [将 H3 Max Turbo 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/fal/h3-max-turbo/code) — 通过 Comfy Router 调用 fal/h3-max-turbo：端点、请求形状以及 Router 返回的响应。
- [在 Comfy Router 中使用 H3 Max](https://docs.comfy.org/development/comfy-router/models/fal/h3-max/code) — 通过 Comfy Router 调用 fal/h3-max：端点、请求结构以及 Router 返回的响应。
- [将 Patina 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/fal/patina/code) — 通过 Comfy Router 调用 fal/patina：端点、请求结构以及 Router 返回的响应。

###### Freepik

- [将 AI Image Upscaler Precision V2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/freepik/ai-image-upscaler-precision-v2/code) — 通过 Comfy Router 调用 freepik/ai-image-upscaler-precision-v2：端点、请求结构以及 Router 返回的响应。
- [将 AI Skin Enhancer Creative 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/freepik/ai-skin-enhancer-creative/code) — 通过 Comfy Router 调用 freepik/ai-skin-enhancer-creative：endpoint、请求结构以及 Router 返回的响应。
- [将 AI Skin Enhancer Faithful 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/freepik/ai-skin-enhancer-faithful/code) — 通过 Comfy Router 调用 freepik/ai-skin-enhancer-faithful：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 AI Skin Enhancer Flexible](https://docs.comfy.org/development/comfy-router/models/freepik/ai-skin-enhancer-flexible/code) — 通过 Comfy Router 调用 freepik/ai-skin-enhancer-flexible：endpoint、请求形状以及 Router 返回的响应。

###### Gemini Interactions

- [搭配 Comfy Router 使用 Gemini Omni 1.1 Flash](https://docs.comfy.org/development/comfy-router/models/gemini-interactions/gemini-omni-1-1-flash/code) — 通过 Comfy Router 调用 gemini-interactions/gemini-omni-1.1-flash：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Gemini Omni Flash Preview](https://docs.comfy.org/development/comfy-router/models/gemini-interactions/gemini-omni-flash-preview/code) — 通过 Comfy Router 调用 gemini-interactions/gemini-omni-flash-preview：endpoint、请求形状以及 Router 返回的响应。

###### Google

- [使用 Gemini 2.5 Flash Image 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/google/gemini-2-5-flash-image/code) — 通过 Comfy Router 调用 vertexai/gemini-2.5-flash-image：endpoint、请求形状以及 Router 返回的响应。
- [使用 Gemini 3.1 Flash Lite 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/google/gemini-3-1-flash-lite/code) — 通过 Comfy Router 调用 vertexai/gemini-3.1-flash-lite：端点、请求形状以及 Router 返回的响应。
- [使用 Gemini 3.7 Flash 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/google/gemini-3-7-flash/code) — 通过 Comfy Router 调用 vertexai/gemini-3.7-flash：端点、请求形状以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Gemini 3.8 Flash](https://docs.comfy.org/development/comfy-router/models/google/gemini-3-8-flash/code) — 通过 Comfy Router 调用 vertexai/gemini-3.8-flash：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 Google Gemini](https://docs.comfy.org/development/comfy-router/models/google/gemini/code) — 通过 Comfy Router 以 HTTP 方式调用 Google Gemini 文本模型的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果的结构
- [使用 Comfy Router 调用 Imagen 3.0 Fast Generate 001](https://docs.comfy.org/development/comfy-router/models/google/imagen-3-0-fast-generate-001/code) — 通过 Comfy Router 调用 vertexai/imagen-3.0-fast-generate-001：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Imagen 3.0 Generate 001](https://docs.comfy.org/development/comfy-router/models/google/imagen-3-0-generate-001/code) — 通过 Comfy Router 调用 vertexai/imagen-3.0-generate-001：endpoint、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Imagen 3.0 Generate 002](https://docs.comfy.org/development/comfy-router/models/google/imagen-3-0-generate-002/code) — 通过 Comfy Router 调用 vertexai/imagen-3.0-generate-002：端点、请求形状以及 Router 返回的响应。
- [将 Nano Banana 2 Lite 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/google/nano-banana-2-lite/code) — 通过 Comfy Router 以 HTTP 方式调用 Nano Banana 2 Lite（Gemini 3.1 Flash-Lite Image）生成图像的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果的结构
- [将 Nano Banana 2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/google/nano-banana-2/code) — 通过 Comfy Router 以 HTTP 方式调用 Nano Banana 2（Gemini 3.1 Flash Image）生成图像的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果结构
- [搭配 Comfy Router 使用 Nano Banana Pro](https://docs.comfy.org/development/comfy-router/models/google/nano-banana-pro/code) — 通过 Comfy Router 以 HTTP 方式使用 Nano Banana Pro（Gemini 3 Pro Image）生成图像的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果结构

###### HeyGen

- [将 Starfish 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/heygen/starfish/code) — 通过 Comfy Router 调用 heygen/starfish：端点、请求形状以及 Router 返回的响应。

###### Higgsfield

- [将 Higgsfield Kling 3.4k 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/higgsfield/higgsfield-kling-3-4k/code) — 通过 Comfy Router 调用 higgsfield/higgsfield-kling-3-4k：端点、请求结构以及 Router 返回的响应。
- [将 Higgsfield Kling 3 Pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/higgsfield/higgsfield-kling-3-pro/code) — 通过 Comfy Router 调用 higgsfield/higgsfield-kling-3-pro：端点、请求结构以及 Router 返回的响应。

###### Ideogram

- [将 Ideogram V3 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/ideogram/ideogram-v3/code) — 通过 Comfy Router 调用 ideogram/ideogram-v3：endpoint、请求结构与 Router 返回的响应。
- [结合 Comfy Router 使用 Ideogram 4.0](https://docs.comfy.org/development/comfy-router/models/ideogram/ideogram-v4/code) — 通过 Comfy Router 以 HTTP 方式调用 Ideogram 4.0 生成图像的 Python、TypeScript 和 cURL 代码片段，以及请求字段与返回结果的结构
- [配合 Comfy Router 使用 P Image Ideogram](https://docs.comfy.org/development/comfy-router/models/ideogram/p-image-ideogram/code) — 通过 Comfy Router 调用 ideogram/p-image-ideogram：endpoint、请求结构以及 Router 返回的响应。

###### Kling

- [通过 Comfy Router 使用 Kling 3.0 Turbo](https://docs.comfy.org/development/comfy-router/models/kling/kling-3-0-turbo/code) — 通过 Comfy Router 调用 kling/kling-3.0-turbo：endpoint、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Kling Image O1](https://docs.comfy.org/development/comfy-router/models/kling/kling-image-o1/code) — 通过 Comfy Router 调用 kling/kling-image-o1：端点、请求结构以及 Router 返回的响应。
- [将 Kling V2.5 Turbo 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/kling/kling-v2-5-turbo/code) — 通过 Comfy Router 调用 kling/kling-v2-5-turbo：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Kling V2.6](https://docs.comfy.org/development/comfy-router/models/kling/kling-v2-6/code) — 通过 Comfy Router 调用 kling/kling-v2-6：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 Kling V3 Omni](https://docs.comfy.org/development/comfy-router/models/kling/kling-v3-omni/code) — 通过 Comfy Router 调用 kling/kling-v3-omni：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Kling V3](https://docs.comfy.org/development/comfy-router/models/kling/kling-v3/code) — 通过 Comfy Router 调用 kling/kling-v3：端点、请求形状以及 Router 返回的响应。
- [将 Kling Video O1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/kling/kling-video-o1/code) — 通过 Comfy Router 调用 kling/kling-video-o1：endpoint、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Videos Avatar Image 2video](https://docs.comfy.org/development/comfy-router/models/kling/videos-avatar-image2video/code) — 通过 Comfy Router 调用 kling/videos-avatar-image2video：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用视频唇形同步](https://docs.comfy.org/development/comfy-router/models/kling/videos-lip-sync/code) — 通过 Comfy Router 调用 kling/videos-lip-sync：端点、请求结构以及 Router 返回的响应。
- [使用 Videos Video Extend 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/kling/videos-video-extend/code) — 通过 Comfy Router 调用 kling/videos-video-extend：endpoint、请求形状以及 Router 返回的响应。

###### Krea

- [使用 Comfy Router 调用 Krea 2 Large](https://docs.comfy.org/development/comfy-router/models/krea/krea-2-large/code) — 通过 Comfy Router 调用 krea/krea-2-large：endpoint、请求结构以及 Router 返回的响应。
- [将 Krea 2 Medium Turbo 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/krea/krea-2-medium-turbo/code) — 通过 Comfy Router 调用 krea/krea-2-medium-turbo：端点、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Krea 2 Medium](https://docs.comfy.org/development/comfy-router/models/krea/krea-2-medium/code) — 通过 Comfy Router 调用 krea/krea-2-medium：端点、请求形状以及 Router 返回的响应。
- [在 Comfy Router 中使用 Krea 2](https://docs.comfy.org/development/comfy-router/models/krea/krea-2/code) — 通过 Comfy Router 调用 krea/krea-2：端点、请求形状以及 Router 返回的响应。

###### LTX

- [通过 Comfy Router 使用 LTX 2.5 Fast](https://docs.comfy.org/development/comfy-router/models/ltx/ltx-2-5-fast/code) — 通过 Comfy Router 调用 ltx/ltx-2-5-fast：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 LTX 2.5 Pro](https://docs.comfy.org/development/comfy-router/models/ltx/ltx-2-5-pro/code) — 通过 Comfy Router 调用 ltx/ltx-2-5-pro：端点、请求结构以及 Router 返回的响应。

###### Luma

- [将 Photon 1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/luma/photon-1/code) — 通过 Comfy Router 调用 luma/photon-1：端点、请求形状以及 Router 返回的响应。
- [将 Photon Flash 1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/luma/photon-flash-1/code) — 通过 Comfy Router 调用 luma/photon-flash-1：端点、请求结构以及 Router 返回的响应。
- [将 Ray 2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/luma/ray-2/code) — 通过 Comfy Router 调用 luma/ray-2:endpoint、请求 shape 以及 Router 返回的响应。
- [在 Comfy Router 中使用 Ray Flash 2](https://docs.comfy.org/development/comfy-router/models/luma/ray-flash-2/code) — 通过 Comfy Router 调用 luma/ray-flash-2：端点、请求形状以及 Router 返回的响应。

###### Luma 2

- [搭配 Comfy Router 使用 Uni 1 Max](https://docs.comfy.org/development/comfy-router/models/luma_2/uni-1-max/code) — 通过 Comfy Router 调用 luma_2/uni-1-max：端点、请求结构以及 Router 返回的响应。
- [将 Uni 1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/luma_2/uni-1/code) — 通过 Comfy Router 调用 luma_2/uni-1：端点、请求形状以及 Router 返回的响应。

###### Meshy

- [将 Animations 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/meshy/animations/code) — 通过 Comfy Router 调用 meshy/animations：端点、请求结构以及 Router 返回的响应。
- [将 Meshy 5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/meshy/meshy-5/code) — 通过 Comfy Router 调用 meshy/meshy-5：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Meshy 6](https://docs.comfy.org/development/comfy-router/models/meshy/meshy-6/code) — 通过 Comfy Router 调用 meshy/meshy-6：端点、请求结构以及 Router 返回的响应。
- [将 Meshy 7.1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/meshy/meshy-7-1/code) — 通过 Comfy Router 调用 meshy/meshy-7.1：端点、请求结构以及 Router 返回的响应。
- [将 Meshy 7 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/meshy/meshy-7/code) — 通过 Comfy Router 调用 meshy/meshy-7：端点、请求结构以及 Router 返回的响应。
- [将 Remesh 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/meshy/remesh/code) — 通过 Comfy Router 调用 meshy/remesh：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 Rigging](https://docs.comfy.org/development/comfy-router/models/meshy/rigging/code) — 通过 Comfy Router 调用 meshy/rigging：endpoint、请求结构以及 Router 返回的响应。

###### MiniMax

- [配合 Comfy Router 使用 MiniMax H3](https://docs.comfy.org/development/comfy-router/models/minimax/minimax-h3/code) — 通过 Comfy Router 调用 minimax/minimax-h3：端点、请求结构以及 Router 返回的响应。

###### Moonvalley

- [使用 Comfy Router 进行图生视频](https://docs.comfy.org/development/comfy-router/models/moonvalley/image-to-video/code) — 通过 Comfy Router 调用 moonvalley/image-to-video：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 进行文生图](https://docs.comfy.org/development/comfy-router/models/moonvalley/text-to-image/code) — 通过 Comfy Router 调用 moonvalley/text-to-image：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 进行文生视频](https://docs.comfy.org/development/comfy-router/models/moonvalley/text-to-video/code) — 通过 Comfy Router 调用 moonvalley/text-to-video：端点、请求形状以及 Router 返回的响应。
- [将视频转视频调整大小与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/moonvalley/video-to-video-resize/code) — 通过 Comfy Router 调用 moonvalley/video-to-video-resize：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用视频转视频](https://docs.comfy.org/development/comfy-router/models/moonvalley/video-to-video/code) — 通过 Comfy Router 调用 moonvalley/video-to-video：端点、请求形状以及 Router 返回的响应。

###### OpenAI

- [将 GPT 4.1 Mini 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-4-1-mini/code) — 通过 Comfy Router 调用 openai/gpt-4.1-mini：端点、请求格式以及 Router 返回的响应。
- [使用 GPT 4.1 Nano 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/openai/gpt-4-1-nano/code) — 通过 Comfy Router 调用 openai/gpt-4.1-nano：端点、请求结构以及 Router 返回的响应。
- [将 GPT 4.1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-4-1/code) — 通过 Comfy Router 调用 openai/gpt-4.1：端点、请求结构以及 Router 返回的响应。
- [将 GPT 4o 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-4o/code) — 通过 Comfy Router 调用 openai/gpt-4o：endpoint、请求形状以及 Router 返回的响应。
- [使用 GPT 5.5 Pro 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-5-pro/code) — 通过 Comfy Router 调用 openai/gpt-5.5-pro：端点、请求结构以及 Router 返回的响应。
- [将 GPT 5.5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-5/code) — 通过 Comfy Router 调用 openai/gpt-5.5：端点、请求结构以及 Router 返回的响应。
- [将 GPT 5.6 Luna 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-6-luna/code) — 通过 Comfy Router 调用 openai/gpt-5.6-luna：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 GPT 5.6 Sol](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-6-sol/code) — 通过 Comfy Router 调用 openai/gpt-5.6-sol：端点、请求结构以及 Router 返回的响应。
- [将 GPT 5.6 Terra 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-6-terra/code) — 通过 Comfy Router 调用 openai/gpt-5.6-terra：端点、请求形状以及 Router 返回的响应。
- [在 Comfy Router 中使用 GPT 5 Mini](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-mini/code) — 通过 Comfy Router 调用 openai/gpt-5-mini：端点、请求结构及 Router 返回的响应。
- [将 GPT 5 Nano 与 Comfy Router 结合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5-nano/code) — 通过 Comfy Router 调用 openai/gpt-5-nano：端点、请求格式以及 Router 返回的响应。
- [将 GPT 5 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-5/code) — 通过 Comfy Router 调用 openai/gpt-5：端点、请求结构以及 Router 返回的响应。
- [将 GPT 6 Astra 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-6-astra/code) — 通过 Comfy Router 调用 openai/gpt-6-astra：端点、请求结构，以及 Router 返回的响应。
- [将 GPT 6 Luna 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-6-luna/code) — 通过 Comfy Router 调用 openai/gpt-6-luna：端点、请求结构以及 Router 返回的响应。
- [将 GPT 6 Sol 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-6-sol/code) — 通过 Comfy Router 调用 openai/gpt-6-sol：端点、请求结构以及 Router 返回的响应。
- [将 GPT Image 1.5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-image-1-5/code) — 通过 Comfy Router 调用 openai/gpt-image-1.5：端点、请求结构以及 Router 返回的响应。
- [将 GPT Image 1 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-image-1/code) — 通过 Comfy Router 调用 openai/gpt-image-1：端点、请求形状以及 Router 返回的响应。
- [将 GPT Image 2.5 Flare 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-image-2-5-flare/code) — 通过 Comfy Router 调用 openai/gpt-image-2.5-flare：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 GPT Image 2.5 Sunburst](https://docs.comfy.org/development/comfy-router/models/openai/gpt-image-2-5-sunburst/code) — 通过 Comfy Router 调用 openai/gpt-image-2.5-sunburst：端点、请求结构以及 Router 返回的响应。
- [将 GPT Image 2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/gpt-image-2/code) — 通过 Comfy Router 调用 openai/gpt-image-2：端点、请求结构，以及 Router 返回的响应。
- [将 o1-pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/o1-pro/code) — 通过 Comfy Router 调用 openai/o1-pro：端点、请求形状以及 Router 返回的响应。
- [搭配 Comfy Router 使用 o1](https://docs.comfy.org/development/comfy-router/models/openai/o1/code) — 通过 Comfy Router 调用 openai/o1：端点、请求形状以及 Router 返回的响应。
- [将 o3 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/openai/o3/code) — 通过 Comfy Router 调用 openai/o3：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 o4-mini](https://docs.comfy.org/development/comfy-router/models/openai/o4-mini/code) — 通过 Comfy Router 调用 openai/o4-mini：端点、请求结构以及 Router 返回的响应。

###### Pruna

- [结合 Comfy Router 使用 P Video 2](https://docs.comfy.org/development/comfy-router/models/pruna/p-video-2/code) — 通过 Comfy Router 调用 pruna/p-video-2:介绍端点、请求结构以及 Router 返回的响应。

###### Qwen

- [搭配 Comfy Router 使用 Qwen Image 3.0 Pro](https://docs.comfy.org/development/comfy-router/models/qwen/qwen-image-3-0-pro/code) — 通过 Comfy Router 调用 qwen/qwen-image-3.0-pro：端点、请求格式以及 Router 返回的响应。
- [使用 Qwen Image 3.0 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/qwen/qwen-image-3-0/code) — 通过 Comfy Router 调用 qwen/qwen-image-3.0：端点、请求形状以及 Router 返回的响应。

###### Recraft

- [配合 Comfy Router 使用 Recraft V2](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv2/code) — 通过 Comfy Router 调用 recraft/recraftv2：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Recraft V3](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv3/code) — 通过 Comfy Router 调用 recraft/recraftv3：端点、请求结构以及 Router 返回的响应。
- [将 Recraft V4.1 Pro Vector 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-pro-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_pro_vector：端点、请求形状以及 Router 返回的响应。
- [将 Recraft V4.1 Pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-pro/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_pro：端点、请求形状以及 Router 返回的响应。
- [通过 Comfy Router 使用 Recraft V4.1 Utility Pro Vector](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-utility-pro-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_utility_pro_vector：endpoint、请求结构以及 Router 返回的响应。
- [将 Recraft V4.1 Utility Pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-utility-pro/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_utility_pro：端点、请求形状以及 Router 返回的响应。
- [使用 Recraft V4.1 Utility Vector 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-utility-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_utility_vector：端点、请求结构以及 Router 返回的响应。
- [将 Recraft V4.1 Utility 与 Comfy Router 搭配使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-utility/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_utility：端点、请求结构以及 Router 返回的响应。
- [结合 Comfy Router 使用 Recraft V4.1 Vector](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_1_vector：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Recraft V4.1](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-1/code) — 通过 Comfy Router 调用 recraft/recraftv4_1：端点、请求结构以及 Router 返回的响应。
- [在 Comfy Router 中使用 Recraft V4 Pro](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-pro/code) — 通过 Comfy Router 调用 recraft/recraftv4_pro：端点、请求结构以及 Router 返回的响应。
- [将 Recraft V4 Styles Pro Vector 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-styles-pro-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_styles_pro_vector：端点、请求结构以及 Router 返回的响应。
- [将 Recraft V4 Styles Pro 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-styles-pro/code) — 通过 Comfy Router 调用 recraft/recraftv4_styles_pro：端点、请求结构以及 Router 返回的响应。
- [使用 Recraft V4 Styles Vector 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-styles-vector/code) — 通过 Comfy Router 调用 recraft/recraftv4_styles_vector：端点、请求形状以及 Router 返回的响应。
- [使用 Recraft V4 Styles 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4-styles/code) — 通过 Comfy Router 调用 recraft/recraftv4_styles：端点、请求形状以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Recraft V4](https://docs.comfy.org/development/comfy-router/models/recraft/recraftv4/code) — 通过 Comfy Router 调用 recraft/recraftv4：端点、请求结构以及 Router 返回的响应。

###### Runway

- [将 Aleph 2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/runway/aleph2/code) — 通过 Comfy Router 调用 runway/aleph2：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用 Gen 4 Image](https://docs.comfy.org/development/comfy-router/models/runway/gen4-image/code) — 通过 Comfy Router 调用 runway/gen4_image：端点、请求结构以及 Router 返回的响应。
- [将 Gen 4 Turbo 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/runway/gen4-turbo/code) — 通过 Comfy Router 调用 runway/gen4_turbo：端点、请求形状以及 Router 返回的响应。

###### Synclabs

- [通过 Comfy Router 使用 Sync 3](https://docs.comfy.org/development/comfy-router/models/synclabs/sync-3/code) — 通过 Comfy Router 调用 synclabs/sync-3：端点、请求结构以及 Router 返回的响应。

###### Tencent

- [使用混元 3D Part 配合 Comfy Router](https://docs.comfy.org/development/comfy-router/models/tencent/hunyuan-3d-part/code) — 通过 Comfy Router 调用 tencent/hunyuan-3d-part：endpoint、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用混元3D智能拓扑](https://docs.comfy.org/development/comfy-router/models/tencent/hunyuan-3d-smart-topology/code) — 通过 Comfy Router 调用 tencent/hunyuan-3d-smart-topology：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用混元3D 纹理编辑](https://docs.comfy.org/development/comfy-router/models/tencent/hunyuan-3d-texture-edit/code) — 通过 Comfy Router 调用 tencent/hunyuan-3d-texture-edit：端点、请求结构以及 Router 返回的响应。
- [通过 Comfy Router 使用混元 3D Uv](https://docs.comfy.org/development/comfy-router/models/tencent/hunyuan-3d-uv/code) — 通过 Comfy Router 调用 tencent/hunyuan-3d-uv：端点、请求结构与 Router 返回的响应。

###### Veo

- [配合 Comfy Router 使用 Veo 2.0 Generate 001](https://docs.comfy.org/development/comfy-router/models/veo/veo-2-0-generate-001/code) — 通过 Comfy Router 调用 veo/veo-2.0-generate-001：端点、请求结构以及 Router 返回的响应。
- [将 Veo 3.0 Fast Generate 001 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/veo/veo-3-0-fast-generate-001/code) — 通过 Comfy Router 调用 veo/veo-3.0-fast-generate-001：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Veo 3.0 Generate 001](https://docs.comfy.org/development/comfy-router/models/veo/veo-3-0-generate-001/code) — 通过 Comfy Router 调用 veo/veo-3.0-generate-001：端点、请求结构以及 Router 返回的响应。
- [将 Veo 3.1 Fast Generate 001 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/veo/veo-3-1-fast-generate-001/code) — 通过 Comfy Router 调用 veo/veo-3.1-fast-generate-001：endpoint、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Veo 3.1 Generate 001](https://docs.comfy.org/development/comfy-router/models/veo/veo-3-1-generate-001/code) — 通过 Comfy Router 调用 veo/veo-3.1-generate-001：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Veo 3.1 Lite Generate 001](https://docs.comfy.org/development/comfy-router/models/veo/veo-3-1-lite-generate-001/code) — 通过 Comfy Router 调用 veo/veo-3.1-lite-generate-001：端点、请求结构以及 Router 返回的响应。

###### Wan

- [通过 Comfy Router 使用 HappyHorse 1.0 I2V](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-0-i2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/happyhorse-1.0-i2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果形状
- [使用 HappyHorse 1.0 R2V 搭配 Comfy Router](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-0-r2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/happyhorse-1.0-r2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段与结果形状
- [使用 Comfy Router 调用 HappyHorse 1.0 T2V](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-0-t2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/happyhorse-1.0-t2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果结构
- [使用 Comfy Router 调用 HappyHorse 1.0 Video Edit](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-0-video-edit/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/happyhorse-1.0-video-edit 的 Python、TypeScript 和 cURL 代码片段，以及请求字段与结果结构
- [将 HappyHorse 1.1 I2V 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-1-i2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/happyhorse-1.1-i2v 的 Python、TypeScript 与 cURL 代码片段，以及请求字段和结果形状
- [通过 Comfy Router 使用 HappyHorse 1.1 R2V](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-1-r2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/happyhorse-1.1-r2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [使用 Comfy Router 调用 HappyHorse 1.1 T2V](https://docs.comfy.org/development/comfy-router/models/wan/happyhorse-1-1-t2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/happyhorse-1.1-t2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果结构
- [通过 Comfy Router 使用 Wan 2.5 I2I Preview](https://docs.comfy.org/development/comfy-router/models/wan/wan2-5-i2i-preview/code) — 通过 Comfy Router 调用 wan/wan2.5-i2i-preview：端点、请求结构以及 Router 返回的响应。
- [使用 Comfy Router 调用 Wan 2.5 I2V Preview](https://docs.comfy.org/development/comfy-router/models/wan/wan2-5-i2v-preview/code) — 通过 Comfy Router 以 HTTP 调用 wan/wan2.5-i2v-preview 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果结构
- [将 Wan 2.5 T2I Preview 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wan/wan2-5-t2i-preview/code) — 通过 Comfy Router 调用 wan/wan2.5-t2i-preview：端点、请求形状以及 Router 返回的响应。
- [使用 Comfy Router 调用 Wan 2.5 T2V Preview](https://docs.comfy.org/development/comfy-router/models/wan/wan2-5-t2v-preview/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.5-t2v-preview 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果结构
- [使用 Comfy Router 调用 Wan 2.6 I2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-6-i2v/code) — 通过 Comfy Router 以 HTTP 调用 wan/wan2.6-i2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果形状
- [通过 Comfy Router 使用 Wan 2.6 R2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-6-r2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.6-r2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果结构
- [通过 Comfy Router 使用 Wan 2.6 T2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-6-t2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.6-t2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [使用 Comfy Router 调用 Wan 2.7 I2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-7-i2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.7-i2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [使用 Comfy Router 调用 Wan 2.7 R2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-7-r2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.7-r2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [使用 Comfy Router 调用 Wan 2.7 T2V](https://docs.comfy.org/development/comfy-router/models/wan/wan2-7-t2v/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan2.7-t2v 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果结构
- [搭配 Comfy Router 使用 Wan 2.7 Video Edit](https://docs.comfy.org/development/comfy-router/models/wan/wan2-7-videoedit/code) — 用于通过 Comfy Router 以 HTTP 方式调用 wan/wan2.7-videoedit 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果结构
- [将 Wan 3.0 Video Prime 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wan/wan3-0-video-prime/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan3.0-video-prime 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和结果形状
- [通过 Comfy Router 使用 Wan 3.0 Video](https://docs.comfy.org/development/comfy-router/models/wan/wan3-0-video/code) — 通过 Comfy Router 以 HTTP 方式调用 wan/wan3.0-video 的 Python、TypeScript 和 cURL 代码片段，以及请求字段和返回结果的形状

###### WaveSpeed

- [将 Flashvsr 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wavespeed/flashvsr/code) — 通过 Comfy Router 调用 wavespeed/flashvsr：端点、请求形状以及 Router 返回的响应。
- [将 Seedvr 2 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wavespeed/seedvr2/code) — 通过 Comfy Router 调用 wavespeed/seedvr2：端点、请求形状以及 Router 返回的响应。
- [将 Ultimate Image Upscaler 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/wavespeed/ultimate-image-upscaler/code) — 通过 Comfy Router 调用 wavespeed/ultimate-image-upscaler：端点、请求形状以及 Router 返回的响应。

###### xAI

- [将 Grok Imagine Image 2.0 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-image-2-0/code) — 通过 Comfy Router 调用 xai/grok-imagine-image-2.0：端点、请求结构以及 Router 返回的响应。
- [配合 Comfy Router 使用 Grok Imagine Image Pro](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-image-pro/code) — 通过 Comfy Router 调用 xai/grok-imagine-image-pro:端点、请求形状以及 Router 返回的响应。
- [配合 Comfy Router 使用 Grok Imagine Image Quality](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-image-quality/code) — 通过 Comfy Router 调用 xai/grok-imagine-image-quality：端点、请求结构与 Router 返回的响应。
- [使用 Grok Imagine Image 与 Comfy Router](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-image/code) — 通过 Comfy Router 调用 xai/grok-imagine-image：端点、请求结构以及 Router 返回的响应。
- [结合 Comfy Router 使用 Grok Imagine Video 1.5 Preview](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-video-1-5-preview/code) — 通过 Comfy Router 调用 xai/grok-imagine-video-1.5-preview：端点、请求结构以及 Router 返回的响应。
- [将 Grok Imagine Video 1.5 与 Comfy Router 配合使用](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-video-1-5/code) — 通过 Comfy Router 调用 xai/grok-imagine-video-1.5：端点、请求结构以及 Router 返回的响应。
- [搭配 Comfy Router 使用 Grok Imagine Video](https://docs.comfy.org/development/comfy-router/models/xai/grok-imagine-video/code) — 通过 Comfy Router 调用 xai/grok-imagine-video：端点、请求形状以及 Router 返回的响应。

###### Openrouter

- [配合 Comfy Router 使用 Chat Completions](https://docs.comfy.org/development/comfy-router/models/openrouter/chat-completions/code) — 通过 Comfy Router 调用 openrouter/chat-completions：端点、请求结构以及 Router 返回的响应。

#### Comfy CLI

- [Comfy CLI 入门](https://docs.comfy.org/comfy-cli/getting-started) — 安装 comfy-cli，设置本地或云端路由，使用合作节点生成，并从终端运行工作流。
- [参考](https://docs.comfy.org/comfy-cli/reference) — Comfy CLI 完整参考，涵盖安装命令、节点管理和模型下载，用于在终端中安装和管理 ComfyUI。
- [Comfy CLI 故障排查指南](https://docs.comfy.org/comfy-cli/troubleshooting) — Comfy CLI 故障排查指南，包括使用 CLI 命令前需先安装 git 等前置条件。

#### 规范


##### Workflow JSON

- [工作流 JSON](https://docs.comfy.org/specs/workflow_json) — ComfyUI 工作流文件格式（v1.0 及旧版 v0.4）的 Workflow JSON schema，涵盖节点、连线、分组和版本字段。
- [工作流 JSON 0.4](https://docs.comfy.org/specs/workflow_json_0.4) — ComfyUI 工作流的 JSON 模式。

##### 节点定义

- [节点定义 JSON](https://docs.comfy.org/specs/nodedef_json) — ComfyUI 节点的 JSON 模式。
- [节点定义 JSON 1.0](https://docs.comfy.org/specs/nodedef_json_1_0) — ComfyUI 节点的 JSON 模式。

#### Demo Apps

- [演示应用](https://docs.comfy.org/development/samples/overview) — 从基于 Comfy API 构建的可运行演示应用开始。

### OpenAPI Specs

- [openapi-cloud](https://docs.comfy.org/openapi-cloud.yaml) — （官方索引未提供说明）
- [openapi-v2](https://docs.comfy.org/openapi-v2.yaml) — （官方索引未提供说明）
- [router-openapi](https://docs.comfy.org/router-openapi.yaml) — （官方索引未提供说明）

## 三、自定义节点 · Registry · 支持 · 社区

> 来源索引：<https://docs.comfy.org/_llms/zh.md>（英文对应 <https://docs.comfy.org/llms.txt>）

### Chinese


#### 自定义节点

- [自定义节点](https://docs.comfy.org/custom-nodes/intro) — 选择构建、扩展和发布 ComfyUI 自定义节点的正确路径。

##### 构建自定义节点

- [概述](https://docs.comfy.org/custom-nodes/overview) — 了解 ComfyUI 自定义节点的工作方式、客户端-服务器模型，以及四类节点：仅服务端、仅客户端、独立和连接式。
- [在 ComfyUI 中创建自定义节点](https://docs.comfy.org/custom-nodes/walkthrough) — 在 ComfyUI 中创建自定义节点的分步指南：定义 CATEGORY、INPUT_TYPES 和 FUNCTION，注册节点，并构建客户端 JS 扩展。
- [多语言支持](https://docs.comfy.org/custom-nodes/i18n) — 了解如何为 ComfyUI 自定义节点添加多语言支持

###### Python（后端）

- [自定义节点属性](https://docs.comfy.org/custom-nodes/backend/server_overview) — 使用 V1 模式定义 ComfyUI 自定义节点：INPUT_TYPES、RETURN_TYPES、CATEGORY、FUNCTION、执行控制属性与输入校验。
- [ComfyUI 自定义节点生命周期](https://docs.comfy.org/custom-nodes/backend/lifecycle) — 了解 ComfyUI 如何加载自定义节点：__init__.py 导入流程、NODE_CLASS_MAPPINGS、NODE_DISPLAY_NAME_MAPPINGS，以及用于客户端 JavaScript 的 WEB_DIRECTORY。
- [ComfyUI 自定义节点数据类型](https://docs.comfy.org/custom-nodes/backend/datatypes) — ComfyUI 自定义节点数据类型参考：Python 类型、张量格式（IMAGE、LATENT、MASK）、自定义类型，以及 INPUT_TYPES 中的通配符。
- [图像、潜变量和蒙版](https://docs.comfy.org/custom-nodes/backend/images_and_masks) — 掌握 ComfyUI 自定义节点后端中图像与蒙版的数据处理。学习 PyTorch 张量形状、PIL 转换和潜变量。
- [隐藏与灵活输入](https://docs.comfy.org/custom-nodes/backend/more_on_inputs) — 构建自定义节点时使用 ComfyUI 隐藏输入（UNIQUE_ID、PROMPT、EXTRA_PNGINFO、DYNPROMPT）和灵活输入，包括自定义数据类型和通配符输入。
- [延迟求值](https://docs.comfy.org/custom-nodes/backend/lazy_evaluation) — 了解 ComfyUI（v0.2.0+）中的延迟求值：如何推迟输入求值、优化显存占用，以及在自定义节点中实现 lazy: True。
- [节点扩展](https://docs.comfy.org/custom-nodes/backend/expansion) — 掌握 ComfyUI 节点扩展，在后端自定义节点中返回新的子图。了解 GraphBuilder 要求和缓存技巧。
- [数据列表](https://docs.comfy.org/custom-nodes/backend/lists) — 了解 ComfyUI 如何在内部将数据作为 Python 列表处理，包括长度为 1 的处理、批处理列表处理，以及开发自定义节点时如何使用 INPUT_IS_LIST 和 OUTPUT_IS_LIST。
- [使用 torch.Tensor](https://docs.comfy.org/custom-nodes/backend/tensors) — 学习 ComfyUI 自定义节点所需的 torch.Tensor 基础：张量形状、squeeze/unsqueeze、记号、逐元素运算，以及张量真值判断。
- [带注释的示例](https://docs.comfy.org/custom-nodes/backend/snippets) — ComfyUI 自定义节点代码示例：加载和保存图像、反转蒙版、转换蒙版形状、将蒙版用作透明层，以及创建噪声。
- [执行模型反转指南](https://docs.comfy.org/development/comfyui-server/execution_model_inversion_guide) — ComfyUI 执行模型反转指南：涵盖 monkey patching 和可选输入校验的破坏性变更，以及延迟求值和节点扩展等新功能。

###### JavaScript（UI）

- [Javascript 扩展](https://docs.comfy.org/custom-nodes/js/javascript_overview) — 了解如何通过导出 WEB_DIRECTORY、添加 .js 文件，并用 app.registerExtension 注册扩展，为 ComfyUI 添加 JavaScript 扩展。
- [ComfyUI JavaScript 钩子](https://docs.comfy.org/custom-nodes/js/javascript_hooks) — ComfyUI 前端 JavaScript 钩子参考：app.registerExtension、nodeCreated、beforeRegisterNodeDef，以及自定义界面行为的回调函数。
- [Comfy 对象](https://docs.comfy.org/custom-nodes/js/javascript_objects_and_hijacking) — ComfyUI 核心前端对象参考：LiteGraph、ComfyApp、LGraph、LLink 和 ComfyNode，包括它们的属性、函数和 widget 类型。
- [设置 API](https://docs.comfy.org/custom-nodes/js/javascript_settings) — 使用 app.registerExtension 添加、读取、写入 ComfyUI 扩展设置并响应变更，涵盖 boolean、text、number、slider、combo、color 和 image 等设置类型。
- [对话框 API](https://docs.comfy.org/custom-nodes/js/javascript_dialog) — 使用 ComfyUI 的 Dialog API 在桌面端和 Web 端提供标准化的 prompt 与 confirm 对话框，含用法示例和完整 API 参考。
- [ComfyUI Toast API](https://docs.comfy.org/custom-nodes/js/javascript_toast) — 使用 ComfyUI 的 Toast API 显示非阻塞通知，涵盖 toast 类型（success、warning、error）、alert 辅助函数以及完整 API 参考。
- [关于面板徽章](https://docs.comfy.org/custom-nodes/js/javascript_about_panel_badges) — 使用 About Panel Badges API 为 ComfyUI 关于面板添加带标签、URL 和图标的自定义徽章，并链接到文档、GitHub 或扩展资源。
- [底部面板标签页](https://docs.comfy.org/custom-nodes/js/javascript_bottom_panel_tabs) — 使用 Bottom Panel Tabs API 在 ComfyUI 底部面板添加自定义标签页，包括交互元素、React 组件和独立注册。
- [侧边栏标签页](https://docs.comfy.org/custom-nodes/js/javascript_sidebar_tabs) — 掌握 ComfyUI Extension API，构建自定义 JavaScript 侧边栏标签页。查看 React 组件和动态内容更新的代码示例。
- [选择工具箱](https://docs.comfy.org/custom-nodes/js/javascript_selection_toolbox) — 使用 getSelectionToolboxCommands，为选中的节点、组和画布项在 ComfyUI 选择工具箱中添加自定义操作命令。
- [命令与快捷键绑定](https://docs.comfy.org/custom-nodes/js/javascript_commands_keybindings) — 掌握 ComfyUI 命令与快捷键绑定，为扩展注册自定义操作和快捷键。
- [顶部菜单栏](https://docs.comfy.org/custom-nodes/js/javascript_topbar_menu) — 向 ComfyUI 顶部菜单栏添加自定义命令，包括加入现有菜单、创建子菜单，以及将同一命令放在多个位置。
- [子图](https://docs.comfy.org/custom-nodes/js/subgraphs) — 在 ComfyUI 扩展中使用子图：节点 ID、图遍历、事件、控件提升和清理。
- [带注释的示例](https://docs.comfy.org/custom-nodes/js/javascript_examples) — 浏览 ComfyUI JavaScript 示例，构建自定义节点和 UI 扩展。获取实用代码片段，开始创建稳健的 Web 界面。

###### 迁移指南

- [V3 迁移指南](https://docs.comfy.org/custom-nodes/v3_migration) — 如何将现有的 V1 节点迁移到新的 V3 架构。
- [上下文菜单迁移指南](https://docs.comfy.org/custom-nodes/js/context-menu-migration) — 从已弃用的 monkey-patching 迁移到 ComfyUI 上下文菜单 API。涵盖画布菜单和节点菜单迁移、条件项、子菜单，以及如何识别和排查旧 API 用法。
- [节点替换](https://docs.comfy.org/custom-nodes/backend/node-replacement) — 注册节点替换以帮助用户从已弃用的节点迁移

##### 打包与发布

- [为你的 ComfyUI 自定义节点添加节点文档](https://docs.comfy.org/custom-nodes/help_page) — 如何为内置节点创建帮助文档
- [Workflow templates](https://docs.comfy.org/custom-nodes/workflow_templates) — （官方索引未提供说明）
- [子图蓝图](https://docs.comfy.org/custom-nodes/subgraph_blueprints) — 了解如何为 ComfyUI 自定义节点创建可复用的子图蓝图。按照本指南公开预构建节点组。
- [Comfy Registry：发布与版本管理自定义节点](https://docs.comfy.org/registry/overview) — 了解 Comfy Registry 是什么、为何用于节点版本管理和安全，以及如何开始将自定义节点发布到 ComfyUI-Manager。
- [发布节点](https://docs.comfy.org/registry/publishing) — 了解如何创建 Comfy Registry 账户、创建 publisher、生成 API 密钥、添加元数据，以及通过 Comfy CLI 或 GitHub Actions 发布自定义节点。
- [认领我的节点](https://docs.comfy.org/registry/claim-my-node) — 了解如何认领已迁移到 Comfy Registry 的未认领自定义节点，包括 publisher 设置和 GitHub 验证步骤。
- [标准](https://docs.comfy.org/registry/standards) — 发布到注册表（Registry）的安全和其他标准
- [自定义节点 CI/CD](https://docs.comfy.org/registry/cicd) — 在发布前使用 Comfy-Action 在 GitHub Actions 上运行工作流，测试 ComfyUI 自定义节点，并在 CI/CD Dashboard 中查看结果。
- [pyproject.toml](https://docs.comfy.org/registry/specifications) — ComfyUI 自定义节点 pyproject.toml 完整规范：[project] 和 [tool.comfy] 部分、必填字段、版本管理，以及完整示例。
- [API 概览](https://docs.comfy.org/registry/api-reference/overview) — 了解 ComfyUI 自定义节点 Registry API：publisher、user、节点与节点版本的数据模型，以及列出和安装节点的常用端点。

###### Registry API 参考

- [Get information about the calling user.](https://docs.comfy.org/registry/api-reference/registry/get-information-about-the-calling-user) — （官方索引未提供说明）
- [Retrieve all publishers for a given user](https://docs.comfy.org/registry/api-reference/registry/retrieve-all-publishers-for-a-given-user) — （官方索引未提供说明）
- [Validate if a publisher username is available](https://docs.comfy.org/registry/api-reference/registry/validate-if-a-publisher-username-is-available) — Checks if the publisher username is already taken.
- [Create a new publisher](https://docs.comfy.org/registry/api-reference/registry/create-a-new-publisher) — （官方索引未提供说明）
- [Retrieve all publishers](https://docs.comfy.org/registry/api-reference/registry/retrieve-all-publishers) — （官方索引未提供说明）
- [Retrieve a publisher by ID](https://docs.comfy.org/registry/api-reference/registry/retrieve-a-publisher-by-id) — （官方索引未提供说明）
- [Update a publisher](https://docs.comfy.org/registry/api-reference/registry/update-a-publisher) — （官方索引未提供说明）
- [Delete a publisher](https://docs.comfy.org/registry/api-reference/registry/delete-a-publisher) — （官方索引未提供说明）
- [Retrieve permissions the user has for a given publisher](https://docs.comfy.org/registry/api-reference/registry/retrieve-permissions-the-user-has-for-a-given-publisher) — （官方索引未提供说明）
- [Create a new personal access token](https://docs.comfy.org/registry/api-reference/registry/create-a-new-personal-access-token) — （官方索引未提供说明）
- [Delete a specific personal access token](https://docs.comfy.org/registry/api-reference/registry/delete-a-specific-personal-access-token) — （官方索引未提供说明）
- [Retrieve all nodes](https://docs.comfy.org/registry/api-reference/registry/retrieve-all-nodes) — （官方索引未提供说明）
- [Create a new custom node](https://docs.comfy.org/registry/api-reference/registry/create-a-new-custom-node) — （官方索引未提供说明）
- [Update a specific node](https://docs.comfy.org/registry/api-reference/registry/update-a-specific-node) — （官方索引未提供说明）
- [Delete a specific node](https://docs.comfy.org/registry/api-reference/registry/delete-a-specific-node) — （官方索引未提供说明）
- [Claim nodeId into publisherId for the authenticated publisher](https://docs.comfy.org/registry/api-reference/registry/claim-nodeid-into-publisherid-for-the-authenticated-publisher) — This endpoint allows a publisher to claim an unclaimed node that they own the repo, which is identified by the nodeId. The unclaimed node's repository must be owned by the authenticated user.
- [Publish a new version of a node](https://docs.comfy.org/registry/api-reference/registry/publish-a-new-version-of-a-node) — （官方索引未提供说明）
- [Update changelog and deprecation status of a node version](https://docs.comfy.org/registry/api-reference/registry/update-changelog-and-deprecation-status-of-a-node-version) — Update only the changelog and deprecated status of a specific version of a node.
- [Unpublish (delete) a specific version of a node](https://docs.comfy.org/registry/api-reference/registry/unpublish-delete-a-specific-version-of-a-node) — （官方索引未提供说明）
- [Retrieves a list of nodes](https://docs.comfy.org/registry/api-reference/registry/retrieves-a-list-of-nodes) — Returns a paginated list of nodes across all publishers.
- [Retrieve a specific node by ID](https://docs.comfy.org/registry/api-reference/registry/retrieve-a-specific-node-by-id) — Returns the details of a specific node.
- [Returns a node version to be installed.](https://docs.comfy.org/registry/api-reference/registry/returns-a-node-version-to-be-installed) — Retrieves the node data for installation, either the latest or a specific version.
- [Add review to a specific version of a node](https://docs.comfy.org/registry/api-reference/registry/add-review-to-a-specific-version-of-a-node) — （官方索引未提供说明）
- [Create Node Translations](https://docs.comfy.org/registry/api-reference/registry/create-node-translations) — （官方索引未提供说明）
- [List all versions of a node](https://docs.comfy.org/registry/api-reference/registry/list-all-versions-of-a-node) — （官方索引未提供说明）
- [Retrieve a specific version of a node](https://docs.comfy.org/registry/api-reference/registry/retrieve-a-specific-version-of-a-node) — （官方索引未提供说明）
- [Retrieve multiple node versions in a single request](https://docs.comfy.org/registry/api-reference/registry/retrieve-multiple-node-versions-in-a-single-request) — Retrieves up to 1000 node versions in one request. Requests carrying more than 1000 identifiers are rejected in full with a 400 — there is no partial result — so clients with more than 1000 installed packs must split the list into batches of at most 1000 and merge the responses. Each node_id and ver…
- [List all node versions given some filters.](https://docs.comfy.org/registry/api-reference/registry/list-all-node-versions-given-some-filters) — （官方索引未提供说明）
- [list all comfy-nodes](https://docs.comfy.org/registry/api-reference/registry/list-all-comfy-nodes) — （官方索引未提供说明）
- [Retrieve a node by ComfyUI node name](https://docs.comfy.org/registry/api-reference/registry/retrieve-a-node-by-comfyui-node-name) — Returns the node that contains a ComfyUI node with the specified name
- [create comfy-nodes for certain node](https://docs.comfy.org/registry/api-reference/registry/create-comfy-nodes-for-certain-node) — （官方索引未提供说明）
- [list comfy-nodes for node version](https://docs.comfy.org/registry/api-reference/registry/list-comfy-nodes-for-node-version) — （官方索引未提供说明）
- [get specify comfy-node based on its id](https://docs.comfy.org/registry/api-reference/registry/get-specify-comfy-node-based-on-its-id) — （官方索引未提供说明）
- [Update a specific comfy-node](https://docs.comfy.org/registry/api-reference/registry/update-a-specific-comfy-node) — （官方索引未提供说明）
- [Get server feature flags](https://docs.comfy.org/registry/api-reference/registry/get-server-feature-flags) — Returns the server's feature capabilities
- [Get release notes](https://docs.comfy.org/registry/api-reference/releases/get-release-notes) — Fetch release notes from Strapi with caching

#### 支持

- [联系 ComfyUI 支持](https://docs.comfy.org/support/contact-support) — 获取有关 ComfyUI、Comfy Cloud 和 Comfy桌面版的帮助。请使用 support.comfy.org，或在对应的 GitHub 仓库中反馈错误。
- [数据保留](https://docs.comfy.org/support/data-retention) — Comfy 如何保留和管理客户数据

##### 账户管理

- [创建 Comfy 账户](https://docs.comfy.org/account/create-account) — 了解如何创建新的 Comfy 账户以访问 ComfyUI 的所有功能和服务。
- [登录您的 Comfy 账户](https://docs.comfy.org/account/login) — 访问您的 Comfy 账户以使用 ComfyUI 的所有平台功能和服务。
- [删除您的 Comfy 账户](https://docs.comfy.org/account/delete-account) — 了解如何永久删除您的 Comfy 账户和 ComfyUI 相关数据。

##### 账单支持


###### 订阅

- [订阅 Comfy Cloud](https://docs.comfy.org/support/subscription/subscribing) — 从“订阅和定价”订阅 Comfy Cloud。选择“个人使用”或“团队使用”，选择月度或年度计费，然后确认付款即可运行工作流。
- [管理 Comfy Cloud 账单与发票](https://docs.comfy.org/support/subscription/managing) — 在 Comfy Cloud 打开管理订阅可进入计划与积分。账单与发票会打开 Stripe 门户，用于管理支付方式和发票。使用更改套餐来切换套餐。
- [更改 Comfy Cloud 套餐](https://docs.comfy.org/support/subscription/changing-plan) — 升级或降级 Comfy Cloud 套餐。在个人与团队之间切换，选择月付或年付，并了解变更何时生效。
- [取消您的 Comfy Cloud 订阅](https://docs.comfy.org/support/subscription/canceling) — 从“计划与积分”中取消 Comfy Cloud 套餐。打开更多选项，选择“取消套餐”，然后确认。在当前计费周期结束前仍可继续访问。

###### 支付

- [Comfy Cloud 接受的付款方式](https://docs.comfy.org/support/payment/accepted-payment-methods) — 使用主要银行卡、Google Pay 或 Link 为 Comfy Cloud 付款。支付宝支持以美元支付 Comfy Cloud 和 API 积分。微信支付支持以美元支付 API 积分。
- [编辑 Comfy Cloud 付款信息](https://docs.comfy.org/support/payment/editing-payment-information) — 从计划与积分更新 Comfy Cloud 的付款方式或账单地址。账单与发票会打开 Stripe 账单门户，在那里编辑详情。
- [查看 Comfy Cloud 付款历史记录](https://docs.comfy.org/support/payment/payment-history) — 在 Comfy Cloud 打开计划与积分，再点账单与发票。发票列表和 PDF 下载在 Stripe 账单门户里。
- [修复失败的 Comfy Cloud 付款](https://docs.comfy.org/support/payment/unsuccessful-payments) — 如果 Comfy Cloud 付款失败，请通过“计划与积分”或“付款失败”横幅更新您的付款方式，以避免订阅暂停。
- [Comfy Cloud 付款货币](https://docs.comfy.org/support/payment/payment-currency) — Comfy Cloud 价格以 USD 列出。结账时选择 USD 即可使用支付宝。微信支付仅支持以 USD 购买本地 API 积分。您的银行可能会转换其他货币。
- [Comfy Cloud 发票信息](https://docs.comfy.org/support/payment/invoice-information) — Comfy Cloud 发票使用您在结账时输入的账单详情。更新仅适用于未来的发票，不适用于已开具的发票。

##### 故障排除

- [如何排查和解决 ComfyUI 中出现的错误](https://docs.comfy.org/troubleshooting/overview) — ComfyUI 故障排除指南：先排除自定义节点，修复常见核心问题，并提交包含正确细节的错误报告。
- [如何排查和解决 ComfyUI 中模型相关的问题](https://docs.comfy.org/troubleshooting/model-issues) — 故障排除模型相关问题，包括架构不匹配、缺少模型和加载错误
- [自定义节点问题排查](https://docs.comfy.org/troubleshooting/custom-node-issues) — 修复 ComfyUI 自定义节点问题：用 --disable-all-custom-nodes 禁用所有自定义节点，然后二分排查以隔离、修复或移除出问题的节点。

##### 社区

- [贡献指南](https://docs.comfy.org/community/contributing) — 了解如何为 Comfy 做贡献：浏览 GitHub 组织仓库、分享工作流，或开发自定义节点。
- [社区链接](https://docs.comfy.org/community/links) — 通过各种平台与 ComfyUI 社区联系

### OpenAPI Specs


## 四、内置节点参考（built-in-nodes，按官方分类）

> 来源索引：<https://docs.comfy.org/_llms/zh/tab-4ef7ed40/group.md>、`.../group/model.md`、`.../group/partner.md`

### 节点


#### 3D

- [BuildPoseFile](https://docs.comfy.org/built-in-nodes/BuildPoseFile) — 此节点根据姿态数据构建一个可直接保存的 3D 动画文件。
- [CreateCameraInfo](https://docs.comfy.org/built-in-nodes/CreateCameraInfo) — 创建相机信息节点用于构建3D渲染所需的相机信息结构。
- [Get3DComponents](https://docs.comfy.org/built-in-nodes/Get3DComponents) — Get3DComponents 会将 3D 模型文件（GLB、GLTF、OBJ 或 STL）解析为可编辑网格，可供 decimate、remesh、UV unwrap 和 bake 等网格处理节点使用。
- [Load3D](https://docs.comfy.org/built-in-nodes/Load3D) — 以下是您要求的 ComfyUI 节点文档的简体中文翻译：
- [Load3DAdvanced](https://docs.comfy.org/built-in-nodes/Load3DAdvanced) — Load 3D (Advanced) 节点从 ComfyUI 的 input/3d 目录加载 3D 模型文件，并提供模型数据以及从 3D 查看器视口状态中捕获的模型摆放和相机信息。
- [Load3DAnimation](https://docs.comfy.org/built-in-nodes/Load3DAnimation) — markdown
- [MeshToFile3D](https://docs.comfy.org/built-in-nodes/MeshToFile3D) — 此节点将网格序列化为一个 GLB 文件对象，该对象可传递给 Save 3D 或 Preview 3D 节点。
- [Preview3D](https://docs.comfy.org/built-in-nodes/Preview3D) — Preview3D 节点主要用于预览 3D 模型输出。
- [Preview3DAdvanced](https://docs.comfy.org/built-in-nodes/Preview3DAdvanced) — 此节点在 UI 中显示 3D 模型预览，而无需将文件保存到 ComfyUI 输出目录。
- [Preview3DAnimation](https://docs.comfy.org/built-in-nodes/Preview3DAnimation) — Preview3DAnimation 节点主要用于预览 3D 模型输出。
- [PreviewGaussianSplat](https://docs.comfy.org/built-in-nodes/PreviewGaussianSplat) — PreviewGaussianSplat 节点在预览窗口中显示 3D 高斯泼溅文件，而不会将其保存到 ComfyUI 输出目录。
- [PreviewPointCloud](https://docs.comfy.org/built-in-nodes/PreviewPointCloud) — 预览点云节点允许您在 ComfyUI 界面中查看 3D 点云文件，而无需将其保存到 ComfyUI 输出目录。
- [Save3DAdvanced](https://docs.comfy.org/built-in-nodes/Save3DAdvanced) — 将 3D 模型保存到 ComfyUI 输出目录中的文件，并生成已保存场景的预览。
- [SaveGaussianSplat](https://docs.comfy.org/built-in-nodes/SaveGaussianSplat) — 此节点将高斯泼溅 3D 文件保存到输出目录。
- [SaveGLB](https://docs.comfy.org/built-in-nodes/SaveGLB) — SaveGLB 节点将 3D 网格数据或 3D 文件输入保存到输出目录。
- [SavePointCloud](https://docs.comfy.org/built-in-nodes/SavePointCloud) — 保存点云节点将3D点云文件保存到输出目录，并可选择为3D查看器提供预览数据。
- [VoxelToMesh](https://docs.comfy.org/built-in-nodes/VoxelToMesh) — VoxelToMesh 节点通过在指定阈值处提取表面，将 3D 体素数据转换为网格几何体。
- [VoxelToMeshBasic](https://docs.comfy.org/built-in-nodes/VoxelToMeshBasic) — VoxelToMeshBasic 节点将 3D 体素数据转换为网格几何体。

##### Mesh

- [DecimateMesh](https://docs.comfy.org/built-in-nodes/DecimateMesh) — 使用 QEM（二次误差度量）简化将 3D 网格简化到目标面数，并在当前计算设备上运行计算。
- [FillHoles](https://docs.comfy.org/built-in-nodes/FillHoles) — 此节点通过检测开放边界边并创建新面来闭合它们，从而填充 3D 网格中的孔洞。
- [GetMeshInfo](https://docs.comfy.org/built-in-nodes/GetMeshInfo) — Get Mesh Info 用于报告网格中的顶点数和面数，以及它所包含的属性（例如 UV、顶点颜色、法线、纹理）。
- [MergeMeshes](https://docs.comfy.org/built-in-nodes/MergeMeshes) — MergeMeshes 通过堆叠多个网格输入的顶点、面、UV 坐标和顶点颜色，并偏移面索引，使所有部分正确连接成一个连续网格，从而将它们合并为单个网格。
- [MeshSmoothNormals](https://docs.comfy.org/built-in-nodes/MeshSmoothNormals) — 为网格计算平滑的逐顶点法线并将其附加到网格上。
- [PaintMesh](https://docs.comfy.org/built-in-nodes/PaintMesh) — PaintMesh 接收一个 3D 网格和一个体素颜色场。
- [RemeshMesh](https://docs.comfy.org/built-in-nodes/RemeshMesh) — Remesh Mesh 会围绕原始表面采样窄带距离场，并使用 Dual Contouring 提取，从而以干净、均匀的细分重建网格。
- [RenderMesh](https://docs.comfy.org/built-in-nodes/RenderMesh) — 此节点通过光线投射单个视图将 3D 网格渲染为 2D 图像。
- [RotateMesh](https://docs.comfy.org/built-in-nodes/RotateMesh) — 使用欧拉 XYZ 角度（以度为单位）或四元数围绕世界轴旋转 3D 网格。
- [WeldVertices](https://docs.comfy.org/built-in-nodes/WeldVertices) — Weld Vertices 节点会合并 3D 网格中的重合顶点，使原本各自拥有独立角点的面最终共享相同的顶点。

##### Splat

- [File3DToSplat](https://docs.comfy.org/built-in-nodes/File3DToSplat) — 此节点将包含高斯泼溅数据的 3D 文件转换为可在节点图中使用的高斯泼溅格式。
- [GetSplatCount](https://docs.comfy.org/built-in-nodes/GetSplatCount) — 获取 Splat 计数节点返回 splat 批次中的 splat（高斯点）总数，该计数是对批次中所有项目求和得出的。
- [MergeSplat](https://docs.comfy.org/built-in-nodes/MergeSplat) — 合并高斯泼溅节点通过连接多个高斯泼溅模型的数据，将其合并为单个泼溅。
- [RenderSplat](https://docs.comfy.org/built-in-nodes/RenderSplat) — 使用各向异性EWA光栅化器将高斯泼溅渲染为图像，该光栅化器采用定向椭圆泼溅、抗锯齿和从前到后的深度排序渲染。
- [SplatToFile3D](https://docs.comfy.org/built-in-nodes/SplatToFile3D) — SplatToFile3D 节点将高斯溅射转换为 File3D 对象，该对象可与 Save 或 Preview 3D 节点一起使用。
- [SplatToMesh](https://docs.comfy.org/built-in-nodes/SplatToMesh) — 此节点将 3D 高斯泼溅转换为彩色网格表面。
- [TransformSplat](https://docs.comfy.org/built-in-nodes/TransformSplat) — Transform Splat 节点可对高斯泼溅（gaussian splat）应用平移、旋转和缩放变换。

##### Texturing

- [ApplyTextureToMesh](https://docs.comfy.org/built-in-nodes/ApplyTextureToMesh) — 此节点将烘焙后的纹理图像附加到网格的 UV 布局上，以便它们可以通过 SaveGLB 节点与网格一起导出。
- [BakeAmbientOcclusion](https://docs.comfy.org/built-in-nodes/BakeAmbientOcclusion) — 将高模网格的环境光遮蔽贴图烘焙到低模网格的 UV 布局中。
- [BakeNormalMapFromMesh](https://docs.comfy.org/built-in-nodes/BakeNormalMapFromMesh) — 此节点将高多边形网格的切线空间法线贴图烘焙到低多边形网格的 UV 布局上，以捕捉在简化过程中丢失的表面细节。
- [BakeTextureFromVoxel](https://docs.comfy.org/built-in-nodes/BakeTextureFromVoxel) — 此节点使用网格现有的 UV 布局将 PBR 纹理烘焙到 3D 网格上。
- [MeshTextureToImage](https://docs.comfy.org/built-in-nodes/MeshTextureToImage) — 此节点提取网格的烘焙纹理，并将其作为独立图像返回：基础颜色、金属度、粗糙度、环境光遮蔽和法线贴图。
- [RenderUVAtlas](https://docs.comfy.org/built-in-nodes/RenderUVAtlas) — 将网格的 UV 布局渲染为图像。
- [UnwrapMesh](https://docs.comfy.org/built-in-nodes/UnwrapMesh) — 为 3D 网格生成 UV 图集。

#### API Node


##### Image


###### BFL

- [FluxProCannyNode](https://docs.comfy.org/built-in-nodes/FluxProCannyNode) — 使用控制图像（canny）生成图像。
- [FluxProDepthNode](https://docs.comfy.org/built-in-nodes/FluxProDepthNode) — 此节点使用深度控制图像作为引导来生成图像。
- [FluxProImageNode](https://docs.comfy.org/built-in-nodes/FluxProImageNode) — 根据提示词和分辨率同步生成图像。
- [Flux 1.1 [pro] Ultra Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/bfl/flux-1-1-pro-ultra-image) — 使用 Black Forest Labs 的高分辨率图像生成 API 创建图像

###### Bytedance

- [ByteDanceImageEditNode](https://docs.comfy.org/built-in-nodes/ByteDanceImageEditNode) — ByteDance Image Edit 节点允许你通过 API 使用 ByteDance 的 AI 模型来修改图像。

###### Ideogram

- [Ideogram V1 - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/ideogram/ideogram-v1) — 使用Ideogram API创建精准文字渲染图像的节点
- [Ideogram V2 - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/ideogram/ideogram-v2) — 使用Ideogram V2 API创建高质量图像和文字渲染的节点

###### Luma

- [Luma Image to Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/luma/luma-image-to-image) — 使用Luma AI修改图像的节点
- [Luma Reference - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/luma/luma-reference) — 为Luma图像生成提供参考图像的辅助节点
- [Luma Text to Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/luma/luma-text-to-image) — 使用Luma AI将文本描述转换为高质量图像的节点

###### OpenAI

- [OpenAI DALL·E 2 - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/openai/openai-dalle2) — 使用OpenAI的DALL·E 2模型生成图像的节点
- [OpenAI DALL·E 3 - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/openai/openai-dalle3) — 使用OpenAI的DALL·E 3模型生成高质量图像的节点
- [OpenAI GPT Image 1 - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/openai/openai-gpt-image1) — 使用OpenAI的GPT-4 Vision模型生成图像的节点

###### Recraft

- [Recraft Color RGB - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-color-rgb) — 为Recraft图像生成定义颜色控制的辅助节点
- [Recraft Controls - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-controls) — 为Recraft图像生成提供高级控制参数的节点
- [Recraft Creative Upscale - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-creative-upscale) — 使用AI技术创意增强图像细节和分辨率的 Recraft 合作伙伴节点
- [Recraft Crisp Upscale - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-crisp-upscale) — 使用AI技术增加图像清晰度和分辨率的 Recraft 合作伙伴节点
- [Recraft Image Inpainting - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-image-inpainting) — 使用Recraft API选择性地修改图像区域
- [Recraft Image to Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-image-to-image) — 通过文本描述和参考图像生成新图像的 Recraft 合作伙伴节点
- [Recraft Remove Background - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-remove-background) — 自动移除图像背景并生成透明Alpha通道的 Recraft 合作伙伴节点
- [Recraft Replace Background - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-replace-background) — 自动识别前景主体并替换背景的 Recraft 合作伙伴节点
- [Recraft Style - Digital Illustration - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-style-digital-illustration) — 为Recraft图像生成设置数字插画风格的辅助节点
- [Recraft Style - Logo Raster - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-style-logo-raster) — 为Recraft图像生成设置Logo栅格风格的辅助节点
- [Recraft Style - Realistic Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-style-realistic-image) — 为Recraft图像生成设置真实照片风格的辅助节点
- [Recraft Text to Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-text-to-image) — 通过文本描述生成高质量图像的 Recraft 合作伙伴节点
- [Recraft Text to Vector - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-text-to-vector) — 通过文本描述生成可缩放矢量图像的 Recraft 合作伙伴节点
- [Recraft Vectorize Image - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/recraft-vectorize-image) — 将栅格图像转换为矢量SVG格式的 Recraft 合作伙伴节点
- [Save SVG - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/image/recraft/save-svg) — 将SVG矢量图形保存到文件的实用节点

##### Video


###### Google

- [Google Veo2 Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/google/google-veo2-video) — 使用Google的Veo2技术通过文本描述生成视频的节点

###### Kling

- [Kling Image to Video (Camera Control) - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-camera-control-i2v) — 使用摄像机控制功能的Kling图像到视频转换节点
- [Kling Text to Video (Camera Control) - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-camera-control-t2v) — 使用摄像机控制功能的Kling文本到视频生成节点
- [Kling Camera Controls - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-camera-controls) — 为Kling视频生成提供摄像机控制参数的节点
- [Kling Image to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-image-to-video) — 使用Kling的AI技术将静态图像转换为动态视频的节点
- [Kling Start-End Frame to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-start-end-frame-to-video) — 使用Kling的AI技术创建从起始帧到结束帧平滑过渡的视频
- [Kling Text to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/kwai_vgi/kling-text-to-video) — 使用Kling的AI技术将文本描述转换为视频的节点

###### Luma

- [Luma Concepts - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/luma/luma-concepts) — 为Luma图像生成提供概念引导的辅助节点
- [Luma Image to Video - ComfyUI 原生合作伙伴节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/luma/luma-image-to-video) — 使用Luma AI将静态图像转换为动态视频的节点
- [Luma Text to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/luma/luma-text-to-video) — 使用Luma AI将文本描述转换为视频的节点

###### MiniMax

- [MiniMax Image to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/minimax/minimax-image-to-video) — 使用 MiniMax AI将静态图像转换为动态视频的节点
- [MiniMax Text to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/minimax/minimax-text-to-video) — 使用 MiniMax AI将文本描述转换为视频的节点

###### Pika

- [Pika 2.2 Image to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pika/pika-image-to-video) — 使用Pika的AI技术将静态图像转换为动态视频的节点
- [Pika 2.2 Scenes - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pika/pika-scenes) — 使用Pika的AI技术基于多张图像创建连贯场景视频的节点
- [Pika 2.2 Text to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pika/pika-text-to-video) — 使用Pika的AI技术将文本描述转换为视频的节点
- [Pikadditions](https://docs.comfy.org/built-in-nodes/Pikadditions) — Pikadditions 节点允许您将任意物体或图像添加到视频中。
- [Pikaffects](https://docs.comfy.org/built-in-nodes/Pikaffects) — The Pikaffects node generates videos with various visual effects applied to an input image.
- [PikaImageToVideoNode2_2](https://docs.comfy.org/built-in-nodes/PikaImageToVideoNode2_2) — Pika 图像转视频节点将图像和文本提示发送至 Pika API 2.2 版本以生成视频。
- [PikaScenesV2_2](https://docs.comfy.org/built-in-nodes/PikaScenesV2_2) — PikaScenes v2.2 节点可组合多张图像，生成一段融合所有输入图像中物体的视频。
- [PikaStartEndFrameNode2_2](https://docs.comfy.org/built-in-nodes/PikaStartEndFrameNode2_2) — PikaFrames v2.2 节点通过组合首帧和尾帧来生成视频。
- [Pikaswaps](https://docs.comfy.org/built-in-nodes/Pikaswaps) — Pika Swaps 节点可将视频中的物体或区域替换为新图像。
- [PikaTextToVideoNode2_2](https://docs.comfy.org/built-in-nodes/PikaTextToVideoNode2_2) — Pika Text2Video v2.2 节点将文本提示发送至 Pika API 2.2 版本以生成视频。

###### PixVerse

- [PixVerse Image to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pixverse/pixverse-image-to-video) — 使用PixVerse的AI技术将静态图像转换为动态视频的节点
- [Pixverse Template - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pixverse/pixverse-template) — 为Pixverse视频生成提供预设模板的辅助节点
- [PixVerse Text to Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pixverse/pixverse-text-to-video) — 使用PixVerse的AI技术将文本描述转换为视频的节点
- [PixVerse Transition Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/partner-node/video/pixverse/pixverse-transition-video) — 使用 PixVerse 的AI技术创建从起始帧到结束帧平滑过渡的视频

#### Audio

- [AudioAdjustVolume](https://docs.comfy.org/built-in-nodes/AudioAdjustVolume) — AudioAdjustVolume 节点通过以分贝（dB）为单位调整音量来修改音频的响度。
- [AudioConcat](https://docs.comfy.org/built-in-nodes/AudioConcat) — AudioConcat 节点通过拼接两个音频输入来合并它们。
- [AudioEqualizer3Band](https://docs.comfy.org/built-in-nodes/AudioEqualizer3Band) — 音频均衡器（3 频段）节点允许您调整音频波形的低频、中频和高频。
- [AudioMerge](https://docs.comfy.org/built-in-nodes/AudioMerge) — AudioMerge 节点通过叠加波形来合并两条音轨。
- [EmptyAudio](https://docs.comfy.org/built-in-nodes/EmptyAudio) — 此文档由 AI 生成。
- [JoinAudioChannels](https://docs.comfy.org/built-in-nodes/JoinAudioChannels) — 合并音频通道节点将两个独立的单声道音频输入合并为单个立体声音频输出。
- [LoadAudio](https://docs.comfy.org/built-in-nodes/LoadAudio) — LoadAudio 节点从输入目录加载音频文件，并将其转换为 ComfyUI 中其他音频节点可处理的格式。
- [PreviewAudio](https://docs.comfy.org/built-in-nodes/PreviewAudio) — Preview Audio 节点让你可以直接在 ComfyUI 中试听音频，而无需将其保存到输出目录。
- [RecordAudio](https://docs.comfy.org/built-in-nodes/RecordAudio) — RecordAudio 节点用于加载通过音频录制界面录制或选择的音频文件。
- [SaveAudio](https://docs.comfy.org/built-in-nodes/SaveAudio) — 此节点将音频数据保存为 FLAC 格式文件。
- [SaveAudioAdvanced](https://docs.comfy.org/built-in-nodes/SaveAudioAdvanced) — 将输入音频保存到你的 ComfyUI 输出目录。
- [SaveAudioMP3](https://docs.comfy.org/built-in-nodes/SaveAudioMP3) — SaveAudioMP3 节点将音频数据保存为 MP3 文件。
- [SaveAudioOpus](https://docs.comfy.org/built-in-nodes/SaveAudioOpus) — SaveAudioOpus 节点将音频数据保存为 Opus 格式文件，让您可以选择编码质量（比特率）以及导出文件的文件名前缀。
- [SplitAudioChannels](https://docs.comfy.org/built-in-nodes/SplitAudioChannels) — SplitAudioChannels 节点可将立体声音频分离为独立的左声道和右声道。
- [TrimAudioDuration](https://docs.comfy.org/built-in-nodes/TrimAudioDuration) — 此文档由 AI 生成。

#### Experimental

- [DifferentialDiffusion](https://docs.comfy.org/built-in-nodes/DifferentialDiffusion) — 差分扩散节点通过基于时间步长阈值应用二值掩码来修改去噪过程。
- [FluxKVCache](https://docs.comfy.org/built-in-nodes/FluxKVCache) — Flux KV Cache节点为Flux系列模型启用了键值（KV）缓存优化。
- [FreSca](https://docs.comfy.org/built-in-nodes/FreSca) — FreSca 节点在采样过程中对引导信号应用频率相关的缩放。
- [LatentBlend](https://docs.comfy.org/built-in-nodes/LatentBlend) — LatentBlend 节点通过使用指定的混合因子将两个潜在样本混合在一起。
- [LoraSave](https://docs.comfy.org/built-in-nodes/LoraSave) — LoraSave 节点可从模型差异中提取并保存 LoRA（低秩适应）文件。
- [Mahiro](https://docs.comfy.org/built-in-nodes/Mahiro) — Mahiro 节点修改了引导函数，使其更侧重于正向提示的方向，而非正向与负向提示之间的差异。
- [PerpNeg](https://docs.comfy.org/built-in-nodes/PerpNeg) — PerpNeg 节点对模型的采样过程应用垂直负向引导。
- [PerpNegGuider](https://docs.comfy.org/built-in-nodes/PerpNegGuider) — PerpNegGuider 节点创建了一个引导系统，用于通过垂直负向条件控制图像生成。
- [SamplerEulerCFGpp](https://docs.comfy.org/built-in-nodes/SamplerEulerCFGpp) — SamplerEulerCFGpp 节点提供了一种用于生成输出的 Euler CFG++ 采样方法。
- [SelfAttentionGuidance](https://docs.comfy.org/built-in-nodes/SelfAttentionGuidance) — The Self-Attention Guidance node applies guidance to diffusion models by modifying the attention mechanism during the sampling process.
- [TorchCompileModel](https://docs.comfy.org/built-in-nodes/TorchCompileModel) — TorchCompileModel 节点对模型应用 PyTorch 编译以优化其性能。

##### Attention Experiments

- [CLIPAttentionMultiply](https://docs.comfy.org/built-in-nodes/CLIPAttentionMultiply) — CLIPAttentionMultiply节点允许您通过将乘法因子应用于自注意力层的不同组件来调整CLIP模型中的注意力机制。
- [UNetCrossAttentionMultiply](https://docs.comfy.org/built-in-nodes/UNetCrossAttentionMultiply) — UNetCrossAttentionMultiply 节点对 UNet 模型中的交叉注意力机制应用乘法因子。
- [UNetSelfAttentionMultiply](https://docs.comfy.org/built-in-nodes/UNetSelfAttentionMultiply) — UNetSelfAttentionMultiply 节点对 UNet 模型中的自注意力机制的查询、键、值和输出分量应用乘法因子。
- [UNetTemporalAttentionMultiply](https://docs.comfy.org/built-in-nodes/UNetTemporalAttentionMultiply) — UNetTemporalAttentionMultiply 节点对时序 UNet 模型中的不同注意力机制应用乘法因子。

##### Stable Cascade

- [StableCascade_SuperResolutionControlnet](https://docs.comfy.org/built-in-nodes/StableCascade_SuperResolutionControlnet) — 此节点属于实验性 Stable Cascade 组。

#### Text

- [AddTextPrefix](https://docs.comfy.org/built-in-nodes/AddTextPrefix) — 添加文本前缀节点通过将指定字符串添加到每个输入文本的开头来修改文本。
- [AddTextSuffix](https://docs.comfy.org/built-in-nodes/AddTextSuffix) — 此节点将指定的后缀附加到输入文本字符串的末尾。
- [BuildJsonPromptIdeogram](https://docs.comfy.org/built-in-nodes/BuildJsonPromptIdeogram) — 此节点构建一个结构化的 JSON 提示词，专为 Ideogram 4 图像生成模型格式化。
- [CaseConverter](https://docs.comfy.org/built-in-nodes/CaseConverter) — 大小写转换节点用于将文本字符串转换为不同的大小写格式。
- [ConvertArrayToString](https://docs.comfy.org/built-in-nodes/ConvertArrayToString) — 将数组转换为字符串节点接收一个项目数组（列表），并将其转换为格式化的 JSON 字符串。
- [ConvertDictionaryToString](https://docs.comfy.org/built-in-nodes/ConvertDictionaryToString) — 此节点将字典（键值对集合）转换为文本字符串，通常采用 JSON 格式。
- [JsonExtractString](https://docs.comfy.org/built-in-nodes/JsonExtractString) — JsonExtractString 节点会扫描文本字符串中的第一个有效 JSON 对象，并提取与指定键关联的值，再将其转换为字符串。
- [MergeTextLists](https://docs.comfy.org/built-in-nodes/MergeTextLists) — 此节点将多个文本列表合并为一个组合列表。
- [RegexExtract](https://docs.comfy.org/built-in-nodes/RegexExtract) — RegexExtract 节点使用正则表达式在文本中搜索模式。
- [RegexMatch](https://docs.comfy.org/built-in-nodes/RegexMatch) — RegexMatch 节点用于检查文本字符串是否包含与给定正则表达式模式匹配的内容。
- [RegexReplace](https://docs.comfy.org/built-in-nodes/RegexReplace) — RegexReplace 节点使用正则表达式模式在字符串中查找和替换文本。
- [ReplaceText](https://docs.comfy.org/built-in-nodes/ReplaceText) — 替换文本节点执行简单的文本替换操作。
- [SaveText](https://docs.comfy.org/built-in-nodes/SaveText) — Save Text 节点将文本内容写入输出目录中的文件。
- [StringCompare](https://docs.comfy.org/built-in-nodes/StringCompare) — The StringCompare node compares two text strings using different comparison methods.
- [StringConcatenate](https://docs.comfy.org/built-in-nodes/StringConcatenate) — StringConcatenate 节点通过指定的分隔符将两个文本字符串合并为一个。
- [StringContains](https://docs.comfy.org/built-in-nodes/StringContains) — StringContains 节点用于检查给定字符串是否包含指定的子字符串。
- [StringFormat](https://docs.comfy.org/built-in-nodes/StringFormat) — 内置节点参考页（官方暂无中文说明）
- [StringLength](https://docs.comfy.org/built-in-nodes/StringLength) — 此文档由 AI 生成。
- [StringReplace](https://docs.comfy.org/built-in-nodes/StringReplace) — StringReplace 节点对输入字符串执行文本替换操作。
- [StringSubstring](https://docs.comfy.org/built-in-nodes/StringSubstring) — StringSubstring 节点用于从较长的字符串中提取一部分文本。
- [StringTrim](https://docs.comfy.org/built-in-nodes/StringTrim) — StringTrim 节点用于移除文本字符串开头、结尾或两端的空白字符。
- [StripWhitespace](https://docs.comfy.org/built-in-nodes/StripWhitespace) — 此节点用于移除文本字符串开头和结尾的所有多余空格、制表符或换行符。
- [TextGenerate](https://docs.comfy.org/built-in-nodes/TextGenerate) — TextGenerate 节点使用 CLIP 模型根据用户提示词生成文本。
- [TextGenerateLTX2Prompt](https://docs.comfy.org/built-in-nodes/TextGenerateLTX2Prompt) — TextGenerateLTX2Prompt 节点可将简短的用户提示词扩展为详细的音视频描述，适用于使用 LTX-2 系列视频模型生成视频。
- [TextOverlay](https://docs.comfy.org/built-in-nodes/TextOverlay) — 此节点在图像或一批图像上绘制文本。
- [TextToLowercase](https://docs.comfy.org/built-in-nodes/TextToLowercase) — 文本转小写节点接收一个文本字符串作为输入，并将其所有字符转换为小写。
- [TextToUppercase](https://docs.comfy.org/built-in-nodes/TextToUppercase) — 文本转大写节点接收文本输入，并将其所有字符转换为大写。
- [TruncateText](https://docs.comfy.org/built-in-nodes/TruncateText) — 此节点通过在指定最大长度处截断文本来缩短文本。

#### Utilities

- [ColorToRGBInt](https://docs.comfy.org/built-in-nodes/ColorToRGBInt) — ColorToRGBInt 节点将十六进制格式（如 FF5733）的颜色转换为单个 RGB 整数值。
- [ComfyMathExpression](https://docs.comfy.org/built-in-nodes/ComfyMathExpression) — ComfyMathExpression 节点会计算你以文本形式编写的数学公式。
- [ComfyNumberConvert](https://docs.comfy.org/built-in-nodes/ComfyNumberConvert) — Number Convert 节点可将各种输入数据类型转换为数值。
- [CreateBoundingBoxes](https://docs.comfy.org/built-in-nodes/CreateBoundingBoxes) — 此节点提供一个画布界面，用于在图像中的物体或文本区域周围绘制边界框。
- [CreateList](https://docs.comfy.org/built-in-nodes/CreateList) — Create List 节点将多个输入合并为一个按顺序排列的列表。
- [CurveEditor](https://docs.comfy.org/built-in-nodes/CurveEditor) — Curve Editor 节点提供了一个可视化界面，用于调整和微调曲线。
- [CustomCombo](https://docs.comfy.org/built-in-nodes/CustomCombo) — Custom Combo 节点允许你为下拉菜单定义自己的文本选项列表，而不是从固定值中选择。
- [GetItemFromList](https://docs.comfy.org/built-in-nodes/GetItemFromList) — 此节点从列表中返回单个项，并根据其位置进行选择。
- [ImageHistogram](https://docs.comfy.org/built-in-nodes/ImageHistogram) — ImageHistogram 节点分析输入图像的颜色分布。
- [PreviewAny](https://docs.comfy.org/built-in-nodes/PreviewAny) — PreviewAny 可将任意输入值转换为可读文本，以便你进行检查。
- [ResolutionSelector](https://docs.comfy.org/built-in-nodes/ResolutionSelector) — Resolution Selector 节点根据选定的宽高比和目标总分辨率（以百万像素为单位）计算像素宽度和高度。
- [SeedNode](https://docs.comfy.org/built-in-nodes/SeedNode) — Seed 节点提供一个整数值，可用作种子来控制其他节点中随机操作的可复现性。

##### Logic

- [AutogrowNamesTestNode](https://docs.comfy.org/built-in-nodes/AutogrowNamesTestNode) — 此节点用于测试 Autogrow 输入功能。
- [AutogrowPrefixTestNode](https://docs.comfy.org/built-in-nodes/AutogrowPrefixTestNode) — AutogrowPrefixTestNode 是一个逻辑节点，用于测试自动增长输入功能。
- [ComboOptionTestNode](https://docs.comfy.org/built-in-nodes/ComboOptionTestNode) — 此节点接收两个组合框选项，并将其原样传递到输出，不做任何更改。
- [ComfyAndNode](https://docs.comfy.org/built-in-nodes/ComfyAndNode) — And 节点对一组输入值执行逻辑 AND 运算。
- [ComfyNotNode](https://docs.comfy.org/built-in-nodes/ComfyNotNode) — Not 节点对任意输入值执行逻辑 NOT 运算。
- [ComfyOrNode](https://docs.comfy.org/built-in-nodes/ComfyOrNode) — Or 节点对一组输入值执行逻辑或运算。
- [ComfySoftSwitchNode](https://docs.comfy.org/built-in-nodes/ComfySoftSwitchNode) — Soft Switch 节点根据布尔条件在两个可能的输入值之间进行选择。
- [ComfySwitchNode](https://docs.comfy.org/built-in-nodes/ComfySwitchNode) — If/Else Switch 节点根据布尔条件在两个可能的输入之间进行选择。
- [ConvertStringToComboNode](https://docs.comfy.org/built-in-nodes/ConvertStringToComboNode) — Convert String to Combo 节点接收文本字符串作为输入，并将其转换为 Combo 数据类型。
- [DCTestNode](https://docs.comfy.org/built-in-nodes/DCTestNode) — DCTestNode 是一个逻辑节点，会根据用户在动态组合框中的选择返回不同类型的数据。
- [InvertBooleanNode](https://docs.comfy.org/built-in-nodes/InvertBooleanNode) — 此节点接收单个布尔值（true/false）输入，并输出相反的值。

##### Looping

- [EndLoop](https://docs.comfy.org/built-in-nodes/EndLoop) — End Loop 标记循环块的结束。
- [StartLoop](https://docs.comfy.org/built-in-nodes/StartLoop) — Start Loop 节点在工作流内启动一个循环结构。

##### Primitive

- [PrimitiveBoolean](https://docs.comfy.org/built-in-nodes/PrimitiveBoolean) — Boolean 节点会将一个布尔值（true/false）传递通过你的工作流。
- [PrimitiveBoundingBox](https://docs.comfy.org/built-in-nodes/PrimitiveBoundingBox) — PrimitiveBoundingBox 节点创建一个由其位置和大小定义的简单矩形区域。
- [PrimitiveFloat](https://docs.comfy.org/built-in-nodes/PrimitiveFloat) — PrimitiveFloat 节点创建一个可在工作流中使用的浮点数值。
- [PrimitiveInt](https://docs.comfy.org/built-in-nodes/PrimitiveInt) — PrimitiveInt 节点提供了一种在工作流中处理整数值的简单方法。
- [PrimitiveString](https://docs.comfy.org/built-in-nodes/PrimitiveString) — Text 节点提供了一种在工作流中输入和传递文本数据的简单方式。
- [PrimitiveStringMultiline](https://docs.comfy.org/built-in-nodes/PrimitiveStringMultiline) — Text (Multiline) 节点提供了一个多行文本输入字段，供您在工作流中输入和传递字符串值。

#### Video

- [ConcatenateVideo](https://docs.comfy.org/built-in-nodes/ConcatenateVideo) — 将多个视频片段拼接为单个视频，并保持它们连接时的顺序。
- [CreateVideo](https://docs.comfy.org/built-in-nodes/CreateVideo) — Create Video 节点将一系列图像合并为视频。
- [FrameInterpolate](https://docs.comfy.org/built-in-nodes/FrameInterpolate) — Frame Interpolate 节点会在图像序列中的现有帧之间创建新帧，从而有效提高帧率。
- [GetVideoComponents](https://docs.comfy.org/built-in-nodes/GetVideoComponents) — Get Video Components 节点从视频文件中提取所有主要元素。
- [LoadVideo](https://docs.comfy.org/built-in-nodes/LoadVideo) — Load Video 节点从输入目录加载视频文件，并使其可在工作流中进行处理。
- [LoadVideoDataSetFromFolder](https://docs.comfy.org/built-in-nodes/LoadVideoDataSetFromFolder) — 从 ComfyUI 输入目录中的选定文件夹加载视频数据集，并将其作为惰性视频引用列表返回。
- [LoadVideoTextDataSetFromFolder](https://docs.comfy.org/built-in-nodes/LoadVideoTextDataSetFromFolder) — 此节点从 ComfyUI 输入目录内的文件夹中加载视频文件及其匹配的文本描述，并以两个列表的形式返回：视频和描述。
- [SaveVideo](https://docs.comfy.org/built-in-nodes/SaveVideo) — Save Video 节点将输入视频保存到你的 ComfyUI 输出目录。
- [SaveWEBM](https://docs.comfy.org/built-in-nodes/SaveWEBM) — SaveWEBM 节点将一系列图像保存为 WEBM 视频文件。
- [VideoCrop](https://docs.comfy.org/built-in-nodes/VideoCrop) — 此节点将视频裁剪到以像素定义的矩形区域，仅保留该矩形内的区域。
- [VideoFrameSample](https://docs.comfy.org/built-in-nodes/VideoFrameSample) — VideoFrameSample 节点使用四种策略之一从视频中提取固定数量的帧。
- [VideoTrim](https://docs.comfy.org/built-in-nodes/VideoTrim) — 此节点通过设置起始时间和时长，将视频剪切到选定的时间窗口。

##### Batch

- [ShuffleVideoDataset](https://docs.comfy.org/built-in-nodes/ShuffleVideoDataset) — 此节点接收一个视频列表并随机重新排序。
- [ShuffleVideoTextDataset](https://docs.comfy.org/built-in-nodes/ShuffleVideoTextDataset) — 此节点会随机打乱列表中“视频-文本”对的顺序，确保每个视频仍与其对应的文本配对。

##### Preprocessors

- [LTXVPreprocess](https://docs.comfy.org/built-in-nodes/LTXVPreprocess) — LTXVPreprocess 节点对图像应用压缩预处理。

##### Transform

- [VideoRandomTemporalCrop](https://docs.comfy.org/built-in-nodes/VideoRandomTemporalCrop) — 从输入视频中随机裁剪一段连续的帧。
- [VideoTemporalCrop](https://docs.comfy.org/built-in-nodes/VideoTemporalCrop) — 此节点从视频中裁剪出连续的帧范围。

#### 加载器

- [ControlNetLoader](https://docs.comfy.org/built-in-nodes/ControlNetLoader) — 此节点将检测位于 ComfyUI/models/controlnet 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的其他路径中的模型。

#### 图像

- [AddLayer](https://docs.comfy.org/built-in-nodes/AddLayer) — The Add Layer 节点将输入图像转换为图层并将其放置在画布上，可以开始新的图层堆栈，或将图层追加到现有堆栈。
- [BatchImagesNode](https://docs.comfy.org/built-in-nodes/BatchImagesNode) — 批量图像节点将多个单独图像合并为单个批次。
- [ConditioningCombine](https://docs.comfy.org/built-in-nodes/ConditioningCombine) — 此节点将两个条件输入合并为单个输出，有效融合其信息。
- [EmptyImage](https://docs.comfy.org/built-in-nodes/EmptyImage) — 内置节点参考页（官方暂无中文说明）
- [GetImageSize](https://docs.comfy.org/built-in-nodes/GetImageSize) — GetImageSize 节点读取输入图像，并返回其宽度、高度和批次大小。
- [ImageBatch](https://docs.comfy.org/built-in-nodes/ImageBatch) — ImageBatch 节点用于将两张图像合并为一个批次。
- [ImageCompare](https://docs.comfy.org/built-in-nodes/ImageCompare) — 内置节点参考页（官方暂无中文说明）
- [ImageCompositor](https://docs.comfy.org/built-in-nodes/ImageCompositor) — 此节点将多个图像图层合并为单个合成图像。
- [ImageInvert](https://docs.comfy.org/built-in-nodes/ImageInvert) — ImageInvert 节点用于反转图像的颜色，将每个像素的颜色值转换为其在色轮上的互补色。
- [LayersFromBoundingBoxes](https://docs.comfy.org/built-in-nodes/LayersFromBoundingBoxes) — 此节点将图像批次及其边界框转换为图层堆栈，为每一帧创建一个图层，并根据匹配的框放置每个图层。
- [LoadImage](https://docs.comfy.org/built-in-nodes/LoadImage) — LoadImage 节点用于从指定路径加载并预处理图像。
- [LoadImageDataSetFromFolder](https://docs.comfy.org/built-in-nodes/LoadImageDataSetFromFolder) — 此节点从 ComfyUI 主输入目录中选定的子文件夹加载多张图像，并以列表形式返回。
- [LoadImageMask](https://docs.comfy.org/built-in-nodes/LoadImageMask) — LoadImageMask 节点用于从指定路径加载图像及其关联的遮罩，并对其进行处理，以确保与后续图像处理或分析任务的兼容性。
- [LoadImageOutput](https://docs.comfy.org/built-in-nodes/LoadImageOutput) — LoadImageOutput 节点用于从输出文件夹加载图像。
- [LoadImageSetFromFolderNode](https://docs.comfy.org/built-in-nodes/LoadImageSetFromFolderNode) — LoadImageSetFromFolderNode 从指定文件夹目录加载多张图像用于训练目的。
- [LoadImageSetNode](https://docs.comfy.org/built-in-nodes/LoadImageSetNode) — LoadImageSetNode 从输入目录加载多张图像，用于批量处理与训练目的。
- [LoadImageTextDataSetFromFolder](https://docs.comfy.org/built-in-nodes/LoadImageTextDataSetFromFolder) — 此节点从选定文件夹加载图像-文本描述对数据集，并以列表形式返回。
- [LoadImageTextSetFromFolderNode](https://docs.comfy.org/built-in-nodes/LoadImageTextSetFromFolderNode) — 从指定目录加载一批图像及其对应的文本描述，用于训练目的。
- [LoraLoader](https://docs.comfy.org/built-in-nodes/LoraLoader) — 此节点会自动检测 LoRA 文件夹（包括子文件夹）中的模型，对应的模型路径为 ComfyUI\models\loras。
- [LoraLoaderModelOnly](https://docs.comfy.org/built-in-nodes/LoraLoaderModelOnly) — 此节点将检测位于 ComfyUI/models/loras 文件夹中的模型，同时也会读取在 extramodelpaths.yaml 文件中配置的其他路径中的模型。
- [Painter](https://docs.comfy.org/built-in-nodes/Painter) — Painter 节点提供了一个交互式画布，用于直接在 ComfyUI 中创建或编辑图像和遮罩。
- [PreviewImage](https://docs.comfy.org/built-in-nodes/PreviewImage) — PreviewImage 节点用于创建临时预览图像。
- [ResizeImageMaskNode](https://docs.comfy.org/built-in-nodes/ResizeImageMaskNode) — 此文档由 AI 生成。
- [SaveAnimatedPNG](https://docs.comfy.org/built-in-nodes/SaveAnimatedPNG) — SaveAnimatedPNG 节点用于从一系列帧创建并保存动画 PNG 图像。
- [SaveAnimatedWEBP](https://docs.comfy.org/built-in-nodes/SaveAnimatedWEBP) — 此节点用于将一系列图像保存为动画 WEBP 文件。
- [SaveImage](https://docs.comfy.org/built-in-nodes/SaveImage) — SaveImage 节点将输入的图像以 PNG 文件的形式保存到你的 ComfyUI 输出目录中。
- [SaveImageAdvanced](https://docs.comfy.org/built-in-nodes/SaveImageAdvanced) — Save Image (Advanced) 节点将输入图像保存到你的 ComfyUI 输出目录，并提供对文件格式、位深度和色彩空间的高级控制。
- [SaveImageDataSetToFolder](https://docs.comfy.org/built-in-nodes/SaveImageDataSetToFolder) — 此节点将图像列表保存到 ComfyUI 输出目录内的指定文件夹中。
- [SaveImageTextDataSetToFolder](https://docs.comfy.org/built-in-nodes/SaveImageTextDataSetToFolder) — Save Image-Text (to Folder) 将图像和文本描述对数据集保存到 ComfyUI 输出目录内的文件夹中。
- [SaveSVGNode](https://docs.comfy.org/built-in-nodes/SaveSVGNode) — 将 SVG 文件保存到磁盘。
- [WebcamCapture](https://docs.comfy.org/built-in-nodes/WebcamCapture) — WebcamCapture 节点用于从摄像头设备捕获图像，并将其转换为可在 ComfyUI 工作流中使用的格式。

##### Adjustments

- [AdjustBrightness](https://docs.comfy.org/built-in-nodes/AdjustBrightness) — Adjust Brightness 节点用于调整图像的亮度。
- [AdjustContrast](https://docs.comfy.org/built-in-nodes/AdjustContrast) — Adjust Contrast 节点通过围绕颜色范围中点缩放亮部与暗部之间的差异来调整输入图像的对比度。

##### Background Removal

- [RemoveBackground](https://docs.comfy.org/built-in-nodes/RemoveBackground) — 内置节点参考页（官方暂无中文说明）

##### Batch

- [ImageDeduplication](https://docs.comfy.org/built-in-nodes/ImageDeduplication) — 此节点用于从一批图像中移除重复或高度相似的图像。
- [ImageFromBatch](https://docs.comfy.org/built-in-nodes/ImageFromBatch) — ImageFromBatch 节点用于根据指定的索引和长度从批次中提取特定图像片段。
- [ImageGrid](https://docs.comfy.org/built-in-nodes/ImageGrid) — 图像网格节点将多张图像合并为一张排列有序的网格或拼贴图。
- [ImageMergeTileList](https://docs.comfy.org/built-in-nodes/ImageMergeTileList) — 此节点接收一个图像瓦片列表，并将其合并回一张更大的完整图像。
- [MergeImageLists](https://docs.comfy.org/built-in-nodes/MergeImageLists) — 合并图像列表节点将多个独立的图像列表合并为一个连续的列表。
- [RebatchImages](https://docs.comfy.org/built-in-nodes/RebatchImages) — RebatchImages 节点旨在将一批图像重新组织为新的批次配置，并按指定调整批次大小。
- [RepeatImageBatch](https://docs.comfy.org/built-in-nodes/RepeatImageBatch) — RepeatImageBatch 节点旨在将指定图像复制指定次数，从而创建一批相同的图像。
- [ShuffleDataset](https://docs.comfy.org/built-in-nodes/ShuffleDataset) — Shuffle Dataset（数据集打乱）节点接收一个图像列表并随机改变其顺序。
- [ShuffleImageTextDataset](https://docs.comfy.org/built-in-nodes/ShuffleImageTextDataset) — 此节点将图像列表和文本列表一起打乱，保持它们的配对关系不变。
- [SplitImageToTileList](https://docs.comfy.org/built-in-nodes/SplitImageToTileList) — 将图像分割为图块列表节点可将单个输入图像划分为一系列较小的、重叠的矩形区域（称为图块）。

##### Color

- [ImageColorSpace](https://docs.comfy.org/built-in-nodes/ImageColorSpace) — ImageColorSpace 节点可在 sRGB（Rec.709）、线性 Rec.709、HDR（Rec.2020 HLG）、HDR PQ（Rec.2020 PQ）、HDR LogC3 和 HDR ACEScct 色彩空间之间转换图像。
- [ImageRGBToYUV](https://docs.comfy.org/built-in-nodes/ImageRGBToYUV) — ImageRGBToYUV 节点使用 RGB 到 YCbCr 的颜色转换，将 RGB 图像转换为 YUV 风格的色彩分量。
- [ImageYUVToRGB](https://docs.comfy.org/built-in-nodes/ImageYUVToRGB) — ImageYUVToRGB 节点将 YUV 色彩空间图像转换为 RGB 色彩空间。
- [NormalizeImages](https://docs.comfy.org/built-in-nodes/NormalizeImages) — 此节点通过根据指定的均值和标准差调整输入图像的像素值来归一化其颜色。

##### Compositing

- [ImageCompositeMasked](https://docs.comfy.org/built-in-nodes/ImageCompositeMasked) — ImageCompositeMasked 节点专为图像合成而设计，支持将源图像叠加到目标图像的指定坐标位置，并可选择调整大小和遮罩。
- [JoinImageWithAlpha](https://docs.comfy.org/built-in-nodes/JoinImageWithAlpha) — 此节点专为合成操作设计，具体用于将图像与其对应的 Alpha 蒙版合并，生成单一输出图像。
- [PorterDuffImageComposite](https://docs.comfy.org/built-in-nodes/PorterDuffImageComposite) — PorterDuffImageComposite 节点旨在使用 Porter-Duff 合成运算符执行图像合成。
- [SplitImageWithAlpha](https://docs.comfy.org/built-in-nodes/SplitImageWithAlpha) — SplitImageWithAlpha 节点旨在分离图像的色彩和 Alpha 分量。

##### Detection

- [DrawBBoxes](https://docs.comfy.org/built-in-nodes/DrawBBoxes) — DrawBBoxes 节点通过在图像上绘制边界框、标签和置信度分数来可视化目标检测结果。
- [MediaPipeFaceLandmarker](https://docs.comfy.org/built-in-nodes/MediaPipeFaceLandmarker) — 内置节点参考页（官方暂无中文说明）
- [MediaPipeFaceMask](https://docs.comfy.org/built-in-nodes/MediaPipeFaceMask) — 内置节点参考页（官方暂无中文说明）
- [MediaPipeFaceMeshVisualize](https://docs.comfy.org/built-in-nodes/MediaPipeFaceMeshVisualize) — 内置节点参考页（官方暂无中文说明）
- [RTDETR_detect](https://docs.comfy.org/built-in-nodes/RTDETR_detect) — RT-DETR Detect 节点使用 RT-DETR 模型对输入图像执行目标检测。
- [SAM3_Detect](https://docs.comfy.org/built-in-nodes/SAM3_Detect) — 内置节点参考页（官方暂无中文说明）
- [SAM3_TrackPreview](https://docs.comfy.org/built-in-nodes/SAM3_TrackPreview) — 内置节点参考页（官方暂无中文说明）
- [SAM3_TrackToMask](https://docs.comfy.org/built-in-nodes/SAM3_TrackToMask) — 内置节点参考页（官方暂无中文说明）
- [SAM3_VideoTrack](https://docs.comfy.org/built-in-nodes/SAM3_VideoTrack) — 使用 SAM3 基于记忆的跟踪器跨视频帧跟踪对象。
- [SAM3DBody_FaceExpression](https://docs.comfy.org/built-in-nodes/SAM3DBody_FaceExpression) — 此节点通过使用 MediaPipe Face Landmarker 检测图像中的人脸，将每张检测到的人脸与跟踪到的人物进行匹配，并将 52 个 ARKit 混合形状映射到 MHR 的 72 轴表情参数上，从而为 SAM3D 身体添加面部表情。
- [SAM3DBody_Loader](https://docs.comfy.org/built-in-nodes/SAM3DBody_Loader) — 加载存储在检测文件夹中的检查点文件中的 SAM3D Body 模型，并准备用于 3D 身体检测。
- [SAM3DBody_Predict](https://docs.comfy.org/built-in-nodes/SAM3DBody_Predict) — SAM3D 人体预测在输入图像上运行 3D 人体和手部姿态估计，每帧可检测一个或多个人。
- [SAM3DBody_Render](https://docs.comfy.org/built-in-nodes/SAM3DBody_Render) — 使用可选样式将 3D 身体姿态数据渲染为图像。
- [SAM3DBody_Smooth](https://docs.comfy.org/built-in-nodes/SAM3DBody_Smooth) — 平滑 SAM3D 身体姿态数据（Smooth SAM3D Body Pose Data）节点通过随时间对运动进行平均，减少一系列 3D 身体姿态中的帧间抖动。
- [SDPoseDrawKeypoints](https://docs.comfy.org/built-in-nodes/SDPoseDrawKeypoints) — SDPoseDrawKeypoints 节点接收姿态估计数据（关键点）并将其绘制在空白画布上，形成可视化骨架。
- [SDPoseFaceBBoxes](https://docs.comfy.org/built-in-nodes/SDPoseFaceBBoxes) — SDPoseFaceBBoxes 节点处理姿态关键点数据，用于检测并生成人脸周围的边界框。
- [SDPoseKeypointExtractor](https://docs.comfy.org/built-in-nodes/SDPoseKeypointExtractor) — 此节点使用SDPose模型从输入图像中检测人体姿态关键点。

##### Filters

- [Canny](https://docs.comfy.org/built-in-nodes/Canny) — 从照片中提取所有边缘线，就像用笔勾勒照片一样，描绘出物体的轮廓和细节边界。
- [ColorTransfer](https://docs.comfy.org/built-in-nodes/ColorTransfer) — ColorTransfer 节点用于调整目标图像的调色板，使其与参考图像的颜色相匹配。
- [ImageAddNoise](https://docs.comfy.org/built-in-nodes/ImageAddNoise) — ImageAddNoise 节点会向输入图像添加随机噪声。
- [ImageBlend](https://docs.comfy.org/built-in-nodes/ImageBlend) — ImageBlend 节点用于根据指定的混合模式和混合因子将两张图像混合在一起。
- [ImageBlur](https://docs.comfy.org/built-in-nodes/ImageBlur) — ImageBlur 节点对图像应用高斯模糊，可柔化边缘、减少细节和噪点。
- [ImageQuantize](https://docs.comfy.org/built-in-nodes/ImageQuantize) — ImageQuantize 节点旨在将图像中的颜色数量减少到指定数目，并可选择应用抖动技术以保持视觉质量。
- [ImageSharpen](https://docs.comfy.org/built-in-nodes/ImageSharpen) — ImageSharpen 节点通过突出图像的边缘和细节来增强其清晰度。
- [Morphology](https://docs.comfy.org/built-in-nodes/Morphology) — 形态学节点对图像应用各种形态学运算，这些运算是一种用于处理和分析图像中形状的数学方法。

##### Geometry Estimation

- [DA3GeometryToMesh](https://docs.comfy.org/built-in-nodes/DA3GeometryToMesh) — 此节点通过反投影深度图并对生成的点云进行三角化，将 DA3GEOMETRY 数据包转换为 3D 网格。
- [DA3GeometryToPointCloud](https://docs.comfy.org/built-in-nodes/DA3GeometryToPointCloud) — 此节点将 DA3GEOMETRY 对象中的深度图转换为 3D 点云。
- [DA3Inference](https://docs.comfy.org/built-in-nodes/DA3Inference) — 此节点在图像上运行 Depth Anything 3 模型，以估算深度和几何信息。
- [DA3Render](https://docs.comfy.org/built-in-nodes/DA3Render) — 此节点用于从 Depth Anything 3 几何数据渲染可视化结果。
- [MarigoldV2PostProcess](https://docs.comfy.org/built-in-nodes/MarigoldV2PostProcess) — 此节点将解码后的 Marigold V2 预测转换为可查看的图像。
- [MoGeGeometryToFOV](https://docs.comfy.org/built-in-nodes/MoGeGeometryToFOV) — 此节点从存储在 MoGe 几何对象中的相机内参推导出视场角（FOV）和焦距。
- [MoGeInference](https://docs.comfy.org/built-in-nodes/MoGeInference) — 对图像运行 MoGe 以估计深度和几何。
- [MoGePanoramaInference](https://docs.comfy.org/built-in-nodes/MoGePanoramaInference) — 此节点对等距柱状全景图执行深度估计。
- [MoGePointMapToMesh](https://docs.comfy.org/built-in-nodes/MoGePointMapToMesh) — 此节点将 MoGe 点图转换为 3D 网格。
- [MoGeRender](https://docs.comfy.org/built-in-nodes/MoGeRender) — 此节点接收一个 MOGEGEOMETRY 数据包（由 MoGe 深度/法线估计节点生成），并将其渲染为标准图像格式。

##### Mask

- [BatchMasksNode](https://docs.comfy.org/built-in-nodes/BatchMasksNode) — Batch Masks 节点将多个单独的掩码输入组合成一个批次。
- [CropMask](https://docs.comfy.org/built-in-nodes/CropMask) — CropMask节点用于从给定的遮罩中裁剪指定区域。
- [FeatherMask](https://docs.comfy.org/built-in-nodes/FeatherMask) — FeatherMask 节点用于对给定蒙版的边缘应用羽化效果，通过根据距各边缘的指定距离调整边缘的不透明度，使蒙版边缘平滑过渡，从而产生更柔和、更自然的边缘效果。
- [GrowMask](https://docs.comfy.org/built-in-nodes/GrowMask) — GrowMask 节点用于修改给定遮罩的尺寸，可将其扩大或收缩，同时可选择对边角应用渐变效果。
- [ImageColorToMask](https://docs.comfy.org/built-in-nodes/ImageColorToMask) — ImageColorToMask 节点旨在将图像中的指定颜色转换为遮罩。
- [ImageToMask](https://docs.comfy.org/built-in-nodes/ImageToMask) — ImageToMask 节点旨在根据指定的颜色通道将图像转换为遮罩。
- [InvertMask](https://docs.comfy.org/built-in-nodes/InvertMask) — InvertMask 节点用于反转给定蒙版的值，有效交换蒙版区域与非蒙版区域。
- [MaskComposite](https://docs.comfy.org/built-in-nodes/MaskComposite) — 此节点专门用于通过加法、减法及逻辑运算等多种操作，将两个遮罩输入合并，生成新的修改后遮罩。
- [MaskPreview](https://docs.comfy.org/built-in-nodes/MaskPreview) — The MaskPreview 节点直接在 ComfyUI 界面中显示遮罩数据的可视化预览，而不会将其保存到输出目录。
- [MaskToImage](https://docs.comfy.org/built-in-nodes/MaskToImage) — MaskToImage 节点旨在将遮罩转换为图像格式。
- [SolidMask](https://docs.comfy.org/built-in-nodes/SolidMask) — SolidMask 节点用于生成一个在整个区域内具有指定值的均匀遮罩。
- [ThresholdMask](https://docs.comfy.org/built-in-nodes/ThresholdMask) — ThresholdMask 节点通过应用阈值将掩码转换为二值掩码。
- [VOIDQuadmaskPreprocess](https://docs.comfy.org/built-in-nodes/VOIDQuadmaskPreprocess) — 内置节点参考页（官方暂无中文说明）

##### Post Processors

- [SeedVR2PostProcessing](https://docs.comfy.org/built-in-nodes/SeedVR2PostProcessing) — 此节点将生成的图像与原始缩放图像对齐，并应用可选的颜色校正。

##### Pre Processors

- [SeedVR2Preprocess](https://docs.comfy.org/built-in-nodes/SeedVR2Preprocess) — 此节点通过将调整尺寸后的图像或视频填充到 SeedVR2 模型期望的形状，为 SeedVR2 模型准备输入。

##### Shader

- [GLSLShader](https://docs.comfy.org/built-in-nodes/GLSLShader) — The GLSL Shader node lets you write custom fragment shaders in GLSL ES 3.00 (WebGL 2.0 compatible) to process images directly on the GPU.

##### Transform

- [CenterCropImages](https://docs.comfy.org/built-in-nodes/CenterCropImages) — 中心裁剪图像节点从图像中心裁剪出指定宽度和高度的区域。
- [CropByBBoxes](https://docs.comfy.org/built-in-nodes/CropByBBoxes) — CropByBBoxes 节点从输入图像批次中提取并调整特定矩形区域的大小。
- [ImageCrop](https://docs.comfy.org/built-in-nodes/ImageCrop) — ImageCrop 节点用于将图像从指定的 x 和 y 坐标开始裁剪为指定的宽度和高度。
- [ImageCropToMask](https://docs.comfy.org/built-in-nodes/ImageCropToMask) — 裁剪图像到其掩码的边界框，在纯色背景上生成居中的主体。
- [ImageCropV2](https://docs.comfy.org/built-in-nodes/ImageCropV2) — 此文档由 AI 生成。
- [ImageFlip](https://docs.comfy.org/built-in-nodes/ImageFlip) — ImageFlip 节点可沿不同轴翻转图像。
- [ImagePadForOutpaint](https://docs.comfy.org/built-in-nodes/ImagePadForOutpaint) — 此节点专为外绘（outpainting）流程准备图像而设计，通过在图像周围添加填充区域来调整图像尺寸，确保与外绘算法兼容，从而便于在原始边界之外生成扩展的图像区域。
- [ImageRotate](https://docs.comfy.org/built-in-nodes/ImageRotate) — ImageRotate 节点可按指定角度旋转输入图像。
- [ImageStitch](https://docs.comfy.org/built-in-nodes/ImageStitch) — 此节点允许您将两张图像沿指定方向（上、下、左、右）拼接在一起，并支持尺寸匹配和图像间距设置。
- [RandomCropImages](https://docs.comfy.org/built-in-nodes/RandomCropImages) — 随机裁剪图像节点从每张输入图像中随机选取一个矩形区域，并将其裁剪为指定的宽度和高度。
- [ResizeAndPadImage](https://docs.comfy.org/built-in-nodes/ResizeAndPadImage) — ResizeAndPadImage 节点用于将图像调整至指定尺寸范围内，同时保持原始宽高比。
- [ResizeImagesByLongerEdge](https://docs.comfy.org/built-in-nodes/ResizeImagesByLongerEdge) — 按较长边调整图像大小节点可调整一个或多个图像的尺寸，使其最长边与指定的目标长度匹配。
- [ResizeImagesByShorterEdge](https://docs.comfy.org/built-in-nodes/ResizeImagesByShorterEdge) — 此节点用于调整图像大小，使较短边匹配指定长度，同时保持原始宽高比。

##### Upscaling

- [ImageScale](https://docs.comfy.org/built-in-nodes/ImageScale) — ImageScale 节点专为将图像调整至特定尺寸而设计，提供多种放大方法选择以及裁剪调整后图像的功能。
- [ImageScaleBy](https://docs.comfy.org/built-in-nodes/ImageScaleBy) — ImageScaleBy 节点旨在通过指定的缩放因子，使用多种插值方法对图像进行放大。
- [ImageScaleToMaxDimension](https://docs.comfy.org/built-in-nodes/ImageScaleToMaxDimension) — ImageScaleToMaxDimension 节点用于将图像调整至指定的最大尺寸范围内，同时保持原始宽高比。
- [ImageScaleToTotalPixels](https://docs.comfy.org/built-in-nodes/ImageScaleToTotalPixels) — ImageScaleToTotalPixels 节点用于将图像调整至指定的总像素数，同时保持原始宽高比。
- [ImageUpscaleWithModel](https://docs.comfy.org/built-in-nodes/ImageUpscaleWithModel) — 此节点专为使用指定的放大模型对图像进行放大而设计。

##### Video

- [WanDancerPadKeyframes](https://docs.comfy.org/built-in-nodes/WanDancerPadKeyframes) — 内置节点参考页（官方暂无中文说明）
- [WanDancerPadKeyframesList](https://docs.comfy.org/built-in-nodes/WanDancerPadKeyframesList) — 内置节点参考页（官方暂无中文说明）

#### 实用工具

- [BatchImagesMasksLatentsNode](https://docs.comfy.org/built-in-nodes/BatchImagesMasksLatentsNode) — 批量图像/遮罩/潜空间节点将多个相同类型的输入合并为单个批次。
- [MarkdownNote](https://docs.comfy.org/built-in-nodes/MarkdownNote) — 节点用于向工作流添加注释。
- [Note](https://docs.comfy.org/built-in-nodes/Note) — 用于向工作流添加注释的节点。
- [Reroute](https://docs.comfy.org/built-in-nodes/Reroute) — 节点名称：Reroute 节点 节点用途：主要用于整理 ComfyUI 工作流中过长的连接线逻辑。
- [TerminalLog](https://docs.comfy.org/built-in-nodes/TerminalLog) — 终端日志（管理）节点主要用于在 ComfyUI 界面中显示终端内 ComfyUI 的运行信息。
- [wanBlockSwap](https://docs.comfy.org/built-in-nodes/wanBlockSwap) — 此节点已弃用，不执行任何功能。

#### 条件

- [ConditioningAverage](https://docs.comfy.org/built-in-nodes/ConditioningAverage) — ConditioningAverage 节点用于根据指定权重混合两组不同的条件（如文本提示），生成介于两者之间的新条件向量。
- [Sd4xupscaleConditioning](https://docs.comfy.org/built-in-nodes/Sd4xupscaleConditioning) — 此节点专注于通过 4 倍放大过程提升图像分辨率，并结合调节元素来优化输出。

##### Video Models

- [Wan Vace To Video - ComfyUI 原生节点文档](https://docs.comfy.org/built-in-nodes/conditioning/video-models/wan-vace-to-video) — 使用阿里通义万相的高分辨率视频生成 API 创建视频
- [Stablezero123Conditioning](https://docs.comfy.org/built-in-nodes/Stablezero123Conditioning) — 此节点专为处理 StableZero123 模型的数据并准备条件输入而设计，重点是将输入格式化为兼容且优化的特定格式，以满足这些模型的需求。
- [Stablezero123ConditioningBatched](https://docs.comfy.org/built-in-nodes/Stablezero123ConditioningBatched) — 此节点专为 StableZero123 模型设计，以批处理方式处理条件信息。
- [SVD_img2vid_Conditioning](https://docs.comfy.org/built-in-nodes/SVD_img2vid_Conditioning) — SVDimg2vidConditioning 节点用于准备基于 Stable Video Diffusion 的视频生成条件数据。
- [SvdImg2vidConditioning](https://docs.comfy.org/built-in-nodes/SvdImg2vidConditioning) — 此节点专为视频生成任务的条件数据生成而设计，特别适用于 SVDimg2vid 模型。

#### 潜变量


##### Video

- [TrimVideoLatent 节点](https://docs.comfy.org/built-in-nodes/latent/video/trim-video-latent) — 裁剪潜在空间中的视频帧

#### 采样


##### Custom Sampling


###### Samplers

- [SamplerDpmpp2mSde](https://docs.comfy.org/built-in-nodes/SamplerDpmpp2mSde) — 此节点旨在为 DPMPP2MSDE 模型生成采样器，支持根据指定的求解器类型、噪声水平和计算设备偏好创建样本。
- [SamplerDpmppSde](https://docs.comfy.org/built-in-nodes/SamplerDpmppSde) — 此节点用于为 DPM++ SDE（随机微分方程）模型生成采样器。

#### 高级

- [ByteDanceImageNode](https://docs.comfy.org/built-in-nodes/ByteDanceImageNode) — 此文档由 AI 生成。
- [ByteDanceImageReferenceNode](https://docs.comfy.org/built-in-nodes/ByteDanceImageReferenceNode) — 字节跳动图像参考节点通过文本提示和一到四张参考图像生成视频。
- [ComfyCloudFlux2TextToImageNode](https://docs.comfy.org/built-in-nodes/ComfyCloudFlux2TextToImageNode) — 在 Comfy Cloud GPU 上运行 Flux 2 dev 文本到图像模型，并返回生成的图像。
- [ComfyCloudMageFlowTextToImageNode](https://docs.comfy.org/built-in-nodes/ComfyCloudMageFlowTextToImageNode) — 此节点通过将请求发送到 Comfy Cloud 中的 Mage-Flow 文本到图像工作流，从文本提示词生成图像。
- [ComfyCloudMageFlowTurboTextToImageNode](https://docs.comfy.org/built-in-nodes/ComfyCloudMageFlowTurboTextToImageNode) — 此 Comfy Cloud 节点使用 Mage-Flow Turbo 工作流（mage-flow-turbo/text-to-image）根据文本提示词生成图像。
- [ComfyCloudZImageTurboNode](https://docs.comfy.org/built-in-nodes/ComfyCloudZImageTurboNode) — 此节点使用 Z-Image Turbo 模型根据文本提示生成图像，仅需 8 步即可完成。
- [IdeogramV1](https://docs.comfy.org/built-in-nodes/IdeogramV1) — IdeogramV1 节点通过 API 使用 Ideogram V1 模型生成图像。
- [IdeogramV2](https://docs.comfy.org/built-in-nodes/IdeogramV2) — Ideogram V2 节点使用 Ideogram V2 AI 模型生成图像。
- [KlingCameraControlI2VNode](https://docs.comfy.org/built-in-nodes/KlingCameraControlI2VNode) — 此节点可将静态图像转换为具有专业摄像机运镜的电影级视频。
- [KlingCameraControls](https://docs.comfy.org/built-in-nodes/KlingCameraControls) — Kling 摄像机控制节点允许您配置各种摄像机移动和旋转参数，以便在视频生成中创建运动控制效果。
- [KlingCameraControlT2VNode](https://docs.comfy.org/built-in-nodes/KlingCameraControlT2VNode) — Kling Text to Video Camera Control Node transforms text into cinematic videos with professional camera movements that simulate real-world cinematography.
- [KlingDualCharacterVideoEffectNode](https://docs.comfy.org/built-in-nodes/KlingDualCharacterVideoEffectNode) — The Kling Dual Character Video Effect Node creates videos with special effects based on the selected scene.
- [KlingSingleImageVideoEffectNode](https://docs.comfy.org/built-in-nodes/KlingSingleImageVideoEffectNode) — Kling Single Image Video Effect 节点基于单张参考图像创建具有不同特效的视频。
- [KlingVideoExtendNode](https://docs.comfy.org/built-in-nodes/KlingVideoExtendNode) — Kling 视频扩展节点允许您扩展由其他 Kling 节点生成的视频。
- [KlingVirtualTryOnNode](https://docs.comfy.org/built-in-nodes/KlingVirtualTryOnNode) — Kling 虚拟试穿节点。
- [LoopIteration](https://docs.comfy.org/built-in-nodes/LoopIteration) — 此节点为循环式工作流提供迭代元数据。
- [LoopProgress](https://docs.comfy.org/built-in-nodes/LoopProgress) — LoopProgress 是一个仅用于开发的辅助节点，用于向 ComfyUI 服务器界面报告循环进度。
- [LoopResult](https://docs.comfy.org/built-in-nodes/LoopResult) — LoopResult 是仅面向开发者的输出节点，用于标记循环块的结束点。
- [LtxvApiImageToVideo](https://docs.comfy.org/built-in-nodes/LtxvApiImageToVideo) — LTXV Image To Video 节点可从单张起始图像生成专业级质量的视频。
- [LtxvApiTextToVideo](https://docs.comfy.org/built-in-nodes/LtxvApiTextToVideo) — LTXV Text To Video 节点根据文本描述生成专业质量的视频。
- [MoonvalleyImg2VideoNode](https://docs.comfy.org/built-in-nodes/MoonvalleyImg2VideoNode) — 此文档由 AI 生成。
- [MoonvalleyTxt2VideoNode](https://docs.comfy.org/built-in-nodes/MoonvalleyTxt2VideoNode) — 此文档由AI生成。
- [MoonvalleyVideo2VideoNode](https://docs.comfy.org/built-in-nodes/MoonvalleyVideo2VideoNode) — 此节点基于文本描述，将输入视频转换为新视频。
- [OpenAIDalle2](https://docs.comfy.org/built-in-nodes/OpenAIDalle2) — 通过 OpenAI 的 DALL·E 2 端点同步生成图像。
- [OpenAIDalle3](https://docs.comfy.org/built-in-nodes/OpenAIDalle3) — 通过 OpenAI 的 DALL·E 3 端点同步生成图像。
- [SeedVR2ProgressiveSampler](https://docs.comfy.org/built-in-nodes/SeedVR2ProgressiveSampler) — 用于 SeedVR2 原生工作流的顺序时间分块采样器。
- [StabilityAudioInpaint](https://docs.comfy.org/built-in-nodes/StabilityAudioInpaint) — 使用文本指令转换现有音频样本的一部分。
- [StabilityAudioToAudio](https://docs.comfy.org/built-in-nodes/StabilityAudioToAudio) — 此文档由 AI 生成。
- [StabilityStableImageSD_3_5Node](https://docs.comfy.org/built-in-nodes/StabilityStableImageSD_3_5Node) — 此节点使用 Stability AI 的 Stable Diffusion 3.5 模型同步生成图像。
- [StabilityStableImageUltraNode](https://docs.comfy.org/built-in-nodes/StabilityStableImageUltraNode) — 此文档由 AI 生成。
- [StabilityTextToAudio](https://docs.comfy.org/built-in-nodes/StabilityTextToAudio) — 根据文本描述生成高质量的音乐和音效。
- [StabilityUpscaleConservativeNode](https://docs.comfy.org/built-in-nodes/StabilityUpscaleConservativeNode) — 以最小改动将图像放大至 4K 分辨率。
- [StabilityUpscaleCreativeNode](https://docs.comfy.org/built-in-nodes/StabilityUpscaleCreativeNode) — 以最小改动将图像放大至 4K 分辨率。
- [StabilityUpscaleFastNode](https://docs.comfy.org/built-in-nodes/StabilityUpscaleFastNode) — 通过 Stability API 调用，将图像快速放大至原始尺寸的 4 倍。
- [TripoRefineNode](https://docs.comfy.org/built-in-nodes/TripoRefineNode) — 此文档由 AI 生成。
- [VeoVideoGenerationNode](https://docs.comfy.org/built-in-nodes/VeoVideoGenerationNode) — 此节点使用 Google 的 Veo 2 API 根据文本提示生成视频。

##### Debug

- [EasyCache](https://docs.comfy.org/built-in-nodes/EasyCache) — EasyCache 节点向扩散模型添加原生缓存系统，通过复用先前已计算步骤的结果而不是重新计算每个步骤来加速采样。
- [LazyCache](https://docs.comfy.org/built-in-nodes/LazyCache) — LazyCache 是 EasyCache 的一个实验性、自制版本，它在采样期间添加缓存以减少计算量。
- [ModelComputeDtype](https://docs.comfy.org/built-in-nodes/ModelComputeDtype) — ModelComputeDtype 节点会更改模型在处理过程中使用的计算数据类型（精度）。

##### Guidance

- [CFGNorm](https://docs.comfy.org/built-in-nodes/CFGNorm) — CFGNorm 通过比较条件预测与引导预测的大小（范数），并对结果进行重新缩放，从而调整扩散模型中无分类器引导（CFG）的应用方式。
- [CFGZeroStar](https://docs.comfy.org/built-in-nodes/CFGZeroStar) — CFGZeroStar 节点对扩散模型应用了一种专门的引导缩放技术。
- [LTXVModalityGuidance](https://docs.comfy.org/built-in-nodes/LTXVModalityGuidance) — 此节点对 LTXV-AV 模型应用跨模态（音频-视频）引导。
- [LTXVSpatioTemporalGuidance](https://docs.comfy.org/built-in-nodes/LTXVSpatioTemporalGuidance) — 此节点通过在每个采样步骤额外运行一次前向传播，提升 LTXV 视频生成的空间细节与运动连贯性。
- [NAGuidance](https://docs.comfy.org/built-in-nodes/NAGuidance) — NAGuidance 节点将归一化注意力引导（Normalized Attention Guidance）应用于模型。
- [SkipLayerGuidanceDiT](https://docs.comfy.org/built-in-nodes/SkipLayerGuidanceDiT) — 通过使用另一组带有跳过层的 CFG 负向引导，增强对详细结构的引导。
- [SkipLayerGuidanceDiTSimple](https://docs.comfy.org/built-in-nodes/SkipLayerGuidanceDiTSimple) — SkipLayerGuidanceDiT 节点的简化版本，仅在去噪过程中修改无条件传递。
- [SkipLayerGuidanceSD3](https://docs.comfy.org/built-in-nodes/SkipLayerGuidanceSD3) — SkipLayerGuidanceSD3 节点通过应用一组带有跳过层的额外无分类器引导，增强对详细结构的引导。
- [TCFG](https://docs.comfy.org/built-in-nodes/TCFG) — TCFG（切向阻尼 CFG）在采样过程中优化无条件（负向）预测，使其更好地与条件（正向）预测对齐。

##### Hooks

- [ConditioningTimestepsRange](https://docs.comfy.org/built-in-nodes/ConditioningTimestepsRange) — ConditioningTimestepsRange 节点会创建三个不同的时间步长范围，用于控制生成过程中条件效果的生效时机。

###### Clip

- [SetClipHooks](https://docs.comfy.org/built-in-nodes/SetClipHooks) — SetClipHooks 节点允许您对 CLIP 模型应用自定义钩子，从而对其行为进行高级修改。

###### Combine

- [CombineHooks](https://docs.comfy.org/built-in-nodes/CombineHooks) — 组合钩子 [2] 节点将两个钩子组合合并为一个统一的组合钩子。
- [CombineHooksEight](https://docs.comfy.org/built-in-nodes/CombineHooksEight) — 组合钩子 [8] 节点将最多八个不同的钩子组合合并为一个统一的组合钩子组合。
- [CombineHooksFour](https://docs.comfy.org/built-in-nodes/CombineHooksFour) — 组合钩子 [4] 节点将最多四个独立的钩子组合合并为一个组合钩子组。

###### Cond Pair

- [PairConditioningCombine](https://docs.comfy.org/built-in-nodes/PairConditioningCombine) — PairConditioningCombine 节点将两组独立的条件配对（每组包含一个正向条件和一个负向条件）合并为一组组合配对。
- [PairConditioningSetDefaultAndCombine](https://docs.comfy.org/built-in-nodes/PairConditioningSetDefaultAndCombine) — PairConditioningSetDefaultAndCombine 节点用于设置默认条件值，并将其与输入的条件数据结合。
- [PairConditioningSetProperties](https://docs.comfy.org/built-in-nodes/PairConditioningSetProperties) — The PairConditioningSetProperties node allows you to modify properties of both positive and negative conditioning pairs at the same time.
- [PairConditioningSetPropertiesAndCombine](https://docs.comfy.org/built-in-nodes/PairConditioningSetPropertiesAndCombine) — PairConditioningSetPropertiesAndCombine 节点通过将新的条件数据应用于现有的正面和负面条件输入，来修改和组合条件对。

###### Cond Single

- [ConditioningSetDefaultAndCombine](https://docs.comfy.org/built-in-nodes/ConditioningSetDefaultAndCombine) — 此节点通过基于钩子的系统，将主要条件输入与默认条件输入相结合。
- [ConditioningSetProperties](https://docs.comfy.org/built-in-nodes/ConditioningSetProperties) — ConditioningSetProperties 节点通过调整强度、区域设置，并应用可选的遮罩、钩子或时间步范围，来修改条件数据（conditioning data）的属性。
- [ConditioningSetPropertiesAndCombine](https://docs.comfy.org/built-in-nodes/ConditioningSetPropertiesAndCombine) — ConditioningSetPropertiesAndCombine 节点通过将新条件输入中的属性应用于现有条件输入来修改条件数据。

###### Create

- [CreateHookLora](https://docs.comfy.org/built-in-nodes/CreateHookLora) — 此节点用于生成钩子对象，以便对模型应用 LoRA（低秩适配）修改。
- [CreateHookLoraModelOnly](https://docs.comfy.org/built-in-nodes/CreateHookLoraModelOnly) — 此节点创建一个仅应用于模型组件的 LoRA（低秩适配）钩子，完全保持 CLIP 组件不变。
- [CreateHookModelAsLora](https://docs.comfy.org/built-in-nodes/CreateHookModelAsLora) — 此节点通过加载检查点权重并对模型和 CLIP 组件应用强度调整，以 LoRA（低秩适应）方式创建钩子模型。
- [CreateHookModelAsLoraModelOnly](https://docs.comfy.org/built-in-nodes/CreateHookModelAsLoraModelOnly) — 此节点创建一个钩子，将 LoRA（低秩适配）模型应用于神经网络，仅修改模型的组件部分。

###### Manual

- [SetModelHooksOnCond](https://docs.comfy.org/built-in-nodes/SetModelHooksOnCond) — 此节点将自定义钩子附加到条件数据上，允许您在模型执行期间拦截并修改条件处理过程。

###### Scheduling

- [CreateHookKeyframe](https://docs.comfy.org/built-in-nodes/CreateHookKeyframe) — 创建钩子关键帧节点允许您在生成过程中定义钩子行为发生变化的特定点。
- [CreateHookKeyframesFromFloats](https://docs.comfy.org/built-in-nodes/CreateHookKeyframesFromFloats) — 此文档由 AI 生成。
- [CreateHookKeyframesInterpolated](https://docs.comfy.org/built-in-nodes/CreateHookKeyframesInterpolated) — 此文档由 AI 生成。
- [SetHookKeyframes](https://docs.comfy.org/built-in-nodes/SetHookKeyframes) — 设置钩子关键帧节点允许您对现有钩子组应用关键帧调度。

##### Loaders

- [DeprecatedCheckpointLoader](https://docs.comfy.org/built-in-nodes/DeprecatedCheckpointLoader) — CheckpointLoader 节点专为高级加载操作而设计，具体用于加载模型检查点及其配置。
- [DeprecatedDiffusersLoader](https://docs.comfy.org/built-in-nodes/DeprecatedDiffusersLoader) — DiffusersLoader 节点专为从 diffusers 库加载模型而设计，能够根据提供的模型路径处理 UNet、CLIP 和 VAE 模型的加载。

##### Model Merging

- [SaveLoRANode](https://docs.comfy.org/built-in-nodes/SaveLoRANode) — SaveLoRA 节点将 LoRA（低秩适配）模型保存到您的输出目录。

##### Multigpu

- [MultiGPU_Options](https://docs.comfy.org/built-in-nodes/MultiGPU_Options) — 内置节点参考页（官方暂无中文说明）
- [MultiGPU_WorkUnits](https://docs.comfy.org/built-in-nodes/MultiGPU_WorkUnits) — 内置节点参考页（官方暂无中文说明）
- [SelectCLIPDevice](https://docs.comfy.org/built-in-nodes/SelectCLIPDevice) — 内置节点参考页（官方暂无中文说明）
- [SelectModelDevice](https://docs.comfy.org/built-in-nodes/SelectModelDevice) — Select Model Device 节点允许你手动选择扩散模型在哪个设备（CPU 或特定 GPU）上运行。
- [SelectVAEDevice](https://docs.comfy.org/built-in-nodes/SelectVAEDevice) — 内置节点参考页（官方暂无中文说明）

### Model


#### Conditioning

- [AudioEncoderEncode](https://docs.comfy.org/built-in-nodes/AudioEncoderEncode) — AudioEncoderEncode 节点使用音频编码器模型将音频转换为编码表示。
- [CLIPSetLastLayer](https://docs.comfy.org/built-in-nodes/ClipSetLastLayer) — CLIP Set Last Layer 是 ComfyUI 中的一个核心节点，用于控制 CLIP 模型的处理深度。
- [CLIPTextEncode](https://docs.comfy.org/built-in-nodes/ClipTextEncode) — Encodes 一段文本提示词，使用 CLIP 模型将其编码为嵌入，可用于引导扩散模型生成特定图像。
- [CLIPTextEncodeControlnet](https://docs.comfy.org/built-in-nodes/CLIPTextEncodeControlnet) — CLIP Text Encode (Controlnet) 节点使用 CLIP 模型对文本提示进行编码，并将生成的文本编码添加到现有的条件数据中。
- [CLIPVisionEncode](https://docs.comfy.org/built-in-nodes/ClipVisionEncode) — CLIP Vision Encode 节点是 ComfyUI 中的图像编码节点，用于通过 CLIP Vision 模型将输入图像转换为视觉特征向量。
- [InpaintModelConditioning](https://docs.comfy.org/built-in-nodes/InpaintModelConditioning) — InpaintModelConditioning 节点旨在简化修复模型的条件处理流程，支持集成和操作多种条件输入以定制修复输出。
- [NormalizeVideoLatentStart](https://docs.comfy.org/built-in-nodes/NormalizeVideoLatentStart) — 此节点会调整视频 latent 的前几帧，使其看起来更接近后续帧。
- [PiDConditioning](https://docs.comfy.org/built-in-nodes/PiDConditioning) — 将 latent 和 degradesigma 值附加到 CONDITIONING，以便用于 PiD 解码或放大。
- [ReferenceLatent](https://docs.comfy.org/built-in-nodes/ReferenceLatent) — 此节点为编辑模型设置引导 latent。
- [ReferenceTimbreAudio](https://docs.comfy.org/built-in-nodes/ReferenceTimbreAudio) — 此节点为 "ace step 1.5" 流程设置参考音频。
- [SaveConditioning](https://docs.comfy.org/built-in-nodes/SaveConditioning) — 此节点将单个 conditioning 保存到输出文件夹中，保存为 safetensors 文件。
- [SeedVR2Conditioning](https://docs.comfy.org/built-in-nodes/SeedVR2Conditioning) — 从 VAE 潜空间构建正向和负向条件，以供 SeedVR2 模型使用。
- [StyleModelApply](https://docs.comfy.org/built-in-nodes/StyleModelApply) — 此节点将样式模型应用于给定的 conditioning，基于 CLIP 视觉模型的输出增强或改变其样式。
- [T5TokenizerOptions](https://docs.comfy.org/built-in-nodes/T5TokenizerOptions) — 内置节点参考页（官方暂无中文说明）
- [unCLIPConditioning](https://docs.comfy.org/built-in-nodes/unCLIPConditioning) — 此节点旨在将 CLIP 视觉输出整合到条件处理过程中，根据指定的强度和噪声增强参数调整这些输出的影响。

##### Ace

- [TextEncodeAceStepAudio](https://docs.comfy.org/built-in-nodes/TextEncodeAceStepAudio) — TextEncodeAceStepAudio 节点通过将标签（tags）和歌词（lyrics）组合为 token 来处理用于音频条件化的文本输入，并使用可调节的歌词强度进行编码。
- [TextEncodeAceStepAudio1.5](https://docs.comfy.org/built-in-nodes/TextEncodeAceStepAudio1.5) — TextEncodeAceStepAudio1.5 节点用于准备与 AceStepAudio 1.5 模型配合使用的文本及音频相关元数据。

##### Autoregressive

- [ARVideoI2V](https://docs.comfy.org/built-in-nodes/ARVideoI2V) — 此节点为使用 Causal Forcing 或 Self-Forcing 的 AR（自回归）视频模型准备图像到视频生成设置。

##### Bernini

- [BerniniConditioning](https://docs.comfy.org/built-in-nodes/BerniniConditioning) — BerniniConditioning 节点为 Wan2.2-A14B 模型准备视频和图像条件数据。

##### Boogu

- [TextEncodeBooguEdit](https://docs.comfy.org/built-in-nodes/TextEncodeBooguEdit) — 此节点为使用 Boogu 进行图像编辑准备 conditioning。

##### Controlnet

- [ControlNetApply](https://docs.comfy.org/built-in-nodes/ControlNetApply) — 使用 controlNet 需要对输入图像进行预处理。
- [ControlNetApplyAdvanced](https://docs.comfy.org/built-in-nodes/ControlNetApplyAdvanced) — 此节点根据图像和控制网模型，对 conditioning 数据应用高级控制网变换。
- [ControlNetApplySD3](https://docs.comfy.org/built-in-nodes/ControlNetApplySD3) — 此节点将 ControlNet 引导应用于 Stable Diffusion 3 条件输入。
- [ControlNetInpaintingAliMamaApply](https://docs.comfy.org/built-in-nodes/ControlNetInpaintingAliMamaApply) — ControlNetInpaintingAliMamaApply 节点通过将正向和负向条件与控制图像和遮罩相结合，为图像修复任务应用 ControlNet 条件。
- [SetUnionControlNetType](https://docs.comfy.org/built-in-nodes/SetUnionControlNetType) — SetUnionControlNetType 节点让你选择控制网络使用哪种控制类型。

##### Cosmos

- [CosmosImageToVideoLatent](https://docs.comfy.org/built-in-nodes/CosmosImageToVideoLatent) — The CosmosImageToVideoLatent node creates a video latent representation from input images.
- [CosmosPredict2ImageToVideoLatent](https://docs.comfy.org/built-in-nodes/CosmosPredict2ImageToVideoLatent) — 为 Cosmos Predict2 图像到视频工作流创建视频潜变量。

##### Flux

- [CLIPTextEncodeFlux](https://docs.comfy.org/built-in-nodes/ClipTextEncodeFlux) — CLIPTextEncodeFlux 是一个专为 Flux 架构设计的文本编码节点。
- [FluxDisableGuidance](https://docs.comfy.org/built-in-nodes/FluxDisableGuidance) — 此节点完全禁用 Flux 及类似模型上的 guidance 嵌入。
- [FluxGuidance](https://docs.comfy.org/built-in-nodes/FluxGuidance) — 内置节点参考页（官方暂无中文说明）
- [FluxKontextImageScale](https://docs.comfy.org/built-in-nodes/FluxKontextImageScale) — 此节点根据输入图像的宽高比，使用 Lanczos 算法将输入图像缩放至 Flux Kontext 模型训练时使用的最佳尺寸。
- [FluxKontextMultiReferenceLatentMethod](https://docs.comfy.org/built-in-nodes/FluxKontextMultiReferenceLatentMethod) — FluxKontextMultiReferenceLatentMethod 节点通过在其中存储选定的参考潜变量方法来更新 conditioning 数据。

##### Gligen

- [GLIGENTextBoxApply](https://docs.comfy.org/built-in-nodes/GLIGENTextBoxApply) — GLIGENTextBoxApply 节点旨在将基于文本的条件信息集成到生成模型的输入中，具体通过应用文本框参数并使用 CLIP 模型对其进行编码。

##### Hidream

- [CLIPTextEncodeHiDream](https://docs.comfy.org/built-in-nodes/CLIPTextEncodeHiDream) — CLIPTextEncodeHiDream 节点使用不同的语言模型（CLIP-L、CLIP-G、T5-XXL 和 LLaMA）处理四个独立的文本输入，并将它们组合成单个 conditioning 输出。
- [HiDreamO1ReferenceImages](https://docs.comfy.org/built-in-nodes/HiDreamO1ReferenceImages) — 此节点将参考图像附加到正向和负向条件上，使下游节点可以使用这些参考图像来引导生成。

##### Hunyuan 3d

- [Hunyuan3Dv2Conditioning](https://docs.comfy.org/built-in-nodes/Hunyuan3Dv2Conditioning) — Hunyuan3Dv2Conditioning 节点处理 CLIP 视觉输出，为 3D 模型生成条件数据。
- [Hunyuan3Dv2ConditioningMultiView](https://docs.comfy.org/built-in-nodes/Hunyuan3Dv2ConditioningMultiView) — Hunyuan3Dv2ConditioningMultiView 节点会将最多四个视角（front、left、back 和 right）的 CLIP 视觉输出组合成单个多视角条件。

##### Hunyuan Image

- [CLIPTextEncodeHunyuanDiT](https://docs.comfy.org/built-in-nodes/ClipTextEncodeHunyuanDit) — CLIPTextEncodeHunyuanDiT 节点将文本描述转换为 HunyuanDiT 模型能够理解的格式。

##### Hunyuan Video

- [HunyuanImageToVideo](https://docs.comfy.org/built-in-nodes/HunyuanImageToVideo) — HunyuanImageToVideo 节点使用 Hunyuan 视频模型将图像转换为视频潜在表示。
- [HunyuanRefinerLatent](https://docs.comfy.org/built-in-nodes/HunyuanRefinerLatent) — HunyuanRefinerLatent 节点为 Hunyuan 视频精炼过程准备 conditioning 和 latent 数据。
- [HunyuanVideo15ImageToVideo](https://docs.comfy.org/built-in-nodes/HunyuanVideo15ImageToVideo) — HunyuanVideo15ImageToVideo 节点基于 HunyuanVideo 1.5 模型，为视频生成准备条件（conditioning）和潜空间数据。
- [HunyuanVideo15SuperResolution](https://docs.comfy.org/built-in-nodes/HunyuanVideo15SuperResolution) — HunyuanVideo15SuperResolution 节点为视频超分辨率过程准备条件数据。
- [TextEncodeHunyuanVideo_ImageToVideo](https://docs.comfy.org/built-in-nodes/TextEncodeHunyuanVideo_ImageToVideo) — TextEncodeHunyuanVideoImageToVideo 节点通过将文本提示与参考图像的视觉信息相结合，为图像转视频生成创建条件数据。

##### Instructpix2pix

- [InstructPixToPixConditioning](https://docs.comfy.org/built-in-nodes/InstructPixToPixConditioning) — InstructPixToPixConditioning 节点通过将正向和负向文本提示与图像数据相结合，为 InstructPix2Pix 图像编辑准备条件数据。

##### Joyimage

- [TextEncodeJoyImageEdit](https://docs.comfy.org/built-in-nodes/TextEncodeJoyImageEdit) — 此节点将文本提示和可选图像编码为条件数据，用于 JoyImage 模型。

##### Kandinsky

- [CLIPTextEncodeKandinsky5](https://docs.comfy.org/built-in-nodes/CLIPTextEncodeKandinsky5) — CLIP Text Encode (Kandinsky 5) 节点为 Kandinsky 5 模型准备文本提示词。
- [Kandinsky5ImageToVideo](https://docs.comfy.org/built-in-nodes/Kandinsky5ImageToVideo) — Kandinsky5ImageToVideo 节点使用 Kandinsky 模型为视频生成准备条件数据和 latent 数据。

##### Lotus

- [LotusConditioning](https://docs.comfy.org/built-in-nodes/LotusConditioning) — LotusConditioning 节点为 Lotus 模型提供固定的、预计算的条件化嵌入。

##### Ltxv

- [GetICLoRAParameters](https://docs.comfy.org/built-in-nodes/GetICLoRAParameters) — 此节点从加载了 LoRA 的模型中读取元数据，以提取 IC-LoRA 参数，例如参考下采样因子（referencedownscalefactor）。
- [LTXVAddGeneratedKeyframes](https://docs.comfy.org/built-in-nodes/LTXVAddGeneratedKeyframes) — LTXV Add Generated Keyframes 节点将细节关键帧追加到视频 latent。
- [LTXVAddGuide](https://docs.comfy.org/built-in-nodes/LTXVAddGuide) — The LTXVAddGuide 节点通过 VAE 编码器对输入图像或视频进行编码，并将它们作为引导关键帧添加到潜空间视频序列中。
- [LTXVAddLatentGuide](https://docs.comfy.org/built-in-nodes/LTXVAddLatentGuide) — LTXV Add Latent Guide 节点将已编码的 latent 固定为引导，适用于引导来自较早阶段而非图像的情况。
- [LTXVConditioning](https://docs.comfy.org/built-in-nodes/LTXVConditioning) — LTXVConditioning 节点为视频生成模型的正向和负向 conditioning 输入添加帧率信息。
- [LTXVCropGuides](https://docs.comfy.org/built-in-nodes/LTXVCropGuides) — LTXVCropGuides 节点用于从视频生成工作流中移除关键帧引导数据。
- [LTXVDurationPredictor](https://docs.comfy.org/built-in-nodes/LTXVDurationPredictor) — 此节点使用由 ModelPatchLoader 加载的 LTX 2.4 duration head，根据文本提示预测自然镜头时长，然后将结果对齐到 VAE 的 8k+1 帧网格。
- [LTXVGeneratedKeyframesToGuides](https://docs.comfy.org/built-in-nodes/LTXVGeneratedKeyframesToGuides) — LTXV Generated Keyframes to Guides 节点将来自较早阶段生成的关键帧固定为后续画布上的冻结图像引导。
- [LTXVImgToVideo](https://docs.comfy.org/built-in-nodes/LTXVImgToVideo) — LTXVImgToVideo 将输入图像转换为视频潜在表示，以供视频生成模型使用。
- [LTXVImgToVideoInplace](https://docs.comfy.org/built-in-nodes/LTXVImgToVideoInplace) — LTXVImgToVideoInplace 将输入图像编码到潜在空间，并将这些编码帧放置在现有潜在视频的开头。
- [LTXVReferenceAudio](https://docs.comfy.org/built-in-nodes/LTXVReferenceAudio) — LTXV Reference Audio 将说话人的语音身份从参考音频片段迁移到生成的音频中。
- [LTXVSeparateGeneratedKeyframes](https://docs.comfy.org/built-in-nodes/LTXVSeparateGeneratedKeyframes) — 内置节点参考页（官方暂无中文说明）

##### Lumina

- [CLIPTextEncodeLumina2](https://docs.comfy.org/built-in-nodes/CLIPTextEncodeLumina2) — 此节点使用 CLIP 模型将系统提示和用户提示编码为嵌入，该嵌入可用于引导扩散模型生成特定图像。

##### Mage

- [TextEncodeMageFlowEdit](https://docs.comfy.org/built-in-nodes/TextEncodeMageFlowEdit) — 内置节点参考页（官方暂无中文说明）

##### Ming Image

- [TextEncodeMingImageEdit](https://docs.comfy.org/built-in-nodes/TextEncodeMingImageEdit) — Text Encode Ming Image Edit 将文本提示词编码为用于 Ming 图像编辑的 CONDITIONING，并可选择混入参考图像。

##### Minimax

- [MiniMaxH3AddGuide](https://docs.comfy.org/built-in-nodes/MiniMaxH3AddGuide) — 此节点可将图像、短片段、音频，或带音轨的片段锚定到 MiniMax H3 视频的任意帧。
- [MiniMaxH3ImageToVideo](https://docs.comfy.org/built-in-nodes/MiniMaxH3ImageToVideo) — 此节点准备使用 MiniMax H3 模型生成视频所需的 conditioning 和空 latent。
- [MiniMaxH3ReferenceToVideo](https://docs.comfy.org/built-in-nodes/MiniMaxH3ReferenceToVideo) — MiniMax H3 Reference to Video 创建 MiniMax H3 参考视频生成所需的文本条件化数据和空音频-视频 latent。

##### Minimax Music

- [MiniMaxMusic3TextEncode](https://docs.comfy.org/built-in-nodes/MiniMaxMusic3TextEncode) — MiniMax Music3 Text Encode 使用 MiniMax Music3 CLIP 模型将文本描述和歌词转换为用于音乐生成的声学条件序列。

##### Photomaker

- [PhotoMakerEncode](https://docs.comfy.org/built-in-nodes/PhotoMakerEncode) — PhotoMakerEncode 节点将参考图像与文本提示词相结合，为图像生成创建条件数据。

##### Pixart

- [CLIPTextEncodePixArtAlpha](https://docs.comfy.org/built-in-nodes/CLIPTextEncodePixArtAlpha) — 对文本进行编码，并为 PixArt Alpha 设置分辨率条件。

##### Qwen Image

- [QwenImage21Cache](https://docs.comfy.org/built-in-nodes/QwenImage21Cache) — QwenImage21Cache 节点用于配置 Qwen-Image 2.1 模型的 KV 前缀缓存：缓存键和值的存储位置以及存储精度。
- [TextEncodeQwenImage21](https://docs.comfy.org/built-in-nodes/TextEncodeQwenImage21) — TextEncodeQwenImage21 节点为 Qwen-Image 2.1 模型编码提示词和负面提示词，并可选择附加参考图像。
- [TextEncodeQwenImageEdit](https://docs.comfy.org/built-in-nodes/TextEncodeQwenImageEdit) — TextEncodeQwenImageEdit 节点将文本提示和可选图像转换为用于图像生成或编辑的条件数据。
- [TextEncodeQwenImageEditPlus](https://docs.comfy.org/built-in-nodes/TextEncodeQwenImageEditPlus) — TextEncodeQwenImageEditPlus 节点处理一个文本提示词以及最多三张可选图像，用于生成图像生成或编辑任务所需的 conditioning 数据。

##### Stable Audio

- [ConditioningStableAudio](https://docs.comfy.org/built-in-nodes/ConditioningStableAudio) — ConditioningStableAudio 节点用于在音频生成时向正负条件输入中添加时序信息。

##### Stable Cascade

- [StableCascade_StageB_Conditioning](https://docs.comfy.org/built-in-nodes/StableCascade_StageB_Conditioning) — StableCascadeStageBConditioning 节点通过将现有的 conditioning 信息与 Stage C 生成的先验潜在表示相结合，为 Stable Cascade Stage B 生成准备 conditioning 数据。

##### Stable Diffusion

- [CLIPTextEncodeSD3](https://docs.comfy.org/built-in-nodes/CLIPTextEncodeSD3) — CLIPTextEncodeSD3 通过使用不同的 CLIP 模型对多个文本提示进行编码，为 Stable Diffusion 3 模型处理文本输入。
- [CLIPTextEncodeSDXL](https://docs.comfy.org/built-in-nodes/ClipTextEncodeSdxl) — 此节点专门用于通过针对 SDXL 架构定制的 CLIP 模型对文本输入进行编码。
- [CLIPTextEncodeSDXLRefiner](https://docs.comfy.org/built-in-nodes/ClipTextEncodeSdxlRefiner) — 此节点专为 SDXL Refiner 模型设计，通过引入美学评分和尺寸信息，将文本提示转换为条件信息，以增强生成任务的条件，从而提升最终的细化效果。

##### Stable Diffusion Upscaler

- [SD_4XUpscale_Conditioning](https://docs.comfy.org/built-in-nodes/SD_4XUpscale_Conditioning) — SD4XUpscaleConditioning 节点用于为使用扩散模型放大图像准备条件数据。

##### Stable Video 3d

- [SV3D_Conditioning](https://docs.comfy.org/built-in-nodes/SV3D_Conditioning) — SV3DConditioning 使用 SV3D 模型为 3D 视频生成准备条件数据。

##### Stable Zero123

- [StableZero123_Conditioning](https://docs.comfy.org/built-in-nodes/StableZero123_Conditioning) — StableZero123Conditioning 节点处理输入图像和相机角度，为 3D 模型生成任务生成条件数据和潜空间表示。
- [StableZero123_Conditioning_Batched](https://docs.comfy.org/built-in-nodes/StableZero123_Conditioning_Batched) — StableZero123ConditioningBatched 节点用于准备从单张输入图像生成 3D 模型的 conditioning 数据。

##### Transform

- [ConditioningConcat](https://docs.comfy.org/built-in-nodes/ConditioningConcat) — ConditioningConcat 节点用于拼接条件向量，具体操作是将 'conditioningfrom' 向量合并到 'conditioningto' 向量中。
- [ConditioningMultiply](https://docs.comfy.org/built-in-nodes/ConditioningMultiply) — 此节点将 conditioning 值乘以指定系数，使您能够缩放 conditioning 对生成过程的影响。
- [ConditioningSetArea](https://docs.comfy.org/built-in-nodes/ConditioningSetArea) — 此节点旨在通过设置条件上下文中的特定区域来修改条件信息。
- [ConditioningSetAreaPercentage](https://docs.comfy.org/built-in-nodes/ConditioningSetAreaPercentage) — ConditioningSetAreaPercentage 节点专门用于基于百分比值调整条件元素的区域影响范围。
- [ConditioningSetAreaPercentageVideo](https://docs.comfy.org/built-in-nodes/ConditioningSetAreaPercentageVideo) — ConditioningSetAreaPercentageVideo 节点通过定义视频生成的特定区域和时间范围来修改 conditioning 数据。
- [ConditioningSetAreaStrength](https://docs.comfy.org/built-in-nodes/ConditioningSetAreaStrength) — 此节点用于修改给定条件集的强度属性，从而调整条件对生成过程的影响程度或强度。
- [ConditioningSetMask](https://docs.comfy.org/built-in-nodes/ConditioningSetMask) — 此节点旨在通过将指定强度的遮罩应用于特定区域来修改生成模型的条件控制。
- [ConditioningSetTimestepRange](https://docs.comfy.org/built-in-nodes/ConditioningSetTimestepRange) — 此节点旨在通过设置特定的时间步长范围来调整条件作用的时间维度。
- [ConditioningZeroOut](https://docs.comfy.org/built-in-nodes/ConditioningZeroOut) — 此节点将 conditioning 数据结构中的特定元素归零，从而有效消除它们在后续处理步骤中的影响。

##### Trellis

- [Pixal3DConditioning](https://docs.comfy.org/built-in-nodes/Pixal3DConditioning) — Pixal3DConditioning 节点为 Trellis2 3D 生成流程准备图像条件。
- [Pixal3DMultiViewConditioning](https://docs.comfy.org/built-in-nodes/Pixal3DMultiViewConditioning) — Pixal3D Multi-View Conditioning 节点从固定的轨道相机 rig 构建条件数据：前、左、后、右四个视图彼此相隔 90 度，并完全按照取景构图使用。
- [Trellis2Conditioning](https://docs.comfy.org/built-in-nodes/Trellis2Conditioning) — Trellis2Conditioning 将输入图像转换为 TRELLIS.2 模型的条件数据。
- [Trellis2ShapeStage](https://docs.comfy.org/built-in-nodes/Trellis2ShapeStage) — 此节点用于设置 Trellis2 流水线的第一次形状生成采样阶段。
- [Trellis2TextureStage](https://docs.comfy.org/built-in-nodes/Trellis2TextureStage) — 此节点为 Trellis2 生成设置纹理阶段采样流程。
- [Trellis2UpsampleStage](https://docs.comfy.org/built-in-nodes/Trellis2UpsampleStage) — 此节点将 512 分辨率的形状 latent 上采样为高分辨率稀疏坐标，并在目标分辨率下准备第二阶段形状采样的第二次采样过程。

##### Triposplat

- [TripoSplatConditioning](https://docs.comfy.org/built-in-nodes/TripoSplatConditioning) — 此节点使用 DINOv3 图像编码器和 Flux2 VAE 对输入图像进行编码，为 TripoSplat 模型生成正向和负向条件数据。
- [TripoSplatPreprocessImage](https://docs.comfy.org/built-in-nodes/TripoSplatPreprocessImage) — 此节点将每个输入图像裁剪为黑色背景上的居中正方形，并添加填充以达到指定的输出大小。

##### Void

- [VOIDInpaintConditioning](https://docs.comfy.org/built-in-nodes/VOIDInpaintConditioning) — VOIDInpaintConditioning 节点用于准备使用 CogVideoX 模型进行局部重绘所需的 conditioning 数据。

##### Wan

- [Wan22ImageToVideoLatent](https://docs.comfy.org/built-in-nodes/Wan22ImageToVideoLatent) — Wan22ImageToVideoLatent 从图像创建视频潜表示。
- [WanFirstLastFrameToVideo](https://docs.comfy.org/built-in-nodes/WanFirstLastFrameToVideo) — WanFirstLastFrameToVideo 节点通过将起始帧和结束帧与文本提示组合，为视频生成准备条件。
- [WanImageToVideo](https://docs.comfy.org/built-in-nodes/WanImageToVideo) — WanImageToVideo 节点为视频生成准备条件和潜在表示。

###### Animate

- [WanAnimate2Cache](https://docs.comfy.org/built-in-nodes/WanAnimate2Cache) — 该节点会预先缓存姿态视频各数据块的激活值，这样就不必在每个采样步骤中重新计算，生成时间大约可以减半。
- [WanAnimate2ToVideo](https://docs.comfy.org/built-in-nodes/WanAnimate2ToVideo) — WanAnimate2ToVideo 通过将参考图像中的人物的面部表情、身体动作和手势从单独的姿态视频中转移，从而对参考图像中的人物进行动画化。
- [WanAnimateToVideo](https://docs.comfy.org/built-in-nodes/WanAnimateToVideo) — WanAnimateToVideo 节点用于准备 conditioning 数据和初始 latent，以使用 Wan 生成动画视频，输入包括参考图像、姿态、人脸、背景以及可选的前一个块的运动。

###### Camera

- [WanCameraEmbedding](https://docs.comfy.org/built-in-nodes/WanCameraEmbedding) — 此节点使用 Plücker 嵌入为您选择的相机路径生成相机轨迹嵌入。
- [WanCameraImageToVideo](https://docs.comfy.org/built-in-nodes/WanCameraImageToVideo) — WanCameraImageToVideo 节点用于为基于图像的相机控制视频生成准备条件和潜空间数据。

###### Dancer

- [WanDancerEncodeAudio](https://docs.comfy.org/built-in-nodes/WanDancerEncodeAudio) — 此节点分析音频片段，并将其转换为一组可指导视频生成模型的特征。
- [WanDancerVideo](https://docs.comfy.org/built-in-nodes/WanDancerVideo) — WanDancerVideo 节点为使用 WanDancer 模型的视频生成准备 conditioning 数据和空的 latent 张量。

###### Fun Control

- [Wan22FunControlToVideo](https://docs.comfy.org/built-in-nodes/Wan22FunControlToVideo) — Wan22FunControlToVideo 节点为使用 Wan 视频模型进行视频生成准备 conditioning 数据和空 latent 张量。
- [WanFunControlToVideo](https://docs.comfy.org/built-in-nodes/WanFunControlToVideo) — 此节点用于支持阿里巴巴万Fun Control视频生成模型，在[此提交](https://github.com/comfyanonymous/ComfyUI/commit/3661c833bcc41b788a7c9f0e7bc48524f8ee5f82)之后添加。

###### Fun Inpaint

- [WanFunInpaintToVideo](https://docs.comfy.org/built-in-nodes/WanFunInpaintToVideo) — WanFunInpaintToVideo 节点为修复式视频生成准备 conditioning 和 latent 数据，并使用可选的起始图像和结束图像来引导结果。

###### Humo

- [WanHuMoImageToVideo](https://docs.comfy.org/built-in-nodes/WanHuMoImageToVideo) — WanHuMoImageToVideo 节点为 Wan HuMo 视频生成流程准备条件数据和一个空 latent 视频。

###### Infinite Talk

- [WanInfiniteTalkToVideo](https://docs.comfy.org/built-in-nodes/WanInfiniteTalkToVideo) — WanInfiniteTalkToVideo 根据音频输入生成视频序列。

###### Move

- [GenerateTracks](https://docs.comfy.org/built-in-nodes/GenerateTracks) — GenerateTracks 节点为视频生成创建多条平行的运动路径（轨道）。
- [WanMoveConcatTrack](https://docs.comfy.org/built-in-nodes/WanMoveConcatTrack) — WanMoveConcatTrack 节点将两组运动跟踪数据合并为一个更长的单一序列。
- [WanMoveTracksFromCoords](https://docs.comfy.org/built-in-nodes/WanMoveTracksFromCoords) — WanMoveTracksFromCoords 节点根据 JSON 格式的坐标字符串创建运动轨迹。
- [WanMoveTrackToVideo](https://docs.comfy.org/built-in-nodes/WanMoveTrackToVideo) — markdown WanMoveTrackToVideo 节点为视频生成准备 conditioning 和潜在空间数据，并整合可选的运动跟踪信息。
- [WanMoveVisualizeTracks](https://docs.comfy.org/built-in-nodes/WanMoveVisualizeTracks) — WanMoveVisualizeTracks 节点将运动跟踪数据叠加到一系列图像或视频帧上。
- [WanTrackToVideo](https://docs.comfy.org/built-in-nodes/WanTrackToVideo) — WanTrackToVideo 节点通过处理轨迹点并生成相应的视频帧，将运动跟踪数据转换为视频序列。

###### Phantom Subject

- [WanPhantomSubjectToVideo](https://docs.comfy.org/built-in-nodes/WanPhantomSubjectToVideo) — WanPhantomSubjectToVideo 节点为 Wan 视频生成准备条件数据和潜变量。

###### Scail

- [SCAIL2ColoredMask](https://docs.comfy.org/built-in-nodes/SCAIL2ColoredMask) — 此节点将 SAM3 跟踪数据渲染为彩色遮罩，供 WanSCAILToVideo 节点使用。
- [WanSCAILToVideo](https://docs.comfy.org/built-in-nodes/WanSCAILToVideo) — WanSCAILToVideo 节点为使用 SCAIL 和 SCAIL-2 视频模型进行视频生成准备条件和空 latent 空间。

###### Sound

- [WanSoundImageToVideo](https://docs.comfy.org/built-in-nodes/WanSoundImageToVideo) — WanSoundImageToVideo 节点为 Wan 声音到视频生成准备条件化信息和一个空的 latent 视频张量。
- [WanSoundImageToVideoExtend](https://docs.comfy.org/built-in-nodes/WanSoundImageToVideoExtend) — WanSoundImageToVideoExtend 节点用于扩展现有的视频潜在变量，生成额外帧，并可选择由音频、参考图像和控制视频引导。

###### Vace

- [WanVaceToVideo](https://docs.comfy.org/built-in-nodes/WanVaceToVideo) — WanVaceToVideo 节点为 VACE 控制的视频生成模型准备视频条件数据。

##### Yue2

- [SheetSage2AudioToABC](https://docs.comfy.org/built-in-nodes/SheetSage2AudioToABC) — 此节点将音乐中的人声与器乐旋律转写为 ABC 记谱法，这是一种基于文本的乐谱书写格式。
- [YuE2GenerateABC](https://docs.comfy.org/built-in-nodes/YuE2GenerateABC) — 此节点使用 YuE2 文本与歌词模型，根据风格描述和歌词为歌曲生成 ABC 记谱。
- [YuE2GenerateMusic](https://docs.comfy.org/built-in-nodes/YuE2GenerateMusic) — 从风格、歌词和 ABC 记谱生成音乐 token 和声学条件。

##### Z Image

- [TextEncodeZImageOmni](https://docs.comfy.org/built-in-nodes/TextEncodeZImageOmni) — TextEncodeZImageOmni 将文本提示词与最多三张可选参考图像一起编码为图像生成模型的条件格式。

#### Latent

- [EmptyLatentAudio](https://docs.comfy.org/built-in-nodes/EmptyLatentAudio) — Empty Latent Audio 节点会创建一个用于音频处理的空潜空间张量。
- [EmptyLatentImage](https://docs.comfy.org/built-in-nodes/EmptyLatentImage) — EmptyLatentImage 节点用于生成具有指定尺寸和批次大小的空白潜空间表示。
- [LatentComposite](https://docs.comfy.org/built-in-nodes/LatentComposite) — LatentComposite 节点旨在将两个潜在表示混合或合并为单个输出。
- [LatentCompositeMasked](https://docs.comfy.org/built-in-nodes/LatentCompositeMasked) — LatentCompositeMasked 节点用于在指定坐标处将两个潜在表示混合在一起，并可选择使用遮罩进行更可控的合成。
- [LatentUpscale](https://docs.comfy.org/built-in-nodes/LatentUpscale) — LatentUpscale 节点用于对图像的潜在表示进行放大。
- [LatentUpscaleBy](https://docs.comfy.org/built-in-nodes/LatentUpscaleBy) — LatentUpscaleBy 节点用于对图像的潜在表示进行放大。
- [LoadLatent](https://docs.comfy.org/built-in-nodes/LoadLatent) — LoadLatent 节点从输入目录中的 .latent 文件加载先前保存的潜在表示。
- [SaveLatent](https://docs.comfy.org/built-in-nodes/SaveLatent) — SaveLatent 将潜在张量以 .latent 文件形式保存到磁盘，以便后续复用或共享。
- [SetLatentNoiseMask](https://docs.comfy.org/built-in-nodes/SetLatentNoiseMask) — 此节点用于对一组潜在样本应用噪声掩码。
- [TrimVideoLatent](https://docs.comfy.org/built-in-nodes/TrimVideoLatent) — TrimVideoLatent 节点从视频潜空间表示的开头移除帧。
- [VAEDecode](https://docs.comfy.org/built-in-nodes/VAEDecode) — VAEDecode 节点专用于使用指定的变分自编码器（VAE）将潜在表示解码为图像。
- [VAEDecodeAudio](https://docs.comfy.org/built-in-nodes/VAEDecodeAudio) — 此节点使用变分自编码器（VAE）将音频潜空间表示转换回可播放的音频波形。
- [VAEDecodeAudioTiled](https://docs.comfy.org/built-in-nodes/VAEDecodeAudioTiled) — 此节点使用变分自编码器（VAE）将压缩的音频表示（潜在样本）转换回音频波形。
- [VAEDecodeTiled](https://docs.comfy.org/built-in-nodes/VAEDecodeTiled) — VAEDecodeTiled 节点使用分块方式将潜在表示解码为图像，以高效处理大图像。
- [VAEEncode](https://docs.comfy.org/built-in-nodes/VAEEncode) — 此节点用于使用指定的 VAE 模型将图像编码为潜在空间表示。
- [VAEEncodeAudio](https://docs.comfy.org/built-in-nodes/VAEEncodeAudio) — VAE Encode Audio 节点使用变分自编码器（VAE）将音频数据转换为潜在表示。
- [VAEEncodeForInpaint](https://docs.comfy.org/built-in-nodes/VAEEncodeForInpaint) — 此节点专为将图像编码为适用于修复任务的潜在表示而设计，并包含额外的预处理步骤，以调整输入图像和遮罩，确保 VAE 模型能够进行最佳编码。
- [VAEEncodeTiled](https://docs.comfy.org/built-in-nodes/VAEEncodeTiled) — VAEEncodeTiled 通过将图像拆分为较小的图块，并使用变分自编码器对其进行编码来处理图像。

##### Ace

- [EmptyAceStep1.5LatentAudio](https://docs.comfy.org/built-in-nodes/EmptyAceStep1.5LatentAudio) — Empty Ace Step 1.5 Latent Audio 节点会为音频生成工作流创建一个空的（静音）音频 latent 张量。
- [EmptyAceStepLatentAudio](https://docs.comfy.org/built-in-nodes/EmptyAceStepLatentAudio) — Empty Ace Step 1.0 Latent Audio 节点为选定持续时间创建空的 latent 音频样本。

##### Advanced

- [LatentAdd](https://docs.comfy.org/built-in-nodes/LatentAdd) — LatentAdd 节点用于对两个潜在表示进行加法运算。
- [LatentBatchSeedBehavior](https://docs.comfy.org/built-in-nodes/LatentBatchSeedBehavior) — LatentBatchSeedBehavior 节点用于修改一批潜在样本的种子行为。
- [LatentConcat](https://docs.comfy.org/built-in-nodes/LatentConcat) — The LatentConcat 节点通过沿所选维度将两个潜在样本拼接在一起。
- [LatentCut](https://docs.comfy.org/built-in-nodes/LatentCut) — LatentCut 节点沿选定的维度从潜在样本中提取特定部分。
- [LatentCutToBatch](https://docs.comfy.org/built-in-nodes/LatentCutToBatch) — LatentCutToBatch 节点将 latent 表示沿所选维度（时间、宽度或高度）切分为指定大小的切片，并将这些切片堆叠成一个新批次。
- [LatentInterpolate](https://docs.comfy.org/built-in-nodes/LatentInterpolate) — LatentInterpolate 节点旨在根据指定比例对两组潜在样本进行插值，融合两组样本的特征，生成一组新的中间潜在样本。
- [LatentMultiply](https://docs.comfy.org/built-in-nodes/LatentMultiply) — LatentMultiply 节点旨在通过指定的乘数缩放样本的潜在表示。
- [LatentSubtract](https://docs.comfy.org/built-in-nodes/LatentSubtract) — LatentSubtract 节点用于从一个潜在表示中减去另一个潜在表示。

###### Operations

- [LatentApplyOperation](https://docs.comfy.org/built-in-nodes/LatentApplyOperation) — LatentApplyOperation 节点将指定的潜在操作应用于潜在样本。
- [LatentApplyOperationCFG](https://docs.comfy.org/built-in-nodes/LatentApplyOperationCFG) — LatentApplyOperationCFG 节点在模型采样过程的无分类器引导（CFG）步骤中应用一个 latent 操作。
- [LatentOperationSharpen](https://docs.comfy.org/built-in-nodes/LatentOperationSharpen) — LatentOperationSharpen 节点使用基于高斯的内核为潜在表示创建锐化操作。
- [LatentOperationTonemapReinhard](https://docs.comfy.org/built-in-nodes/LatentOperationTonemapReinhard) — 此节点会创建一个 latent 操作，用于对 latent 向量应用 Reinhard 色调映射。

##### Autoregressive

- [EmptyARVideoLatent](https://docs.comfy.org/built-in-nodes/EmptyARVideoLatent) — EmptyARVideoLatent 节点用于为视频生成创建一个空白潜在表示。

##### Batch

- [BatchLatentsNode](https://docs.comfy.org/built-in-nodes/BatchLatentsNode) — Batch Latents 节点将多个 latent 输入合并为一个批次。
- [LatentBatch](https://docs.comfy.org/built-in-nodes/LatentBatch) — LatentBatch 节点旨在将两组潜在样本合并为单个批次，在拼接前可能会调整其中一组样本的尺寸以匹配另一组。
- [LatentFromBatch](https://docs.comfy.org/built-in-nodes/LatentFromBatch) — 此节点用于根据指定的批次索引和长度，从给定批次中提取特定的潜在样本子集。
- [RebatchLatents](https://docs.comfy.org/built-in-nodes/RebatchLatents) — RebatchLatents 节点旨在根据指定的批次大小，将一批潜在表示重新组织为新的批次配置。
- [RepeatLatentBatch](https://docs.comfy.org/built-in-nodes/RepeatLatentBatch) — RepeatLatentBatch 节点用于将给定的潜在表示批次按指定次数复制，并可包含噪声掩码和批次索引等附加数据。
- [ReplaceVideoLatentFrames](https://docs.comfy.org/built-in-nodes/ReplaceVideoLatentFrames) — ReplaceVideoLatentFrames 会用源潜在视频中的帧替换目标潜在视频中的一段帧范围，从指定的帧索引开始。

##### Chroma Radiance

- [EmptyChromaRadianceLatentImage](https://docs.comfy.org/built-in-nodes/EmptyChromaRadianceLatentImage) — EmptyChromaRadianceLatentImage 节点会创建一个具有你指定尺寸的空白潜空间图像，用于 Chroma Radiance 工作流。

##### Cosmos

- [EmptyCosmosLatentVideo](https://docs.comfy.org/built-in-nodes/EmptyCosmosLatentVideo) — EmptyCosmosLatentVideo 创建一个具有指定维度的空潜空间视频张量。

##### Flux

- [EmptyFlux2LatentImage](https://docs.comfy.org/built-in-nodes/EmptyFlux2LatentImage) — Empty Flux 2 Latent 节点创建一个填充为零的空白潜在表示。

##### Hidream

- [EmptyHiDreamO1LatentImage](https://docs.comfy.org/built-in-nodes/EmptyHiDreamO1LatentImage) — 此节点为 HiDream-O1-Image 模型在像素空间中创建一个空潜空间图像。

##### Hunyuan 3d

- [EmptyLatentHunyuan3Dv2](https://docs.comfy.org/built-in-nodes/EmptyLatentHunyuan3Dv2) — 此节点为 Hunyuan3Dv2 3D 生成模型创建一批空的（全零）潜空间样本。
- [VAEDecodeHunyuan3D](https://docs.comfy.org/built-in-nodes/VAEDecodeHunyuan3D) — VAEDecodeHunyuan3D 节点使用 VAE 解码器将潜在表示转换为 3D 体素数据。

##### Hunyuan Image

- [EmptyHunyuanImageLatent](https://docs.comfy.org/built-in-nodes/EmptyHunyuanImageLatent) — EmptyHunyuanImageLatent 节点为 Hunyuan 图像生成模型创建一个全零的空白潜空间。

##### Hunyuan Video

- [EmptyHunyuanLatentVideo](https://docs.comfy.org/built-in-nodes/EmptyHunyuanLatentVideo) — EmptyHunyuanLatentVideo 节点与 EmptyLatentImage 节点类似。
- [EmptyHunyuanVideo15Latent](https://docs.comfy.org/built-in-nodes/EmptyHunyuanVideo15Latent) — 此节点创建一个专为与 HunyuanVideo 1.5 模型配合使用而格式化好的空 latent 张量。
- [HunyuanVideo15LatentUpscaleWithModel](https://docs.comfy.org/built-in-nodes/HunyuanVideo15LatentUpscaleWithModel) — Hunyuan Video 15 Latent Upscale With Model 节点可提高潜在图像表示的分辨率。

##### Ltxv

- [EmptyLTXVLatentVideo](https://docs.comfy.org/built-in-nodes/EmptyLTXVLatentVideo) — EmptyLTXVLatentVideo 节点使用你指定的 width、height、length 和 batchsize 创建一个空（填零）的潜在视频张量。
- [LTXVAudioVAEDecode](https://docs.comfy.org/built-in-nodes/LTXVAudioVAEDecode) — LTXV Audio VAE 解码节点将音频的潜在表示转换回音频波形。
- [LTXVAudioVAEEncode](https://docs.comfy.org/built-in-nodes/LTXVAudioVAEEncode) — LTXV Audio VAE Encode 节点接收音频输入，并使用指定的 Audio VAE 模型将其压缩为更小的潜在表示。
- [LTXVConcatAVLatent](https://docs.comfy.org/built-in-nodes/LTXVConcatAVLatent) — 此节点将视频潜空间和音频潜空间合并为单个联合音视频（AV）潜空间，可供 LTXV 或 MiniMax H3 等 AV 模型使用。
- [LTXVEmptyLatentAudio](https://docs.comfy.org/built-in-nodes/LTXVEmptyLatentAudio) — LTXV Empty Latent Audio 节点创建一批空（零填充）的潜在音频张量。
- [LTXVFreezeLatent](https://docs.comfy.org/built-in-nodes/LTXVFreezeLatent) — LTXV Freeze Latent 节点会将 latent 的噪声掩码设置为零，从而在采样运行期间保持该 latent 干净且不变。
- [LTXVLatentUpsampler](https://docs.comfy.org/built-in-nodes/LTXVLatentUpsampler) — LTXVLatentUpsampler 节点将视频 latent 表示的空间分辨率提高到两倍。
- [LTXVSeparateAVLatent](https://docs.comfy.org/built-in-nodes/LTXVSeparateAVLatent) — LTXVSeparateAVLatent 节点用于将组合的音频-视频潜在表示拆分为两个独立的潜在表示：一个包含视频数据，另一个包含音频数据。

##### Minimax

- [EmptyMiniMaxH3LatentAV](https://docs.comfy.org/built-in-nodes/EmptyMiniMaxH3LatentAV) — 此节点为 MiniMax H3 模型创建一个同时包含视频和音频信息的空 latent。

##### Minimax Music

- [EmptyMiniMaxMusic3LatentAudio](https://docs.comfy.org/built-in-nodes/EmptyMiniMaxMusic3LatentAudio) — 此节点为 MiniMax Music3 模型创建一个空的（零填充）音频潜变量。

##### Mochi

- [EmptyMochiLatentVideo](https://docs.comfy.org/built-in-nodes/EmptyMochiLatentVideo) — EmptyMochiLatentVideo 会根据你指定的尺寸创建一个空的潜在视频张量。

##### Qwen

- [EmptyQwenImageLayeredLatentImage](https://docs.comfy.org/built-in-nodes/EmptyQwenImageLayeredLatentImage) — Empty Qwen Image Layered Latent 准备 Qwen-Image-Layered 模型绘制所需的空白画布。

##### Seedvr

- [SeedVR2TemporalChunk](https://docs.comfy.org/built-in-nodes/SeedVR2TemporalChunk) — 此节点将 SeedVR2 视频潜空间变量分割成较小的时序块，以便在可用 VRAM 内逐一处理。
- [SeedVR2TemporalMerge](https://docs.comfy.org/built-in-nodes/SeedVR2TemporalMerge) — 此节点将采样的 SeedVR2 潜在时间块重新组合为单个全长潜在变量。

##### Stable Cascade

- [StableCascade_EmptyLatentImage](https://docs.comfy.org/built-in-nodes/StableCascade_EmptyLatentImage) — StableCascadeEmptyLatentImage 节点为 Stable Cascade 模型创建空的潜空间张量。
- [StableCascade_StageC_VAEEncode](https://docs.comfy.org/built-in-nodes/StableCascade_StageC_VAEEncode) — StableCascadeStageCVAEEncode 节点通过 VAE 编码器处理输入图像，为 Stable Cascade 模型生成潜在表示。

##### Stable Diffusion

- [EmptySD3LatentImage](https://docs.comfy.org/built-in-nodes/EmptySD3LatentImage) — EmptySD3LatentImage 创建一个空白的（全零）潜空间图像，其布局符合 Stable Diffusion 3 模型的要求。

##### Transform

- [LatentCrop](https://docs.comfy.org/built-in-nodes/LatentCrop) — LatentCrop 节点用于对图像的潜在表示执行裁剪操作。
- [LatentFlip](https://docs.comfy.org/built-in-nodes/LatentFlip) — The LatentFlip node is designed to manipulate latent representations by flipping them either vertically or horizontally.
- [LatentRotate](https://docs.comfy.org/built-in-nodes/LatentRotate) — LatentRotate 节点旨在按指定角度旋转图像的潜在表示。

##### Trellis

- [EmptyTrellis2LatentStructure](https://docs.comfy.org/built-in-nodes/EmptyTrellis2LatentStructure) — 此节点为 Trellis2 模型创建一个空的潜在结构，其中所有值均设为零。
- [VaeDecodeShapeTrellis](https://docs.comfy.org/built-in-nodes/VaeDecodeShapeTrellis) — 此节点将 Trellis2 形状潜在表示解码为 3D 网格。
- [VaeDecodeStructureTrellis2](https://docs.comfy.org/built-in-nodes/VaeDecodeStructureTrellis2) — 此节点使用 VAE 的结构解码器，将 Trellis 结构潜在样本转换为 3D 体素网格。
- [VaeDecodeTextureTrellis](https://docs.comfy.org/built-in-nodes/VaeDecodeTextureTrellis) — 此节点使用 VAE 将 Trellis2 纹理潜变量解码为体素颜色。

##### Triposplat

- [TripoSplatSamplingPreview](https://docs.comfy.org/built-in-nodes/TripoSplatSamplingPreview) — 此节点会对TripoSplat模型进行补丁处理，使其与标准KSampler节点一起使用时，在每个采样步骤中显示解码后的高斯溅射（gaussian splat）实时预览。
- [VAEDecodeTripoSplat](https://docs.comfy.org/built-in-nodes/VAEDecodeTripoSplat) — 将 TripoSplat 潜空间表示解码为 3D 高斯泼溅。

##### Void

- [VOIDWarpedNoise](https://docs.comfy.org/built-in-nodes/VOIDWarpedNoise) — 为 VOID 视频细化过程的第二遍生成时间相关噪声。
- [VOIDWarpedNoiseSource](https://docs.comfy.org/built-in-nodes/VOIDWarpedNoiseSource) — 此节点将 LATENT（例如来自 VOIDWarpedNoise 节点的输出）转换为 NOISE 源。

##### Yue2

- [EmptyYuE2LatentAudio](https://docs.comfy.org/built-in-nodes/EmptyYuE2LatentAudio) — 此节点为 YuE2 创建一个空音频 latent，其大小根据所选时长和批次数量确定。

#### Loaders

- [AudioEncoderLoader](https://docs.comfy.org/built-in-nodes/AudioEncoderLoader) — 内置节点参考页（官方暂无中文说明）
- [CheckpointLoader](https://docs.comfy.org/built-in-nodes/CheckpointLoader) — CheckpointLoader 节点加载预训练模型检查点及其配置文件。
- [CheckpointLoaderSimple](https://docs.comfy.org/built-in-nodes/CheckpointLoaderSimple) — 加载扩散模型 checkpoint 文件，并将其拆分为三个核心组件：用于对潜变量去噪的主模型、CLIP 文本编码器，以及 VAE 图像编码器/解码器。
- [CLIPLoader](https://docs.comfy.org/built-in-nodes/ClipLoader) — CLIPLoader 节点从文件加载文本编码器模型（CLIP、T5 或类似模型），使其可供其他需要将文本提示转换为数值表示的节点使用。
- [CLIPVisionLoader](https://docs.comfy.org/built-in-nodes/ClipVisionLoader) — 此节点会自动检测位于 ComfyUI/models/clipvision 文件夹中的模型，以及 extramodelpaths.yaml 文件中配置的任何额外模型路径。
- [ConditioningLoader](https://docs.comfy.org/built-in-nodes/ConditioningLoader) — 此节点从 embeddings 文件夹中加载此前通过 Save Conditioning 节点保存的 conditioning，或任何包含 conditioning 张量的 safetensors 文件。
- [DiffControlNetLoader](https://docs.comfy.org/built-in-nodes/DiffControlNetLoader) — 此节点将检测位于 ComfyUI/models/controlnet 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的额外路径中的模型。
- [DiffusersLoader](https://docs.comfy.org/built-in-nodes/DiffusersLoader) — DiffusersLoader 节点用于加载以 diffusers 格式保存的预训练模型。
- [DualCLIPLoader](https://docs.comfy.org/built-in-nodes/DualCLIPLoader) — DualCLIPLoader 节点专为同时加载两个 CLIP 模型而设计，便于执行需要整合或比较两个模型特征的操作。
- [FrameInterpolationModelLoader](https://docs.comfy.org/built-in-nodes/FrameInterpolationModelLoader) — 此节点加载帧插值模型文件，并准备好在工作流中使用。
- [GLIGENLoader](https://docs.comfy.org/built-in-nodes/GLIGENLoader) — 此节点将检测位于 ComfyUI/models/gligen 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的其他路径中的模型。
- [HypernetworkLoader](https://docs.comfy.org/built-in-nodes/HypernetworkLoader) — 此节点将检测位于 ComfyUI/models/hypernetworks 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的额外路径中的模型。
- [ImageOnlyCheckpointLoader](https://docs.comfy.org/built-in-nodes/ImageOnlyCheckpointLoader) — 此节点将检测位于 ComfyUI/models/checkpoints 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的额外路径中的模型。
- [LatentUpscaleModelLoader](https://docs.comfy.org/built-in-nodes/LatentUpscaleModelLoader) — LatentUpscaleModelLoader 节点从存储在 ComfyUI 的 latentupscalemodels 文件夹中的文件加载一个专门用于放大潜空间表示的模型。
- [LoadBackgroundRemovalModel](https://docs.comfy.org/built-in-nodes/LoadBackgroundRemovalModel) — 从文件加载背景移除模型。
- [LoadDA3Model](https://docs.comfy.org/built-in-nodes/LoadDA3Model) — 此节点从文件加载 Depth Anything 3 模型，为深度估计任务做好准备。
- [LoadMediaPipeFaceLandmarker](https://docs.comfy.org/built-in-nodes/LoadMediaPipeFaceLandmarker) — 此节点加载一个 MediaPipe Face Landmarker v2 模型，用于检测图像中的人脸和面部特征点（例如眼睛、鼻子和嘴巴）。
- [LoadMoGeModel](https://docs.comfy.org/built-in-nodes/LoadMoGeModel) — 从文件中加载 MoGe（单目几何）模型，并使其可用于几何估计任务。
- [LoraLoaderBypass](https://docs.comfy.org/built-in-nodes/LoraLoaderBypass) — LoraLoaderBypass 节点以特殊的“bypass”模式将 LoRA（低秩适应）应用于扩散模型和 CLIP 模型。
- [LoraLoaderBypassModelOnly](https://docs.comfy.org/built-in-nodes/LoraLoaderBypassModelOnly) — 此节点对模型应用 LoRA（低秩适配）以修改其行为，但仅影响模型组件本身。
- [LoraModelLoader](https://docs.comfy.org/built-in-nodes/LoraModelLoader) — LoraModelLoader 节点将训练好的 LoRA（低秩自适应）权重应用于扩散模型。
- [LTXAVTextEncoderLoader](https://docs.comfy.org/built-in-nodes/LTXAVTextEncoderLoader) — 此节点为 LTXV 音频模型加载专用文本编码器。
- [LTXVAudioVAELoader](https://docs.comfy.org/built-in-nodes/LTXVAudioVAELoader) — LTXV Audio VAE Loader 节点可从检查点文件中加载预训练的音频变分自编码器（VAE）模型。
- [ModelPatchLoader](https://docs.comfy.org/built-in-nodes/ModelPatchLoader) — ModelPatchLoader 节点从 modelpatches 文件夹加载模型补丁文件，并准备好在工作流中使用。
- [OpticalFlowLoader](https://docs.comfy.org/built-in-nodes/OpticalFlowLoader) — 从 models/opticalflow/ 文件夹加载光流模型。
- [PhotoMakerLoader](https://docs.comfy.org/built-in-nodes/PhotoMakerLoader) — PhotoMakerLoader 节点从可用的模型文件中加载 PhotoMaker 模型。
- [QuadrupleCLIPLoader](https://docs.comfy.org/built-in-nodes/QuadrupleCLIPLoader) — The Quadruple CLIP Loader, QuadrupleCLIPLoader, is one of the core nodes of ComfyUI, first added to support the HiDream I1 version model.
- [StyleModelLoader](https://docs.comfy.org/built-in-nodes/StyleModelLoader) — 此节点将检测位于 ComfyUI/models/stylemodels 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的其他路径下的模型。
- [TripleCLIPLoader](https://docs.comfy.org/built-in-nodes/TripleCLIPLoader) — TripleCLIPLoader 同时加载三个文本编码器模型，并将它们组合成一个单一的 CLIP 模型。
- [unCLIPCheckpointLoader](https://docs.comfy.org/built-in-nodes/unCLIPCheckpointLoader) — 此节点将检测位于 ComfyUI/models/checkpoints 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的其他路径中的模型。
- [UNETLoader](https://docs.comfy.org/built-in-nodes/UNETLoader) — UNETLoader 节点用于按名称加载 U-Net 模型，便于在系统中使用预训练的 U-Net 架构。
- [UpscaleModelLoader](https://docs.comfy.org/built-in-nodes/UpscaleModelLoader) — 此节点将检测位于 ComfyUI/models/upscalemodels 文件夹中的模型，同时也会读取在 extramodelpaths.yaml 文件中配置的其他路径中的模型。
- [VAELoader](https://docs.comfy.org/built-in-nodes/VAELoader) — 此节点会检测位于 ComfyUI/models/vae 文件夹中的模型，同时也会读取 extramodelpaths.yaml 文件中配置的其他路径下的模型。

#### Merging

- [CheckpointSave](https://docs.comfy.org/built-in-nodes/CheckpointSave) — Save Checkpoint 节点用于将完整的 Stable Diffusion 模型（包括 UNet、CLIP 和 VAE 组件）保存为 .safetensors 格式的检查点文件。
- [CLIPMergeAdd](https://docs.comfy.org/built-in-nodes/CLIPMergeAdd) — CLIPMergeAdd 节点通过将第二个模型的补丁添加到第一个模型中来组合两个 CLIP 模型。
- [CLIPMergeSimple](https://docs.comfy.org/built-in-nodes/ClipMergeSimple) — CLIPMergeSimple 是一个模型合并节点，可根据指定比例合并两个 CLIP 文本编码器模型。
- [CLIPMergeSubtract](https://docs.comfy.org/built-in-nodes/CLIPMergeSubtract) — CLIPMergeSubtract 节点通过将一个 CLIP 模型的权重与另一个 CLIP 模型相减来执行模型合并。
- [CLIPSave](https://docs.comfy.org/built-in-nodes/ClipSave) — CLIPSave 节点将 CLIP 文本编码器模型以 SafeTensors 格式保存到磁盘。
- [ImageOnlyCheckpointSave](https://docs.comfy.org/built-in-nodes/ImageOnlyCheckpointSave) — 此节点用于保存一个检查点文件，将模型与其 CLIP 视觉编码器和 VAE 打包在一起。
- [ModelMergeAdd](https://docs.comfy.org/built-in-nodes/ModelMergeAdd) — ModelMergeAdd 节点用于通过将一个模型的关键补丁添加到另一个模型来合并两个模型。
- [ModelMergeBlocks](https://docs.comfy.org/built-in-nodes/ModelMergeBlocks) — ModelMergeBlocks 专为高级模型合并操作而设计，允许将两个模型进行整合，并可针对模型的不同部分自定义混合比例。
- [ModelMergeSimple](https://docs.comfy.org/built-in-nodes/ModelMergeSimple) — ModelMergeSimple 节点用于通过按指定比例混合两个模型的参数来合并它们。
- [ModelMergeSubtract](https://docs.comfy.org/built-in-nodes/ModelMergeSubtract) — 此节点专为高级模型合并操作而设计，具体用于根据指定的乘数将一个模型的参数从另一个模型中减去。
- [ModelSave](https://docs.comfy.org/built-in-nodes/ModelSave) — The ModelSave 节点将 MODEL 保存到计算机存储中，作为 .safetensors checkpoint 文件。
- [SaveLoRA](https://docs.comfy.org/built-in-nodes/SaveLoRA) — SaveLoRA 节点将 LoRA（低秩适应）模型保存到文件中。
- [VAESave](https://docs.comfy.org/built-in-nodes/VAESave) — VAESave 节点用于将 VAE 模型及其元数据（包括提示词和额外的 PNG 信息）保存到指定的输出目录。

##### Model Specific

- [ModelMergeAuraflow](https://docs.comfy.org/built-in-nodes/ModelMergeAuraflow) — ModelMergeAuraflow 节点通过为模型的每个部分（从初始层到最终输出）分别指定一个混合权重，将两个 Auraflow 模型混合在一起。
- [ModelMergeCosmos14B](https://docs.comfy.org/built-in-nodes/ModelMergeCosmos14B) — ModelMergeCosmos14B 节点使用专为 Cosmos 14B 模型架构设计的基于 block 的方法合并两个 AI 模型。
- [ModelMergeCosmos7B](https://docs.comfy.org/built-in-nodes/ModelMergeCosmos7B) — ModelMergeCosmos7B 节点通过特定组件的加权混合将两个 AI 模型合并在一起。
- [ModelMergeCosmosPredict2_14B](https://docs.comfy.org/built-in-nodes/ModelMergeCosmosPredict2_14B) — ModelMergeCosmosPredict214B 节点通过混合两个 AI 模型中匹配的内部组件，将它们合并为一个模型。
- [ModelMergeCosmosPredict2_2B](https://docs.comfy.org/built-in-nodes/ModelMergeCosmosPredict2_2B) — ModelMergeCosmosPredict22B 节点使用基于块的方法合并两个扩散模型，对不同模型组件提供细粒度控制。
- [ModelMergeFlux1](https://docs.comfy.org/built-in-nodes/ModelMergeFlux1) — ModelMergeFlux1 节点通过使用加权插值混合两个扩散模型的组件来合并它们。
- [ModelMergeKrea2](https://docs.comfy.org/built-in-nodes/ModelMergeKrea2) — 此节点通过在细粒度级别混合两个模型的内部组件来合并它们，使您能够控制每个模型特定部分对最终结果的影响程度。
- [ModelMergeLTXV](https://docs.comfy.org/built-in-nodes/ModelMergeLTXV) — ModelMergeLTXV 节点通过混合两个 LTXV 模型的匹配组件来合并它们。
- [ModelMergeMochiPreview](https://docs.comfy.org/built-in-nodes/ModelMergeMochiPreview) — 此节点使用基于块的方法合并两个 Mochi AI 模型，可对不同模型组件进行精细控制。
- [ModelMergeQwenImage](https://docs.comfy.org/built-in-nodes/ModelMergeQwenImage) — 此节点通过使用可调权重混合两个 Qwen 图像模型的各个组件来合并它们。
- [ModelMergeSD1](https://docs.comfy.org/built-in-nodes/ModelMergeSD1) — ModelMergeSD1 节点通过调整每个模型组件对结果的贡献程度，将两个 Stable Diffusion 1.x 模型混合在一起。
- [ModelMergeSD35_Large](https://docs.comfy.org/built-in-nodes/ModelMergeSD35_Large) — ModelMergeSD35Large 节点通过将第二个 Stable Diffusion 3.5 Large 模型中的特定内部组件混合到第一个模型中，实现两个模型的合并。
- [ModelMergeSD3_2B](https://docs.comfy.org/built-in-nodes/ModelMergeSD3_2B) — ModelMergeSD32B 节点允许您通过可调整的权重混合两个 Stable Diffusion 3 2B 模型的组件来合并它们。
- [ModelMergeSDXL](https://docs.comfy.org/built-in-nodes/ModelMergeSDXL) — ModelMergeSDXL 节点允许您通过调整每个模型对架构不同部分的影响，将两个 SDXL 模型混合在一起。
- [ModelMergeWAN2_1](https://docs.comfy.org/built-in-nodes/ModelMergeWAN2_1) — ModelMergeWAN21 节点通过使用加权平均融合两个 WAN2.1 模型的组件来合并它们。

#### Patch

- [BlockSparseAttention](https://docs.comfy.org/built-in-nodes/BlockSparseAttention) — Block Sparse Attention 节点会修改模型，使其注意力层仅关注输入中最相关的部分，而不是一次性处理所有内容，从而减少长序列所需的计算量。
- [ContextWindowsManual](https://docs.comfy.org/built-in-nodes/ContextWindowsManual) — Context Windows (Manual) 节点允许你在采样过程中为模型手动配置上下文窗口，创建具有指定长度、重叠大小和调度模式的重叠上下文片段，以便将数据划分为可管理的数据块进行处理，同时保持各片段之间的连续性。
- [ModelAttentionBackend](https://docs.comfy.org/built-in-nodes/ModelAttentionBackend) — 此节点为模型选择稠密注意力实现，克隆该模型，应用所选后端，并返回打过补丁的克隆。
- [ModelNoiseScale](https://docs.comfy.org/built-in-nodes/ModelNoiseScale) — 此节点用于调整模型采样时使用的噪声缩放。
- [ModelSamplingAuraFlow](https://docs.comfy.org/built-in-nodes/ModelSamplingAuraFlow) — ModelSamplingAuraFlow 节点会为扩散模型应用一种专门的采样配置，专为 AuraFlow 模型架构而设计。
- [ModelSamplingContinuousEDM](https://docs.comfy.org/built-in-nodes/ModelSamplingContinuousEDM) — 此节点通过集成连续 EDM（基于能量的扩散模型）采样技术，增强模型的采样能力。
- [ModelSamplingContinuousV](https://docs.comfy.org/built-in-nodes/ModelSamplingContinuousV) — ModelSamplingContinuousV 节点通过应用连续 V-prediction 采样来调整模型的采样行为。
- [ModelSamplingDiscrete](https://docs.comfy.org/built-in-nodes/ModelSamplingDiscrete) — 此节点旨在通过应用离散采样策略来修改模型的采样行为。
- [RenormCFG](https://docs.comfy.org/built-in-nodes/RenormCFG) — RenormCFG 节点通过应用条件缩放和归一化来修改扩散模型中的无分类器引导（CFG）过程。
- [RescaleCFG](https://docs.comfy.org/built-in-nodes/RescaleCFG) — RescaleCFG 节点旨在根据指定的乘数调整模型输出的条件与非条件缩放比例，以实现更平衡且可控的生成过程。
- [ScaleROPE](https://docs.comfy.org/built-in-nodes/ScaleROPE) — ScaleROPE 节点允许你通过分别对 X、Y 和 T（时间）分量应用独立的缩放和偏移因子，来修改模型的旋转位置编码（ROPE）。

##### Anima

- [AnimaLLLiteApply](https://docs.comfy.org/built-in-nodes/AnimaLLLiteApply) — AnimaLLLiteApply 将轻量级动画补丁应用于扩散模型，从而启用具有可调节强度和时间控制的可控图像到图像生成。

##### Chroma Radiance

- [ChromaRadianceOptions](https://docs.comfy.org/built-in-nodes/ChromaRadianceOptions) — ChromaRadianceOptions 节点允许你为 Chroma Radiance 模型配置高级设置。

##### Flux

- [ModelSamplingFlux](https://docs.comfy.org/built-in-nodes/ModelSamplingFlux) — ModelSamplingFlux 节点根据图像尺寸计算移位参数，对给定模型应用 Flux 模型采样。
- [USOStyleReference](https://docs.comfy.org/built-in-nodes/USOStyleReference) — USOStyleReference 节点通过将 CLIP 视觉特征与模型补丁相结合，将风格参考应用于模型，并返回输入模型的修补副本。

##### Hidream

- [HiDreamO1PatchSeamSmoothing](https://docs.comfy.org/built-in-nodes/HiDreamO1PatchSeamSmoothing) — 此节点通过在采样过程的后段，对模型在多个偏移后的 patch 网格位置上的输出进行平均，来减少 HiDream-O1 模型生成图像中的可见接缝。

##### Ltxv

- [LTXVContextWindows](https://docs.comfy.org/built-in-nodes/LTXVContextWindows) — 此节点在采样期间为类 LTXV 模型设置上下文窗口。
- [ModelSamplingLTXV](https://docs.comfy.org/built-in-nodes/ModelSamplingLTXV) — ModelSamplingLTXV 节点根据 token 数量对模型应用高级采样参数。

##### Minimax

- [MiniMaxH3FunControlNetApply](https://docs.comfy.org/built-in-nodes/MiniMaxH3FunControlNetApply) — 此节点将 MiniMax H3 Fun ControlNet 作为模型补丁应用于文本到视频模型。
- [MiniMaxH3SigmaShift](https://docs.comfy.org/built-in-nodes/MiniMaxH3SigmaShift) — 为 MiniMax H3 模型设置视频和音频流偏移值。

##### Qwen

- [QwenImageDiffsynthControlnet](https://docs.comfy.org/built-in-nodes/QwenImageDiffsynthControlnet) — QwenImageDiffsynthControlnet 将一个扩散合成控制网络补丁应用到基础模型上。

##### Sensenova

- [SenseNovaSamplingOptions](https://docs.comfy.org/built-in-nodes/SenseNovaSamplingOptions) — SenseNova Sampling Options 用于在模型上设置 SenseNova flow shift。

##### Stable Cascade

- [ModelSamplingStableCascade](https://docs.comfy.org/built-in-nodes/ModelSamplingStableCascade) — ModelSamplingStableCascade 节点通过向采样参数应用 shift 值，将 Stable Cascade 采样设置应用到模型中。

##### Stable Diffusion

- [ModelSamplingSD3](https://docs.comfy.org/built-in-nodes/ModelSamplingSD3) — 此节点将 Stable Diffusion 3 风格的采样设置应用于模型。

##### Supir

- [SUPIRApply](https://docs.comfy.org/built-in-nodes/SUPIRApply) — SUPIRApply 节点将 SUPIR 模型补丁应用于扩散模型。

##### Unet

- [FreeU](https://docs.comfy.org/built-in-nodes/FreeU) — FreeU 节点会对模型的输出块应用频域修改，以提升图像生成质量。
- [FreeU_V2](https://docs.comfy.org/built-in-nodes/FreeU_V2) — FreeUV2 通过对扩散模型的 U-Net 架构应用基于频率的修改来提升图像生成质量。
- [HyperTile](https://docs.comfy.org/built-in-nodes/HyperTile) — HyperTile 将分块（tiling）技术应用于扩散模型内部的注意力机制，以减少图像生成过程中的内存占用。
- [PatchModelAddDownscale](https://docs.comfy.org/built-in-nodes/PatchModelAddDownscale) — PatchModelAddDownscale (Kohya Deep Shrink) 通过在选择的目标块处缩小中间特征，然后将其缩放回原始尺寸，从而将 Kohya Deep Shrink 技术应用于模型。
- [PerturbedAttentionGuidance](https://docs.comfy.org/built-in-nodes/PerturbedAttentionGuidance) — PerturbedAttentionGuidance 节点对扩散模型应用扰动注意力引导，以提升生成质量。
- [TemporalScoreRescaling](https://docs.comfy.org/built-in-nodes/TemporalScoreRescaling) — 此节点将 Temporal Score Rescaling（TSR，时间分数重缩放）应用于扩散模型。
- [TomePatchModel](https://docs.comfy.org/built-in-nodes/TomePatchModel) — TomePatchModel 会对扩散模型应用 Token Merging (ToMe)，以降低推理过程中的计算开销。

##### Wan

- [WanContextWindowsManual](https://docs.comfy.org/built-in-nodes/WanContextWindowsManual) — markdown WAN 上下文窗口（手动）节点允许你手动为 Wan 风格视频模型配置上下文窗口。
- [WanUni3CControlnetApply](https://docs.comfy.org/built-in-nodes/WanUni3CControlnetApply) — 内置节点参考页（官方暂无中文说明）

##### Z Image

- [ZImageFunControlnet](https://docs.comfy.org/built-in-nodes/ZImageFunControlnet) — ZImageFunControlnet 将控制网络补丁应用于基础模型，以便其能够引导图像生成或编辑过程。

#### Sampling

- [KSampler](https://docs.comfy.org/built-in-nodes/KSampler) — KSampler 的工作原理如下：它根据特定模型以及正向和负向条件，修改所提供的原始潜空间图像信息。
- [KSamplerAdvanced](https://docs.comfy.org/built-in-nodes/KSamplerAdvanced) — KSamplerAdvanced 节点旨在通过提供高级配置和技术来增强采样过程。

##### Custom

- [APG](https://docs.comfy.org/built-in-nodes/APG) — APG（自适应投影引导）节点通过调整扩散过程中引导的应用方式来修改采样过程。
- [SamplerCustom](https://docs.comfy.org/built-in-nodes/SamplerCustom) — SamplerCustom 节点旨在为各种应用提供灵活且可定制的采样机制。
- [SamplerCustomAdvanced](https://docs.comfy.org/built-in-nodes/SamplerCustomAdvanced) — SamplerCustomAdvanced 节点使用自定义噪声、引导和采样配置执行高级潜空间采样。

##### Guiders

- [BasicGuider](https://docs.comfy.org/built-in-nodes/BasicGuider) — BasicGuider 节点为采样过程创建了一种简单的引导机制。
- [CFGGuider](https://docs.comfy.org/built-in-nodes/CFGGuider) — CFG Guider 节点创建一个引导系统，用于控制图像生成中的采样过程。
- [CFGOverride](https://docs.comfy.org/built-in-nodes/CFGOverride) — CFG Override 节点可在采样过程的某个百分比（sigma）范围内，将 CFG（Classifier-Free Guidance，无分类器引导）缩放值覆盖为固定值。
- [DualCFGGuider](https://docs.comfy.org/built-in-nodes/DualCFGGuider) — Dual CFG Guider 节点创建了一个用于采样的引导系统，它同时使用两个条件输入和一个负面条件输入。
- [DualModelGuider](https://docs.comfy.org/built-in-nodes/DualModelGuider) — 此节点允许您在引导式 CFG 采样过程中使用两个不同的模型：一个模型用于正向（条件）传递，另一个独立的模型用于负向（无条件）传递。
- [LTXVDualCFGGuider](https://docs.comfy.org/built-in-nodes/LTXVDualCFGGuider) — 此节点为 LTXV-AV 模型创建引导采样对象（CFG guider）。
- [VideoLinearCFGGuidance](https://docs.comfy.org/built-in-nodes/VideoLinearCFGGuidance) — VideoLinearCFGGuidance 节点对视频模型应用线性条件引导缩放，在指定范围内调整条件与非条件成分的影响程度。
- [VideoTriangleCFGGuidance](https://docs.comfy.org/built-in-nodes/VideoTriangleCFGGuidance) — VideoTriangleCFGGuidance 节点将三角形无分类器引导 (CFG) 缩放模式应用于视频模型。

##### Noise

- [AddNoise](https://docs.comfy.org/built-in-nodes/AddNoise) — 此节点使用指定的噪声生成器和 sigma 值向潜空间图像添加受控噪声。
- [DisableNoise](https://docs.comfy.org/built-in-nodes/DisableNoise) — 此节点提供一个空噪声配置，用于在采样过程中禁用噪声生成。
- [RandomNoise](https://docs.comfy.org/built-in-nodes/RandomNoise) — RandomNoise 节点基于种子值创建一个噪声生成器，用于采样过程。

##### Samplers

- [KSamplerSelect](https://docs.comfy.org/built-in-nodes/KSamplerSelect) — KSamplerSelect 节点旨在根据提供的采样器名称选择特定的采样器。
- [SamplerARVideo](https://docs.comfy.org/built-in-nodes/SamplerARVideo) — Sampler AR Video 节点为自回归视频模型提供了一种专门的采样方法，例如使用 Causal Forcing 或 Self-Forcing 技术的模型。
- [SamplerDPMAdaptative](https://docs.comfy.org/built-in-nodes/SamplerDPMAdaptative) — SamplerDPMAdaptative 节点实现了一个自适应 DPM（扩散概率模型）采样器，可在采样过程中自动调整步长。
- [SamplerDPMPP_2M_SDE](https://docs.comfy.org/built-in-nodes/SamplerDPMPP_2M_SDE) — SamplerDPMPP2MSDE 节点为扩散模型创建一个 DPM++ 2M SDE 采样器。
- [SamplerDPMPP_2S_Ancestral](https://docs.comfy.org/built-in-nodes/SamplerDPMPP_2S_Ancestral) — SamplerDPMPP2SAncestral 节点创建一个使用 DPM++ 2S Ancestral 采样方法生成图像的采样器。
- [SamplerDPMPP_3M_SDE](https://docs.comfy.org/built-in-nodes/SamplerDPMPP_3M_SDE) — SamplerDPMPP3MSDE 节点用于创建 DPM++ 3M SDE 采样器，供采样过程使用。
- [SamplerDPMPP_SDE](https://docs.comfy.org/built-in-nodes/SamplerDPMPP_SDE) — 内置节点参考页（官方暂无中文说明）
- [SamplerER_SDE](https://docs.comfy.org/built-in-nodes/SamplerER_SDE) — SamplerERSDE 节点为扩散模型提供专门的采样方法，支持不同的求解器类型：ER-SDE、Reverse-time SDE 和 ODE。
- [SamplerEulerAncestral](https://docs.comfy.org/built-in-nodes/SamplerEulerAncestral) — SamplerEulerAncestral 节点会创建一个可在图像生成过程中使用的 Euler Ancestral 采样器。
- [SamplerEulerAncestralCFGPP](https://docs.comfy.org/built-in-nodes/SamplerEulerAncestralCFGPP) — SamplerEulerAncestralCFG++ 节点创建一个采样器，该采样器使用 Euler Ancestral 方法并结合无分类器引导（CFG++）进行图像生成。
- [SamplerLCM](https://docs.comfy.org/built-in-nodes/SamplerLCM) — 此节点提供带有可调节每步噪声的 LCM（Latent Consistency Model）采样器。
- [SamplerLCMUpscale](https://docs.comfy.org/built-in-nodes/SamplerLCMUpscale) — 此节点提供一种专用采样方法，将潜在一致性模型（LCM）采样与渐进式图像放大相结合。
- [SamplerLMS](https://docs.comfy.org/built-in-nodes/SamplerLMS) — SamplerLMS 节点创建用于扩散模型的最小均方（LMS）采样器。
- [SamplerSASolver](https://docs.comfy.org/built-in-nodes/SamplerSASolver) — SamplerSASolver 节点为扩散模型创建并配置自定义采样器。
- [SamplerSEEDS2](https://docs.comfy.org/built-in-nodes/SamplerSEEDS2) — 此节点提供用于图像生成的可配置采样器。
- [VOIDSampler](https://docs.comfy.org/built-in-nodes/VOIDSampler) — VOIDSampler 是专为 VOID 修复模型设计的专用 DDIM 采样器。

##### Schedulers

- [AlignYourStepsScheduler](https://docs.comfy.org/built-in-nodes/AlignYourStepsScheduler) — AlignYourStepsScheduler 节点会根据不同的模型类型为去噪过程生成 sigma 值（噪声水平）。
- [BasicScheduler](https://docs.comfy.org/built-in-nodes/BasicScheduler) — BasicScheduler 节点旨在根据提供的 scheduler、model 和去噪参数，为扩散模型计算一组 sigma 值序列。
- [BetaSamplingScheduler](https://docs.comfy.org/built-in-nodes/BetaSamplingScheduler) — BetaSamplingScheduler 节点使用 beta 调度算法为采样过程生成一系列噪声水平（sigmas）。
- [ExponentialScheduler](https://docs.comfy.org/built-in-nodes/ExponentialScheduler) — ExponentialScheduler 节点旨在为扩散采样过程生成遵循指数调度的一系列 sigma 值。
- [Flux2Scheduler](https://docs.comfy.org/built-in-nodes/Flux2Scheduler) — Flux2Scheduler 生成用于去噪过程的噪声水平序列（sigmas），专门针对 Flux 模型定制。
- [GITSScheduler](https://docs.comfy.org/built-in-nodes/GITSScheduler) — GITSScheduler 节点为 GITS（Generative Iterative Time Steps，生成式迭代时间步）采样方法生成噪声调度 sigmas。
- [Ideogram4Scheduler](https://docs.comfy.org/built-in-nodes/Ideogram4Scheduler) — Ideogram 4 Scheduler 节点根据 Ideogram 4 参考调度，为扩散采样过程生成一系列 sigma 值（噪声水平）。
- [KarrasScheduler](https://docs.comfy.org/built-in-nodes/KarrasScheduler) — KarrasScheduler 节点用于根据 Karras 等人（2022）提出的噪声调度生成一系列噪声水平（sigma）。
- [LaplaceScheduler](https://docs.comfy.org/built-in-nodes/LaplaceScheduler) — LaplaceScheduler 节点生成一系列遵循拉普拉斯分布的 sigma 值，用于扩散采样。
- [LTXVScheduler](https://docs.comfy.org/built-in-nodes/LTXVScheduler) — LTXVScheduler 节点为自定义采样过程生成 sigma 值。
- [OptimalStepsScheduler](https://docs.comfy.org/built-in-nodes/OptimalStepsScheduler) — OptimalStepsScheduler 节点创建一个用于扩散采样期间的噪声调度（一系列 sigma 值）。
- [PolyexponentialScheduler](https://docs.comfy.org/built-in-nodes/PolyexponentialScheduler) — PolyexponentialScheduler 节点旨在基于多指数噪声调度生成一系列噪声水平（sigma）。
- [SDTurboScheduler](https://docs.comfy.org/built-in-nodes/SDTurboScheduler) — SDTurboScheduler 专为生成图像采样所需的 sigma 值序列而设计，可根据去噪程度和指定的步数调整序列。
- [VPScheduler](https://docs.comfy.org/built-in-nodes/VPScheduler) — VPScheduler 节点旨在基于方差保持（VP）调度方法生成一系列噪声水平（sigma 值）。

##### Sigmas

- [ExtendIntermediateSigmas](https://docs.comfy.org/built-in-nodes/ExtendIntermediateSigmas) — ExtendIntermediateSigmas 节点接收现有的 sigma 值序列，并在它们之间插入额外的中间 sigma 值。
- [FlipSigmas](https://docs.comfy.org/built-in-nodes/FlipSigmas) — FlipSigmas 节点旨在通过反转扩散模型中使用的 sigma 值序列顺序，并确保如果第一个值原本为零则将其设为非零值，来操控该序列。
- [ManualSigmas](https://docs.comfy.org/built-in-nodes/ManualSigmas) — ManualSigmas 节点允许你为采样过程手动定义自定义的噪声水平序列（sigmas）。
- [SamplingPercentToSigma](https://docs.comfy.org/built-in-nodes/SamplingPercentToSigma) — 使用所选模型的采样设置，将采样百分比转换为对应的 sigma 值。
- [SetFirstSigma](https://docs.comfy.org/built-in-nodes/SetFirstSigma) — SetFirstSigma 节点通过仅将序列中的第一个值替换为自定义 sigma 值来修改 sigma 序列。
- [SplitSigmas](https://docs.comfy.org/built-in-nodes/SplitSigmas) — SplitSigmas 节点用于根据指定步长将 sigma 值序列分割为两部分。
- [SplitSigmasDenoise](https://docs.comfy.org/built-in-nodes/SplitSigmasDenoise) — SplitSigmasDenoise 节点根据去噪强度参数将一串 sigma 值序列分为两部分。

#### Training

- [LoadTrainingDataset](https://docs.comfy.org/built-in-nodes/LoadTrainingDataset) — 此节点加载一个之前已保存到磁盘的编码训练数据集（latents 和 conditioning）。
- [LossGraphNode](https://docs.comfy.org/built-in-nodes/LossGraphNode) — LossGraphNode 创建训练损失值随训练步数变化的折线图，并将其显示为预览图像。
- [MakeTrainingDataset](https://docs.comfy.org/built-in-nodes/MakeTrainingDataset) — 此节点通过编码图像和文本来为训练准备数据。
- [ResolutionBucket](https://docs.comfy.org/built-in-nodes/ResolutionBucket) — 此节点按分辨率组织潜在图像列表及其对应的条件数据。
- [SaveTrainingDataset](https://docs.comfy.org/built-in-nodes/SaveTrainingDataset) — 此节点将编码后的训练数据集保存到磁盘，以便在训练期间高效加载。
- [TrainLoraNode](https://docs.comfy.org/built-in-nodes/TrainLoraNode) — TrainLoraNode 使用提供的潜空间数据和条件数据，在扩散模型上创建并训练一个 LoRA（低秩适配）模型。

### Partner


#### 3d


##### Meshy

- [MeshyAnimateModelNode](https://docs.comfy.org/built-in-nodes/MeshyAnimateModelNode) — 此节点使用 Meshy 服务对先前已绑定的 3D 角色应用特定的动画动作。
- [MeshyImageToModelNode](https://docs.comfy.org/built-in-nodes/MeshyImageToModelNode) — Mesh：Image to Model 节点使用 Meshy API，从单个输入图像生成 3D 模型。
- [MeshyMultiImageToModelNode](https://docs.comfy.org/built-in-nodes/MeshyMultiImageToModelNode) — 此节点使用 Meshy API 从多张输入图像生成 3D 模型。
- [MeshyRefineNode](https://docs.comfy.org/built-in-nodes/MeshyRefineNode) — Meshy: Refine Draft Model 节点获取来自先前 Meshy 任务的 3D 草稿模型并对其进行改进，可选择使用文本提示或参考图像添加纹理。
- [MeshyRigModelNode](https://docs.comfy.org/built-in-nodes/MeshyRigModelNode) — Meshy: Rig Model 节点从之前的 Meshy 任务中获取 3D 模型，并自动为其创建骨架，生成可以摆姿势和动画的绑定角色。
- [MeshyTextToModelNode](https://docs.comfy.org/built-in-nodes/MeshyTextToModelNode) — Meshy: Text to Model 节点使用 Meshy API 根据文本描述生成 3D 模型。
- [MeshyTextureMultiViewNode](https://docs.comfy.org/built-in-nodes/MeshyTextureMultiViewNode) — 此节点使用同一物体的 1 至 4 个参考视图，为先前创建的 3D 模型生成纹理。
- [MeshyTextureNode](https://docs.comfy.org/built-in-nodes/MeshyTextureNode) — Meshy: Texture Model 节点将 AI 生成的纹理应用到现有的 3D 模型。

##### Rodin

- [Rodin3D_Detail](https://docs.comfy.org/built-in-nodes/Rodin3D_Detail) — Rodin 3D 细节生成节点通过 Rodin API 生成高细节的 3D 资产。
- [Rodin3D_Gen2](https://docs.comfy.org/built-in-nodes/Rodin3D_Gen2) — Rodin3DGen2 节点使用 Rodin API 生成 3D 资产。
- [Rodin3D_Gen25_Image](https://docs.comfy.org/built-in-nodes/Rodin3D_Gen25_Image) — 内置节点参考页（官方暂无中文说明）
- [Rodin3D_Gen25_Text](https://docs.comfy.org/built-in-nodes/Rodin3D_Gen25_Text) — 内置节点参考页（官方暂无中文说明）
- [Rodin3D_Regular](https://docs.comfy.org/built-in-nodes/Rodin3D_Regular) — The Rodin 3D Regular node generates 3D assets using the Rodin API.
- [Rodin3D_Sketch](https://docs.comfy.org/built-in-nodes/Rodin3D_Sketch) — 此节点使用 Rodin API 生成 3D 资产。
- [Rodin3D_Smooth](https://docs.comfy.org/built-in-nodes/Rodin3D_Smooth) — The Rodin 3D Smooth node generates 3D assets using the Rodin API by processing input images and converting them into smooth 3D models.

##### Tencent

- [Tencent3DPartNode](https://docs.comfy.org/built-in-nodes/Tencent3DPartNode) — 此节点使用腾讯 Hunyuan3D API，根据 3D 模型的结构自动识别并生成其组件。
- [Tencent3DTextureEditNode](https://docs.comfy.org/built-in-nodes/Tencent3DTextureEditNode) — 此节点使用腾讯 Hunyuan3D API 编辑 3D 模型的纹理。
- [TencentImageToModelNode](https://docs.comfy.org/built-in-nodes/TencentImageToModelNode) — 此节点使用腾讯混元3D Pro API，根据一张或多张输入图像生成3D模型。
- [TencentModelTo3DUVNode](https://docs.comfy.org/built-in-nodes/TencentModelTo3DUVNode) — 此节点使用腾讯混元3D API对3D模型执行UV展开操作。
- [TencentSmartTopologyNode](https://docs.comfy.org/built-in-nodes/TencentSmartTopologyNode) — 此节点对 3D 模型执行智能重拓扑，自动创建具有优化多边形数量的全新、更干净的网格。
- [TencentTextToModelNode](https://docs.comfy.org/built-in-nodes/TencentTextToModelNode) — 此节点使用腾讯 Hunyuan3D Pro API 从文本描述生成 3D 模型。

##### Tripo

- [TripoConversionNode](https://docs.comfy.org/built-in-nodes/TripoConversionNode) — 此节点将现有的 Tripo 3D 模型转换为另一种 3D 文件格式。
- [TripoEditMultiviewNode](https://docs.comfy.org/built-in-nodes/TripoEditMultiviewNode) — 使用针对每个视图的单独文本指令编辑 Tripo: Image to Multiview 结果的视图。
- [TripoImageToModelNode](https://docs.comfy.org/built-in-nodes/TripoImageToModelNode) — 使用 Tripo 的 API 基于单张图像同步生成 3D 模型。
- [TripoImageToModelNodeV2](https://docs.comfy.org/built-in-nodes/TripoImageToModelNodeV2) — Tripo: Image to Model 节点使用 Tripo 的图像到模型服务，将单张参考图像转换为 3D 模型。
- [TripoImageToMultiviewNode](https://docs.comfy.org/built-in-nodes/TripoImageToMultiviewNode) — 使用 Tripo API 从单张输入图像生成主体的正面、左侧、背面和右侧视图。
- [TripoImportModelNode](https://docs.comfy.org/built-in-nodes/TripoImportModelNode) — 此节点将外部 3D 模型导入 Tripo，以便 Tripo 后处理节点（例如 Texture、Rig 和 Convert）可以使用它。
- [TripoMeshCompleteNode](https://docs.comfy.org/built-in-nodes/TripoMeshCompleteNode) — 完成分段 3D 模型的各个部件，并修复网格中缺失或损坏的区域。
- [TripoMultiviewToModelNode](https://docs.comfy.org/built-in-nodes/TripoMultiviewToModelNode) — 此节点使用 Tripo 的 API 同步生成 3D 模型，通过处理最多四张展示物体不同视图的图像（前、左、后、右）来实现。
- [TripoP1ImageToModelNode](https://docs.comfy.org/built-in-nodes/TripoP1ImageToModelNode) — Tripo P1: Image to Model 使用 Tripo P1 API 将单张 2D 图像转换为 3D 模型。
- [TripoP1MultiviewToModelNode](https://docs.comfy.org/built-in-nodes/TripoP1MultiviewToModelNode) — 此节点可根据物体或角色的两到四张参考图像生成 3D 模型。
- [TripoP1TextToModelNode](https://docs.comfy.org/built-in-nodes/TripoP1TextToModelNode) — Tripo P1 文本转 3D。
- [TripoPSeriesImageToModelNode](https://docs.comfy.org/built-in-nodes/TripoPSeriesImageToModelNode) — 使用 Tripo 的 P2 模型，从单张图像生成具有干净拓扑的低多边形 3D 模型。
- [TripoPSeriesMultiviewToModelNode](https://docs.comfy.org/built-in-nodes/TripoPSeriesMultiviewToModelNode) — 使用 Tripo 的 P2 模型，根据同一主体的多个视图生成具有干净拓扑的低多边形 3D 模型。
- [TripoPSeriesTextToModelNode](https://docs.comfy.org/built-in-nodes/TripoPSeriesTextToModelNode) — 使用 Tripo 的 P2 模型，根据文本提示生成具有干净拓扑的低多边形 3D 模型。
- [TripoRetargetNode](https://docs.comfy.org/built-in-nodes/TripoRetargetNode) — The TripoRetargetNode 将预设动画应用于现有的已绑定骨骼的 3D 模型。
- [TripoRetopologyNode](https://docs.comfy.org/built-in-nodes/TripoRetopologyNode) — Tripo: Retopology 接收由先前的 Tripo 节点生成的高多边形 3D 模型，并将其重建为具有干净拓扑的低多边形版本。
- [TripoRigCheckNode](https://docs.comfy.org/built-in-nodes/TripoRigCheckNode) — 此节点将已完成的 Tripo 3D 模型任务 ID 发送到 Tripo API，并检查该模型是否可进行绑定。
- [TripoRigNode](https://docs.comfy.org/built-in-nodes/TripoRigNode) — 此节点接收一个现有的 Tripo 3D 模型，并为其创建绑定骨骼后的版本，也就是说，模型会获得一副骨架，从而可以制作动画。
- [TripoSegmentNode](https://docs.comfy.org/built-in-nodes/TripoSegmentNode) — 此节点将 3D 模型拆分为各个部件。
- [TripoSmartSegmentNode](https://docs.comfy.org/built-in-nodes/TripoSmartSegmentNode) — 将一个 3D 模型拆分为具有语义意义的部分，并为每个部分命名。
- [TripoTextToModelNode](https://docs.comfy.org/built-in-nodes/TripoTextToModelNode) — 此旧版节点使用 Tripo 的 API 根据文本描述生成成品 3D 模型。
- [TripoTextToModelNodeV2](https://docs.comfy.org/built-in-nodes/TripoTextToModelNodeV2) — 使用 Tripo 服务根据文本描述生成 3D 模型。
- [TripoTextureNode](https://docs.comfy.org/built-in-nodes/TripoTextureNode) — 此节点在源代码中标记为已弃用（旧版）；显示名称为 “Tripo: Texture model (Legacy)”。
- [TripoTextureNodeV2](https://docs.comfy.org/built-in-nodes/TripoTextureNodeV2) — 此节点为 Tripo 工作流中已有的 3D 模型添加纹理，该模型通过前一步生成过程中的任务 ID 来标识。

#### Audio


##### Bytedance

- [ByteDanceSeedAudio](https://docs.comfy.org/built-in-nodes/ByteDanceSeedAudio) — 使用 ByteDance Seed Audio 1.0，通过单个提示词生成语音、音乐、音效和多说话人对话。

##### Elevenlabs

- [ElevenLabsAudioIsolation](https://docs.comfy.org/built-in-nodes/ElevenLabsAudioIsolation) — ElevenLabs 语音隔离节点可从音频文件中去除背景噪音，分离出人声或语音。
- [ElevenLabsInstantVoiceClone](https://docs.comfy.org/built-in-nodes/ElevenLabsInstantVoiceClone) — 此节点通过分析1到8段人声音频录音，创建全新的独特语音模型。
- [ElevenLabsSpeechToSpeech](https://docs.comfy.org/built-in-nodes/ElevenLabsSpeechToSpeech) — ElevenLabs 语音转语音节点可将输入音频文件从一种语音转换为另一种语音。
- [ElevenLabsSpeechToText](https://docs.comfy.org/built-in-nodes/ElevenLabsSpeechToText) — ElevenLabs 语音转文本节点使用 ElevenLabs API 将音频转写为文本。
- [ElevenLabsTextToDialogue](https://docs.comfy.org/built-in-nodes/ElevenLabsTextToDialogue) — ElevenLabs Text to Dialogue 节点根据文本生成多说话人音频对话。
- [ElevenLabsTextToSoundEffects](https://docs.comfy.org/built-in-nodes/ElevenLabsTextToSoundEffects) — ElevenLabs 文本转音效节点可根据文本描述生成音频音效。
- [ElevenLabsTextToSpeech](https://docs.comfy.org/built-in-nodes/ElevenLabsTextToSpeech) — ElevenLabs Text to Speech 节点使用 ElevenLabs API 将书面文本转换为语音音频。
- [ElevenLabsVoiceSelector](https://docs.comfy.org/built-in-nodes/ElevenLabsVoiceSelector) — ElevenLabs 语音选择器节点允许您从预定义的 ElevenLabs 文本转语音语音列表中选择特定语音。

##### Fish Audio

- [FishAudioInstantVoiceClone](https://docs.comfy.org/built-in-nodes/FishAudioInstantVoiceClone) — 此节点使用 Fish Audio API 根据您的录音创建私有克隆语音。
- [FishAudioSpeechToText](https://docs.comfy.org/built-in-nodes/FishAudioSpeechToText) — 此节点使用 Fish Audio 语音转文本服务将音频转录为文本。
- [FishAudioTextToSpeech](https://docs.comfy.org/built-in-nodes/FishAudioTextToSpeech) — 此节点使用 Fish Audio 文本转语音模型将书面文本转换为语音音频。
- [FishAudioVoiceSelector](https://docs.comfy.org/built-in-nodes/FishAudioVoiceSelector) — Fish Audio Voice Selector 节点从 Fish Audio 库中选择一个语音，用于文本转语音生成。

##### Heygen

- [HeyGenTextToSpeechNode](https://docs.comfy.org/built-in-nodes/HeyGenTextToSpeechNode) — 使用 HeyGen 的 Starfish TTS 引擎从文本生成语音音频。

##### Sonilo

- [SoniloTextToMusic](https://docs.comfy.org/built-in-nodes/SoniloTextToMusic) — Sonilo Text to Music 节点使用 Sonilo 的 AI 模型根据文本描述生成音乐。
- [SoniloVideoToMusic](https://docs.comfy.org/built-in-nodes/SoniloVideoToMusic) — 使用 Sonilo 的 AI 模型从视频生成音乐。

#### Image


##### Beeble

- [BeebleSwitchXImageEdit](https://docs.comfy.org/built-in-nodes/BeebleSwitchXImageEdit) — Edit a single image with Beeble SwitchX.

##### BFL

- [Flux2ImageNode](https://docs.comfy.org/built-in-nodes/Flux2ImageNode) — 使用 Flux.2 [pro] 或 Flux.2 [max] 模型，根据文本提示和可选参考图像生成图像。
- [FluxEraseNode](https://docs.comfy.org/built-in-nodes/FluxEraseNode) — 从图像中移除蒙版覆盖的对象并重建背景。
- [FluxProExpandNode](https://docs.comfy.org/built-in-nodes/FluxProExpandNode) — 根据提示词生成图像的外延。
- [FluxProFillNode](https://docs.comfy.org/built-in-nodes/FluxProFillNode) — 根据遮罩和提示词对图像进行修复。
- [FluxProUltraImageNode](https://docs.comfy.org/built-in-nodes/FluxProUltraImageNode) — 此文档由 AI 生成。
- [FluxVTONode](https://docs.comfy.org/built-in-nodes/FluxVTONode) — 此节点通过将人物穿上所提供服装图像中的服装来执行虚拟试穿。

##### Bria

- [BriaAddObject](https://docs.comfy.org/built-in-nodes/BriaAddObject) — 此节点使用 Bria 将纯文本描述的对象插入图像中。
- [BriaEraseByText](https://docs.comfy.org/built-in-nodes/BriaEraseByText) — 此节点使用 Bria 从图像中移除用纯文本描述的对象。
- [BriaEraseForeground](https://docs.comfy.org/built-in-nodes/BriaEraseForeground) — 此节点使用 Bria 移除图像的前景，并在原位置生成新的背景。
- [BriaEraser](https://docs.comfy.org/built-in-nodes/BriaEraser) — Bria Eraser 使用 Bria API 从图像中移除对象或区域。
- [BriaExpandImage](https://docs.comfy.org/built-in-nodes/BriaExpandImage) — Bria Expand Image 通过使用 Bria 生成新内容，将图像扩展到其原始边界之外。
- [BriaGenFill](https://docs.comfy.org/built-in-nodes/BriaGenFill) — 此节点使用 Bria 在图像的蒙版区域内生成物体或场景。
- [BriaImageEditNode](https://docs.comfy.org/built-in-nodes/BriaImageEditNode) — Bria FIBO 图像编辑节点根据文本指令编辑现有图像。
- [BriaIncreaseResolution](https://docs.comfy.org/built-in-nodes/BriaIncreaseResolution) — Bria Increase Resolution 使用 Bria 的图像放大服务将输入图像放大 2 倍或 4 倍，同时保留原始内容。
- [BriaRelight](https://docs.comfy.org/built-in-nodes/BriaRelight) — 此节点使用 Bria 改变图像的光照氛围和方向。
- [BriaRemoveImageBackground](https://docs.comfy.org/built-in-nodes/BriaRemoveImageBackground) — 此节点使用 Bria RMBG 2.0 服务从图像中移除背景。
- [BriaReplaceImageBackground](https://docs.comfy.org/built-in-nodes/BriaReplaceImageBackground) — 此节点将图像背景替换为由 Bria 生成的新背景。
- [BriaReplaceObject](https://docs.comfy.org/built-in-nodes/BriaReplaceObject) — 使用 Bria 的文本引导图像编辑，将图像中的一个对象替换为用纯文本描述的其他对象。
- [BriaReseason](https://docs.comfy.org/built-in-nodes/BriaReseason) — 此节点使用 Bria 将图像移动到另一个季节。
- [BriaRestorePhoto](https://docs.comfy.org/built-in-nodes/BriaRestorePhoto) — 此节点通过 Bria API 修复老旧或损坏的照片。

##### Bytedance

- [ByteDanceCreateImageAsset](https://docs.comfy.org/built-in-nodes/ByteDanceCreateImageAsset) — 此节点为字节跳动的 Seedance 2.0 服务创建个人图像资产。
- [ByteDanceSeedreamLayerSeparationNode](https://docs.comfy.org/built-in-nodes/ByteDanceSeedreamLayerSeparationNode) — ByteDance Seedream 5.0 Pro 图层分离功能可将图像分解为一个背景底板以及最多 16 个可重新定位的透明图层，每个图层均具有堆叠顺序、边界框、名称和描述。
- [ByteDanceSeedreamLayerSeparationNodeV2](https://docs.comfy.org/built-in-nodes/ByteDanceSeedreamLayerSeparationNodeV2) — ByteDance Seedream 5.0 Layer Separation 将图像分解为一个背景底板以及最多 16 个可重新定位的透明图层，每个图层都包含堆叠顺序、边界框、名称和描述。
- [ByteDanceSeedreamNode](https://docs.comfy.org/built-in-nodes/ByteDanceSeedreamNode) — 此文档由 AI 生成。
- [ByteDanceSeedreamNodeV2](https://docs.comfy.org/built-in-nodes/ByteDanceSeedreamNodeV2) — 此节点使用字节跳动的 Seedream 模型（版本 4.0、4.5、5.0 Lite 和 5.0 Pro）生成或编辑图像。
- [ByteDanceSeedreamNodeV3](https://docs.comfy.org/built-in-nodes/ByteDanceSeedreamNodeV3) — ByteDance Seedream 4.5 & 5.0 可使用 ByteDance Seedream 4.0、4.5 和 5.0 模型，通过文本提示词生成图像（文生图），或在可选参考图像的引导下生成/编辑图像，分辨率最高可达 4K。

##### Gemini

- [GeminiImage2Node](https://docs.comfy.org/built-in-nodes/GeminiImage2Node) — 通过 Google Vertex AI Gemini API 同步生成或编辑图像。
- [GeminiImageNode](https://docs.comfy.org/built-in-nodes/GeminiImageNode) — GeminiImage 节点通过 Google 的 Gemini AI 模型生成文本和图像响应。
- [GeminiNanoBanana2](https://docs.comfy.org/built-in-nodes/GeminiNanoBanana2) — Nano Banana 2 节点通过 Google Vertex API 使用 Gemini 3.1 Flash Image 模型同步生成或编辑图像。
- [GeminiNanoBanana2V2](https://docs.comfy.org/built-in-nodes/GeminiNanoBanana2V2) — 此节点通过 Gemini 图像模型将文本提示词发送到 Google 的 Vertex AI API，从而生成或编辑图像。

##### Grok

- [GrokImageEditNode](https://docs.comfy.org/built-in-nodes/GrokImageEditNode) — Grok Image Edit 节点基于文本提示修改现有图像。
- [GrokImageEditNodeV2](https://docs.comfy.org/built-in-nodes/GrokImageEditNodeV2) — 基于文本提示修改一张或多张现有图像。
- [GrokImageNode](https://docs.comfy.org/built-in-nodes/GrokImageNode) — Grok Image 节点使用 Grok AI 模型根据文本描述生成一张或多张图像。

##### Hitpaw

- [HitPawGeneralImageEnhance](https://docs.comfy.org/built-in-nodes/HitPawGeneralImageEnhance) — 此节点通过将低分辨率图像放大到超分辨率，同时去除伪影和噪点，来增强低分辨率图像。

##### Ideogram

- [IdeogramPImage](https://docs.comfy.org/built-in-nodes/IdeogramPImage) — Ideogram & Pruna P-Image 使用 Ideogram 的快速文本到图像模型从文本提示词生成图像，该模型以强大的排版和照片级真实感而闻名。
- [IdeogramV3](https://docs.comfy.org/built-in-nodes/IdeogramV3) — 此节点使用 Ideogram V3 模型生成图像。
- [IdeogramV4](https://docs.comfy.org/built-in-nodes/IdeogramV4) — 根据文本提示，使用 Ideogram 4.0 模型生成图像。

##### Kling

- [KlingImageGenerationNode](https://docs.comfy.org/built-in-nodes/KlingImageGenerationNode) — Kling 图像生成节点从文本提示词生成图像，并可以选择使用参考图像进行引导。
- [KlingOmniProImageNode](https://docs.comfy.org/built-in-nodes/KlingOmniProImageNode) — Kling Omni Image (Pro) 节点使用最新的 Kling AI 模型创建或编辑图像。

##### Krea

- [Krea2ImageNode](https://docs.comfy.org/built-in-nodes/Krea2ImageNode) — 内置节点参考页（官方暂无中文说明）
- [Krea2StyleReferenceNode](https://docs.comfy.org/built-in-nodes/Krea2StyleReferenceNode) — The Krea 2 Style Reference node lets you add a reference image to influence the style of a Krea 2 image generation.

##### Luma

- [LumaImageEditNode2](https://docs.comfy.org/built-in-nodes/LumaImageEditNode2) — 此节点基于 Luma UNI-1 模型，使用文本提示词编辑现有图像。
- [LumaImageModifyNode](https://docs.comfy.org/built-in-nodes/LumaImageModifyNode) — 根据文本提示和原始图像的宽高比同步修改图像。
- [LumaImageNode](https://docs.comfy.org/built-in-nodes/LumaImageNode) — 此文档由 AI 生成。
- [LumaImageNode2](https://docs.comfy.org/built-in-nodes/LumaImageNode2) — 此节点使用 Luma UNI-1 模型根据文本描述生成图像。
- [LumaReferenceNode](https://docs.comfy.org/built-in-nodes/LumaReferenceNode) — 此节点用于保存图像及其权重值，供 Luma 生成图像节点使用。

##### Magnific

- [MagnificImageRelightNode](https://docs.comfy.org/built-in-nodes/MagnificImageRelightNode) — Magnific Image Relight 节点用于调整输入图像的照明效果。
- [MagnificImageSkinEnhancerNode](https://docs.comfy.org/built-in-nodes/MagnificImageSkinEnhancerNode) — Magnific 图像皮肤增强节点对肖像图像应用专门的 AI 处理，以改善皮肤外观。
- [MagnificImageStyleTransferNode](https://docs.comfy.org/built-in-nodes/MagnificImageStyleTransferNode) — 此节点将参考图像的视觉风格应用于您的输入图像。
- [MagnificImageUpscalerCreativeNode](https://docs.comfy.org/built-in-nodes/MagnificImageUpscalerCreativeNode) — 此节点使用 Magnific AI 服务对图像进行放大和创意增强。
- [MagnificImageUpscalerPreciseV2Node](https://docs.comfy.org/built-in-nodes/MagnificImageUpscalerPreciseV2Node) — Magnific Image Upscale (Precise V2) 节点执行高保真图像放大，并可精细控制锐度、颗粒感和细节增强。

##### Meta

- [MetaMuseImageEditApi](https://docs.comfy.org/built-in-nodes/MetaMuseImageEditApi) — 使用文本提示和 Meta 的 Muse Image 模型编辑或组合最多 10 张参考图像。
- [MetaMuseImageTextToImageApi](https://docs.comfy.org/built-in-nodes/MetaMuseImageTextToImageApi) — Meta Muse Image 文生图节点使用 Meta 的 Muse Image 模型，根据文本提示词生成图像。

##### Openai

- [OpenAIGPTImage1](https://docs.comfy.org/built-in-nodes/OpenAIGPTImage1) — 通过 OpenAI 的 GPT Image 端点同步生成图像。
- [OpenAIGPTImageNodeV2](https://docs.comfy.org/built-in-nodes/OpenAIGPTImageNodeV2) — 此节点使用 OpenAI 的 GPT Image API 生成图像。

##### Openrouter

- [OpenRouterImageNode](https://docs.comfy.org/built-in-nodes/OpenRouterImageNode) — 此节点通过 OpenRouter 使用 Microsoft 的 MAI-Image-2.6 模型生成或编辑图像。

##### Quiver

- [QuiverImageToSVGNode](https://docs.comfy.org/built-in-nodes/QuiverImageToSVGNode) — 此节点使用 Quiver AI 的矢量化模型将栅格图像转换为可缩放矢量图形 (SVG)。
- [QuiverTextToSVGNode](https://docs.comfy.org/built-in-nodes/QuiverTextToSVGNode) — Quiver Text to SVG 节点使用 Quiver AI 的模型，根据文本描述生成可缩放矢量图形（SVG）图像。

##### Qwen

- [QwenImageEditApi](https://docs.comfy.org/built-in-nodes/QwenImageEditApi) — 此节点使用 Qwen-Image 3.0 模型，在文本提示词的引导下编辑或组合最多 3 张参考图像。
- [QwenImageTextToImageApi](https://docs.comfy.org/built-in-nodes/QwenImageTextToImageApi) — Qwen Image 3 Text to Image 使用 Qwen-Image 3.0 模型，根据文本提示词生成一张或多张图像。

##### Recraft

- [RecraftColorRGB](https://docs.comfy.org/built-in-nodes/RecraftColorRGB) — 通过指定独立的红、绿、蓝数值创建 Recraft 颜色。
- [RecraftControls](https://docs.comfy.org/built-in-nodes/RecraftControls) — 此文档由 AI 生成。
- [RecraftCreateStyleNode](https://docs.comfy.org/built-in-nodes/RecraftCreateStyleNode) — 此节点通过上传参考图像创建用于图像生成的定制风格。
- [RecraftCreativeUpscaleNode](https://docs.comfy.org/built-in-nodes/RecraftCreativeUpscaleNode) — 此文档由 AI 生成。
- [RecraftCrispUpscaleNode](https://docs.comfy.org/built-in-nodes/RecraftCrispUpscaleNode) — 此节点使用 "crisp upscale" 工具对图像进行同步放大。
- [RecraftImageInpaintingNode](https://docs.comfy.org/built-in-nodes/RecraftImageInpaintingNode) — 此节点根据文本提示和遮罩修改图像的特定区域。
- [RecraftImageToImageNode](https://docs.comfy.org/built-in-nodes/RecraftImageToImageNode) — 此节点根据文本提示和强度设置修改现有图像。
- [RecraftRemoveBackgroundNode](https://docs.comfy.org/built-in-nodes/RecraftRemoveBackgroundNode) — 此节点使用 Recraft API 服务从图像中移除背景。
- [RecraftReplaceBackgroundNode](https://docs.comfy.org/built-in-nodes/RecraftReplaceBackgroundNode) — 根据提供的提示词替换图像背景。
- [RecraftStyleV3DigitalIllustration](https://docs.comfy.org/built-in-nodes/RecraftStyleV3DigitalIllustration) — 此节点用于配置 Recraft API 使用的样式，专门选择"数字插画"风格。
- [RecraftStyleV3InfiniteStyleLibrary](https://docs.comfy.org/built-in-nodes/RecraftStyleV3InfiniteStyleLibrary) — 此节点允许您使用已有的 UUID 从 Recraft 的无限样式库中选择一种样式。
- [RecraftStyleV3LogoRaster](https://docs.comfy.org/built-in-nodes/RecraftStyleV3LogoRaster) — 此节点选择 Logo 栅格风格和特定子风格，用于生成 Logo 图像。
- [RecraftStyleV3RealisticImage](https://docs.comfy.org/built-in-nodes/RecraftStyleV3RealisticImage) — 此节点用于创建生成逼真图像的样式配置，通过 Recraft 的 API 实现。
- [RecraftStyleV3VectorIllustrationNode](https://docs.comfy.org/built-in-nodes/RecraftStyleV3VectorIllustrationNode) — 此节点为 Recraft API 选择一个风格，具体来说属于矢量插画（vector illustration）风格类别。
- [RecraftTextToImageNode](https://docs.comfy.org/built-in-nodes/RecraftTextToImageNode) — 根据提示词和分辨率同步生成图像。
- [RecraftTextToVectorNode](https://docs.comfy.org/built-in-nodes/RecraftTextToVectorNode) — 根据文本提示和分辨率同步生成 SVG 矢量插画。
- [RecraftV4CreateStyleNode](https://docs.comfy.org/built-in-nodes/RecraftV4CreateStyleNode) — 此节点根据 1 到 10 张参考图像创建可复用的 Recraft V4 风格。
- [RecraftV4TextToImageNode](https://docs.comfy.org/built-in-nodes/RecraftV4TextToImageNode) — 使用 Recraft V4 和 V4.1 模型根据文本提示词生成图像。
- [RecraftV4TextToVectorNode](https://docs.comfy.org/built-in-nodes/RecraftV4TextToVectorNode) — Recraft V4 文本转矢量节点使用 Recraft V4 和 V4.1 模型，根据文本描述生成可缩放矢量图形（SVG）插图。
- [RecraftVectorizeImageNode](https://docs.comfy.org/built-in-nodes/RecraftVectorizeImageNode) — 从输入图像同步生成 SVG。

##### Reve

- [ReveImageCreateNode](https://docs.comfy.org/built-in-nodes/ReveImageCreateNode) — Reve Image Create 节点使用 Reve AI 模型根据文本描述生成图像。
- [ReveImageEditNode](https://docs.comfy.org/built-in-nodes/ReveImageEditNode) — Reve Image Edit 节点根据自然语言文本指令修改现有图像。
- [ReveImageRemixNode](https://docs.comfy.org/built-in-nodes/ReveImageRemixNode) — Reve Image Remix 节点使用 Reve API 生成新图像。

##### Runway

- [RunwayTextToImageNode](https://docs.comfy.org/built-in-nodes/RunwayTextToImageNode) — Runway 文本转图像节点使用 Runway 的 Gen 4 模型，根据文本提示生成图像。

##### Tencent

- [HunyuanImageEditApi](https://docs.comfy.org/built-in-nodes/HunyuanImageEditApi) — Tencent HY Image: Edit 节点使用腾讯的 Hunyuan Image 模型，根据文本指令编辑或组合参考图像。
- [HunyuanImageTextToImageApi](https://docs.comfy.org/built-in-nodes/HunyuanImageTextToImageApi) — Tencent HY Image: Text to Image 节点使用腾讯的 Hunyuan Image 模型，根据文本描述生成图像。

##### Topaz

- [TopazImageEnhance](https://docs.comfy.org/built-in-nodes/TopazImageEnhance) — Topaz Image Enhance 节点提供行业标准的放大和图像增强功能。
- [TopazImageEnhanceV2](https://docs.comfy.org/built-in-nodes/TopazImageEnhanceV2) — Topaz Image Enhance 使用 Topaz 模型对单张输入图像应用行业标准的放大和图像增强。

##### Wan

- [WanImageToImageApi](https://docs.comfy.org/built-in-nodes/WanImageToImageApi) — Wan 图像到图像节点根据一张或两张输入图像以及文本提示生成一张新图像。
- [WanTextToImageApi](https://docs.comfy.org/built-in-nodes/WanTextToImageApi) — Wan 文本到图像节点根据文本描述生成图像。

##### Wavespeed

- [WavespeedImageUpscaleNode](https://docs.comfy.org/built-in-nodes/WavespeedImageUpscaleNode) — WaveSpeed 图像放大节点使用外部 AI 服务来提高图像的分辨率和质量。

#### Text


##### Anthropic

- [ClaudeNode](https://docs.comfy.org/built-in-nodes/ClaudeNode) — 从 Anthropic 的 Claude 模型生成文本回复。

##### Bytedance

- [ByteDanceSeedNode](https://docs.comfy.org/built-in-nodes/ByteDanceSeedNode) — 使用 ByteDance 的 Seed 2.0 模型生成文本响应。

##### Gemini

- [GeminiInputFiles](https://docs.comfy.org/built-in-nodes/GeminiInputFiles) — 此文档由 AI 生成。
- [GeminiNode](https://docs.comfy.org/built-in-nodes/GeminiNode) — 此节点允许用户与 Google 的 Gemini AI 模型交互，以生成文本回复。
- [GeminiNodeV2](https://docs.comfy.org/built-in-nodes/GeminiNodeV2) — 使用 Google 的 Gemini 模型生成文本回复。
- [GeminiNodeV3](https://docs.comfy.org/built-in-nodes/GeminiNodeV3) — 使用 Google Gemini 模型生成文本回复。

##### Openai

- [OpenAIChatConfig](https://docs.comfy.org/built-in-nodes/OpenAIChatConfig) — OpenAIChatConfig 节点定义用于控制 OpenAI Chat 节点如何生成响应的高级选项。
- [OpenAIChatNode](https://docs.comfy.org/built-in-nodes/OpenAIChatNode) — 此节点从 OpenAI 模型生成文本响应。
- [OpenAIInputFiles](https://docs.comfy.org/built-in-nodes/OpenAIInputFiles) — 加载并格式化 OpenAI API 的输入文件。

##### Openrouter

- [OpenRouterLLMNode](https://docs.comfy.org/built-in-nodes/OpenRouterLLMNode) — OpenRouter LLM 节点将文本提示词发送给通过 OpenRouter 服务提供的一组精选热门语言模型，并返回生成的文本响应。

#### Video


##### Beeble

- [BeebleSwitchXVideoEdit](https://docs.comfy.org/built-in-nodes/BeebleSwitchXVideoEdit) — 使用 Beeble SwitchX 编辑视频。

##### BFL

- [Flux3ImageToVideoNode](https://docs.comfy.org/built-in-nodes/Flux3ImageToVideoNode) — Flux 3 Image to Video 使用 FLUX 3 为 1 到 10 张图像制作动画。
- [Flux3TextToVideoNode](https://docs.comfy.org/built-in-nodes/Flux3TextToVideoNode) — 使用 FLUX 3 根据文本提示词生成带有同步音频的视频。
- [Flux3VideoContinuationNode](https://docs.comfy.org/built-in-nodes/Flux3VideoContinuationNode) — 此节点使用 FLUX 3 续写现有视频片段：新片段会从您提供视频的最后几帧继续。
- [FluxVideoEditNode](https://docs.comfy.org/built-in-nodes/FluxVideoEditNode) — 编辑现有视频片段，依据文字指令进行修改。
- [FluxVideoUpscaleNode](https://docs.comfy.org/built-in-nodes/FluxVideoUpscaleNode) — Flux Video Upscale 使用 FLUX 超分辨率将视频片段放大 1.5 到 3 倍。

##### Bria

- [BriaRemoveVideoBackground](https://docs.comfy.org/built-in-nodes/BriaRemoveVideoBackground) — 此节点使用 Bria AI 服务移除视频背景。
- [BriaTransparentVideoBackground](https://docs.comfy.org/built-in-nodes/BriaTransparentVideoBackground) — 此节点使用 Bria 的 AI 服务移除视频背景，并输出抠图后的帧以及 Alpha 遮罩。
- [BriaVideoEraser](https://docs.comfy.org/built-in-nodes/BriaVideoEraser) — 使用 Bria 从视频中擦除逐帧遮罩覆盖的任何内容，并填补空缺。
- [BriaVideoGreenScreen](https://docs.comfy.org/built-in-nodes/BriaVideoGreenScreen) — 此节点使用 Bria API 将视频的背景替换为纯色色度键（chroma-key）屏幕。
- [BriaVideoReplaceBackground](https://docs.comfy.org/built-in-nodes/BriaVideoReplaceBackground) — 此节点使用 Bria 的 API，用提供的图像或视频替换视频的背景。

##### Bytedance

- [ByteDance2DraftToFinalVideoNode](https://docs.comfy.org/built-in-nodes/ByteDance2DraftToFinalVideoNode) — 此节点用于渲染 Seedance 2.5 Draft 的 1080p 最终视频。
- [ByteDance2FirstLastFrameNode](https://docs.comfy.org/built-in-nodes/ByteDance2FirstLastFrameNode) — 此节点使用 ByteDance Seedance 模型，根据必需的首帧图像和可选的尾帧图像生成视频。
- [ByteDance2ReferenceNode](https://docs.comfy.org/built-in-nodes/ByteDance2ReferenceNode) — 此节点使用字节跳动的 Seedance 2.5 或 Seedance 2.0 AI 模型生成、编辑或延长视频。
- [ByteDance2ReferenceNodeV2](https://docs.comfy.org/built-in-nodes/ByteDance2ReferenceNodeV2) — ByteDance Seedance 2.5 Reference to Video 使用 ByteDance Seedance 模型（Seedance 2.5、2.5 Draft、2.0、2.0 Fast 和 2.0 Mini），在文本提示词以及可选的参考图像、视频、音频或先前上传的库资源的引导下，生成、编辑或扩展视频。
- [ByteDance2TextToVideoNode](https://docs.comfy.org/built-in-nodes/ByteDance2TextToVideoNode) — 此节点使用 ByteDance 的 Seedance 2.5 或 2.0 模型，根据文本提示生成视频。
- [ByteDanceCreateVideoAsset](https://docs.comfy.org/built-in-nodes/ByteDanceCreateVideoAsset) — 此节点用于为 Seedance 2.0 创建个人视频资产。
- [ByteDanceFirstLastFrameNode](https://docs.comfy.org/built-in-nodes/ByteDanceFirstLastFrameNode) — 此节点使用文本提示词以及首帧和尾帧图像来生成视频。
- [ByteDanceImageToVideoNode](https://docs.comfy.org/built-in-nodes/ByteDanceImageToVideoNode) — ByteDance Image to Video 节点通过 API，基于输入图像和文本提示词，使用 ByteDance 模型生成视频。
- [ByteDanceTextToVideoNode](https://docs.comfy.org/built-in-nodes/ByteDanceTextToVideoNode) — 字节跳动文本转视频节点通过 API 基于文本提示词，使用字节跳动模型生成视频。
- [ByteDanceVideoEnhanceNode](https://docs.comfy.org/built-in-nodes/ByteDanceVideoEnhanceNode) — 此节点使用 ByteDance vCube 对视频进行放大和修复。

##### Gemini

- [GeminiVideoOmni](https://docs.comfy.org/built-in-nodes/GeminiVideoOmni) — 使用 Google 的 Gemini Omni Flash 模型，根据文本提示生成带有音频的视频。
- [GeminiVideoOmniV2](https://docs.comfy.org/built-in-nodes/GeminiVideoOmniV2) — Google Gemini Omni (Video) 使用 Google 的 Gemini Omni Flash 模型，根据文本提示生成带音频的视频。

##### Grok

- [GrokVideoEditNode](https://docs.comfy.org/built-in-nodes/GrokVideoEditNode) — 此节点使用 Grok API 根据文本提示编辑现有视频。
- [GrokVideoExtendNode](https://docs.comfy.org/built-in-nodes/GrokVideoExtendNode) — Grok Video Extend 节点基于文本提示扩展现有视频并实现无缝续接。
- [GrokVideoNode](https://docs.comfy.org/built-in-nodes/GrokVideoNode) — Grok Video 节点根据文本描述生成短视频。
- [GrokVideoReferenceNode](https://docs.comfy.org/built-in-nodes/GrokVideoReferenceNode) — Grok 参考转视频节点根据文本提示生成视频，使用最多七张参考图像来引导输出的风格和内容。

##### Heygen

- [HeyGenAvatarVideoNode](https://docs.comfy.org/built-in-nodes/HeyGenAvatarVideoNode) — 从 HeyGen 虚拟形象生成一个会说话的主持人视频。
- [HeyGenCreateAvatarNode](https://docs.comfy.org/built-in-nodes/HeyGenCreateAvatarNode) — 从人物照片或描述要生成角色的文本提示创建可复用的 HeyGen 虚拟形象。
- [HeyGenTalkingPhotoNode](https://docs.comfy.org/built-in-nodes/HeyGenTalkingPhotoNode) — 使用 HeyGen 的 Avatar IV 技术，将人物的静态图像动画化为唇形同步的说话视频。
- [HeyGenVideoTranslateNode](https://docs.comfy.org/built-in-nodes/HeyGenVideoTranslateNode) — 将带语音的视频翻译成另一种语言，并应用声音克隆和唇形同步。

##### Hitpaw

- [HitPawVideoEnhance](https://docs.comfy.org/built-in-nodes/HitPawVideoEnhance) — HitPaw Video Enhance 节点使用外部 API 来提高视频质量。

##### Kling

- [KlingAvatarNode](https://docs.comfy.org/built-in-nodes/KlingAvatarNode) — The Kling Avatar 2.0 node generates broadcast-style digital human videos from a single reference photo and an audio file.
- [KlingFirstLastFrameNode](https://docs.comfy.org/built-in-nodes/KlingFirstLastFrameNode) — 此节点使用 Kling 3.0 模型生成视频。
- [KlingImage2VideoNode](https://docs.comfy.org/built-in-nodes/KlingImage2VideoNode) — Kling 图像转视频节点使用起始图像作为第一帧生成短视频。
- [KlingImageToVideoWithAudio](https://docs.comfy.org/built-in-nodes/KlingImageToVideoWithAudio) — 此文档由 AI 生成。
- [KlingLipSyncAudioToVideoNode](https://docs.comfy.org/built-in-nodes/KlingLipSyncAudioToVideoNode) — Kling 音频到视频口型同步节点可将视频文件中的嘴部动作与音频文件的音频内容同步。
- [KlingLipSyncTextToVideoNode](https://docs.comfy.org/built-in-nodes/KlingLipSyncTextToVideoNode) — Kling Lip Sync Text to Video 节点可将视频文件中的嘴部动作与文本提示同步。
- [KlingMotionControl](https://docs.comfy.org/built-in-nodes/KlingMotionControl) — The Kling Motion Control node generates a video by applying the motion, expressions, and camera movements from a reference video to a character defined by a reference image and a t
- [KlingOmniProEditVideoNode](https://docs.comfy.org/built-in-nodes/KlingOmniProEditVideoNode) — Kling Omni 编辑视频（专业版）节点使用 AI 模型，根据文本描述编辑现有视频。
- [KlingOmniProFirstLastFrameNode](https://docs.comfy.org/built-in-nodes/KlingOmniProFirstLastFrameNode) — 此节点使用最新的 Kling AI 模型，从起始帧、可选结束帧或参考图像生成视频。
- [KlingOmniProImageToVideoNode](https://docs.comfy.org/built-in-nodes/KlingOmniProImageToVideoNode) — 此节点使用 Kling AI 模型，根据文本提示词和最多七张参考图像生成视频。
- [KlingOmniProTextToVideoNode](https://docs.comfy.org/built-in-nodes/KlingOmniProTextToVideoNode) — 此节点使用最新的 Kling AI 模型根据文本描述生成视频。
- [KlingOmniProVideoToVideoNode](https://docs.comfy.org/built-in-nodes/KlingOmniProVideoToVideoNode) — 此节点使用 Kling AI 模型，基于输入视频和可选参考图像生成新视频。
- [KlingStartEndFrameNode](https://docs.comfy.org/built-in-nodes/KlingStartEndFrameNode) — 此节点创建一段视频序列，在您提供的起始图像和结束图像之间进行过渡。
- [KlingTextToVideoNode](https://docs.comfy.org/built-in-nodes/KlingTextToVideoNode) — Kling Text to Video 节点使用 Kling 视频生成 API 根据文本描述生成视频。
- [KlingTextToVideoWithAudio](https://docs.comfy.org/built-in-nodes/KlingTextToVideoWithAudio) — Kling Text to Video with Audio 节点可根据文本描述生成短视频。
- [KlingVideoNode](https://docs.comfy.org/built-in-nodes/KlingVideoNode) — 此节点使用 Kling V3 模型生成视频。

##### LTXV

- [LtxApi25AudioToVideo](https://docs.comfy.org/built-in-nodes/LtxApi25AudioToVideo) — 此节点使用 LTX 2.5 模型生成跟随音轨的视频。
- [LtxApi25ImageToVideo](https://docs.comfy.org/built-in-nodes/LtxApi25ImageToVideo) — 此节点使用 LTX 2.5 模型从起始图像生成专业质量的视频。
- [LtxApi25TextToVideo](https://docs.comfy.org/built-in-nodes/LtxApi25TextToVideo) — LTX 2.5 文生视频是一个 API 节点，使用 LTX 2.5 模型根据文本描述生成专业品质的视频。

##### Luma

- [LumaConceptsNode](https://docs.comfy.org/built-in-nodes/LumaConceptsNode) — 此文档由 AI 生成。
- [LumaImageToVideoNode](https://docs.comfy.org/built-in-nodes/LumaImageToVideoNode) — 根据文本提示和可选的起始/结束图像同步生成视频。
- [LumaRay32ExtendVideoNode](https://docs.comfy.org/built-in-nodes/LumaRay32ExtendVideoNode) — Luma Ray 3.2 Extend Video 通过创建新的 5 秒片段来延续先前的 Luma Ray 3.2 视频生成，该片段可以位于原始片段之后（forward）或之前（backward）。
- [LumaRay32ImageToVideoNode](https://docs.comfy.org/built-in-nodes/LumaRay32ImageToVideoNode) — 使用 Luma 的 Ray 3.2 模型，根据起始帧和/或结束帧生成视频。
- [LumaRay32KeyframeNode](https://docs.comfy.org/built-in-nodes/LumaRay32KeyframeNode) — 此节点将引导图像锚定到 Luma Ray 3.2 输出视频时间线上的特定位置。
- [LumaRay32KeyframesToVideoNode](https://docs.comfy.org/built-in-nodes/LumaRay32KeyframesToVideoNode) — 此节点使用 Luma Ray 3.2 生成一段视频，该视频通过一系列引导图像进行插值，每张引导图像都锚定到时间轴上的特定位置。
- [LumaRay32TextToVideoNode](https://docs.comfy.org/built-in-nodes/LumaRay32TextToVideoNode) — 此节点使用 Luma 的 Ray 3.2 模型，根据文本提示生成视频。
- [LumaRay32VideoEditNode](https://docs.comfy.org/built-in-nodes/LumaRay32VideoEditNode) — 内置节点参考页（官方暂无中文说明）
- [LumaRay32VideoReframeNode](https://docs.comfy.org/built-in-nodes/LumaRay32VideoReframeNode) — 此节点使用 Luma Ray 3.2 更改现有视频的宽高比，通过生成内容填充新暴露的画布区域。
- [LumaVideoNode](https://docs.comfy.org/built-in-nodes/LumaVideoNode) — 根据文本提示和输出设置同步生成视频。

##### Minimax

- [MinimaxHailuo03ContextIRNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuo03ContextIRNode) — 内置节点参考页（官方暂无中文说明）
- [MinimaxHailuo03FirstLastFrameNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuo03FirstLastFrameNode) — 此节点使用 MiniMax H3 模型，根据首帧图像以及可选的末帧图像生成视频。
- [MinimaxHailuo03ReferenceNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuo03ReferenceNode) — 此节点使用 MiniMax H3 模型生成视频，并以参考图像、视频和音频作为条件。
- [MinimaxHailuo03RegenerateNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuo03RegenerateNode) — 此节点将 MiniMax H3 768P 视频输出重新渲染为 2K 分辨率。
- [MinimaxHailuo03TextToVideoNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuo03TextToVideoNode) — 此节点使用 MiniMax H3 系列模型（MiniMax H3、MiniMax H3 Max 和 MiniMax H3 Max Turbo）根据文本提示生成视频。
- [MinimaxHailuoVideoNode](https://docs.comfy.org/built-in-nodes/MinimaxHailuoVideoNode) — 使用 MiniMax Hailuo-02 模型根据文本提示词生成视频。
- [MinimaxImageToVideoNode](https://docs.comfy.org/built-in-nodes/MinimaxImageToVideoNode) — 此文档由 AI 生成。
- [MinimaxSubjectToVideoNode](https://docs.comfy.org/built-in-nodes/MinimaxSubjectToVideoNode) — 使用 MiniMax API，基于主体图像和文本提示同步生成视频。
- [MinimaxTextToVideoNode](https://docs.comfy.org/built-in-nodes/MinimaxTextToVideoNode) — 此文档由 AI 生成。

##### Pixverse

- [PixverseImageToVideoNode](https://docs.comfy.org/built-in-nodes/PixverseImageToVideoNode) — 使用 PixVerse 从静态图像和文本提示生成视频。
- [PixverseTemplateNode](https://docs.comfy.org/built-in-nodes/PixverseTemplateNode) — PixVerse 模板节点允许您从可用的模板中选择用于 PixVerse 视频生成的模板。
- [PixverseTextToVideoNode](https://docs.comfy.org/built-in-nodes/PixverseTextToVideoNode) — 使用 PixVerse API 根据文本提示词生成视频。
- [PixverseTransitionVideoNode](https://docs.comfy.org/built-in-nodes/PixverseTransitionVideoNode) — 使用 PixVerse API 在两个输入图像之间生成一段过渡视频。
- [PixverseV6ExtendVideoNode](https://docs.comfy.org/built-in-nodes/PixverseV6ExtendVideoNode) — 此节点使用 PixVerse V6 模型对现有视频进行续写，并可在续写的同时选择生成原生音轨。
- [PixverseV6FirstLastFrameNode](https://docs.comfy.org/built-in-nodes/PixverseV6FirstLastFrameNode) — PixVerse V6 First-Last-Frame to Video 使用 PixVerse 生成从首帧过渡到尾帧的视频，并可选生成原生音频。
- [PixverseV6FusionVideoNode](https://docs.comfy.org/built-in-nodes/PixverseV6FusionVideoNode) — PixVerse V6 Fusion (Reference to Video) 使用 PixVerse 根据参考主体、背景和视频合成视频。
- [PixverseV6ImageToVideoNode](https://docs.comfy.org/built-in-nodes/PixverseV6ImageToVideoNode) — 此节点使用 PixVerse V6 模型为输入图像添加动画，并返回视频，可选带原生音轨。
- [PixverseV6TextToVideoNode](https://docs.comfy.org/built-in-nodes/PixverseV6TextToVideoNode) — PixVerse V6 文本转视频节点使用 PixVerse 的 V6 模型根据文本提示词生成视频。

##### Pruna

- [PrunaImageToVideoNode](https://docs.comfy.org/built-in-nodes/PrunaImageToVideoNode) — 使用 Pruna 的 P-Video-2 模型将图像动画化为视频。
- [PrunaTextToVideoNode](https://docs.comfy.org/built-in-nodes/PrunaTextToVideoNode) — 使用 Pruna 的 P-Video-2 模型根据文本提示生成视频。

##### Runway

- [RunwayAleph2KeyframeNode](https://docs.comfy.org/built-in-nodes/RunwayAleph2KeyframeNode) — Runway Aleph2 关键帧节点将引导图像锚定到输入视频的特定时刻
- [RunwayAleph2PromptImageNode](https://docs.comfy.org/built-in-nodes/RunwayAleph2PromptImageNode) — 此节点将引导图像锚定到输出视频中的特定时刻，控制编辑后的视频在该点的外观。
- [RunwayAleph2VideoToVideoNode](https://docs.comfy.org/built-in-nodes/RunwayAleph2VideoToVideoNode) — 此节点使用 Runway 的 Aleph2 模型，通过文本提示编辑视频。
- [RunwayFirstLastFrameNode](https://docs.comfy.org/built-in-nodes/RunwayFirstLastFrameNode) — Runway First-Last-Frame to Video 节点使用起始帧、结束帧和文本提示生成视频。
- [RunwayImageToVideoNodeGen3a](https://docs.comfy.org/built-in-nodes/RunwayImageToVideoNodeGen3a) — Runway Image to Video (Gen3a Turbo) 节点使用 Runway 的 Gen3a Turbo 模型，从单个起始帧生成视频。
- [RunwayImageToVideoNodeGen4](https://docs.comfy.org/built-in-nodes/RunwayImageToVideoNodeGen4) — Runway 图像转视频（Gen4 Turbo）节点使用 Runway 的 Gen4 Turbo 模型，从单个起始帧生成视频。

##### Sora

- [OpenAIVideoSora2](https://docs.comfy.org/built-in-nodes/OpenAIVideoSora2) — OpenAIVideoSora2 节点使用 OpenAI 的 Sora 模型生成视频。

##### Sync.so

- [SyncLipSyncNode](https://docs.comfy.org/built-in-nodes/SyncLipSyncNode) — 此节点使用 sync.so API 将视频中的口型动作与新的语音音频重新同步。
- [SyncTalkingImageNode](https://docs.comfy.org/built-in-nodes/SyncTalkingImageNode) — 使用 sync.so 的 sync-3 模型，将静态人像动画化为由语音音频驱动的说话视频。

##### Topaz

- [TopazVideoEnhance](https://docs.comfy.org/built-in-nodes/TopazVideoEnhance) — Topaz Video Enhance 节点通过强大的放大和修复技术为视频注入新的活力，利用外部 API 来提升视频质量。
- [TopazVideoEnhanceV2](https://docs.comfy.org/built-in-nodes/TopazVideoEnhanceV2) — Topaz Video Enhance V2 节点借助强大的放大与修复技术，为视频注入新的活力。

##### Veo

- [Veo3FirstLastFrameNode](https://docs.comfy.org/built-in-nodes/Veo3FirstLastFrameNode) — Veo3FirstLastFrameNode 使用 Google 的 Veo 3 模型，根据文本提示生成视频，并提供定义视频序列起始和结束的首帧与末帧。
- [Veo3VideoGenerationNode](https://docs.comfy.org/built-in-nodes/Veo3VideoGenerationNode) — 使用 Google 的 Veo 3 API 根据文本提示生成视频。

##### Vidu

- [Vidu2ImageToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu2ImageToVideoNode) — Vidu2 图像转视频节点可从单张输入图像创建视频序列。
- [Vidu2ReferenceVideoNode](https://docs.comfy.org/built-in-nodes/Vidu2ReferenceVideoNode) — Vidu2 参考图生成视频节点可根据文本提示和多张参考图像创建视频。
- [Vidu2StartEndToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu2StartEndToVideoNode) — 此文档由 AI 生成。
- [Vidu2TextToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu2TextToVideoNode) — Vidu2 文本到视频生成节点可根据文本描述创建视频。
- [Vidu3ImageToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu3ImageToVideoNode) — Vidu Q3 图生视频生成节点从输入图像开始创建视频序列。
- [Vidu3StartEndToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu3StartEndToVideoNode) — 此节点通过在起始帧和结束帧之间创建过渡来生成视频，并由文本提示词引导。
- [Vidu3TextToVideoNode](https://docs.comfy.org/built-in-nodes/Vidu3TextToVideoNode) — Vidu Q3 文生视频节点可根据文本描述生成视频。
- [ViduExtendVideoNode](https://docs.comfy.org/built-in-nodes/ViduExtendVideoNode) — Vidu Video Extension 节点可生成额外帧，以延长现有视频的长度。
- [ViduImageToVideoNode](https://docs.comfy.org/built-in-nodes/ViduImageToVideoNode) — 此文档由 AI 生成。
- [ViduMultiFrameVideoNode](https://docs.comfy.org/built-in-nodes/ViduMultiFrameVideoNode) — 此节点通过在多个关键帧之间创建过渡来生成视频。
- [ViduReferenceVideoNode](https://docs.comfy.org/built-in-nodes/ViduReferenceVideoNode) — Vidu 参考视频节点可根据多张参考图像和文本提示生成视频。
- [ViduStartEndToVideoNode](https://docs.comfy.org/built-in-nodes/ViduStartEndToVideoNode) — Vidu 起始帧到结束帧视频生成节点通过在起始帧和结束帧之间生成帧来创建视频。
- [ViduTextToVideoNode](https://docs.comfy.org/built-in-nodes/ViduTextToVideoNode) — The Vidu Text To Video Generation node creates videos from text descriptions.

##### Wan

- [HappyHorseImageToVideoApi](https://docs.comfy.org/built-in-nodes/HappyHorseImageToVideoApi) — 此节点使用 HappyHorse 模型从单张起始图像生成短视频。
- [HappyHorseReferenceVideoApi](https://docs.comfy.org/built-in-nodes/HappyHorseReferenceVideoApi) — 此节点使用 HappyHorse 模型，根据参考图像生成包含人物或物体的视频。
- [HappyHorseTextToVideoApi](https://docs.comfy.org/built-in-nodes/HappyHorseTextToVideoApi) — 此节点使用 HappyHorse 模型根据文本提示生成视频。
- [HappyHorseVideoEditApi](https://docs.comfy.org/built-in-nodes/HappyHorseVideoEditApi) — 使用 HappyHorse 模型，通过文本指令或参考图像编辑视频。
- [Wan2ImageToVideoApi](https://docs.comfy.org/built-in-nodes/Wan2ImageToVideoApi) — Wan 2.7 图像转视频节点根据首帧图像生成视频。
- [Wan2ReferenceVideoApi](https://docs.comfy.org/built-in-nodes/Wan2ReferenceVideoApi) — 此节点根据提供的参考素材生成以人物或物体为主角的视频。
- [Wan2TextToVideoApi](https://docs.comfy.org/built-in-nodes/Wan2TextToVideoApi) — 此节点使用 Wan 2.7 模型根据文本描述生成视频。
- [Wan2VideoContinuationApi](https://docs.comfy.org/built-in-nodes/Wan2VideoContinuationApi) — Wan 2.7 视频续接节点用于生成一段新视频，该视频从输入视频片段的结尾处继续延伸。
- [Wan2VideoEditApi](https://docs.comfy.org/built-in-nodes/Wan2VideoEditApi) — Wan 2.7 视频编辑节点使用文本指令、参考图像或风格迁移来编辑视频。
- [Wan3ImageToVideoApi](https://docs.comfy.org/built-in-nodes/Wan3ImageToVideoApi) — 此节点使用 Wan 3.0 模型从首帧图像生成视频。
- [Wan3ReferenceToVideoApi](https://docs.comfy.org/built-in-nodes/Wan3ReferenceToVideoApi) — 此节点使用 Wan 3.0 模型，根据文本提示词以及可选的参考图像、视频和音频生成视频。
- [WanImageToVideoApi](https://docs.comfy.org/built-in-nodes/WanImageToVideoApi) — Wan 图像转视频节点可根据单张输入图像和文本提示词生成视频。
- [WanReferenceVideoApi](https://docs.comfy.org/built-in-nodes/WanReferenceVideoApi) — 此文档由 AI 生成。
- [WanTextToVideoApi](https://docs.comfy.org/built-in-nodes/WanTextToVideoApi) — Wan 文生视频节点根据文本描述生成视频内容。

##### Wavespeed

- [WavespeedFlashVSRNode](https://docs.comfy.org/built-in-nodes/WavespeedFlashVSRNode) — The WavespeedFlashVSRNode is a fast, high-quality video upscaler that boosts resolution and restores clarity for low-resolution or blurry footage.

## 五、Comfy Router 合作方模型 Schema（JSON）

> 来源：<https://docs.comfy.org/llms.txt> 的 OpenAPI Specs 段。这些是合作方（付费云端）模型的输入/输出 schema，本项目不使用，仅作全站索引完整性收录。

### anthropic

- [claude-fable-5-1](https://docs.comfy.org/router-schemas/anthropic/claude-fable-5-1.json) — Router 模型 schema JSON
- [claude-fable-5](https://docs.comfy.org/router-schemas/anthropic/claude-fable-5.json) — Router 模型 schema JSON
- [claude-haiku-4-5-20251001](https://docs.comfy.org/router-schemas/anthropic/claude-haiku-4-5-20251001.json) — Router 模型 schema JSON
- [claude-opus-4-6](https://docs.comfy.org/router-schemas/anthropic/claude-opus-4-6.json) — Router 模型 schema JSON
- [claude-opus-4-7](https://docs.comfy.org/router-schemas/anthropic/claude-opus-4-7.json) — Router 模型 schema JSON
- [claude-opus-4-8](https://docs.comfy.org/router-schemas/anthropic/claude-opus-4-8.json) — Router 模型 schema JSON
- [claude-opus-5-5](https://docs.comfy.org/router-schemas/anthropic/claude-opus-5-5.json) — Router 模型 schema JSON
- [claude-opus-5](https://docs.comfy.org/router-schemas/anthropic/claude-opus-5.json) — Router 模型 schema JSON
- [claude-sonnet-4-5-20250929](https://docs.comfy.org/router-schemas/anthropic/claude-sonnet-4-5-20250929.json) — Router 模型 schema JSON
- [claude-sonnet-4-6](https://docs.comfy.org/router-schemas/anthropic/claude-sonnet-4-6.json) — Router 模型 schema JSON
- [claude-sonnet-5-5](https://docs.comfy.org/router-schemas/anthropic/claude-sonnet-5-5.json) — Router 模型 schema JSON
- [claude-sonnet-5](https://docs.comfy.org/router-schemas/anthropic/claude-sonnet-5.json) — Router 模型 schema JSON

### beeble

- [switchx](https://docs.comfy.org/router-schemas/beeble/switchx.json) — Router 模型 schema JSON

### bfl

- [erase-v1](https://docs.comfy.org/router-schemas/bfl/erase-v1.json) — Router 模型 schema JSON
- [flux-2-max](https://docs.comfy.org/router-schemas/bfl/flux-2-max.json) — Router 模型 schema JSON
- [flux-2-pro](https://docs.comfy.org/router-schemas/bfl/flux-2-pro.json) — Router 模型 schema JSON
- [flux-3-image](https://docs.comfy.org/router-schemas/bfl/flux-3-image.json) — Router 模型 schema JSON
- [flux-3-video](https://docs.comfy.org/router-schemas/bfl/flux-3-video.json) — Router 模型 schema JSON
- [flux-kontext-max](https://docs.comfy.org/router-schemas/bfl/flux-kontext-max.json) — Router 模型 schema JSON
- [flux-kontext-pro](https://docs.comfy.org/router-schemas/bfl/flux-kontext-pro.json) — Router 模型 schema JSON
- [flux-pro-1.0-expand](https://docs.comfy.org/router-schemas/bfl/flux-pro-1.0-expand.json) — Router 模型 schema JSON
- [flux-pro-1.0-fill](https://docs.comfy.org/router-schemas/bfl/flux-pro-1.0-fill.json) — Router 模型 schema JSON
- [flux-pro-1.1-ultra](https://docs.comfy.org/router-schemas/bfl/flux-pro-1.1-ultra.json) — Router 模型 schema JSON
- [flux-pro-1.1](https://docs.comfy.org/router-schemas/bfl/flux-pro-1.1.json) — Router 模型 schema JSON
- [video-edit-v1](https://docs.comfy.org/router-schemas/bfl/video-edit-v1.json) — Router 模型 schema JSON
- [video-upscale-v1](https://docs.comfy.org/router-schemas/bfl/video-upscale-v1.json) — Router 模型 schema JSON
- [vto-v1](https://docs.comfy.org/router-schemas/bfl/vto-v1.json) — Router 模型 schema JSON

### bria

- [fibo](https://docs.comfy.org/router-schemas/bria/fibo.json) — Router 模型 schema JSON
- [image-edit-add-object-by-text](https://docs.comfy.org/router-schemas/bria/image-edit-add-object-by-text.json) — Router 模型 schema JSON
- [image-edit-erase-by-text](https://docs.comfy.org/router-schemas/bria/image-edit-erase-by-text.json) — Router 模型 schema JSON
- [image-edit-erase-foreground](https://docs.comfy.org/router-schemas/bria/image-edit-erase-foreground.json) — Router 模型 schema JSON
- [image-edit-erase](https://docs.comfy.org/router-schemas/bria/image-edit-erase.json) — Router 模型 schema JSON
- [image-edit-expand](https://docs.comfy.org/router-schemas/bria/image-edit-expand.json) — Router 模型 schema JSON
- [image-edit-gen-fill](https://docs.comfy.org/router-schemas/bria/image-edit-gen-fill.json) — Router 模型 schema JSON
- [image-edit-increase-resolution](https://docs.comfy.org/router-schemas/bria/image-edit-increase-resolution.json) — Router 模型 schema JSON
- [image-edit-relight](https://docs.comfy.org/router-schemas/bria/image-edit-relight.json) — Router 模型 schema JSON
- [image-edit-remove-background](https://docs.comfy.org/router-schemas/bria/image-edit-remove-background.json) — Router 模型 schema JSON
- [image-edit-replace-background](https://docs.comfy.org/router-schemas/bria/image-edit-replace-background.json) — Router 模型 schema JSON
- [image-edit-replace-object-by-text](https://docs.comfy.org/router-schemas/bria/image-edit-replace-object-by-text.json) — Router 模型 schema JSON
- [image-edit-reseason](https://docs.comfy.org/router-schemas/bria/image-edit-reseason.json) — Router 模型 schema JSON
- [image-edit-restore](https://docs.comfy.org/router-schemas/bria/image-edit-restore.json) — Router 模型 schema JSON
- [structured-instruction](https://docs.comfy.org/router-schemas/bria/structured-instruction.json) — Router 模型 schema JSON
- [video-edit-erase](https://docs.comfy.org/router-schemas/bria/video-edit-erase.json) — Router 模型 schema JSON
- [video-edit-green-screen](https://docs.comfy.org/router-schemas/bria/video-edit-green-screen.json) — Router 模型 schema JSON
- [video-edit-remove-background](https://docs.comfy.org/router-schemas/bria/video-edit-remove-background.json) — Router 模型 schema JSON
- [video-edit-replace-background](https://docs.comfy.org/router-schemas/bria/video-edit-replace-background.json) — Router 模型 schema JSON

### byteplus

- [dreamina-seedance-2-0-260128](https://docs.comfy.org/router-schemas/byteplus/dreamina-seedance-2-0-260128.json) — Router 模型 schema JSON
- [dreamina-seedance-2-0-fast-260128](https://docs.comfy.org/router-schemas/byteplus/dreamina-seedance-2-0-fast-260128.json) — Router 模型 schema JSON
- [dreamina-seedance-2-0-mini](https://docs.comfy.org/router-schemas/byteplus/dreamina-seedance-2-0-mini.json) — Router 模型 schema JSON
- [dreamina-seedance-2-5-260628](https://docs.comfy.org/router-schemas/byteplus/dreamina-seedance-2-5-260628.json) — Router 模型 schema JSON
- [seed-2-0-lite-260228](https://docs.comfy.org/router-schemas/byteplus/seed-2-0-lite-260228.json) — Router 模型 schema JSON
- [seed-2-0-mini-260215](https://docs.comfy.org/router-schemas/byteplus/seed-2-0-mini-260215.json) — Router 模型 schema JSON
- [seed-2-0-pro-260328](https://docs.comfy.org/router-schemas/byteplus/seed-2-0-pro-260328.json) — Router 模型 schema JSON
- [seed-audio-1.0-multilingual](https://docs.comfy.org/router-schemas/byteplus/seed-audio-1.0-multilingual.json) — Router 模型 schema JSON
- [seed-audio-1.0](https://docs.comfy.org/router-schemas/byteplus/seed-audio-1.0.json) — Router 模型 schema JSON
- [seedance-1-0-pro-250528](https://docs.comfy.org/router-schemas/byteplus/seedance-1-0-pro-250528.json) — Router 模型 schema JSON
- [seedance-1-0-pro-fast-251015](https://docs.comfy.org/router-schemas/byteplus/seedance-1-0-pro-fast-251015.json) — Router 模型 schema JSON
- [seedance-1-5-pro-251215](https://docs.comfy.org/router-schemas/byteplus/seedance-1-5-pro-251215.json) — Router 模型 schema JSON
- [seedream-4-0-250828](https://docs.comfy.org/router-schemas/byteplus/seedream-4-0-250828.json) — Router 模型 schema JSON
- [seedream-4-5-251128](https://docs.comfy.org/router-schemas/byteplus/seedream-4-5-251128.json) — Router 模型 schema JSON
- [seedream-5-0-260128](https://docs.comfy.org/router-schemas/byteplus/seedream-5-0-260128.json) — Router 模型 schema JSON
- [seedream-5-0-flash-260915](https://docs.comfy.org/router-schemas/byteplus/seedream-5-0-flash-260915.json) — Router 模型 schema JSON
- [seedream-5-0-pro-260628](https://docs.comfy.org/router-schemas/byteplus/seedream-5-0-pro-260628.json) — Router 模型 schema JSON

### elevenlabs

- [eleven_sfx_v2](https://docs.comfy.org/router-schemas/elevenlabs/eleven_sfx_v2.json) — Router 模型 schema JSON
- [eleven_v3](https://docs.comfy.org/router-schemas/elevenlabs/eleven_v3.json) — Router 模型 schema JSON
- [eleven_v4_turbo](https://docs.comfy.org/router-schemas/elevenlabs/eleven_v4_turbo.json) — Router 模型 schema JSON
- [eleven_v4](https://docs.comfy.org/router-schemas/elevenlabs/eleven_v4.json) — Router 模型 schema JSON

### fal

- [fal-gpt-image-2.5-flare](https://docs.comfy.org/router-schemas/fal/fal-gpt-image-2.5-flare.json) — Router 模型 schema JSON
- [fal-gpt-image-2.5-sunburst](https://docs.comfy.org/router-schemas/fal/fal-gpt-image-2.5-sunburst.json) — Router 模型 schema JSON
- [fal-gpt-image-2](https://docs.comfy.org/router-schemas/fal/fal-gpt-image-2.json) — Router 模型 schema JSON
- [fal-nano-banana-2](https://docs.comfy.org/router-schemas/fal/fal-nano-banana-2.json) — Router 模型 schema JSON
- [fal-nano-banana-pro](https://docs.comfy.org/router-schemas/fal/fal-nano-banana-pro.json) — Router 模型 schema JSON
- [fal-seedance-2.0](https://docs.comfy.org/router-schemas/fal/fal-seedance-2.0.json) — Router 模型 schema JSON
- [fal-seedance-2.5](https://docs.comfy.org/router-schemas/fal/fal-seedance-2.5.json) — Router 模型 schema JSON
- [h3-max-turbo](https://docs.comfy.org/router-schemas/fal/h3-max-turbo.json) — Router 模型 schema JSON
- [h3-max](https://docs.comfy.org/router-schemas/fal/h3-max.json) — Router 模型 schema JSON
- [patina](https://docs.comfy.org/router-schemas/fal/patina.json) — Router 模型 schema JSON

### freepik

- [ai-image-upscaler-precision-v2](https://docs.comfy.org/router-schemas/freepik/ai-image-upscaler-precision-v2.json) — Router 模型 schema JSON
- [ai-skin-enhancer-creative](https://docs.comfy.org/router-schemas/freepik/ai-skin-enhancer-creative.json) — Router 模型 schema JSON
- [ai-skin-enhancer-faithful](https://docs.comfy.org/router-schemas/freepik/ai-skin-enhancer-faithful.json) — Router 模型 schema JSON
- [ai-skin-enhancer-flexible](https://docs.comfy.org/router-schemas/freepik/ai-skin-enhancer-flexible.json) — Router 模型 schema JSON

### gemini-interactions

- [gemini-omni-1.1-flash](https://docs.comfy.org/router-schemas/gemini-interactions/gemini-omni-1.1-flash.json) — Router 模型 schema JSON
- [gemini-omni-flash-preview](https://docs.comfy.org/router-schemas/gemini-interactions/gemini-omni-flash-preview.json) — Router 模型 schema JSON

### heygen

- [starfish](https://docs.comfy.org/router-schemas/heygen/starfish.json) — Router 模型 schema JSON

### higgsfield

- [higgsfield-kling-3-4k](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-kling-3-4k.json) — Router 模型 schema JSON
- [higgsfield-kling-3-pro](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-kling-3-pro.json) — Router 模型 schema JSON
- [higgsfield-kling-3-std](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-kling-3-std.json) — Router 模型 schema JSON
- [higgsfield-kling-3-turbo](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-kling-3-turbo.json) — Router 模型 schema JSON
- [higgsfield-seedance-2.0](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-seedance-2.0.json) — Router 模型 schema JSON
- [higgsfield-seedance-2.5](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-seedance-2.5.json) — Router 模型 schema JSON
- [higgsfield-wan-3](https://docs.comfy.org/router-schemas/higgsfield/higgsfield-wan-3.json) — Router 模型 schema JSON

### ideogram

- [ideogram-4-5](https://docs.comfy.org/router-schemas/ideogram/ideogram-4-5.json) — Router 模型 schema JSON
- [ideogram-v3](https://docs.comfy.org/router-schemas/ideogram/ideogram-v3.json) — Router 模型 schema JSON
- [ideogram-v4](https://docs.comfy.org/router-schemas/ideogram/ideogram-v4.json) — Router 模型 schema JSON
- [p-image-ideogram](https://docs.comfy.org/router-schemas/ideogram/p-image-ideogram.json) — Router 模型 schema JSON

### kling

- [kling-3.0-turbo](https://docs.comfy.org/router-schemas/kling/kling-3.0-turbo.json) — Router 模型 schema JSON
- [kling-image-o1](https://docs.comfy.org/router-schemas/kling/kling-image-o1.json) — Router 模型 schema JSON
- [kling-v2-5-turbo](https://docs.comfy.org/router-schemas/kling/kling-v2-5-turbo.json) — Router 模型 schema JSON
- [kling-v2-6](https://docs.comfy.org/router-schemas/kling/kling-v2-6.json) — Router 模型 schema JSON
- [kling-v3-omni](https://docs.comfy.org/router-schemas/kling/kling-v3-omni.json) — Router 模型 schema JSON
- [kling-v3](https://docs.comfy.org/router-schemas/kling/kling-v3.json) — Router 模型 schema JSON
- [kling-video-o1](https://docs.comfy.org/router-schemas/kling/kling-video-o1.json) — Router 模型 schema JSON
- [videos-avatar-image2video](https://docs.comfy.org/router-schemas/kling/videos-avatar-image2video.json) — Router 模型 schema JSON
- [videos-lip-sync](https://docs.comfy.org/router-schemas/kling/videos-lip-sync.json) — Router 模型 schema JSON
- [videos-video-extend](https://docs.comfy.org/router-schemas/kling/videos-video-extend.json) — Router 模型 schema JSON

### krea

- [krea-2-large](https://docs.comfy.org/router-schemas/krea/krea-2-large.json) — Router 模型 schema JSON
- [krea-2-medium-turbo](https://docs.comfy.org/router-schemas/krea/krea-2-medium-turbo.json) — Router 模型 schema JSON
- [krea-2-medium](https://docs.comfy.org/router-schemas/krea/krea-2-medium.json) — Router 模型 schema JSON
- [krea-2](https://docs.comfy.org/router-schemas/krea/krea-2.json) — Router 模型 schema JSON

### ltx

- [ltx-2-5-fast](https://docs.comfy.org/router-schemas/ltx/ltx-2-5-fast.json) — Router 模型 schema JSON
- [ltx-2-5-pro](https://docs.comfy.org/router-schemas/ltx/ltx-2-5-pro.json) — Router 模型 schema JSON

### luma_2

- [uni-1-max](https://docs.comfy.org/router-schemas/luma_2/uni-1-max.json) — Router 模型 schema JSON
- [uni-1](https://docs.comfy.org/router-schemas/luma_2/uni-1.json) — Router 模型 schema JSON

### luma

- [photon-1](https://docs.comfy.org/router-schemas/luma/photon-1.json) — Router 模型 schema JSON
- [photon-flash-1](https://docs.comfy.org/router-schemas/luma/photon-flash-1.json) — Router 模型 schema JSON
- [ray-2](https://docs.comfy.org/router-schemas/luma/ray-2.json) — Router 模型 schema JSON
- [ray-flash-2](https://docs.comfy.org/router-schemas/luma/ray-flash-2.json) — Router 模型 schema JSON

### meshy

- [animations](https://docs.comfy.org/router-schemas/meshy/animations.json) — Router 模型 schema JSON
- [meshy-5](https://docs.comfy.org/router-schemas/meshy/meshy-5.json) — Router 模型 schema JSON
- [meshy-6](https://docs.comfy.org/router-schemas/meshy/meshy-6.json) — Router 模型 schema JSON
- [meshy-7.1](https://docs.comfy.org/router-schemas/meshy/meshy-7.1.json) — Router 模型 schema JSON
- [meshy-7](https://docs.comfy.org/router-schemas/meshy/meshy-7.json) — Router 模型 schema JSON
- [remesh](https://docs.comfy.org/router-schemas/meshy/remesh.json) — Router 模型 schema JSON
- [rigging](https://docs.comfy.org/router-schemas/meshy/rigging.json) — Router 模型 schema JSON

### minimax

- [minimax-h3](https://docs.comfy.org/router-schemas/minimax/minimax-h3.json) — Router 模型 schema JSON

### moonvalley

- [image-to-video](https://docs.comfy.org/router-schemas/moonvalley/image-to-video.json) — Router 模型 schema JSON
- [text-to-image](https://docs.comfy.org/router-schemas/moonvalley/text-to-image.json) — Router 模型 schema JSON
- [text-to-video](https://docs.comfy.org/router-schemas/moonvalley/text-to-video.json) — Router 模型 schema JSON
- [video-to-video-resize](https://docs.comfy.org/router-schemas/moonvalley/video-to-video-resize.json) — Router 模型 schema JSON
- [video-to-video](https://docs.comfy.org/router-schemas/moonvalley/video-to-video.json) — Router 模型 schema JSON

### openai

- [gpt-4.1-mini](https://docs.comfy.org/router-schemas/openai/gpt-4.1-mini.json) — Router 模型 schema JSON
- [gpt-4.1-nano](https://docs.comfy.org/router-schemas/openai/gpt-4.1-nano.json) — Router 模型 schema JSON
- [gpt-4.1](https://docs.comfy.org/router-schemas/openai/gpt-4.1.json) — Router 模型 schema JSON
- [gpt-4o](https://docs.comfy.org/router-schemas/openai/gpt-4o.json) — Router 模型 schema JSON
- [gpt-5-mini](https://docs.comfy.org/router-schemas/openai/gpt-5-mini.json) — Router 模型 schema JSON
- [gpt-5-nano](https://docs.comfy.org/router-schemas/openai/gpt-5-nano.json) — Router 模型 schema JSON
- [gpt-5.5-pro](https://docs.comfy.org/router-schemas/openai/gpt-5.5-pro.json) — Router 模型 schema JSON
- [gpt-5.5](https://docs.comfy.org/router-schemas/openai/gpt-5.5.json) — Router 模型 schema JSON
- [gpt-5.6-luna](https://docs.comfy.org/router-schemas/openai/gpt-5.6-luna.json) — Router 模型 schema JSON
- [gpt-5.6-sol](https://docs.comfy.org/router-schemas/openai/gpt-5.6-sol.json) — Router 模型 schema JSON
- [gpt-5.6-terra](https://docs.comfy.org/router-schemas/openai/gpt-5.6-terra.json) — Router 模型 schema JSON
- [gpt-5](https://docs.comfy.org/router-schemas/openai/gpt-5.json) — Router 模型 schema JSON
- [gpt-6-astra](https://docs.comfy.org/router-schemas/openai/gpt-6-astra.json) — Router 模型 schema JSON
- [gpt-6-luna](https://docs.comfy.org/router-schemas/openai/gpt-6-luna.json) — Router 模型 schema JSON
- [gpt-6-sol](https://docs.comfy.org/router-schemas/openai/gpt-6-sol.json) — Router 模型 schema JSON
- [gpt-image-1.5](https://docs.comfy.org/router-schemas/openai/gpt-image-1.5.json) — Router 模型 schema JSON
- [gpt-image-1](https://docs.comfy.org/router-schemas/openai/gpt-image-1.json) — Router 模型 schema JSON
- [gpt-image-2.5-flare](https://docs.comfy.org/router-schemas/openai/gpt-image-2.5-flare.json) — Router 模型 schema JSON
- [gpt-image-2.5-sunburst](https://docs.comfy.org/router-schemas/openai/gpt-image-2.5-sunburst.json) — Router 模型 schema JSON
- [gpt-image-2](https://docs.comfy.org/router-schemas/openai/gpt-image-2.json) — Router 模型 schema JSON
- [o1-pro](https://docs.comfy.org/router-schemas/openai/o1-pro.json) — Router 模型 schema JSON
- [o1](https://docs.comfy.org/router-schemas/openai/o1.json) — Router 模型 schema JSON
- [o3](https://docs.comfy.org/router-schemas/openai/o3.json) — Router 模型 schema JSON
- [o4-mini](https://docs.comfy.org/router-schemas/openai/o4-mini.json) — Router 模型 schema JSON

### openrouter

- [chat-completions](https://docs.comfy.org/router-schemas/openrouter/chat-completions.json) — Router 模型 schema JSON

### pruna

- [p-video-2](https://docs.comfy.org/router-schemas/pruna/p-video-2.json) — Router 模型 schema JSON

### qwen

- [qwen-image-3.0-pro](https://docs.comfy.org/router-schemas/qwen/qwen-image-3.0-pro.json) — Router 模型 schema JSON
- [qwen-image-3.0](https://docs.comfy.org/router-schemas/qwen/qwen-image-3.0.json) — Router 模型 schema JSON

### recraft

- [recraftv2](https://docs.comfy.org/router-schemas/recraft/recraftv2.json) — Router 模型 schema JSON
- [recraftv3](https://docs.comfy.org/router-schemas/recraft/recraftv3.json) — Router 模型 schema JSON
- [recraftv4_1_pro_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_pro_vector.json) — Router 模型 schema JSON
- [recraftv4_1_pro](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_pro.json) — Router 模型 schema JSON
- [recraftv4_1_utility_pro_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_utility_pro_vector.json) — Router 模型 schema JSON
- [recraftv4_1_utility_pro](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_utility_pro.json) — Router 模型 schema JSON
- [recraftv4_1_utility_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_utility_vector.json) — Router 模型 schema JSON
- [recraftv4_1_utility](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_utility.json) — Router 模型 schema JSON
- [recraftv4_1_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_1_vector.json) — Router 模型 schema JSON
- [recraftv4_1](https://docs.comfy.org/router-schemas/recraft/recraftv4_1.json) — Router 模型 schema JSON
- [recraftv4_pro](https://docs.comfy.org/router-schemas/recraft/recraftv4_pro.json) — Router 模型 schema JSON
- [recraftv4_styles_pro_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_styles_pro_vector.json) — Router 模型 schema JSON
- [recraftv4_styles_pro](https://docs.comfy.org/router-schemas/recraft/recraftv4_styles_pro.json) — Router 模型 schema JSON
- [recraftv4_styles_vector](https://docs.comfy.org/router-schemas/recraft/recraftv4_styles_vector.json) — Router 模型 schema JSON
- [recraftv4_styles](https://docs.comfy.org/router-schemas/recraft/recraftv4_styles.json) — Router 模型 schema JSON
- [recraftv4](https://docs.comfy.org/router-schemas/recraft/recraftv4.json) — Router 模型 schema JSON

### runware

- [runware-gpt-image-2.5-flare](https://docs.comfy.org/router-schemas/runware/runware-gpt-image-2.5-flare.json) — Router 模型 schema JSON
- [runware-gpt-image-2.5-sunburst](https://docs.comfy.org/router-schemas/runware/runware-gpt-image-2.5-sunburst.json) — Router 模型 schema JSON
- [runware-gpt-image-2](https://docs.comfy.org/router-schemas/runware/runware-gpt-image-2.json) — Router 模型 schema JSON
- [runware-nano-banana-2](https://docs.comfy.org/router-schemas/runware/runware-nano-banana-2.json) — Router 模型 schema JSON
- [runware-nano-banana-pro](https://docs.comfy.org/router-schemas/runware/runware-nano-banana-pro.json) — Router 模型 schema JSON
- [runware-seedance-2.0](https://docs.comfy.org/router-schemas/runware/runware-seedance-2.0.json) — Router 模型 schema JSON
- [runware-seedance-2.5](https://docs.comfy.org/router-schemas/runware/runware-seedance-2.5.json) — Router 模型 schema JSON

### runway

- [aleph2](https://docs.comfy.org/router-schemas/runway/aleph2.json) — Router 模型 schema JSON
- [gen4_image](https://docs.comfy.org/router-schemas/runway/gen4_image.json) — Router 模型 schema JSON
- [gen4_turbo](https://docs.comfy.org/router-schemas/runway/gen4_turbo.json) — Router 模型 schema JSON

### synclabs

- [sync-3](https://docs.comfy.org/router-schemas/synclabs/sync-3.json) — Router 模型 schema JSON

### tencent

- [hunyuan-3d-part](https://docs.comfy.org/router-schemas/tencent/hunyuan-3d-part.json) — Router 模型 schema JSON
- [hunyuan-3d-smart-topology](https://docs.comfy.org/router-schemas/tencent/hunyuan-3d-smart-topology.json) — Router 模型 schema JSON
- [hunyuan-3d-texture-edit](https://docs.comfy.org/router-schemas/tencent/hunyuan-3d-texture-edit.json) — Router 模型 schema JSON
- [hunyuan-3d-uv](https://docs.comfy.org/router-schemas/tencent/hunyuan-3d-uv.json) — Router 模型 schema JSON

### veo

- [veo-2.0-generate-001](https://docs.comfy.org/router-schemas/veo/veo-2.0-generate-001.json) — Router 模型 schema JSON
- [veo-3.0-fast-generate-001](https://docs.comfy.org/router-schemas/veo/veo-3.0-fast-generate-001.json) — Router 模型 schema JSON
- [veo-3.0-generate-001](https://docs.comfy.org/router-schemas/veo/veo-3.0-generate-001.json) — Router 模型 schema JSON
- [veo-3.1-fast-generate-001](https://docs.comfy.org/router-schemas/veo/veo-3.1-fast-generate-001.json) — Router 模型 schema JSON
- [veo-3.1-generate-001](https://docs.comfy.org/router-schemas/veo/veo-3.1-generate-001.json) — Router 模型 schema JSON
- [veo-3.1-lite-generate-001](https://docs.comfy.org/router-schemas/veo/veo-3.1-lite-generate-001.json) — Router 模型 schema JSON

### vertexai

- [gemini-2.5-flash-image](https://docs.comfy.org/router-schemas/vertexai/gemini-2.5-flash-image.json) — Router 模型 schema JSON
- [gemini-2.5-flash](https://docs.comfy.org/router-schemas/vertexai/gemini-2.5-flash.json) — Router 模型 schema JSON
- [gemini-2.5-pro](https://docs.comfy.org/router-schemas/vertexai/gemini-2.5-pro.json) — Router 模型 schema JSON
- [gemini-3-pro-image](https://docs.comfy.org/router-schemas/vertexai/gemini-3-pro-image.json) — Router 模型 schema JSON
- [gemini-3.1-flash-image](https://docs.comfy.org/router-schemas/vertexai/gemini-3.1-flash-image.json) — Router 模型 schema JSON
- [gemini-3.1-flash-lite-image](https://docs.comfy.org/router-schemas/vertexai/gemini-3.1-flash-lite-image.json) — Router 模型 schema JSON
- [gemini-3.1-flash-lite](https://docs.comfy.org/router-schemas/vertexai/gemini-3.1-flash-lite.json) — Router 模型 schema JSON
- [gemini-3.1-pro-preview](https://docs.comfy.org/router-schemas/vertexai/gemini-3.1-pro-preview.json) — Router 模型 schema JSON
- [gemini-3.5-flash](https://docs.comfy.org/router-schemas/vertexai/gemini-3.5-flash.json) — Router 模型 schema JSON
- [gemini-3.7-flash](https://docs.comfy.org/router-schemas/vertexai/gemini-3.7-flash.json) — Router 模型 schema JSON
- [gemini-3.8-flash](https://docs.comfy.org/router-schemas/vertexai/gemini-3.8-flash.json) — Router 模型 schema JSON
- [imagen-3.0-fast-generate-001](https://docs.comfy.org/router-schemas/vertexai/imagen-3.0-fast-generate-001.json) — Router 模型 schema JSON
- [imagen-3.0-generate-001](https://docs.comfy.org/router-schemas/vertexai/imagen-3.0-generate-001.json) — Router 模型 schema JSON
- [imagen-3.0-generate-002](https://docs.comfy.org/router-schemas/vertexai/imagen-3.0-generate-002.json) — Router 模型 schema JSON

### wan

- [happyhorse-1.0-i2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.0-i2v.json) — Router 模型 schema JSON
- [happyhorse-1.0-r2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.0-r2v.json) — Router 模型 schema JSON
- [happyhorse-1.0-t2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.0-t2v.json) — Router 模型 schema JSON
- [happyhorse-1.0-video-edit](https://docs.comfy.org/router-schemas/wan/happyhorse-1.0-video-edit.json) — Router 模型 schema JSON
- [happyhorse-1.1-i2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.1-i2v.json) — Router 模型 schema JSON
- [happyhorse-1.1-r2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.1-r2v.json) — Router 模型 schema JSON
- [happyhorse-1.1-t2v](https://docs.comfy.org/router-schemas/wan/happyhorse-1.1-t2v.json) — Router 模型 schema JSON
- [wan2.5-i2i-preview](https://docs.comfy.org/router-schemas/wan/wan2.5-i2i-preview.json) — Router 模型 schema JSON
- [wan2.5-i2v-preview](https://docs.comfy.org/router-schemas/wan/wan2.5-i2v-preview.json) — Router 模型 schema JSON
- [wan2.5-t2i-preview](https://docs.comfy.org/router-schemas/wan/wan2.5-t2i-preview.json) — Router 模型 schema JSON
- [wan2.5-t2v-preview](https://docs.comfy.org/router-schemas/wan/wan2.5-t2v-preview.json) — Router 模型 schema JSON
- [wan2.6-i2v](https://docs.comfy.org/router-schemas/wan/wan2.6-i2v.json) — Router 模型 schema JSON
- [wan2.6-r2v](https://docs.comfy.org/router-schemas/wan/wan2.6-r2v.json) — Router 模型 schema JSON
- [wan2.6-t2v](https://docs.comfy.org/router-schemas/wan/wan2.6-t2v.json) — Router 模型 schema JSON
- [wan2.7-i2v](https://docs.comfy.org/router-schemas/wan/wan2.7-i2v.json) — Router 模型 schema JSON
- [wan2.7-r2v](https://docs.comfy.org/router-schemas/wan/wan2.7-r2v.json) — Router 模型 schema JSON
- [wan2.7-t2v](https://docs.comfy.org/router-schemas/wan/wan2.7-t2v.json) — Router 模型 schema JSON
- [wan2.7-videoedit](https://docs.comfy.org/router-schemas/wan/wan2.7-videoedit.json) — Router 模型 schema JSON
- [wan3.0-video-prime](https://docs.comfy.org/router-schemas/wan/wan3.0-video-prime.json) — Router 模型 schema JSON
- [wan3.0-video](https://docs.comfy.org/router-schemas/wan/wan3.0-video.json) — Router 模型 schema JSON

### wavespeed

- [flashvsr](https://docs.comfy.org/router-schemas/wavespeed/flashvsr.json) — Router 模型 schema JSON
- [seedvr2](https://docs.comfy.org/router-schemas/wavespeed/seedvr2.json) — Router 模型 schema JSON
- [ultimate-image-upscaler](https://docs.comfy.org/router-schemas/wavespeed/ultimate-image-upscaler.json) — Router 模型 schema JSON
- [wavespeed-gpt-image-2.5-flare](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-gpt-image-2.5-flare.json) — Router 模型 schema JSON
- [wavespeed-gpt-image-2.5-sunburst](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-gpt-image-2.5-sunburst.json) — Router 模型 schema JSON
- [wavespeed-gpt-image-2](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-gpt-image-2.json) — Router 模型 schema JSON
- [wavespeed-nano-banana-2](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-nano-banana-2.json) — Router 模型 schema JSON
- [wavespeed-nano-banana-pro](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-nano-banana-pro.json) — Router 模型 schema JSON
- [wavespeed-seedance-2.0](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-seedance-2.0.json) — Router 模型 schema JSON
- [wavespeed-seedance-2.5](https://docs.comfy.org/router-schemas/wavespeed/wavespeed-seedance-2.5.json) — Router 模型 schema JSON

### xai

- [grok-imagine-image-2.0](https://docs.comfy.org/router-schemas/xai/grok-imagine-image-2.0.json) — Router 模型 schema JSON
- [grok-imagine-image-pro](https://docs.comfy.org/router-schemas/xai/grok-imagine-image-pro.json) — Router 模型 schema JSON
- [grok-imagine-image-quality](https://docs.comfy.org/router-schemas/xai/grok-imagine-image-quality.json) — Router 模型 schema JSON
- [grok-imagine-image](https://docs.comfy.org/router-schemas/xai/grok-imagine-image.json) — Router 模型 schema JSON
- [grok-imagine-video-1.5-lite](https://docs.comfy.org/router-schemas/xai/grok-imagine-video-1.5-lite.json) — Router 模型 schema JSON
- [grok-imagine-video-1.5-preview](https://docs.comfy.org/router-schemas/xai/grok-imagine-video-1.5-preview.json) — Router 模型 schema JSON
- [grok-imagine-video-1.5](https://docs.comfy.org/router-schemas/xai/grok-imagine-video-1.5.json) — Router 模型 schema JSON
- [grok-imagine-video](https://docs.comfy.org/router-schemas/xai/grok-imagine-video.json) — Router 模型 schema JSON

## 六、OpenAPI 规范文件

- [openapi-v2](https://docs.comfy.org/openapi-v2.yaml) — Comfy API v2 的 OpenAPI 规范（YAML）
- [openapi-cloud](https://docs.comfy.org/openapi-cloud.yaml) — Comfy Cloud API 的 OpenAPI 规范（YAML）
- [router-openapi](https://docs.comfy.org/router-openapi.yaml) — Comfy Router 的 OpenAPI 规范（YAML）
- [openapi（Registry）](https://api.comfy.org/openapi) — Comfy Registry 节点仓库 API 的 OpenAPI 规范
