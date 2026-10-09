# dsh-comfyui-preset

> 给 **DeepSeek Harness（DSH）** 的【ComfyUI 创作模式】Agent 预设。
> 装上它，DSH 就能**不用思考地**驱动你本机的 ComfyUI 出图、改图、生视频 —— 并自带一套专业动画项目的文件管理、视觉质检与媒体处理能力。
>
> **知识不是预置的，而是随用随取的**：用到任何软件 / 模型 / 插件时，它**先去查官方**，
> 把学到的落盘成**你能直接打开读的** `study/` 笔记，再照官方行动（见 §2「知识获取流程」）。

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
| **8 个专家手册** | `comfyui-mcp-ops`（操作）· `comfyui-prompt-craft`（提示词 + 参考接线）· `comfyui-perf`（显存性能）· **`comfyui-media`（视频抽帧 / 图像编辑 / 音频处理）** · `comfyui-review`（视觉质检）· `comfyui-project-layout`（文件管理 + 生长式结构 + 资产表）· `art-reference`（参考检索）· **`study`（知识获取流程 —— 用到外部软件 / 模型时先查官方）** |
| **15 行插件** | persona · agent-instructions · pwsh/bash · fs · fs-search · jobs · skill-filesystem · tool-skill · compaction 组(3) · ask-user · todo · web · present |
| **6 个工具脚本** | `verify-preset`（自检）· `pack-preset`（打包）· `run-python`（编码安全的 Python）· **`wait-job`（真推送等待）** · `check-encoding` · `asar-modules` |

### 技术要点：MoE 式稀疏加载

**常驻一个轻量路由器，专家按需激活** —— 这是本 preset 省 token 的核心。

| 层 | 体量（实测） | 何时进上下文 |
|---|---|---|
| persona（路由器） | ≈ **5,050 tokens** | **每轮** |
| 8 个 description（路由表） | ≈ **600 tokens** | **每轮** |
| **常驻合计** | ≈ **5,650 tokens/轮** | |
| 8 个专家正文 | ≈ 76,600 tokens | 按需，一次最多 1–2 个 |
| 各手册的 `references/` | ≈ 36,100 tokens | 再按需，只取具体那一篇 |
| **外部知识**（`study/`） | **不占 bundle** | 用到才查，摘要 ≤2000 tokens 进上下文 |

> 对比：全部预置手册正文约 **77K tokens** —— 一次全读会直接撑爆上下文。
> 稀疏加载把它压到**每轮 5.6K**。

**三条纪律**（写在 persona 里，靠它才真的生效）：

1. **加载预算**：一次最多 1–2 个专家手册。「以防万一把相关的都读一遍」是最贵的错误。
2. **配方延迟加载**：成品配方在 `references/recipes.md`，只在真要跑工作流时读。
3. **参考只取具体那篇**：不要整目录读。

### 技术要点：知识获取流程（`study`）

**知识不预置在 preset 里** —— 预置有两个根本问题：**普遍性不足**（只能覆盖预置的领域）
与**体积膨胀**（文档越加越多）。所以改成**流程**：

| 步骤 | 做什么 |
|---|---|
| **① 触发判据** | 这个决定是否依赖「我可能不知道 / 记错 / 版本已变」的外部事实，**且查错了代价高**？ |
| **② 查缓存** | 本地 `study/`（项目级 → `02_env/study/`）→ 没有再联网 |
| **③ 官方优先，但不定死官方** | 官方是**默认第一站**；**用户提出要社区方案就用社区的**；官方解决不了 / 没写 / 在本机行不通 → **社区是正当选项**。官方须**交叉验证确认是官方** · 学**方法思路**不照抄参数 · 社区须**标明来源 + 记可信度 + 实测验证** · 🔴 **官方 ≠ 无风险**，无论来源都过风险管控 |
| **④ 无官方（创造性领域）** | 🔴 **先出一版，别卡在选参考上** —— 找参考 → **直接做一版交付** → 满意就完事；**用户要改时才**把"参考了什么、为什么这么选"摆出来让他确认。交付时**标明参考级别**（大师 / 经典 / 权威 / 普通） |
| **⑤ 查不到** | 🔴 **停下给三选一**：跳过（标注未经官方确认）/ 你提供文档 / 改善网络后重试 |
| **⑥ 落盘** | 原档 → `study/<主题>/`（`source.md` + `refs/`）；我们的 → `notes/<主题>/`（`summary.md` + `lessons.md`） |
| **⑦ 用户示范 → 学成手册** | 🔴 **反复修不对（≥2 轮）就停下请用户示范** → 对比改前改后 → **追问「为什么这样对」** → 落盘 `notes/<主题>/lessons.md` → 用新规则重做一次验证 |

**🔴 `refs/` 必须放原始全文，一字不删、不得再精炼** ——
摘要的价值在**快**，原文的价值在**全**，两者不可互相替代。
**精炼了原文，就等于既没有快的、也没有全的**（拆成多文件可以，删段落不行）。

**两级缓存**：通用知识 → `02_env/study/<主题>/`；项目特有 → `01_projects/<项目>/study/<主题>/`

> 🔴 **`study/` 只存原档** —— 里面每一个字都应该是**从外面抓来的**。
> 我们的**总结**（`summary.md`）和**经验**（`lessons.md`）放 **`notes/<主题>/`**。
> **混在一起，你就再也分不清哪句是官方的、哪句是模型编的** —— 而那正是这套机制存在的理由。

### 🔴 技术要点：`study` 前置门（**真拦截，不只是规则**）

**规则靠自觉是不够的** —— 实测事故：用户清空 `study/` 后让它用 ComfyUI + Qwen 2.1，
它**加载了手册、也知道该往 `study/` 放**，却**跳过了「去抓」这一步**，直接凭记忆写了一份说明。
**没有报错、没有失败、一切看起来正常** —— 它自己觉得完成了。

所以加了一道**机械的**门（`plugin/study-gate.js`）：

```
调用任何 mcp__* 工具
      ↓
study/<主题>/ 有合规原档吗？（source.md 含真 URL + refs/ 非空）
      ├─ 有   → 放行，本会话不再问
      └─ 没有 → 🔴 拒绝，并给出可执行的出路
```

**为什么拦 MCP**：网页操作 / 电脑控制 / 软件控制**全都要经过 MCP** ——
拦 `mcp__*` 就等于拦住了所有外部操作。

**挂载点**：DSH 的 `tools/pre-execute` 事件（waterfall，dispatch 之前，可 allow/deny/cancel/ask）。

| 纪律 | 做法 |
|---|---|
| **fail-safe** | 任何异常一律放行；找不到工作根也放行 —— **宁可漏拦，不可误伤** |
| **不锁死** | 拒绝信息里给三条出路（去抓 / 问用户 / **写豁免文件**），不会卡住 |
| **学习通道不受影响** | `web_fetch` / `web_search` **不是** `mcp__*` → **永不被拦**，agent 能去查、能落盘、能再回来 |

**临时关掉整个门**：`cordis.patch.yml` 里把 `study-gate` 那行的 `enabled` 改成 `false`。

> ⚠️ 插件行用**裸包名 + 子路径**（`dsh-comfyui-preset/plugin/study-gate.js`），**不能用 `./plugin/...`**
> —— bundle 作用域的 `baseUrl` 可能是裸路径，加载器的 `new URL(name, baseUrl)` 会抛异常，
> 表现为预设显示「加载失败：never started」。详见 `cordis.patch.yml` 里那一行的注释。
>
> ⚠️ `workRoots` 是**本机路径**，换机器要改；路径不存在时插件会**自动放行**（不会误伤）。
> 离线干跑测试 **35 项**，含各种畸形输入、fail-safe 分支、两阶段检查与注入行为。

```
02_env/study/<主题>/
├─ summary.md      ★ 进上下文的就是这个（≤2000 tokens，每条带原文指针）
├─ source.md       ★ 出处、抓取时间、可信度评级、交叉验证记录
├─ refs/           🔴 原始全文，一字不删（按需取，不进上下文）
└─ lessons.md      ★ 用户教我们的（现象 / 用户示范 / 我们学到的）
```

> **为什么是"两级 + 摘要"**：`summary.md` 进上下文，`refs/` 按需取原文 ——
> 这跟 skill 的 `SKILL.md` + `references/` 是同一个渐进披露思路，只是内容**不再预置**。
> **全部是人类可读的 Markdown**，你可以直接打开看"它学到了什么"。
>
> **`lessons.md` 是价值最高的一类知识** —— 它是**你亲自示范过**的，比任何网上查来的都准。
> 每条记三段：**现象**（带数字）· **用户示范**（改前→改后）· **我们学到的**（为什么这样对）。
> 第三段是它存在的理由 —— **只记结论，下次遇到变体还是不会**。

### 技术要点：产物落盘结构

**根下三个主体文件夹**，永不互相嵌套：

```
<工作根>/
├─ 00_assets/    总资产 —— 跨项目复用（01_characters / 02_scenes / 04_3d / 05_audio …）
├─ 01_projects/  项目 —— ep01/ → sq010_temple/ → sh0010_arrive/
└─ 02_env/       环境 —— workflows / models 清单 / tools / **study（学到的知识）**
```

- **镜头码** `ep01_sq010_sh0010`，全项目唯一引用锚点
- **镜头号按 10 递增**（`0010/0020/0030`），中途插镜取 `0015` —— **永不重排**
- **`old/` 在每条资产/每个镜头自己的目录下**，保存舍弃或中间的产物，随时可回滚

### 🔴 技术要点：生长式结构 —— **结构不变，只按需创建**

> **目录名与层级是固定的，但什么时候建是按需的 —— 没有东西要放，就不建它。**

| 情况 | 做 / 不做 |
|---|---|
| 这次**没有音频** | ❌ 不建 `50_audio/` |
| 不用 3D | ❌ 不建 `00_assets/04_3d/` |
| 还没有任何角色资产 | ❌ 不建 `00_assets/01_characters/` |
| 第一次要往 `30_key/` 放图 | ✅ 建它 |

**为什么**：空目录是噪音、会误导判断（看到 `50_audio/` 会以为有音频）、
一次建全套会让每个项目长得一样看不出进度。**反过来，目录本身就是进度。**

**唯一入口**是 `comfyui-project-layout` 的 `scripts/ensure.ps1`（幂等）：
```powershell
& ensure.ps1 -Dir 01_projects/demo/20_shots/ep01/sq010/sh0010/30_key
& ensure.ps1 -Asset characters -Name kirito -NameZh 桐人 -Sub ref,sheet
```
`new-project.ps1` **只建项目根 + `project.json`**，不铺骨架。

### 技术要点：资产路径表

资产多了不好找。自动生成**两张带预览图与中英对照的索引**：

| 表 | 位置 | 内容 |
|---|---|---|
| **总资产表** | `00_assets/资产表.md` | 预览图 / 中文名 / 英文名 / 编号 / 出处 / 标签 / 文件数 / 最近更新 / 路径 |
| **分镜资产表** | `<镜头目录>/资产表.md` | **这个镜头用到哪些资产** |

```powershell
& asset-index.ps1 -All          # 总表 + 所有分镜表
```

- **预览图是缩略图**（生成到 `00_assets/.index/thumbs/`，按源文件内容哈希命名）——
  表保持轻量，100 个资产也不拖垮
- **中文名**来自每个资产的 `asset.json`（`ensure.ps1 -NameZh` 直接写）；没填的标 **⚠️ 待填**
- **分镜表识别资产**：`shot.json` 的 `assets[]` + `10_ref/` 文件名反查

### 技术要点：长任务用**真推送**等，不轮询

MCP 是同步模型，`comfy-mcp` 不推进度。**让模型反复去问是最贵的做法** ——
每次询问一次完整往返 + 上下文开销，而任务耗时不会因为多问而变短。

**做法**：`run_workflow wait=false` 拿 `prompt_id` + **`client_id`** → 起 `tools/wait-job.ps1`
连 ComfyUI 的 WebSocket **阻塞等服务端推事件** → 完成时退出 → **DSH 主动唤醒模型**。

> 🔴 **`-ClientId` 必须传**：查 ComfyUI 源码（`execution.py`）确认执行事件是**定向发送**的
> （`send_sync("executing", {...}, server.client_id)`），只发给提交时那个 client_id。
> **随机 id 连上去一条事件都收不到** —— 实测验证过。

**默认不设超时** —— 任务卡住就一直挂着，**由人决定要不要终止**（视频最长 58 分钟也等得起）。
**等待期间模型 turn 数 = 0。**

### 技术要点：它怎么"不用思考"

- **persona 常驻触发规则** —— 什么时候该加载哪个专家、什么绝不能做，写在每轮都读的地方
- **MCP 工具决策表** —— 哪个任务用哪个工具、参数怎么填，不用现查
- **进度信号自动路由** —— `pipeline-status.ps1` 报告每个镜头走到哪一步，**并直接写出该激活哪些专家**
- **外部知识先查官方** —— 不再靠模型记忆猜（见上「知识获取流程」）

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
├─ cordis.patch.yml      # ★ 主体：1 行 preset 声明 + 15 行插件
├─ skills/               # ★ 8 个专家手册（每个是一个带 SKILL.md 的目录）
├─ tools/                # 6 个工具脚本
├─ README.md
└─ INSTALL.md
```

**七种常见改造**：

| 想改什么 | 改哪里 | 怎么做 |
|---|---|---|
| **换模型**（用你本机的模型） | `02_env/study/<你的模型>/` | **建一个 study 条目**：`summary.md`（参数要点）+ `source.md`（官方出处）+ `refs/`（原文）。也可以直接让 DSH 去查官方再落盘 |
| **换工作流** | `02_env/workflows/` | 把你的工作流 JSON 放进去，在 `comfyui-mcp-ops` 的 recipes 里登记 |
| **加/减专家** | `cordis.patch.yml` → `config.plugins` | 加一行 `{id, name: '@deepseek-ai/dsh-...'}` 即可 |
| **改人格与规则** | `cordis.patch.yml` → `persona` 行的 `config.prefix` | ⚠️ **只放"何时激活谁"，细节进 skill**（见下） |
| **加自己的知识库** | `skills/<你的名字>/SKILL.md` | 建目录 + 写 frontmatter（`name` 用 kebab-case、`description` 要含触发词） |
| **喂它外部知识** | `02_env/study/<主题>/` | 把官方文档 / 你自己的资料放进去，写一份 `summary.md` 摘要 —— 它下次就会先查这里 |
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

**知识不再预置在 preset 里** —— 而是随用随取（见 §2「知识获取流程」）。

下列官方说明书已**播种为本机 `02_env/study/` 的初始缓存**（从早期预置快照迁移而来，
原文一字未丢），此后由 `study` 流程按需刷新：

| 官方说明书 | 本机位置 |
|---|---|
| **[ComfyUI 官方文档](https://docs.comfy.org)** | `02_env/study/comfyui/` |
| **[Qwen Image 2.1 官方说明](https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1)**（ComfyUI 官方教程） | `02_env/study/qwen-image-2-1/` |
| **[MiniMax H3 官方说明](https://docs.comfy.org/tutorials/video/minimax/minimax-h3)**（ComfyUI 官方教程） | `02_env/study/minimax-h3/` |

每个条目都是这个结构：

```
02_env/study/<主题>/
├─ summary.md      ★ 进上下文的就是这个（≤2000 tokens，每条带原文指针）
├─ source.md       ★ 出处、抓取时间、可信度评级、交叉验证记录
└─ refs/           细节原文（按需取，不进上下文）
```

> ⚠️ **这些是「整理与索引」，不是原文转载。**
> 每篇 `refs/` 顶部都标注了**原始 URL 与抓取时间**，可自行回源核对。
> **官方文档更新后，请以官方为准** —— 缓存可能滞后（`study` 流程有 90 天失效检查）。
>
> 本项目只做**参数提取、结构整理与要点索引**，用于让 Agent 不必每次联网查文档。
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
