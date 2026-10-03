# 依据出处（`comfyui-project-layout` 的规范来源）

> 本文件由 SKILL.md 的 §8 拆出，运行时按需查阅，不随 skill 正文一起加载。


> 完整调研简报（含每个问题的出处分级、「未找到权威出处」的标注、以及检索失败说明）见
> [`references/pipeline-research.md`](references/pipeline-research.md)，251 行。下面只列被固化进本规范的来源。

## 目录与命名

- [CG Pipeline: A Proposal For Your File Hierarchy — CGWire](https://blog.cg-wire.com/cg-pipeline-a-proposal-for-your-file-hierarchy/)
  → `working/` vs `export/` 分离、**assets 与 shots 两棵树**、`ep001/se001/sh001/<环节>` 层级、**全小写无空格无特殊字符**
- [Shared Folder Structure — Blender Studio](https://studio.blender.org/tools/naming-conventions/shared-folder-structure)
  → `NNN_name` 序列号段、`NNN_NNNN` 镜头号段、`NNN_NNNN-<element>-vNNN` 文件命名、`_archive/` 归档做法
- [Naming Conventions — Blender Studio](https://studio.blender.org/tools/naming-conventions/introduction)
  → 「No caps, no gaps」
- [An introduction to organizing project files — La Cuisine（Les Fées Spéciales）](https://lacuisine.tech/an-introduction-to-organizing-project-files)
  → **`EDIT/current/` 技巧**、LIB/FILM 双块、反对连续数字前缀、长名字优于短名字
- [VFX Plate Naming Conventions — Aspect](https://aspect.inc/blog/post-production/vfx-plate-naming-conventions-for-shot-and-frame-delivery)
  → **"Don't allow silent overwrites"**、shot ID 与源 clip 名解耦、**编号按 10 递增**、帧号从 `1001` 起、点号只留给帧号与扩展名
- [Kitsu · Production Structure](https://kitsu.cg-wire.com/guides/production-structure)
  → Sequence 是分组层、Shot 是工作单元、Asset 是平行分支
- [PostMicroTools Shot Naming](https://www.postmicrotools.com/shotnamer)
  → 四套命名 preset；不零填充会把 `SH10` 排在 `SH2` 前面

## 版本与状态

- [Semantic Versioning 2.0.0](https://semver.org) 规则 3 → **已发布的版本内容不得修改**，必须发新版本
- [Prism Pipeline · Project Settings](http://prism-pipeline.com/docs/latest/general/settings/project/)
  → `Version Padding` 统一版本位数、`master version`（push workflow）；Prism 另有 **ComfyUI 插件**，说明 AI 生成已进入传统管线

## 二维动画环节

- [東映アニメーション · 製作工程について](https://corp.toei-anim.co.jp/ja/company/animation_production.html)
  → 絵コンテ → 原画 → 色指定 → 動画 → 背景 → 彩色 → CG → 撮影；**撮影 = 合成，不是实拍**
- [AREA JAPAN · 第3回：プロダクション（Autodesk）](https://area.autodesk.jp/column/trend_tech/animation/03-production)
  → レイアウト 的职责定义；音響作为独立部门

## 剪辑与交付

- [Blender Studio · shared/editorial 结构](https://studio.blender.org/tools/naming-conventions/shared-folder-structure)
  → `audio/` `deliver/` `export/` `footage/` 四件套
- [OpenTimelineIO（ASWF）](https://opentimelineio.readthedocs.io/en/latest/tutorials/architecture.html)
  → 剪辑信息的交换格式；可当机器可读的镜头表

## AI 生成可复现性

- [ComfyUI · Workflow Metadata](https://docs.comfy.org/development/api-development/workflow-metadata)
  → 保存输出时把 workflow 存进文件本身："saving a generated image together with its recipe"
- [ComfyUI · SaveImage](https://docs.comfy.org/built-in-nodes/SaveImage)
  → PNG 的 `tEXt` 块会嵌入 `prompt`（API 格式执行图）与 `workflow`（完整节点图）
- ⚠️ [ComfyUI Discussion #1124](https://github.com/Comfy-Org/ComfyUI/discussions/1124)
  → **batch 生成时 PNG 元数据只含初始 seed，逐图实际 seed 可能丢失** —— 本条直接催生了 §4 的「坑 ①」
- [Civitai Developer · ModelHash](https://developer.civitai.com/orchestration/reference/operations/InvokeModelHashStepTemplate)
  → 模型标识用 SHA256 / AutoV2 等 hash，**不用文件名**
- [MLflow · Artifact Stores](https://mlflow.org/docs/latest/self-hosting/architecture/artifact-store/)
  → 元数据与大数据分存、每次 run 记 `artifact_uri` 可事后回溯
- [Model Cards for Model Reporting（arXiv 1810.03993）](https://arxiv.org/pdf/1810.03993v2.pdf)
  → 结构化记录模型用途与限制的通行做法
- [MovieLabs/comfyui-movielabs-util](https://github.com/MovieLabs/comfyui-movielabs-util)
  → **MovieLabs 官方的 ComfyUI 节点**，已实现自动版本号、自动建目录、命名校验并对接 ShotGrid ——
  证明「AI 生成 + 专业 pipeline 规范」在工业界已落地，是本规范的上限参照

## 有意偏离的说明

| 偏离 | 业界做法 | 本项目做法 | 理由 |
|---|---|---|---|
| 归档目录名 | `_archive/`（Blender Studio） | `old/` | 用户明确要求；行业对 `_old` 无权威定义，故只准用这一个名字 |
| 工作文件带版本号 | 工作文件不带 `vNNN`，历史交给 SVN | 一律带 `vNNN` | 个人创作者没有 VCS，版本只能靠文件名 |
| 音频在 shot 内 | 音響是独立部门，不进 shot | 按镜归属到 `50_audio/` | H3 等模型音画同一次生成 |
