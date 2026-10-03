# 参数与推荐值

来源：
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档，主来源）
- `https://huggingface.co/Qwen/Qwen-Image-2.1`（官方模型卡，默认参数表）
- `https://github.com/QwenLM/Qwen-Image-2.1`（官方 README，diffusers / SGLang 调用示例）

抓取日期：2026-10-03

## 采样参数一览

三个官方工作流**全部**使用：

| 参数 | 值 |
| --- | --- |
| `steps` | **25**（模板值） |
| `cfg` | **1** |
| sampler | **euler** |
| scheduler | **simple** |

官方 README / 模型卡侧的默认值：

| 参数 | 默认 | 说明 |
| --- | --- | --- |
| `num_inference_steps` | **40** | 官方推荐步数 |
| `width` / `height` | **2048 × 2048** | 原生 2K |
| `guidance-scale`（SGLang 示例） | **1** | 与 ComfyUI 的 cfg 1 一致 |

> **差异说明**：官方发布的推理管线（published pipeline）用 **约 40–50 步 + euler**，
> 而 ComfyUI 模板从 **25 步**起步。两者不矛盾，是"发布配置"与"模板默认"的区别。

## CFG（最关键的一个参数）

**在 `cfg` 1 时，ComfyUI 会跳过负向条件计算，因此负向提示词对这三个工作流完全无效。**
模板保持 `cfg` 1，因为**这正是 Qwen-Image-2.1 发布的原始路径**；只有当你确实想让负向提示词生效时才提高它。

官方给出的各档位行为：

| cfg | 行为 |
| --- | --- |
| **1**（默认） | 官方发布路径；不跑负向条件，**负向词无效** |
| **2** | **更贴合密集提示词**，包括**小字和数字**；代价是**边缘过锐（over-sharpened edges）** |
| 更高 | 曝光向**过亮或过暗**偏移 |
| **5** | **画质严重崩坏**（degrades quality badly） |
| **0.5** | **直接出废图**（breaks the image） |

官方建议：**一次只改一个值，并固定种子做对比。**

## 步数（steps）

- **发布管线的推荐区间**：约 **40–50 步**（euler）。
- **简单局部编辑**在 **4–8 步**就能站得住 —— 例如"改一件衣服的颜色"这类请求会比默认值快好几倍。
- **重写整个画面的编辑**会失去连贯性，需要走满 **25 步**。
- **顽固的细节（手、手指）大约在 30 步左右稳定下来**。
- **从 25 步提到 40 步可以减少细节区域的"融化/fizzle"**。
- 官方建议：**只在某个具体东西确实没解出来时才调 steps**。

## 分辨率

### 文生图

**Resolution Selector 节点**同时设定宽高比和一个**兆像素（MP）目标**，其中 **1.0 MP 约等于 1024×1024**。

- Qwen-Image-2.1 原生 2K，所以想得到 **2048×2048** 就把目标设到 **约 4.0 MP**。

### 图像编辑（画布语义，容易搞错）

画布由 **Image Edit 子图节点上的 `resolution` 控件**决定：

| 项目 | 值 |
| --- | --- |
| 范围 | `0` – `4096` |
| 步长 | `32` |
| 节点自身默认 | `1024` |
| **模板实际出厂值** | **`0`** |
| `custom_size` | 模板默认**关闭** |

`custom_size` **关闭**时（模板默认），编辑结果按**第一张参考图 `image_1` 的尺寸**生成：

- **`resolution` = 0**：每张参考图**保持自己的像素尺寸**，圆整到 32 的倍数。
  例：一张 3000×4000 的照片 → 画布 **3008×4000**。
- **`resolution` > 0**：把 `image_1` 的宽高比缩放到一个 **`resolution` × `resolution` 的像素预算**。
  注意这是**总像素数**，**不是宽或高**。同样那张照片在 `resolution` = 1024 时约得 **896×1184**。

`custom_size` **打开**时，画布改由 **Resolution Selector** 决定；
官方提醒：要保持它**接近缩放后的 `image_1` 尺寸**，否则编辑会**发生位移（shift）**。

### 画布尺寸 = 成本

官方给的 RTX 5090 实测对比：

| 画布 | 像素量 | 速度 |
| --- | --- | --- |
| 3008×4000 | 约 12 MP | **约 6 s/it** |
| 896×1184 | 约 1 MP | **约 0.3 s/it** |

**降低 `resolution` 是让结果变小来提速，不是增加细节。**
如果一次编辑感觉很慢，**先检查 `resolution` 和参考图的像素尺寸**，再考虑动别的参数。
多张大参考图会进一步拖慢编辑，KV cache 设置也会影响这个开销。

> 超出模型 2K 训练尺寸很多的目标（例如 **4K**）会**损失提示词遵循度（prompt adherence）**。

## KV cache 节点（实验性）

编辑工作流包含 **Qwen Image 2.1 Cache** 节点，它在采样步之间把**缓存的文本与参考前缀**留在内存里。
模板默认值对大多数配置都适用。它暴露两个控件：

### `device`

| 值 | 效果 |
| --- | --- |
| `auto`（默认） | 先用空闲显存，再用内存 |
| `gpu` | 固定用显存 |
| `cpu` | 用内存（RAM），在计算背后预取，**速度损失很小** |
| `off` | 每步重算前缀，更慢；**排障时用它来排除缓存因素** |

### `dtype`

| 值 | 效果 |
| --- | --- |
| `default`（默认） | **无损** |
| `int8` | 缓存**减半**，精度**约等于 bf16** |
| `int4` | 缓存**降到四分之一**，但**每步误差大约翻倍** |

## 提示词增强（可选）

文生图与图像编辑模板都带一个**可选的提示词增强步骤**：用一个专用文本编码器**先把提示词改写**，
把一句短请求变成更长、更详细的描述。

两个模板都在 **Qwen Image 2.1 子图节点**上暴露这些控件：

| 控件 | 默认 | 说明 |
| --- | --- | --- |
| `refine_prompt` | **关闭**（两个模板都是） | 打开后，图像模型会用**改写后的提示词**采样，而不是你输入的原文 |
| `PE_model` | — | 执行改写的文本编码器：文生图用 `qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors`；编辑用 `qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors` |
| `thinking_mode` | **关闭**（两个模板都是） | 与 `refine_prompt` **一起**打开时，让改写模型在动笔前先推理 |

要点：
- 子图内的 **`Preview Any` 节点会显示真正送进图像模型的提示词**，可以先读改写结果再决定要不要用。
- 改写模型遵循的指令存在一个 **`Text (System Prompt)` 节点**里，**你可以编辑它**。
- 因为增强分支**只在 `refine_prompt` 打开时才会被求值**，所以这个文本编码器在两个模板里都是**可选的**。
- **抠图模板没有这个步骤。**

## diffusers 侧的参数注意（官方 README / 社区整理）

| 事项 | 说明 |
| --- | --- |
| CFG 关键字 | 是 **`true_cfg_scale`**，**不是** `guidance_scale`；且需要同时给 `negative_prompt` 才会生效 |
| 宽高约束 | **必须是 32 的倍数，最大边 2048** |
| CPU offload | 使用 `enable_model_cpu_offload()` 时，generator 应该放在 **`'cpu'`** 上 |
| 默认采样 | **40 步、无 CFG**；加 CFG 会改变观感，别默认认为步数越多越好 |
| 安装 | `QwenImage21Pipeline` 需要 diffusers **`main`** 分支，release `0.40.0` 没有它 |
| 依赖 | `torch>=2.4.0`、`transformers>=5.17`、diffusers（git main）、accelerate、pillow |

## 官方 diffusers 参考调用

```python
image = pipe(
    prompt="A neon shop sign that reads \"QWEN IMAGE 2.1\", rainy night, reflections on wet pavement",
    width=2048, height=2048,
    num_inference_steps=40,
    generator=torch.Generator("cuda").manual_seed(42),
).images[0]
```

## 关于 shift

官方文档、模型卡与 README **均未把 `shift` 列为用户可调参数**。
调度侧只说明使用 **Flow Matching + Euler discrete scheduling + dynamic shifting**
（即 shift 是调度策略的一部分，原文未给出可调数值）。
→ **本快照不提供 shift 推荐值，因为没有可核实的官方数字。**

（社区旁证：ComfyUI-AlphaTrace 节点包建议对 2.1 传入 LTXVScheduler 作为 `sigmas`，参数为
`max_shift` 0.69、`base_shift` 0.54、`stretch` 开、`terminal` 0.02，用于对齐官方调度。
此为非官方来源，仅供参考。）
