# 自定义节点与节点管理（ComfyUI-Manager）

> 来源：https://docs.comfy.org/custom-nodes/intro
> 来源：https://docs.comfy.org/custom-nodes/overview
> 来源：https://docs.comfy.org/installation/install_custom_node
> 来源：https://docs.comfy.org/manager/overview
> 来源：https://docs.comfy.org/manager/install
> 来源：https://docs.comfy.org/manager/pack-management
> 来源：https://docs.comfy.org/manager/configuration
> 来源：https://docs.comfy.org/manager/troubleshooting
> 抓取日期：2026-10-03

## 一句话结论

**自定义节点（custom node）就是给 ComfyUI 加功能的扩展**，社区开发、数量巨大，注册表在 <https://registry.comfy.org>。**安装永远是两步：① 把节点代码放进 `ComfyUI/custom_nodes`；② 装它的 Python 依赖。** 这两步**必须都做**，且**依赖必须装进 ComfyUI 自己的 Python 环境**（装到系统级环境是最常见的失败原因）。日常管理统一用 **ComfyUI-Manager**——它**已并入 ComfyUI 核心**，Desktop 版自带并自动启用，Portable / 手动安装版需要**手动开启**。

## 自定义节点是什么 / 边界在哪

ComfyUI 装完自带的官方节点叫 **Comfy Core** 节点；**自定义节点**是社区作者创建的、能带来大量功能的扩展。官方对使用侧的定义：

> 自定义节点是给 ComfyUI **增加新功能**的扩展，例如高级图像处理、机器学习微调、颜色调整等。**社区开发的节点能显著扩展 ComfyUI 的核心能力。**

### 开发侧：ComfyUI 是客户端-服务器模型

| 角色 | 语言 | 负责什么 |
|---|---|---|
| **server** | Python | **所有真正的工作**：数据处理、模型、图像扩散等 |
| **client** | JavaScript | 用户界面 |

ComfyUI **也可以用在 API 模式**下：这时工作流由**非 Comfy 客户端**（比如另一个 UI、或一个命令行脚本）发给服务器。自定义节点按这个模型分**四类**：

| 类别 | 说明 |
|---|---|
| **Server side only（仅服务端）** | **绝大多数**自定义节点属于此类：定义一个 Python 类，声明输入/输出类型，并提供处理输入、产出输出的函数 |
| **Client side only（仅客户端）** | 少数节点只改客户端 UI、不增加核心功能；**尽管叫这个名字，它们甚至可能不新增节点** |
| **Independent Client and Server（客户端与服务端相互独立）** | 同时提供服务端功能与相关的 UI 功能（例如为新数据类型做一个新 widget）；多数情况下前后端通信由 Comfy 的数据流控制处理 |
| **Connected Client and Server（客户端与服务端需直接交互）** | 少数情况，UI 与服务端必须**直接**互相通信 |

> ⚠️ **官方原文警告：任何需要客户端-服务端通信的节点，都无法通过 API 使用。**（`Any node that requires Client-Server communication will not be compatible with use through the API.`）
> **对本项目意义重大**：走 MCP / API 提交工作流（见 `references/01-mcp-agent-tools.md`）时，这类「Connected」节点**不可用**。挑节点时优先选纯服务端节点。

开发入口（官方给的路径）：新手 → `custom-nodes/overview`；做后端 → `custom-nodes/backend/server_overview`；扩展 UI → `custom-nodes/js/javascript_overview`；发布包 → `registry/overview`。官方示例仓库：<https://github.com/Comfy-Org/cookiecutter-comfy-extension>、<https://github.com/Comfy-Org/ComfyUI-React-Extension-Template>、<https://github.com/jtydhr88/ComfyUI_frontend_vue_basic>。

## 安装：三种方式

**所有安装方式都必须完成这两步：**

1. **把节点代码克隆到 `ComfyUI/custom_nodes` 目录**
2. **安装所需的 Python 依赖**

官方对照表：

| 方式 | 优点 | 缺点 |
|---|---|---|
| **ComfyUI Manager（推荐）** | ① 自动安装 ② **自动处理依赖** ③ GUI 界面 | **无法直接搜索未在注册表（registry）登记的节点** |
| **Git Clone** | 能装**未登记在注册表**里的节点 | ① 需要 Git 知识 ② **手动处理依赖** ③ 有安装风险 |
| **仓库 ZIP 下载** | ① 不需要 Git ② 手动可控 | ① 手动处理依赖 ② **无版本控制** ③ 有安装风险 |

> 官方提示：装之前**先看插件的 README**，了解安装方式、用法，以及它要求的特定模型、依赖版本、常见问题解法。

### ⚠️ 安全警告（官方原文要点）

ComfyUI 是开源项目，**恶意插件可能通过自定义节点利用你的系统**。官方要求：

1. **只装可信作者、且社区普遍在用的**自定义节点；
2. 装之前**先搞清插件的功能**，避免不明来源，保证系统安全；
3. **避免安装冷门或可疑插件**——未经验证的插件可能带来安全风险，**导致系统被入侵**。

### 方式 2：Git 手动安装

要求系统已装 [Git](https://git-scm.com/)。四步：

```bash
# 1. 在 GitHub 仓库页点 "Code" 按钮，复制 HTTPS 链接

# 2. 进入 custom_nodes 目录
cd /path/to/ComfyUI/custom_nodes

# 3. 克隆仓库
git clone [repository URL]

# 4. 装依赖（必须装进 ComfyUI 环境，别和系统环境混，避免污染）
```

**装依赖命令按安装形态选：**

```bash
# Windows Portable：装进内嵌 Python
python_embeded\python.exe -m pip install -r ComfyUI\custom_nodes\[node directory]\requirements.txt

# 手动安装：装进 ComfyUI 环境
cd [node directory]
pip install -r requirements.txt
```

**最后：重启 ComfyUI 并刷新浏览器，检查启动日志里有没有 `import failed` 错误。**

### 方式 3：ZIP 下载安装

适用于**既用不了 Git 也用不了 Manager** 的人。官方**不推荐**，因为**会丢失版本控制能力**。

1. GitHub 页面点 `Code` → `Download ZIP`
2. 解压 ZIP
3. 把解压出来的文件夹拷进 **`ComfyUI/custom_nodes/`**
4. 手动装依赖（同 Git 方式的第 4 步）
5. 重启 ComfyUI 并刷新浏览器
6. **验证**：重启后在 ComfyUI Manager 里确认插件装好了、**没有 `import failed` 错误**

### 依赖装错环境的后果（务必记住）

ComfyUI 是 **Python** 项目，官方为运行 ComfyUI 构建了**独立的 Python 运行环境**，**所有相关依赖都必须装进这个环境**。如果在**系统级终端**直接跑 `pip install -r requirements.txt`，依赖可能被装进**系统级 Python**，结果 **ComfyUI 环境里依然缺依赖，节点跑不起来**。

各形态的正确做法：

| 形态 | 用什么 Python | 命令 |
|---|---|---|
| **ComfyUI Portable** | 内嵌 Python，位于 `\ComfyUI_windows_portable\python_embeded` | `python_embeded\python.exe -m pip install -r ComfyUI\custom_nodes\<节点目录名>\requirements.txt` |
| **Comfy Desktop** | Desktop 已自带 Manager 及其依赖；**用 Manager 装节点时依赖会自动装**，一般无需手动 | `pip install -r .\custom_nodes\<对应节点名>\requirements.txt` |
| **自建 Python 环境** | 自己的 venv | `pip install -r requirements.txt` |

> 用 **ComfyUI Manager 装插件，它会自动帮你完成依赖安装**，装完只要重启 ComfyUI——这就是官方强烈推荐用 Manager 的原因。

### 版本控制

自定义节点的版本控制**本质基于 Git**。ZIP 手动安装会**丢失 git 版本历史**，无法做版本管理。

- **用 Manager**：进节点管理界面 → 用过滤器筛出已装的节点包 → 切换版本。**Manager 会帮你完成相应的依赖更新与安装**；换版本后**通常需要重启 ComfyUI** 才生效。
- **用 Git**：
  ```bash
  cd <安装目录>/ComfyUI/custom_nodes/ComfyUI-Manager
  git tag                  # 列出所有可用 tag / release
  git checkout <tag_name>  # 切到指定 tag
  git checkout <commit_hash>  # 或切到指定 commit
  ```
  切完**必须重装依赖**（依赖可能变了）。

## ComfyUI-Manager

### 它能干什么（官方列出的核心功能）

> **ComfyUI-Manager** 是一个增强 ComfyUI 可用性的扩展，提供**安装、移除、禁用、启用**各类自定义节点的管理功能，另外还提供 hub 特性与便利功能，用于访问 ComfyUI 内的大量信息。

| 核心功能 | 说明 |
|---|---|
| **自定义节点管理** | 安装、更新、移除、禁用自定义节点 |
| **模型管理** | 从各种来源**下载并管理模型** |
| **快照管理（Snapshot）** | **保存与恢复安装状态** |
| **缺失节点检测** | 从工作流中**自动检测并安装缺失的节点** |

Manager 有**两套 UI**：**新 UI（new UI，Desktop 默认）** 与 **Legacy UI（旧界面）**。

### 安装 / 启用（按你的安装形态）

**Desktop 用户** —— **什么都不用装**：Comfy Desktop **每次安装 ComfyUI 都会一起装上 ComfyUI-Manager，并以 `--enable-manager` 启动它**。Manager 是**按安装实例（per installation）**在 app 内配置的：

1. 在 Comfy Desktop 里打开该实例，进入 **Manage panel**，切到 **Startup Args** 标签页
2. 设置两个选项（**下次启动该实例时生效**）：
   - **Manager Security Level** —— 决定 Manager **允许安装哪些节点包**：`Strict` / `Standard`（**推荐**）/ `Relaxed` / `Permissive`。**当 ComfyUI 用 `--listen` 暴露在网络上时，更严格的级别尤其重要。**
   - **Manager Network Mode** —— 决定 Manager **怎么访问节点注册表**：`Public`（默认）/ `Private` / `Offline` / `Personal cloud`（**仅限你自己控制的机器**）
3. （可选）改启动参数：**同一个标签页**的 **Startup Arguments** 控制该实例启动时带的 flag。**删掉 `--enable-manager` 就能不带 Manager 启动**；或者**保留它再加 `--disable-manager-ui`**，这样**隐藏 Manager UI 但后台任务继续跑**。

**Portable 用户** —— 新版 Manager **已内置在 ComfyUI 核心里，但需要手动启用**：

```bash
# 1. 装 Manager 依赖
.\python_embeded\python.exe -m pip install -r ComfyUI\manager_requirements.txt

# 2. 带 manager 启动
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --enable-manager
pause
```

**手动安装用户** —— 同样**已内置但需启用**：

```bash
# 1. 激活虚拟环境
venv\Scripts\activate          # Windows
source venv/bin/activate       # Linux/macOS

# 2. 装 Manager 依赖
pip install -r manager_requirements.txt

# 3. 带 --enable-manager 启动
python main.py --enable-manager
```

### Manager 相关启动参数

| Flag | 说明 |
|---|---|
| `--enable-manager` | 启用 ComfyUI-Manager |
| `--enable-manager-legacy-ui` | 使用**旧版** Manager UI 而非新 UI（**需要同时有 `--enable-manager`**） |
| `--disable-manager-ui` | 禁用 Manager 的 UI 与端点，**但保留后台功能**（**需要同时有 `--enable-manager`**） |

**在新 UI / 旧 UI 之间切换**（注意：此版本切换**只支持 pip 安装**；**通过 custom_nodes 方式安装的版本不支持切到新 UI**）：

```bash
python main.py --enable-manager                          # 新 UI
python main.py --enable-manager --enable-manager-legacy-ui  # 旧 UI
```

Desktop 用户切换旧 UI：**Server Settings → UI Settings → Use legacy manager interface**。

### 更新 ComfyUI-Manager

**它是以独立的 Python 包形式发布的**，**ComfyUI 核心在 `manager_requirements.txt` 里钉住了与之配套的版本**。

| 安装形态 | 更新方式 |
|---|---|
| **Desktop** | Desktop 自带 Manager，**跟随 Comfy Desktop 更新保持最新**；ComfyUI 引擎则从 Manage panel 更新 |
| **Portable / 手动安装** | **更新 ComfyUI 可能不会动已装的 Manager 包**。要在**你启动 ComfyUI 的那个环境**里装 manager 依赖，然后带 `--enable-manager` 重启 |
| **Git clone 装的** | `cd ComfyUI/custom_nodes/comfyui-manager` → `git pull` → 重启 ComfyUI |

```bash
# Portable (Windows)
.\python_embeded\python.exe -m pip install -r ComfyUI\manager_requirements.txt
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --enable-manager

# Manual install
pip install -r manager_requirements.txt
python main.py --enable-manager
```

### 旧式安装方式（官方归入 "Legacy installation methods"）

<details open>
<summary>四种旧方式（新安装推荐用 comfy-cli 那条）</summary>

1. **Git clone（通用）**：
   ```bash
   cd ComfyUI/custom_nodes
   git clone https://github.com/Comfy-Org/ComfyUI-Manager comfyui-manager
   cd comfyui-manager
   pip install -r requirements.txt
   ```
   然后重启 ComfyUI。
2. **Portable（Windows）**：装 [Git for Windows](https://git-scm.com/download/win)（standalone 版，选 "use windows default console window"）→ 下载 [install-manager-for-portable-version.bat](https://github.com/Comfy-Org/ComfyUI-Manager/raw/main/scripts/install-manager-for-portable-version.bat) 到 `ComfyUI_windows_portable` 目录 → 双击运行。
3. **comfy-cli（新安装官方推荐）**：前置 = Python 3 + Git。
   ```bash
   python -m venv venv
   venv\Scripts\activate       # Windows（Linux/macOS 用 . venv/bin/activate）
   pip install comfy-cli
   comfy install
   ```
   另见 <https://docs.comfy.org/comfy-cli/getting-started>。
4. **Linux + venv**：前置 = `python-is-python3`、`python3-venv`、`git` → 下载 [install-comfyui-venv-linux.sh](https://github.com/comfy-org/ComfyUI-Manager/raw/main/scripts/install-comfyui-venv-linux.sh) 到空安装目录 → `chmod +x` 后运行 → 用 `./run_gpu.sh` 或 `./run_cpu.sh` 启动。

</details>

> ⚠️ **安装路径的三条硬性禁忌**（官方 Warning）：
> - Manager 文件**必须**准确位于路径 **`ComfyUI/custom_nodes/comfyui-manager`**
> - **不要**直接解压到 `ComfyUI/custom_nodes`（像 `__init__.py` 这类文件**不应该**出现在该目录下）
> - **不要**装成 `ComfyUI/custom_nodes/ComfyUI-Manager/ComfyUI-Manager` 或 `ComfyUI/custom_nodes/ComfyUI-Manager-main` 这类路径

## 用新 UI 管理节点

**界面三块**：

1. **左侧栏（Filters）**：过滤**已安装节点 / 工作流中的节点 / 缺失节点 / 可更新节点**等
2. **顶部搜索栏**：搜索 **Node Pack（整个节点包）** 或 **Node（单个节点）**，用 Filter 下拉切换搜索类型
3. **右侧详情面板**：点节点显示描述、启用状态、版本信息等；**Description 标签**含仓库信息，**Nodes 标签**预览该包里的全部节点

**各操作步骤**：

| 操作 | 怎么做 |
|---|---|
| **搜索** | Manager **支持「节点包」与「单个节点」分开搜**；`Node Pack` = 完整的自定义节点包，`Individual Node` = 在节点包里搜单个节点 |
| **安装** | 选中对应节点卡片 → 在展开的信息里点 **Install**；或先在 **Version** 里选特定版本再装 |
| **更新** | 用 **Update available** 过滤器筛出可更新的节点（**会有更新箭头标记**）→ 在 **Version** 里选版本 → 点 **Update** |
| **找缺失节点** | **加载含缺失节点的工作流时会自动弹提示**：可选 **Install All** 一次装完，或 **Open Manager** 先浏览细节再决定。也可**选中该节点 → 在预览面板点 `Missing` 按钮**查找缺失节点 |
| **卸载** | 选中已安装节点 → 在预览面板点 **Uninstall** |

**新 UI 的两个常见疑问（官方 FAQ）**：

1. **为什么找不到我需要的节点？** —— 新 Manager **只支持从 [registry](https://docs.comfy.org/registry/overview) 安装节点**。如果节点没登记在注册表里，**先在 Manager 里登记它**。
2. **为什么找不到「通过 git 安装」的选项？** —— 为了 ComfyUI 用户系统的**安全与稳定，新 UI 不支持通过 git 安装节点**。请改用[手动安装自定义节点](https://docs.comfy.org/installation/install_custom_node)。

## Manager 配置

### 配置路径（V3.38 起用受保护的系统路径）

| ComfyUI 版本 | Manager 路径 |
|---|---|
| **v0.3.76+（带 System User API）** | **`<USER_DIRECTORY>/__manager/`** |
| 更老版本 | `<USER_DIRECTORY>/default/ComfyUI-Manager/` |

`<USER_DIRECTORY>` **不带任何参数运行时默认为 `ComfyUI/user`**，可用 **`--user-directory <USER_DIRECTORY>`** 指定。

### 配置文件清单

| 文件 | 说明 |
|---|---|
| `config.ini` | **基础配置** |
| `channels.list` | 可配置的 channel 列表 |
| `pip_overrides.json` | 自定义 pip 包映射 |
| `pip_blacklist.list` | **阻止安装**的包 |
| `pip_auto_fix.list` | 自动恢复的包 |
| `snapshots/` | 保存的快照文件 |
| `startup-scripts/` | 启动脚本文件 |
| `components/` | 组件文件 |

### `config.ini` 全部选项（官方原文）

```ini
[default]
git_exe = <path to git executable>
use_uv = <True/False - use uv instead of pip>
default_cache_as_channel_url = <True/False - retrieve DB designated as channel_url at startup>
bypass_ssl = <True/False - disable SSL if errors occur>
file_logging = <True/False - create log file>
windows_selector_event_loop_policy = <True/False - fix event loop errors on Windows>
model_download_by_agent = <True/False - use agent for model downloads>
downgrade_blacklist = <comma-separated list of packages to prevent downgrades>
security_level = <strong|normal|normal-|weak>
always_lazy_install = <True/False - perform dependency installation on restart>
network_mode = <public|private|offline>
```

> `config.ini` 的路径会在**启动日志里打印出来**。

**`network_mode`**：

| 模式 | 说明 |
|---|---|
| `public` | 标准公网环境 |
| `private` | 封闭网络，通过 `channel_url` 配置私有节点 DB（**有缓存就用缓存**） |
| `offline` | **不建立任何外部连接**（有缓存就用缓存） |

**`security_level` 与功能风险等级的对应**：

| 级别 | 说明 |
|---|---|
| `strong` | **不允许**高风险与中风险功能 |
| `normal` | 不允许高风险；**中风险可用** |
| `normal-` | **当指定了 `--listen` 且地址不以 `127.` 开头时**不允许高风险；中风险可用 |
| `weak` | **所有功能都可用** |

| 风险等级 | 包含哪些功能 |
|---|---|
| **High（高）** | **通过 git url 安装**、`pip install`、**安装不在默认 channel 里的自定义节点**、修复自定义节点 |
| **Middle（中）** | **卸载/更新**、安装默认 channel 里的自定义节点、恢复/删除快照、重启 |
| **Low（低）** | 更新 ComfyUI |

> 因此：**想通过 git URL 装节点或使用 nightly 版本，需要把 `security_level` 设为 `weak`。**

### 环境变量

| 变量 | 说明 |
|---|---|
| `COMFYUI_PATH` | ComfyUI 的安装路径 |
| `GITHUB_ENDPOINT` | GitHub 访问的**反向代理** |
| `HF_ENDPOINT` | Hugging Face 访问的**反向代理** |

```bash
# 通过代理重定向 GitHub 请求
GITHUB_ENDPOINT=https://mirror.ghproxy.com/https://github.com

# 换 Hugging Face 端点
HF_ENDPOINT=https://some-hf-mirror.com
```

### 进阶配置

| 想做什么 | 怎么做 |
|---|---|
| **阻止特定包被降级** | 在 `config.ini` 的 `downgrade_blacklist` 里列包名、逗号分隔：`downgrade_blacklist = diffusers, kornia` |
| **自定义 pip 映射** | 建 `pip_overrides.json`，把特定 pip 包的安装改成用户自定义安装；格式参考 `pip_overrides.json.template` |
| **阻止安装特定 pip 包** | 在 `pip_blacklist.list` 里**一行一个**列包名 |
| **自动恢复 pip 安装** | 在 `pip_auto_fix.list` 里写 pip spec 要求（类似 `requirements.txt`）。**启动 ComfyUI 时、或装自定义节点过程中版本不匹配时，会自动恢复指定版本**。可用 `--index-url` |
| **用 aria2 加速下载** | 见官方指南 <https://github.com/Comfy-Org/ComfyUI-Manager/blob/main/docs/en/use_aria2.md> |

### `extra_model_paths.yaml` 里与 Manager 相关的两项

官方说明：**以下设置基于被标记为 `is_default` 的那个 section 生效**：

- **`custom_nodes`** —— **安装自定义节点的路径**
- **`download_model_base`** —— **下载模型的路径**

### CLI：`cm-cli`

Manager 提供 **`cm-cli`** 命令行工具，**让你不启动 ComfyUI 也能用 Manager 的功能**——适合**自动化安装自定义节点**以及在**无头（headless）环境**里做管理。详细文档：<https://github.com/Comfy-Org/ComfyUI-Manager/blob/main/docs/en/cm-cli.md>。想要更完整的 CLI 体验，官方建议用 [comfy-cli](https://docs.comfy.org/comfy-cli/getting-started)。

## Manager 故障排查

### 常见问题

| 症状 | 官方解法 |
|---|---|
| **git.exe 装在非系统默认位置** | 装好 Manager 并**跑一次 ComfyUI** → 打开 `<USER_DIRECTORY>/default/ComfyUI-Manager/config.ini` → 在 `git_exe =` 里写**含文件名的完整路径**，如 `git_exe = C:\Program Files\Git\bin\git.exe` |
| **Manager 自身更新失败** | 进 Manager 目录跑：`git update-ref refs/remotes/origin/main a361cc1 && git fetch --all && git pull` |
| **Windows：`Overlapped Object has pending operation at deallocation on ComfyUI Manager load`** | 在 `config.ini` 加 `windows_selector_event_loop_policy = True` |
| **`SSL: CERTIFICATE_VERIFY_FAILED`** | 在 `config.ini` 加 `bypass_ssl = True` |
| **`This action is not allowed with this security level configuration`**（在用 git URL 装节点、或用 nightly 版本时出现） | 调整 `config.ini` 里的 `security_level`（见上方安全级别表；要 git URL / nightly 需 `weak`） |
| **GitHub 访问受限** | 设 `GITHUB_ENDPOINT` |
| **Hugging Face 访问受限** | 设 `HF_ENDPOINT` |

### 安装路径错误的四种典型（官方表）

| 问题 | 具体表现 |
|---|---|
| 文件放错位置 | Manager 的 `__init__.py` 之类的文件**被直接放在 `custom_nodes` 目录下** |
| **双层嵌套目录** | 装成了 `custom_nodes/ComfyUI-Manager/ComfyUI-Manager` |
| 文件夹名不对 | 装成了 `custom_nodes/ComfyUI-Manager-main` |
| 压缩包格式 | 从压缩文件安装但**没有正确解压** |

> ⚠️ 官方警告：**装错位置的 Manager 可能「看起来能用」，但不会被识别为可更新，还可能导致重复安装。** 要删掉它，并**用 `git clone` 正确重装**。

### scanner 脚本

运行 `scan.sh` 时：

- 它会把 `custom-node-list.json` 里列出的自定义节点**拉取/克隆到 `~/.tmp/default`**，以此更新 `extension-node-map.json`
- 它用 **GitHub API** 更新 `github-stats.json`

| 选项 | 说明 |
|---|---|
| `--skip-update` | 跳过更新 `extension-node-map.json` |
| `--skip-stat-update` | 跳过更新 `github-stats.json` |
| `--skip-all` | 两步更新都跳过 |

> 为避免 GitHub API 速率限制，设置你的 token：`export GITHUB_TOKEN=your_token_here`。
> 想指定 `~/.tmp/default` 之外的路径，就直接跑 `python scanner.py [path]` 而不是 `scan.sh`。

### 还解决不了时（官方给的三步）

1. 查 [ComfyUI-Manager GitHub issues](https://github.com/Comfy-Org/ComfyUI-Manager/issues) 里有没有同类问题
2. **看启动日志里的错误详情**
3. 加入 [ComfyUI Discord](https://discord.com/invite/comfyorg) 找社区支持

## 自定义节点还能带哪些附加资源（作者侧）

在 ComfyUI 里，自定义节点除了基本功能，**还可以带上这些资源**：

- **节点文档（Node Documentation）** —— 该功能**支持所有自定义节点与基础节点**；可用来查看节点文档、理解用途与用法，并能**通过 PR 向作者贡献文档**。见 <https://docs.comfy.org/custom-nodes/help_page>
- **自定义节点工作流模板** —— 作者提供的示例工作流，可在 ComfyUI 的模板里浏览和加载。见 `references/07-templates.md`
- **多语言支持（i18n）** —— 见 <https://docs.comfy.org/custom-nodes/i18n>

## 官方该页未覆盖 / 官方文档自身的瑕疵

- `basic-concepts/custom-nodes` 里的**「卸载自定义节点」「临时禁用自定义节点」「自定义节点依赖冲突」三节，官方正文就是一句 `To be updated`**——还没写。卸载/禁用请用 Manager 新 UI（本文档已给步骤）；依赖冲突的三大成因与解法见 `references/02-core-concepts.md`。
- **配置路径的官方描述自相矛盾**：`manager/configuration` 与 `manager/troubleshooting` 的 "Security policy" 一节都写 **v0.3.76+ 用 `<USER_DIRECTORY>/__manager/`**；但 `manager/troubleshooting` 的 **"Custom git executable path"** 一节仍写 **`<USER_DIRECTORY>/default/ComfyUI-Manager/config.ini`**。以**启动日志里打印的实际路径**为准。
- **Comfy Registry 的发布流程**（`registry/*` 系列页面）属于**发布自定义节点**的开发者流程，本项目不做展开，需要时用 `web_fetch` 抓 `https://docs.comfy.org/registry/overview`（索引见 `references/00-site-index.md` 的栏目三）。
