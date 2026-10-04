---
name: comfyui-mcp-ops
description: ComfyUI MCP 操作手册（精简核心）。含 39 个 MCP 工具（mcp__comfymcp__*）的调用决策表、五步出图标准流程、花钱红线与已知坑。**成品配方与工作流库不在这里**，在 references/recipes.md，只在真正要跑工作流时才读。凡是要出图、改图、抠图、上色、生成视频、跑 ComfyUI 工作流，先加载本手册再动手。
whenToUse: 用户提到出图/绘图/画图/生成图片/改图/抠图/上色/放大/生成视频/ComfyUI/工作流/采样/显存/模型 时
---

# ComfyUI MCP 操作手册

> 实测环境（2026-10-03）：comfy-cli **1.17.0** · comfy-mcp **0.10.0** · ComfyUI 于 `http://127.0.0.1:8188` · **RTX 5070 / 12GB**
> 工具前缀：本手册所有工具都叫 **`mcp__comfymcp__<名字>`**
> 详细的本机模型清单、目录、配方对照见 [`references/local-inventory.md`](references/local-inventory.md)

---

## 0. 七条铁律（违反任何一条都会浪费一整轮）

1. **`confirm_spend` 永远不主动传 `true`。** 只有用户明确说"花钱吧/用 API 吧"才传。本预设只做本地免费能力。
2. **`run_workflow` 一律 `wait: false`**，拿到 `prompt_id` 后用 `job(action="wait")` 轮询。慢任务用 `wait: true` 会被调用超时打断（任务其实没死，但你会以为失败了）。
3. **`fetch_outputs` 不要传 `inline_images`。** comfy-mcp 0.10.0 有序列化 bug，会报 `Unable to serialize unknown type: <class 'mcp.server.mcpserver.utilities.types.Image'>`。不传就正常下载到 `out_dir`。
4. **先 `validate_workflow` 再 `run_workflow`。** 缺节点/缺模型在这一步就会暴露，比跑失败再排查快得多。
5. **写任何提示词之前，先加载 `comfyui-prompt-craft`。**
   只要你要产出或修改 `prompt` / `positive` / `negative` 文本 —— **出图、改图、抠图、上色、做视频、批量改词、给工作流槽位填 prompt** —— 都算。
   ⚠️ 这条最容易漏：用户往往**不会说"写提示词"这个词**，只会说「把这只猫改成赛博朋克」「用 H3 生成雨夜街头」。**判断依据是"我接下来要写出提示词文本"，而不是"用户有没有提提示词"。**
   漏掉的代价是语言用错（图像该中文、视频必须英文）和结构用错，两者都直接劣化结果。
6. **产物出来之后、交付之前，必须先加载 `comfyui-review` 真看图审一遍。**
   拿到 `fetch_outputs` 的结果直接甩给用户 = 违规；没读图就说"效果不错" = 违规。
   审查报告要落盘到 `60_review/`，并交人 review —— **采纳权在人，不在你**。
7. ⛔ **全程只用 MCP 工具操作 ComfyUI，不许绕过它直连 HTTP API。**
   **即使 MCP 调用超时或报错，也不要"换个办法"去写脚本打 `http://127.0.0.1:8188`。**
   原因：
   - MCP 工具做了**参数校验与错误归一化**（如 `validate_workflow`、付费节点拦截），
     直连 API 等于把这些保护全丢掉；
   - 直连要自己拼 JSON、处理轮询与超时，**多烧一轮甚至几轮 token**，而这正是本预设要消灭的成本；
   - MCP 报 `Request timed out` **通常不是失败** —— 任务还在跑，**继续用 `job action="status"` 轮询**即可。

   **唯一例外**：MCP 连接器**确实整体不可用**（工具列表里没有 `mcp__comfymcp__*`）。
   那种情况**先停下告诉用户**，由用户决定；不要自作主张换方案。

> 📌 与提示词有关的工具参数速记：`create` 类任务（出图/改图/视频）真正决定质量的是那句提示词本身——
> 结构模板与语言规则在 `comfyui-prompt-craft`，本手册只管**怎么把它送进 ComfyUI**。

---

## 1. 意图 → 工具：调用决策表

| 用户想要 | 第一步调用 | 关键参数 |
|---|---|---|
| **要写/改提示词**（不管用户提没提"提示词"这个词） | `skill(comfyui-prompt-craft)` | 结构模板 + 语言硬规则：**图像中文 / 视频英文** |
| 不确定环境/服务在不在 | `server_info` | 无 |
| 看显存够不够 | `system_stats` | 跑大图/视频前必看 |
| 一键随便出张图 | `generate_image` | `prompt`。**永远免费**，跑默认模板 |
| **按明确要求出图/改图** | → 第 2 节五步流程 | 优先用本机已验证配方 |
| 从官方模板出图 | `search_templates` → `get_template` → `fetch_template` → 看 `local_check.runnable` | **本机模型文件名与官方模板对不上，见 §3.4** |
| 找本机有什么模型 | `search_models` | 无参列目录；`query=` 按名搜；`folder=` 列具体目录 |
| 下载模型 | `download_model` | ⚠️ 会往本机写多 GB 文件，先问用户 |
| 把图喂给工作流 | `upload_file` | **必须绝对路径**，存进 ComfyUI 的 `input\` |
| 取回产物 | `fetch_outputs` | `prompt_id` + `out_dir`。**不传 `inline_images`**。`out_dir` 按项目结构落环节目录，见 §2 |
| 更新/覆盖已有**产物** | `comfyui-project-layout` 的 `scripts/safe-write.ps1`（**先归档到 old/**）→ 再写 | 规范见 `comfyui-project-layout`；不归档就覆盖 = 历史丢失。⚠️ 只针对产物，代码/配置/文档不适用 |
| 建项目 / 建镜头 | `comfyui-project-layout` 的 `scripts/new-project.ps1` | 同上 |
| **审图 / 审片 / 写审查报告 / 做前后对比** | `comfyui-review` | **必须先 `read_image` 真看图**；视频先 `review.py frames` 抽帧；报告落 `60_review/`，交人 review |
| 改工作流参数（prompt/seed/步数） | `list_workflow_slots` → `set_workflow_slot` | 只对**前端格式**工作流有效 |
| 批量扫参 | `vary_workflow` | 各槽位列表长度必须相同 |
| 读工作流里的说明文字 | `list_workflow_notes` | 读 Note/MarkdownNote |
| 报错说缺节点类 | `workflow_deps` → `install_node` → `restart_comfyui` | install 会让用户确认（跑第三方代码） |
| 查某个节点怎么连 | `nodes` | `action="get"` / `"search"` / `"upstream"` / `"downstream"` |
| 长任务在跑，看进度 | `job` | `action="status"` / `"wait"` / `"watch"` / `"cancel"` / `"queue"` |
| 卡住了、想清显存 | `system_stats` → `free_memory` | `free_memory` 不会打断正在跑的任务 |
| 看 ComfyUI 后台日志 | `get_logs` | 唯一的后台输出通道 |

> ⚠️ **脚本不在本手册目录下**。`new-project.ps1` / `safe-write.ps1` / `write-meta.ps1` 三个脚本都在
> **`comfyui-project-layout` skill** 的 `scripts/` 里。调用前先从该 skill 拿到它的资源基底路径再拼。

> ⛔ **本预设不涉及**：`partner_generate` / `list_partner_models` / `auth_login` 等付费托管模型工具，以及 `run_template` / `run_workflow` 中含 partner-API 节点的图。

---

## 2. 五步出图标准流程（复制即用）

```
① mcp__comfymcp__validate_workflow   workflow_path=<绝对路径>
      看 valid: true；顺带确认不涉及付费节点

② mcp__comfymcp__run_workflow        workflow_path=<同上>  wait=false
      → 立刻返回 prompt_id

③ mcp__comfymcp__job                 action="wait"  prompt_id=<上>  timeout_seconds=20
      🔴 **一次只等 20 秒**，然后反复调 action="status" 轮询，直到状态变终态。
      **不要在一次调用里等很久。**

      ⚠️ **实测过的坑（2026-10-04）**：传 `timeout_seconds=120` 会让 **MCP 传输层先超时**，
      返回 `Error: Request timed out`。**这个报错不代表任务失败** —— 任务仍在 ComfyUI 里跑，
      继续用 `status` 轮询就能拿到结果。

      ⛔ **绝不能因为超时就绕过 MCP**：不要写脚本直连 `http://127.0.0.1:8188` 的 HTTP API。
      那会丢掉 MCP 的参数校验与错误归一化，而且多烧一轮 token。见 §0 铁律 7。

④ mcp__comfymcp__fetch_outputs       prompt_id=<上>  out_dir=<项目对应环节目录>
      不要传 inline_images

⑤ 收尾（三步，一个都不能漏）
      a. 归档：若目标路径上已有同名产物 → 先跑 `comfyui-project-layout` 的 scripts/safe-write.ps1
         把它移进同目录 old/（**只对产物，代码/配置/文档不适用**）
      b. 侧车：跑同目录下的 scripts/write-meta.ps1 给产物写 .meta.json 可复现侧车
      c. 🔴 审查：加载 `comfyui-review`，**用 read_image 真看图**，按它的清单逐维度审、
         生成前后对比图、把审查报告落盘到 60_review/，然后交人 review
```

> ⚠️ **流程到 ⑤c 才算完。** 拿到产物直接丢给用户 = 违规。没看图就说"效果不错" = 违规。

**`out_dir` 怎么定**：不要往 `out/` 里平铺。按产物性质落到 `projects/<项目>/30_shots/<seq>/<shot>/` 下的环节目录
（构图→`20_layout`，关键帧→`30_key`，视频→`40_video`，音频→`50_audio`），
设定图落 `10_assets/`，分镜落 `20_pre/storyboard/`，试参数落 `00_dev/`。
完整规范与命名法见 `comfyui-project-layout`。

**改图类任务注意**：输入图片必须先放进 ComfyUI 的 `input\` 目录 —— 用 `mcp__comfymcp__upload_file`，传**绝对路径**。

---

## 3. 配方与工作流库（**按需加载 + 定点读，都不在本手册里**）

> 🔀 **MoE 式稀疏加载**：这一节原本占本手册近一半篇幅（约 5.3K token），但**只有真正要跑工作流时才需要**。
> 现已移到 [`references/recipes.md`](references/recipes.md)。

**什么时候读**：确认了要出图/出视频、准备拼工作流参数时。
**什么时候不读**：查工具怎么调、问模型能力、排查报错、讨论方案 —— 都不读。

⚠️ **读的时候也不要整文件读。** 那个文件**开头有一张定点索引表**，写明每节在第几行
（Qwen 配方 / H3 配方 / 工作流库 / 官方模板落差 四节）。
做法：先 `read references/recipes.md limit=18` 拿到索引，再按行号 `read ... offset=<起> limit=<行数>` **只取你需要的那一节**。

> 索引行号由 `_scratch/validate-recipes-index.cjs` 自动校验，不会悄悄过期。

> ⚠️ 配方里的模型文件名**必须照抄**，本机没有的模型不要照官方模板猜。

## 4. 环境目录速查

| 用途 | 路径 |
|---|---|
| ComfyUI 工作区 | `%COMFYUI_HOME%\ComfyUI` |
| 模型根目录 | `<工作区>\models\`（`unet_gguf` / `text_encoders` / `clip_gguf` / `vae` / `loras` / `controlnet` …） |
| 待输入图片（`LoadImage` 认这里） | `<工作区>\input\` |
| 原生产物 | `<工作区>\output\` |
| 用户工作流库 | `<工作区>\user\default\workflows\` |
| 官方模板 JSON | `<venv>\Lib\site-packages\comfyui_workflow_templates_json\templates\` |
| comfy-cli 配置 | `%USERPROFILE%\AppData\Local\comfy-cli\config.ini` |
| comfy-cli 作业状态 | `%USERPROFILE%\AppData\Local\comfy-cli\jobs\<prompt_id>.json` |

---

## 5. 缺东西了怎么办

**缺节点类**（`validate_workflow` 报 unknown class）：
```
workflow_deps（拿到缺失的 registry id 或 git URL）
  → install_node(names=[...])      ← 会让用户确认，因为要跑第三方代码
  → restart_comfyui                ← 新节点必须重启才可见
  → validate_workflow 再验一次
```
`workflow_deps` 返回的 key 里带 `/` `:` `@` 的是 **git 仓库 URL 而非注册表 id**，`install_node` 会拒绝 —— 这种情况交给用户手动装。

**缺模型**：`download_model(url, relative_path="models/unet_gguf")`。
⚠️ 动辄几 GB，**先问用户**。`relative_path` 第一段必须是 `models`。

---

## 6. 显存策略（12GB 的现实）

- 出图前先 `system_stats` 看 `vram_free`；不够就 `free_memory`（不会打断正在跑的任务）。
- Qwen Image 2.1 已用 Q6_K + `QwenImage21Cache` 压过显存，1024 分辨率稳。
- 视频**永远从最小配置试起**：5.17 秒 → 通 → 再加长/加分辨率。
- 见到连接中断/超时而非节点报错，多半是 **OOM 把 ComfyUI 进程整个干掉了** —— 用 `get_logs` 看日志，别反复重试同一个配置。
