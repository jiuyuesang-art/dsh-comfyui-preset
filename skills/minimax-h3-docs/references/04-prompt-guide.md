# 提示词指南（官方）

- **来源 URL**：
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide （ComfyUI 官方整理）
  - https://github.com/MiniMax-AI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md （MiniMax 官方，基座生成模式 T2VA / I2VA / FL2VA / L2VA）
  - https://github.com/MiniMax-AI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md （MiniMax 官方，全参考模式 R2V）
  - 两份指南的实际抓取走镜像：https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md 与 .../VIDEO_PROMPT_WRITING_GUIDE_ref_en.md
  - https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills （官方发布的 H3 skills，含提示词写作 skill）
- **抓取日期**：2026-10-03

---

## 0. 总原则

- **提示词用英文写**。只有**对白与歌词**（放在 `<d>` 标签内）以及**画面上实际可见的文字**保留原文语言，且**逐字照抄**。
- 提示词就是 H3 多模态训练成果的兑现处：**镜头、运镜、对白、音效全都在一个提示词块里**。
- 官方给的时间线切分惯例：**第一个镜头不加时间戳**，后续镜头用严格递增的切点时间，且必须落在视频时长以内：

```text
[Shot 2] At 00:03.500, the camera cuts to...
```

- 普通硬切用 `the camera cuts to` / `the shot cuts to` / `the shot transitions to` / `the shot changes to` / `the shot switches to`。**只有当用户明确要求时**才用 cross-dissolve / fade / wipe。
- 一次切镜应当引入关于主体、空间、状态、视角或时间的**新信息**；**如果只是想改变景别或轻微换角度，优先用运镜而不是切镜。**

---

## 1. 最终提示词的固定结构

### 1.1 第一部分：指令行（视模式而定）

- **T2VA**：**没有**图像对齐指令，**直接以三个核心字段开头**。
- **I2VA**：固定用这一句：

```text
For the target video, at 0.00 seconds into the target video, <Picture 1> (from [Shot 1]) is fully referenced.
```

- **FL2VA**：固定用这一句（`N` 是实际最后一个镜头的序号，`S.SS` 是有效视频时长，**恰好两位小数**）：

```text
How the reference pictures align with the target video — Picture 1 (from Shot 1) aligns with the 0.00-second mark of the target video; Picture 2 (from Shot N) aligns with the S.SS-second mark of the target video.
```

- **L2VA**：固定用这一句：

```text
How the reference pictures align with the target video — <Picture 1> (from [Shot N]) aligns with the S.SS-second mark of the target video.
```

> 指令行**必须是最终提示词的第一行**，后面跟**一个空行**再接核心字段。

### 1.2 第二部分：三个核心字段（顺序固定）

```text
integrated_multimodal_description: [Shot 1] ...

overall_soundscape: ...

non_diegetic_music: ...
```

| 字段 | 写什么 |
| --- | --- |
| `integrated_multimodal_description` | 沿时间线描述**画面、动作、镜头、说话人、对白、歌唱、以及画内音频（diegetic audio）** |
| `overall_soundscape` | 概括**整条视频的环境音、物理动作声、非语言人声** |
| `non_diegetic_music` | 描述**角色听不到、只有观众能听到**的背景音乐 |

### 1.3 时间线上怎么展开 `integrated_multimodal_description`

每个细节都应**对应到看得见或听得见的东西**：视觉风格、初始构图、主体外观与位置、场景与关键道具、动作与反应、镜头变化、说话语言、同步的画内声音。

**在 `[Shot 1]` 开头要先说明整体风格与初始构图。** 官方列出的常见风格词：`Cinematic`、`live-action`、`2D-animated`、`3D CG`、`claymation`、`watercolor`、`vintage film`。

```text
[Shot 1] Live-action, cinematic, a medium-wide shot frames...
```

- 关键帧任务：**风格从参考图推导**；T2VA：**从用户文本里选**。

### 1.4 运镜：运动类型 + 幅度 + 速度

完整运镜表达有三个维度：**运动类型**（怎么动）、**幅度**（构图变化范围）、**速度**（变化的节奏）。**只有当幅度和速度有意义时才写**；中等幅度和常速通常省略。

| 维度 | 可用表达 | 含义 |
| --- | --- | --- |
| 运动类型 | `Zoom In / Zoom Out` | 机位不动，焦距变化 |
| 运动类型 | `Push In / Pull Out` | 机身前推 / 后拉 |
| 运动类型 | `Pan Left / Pan Right` | 机位不动，镜头水平摇 |
| 运动类型 | `Truck Left / Truck Right` | 机身水平平移 |
| 运动类型 | `Tilt Up / Tilt Down` | 机位不动，镜头垂直摇 |
| 运动类型 | `Pedestal Up / Pedestal Down` | 整机上升 / 下降 |
| 运动类型 | `Arc Shot` | 绕主体弧线运动 |
| 运动类型 | `Tracking Shot` | 跟拍运动主体 |
| 运动类型 | `Static Shot` | 机位与镜头都不动 |
| 运动类型 | `Shake Slightly / Shake Strongly` | 轻微 / 强烈抖动 |
| 运动类型 | `POV` | 主体视角 |
| 运动类型 | `Roll Clockwise / Roll Counterclockwise` | 绕镜头轴顺 / 逆时针滚转 |
| 幅度 | `with small amplitude` / `with large amplitude` | 构图变化小 / 大 |
| 速度 | `at slow speed` / `at fast speed` | 慢 / 快 |

运镜要**写成镜头里自然的英文动作**，而不是把标签堆在句尾：

```text
The camera pushes in with small amplitude at slow speed toward the folded letter in her hands.
The camera pans right with large amplitude at fast speed, revealing the open doorway.
The camera holds a static shot as the runner exits the frame.
```

---

## 2. 四种基座模式怎么写

官方对四个模式的定位：

- **T2VA**：从文本构建完整的视听时间线。
- **I2VA**：T2VA 主体 + 首帧指令 + 一条**从首帧向前发展**的视觉路径。
- **FL2VA**：T2VA 主体 + 首尾帧指令 + 一条**从首帧连续走到尾帧**的路径。
- **L2VA**：T2VA 主体 + 尾帧指令 + 一条**从合理的前置状态收敛到尾帧**的路径。

### 2.1 I2VA：从图像出发向前发展

- `<Picture 1>` 是视频 **0.00 秒处的真实首帧**，属于 `[Shot 1]`。
- 描述应**先确立图里的风格、主体、构图、场景锚点**，再描述接下来的动作。
- **角色身份、服装、颜色、关键物体、空间关系应保持一致。**
- 推荐结构：**首帧锚定 → 动作起始 → 连续发展 → 结果或反应**。

### 2.2 FL2VA：描述首尾帧之间的路径

- Picture 1 是开场，Picture 2 是结尾。重点写**主体怎么移动、姿态怎么变、物体怎么被操作、构图怎么演化、场景或光线怎么过渡**。
- FL2VA **一般偏好单镜头**，以便模型能从首帧连续插值到尾帧。**只有在明确指定时才用多镜头。**
- **尾帧必须由视频末尾的最后一个 `[Shot N]` 抵达。**
- 推荐结构：**首帧状态 → 可观察的中间变化 → 差异逐步收窄 → 尾帧状态**。
- ⚠️ 正文**不要重复两段静态图像描述**，而要提供**连接两者的运动路径**。

### 2.3 L2VA：推断开场，落在那张图上

- `<Picture 1>` 是视频的**最后一帧**，属于最后的 `[Shot N]`，**它本身并不属于 Shot 1**。
- 从用户意图和尾帧**推断一个合理的早期状态**，然后描述角色、物体、镜头、场景如何逐步逼近参考图。
- 推荐结构：**合理的前置状态 → 明确的动作与过渡路径 → 最后一个镜头逐步收敛 → 尾帧落地**。

---

## 3. 说话人、对白与歌唱（所有模式通用）

- **稳定说话人 ID**：提示词里每一个嗓音都给一个 ID，如 `(S1)`、`(S2)`，**包括画外音与歌唱的声音**，并在其说话的**每个镜头**里重复该 ID。
- **ID 编号的是「说话人」而不是「主体」**：从不发声的角色**不分配 ID**；提示词里**第一个嗓音就是 `(S1)`**，即使其角色编号不同。
- 同时发声的说话人用**复合 ID**，如 `(S1,S2)`。
- **`<d>` 外面**放：识别性描述（身份特征）、说话人 ID、动作、以及**念白方式**。**`<d>` 里面**只放**语言标签 + 用户提供的台词本身**，且**逐字保留每一个词与标点，不翻译不改写**。

```text
The young woman with a quiet, breathy voice (S1) says: <d>[English] I get off at the next station.</d>
The two children (S1,S2) shout together, <d>[English] Wait for us!</d>
```

- 首次出现某个说话人时，要从视觉与音频上下文给出**足够建立稳定身份的信息**：角色类型、年龄、性别、是否在画内、音高、音色、语速、口音等。
- 对白写在**它被说出的那个镜头里**，与那个镜头的动作同一段。
- **画外音（voiceover）**：观众能听到但角色没有开口的台词，需要**精确短语** `says in an off-screen voiceover`，并在**每个画外音 `<d>` 块之后紧跟一句**说明对应画内角色的**嘴唇保持闭合**。

```text
The man (S1) says in an off-screen voiceover: <d>[English] I still remember that road.</d> while his lips remain completely closed.
```

- **跨切镜的台词/歌词**：在两个连接点都用 `<scenetrans>`，并明确说明音频**跨切镜延续**。可用 `continues seamlessly across the cut`、`continues uninterrupted into the next shot`、`carries over from the previous shot`、`remains audible across the transition`。
- **`<cutoff>`**：用于**被视频结尾截断**的语音。

---

## 4. 画面可见文字

- 任何**实际出现在画面上**的横幅、招牌、标签、字幕、霓虹字，都要用**英文双引号**包起来。
- **逐字保留原文与标点，不翻译**。

```text
A red neon sign reading "营业中" glows above the doorway.
```

- **引号是给印刷文字的，`<d>` 是给角色说的话的**——不要混用。要分别列出每个字符串。

---

## 5. 两个音频字段怎么写

| 字段 | 句数 | 写什么 | 不写什么 |
| --- | --- | --- | --- |
| `overall_soundscape` | **1–4 句**英文，一段连续文字 | 整条视频的**环境音、物理动作声、非语言人声**（风、雨、交通、脚步、布料声、撞击、呼吸、笑、喘） | **对白、歌唱、画内音乐（diegetic music）不属于这里**——它们已经在 `integrated_multimodal_description` 里 |
| `non_diegetic_music` | **1–3 句** | **角色听不到、只有观众听得到**的背景音乐；聚焦**配器、速度、节奏、力度变化** | 不要用抽象情绪词，不要解释配乐的情绪功能 |

- `overall_soundscape`：**只有当整条视频要求完全静音时**才用 `N/A`。
- `non_diegetic_music`：**没有这种音乐时**用 `N/A`。
- **角色能听到的**歌唱、乐器、收音机、电视、手机音乐属于 **diegetic（画内）事件**，应写进多模态描述里。
- **实操技巧（官方给的）**：如果一个安静的镜头回来却带了**你没要求的说话声**，就**把两个字段都显式写出来并重新生成**。

```text
overall_soundscape: Steady rain taps against the café windows while low room ambience continues underneath. The entrance bell rings once, followed by wet footsteps and the soft scrape of a chair.

non_diegetic_music: Sparse piano notes at a slow tempo, joined by sustained low strings that gradually increase in volume before fading out.
```

---

## 6. 全参考模式（R2V）的结构

全参考模式的改写输出由**六个 section 按序组成**：

| Section | 作用 |
| --- | --- |
| `subject_definitions` | 定义被引用的内容及其**引用标签** |
| `summary` | 概括**任务类型**、目标视频与主要引用关系 |
| `retention_analysis` | 描述被引用内容如何被**保留、迁移或复用** |
| `detailed_description` | 按**播放顺序**描述画面、动作、镜头、声音与对白 |
| `overall_soundscape` | 概括环境音与物理声 |
| `non_diegetic_music` | 描述只有观众听得到的背景音乐 |

> 与基座模式的主要字段差异：全参考模式的主字段叫 **`detailed_description`**（不是 `integrated_multimodal_description`）；**风格开场白写在 `[Shot 1]` 之前的一到两句英文里**；并且要在**首次出现处及其角色生效处**插入 `<Subject N>` / `<Picture N>` / `<Video N>` / `<Audio N>` 标签。

### 6.1 四种引用标签

| 标签 | 含义 |
| --- | --- |
| `<Subject N>` | 从参考素材中抽象出来的、可在目标视频中复用或修改的**可见内容** |
| `<Picture N>` | 用作**具体目标帧**或分镜规划锚点的参考图 |
| `<Video N>` | 提供**剪辑源、续写起点或整片时间结构**的参考视频 |
| `<Audio N>` | 被**复制或引用**的音频信号 |

- 一旦某份内容被分配了引用标签，它在 `subject_definitions`、`summary`、`retention_analysis`、`detailed_description` 及音频 section 里**含义始终不变**。
- `<Subject N>` 用于可复用的可见内容：人、动物、物体；场景、背景、环境；服装、道具、界面、视觉特效；风格、动作、表情、姿态。**它代表的是会在目标视频里被实际使用的内容单元，而不是源文件本身。** 一个 subject 可以由多个参考素材定义，一个参考素材也可以提供多个 subject。

```text
<Subject 1> is the young woman in <Picture 1>, with long dark hair, a blue cardigan, and a thin silver necklace.
<Subject 1> is the woman whose appearance comes from <Picture 1> and whose walking motion comes from <Video 1>.
```

- `<Picture N>` **单独成条**的条件：这张图**本身**就是某个镜头的首帧、关键帧、尾帧、被编辑的关键帧，或构图锚点。
  - 如果一张图**只用来定义**角色、场景、服装或风格，**不要**给它单独建条目，而是在对应的 `<Subject N>` 定义里引用它作为来源。
  - **关键坑**：**只在某个定义内部被引用的图片，不会被当作独立参考使用。** 参考图集（reference sheet）必须**有自己的 `<Picture N>` 条目**。
- `<Video N>` **专用于整片级关系**：剪辑原片、从原片结尾续写、引用原片的运镜/剪辑/节奏/时间结构。如果只是复用参考视频里的人物、物体、场景、动作或效果作为可见内容，那仍然属于 `<Subject N>`。
- `<Audio N>` 代表独立音频素材，或参考视频中**已启用的同步音轨**。常见用途：整体或部分复制音频信号、引用背景音乐风格、引用说话人音色与念白方式、使用原音频里的对白/歌词/音效、引用节拍/节奏/音频连续性。
- **`<Video N>` 与 `<Audio N>` 独立编号**：索引只表示该标签在**自己类别内**的顺序，**不编码两者之间的配对**。同一条参考视频完全可能对应 `<Video 1>` 和 `<Audio 2>`——**不同索引不妨碍它们来自同一个源素材**。
  - **一条普通参考视频不会仅仅因为文件里带声音就产生 `<Audio N>`。**
- `<Audio N>` 显式对应某个目标说话人时，**复用该说话人的全局 ID**：主体已定义则写 `<Subject N> (Sx)`，否则用稳定的嗓音描述后跟 `(Sx)`。**该 ID 来自目标视频的全局说话人顺序，不在音频定义里独立分配或重新编号。** 且**不要在 `retention_analysis` 里写 `(Sx)`**。

```text
<Audio 1> is the voice-timbre reference for <Subject 1> (S1).
```

### 6.2 `summary` 的任务类型前缀

用一段简短英文，以**方括号任务类型前缀**开头，多个关系用 ` + ` 组合，**不要重复同一类型**：

| 任务类型 | 何时使用 |
| --- | --- |
| `keyframe completion` | 图像作为目标视频的首帧、关键帧、尾帧、被编辑关键帧或其他具体帧锚点 |
| `reference generation` | 图像/视频/音频为角色、场景、风格、动作、运镜、分镜等提供生成指导，**但本身不作为具体帧、也不作为被剪辑或续写的源视频** |
| `video editing` | 直接修改一段已存在的源视频（编辑图片或在两张静帧之间生成**不属于**此类） |
| `video continuation` | 新内容从已有源视频继续、延长、恢复或转场 |
| `audio reuse` | 同一音频信号被整体或部分复用 |
| `audio reference` | 不直接复制音频信号，只引用其音乐风格、音色、对白或歌词内容、音效质感、节拍或连续性 |

- 示例：从源视频续写同时用一张图作尾帧 → `[video continuation + keyframe completion]`；编辑源视频同时保留其原声 → `[video editing + audio reuse]`。
- **光是存在视频或音频并不会自动产生对应任务类型。** 如果一条参考视频只提供运镜、剪辑或节奏，通常属于 `reference generation`。
- 编辑源视频时，**如果它的原声仍然可听**，也要用 `audio reuse`。续写源视频但**不直接复制音频信号**、新音频只延续原音轨的可听特征时，用 `audio reference`。
- **视频编辑任务**的 summary 在前缀之后以这句开头：`The target video is an edited version of <Video 1>.`
- **不要在 summary 里引入新的引用标签。**

### 6.3 `retention_analysis` 的关系标记

**可见内容**（`<Subject N>` / `<Picture N>` / `<Video N>`）：

| 标记 | 含义 |
| --- | --- |
| `fully_preserved` | 被引用内容的既定角色被**完整保留** |
| `partially_preserved` | 仍在使用，但**部分既定特征被改变或只部分保留** |
| `attribute_transfer` | 被引用特征**迁移到了另一个可识别的目标主体**上 |
| `weak_reference` | 只保留风格、类别、构图或氛围上的**宽泛相似** |

**音频**（`<Audio N>`）：

| 标记 | 含义 |
| --- | --- |
| `fully_copy` | 完整源音频成为目标视频**完整最终音轨** |
| `partially_copy` | 只复制部分时间线或选定音频层，或复制后增删替换了其他声音 |
| `reference` | 不直接复制信号；只引用音色、节奏、音乐风格、对白内容或声音质感 |
| `weak_reference` | 只保留类别或氛围上的宽泛相似 |

```text
<Subject 1> (appears in [Shot 1], [Shot 3]): fully_preserved - ...
<Picture 2> ([Shot 1] first frame): fully_preserved - ...
<Video 1> (cut and pacing structure): weak_reference - ...
<Audio 1>: fully_copy - <Audio 1> is reused 1:1 as the target video's complete final audio track.
<Audio 2>: reference - the target speaker follows <Audio 2>'s voice timbre and measured delivery without copying the original signal.
```

- 每个引用标签**一行**；**每个标记只能在该标签已于 `subject_definitions` 中定义的角色范围内选择**。
- **不要把目标视频里新增的动作、背景或情节事件当作参考保真度的损失。**

### 6.4 `detailed_description` 的篇幅

- 生成任务通常 **350–500 个英文词**。
- **对白密集**的内容**优先把完整口语时间线排进去**，而不是机械凑字数。
- **视频编辑**的描述**随源视频复杂度伸缩**，不必遵守生成任务的字数区间。
- **单镜头不自动意味着可以写短**——按各镜头的信息量分配细节。

### 6.5 直接复用的音频 vs 说话人 ID

- 当口播内容只是**被直接复用**的 BGM 或完整音轨里的一个提示，**并没有**具体的人、角色、旁白或其他独立发声源去「物理地说出它」时，**用 `<Audio N>` 作为可听来源，不要凭空发明一个 `(Sx)`**。
- 反之，如果确实有具体的人/角色/旁白在发声，就为它分配并复用 `(Sx)`。
- 直接复用参考音频里的对白、旁白或歌词时（或输入明确要求重演时），在 `<d>` 内**保留源词与原始语言**。**听不清的片段写 `[unclear]`，不要猜、不要改写。**
- 标点规范化到**表达句子所需的基础书面标点**（`,`、`.`、`?`、`!`）；**去掉重复波浪号、emoji、项目符号、重复或装饰性标点**。完整陈述句、疑问句、感叹句分别在 `</d>` 前以 `.`、`?`、`!` 收尾。
- **只引用音色、节奏、情绪或念白方式时，不要把参考音频里的原始对白带到目标视频里。**
- `(Sx)` **按目标视频中实际发声事件的顺序一次性分配**，并在 `detailed_description` 的每一次实际发声事件处复用。

### 6.6 `overall_soundscape` / `non_diegetic_music` 与参考音频

- 使用了参考音频时，**只在与其可听层相符的 section 里陈述复制/引用关系**：**环境音与音效放 `overall_soundscape`，只有观众能听的配乐放 `non_diegetic_music`**。
- 如果同一段音频同时提供两类内容，就在两个 section 里分别描述对应关系。
- **完整对白与歌词只写在 `detailed_description` 的 `<d>` 里，不要在这两个 section 里重复。**

```text
overall_soundscape: The copied ambience layer from <Audio 1> continues throughout the target video.
non_diegetic_music: <Audio 2> is directly reused as the complete audience-only score.
```

---

## 7. 官方提示词技能包

MiniMax 在 GitHub 上发布了可安装的 **H3 skills**，其中包含把上述指南打包成 agent 可用的提示词写作 skill：

- https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills

（这与本项目正在做的 DSH skill 是同类思路，但那是官方给 agent 用的提示词写作技能，不是 ComfyUI 使用文档。）

---

## 8. 完整示例（官方样例，可直接照此结构仿写）

### 8.1 T2VA

```text
integrated_multimodal_description: [Shot 1] Live-action, cinematic, a medium-wide shot frames a baker opening the shutters of a small street bakery before sunrise. The camera pushes in with small amplitude at slow speed as the middle-aged baker with a calm, slightly raspy voice (S1) places a fresh loaf on the wooden counter and says: <d>[English] First batch of the morning.</d> [Shot 2] At 00:05.000, the camera cuts to a close-up of steam rising from the sliced bread while the baker's final words carry over from the previous shot.

overall_soundscape: Wooden shutters scrape open over a quiet street as trays clink softly inside the bakery. The doorbell rings once, followed by light footsteps and the crisp sound of bread being sliced.

non_diegetic_music: A soft acoustic-guitar pattern at a moderate tempo, joined by sparse upright-bass notes and a gentle fade at the end.
```

### 8.2 I2VA

```text
For the target video, at 0.00 seconds into the target video, <Picture 1> (from [Shot 1]) is fully referenced.

integrated_multimodal_description: [Shot 1] Live-action, cinematic, the young woman shown in <Picture 1> remains beside the rain-covered train window, preserving her appearance, clothing, seat position, and the carriage layout. The camera trucks right with small amplitude at slow speed as she lifts her gaze from the folded letter toward the passing city lights. Her reflection moves across the glass while the quiet, breathy young woman (S1) says: <d>[English] I get off at the next station.</d> She folds the letter along its existing crease.

overall_soundscape: The train wheels produce a steady metallic rhythm beneath a low ventilation hum. Rain ticks against the window while paper rustles softly in her hands.

non_diegetic_music: Sustained cello notes at a slow tempo with widely spaced piano tones, gradually decreasing in volume.
```

### 8.3 FL2VA（八秒单镜头）

```text
How the reference pictures align with the target video — Picture 1 (from Shot 1) aligns with the 0.00-second mark of the target video; Picture 2 (from Shot 1) aligns with the 8.00-second mark of the target video.

integrated_multimodal_description: [Shot 1] Live-action, cinematic, a rain-soaked cyclist begins in the position and framing established by Picture 1, holding a closed black umbrella beside a silver bicycle. The camera pulls out with small amplitude at slow speed as she releases the bicycle handle, raises the umbrella above her shoulder, and presses the runner upward until the canopy opens. Water rolls from the expanding fabric while she steps beneath it, rotates the handle into the final angle, and settles into the pose, spacing, and composition established by Picture 2 at the end of the shot.

overall_soundscape: Rain falls steadily on the pavement, followed by the metallic click of the umbrella runner and the soft snap of the canopy opening. Water drips from the bicycle frame as distant traffic passes.

non_diegetic_music: N/A
```

### 8.4 L2VA（六秒单镜头）

```text
How the reference pictures align with the target video — <Picture 1> (from [Shot 1]) aligns with the 6.00-second mark of the target video.

integrated_multimodal_description: [Shot 1] Live-action, cinematic, a close shot begins with an intact drinking glass near the edge of a dark wooden table, while the same hand and sleeve visible in <Picture 1> approach from the right. The camera pushes in with small amplitude at slow speed as the fingertips strike the rim. The glass tips, falls, and hits the floor with a sharp impact; cracks spread through it as fragments slide outward. Toward the end, the moving pieces lose momentum and settle into the exact broken arrangement, hand position, camera angle, lighting, and final composition established by <Picture 1>.

overall_soundscape: Fingertips tap the glass before it scrapes across the tabletop, falls, and breaks with a sharp crash. Small fragments scatter and gradually stop sliding across the floor.

non_diegetic_music: A low electronic pulse at a slow tempo, ending immediately after the glass breaks.
```

---

## 9. ComfyUI 侧对提示词的两个额外机制

### 9.1 提示词嵌入（prompt embeddings）

来源：Comfy-Org/ComfyUI PR **#15697**。H3 提示词支持 ComfyUI 标准的 `embedding:` 语法。

- 把 embedding 文件放到 `ComfyUI/models/embeddings/`，在提示词里按名引用，例如 `embedding:my_embedding`。它会像其他 ComfyUI 模型一样被加载并混进文本条件。
- **Comfy-Org/MiniMax-H3 仓库的 `embeddings` 目录下有 10 个风格 embedding。** 官方文档明确说明这些文件**是非官方的**：由社区成员 silveroxides 通过 HF PR #50 贡献，**并非 Comfy-Org 或 MiniMax 出品**；原始文件在 `silveroxides/MiniMax-H3_tests` 仓库。
- **触发词 = 去掉扩展名的文件名。**

| Embedding | 效果（按名称） |
| --- | --- |
| `minimaxh3_art_is_explosion` | 爆发式艺术构图 |
| `minimaxh3_blooming_flowers` | 花朵绽放 |
| `minimaxh3_bullet_time` | 子弹时间 |
| `minimaxh3_dark_magic` | 黑魔法氛围 |
| `minimaxh3_fire_breath` | 吐息火焰 |
| `minimaxh3_four_seasons` | 四季转换 |
| `minimaxh3_kiss_camera` | 吻戏运镜 |
| `minimaxh3_spiral_ascent` | 螺旋上升 |
| `minimaxh3_storm_magic` | 风暴魔法 |
| `minimaxh3_truman_show` | 楚门的世界风格 |

### 9.2 R2V 参考图集（reference sheet）技巧

- 一张参考图可以同时容纳同一主体的**多个视角**，或一张分镜图的**多个分格**，提示词再**逐个分格**去指。
- 必须**给图集一个自己的 `<Picture N>` 条目**，而不是只在某个 `<Subject N>` 定义里引用它——**只在定义内部被引用的图片不会被当作独立参考使用**。
- 在该条目里描述这张图集：

```text
<Picture 2> is a character sheet with three panels: a portrait, a full front view, and a full back view of the woman
```

- 然后在镜头描述里指向其中一个分格：

```text
[Shot 2] the shot's keyframe corresponds to the full front view panel of <Picture 2>
```

- 好处：一张图集把多个视角塞进 R2V 节点「9 张参考图」的限额内，且每个镜头都能指明它要哪个视角。**给分格编号或加标签，方便提示词去指；图集上的印刷文字只保留这些标签。**

---

## 10. 多个说话人 + 音频参考时的已知失败模式（官方明说）

- 在**全参考（R2V）**提示词里，当把**两个或更多说话人**与**音频参考**配对时，**即使提示词文本和参考连接顺序都正确，H3 也可能把某个音频参考交给错误的说话人。**
- 官方给的缓解办法：
  1. **每个镜头只保留该镜头需要的参考**；
  2. 把台词**绑定到可见事件**，而不是绝对时间码——例如 `When the phone is at his ear, the man in the coat speaks`（绝对时间码是留给切点用的）；
  3. 如果台词仍然落到错误的说话人身上，**用语音工具生成这句台词，把它作为该说话人的音频参考提供**，并配上与片段相符的关系标记：整段成为视频完整最终音轨时用 `fully_copy`，只覆盖部分时间线时用 `partially_copy`。
