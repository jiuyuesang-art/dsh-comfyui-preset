# 工作流 JSON 结构：UI 导出格式 vs API format

> 来源：https://docs.comfy.org/development/api-development/workflow-api-format
> 来源：https://docs.comfy.org/specs/workflow_json （Workflow JSON v1.0 schema）
> 来源：https://docs.comfy.org/specs/workflow_json_0.4 （Workflow JSON v0.4 schema，旧版）
> 来源：https://docs.comfy.org/development/api-development/workflow-metadata
> 抓取日期：2026-10-03

## 一句话结论

ComfyUI 的工作流是**描述节点图的 JSON 对象**。**要程序化提交（不管是用 Cloud API 还是跑自己的服务器），工作流必须以 `API format` 提交**；它和浏览器里 `Ctrl+S` 存的**常规保存格式（save format）**不是同一种结构。**核心差别：`API format` 丢掉了一切只对可视化编辑有用的 UI 元数据**（位置、颜色、分组、节点尺寸），因此 JSON 更小更干净。

## 保存格式 vs API format（官方对照表）

| | **Save Format**（保存格式） | **API Format** |
|---|---|---|
| **菜单** | `File → Save` 或 `Ctrl+S` | `File → Export Workflow (API)` |
| **扩展名** | `.json` | `.json` |
| **节点键（node keys）** | 节点标题或标签 | **数字节点 ID** |
| **widget 值** | 包含 | 包含 |
| **位置/布局数据** | 包含（x, y, width） | **不包含** |
| **颜色 / 分组** | 包含 | **不包含** |
| **用途** | 在前端重新打开 | API 提交 |
| **能否在 UI 里加载** | 能 | 能，**但没有布局** |

## API format 长什么样

顶层是**一个对象**，键是**节点 id 的字符串**，值是节点对象。每个节点对象只有三样东西：

| 字段 | 含义 |
|---|---|
| `class_type` | **节点类名**（不是屏幕上的显示名），例如 `"KSampler"`、`"CheckpointLoaderSimple"`、`"CLIPTextEncode"`、`"EmptyLatentImage"`、`"VAEDecode"`、`"SaveImage"` |
| `inputs` | 该节点的**全部输入**：常量直接写值，**来自其它节点的输入写成连线引用** |
| `_meta.title` | 仅作显示的标题（前端用），对执行无影响 |

**连线的写法（关键）**：某个输入的值写成**两元素数组 `["<上游节点 id 字符串>", <上游该输出槽的序号>]`**。

**槽序号**：官方示例里 `CheckpointLoaderSimple`（节点 `"4"`）的输出被这样引用——`"model": ["4", 0]` 给 KSampler 的 `model`、`"clip": ["4", 1]` 给 CLIPTextEncode 的 `clip`、`"vae": ["4", 2]` 给 VAEDecode 的 `vae`。从中可验证：**序号从 `0` 开始，按该节点输出槽的排列顺序编号**（`CheckpointLoaderSimple` 的输出依次是 MODEL、CLIP、VAE）。这是从官方示例反推的结论，不是官方明写的句子。

### 官方给的完整 API format 示例（原文照录）

```json
{
  "3": {
    "inputs": {
      "seed": 156680208700286,
      "steps": 20,
      "cfg": 8,
      "sampler_name": "euler",
      "scheduler": "normal",
      "denoise": 1,
      "model": [ "4", 0 ],
      "positive": [ "6", 0 ],
      "negative": [ "7", 0 ],
      "latent_image": [ "5", 0 ]
    },
    "class_type": "KSampler",
    "_meta": { "title": "KSampler" }
  },
  "4": {
    "inputs": { "ckpt_name": "v1-5-pruned-emaonly-fp16.safetensors" },
    "class_type": "CheckpointLoaderSimple",
    "_meta": { "title": "Load Checkpoint" }
  },
  "5": {
    "inputs": { "width": 512, "height": 512, "batch_size": 1 },
    "class_type": "EmptyLatentImage",
    "_meta": { "title": "Empty Latent Image" }
  },
  "6": {
    "inputs": {
      "text": "beautiful scenery nature glass bottle landscape, , purple galaxy bottle,",
      "clip": [ "4", 1 ]
    },
    "class_type": "CLIPTextEncode",
    "_meta": { "title": "CLIP Text Encode (Prompt)" }
  },
  "7": {
    "inputs": { "text": "text, watermark", "clip": [ "4", 1 ] },
    "class_type": "CLIPTextEncode",
    "_meta": { "title": "CLIP Text Encode (Prompt)" }
  },
  "8": {
    "inputs": { "samples": [ "3", 0 ], "vae": [ "4", 2 ] },
    "class_type": "VAEDecode",
    "_meta": { "title": "VAE Decode" }
  },
  "9": {
    "inputs": { "filename_prefix": "ComfyUI", "images": [ "8", 0 ] },
    "class_type": "SaveImage",
    "_meta": { "title": "Save Image" }
  }
}
```

> 上图这条链路就是最经典的文生图：`4 CheckpointLoaderSimple` → `6/7 CLIPTextEncode`（正/负 prompt）+ `5 EmptyLatentImage` → `3 KSampler` → `8 VAEDecode` → `9 SaveImage`。**注意 `_meta.title` 里的中文/英文只是显示名**，真正决定行为的是 `class_type`。

### 手写/改一个 API format 工作流的步骤

1. **先确定节点类名**（`class_type`）。可从内置节点文档、节点右键菜单、或本机 `object_info` 拿到**精确类名**。类名写错 → 提交时报节点类型不存在。
2. **给每个节点分配一个 id**（字符串键即可，官方示例用 `"3"`…`"9"`；不要求连续，也不要求有序）。
3. **写 `inputs`**：
   - 常量（数字、字符串、布尔、枚举名）**直接写值**。枚举值必须是该节点合法的选项名（例如 `sampler_name` 要写 `"euler"` 这类**内部名**）。
   - 需要上游数据的输入，写 `["上游 id", 槽序号]`。
4. **别忘 `_meta.title`**（可选但推荐，便于阅读和前端还原显示）。
5. **校验依赖**：API format 里**不包含**模型是否是本机已有、也不包含自定义节点是否已装——提交前请自行确认（可用 `validate_workflow` 之类的预检，见 `references/01-mcp-agent-tools.md`）。

### 格式互转

官方给的**最简单方法**（无需任何代码）：

1. 在前端用 `File → Load` 打开那个 `.json`
2. 用 `File → Export Workflow (API)` 导出

## UI 保存格式的 JSON Schema（Workflow JSON v1.0，最新）

工作流 JSON 用 **JSON Schema** 定义；schema 的变更在 <https://github.com/comfy-org/rfcs> 讨论。Schema 根定义名 **`ComfyWorkflow1_0`**，`$schema` 为 `http://json-schema.org/draft-07/schema#`。

**顶层必填字段**：`version`、`state`、`nodes`（其余可选；`additionalProperties: true`）。

| 顶层字段 | 类型 | 说明 |
|---|---|---|
| `version` | number，**`const: 1`** | 版本号，v1.0 固定为 `1` |
| `state` | object | 编辑器状态计数：`lastGroupid`、`lastNodeId`、`lastLinkId`、`lastRerouteId`（都是 number） |
| `groups` | array | 分组框 |
| `nodes` | array | **节点数组**（必填） |
| `links` | array | **连线数组** |
| `reroutes` | array | reroute 点（v1.0 新增） |
| `config` | object \| null | 画布配置：`links_ontop`、`align_to_grid` |
| `extra` | object \| null | 附加信息：`ds`（{scale, offset}）、`info`、`linkExtensions`、`reroutes` |
| `models` | array | 模型清单（见下） |

### `nodes[]`（每个节点对象）

**必填**：`id`、`type`、`pos`、`size`、`flags`、`order`、`mode`、`properties`。

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | integer \| string | 节点 id |
| `type` | string | **节点类型**（对应 API format 的 `class_type`） |
| `pos` | `[number, number]` 或 `{"0":…,"1":…}` | 画布位置 |
| `size` | 同上 | 节点尺寸 |
| `flags` | object | `collapsed`、`pinned`、`allow_interaction`、`horizontal`、`skip_repeated_outputs` |
| `order` | number | 执行顺序 |
| `mode` | number | **节点模式**（对应界面上的 Always / Never / Bypass） |
| `inputs` | array | 每个元素必填 `name`、`type`；还有 `link`（number\|null）、`slot_index`（integer\|string） |
| `outputs` | array | 每个元素必填 `name`、`type`；还有 `links`（number[] \| null）、`slot_index` |
| `properties` | object | 例如 `"Node name for S&R"` |
| `widgets_values` | array \| object | **widget 的值**（就是你在节点上填的那些参数） |
| `color` / `bgcolor` | string | 节点配色 |

> 注意 `inputs[].type` / `outputs[].type` 允许 **string、string[] 或 number** 三种形态——因为一个槽位可能接受多个类型。

### `links[]`（每条连线对象）

**必填**：`id`、`origin_id`、`origin_slot`、`target_id`、`target_slot`、`type`。

| 字段 | 含义 |
|---|---|
| `id` | 连线的 id |
| `origin_id` | **起点节点** id |
| `origin_slot` | **起点节点的输出槽**序号 |
| `target_id` | **终点节点** id |
| `target_slot` | **终点节点的输入槽**序号 |
| `type` | 数据类型（string \| string[] \| number） |
| `parentId` | number（可选，用于子图嵌套） |

**这就是「UI 格式的连线写法」**：节点侧只记 `link` 的 id，真正的两端信息在顶层 `links[]` 里。**与 API format 的 `["id", slot]` 完全不同**——这正是两种格式最容易混淆的地方。

### 其它结构

- `groups[]`：必填 `title`、`bounding`（**4 个 number 的数组**：x, y, w, h）；可选 `color`、`font_size`、`locked`。
- `reroutes[]`：必填 `id`、`pos`；可选 `parentId`、`linkIds`（number[] \| null）。
- `extra.info`：必填 `name`、`author`、`description`、`version`、`created`、`modified`、`software`。
- `extra.ds`：必填 `scale`、`offset`（画布缩放与平移）。
- `models[]`：必填 `name`、`url`、`directory`；可选 `hash`、`hash_type`；**`additionalProperties: false`**（即只允许这几个字段，多写会不合规）。`url` 带 `format: uri`。

## v0.4（旧版）与 v1.0 的差异

根定义名 **`ComfyWorkflow0_4`**。

| | **v0.4** | **v1.0** |
|---|---|---|
| **顶层必填** | `last_node_id`、`last_link_id`、`nodes`、`links`、`version` | `version`、`state`、`nodes` |
| **编辑器计数** | **平铺**两个字段：`last_node_id`、`last_link_id` | 收进 **`state` 对象**：`lastGroupid`、`lastNodeId`、`lastLinkId`、`lastRerouteId` |
| **`reroutes` 顶层数组** | **没有**（`reroutes` 只在 `extra` 里） | **有**，顶层独立 `reroutes[]` |
| 顶层字段并集 | `last_node_id`、`last_link_id`、`nodes`、`links`、`groups`、`config`、`extra`、`version`、`models` | `version`、`config`、`state`、`groups`、`nodes`、`links`、`reroutes`、`extra`、`models` |
| **`nodes[]` 必填** | `id`、`type`、`pos`、`size`、`flags`、`order`、`mode`、`properties`（同 v1.0） | 同 |
| **`version` 取值** | schema 里是普通 number（**没有** `const`） | **`const: 1`** |

> 判版本最快的办法：**看顶层有没有 `state` 对象**——有就是 v1.0，只有平铺的 `last_node_id`/`last_link_id` 就是 v0.4。

## 嵌入文件的元数据（workflow metadata）

ComfyUI 保存产物时，**可以把产生这个文件的工作流存进文件本身**——相当于「把图和它的菜谱一起存」。**元数据写在文件格式内部，不改变可见的画面/视频内容。**

官方常存**两个 JSON 字段**：

| 字段 | 内容 |
|---|---|
| `workflow` | **完整的工作流图**，含 nodes、links 与布局信息（= UI 保存格式那一套） |
| `prompt` | 实际用于执行的 **API prompt**，含执行所需的节点与输入（= API format 那一套） |

```json
{
  "workflow": { "nodes": [], "links": [] },
  "prompt": { "3": { "class_type": "KSampler", "inputs": {} } }
}
```

**两个字段用途不同**：`workflow` 用于在前端还原工作流；`prompt` 是提交给 ComfyUI 服务器时用的面向执行的表示。**一个文件可能只有其中一个字段。** 自定义节点还可以通过 **`extra_pnginfo`** 追加字段。

### 各输出格式里元数据存在哪

| 输出格式 | 元数据位置 |
|---|---|
| PNG | PNG 的 **`tEXt` chunk** |
| Animated PNG | PNG 文本元数据 |
| Animated WebP | **EXIF tag** |
| MP4 | 容器元数据 tag |
| WebM | 容器元数据 tag |
| `.latent` | Safetensors 元数据 |
| `.safetensors` | Safetensors 元数据（**当写入它的节点带工作流元数据时**） |

- **PNG** 以文本条目写入，标准字段名就是 `prompt` 和 `workflow`。
- **Animated WebP** 把值存在 EXIF tag 里，tag 内容是形如 `workflow:{JSON}`、`prompt:{JSON}` 的字符串——**这和 MP4/WebM 用容器元数据 tag 存不同**。
- 具体支持取决于**保存节点与写文件路径**；**被别的应用重新编码过的文件可能已经不含元数据**。

### 写入与关闭

内置输出节点在执行工作流时会拿到 API prompt 与额外工作流信息；除非元数据保存被关闭，保存节点会把这些值**序列化成 JSON 写进输出文件**。**元数据不是额外的 sidecar 文件**，而是在保存操作中写进输出文件——所以**复制文件会连它的工作流一起复制**，但**任何重写文件的操作都可能移除或替换元数据**。

关闭方式：

- 命令行启动：`python main.py --disable-metadata`
- **ComfyUI Desktop**：打开 **Settings > Server-Config**，启用 **Disable saving prompt metadata in files.**

> 在此选项启用期间创建的文件，**无法**再从嵌入元数据恢复工作流。

### 读取

- 在 ComfyUI 界面里把生成的文件**拖到画布上**即可恢复工作流；也可以用 **File > Open** 打开文件。
- **若文件同时含 `workflow` 和 `prompt`，ComfyUI 用嵌入的 `workflow` 重建画布**；若文件不含 workflow，ComfyUI 就把这个受支持的媒体文件当作**普通输入素材**处理。
- 做集成时**解析前先检查字段是否存在**。元数据可能因三种原因缺失：文件是用 `--disable-metadata` 生成的、保存节点没拿到工作流信息、或文件被别的应用重新编码过。

### 限制（官方明列）

- 嵌入元数据**不是数字签名**，**不能**证明文件由谁创建或修改。
- **工作流不包含它依赖的模型文件、输入素材、自定义节点包。**
- 移动或重命名模型、输入素材、自定义节点，会导致**恢复出来的工作流跑不起来**。
- 图像/视频编辑器重新编码文件时可能移除元数据。
- 用 `--disable-metadata` 创建的文件不含标准 ComfyUI 工作流元数据。
- **把嵌入元数据当作可选的、不可信的输入**：用之前先校验它是合法 JSON，**不要假定工作流里已经包含了跑起来所需的每一个模型或自定义节点**。

### 官方给出的浏览器端查看/编辑工具

- [ComfyUI Embedded Workflow Editor](https://comfyui-embedded-workflow-editor.vercel.app/)

## 官方该页未覆盖

- `workflow-api-format` 页**没有**说明「输出槽序号从 0 开始」这句话本身（本文档里的 0-based 结论是从官方示例反推的，已在原处标注）。
- `workflow-api-format` 页**没有**给出「本地服务器 `/prompt` 端点的字段与请求方式」——那是 API 集成内容，本项目不做云端/托管 API 教学。本地相关操作请走 `references/01-mcp-agent-tools.md` 里的 `run_workflow`。
- 关于**缺失节点/缺失模型**导致 API format 提交失败时的具体报错文本，官方这几页未覆盖，见 `references/06-troubleshooting.md`。
