# 提示词指南

来源：
- `https://huggingface.co/Qwen/Qwen-Image-2.1`（官方模型卡：RGBA 推荐提示词模板）
- `https://github.com/QwenLM/Qwen-Image-2.1`（官方 README：示例提示词、prompt rewriting 章节）
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档：编辑类提示词写法）
- `https://github.com/wildminder/awesome-qwen-image`（社区整理：中文提示词、diffusers 坑位）

抓取日期：2026-10-03

## 最重要的三条官方写法

### 1. 透明底图必须用官方模板句

官方明确要求：生成透明图像时**使用推荐的提示词格式**：

```
This is an RGBA image with transparency. <你的描述>. The image has alpha channel and the background is transparent.
```

官方给的完整示例（逐字）：

```
This is an RGBA image with transparency. A cute cartoon dragon sticker. The image has alpha channel and the background is transparent.
```

→ 换句话说：**"生成透明背景"不是靠参数开关，而是靠提示词里这两句固定话术。**
少了这两句，即使 VAE 支持 4 通道，模型也不一定给你 alpha。

### 2. 多参考图用 `<imageN>` 按序号引用

参考图**按槽位顺序**被拼接进文本编码器，提示词里用尖括号序号指向它们：

| 槽位 | 提示词里的写法 | 角色 |
| --- | --- | --- |
| `image_1` | `<image1>` | **被编辑的那张主图** |
| `image_2` | `<image2>` | 提供内容（如服装、道具） |
| … | `<imageN>` | 依次类推 |

官方逐字示例：

```
Keep the character and pose in <image1> unchanged, put this light blue denim shirt from <image2> on the character, preserve the original facial features, hair, body shape and pose
```

这个例子的结构值得直接抄：

1. **先声明要保留什么** —— `Keep the character and pose in <image1> unchanged`
2. **再说明从哪张图取什么** —— `put this light blue denim shirt from <image2>`
3. **最后再强调一遍要保持的东西** —— `preserve the original facial features, hair, body shape and pose`

### 3. 文字渲染：把要显示的字直接写进提示词并加引号

官方文生图示例本身就是文字渲染用例：

```
A neon shop sign that reads "QWEN IMAGE 2.1", rainy night, reflections on wet pavement
```

要点：**要渲染的文字用引号包起来**，并用 `reads "..."` / 类似动词明确指出这是画面中的文字内容。
模型强项就是**密集小字与复杂排版**（infographics、幻灯片、UI mockup、海报、包装设计）。

## 提示词增强（官方推荐做法）

官方原话：为了拿到最好的效果，**推荐使用官方的 prompt rewriting 模型**把短提示词扩写成详细、高质量的描述。

- 两个 fine-tuned **Qwen3.5-VL 9B** checkpoint，分别对应文生图与图像编辑，
  共享同一套代码库，**按输入自动判别模式**。
- 权重仓库：`Qwen/Qwen-Image-2.1-PE-T2I`（文生图）、`Qwen/Qwen-Image-2.1-PE-I2I`（图像编辑）。
- 代码在官方仓库的 `prompt_rewrite/` 目录。

### 它输出什么

文生图输出：

```json
{
  "rewritten_prompt": "<long detailed English prompt>",
  "wh_ratio": "16:9"
}
```

- `wh_ratio` —— 模型**自己挑了一个宽高比**（可直接映射到官方尺寸表）。
- `ratio_follow` —— （编辑侧）输出**继承指定输入图的宽高比**，例如 `"<image1>"`。

### 怎么跑

```bash
cd prompt_rewrite
pip install -r requirements.txt

# vLLM 批处理（规模大时推荐）
python run_vllm.py --task t2i \
    --ckpt Qwen/Qwen-Image-2.1-PE-T2I \
    --input data/t2i_example.jsonl --output out.jsonl

# 或本地 transformers
python run_transformers.py --task t2i \
    --ckpt Qwen/Qwen-Image-2.1-PE-T2I \
    --input data/t2i_example.jsonl --output out.jsonl
```

编辑模式把 `--task` 换成 `edit`，checkpoint 换成 `Qwen/Qwen-Image-2.1-PE-I2I`。

编辑侧的输入格式（JSONL）：

```json
{"id": "abc123", "prompt": "make the sky sunset", "input_images": ["images/photo.png"]}
```

### 在 ComfyUI 里用

文生图与图像编辑模板都内置了增强分支（抠图模板没有）：

- `refine_prompt` —— **默认关闭**。打开后图像模型用**改写后的提示词**采样。
- `PE_model` —— 执行改写的编码器：文生图 `qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors`，
  编辑 `qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors`。
- `thinking_mode` —— **默认关闭**。与 `refine_prompt` 一起打开，让改写模型先推理再动笔。
- **`Preview Any` 节点**显示真正送进图像模型的那段提示词 —— 先读再决定要不要用。
- 改写模型遵循的指令放在 **`Text (System Prompt)` 节点**里，**可以自己改**。

## 中文提示词

**中文提示词可以原生使用。** 官方的 PE（prompt enhancement）模型负责把中文短句改写成详细英文提示词。
→ 实践中：直接写中文就能出图；如果想要更好的效果，用 PE 模型把中文扩写成英文再喂给主模型。

## 图像编辑类提示词（指令式）

编辑提示词应当写成**明确的指令句**，而不是描述句。官方示例：

```
Change the background to a sunset beach
```

```
These three characters are sitting around a campfire in a forest
```

```
Remove the background, and output a PNG image
```

### 局部编辑：先标记，再在提示词里点名标记颜色

官方做法（ComfyUI）：

1. 在提供 `image_1` 的 `LoadImage` 节点（图像编辑模板中为**节点 470**）上右键 →
   **Open in Mask Editor**。
2. 用 **Paint Pen** 涂出想修改的区域，保存。
3. **在提示词里点名这个标记的颜色**，例如 `change the jacket in the red area`。

**关键机制**：Paint Pen 的笔迹**落在图像的 RGB 层，而不是 mask 里**。
所以保存时的效果是"把标注过的图写回节点"，**标注本身成为编辑所读参考图的一部分**。
模型是通过"看到图上有一块红色"来理解你指的是哪里的。

两个注意事项：

- **标记要留在想修改的区域内部。**
- **如果标记的颜色本身出现在了输出里**，那就在提示词里同时说明你想要的颜色。

## 提示词相关的其他要点

| 要点 | 说明 |
| --- | --- |
| CFG 1 时负向提示词无效 | 见 `03-parameters.md`；这是官方发布路径，别在负向词上花力气 |
| 密集文字/小字/数字 | 把 cfg 提到 **2** 会更贴合，代价是边缘过锐 |
| 提示词遵循度与分辨率 | 目标远高于 2K 训练尺寸（如 4K）会**损失提示词遵循度** |
| 编辑提速 | 简单局部编辑（如换一件衣服的颜色）**4–8 步**即可 |
| PE 模型体积 | 官方 BF16 权重各约 **18.82 GB**；ComfyUI 的 int8_convrot 版本各约 **9.47 GB** |
