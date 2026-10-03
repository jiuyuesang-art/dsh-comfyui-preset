# 音频能力

- **来源 URL**：
  - https://www.minimax.io/blog/minimax-h3 （官方博客）
  - https://huggingface.co/MiniMaxAI/MiniMax-H3 （官方模型卡，经镜像 https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/README.md）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3 （采样步数与音频收敛）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide （提示词侧音频控制）
  - https://blog.comfy.org/p/minimax-h3-day-0-support-in-comfyui （ComfyUI 官方博客）
- **抓取日期**：2026-10-03

---

## 1. 核心结论：音频不是后处理

官方模型卡与 ComfyUI 文档都反复强调这一点：

- 官方博客：**"Audio is generated with the video in the same pass, in stereo, not bolted on afterward."**
- ComfyUI 文档：**"voice, sound effects, and music are modeled together in a single forward pass instead of being layered on afterward."**
- ComfyUI 官方博客：**"Every audio output is native stereo."**

官方预训练范式里明确写：

> With jointly generated audio, all audio output is native stereo
> Text-to-audio
> No separation between voice, sound effects, and music — all jointly modeled

也就是说：**语音、音效、音乐不再分域建模**，音频是一个联合建模的对象。

## 2. 官方音频规格

| 项 | 值 | 来源 |
| --- | --- | --- |
| 输出音频 | **32 kHz 立体声**（stereo） | 官方模型卡 |
| 声道处理 | H3-AudioVAE **左右声道共用同一套 encoder/decoder**，各声道独立处理后再合并 | 官方模型卡 |
| latent 时间率 | 每个声道把 32 kHz 音频压成时间率 **40 Hz** 的 latent token 序列 | 官方模型卡 |
| 音频 VAE 文件 | `minimax_h3_audio_vae_fp32.safetensors`，**约 605 MB**（fp32） | Comfy-Org 仓库 |
| 输出封装 | 生成结果是把视频与音频**放在一个 MP4** 里同步输出 | ComfyUI 文档 |
| 对话语言 | **稳定支持 11 种**：阿拉伯语、中文、英语、法语、德语、意大利语、日语、韩语、葡萄牙语、俄语、西班牙语；其他语言亦有不同程度支持 | 官方模型卡 |

> 音频 VAE 只有 fp32 一个版本是官方发布的（Comfy-Org 仓库里 `minimax_h3_audio_vae_fp32.safetensors` 是唯一的音频 VAE 文件）。

## 3. 音频在采样过程中怎么表现（ComfyUI 官方文档，很重要）

- **音频比画面收敛得晚。**
- 视频与音频在**一趟里联合去噪**，所以**一条调度同时驱动两者**；音频在画面已经不再变化的步数上**仍在继续改善**。
- **语音与音色收敛得最晚**：在 **8 步**时它们是**整个输出里最弱的部分**；**12 步及以上音轨才保持可用**。

> 实践含义：如果你打算用 8 步 turbo LoRA 换速度，**要接受音轨质量是最大代价**（官方也用词 "with slightly lower audio and motion quality"）。

## 4. 怎么控制音频：靠提示词，不靠音频参数

**本次抓取的所有官方页面里，H3 没有任何「音频专属参数」**（没有音量、混音比例、音频步数之类的旋钮）。音频内容完全由提示词的两个字段 + 多模态描述里的画内声音决定。

### 4.1 三个音频归属地（必须分清）

| 内容 | 写在哪里 |
| --- | --- |
| **对白、歌唱、画内音乐（diegetic music）** | `integrated_multimodal_description`（全参考模式：`detailed_description`） |
| **环境音、物理动作声、非语言人声** | `overall_soundscape`（1–4 句） |
| **只有观众听得到的配乐** | `non_diegetic_music`（1–3 句） |

- 判别口径：**角色能听到的**歌唱、乐器、收音机、电视、手机音乐都是 **diegetic（画内）事件** → 写进多模态描述，**不是** `non_diegetic_music`。
- `non_diegetic_music` 的定义就是「**角色听不到、只有观众听得到**」的背景音乐。
- 写 `non_diegetic_music` 时聚焦**配器、速度、节奏、力度变化**，不要用抽象情绪词，也不要解释配乐的情绪功能。
- 边界值：`overall_soundscape` 用 `N/A` **仅当整条视频要求完全静音**；`non_diegetic_music` 在**没有这种音乐时**用 `N/A`。

### 4.2 对白/音效/环境音的具体写法

**对白**（所有模式通用规则）：

- 每个嗓音给**稳定说话人 ID**，如 `(S1)`、`(S2)`，**包括画外音与歌唱的声音**；ID 在每次发声的镜头里重复。
- **识别性描述、ID、动作、念白方式写在 `<d>` 外面；`<d>` 里面只放语言标签 + 台词本身**，逐字保留不翻译。
- 首次出现说话人时给出足够建立身份的信息：**角色类型、年龄、性别、是否画内、音高、音色、语速、口音**。
- **画外音**需精确短语 `says in an off-screen voiceover`，并紧跟一句说明画内角色**嘴唇保持闭合**。
- **跨切镜的台词**：两端都用 `<scenetrans>` 并说明音频跨切延续；被结尾截断时用 `<cutoff>`。
- 同时发声用复合 ID `(S1,S2)`；从不发声的角色**不给 ID**。

**音效与环境音**：`overall_soundscape` 用 1–4 句英文一段连续文字，覆盖**风、雨、交通、脚步、布料移动、撞击、呼吸、笑声、喘息**这类环境音、物理动作声与非语言人声。

**音乐**：`non_diegetic_music` 用 1–3 句描述配器、速度、节奏与力度变化。

### 4.3 实用技巧（官方给的）

- **如果安静的镜头回来却带了没要求的说话声**：把 `overall_soundscape` 与 `non_diegetic_music` **两个字段都显式写出来并重新生成**。
- **负向提示词对音频同样无效**（H3 走 `BasicGuider`，`cfg` = 1，没有负向分支）。想说「不要有旁白」，要改成正面描述该镜头里实际存在什么声音。详见 `03-parameters-limits.md` 第 5 节。

## 5. 音频参考（R2V / 全参考模式）

这是 H3 音频能力里最强的一块：**可以把音频当参考喂进去**。

### 5.1 数量与时长限制

- 独立参考音频：**最多 3 段**，每段 **2–15 秒**，**总时长 ≤ 15 秒**。
- 参考视频：最多 3 段，**每段可自带音轨**（也就是说音频也可以跟着参考视频进来）。
- 跨所有输入类型的**文件总数上限 12**。

### 5.2 四种音频关系标记

在全参考模式的 `retention_analysis` 里为每个 `<Audio N>` 选择**恰好一个**标记：

| 标记 | 含义 |
| --- | --- |
| `fully_copy` | 完整源音频成为目标视频的**完整最终音轨**（1:1 使用） |
| `partially_copy` | 只复制**部分时间线或选定音频层**，或复制后**增删替换**了其他声音 |
| `reference` | **不直接复制信号**；只引用**音色、节奏、音乐风格、对白内容或声音质感** |
| `weak_reference` | 只保留**类别或氛围**上的宽泛相似 |

- **标记必须与音频在目标视频中实际扮演的角色相符。**
- 官方给的正例：

```text
<Audio 1>: fully_copy - <Audio 1> is reused 1:1 as the target video's complete final audio track.
<Audio 2>: reference - the target speaker follows <Audio 2>'s voice timbre and measured delivery without copying the original signal.
```

### 5.3 音频参考的典型用途（官方列举）

- 整体或部分复制音频信号
- 引用背景音乐风格
- 引用说话人的**音色与念白方式**
- 使用原音频里的**对白、歌词或音效**
- 引用**节拍、节奏或音频连续性**

### 5.4 与参考音频配合时的两个陷阱（官方明说）

1. **一个 `<Audio N>` 显式对应某个目标说话人时，要复用该说话人的全局 ID**（`<Subject N> (Sx)`，或稳定嗓音描述 + `(Sx)`）；**ID 来自目标视频的全局说话人顺序，不在音频定义里独立分配**；并且**不要在 `retention_analysis` 里写 `(Sx)`**。
2. **多个说话人 + 音频参考时，H3 可能把音频参考交给错误的说话人**，即使提示词文本与连接顺序都正确。缓解办法见 `04-prompt-guide.md` 第 10 节：每个镜头只带该镜头需要的参考、把台词绑定到**可见事件**而非绝对时间码、必要时用语音工具生成该说话人的音频参考再喂进来。

### 5.5 直接复用的音频里有人声时

- 当口播内容只是**被直接复用的 BGM 或完整音轨里的一个提示**，且**没有**具体的人/角色/旁白去「物理说出它」时：**用 `<Audio N>` 标识可听来源，不要凭空发明一个 `(Sx)`**。
- 反之，真的有具体发声源，就为它分配并复用 `(Sx)`。
- 直接复用参考音频里的对白/旁白/歌词（或输入明确要求重演）时，`<d>` 内**保留源词与原始语言**；**听不清写 `[unclear]`，不要猜不要改写**；标点规范化，去掉装饰性标点与 emoji。

## 6. 音频与 FastH3

- FastH3 **复用 H3 的 audio VAE**，所以音频输出格式与基座一致。
- FastH3 的代价明确包含**音频保真度**："FastH3 trades some motion and audio fidelity for speed"。
- FastH3 的 `MiniMaxH3SigmaShift` 里 **`shift_audio` = 3**（与基座一致），`shift_video` 才从 12 降到 10。
- FastH3 的 VSA 稀疏注意力把 **text 与 audio 保持为 dense**（不稀疏化），这解释了为什么稀疏化没有直接压垮音轨。

## 7. 音频相关的工程坑

- **稀疏注意力节点**：ComfyUI 的 `Model Sparse Attention` 的 `sink_conditioning` 在 H3 上**必须保持默认值 `exact_kv_and_rows`**，它会**保持打包的 text / audio / reference 行精确**，并让**生成的 audio query 行保持 dense**，这样稀疏路径才不会劣化音轨。
- **latent noise mask 支持音频**：per-token noise mask 同时覆盖 **video 与 audio latent**；音频 mask 对齐到**整个 latent 帧**（视频 mask 对齐到 2×2 latent patch 网格）。可用来只重生成音轨的某一段。
- **Add Guide 支持音频锚定**：`MiniMaxH3AddGuide` 的 `audio` 输入会把音轨锚在同一个 frame index 上，并裁到视频剩余时长；提供音频时要接 `audio_vae`。
