---
name: comfyui-prompt-craft
description: 专业提示词工程手册（Qwen Image 2.1 图像 / MiniMax H3 视频）。**只要你要产出或修改提示词文本就加载**——包括用户没点名「提示词」的情况：出图、改图、抠图、上色、生成视频、批量改词、给工作流槽位填 prompt。含两套模型的成品结构模板、语言硬规则（图像中文 / 视频英文）、反模式清单与固定的交付格式。
whenToUse: 即将写出或修改任何 prompt 文本时；用户提到 写提示词 / prompt / 提示词优化 / 扩写 / 镜头 / 运镜 / 对白 / 音效描述 时
---

# 提示词工程手册

> **这份手册是「动手用的」。** 要查官方原文与依据，去 `qwen-image-2-1-docs` / `minimax-h3-docs` 各自的 `04-prompt-guide.md`。
> 目标只有一个：交付**可以直接粘进 ComfyUI 的成品提示词**，不是写作教学。

---

## 0. 交付契约 —— 本模式的说话方式（必须遵守）

写提示词时的输出固定为**三段**，顺序不变：

**① 成品** —— 一个代码块，里面就是可直接粘贴的提示词。**代码块外不要混入解释。**

**② 设计说明** —— **不超过 3 行**。只说「关键取舍」和「为什么」，不复述提示词内容、不讲原理。

**③ 变体**（用户要、或明显有用时）—— 每个变体同样是一个代码块成品 + 半行差异说明。

### 硬性禁止

- ❌ 输出「提示词写作教程」「基础概念讲解」
- ❌ 「你可以试试…」「建议再考虑…」这类含糊试探 —— **直接给判断**
- ❌ 一次抛出 3 个以上问题。最多问 **1 个**真正影响结果的关键问题，其余按合理默认值替你决定，并在设计说明里点一句
- ❌ 把提示词写成散文段落混在解释里
- ❌ 罗列「还可以加这些元素」的清单却不给成品

### 默认值（用户没说时直接采用）

| 项 | 默认 | 说明 |
|---|---|---|
| **语言** | **Qwen 图像 → 中文**；**H3 视频 → 英文** | 这条是硬规则，见 §2 / §3 |
| 分辨率 / 步数 / CFG | 按模型默认 | 见 §2.1 / §3.1；不要主动调 |
| 视频时长 / 帧数 | 5 秒 / 124 帧 | 12GB 显存下的现实档位 |

---

## 1. 通用原则（三条，别的都是推论）

**① 结构 > 堆砌。**
现代指令遵循模型吃的是**有逻辑的句子**，不是逗号堆形容词。
→ 先把「谁 / 在哪 / 做什么 / 什么状态」写成一句能读懂的话，再往上挂镜头、光照、风格。

**② 具体 > 抽象。**
「美丽的花」= 无效信息；「窗台上半开的白色山茶，花瓣边缘带一点焦褐」= 有效信息。
→ **每个形容词都必须能对应到画面里看得见、或声音里听得见的东西。** 做不到就删掉。

**③ 不要 SD1.5 时代的咒语。**
`masterpiece`、`best quality`、`8k`、`ultra detailed`、`(worst quality:1.4)`、`score_9` 这一类
对 **Qwen-Image 2.1 与 MiniMax H3 完全无效**（它们不是 CLIP 关键词模型）。写进去只会稀释真正的描述。

---

## 2. Qwen Image 2.1 —— 图像提示词

### 2.0 语言

**中文直接可用，而且是强项**（原生多语言 + 密集小字渲染）。
想要更细的细节表现时，可以写英文；但**不要中英混写在同一句里**。

### 2.1 文生图（T2I）

按这个顺序组织，缺哪段就跳过哪段：

```
[主体 + 外观细节] → [动作/姿态] → [环境/场景] → [光照与氛围] → [镜头/构图] → [风格/媒介] → [要渲染的文字]
```

**参数默认**：25 步 · cfg 1 · `euler` + `simple` · 1024 打底，往 2K 走。

**示例（成品，可直接用）**：

```text
雨夜的老式霓虹招牌，湿漉漉的柏油路面上倒映着扭曲的光带；招牌上用繁体字写着「深夜食堂」，旁边一行小字「营业中」。胶片颗粒感，低机位仰拍，青橙色调。
```

### 2.2 要渲染的文字 —— 必须加引号

模型强项是**把字真正画对**（海报、包装、UI mockup、信息图）。写法：

```text
A neon shop sign that reads "QWEN IMAGE 2.1", rainy night, reflections on wet pavement
```

- 要显示的字用**引号**包起来
- 用 `reads "..."` 这类动词**明确指出这是画面中的文字**，而不是普通描述
- 字多、字小、排版复杂时，把 **cfg 提到 2** 会更贴合 —— 代价是边缘偏锐

### 2.3 透明底图 —— 必须用官方固定话术

**"透明背景"不是参数开关，是提示词里的两句固定话。** 少了它们，即使 VAE 支持 4 通道也可能不给你 alpha：

```text
This is an RGBA image with transparency. <你的描述>. The image has alpha channel and the background is transparent.
```

### 2.4 图像编辑（I2I）—— 写指令句，不写描述句

❌ 描述句：`a girl standing in a sunset beach`
✅ 指令句：`Change the background to a sunset beach`

**多参考图的四段式结构**（官方示例的结构，值得直接套）：

```text
Keep the character and pose in <image1> unchanged, put this light blue denim shirt from <image2> on the character, preserve the original facial features, hair, body shape and pose
```

拆开就是：

1. **先声明要保留什么** —— `Keep ... in <image1> unchanged`
2. **再说明从哪张图取什么** —— `put this ... from <image2>`
3. **最后再强调一遍要保持的东西** —— `preserve the original ...`

> `<imageN>` 按 `image_1`、`image_2`… 的**槽位顺序**引用：
> `<image1>` 是被编辑的主图，`<image2>` 起是提供内容的参考图。

**编辑提速**：简单局部编辑（换个颜色、改个背景）**4–8 步**就够，不用 25 步。

### 2.5 局部编辑 —— 先标记，再在提示词里点名颜色

官方做法：在提供 `image_1` 的 `LoadImage` 节点右键 → **Open in Mask Editor** → 用 **Paint Pen** 涂出要改的区域 → **在提示词里点名这个颜色**：

```text
change the jacket in the red area
```

**机制**：Paint Pen 的笔迹落在**图像的 RGB 层而不是 mask 里**，标注本身成了参考图的一部分，模型是"看到图上有一块红"才理解你指哪里。
→ 标记要留在**想修改的区域内部**；如果标记色出现在输出里，就在提示词里同时说明你想要的颜色。

### 2.6 图像参数红线

- **cfg 1 时负向提示词完全无效** —— 别在 negative 上花任何力气
- 目标分辨率**远高于 2K 会损失提示词遵循度**（比如硬上 4K）

---

## 3. MiniMax H3 —— 视频提示词

### 3.0 语言（硬规则）

> **提示词正文必须用英文写。**
> 只有两类内容保留原文语言、且**逐字照抄**：
> ① **对白与歌词**（放进 `<d>` 标签）；② **画面上实际可见的文字**。

这条最容易写错，写中文正文 = 直接劣化结果。

### 3.1 固定结构（顺序不能变）

```text
<指令行，视模式而定 —— T2VA 没有这一行>

<空行>

integrated_multimodal_description: [Shot 1] ...

overall_soundscape: ...

non_diegetic_music: ...
```

**三个核心字段各自写什么：**

| 字段 | 内容 |
|---|---|
| `integrated_multimodal_description` | 沿时间线写**画面、动作、镜头、说话人、对白、歌唱、画内音频** |
| `overall_soundscape` | 概括**整条视频的环境音、物理动作声、非语言人声** |
| `non_diegetic_music` | **角色听不到、只有观众听得到**的背景音乐 |

**指令行按模式选，是固定句（一字不改）：**

| 模式 | 指令行 |
|---|---|
| **T2VA** | **没有** —— 直接以 `integrated_multimodal_description:` 开头 |
| **I2VA** | `For the target video, at 0.00 seconds into the target video, <Picture 1> (from [Shot 1]) is fully referenced.` |
| **FL2VA** | `How the reference pictures align with the target video — Picture 1 (from Shot 1) aligns with the 0.00-second mark of the target video; Picture 2 (from Shot N) aligns with the S.SS-second mark of the target video.` |
| **L2VA** | `How the reference pictures align with the target video — <Picture 1> (from [Shot N]) aligns with the S.SS-second mark of the target video.` |

> 指令行**必须是最终提示词的第一行**，后面跟**一个空行**再接核心字段。`S.SS` 恰好两位小数。

**参数默认**：24 fps 固定 · 5 秒 = **124 帧**（帧数吸附 17k+5 网格）· 基座 20 步 /
turbo LoRA 8 步（R2V 系列 4 步）· `res_multistep` + `simple` · **负向提示词完全无效**。

### 3.2 时间线怎么写

- **第一个镜头不加时间戳。** `[Shot 1]` 开头先交代**整体风格与初始构图**。
- 后续镜头用**严格递增**的切点时间，且必须落在时长以内：

```text
[Shot 2] At 00:03.500, the camera cuts to...
```

- 普通硬切用 `the camera cuts to` / `the shot cuts to` / `the shot transitions to` /
  `the shot changes to` / `the shot switches to`。
  **只有用户明确要求时**才用 cross-dissolve / fade / wipe。
- **一次切镜必须引入新信息**（主体、空间、状态、视角或时间）。
  **只是想改景别或轻微换角度 → 用运镜，不要切镜。**
- 官方常见风格词（`[Shot 1]` 开头用）：`Cinematic`、`live-action`、`2D-animated`、
  `3D CG`、`claymation`、`watercolor`、`vintage film`。

### 3.3 运镜 —— 三维度，但要写成句子

**运动类型 + 幅度 + 速度。** 幅度和速度**只在有意义时才写**（中等幅度、常速通常省略）。

| 维度 | 可用表达 |
|---|---|
| 运动类型 | `Zoom In/Out`（变焦）· `Push In/Pull Out`（推拉机身）· `Pan Left/Right`（摇）· `Truck Left/Right`（平移）· `Tilt Up/Down`（俯仰）· `Pedestal Up/Down`（升降）· `Arc Shot`（环绕）· `Tracking Shot`（跟拍）· `Static Shot`（固定）· `Shake Slightly/Strongly`（抖动）· `POV` · `Roll Clockwise/Counterclockwise`（滚转） |
| 幅度 | `with small amplitude` / `with large amplitude` |
| 速度 | `at slow speed` / `at fast speed` |

> ⚠️ **写成镜头里自然的英文动作，不要把标签堆在句尾。**

```text
The camera pushes in with small amplitude at slow speed toward the folded letter in her hands.
The camera pans right with large amplitude at fast speed, revealing the open doorway.
The camera holds a static shot as the runner exits the frame.
```

---

## 4. 反模式清单（写完先拿这个过一遍）

| 反模式 | 为什么错 | 改成 |
|---|---|---|
| `masterpiece, best quality, 8k, ultra detailed` | 对这两个模型无效，稀释信息 | 删掉，换成具体描述 |
| `(worst quality:1.4)` 之类加权负向 | Qwen cfg=1、H3 负向**完全无效** | 删掉 |
| 中文正文写给 H3 | 官方硬要求英文 | 译成英文；只对白/画面文字保留原文 |
| 用描述句做图像编辑 | 模型当成"生成新图" | 改写成祈使句 `Change ... / Remove ...` |
| 只想换景别却写切镜 | 无新信息的切镜 | 改用运镜 |
| 一次改多个变量 | 无法归因 | 定死种子，一次只改一个 |
| 提示词长到几百字还全是形容词 | 遵循度反而下降 | 砍到只剩可看见/可听见的信息 |
| 透明底没写官方那两句 | 拿不到 alpha | 补上 RGBA 模板句 |
| 要渲染的字没加引号 | 模型当普通描述 | 加引号 + `reads "..."` |
| 对白没放进 `<d>` 标签 | H3 认不出说话内容 | 用 `<d>` 包住并逐字保留原语言 |

---

## 5. 交付前自检（4 条，10 秒过一遍）

1. **语言对吗？** 图像=中文可；视频=**英文正文**，只有对白/画面文字保留原文。
2. **H3 的骨架对吗？** 指令行（T2VA 无）→ 空行 → 三个字段按序 → `[Shot 1]` 无时间戳。
3. **每句都能对应到看得见/听得见的东西吗？** 对不上就删。
4. **成品是一个可直接粘贴的代码块吗？** 不是就重排。

---

## 6. 更深的依据在哪（需要查证时）

| 要查什么 | 去哪 |
|---|---|
| Qwen 官方示例、PE 改写模型、Mask Editor 机制、cfg 与文字渲染的关系 | `qwen-image-2-1-docs` → `04-prompt-guide.md` |
| H3 官方两份提示词指南全文、说话人/对白/歌唱、R2V 全参考结构与引用标签、完整官方样例 | `minimax-h3-docs` → `04-prompt-guide.md` |
| 工具怎么调、工作流怎么跑、本机模型与配方 | `comfyui-mcp-ops` |
