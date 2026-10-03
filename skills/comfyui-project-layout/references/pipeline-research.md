<!-- 本文件是 comfyui-project-layout 规范的调研依据，随 bundle 交付。 -->
<!-- 原始检索日期：2026-10-03。出处分级与检索失败说明见文末。 -->

# 动画 / VFX 项目文件管理与目录组织规范 · 调研简报

用途：为「AI 辅助动画制作（ComfyUI 生成图像/视频）的本地目录规范」提供依据。面向**个人二维/动漫风格创作者**，刻意区分「主干」与「只有几十人团队才需要的重装备」。

检索时间 2026-10-03。引擎：exa / tavily / multi，另用 web_fetch 直读官方文档页。

**记号说明**：`- [标题](URL) — 一句话` = 有出处；标「（一般做法，未找到权威出处）」= 检索未命中可靠来源，仅作经验陈述。

---

## 1. 层级结构：show → episode / sequence → shot，以及为什么 assets 与 shots 必须分两棵树

**主流层级（事实）**

- [Kitsu · Production Structure](https://kitsu.cg-wire.com/guides/production-structure) — 数据模型为 Production → Episode（可选，系列剧用）→ Sequence（把相关 shots 分组；非剧集作品直接挂在 production 下）→ Shot（"一段被拍摄/动画化的动作单元，是 shot-based 任务的容器"）；另一条平行分支是 Asset。
- [ftrack Glossary](https://help.ftrack-studio.backlight.co/hc/en-us/articles/13129833878039-ftrack-Glossary)（经搜索摘要，页面本身被 Cloudflare 挡）— 官方示例层级 `Project → Episode → Sequence → Shot → Tasks`。
- [ShotGrid 社区讨论](https://community.shotgridsoftware.com/t/linking-shots-to-episodes/10522) — 典型 VFX 工作流：Shots 组织进 Sequences，Assets 链接到 Shots；且"sequence 名会作为 shot 名的前缀"。
- [Blender Studio · Folder Structure Overview](https://studio.blender.org/tools/td-guide/folder_structure_overview) — `svn/pro/` 下 **assets/**（chars / props / sets / lib / maps / lgt / cam / fx / poses / nodes / scripts）与 **shots/**（`001_intro/010_0010/010_0010-anim.blend`）**平级并列两棵树**；sequence 目录带语义前缀如 `000_titles`、`900_animtest`、`990_promo`。
- [CGWire · CG Pipeline: A Proposal For Your File Hierarchy](https://blog.cg-wire.com/cg-pipeline-a-proposal-for-your-file-hierarchy/) — `working/{assets,shots}`，shots 下 `ep001/se001/sh001/{animation,fx,compositing}`，**并明确：没有 episode/chapter 时可以跳过 `ep001` 这一层**。
- [La Cuisine · An introduction to organizing project files](https://lacuisine.tech/an-introduction-to-organizing-project-files)（Les Fées Spéciales 技术博客，作者出身 Illumination Mac Guff）— 把项目切成两大块：**LIB**（asset 库：type → family → asset → department）与 **FILM**（shot：Sequence → Shot → department）。原话："assets are individual elements used one or more times in a shot"。

**sequence 与 shot 的边界（事实）**

- [Kitsu 文档](https://kitsu.cg-wire.com/guides/production-structure)：Sequence 是 **分组层**，Shot 是 **工作单元**。
- [Aspect · VFX Plate Naming Conventions](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery) — 讲得最透："**Editorial tracks clips… VFX tracks shots**"；shot 是被 bidding / 分配 / 评审 / 版本化 / 批准 / 交付 / conform 的单位，它可能来自多个源 clip、可能含不入剪的 handles、可能之后被拆分、可能最终没进正片却仍要可追溯 —— 所以 **shot ID 既不能等于源 clip 名，也不能只是一个剪辑事件号**。规则：**shot 号在父分组内唯一，shot 全名在全项目唯一**。
- 编号间隔：Blender Studio 的 sequence 用 3 位、shot 用 4 位，**创建时按 10 递增**；Aspect 同样推荐 `0010 / 0020 / 0030`，理由是"剪辑后来插一镜就变成 0015，比改名一整条 sequence 便宜得多"。
- 日式二维动画的对应词不同：现场用的是 **カット（cut）** 而非 shot，上面套 **シーン（scene）**，再上面是 **話数（episode）**；[日本におけるテレビアニメの作り方](http://www1.tcue.ac.jp/home1/takamatsu/106259/sotsuron.html) 里有"1 カット の中で大きな変化がある場合は何コマものイラストによって一つのカットが説明される"的用法。

**为什么必须分两棵树（事实 + 推论）**：assets 被多个 shot 复用、生命周期跨整部片子（La Cuisine；Blender Studio 的 `svn/pro/assets/lib`、`poses`、`maps` 就是共享库）；shot 是一次性工作单元，会被拆、被并、被砍（Aspect）。因此方向是**单向引用**：shot 引用 asset，asset 不引用 shot。唯一的例外是"某镜专用变体"——CGWire 的做法是在 shot 目录内再开一个 `assets/` 子目录（`shots/.../sh001/assets/rabbit/modeling`），Blender Studio 则在 shot 内放 `published/`。

**结论 / 建议固化**：建 `<project>/assets/`（chars/props/sets/lib）与 `<project>/shots/`（按 sequence 分组、每组按 shot 分目录）两棵平级树，**shot 只准单向引用 asset**；个人项目可省掉 episode 层，但 sequence 与 shot 两层必须保留，且编号一律按 10 递增。

---

## 2. 命名规范：完整镜头文件名长什么样

**真实格式示例（均来自公开文档）**

1. `DIL_S13_P042_Animation_Main_v07.blend` — [La Cuisine](https://lacuisine.tech/an-introduction-to-organizing-project-files)。路径 `myProject/DIL/S13/P042/Animation/DIL_S13_P042_Animation_Main_v07.blend`。字段：`DIL`=片名代号 / `S13`=sequence 13 / `P042`=shot 42（P 为法语 Plan）/ `Animation`=部门 / `Main`=tag / `v07`=版本。
2. `140_0010-anim.blend` — [Blender Studio · Naming Conventions](https://studio.blender.org/tools/naming-conventions/introduction)。路径 `svn/pro/shots/140_credits/140_0010/140_0010-anim.blend`。`140`=sequence（3 位）/ `0010`=shot（4 位）/ `anim`=task。
3. `AGM_104_TCC_067_0010_PL01_v001.1001.exr` — [Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery)。`AGM`=show / `104`=episode / `TCC`=sequence / `067`=scene / `0010`=shot / `PL01`=plate 号 / `v001`=版本 / `.1001`=**帧号** / `.exr`=扩展名。
4. asset 侧对照：`LIB_chars_main_Tomoe_shad_high_v05.blend`（La Cuisine）、`char-gabby-rigging.blend`、`char-gabby-shading-v001.mp4`（Blender Studio）。

**工具侧的通用模板（事实）**

- [PostMicroTools Shot Naming](https://www.postmicrotools.com/shotnamer) 内置四套 preset：feature `SEQ_SHOT_TASK_vNNN`、episodic `SHOW_EP_SEQ_SHOT_TASK_vNNN`、commercial `PROJECT_DESC_vNN_DATE`、Netflix-style 简化版。
- [Blender Studio](https://studio.blender.org/tools/naming-conventions/introduction) 的正式模板：`{show_prefix:optional}-{type:only for assets}-{name}.{variant:optional}-{task}-v{version:optional}_{version_info:optional}.{extension}`。

**分隔符为什么这样定（事实）**

- 下划线分**字段**；点号**留给帧号与扩展名**；连字符留给**字段内部**（如双段 task 名）。Aspect 明确："dots are usually reserved for the frame number and extension… hyphens can work, but mixing hyphens and underscores casually makes parsing harder"；Blender Studio："Underscores are allowed as spacing, dashes to separate items"。
- 空格必须避免：会破坏命令行工具、渲染农场提交与 URL 编码路径（Aspect、PostMicroTools）。
- 大小写要全项目统一，否则 `PL01` / `pl01` 会在某些存储/OS 上产生重复文件（Aspect）。Blender Studio 更狠：**"No caps, no gaps"**（全小写、无空格），并禁特殊字符。
- 非 ASCII（é ö à ñ）会让脚本炸掉（La Cuisine）。

**零填充（zero-pad）为什么是硬要求（事实）**

- 不填充时按字典序排：`render.1.exr → render.10.exr → render.11.exr → render.2.exr`（[La Cuisine](https://lacuisine.tech/an-introduction-to-organizing-project-files) 原文举例）。
- PostMicroTools："Without it, alphabetical sorting puts shot 10 before shot 2 (SH10 < SH2)"；4 位填充让文件浏览器、Nuke、Deadline 对顺序达成一致。
- 建议位数：shot 4 位（`0080`）、version 3 位（`v012`）"covers almost any show"（PostMicroTools）；帧号 4 位（`1001`）常见，长序列用 6 位（Aspect）。

**两条反直觉但重要的纪律（事实）**

- **别用数字前缀给文件夹排序**：`1_Layout / 2_Animation / 5_Lighting` 一旦中途插入新部门就会全盘重编号，且 Python 对象名不能以数字开头（[La Cuisine](https://lacuisine.tech/an-introduction-to-organizing-project-files)）。
- **长名字优于短名字**：`DIL_S01_P0001_Animation-Crowd_Render_v03.0101.exr` 好过 `render.0101.exr`。原则："A file name should provide all the necessary information to identify the file without opening it."（同上）

**结论 / 建议固化**：统一为 `项目_集_场_镜_任务_版本.扩展名`（如 `myanime_ep01_sq0010_sh0020_anim_v003.png`），全小写、只用下划线分字段、点号只给帧号与扩展名、所有数字零填充（shot 4 位 / 版本 3 位）、字段顺序固定**由宽到窄**、禁止空格与非 ASCII。

---

## 3. 版本管理：v001 递增 vs 覆盖

**为什么严禁覆盖（事实）**

- [Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery)：**"Don't allow silent overwrites in shared destinations."** 命名问题全部在同一时刻爆发——两个文件落进同一目录而没人能说出谁取代谁；一次 re-pull 盖掉了好 plate；conform 时对不上。并给出保留旧版本的理由："Storage is cheaper than rediscovering why a vendor's comp no longer lines up."
- [ArcLoop · AI 动画文件命名规则](https://arcloop.ai/handbook/ja-JP/ai-anime-file-naming-conventions)（厂商手册，实践性来源）："内容变了就升版本，不要复用同一个名字"，否则唯一一份 approved take 会被后续测试静默替换；并点名 `scene04_final.mp4 → scene04_final_new.mp4 → scene04_final_revised_real.mp4` 这条典型的死亡螺旋。
- 软件版本领域的权威类比：[Semantic Versioning 2.0.0](https://semver.org) 规则 3 ——"Once a versioned package has been released, the contents of that version MUST NOT be modified. Any modifications MUST be released as a new version."
- 版本号还要说清"改的是哪个东西"：**plate version / comp version / review package version / tracking status 是四个独立命名空间**，各自递增（Aspect 给了对照表）。

**WIP 与 publish / approved 怎么区分（事实）**

- **目录分离派**：[CAVE Academy](https://caveacademy.com/wiki/pipeline/vfx-pipeline/vfx-project-file-structure/vfx-sequence-directory/)（页面被 Cloudflare 挡，取自搜索摘要）——每个 asset / sequence 下分 `wip`（个人进行中，**不得向下游传递**）、`versions`（提交评审的版本）、`published`（可交给下游部门）。
- **目录分离派（另一版）**：[Blender Studio](https://studio.blender.org/tools/naming-conventions/svn-folder-structure) 用 `pre`（沙盒，可以乱）/ `pro`（必须严格结构化）/ `dev`（早期开发与测试），asset 目录内再分 `blend` 文件 + `published/` + `maps/`。
- **后缀分离派**：ArcLoop 建议状态词表保持小集合 —— `draft / select / review / approved / final / rejected / archive`，直接在文件名尾部加状态。
- **混合版**：Blender Studio 明确把 `v001` 限定给 **renders / exports**，工作文件（work files）**不带版本号**，因为版本历史由 SVN 承担。**这一点个人创作者无法照搬**（没有 SVN），所以工作文件也要带 `vNNN`——这是有意偏离，属于合理简化。

**`_latest` 软链接的惯例（部分事实）**

- [Prism Pipeline · Project Settings](http://prism-pipeline.com/docs/latest/general/settings/project/) 提供 **"master version"**：每个 product 除编号版本外多一个 `master` 版本（通常是最新版的副本，但版本号被替换成 `master`），下游场景文件引用它，master 更新后下游自动指向新内容 —— 官方称之为 **"Push Workflow"**（禁用即 "Pull Workflow"）。Blender Studio 的 `shared/` 与 `render` 本身也是**符号链接**（分别指向网络盘 / Syncthing 同步目录、渲染农场输出）。至于字面量 `_latest` 这个名字，**未找到权威出处**（一般做法，未找到权威出处）。

**结论 / 建议固化**：内容一变就 `vNNN+1`，**永不复用旧文件名**；工作文件放 `work/`（带 `vNNN`，因为个人没有 VCS），下游只读 `publish/`（只放 approved 过的版本）；状态用固定小词表后缀（`_wip` / `_review` / `_approved` / `_final`）而不是靠记忆，`final` 只留给通过检查的交付物。

---

## 4. 归档与旧版本处理：要改一版旧文件怎么办

**常见做法与利弊（多数有出处）**

| 做法 | 出处 | 利 | 弊 |
|---|---|---|---|
| 旧版本原地保留，只新增 `vN+1` | [Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery) | 可回溯、可 conform、零思考成本 | 目录会变长；需要定期清理策略 |
| `_archive/` 子目录下移旧件 | [Blender Studio shared 目录](https://studio.blender.org/tools/naming-conventions/shared-folder-structure) 里真实存在 `export/_archive/gold-edit-v001_storyboard.mp4` | 主目录保持干净，旧件仍可查 | 需要一条"何时下移"的规则 |
| `wip / versions / published` 三分离 | [CAVE Academy](https://caveacademy.com/wiki/pipeline/vfx-pipeline/vfx-project-file-structure/vfx-asset-directory/) | 语义明确，下游只能看 published | 三层目录对小项目偏重 |
| 工具化归档（分析后批量删/移已发布版本） | [AYON Project Archival Tool](https://help.ayon.app/en/help/articles/7924402-project-archival-tool)（"100 versions of a render → 只留若干"） | 可规模化，能回收磁盘 | 需要专门的 pipeline 工具 |
| 状态标记 `superseded` 而不动文件；或做事后 3-2-1 备份 | [Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery) 的 tracking status 命名空间；[AnimationTech](https://animationtech.tv/knowledge/data-archiving-guide.html)（3 份副本 / 2 种介质 / 1 份异地） | 前者保留血缘无需搬运，后者抗硬件故障 | 前者依赖一个表格；备份与版本管理是两件事，不能互相替代 |
| `_old` / `_backup` / `.trash` | — | 直觉、零成本 | **未找到权威出处**；三者语义模糊、无回收策略、容易变成永久垃圾（一般做法，未找到权威出处） |

**"要改一版旧文件"的正确姿势（事实）**

- 不要原地改老版本：从 archive/旧版本**复制出来升版本号再改**，让旧版本保持"当时的真相"（Aspect 的版本语义 + SemVer 规则 3）。
- 老版本可以标记 `superseded`（Aspect），但文件留着，等保留策略到期。
- 会被长期复用的旧产物（比如某镜的 clean plate），应该从 shot 目录里提升成 **asset**（La Cuisine 的 LIB 概念正好承接这件事）。

**结论 / 建议固化**：删旧版本这件事**不做**；需要改旧稿时从 `_archive/` 取出、另存为 `vN+1` 再改；`_old` / `_backup` 这类命名一律禁止，只用 `_archive/` 一个归档位置；另外单独执行 3-2-1 备份。

---

## 5. 二维动画特有环节：絵コンテ → レイアウト → 原画 → 動画 → 仕上げ → 撮影

**官方流水线顺序（事实）**

- [東映アニメーション · 製作工程について](https://corp.toei-anim.co.jp/ja/company/animation_production.html) 给出的顺序：企画 → シナリオ → **絵コンテ → 原画 → 色指定 → 動画 → 背景 → 彩色 → CG → 特殊効果 → 撮影** → 録音・編集。其中 **撮影 = "彩色した動画と背景、CGをコンピューター上でひとつの絵に合成して映像にする"** ——也就是中文语境的"合成/合成摄影"，**不是实拍**。
- [AREA JAPAN · 第3回：プロダクション](https://area.autodesk.jp/column/trend_tech/animation/03-production)（Autodesk 官方专栏）把 レイアウト 单列并说明其职责：决定 カメラ位置/高度/アングル/レンズ、角色在画面中的大小与朝向、背景信息量、角色在做什么、カメラワーク；再往下 原画（"動きの要"、海外称 key animation）→ 動画（中割 + 原画 cleanup）→ 彩色（色彩設計 → 色指定 → ペイント/仕上げ）→ 背景美術。该文还给出关键工具：原画/動画 用 Clip Studio Paint、OpenToonz；彩色用 CSP/Photoshop；背景用 Procreate/CSP/PS/AI；**撮影 业界最常用 After Effects**。
- [厚生労働省 資料（PDF）](https://www.mhlw.go.jp/content/11901000/001152417.pdf)（搜索摘要可见正文）界定 2D アニメ 的「制作」= **"シナリオ・絵コンテから撮影に至るまでの工程"**，以 原画・動画 的作画工程为中心；并指出 音響（アフレコ・劇伴・効果音）通常作为**独立的「音響製作」**处理 —— 这对目录规划有意义：**声音不该塞进 shot 目录**。
- 另外两份资料的章节/框图顺序也印证同一条链：[文化庁 ガイドブック（PDF，搜索摘要）](https://www.bunka.go.jp/seisaku/bunka_gyosei/kibankyoka/kenshukai/pdf/94028601_02.pdf) 为 絵コンテ・キャラクターデザイン・その他設定 → **レイアウト・ラフ原画(第1原画)、原画** → 動画；[アニメノタネ 制作概要資料（PDF）](http://animenotane.jp/2024/wp-content/uploads/download/productionoverview/animenotane2024_open_Productionoverview01.pdf) 把 **レイアウト / 原画 / 美術・背景 / CG / 撮影** 并列。

**建议的任务目录映射**

```
shots/<seq>/<shot>/
  layout/     # レイアウト：构图、camera、背景指示
  key/        # 原画（key animation）：作画の要
  inbetween/  # 動画：中割 + cleanup
  paint/      # 仕上げ/彩色：色指定表 + 着色済み素材
  bg/         # 背景美術（原図 → 原図整理 → 背景）
  comp/       # 撮影：AE 合成工程 + 输出
  gen/        # 【AI 补充】生成原料与 run 归档，见第 8 节
```

**中文语境里"分镜"通常指什么（关键澄清）**

- **默认指 storyboard**：[分鏡 · 維基百科](https://zh.wikipedia.org/wiki/%E5%88%86%E9%8F%A1)："分鏡或分鏡腳本，**又称故事板**（storyboard），是指…以故事圖格的方式來說明影像的構成，將連續畫面以一次運鏡為單位作分解，並且標註運鏡方式、時間長度、對白、特效等。"
- **但"文字分镜 / 分镜头脚本"实际是 shot list**：中文教学与实务里常以表格形式出现，栏目为 **镜号、景别、镜头运动、画面内容描述、对白**（[一品威客 · 从故事板到动态分镜的完整规划流程](https://www.epwk.com/meijie/322359.html)），本质是把剧本翻译成镜头语言的**镜头表**。
- 教材语境：[《动画分镜头概述》](https://www.tup.com.cn/upload/books/yz/099751-01.pdf)（人民邮电出版社样章）把"分镜头设计"归入**前期设计**阶段，与角色设计、场景设计、道具设计并列。

**结论 / 建议固化**：按 `layout / key / inbetween / paint / bg / comp` 六个任务子目录排 shot，中文文档里统一写"**分镜（storyboard，絵コンテ）**"与"**镜头表（shot list）**"两个不同的词，绝不混用"分镜"一词；音频不进 shot 目录。

---

## 6. 剪辑与交付：editorial / edit / deliver 放什么

**事实**

- [Blender Studio · Shared Folder Structure](https://studio.blender.org/tools/naming-conventions/shared-folder-structure) 的 `shared/editorial/` 结构：`audio/`、`deliver/`（Final approved render of film）、`export/`（Exports of edit in progress，内含 `_archive/`）、`footage/`（拍摄期生成的渲染预览）。另有 `svn/edit/` 放剪辑工程 `.blend`，其下也各自有 `audio / deliver / export / footage`。
- [Blender Studio · Folder Structure Overview](https://studio.blender.org/tools/td-guide/folder_structure_overview) 里 `svn/edit/export/prod_code-v001.mp4` 是"编辑成片的导出"，`svn/edit/footage/SQ01/SH01/SH01-anim/Sh01-anim-v001.blend` 是"用于剪辑的镜头渲染"。
- [La Cuisine](https://lacuisine.tech/an-introduction-to-organizing-project-files) 的 `EDIT/` 文件夹四件套值得直接抄：① 带版本的剪辑工程文件；② 对应版本的导出影片；③ **`EDL/`** 子目录存 EDL/XML（把剪辑时间导出给其他环节）；④ **`current/`** 子目录——每次有人出 playblast，就往这里拷一份，**剪辑软件永远读 `current/`，于是打开剪辑工程看到的永远是所有镜头的最新版**。这是全篇最有复用价值的一个技巧。
- 音频/字幕/交付清单一般不在"目录规范"里定死，而在**交付规范（delivery spec）**里逐项列出：例如 [Roku 的 scripted media delivery specifications](https://developer.roku.com/dev/docs/acquisitions-specs) 有 "Master audio deliverables" 表格；[Grammy P&E Guidebook（PDF）](https://media.grammy.net/uploads/2026/05/PE_Guidebook_241016.pdf) 强调交付物应"能重建最终混音或复用原始录音"；[BBC Studios Content Delivery Book（PDF）](https://www.bbcstudios.com/media/6914/contentdeliverybook.pdf) 有专门的 "Audio Split Stem Manifest" 章节。音频交付目录的一个现成模板见 [Soundfreak Studios](https://soundfreakstudios.com/stem-deliverables-folder-generator)：Dolby Atmos / 5.1 / Stereo / Web mix / Printmasters / **DX、MX、FX、M&E** / QC reports / session documents。
- 交付侧要有一张 **delivery matrix**：每行一个实际文件或资产组，含交付物名与内部 ID、目的地（客户评审 / Reels / 平台）、规格（[Aeliavision · Delivery Guide](https://aeliavision.com/delivery-guide/)）。
- 帧号起点：多数 VFX pipeline 从 **1001** 起（避开 0、给 handles 留空间、被评审与合成工具广泛支持），也有用 `0001`、源帧号或时间线帧号的；**关键是全片统一，且同一 plate version 的帧起不能偷偷变**（[Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery)）。

**结论 / 建议固化**：`edit/` 放剪辑工程 + `edit/export/` 放进展导出 + `edit/current/`（供剪辑读取各镜最新预览）+ `edit/edl/`（OTIO/EDL/XML）；`deliver/` **只放已批准的成片**，音频与字幕按 `deliver/<平台>/<交付物类型>/` 分开放，并在 `deliver/delivery_manifest.md` 里逐条登记（文件名 / 规格 / 目的地 / 日期）。

---

## 7. 工具侧的通行做法与可直接抄的公开模板

- [Kitsu（CGWire，开源）](https://kitsu.cg-wire.com/guides/production-structure) — 数据模型：Department / Production / Episode / Sequence / Shot / Asset + task type / task status；自有 [文件层级提案](https://blog.cg-wire.com/cg-pipeline-a-proposal-for-your-file-hierarchy/)（`working` vs `export` 两个状态目录 + 全小写无特殊字符路径）。**推荐个人先抄它，因为文档最完整且开源。**
- [ftrack](https://help.ftrack-studio.backlight.co/hc/en-us/articles/13129833878039-ftrack-Glossary) — `Project → Episode → Sequence → Shot → Tasks`。
- ShotGrid / Autodesk Flow Production Tracking — [官方社区](https://community.shotgridsoftware.com/t/linking-shots-to-episodes/10522) 确认 Shots 进 Sequences、Assets 链接到 Shots、sequence 名作 shot 名前缀；其 Toolkit 用**路径模板**驱动落盘，例如 [Filesystem Configuration Reference](https://developers.shotgridsoftware.com/82ff76f7/)（SG Developer）里的 `sequences/{Shot}/work/{Shot}.v{version}.ma` —— "模板 + 字段"这个思路可以直接借来描述自己的命名规则。
- [Prism Pipeline · Project Settings](http://prism-pipeline.com/docs/latest/general/settings/project/) — **folder structure templates 可编辑（支持 Python 表达式）**、`Version Padding` 统一版本位数、Episodes 开关、`master version`（push workflow）、publish 时备份 scenefile、scenefile locking、项目设置存 `\00_Pipeline\pipeline.json`。另外 Prism 有 **ComfyUI 插件**（Prism Pro），说明 AI 生成已被纳入传统 pipeline。
- [AYON · Project Anatomy](https://help.ayon.app/en/help/articles/3815114-project-anatomy) — 目录结构由 admin 在 "Project Anatomy" 里定义；[About AYON Pipeline](https://help.ayon.app/en/help/articles/7070980-about-ayon-pipeline)："所有发布文件都存进基于 asset / shot / sequence 的特定目录"；发布走 Validate →（extract）→ Integrate 流程，并有 [cleanup 插件](https://github.com/ynput/ayon-core/blob/3f549a0ecf926d432265b27bfaf52fe5cffa38c3/client/ayon_core/plugins/publish/cleanup.py) 清理 staging 目录。
- [OpenTimelineIO（ASWF）](https://opentimelineio.readthedocs.io/en/latest/tutorials/architecture.html) — **不是目录规范，是剪辑信息的交换格式/API**："an open source library for the interchange of editorial information"，可理解为"带 API 的现代 EDL"。结构：`Timeline` → `tracks`(Stack) → `Track` → `Clip` / `Gap` / `Stack` / `Transition`；Clip 通过 `media_reference` 指向素材，用 `available_range` 与 `source_range` 描述可用区间与入剪区间。对个人的价值：**它可以充当机器可读的"镜头表"**，把剪辑时间线导出成下游能读的数据。
- [Blender Studio Tools 文档](https://studio.blender.org/tools/td-guide/folder_structure_overview) — 公开、完整、且配了 `setup_assistant.py` 可自动生成目录树（另见 [Pipeline Setup](https://studio.blender.org/tools/pipeline-overview/quick-start/setup) 的部署说明），是**最接近"可以直接抄的模板"**的一份。
- [cgwire/awesome-cg-vfx-pipeline](https://github.com/cgwire/awesome-cg-vfx-pipeline) — 开源 pipeline 技术清单（DCC / 2D / 3D / 渲染 / 素材管理等），找现成工具时当索引。
- **AI × 传统 pipeline 的交汇点**：[MovieLabs/comfyui-movielabs-util](https://github.com/MovieLabs/comfyui-movielabs-util) — MovieLabs 官方的 ComfyUI 自定义节点，把资产发布到其本体并对接 ShotGrid，实现了**大量 validation check、自动版本号、自动建目录、命名规范校验**以符合制作要求。这直接印证了第 8 节的思路在工业界已经落地。

**结论 / 建议固化**：目录树直接以 Blender Studio 的公开文档为蓝本（assets/shots 双树 + editorial 四件套），命名规则用"模板 + 字段"描述（照抄 ShotGrid Toolkit 的 template 表达方式），并用一个 OTIO 或 CSV 文件作为镜头表的唯一事实来源。

---

## 8. AI 生成特有的补充：为了可复现，一张图之外还必须存什么

**ComfyUI 自身会存什么（事实）**

- [ComfyUI 官方文档 · Workflow Metadata](https://docs.comfy.org/development/api-development/workflow-metadata)：保存输出文件时可以把生成它的 workflow **存进文件本身**——"You can think of this as saving a generated image together with its recipe"，用于重新打开恢复工作流、分享、自动化检查设置。
- [ComfyUI 官方文档 · SaveImage](https://docs.comfy.org/built-in-nodes/SaveImage)：把图像写成 PNG 并**可以嵌入 workflow** 到 PNG 元数据。
- 第三方拆解（[Numonic · PNG Metadata vs. Workflow JSON](https://www.numonic.ai/blog/png-metadata-vs-workflow-json-a-persistence-guide)、[AICheck365](https://www.aicheck365.com/en/platforms/stable-diffusion)）指出：默认 `SaveImage` 会往 PNG 的 `tEXt` 块里塞**两个**东西 —— `prompt`（**API 格式的执行图 JSON，含解析后的实际取值**）与 `workflow`（完整节点图）。
- **坑（务必记住）**：[ComfyUI Discussion #1124](https://github.com/Comfy-Org/ComfyUI/discussions/1124) —— batch 生成时，一批图共享同一份 prompt/workflow 元数据，里面只有**初始 seed**；单独某张图的实际 seed 可能并不单独存。所以"我看中了第 77 张"这种情况，光靠 PNG 元数据可能复现不出那一张。

**模型 / LoRA 的标识（事实）**

- 文件名会重名、会被改名，**内容 hash 才唯一**。[Civitai Developer · ModelHash](https://developer.civitai.com/orchestration/reference/operations/InvokeModelHashStepTemplate) 计算的是 SHA256 / AutoV1 / AutoV2 / AutoV3 / Blake3 / CRC32；[Civitai · Model versions](https://developer.civitai.com/site/reference/model-versions) 说明每个 model version 有自己的 `baseModel`、文件与 **AIR 标识**。→ 归档时记 hash（尤其 AutoV2 那 10 位），不要只记文件名。

**ML 侧可借用的"可复现归档"通行做法（事实）**

- **Model Cards**：[Model Cards for Model Reporting（arXiv 1810.03993）](https://arxiv.org/pdf/1810.03993v2.pdf) 提出用结构化文档说明模型；[Hugging Face 文档](https://huggingface.co/docs/hub/main/en/model-cards) 把它落地为"仓库里的 `README.md` + 元数据"（另有 [Annotated Model Card Template](https://huggingface.co/docs/hub/main/en/model-card-annotated)），并称 model cards 对 **discoverability、reproducibility、sharing** 是 essential。
- **Datasheets for Datasets**：[CACM 版](https://cacm.acm.org/research/datasheets-for-datasets/) 提出用"数据表"文档化数据集的动机、构成、采集过程与推荐用途；Google 的 [Data Cards Playbook](https://sites.research.google/datacardsplaybook/) 是同一思路的实操化。
- **MLflow 的 run / artifact 约定（最值得直接照搬的结构）**：[MLflow Tracking](https://mlflow.org/docs/latest/ml/tracking/) 以 **run** 为组织单位，记录 parameters、metrics、code versions、output files；[Artifact Stores](https://mlflow.org/docs/latest/self-hosting/architecture/artifact-store/) 把**元数据（parameters/metrics/tags）与大数据（模型权重、PNG、Parquet）分存两处**，每次 run 记录 `artifact_uri` 可事后回溯，删除 run **不会自动删 artifact**（需显式 `mlflow gc`）；[ML Model Registry](https://mlflow.org/docs/latest/ml/model-registry/) 提供 lineage（哪个 experiment/run 产出的模型）、versioning、aliasing。
- 综述可参考 [Management of Machine Learning Lifecycle Artifacts（SIGMOD Record）](https://sigmodrecord.org/publications/sigmodRecord/2212/pdfs/04_Surveys_Schlegel.pdf) —— 把 artifacts 列举为 datasets、features、models、hyperparameters、metrics、software、configurations、logs，目标是 comparability / reproducibility / traceability。
- 硬件与显存：ML 生态里没有强制的"硬件指纹"字段，把 GPU / 驱动 / CUDA / PyTorch 版本写进 run 的参数文件是常见做法，但**未找到权威出处**（一般做法，未找到权威出处）。

**建议的 per-shot 生成归档结构（综合上述）**

```
shots/<seq>/<shot>/gen/
  run_20261003_142530_v001/          # 一次生成 = 一个 run 目录（照 MLflow run）
    out/                             # 成图/成片（PNG 内含 ComfyUI 嵌入元数据）
    workflow_api.json                # API 格式执行图（含解析后的实际取值）
    workflow_ui.json                 # 可拖回 ComfyUI 的完整节点图
    params.json                      # prompt / negative / seed / steps / cfg /
                                     # sampler / scheduler / 分辨率 / batch /
                                     # 每张图的实际 seed（batch 场景必填）
    models.json                      # 每个 checkpoint / LoRA / VAE / ControlNet
                                     # 的 文件名 + hash(AutoV2/SHA256) + 来源 URL
    refs/                            # 参考图、ControlNet 输入、pose/depth 图
    notes.md                         # 这一版想解决什么、为什么被否
  selected -> run_20261003_142530_v001   # 被选中的那一版（软链接或文本指针）
```

**结论 / 建议固化**：一张成图不算归档 —— **"图 + workflow JSON + params.json + models.json（含 hash）"四件套齐了才算**；每次生成尝试建一个独立 `run_*` 目录、绝不覆盖；prompt 与 seed 一律进 `params.json` 而不进文件名（文件名只保留标识性字段）；被选中的版本用指针（`selected`）指向，而不是把文件改名成 `final`。

---

## 个人创作者的最小可行子集（15 条，按重要性排序）

1. **assets 与 shots 两棵平级树**，shot 只单向引用 asset，绝不让 asset 依赖某个 shot。
2. **永不覆盖**：只要文件内容变了，就另存为 `vNNN+1`；旧文件永远留着。
3. **每次 AI 生成 = 一个独立 `run_*` 目录**，包含图 + workflow JSON + params.json + models.json 四件套。
4. **`params.json` 必须记全**：prompt / negative prompt / seed / steps / cfg / sampler / scheduler / 分辨率 / batch size，且 batch 场景要为每张图单独记实际 seed。
5. **`models.json` 记 hash 而不只记文件名**（checkpoint、LoRA、VAE、ControlNet 的 SHA256 或 AutoV2）。
6. **文件名格式统一**：`项目_集_场_镜_任务_版本.扩展名`，全小写、只用下划线分字段、点号只给帧号与扩展名，**禁止空格**。
7. **所有数字零填充**：shot 4 位（`0020`）、版本 3 位（`v003`）、序列帧帧号 4 位（`1001`，也可是 `0001`，但全项目统一）。
8. **shot 编号按 10 递增**（`0010 / 0020 / 0030`），给"剪辑中途插一镜"留出空间，避免全盘改名。
9. **`work/` 与 `publish/` 分离**：下游（剪辑、交付）只准读 `publish/`，`publish/` 只准放检查通过的版本。
10. **状态用固定小词表后缀**（`_wip` / `_review` / `_approved` / `_final`），`final` 只给已交付物；禁止 `final2`、`new`、`real`、`good` 这类词。
11. **建一个镜头表**（`shots.csv` 或 OTIO 文件）作为"这个项目有哪些 shot"的唯一事实来源，文件名只是它的投影。
12. **`edit/current/` 技巧**：各镜最新预览统一拷进一个目录，剪辑工程只读它，于是每次打开剪辑都是最新状态。
13. **`deliver/` 只放已批准成片**，音频、字幕、各平台版本分目录，并配一份 `delivery_manifest.md` 逐条登记。
14. **旧版本一律进 `_archive/`**，不许出现 `_old` / `_backup` / `.trash`；另外独立执行 3-2-1 备份（3 份副本、2 种介质、1 份异地）。
15. **目录结构用脚本生成**（照 Blender Studio 的 `setup_assistant.py` 思路写个自己的小脚本），而不是每个新镜头手动建文件夹 —— 规范只有被工具强制才活得下来。

---

## 检索说明与未解决问题

- 命中权威出处的问题：**1、2、3、5、6、7**（各有官方文档 / 官方站点 / 标准组织页面）。只有"一般做法"或厂商手册级来源的：**4**（归档与旧版本处理，除 `_archive/`、wip/versions/published、AYON 归档工具外，`_old` / `_backup` / `.trash` 的惯例未找到权威出处）；**8** 的硬件/驱动版本记录部分。
- 未能读到全文的页面：CAVE Academy 的 VFX 目录页、ftrack Glossary 页（均为 Cloudflare 403），内容取自搜索引擎摘要；MovieLabs 的 Image Sequence Naming PDF（`movielabs.com/prodtech/sdw/vfx/ETC_ImageSequenceNaming_v1.0-063020_FINAL.pdf`）与若干部委/出版社 PDF 因抓取工具不支持 `application/pdf` 只取到搜索摘要；zh.wikipedia 因 DNS 解析到非公网地址无法直抓，内容取自搜索索引摘要。
- 明确未验证：`_latest` 软链接这个**具体名字**的行业惯例（Prism 的 `master` 版本、Blender Studio 的 symlink 是被证实的近似物）。
