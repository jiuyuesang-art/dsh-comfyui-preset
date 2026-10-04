# dsh-comfyui-preset —— 【ComfyUI 创作模式】

一个 DeepSeek Harness **bundle**，注册一个名为【ComfyUI 创作模式】的 Agent 预设。
装上之后新开会话选它，就能直接用本地 ComfyUI 出图 / 改图 / 抠图 / 上色 / 生成视频 ——
**模型不需要思考该调哪个 MCP 工具，也不需要联网查文档。**

> ### 这是什么
>
> 它把 DSH 从"通用编码助手"变成**本地 ComfyUI 创作工作台**：
> 8 个专家手册按需加载、产物按专业动画项目规范落盘、交付前强制看一遍再交给你。
>
> **它不包含** DSH 本体、ComfyUI 本体、模型权重 —— 那些是前提条件（见 [INSTALL.md](INSTALL.md)）。
>
> **安装**：`plugin_manager action=install_bundle target=<本目录>` → 新开会话选预设。
> 细节、依赖、更新后重启用步骤都写在 [INSTALL.md](INSTALL.md)。

---

## 装了什么

| 组成 | 内容 |
|---|---|
| **1 个预设** | `id: comfyui`，显示名【ComfyUI 创作模式】，roster 排位 `order: 5`（在 standard/ptc/minimal/cordis 之后） |
| **8 个 skill（知识库 + 工具）** | `comfyui-mcp-ops`（操作手册）· `comfyui-prompt-craft`（提示词工程手册）· **`comfyui-review`（视觉质检 + 抽帧/对比脚本）** · **`comfyui-project-layout`（动画项目文件管理 + 4 个脚本）** · **`art-reference`（艺术参考检索 + 可达性实测表）** · `comfyui-docs`（ComfyUI 官方文档快照 + 全站索引）· `qwen-image-2-1-docs` · `minimax-h3-docs` |
| **15 行插件** | persona · agent-instructions · pwsh/bash · fs · fs-search · jobs · workspace-dependencies · skill-filesystem · tool-skill · compaction 组(3) · ask-user · todo · web · present |

> `workspace-dependencies` 是给视觉审查兜底的：PATH 上没 Python/Pillow 时，用它取捆绑 Python 的绝对路径。

### 预设做了什么

**① 解决"调用 MCP 要思考很久"** —— 用两个杠杆，不是靠再挂一遍 MCP：

- **persona 常驻硬规则**：任何出图/改图/视频/ComfyUI 请求，模型的**第一个动作**必须是加载 `comfyui-mcp-ops`。这条规则每轮都在上下文里，模型没有犹豫空间。
- **操作手册里放决策表 + 成品配方**：39 个工具的「意图 → 工具」对照表、三步出图流程、以及**与用户本机模型文件名完全对齐**的两套可用配方（Qwen Image 2.1 的 GGUF 配方含 `QwenImage21Cache` 显存优化节点与 `TextEncodeQwenImage21` 一体化编码；MiniMax H3 的 Ref2VA 配方含 17n+5 帧数对齐公式与音频 VAE 接线）。手册里还有用户现成的 10 个工作流路径，优先复用而不是从零造 —— 并**明确标注了哪条路线有产出证据、哪条没有**（Qwen Image 2.1 侧有 26 个 `qwen21*` 产物可证；MiniMax H3 侧只有工作流文件、`output\video\` 为空，属未验证）。

**② 花钱红线写进 persona**：`confirm_spend` 永不主动传 `true`；partner-API 节点与云端模型一律先问用户。本预设只做本地免费能力。

**③ 显存现实写进知识库**：12GB 的瓶颈、Windows 驱动 System Memory Fallback 会让超显存任务"跑完但不报错只变极慢"这类陷阱，都在 skill 里点明。

**④ 写提示词时切换到「提示词工程师」语言风格**（2026-10-03 加入）
persona 里写死了一条交付契约，`comfyui-prompt-craft` 手册承载执行细节：

- **输出固定三段**：① 可直接粘贴的**成品代码块** → ② **不超过 3 行**的设计说明（只讲取舍，不复述内容）→ ③ 需要时给**变体**（每个变体也是成品）
- **硬性禁止**：写「提示词写作教程」、讲基础概念、「你可以试试…」这类含糊试探、一次抛 3 个以上问题
- **两条语言硬规则**：图像提示词用**中文**（Qwen Image 2.1 原生支持且是强项）；视频提示词正文**必须英文**（H3 官方要求），只有对白与画面可见文字保留原文
- **一条反咒语规则**：`masterpiece` / `best quality` / `8k` / 加权负向词这类 SD1.5 时代的东西对这两个模型**完全无效**，一律不写
- 手册里还有：Qwen 的 RGBA 固定话术、`<imageN>` 四段式编辑结构、Mask Editor 点名颜色机制；H3 的固定骨架（指令行 → 空行 → 三个核心字段）、时间线与切镜规则、运镜三维词表、以及 10 条反模式对照表

**⑤ 产物按专业动画项目结构落盘，且更新前强制归档**（2026-10-03 加入）
persona 里把原来的「统一落到 `out/`」换成了一条硬规则，`comfyui-project-layout` 承载规范，三个脚本负责执行：

- **目录骨架**取自 [CGWire 管线目录提案](https://blog.cg-wire.com/cg-pipeline-a-proposal-for-your-file-hierarchy/)（`working`/`export` 分离、**assets 与 shots 两棵树**、`序列/镜头/环节` 三层）
- **命名法**取自 [Blender Studio 官方规范](https://studio.blender.org/tools/naming-conventions/shared-folder-structure)：序列 `NNN_name`、镜头 `NNN_NNNN`、文件 `<seq>_<shot>-<环节>-v<NNN>.<ext>`，**全小写、无空格**
- 🔴 **核心规则：更新或覆盖任何已存在的文件之前，先把旧文件移进【同目录的 `old/`】**（带时间戳，反复更新也不互相覆盖）。
  ⚠️ 回滚**不能简单 `Move-Item`**（原位已有新版本，会报"文件已存在"）——正确做法是"先归档当前版本，再把目标版本移回来"，**两边都不丢、可反复来回切**。完整步骤见 skill 的 §3.3（已实测通过往返切换）。Blender Studio 用的是同样思路（他们叫 `_archive/`）
- **可复现侧车**：每个产物旁写 `.meta.json`（prompt / seed / 步数 / cfg / 模型 hash / sha256）
- **三个脚本**（都经实测）：`new-project.ps1`（建项目/序列/镜头 + 命名校验）、`safe-write.ps1`（归档守卫，**图与侧车成对归档**）、`write-meta.ps1`（写侧车）

**⑥ 交付前强制视觉审查**（2026-10-03 加入）
persona 里加了硬规则，`comfyui-review` 承载清单，`review.py` 承载工具：

- **流程**：产物出来 → **必须用 `read_image` 真看图** → 逐维度审 → 生成前后对比图 → 报告落盘 `60_review/` → **交人 review**
- **四条红线**：不许自我批准（采纳权在人）· 每条结论必须指向画面里看得见的证据 · 必须真看图、禁止凭参数推断 · 视频是抽帧看的，必须声明抽样限制与"听不到音频"
- **审查清单**：图像 8 维（主体保真 / 提示词符合度 / 解剖结构 / 文字渲染 / 技术瑕疵 / 构图 / 风格一致性 / 通道格式）；视频另加时间一致性、运动合理性、首尾帧、技术规格
- **判定分级**：`PASS` / `PASS_WITH_NOTES` / `NEEDS_WORK` / `FAIL`，**默认从严，拿不准就降一级**
- **报告固定三段**：① 前后对比（对比图 + 差异要点）② 审查结果（逐维度 + 证据）③ 修改建议（**具体到能直接照做的参数**）
- **`review.py` 三个子命令**（都经实测）：`frames`（ffmpeg 抽帧 + 接触表 + META JSON）、`compare`（并排 + 差异×4 增强 + 中文标签）、`sheet`（多图接触表）

> 已用**你的真实产物**跑通一遍完整审查：`top20/01_luffy` vs `top20cn2/01_luffy`，真查出三条问题（背心配色红→黄漂移、胸口 X 伤疤缺失、肩部一个身份不明的黄色小人形）。样例报告见 `_scratch/realreview/01_luffy-review-v001.md`。
>
> ⚠️ **视觉前提**：`read_image` 由 `dsh-tool-fs` 提供，但它**执行时会检查调用模型是否声明了 image 输入**。当前默认模型 `deepseek-v4.1-flash` 的配置是 `input: [text, image]` ✅。**若换成纯文本模型，视觉审查会静默失效** —— 表里看不到图，报告就只能是编的。

**⑦ MoE 式稀疏激活：按工程进度决定加载哪个专家**（2026-10-03 加入）

把上下文当 MoE 来管：8 个手册 = 8 个专家，**按门控信号稀疏激活**，不再"一次全背"。

| MoE 概念 | 本预设的对应物 |
|---|---|
| 专家 | 8 个 skill + 它们的 references |
| **门控信号** | **① 意图信号**（用户说了什么）⊕ **② 进度信号**（工程走到哪一步） |
| 门控网络 | persona 的激活路由表 + `pipeline-status.ps1` |
| 稀疏激活 | 只装当前阶段需要的；配方**按节定点读** |

**① 进度信号是新增的一路**（就是你说的"不能只看输入命令"）：
`pipeline-status.ps1` 扫描 `30_shots/`，判定每个镜头的阶段（`empty`/`ref`/`layout`/`key-needs-meta`/`key-needs-review`/`key-rework`/`key-done`/`video-*`），
**并直接输出该激活哪些专家、下一步做什么**。它把"工程进度"从"要靠模型翻目录猜"变成"一条命令拿到的事实"。

**② 配方延迟加载 + 定点读**：`comfyui-mcp-ops` 的配方（原本占该手册 49%）移到 `references/recipes.md`，
该文件**开头有带行号的定点索引** —— 模型先读 18 行索引，再 `read offset/limit` **只取需要的那一节**，
而不是把 135 行全读进来。索引由 `_scratch/validate-recipes-index.cjs` 自动校验（**自测过：故意改错一行会被抓**）。

**实测体量变化**：

| 项 | 改前 | 改后 |
|---|---|---|
| `comfyui-mcp-ops` 正文 | 12,012 字符（≈10,811 tok） | **6,767 字符（≈6,090 tok）** |
| persona 常驻 | 2,533 字符（≈2,280 tok） | 3,713 字符（≈3,342 tok） |
| 全 7 手册一次加载最坏情况 | 51,141 字符（≈46,027 tok） | **45,959 字符（≈41,363 tok）** |

**净账（诚实版，别只看好处）**：

| 任务类型 | 净变化 |
|---|---|
| **不跑生成**（查工具 / 问能力 / 讨论方案） | **约 −3.8K token** ✅ |
| **要跑生成**，且按索引只读一节配方 | 约 **−1.4K token** ✅ |
| **要跑生成**，但把 135 行配方全读 | 约 **+1.7K token** ❌（persona 变长换来路由能力） |

> 所以：**收益取决于模型是否按索引定点读**。校验器保证了行号准确，但"是否照做"是模型行为，**无法强制**。

**⑧ 主动联网找参考 + 艺术站点清单**（2026-10-03 加入）

艺术创模式不能凭记忆硬编。`art-reference` 承载规范，persona 里加了积极触发规则。

- **触发判据不是"用户有没有说找参考"**，而是「**这个决定有没有客观依据可查**」——风格特征 / 构图 / 姿势 / 配色 / 材质 / 服装考据，有就先查再动笔
- **检索顺序**：`web_search` 摸清 → `multi_search` 交叉验证 → `web_fetch` 取确切 URL
- ⚠️ **本机搜索工具是第三方插件提供的**（`dsh-free-search`），与预设无关、一直在，已写进 persona

**‼️ 站点清单按「从你这台机器实测可达」筛，不是照搬"著名站点"。而且可达性是动态的——所以做成了探针：**

```powershell
& "<art-reference>/scripts/check-sites.ps1"          # 全部，并发探测，约 15 秒
& "<art-reference>/scripts/check-sites.ps1" -Group 传统
```

实测输出（代理关闭状态下）：**`可达 29 / 39`**，并且分三档——`✅ 通` / `⚠️ 可达但挡爬虫(403/405/429)` / `❌ 网络不可达`。
**`⚠️` 这一档很关键**：站点其实活着，只是拒绝爬虫，换 `web_fetch` 或搜索工具很可能能拿到内容。

**🔺 传统艺术优先**（你的论点，已写进规范核心）：
> 风格会过时，根基不会。一个 2026 年的日式角色，其**头身比、面部结构、衣纹走向、场景透视、光影逻辑**全部建立在古典与传统绘画之上，潮流只是表面处理。
> **所以先把结构与造型的参考找实，再定风格表皮。** 反过来做，画面就会"飘、软、站不住"。

| ✅ 传统艺术（实测可达） | 用途 |
|---|---|
| **Met Museum API** | 全门类，含**服饰/盔甲/雕塑**，公共领域 |
| **Art Institute of Chicago API** | 绘画、版画、**东方艺术** |
| **WikiArt** | 按流派/艺术家/题材组织的绘画总库 |
| **Europeana API** | 聚合全欧洲博物馆 |
| **Web Gallery of Art** `wga.hu` | 文艺复兴至巴洛克，带构图分析 |
| **V&A** | **服饰史 / 设计 / 装饰纹样**（做角色服装必看） |
| **Theoi** | 希腊神话图像学（奇幻设定考据源） |
| **David Rumsey** | 历史地图与建筑图纸（世界设定） |
| **National Gallery UK** · **Getty** · **ArchDaily**（+中文版） | 绘画 / 建筑园林 / 建筑摄影 |

| ✅ 中文古画古籍（全可达，做东方题材必用） | 用途 |
|---|---|
| **中华珍宝馆** `ltfc.net` | 历代绘画**高清**，可放大看笔墨衣纹 |
| **书格** `shuge.org` | 古籍古画扫描，**公共领域**可下载 |
| **故宫博物院** · **上海博物馆** · **雅昌艺术网** | 院藏书画器物 / 青铜陶瓷 / 拍卖图录高清细节 |

| ✅ 外网内容的镜像替代 | 说明 |
|---|---|
| **Pixivision** `pixivision.net` | **Pixiv 官方媒体站** —— Pixiv 本人不可达时的**官方替代** |
| **pixiv.re** | Pixiv 图床镜像，已知作品 ID 可直接出图 URL |
| **Safebooru** | Danbooru 被 Cloudflare 挡时的内容相近替代 |
| **萌娘百科** · **MyAnimeList** · **Zerochan** | 设定考据与图库 |
| **百度图片** · **Bing 图片** | 想不出词时**直接搜画面**，效率高于文字检索 |

> ❌ 代理关闭时不可达：Pixiv、ArtStation、Civitai、Wikimedia/Wikipedia、Google Arts、Louvre、Internet Archive、台北故宫。

**🔁 关于代理（你说会手动启用）**：

- 探针会读注册表报出**代理当前状态**。这台机器现状：**已配置 `127.0.0.1:7890` 但 `ProxyEnable = 0`（未启用）**
- 用户开了代理 → **重跑探针**，会多出一批可达源站，此时优先用**源站**而不是镜像
- ⚠️ 已写进规范：**绝不自己改系统代理设置**（那是用户的网络配置）；若用户说开了但探针仍不通，**如实报告观察**，别硬试

**⚠️ 三个实测踩出来的坑，都写进 skill 了**：

1. **别把列表页拉进上下文** —— 实测 fetch 一个 booru 帖子列表页，灌进几万字符缩略图标记后被截断，**有用信息反而看不全**。要用带 `limit` 的 JSON API。
2. **booru tag 词表是金矿但不能直接抄** —— 它是人工维护的**受控词表 + 使用量排序**，是"把模糊中文感受翻译成精确描述"的最短路径；但它是**检索用的描述体系，不是 Qwen 2.1 / H3 的 prompt 语法**。正确姿势是**用 tag 校准观察维度，再用目标模型的语言写提示词**。

**版权红线**（写进 skill）：公共领域/CC0 可直接用于交付物；他人作品**只能当参考看**，不能进交付物、不能描图；需要直接用外部素材时**只从公共领域取**，并注明来源。

**⑨ 中文编码保障：杜绝静默损坏**（2026-10-04 加入）

本模式全程中文（提示词、报告、文件名），编码错了会产生两种损失——第二种**不报错**：

| 损失 | 现象 |
|---|---|
| 输出乱码 | 看不懂 → 重跑一轮 → 白烧 token |
| **`open()` 写出 GBK 文件** | **内容坏了但不报错** → 直到有人用 UTF-8 读才发现 ← 更贵 |

**先逐段实测，才找到真正的破口**：

| 环节 | 实测结果 |
|---|---|
| PowerShell 7 字面量 / 输出 / 写文件 | ✅ 正常（`$OutputEncoding` = utf-8，写文件无 BOM） |
| Node（含 emoji） | ✅ 完美 |
| **MCP → ComfyUI** | ✅ **正常**（`list_workflow_slots` 返回的中文文件名与提示词完好） |
| **Python（裸调）** | ❌ `sys.stdout.encoding = gbk`、`locale = cp936`、**`open()` 写 GBK** |

**根因**：控制台代码页是 **936（GBK）**，而 **Python 是唯一会跟随它的环节**。

**实测对照**（同一段中文，只差一个环境变量）：

| | 写出的字节 | UTF-8 读回 |
|---|---|---|
| 裸调 | 16 字节 `D6 D0 CE C4…`（**GBK**） | ❌ 乱码 |
| `PYTHONUTF8=1` | 22 字节 `E4 B8 AD E6 96 87…`（**UTF-8**） | ✅ 正常 |

> ⚠️ **`PYTHONIOENCODING=utf-8` 单独用不够**：它只改 stdout/stderr，`locale.getpreferredencoding()` 仍是 cp936，
> **`open()` 照样写 GBK**。只有 `PYTHONUTF8=1`（Python UTF-8 模式）能一次修好**输出 + locale + `open()`**。

**解法：`tools/run-python.ps1`——统一入口**

```powershell
& "<bundle>/tools/run-python.ps1" <脚本.py> [参数...]
& "<bundle>/tools/run-python.ps1" -c "print('中文 ✅')"
```

它设好 `PYTHONUTF8=1` + `PYTHONIOENCODING=utf-8`，对齐 PS 侧编码，自动探测 python，
并**原样转发 `--` 前缀参数**（实测 `--count 9 --sheet x.png` 不被 PowerShell 吃掉）。
**persona 里写成了硬规则：一切 Python 调用都走它，不要直接敲 `python`。**

**`tools/check-encoding.ps1`——链路自检**

逐段探测并指出**哪一段**坏了（不是笼统说"编码有问题"）。当前实测：

```
✅ PS 写文件往返        42 字节（期望 42，无 BOM）· 读回正常
✅ PS 输出/控制台编码    utf-8
✅ Node 输出            中文✅
ℹ️  Python 默认 stdout   gbk   ← 已知事实（所以必须走包装器）
ℹ️  Python 默认 locale   cp936 ← 它决定 open() 用什么编码
✅ run-python 中文输出 / UTF-8 模式 / 写文件编码（42 字节，读回一致）
✅ MCP → ComfyUI 中文    实测正常
✅ DSH 读写工具中文       实测正常
🎉 编码链路正常
```

> **两个设计细节，都是修过 bug 得来的**：
> ① **期望值一律运行时算，不硬编码** —— 第一版写死了"22 字节"，换了个探测串后**永久假警报**；
> ② **三态而不是布尔** —— 裸调 python 的 GBK 是**已知事实**而非故障，
> 当成失败会让工具**永远报错**，等于没有。

### 关于第三方插件：选本预设**不会**关掉它们

这一条有**注册表层面的事实**，不是推测：

| 证据 | 结果 |
|---|---|
| `preset-cordis` 声明 33 个模块，其中第三方 | **0 个**（只有 DSH 自己的 `dsh-plugin-manager/tools`） |
| 但当前会话（正是 cordis 预设）能用 `multi_search` / `mcp_connector_*` / `mcp__comfymcp__*` | ✅ 全部可用 |

**结论：第三方插件挂在宿主层，预设只贡献"作用域内的行"，动不了它们。** 你现在启用的这些在 ComfyUI 模式下**保持同样状态**：
`dsh-free-search` · `dsh-mcp-connector` · `dsh-comfyui-win`(computer-use) · `@opencode2dsh/dsh-plugin` · `dsh-opencode-go` · `dsh-plugin` · `dshmarket` · `dsh-pocket` · `@mzzsfy/dsh-usage-panel` · `@weibaohui/skills-management`。

> ⚠️ **一个未来会冲突的坑**：`billion-context`（上下文压缩插件，**当前是关闭状态**）声明了 `overrides: ["compaction-basic"]`。
> 本预设**自带自己的 compaction 行**。若将来启用 `billion-context`，可能出现两套压缩机制同时作用。启用前先试一下。

### DSH 更新会不会弄坏它？—— 有实测依据的答案

**结论：bundle 本体不会坏，但有三处会失效，其中一处最容易漏。**

| 部分 | 更新后 | 依据 |
|---|---|---|
| **bundle 本体 + 8 个 skill + 脚本** | ✅ **不受影响** | 它在 `Documents\...`，应用本体在 `D:\Deepseek\resources\app.asar` —— **两个不同的根** |
| **依赖的 18 个 DSH 内部模块** | ⚠️ 可能改名/移除 | 实测：这些模块**不在 profile 的 `node_modules` 里**，**只存在于 `app.asar` 内**（asar 头解析：12,967 文件 / 529 包）。→ **预设与 DSH 版本的内部模块集硬耦合** |
| **profile 注册**（link + bundles 列表） | ⚠️ 可能失效 | profile 里是**相对符号链接** `..\..\..\..\Documents\...`，锚在 `C:\Users\<你>\` —— **移动/改名工作区就会悬空** |
| **PowerShell 7 配置** | ⚠️ **可能被重置** | 🔴 **它在 profile 的 `cordis.patch.yml`，根本不在 bundle 内** —— 这条最容易漏，且漏了以后四个脚本**全部拒绝执行** |

**为此补上了真实 bundle 的兼容声明**（对照 `dsh-free-search` 的写法），我的 bundle 之前**三样都没写**：

```json
"dsh": {
  "bundle": { "patch": "./cordis.patch.yml" },
  "engines": { "dsh": ">=0.1.7-rc.1" },                    ← 补上
  "compatibility": { "dshReleases": { "0.2.0-rc.2": "compatible" } }   ← 补上（实测验证过的版本）
}
```

> 注意：真实 bundle 的 `peerDependencies` 用**范围**（`^0.1.7-rc.1 || ^0.2.0-rc.1`）而不是精确钉版本——
> 这是"扛住小版本更新"的关键。本 bundle 无 JS 代码、不 import 任何模块，所以不声明 code peer，
> 改为**用 asar 扫描器实测模块是否还在**（更精确：它会指出**具体哪几个**模块没了）。

### 打包与更新后重启用（`tools/` 三个工具）

| 工具 | 作用 |
|---|---|
| `tools/pack-preset.ps1` | 打包 → `dist/*.zip` + `.sha256` + `MANIFEST.json`（版本 / 文件哈希 / 依赖模块清单） |
| `tools/verify-preset.ps1` | **DSH 更新后必跑**：模块兼容性 → 文件完整性 → profile 注册 → PS7 配置，四项逐一报 |
| `tools/asar-modules.cjs` | 正确解析 `app.asar` 头部（JSON 目录树），列出应用内全部 529 个包 |

**流程**：更新 DSH 后 → 跑 `verify-preset.ps1` → 按报错修 → `set_bundle` 重新启用 → **新开会话**。

**分发**：`zip + .sha256 + INSTALL.md`。已实测**解压到别处后自检通过（48/48 哈希一致）**，分发物自足。

> ⚠️ 打包器的**两个 bug 是这个验证抓出来的**：① `MANIFEST.json` **自我引用**（重打包必报"1 个文件不符"）；
> ② zip 里**嵌套了 `dist/`**，每打一次包就臃肿一层。现在改用 `package.json` 的 `files` 声明 + 暂存目录。
>
> ⚠️ **哈希不可复现**：连打两次包 SHA256 不同（清单含打包时间戳）。`.sha256` 永远与随附的那个 zip 匹配，但别指望"同样输入得到同样哈希"。

**调研后补进规范的 6 条**（来自 248 行调研简报，出处分级见 skill §8）：

| 补进来的 | 依据 |
|---|---|
| **`edit/current/` 技巧**：各镜最新预览统一拷进 `40_editorial/current/`，剪辑只读它 → 打开剪辑永远是全片最新 | La Cuisine / Les Fées Spéciales |
| ⚠️ **batch seed 陷阱**：ComfyUI 一次 batch 的 PNG 元数据**只有初始 seed**，逐图实际 seed 会丢 → 侧车必须写 `perImageSeeds` 数组 | ComfyUI Discussion #1124（**这条直接决定侧车能不能真复现**） |
| **模型记 hash 不记文件名**：模型会改名、同名不同内容 | Civitai ModelHash |
| **归档=四件套**：图 + workflow JSON + params.json + models.json | ComfyUI Workflow Metadata 官方文档 + MLflow artifact 约定 |
| **状态后缀固定小词表** `_wip/_review/_approved/_final/_rejected`；禁 `_final2`/`_new`/`_real` | Aspect、ArcLoop（死亡螺旋案例） |
| **帧号 4 位、从 `1001` 起**；编号**按 10 递增**给插镜留空间 | Aspect、PostMicroTools |

> 工业界背书：[MovieLabs/comfyui-movielabs-util](https://github.com/MovieLabs/comfyui-movielabs-util) 是 **MovieLabs 官方的 ComfyUI 节点**，已实现自动版本号、自动建目录、命名校验并对接 ShotGrid——证明「AI 生成 + 专业 pipeline 规范」不是自娱自乐。
>
> **三处有意偏离业界**（已在 skill §8 列表说明）：归档叫 `old/` 而非 `_archive/`（你的要求）；工作文件也带 `vNNN`（个人没有 SVN）；音频按镜归属 `50_audio/`（H3 音画同一次生成）。

---

## 安装

在 DSH 里让 Agent 执行（需要 danger-full-access 或批准）：

```
plugin_manager  action=install_bundle   target=<本目录的绝对路径>
```

它会自己完成包安装与 bundle 选择，**不要**手动去改 `cordis.yml` 或跑 pnpm。

## 验证

1. `plugin_manager action=list_bundles` → 应出现 `dsh-comfyui-preset`
2. `plugin_manager action=list_plugins` → 应出现 `preset-comfyui` 行
3. **新开一个会话**，预设选择器里应能看到【ComfyUI 创作模式】

> ⚠️ **已存在的会话不会切换过去。** 会话在启动时绑定插件版本（"现有 Agent 保留已经使用的组合"）。
> 必须在**新会话**里选这个预设才能验证。

新会话里的自检清单（约 1 分钟，**按顺序**做，第 0 步是前提）：

- **第 0 步 · 对话本身通不通**：随便说句话，模型能正常回。约等于同时验证了宿主层的 LLM / opencode 适配器 / 请求头 / 会话循环都在位（它们与预设无关，见上一节）。
- 说「用 ComfyUI 出一张猫」→ 模型应先调 `skill(comfyui-mcp-ops)`，再走 validate → run(wait=false) → job(wait) → fetch_outputs
- 说「查一下 ComfyUI 的工作流 JSON 格式」→ 应加载 `comfyui-docs`
- 说「读一下我这个工作流里的说明」→ 应能 `list_workflow_notes`
- 说「本机 12GB 能跑 H3 视频吗」→ 应加载 `minimax-h3-docs` 并给出显存告警，而不是硬跑
- **说「帮我给一张赛博朋克城市夜景写提示词」** → 应先加载 `comfyui-prompt-craft`，输出**以代码块成品开头**（而不是先来一段"要写好提示词需要注意……"），代码块后只跟 ≤3 行说明
- **说「给一段 5 秒的雨天街头视频写提示词」** → 成品应是**英文**，且带 `integrated_multimodal_description:` / `overall_soundscape:` / `non_diegetic_music:` 三字段骨架（T2VA 无指令行）
- **【隐式触发·关键】说「把这张图改成赛博朋克风格，出图」**（**全程不提"提示词"**）→ 仍应加载 `comfyui-prompt-craft`，编辑提示词写成**祈使句**并以「保留 → 变更 → 再强调保留」组织
- **【隐式触发·关键】说「用 H3 生成一段雨夜街头的视频」**（**不提"提示词"**）→ 成品仍是**英文 + 三字段骨架**

> 🔍 **3 秒判合规**：回复是不是**以代码块开头**？如果开头是「要写好提示词，需要注意……」——即漏加载，直接告诉它「按提示词手册的契约重来」。

**文件管理（`comfyui-project-layout`）的三条验收：**

- 说「**帮我建一个动画项目**」→ 应加载 `comfyui-project-layout`，并在工作区生成 `projects/<slug>/` 的完整骨架（`00_dev` / `10_assets` / `20_pre` / `30_shots` / `40_editorial` / `90_deliver`）+ `project.json`
- 说「**帮我加一个镜头**」→ 应生成 `30_shots/<seq>/<shot>/` 下的 5 个环节目录；给它一个不合规的名字（如 `My Shot`）应当**被拒绝并说明格式**
- 说「**把这个文件重出一版**」（指向一个已存在的文件）→ 🔴 **必须先看到它跑 `safe-write.ps1`**，旧文件出现在**同目录的 `old/`** 里且带时间戳；随后应写 `.meta.json` 侧车。**如果它直接把文件覆盖了，就是违规。**

**视觉审查（`comfyui-review`）的三条验收：**

- 出一张图后**什么都不说**，等它自己收尾 → 🔴 **必须先看到它调 `read_image` 读产物**，再落盘 `60_review/` 下的审查报告与对比图。**如果它直接说"已完成"就把图给你了，就是违规。**
- 问它「**这张图哪里有问题**」 → 答复必须**指向画面里看得见的具体位置**（「招牌第 3 个字缺右边一竖」），出现「整体效果不错」「质量尚可」这类**没有落点的评价即为违规**
- 给一段**视频**让它审 → 报告里必须写明「基于 N 帧抽样、未逐帧、音频仅核对技术规格」；**如果它声称看了每一帧、或评价了音频内容，就是编的**

> 判断技能是否加载成功：模型回复里会体现手册内容（例如直接说出 `mcp__comfymcp__validate_workflow` 这类工具全名）。若它仍在猜工具名，说明 8 个 skill 没进技能目录 —— 见下节排错。

---

## 设计取舍（为什么是这样）

1. **不声明 `@deepseek-ai/dsh-mcp-client`。** ComfyUI 的 MCP 由 profile 层已有的全局连接器 `custom-comfymcp` 提供（serverName=`comfymcp` → 工具名 `mcp__comfymcp__*`）。宿主作用域的工具对所有 Agent 可见，本预设自动就能用。若在这里再声明一份，模型会看到**两套同功能工具（约 78 个）**，白白吃上下文 —— 本预设的卖点是"不用思考就知道怎么调"，不是"再挂一遍"。
   > 换机器时：要么在新机器上照 `%USERPROFILE%\.dsh\storages\mcp_connector.json` 里的 `custom-comfymcp` 记录配好连接器，要么在本补丁里加一行 `dsh-mcp-client`（写法见 `dsh-computer-use-win/cordis.patch.yml`）。
2. **知识库走 skill 而不是 RAG。** DSH 没有内置 RAG/知识库插件；`dsh-skill-filesystem` + `dsh-tool-skill` 是唯一的正规落点。skill 目录深度**只有一层**：`<root>/<name>/SKILL.md`。
3. **knowledge base 随 bundle 走。** `customSkillDirs` 用 `createRequire(new URL('package.json', baseUrl))` 锚定 profile 目录解析本包路径，不写死绝对路径 —— 同一手法见 `dsh-computer-use-win`。
4. **精简掉 plan-mode / goal / delegation / ralph 组。** 创作场景下这些会带来十几个额外工具，拖慢每一步的工具扫描。需要时见"可选扩展"。
5. **只做本地免费能力。** 不含 MiniMax H3 Max、Qwen Image 3.0 Pro 等付费路线的调用教学（知识库里只留一句"存在但不在本项目范围"）。

---

## 可选扩展

想加回批量并行出图，在 `cordis.patch.yml` 的 `plugins:` 末尾追加 delegation 组（照抄 `preset-standard`，注意 `isolate: {workflowEngine: true}` 必须带上）：

```yaml
          - id: delegation
            name: cordis:group
            group: true
            isolate:
              workflowEngine: true
            config:
              - id: tool-subagent-control
                name: '@deepseek-ai/dsh-tool-subagent-control'
              - id: tool-subagent
                name: '@deepseek-ai/dsh-tool-subagent'
                config:
                  provider: spawn
                  toolName: subagent
                  backgroundMode: continuable
```

想加计划模式，追加 `planning` 组（见 `preset-standard.patch.yml`）。

改完重新 `install_bundle` 覆盖安装，然后**再开一个新会话**验证。

---

## 排错

| 症状 | 处置 |
|---|---|
| 预设选择器里没有【ComfyUI 创作模式】 | 确认 `list_plugins` 里有 `preset-comfyui` 行；有行但选不到 → 该行激活失败，看它的 diagnostic |
| 现有会话里没变化 | 正常。必须新开会话 |
| 8 个 skill 一个都不出现 | `customSkillDirs` 的 `!!js` 没解析出来（bundle 没真正装进 profile 的 `node_modules`），或 skill 目录层级不对（必须是 `<skills>/<name>/SKILL.md`，不能嵌套更深） |
| skill 出现了但描述不对 | frontmatter 的 `name` / `description` 不合法会被**静默跳过**（模型目录不报逐条诊断）——用 `node _scratch\validate-skills.cjs comfyui-preset\skills` 自查 |
| MCP 工具不见了 | 是全局连接器的事，与预设无关。查 `mcp_connector_status`，或重写 `custom-comfymcp` 记录 |
| `comfy templates fetch` 超时 / WinError 10054 | 图库在线刷新被断。**改用本地模板目录**：`…\site-packages\comfyui_workflow_templates_json\templates\` |
| 脚本报 `cannot be run because it contained a "#requires" statement for Windows PowerShell 7.0` | 三个脚本都声明了 `#requires -Version 7`，**在 PowerShell 5.1 下失败关闭**（不碰任何文件，这是有意的）。处置：确认 profile 补丁里的 `pwshPath` 还在、且指向的 `pwsh.exe` 有效。**别删 `#requires`** —— 5.1 跑这些脚本会得到错误语义 |
| 脚本报「拒绝归档：目标是 old/ 目录本身」 | 这是保护，不是故障。`old/` 不该再被归档（否则会试图把目录移进它自己的子目录） |
| 模型找不到 `safe-write.ps1` | 脚本**不在** `comfyui-mcp-ops` 目录下，而在 `comfyui-project-layout` skill 的 `scripts/` 里。先加载那个 skill 拿到资源基底路径再拼 |
| markdown 渲染错乱（表格断掉等） | 跑 `node _scratch\validate-markdown.cjs comfyui-preset` 自查（表格被打断 / 围栏不配对 / 标题跳级 / 占位符残留） |

---

## 验证状态（2026-10-03 实测，逐条区分）

**已实测通过 ✅**

| 项 | 证据 |
|---|---|
| bundle 已装进 profile | `plugin_manager list_bundles` 有 `dsh-comfyui-preset`，`package.json` 记录为 `link:…/default-workspace/comfyui-preset` |
| 预设行已注册且**激活** | `list_plugins` → `include:preset-comfyui`，`enabled: true`，**`fiberPhase: "active"`**，与 4 个出厂预设状态一致 |
| 补丁方言合法 | `_scratch/validate-preset.cjs` 20 项断言全过（含 `!!js` 惰性标签、行 id 唯一性、与 package.json 一致性） |
| 16 个插件包名全部存在 | 逐个对 asar 清单核验，缺失 0 |
| 8 个 skill 层级与 frontmatter 合法 | `_scratch/validate-skills.cjs` 0 失败 0 提醒（含 name=kebab-case、与目录名一致、references 引用全部存在） |
| 知识库路径解析 | 用修正后的表达式语义对 **3 种 `baseUrl` 形态**（目录路径 / 目录 URL / 文件名路径）实测，**均能解析出 8 个 skill** |
| 手册里的 Qwen 2.1 配方 | 拿真图跑 `validate_workflow` → **`valid: true`、`error_count: 0`、`spends_credits: false`** |
| 全局 MCP 连接器在位 | `list_plugins` → `mcp-custom-comfymcp` 为 `active`，故 `mcp__comfymcp__*` 对新预设的会话可见 |

**未能实测（只能在你的新会话里验）⚠️**

- 预设的 **15 行插件真正挂载**。预设行本身 `active`，但插件树是**按会话**惰性挂载的（"Preset revisions are eagerly activated once and shared by their selecting Agents"），本会话已绑死 `cordis`，无法切换到新预设。
- 8 个 skill 是否真的出现在**模型技能目录**里。
- `customSkillDirs` 的 `!!js` 在真实 preset 作用域下的求值结果（我只能用等价语义离线复现，见上表）。

> 🔁 **建议：装完后重启一次 DSH 再新开会话。** 理由：`!!js` 表达式源码是在 bundle 补丁**应用时**被抓进 Loader 树的；本文件在我改完表达式后又重新 enable 过一次，但重启能 100% 确保读到的是修正后的版本。重启是一次性的，之后改工作区里的文件即生效（因为是 `link:`）。

---

## 重要：预设不需要（也无法）承载 DSH 的运行机制

这是最容易误解的一点。**预设只贡献「作用域内的工具 + 人设 + 策略」，DSH 的运行机制全在宿主层，选哪个预设都动不了。** 证据（2026-10-03 实测）：

**① 出厂 `preset-minimal` 只有 6 行** —— `persona` + `persistent-shell` 组（pty / terminal-bash / terminal-pwsh / persistent-bash / persistent-pwsh）。**没有 LLM、没有工具注册表、没有 fs/web、没有 skill**，而它能正常对话。所以"预设里少了某个运行必需插件"这件事在结构上不可能发生。

**② 宿主层有 203 行**（在 `~/.dsh/profiles/desktop/cordis.yml` 里位于所有预设块之外，预设块从 L720 才开始）：

| 类别 | 宿主行 |
|---|---|
| **模型链路** | `llm`(L14) · `agent-default-model`(L48，provider=`opencode-go` / model=`deepseek-v4.1-flash`) · `llm-pi-ai`(L74，含各 provider 与 `OPENCODE_GO_API_KEY`) · `llm-retry`(L56) |
| **会话与循环** | `session` · `session-title` · `agent` · `agent-loop` · `system-prompt` · `tools` |
| **能力底座** | `jobs` · `storage` · `sandbox` · `approval` · `credentials` · `web` |
| **opencode 相关** | `@opencode2dsh/dsh-plugin`（L1479-1480，**active**）· `dsh-opencode-go`(L1412，**active**) |

**③ 你提到的「opencode 请求头」不是一个独立插件，而是内置在两个适配器内部，且都在宿主层、当前 active：**

- `@opencode2dsh/dsh-plugin`（OpenCode Zen）：源码里有 `disguiseHeaders()` 与 `opencodeUserAgent()`，把请求伪装成 OpenCode CLI 的请求头（因为 Zen 的 API 有 User-Agent 门槛，注释写着 "the plain User-Agent gate stopped…"）。宿主行 `include:opencode2dsh` → `fiberPhase: "active"`。
- `dsh-opencode-go`：`adapter.d.ts` 明确写着 "Every request to the gateway carries two Harness-owned headers"（两个 Harness 归因头），并会覆盖 profile 中同名 header。宿主行 `include:opencode-go` → `fiberPhase: "active"`。

**结论：Chat / 模型 / 请求头 / 会话循环 都不依赖预设，本项目这个预设也影响不到它们。** 它的唯一职责是让「对话驱动 ComfyUI」这条路不用思考（人设触发规则 + 操作手册 + 知识库）。

> 🔴 **关于重启：这里曾有一条判断是错的，代价是预设重启后消失。**（2026-10-04 修正）
>
> 我原先写的是「快照落后一个 bundle 属正常现象，不是故障」——**前半句对，结论错**。
>
> 实测 + 读 `dsh-app-boot` 源码确认：`set_bundle` 两个方向**行为不对称**——
> **`enabled=false` 会把当前树写进 `cordis.yml`（此时没有本预设的行），
> 而 `enabled=true` 只热生效、不落盘**（实测 mtime 不变）。
>
> **后果**：任何一次 disable→enable 之后，运行中一切正常（`fiberPhase: active`），
> 但落盘快照**永久停在"禁用"状态** —— **一重启预设就没了**。
> 而 DSH 启动时正是从 `cordis.yml` + profile 补丁层建树。
> 这也解释了为什么另外 16 个 bundle 都在快照里、只有本预设不在：**它们从没被 toggle 过**。
>
> **正确做法**：不要把「禁用→启用」当重应用手段（INSTALL.md 已删掉这条）。
> 若预设从选择器消失，把 bundle 的 `- insert:` 块并入 profile 的 `cordis.patch.yml`
> —— profile 层**每次启动都会应用**。`tools/verify-preset.ps1` 的第 ⑤ 项会自动检出这个问题。

---

## 目录结构

```
comfyui-preset/
├── package.json                    # dsh.bundle.patch → ./cordis.patch.yml
├── cordis.patch.yml                # insert 一行 preset-comfyui 声明（15 行插件）
├── README.md                       # 本文件
└── skills/
    ├── comfyui-mcp-ops/            # ★ 操作手册：决策表 / 五步流程 / 两套成品配方 / 坑
    │   ├── SKILL.md
    │   └── references/local-inventory.md
    ├── comfyui-prompt-craft/       # ★ 提示词工程手册：交付契约 / 两套模板 / 反模式 / 自检
    │   └── SKILL.md
    ├── comfyui-review/             # ★ 视觉质检：8 维清单 / 判定分级 / 报告模板 / 红线
    │   ├── SKILL.md
    │   └── scripts/
    │       └── review.py           #   抽帧 frames / 前后对比 compare / 接触表 sheet
    ├── comfyui-project-layout/     # ★ 动画项目文件管理规范：目录 / 命名 / 归档 / 侧车
    │   ├── SKILL.md
    │   ├── references/             #   调研简报 + 依据出处（按需查阅）
    │   └── scripts/
    │       ├── new-project.ps1     #   建项目 / 序列 / 镜头（含命名校验）
    │       ├── safe-write.ps1      #   归档守卫：覆盖前把旧文件移进同目录 old/
    │       └── write-meta.ps1      #   写可复现侧车 .meta.json
    ├── comfyui-docs/               # docs.comfy.org 核心页快照 + 全站索引
    ├── qwen-image-2-1-docs/        # 架构 / 参数 / 提示词 / 图像编辑 / 显存 / 限制
    └── minimax-h3-docs/            # 能力 / 模板 / 参数与限制 / 提示词 / 音频 / 显存
```

镜头目录现在是 6 个环节：`10_ref` / `20_layout` / `30_key` / `40_video` / `50_audio` / **`60_review`**
（`60_review/` 放审查报告与前后对比图；编号按 10 递增，所以插新环节不用重编号 —— 这次插 `60_` 就是设计生效的实例）。

配套的自查脚本（在 DSH 工作区，不在本 bundle 内）：

- `_scratch/validate-preset.cjs comfyui-preset/cordis.patch.yml` —— 校验补丁方言、行 id 唯一性、`!!js` 标签、与 package.json 的一致性
- `_scratch/validate-skills.cjs comfyui-preset/skills` —— 校验 8 个 skill 的层级与 frontmatter
- `_scratch/validate-markdown.cjs comfyui-preset` —— 校验 35 个 markdown 的表格/围栏/标题结构
