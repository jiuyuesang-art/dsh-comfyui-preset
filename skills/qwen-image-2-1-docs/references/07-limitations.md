# 能力边界与已知问题

来源：
- `https://docs.comfy.org/tutorials/image/qwen/qwen-image-2-1`（ComfyUI 官方文档：分辨率/步数/缓存的实际限制）
- `https://github.com/QwenLM/Qwen-Image-2.1`（官方 README：架构说明、社区支持）
- `https://huggingface.co/Qwen/Qwen-Image-2.1`（官方模型卡：许可证）
- `https://github.com/wildminder/awesome-qwen-image`（社区整理：diffusers 坑位、平台实测）
- `https://modelvram.com/qwen-image-2-1-vram-calculator/`（Windows 驱动行为提醒）

抓取日期：2026-10-03

## ⚠️ 首先必须说明的一点

**Qwen 官方没有发布"能力边界 / 不能做什么 / 已知缺陷"清单。**
官方 README、模型卡、ComfyUI 官方文档都没有这样一个章节。

因此本文件的内容分两类，来源分别标注：

- **【官方文档明说】** —— 来自官方或其文档的具体限制描述；
- **【社区实测】** —— 来自社区工具/索引的可复核数据；
- 凡属推测或未经核实的内容，**本快照一律不写**。

## 【官方文档明说】分辨率与画布

| 限制 | 原文要点 |
| --- | --- |
| 目标远超 2K 会掉遵循度 | 目标远高于模型 **2K 训练尺寸**（例如 **4K**）会**损失提示词遵循度（lose prompt adherence）** |
| 最大边与倍数 | diffusers 侧要求**宽高是 32 的倍数**，**最大边 2048** |
| 官方宽高比表最大边是 2752 | 官方给出的 16:9 推荐尺寸是 2752×1536，与上一条的"最大边 2048"存在张力。实践中以实际模板/管线报错为准，**不要假定 2752 在所有路径都可用** |
| `custom_size` 导致位移 | 打开 `custom_size` 后画布改由 Resolution Selector 决定，**必须保持接近缩放后的 `image_1` 尺寸，否则编辑会发生位移（the edit can shift）** |

## 【官方文档明说】采样参数陷阱

| 陷阱 | 说明 |
| --- | --- |
| **CFG 1 时负向提示词完全无效** | ComfyUI 在 `cfg` 1 时跳过负向条件计算。这是官方发布路径，负向词不会起作用 |
| **cfg 0.5 直接出废图** | "cfg 0.5 breaks the image" |
| **cfg 5 画质严重崩坏** | "cfg 5 degrades quality badly" |
| **cfg 2 有过锐代价** | 更贴合密集提示词（含小字和数字），但**边缘过锐** |
| **更高值偏曝光** | 曝光向过亮或过暗偏移 |
| **调参纪律** | 官方要求：**一次只改一个值**，并**固定种子**做对比 |
| **步数不是越多越好** | "Adjust `steps` only when something specific fails to resolve." —— 只在某个具体东西确实没解出来时才调步数 |

## 【官方文档明说】性能与缓存

| 问题 | 说明 |
| --- | --- |
| 大画布极慢 | RTX 5090 上 12 MP 画布约 **6 s/it**，1 MP 约 **0.3 s/it**；降 `resolution` 是让输出变小来提速，**不是增加细节** |
| 多张大参考图拖慢编辑 | "Several large references slow the edit further" |
| **KV cache 节点是实验性的** | 官方原文标注 "The node is experimental" |
| `int4` 缓存精度损失 | 缓存降到四分之一，但**每步误差大约翻倍**（`int8` 则约等于 bf16 精度） |
| 顽固细节需要更多步数 | 手、手指这类**大约 30 步**才稳定；25 → 40 步可减少细节区域的 fizzle |
| 局部编辑步数有下限场景 | 简单局部编辑 4–8 步可用，但**重写整个画面的编辑会失去连贯性**，需走满 25 步 |

## 【官方明说】许可证限制

**Qwen Research License Agreement**（`license_name: qwen-research`）。
这是**研究许可**，不是 Apache/MIT 类宽松许可。
官方 README 与模型卡均只给出这一句，**未在页面中展开具体条款**；
`LICENSE` 文件在仓库根目录与 HuggingFace 仓库内。
→ 商用前**必须自行阅读 LICENSE 原文**，本快照不代作法律解读。

## 【社区实测】diffusers 使用坑位

摘自 awesome-qwen-image 的 "Gotchas that will save you an afternoon"（**非官方**，但与官方 README 一致的部分已交叉验证）：

| 坑 | 说明 |
| --- | --- |
| **需要 diffusers `main`** | `QwenImage21Pipeline` 在 release **`0.40.0` 里不存在**，必须从 git 装 |
| **CFG 关键字不是 `guidance_scale`** | 是 **`true_cfg_scale`**，而且**需要同时提供 `negative_prompt`** 才会生效 |
| **宽高约束** | 必须是 **32 的倍数**，**最大边 2048** |
| **CPU offload 时 generator 位置** | generator 应该放在 **`'cpu'`** 上 |
| **默认无 CFG** | 默认是 **40 步、无 CFG**；加 CFG 会改变观感 |
| **中文提示词** | 中文**原生可用**；官方 PE 模型负责把中文改写成英文 |

## 【社区实测】各平台失败模式

| 平台 | 现象 |
| --- | --- |
| **Windows（NVIDIA 驱动）** | **显存不足不报错**：驱动的 **System Memory Fallback**（驱动 536.40 起）把放不下的部分挪进共享系统内存，任务**跑完但跑在内存上**，速度极慢。标题原文："On Windows, 'runs on 8 GB' can mean 18 GB" |
| **8 GB 显卡（RTX 3070）** | 用 Q3_K_M DiT + Q3_K_M 编码器**全部驻留显存**时，**在 VAE 解码阶段 OOM** —— 失败点是 VAE 解码，不是去噪 |
| **T4 16 GB** | 社区 Colab notebook 明确说明 **T4 会因设计而 OOM**（L4 22 GB 可用） |
| **Apple Silicon / MLX** | 1024×1024 可用，**2048×2048 尚不支持** |

## 【社区实测】量化带来的取舍

| 项 | 取舍 |
| --- | --- |
| KV cache `int8` | 缓存减半，精度**约等于 bf16** —— 基本无痛 |
| KV cache `int4` | 缓存四分之一，但**每步误差约翻倍** |
| DiT 量化（GGUF Q4 及以下） | 体积大幅下降，但**画质随位数下降**；Q4_K_M 是常用平衡点 |
| 文本编码器量化 | 注意文本编码器**比 DiT 还大**，量化它的收益最直接 |

## 容易误判的两件事

1. **"7B 模型应该很省显存"** —— 错。7B 只是 DiT；
   文本编码器 Qwen3-VL 8B 的 BF16 权重 **17.53 GB**，比 DiT 的 14.23 GB 还大。
2. **"任务跑完了说明显存够"** —— 在 Windows 上不成立（见上）。

## 本快照未覆盖的内容

- **官方博客的 benchmark 数字** —— 博客页 `https://qwen.ai/blog?id=qwen-image-2.1` 为前端渲染 SPA，
  本次**未能抓取正文**，因此**没有采信任何来自博客的具体数字**。需要时请重新抓取。
- **Qwen Image 3.0 Pro 等云端/付费路线** —— 存在，但**不在本项目（本地免费能力）范围**。
- **ControlNet Union 的细节** —— Comfy-Org 上那两个 `qwen_image_2.1_fun_controlnet_union_*` 文件
  是**阿里 PAI Union checkpoint 的重打包，不是 Qwen 官方发布**，本快照未展开其用法。
- **LoRA 训练** —— ModelScope 侧基于 DiffSynth-Studio 支持 LoRA 训练，本快照未展开。
