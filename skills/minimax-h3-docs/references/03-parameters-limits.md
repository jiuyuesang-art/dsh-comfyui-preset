# 参数与限制

- **来源 URL**：
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3 （分辨率、步数、采样器与调度器）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native （分辨率、时长网格、turbo 参数）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3-fun-controlnet （guidance_scale、strength、控制视频长度）
  - https://huggingface.co/MiniMaxAI/MiniMax-H3 （官方规格表，经镜像 https://hf-mirror.com/MiniMaxAI/MiniMax-H3/raw/main/README.md）
- **抓取日期**：2026-10-03

---

## 1. 时长

| 项 | 值 | 来源 |
| --- | --- | --- |
| 官方输出时长范围 | **4–15 秒** | 官方模型卡 |
| ComfyUI 模板表述 | 5–15 秒（Fun ControlNet 页写 "The target video runs 5 to 15 seconds"） | ComfyUI 文档 |
| 帧率 | **24 FPS** | 官方模型卡 + ComfyUI 文档 |
| 帧数网格 | 节点 `length` 输入是**帧数**，会**向上吸附到 17 帧一块的网格（17k+5）** | ComfyUI 文档 |
| 默认值 | `length` 默认 **124 帧 ≈ 5 秒**（@24fps） | ComfyUI 文档 |
| 实际帧数示例 | 5 秒 = **124 帧**；10 秒 = **243 帧**；15 秒 = **345 帧** | FastH3 官方博客性能表 |
| 合法 clip 长度序列 | **5、22、39…帧（17k+5）** | ComfyUI 文档（Add Guide 一节） |

> 注意 124 = 17×7+5，243 = 17×14+5，345 = 17×20+5，与网格一致。

## 2. 分辨率

| 项 | 值 |
| --- | --- |
| 官方默认 | 短边 **768 像素** |
| 原生画布（16:9） | **1344 × 768**（≈1 兆像素 / 0.98 MP） |
| 像素面积上限 | **768 × 1344**（即约 1 MP；横向 1376×768 已超上限） |
| 对齐 | 分辨率**四舍五入到 32 的倍数**（ComfyUI 的 Resolution Selector 里 `Multiple` 保持 **32**） |
| 支持宽高比 | 21:9、16:9、4:3、1:1、3:4、9:16 等 |
| 2K | 由官方托管的 **H3-Regenerate-2K** 产出，**未开源**；在 ComfyUI 里需要**额外的单独上采样 pass** |
| FastH3 上限表述 | "capped at 768x1344"，且以 32 的倍数为准 |

### ComfyUI 的 Resolution Selector 节点

节点由三个设置算出 `width` / `height`，输出直接接到 MiniMax H3 节点的 `width` / `height`：

- **Aspect ratio**：预设如 `16:9 (Widescreen)`、`9:16 (Portrait Widescreen)`、`1:1 (Square)`
- **Megapixels**：目标总像素；值越大画面越大、越慢
- **Multiple**：结果四舍五入到该值的倍数，**保持 32**

官方明确的操作要点：

- 模板自带一个**快速预览尺寸**。
- 要 16:9 全质量，把 Megapixels 设为 **0.98**（得到 H3 原生画布 1344×768），或直接在 MiniMax H3 节点里填 `width` `height` = **1344 × 768**（这是它的默认值）。
- **跳过 1.0 兆像素这一步**——它算出 1376×768，**超过模型 768×1344 的像素面积上限**。
- 远高于原生画布的分辨率**不会**保住细节：H3 是在约 1 兆像素上训练的，后续上采样**无法恢复生成阶段就没留下的东西**。要 2K，请先在原生画布生成，再单独走一趟上采样。
- 「画面发糊首先是分辨率问题，不是步数问题」。

## 3. 采样步数与调度

### 3.1 步数总表（基座权重）

| 场景 | 步数 |
| --- | --- |
| 模板默认（**Enable Lightning LoRA 开关关闭**） | **20 步** |
| turbor 模式（Lightning LoRA 开启）：T2V / I2V（含 continuation 变体） | **8 步** |
| turbo 模式：R2V / Multiframe Reference / Fun ControlNet Union（这些模板带 reference turbo LoRA） | **4 步** |
| 简单内容镜头 | 12–16 步即可 |
| 高频细节（锁子甲、金银丝/花纹、一堆小物件） | 一路改善到约 **50 步** |
| 提示词遵循度与运动 | 大部分收益在 **第 16 步**前拿到；超过约 50 步差别很难看出来 |
| 参考驱动镜头（要贴合参考） | **关掉 turbo，跑基座 20 步**；仍漂移则提到 **25 步** |

在 T2V / I2V 模板里，turbo 开关表现为子图节点上的 `turbo_mode` widget。

### 3.2 官方对短步数调度的警告（重要）

- **短调度对参考驱动的镜头伤害最大**：参考 token 会跟着**每一个采样步**走，开关打开后留给这份条件起作用的步数大幅减少——**4 步时参考可能几乎没被应用**，主体姿态或面部角度会随片段推进而漂离参考。
- 高频细节区域在步数不足时会显示**不稳定的三角形网格伪影**（"unstable triangular grid artifacts that swim under motion"），**蒸馏/turbo 检查点最先暴露这个问题**。
- **音频比画面收敛得晚**：视频与音频在**同一趟**里联合去噪，所以一条调度同时驱动两者；音频在人眼已看不出画面变化的步数上仍在改善。
- **语音与音色最后收敛**：**8 步时它们是输出里最弱的部分**，**12 步及以上音轨才保持可用**。

### 3.3 采样器与调度器

- **所有本地 MiniMax H3 工作流都用 `res_multistep` 采样器 + `simple` 调度器。**
  - T2V、I2V、FastH3 把这两个节点**放在子图内部**（要改得先进子图）。
  - R2V、Multiframe Reference、Fun ControlNet Union 把 `KSamplerSelect` 与 `BasicScheduler` **放在顶层画布**。
- `res_multistep` 是**二阶多步**采样器：每一步复用上一步的去噪估计。**第一步没有上一步可复用，所以按普通一阶（Euler）步跑**，二阶步从第二步开始。
- `er_sde` 用同样方式积累阶数（第一步一阶、第二步二阶，`max_stage` 默认 3 时从第三步起三阶全开）。
- ⚠️ **多步历史存在单次采样运行内部，不在 latent 里**：把调度拆给两个采样器**不会**把历史带过去。两段式设置（例如基座 + latent 上采样后的第二个采样器）里，第二个采样器的历史是空的——它第一步跑一阶，二阶更新从第二步才恢复。**短尾段最容易暴露这个问题**，因为它为数不多的步里还有一步花在低阶上。**要么把整条调度放在一次采样运行里，要么给第二个采样器足够步数重建历史。**

## 4. flow shift（sigma shift）

- 这对值**来自模型定义，不是工作流**：ComfyUI 的 H3 定义携带 **`shift` = 12** 与 **`audio_shift` = 3**，**除 FastH3 外**所有工作流都读这两个值，所以工作流里**没有 shift 节点**。
- **FastH3 模板**则自带内建 **`ModelSamplingMiniMaxH3`** 节点（工作流 JSON 里名为 `MiniMaxH3SigmaShift`，分类 `model/patch/minimax`），设为 **`shift_video` = 10** 与 **`shift_audio` = 3** ——这是它蒸馏调度所依据的那一对值。
- 视频 shift 驱动采样器的 sigma 调度；模型再把视频调度**反演到共享基网格**上，由此推出音频调度。
- 当某个 checkpoint 需要不同的一对值时，才加这个节点；并且**要贴近该 checkpoint 所构建的值**：在 **8 步蒸馏 build** 上用 `shift_video` **3** 而不是 **10** 采样，**画面会出现网格伪影**。

## 5. guidance

| 项 | 值 / 说明 |
| --- | --- |
| Fun ControlNet Union 的 `guidance_scale` | **保持 1.0**（官方文档明确） |
| patch `strength` | **只有**当输出偏离控制时才把 Fun ControlNet patch 的 `strength` **提到 1 以上** |
| CFG | H3 模板通过 **`BasicGuider`** 采样，它**只有一个条件输入**，没有负向分支；该 guider 跑在 **`cfg` = 1**，此时 ComfyUI **跳过无条件 pass**（`CFGGuider` 也只在 `cfg` > 1 时才使用负向条件） |
| **负向提示词** | **完全无效**。而且「说出不想要的东西」会把那段措辞**加进模型读到的描述里**，没有单独的 pass 去把它减掉——例如写 `no subtitles and no on-screen text` 反而会让模型把「文字」登记成内容 |
| 正确做法 | **把禁令写成正面描述**：要说「门上方的招牌是空白的」（`the sign above the door is blank`），而不是「不要有字幕」 |
| 全参考模式（R2V） | 同样的事通过 retention analysis 表达：用 `fully_preserved` / `partially_preserved` / `attribute_transfer` / `weak_reference` 说明每份参考给目标视频贡献了什么 |

## 6. 种子（seed）

- **官方页面未记录 H3 专属的 seed 参数或取值范围。** 本次抓取的所有官方页面（ComfyUI 6 页 + MiniMax 模型卡 + 官方博客）都没有提到 seed。
- 在 ComfyUI 中，H3 工作流的随机性由标准采样/引导节点提供；`BasicGuider` + `BasicScheduler` + `KSamplerSelect` 这套组合里，种子仍由采样节点管理。
- 结论：**seed 走 ComfyUI 通用机制即可，官方没有 H3 专属说明**。不要编造 H3 特有的 seed 规格。

## 7. turbo（Lightning LoRA）参数

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `turbo_mode` | 关 | T2V / I2V 子图节点上的开关；打开了就用 turbo LoRA 代替 20 步 |
| `turbo_steps` | **8** | turbo 模式下的步数（R2V 系列的 reference turbo LoRA 对应 4 步） |
| `turbo_model_strength` | **1.0** | LoRA 强度 |

- T2V / I2V 用的 turbo LoRA：`minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors`（来源 https://huggingface.co/lightx2v/Minimax-h3-Turbo ，Comfy-Org 仓库也有一份）
- R2V / Multiframe / Fun ControlNet 用的 reference turbo LoRA：`minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors`
- 官方代价说明：turbo 更快，但**音频与运动质量略低**。

## 8. R2V 专属参数

| 参数 | 说明 |
| --- | --- |
| `ref_images` | 参考图槽位，最多 **9** 张；提示词里按连接顺序引用为 `<Picture 1>`、`<Picture 2>`… |
| 参考视频 | 最多 **3** 段，每段**可自带音轨** |
| 独立参考音频 | 最多 **3** 段 |
| 文件总数 | 跨所有输入类型**最多 12 个** |
| `ref_image_size` | `match`：把参考**缩到生成分辨率**，更快；`max`：**保留到 2048px 短边**，身份保真更强但更慢 |

## 9. Fun ControlNet Union 专属参数

| 参数 | 说明 |
| --- | --- |
| `control_video` | 控制视频，支持由单个 checkpoint 条件化 **Canny / Depth / HED / MLSD / Pose** |
| `mask` | 接 mask 即进入视频局部重绘：标 **1** 的区域被重生成（受可选 `source_video` 控制），其余画面保持不动 |
| `source_video` | 可选，重绘时的源视频 |
| `strength` | patch 强度；默认 1，**只在输出偏离控制时**才提高 |
| 控制视频长度行为 | 目标视频 **5–15 秒**（17n+5 网格，124 帧 = 5 秒）。控制视频**比目标长** → 裁到前几帧；**比目标短** → **保持最后一帧**。若要精确匹配控制视频长度，把示例里算出的 `batch_size` 输出接到 `MiniMax H3 Reference to Video` 节点的 length 输入 |
| 预处理节点 | ComfyUI 内置各控制类型的预处理节点（Canny 见 `docs.comfy.org/built-in-nodes/Canny`；Depth 见 Depth Anything 3 教程） |

## 10. 参数速查（常用默认值汇总）

| 参数 | 推荐/默认值 |
| --- | --- |
| `width` × `height` | 1344 × 768（16:9 原生画布）；其他比例按 32 倍数对齐、总像素 ≤ 768×1344 |
| `length` | 124（≈5 秒 @24fps），吸附到 17k+5 |
| 帧率 | 24 FPS（模型固定） |
| 步数 | 基座 20；简单镜头 12–16；高频细节最多 ~50；turbo 8（fl2va）/ 4（ref2va）；**FastH3 固定 8** |
| 采样器 / 调度器 | `res_multistep` / `simple` |
| shift / audio_shift | 12 / 3（基座）；FastH3：10 / 3 |
| `guidance_scale` | 1.0 |
| CFG | 1（无负向提示词） |
| `turbo_model_strength` | 1.0 |
| Resolution Selector 的 `Multiple` | 32 |
| 参考图上限 | 9 张（R2V） |
| 参考文件总数上限 | 12 |
