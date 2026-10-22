# 批量渲染 · 计划文件格式（完整参考）

按需读。大多数人只需要 `SKILL.md` 里那个最小示例。

---

## 1. 顶层字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `workflow` | ✅ | 基础工作流（API 格式 JSON）。**相对计划文件所在目录**解析；也可写绝对路径 |
| `items` | ✅ | 项目数组，至少 1 项（只有 1 项时不如走单任务流程） |
| `seedAddress` |  | 种子地址，如 `"7.seed"`。配合 `seedBase`/`seedStep` 用 |
| `seedBase` |  | 第一项的种子，默认 `0` |
| `seedStep` |  | 每项递增多少，默认 `1`（想拉开距离用 `1000` 这类大步长） |
| `freeBetween` |  | `false` = 关掉每项之间清显存（等价于 `-NoFree`） |

## 2. 项目字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | 建议 | 唯一标识。用于产物文件名前缀、报告里的条目名。省略则叫 `item1`、`item2`… |
| `workflow` |  | 覆盖基础工作流（同一批混跑不同工作流） |
| `params` |  | `{ "<节点id>.<输入名>": 值 }`，值原样写入 |

**`params` 的键不要加引号里的数组下标**：只能改「节点输入的整个值」。
要改数组元素（例如 `images` 列表），说明你该改工作流而不是参数。

## 3. 地址怎么写

打开工作流的 API JSON，数字键就是节点 id：

```json
{
  "6": { "class_type": "CLIPTextEncode", "inputs": { "text": "…", "clip": ["4", 1] } },
  "7": { "class_type": "KSampler", "inputs": { "seed": 0, "steps": 25, "cfg": 4.5, "…": "…" } },
  "9": { "class_type": "SaveImage", "inputs": { "filename_prefix": "out", "images": ["8", 0] } }
}
```

对应地址：`6.text`、`7.seed`、`7.steps`、`9.filename_prefix`。

**类型要自己保证**：`seed`/`steps` 给数字，`text`/`filename_prefix` 给字符串。
写错类型服务端会在提交阶段拒绝，干跑看不出来（干跑只验证地址存在）。

## 4. 示例：一组提示词变体（同一个工作流）

```json
{
  "workflow": "02_env/workflows/qwen21_t2i.json",
  "seedAddress": "7.seed", "seedBase": 100000, "seedStep": 137,
  "items": [
    { "name": "sq010_key_a", "params": { "6.text": "清晨的寺庙，薄雾，侧逆光", "9.filename_prefix": "sq010_key_a" } },
    { "name": "sq010_key_b", "params": { "6.text": "清晨的寺庙，薄雾，广角俯拍", "9.filename_prefix": "sq010_key_b" } },
    { "name": "sq010_key_c", "params": { "6.text": "清晨的寺庙，雨后石阶反光", "9.filename_prefix": "sq010_key_c" } }
  ]
}
```

## 5. 示例：混跑不同工作流（图 + 视频）

```json
{
  "workflow": "02_env/workflows/qwen21_t2i.json",
  "items": [
    { "name": "key_01", "params": { "6.text": "…", "9.filename_prefix": "key_01" } },
    { "name": "anim_01", "workflow": "02_env/workflows/minimax_h3_i2v.json",
      "params": { "12.image": "key_01__out_00001_.png", "20.text": "镜头缓慢推近", "30.filename_prefix": "anim_01" } }
  ]
}
```

注意：本示例里视频项用到的图片，必须**已经存在于 ComfyUI 的 input 目录**。
`-OutDir` 下载到的是你本机项目目录，**不在** ComfyUI 的 input 里 ——
需要图生视频时，先把起始图放进 ComfyUI 的 `input/`（或用 `upload_file`），再写进计划。

## 6. 示例：多分辨率/多步数的同题对比（调参用）

```json
{
  "workflow": "02_env/workflows/qwen21_t2i.json",
  "seedAddress": "7.seed", "seedBase": 424242, "seedStep": 0,
  "items": [
    { "name": "res_768",  "params": { "5.width": 768,  "5.height": 1024, "7.steps": 20, "9.filename_prefix": "res_768" } },
    { "name": "res_1024", "params": { "5.width": 1024, "5.height": 1365, "7.steps": 20, "9.filename_prefix": "res_1024" } },
    { "name": "res_1280", "params": { "5.width": 1280, "5.height": 1706, "7.steps": 20, "9.filename_prefix": "res_1280" } }
  ]
}
```

`seedStep: 0` 让三项共用同一个种子 —— 对比分辨率时只变一个变量。

## 7. 命令行参数（脚本侧）

| 参数 | 默认 | 说明 |
|---|---|---|
| `-PlanPath` | 必填 | 计划文件 |
| `-OutDir` | 无 | 下载产物到此目录 |
| `-DryRun` | 关 | 只解析并打印，不提交 |
| `-AllowSingle` | 关 | 允许只有 1 项（默认拒绝：单项该走单任务流程） |
| `-NoRestart` | 关 | 不重启 ComfyUI，改为只 `/free` |
| `-RestartEach` | 自动 | 强制每项之间重启（默认在找到重启器时就是开） |
| `-RestartCommand` | 无 | 自定义同步重启命令（覆盖自动推断） |
| `-RestartWaitSeconds` | 180 | 等服务回来的上限（超时记一次警告，**不中止批次**） |
| `-NoFree` | 关 | 连 `/free` 也不做（`-NoRestart` 时才有意义） |
| `-FreeWaitSeconds` | 25 | 等显存真正释放的上限 |
| `-NoProgressWindow` | 关 | 不弹桌面状态栏 |
| `-StopOnError` | 关 | 任何一项失败就停 |
| `-Quiet` | 关 | 只输出末行 |
| `-HostName` / `-Port` | 127.0.0.1 / 8188 | ComfyUI 地址 |

### 显存策略：默认「每项换一个进程」

| 模式 | 怎么用 | 适合 |
|---|---|---|
| **重启进程**（默认） | 自动：`comfy-restart.ps1` 推断启动器 → 停 → 拉 → 等就绪 | 12GB 卡、模型/分辨率会变、要「主模型整块吃显存」 |
| 只 `/free` | `-NoRestart` | 显存富余（≥24GB）或整批同一模型 |
| 自定义重启 | `-RestartCommand 'pwsh -File C:\comfy\restart.ps1'` | 你的 ComfyUI 不是「python main.py」也不是 EasyManager 布局 |

重启的代价与收益：约 **35–40 秒/次**（实测 EasyManager + RTX 5070），换回 **10.8 GB** 可用显存。
重启失败会**自动退回 `/free`** 并继续，不会毁掉整批。

## 7.1 进度文件与状态栏

`<计划名>.progress.json`（与计划同目录，每次状态变化原子覆盖）：

```json
{ "plan": "…\\plan.json", "total": 3, "done": 1, "ok": 1, "failed": 0,
  "currentIndex": 2, "current": "shot0010_b", "phase": "restarting",
  "statusText": "重启 ComfyUI", "startedAt": "2026-10-22 20:52:27", "totalSeconds": 63.5 }
```

`phase`：`starting` / `running` / `freeing` / `restarting` / `done` / `partial` / `failed` / `aborted`。

桌面状态栏（`tools/progress-window.ps1`）**只读**这个文件，显示「已完成 / 总任务」、进度条、
当前项与累计耗时；批次结束后停住不回退，方便回看。它**不参与渲染、不进模型上下文**。

## 8. 报告文件

计划旁边生成 `<计划名>.result.json`（例如 `plan.result.json`）：

```json
{
  "plan": "…\\plan.json",
  "startedAt": "2026-10-22 17:02:11",
  "totalSeconds": 412.3,
  "ok": 3, "failed": 0, "total": 3,
  "outDir": "…\\30_key",
  "items": [
    {
      "name": "sq010_key_a",
      "status": "DONE",
      "seconds": 137.9,
      "promptId": "0ef667b4-…",
      "files": ["out_A_00001_.png"],
      "saved": ["…\\30_key\\sq010_key_a__out_A_00001_.png"],
      "error": null,
      "params": { "6.text": "…", "9.filename_prefix": "sq010_key_a", "7.seed": 100000 }
    }
  ]
}
```

`params` 是**实际写进工作流的值**（含自动种子）—— 复现一次跑批靠它。
