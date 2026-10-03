# MCP 与 Agent 工具（把 AI agent 接到 ComfyUI 上）

> 来源：https://docs.comfy.org/agent-tools/mcp
> 来源：https://docs.comfy.org/agent-tools
> 来源：https://docs.comfy.org/agent-tools/skills
> 抓取日期：2026-10-03

## 一句话结论

**Comfy MCP** 是 Comfy 官方的「把 AI agent 接到 ComfyUI」方案，走 **Model Context Protocol (MCP)**。它有**两条路线**，是同一个产品的两种连接方式：

| | **本地连接**（Local Comfy MCP） | **云端连接**（Comfy Cloud MCP） |
|---|---|---|
| 是什么 | 开源的一方本地 MCP server，驱动**你自己机器上**的 ComfyUI | 官方托管的远程 MCP server，工作流跑在 Comfy Cloud 的 GPU 上 |
| 实现 | `comfy-mcp` 命令，走 **stdio**（客户端把它作为子进程启动） | `https://cloud.comfy.org/mcp`，走**远程 HTTP / Streamable HTTP** + OAuth |
| 仓库 | <https://github.com/Comfy-Org/comfy-mcp>（开源） | 托管，无仓库 |
| GPU | 你的本地 GPU | 云端 GPU（无硬件要求） |
| 模型 | 本机已下载的模型 | Comfy Cloud 的模型（也可导入自己的） |
| 自定义节点 | **任意节点包都能装** | 仅 Cloud 支持的节点 |
| 花费 | **本地运行免费** | 需要**有效的 Comfy Cloud 订阅** |
| 本项目 | ✅ **采用这条** | ⚠️ 云端/付费路线存在，不在本项目范围 |

官方同时建议：**两条可以同时接**，互不冲突；但它们各自独立登录——「在一条上登录不会让另一条也登录」。

## 本路线（本地）前置要求

- **Python 3.10+**
- **`comfy-cli` 在 `PATH` 上**：`pip install "comfy-cli>=1.14.0"`
- **一个 ComfyUI 工作区（workspace）**
  - 没有就 `comfy install` 新建
  - 已有 ComfyUI 检出可用 `comfy set-default <path>` 指过去
- **一个正在运行的 ComfyUI**（只对执行类工具有效）：用 `comfy launch` 启动。
  **server 不会隐式启动 ComfyUI**——你必须自己先把它拉起来。

## 安装

```bash
pip install comfy-mcp
```

这会在 `PATH` 上放一个 **`comfy-mcp`** 命令，**该命令本身就是 MCP server**，通过 stdio 讲 MCP。

要改 server 源码就在仓库检出里 `pip install -e .`。

## 环境变量 `COMFY_BIN`（可选但常见）

MCP 客户端是用**它自己的环境**启动 server 的，这个环境**通常不包含你 shell 的 `PATH`**。如果 `comfy` 装在 virtualenv 或非标准位置，就把 `COMFY_BIN` 设成它的绝对路径：

```
COMFY_BIN=/path/to/venv/bin/comfy
```

如果 `comfy` 已经在客户端启动 server 所用的环境里，就不用设。

## 客户端配置（本地路线，stdio）

所有客户端用的是**同一套契约**：把 `comfy-mcp` 当作 server 命令跑起来。

**Claude Desktop** — 编辑 `claude_desktop_config.json`（Settings → Developer → Edit Config；macOS 路径 `~/Library/Application Support/Claude/claude_desktop_config.json`），改完**重启 Claude Desktop**：

```json
{
  "mcpServers": {
    "comfy-mcp": {
      "command": "comfy-mcp",
      "env": { "COMFY_BIN": "/path/to/venv/bin/comfy" }
    }
  }
}
```

**Claude Code** — 一条命令注册：

```bash
claude mcp add comfy-mcp -e COMFY_BIN=/path/to/venv/bin/comfy -- comfy-mcp
```

或者把 `.mcp.json` 签进项目根目录，内容同上。

**Cursor** — 加到 `~/.cursor/mcp.json`（全局）或 `.cursor/mcp.json`（按项目），内容同上。

## 快速开始（零到出一张图）

```bash
pip install "comfy-cli>=1.14.0"   # 引擎
comfy install                     # 建 ComfyUI 工作区（已有则跳过）
pip install comfy-mcp             # 本 MCP server → 提供 comfy-mcp 命令
comfy launch                      # 启动 ComfyUI 并保持运行
```

然后把上面的配置片段加进你的客户端并**重启 / reload**，让工具出现。

之后用自然语言提要求，例如：

> 「确认我的本地 ComfyUI 在运行，然后跑 `~/workflows/txt2img.json` 这个工作流并把图给我看。」

底层 agent 会依次调 `server_info` 确认 ComfyUI 活着 → `run_workflow` 执行工作流 JSON → `fetch_outputs` 收结果。

> 官方给的省事做法：把 `https://docs.comfy.org/agent-tools/mcp#installation` 这一页丢给你的 AI 客户端，让它替你配。

## 本地工具清单

每个工具都对应一条 `comfy-cli` 命令，并以 `--where local` 运行。官方列出的要点：

| 工具 | 作用 |
|---|---|
| `server_info()` | 本地 ComfyUI 在不在跑、在哪、用哪个 workspace。**必须先调这个。** |
| `run_workflow(workflow_path, wait=True)` | 跑一个工作流 JSON；`wait=False` 则异步提交并返回 `prompt_id` |
| `job_status` / `wait_for_job` / `watch_job` | 轮询 / 等待 / 流式观察已提交的 job |
| `fetch_outputs(prompt_id, out_dir)` | 把完成的 job 产物拷到 `out_dir` |
| `launch_comfyui` / `stop_comfyui` | 启动 / 停止本地 ComfyUI |
| `search_templates` / `fetch_template` | 找内置 template，并把它可运行的工作流 JSON 落盘 |
| `search_nodes` / `get_node` / `list_nodes` | 检视**本机 live 安装**里的节点类（含自定义节点） |
| `search_models` | 列出磁盘上的模型文件 |
| `validate_workflow` | 跑之前拿 live `object_info` 做一次预检 |

> **本地路线的差异化优势**：节点自省与模型检索读的是**你机器上的 live install**（含自定义节点），这是云端连接做不到的。
> 完整工具列表以仓库 <https://github.com/Comfy-Org/comfy-mcp> 为准。

## 云端路线要点（记录备查，本项目不用）

- 服务地址固定为 **`https://cloud.comfy.org/mcp`**（任何支持远程 HTTP 的 MCP 客户端都能接）。
- 鉴权：支持 MCP OAuth 的客户端（Claude Code / Claude Desktop / Codex / OpenClaw）浏览器登录即可；**Cursor 目前不支持 MCP OAuth**，必须在 MCP 配置里用 Comfy Cloud API key，走 `X-API-Key` 头 + 环境变量 `COMFY_API_KEY`（key 在 <https://platform.comfy.org/profile/api-keys> 创建，形如 `comfyui-…`）。无浏览器的 headless / CI 同理用 API key。
- Codex 另有 CLI 方式：`codex mcp add comfy-cloud --url https://cloud.comfy.org/mcp` + `codex mcp login comfy-cloud`（写入 `~/.codex/config.toml`）。
- 云端工具按用途分组（名字与 MCP 客户端日志里的一致）：
  - **Discovery**：`search_templates`、`get_template`、`get_template_schema`、`search_models`、`search_nodes`、`get_node`、`cql`（CQL 图查询）、`get_prompting_guide`
  - **Generation**：`run_template`（优先走模板）、`submit_workflow`、`partner_generate`、`upload_file`、`apply_slots`
  - **Jobs / 批量**：`get_job_status`、`wait_for_job`、`get_output`、`use_previous_output`、`cancel_job`、`get_queue`、`submit_batch` / `get_batch_status` / `get_batch_output` / `wait_for_batch`
  - **保存的工作流**：`list_saved_workflows`、`get_saved_workflow`、`save_workflow`、`update_workflow`、`run_saved_workflow`
  - **分享**：`share_workflow`、`import_shared_workflow`
  - **App 与链接**：`create_app`、`get_app_mode_url`、`get_workflow_canvas_url`
  - **账户**：`get_billing_status`、`get_server_info`、`submit_feedback`、`report_session_summary`
- 云端 agent 的典型流程：**发现** → **运行** → **等待并取回**；server 会优先匹配现成模板，再考虑从零搭工作流。

## 计费（两条路线的差别）

- **发现免费**：搜模板 / 搜模型 / 搜节点，两条路线都只要一个 Comfy 账号。
- **云端连接**：跑生成需要**有效的 Comfy Cloud 订阅**。注意——**只有积分或充值余额并不能开通执行权限**，必须有活跃订阅；新用户有 **5 次免费运行**。
- **本地连接**：跑生成**免费**，因为跑在你自己的硬件上。**唯一例外**是 partner 模型（合作方基建执行，会消耗积分）。

## 产物去哪了

- **本地连接**：ComfyUI 写进你 workspace 的 `output/` 目录；`fetch_outputs(prompt_id, out_dir)` 把完成的 job 文件拷到你指定的任意位置。
- **云端连接**：MCP server 跑在云上、**不往你机器写文件**。`get_output` 返回 ① 一个短时效的**临时签名下载 URL**，② 一条**可直接执行的 shell 命令**（macOS/Linux 用 `curl`，Windows 用 `curl.exe`），命令里已经带好目标路径与文件名。
  ⚠️ 官方明确警告：这条命令要**原样执行**，**不要重新编码或改动签名 URL**——签名在 query string 里，改了 URL 就失效。

## 硬件建议（官方 FAQ 口径）

| 你的机器 | 官方建议 |
|---|---|
| **Mac**（Apple GPU） | 用**云端**生成。今天的开放权重模型（MiniMax H3、LTX-2.3 等本地版）太大，Apple GPU 跑不到可用速度 |
| **PC + 独立显卡，显存 ≥ 24 GB** | 本地基本都能跑，**包括视频** |
| **PC + 独立显卡，显存 8–24 GB** | 图像没问题；**视频会慢或放不下** |
| **PC + 独立显卡，显存 < 8 GB** | 用云端 |

## 其他 FAQ 要点

- **支持哪些客户端**：任何 MCP 兼容客户端。本地连接需要客户端**能把它作为本地 stdio 子进程启动**——这就排除了纯浏览器客户端（claude.ai、ChatGPT 只接受远程 connector）。
- **能不能两条同时接**：能，官方还推荐本地用户这么做。但**两边登录是独立的**。
- **本地路线怎么升级**：让 agent 处理；**之后要重启客户端或开新会话**——MCP server 只在会话启动时加载，正在跑的会话会一直用旧版本直到重启。
- **在本地和云端之间切换**：不用切模式、不用重配。直接说「这个跑在 Cloud 上」「这个跑本地」即可。
- **是否 GA**：是。云端连接已 GA；本地连接对本地 ComfyUI 安装可用。

## 已知限制（官方自述，早期版本）

- 通过 `submit_workflow` 产出的产物**可能不嵌入 workflow metadata**，在 ComfyUI 里打开时未必能还原出原始工作流。
- **工作流搭得对不对取决于 agent 的准确度**：复杂的多节点工作流可能需要重试或微调。
- 云端产物**必须先经过一步 shell 下载**。
- **上传体积限制**可能生效，取决于 MCP 客户端自身。
- 鉴权：OAuth 或 API key 二选一；面向无法开浏览器的客户端的 device-code OAuth 流程官方标注为"计划中"。

## 相关资源（官方列出）

| 资源 | 用途 |
|---|---|
| [Comfy Skills](https://github.com/Comfy-Org/comfy-skills) | Claude Code 插件市场 + 社区 agent skill 库；`comfy-cloud` 插件从这里分发 |
| [Comfy CLI](https://docs.comfy.org/agent-tools/cli) | 本地 ComfyUI 的安装/启动命令行；也用于脚本或 CI 调用托管 partner 节点（`comfy generate`，beta） |
| [Comfy Agent](https://docs.comfy.org/agent-tools/in-app-agent) | **ComfyUI 内部**的 AI 助手，用于理解/搭建/编辑/运行选中的工作流。Cloud 已 GA，本地（Comfy Desktop）"即将推出"——**不在本项目范围** |
| [在 Comfy Cloud 上分享工作流](https://docs.comfy.org/cloud/share-workflow) | Cloud UI 里的分享功能（云端路线） |

## What is MCP（官方 agent-tools 概览页的说法）

MCP（Model Context Protocol）是一个开放标准，让 AI 助手通过**统一接口**与外部工具/服务交互；有了它，agent 不需要为每个服务学一套自定义 API 格式。把 MCP server 接到 Claude Desktop / Claude Code / Cursor / Amp 之后，AI 助手就能用自然语言完成：文生图、文/图生视频、文/图生 3D、生成音频与音乐、搜索模型与模板——**全程不用手写 API 调用**。
