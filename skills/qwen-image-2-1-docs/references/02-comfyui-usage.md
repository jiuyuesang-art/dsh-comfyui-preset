# ComfyUI 使用方式

来源：
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档，主来源）
- `https://huggingface.co/Comfy-Org/Qwen-Image-2.1`（Comfy-Org 重打包模型卡）
- `https://blog.comfy.org/p/qwen-image-21-in-comfyui-open-weight`（ComfyUI 官方博客）

抓取日期：2026-10-03

## 前置条件

- **把 ComfyUI 更新到最新版本**。官方原文：
  "Workflows in this guide can be found in the Workflow Templates. If you can't find them in the template,
  your ComfyUI may be outdated."
- 加载工作流若提示节点缺失，官方给出的两个原因是：
  1. 不是最新版 ComfyUI（**Nightly** 版本）；
  2. 某些节点在启动时导入失败。

## 三个官方模板

模板面板搜索 **"Qwen-Image-2.1"** 即可找到。三者在 ComfyUI 官方模板库中的名字是：

| 模板名 | 用途 | 工作流 JSON |
| --- | --- | --- |
| `image_qwen_image_2_1_t2i` | **文生图**。按所选宽高比与兆像素目标从文本提示词生成图像 | `https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_t2i.json` |
| `image_qwen_image_2_1_image_edit` | **图像编辑**。用指令编辑图像；需要源图里没有的内容时可加参考图 | `https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_image_edit.json` |
| `image_qwen_image_2_1_background_removal` | **抠图/去背景**。复用图像编辑子图，固定提示词 `Remove the background, and output a PNG image`，并把结果与原图对比 | `https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_background_removal.json` |

> `image_qwen_image_2_1_background_removal` **不包含**提示词增强步骤（另外两个模板有）。

### 图像编辑模板的输入素材

把下面两个文件上传到对应的 `LoadImage` 节点：

| 文件 | 节点 |
| --- | --- |
| `portrait_model_denim.png` | `LoadImage` 节点 **470** |
| `clothing_light_blue_denim_shirt.png` | `LoadImage` 节点 **475** |

（文件可从 Comfy-Org/workflow_templates 仓库的 `input/` 目录下载。）

## 模型文件与目录结构

三个工作流**共用**同一个 diffusion model、VAE 和基础文本编码器。
文生图与图像编辑模板**各自额外**加载一个提示词增强文本编码器。

### 需要下载的文件

**text_encoders**（放到 `ComfyUI/models/text_encoders/`）

| 文件 | 用途 |
| --- | --- |
| `qwen3vl_8b_int8_convrot.safetensors` | **模板默认加载**，显存占用更低 |
| `qwen3vl_8b_bf16.safetensors` | 全精度，需要更多显存 |
| `qwen3vl_8b_w4a8.safetensors` | 更低比特的文本编码器（社区整理中列出，体积约 6.31 GB） |
| `qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors` | **文生图模板**的提示词增强编码器 |
| `qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors` | **图像编辑模板**的提示词增强编码器 |

**diffusion_models**（放到 `ComfyUI/models/diffusion_models/`）

| 文件 | 用途 |
| --- | --- |
| `qwen_image_2.1_int8_convrot.safetensors` | **模板默认加载**，显存占用更低 |
| `qwen_image_2.1_bf16.safetensors` | 全精度，需要更多显存 |

**vae**（放到 `ComfyUI/models/vae/`）

| 文件 | 用途 |
| --- | --- |
| `qwen_image_2.1_vae_bf16.safetensors` | 唯一的 VAE 文件 |

**model_patches**（可选，放到 `ComfyUI/models/model_patches/`）

| 文件 | 说明 |
| --- | --- |
| `qwen_image_2.1_fun_controlnet_union_bf16.safetensors` | ControlNet Union。**注意**：这两行是阿里 PAI Union checkpoint 的重打包，**不是 Qwen 官方发布** |
| `qwen_image_2.1_fun_controlnet_union_int8_convrot.safetensors` | 同上，int8 版本体积减半 |

### 目录树（官方文档原文）

```
📂 ComfyUI/
├── 📂 models/
│   ├── 📂 text_encoders/
│   │      ├── qwen3vl_8b_int8_convrot.safetensors
│   │      ├── qwen3vl_8b_bf16.safetensors
│   │      ├── qwen3.5_9b_qwen_image_2.1_pe_t2i.int8_convrot.safetensors
│   │      └── qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors
│   ├── 📂 diffusion_models/
│   │      ├── qwen_image_2.1_int8_convrot.safetensors
│   │      └── qwen_image_2.1_bf16.safetensors
│   └── 📂 vae/
│          └── qwen_image_2.1_vae_bf16.safetensors
```

### 关于 `convrot` 格式

`*_convrot` 是 **ComfyUI 原生的旋转通道整数格式**。
用**标准的 diffusion-model 与 text-encoder 加载器**即可加载，**不需要任何自定义节点**。
需要较新的 ComfyUI 版本。

## 关键节点

| 节点 | 作用 |
| --- | --- |
| **Text Encode Qwen Image 2.1** | 文本/图像条件编码。图像输入槽会随填充展开，**最多 16 个槽**（`image_1` … `image_16`）。官方两个编辑模板接了前 **10** 个 |
| **Resolution Selector** | 文生图里设定宽高比 + 兆像素目标（1.0 MP ≈ 1024×1024） |
| **Image Edit 子图节点** | 编辑画布控制。带 `resolution` 控件（范围 `0`–`4096`，步长 `32`）与 `custom_size` 开关 |
| **Qwen Image 2.1 子图节点** | 提示词增强控制：`refine_prompt`、`PE_model`、`thinking_mode` |
| **Qwen Image 2.1 Cache** | KV cache 节点（**实验性**），控制缓存设备与精度 |
| **Preview Any** | 位于子图内，显示**真正送进图像模型的那段提示词**（增强后的结果） |
| **Text (System Prompt)** | 提示词增强模型所遵循的系统提示词，**可自行编辑** |
| **LoadImage** | 图像编辑模板中节点 **470**（`image_1`，被编辑的图）与 **475**（`image_2`，参考图） |

## 参考图的拼接顺序（重要）

- 参考图**按槽位顺序**被拼接进文本编码器。
- **`image_1` 是被编辑的那张图**，其余槽位提供内容。
- 提示词里**按序号引用**它们，写法是 `<image1>`、`<image2>` …
- 官方文档也提到 `Text Encode Qwen Image 2.1` 支持到 16 槽（`image_1`…`image_16`），
  而页面上的两个编辑模板接了前 10 个。ComfyUI 博客同样表述为 "最多 10 张"。

## 快速上手四步（ComfyUI 博客原文表述）

1. 更新 ComfyUI 到最新版。
2. 从 HuggingFace 下载 Qwen-Image-2.1 权重，放进 models 目录。
3. 从模板面板加载 Qwen-Image-2.1 模板。
4. 写提示词，把参考图挂到 `image_1` 及其后，运行。

## 无需自定义节点

ComfyUI 官方支持是 **Day-0 原生**的（原生节点 + 官方模板），
不需要安装额外插件。社区存在第三方增强节点包，但**非必需**。
