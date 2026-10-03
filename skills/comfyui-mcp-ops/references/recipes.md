# 本机已验证的配方与工作流库

> 由 `comfyui-mcp-ops` 的 §3 拆出。**只在真正要跑工作流、准备填参数时才读**。
> 查工具、问能力、排错都**不要**读本文件。

## 定点索引 —— 只读你要的那一节，不要整文件读

| 要做什么 | 读哪几行 |
|---|---|
| **先看** 官方模板与本机模型的落差（避免照抄跑不通的模板） | 115-134 |
| Qwen Image 2.1 出图 / 改图 / 抠图 / 上色 | 17-56 |
| MiniMax H3 视频（Ref2VA，含原生音频） | 57-83 |
| 复用已有工作流（别从零造） | 84-114 |

> 用法：`read <本文件> offset=<起始行> limit=<行数>`，只取需要的那一节。

## 3.1 Qwen Image 2.1 —— 出图 / 改图 / 抠图 / 上色

本机走 **GGUF 量化 + int8 文本编码器**路线。API 格式骨架：

```json
{
  "1": { "class_type": "UnetLoaderGGUF",
         "inputs": { "unet_name": "qwen_image_2.1_Q6_K.gguf" } },
  "2": { "class_type": "QwenImage21Cache",
         "inputs": { "model": ["1",0], "device": "auto", "dtype": "default" } },
  "3": { "class_type": "CLIPLoader",
         "inputs": { "clip_name": "qwen3vl_8b_int8_convrot.safetensors",
                     "type": "qwen_image", "device": "default" } },
  "4": { "class_type": "VAELoader",
         "inputs": { "vae_name": "qwen_image_2.1_vae_bf16.safetensors" } },
  "5": { "class_type": "LoadImage", "inputs": { "image": "<input目录里的文件名>" } },
  "6": { "class_type": "TextEncodeQwenImage21",
         "inputs": { "clip": ["3",0], "prompt": "<指令>", "negative_prompt": "",
                     "resolution": 1024, "images.image_1": ["5",0], "vae": ["4",0] } },
  "7": { "class_type": "KSampler",
         "inputs": { "model": ["2",0], "positive": ["6",0], "negative": ["6",1],
                     "latent_image": ["6",2], "seed": 0, "steps": 25, "cfg": 1.5,
                     "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0 } },
  "8": { "class_type": "VAEDecode", "inputs": { "samples": ["7",0], "vae": ["4",0] } },
  "9": { "class_type": "SaveImage",
         "inputs": { "images": ["8",0], "filename_prefix": "qwen21" } }
}
```

> ✅ **上面这段骨架已在 2026-10-03 用 `validate_workflow` 对着 live ComfyUI 实测通过**：`valid: true`、`error_count: 0`、`spends_credits: false`。节点类名、输入名、连接形状都是对的，放心照抄。

要点：
- **`TextEncodeQwenImage21` 一个节点搞定全部 conditioning**：输出 `0=正向 / 1=负向 / 2=latent`，所以 `KSampler` 直接接 `["6",0] ["6",1] ["6",2]`。
  - **纯文生图**：把 `images.image_1` 和节点 `5` 去掉即可。
  - **改图/抠图/上色**：接上 `images.image_1`，`prompt` 写成**指令式**（"Remove the background..." / "Colorize this..."）。
    ⚠️ **动笔写这句提示词之前，先加载 `comfyui-prompt-craft`** —— 保留/变更三段式、`<imageN>` 引用规则、语言选择都在那儿。
- `QwenImage21Cache` 是 Qwen2.1 专用 KV Cache 节点，**12GB 显存必留**，删了容易 OOM。
- `cfg` 实测取值很低：**抠图用 1.0，上色用 1.5**（Qwen-Image 系列特性）。步数 25，`euler` + `simple`。
- 本机还有一个 `Qwen-Image-Edit-2509-Lightning-4steps-V1.0` LoRA（4 步加速），以及 `qwen_image_controlnet_union_instantX.safetensors`（ControlNet，可接 canny/depth/pose）。

## 3.2 MiniMax H3 —— 视频（Ref2VA，含原生音频）

本机走 **Q4_K_M GGUF + minimax CLIP GGUF + 双 VAE** 路线。关键节点与取值取自用户现成的工作流文件（⚠️ **该路线在本机尚未有成功产出的证据，详见 §3.3**）：

```
CLIPLoaderGGUF      ["qwen3vl_32b_minimax_h3-Q4_K_M.gguf", "minimax"]
UnetLoaderGGUF      ["MiniMax-H3-Ref2VA-Pruned-Q4_K_M.gguf"]
VAELoader           ["minimax_h3_video_vae_fp16.safetensors"]
VAELoader           ["minimax_h3_audio_vae_fp32.safetensors"]    ← 音频轨，别漏
PrimitiveFloat      [5.17]                                        ← 目标时长（秒）
ComfyMathExpression ["max(5, round(a * 24)) + (5 - (max(5, round(a * 24)) % 17)) % 17"]
KSamplerSelect      ["res_multistep"]
SamplerCustomAdvanced ← BasicGuider + RandomNoise
VAEDecode + VAEDecodeAudio
CreateVideo         [24, 8]
SaveVideo           ["video/<名字>", "auto", "auto"]
```

要点：
- **帧数必须对齐 17n+5 格点**，上面那条 `ComfyMathExpression` 就是用户验证过的公式（`a`=秒数，24fps）。手填帧数会导致时长/音画不对。
- **H3 是三模态模型，会顺带生成音频**，所以必须同时接 video VAE 和 audio VAE，并走 `VAEDecodeAudio` → `CreateVideo`，否则音频轨丢了。
  ⚠️ 提示词部分（英文正文 + `integrated_multimodal_description:` / `overall_soundscape:` / `non_diegetic_music:` 三字段骨架 + 运镜写法）**先加载 `comfyui-prompt-craft`**。
- 可用 LoRA：`minimax_h3_turbo_8step_v1.0.safetensors`（8 步）、`minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors`（4 步）。
- 另有一套 FL2VA 权重：`MiniMax-H3-FL2VA-Pruned-Q4_K_M.gguf`（首尾帧路线）。
- **12GB 显存下这是"能跑但慢"**：Q4_K_M + max 867p 左右 + 5 秒起步。**不要一上来就 15 秒高分辨率**——先 5.17 秒小尺寸试通，再按用户要求加长。
- 官方全精度权重（`minimax_h3_fl2va_pruned_int8_convrot.safetensors`）本机**没有**，别照着官方模板填。

## 3.3 已有的工作流库（优先复用，别从零造）

用户已积累一批工作流，直接读文件、改参数、验证、运行。

⚠️ **先分清哪条路线真有产出证据，不要一律当成"已跑通"**（2026-10-03 查 `output\` 目录得到的结论）：

| 路线 | 产出证据 | 可信度 |
|---|---|---|
| **Qwen Image 2.1** | `output\` 下有 **26 个 `qwen21*` 文件**、`黑白图上色*` 产物（09-27），今日仍在产出 `top20` 批次 | ✅ **确有产出** |
| Qwen 抠图 / 人物替换 / 三视图 | 按各自 SaveImage 前缀**找不到产物** | ⚠️ 工作流存在但没跑过/没存过 |
| **MiniMax H3** | `output\video\` **为空**，全盘无 H3 / Ref2VA / bomu 命名文件 | ❌ **无产出证据**，工作流文件可能从未成功跑完 |

```
%COMFYUI_HOME%\ComfyUI\user\default\workflows\
```

| 路径 | 用途 |
|---|---|
| `zcode\Qwen2.1图片能力\脚本版\黑白图上色_api.json` | 黑白图上色（**API 格式，可直接 run_workflow**） |
| `zcode\Qwen2.1图片能力\脚本版\角色抠图_api.json` | 角色抠图输出透明 PNG |
| `zcode\Qwen2.1图片能力\脚本版\自然语言改图_api.json` | 自然语言改图 |
| `zcode\Qwen2.1图片能力\脚本版\图生图人物替换_api.json` | 图生图人物替换 |
| `zcode\Qwen2.1图片能力\界面版\*.json` | 同上各能力的界面版（**前端格式**，可用 slots 工具改参） |
| `宗主跳舞替换_Ref2VA官方规范版.json` | **H3 Ref2VA 官方规范版**（当前最规范的一套） |
| `宗主跳舞替换_Ref2VA高遵循版.json` / `_多角色教程版.json` / `_原片仅换主角版.json` | H3 换人不同策略 |
| `宗主跳舞替换_FL2VA混合版.json` | H3 首尾帧混合路线 |
| `minimax_h3_fl2v_gguf.json` | H3 FL2V 早期 GGUF 版（引用了已不在本机的模型，需先核对） |
| `flux_kontext_dev_img2img.json` | Flux Kontext 图生图 |

> ⚠️ 用之前先 `search_models` 核对里面引用的模型文件名是否还在本机（08 月那批文件引用过 `Krea-R-Turbo-Q8_0.gguf` 等已不在的模型）。

## 3.4 官方模板库与本机模型的落差（重要）

官方模板 JSON **就在本机磁盘上**，不用联网：

```
%COMFYUI_HOME%\envs\comfyui\Lib\site-packages\comfyui_workflow_templates_json\templates\
```

⚠️ **但官方模板要的是全精度权重，本机是 GGUF 量化版，文件名对不上**。典型落差：

| 官方模板要 | 本机实际 | 处置 |
|---|---|---|
| `qwen_image_2.1_bf16.safetensors` / `_int8_convrot.safetensors` | `qwen_image_2.1_Q6_K.gguf`（unet_gguf） | 把 `UNETLoader` 换成 `UnetLoaderGGUF` |
| `qwen3vl_8b_bf16.safetensors` | `qwen3vl_8b_int8_convrot.safetensors` | 用 int8 版（`CLIPLoader` + `type: qwen_image`） |
| `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` | `qwen3vl_32b_minimax_h3-Q4_K_M.gguf` | 换 `CLIPLoaderGGUF` |
| `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | `MiniMax-H3-FL2VA-Pruned-Q4_K_M.gguf` | 换 `UnetLoaderGGUF` |

**结论：把官方模板当"结构蓝本"，把加载器节点换成 GGUF 版，再对照 §3.3 的成品工作流。** `comfy templates fetch` 目前还会因为在线的图库刷新失败或超时——用本机模板目录读文件更快更稳。

---

