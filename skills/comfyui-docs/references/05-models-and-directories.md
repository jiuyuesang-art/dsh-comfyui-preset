# 模型文件与目录结构

> 来源：https://docs.comfy.org/basic-concepts/models
> 来源：https://docs.comfy.org/installation/system_requirements
> 来源：https://docs.comfy.org/troubleshooting/model-issues
> 来源：https://docs.comfy.org/development/comfyui-server/startup-flags （只取与目录/模型/显存相关的参数）
> 抓取日期：2026-10-03

## 一句话结论

**模型（model）= 真正让工作流跑起来的权重文件**，包括 checkpoints、VAEs、LoRAs、ControlNets、upscalers。**ComfyUI 的应用安装包很小，这些模型文件默认不包含**——你需要自己从网上下载，放进 **`ComfyUI/models/`** 下对应类型的子目录（或按模板的提示操作），然后在对应的**加载节点（loader node，画布上名字常以 `Load` 开头）**里选中这个文件。

> 想用 `ComfyUI/models` 之外的模型目录，靠 **`extra_model_paths.yaml`**（或 Desktop 的 **Storage** 标签页）——见下文。

## 官方对「支持哪些模型」的三条限定（很重要，先读）

1. **内置/一方（first-party）覆盖是有意保持有限的**，但会随 ComfyUI 与开源生态演进而增长。当某个模型获得一方支持时，**通常会在[工作流模板库](https://docs.comfy.org/interface/features/template)里新增一条**，展示预期的图结构与模型搭配。
2. **不是每个 checkpoint 或权重文件都能开箱即用。** 对一方支持的模型及其常见配套权重：**保持 ComfyUI 最新**，并**先在模板库里确认存在匹配的工作流**，再去怀疑文件放错了位置。
3. **还有很多模型是靠社区自定义节点启用的。** 它们的路径、加载节点、图布局可能与本文档通用的 `ComfyUI/models/` 指引不同——**一律以各项目自己的 README 或文档为准**。ComfyUI 高度可扩展，不同作者的实现各不相同。

## 怎么用模型（官方四步）

1. **把文件放到正确位置**：从 [Hugging Face](https://huggingface.co)、[Civitai](https://civitai.green) 或项目的 GitHub 页下载，放进 `ComfyUI/models/` 下**对应类型的子文件夹**（例如 `checkpoints`、`loras`、`vae`）。
2. **加上匹配的加载节点**：按模型类型选 loader（checkpoint、LoRA、VAE 等）。**节点列表里标题通常以 `Load` 开头。**
3. **在 loader 节点的下拉框里选中该文件。**
4. **把 loader 节点接到图里其余部分。** ⚠️ 如果你是在 **ComfyUI 已经打开时手工拷进去的**文件，**要重启**应用（或按需刷新），列表才会更新。

> **预期大文件**：单个生成模型经常是**好几 GB**。下载或同步时要预留磁盘空间与时间。

## 主 checkpoint 之外的「小助手模型」

主扩散 checkpoint 承担大部分工作，但很多工作流还会加**更小的辅助模型**：

| 类型 | 作用 |
|---|---|
| **LoRA** | 轻量附加件，针对某个风格、角色或概念调优 |
| **ControlNet** | 用边缘、深度、姿态等提供额外引导 |
| **Inpainting** | 填充或替换已有图像内的区域 |

## 卸载模型

**UI 里目前还没有「卸载」按钮。** 要移除模型，**直接把它从 `ComfyUI/models/` 下你放它的那个文件夹里删掉**。

## `models/` 目录结构

> ⚠️ **官方没有单独给出一张「models 全目录表」**。下面的清单是把官方三处内容合并后的结果，**每行都标了出处**，没有编造。

| 目录 | 放什么 | 出处 |
|---|---|---|
| `checkpoints/` | 主 checkpoint（完整生成模型） | models 页、model-issues 路径清单、`extra_model_paths` 示例 |
| `loras/` | LoRA 附加件 | 同上 |
| `vae/` | VAE 模型 | 同上 |
| `controlnet/` | ControlNet 模型 | 同上 |
| `embeddings/` | textual inversion / embeddings | model-issues 路径清单、`extra_model_paths` 示例 |
| `clip/` | 文本编码器权重 | `extra_model_paths.yaml.example` 的 `comfyui:` 段 |
| `clip_vision/` | CLIP vision 权重 | 同上 |
| `configs/` | 模型配置文件 | 同上 |
| `diffusion_models/`（也写作 `unet/`） | 扩散/UNet 主体权重 | 同上（示例里写作 `models/diffusion_models` 与 `models/unet` 两个路径） |
| `upscale_models/` | 放大模型（如 RealESRGAN、SwinIR、ESRGAN） | 同上 |
| `gligen/` | GLIGEN 权重 | `extra_model_paths.yaml.example` 的 `other_ui:` 段 |
| `hypernetworks/` | hypernetwork 权重 | 同上示例的 `a111:` 段 |

**另外两个与目录相关的位置**（非 `models/` 下）：

- **`custom_nodes/`** —— 自定义节点的**默认安装目录**：`ComfyUI/custom_nodes`。
- **`ComfyUI/models/` 之外**还有输入/输出/临时目录（`input`、`output`、`temp`、`user`），它们的根由 `--base-directory` 决定，见下方参数表。

### 支持的模型文件格式

> ⚠️ **官方该页未覆盖。** `basic-concepts/models` **没有给出支持的模型文件格式清单**（没有列举 `.safetensors` / `.ckpt` / `.pt` / `.gguf` 的官方支持矩阵）。官方只在 `extra_model_paths.yaml.example` 的示例里用了 `.safetensors` 作为文件名后缀示例。
>
> **唯一明确的一条格式结论**：**ComfyUI 不原生支持 GGUF 格式模型**。要用 GGUF，需要安装社区自定义节点，例如 [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF)。
>
> 需要完整的格式支持矩阵时，请用 `web_fetch` 查官方最新页面或用本机 `object_info` 看各 loader 节点的实际可选值。

## 添加额外模型路径（`extra_model_paths.yaml`）

**为什么需要**（官方列的三条理由）：

- 你有**多个 ComfyUI 实例**，想让它们**共享模型文件以省磁盘**；
- 你有**不同种类的 GUI 程序**（例如 WebUI），想让它们**用同一批模型文件**；
- **模型文件无法被识别或找不到**。

### 配置文件在哪

**Portable / 手动安装**：ComfyUI 根目录里有示例文件 `ComfyUI/extra_model_paths.yaml.example`。**复制并重命名为 `extra_model_paths.yaml`** 使用，**必须留在 ComfyUI 根目录**（`ComfyUI/extra_model_paths.yaml`）。示例文件在线版：<https://github.com/Comfy-Org/ComfyUI/blob/master/extra_model_paths.yaml.example>

**Comfy Desktop**：点桌面 app **顶部的 capsule 菜单**，打开 **Storage** 标签页，在那里添加模型目录。（**capsule 只在桌面 app 中存在，浏览器里跑 ComfyUI 时没有。**）也可以直接编辑：

| 系统 | 路径 |
|---|---|
| Windows | `C:\\Users\\YourUsername\\AppData\\Roaming\\ComfyUI\\extra_models_config.yaml` |
| macOS | `~/Library/Application Support/ComfyUI/extra_models_config.yaml` |

**文件要保持在同一目录，不要搬到别处。** 文件不存在就用任意文本编辑器自己建一个。

### 写法示例

假设你要把这样一个目录加进来：

```
📁 YOUR_PATH/
  ├── 📁models/
  |   ├── 📁 loras/
  |   │   └── xxxxx.safetensors
  |   ├── 📁 checkpoints/
  |   │   └── xxxxx.safetensors
  |   ├── 📁 vae/
  |   │   └── xxxxx.safetensors
  |   └── 📁 controlnet/
  |       └── xxxxx.safetensors
```

**写法 A**（`base_path` 指向 `models/` 的上一级）：

```yaml
my_custom_config:
    base_path: YOUR_PATH
    loras: models/loras/
    checkpoints: models/checkpoints/
    vae: models/vae/
    controlnet: models/controlnet/
```

**写法 B**（`base_path` 直接指向 `models/`）：

```yaml
my_custom_config:
    base_path: YOUR_PATH/models/
    loras: loras
    checkpoints: checkpoints
    vae: vae
    controlnet: controlnet
```

> ⚠️ **Desktop 版警告**：请把配置**加到已有配置路径里**，**不要覆盖安装时生成的路径配置**；改之前**先备份**该文件，改错了还能恢复。

**改完必须重启 ComfyUI 才生效。**

### 官方原始示例（`extra_model_paths.yaml.example` 全文对照）

```yaml
#Rename this to extra_model_paths.yaml and ComfyUI will load it

#config for a1111 ui
#all you have to do is change the base_path to where yours is installed
a111:
    base_path: path/to/stable-diffusion-webui/

    checkpoints: models/Stable-diffusion
    configs: models/Stable-diffusion
    vae: models/VAE
    loras: |
         models/Lora
         models/LyCORIS
    upscale_models: |
                  models/ESRGAN
                  models/RealESRGAN
                  models/SwinIR
    embeddings: embeddings
    hypernetworks: models/hypernetworks
    controlnet: models/ControlNet

#config for comfyui
#your base path should be either an existing comfy install or a central folder where you store all of your models, loras, etc.

#comfyui:
#     base_path: path/to/comfyui/
#     # You can use is_default to mark that these folders should be listed first, and used as the default dirs for eg downloads
#     #is_default: true
#     checkpoints: models/checkpoints/
#     clip: models/clip/
#     clip_vision: models/clip_vision/
#     configs: models/configs/
#     controlnet: models/controlnet/
#     diffusion_models: |
#                  models/diffusion_models
#                  models/unet
#     embeddings: models/embeddings/
#     loras: models/loras/
#     upscale_models: models/upscale_models/
#     vae: models/vae/

#other_ui:
#    base_path: path/to/ui
#    checkpoints: models/checkpoints
#    gligen: models/gligen
#    custom_nodes: path/custom_nodes
```

**具体例子**：如果你的 WebUI 位于 `D:\\stable-diffusion-webui\\`，把 `a111` 段的 `base_path` 改成该路径即可。

> 注意 `loras`、`upscale_models`、`diffusion_models` 用了 YAML 的 `|` 块标量来**写多个路径**（一行一个）。

### 添加额外的自定义节点路径

除了外部模型，**你也可以添加不在 ComfyUI 默认路径下的自定义节点路径**：

```yaml
my_custom_nodes:
  custom_nodes: /Users/your_username/Documents/extra_custom_nodes
```

> ⚠️ 官方提示：**这不会改变自定义节点的默认安装路径**，只是**在启动 ComfyUI 时增加一个额外的搜索路径**。你**仍然需要在对应环境里完成自定义节点的依赖安装**，以保证运行环境的完整性。

## 模型相关报错与排查

### 1. 模型架构不匹配（Model Architecture Mismatch）

**症状**：生成过程中出现**张量维度错误**，**尤其是在 VAE decode 阶段**。

**官方列出的报错原文**：

```
Given groups=1, weight of size [64, 4, 3, 3], expected input[1, 16, 128, 128] to have 4 channels, but got 16 channels instead
Given groups=1, weight of size [4, 4, 1, 1], expected input[1, 16, 144, 112] to have 4 channels, but got 16 channels instead
Given groups=1, weight of size [320, 4, 3, 3], expected input[2, 16, 192, 128] to have 4 channels, but got 16 channels instead
The size of tensor a (49) must match the size of tensor b (16) at non-singleton dimension 1
Tensors must have same number of dimensions: got 2 and 3
mat1 and mat2 shapes cannot be multiplied (154x2048 and 768x320)
```

**根因**：**把不同架构族的模型混在一起用。**

**各模型族的架构口径（官方表）**：

| 模型族 | latent 通道数 | 文本编码器 |
|---|---|---|
| **Flux** | **16 通道** | 双文本编码器（CLIP-L + T5-XXL） |
| **SD1.5** | **4 通道** | 单个 CLIP ViT-L/14 |
| **SDXL** | **4 通道** | 双文本编码器（CLIP ViT-L/14 + OpenCLIP ViT-bigG/14） |
| **SD3** | **16 通道** | **三**文本编码器（CLIP-L + OpenCLIP bigG + T5-XXL） |
| **ControlNet** | — | **必须与基础 checkpoint 架构匹配**：SD1.5 ControlNet 只能配 SD1.5 checkpoint，SDXL ControlNet 只能配 SDXL，依此类推 |

**常见不匹配场景与修复（官方原文）**：

```
Flux + 用错 VAE：
Problem: 对 Flux checkpoint 使用了 taesd 或 sdxl_vae.safetensors
Fix:     改用 ae.safetensors（Flux 的 VAE），来自 Hugging Face 的 Flux 发布

Flux + CLIP 配置错误：
Problem: 在 DualClipLoader 的两个 CLIP 槽里都用了 t5xxl_fp8_e4m3fn.safetensors
Fix:     一个槽用 t5xxl_fp8_e4m3fn.safetensors，另一个槽用 clip_l.safetensors

ControlNet 架构不匹配：
Problem: SD1.5 的 ControlNet 配 SDXL checkpoint（或反过来）
Error:   "mat1 and mat2 shapes cannot be multiplied (154x2048 and 768x320)"
Fix:     用与你的 checkpoint 架构匹配的 ControlNet
         - SD1.5 checkpoint 要用 SD1.5 ControlNet
         - SDXL checkpoint 要用 SDXL ControlNet
```

**快速诊断**：看错误是否出在 VAE decode 阶段，找 `expected input[X, Y, Z] to have N channels, but got M channels` 这类信息——**其中 `Y` 值表示通道数：`4` = SD 系模型，`16` = Flux 系模型**。

**预防**：

- **让工作流里所有模型属于同一架构族**；
- 从**同一来源/同一次发布**下载完整模型包（通常都在同一个 Hugging Face repo 里）；
- 试新模型时，**先从模板工作流或官方 ComfyUI 示例工作流开始**，再动手改。

### 2. 缺失模型（Missing Models）

**报错示例原文**：

```
Prompt execution failed
Prompt outputs failed validation:
CheckpointLoaderSimple:
- Value not in list: ckpt_name: 'model-name.safetensors' not in []
```

> 注意 `not in []` 里的**空列表**：说明**该 loader 的候选列表是空的**——即这个类型的目录里 ComfyUI 一个文件都没看到。

**解决**：

1. **下载所需模型**：用 **ComfyUI Manager 自动下载**；并**确认模型放在正确的子文件夹**里。
2. **核对模型路径**（官方明确列出的五个）：
   - **Checkpoints**：`models/checkpoints/`
   - **VAE**：`models/vae/`
   - **LoRA**：`models/loras/`
   - **ControlNet**：`models/controlnet/`
   - **Embeddings**：`models/embeddings/`
3. **跨 UI 共享模型 / 使用自定义路径**：编辑 `extra_model_paths.yaml` 添加自定义模型目录（见上文）。

### 3. 模型加载错误（Model Loading Errors）

**报错原文**：`Error while deserializing header`

**解决**：

1. **重新下载模型** —— 文件可能在下载过程中损坏
2. **检查可用磁盘空间** —— 确保有足够空间加载模型（**模型可能 2–15GB+**）
3. **检查文件权限** —— 确保 ComfyUI 能读取模型文件
4. **换一个模型测试** —— 判断问题是该模型特有还是系统性的

### 4. 模型性能问题

**加载慢**（症状：切换模型或开始生成时长时间延迟）：

1. **用更快的存储**：模型从 HDD 挪到 **SSD**；追求最佳性能用 **NVMe SSD**。
2. **调整缓存设置**：
   ```bash
   python main.py --cache-classic    # 使用旧式（激进）缓存
   python main.py --cache-lru 10     # 增大 LRU 缓存
   ```

**大模型的显存问题** —— 报错原文 `RuntimeError: CUDA out of memory`，官方给的**递进式降显存**顺序：

```bash
# 逐步降低内存占用
python main.py --lowvram    # 先试这个
python main.py --novram     # 如果 lowvram 还不够
python main.py --cpu        # 最后手段
```

**针对模型的显存优化**：

```bash
# 强制更低精度
python main.py --force-fp16

# 降低 attention 的内存占用
python main.py --use-pytorch-cross-attention
```

## 与目录 / 模型 / 显存相关的启动参数

| 参数 | 默认值 | 作用 |
|---|---|---|
| `--base-directory` `PATH` | ComfyUI 根目录 | **models、custom_nodes、input、output、temp、user 目录的根** |
| `--models-directory` `PATH` | `ComfyUI root/models` | **模型目录。会覆盖 `--base-directory` 里的 models 文件夹** |
| `--extra-model-paths-config` `PATH` | — | 加载一个或多个 `extra_model_paths.yaml` 文件。**可重复指定** |
| `--output-directory` `PATH` | — | 输出目录。覆盖 `--base-directory` |
| `--input-directory` `PATH` | — | 输入目录。覆盖 `--base-directory` |
| `--temp-directory` `PATH` | — | 临时目录。覆盖 `--base-directory` |
| `--user-directory` `PATH` | — | 用户目录（**绝对路径**）。覆盖 `--base-directory`。**路径必须存在且可读** |
| `--cuda-device` `DEVICE_ID` | — | 要用的 CUDA 设备 ID，逗号分隔（如 `0` 或 `0,1`），或 `all` 保留当前所有可见设备。**其他设备会被隐藏** |
| `--cuda-malloc` / `--disable-cuda-malloc` | auto（torch 2.0+） | 启用 / 禁用 `cudaMallocAsync`。**两者互斥** |
| `--gpu-only` | — | 一切（文本编码器、CLIP 等）都放在 GPU 上存储和运行 |
| `--highvram` | — | **模型留在 GPU 显存里**，用完后不卸载到 CPU |
| `--lowvram` | — | **开启动态显存时无效果**；否则在 CPU 上跑文本编码器 |
| `--novram` | — | 当 `--lowvram` 不够时的**最小显存**模式 |
| `--cpu` | — | **全部用 CPU**（慢） |
| `--reserve-vram` `GB` | 取决于操作系统 | **为 OS 和其它软件保留的显存 GB 数** |
| `--disable-smart-memory` | 默认关闭 | **激进地把模型卸载到内存**，而不是留在显存 |
| `--preview-method` | `none` | 采样节点的预览方式。可选 `none`、`auto`、`latent2rgb`、`taesd` |
| `--force-fp16` | — | **全局强制 fp16**，同时会设置 `--fp16-unet` |
| `--cpu-vae` | — | **在 CPU 上跑 VAE**（与 VAE 精度开关不互斥） |
| `--verbose` `[LEVEL] [FILE]` | `INFO` | 日志级别：`DEBUG`/`DETAIL`/`INFO`/`WARNING`/`ERROR`/`CRITICAL`。单独 `--verbose` = `DEBUG`；可再加一个级别和一个文件路径把该级别同时写进文件；**可重复使用**以分别配置控制台与文件输出 |

> Manager 相关参数（`--enable-manager`、`--disable-manager-ui`、`--enable-manager-legacy-ui`）与自定义节点参数（`--disable-all-custom-nodes`、`--whitelist-custom-nodes FOLDER...`）见 `references/04-custom-nodes-and-manager.md` 与 `references/06-troubleshooting.md`。

## 系统要求

### 支持的操作系统

- **Windows**
- **Linux**
- **macOS**（支持 **Apple Silicon**，如 M 系列）

**不管用哪个版本的 ComfyUI，它都跑在一个独立的 Python 环境里。**

| 安装形态 | 平台支持 |
|---|---|
| **Comfy Desktop** | 独立安装包支持 **Windows**、**macOS（Apple Silicon）**、**Linux**（AppImage 与 `.deb`）。源码在 <https://github.com/Comfy-Org/Comfy-Desktop> |
| **ComfyUI Portable** | **仅 Windows**；集成了独立的嵌入式 Python 环境；支持 **Nvidia GPU** 或 **纯 CPU**；始终使用最新 commit、完全便携 |
| **手动安装** | **支持所有系统类型与 GPU 类型**：Nvidia、AMD、Intel、Apple Silicon、**Ascend NPU**、**Cambricon MLU** |

> 官方提示：**Desktop 版默认跟踪 `stable`（稳定）版 ComfyUI**。想要每个最新 commit，用 portable 版或手动 git 安装，或把实例的更新通道切成 **Latest on GitHub**。

### Python 版本

| 版本 | 官方口径 |
|---|---|
| **Python 3.13** | **支持非常好，推荐** |
| Python 3.14 | 能用，**但部分自定义节点可能有问题**。free-threaded 变体也能用，**但部分依赖会启用 GIL，因此不是完全支持** |
| Python 3.12 | 如果 3.13 上某些自定义节点依赖出问题，**这是很好的退路** |

### 浏览器要求

为了最好体验，**用 Google Chrome 143 或更高版本**。**更早的 Chrome（142 及以下）有已知问题，会导致 ComfyUI 出现视觉故障与性能问题。**

### 支持的硬件

| 硬件 | 说明 |
|---|---|
| **NVIDIA GPU** | 安装带 **CUDA 13.0** 的 stable PyTorch：`pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130` |
| **AMD GPU（Linux）** | **ROCm 7.2** stable 或 nightly |
| **AMD GPU（Windows）** | **ROCm 10.0**，通过 AMD 多架构 PyTorch 包。**支持 RDNA 2、RDNA 3、RDNA 3.5、RDNA 4；无需单独安装 HIP SDK** |
| **Intel GPU** | **Arc 系列**，用 PyTorch 原生 `torch.xpu` 支持 |
| **Apple Silicon** | **M1/M2/M3/M4** 系列，Metal 加速 |
| **Ascend NPU** | 通过 `torch_npu` 扩展 |
| **Cambricon MLU** | 通过 `torch_mlu` 扩展 |
| **Iluvatar Corex** | 通过 Iluvatar Extension for PyTorch |
| **CPU** | 用 `--cpu` 参数（**更慢**） |

**PyTorch 口径**：**支持 PyTorch 2.7 及以上，但强烈建议用更新的版本**。**Nvidia 20 系及以上需要 cu130 或更高版本的 PyTorch。** 某些功能与优化可能只在更新版本上可用。官方的一般建议是**用最新的大版本 PyTorch + 最新 CUDA**，**除非该版本发布还不到 2 周**。

> **Windows portable 构建目前自带 Python 3.13 与 PyTorch CUDA 13.0。启动不起来就更新 Nvidia 驱动。**

### 依赖

1. 安装 PyTorch（版本按你的硬件选）
2. 安装 ComfyUI `requirements.txt` 里的全部依赖：`pip install -r requirements.txt`

### FAQ

- **ComfyUI 支持 MLX（Apple 的机器学习框架）吗？** —— **ComfyUI 不直接使用 MLX**。在 Apple Silicon（M1/M2/M3/M4）Mac 上，ComfyUI 用的是带 **MPS（Metal Performance Shaders）后端**的 PyTorch，它借助 Apple 的 Metal 图形框架做 GPU 加速。MLX 是为 Apple Silicon 设计的独立机器学习数组框架；ComfyUI 的 PyTorch 架构用的是 MPS。
  **验证 Mac 上 MPS 是否工作**：
  ```bash
  python -c "import torch; print(torch.backends.mps.is_available())"
  ```
- **Docker**：**ComfyUI 不提供官方 Docker 镜像。** 想在容器里跑就自己去 [Docker Hub](https://hub.docker.com) 找社区维护的镜像。注意**这些都不是官方 ComfyUI 镜像，ComfyUI 团队不支持它们，使用风险自担**。

## 找不到模型时的四步（官方 FAQ）

如果模型装了但在 ComfyUI 里找不到：

1. **确认模型位置正确**：默认路径 `ComfyUI/models/`（例如 `checkpoints`、`loras`、`vae` 子目录）。
   **Comfy Desktop** 用户：点桌面 app **顶部的 capsule 菜单** → **Storage** 标签页，查看你的模型目录。（**capsule 只在桌面 app 里存在，浏览器里跑 ComfyUI 时没有。**）
2. **按 `r` 键刷新节点定义**，让 ComfyUI 能检测到该模型。
3. **重启 ComfyUI。**
4. **确认 loader 节点里选中的是正确的那个模型。**

## 背景补充

- **这里说的「模型」是什么**：一个**编码了网络学到了什么的数据文件**，包含把输入（如文本与噪声）转成输出（如图像）所需的全部信息。图像工作流里的常见例子：**diffusion** checkpoint、**CLIP** 这类文本/图像编码器、**RealESRGAN** 这类放大器。
- **base model 与社区变体**：来自实验室与开源项目的大型 **base** 模型是通用的。社区经常对它们做**微调（fine-tune）或合并**，产出新的 checkpoint 与 LoRA，让某个风格更好看、跑得轻一点、或增加新行为——就像在 Civitai 或 Hugging Face 上挑一个中意的 checkpoint。
