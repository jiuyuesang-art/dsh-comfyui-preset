# 显存与性能

- **来源 URL**：
  - https://blog.comfy.org/p/minimax-h3-day-0-support-in-comfyui （**ComfyUI 官方博客**，2026-08-03，本地优化的官方说明）
  - https://docs.comfy.org/tutorials/video/minimax/minimax-h3 （ComfyUI 官方文档，加速与量化注意事项）
  - https://hf-mirror.com/Comfy-Org/MiniMax-H3/raw/main/README.md （**Comfy-Org 官方仓库 README**，量化选择建议）
  - https://hf-mirror.com/api/models/Comfy-Org/MiniMax-H3?blobs=true （**官方文件体积**，仓库最后更新 2026-09-29）
  - https://haoailab.com/blogs/fasth3-preview/ （**FastVideo 官方博客**，FastH3 性能表）
  - https://modelvram.com/minimax-h3-vram-calculator/ （**第三方** VRAM 计算器，汇总 HF discussion #59 / ComfyUI GitHub issues 的实测；非官方）
- **抓取日期**：2026-10-03

---

## 1. 官方给的定性结论（ComfyUI 博客原文）

> We found that the model's modulation weights (~40% of the total parameters) could be pruned and replaced with a functionally equivalent lookup table, dramatically shrinking the memory footprint with no loss in output quality.

> The result gives a total memory footprint **reduced by 66%, from 123.6 GB in full precision to 42.5 GB** with the smallest models variants. Combining this with our dynamic VRAM offloading enables a next-generation 2K video model to run locally on a GPU like the **RTX 3060**.

要点：

- **调制权重（约占总参数 40%）被剪掉**，换成功能等价的**查找表**——这就是 `pruned` 检查点的由来，也是体积从 123.6 GB 降到 42.5 GB 的主因。官方称**输出质量无损失**。
- 权重自带**精确高效的 int8 convrot 量化**，并有**自定义 kernel 降低推理期峰值显存**。
- **动态显存卸载（dynamic VRAM offloading）**是让 12 GB 卡能跑起来的关键机制：显存放不下的权重留在系统内存里，**每一步在 PCIe 上搬**。
- 官方点名 **RTX 3060**（12 GB 显存）——这与本机 RTX 5070 的 12 GB 属同一档。

> ⚠️ **官方从未给出最低 VRAM 数字。** 官方模型卡与 ComfyUI 官方教程都没有「最低显存」这一项。上面是唯一的官方定性说法。

## 2. 官方文件体积（Comfy-Org/MiniMax-H3，实测字节数）

来源：HF API `blobs=true`。仓库 `usedStorage` 合计 **535.6 GB**，下载量 22,813,102，likes 2,100。

### 2.1 扩散模型（DiT）

| 文件 | 体积 |
| --- | --- |
| `minimax_h3_fl2va_bf16.safetensors`（全量 bf16） | **66.28 GB** |
| `minimax_h3_ref2va_bf16.safetensors`（全量 bf16） | **66.28 GB** |
| `minimax_h3_fl2va_pruned_bf16.safetensors` | **40.23 GB** |
| `minimax_h3_fl2va_int8_convrot.safetensors`（全量 int8） | **34.04 GB** |
| `minimax_h3_fl2va_pruned_int8_convrot.safetensors`（**模板默认**） | **20.97 GB** |
| `minimax_h3_fl2va_pruned_fp8_scaled.safetensors` | **20.96 GB** |
| `minimax_h3_fl2va_pruned_w6a8.safetensors`（**最小官方 DiT**） | **15.98 GB** |
| ref2va 各对应版本 | 与 fl2va 同尺寸 |

### 2.2 文本编码器（Qwen3-VL-32B）

| 文件 | 体积 |
| --- | --- |
| `qwen3vl_32b_minimax_h3_bf16.safetensors` | **51.51 GB** |
| `qwen3vl_32b_minimax_h3_int8_convrot.safetensors` | **27.14 GB** |
| `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors`（**模板默认**） | **15.69 GB** |

### 2.3 VAE 与 LoRA

| 文件 | 体积 |
| --- | --- |
| `minimax_h3_video_vae_fp16.safetensors` | 5.21 GB |
| `minimax_h3_video_vae_int8_convrot.safetensors` | 2.81 GB |
| `minimax_h3_audio_vae_fp32.safetensors` | 0.61 GB |
| `minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors` | 1.96 GB |
| `minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors` | 1.96 GB |
| `minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors` | 1.96 GB |
| `minimax_h3_fun_controlnet_union_pruned_int8_convrot.safetensors` | 2.30 GB |
| `minimax_h3_fun_controlnet_union_pruned_bf16.safetensors` | 4.22 GB |
| `minimax_h3_fun_controlnet_union_2.0_pruned_int8_convrot.safetensors` | 4.53 GB |
| `minimax_h3_fun_controlnet_union_2.0_pruned_bf16.safetensors` | 8.38 GB |
| `embeddings/*.safetensors`（10 个风格 embedding） | 0.5 – 1.5 MB / 个 |

### 2.4 官方最小可用组合 = **42.5 GB**

模板默认那套就是「最小组合」：

| 组件 | 文件 | 体积 |
| --- | --- | --- |
| DiT | `minimax_h3_fl2va_pruned_int8_convrot` | 20.97 GB |
| 文本编码器 | `qwen3vl_32b_minimax_h3_nvfp4_awq` | 15.69 GB |
| 视频 VAE | `minimax_h3_video_vae_int8_convrot` | 2.81 GB |
| 音频 VAE | `minimax_h3_audio_vae_fp32` | 0.61 GB |
| **合计** | | **≈ 40.1 GB**（官方博客口径 42.5 GB，含 LoRA/embedding 等零头） |

R2V 系列还要加 1.96 GB 的 reference turbo LoRA；Fun ControlNet 还要加 2.30 GB 的 controlnet patch 与 SDPose 的 checkpoint/detector。

## 3. 官方量化选择建议（Comfy-Org README 原文）

- **扩散模型优先用 `int8_convrot`**——**前提是你能用 cu130 的 pytorch**。
- **`fp8_scaled` 只在你用不了 `int8_convrot` 时才用。**
- 文本编码器的 **`nvfp4` 不需要 Blackwell GPU** 也能用（原文："This `nvfp4` text encoder does not require Blackwell GPU to use."）。
- ⚠️ **官方明确 `bf16` checkpoint "needs more VRAM"**（ComfyUI 文档原文）。低显存机器不要碰 bf16。
- `w6a8` 是官方发布里**体积最小**的 DiT（15.98 GB），低显存场景值得优先试。

## 4. FastH3 官方性能表（唯一有官方数字的性能数据）

来源：FastVideo 官方博客。测试条件：**1344×768、24 FPS、带音频**；5s / 10s / 15s = **124 / 243 / 345 帧**；三次计时取中位数，跑过一次完整 warmup，**不含模型加载与编译**；端到端包含编码、去噪、解码、音频、封装与落盘。

| 模型 / 运行时 | 时长 | 1× B200 E2E (s) | 4× B200 E2E (s) | 8× B200 E2E (s) | 相对 Base H3 加速（1× / 4×） |
| --- | ---: | ---: | ---: | ---: | --- |
| **Base H3 · Dense FA4** | 5s | 132.5 | 40.6 | — | 1.0× / 1.0× |
| | 10s | 377.4 | 108.7 | — | 1.0× / 1.0× |
| | 15s | 678.7 | 193.1 | — | 1.0× / 1.0× |
| **Preview v1 VSA / Data-Free · 90% 稀疏** | 5s | **16.2** | **6.1** | **6.84** | **8.16× / 6.65×** |
| | 10s | 31.1 | 12.0 | 11.66 | **12.13× / 9.03×** |
| | 15s | 47.2 | 15.5 | 12.88 | **14.38× / 12.48×** |
| **Preview v1 Dense / Data-Free · Dense FA4** | 5s | 18.3 | 6.8 | — | 7.24× / 5.97× |
| | 10s | 50.2 | 15.0 | — | 7.52× / 7.25× |
| | 15s | 91.3 | 25.6 | — | 7.43× / 7.54× |

**关键数字：Base H3 在 1×B200 上生成 5 秒 768p 视频要 132.5 秒。** B200 是数据中心级 Blackwell 卡，单卡算力与显存带宽远超消费级 RTX 5070。

其他官方说法：

- FastH3 可在 8×B200 上 **不到 13 秒**生成 15s 768p（sub-realtime）。
- 单张 NVIDIA Blackwell GPU 上最高 **14× 加速**。
- Base H3 调用它的 **33B 音视频 DiT 共 49 次**；FastH3 降到 **4 次**。
- FastH3 官方「What's Next」明确包含：**"Optimizations targeting local AI devices including RTX, DGX Sparks, and Apple MLX"** 与 **"Nvfp4 and GPU memory reduction"** —— 即官方承认**面向 RTX 的本地优化还在路上**。
- FastH3 的实测默认配置是 **4 张 B200**；在别的多卡 CUDA 系统上要加 `--no-replicated-dit --vsa-kernel triton --no-fa4`，且 **GPU 数量必须能整除 H3 的 56 个注意力头**。

## 5. 第三方汇总的实测数据（非官方，标注来源原样照录）

以下来自第三方计算器站点 modelvram.com 汇总的 HF discussion #59 与 ComfyUI GitHub issues 报告。**这些不是官方数字，仅作规划参考。**

### 5.1 实测记录

| GPU | 配置 | 视频规格 | 峰值显存 | 系统内存 | 耗时 |
| --- | --- | --- | --- | --- | --- |
| RTX PRO 6000 96GB | Full INT8 ConvRot DiT + INT8 encoder + 双 VAE | 864×480 · 5s · 20 步 | 63.7 GB | — | 47 s |
| RTX 5090 32GB | 同上；**每步有 1–3 GB DiT 走 PCIe** | 864×480 · 5s · 20 步 | 31.8 GB | — | 69 s |
| RTX 4090 24GB | 同上；**每步有 9–10 GB 走 PCIe** | 864×480 · 5s · 20 步 | — | 68 GB 峰值 | 92–93 s |
| RTX 3090 24GB（32GB 内存） | Pruned INT8 DiT + NVFP4 encoder + FP16 VAE，`--disable-pinned-memory` | 832×480 · 124 帧 · 20 步 | 23,716 MiB | — | 4 分 26 秒 |
| RTX 3090 24GB（32GB 内存） | 同上 | 832×480 · **362 帧** · 20 步 | 18,884 MiB | 7.5 GB（**不加该 flag 时 29.9 GB 并被 OOM kill**） | 23 分 17 秒 |
| RTX 5070 Ti **16GB**（125GB 内存） | Pruned INT8 DiT + NVFP4 encoder + 双 VAE（42.5 GB） | **1344×768** · 5s | **14,437 MiB** | 45.4 GiB RSS（加 `--fast-disk` 降到 12.6 GiB） | — |
| RTX 5070 Ti 16GB（125GB 内存） | 同上 | 640×480 · 30s | 14,197 MiB | 同上 | — |
| RTX 5070 Ti **16GB** | Full INT8 ConvRot DiT + INT8 encoder | 1280×736 · 362 帧 · 20 步 | 15.1 GB 平均 | — | **26 分 20 秒（约 79 s/步）** |
| RTX 5070 Ti 16GB | 同上（换 ComfyUI 0.33.1） | 1280×736 · 362 帧 · 20 步 | 15,773 MB 平均 | — | **约 2 小时（341+ s/步），已取消** |
| RTX 5070 Ti 16GB（**16GB 内存**） | 社区混合 INT8 turbo DiT + NVFP4 encoder + INT8 VAE | 0.6 MP · 6s · 6 步 | 初始 ~74%（0.35.0 加 `--vram-headroom 1` 后 ~90%） | — | 129–154 s |
| RTX 4060 Laptop **8GB**（16GB 内存） | Pruned **W4A8** DiT + NVFP4 encoder | 38,968 tokens · 20 步 | 整卡占满 | — | **20 分 51 秒（72 s/步）** |
| **RTX 3060 12GB** | **8 步 Turbo LoRA** + INT8 视频 VAE | **864×480 · 5s · 8 步** | — | — | **4.5 分钟** |

### 5.2 计算器给出的量化结论

**最短答案（站点原文）**：用 pruned INT8 DiT + NVFP4 文本编码器时，**864×480、124 帧片段的峰值显存约 26.2 GB – 31.6 GB**。

| 组合 | 需上卡权重 | 全部文件 | 峰值区间 | 8GB | 12GB | 16GB | 24GB | 32GB |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pruned INT8 + NVFP4 编码器（**Comfy-Org 最小组合**） | 24.9 GB | 39.6 GB | **26.2–31.6 GB** | 流式 | 流式 | 流式 | 流式 | ✅ 装得下 |
| Pruned FP8 + NVFP4 编码器 | 24.9 GB | 39.5 GB | 26.2–31.6 GB | 流式 | 流式 | 流式 | 流式 | ✅ |
| GGUF Q8_0 + NVFP4 + INT8 VAE | 23.3 GB | 37.9 GB | 24.6–30.0 GB | 流式 | 流式 | 流式 | 流式 | ✅ |
| **W4A8 + NVFP4 + INT8 VAE** | 17.8 GB | 29.5 GB | **19.1–24.5 GB** | 流式 | 流式 | 流式 | 勉强 | ✅ |
| GGUF Q4_K_M + Q4_K_M 编码器 + INT8 VAE | 16.8 GB | 27.5 GB | 18.1–23.5 GB | 流式 | 流式 | 流式 | ✅ | ✅ |
| GGUF Q4_K_M，**编码器放 CPU** | 14.0 GB | 27.5 GB | **15.3–20.7 GB** | 流式 | 流式 | 勉强 | ✅ | ✅ |
| GGUF Q2_K，**编码器放 CPU** | 9.4 GB | 23.0 GB | **10.7–16.1 GB** | 流式 | **勉强** | 勉强 | ✅ | ✅ |

**术语定义（站点原文口径）**：
- **Fits**：所有需要的文件 + 工作内存区间上限都装得下。
- **Tight**：只有工作内存区间下限装得下。
- **Streams**：工作内存装得下，但**不是所有权重都装得下**，于是 ComfyUI 动态显存把剩下的留在系统内存里、**每一步搬运一次**：能跑，但更慢。
- **Risky**：连工作内存都可能装不下。

**系统内存**：需求 = 没上卡的权重 + **约 6 GB 给 ComfyUI**。若要像 ComfyUI 默认那样**在内存里保留每个文件的一份副本**（便于快速重跑），要按全部文件体积再规划。

## 6. ComfyUI 官方文档给出的降低显存/提速手段

### 6.1 Sage Attention（约 2× 提速）

- **可把生成速度大致翻倍**，质量损失极小。
- 需要自己装：`sageattention` 包（从 SageAttention releases 下匹配 PyTorch/CUDA 版本的 wheel）+ **KJNodes**（提供 `Patch Sage Attention KJ` 节点）。
- 接法：把 `Patch Sage Attention KJ` 接在 **`UNETLoader` 与 `BasicGuider` 之间**（`model` 进、`model` 出），`sage_attention` 设为 `auto`。**只有 guider 需要这个 patch**，scheduler 只产生 sigma，可以不动。
- 或者用启动参数 **`--use-sage-attention`** 全局开启。
- ⚠️ Sage Attention 要求 fp16/bf16 张量。H3 有些层跑在别的 dtype，所以控制台会看到 `Input tensors must be in dtype of torch.float16 or torch.bfloat16, using pytorch attention instead` ——**这是预期的**，受影响的层回落到标准注意力，生成仍然正常。
- ⚠️ **INT8 注意力的质量退化**：如果用了 Sage Attention 后出现**片段末尾的形变（morphing）或画面文字乱码**，那大概率是 INT8 注意力量化造成的。原因是 **H3 最后几个 block 把大部分注意力 key 信号集中在少数通道上**，而**每行用单一共享 scale 的 INT8 kernel 会丢掉一部分信号**。
  - **模板自带的就是 int8-convrot 检查点**，所以用 Sage Attention 属于「拿一点点画质换 2 倍速度」的取舍——**在 12 GB 这种必须榨速度的机器上通常是值得的**，但要知道这个代价。

### 6.2 Comfy Kitchen attention（修 INT8 伪影，但 12 GB 上大概率用不了）

- ⚠️ **Comfy Kitchen attention 不支持 int8-convrot 检查点**，采样会以**对齐错误（alignment error）崩溃**（ComfyUI issue **#15529**）。**用这些检查点时必须保持默认注意力。**
- 正确路径是：在 `UNETLoader` 里换成 **bf16 对应版本**（`minimax_h3_fl2va_pruned_bf16.safetensors` / `minimax_h3_ref2va_pruned_bf16.safetensors`，**需要更多显存**），再切后端。
- 切法：加内建 **Model Attention Backend** 节点（分类 `model/patch`），backend 设为 `comfy kitchen attention`，接在**模型到达 `BasicGuider` 之前**（即 `LoraLoaderModelOnly` 及其 Enable Lightning LoRA 开关之后）。或用启动参数 **`--use-ck-attention`**（ComfyUI ≥ 0.32.0）。
- 该后端由随 ComfyUI 一起发布的 **`comfy-kitchen`** 包提供，**只有硬件上 INT8 kernel 可用时才会出现在节点的后端列表里**。
- **对 12 GB 机器的结论**：bf16 pruned DiT 是 **40.23 GB**（vs int8 的 20.97 GB），在 12 GB 上不现实。**所以 12 GB 上应当留在默认注意力 + int8-convrot。**

### 6.3 Model Sparse Attention（稀疏注意力）

- 内建 **Model Sparse Attention** 节点（分类 `model/patch`，**实验性**，ComfyUI ≥ 0.35.0），对符合条件的层跑 block-sparse attention；**收益随序列长度增长**。
- `method` 设为 **`sol-attn`**（基座 H3 权重用的模式；`sla` 与 `vsa` 需要专门为该模式训练的权重）。
- 稀疏路径需要 **CUDA** 与 `comfy-kitchen` 的 **`sol_attn` kernel**；缺了的话**每一层都静默回落到 dense，看不到任何加速**。
- 调参要点：
  - **首尾步不要稀疏**：默认 `start_percent` **0.2**、`end_percent` **1.0**；建议起点推迟到约 **0.4**、终点提前到约 **0.9**，让开场运动与收尾画面保持 dense，代价是速度略降。
  - **`sink_conditioning` 保持默认 `exact_kv_and_rows`**：它保持打包的 text/audio/reference 行精确、生成的 audio query 行 dense，**这样稀疏路径才不会劣化音轨**。
  - **`tau` 控制稀疏程度**：`1.0` 约保留 **16%** key block 为精确，`1.5` 约 **7%**，`2.0` 约 **2.7%**；默认 **1.3**，越大越快但风险越高。
  - **短片收益很小**：低于 `min_tokens`（默认 **12288**）的序列，以及 `dense_blocks` 里列出的 block，都保持 dense。
- FastH3 用同一个节点但走 **`vsa`** 模式，`keep_percent` **10**。
- ⚠️ ⚠️ **一个重要的现状冲突**：ComfyUI 文档说 Model Sparse Attention 的 `sol-attn` 是基座 H3 权重用的模式，而 MiniMax 官方模型卡说稀疏注意力**未包含在初始开源版本中**、只提供 full attention 推理，官方后续会单独发布。两者描述的是不同层面（ComfyUI 侧的内核实现 vs 官方权重侧的发布计划）——**实际使用前先按 `07-limits-and-issues.md` 的方式实测确认**。

### 6.4 Add Guide / latent noise mask 对显存的影响

- `MiniMaxH3AddGuide` 会**把 guide 做 VAE 编码后追加到 conditioning**，**每一步都在条件里**，所以参考帧会**增加每步的计算与显存负担**。
- per-token noise mask 不省显存，但省时间：只重生成 mask 标 1 的区域。

## 7. 本机可行性判断：RTX 5070 / 12 GB 显存

**本机硬件**：NVIDIA GeForce RTX 5070，显存 **12 GB**（12,820,938,752 字节），系统内存 **128 GB**，Windows / AMD64。

### 7.1 结论

> **12 GB 是 MiniMax H3 的地板档，不是舒适档。**
> - **能跑，但只能跑「预览级」配置**：低分辨率（864×480 或 640×480）+ 短时长（5 秒 / 124 帧）+ 蒸馏或少步数调度（FastH3 8 步，或 fl2v/ref2v turbo LoRA 8/4 步）。
> - **官方模板的默认配置在这台机器上不可行**：默认就是 1344×768 / 124 帧 / 20 步、权重组合 39.6 GB。第三方汇总显示即使是 **24 GB 的 3090** 跑 832×480/124 帧/20 步峰值也要 **23,716 MiB**，**12 GB 全程只能靠 PCIe 流式搬运**，速度会慢到不实用。
> - **长片段直接判死**：24 GB 的 3090 跑 832×480 **362 帧**要 **23 分 17 秒**；16 GB 的 5070 Ti 跑 1280×736 **362 帧**实测 **26 分 20 秒（约 79 s/步）**，换版本后甚至变成 **341+ s/步（约 2 小时）后被取消**。12 GB 上做 15 秒片段属于「跑得动但等不起」。

### 7.2 可执行的降级方案（按优先级）

1. **一律走蒸馏路线**：优先 **FastH3 8 步**（`video_fastvideo_fasth3_t2v` / `..._i2v`，步数固定 8，不要改），或基座模板里**打开 `turbo_mode`** 用 8 步 / 4 步 turbo LoRA。
2. **分辨率降到 864×480 或 640×480**：用 Resolution Selector 把 **Megapixels 设到 0.4 或更低**，`Multiple` 保持 32。**不要**去够 1344×768 原生画布。
3. **时长压到 5 秒**（`length` = 124 帧）。这是官方模板的默认值，也是 12 GB 上唯一现实的档位。
4. **换更小的权重**：官方发布里最小的是 **`minimax_h3_fl2va_pruned_w6a8.safetensors`（15.98 GB）**，比模板默认的 pruned int8（20.97 GB）小 5 GB。第三方汇总显示 **W4A8 + NVFP4 + INT8 VAE 的峰值约 19.1–24.5 GB**，是 12 GB 上「流式但不至于太惨」的量级。
5. **文本编码器用 `nvfp4_awq`（15.69 GB）**：这是官方推荐且在**非 Blackwell 上也能用**的量化（RTX 5070 本身就是 Blackwell，nvfp4 原生支持，无压力）。
6. **打开 Sage Attention 换速度**（约 2×）：接受「片段末尾形变 / 画面文字乱码」的风险。**不要**去开 `--use-ck-attention`（int8-convrot 检查点会崩，bf16 又放不下）。
7. **点开 Model Sparse Attention 节点试 `sol-attn`**：只在 `comfy-kitchen` 的 `sol_attn` kernel 真能用时才有收益（否则静默回落 dense，白开）。短片（<12288 token）收益很小。
8. **启动参数（社区报告，非官方保证）**：
   - **`--disable-pinned-memory`**：第三方汇总里 **3090 24GB + 32GB 内存不加这个会被 OOM kill**。本机 128 GB 内存，建议先用默认，出现 OOM 再关。
   - **`--fast-disk`**：第三方汇总里能把 RSS 从 **45.4 GiB 降到 12.6 GiB**（SSD 要够快）。
   - **`--vram-headroom 1`** 与 **`--disable-comfy-compiler`**：社区在 5070 Ti 上的自述组合，**历史自报，未经独立验证**，也不保证对当前版本有效。
9. **先跑一次最小尺寸试探再放大**：用 640×480 / 124 帧 / 8 步跑通一次，确认链路与耗时，再决定是否加分辨率。
10. **I2V 比 T2V 稳**：有首帧图约束，变量更少，同样算力下出片成功率更高。
11. **跑不动就明确说不行**：如果用户要的是 1344×768 或 10 秒以上，**直接告知本机 12 GB 不适合，不要硬试**。可选出路是 Comfy Cloud 或伙伴节点（付费路线，不在本项目范围）。

### 7.3 期望时间量级（推算，务必按估算口径使用）

官方唯一的时间数据是 **FastH3 在 1×B200 上 5 秒 768p = 16.2 秒**、**Base H3 = 132.5 秒**。B200 是数据中心双芯卡，显存带宽（约 8 TB/s 级）与算力远超消费级 RTX 5070（约 0.67 TB/s 级 GDDR7 带宽）。再叠加 12 GB 卡**必须每步从系统内存经 PCIe 搬运大量权重**这一额外瓶颈——

**推算：在 RTX 5070 12 GB 上，用 FastH3 8 步生成 864×480 / 5 秒片段，现实耗时量级是「数分钟到十几分钟」；改用 1344×768 或 20 步基座调度则进入「数十分钟到小时级」。**

这个推算**不是官方数字，也不是实测**，只用于给用户设定预期。真实耗时必须在目标机器上实测一次。已抓到的、最接近本机的可比数据点是：**RTX 3060 12GB + 8 步 Turbo LoRA + INT8 视频 VAE 跑 864×480 / 5s / 8 步 = 4.5 分钟**（第三方汇总，引 HF discussion #35）。**RTX 3060 与本机同为 12 GB 显存**，这个 4.5 分钟可以作为「下限乐观值」参考；RTX 5070 的算力与带宽高于 3060，理论上应更快，但实际取决于卸载程度与 attention 后端。

> 一句话给用户：**在 12 GB 上，把 H3 当「慢速草稿机」用是可行的（小尺寸 + 8 步 + 5 秒），当「出片机」用不可行。**
