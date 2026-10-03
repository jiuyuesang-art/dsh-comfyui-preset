# 能力边界与已知问题

- **来源 URL**：
  - https://www.minimax.io/blog/minimax-h3 （MiniMax 官方博客，含官方自述的不足与未来计划）
  - https://huggingface.co/MiniMaxAI/MiniMax-H3 （官方模型卡，经镜像 https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/README.md）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3 （ComfyUI 官方文档，采样与后端坑）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-prompt-guide （官方明说的失败模式）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fastvideo （FastH3 的能力裁剪）
  - https://haoailab.com/blogs/fasth3-preview/ 与 https://hf-mirror.com/FastVideo/FastVideo-FastH3-8-Step-V2/raw/main/README.md （FastH3 官方自述限制）
- **抓取日期**：2026-10-03

---

## 1. 官方自述的「还做不好」的事

MiniMax 官方博客在 "Our Vision & What's Next" 一节直接列了 H3 的短板：

1. **多模态理解仍有很大提升空间** —— 官方说「强多模态理解是高质量生成的基础」，下一代 H 系列计划整合 M 系列模型的能力。
2. **当前模型规模对若干能力仍有提升空间** —— 官方明说 scaling 是明确的前进方向。
3. **某些场景下视觉细节仍可改进** —— 官方会继续推向更高分辨率和更强视觉保真度。

技术报告当时还未发布（官方说 "We'll be sharing the full H3 Technical Report soon"）。

## 2. 本地开源版本的能力裁剪（这是最容易被误期待的部分）

| 缺失的能力 | 影响 | 来源 |
| --- | --- | --- |
| **H3-Context-IR 未开源** | 官方的提示词预处理/编排系统拿不到，而官方说它**对最终输出质量至关重要**。本地要自己按 Prompting Guidance 写结构化提示词。**不按官方结构写提示词，质量会明显掉。** | 官方模型卡 |
| **H3-Regenerate-2K 未开源** | **本地开源权重只能出 768p**，2K 只能走官方 API | 官方模型卡 |
| **原生稀疏注意力未开源** | 官方训练时用了 native sparse attention，但「初始开源版本只提供 full attention 推理」，稀疏实现官方称后续单独发布 | 官方模型卡 |
| **Prompt Embeddings 文件是非官方的** | Comfy-Org 仓库里那 10 个风格 embedding **由社区成员贡献，非 Comfy-Org 或 MiniMax 出品**，效果无官方背书 | ComfyUI 文档 |
| **Sage Attention 质量退化** | 用 Sage Attention 可能出现**片段末尾形变**或**画面文字乱码**（INT8 注意力量化丢了 H3 末层集中在少数通道的 attention-key 信号） | ComfyUI 文档 |
| **Comfy Kitchen attention 与 int8-convrot 冲突** | 模板自带的 int8-convrot 检查点**会让采样以对齐错误崩溃**（issue #15529），**必须保持默认注意力**；要修 INT8 伪影得换 bf16（更吃显存） | ComfyUI 文档 |

## 3. 官方明说的失败模式（逐条照录，按类别）

### 3.1 口型与说话人归属

- **音频参考可能被交给错误的说话人**。官方原文：在全参考（R2V）提示词里把**两个或更多说话人**与**音频参考**配对时，**H3 can hand an audio reference to the wrong speaker even when the prompt text and the reference connection order are both correct**（提示词文本与参考连接顺序都正确也会出错）。
  - 缓解：每个镜头只保留该镜头需要的参考；把台词绑定到**可见事件**（如 `When the phone is at his ear, the man in the coat speaks`）而不是绝对时间码；仍不行就用语音工具生成该说话人的音频参考再喂入。
- **画外音需要显式防穿帮**：用 `says in an off-screen voiceover` 之后**必须紧跟一句说明画内角色嘴唇保持闭合**——官方把它列为规则，说明这是个会出错的点。
- **安静镜头冒出没要求的说话声**：官方给的实操办法是**把 `overall_soundscape` 与 `non_diegetic_music` 两个字段都显式写出来并重新生成**。

### 3.2 文字与画面文字

- **INT8 注意力会让画面文字乱码**（"garbled on-screen text"），同时伴随片段末尾形变。官方给的修法是换 bf16 检查点 + Comfy Kitchen attention，但那需要更多显存。
- **文字渲染是官方宣传的强项**：官方博客把 "accurate text and brand rendering" 列为 H3 擅长项，并说 H3-In-context Regeneration 能恢复传统超分「只能猜」的**小字与细节**。但请注意——**这一条优势建立在 2K 重生成链路（未开源）上**，本地 768p 能拿到多少是另一回事。
- **画面文字写法有硬规则**：必须用英文双引号、逐字保留原文与标点、**不翻译**；且必须与 `<d>` 对白标签区分开。

### 3.3 长镜头与长片段

- **注意力开销随片段长度快速上升**（ComfyUI 文档原话："Attention cost grows quickly with clip length"）。这就是需要稀疏注意力的原因。
- **多步历史不跟着 latent 走**：把调度拆给两个采样器（例如基座 + latent 上采样后的第二个采样器）时，**第二个采样器的历史是空的**，它第一步只能跑一阶。**短尾段最容易暴露这个问题**，因为为数不多的步里还有一步花在低阶上。
- **长片段在低显存机器上直接是时间灾难**：第三方实测 RTX 5070 Ti 16GB 跑 1280×736 / 362 帧 / 20 步 = **26 分 20 秒（约 79 s/步）**，换版本后变成 **341+ s/步（约 2 小时）后被取消**。

### 3.4 运动与细节

- **困难运动、细节与部分音频仍可能低于基座**（FastH3 官方自述："Difficult motion, fine detail, and some audio may remain below the base MiniMax H3 model"）。
- **高频细节在步数不足时出现不稳定的三角形网格伪影**（"unstable triangular grid artifacts that swim under motion"），**蒸馏步数削减的 LoRA 与 turbo 检查点最先把它暴露出来**。官方建议这类内容跑到约 50 步；**12 GB 机器上这基本做不到**。
- **分辨率不是靠步数能补的**：官方明确「步数不会给原生画布分辨不出的东西增加锐度，**糊的画面首先是分辨率问题**」。而在 12 GB 上你**恰恰不敢上原生画布**——这是一个无法两全的结构性矛盾。
- **画面发糊时调步数没有用。**

### 3.5 参考保真度漂移

- **短调度（4 步）下参考可能几乎没被应用**，主体姿态或面部角度会**随片段推进而漂离参考**。
- 官方要求：要紧密跟随参考的镜头**关掉 turbo 跑 20 步**，仍漂移则提到 **25 步**。**这在 12 GB 上是奢侈配置。**
- **锚定 ≠ 视频到视频**：`MiniMaxH3AddGuide` 的 guide 只是加进 conditioning，**`denoise` 不会像图生视频那样缩放 guide 的强度**。想重绘风格要用 R2V 参考视频，想重绘片段要用 mask 路线。误解这一点会得到和预期完全不同的结果。
- **只在 `<Subject N>` 定义内部引用的图片不会被当作独立参考使用**——参考图集必须有自己的 `<Picture N>` 条目。

### 3.6 其他运行期坑

- **负向提示词完全无效**，而且「说出不想要的东西」反而会把那段措辞加进模型读到的描述里。这是最容易踩的坑，官方在 ComfyUI 文档里专门用了一整条来说明。
- **LoRA 与 checkpoint build 不匹配会静默失效**：在完整版上蒸馏的 LoRA 带 adaln 权重，pruned build 里没有对应张量，ComfyUI 报 **shape mismatch 且不合并**，**那部分 LoRA 被跳过**——你不会看到「失败」，只会看到效果不对劲。
- **`shift_video` 用错值会出网格伪影**：在 8 步蒸馏 build 上用 3 而不是 10，画面会出现网格伪影。
- **FastH3 步数必须锁死 8**：该检查点是**正好按 8 步训练**的，**改动调度器里的步数会劣化质量**。
- **FastH3 只支持文生视频与首尾帧图生视频**：官方文档明说 **Ref2VA（多参考条件）没有被蒸馏**，参考类生成必须回基座工作流。（FastVideo 自己的模型卡表述为「支持 T2VA，FL2VA 与 Ref2VA 未蒸馏」；ComfyUI 文档表述为「支持文生视频与首尾帧图生视频」。两处口径略有差异，以你实际用的那个检查点的卡片为准。）
- **FastH3 需要 VSA 注意力后端**：FastVideo 卡明说 "This checkpoint requires FastVideo's VSA-H3 attention backend"，且 **"Dense attention is not a drop-in substitute"**。在 ComfyUI 里对应的是 `BlockSparseAttention`（`vsa` 模式，`keep_percent` 10）。
- **稀疏注意力可能静默失效**：缺 CUDA 或 `comfy_kitchen` 的 `sol_attn` kernel 时，**每一层都静默回落到 dense**，你看不到任何加速也没有报错。
- **OOM 可能整进程崩掉**：ComfyUI 文档警告，请求超大分配的 workflow 能通过校验、然后在执行时**把整个 ComfyUI 进程 OOM 掉**，表现为「连接丢失/超时」而不是节点报错。**必须用 `get_logs` 读日志**才知道发生了什么。
- **系统内存也会被 OOM kill**：第三方汇总里 RTX 3090 24GB + **32GB 系统内存**跑 362 帧时，**不加 `--disable-pinned-memory` 会占用 29.9 GB 并被 OOM kill**。本机 128 GB 内存宽松得多，但 ComfyUI 默认会在内存里保留每个文件副本，仍需留意。

## 4. 官方明确的「未来会做」

| 方向 | 官方原话要点 | 来源 |
| --- | --- | --- |
| 下一代 H 系列整合 M 系列能力 | "In the next generation of the H series, we plan to integrate capabilities from our M-series models." | MiniMax 博客 |
| 继续 scaling | "H3's current model size leaves room for improvement across several capabilities." | MiniMax 博客 |
| 更高分辨率与更强保真 | "We will continue pushing toward higher resolutions and greater visual fidelity." | MiniMax 博客 |
| 完整技术报告 | "We'll be sharing the full H3 Technical Report soon." | MiniMax 博客 |
| 官方稀疏注意力实现 | "The sparse-attention implementation is not included in the initial open-source release and will be published separately in a future update." | 官方模型卡 |
| H3-Regenerate-2K 开源 | "Due to the complexity of the system, this module is not yet open-sourced. We will release it once it is ready." | 官方模型卡 |
| FastH3 的 FL2VA 与 Ref2VA 蒸馏版 | "image ref (FL2VA) and full omni ref (Ref2VA) coming in the next a few weeks" | FastVideo 博客 |
| FastH3 面向 RTX 等本地设备的优化 | "Optimizations targeting local AI devices including RTX, DGX Sparks, and Apple MLX." + "Nvfp4 and GPU memory reduction." | FastVideo 博客 |

> **对本机最重要的两条**：FastH3 的 **Ref2VA 蒸馏版**和**面向 RTX 的本地优化 + 显存缩减**都还在路上。也就是说**当前 12 GB 上的体验是这套技术栈里最差的时间点**，后续版本会改善——如果用户不急着现在出片，值得等。

## 5. 使用限制与合规（不是技术问题但会挡住你）

- **许可不是标准开源许可**：MiniMax H3 Community License Agreement。
- 商业产品/服务**年收入超过 2,000 万美元需另行书面授权**（api@minimax.io）。
- **USA / EU / UK / South Korea 地区**下载模型权重受限，需走申请表：https://platform.minimax.io/h3-license
- **本地生成内容的商用授权，Comfy 是 MiniMax 商业使用许可的唯一官方经销商**：https://comfy.org/minimax/license
- 官方有**内容审核**：用户提交的文本、图像、视频以及增强后的提示词都会过自动化审核；涉嫌违法、色情或侵犯第三方权利的内容可能被拦截。官方声明用了行业标准过滤，但**无法消除误判与漏判**。
- ⚠️ 生态页上存在若干标题带有「破限制 / NSFW / 越狱」字样的社区整合包与视频。**那些内容与官方无关，也不在本项目的知识范围内**；引用它们会误导使用者对官方能力与合规边界的判断。
