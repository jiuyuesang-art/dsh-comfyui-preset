# 官方模板库（Workflow Templates）

> 来源：https://docs.comfy.org/interface/features/template
> 来源：https://docs.comfy.org/custom-nodes/workflow_templates
> 来源：https://docs.comfy.org/agent-tools/cli （只取模板相关命令）
> 来源：https://docs.comfy.org/development/overview
> 抓取日期：2026-10-03

## 一句话结论

**Workflow Templates 是 ComfyUI 内置的「现成工作流浏览器」**，里面既有**一方原生支持的模型工作流**，也有**自定义节点作者提供的示例工作流**。模板本身由**独立依赖包 [`comfyui-workflow-templates`](https://pypi.org/project/comfyui-workflow-templates/)** 管理与更新——所以「更新 ComfyUI 后看不到新模板」通常**不是 ComfyUI 的问题，而是这个依赖没跟着升级**。每个模板**在 JSON 里内嵌了它所需模型的下载直链**，加载时会自动检查并提示下载缺失模型。

## 模板库在哪、怎么打开

- 点**侧边栏的 `Templates` 图标**
- 或走菜单 **`Workflow` → `Browse Workflow Templates`**

在模板库里能找到两类东西：

1. **原生支持的模型工作流**（natively supported model workflows）
2. **自定义节点的示例工作流**（example workflows from custom nodes）

## 怎么用模板（官方三步）

1. **加载模板**：点任意模板即可加载它的工作流。
2. **下载模型**：加载模板时，**ComfyUI 会自动检查所有必需的模型文件是否存在**；有缺失就会**提示你下载模型**。
3. **运行工作流**：当所有条件（模型、输入图像、prompt 等）都就绪后，点 **Run** 开始跑。

## 模型存放位置与「缺失模型」检测的真实规则（很实用）

**每个工作流模板都内嵌了所需模型的链接。** 首次使用时如果检测不到对应模型文件，就会看到下载提示。

| 安装形态 | 点 `Download` 之后会怎样 |
|---|---|
| **桌面版（Desktop）** | **桌面程序自动帮你下载**模型文件 |
| **其它版本** | 用**浏览器**下载对应模型，**你需要自己把它保存到 `ComfyUI/models` 下对应的文件夹** |

官方给的例子（截图里那个模板需要的文件与落位）：

```
📂 ComfyUI/
├── 📂 models/
│   ├── 📂 diffusion_models/
│   │   └── qwen_image_fp8_e4m3fn.safetensors
│   ├── 📂 vae/
│   │   └── qwen_image_vae.safetensors
│   └── 📂 text_encoders/
│       └── qwen_2.5_vl_7b_fp8_scaled.safetensors
```

> 注意这里面出现了 **`text_encoders/`** 目录（文本编码器权重的落位目录之一）。

### ⚠️ 缺失检测的规则（否则你会被弹窗误导）

官方原文：**当前版本的缺失文件检测，只检查「对应顶层目录下是否存在同名文件」**。例如文件必须**直接**存在于 `ComfyUI/models/diffusion_models` 下。

**如果你已经把模型下载到了子文件夹**（例如 `ComfyUI/models/diffusion_models/wan_video`），**你可以直接忽略这个弹窗**，只要**在对应的模型加载节点里选中正确的模型**就行。

## 模型链接是怎么内嵌进模板的

官方说明：**在节点的 `properties` 下加一个 `models` 字段**。完整的 `DualCLIPLoader` 节点片段（官方原文照录）：

```json
    {
      "id": 40,
      "type": "DualCLIPLoader",
      "pos": [
        -320,
        290
      ],
      "size": [
        270,
        130
      ],
      "flags": {},
      "order": 0,
      "mode": 0,
      "inputs": [],
      "outputs": [
        {
          "name": "CLIP",
          "type": "CLIP",
          "links": [
            64
          ]
        }
      ],
      "properties": {
        "Node name for S&R": "DualCLIPLoader",
        "cnr_id": "comfy-core",
        "ver": "0.3.40",
        "models": [
          {
            "name": "clip_l.safetensors",
            "url": "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors",
            "directory": "text_encoders"
          },
          {
            "name": "t5xxl_fp16.safetensors",
            "url": "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors",
            "directory": "text_encoders"
          }
        ]
      },
      "widgets_values": [
        "clip_l.safetensors",
        "t5xxl_fp16.safetensors",
        "flux",
        "default"
      ]
    }
```

`properties` 里的 `models` 字段含三项：

| 字段 | 含义 |
|---|---|
| `name` | **模型文件名** |
| `url` | **该文件的直接下载链接**（不是仓库页面） |
| `directory` | 文件该存到 `ComfyUI/models` 下的**哪个子文件夹**，例如 `vae` 表示 `ComfyUI/models/vae` |

> 对照 `references/03-workflow-json.md`：workflow JSON v1.0 schema 里 `models[]` 要求 `name`、`url`、`directory` 三个字段且 `additionalProperties: false`——这里就是它**实际出现的位置**（挂在节点的 `properties.models` 上）。

**链接来源与格式限制（官方明确）**：

- **目前只支持来自 Hugging Face 与 Civitai 的链接。**
- **模型格式必须是安全格式**，例如 **`.safetensors`** 或 **`.sft`**。
- **像 `.gguf` 这样的格式被视为不安全**；内嵌时**会被标记为不安全，并且不显示链接**。

**编辑工具**：官方推荐用 [ComfyUI Workflow JSON Editor](https://comfyui-wiki.github.io/ComfyUI-Workflow-JSON-Editor/) 来编辑模板里的模型信息。该工具**目前只支持原生节点**（作者 [@ComfyUI-Wiki](https://github.com/ComfyUI-Wiki)）。

## 怎么更新模板

**模板是作为独立依赖管理与更新的**：[`comfyui-workflow-templates`](https://pypi.org/project/comfyui-workflow-templates/)。

> 如果**更新 ComfyUI 之后看不到文档或新公布的模板**，你可能需要**更新对应依赖**。版本可以在 [`ComfyUI/requirements.txt`](https://github.com/Comfy-Org/ComfyUI/blob/master/requirements.txt) 里查看。

官方举例说明：**通常下面三个依赖会随着 ComfyUI 更新一起升级**（注：这是该页面写作时的版本号）：

```
comfyui-frontend-package==1.24.4
comfyui-workflow-templates==0.1.52
comfyui-embedded-docs==0.2.4
```

> **对比一下当前 requirements.txt 里的版本**（见 `references/02-core-concepts.md` 收录的官方清单）：`comfyui-frontend-package==1.49.6`、`comfyui-workflow-templates==0.11.48`、`comfyui-embedded-docs==0.5.10`。**模板包在持续、频繁地发版**——所以遇到「模板里没有某模型」时，**先升级这个依赖**再下结论。
>
> 不确定怎么正确更新，见[更新 ComfyUI](https://docs.comfy.org/installation/update_comfyui)。

## 给官方仓库贡献模板

**所有模板都托管在 [Comfy-Org/workflow_templates](https://github.com/Comfy-Org/workflow_templates/) 仓库**，可以通过提 PR 贡献。**官方模板的三条要求**：

1. **不要使用任何第三方节点**（避免让缺少这些节点的用户还要额外安装）
2. **模板不得与现有模板重复**，且应针对**受支持的模型能力**
3. 可以在仓库里**开 issue 提问**

## 自定义节点模板（作者侧）

**如果你的自定义节点自带示例工作流文件，ComfyUI 就能在模板浏览器里把它们展示给用户**（`Workflow` → `Browse Templates` 菜单）。工作流模板是**帮助用户上手你的节点的好办法**。

### 最少要做什么

作为一个节点开发者，**你只需要建一个 `example_workflows` 文件夹，把 `json` 文件放进去**。**可选**：放**同名**的 `jpg` 文件作为模板缩略图。

**底层机制**：ComfyUI 会**静态托管这些文件**，并提供一个端点 **`/api/workflow_templates`** 返回工作流模板的集合。

> 官方 Note：下面这些文件夹名也**被接受**，但**仍然推荐用 `example_workflows`**：
> `workflow`、`workflows`、`example`、`examples`

**例子** —— 在 `ComfyUI-MyCustomNodeModule/example_workflows/` 目录下：

- `My_example_workflow_1.json`
- `My_example_workflow_1.jpg`
- `My_example_workflow_2.json`

在这个例子里，**ComfyUI 的模板浏览器会显示一个名为 `ComfyUI-MyCustomNodeModule` 的分类，里面有两项，其中一项带缩略图**。

**真实例子**：见 [ComfyUI-Impact-Pack 的 `example_workflows` 文件夹](https://github.com/ltdrdata/ComfyUI-Impact-Pack/tree/Main/example_workflows)。

### 模板浏览器里的位置与格式限制

- 如果**自定义节点作者提供了模板与示例工作流**，你也能在 **Templates 浏览器**里找到。**通常可以按「以该节点命名的分类」找到它的全部模板。**
- 如果你**是**自定义节点作者，注意：**目前只支持 `templates` 文件夹下的单层目录（不能有嵌套子目录），并且只支持 JSON 格式的模板。**

## 在本项目（本地免费）里按名称取用模板

模板属于**本地能力**，不花积分。三条可用路径：

| 路径 | 怎么用 |
|---|---|
| **ComfyUI 界面** | 侧边栏 `Templates`，或菜单 `Workflow → Browse Workflow Templates`，点进去按名称/分类找 |
| **comfy-mcp（本地 MCP，推荐给 agent）** | `search_templates` 找模板 → `fetch_template` 把它可运行的工作流 JSON 落盘 → 交给 `run_workflow` 执行。见 `references/01-mcp-agent-tools.md` |
| **comfy-cli** | 官方 CLI 页把 `comfy templates` 与 `comfy workflow` 的 slot 编辑列在「云工作流」一节里；**完整的 CLI 文档（本地安装、`comfy setup`、`comfy run`、templates、workflow 编辑、节点/模型发现）在 [Comfy CLI getting started](https://docs.comfy.org/comfy-cli/getting-started)**。同页还提到 `comfy run`、`comfy jobs`、`comfy validate` 用于跑完整工作流 |

> 模板优先是官方明确推荐的策略：云端 MCP 的工具说明里写着 **server 会优先匹配现成模板，再考虑从零搭工作流，因为这样更快、效果通常更好**。
>
> **本项目的模板使用以 ComfyUI 本地内置模板（`comfyui-workflow-templates` 包）为准。** 官方另有一个线上的工作流站点（<https://comfy.org/workflows>）用于分享与浏览，属于云端/社区路线，**不在本项目范围**。

## 开发者上下文（为什么模板是「一方支持」的信号）

官方开发者概览页的说法：**ComfyUI 是一个模块化的 GenAI 推理引擎**，可以作为 **server** 运行、通过 **API** 访问、用**自定义节点**扩展、并从命令行管理。**大多数 API 工作都遵循两步：先把 ComfyUI 跑起来，然后从你的应用里针对它执行工作流。**

而 `basic-concepts/models` 页说明了模板与模型支持的关联：**当某个模型获得一方（first-party）支持时，通常会在工作流模板库里新增一条**，展示预期的图结构与模型搭配。因此：

> **判断「这个模型 ComfyUI 是否原生支持」，最快的办法是先在模板库里找它。** 找不到再去怀疑文件放错位置。

## 官方该页未覆盖

- **缩略图的具体尺寸/像素/格式要求没有给**——官方只说「可选地放**同名** `jpg` 作为缩略图」，**没有给尺寸或命名规则的更多约束**。不要自行假定数字。
- **模板文件与缩略图的命名规范没有给**（除了「同名」这一点）。
- **`/api/workflow_templates` 端点的响应结构没有给**——官方只说了它的存在与用途。
- **模板的排序/置顶机制没有给**。
- `templates` 文件夹（自定义节点侧）与 `example_workflows` 文件夹（节点包侧）**两者的关系官方分散在两页**：前者在 `interface/features/template`，后者在 `custom-nodes/workflow_templates`。以各自页面为准。
