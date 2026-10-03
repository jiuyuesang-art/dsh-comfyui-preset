# ComfyUI 核心概念（节点 · 连线 · 工作流 · 属性 · 依赖）

> 来源：https://docs.comfy.org/basic-concepts/workflow
> 来源：https://docs.comfy.org/basic-concepts/nodes
> 来源：https://docs.comfy.org/basic-concepts/links
> 来源：https://docs.comfy.org/basic-concepts/properties
> 来源：https://docs.comfy.org/basic-concepts/custom-nodes
> 来源：https://docs.comfy.org/basic-concepts/dependencies
> 抓取日期：2026-10-03

## 一句话结论

**工作流（workflow）就是一张节点图（node graph）**：节点是图里的点，连线（link）是点之间的数据流。ComfyUI 用「摆方块 + 连线」代替写代码，所以官方把它叫 **visual programming（可视化编程）**。节点、连线、属性三者构成全部：**节点做一件事，连线传数据，属性控制怎么做**。

## 工作流 = 一张节点图

官方用**菜谱**打比方：

| 菜谱 | ComfyUI |
|---|---|
| 菜谱本身 | workflow |
| 每条步骤 | node（节点） |
| 食材 | prompt、image、model 等 |
| 做出来的菜 | 生成的图像 / 视频 / 音频 / 3D 等产物 |

一个最简单的图像工作流的四步：**加载模型 → 读取文本 prompt → 生成图像 → 保存图像**。ComfyUI 把这四步画成画布上的方块。

**运行工作流时**：ComfyUI 执行所需的节点，并沿连线传递数据，直到产出最终输出。
**如果某个节点缺失、报错，或者没拿到它需要的数据，工作流就跑不完**——该节点会被标记出来，方便定位和修。

## 节点（node）

节点是 ComfyUI 的**基本构建块**：每一个都是**独立构建的模块**，要么是 **Comfy Core**（官方核心）节点，要么是 **Custom Node**（自定义节点）。节点通过连线互相连接，像拼乐高一样组合出复杂功能。

- 节点是**函数算子（function operators）**：接受输入数据 → 做某种运算 → 产出输出数据。因此节点**几乎总是至少有一个输入或输出**，通常有多个。
- 节点背后是写好的 **Python** 逻辑，用户不需要写代码就能用。
- 节点在画布上表现为**方框**，彼此相连。

### 节点的四种状态

| 状态 | 含义 |
|---|---|
| **Normal** | 默认状态 |
| **Running** | 运行中，通常在点「运行」后该节点正在执行时显示 |
| **Error** | 节点错误。跑完工作流后若该节点输入有问题就出现，**有问题的输入会被标红**；需要修复该输入 |
| **Missing** | 缺失状态，通常出现在**导入工作流**之后。两种成因见下 |

**Missing 的两种可能**（这条对排查极有用）：

1. **Comfy Core 原生节点缺失** —— 通常是 ComfyUI 已更新、而你用的还是旧版；**更新 ComfyUI 即可解决**。
2. **自定义节点缺失** —— 工作流用了第三方作者开发的自定义节点，而你本地没装。用 [ComfyUI Manager](https://docs.comfy.org/manager/overview) 找到并安装，或参考 [如何安装自定义节点](https://docs.comfy.org/installation/install_custom_node)。

### 节点右键菜单里的「模式（Mode）」

官方菜单里会显示 Always / Never / On Event / On Trigger **四个模式，但实际只有 Always 和 Never 起作用**——`On Event` 和 `On Trigger` 官方明确说**功能尚未实现、当前无效**。此外还可把 **Bypass** 理解为一种模式：

| 模式 | 行为 |
|---|---|
| **Always** | 默认。首次运行、或自上次执行以来任一输入发生变化时，节点都会执行 |
| **Never** | **永不执行**，等同于被删掉；后续节点**读不到也收不到**它的任何数据 |
| **Bypass** | **永不执行**，但后续节点**仍可尝试拿到未经它处理的数据** |

官方给了一个对比例子（两个工作流都用了两个 LoRA，差别是一个 `Load LoRA` 设为 `Never`、另一个设为 `Bypass`）：
- `Never` 的节点导致**后续节点报错**，因为收不到任何输入数据；
- `Bypass` 的节点让后续节点**拿到未经处理的数据**，于是它们用第一个 `Load LoRA` 节点的输出，工作流继续正常跑。

> 实践含义：想让某个节点「跳过但仍把输入透传下去」用 **Bypass**；想彻底切断用 **Never**。

### 其他节点操作（官方页面提到的）

- **节点外观**：可改样式、双击标题改节点名、拖任意角缩放。
- **节点徽章（Node Badges）**：可显示**节点 ID** 与**节点来源**。目前 **Comfy Core 节点显示狐狸图标**，自定义节点显示其名称，便于判断节点来自哪个包。可在菜单里设置。
- **输入/输出右键菜单**：从这个节点的输入/输出拖出连线但**没连到任何节点**就松手，会弹出该输入/输出的右键菜单，用于**快速添加匹配类型的节点**（建议数量可在设置里调）。
- **节点选择工具箱（Node Selection Toolbox）**：选中节点时悬浮在节点上方的小工具条，可**改颜色 / 快速设为 Bypass / 锁定节点 / 删除节点**；这些功能右键菜单里也有，工具箱只是快捷方式，可在设置里关掉。
- **子图（Subgraph）**：可把一组选中的节点折叠成**一个可复用的子图节点**，用来整理复杂图并在工作流间复用同一结构。详见 <https://docs.comfy.org/interface/features/subgraph>。

## 连线（link）

节点之间画出来的线/曲线叫 **link**（也叫 **connection** 或 wire）。它**把一个节点的输出接到另一个节点的输入**，定义了数据在整张图里的流向。

- 视觉样式可切换：**曲线（curves）/ 直角（right angles）/ 直线（straight lines）/ 完全隐藏**。改法：**Setup Menu → Display (Lite Graph) → Graph → Link Render Mode**。也可在 **Canvas Menu** 里临时隐藏所有连线。
- 官方建议：**学习、分享、调试时把连线显示出来**（数据流一目了然）；已定稿、不打算再编辑的工作流隐藏连线可减少视觉杂乱。
- **Reroute 节点**：工作流复杂后连线会互相压盖或穿过节点，`Reroute` 节点能手动把一根线绕到图中任意位置，让布局保持清爽可读。ComfyUI 另有一个**内置的原生 reroute** 功能，**官方推荐新工作流用原生这个**。

### 颜色即类型（只允许同色相接）

ComfyUI 里每种数据类型有专属颜色，节点输入/输出端口与连线颜色一致，**只能连接同色的端口**，以此保证工作流的**类型安全（type safety）**。

| 数据类型（data type） | 颜色 |
|---|---|
| diffusion model | lavender（薰衣草） |
| CLIP model | yellow |
| VAE model | rose |
| conditioning | orange |
| latent image | pink |
| pixel image | blue |
| mask | green |
| number（integer 或 float） | 见下方注 |
| mesh | bright green |

> ⚠️ 官方两页对「number」的颜色写法**不一致**：`basic-concepts/nodes` 写的是 **light green**，`basic-concepts/links` 写的是 **Gray**。以你界面上实际颜色为准。
>
> 连接/断开操作：**连接** = 从一个节点的输出点拖到另一个节点**同色**的输入；**断开** = 点住输入端点用鼠标左键拖开，或通过连线中点的菜单取消连接。

## 属性（properties）

节点是**属性的容器**。属性也叫 **parameters** 或 **attributes**，就是「可变的值」。

| 属性值的两种来源 | 说明 |
|---|---|
| **widget** | 用户在节点上直接填的数据输入控件 |
| **input slot / port** | 由**连到该属性输入槽的其他节点**自动驱动 |

**关键点：同一个属性通常可以在 widget 与 input 之间互相转换**，从而在「手动控制」与「自动控制」之间切换。这解释了为什么同一个节点在不同工作流里有时能看到那个参数框、有时它变成了一个输入点。

例子：

- **Load Checkpoint** 节点只有**一个**属性：生成模型 checkpoint 文件的**文件路径**。
- **KSampler** 节点有**多个**属性：采样 **steps** 数、**CFG** scale、**sampler_name** 等。

### 强类型（strongly typed）

ComfyUI 用 **Python** 写，Python 本身对类型很宽容；但**ComfyUI 环境是非常强类型的（strongly typed）**——不同数据类型不能混用。例如**不能把 image 输出接到 integer 输入**。官方认为这是**对用户的一大好处**：它引导正确的工作流搭建方式，并防止程序出错。

常见数据类型术语：文本叫 **string**，整数叫 **integer**，带小数点的是 **floating point number / float**。官方说明「新数据类型一直在加」。

## 自定义节点（Custom Nodes）与核心节点

- ComfyUI 装完就带很多内置节点，这些原生节点叫 **Comfy Core** 节点，**由 ComfyUI 官方维护**。
- 社区作者创建了大量 **custom nodes**，在 <https://registry.comfy.org> 可以找到，极大扩展了 ComfyUI 的能力边界。
- 官方日常推荐用 **ComfyUI Manager** 做自定义节点管理：从注册表搜索安装、更新或禁用包、**检测导入工作流里缺失的节点**、以及管理模型与快照。
  - **Desktop 版本默认已启用 Manager**；**Portable 与手动安装版可能需要先手动开启**。

### 三种安装方式

| 方式 | 要点 |
|---|---|
| **通过 ComfyUI Manager（官方推荐）** | 在 Manager 里搜到要装的节点，点安装即可；依赖会被自动装好 |
| **Git 克隆** | 先确认装了 Git（`git --version`），`cd` 到 `ComfyUI/custom_nodes`，再 `git clone <仓库地址>`；然后**仍需手动装依赖** |
| **手动安装（ZIP）** | 官方**不推荐**，只在 Git 走不通时兜底。从仓库页 `Code` → `Download ZIP`，解压后把代码放进 `ComfyUI/custom_nodes`；然后手动装依赖 |

官方给的可照抄示例（以 Portable 版装在 `D:\ComfyUI_windows_portable` 为例）：

```bash
git --version
cd D:\ComfyUI_windows_portable\ComfyUI\custom_nodes
git clone https://github.com/Comfy-Org/ComfyUI-Manager
```

> 官方提示：**ZIP 手动安装会丢失 git 版本历史信息**，后续不方便做版本管理。另外，访问 GitHub 不畅的地区可把仓库 fork 到 gitee 等其它托管站，再用那个地址安装。

### 装依赖：必须装进 ComfyUI 自己的 Python 环境

这是最常见的坑，官方专门强调：

> **ComfyUI 是 Python 项目，官方为运行 ComfyUI 构建了一个独立的 Python 运行环境，所有相关依赖都必须装进这个独立环境。**
> 如果在**系统级终端**直接跑 `pip install -r requirements.txt`，依赖可能被装进**系统级 Python**，结果 **ComfyUI 环境里依然缺依赖**，节点跑不起来。

按安装形态选命令：

**ComfyUI Portable** —— 用的是内嵌 Python，位于 `\ComfyUI_windows_portable\python_embeded`。要在 Portable 根目录下用内嵌 Python 来装：

```bash
python_embeded\python.exe -m pip install -r ComfyUI\custom_nodes\<节点目录名>\requirements.txt
```

**Comfy Desktop** —— 官方说明 Desktop 安装过程**已经带上了 ComfyUI-Manager 及其依赖**；用 Manager 装节点时依赖会自动装，一般不需要手动操作。若确需手动：

```bash
pip install -r .\custom_nodes\<corresponding_custom_node_name>\requirements.txt
```

**自建 Python 环境** —— 官方建议直接 `pip install -r requirements.txt`。

### 版本控制

自定义节点的版本控制**本质是基于 Git 的**。两条路：

- **用 ComfyUI Manager**：进节点管理界面 → 用过滤器筛出已装的节点包 → 切换版本。**Manager 会帮你完成相应的依赖更新与安装**；换版本后**通常需要重启 ComfyUI** 才生效。
- **用 Git**：
  ```bash
  cd <安装目录>/ComfyUI/custom_nodes/ComfyUI-Manager
  git tag                      # 列出所有可用 tag / release
  git checkout <tag_name>      # 切到指定 tag
  git checkout <commit_hash>   # 或切到指定 commit
  ```
  切完版本后**必须重装依赖**（依赖可能变了）。

> ⚠️ **官方该页未覆盖**：`basic-concepts/custom-nodes` 里 **「卸载自定义节点」「临时禁用自定义节点」「自定义节点依赖冲突」三节在官方页面上的内容就是一句 `To be updated`**——官方还没写。相关排查请见 `references/06-troubleshooting.md`。

### ComfyUI Manager 的地位（官方说明）

ComfyUI-Manager 已**正式加入 Comfy Org 组织**，**成为 ComfyUI 核心依赖的一部分**，仍由原作者 [@Dr.Lt.Data](https://github.com/ltdrdata) 维护。安装命令：

```bash
git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
```

装好后可以在 Manager 里**检测缺失节点（Detecting Missing Nodes）**。

## 依赖（dependencies）：工作流跑不起来到底缺什么

社区拿来的工作流经常**加载后直接跑不了**，因为一个工作流文件**还依赖工作流以外的其它文件**。官方把依赖分成四类：

1. **Assets（素材）** —— 音频、视频、图片等输入媒体文件
2. **Custom nodes（自定义节点）**
3. **Python dependencies（Python 依赖包）**
4. **Models（模型）**

> **asset（素材）** 的定义：在媒体制作里，asset 是提供输入数据的媒体文件。就像剪辑软件的项目文件里存的是**指向磁盘上影片文件的链接**、从而做到不修改原片的非破坏性编辑；ComfyUI 同理——**只有当所有必需的 asset 都能找到并加载时，工作流才跑得起来**。生成式 AI 模型、图片、影片、声音都可能成为工作流的 ***dependent assets / asset dependencies***。

### Python 依赖

ComfyUI 用它自己**独立的 Python 环境**运行，所有相关依赖都装在这个隔离环境里。当前依赖清单见官方 [requirements.txt](https://github.com/Comfy-Org/ComfyUI/blob/master/requirements.txt)（官方页面贴出的版本快照节选）：

```text
comfyui-frontend-package==1.49.6
comfyui-workflow-templates==0.11.48
comfyui-embedded-docs==0.5.10
torch
torchsde
torchvision
torchaudio
numpy>=1.25.0
einops
transformers>=4.50.3
tokenizers>=0.13.3
sentencepiece
safetensors>=0.4.2
aiohttp>=3.11.8
yarl>=1.18.0
pyyaml
Pillow
scipy
tqdm
psutil
alembic
SQLAlchemy>=2.0.0
filelock
av>=17.0.0
comfy-kitchen==0.2.31
comfy-aimdo==0.4.15
requests
simpleeval>=1.0.0
blake3

#non essential dependencies:
kornia>=0.7.1
spandrel
pydantic~=2.0
pydantic-settings~=2.0
PyOpenGL>=3.1.8
comfy-angle
```

> 注意里面两项值得记住：**`comfyui-workflow-templates`** 是内置模板的来源包；**`comfyui-embedded-docs`** 是节点内嵌文档的来源包。
>
> 用 Git 更新 ComfyUI 后，**要在对应环境里跑一次** `pip install -r requirements.txt` 才能保证依赖跟上。
> 前端（`ComfyUI_frontend`）是**独立项目**维护的，通过 `comfyui-frontend-package` 依赖版本发布；要换前端版本可查 <https://pypi.org/project/comfyui-frontend-package/#history>。

**自定义节点的依赖**：通常每个自定义节点自带 `requirements.txt`。用 **ComfyUI Manager 装节点时它会自动装依赖**。需要手动装时，所有自定义节点都装在 `ComfyUI/custom_nodes` 目录下，**进入 ComfyUI 的 Python 环境**、到对应插件目录跑 `pip install -r requirements.txt`。Portable 版用：

```
python_embeded\python.exe -m pip install -r ComfyUI\custom_nodes\<custom_node_name>\requirements.txt
```

### 依赖冲突（官方列了三类成因与解法）

**症状**：装/更新某个自定义节点后，**之前能用的自定义节点在节点库里消失了**，或者弹错误框。

| 成因 | 官方给的解法 |
|---|---|
| **1. 节点锁死了依赖版本** —— 有的插件固定精确版本（如 `open_clip_torch==2.26.1`），另一个插件要求更高版本（如 `open_clip_torch>=2.29.0`），两者无法同时满足 | 把固定版本改成**范围约束**（如 `open_clip_torch>=2.26.1`），再重装依赖 |
| **2. 环境污染** —— 装依赖时**覆盖掉**了其它插件已装的库版本（例如多个插件都依赖 `PyTorch` 但要不同 CUDA 版本，后装的把现有环境弄坏） | ① 在 Python 虚拟环境里手动装指定版本；② 或给不同插件建**不同的 Python 虚拟环境**；③ 或**一次只装一个插件，每装一个重启 ComfyUI** 观察是否冲突 |
| **3. 自定义节点依赖版本与 ComfyUI 自身依赖版本不兼容** | 官方说这类**较难解决**，可能需要**升级/降级 ComfyUI**，或改自定义节点的依赖版本 |

### 模型（Models）

模型是 ComfyUI **最重要的 asset 依赖**。各种自定义节点与工作流都是围绕特定模型构建的（如 Stable Diffusion 系列、Flux 系列、Ltxv 等）。模型通常放在 **`ComfyUI/models/`** 下对应的子目录里。

也可以**改 `extra_model_paths.yaml` 模板**（官方模板文件：[extra_model_paths.yaml.example](https://github.com/Comfy-Org/ComfyUI/blob/master/extra_model_paths.yaml.example)）来让 ComfyUI 识别**额外的模型路径**——这样**多个 ComfyUI 实例可以共享同一套模型库，省磁盘**。

详见 `references/05-models-and-directories.md`。

### 软件依赖

ComfyUI 作为一个较复杂的应用还有**软件依赖（software dependencies）**——运行所需的代码库与数据。**自定义节点就是软件依赖的例子**；更底层的是 **Python 编程环境本身**，它是 ComfyUI 的**终极依赖**：跑某个版本的 ComfyUI 需要**正确版本的 Python**。**Python、ComfyUI、自定义节点三者的更新都可以在 ComfyUI Manager 窗口里处理。**

## 上手路径（官方建议）

**从模板开始**：打开 **Workflow → Browse Workflow Templates**，模板提供可直接运行和编辑的完整示例。模板用的都是 ComfyUI 自带的 **Core** 节点，并且**会提示你下载所需的模型**。
