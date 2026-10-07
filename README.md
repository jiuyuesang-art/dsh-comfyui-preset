# dsh-comfyui-preset

> 给 **DeepSeek Harness（DSH）** 的【ComfyUI 创作模式】Agent 预设。
> 装上它，DSH 就能**不用思考地**驱动你本机的 ComfyUI 出图、改图、生视频 —— 并自带一套专业动画项目的文件管理、视觉质检与官方文档知识库。

---

## 1. 兼容性与安装

### 兼容版本

| 项 | 要求 |
|---|---|
| **DSH** | `>= 0.1.7-rc.1`（`package.json` 的 `dsh.engines.dsh`） |
| **已验证版本** | `0.2.0-rc.2`（`dsh.compatibility.dshReleases`） |
| **Node.js** | `>= 22` |
| **操作系统** | Windows（脚本为 PowerShell 7；`pwsh` 需在 PATH 上） |
| **ComfyUI** | 本机可访问（默认 `http://127.0.0.1:8188`） |
| **MCP** | 需要 `comfy-mcp` 连接器（见下方「前置条件」） |

### 前置条件

本 preset **不自带 MCP 服务**，它复用你 profile 里**已有的** ComfyUI MCP 连接器：

1. 装好 `comfy-mcp`（`comfy-cli` 附带），并在 DSH 里配置为一个 MCP 连接器
2. 确认工具列表里能看到 `mcp__comfymcp__*`（约 78 个工具）

> 这样做是**故意的**：MCP 工具是宿主级的，所有预设都能用。
> 在 preset 里再挂一份只会让模型看到两套同功能工具，白白吃上下文。

### 安装

在 DSH 里让 agent 执行（`<本目录>` 换成你的绝对路径）：

```
plugin_manager  action=install_bundle  target=<本目录的绝对路径>
```

然后**新开一个会话**，在预设选择器里选【**ComfyUI 创作模式**】。

> ⚠️ **现有会话不会变** —— 预设是**按会话**惰性挂载的。

### 验证安装

```powershell
& "<本目录>/tools/verify-preset.ps1"
```

它会检查五项：DSH 内部模块兼容性 · 文件完整性 · profile 注册状态 · PowerShell 7 配置 · **持久化状态**。

### 🔴 升级 DSH 之后

**这个 preset 会活下来** —— 它是装在**用户 profile**（`%USERPROFILE%\.dsh\profiles\desktop\`）里的，
而 DSH 升级替换的是应用本体（`app.asar`）。两者互不覆盖。

升级后跑一次 `tools/verify-preset.ps1` 确认模块兼容性即可。

### 🔴 一个必须知道的坑：**不要用「禁用→启用」来重应用**

DSH 的 `set_bundle` 两个方向**行为不对称**（实测确认）：

| 操作 | 对组合快照的影响 |
|---|---|
| `enabled=false`（禁用） | **会把当前树写进快照** —— 此时**没有**本 preset 的行 |
| `enabled=true`（启用） | **只热生效、不落盘** |

**后果**：任何一次 disable→enable 之后，运行中一切正常，但**一重启预设就消失**。

**正确做法**：
- 改完 bundle 内容 → **其实不需要任何 toggle**（skill 正文每次加载时重读；persona 变更需重启）
- 预设真的从选择器消失了 → 见 `INSTALL.md` §1.1 的修复步骤

---

## 2. 功能框架与技术

### 组成

| | 内容 |
|---|---|
| **1 个预设** | `id: comfyui`，显示名【ComfyUI 创作模式】，roster 排位 `order: 5` |
| **8 个专家手册** | `comfyui-mcp-ops`（操作）· `comfyui-prompt-craft`（提示词 + 参考接线）· `comfyui-perf`（显存性能）· **`comfyui-media`（视频抽帧 / 图像编辑 / 音频处理）** · `comfyui-review`（视觉质检）· `comfyui-project-layout`（文件管理）· `art-reference`（参考检索）· **`study`（知识获取流程 —— 用到外部软件/模型时先查官方）** |
| **14 行插件** | persona · agent-instructions · pwsh/bash · fs · fs-search · jobs · skill-filesystem · tool-skill · compaction 组(3) · ask-user · todo · web · present |

### 技术要点：MoE 式稀疏加载

**常驻一个轻量路由器，专家按需激活** —— 这是本 preset 省 token 的核心。

| 层 | 体量 | 何时进上下文 |
|---|---|---|
| persona（路由器） | ≈ **3,840 tokens** | **每轮** |
| 9 个 description（路由表） | ≈ **870 tokens** | **每轮** |
| **常驻合计** | ≈ **4,710 tokens/轮** | |
| 9 个专家正文 | ≈ 56,000 tokens | 按需，一次最多 1–2 个 |
| 参考资料 | ≈ 344,000 tokens | 再按需，只取具体那一篇 |

**三条纪律**（写在 persona 里，靠它才真的生效）：

1. **加载预算**：一次最多 1–2 个专家手册。「以防万一把相关的都读一遍」是最贵的错误。
2. **配方延迟加载**：成品配方在 `references/recipes.md`，只在真要跑工作流时读。
3. **参考只取具体那篇**：不要整目录读。

### 技术要点：产物落盘结构

**根下三个主体文件夹**，永不互相嵌套：

```
<工作根>/
├─ 00_assets/    总资产 —— 跨项目复用（01_characters / 02_scenes / 04_3d / 05_audio …）
├─ 01_projects/  项目 —— ep01/ → sq010_temple/ → sh0010_arrive/
└─ 02_env/       环境 —— workflows / models 清单 / tools
```

- **镜头码** `ep01_sq010_sh0010`，全项目唯一引用锚点
- **镜头号按 10 递增**（`0010/0020/0030`），中途插镜取 `0015` —— **永不重排**
- **`old/` 在每条资产/每个镜头自己的目录下**，保存舍弃或中间的产物，随时可回滚

### 技术要点：它怎么"不用思考"

- **persona 常驻触发规则** —— 什么时候该加载哪个专家、什么绝不能做，写在每轮都读的地方
- **MCP 工具决策表** —— 哪个任务用哪个工具、参数怎么填，不用现查
- **官方文档离线快照** —— 三个模型的文档已落盘，断网也能查

---

## 3. 目的与改造

### 它要解决什么

用 DSH 驱动 ComfyUI 的原生体验是**每一步都要想**：该调哪个工具？参数填什么？产物存哪？
模型文件名是什么？出图好不好？——**每一步都在消耗你的注意力和 token**。

这个 preset 把这些**决策前置**成常驻规则 + 按需手册，让"对话驱动 ComfyUI"变成零摩擦。

### 🔧 如何改造成你自己的 preset

本 preset 就是一个普通的 **DSH bundle**，结构简单：

```
dsh-comfyui-preset/
├─ package.json          # bundle 声明（dsh.bundle.patch 指向补丁层）
├─ cordis.patch.yml      # ★ 主体：1 行 preset 声明 + 14 行插件
├─ skills/               # ★ 8 个专家手册（每个是一个带 SKILL.md 的目录）
├─ tools/                # 5 个工具脚本
├─ README.md
└─ INSTALL.md
```

**六种常见改造**：

| 想改什么 | 改哪里 | 怎么做 |
|---|---|---|
| **换模型**（用你本机的模型） | `02_env/study/qwen-image-2-1/` 等 | 把官方文档快照换成你模型的；改 `references/` 里的参数表 |
| **换工作流** | `02_env/workflows/` | 把你的工作流 JSON 放进去，在 `comfyui-mcp-ops` 的 recipes 里登记 |
| **加/减专家** | `cordis.patch.yml` → `config.plugins` | 加一行 `{id, name: '@deepseek-ai/dsh-...'}` 即可 |
| **改人格与规则** | `cordis.patch.yml` → `persona` 行的 `config.prefix` | ⚠️ **只放"何时激活谁"，细节进 skill**（见下） |
| **加自己的知识库** | `skills/<你的名字>/SKILL.md` | 建目录 + 写 frontmatter（`name` 用 kebab-case、`description` 要含触发词） |
| **改预设显示名** | `cordis.patch.yml` → `config.id` / `config.name` | `id` 改了就换了身份，注意别和内置预设撞名 |

**改完怎么生效**：

1. skill 正文与脚本 → **即时生效**（每次加载时重读）
2. persona / 插件行 → **重启 DSH**
3. 改了 `package.json` 的版本或依赖 → 重跑 `install_bundle`
4. 改完**一定跑一次** `tools/verify-preset.ps1`

### 🤖 让 DSH 自己帮你改

**这是最省事的路径** —— 因为 preset 就是一堆文本文件，你可以直接让 DSH 改：

> 在 DSH 里（用内置的「**创造模式**」或任意会话）说：
> **「读一下 `<本目录>/cordis.patch.yml` 和 `skills/` 的结构，帮我把模型换成我本机的 XXX，
> 并把工作流换成 `02_env/workflows/` 里的那几个」**

DSH 会读文件、改文件、跑验证 —— **和它改任何代码项目没有区别**。
`INSTALL.md` 里有完整的结构说明与注意事项，可以直接让它读。

> ⚠️ **改 persona 时请守住一条纪律**：
> 判断标准 —— **这句话是"什么时候该激活谁"，还是"激活后该怎么做"？**
> 前者留 persona，后者进 skill。**往 persona 里塞细节 = 每轮都付一次钱。**

---

## 4. 引用、致谢与开源说明

### 项目结构规范来源

| 来源 | 用在哪 |
|---|---|
| [Blender Studio — Folder Structure](https://studio.blender.org/tools/td-guide/folder_structure_overview) | 三根结构、`local/` 软件环境、资产分类、`集/序列/镜头` 布局 |
| [Blender Studio — File Naming](https://studio.blender.org/tools/naming-conventions/file-types) | 文件名规范、贴图类型后缀 |
| [Netflix — VFX Shot and Version Naming Recommendations](https://partnerhelp.netflixstudios.com/hc/en-us/articles/360057627473-VFX-Shot-and-Version-Naming-Recommendations) | 镜头码「清晰、一致、永不重复」原则 |
| [CGWire — A proposal for your file hierarchy](https://blog.cg-wire.com/cg-pipeline-a-proposal-for-your-file-hierarchy/) | 管线目录提案（Kitsu 团队） |
| [La Cuisine (Les Fées Spéciales) — Organizing project files](https://lacuisine.tech/an-introduction-to-organizing-project-files) | `current/` 技巧 |

### 官方说明书来源

本项目**引用并整理了下列官方说明书**，做成离线快照供 Agent 按需查阅：

| 官方说明书 | 快照位置 |
|---|---|
| **[ComfyUI 官方文档](https://docs.comfy.org)** | `02_env/study/comfyui/` |
| **[Qwen Image 2.1 官方说明](https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1)**（ComfyUI 官方教程） | `02_env/study/qwen-image-2-1/` |
| **[MiniMax H3 官方说明](https://docs.comfy.org/tutorials/video/minimax/minimax-h3)**（ComfyUI 官方教程） | `02_env/study/minimax-h3/` |

> ⚠️ **这些是「整理与索引」，不是原文转载。**
> 每篇 `references/` 顶部都标注了**原始 URL 与抓取时间**，可自行回源核对。
> **官方文档更新后，请以官方为准** —— 快照可能滞后。
>
> 本 preset 只做**参数提取、结构整理与要点索引**，用于让 Agent 不必每次联网查文档。
> 官方说明书的**著作权归各自所有者**。

### 创作来源

> **这个 preset 本身，就是在 DSH 的「创造模式」下、用 DeepSeek V4.1 模型对话写出来的。**

具体来说：

- 用 **DSH 内置的「创造模式」**（`preset-cordis`）作为工作环境 —— 它提供写插件、改配置、验证效果的完整能力
- 用 **DeepSeek V4.1** 模型作为对话方，逐步产出 `cordis.patch.yml`、8 个 skill、工具脚本与文档
- 换句话说：**它是「用 DSH 造 DSH 扩展」的产物** —— 一边造一边用，规则与手册都经过实际使用的打磨

这也意味着：**如果你觉得这套结构好用，你完全可以照同样方式造自己的 preset。**
具体怎么改见本文 §3「目的与改造」——尤其是「**让 DSH 自己帮你改**」那一节。

### 依赖的 DSH 内部模块

本 preset 通过 `cordis.patch.yml` 引用下列 DSH 内部模块（`@deepseek-ai/` 命名空间）：

`dsh-agent-preset` · `dsh-persona` · `dsh-agent-instructions` · `dsh-tool-bash` · `dsh-tool-pwsh`
`dsh-tool-fs` · `dsh-tool-fs-search` · `dsh-tool-jobs` · `dsh-skill-filesystem` · `dsh-tool-skill`
`dsh-compaction` · `dsh-tool-ask-user` · `dsh-tool-todo` · `dsh-tool-web` · `dsh-tool-present`

### 开源说明

**许可证：MIT** —— 见 [`package.json`](package.json)。可自由使用、修改、再分发。

**免责声明**：

- 本项目是**第三方社区作品**，与 **DeepSeek、ComfyUI、Qwen（阿里）、MiniMax 均无隶属关系**，
  也**未获得任何一方的官方背书**
- 引用的**官方说明书**（ComfyUI / Qwen Image 2.1 / MiniMax H3）**著作权归各自所有者**；
  本项目只做**整理与索引**，并在每篇顶部标注原始 URL
- 项目结构规范引用的第三方资料（Blender Studio / Netflix / CGWire / La Cuisine）
  各自适用其原有许可
- 参考图与素材的使用请自行确认版权 —— **免费 ≠ 可商用**（`art-reference` 手册里有红线说明）
- **使用本 preset 生成的内容**，其合规性与版权责任由使用者承担

**贡献**：欢迎提 Issue / PR。改 `skills/` 与 `cordis.patch.yml` 前请先读 [`INSTALL.md`](INSTALL.md)。

---

## 相关文件

| 文件 | 用途 |
|---|---|
| [`INSTALL.md`](INSTALL.md) | 完整安装、验证、故障处置、结构说明 |
| [`tools/verify-preset.ps1`](tools/verify-preset.ps1) | 五项自检（安装后与升级后各跑一次） |
| [`tools/pack-preset.ps1`](tools/pack-preset.ps1) | 打包成可分发的 zip + sha256 |
