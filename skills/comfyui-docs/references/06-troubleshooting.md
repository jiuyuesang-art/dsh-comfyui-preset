# 常见报错与排查

> 来源：https://docs.comfy.org/troubleshooting/overview
> 来源：https://docs.comfy.org/troubleshooting/custom-node-issues
> 来源：https://docs.comfy.org/troubleshooting/model-issues
> 来源：https://docs.comfy.org/development/comfyui-server/startup-flags （只取排查用的启动参数）
> 抓取日期：2026-10-03

## 一句话结论（官方方法论）

**出问题先怀疑自定义节点。** 官方原文：

> 我们收到大量反馈 issue，发现**提交上来的绝大多数问题都与自定义节点有关**。所以在提交错误报告之前，请务必先读过[自定义节点排查指南](https://docs.comfy.org/troubleshooting/custom-node-issues)，确认问题**不是**由自定义节点引起的。

**标准动作**：用 `--disable-all-custom-nodes` 启动 → 问题消失 = 自定义节点引起 → **二分法**定位到具体节点 → 修复/替换/上报/移除。

## 官方排查流程图（文字化）

```
遇到问题
  └─ 禁用所有自定义节点后，问题还在吗？
       ├─ 在  → 不是自定义节点引起的，转到其它排查文档
       └─ 消失 → 是自定义节点引起的
            └─ 能进前端吗？→ 先查「带前端扩展的自定义节点」
                 （好处：只需 reload 前端，不用反复重启 ComfyUI）
                 不能进前端 / 前端不是原因 → 用「通用二分法」（需多次重启 ComfyUI）
                      └─ 二分法定位到出问题的节点
                           └─ 修复 / 替换 / 上报 / 移除
                                └─ 问题解决
```

## 快速修复：三类最常见的症状（先试这些）

| 症状 | 官方快速修复 |
|---|---|
| **ComfyUI 起不来**（启动即崩、黑屏、加载失败） | ① **检查系统要求**，确认机器满足[最低要求](https://docs.comfy.org/installation/system_requirements)；② **更新 GPU 驱动**（从 NVIDIA/AMD/Intel 下载最新驱动） |
| **生成失败或报错**（弹 `Prompt execution failed` 对话框、带 `Show report` 按钮，工作流停止执行） | ① **点 `Show report`**，读详细错误信息定位具体问题；② **判断是不是自定义节点问题**，走[自定义节点排查指南](https://docs.comfy.org/troubleshooting/custom-node-issues)；③ **核对模型文件**，见 `references/05-models-and-directories.md`；④ **检查显存占用**，关掉其它占 GPU 显存的程序 |
| **性能很慢**（生成极慢、系统卡死、内存不足报错） | ① **降分辨率 / 批大小**（减小图像尺寸或张数）；② **用显存优化参数**（见下）；③ **关掉不必要的程序**，腾出 RAM 与 VRAM；④ **看 CPU/GPU 占用**，用任务管理器找瓶颈 |

**显存优化与性能参数（官方命令，可直接照抄）**：

```bash
# —— 低显存机器 ——
python main.py --lowvram     # 低显存模式（文本编码器走 CPU）
python main.py --cpu         # CPU 模式（很慢，但任何硬件都能跑，只作最后手段）

# —— 追求更好性能 ——
python main.py --preview-method none         # 关掉预览（省显存与算力）
python main.py --use-pytorch-cross-attention # 用优化过的 attention 机制
python main.py --use-flash-attention
python main.py --async-offload               # 异步权重卸载

# —— 内存管理 ——
python main.py --reserve-vram 2       # 为 OS 保留指定 GB 显存
python main.py --disable-smart-memory
python main.py --cache-none           # 更省 RAM，但更慢
python main.py --cache-lru 10         # 缓存 10 个结果，更快
python main.py --cache-classic        # 旧式（激进）缓存
```

## 1. 缺失节点（Missing nodes）

### 表现

工作流**导入后**节点进入 **Missing 状态**（见 `references/02-core-concepts.md` 的节点四状态）。官方把成因分成两种，**处置方式完全不同**：

| 成因 | 判断依据 | 解决 |
|---|---|---|
| **Comfy Core 原生节点缺失** | 通常是 ComfyUI 已更新、而你用的是**旧版 ComfyUI** | **更新 ComfyUI** 即可 |
| **自定义节点缺失** | 工作流用了第三方作者开发的自定义节点，本地没装 | 用 [ComfyUI Manager](https://docs.comfy.org/manager/overview) 查找并安装，或参考[如何安装自定义节点](https://docs.comfy.org/installation/install_custom_node) |

在 Manager 新 UI 里，**加载含缺失节点的工作流时官方会弹提示**：可选 **Install All** 一次装完，或 **Open Manager** 先看细节；也可**选中该节点 → 预览面板点 `Missing` 按钮**查找缺失节点。详见 `references/04-custom-nodes-and-manager.md`。

### 「装完重启后节点仍然显示缺失」

这是**通用自定义节点排查**里官方明确列出的典型症状之一（属于**依赖问题**一类）：

> **缺失节点在安装并重启后仍显示为缺失。**

配套的常见原因是：
- 自定义节点需要**额外的 wheel**（官方举例 `ComfyUI-Nunchaku`）
- 自定义节点**锁死了依赖版本**（例如 `torch==2.4.1`），而别的插件要不同版本（例如 `torch>=2.4.2`），**装完就冲突**
- **网络问题导致依赖没装上**

> 官方提示：当问题涉及 Python 环境的相互依赖与版本时，排查会更复杂，**需要 Python 环境管理的知识**（包括怎么装、怎么卸依赖）。依赖冲突的三类成因与解法见 `references/02-core-concepts.md`。

### 禁用所有自定义节点（各安装形态的命令）

**Desktop 用户**：在设置菜单里以「禁用自定义节点」的方式启动 Comfy Desktop；或手动跑 server：

```bash
cd path/to/your/comfyui
python main.py --disable-all-custom-nodes
```

**手动安装**：

```bash
cd ComfyUI
python main.py --disable-all-custom-nodes
```

**Portable 用户**，两种做法：

*改 `.bat` 文件*（官方推荐做法）——在便携版所在目录找到 `run_nvidia_gpu.bat` 或 `run_cpu.bat`：

1. 复制 `run_nvidia_gpu.bat`（或 `run_cpu.bat`），重命名为 **`run_nvidia_gpu_disable_custom_nodes.bat`**
2. 用记事本打开复制出来的文件
3. 加上 `--disable-all-custom-nodes` 参数，或直接把下面这段拷进一个 `.txt` 再把文件重命名成 `run_nvidia_gpu_disable_custom_nodes.bat`：

```bash
.\python_embeded\python.exe -s ComfyUI\main.py --disable-all-custom-nodes  --windows-standalone-build
pause
```

4. 保存并关闭
5. 双击运行。一切正常的话，你会看到 ComfyUI 启动且自定义节点已禁用

*走命令行*：进便携版目录 → 右键菜单打开终端 → 确认当前目录就是便携版目录 → 运行：

```
.\python_embeded\python.exe -s ComfyUI\main.py --disable-all-custom-nodes
```

**结果判读**：

- ✅ **问题消失** → 是某个自定义节点引起的 → 继续往下定位
- ❌ **问题依旧** → 不是自定义节点问题 → 去[上报 issue](https://docs.comfy.org/troubleshooting/overview)

> 相关启动参数：**`--disable-all-custom-nodes`**（默认关闭，即不禁用）禁用加载所有自定义节点；**`--whitelist-custom-nodes FOLDER...`** 在设了 `--disable-all-custom-nodes` 的情况下，指定**仍要加载**的自定义节点文件夹。

## 2. 二分法定位出问题的自定义节点

**二分法（binary search）的定义**（官方说法）：一次检查一半自定义节点，直到定位到出问题的那个。

```
开始 → 把所有自定义节点对半分
  → 启用前一半 → 重启 ComfyUI 并测试 → 问题出现吗？
       ├─ 出现 → 问题在「已启用」的那一半里 → 已启用数量 > 1？→ 是则对这一半继续二分
       └─ 没出现 → 问题在「未启用」的那一半里 → 未启用数量 > 1？→ 是则对那一半继续二分
            └─ 只剩 1 个 → 找到出问题的自定义节点
```

### 先查「带前端扩展的节点」（重要：更常见、且不用反复重启）

官方把自定义节点分成两类来排查：**A = 带前端扩展（frontend extensions）的自定义节点**；**B = 普通自定义节点**。

> **带前端扩展的自定义节点造成的问题最多**，因此**优先排查它们**。它们的主要冲突来自**与 ComfyUI 前端版本更新不兼容**。

**常见表现**（官方清单）：

- 工作流不执行
- 某些节点**显示不出预览图**（例如 save image 节点）
- UI 元素**错位**
- **进不去** ComfyUI 前端
- **UI 完全坏掉或白屏**
- 无法与 ComfyUI 后端正常通信
- 节点连接不正常
- 以及更多

**常见成因**（官方清单）：

- 更新时前端改动，而自定义节点还没适配
- 用户**更新了 ComfyUI 但没同步升级自定义节点**，尽管作者已发布兼容版本
- 作者**停止维护**，导致自定义节点扩展与 ComfyUI 前端不兼容

**排查三步**：

1. **禁用所有第三方前端扩展** —— 启动 ComfyUI 后，在设置里找到 **`Extensions` 菜单**，按官方图示**禁用所有第三方扩展**。
   ⚠️ **如果你根本进不去 ComfyUI 前端，跳过本节**，直接走下面的「通用自定义节点排查」。
2. **重启 ComfyUI** —— 首次禁用前端扩展后**建议重启**，确保全部扩展被正确禁用。
   - 问题消失 → 是前端扩展引起的 → 继续二分
   - 问题依旧 → 不是前端扩展引起的 → 换本文其它排查路径
3. **二分法定位** —— 每次启用一半前端扩展，直到找到出问题的那个。**注意：如果扩展名字很像，它们很可能来自同一个自定义节点的前端扩展。**

> 这个方法的好处：**不需要反复重启 ComfyUI**，启用/禁用前端扩展后**只要 reload**；而且排查范围被限制在「带前端扩展的节点」里，**大幅缩小了搜索面**。

### 通用自定义节点排查

**方式 A：用 Comfy CLI 自动 bisect（官方推荐）**

> 用 Comfy CLI 需要一些命令行经验；不熟就用手动二分法。

```bash
# 开始一个 bisect 会话
comfy-cli node bisect start

# 按提示操作：
# - 用当前启用的节点集测试 ComfyUI
# - 问题消失就标记为 good：comfy-cli node bisect good
# - 问题仍在就标记为 bad： comfy-cli node bisect bad
# - 重复直到定位到出问题的节点

# 结束时重置
comfy-cli node bisect reset
```

官方说明：bisect 工具会**自动启用/禁用节点并引导你走完流程**。

**方式 B：手动二分法**

> ⚠️ 官方警告：动手前**先给 `custom_nodes` 文件夹做备份**，以防万一。

以 8 个自定义节点为例（进 `<你的COMFYUI目录>\ComfyUI\`）：

1. **建临时文件夹并备份**：

   ```bash
   # Windows
   mkdir "%USERPROFILE%\custom_nodes_backup"
   mkdir "%USERPROFILE%\custom_nodes_temp"
   xcopy "custom_nodes\*" "%USERPROFILE%\custom_nodes_backup\" /E /H /Y

   # macOS/Linux
   mkdir ~/custom_nodes_backup
   mkdir ~/custom_nodes_temp
   cp -r custom_nodes/* ~/custom_nodes_backup/
   ```

2. **列出所有自定义节点**：`dir custom_nodes`（Windows 有图形界面可跳过）／`ls custom_nodes/`（macOS/Linux）
3. **把节点对半移走**（把前一半移到临时目录）：

   ```bash
   # Windows
   move "custom_nodes\node1" "%USERPROFILE%\custom_nodes_temp\"
   # …node2 / node3 / node4 同理

   # macOS/Linux
   mv custom_nodes/node1 ~/custom_nodes_temp/
   ```
4. **测试**：正常启动 `python main.py`
5. **判读**：**问题仍在** → 问题在剩下那批（5–8）；**问题消失** → 问题在被移走的那批（1–4）
6. **继续缩小**：问题仍在 → 把剩余节点再移走一半（如 7–8）；问题消失 → 把临时目录里的节点移回一半（如 3–4）
7. **重复**直到找到**单个**出问题的节点

### 找到之后怎么办（官方四个选项）

| 选项 | 做法 |
|---|---|
| **1. 更新该节点** | 看 ComfyUI Manager 里有没有可用更新 → 更新后再测 |
| **2. 替换该节点** | 找功能相近的替代自定义节点；去 [ComfyUI Registry](https://registry.comfy.org) 找 |
| **3. 上报问题** | 联系该自定义节点作者：找到它的 GitHub 仓库 → 建 issue，附上**你的 ComfyUI 版本、错误信息/日志、复现步骤、操作系统** |
| **4. 移除或禁用该节点** | 没有修复且你也不需要这个功能时：从 `custom_nodes/` 里移除，**或在 ComfyUI Manager 界面里禁用它** → **重启 ComfyUI** |

## 3. 缺失模型（Missing model）

**报错原文**：

```
Prompt execution failed
Prompt outputs failed validation:
CheckpointLoaderSimple:
- Value not in list: ckpt_name: 'model-name.safetensors' not in []
```

**解决**：

1. **下载所需模型**：用 **ComfyUI Manager 自动下载**；并确认模型在**正确的子文件夹**里。
2. **核对路径**：Checkpoints → `models/checkpoints/`；VAE → `models/vae/`；LoRA → `models/loras/`；ControlNet → `models/controlnet/`；Embeddings → `models/embeddings/`
3. **跨 UI 共享模型 / 自定义路径**：编辑 `extra_model_paths.yaml` 添加自定义模型目录。

**完整清单（含「架构不匹配」「加载错误 `Error while deserializing header`」「加载慢」「显存不足」）见 `references/05-models-and-directories.md`。**

## 4. OOM / 显存不足

**报错原文**：`RuntimeError: CUDA out of memory`

**官方给的递进式降显存顺序**：

```bash
# 逐步降低内存占用
python main.py --lowvram    # 先试这个
python main.py --novram     # 如果 lowvram 还不够
python main.py --cpu        # 最后手段
```

**针对模型的显存优化**：

```bash
python main.py --force-fp16                  # 强制更低精度
python main.py --use-pytorch-cross-attention # 降低 attention 的内存占用
```

**其它与显存相关的启动参数**（官方 startup-flags）：

| 参数 | 作用 |
|---|---|
| `--gpu-only` | 一切（文本编码器、CLIP 等）都放 GPU 上存储和运行 |
| `--highvram` | 模型留在显存里，用完不卸载到 CPU |
| `--lowvram` | **开启动态显存时无效果**；否则文本编码器跑在 CPU 上 |
| `--novram` | `--lowvram` 不够时的最小显存模式 |
| `--reserve-vram GB` | 为 OS 与其它软件保留的显存 GB 数（默认值取决于操作系统） |
| `--disable-smart-memory` | 激进地把模型卸载到内存，而不是留在显存 |
| `--cpu-vae` | 在 CPU 上跑 VAE |
| `--preview-method none` | 关掉采样节点预览，省显存与算力 |

**非参数手段（官方快速修复）**：**降分辨率 / 降 batch size**；**关掉其它占用 GPU 显存的程序**。

> 官方**没有**给出 OOM 的显存数值门槛或「需要多少 GB 才能跑某模型」的对照表——这类数字不在 troubleshooting 页面上。

## 5. CUDA / GPU 相关

### NVIDIA：`Torch not compiled with CUDA enabled`

```bash
# 先卸载 torch
pip uninstall torch

# 安装带 CUDA 13.0 的 stable PyTorch
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130

# 想用 nightly（可能有性能改进）
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu132

# 验证 CUDA 支持
python -c "import torch; print(torch.cuda.is_available())"
```

### NVIDIA：GPU 检测不到

```bash
nvidia-smi                                              # GPU 是否可见
nvidia-smi --query-gpu=driver_version --format=csv      # 驱动版本与 CUDA 兼容性
```

### NVIDIA Blackwell（`sm_103`）：生成在第一个 attention 层就失败

**症状**：在 Blackwell 世代的 NVIDIA GPU 上，PyTorch 默认的 **scaled dot-product attention（SDPA）**可能选中 **cuDNN 后端**，而该后端**对这个架构没有可用方案**：

```
cuDNN Frontend error: No valid execution plans built
```

**用 FLUX 时这会命中 UNet 里第一个 attention block，因此永远出不了图。**

```bash
# 改用手写的 attention 实现，绕过 SDPA 与 cuDNN
python main.py --use-split-cross-attention

# Blackwell 还需要 CUDA 12.8 或更新的 PyTorch 构建；
# 用 cu121 编译的构建在这些卡上根本跑不起来
```

> 官方补充：**在启动前用代码关掉 cuDNN SDPA 后端是没用的** —— 例如从 `sitecustomize.py` 里调 `torch.backends.cuda.enable_cudnn_sdp(False)` —— 因为**这个标志在 CUDA 初始化过程中不会被保留**。**启动参数才是可靠修法。**

### AMD：ROCm（仅 Linux）

```bash
# stable ROCm PyTorch（写作时为 7.2）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm7.2

# nightly
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm7.2
```

**不受支持的 AMD GPU**（用 `HSA_OVERRIDE_GFX_VERSION` 兜底）：

```bash
# RDNA2 或更老（6700、6600）
HSA_OVERRIDE_GFX_VERSION=10.3.0 python main.py

# RDNA3 卡（7600）
HSA_OVERRIDE_GFX_VERSION=11.0.0 python main.py
```

**AMD 性能优化**：

```bash
# 启用实验性的 memory efficient attention（PyTorch 2.4 之后已不再必要）
TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 python main.py --use-pytorch-cross-attention

# 启用可调优算子（首次运行慢，之后更快）
PYTORCH_TUNABLEOP_ENABLED=1 python main.py
```

### Apple Silicon（M1/M2/M3）

> 官方说明：本节步骤适用于**手动安装 / 源码安装**（ComfyUI 跑在你自己搭的 Python 环境里）。**Apple Silicon 上的 Comfy Desktop 不需要单独装 Python**——app 会为每个实例管理自己的 Python 环境。

```bash
# 为 Apple Silicon 安装 PyTorch nightly
# 参考 Apple 官方指南：https://developer.apple.com/metal/pytorch/

# 检查 MPS 可用性
python -c "import torch; print(torch.backends.mps.is_available())"

# 启动 ComfyUI
python main.py
```

**MPS 出问题时**：

```bash
python main.py --cpu                    # 强制 CPU 模式
python main.py --force-fp16 --cpu       # 带内存优化
```

### Intel GPU：也报 `Torch not compiled with CUDA enabled`

> 在 Intel GPU 上，**这个错误的意思是 ComfyUI 想用 CUDA，因为 XPU 后端不可用**。**不要**照抄上面的 NVIDIA CUDA 重装步骤——**Intel GPU 用 XPU，不用 CUDA**。

```bash
python -c "import torch; print('XPU available:', hasattr(torch, 'xpu') and torch.xpu.is_available())"
```

打印 `True` → ComfyUI 会自动使用 XPU 后端。打印 `False` → 三步：

1. **确认你有受支持的 Intel Arc GPU**（Arc A 系列、Arc B 系列，或带 Arc Graphics 的 Core Ultra 处理器）
2. **安装或更新 [Intel GPU 驱动](https://www.intel.com/content/www/us/en/developer/articles/tool/pytorch-prerequisites-for-intel-gpu.html)**
3. **安装启用 XPU 的 PyTorch 构建**（**不要装 CUDA wheel**）：

```bash
# 方案 1：PyTorch 原生 XPU 支持（Windows/Linux）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu          # stable（推荐）
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/xpu  # nightly
python main.py

# 方案 2：Intel Extension for PyTorch (IPEX)，适用于 Intel Arc A 系列
conda install libuv
pip install torch==2.3.1.post0+cxx11.abi torchvision==0.18.1.post0+cxx11.abi torchaudio==2.3.1.post0+cxx11.abi intel-extension-for-pytorch==2.3.110.post0+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
```

### Linux：`LD_LIBRARY_PATH` 相关报错

**常见症状原文**：

- `libcuda.so.1: cannot open shared object file`
- `libnccl.so: cannot open shared object file`
- `ImportError: libnvinfer.so.X: cannot open shared object file`

**解决（现代 PyTorch 安装，最常见）** —— 把 nvidia 库路径加进 `LD_LIBRARY_PATH`：

```bash
# 虚拟环境 + NVIDIA 包
export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib/python3.12/site-packages/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH

# conda 环境
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib/python3.12/site-packages/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH

# 自动定位 site-packages
PYTHON_PATH=$(python -c "import site; print(site.getsitepackages()[0])")
export LD_LIBRARY_PATH=$PYTHON_PATH/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH

# 可能还需要其它 NVIDIA 库
export LD_LIBRARY_PATH=$PYTHON_PATH/nvidia/cuda_runtime/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PYTHON_PATH/nvidia/cublas/lib:$LD_LIBRARY_PATH
```

**查看装了哪些 NVIDIA 库 / 找出缺失的库**：

```bash
python -c "import site; import os; nvidia_path=os.path.join(site.getsitepackages()[0], 'nvidia'); print('NVIDIA libs:', [d for d in os.listdir(nvidia_path) if os.path.isdir(os.path.join(nvidia_path, d))] if os.path.exists(nvidia_path) else 'Not found')"

python -c "import torch; print(torch.__file__)"
ldd $(python -c "import torch; print(torch.__file__.replace('__init__.py', 'lib/libtorch_cuda.so'))")
```

**永久设置**：

```bash
echo 'export LD_LIBRARY_PATH=$VIRTUAL_ENV/lib/python*/site-packages/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH' >> $VIRTUAL_ENV/bin/activate
conda env config vars set LD_LIBRARY_PATH=$CONDA_PREFIX/lib/python*/site-packages/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH
echo 'export LD_LIBRARY_PATH=$(python -c "import site; print(site.getsitepackages()[0])")/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
```

**备用方案：`ldconfig`**：

```bash
ldconfig -p | grep cuda
ldconfig -p | grep nccl
sudo echo "/usr/local/cuda/lib64" > /etc/ld.so.conf.d/cuda.conf
sudo ldconfig
```

**调试库加载**：

```bash
LD_DEBUG=libs python main.py 2>&1 | grep "looking for"
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda)"
```

## 6. 安装形态相关的坑

### 桌面版（Comfy Desktop）

| 平台 | 官方列出的问题 |
|---|---|
| **Windows** | **Unsupported device**：Comfy Desktop Windows **只支持带 CUDA 的 NVIDIA GPU**；其它 GPU 请用 [Portable](https://docs.comfy.org/installation/comfyui_portable_windows) 或[手动安装](https://docs.comfy.org/installation/manual_install)。**安装失败**：以管理员身份运行安装程序，并确保**至少 15GB 磁盘空间**。**Maintenance 页面**：下载失败时检查[镜像设置](https://docs.comfy.org/installation/desktop/usage/settings#advanced)。**Missing models**：**迁移时模型不会被复制，只被链接（linked）**——请核对模型路径 |
| **macOS** | **"App is damaged"**：在安全与隐私设置里允许该 app。**性能问题**：在隐私设置里授予**完全磁盘访问权限**。**崩溃**：查看 Console app 的崩溃报告 |
| **Linux** | **缺少库**：用包管理器装依赖。**`LD_LIBRARY_PATH` 错误**：PyTorch 库路径问题（见上文） |

### 手动安装

> 官方提示：文档可能略有滞后。出问题时请**自行确认是否存在更新的 stable 版 pytorch 或所列库**，参考 [pytorch 安装矩阵](https://pytorch.org/get-started/locally/) 或 [ROCm 网站](https://rocm.docs.amd.com/projects/install-on-linux/en/develop/install/3rd-party/pytorch-install.html#using-a-wheels-package)。

```bash
# Python 版本冲突（注意：此页写 3.9+ 必需 / 3.12 推荐；
# 而 system_requirements 页写 3.13 推荐、3.12 为退路 —— 两页口径不一致）
python --version

# 用虚拟环境（推荐）
python -m venv comfyui_env
source comfyui_env/bin/activate  # Linux/Mac
comfyui_env\Scripts\activate     # Windows

# 包安装失败
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130   # NVIDIA（CUDA 13.0）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm7.2        # AMD（仅 Linux，ROCm 7.2）
```

### 前端 / 网络 / 登录

| 症状 | 官方解法 |
|---|---|
| **`Frontend or Templates Package Not Updated`** | 用 Git 更新 ComfyUI 之后要更新前端依赖：`pip install -r requirements.txt` |
| **`Can't Find Custom Node`** | 在 ComfyUI 设置里**关闭节点校验（node validation）** |
| **弹 toast 说工作流校验失败** | 临时**关闭工作流校验**，并把问题报告给 ComfyUI 团队 |
| **不在 localhost 时登录不了** | **普通登录只在从 localhost 访问时有效**。局域网 / 远程访问要在 <https://platform.comfy.org/login> 生成 **API key**，在登录对话框里用，或用命令行参数 `--api-key` |
| **`Failed to connect to server` / 超时** | ① 检查防火墙，允许 ComfyUI 通过；② **换端口**（默认 **8188**，可试 8189 / 8190）；③ 临时关掉 VPN；④ 不需要代理就关掉代理 |
| **Partner 节点不工作**（API 调用失败、超时、配额超限） | ① 在[用户设置](https://docs.comfy.org/interface/user)核对 API key 有效性；② 检查账户[积分](https://docs.comfy.org/interface/credits)；③ 验证网络；④ 查服务商状态（可能宕机） |

> ⚠️ Partner 节点属于**云端付费**能力，本项目不使用；此处仅作为官方排查条目收录。

## 7. 上报 Bug 前先做（官方清单）

1. **确认是不是已知问题**：搜 [GitHub Issues](https://github.com/Comfy-Org/ComfyUI/issues)；查 [ComfyUI Forum](https://forum.comfy.org/)；翻 [Discord 讨论](https://discord.com/invite/comfyorg)
2. **做基本排查**：用[默认工作流](https://docs.comfy.org/get_started/first_generation)测试；**禁用所有自定义节点**；看控制台/终端的错误信息；**如果用的是 comfy-cli，试一下 `comfy node update all`**

## 8. 上报时该去哪里

| 问题类型 | 上报去处 |
|---|---|
| **ComfyUI 核心** | [Comfy-Org/ComfyUI Issues](https://github.com/Comfy-Org/ComfyUI/issues) |
| **桌面 App** | [Comfy-Org/Comfy-Desktop Issues](https://github.com/Comfy-Org/Comfy-Desktop/issues) |
| **前端（Frontend）** | [Comfy-Org/ComfyUI_frontend Issues](https://github.com/Comfy-Org/ComfyUI_frontend/issues) |
| **某个自定义节点** | **联系该自定义节点的开发者**（找到它的 GitHub 仓库，在其中建 issue；并先看它的文档与 Issues 页有无已知问题） |

## 9. 上报必须附带的信息（官方 Required Information）

**① 系统信息**（可在**设置里的 About 页面**找到）：

- 操作系统（Windows 11、macOS 14.1、Ubuntu 22.04 等）
- **ComfyUI 版本**（设置在 About 页面）
- **Python 版本**：`python --version`
- **PyTorch 版本**：`python -c "import torch; print(torch.__version__)"`
- **GPU 型号与驱动版本**
- **安装方式**（Desktop / Portable / 手动 / comfy-cli）

命令行收集方式：

```bash
# Windows
systeminfo | findstr /C:"OS Name" /C:"OS Version"
wmic path win32_VideoController get name
python --version
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"

# macOS/Linux
uname -a
lspci | grep VGA
python --version
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
```

**② 桌面 App 问题还要附**：

- 日志：`C:\Users\<username>\AppData\Roaming\ComfyUI\logs`（Windows）
- 配置：`C:\Users\<username>\AppData\Roaming\ComfyUI`（Windows）

**③ 问题细节**：清晰的问题描述；**复现步骤**；期望行为 vs 实际行为；截图或录屏。
**错误信息**：控制台/终端的**完整报错文本**；**浏览器控制台报错（F12 → Console 标签）**；任何崩溃日志或错误对话框。

**④ 附加背景**：**已安装的自定义节点列表**；能复现问题的**工作流文件（.json）**；最近的变更（新装了什么、更新了什么）。

## 10. 社区资源（官方列出）

- **官方论坛**：<https://forum.comfy.org/>
- **Discord**：<https://discord.com/invite/comfyorg>
- **Reddit**：<https://reddit.com/r/comfyui>
- **YouTube**：<https://www.youtube.com/@comfyorg>

## 官方该页未覆盖

- **没有 OOM 的显存数值门槛**，也没有「某模型需要多少 GB 显存」的对照表。官方只给了**递进式参数手段**（`--lowvram` → `--novram` → `--cpu`）与降分辨率/降 batch 的建议。
- **没有专门的「CUDA 版本不兼容」错误码清单**；CUDA 相关内容分散在「NVIDIA GPU Issues」「Blackwell」「AMD」「Intel」几节里。
- **没有给缺失节点的具体报错文本**（只有节点 Missing 状态与 Manager 的 `Missing` 按钮）。
- **前端校验相关的官方建议（关闭节点校验 / 关闭工作流校验）是「临时」手段**，官方同时要求把问题报给 ComfyUI 团队，并没有说明长期解法。
- **Python 版本口径在两页之间不一致**：`troubleshooting/overview` 写「**3.9+ 必需，3.12 推荐**」，`installation/system_requirements` 写「**3.13 很好支持并推荐；3.12 是 3.13 上依赖出问题时的好退路**」。以后者（system_requirements）为准更稳妥。
