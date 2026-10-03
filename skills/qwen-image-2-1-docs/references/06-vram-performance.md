# 显存与性能

来源：
- `https://modelvram.com/qwen-image-2-1-vram-calculator/`（ModelVRAM 显存计算器；其中字节数标注为"read from the Hugging Face API on 2026-09-29"，实测峰值来自真实 GPU 运行）
- `https://github.com/wildminder/awesome-qwen-image`（Comfy-Org 官方文件的精确体积）
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档：RTX 5090 速度基准）
- `https://modelscope.cn/models/Qwen/Qwen-Image-2.1`（官方分片精确字节数）
- `https://github.com/QwenLM/Qwen-Image-2.1`（官方 README：内存优化）

抓取日期：2026-10-03

## 先说结论

**官方没有发布显存门槛数字。** README 只给了一句 `pipe.enable_model_cpu_offload()`
（"For GPUs with limited memory"），没有 GB 数。
下面所有具体数字都来自社区实测工具与官方文件体积，**不是官方门槛**。

关键事实：**7B 是 DiT 部分的参数量，不等于总显存。**
整条链路是"7B DiT + Qwen3-VL 8B 文本编码器 + VAE"三个模型，
**文本编码器 BF16 就有 17.53 GB**，比 DiT 还大。

## 文件体积（Comfy-Org 官方重打包，精确值）

| 文件 | 精度 | 体积 |
| --- | --- | --- |
| Image Model（DiT） | bf16 | **14.23 GB** |
| Image Model（DiT） | int8 ConvRot | **7.26 GB** |
| Text Encoder（Qwen3-VL 8B） | bf16 | **17.53 GB** |
| Text Encoder | int8 ConvRot | **9.35 GB** |
| Text Encoder | w4a8 | **6.31 GB** |
| Prompt Engine T2I | int8 ConvRot | **9.47 GB** |
| Prompt Engine I2I | int8 ConvRot | **9.47 GB** |
| VAE | bf16 | **0.68 GB** |
| ControlNet Union | bf16 | **7.55 GB** |
| ControlNet Union | int8 ConvRot | **3.78 GB** |

官方原始仓库（diffusers 布局）：DiT 14.23 GB + 文本编码器 17.53 GB + VAE 1.35 GB。

### 计算器里可直接选的等价体积

| 部件 | 选项与体积 |
| --- | --- |
| **DiT** | BF16 13.3 GB · GGUF Q8_0 7.1 GB · INT8 ConvRot(ComfyUI) 6.8 GB · FP8 6.6 GB · Q6_K 5.8 GB · Q5_K_M 5.0 GB · Q4_K_M 3.9 GB · NVFP4 3.8 GB · Q3_K_M 3.0 GB · Q2_K 2.3 GB |
| **文本编码器** | BF16 16.3 GB · FP8 8.7 GB · INT8 ConvRot 8.7 GB · GGUF Q8_0 8.1 GB · Q6_K 6.3 GB · W4A8 5.9 GB · NVFP4 5.9 GB · Q5_K_M 5.4 GB · Q4_K_M 4.7 GB · Q3_K_M 3.8 GB |
| **VAE** | BF16 0.6 GB · FP32 1.3 GB |

## 1024×1024 常见组合的峰值区间

计算器短答原文：

> Qwen-Image 2.1 with a Q8_0 DiT and an INT8 text encoder, all kept in VRAM,
> peaks at about **18.6 GB–21.2 GB** for a 1-megapixel image.

| 组合 | 权重驻留 | 峰值区间 | 8 GB | 12 GB | 16 GB | 24 GB | 32 GB |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 全精度（diffusers 默认） | 30.8 GB | 32.9–35.5 GB | No | No | No | No | No |
| **ComfyUI INT8 ConvRot 套件** | 16.1 GB | **18.2–20.8 GB** | No | No | No | **Fits** | Fits |
| **INT8 套件 + 编码器卸载** | 9.3 GB | **11.4–14.0 GB** | No | **Tight** | **Fits** | Fits | Fits |
| FP8 DiT + FP8 编码器 | 16.0 GB | 18.1–20.7 GB | No | No | No | Fits | Fits |
| GGUF Q8_0 + Q8_0 编码器 | 15.9 GB | 18.0–20.6 GB | No | No | No | Fits | Fits |
| GGUF Q4_K_M + INT8 编码器 | 13.2 GB | 15.3–17.9 GB | No | No | Tight | Fits | Fits |
| GGUF Q4_K_M + Q4_K_M 编码器 | 9.2 GB | 11.3–13.9 GB | No | Tight | Fits | Fits | Fits |
| **GGUF Q4_K_M + 编码器在 CPU** | 4.5 GB | **6.1–6.9 GB** | **Fits** | Fits | Fits | Fits | Fits |

**"Tight" 的含义**：只在区间低端能装下。ComfyUI 这类还能把部分模型挪到系统内存（更慢）。
**如果这块 GPU 同时驱动显示器，另外留 0.5–1 GB 给桌面。**

## 低显存具体配置（逐行）

| 目标卡 | DiT + 文本编码器 | 编码器位置 | 提示 / 去噪 / VAE 解码 | 峰值 | 结果 |
| --- | --- | --- | --- | --- | --- |
| **8 GB** | GGUF Q4_K_M + GGUF Q4_K_M + 分块 VAE 解码 | **在 CPU** | 0.6 / 4.5 / 4.5 GB | **6.1–6.9 GB** | **Fits** |
| 8 GB | GGUF Q5_K_M + GGUF Q4_K_M + 分块 VAE 解码 | 在 CPU | 0.6 / 5.6 / 5.6 GB | 7.2–8.0 GB | Tight |
| 8 GB | GGUF Q3_K_M + GGUF Q3_K_M | 全在 GPU | 7.4 / 7.4 / 7.4 GB | 9.5–12.1 GB | **No**（**RTX 3070 8GB 在 VAE 解码阶段 OOM**） |
| **12 GB** | GGUF Q8_0 + GGUF Q4_K_M + 分块 VAE 解码 | **在 CPU** | 0.6 / 7.7 / 7.7 GB | **9.3–10.1 GB** | **Fits** |
| **12 GB** | GGUF Q4_K_M + GGUF Q4_K_M | 提示后卸载 | 5.3 / 4.5 / 4.5 GB | **7.4–10.0 GB** | **Fits** |
| 12 GB | INT8 ConvRot + FP8 | 提示后卸载 | 9.4 / 7.4 / 7.4 GB | **11.5–14.1 GB** | **Tight** |
| 16 GB | INT8 ConvRot + INT8 ConvRot | 提示后卸载 | 9.3 / 7.4 / 7.4 GB | 11.4–14.0 GB | Fits |
| 16 GB | GGUF Q6_K + GGUF Q4_K_M | 全在 GPU | 11.2 GB | 13.3–15.9 GB | Fits |
| 16 GB | GGUF Q4_K_M + INT8 ConvRot | 全在 GPU | 13.2 GB | 15.3–17.9 GB | Tight |

**工作内存**（文本编码器在 CPU 时）实测 **1.6–2.4 GB**，需叠加在上面权重之上。

## 12 GB 显存（RTX 5070 等）怎么选

> 本机 GPU 为 **NVIDIA GeForce RTX 5070，12,820,938,752 字节 ≈ 11.94 GB**，
> 属于下表的 **12 GB** 档。以下为针对该档的结论。

| 方案 | 判断 |
| --- | --- |
| ComfyUI 官方模板默认组合（INT8 DiT + INT8 编码器**全驻留**） | **跑不动**（峰值 18.2–20.8 GB） |
| INT8 DiT + INT8 编码器，**编码器用完卸载** | **Tight**，11.4–14.0 GB，压线可试 |
| INT8 ConvRot DiT + **FP8** 编码器，编码器卸载 | **Tight**，11.5–14.1 GB |
| **GGUF Q4_K_M DiT + Q4_K_M 编码器**，编码器用完卸载 | **Fits**，7.4–10.0 GB，余量较足 |
| **GGUF Q8_0 DiT + Q4_K_M 编码器在 CPU** + 分块 VAE 解码 | **Fits**，9.3–10.1 GB，画质更好 |
| GGUF Q4_K_M，**编码器整个放 CPU** | **Fits**，6.1–6.9 GB，最省，但最慢 |

**实用建议**：12 GB 上优先走 **GGUF 量化 + 文本编码器不常驻显存** 的路线，
并且**开启分块 VAE 解码（tiled VAE decode）** —— 8 GB 那行 OOM 正是发生在 **VAE 解码阶段**，不是去噪阶段。

## ⚠️ Windows 上的假象

ModelVRAM 用一个小节专门警告这件事，标题就是
**"On Windows, 'runs on 8 GB' can mean 18 GB"**：

> NVIDIA 的 Windows 驱动会把装不下的部分挪进共享系统内存，而不是让任务失败
> （**System Memory Fallback**，自驱动 **536.40** 起）。
> 于是**任务能跑完，但实际是从系统内存上跑的。**

后果：显存不足**不会报错**，只会变得极慢。
在 Windows 上判断"能不能跑"，看峰值数字，不要看"它有没有跑完"。

## 速度基准

官方 ComfyUI 文档在 RTX 5090 上的实测（同一张 3000×4000 参考图的编辑）：

| 画布 | 像素量 | 速度 |
| --- | --- | --- |
| 3008×4000 | 约 12 MP | **约 6 s/it** |
| 896×1184 | 约 1 MP | **约 0.3 s/it** |

配合步数看：**简单局部编辑 4–8 步就够**（换一件衣服的颜色），
重写整幅画面的编辑需要走满 **25 步**。
所以"编辑慢"通常是**画布太大**，不是步数太多。

## 官方提供的内存优化手段

```python
pipe = QwenImage21Pipeline.from_pretrained(
    "Qwen/Qwen-Image-2.1", torch_dtype=torch.bfloat16
)
pipe.enable_model_cpu_offload()
```

官方 README 只有这一条，针对 "GPUs with limited memory"。

ComfyUI 侧对应的省显存手段：

1. **用 `int8_convrot` 权重**（模板默认就是这个）而不是 `bf16`。
2. **KV cache 节点**的 `dtype` 设 `int8`（缓存减半，精度约等于 bf16）或 `int4`（四分之一，但误差翻倍）；
   `device` 设 `cpu` 用内存换显存，官方说速度损失很小。
3. **降低编辑画布** —— `resolution` 控件是最有效的单项杠杆。

## 量化与加速生态（社区）

| 方案 | 说明 |
| --- | --- |
| **GGUF**（`unsloth/Qwen-Image-2.1-GGUF`） | 谱系最全，Q2_K → Q8_0；Q4_K_M 是常用平衡点 |
| **INT4ConvRot 套件**（`chfm/Qwen-Image-2.1-INT4ConvRot-ComfyUI`） | 面向 ComfyUI 的一体化包，含 int4 ConvRot 的 DiT + 文本编码器，**标注适配 8–12 GB 显存** |
| **FP8** | 最接近 bf16 的"免调"降级方案 |
| **Viggle Turbo**（`Viggle/Qwen-Image-2.1-viggle-turbo`） | 官方 turbo 蒸馏 + LoRA 变体，**4 步出图** |
| **MLX**（Apple Silicon） | MLX 4bit；1024×1024 可用，**2048×2048 尚不支持** |
| vLLM-Omni / SGLang / LightX2V | 官方 Day-0 支持的服务化推理，含 FP8 量化、prefix KV cache、CUDA Graph、多卡并行 |

## 其他平台的实测提醒

- 社区 Colab notebook：**L4 22 GB 可用；T4 16 GB 会因为设计而 OOM**。
- 8 GB 的 RTX 3070 在"全部驻留显存"配置下 **OOM 发生在 VAE 解码**。
- 本机若显卡同时带显示器，**峰值预算要再加 0.5–1 GB**。
