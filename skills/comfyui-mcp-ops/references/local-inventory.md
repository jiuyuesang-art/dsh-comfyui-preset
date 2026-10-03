# 本机 ComfyUI 资源清单（实测 2026-10-03）

> 数据来源：`mcp__comfymcp__search_models`（live 扫盘）+ 本地工作流文件实测 + `comfyui-mcp-官方配置与调用方法.md`
> 换机器或装了新模型后请重新用 `search_models(folder=...)` 核对，本文件会过期。

> 📍 **路径占位符说明**：本文件里的 `%COMFYUI_HOME%` 与 `%USERPROFILE%` 是**可移植占位符**
> （作者的 ComfyUI 装在 `…\ComfyUI-EasyManager\win`）。
> **别照着猜路径**——实际路径用工具问出来更可靠：
> `mcp__comfymcp__server_info` 的 `workspace` 字段给 ComfyUI 工作区，`search_models` 给各模型目录。
> 这样换机器也不会错。

## 1. 模型清单（按目录）

| 目录 | 文件 |
|---|---|
| `unet_gguf` | `qwen_image_2.1_Q6_K.gguf` · `MiniMax-H3-FL2VA-Pruned-Q4_K_M.gguf` · `MiniMax-H3-Ref2VA-Pruned-Q4_K_M.gguf` · `MiniMax-H3-Ref2VA-Q6_K.gguf` |
| `text_encoders` | `qwen3vl_8b_int8_convrot.safetensors` · `qwen3vl_32b_minimax_h3_int8_convrot.safetensors` · `qwen_3_06b_base.safetensors` · `umt5_xxl_fp8_e4m3fn_scaled.safetensors` · `jina_clip_v2_bf16.safetensors` |
| `clip_gguf` | `qwen3vl_32b_minimax_h3-Q4_K_M.gguf` |
| `vae` | `qwen_image_2.1_vae_bf16.safetensors` · `minimax_h3_video_vae_fp16.safetensors` · `minimax_h3_audio_vae_fp32.safetensors` · `Wan2_1_VAE_bf16.safetensors` · `seedvr2_ema_vae_fp16.safetensors` |
| `loras` | `Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors` · `minimax_h3_turbo_8step_v1.0.safetensors` · `minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors` · `WanAnimate_relight_lora_fp16.safetensors` · `lightx2v_I2V_14B_480p_cfg_step_distill_rank64_bf16.safetensors` · `turbo8_lora_step2500.safetensors` |
| `controlnet` | `qwen_image_controlnet_union_instantX.safetensors` |
| `diffusion_models` | `Wan2_2-Animate-14B_fp8_e4m3fn_scaled_KJ.safetensors` · `anima-base-v1.0.safetensors` · `anima-aesthetic-v1.1.safetensors` · `seedvr2_3b_int8_convrot.safetensors` |
| `checkpoints` | `naiXLVpred102d_custom.safetensors` · `hunyuan3d-dit-v2-mv_fp16.safetensors` · `sam3.1_multiplex_fp16.safetensors` |

**一句话概括**：本机是 **GGUF 量化路线**——Qwen Image 2.1 和 MiniMax H3 都没有全精度权重，全靠 `unet_gguf` 里的 GGUF + `int8_convrot` 文本编码器撑起来。**官方模板里的全精度文件名在本机一律不存在**，照抄会报缺模型。

## 2. 已装的 GGUF 节点（ComfyUI-GGUF，city96）

`search_models` 之外，用 `nodes(action="search", query="gguf")` 实测存在：

- `UnetLoaderGGUF`（bootleg）/ `UnetLoaderGGUFAdvanced`
- `CLIPLoaderGGUF` / `DualCLIPLoaderGGUF` / `TripleCLIPLoaderGGUF` / `QuadrupleCLIPLoaderGGUF`
- `GGUFLoaderKJ`（KJNodes/model_loaders）

另有两个 Qwen2.1 专用节点（非 GGUF 包）：`QwenImage21Cache`（KV Cache 显存优化）、`TextEncodeQwenImage21`（一体化 conditioning）。

## 3. 官方模板要求 vs 本机实际（对照表）

| 官方模板要 | 本机实际 | 处置 |
|---|---|---|
| `qwen_image_2.1_bf16.safetensors`、`qwen_image_2.1_int8_convrot.safetensors` | `qwen_image_2.1_Q6_K.gguf` | `UNETLoader` → `UnetLoaderGGUF` |
| `qwen3vl_8b_bf16.safetensors` | `qwen3vl_8b_int8_convrot.safetensors` | `CLIPLoader` + `type: qwen_image` |
| `qwen_image_2.1_vae_bf16.safetensors` | ✅ 同名存在 | 直接用 |
| `qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors` | `qwen3vl_32b_minimax_h3_int8_convrot.safetensors` / `qwen3vl_32b_minimax_h3-Q4_K_M.gguf` | 优先 `CLIPLoaderGGUF` |
| `minimax_h3_fl2va_pruned_int8_convrot.safetensors` | `MiniMax-H3-FL2VA-Pruned-Q4_K_M.gguf` | `UnetLoaderGGUF` |
| `minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors` | `minimax_h3_turbo_8step_v1.0.safetensors`（LoRA 形态） | 用 LoRA 加载器 |
| `minimax_h3_video_vae_fp16` / `minimax_h3_audio_vae_fp32` | ✅ 同名存在 | 直接用 |
| `minimaxh3_art_is_explosion.safetensors` | ❌ 无 | 可选风格 LoRA，跳过 |

Qwen Image 2.1 官方模板用到的节点类（供参考）：
`UNETLoader` `CLIPLoader` `VAELoader` `TextEncodeQwenImage21` `KSampler` `EmptyLatentImage` `ResolutionSelector` `SaveImageAdvanced` `MarkdownNote`
MiniMax H3 t2v 官方模板为 **subgraph 结构**（`definitions.subgraphs`），顶层只有 `ResolutionSelector` 与 `SaveVideo`。

## 4. 官方模板 JSON 的本地位置（离线可用）

```
%COMFYUI_HOME%\envs\comfyui\Lib\site-packages\comfyui_workflow_templates_json\templates\
```

- 约 560 个 `.json`，文件名即模板 name（如 `image_qwen_image_2_1_t2i.json`、`video_minimax_h3_t2v.json`）
- 相关包：`comfyui_workflow_templates` 0.11.68（薄封装）、`comfyui_workflow_templates_core` 0.3.359、`comfyui_workflow_templates_json` 0.1.94、若干 `media_*` 资源包
- **`mcp__comfymcp__fetch_template` 当前会超时**；`comfy.exe templates fetch` 报 `WinError 10054`（图库在线刷新被强制断开，只能用 7.8 天前的缓存索引，而 workflow JSON 本身要联网抓）。
  → **绕开办法：直接用 read/grep 读上面的本地目录**，比走图库快且稳。

## 5. 环境与路径

| 项 | 值 |
|---|---|
| ComfyUI 工作区 | `%COMFYUI_HOME%\ComfyUI` |
| Python | `%COMFYUI_HOME%\envs\comfyui\python.exe`（3.10.20） |
| comfy / comfy-mcp | `…\envs\comfyui\Scripts\comfy.exe`（1.17.0）/ `comfy-mcp.exe`（0.10.0） |
| comfy-cli 配置 | `%USERPROFILE%\AppData\Local\comfy-cli\config.ini`（**不是** `~/.comfy`） |
| comfy-cli 作业状态 | `%USERPROFILE%\AppData\Local\comfy-cli\jobs\<prompt_id>.json` |
| DSH 连接器持久化 | `%USERPROFILE%\.dsh\storages\mcp_connector.json` → `tables.connections["custom-comfymcp"]`（serverName=comfymcp） |
| MCP 环境变量 | `COMFY_BIN`=comfy.exe 绝对路径（**最关键**，不设则退化为 PATH 查找）· `COMFY_WHERE`=local |
| 日志 | 不在 `~/.dsh/logs`（该目录不存在）；用 `mcp__comfymcp__get_logs` |

## 6. 已知坑（来自实测笔记，均已复现过）

1. **`fetch_outputs(inline_images=true)` 报错**：`Unable to serialize unknown type: <class 'mcp.server.mcpserver.utilities.types.Image'>` —— comfy-mcp 0.10.0 的序列化 bug。不传该参数即可正常下载。
2. **慢任务调用超时 ≠ 任务失败**：`job(action="wait")` 返回 `Error: Request timed out` 只是 MCP 调用超时，任务仍在跑；重新 `job(action="status")` 就能拿到 `completed`。所以长任务一律 `run_workflow(wait=false)` + 轮询。
3. **`server_info` 的 `freshness` 字段可能超时**（`comfy outdated` 联网慢，15s 超时），不影响其他功能。
4. **`stop_comfyui` 只停它自己启动的服务**：桌面版/手动启动的实例会报 "no recorded server"，而不是误杀进程。本机 ComfyUI 由 EasyManager 管理。
5. **`--listen` 暴露网络需确认**：ComfyUI **没有鉴权**，非回环 `--listen` 会把完整 API 暴露到局域网。默认保持 `127.0.0.1`。
6. **12GB 显存 OOM 表现为"连接中断/超时"而非节点报错**（整个 ComfyUI 进程被干掉）——用 `get_logs` 看日志，别对同一配置反复重试。
7. **`workflow_deps` 返回的 key 里带 `/` `:` `@` 的是 git 仓库 URL 而非注册表 id**，`install_node` 会拒绝，需交用户手动安装。
