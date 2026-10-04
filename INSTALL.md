# 安装 / 更新后重新启用

> 本 bundle 是 **DSH 的一个"预设包"**：一份 `cordis.patch.yml` + 8 个 skill 手册 + 若干脚本。
> 它不修改 DSH 本体，只往 profile 里注册一行预设。

---

## 0. 它会不会被 DSH 更新弄坏？

**先说结论，再说依据。**

| 部分 | 更新后 | 说明 |
|---|---|---|
| **bundle 本体**（本目录） | ✅ **不受影响** | 它在 `Documents\...`，不在应用目录 |
| **skill 手册 + 脚本** | ✅ 不受影响 | 同上 |
| **profile 注册**（link + bundles 列表） | ⚠️ **可能失效** | 若更新重装 profile 的 `node_modules` |
| **依赖的 18 个 DSH 内部模块** | ⚠️ **可能改名/移除** | 它们在 `app.asar` 内，随版本变 |
| **PowerShell 7 配置** | ⚠️ **可能被重置** | ⚠️ 它在 **profile 的 `cordis.patch.yml`**，**不在本 bundle 内**！ |

**依据**（都是实测，不是推测）：

1. bundle 实体在 `C:\Users\<你>\Documents\deepseek-harness\default-workspace\comfyui-preset`，
   应用本体在 `D:\Deepseek\resources\app.asar` —— **两个不同的根，更新替换 app 不动 Documents**。
2. 本预设的 15 行插件引用 **18 个 DSH 内部模块**（`@deepseek-ai/dsh-tool-fs` 等）。
   实测：它们**不在 profile 的 `node_modules` 里**，**只存在于 `app.asar` 内**
   （asar 头解析：12,967 个文件 / 529 个包）。→ **预设与 DSH 版本的内部模块集硬耦合。**
3. profile 里是**相对符号链接**：`..\..\..\..\Documents\deepseek-harness\default-workspace\comfyui-preset`。
   它锚在 `C:\Users\<你>\`，**所以：移动/改名工作区会让链接悬空**。

---

## 1. 更新后重新启用（照这个顺序）

```powershell
# ① 先自检 —— 别急着启用
& "<本目录>/tools/verify-preset.ps1"
```

它会报四件事，**按重要性**：

| 检查 | 不过怎么办 |
|---|---|
| **① DSH 内部模块是否还在新 app.asar 里** | 若报"某模块找不到" → 那是更新改了名。**改 `cordis.patch.yml` 里对应行的 `name:`**，或删掉那一行（少一块能力，但不影响其它） |
| **② 文件完整性**（对 MANIFEST.json 的 SHA256） | 你自己改过就是正常现象；改完重跑 `tools/pack-preset.ps1` 刷新清单 |
| **③ profile 注册状态** | 报 link 悬空 → 重新安装（见 §2） |
| **④ PowerShell 7 配置** | 报缺失 → 见 §4 |
| **⑤ 持久化状态** | 🔴 报"快照与 profile 补丁层都不含"→ 见 §1.1，**否则重启后预设会消失** |

```powershell
# ② 若 ③ 不过，重新安装
#    在 DSH 里让 agent 执行：
#      plugin_manager  action=install_bundle  target=<本目录的绝对路径>

# ③ 新开一个会话，在预设选择器里选【ComfyUI 创作模式】
#    现有会话不会变 —— 预设是**按会话**惰性挂载的
```

### 1.1 🔴 千万不要用「禁用→启用」来重应用（2026-10-04 实测的坑）

**这是一个真实踩过的坑，代价是预设重启后消失。**

`plugin_manager set_bundle` 的两个方向**行为不对称**（读 `dsh-app-boot` 源码 + 实测确认）：

| 操作 | 对组合快照 `cordis.yml` 的影响 |
|---|---|
| `enabled=false`（禁用） | **会把当前树写进快照** —— 此时**没有**本预设的行 |
| `enabled=true`（启用） | **只热生效，不落盘**（实测：文件 mtime 不变） |

**后果**：任何一次 disable→enable 之后，**运行中一切正常**（`fiberPhase: active`），
但**落盘的快照永久停在"禁用"状态** —— **一重启，预设就没了**。
而 DSH 启动时正是从 `cordis.yml` + profile 补丁层建树的。

> 所以「报 ambiguous-install 就改用禁用→启用」是**错的**，已从本文件删掉。

**正确的重应用方式**（二选一）：

1. **改完 bundle 内容后** —— 其实**不需要任何 toggle**。skill 正文/脚本是**每次加载时重读**的，
   persona 变更才需要重启；重启本身就会重建树。
2. **若预设真的从选择器里消失了** —— 把 bundle 的 `- insert:` 块原样并入
   profile 的 `cordis.patch.yml`（见下方命令）。profile 层**每次启动都会应用**，放这里最稳。

```powershell
# 把 bundle 补丁的 `- insert:` 块（第一个非注释行到文件末）原样追加到 profile 补丁。
# 两层是同一套 patch 方言，缩进已经正确，**不需要重新缩进**。
$bp = "<bundle>/cordis.patch.yml"
$pp = "$env:USERPROFILE\.dsh\profiles\desktop\cordis.patch.yml"

Copy-Item $pp "$pp.bak-$(Get-Date -f yyyyMMdd-HHmmss)"          # 先备份
$bl = Get-Content $bp -Encoding UTF8
$first = 0; while ($bl[$first] -match '^\s*#' -or $bl[$first].Trim() -eq '') { $first++ }
if ($bl[$first].Trim() -ne '- insert:') { throw "顶层条目不是 - insert:，先人工检查" }
Add-Content $pp ("`n" + (($bl[$first..($bl.Count-1)]) -join "`n"))
```

改完**跑一次 `tools/verify-preset.ps1`**，第 ⑤ 项会告诉你持久化状态对不对。

> ⚠️ **不要两边都放**：若快照与 profile 层同时含 `preset-comfyui`，会重复定义。
> 第 ⑤ 项会检出这种情况并提示二选一。

---

## 2. 全新安装（换机器 / 分发给别人）

```
① 解压 zip 到任意稳定位置（**别放在工作区里**，见下方警告）
② 在 DSH 里让 agent 执行：
     plugin_manager  action=install_bundle  target=<解压出的目录绝对路径>
③ 跑 tools/verify-preset.ps1 自检
④ 补 §4 的 PowerShell 7 配置（否则四个 .ps1 全部拒绝执行）
⑤ 新开会话选【ComfyUI 创作模式】
```

> ⚠️ **不要把 bundle 放在会被移动/改名的工作区里**
> 默认安装会产生一个**相对符号链接**，锚在你的用户目录。工作区一移动，链接就悬空。
> 建议位置：`C:\Users\<你>\.dsh\bundles\comfyui-preset` 或其它**不会再动**的目录。

### 依赖的外部条件

| 条件 | 必需性 | 说明 |
|---|---|---|
| **ComfyUI + comfy-cli** | 要用生成功能则必需 | 本预设不装 ComfyUI，只调用它 |
| **全局 MCP 连接器 `custom-comfymcp`** | 要用 ComfyUI 工具则必需 | 它是**全局连接器**，与预设无关；缺了 `mcp__comfymcp__*` 就没有 |
| **PowerShell 7** | ⚠️ **必需** | 四个 `.ps1` 都声明 `#requires -Version 7`，PS 5.1 下会**失败关闭** |
| **Python 3 + Pillow** | 要用视觉审查则必需 | `review.py` 需要；PATH 上没有就靠 `load_workspace_dependencies` 取捆绑 Python |
| ⚠️ **Python 的 UTF-8 模式** | **必需（否则静默损坏）** | Windows 上 Python 默认跟随控制台代码页（简体中文机是 GBK），`open()` 会**写出 GBK 文件且不报错**。**必须走 `tools/run-python.ps1`**（它设 `PYTHONUTF8=1`），不要直接敲 `python`。自检：`tools/check-encoding.ps1` |
| **ffmpeg / ffprobe** | 要审视频则必需 | 抽帧用 |

---

## 3. 分发清单

`tools/pack-preset.ps1` 产出：

```
dist/
├─ dsh-comfyui-preset-<版本>.zip           ← 给对方的
├─ dsh-comfyui-preset-<版本>.zip.sha256    ← 校验和
└─ dsh-comfyui-preset-<版本>.manifest.json ← 版本 / 文件哈希 / 依赖模块清单
```

**分发时给**：zip + `.sha256` + 本文件（INSTALL.md）。

> `.sha256` 让对方能确认传输没损坏：`(Get-FileHash x.zip -Algorithm SHA256).Hash` 对比。
> `MANIFEST.json` 会被打进 zip，对方解压后 `verify-preset.ps1` 就能用。

---

## 4. ⚠️ PowerShell 7 配置（**这一步不在 bundle 内，必须单独做**）

四个脚本都 `#requires -Version 7`。若 DSH 用的是 Windows PowerShell 5.1，脚本会**拒绝执行**（安全但功能全停）。

**先确认 PowerShell 7 装了并在哪**：

```powershell
Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object Source
# 常见位置：%LOCALAPPDATA%\Microsoft\WindowsApps\pwsh.exe（Store/MSIX 安装）
```

**然后在 profile 的 `cordis.patch.yml` 里加这段覆盖**（`<profile>` = `~\.dsh\profiles\desktop`）：

```yaml
- id: pwsh-sandbox
  config:
    pwshPath: C:\Users\<你>\AppData\Local\Microsoft\WindowsApps\pwsh.exe
  disabled: !!js process.platform !== 'win32'
```

> 这个覆盖是**热生效**的（`pwshPath` 是易变配置字段，不用重启）。
> 它是**幂等**的：`verify-preset.ps1` 的第 4 项会告诉你它在不在。

**若 `pwsh.exe` 不在 PATH 上**（Store 版常见），把它的目录加进用户 PATH：

```powershell
$dir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$cur = [Environment]::GetEnvironmentVariable('Path','User')
if ($cur -notlike "*$dir*") {
    [Environment]::SetEnvironmentVariable('Path', "$cur;$dir", 'User')
}
```

> ⚠️ 写用户 PATH 时注意**保留注册表类型**（`REG_EXPAND_SZ`），别用会把它转成 `REG_SZ` 的写法，
> 否则原有的 `%VAR%` 展开会失效。

---

## 5. 排错

| 症状 | 处置 |
|---|---|
| 预设选择器里没有【ComfyUI 创作模式】 | `plugin_manager list_plugins` 看有没有 `preset-comfyui` 行；有行但选不到 → 该行激活失败，看它的 diagnostic |
| 自检报"某模块在新 app.asar 里找不到" | DSH 更新改了模块名。改 `cordis.patch.yml` 对应行的 `name:`，或删掉那行 |
| 自检报 link 悬空 | bundle 目录被移动/改名了 → 重新 `install_bundle` |
| 脚本报 `#requires ... Windows PowerShell 7.0` | 见 §4 |
| 技能一个都不出现 | `customSkillDirs` 的 `!!js` 没解析出来，或 skill 目录层级不对（必须是 `<skills>/<name>/SKILL.md`） |
| MCP 工具不见了 | 是**全局连接器**的事，与预设无关：查 `mcp_connector_status` |
| 更新后预设还在但少了某块能力 | 大概率就是 §1 表格第 4 行的情况 —— 跑 `verify-preset.ps1` 看第 ① 项 |

---

## 6. 本 bundle 不包含什么

- **不含 DSH 本体与其内部模块** —— 那 18 个模块属于应用，由 DSH 提供
- **不含 ComfyUI / comfy-cli / 模型权重** —— 那是另一套安装
- **不含全局 MCP 连接器配置** —— `custom-comfymcp` 是全局连接器，需要单独配
- **不含 profile 的 PowerShell 7 覆盖** —— 见 §4，**这一项必须单独做**
