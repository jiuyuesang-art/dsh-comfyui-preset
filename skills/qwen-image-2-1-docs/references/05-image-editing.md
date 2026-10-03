# 图像编辑玩法

来源：
- `https://github.com/QwenLM/Qwen-Image-2.1`（官方 README：编辑能力、Showcase）
- `https://huggingface.co/Qwen/Qwen-Image-2.1`（官方模型卡）
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档：Mask Editor 流程、画布语义）

抓取日期：2026-10-03

## 核心机制：一个模型，两件事

Qwen-Image-2.1 的**同一份权重**同时承担文生图与指令式图像编辑，
因此**工作流不需要切换 checkpoint**。这是它相比"生成模型 + 编辑模型"两套权重的最大结构差异。

## 多图参考

| 项目 | 数值 |
| --- | --- |
| 官方支持参考图数量 | **最多 10 张** |
| ComfyUI `Text Encode Qwen Image 2.1` 节点槽位 | **16 个**（`image_1` … `image_16`），槽位随填充展开 |
| 官方两个编辑模板实际接线 | 前 **10** 个 |
| `image_1` 的角色 | **被编辑的那张主图** |
| 其余槽位的角色 | 提供内容（服装、道具、背景板、风格参考……） |

### 拼接方式

参考图**按槽位顺序拼接进文本编码器**，提示词里用 `<image1>`、`<image2>` 按序号引用。
ComfyUI 博客的描述是：所有参考图"都由文本编码器读取，并**作为 VAE latent 拼进序列**"。

### 官方示例结构（可直接抄）

```
Keep the character and pose in <image1> unchanged, put this light blue denim shirt from <image2> on the character, preserve the original facial features, hair, body shape and pose
```

适用场景举例（官方文档原话）：当编辑需要**源图里不存在的内容**时加参考图，
"比如把第二张照片里的衣服穿到第一张照片的人身上"。

多图合成的官方示例提示词：

```
These three characters are sitting around a campfire in a forest
```

## 能做什么（官方 Showcase 实测案例清单）

官方 README 的 Showcase 明确列出以下能力，每一项都配了示例图：

| 玩法 | 官方描述 |
| --- | --- |
| **原生透明生成** | 直接生成带 alpha 的 RGBA 图 |
| **多参考合影** | 用**六张单人肖像参考**合成一张合影 |
| **整套穿搭拼装** | 用**五张参考图（模特、服装、鞋、包、帽）**拼出一套完整穿搭 |
| **圈选引导的多区域编辑** | 一张图里同时：**去手表、改发色、换衣服** |
| **人像与商品保真** | 保持人物与商品的身份一致性 |
| **文字渲染** | 排版与密集文字 |
| **全景图** | **从一张自拍生成全景图** |
| **分镜（Storyboard）** | **从三视图角色参考生成分镜** |
| **抠图/去背景** | 见下方专节 |
| **透明图层编辑** | 编辑透明层；**从照片中提取主体** |

## 局部编辑的三种指定方式

官方 README 原文：可通过 **circles（圈选）、painted annotations（涂鸦标注）、separate masks（独立 mask）**
来指定局部编辑。

### ComfyUI 里怎么做（Mask Editor 流程）

官方文档给的具体步骤：

1. 在提供 `image_1` 的 `LoadImage` 节点上右键 —— 图像编辑模板中是**节点 470** ——
   选择 **Open in Mask Editor**。
2. 用 **Paint Pen** 涂出想修改的区域。
3. 保存。
4. **在提示词里点名标记的颜色**，例如 `change the jacket in the red area`。

**最容易搞错的一点**：Paint Pen 的笔迹**落在图像的 RGB 层，不是写进 mask**。
保存时做的是"把标注过的图写回节点"，于是**标注成为编辑读到的参考图的一部分**。
模型理解"改哪里"的方式，就是**看到图上那块颜色**。

两个注意：

- **标记要留在想改的区域内**（涂出去就会误伤）。
- **如果标记颜色出现在了输出里**，就在提示词里**同时说明你想要的颜色**。

## 抠图 / 去背景

ComfyUI 有独立模板 `image_qwen_image_2_1_background_removal`，做法是：

- **复用图像编辑子图**；
- 提示词固定为：
  ```
  Remove the background, and output a PNG image
  ```
- 把结果与原图并排对比；
- 模板自带的输入样例是 `angry_broccoli.png`（`LoadImage` 节点 470）；
- **该模板不含提示词增强步骤**。

底层能力来源：**VAE 有 4 个通道**，所以透明底是"生成出来就带 alpha"，
不需要额外的去背景节点或抠图模型。

## 编辑画布语义（影响成败的关键）

编辑结果画布由 **Image Edit 子图节点的 `resolution` 控件**决定（范围 `0`–`4096`，步长 `32`；
节点自身默认 `1024`，但**模板出厂值是 `0`**；`custom_size` 模板默认关闭）。

| 设定 | 行为 |
| --- | --- |
| `resolution` = **0** | 每张参考图**保持自己的像素尺寸**，圆整到 32 的倍数。3000×4000 的照片 → **3008×4000** |
| `resolution` > **0** | 按 `image_1` 的宽高比缩放到 **`resolution` × `resolution` 的像素预算**（**总像素数，不是宽也不是高**）。同一张照片在 `resolution` 1024 时 → 约 **896×1184** |
| `custom_size` **打开** | 画布改由 **Resolution Selector** 决定。**必须保持接近缩放后的 `image_1` 尺寸，否则编辑会位移** |

## 速度特征

官方 RTX 5090 数据（同一张 3000×4000 参考图）：

| 画布 | 像素量 | 速度 |
| --- | --- | --- |
| 3008×4000 | 约 12 MP | **约 6 s/it** |
| 896×1184 | 约 1 MP | **约 0.3 s/it** |

→ **降低 `resolution` 是让输出变小来提速，不是加细节。**
编辑感觉慢时，**先查 `resolution` 和参考图的像素尺寸**，再考虑动别的参数。

## 编辑相关的加速与缓存

- **prefix KV cache**：输入图像与文本指令**只在第一步去噪时算一次**，之后复用。
  官方说明这对**多条件图的编辑**提速尤其显著。
- ComfyUI 侧由 **Qwen Image 2.1 Cache 节点**控制（**实验性**），
  `device` 可选 `auto`/`gpu`/`cpu`/`off`，`dtype` 可选 `default`/`int8`/`int4`。
  详见 `03-parameters.md`。
- **简单局部编辑 4–8 步就够**（例如改一件衣服的颜色），比默认快好几倍；
  **重写整个画面的编辑**会失去连贯性，需要走满 25 步。

## 编辑的常见限制

| 限制 | 来源 |
| --- | --- |
| 多张大参考图会**进一步拖慢**编辑 | ComfyUI 官方文档 |
| `custom_size` 画布偏离缩放后的 `image_1` → 编辑**位移** | ComfyUI 官方文档 |
| 目标远高于 2K 训练尺寸（如 **4K**）→ **损失提示词遵循度** | ComfyUI 官方文档 |
| KV cache 节点是**实验性**的；`int4` 每步误差约翻倍 | ComfyUI 官方文档 |
| 参考图上限：官方 10 张 / 节点 16 槽 | 官方 README / ComfyUI 官方文档 |
| Qwen 官方**未发布**编辑能力的缺陷清单 | —— 见 `07-limitations.md` |

## diffusers 侧的编辑调用（对照参考）

```python
input_image = Image.open("input.png")

image = pipe(
    prompt="Change the background to a sunset beach",
    image=input_image,
    num_inference_steps=40,
    generator=torch.Generator("cuda").manual_seed(42),
).images[0]
```

多参考图版本是把 `image=` 换成**图像列表**：

```python
images = [Image.open(f"ref_{i}.png") for i in range(3)]

result = pipe(
    prompt="These three characters are sitting around a campfire in a forest",
    image=images,
    num_inference_steps=40,
).images[0]
```
