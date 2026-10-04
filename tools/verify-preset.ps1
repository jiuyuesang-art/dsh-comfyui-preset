#requires -Version 7
<#
.SYNOPSIS
  DSH 更新后的存活自检 —— 在启用预设【之前】跑，确认它没被更新弄坏。

.DESCRIPTION
  检查四件事，按重要性排序：

    1. **DSH 内部模块是否还在新 app.asar 里**  ← 最关键
       本预设的 15 行插件引用 18 个 DSH 内部模块，它们只存在于 app.asar 内。
       更新若改名/移除任何一个，对应行就激活失败（预设还在，但能力缺一块）。
    2. **文件完整性** —— 与 MANIFEST.json 的 SHA256 逐项核对，确认 bundle 没被改动/损坏。
    3. **profile 注册状态** —— link 是否悬空、bundles 列表是否含本预设。
    4. **PowerShell 7 配置** —— 四个 .ps1 脚本硬依赖 PS7；这个配置在 **profile 的
       cordis.patch.yml** 里，**不在本 bundle 内**，更新可能重置它。

.PARAMETER AsarPath
  app.asar 路径。默认自动探测 D:\Deepseek\resources\app.asar 等常见位置。

.PARAMETER ProfileDir
  profile 目录，默认 $env:USERPROFILE\.dsh\profiles\desktop。

.EXAMPLE
  ./verify-preset.ps1
#>
[CmdletBinding()]
param(
    [string]$AsarPath,
    [string]$ProfileDir
)

$ErrorActionPreference = 'Continue'
$bundle = Split-Path $PSScriptRoot -Parent
if (-not $ProfileDir) { $ProfileDir = Join-Path $env:USERPROFILE '.dsh\profiles\desktop' }
$manifestPath = Join-Path $bundle 'MANIFEST.json'   # 可能不存在（新克隆的仓库里被 gitignore）

$fail = 0
function OK($m)   { "  ✅ $m" }
function BAD($m)  { $script:fail++; "  ❌ $m" }
function WARN($m) { "  ⚠️  $m" }

# ── 0) 定位 app.asar ────────────────────────────────────────────────────────
if (-not $AsarPath) {
    $cands = @(
        'D:\Deepseek\resources\app.asar',
        (Join-Path ${env:ProgramFiles} 'DeepSeek\resources\app.asar'),
        (Join-Path $env:LOCALAPPDATA 'Programs\DeepSeek\resources\app.asar')
    )
    $AsarPath = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
}
"════ 0) 环境 ════"
"  bundle    : $bundle"
"  profile   : $ProfileDir"
"  app.asar  : $(if ($AsarPath) { $AsarPath } else { '（未找到）' })"

# ── 1) DSH 内部模块兼容性（最关键）──────────────────────────────────────────
""
"════ 1) DSH 内部模块兼容性（最关键）════"
# 模块清单的**真正来源是 cordis.patch.yml**（MANIFEST.json 只是打包时的快照，
# 而且它在 .gitignore 里——新克隆的仓库没有它）。所以这里从补丁直接读。
$patchFile = Join-Path $bundle 'cordis.patch.yml'
if (-not (Test-Path $patchFile)) {
    BAD "找不到 cordis.patch.yml —— 这不是一个完整的 bundle"
} elseif (-not $AsarPath) {
    WARN "找不到 app.asar，无法核对模块兼容性（这一步最该做，请用 -AsarPath 指定）"
} else {
    $patchText = Get-Content $patchFile -Raw -Encoding UTF8
    $modules = @([regex]::Matches($patchText, "name:\s*'(@deepseek-ai/[^']+)'") |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $scanner = Join-Path $PSScriptRoot 'asar-modules.cjs'
    if (-not (Test-Path $scanner)) {
        BAD "找不到 tools/asar-modules.cjs"
    } else {
        "  核对 $($modules.Count) 个模块是否仍在 app.asar 内…"
        $out = & node $scanner $AsarPath 'check' @modules 2>&1
        $missed = @($out | Select-String -Pattern '^\s+❌\s' | ForEach-Object { $_.Line.Trim() })
        $tail = ($out | Select-String -Pattern '存在 \d+ / \d+').Line
        if ($missed.Count -eq 0) {
            OK "全部模块仍在（$tail）"
        } else {
            BAD "$($missed.Count) 个模块在新 app.asar 里找不到了（$tail）："
            $missed | ForEach-Object { "       $_" }
            "     → 这些模块对应的插件行会**激活失败**。处置："
            "       a) 若是改名，改 cordis.patch.yml 里对应行的 name；"
            "       b) 若是移除，删掉那一行（能力会缺一块，但不影响其它部分）"
        }
    }
}

# ── 2) 文件完整性 ───────────────────────────────────────────────────────────
""
"════ 2) 文件完整性（与 MANIFEST.json 核对）════"
if (-not (Test-Path $manifestPath)) {
    WARN "没有 MANIFEST.json（新克隆的仓库里它被 .gitignore 排除了）—— 跑一次 tools/pack-preset.ps1 即可生成，跳过完整性核对"
} else {
    $mf = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    "$($mf.name) v$($mf.version)  打包于 $($mf.builtAt)  验证过的 DSH 版本 $($mf.dshVerifiedOn)"
    $bad = @()
    foreach ($f in $mf.files) {
        $p = Join-Path $bundle ($f.path -replace '/', '\')
        if (-not (Test-Path $p)) { $bad += "缺失: $($f.path)"; continue }
        $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
        if ($h -ne $f.sha256) { $bad += "改动: $($f.path)" }
    }
    if ($bad.Count -eq 0) { OK "$($mf.files.Count)/$($mf.files.Count) 文件哈希一致" }
    else {
        WARN "$($bad.Count) 个文件与清单不符（若你自己改过，属正常；改完请重跑 pack-preset.ps1 刷新清单）"
        $bad | Select-Object -First 8 | ForEach-Object { "       $_" }
    }
}

# ── 3) profile 注册状态 ─────────────────────────────────────────────────────
""
"════ 3) profile 注册状态 ════"
$link = Join-Path $ProfileDir 'node_modules\dsh-comfyui-preset'
if (Test-Path $link) {
    $item = Get-Item $link -Force
    # 注意：Resolve-Path 对**相对符号链接**返回的是链接自身路径，不是目标。
    # 必须自己把 .Target 按链接所在目录解析成绝对路径，否则会误报"指向另一个副本"。
    $raw = $item.Target
    if ($raw -is [array]) { $raw = $raw[0] }
    if ($raw) {
        $abs = if ([IO.Path]::IsPathRooted($raw)) { $raw } else {
            [IO.Path]::GetFullPath((Join-Path (Split-Path $link -Parent) $raw))
        }
    } else { $abs = $null }

    if ($abs -and (Test-Path $abs)) {
        OK "link 有效 → $abs"
        if ($abs.TrimEnd('\') -ne $bundle.TrimEnd('\')) {
            WARN "但它指向的是另一个副本（本次检查的目录是 $bundle）—— 你检查的可能不是被加载的那份"
        }
    } else {
        BAD "link 悬空（$($item.LinkType) → $raw）—— 常见原因：bundle 目录被移动/改名了"
    }
} else {
    BAD "profile 里没有 dsh-comfyui-preset —— 需要重新安装（见 INSTALL.md）"
}

$pj = Join-Path $ProfileDir 'package.json'
if (Test-Path $pj) {
    $j = Get-Content $pj -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($j.dsh.profile.bundles -contains 'dsh-comfyui-preset') { OK "bundles 列表含 dsh-comfyui-preset" }
    else { BAD "bundles 列表里没有 dsh-comfyui-preset" }
    if ($j.dependencies.'dsh-comfyui-preset') { OK "dependencies: $($j.dependencies.'dsh-comfyui-preset')" }
    else { BAD "dependencies 里没有 dsh-comfyui-preset 的 link 记录" }
}

# ── 4) PowerShell 7 配置（脚本硬依赖，且不在本 bundle 内）───────────────────
""
"════ 4) PowerShell 7 配置（四个脚本硬依赖）════"
$profilePatch = Join-Path $ProfileDir 'cordis.patch.yml'
if (Test-Path $profilePatch) {
    $txt = Get-Content $profilePatch -Raw -Encoding UTF8
    if ($txt -match 'pwsh-sandbox') {
        $m = [regex]::Match($txt, 'pwshPath:\s*(\S+)')
        if ($m.Success) { OK "profile 补丁里有 pwsh-sandbox 覆盖 → $($m.Groups[1].Value)" }
        else { WARN "有 pwsh-sandbox 行但没找到 pwshPath —— 检查一下" }
    } else {
        BAD "profile 补丁里**没有** pwsh-sandbox 覆盖 —— 脚本会退回 Windows PowerShell 5.1 并全部失败"
        "     → 按 INSTALL.md 的「PowerShell 7 配置」一节重新加上"
    }
} else {
    WARN "profile 里没有 cordis.patch.yml"
}
$pwshExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pwsh.exe'
if (Test-Path $pwshExe) { OK "pwsh.exe 存在 → $pwshExe" }
else {
    $onPath = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($onPath) { OK "pwsh 在 PATH 上 → $($onPath.Source)" }
    else { BAD "找不到 pwsh.exe —— 需安装 PowerShell 7" }
}

# ── 5) 持久化状态（这个坑很隐蔽：运行中正常，重启后丢失）────────────────────
""
"════ 5) 持久化状态（重启后还在吗）════"
# 背景：`cordis.yml` 是组合快照，启动时从它建树。
# **`set_bundle enabled=false` 会把树写进快照（那时没有我们的行），
#   而 `enabled=true` 只热生效、不落盘。** 于是 disable→enable 之后，
# 运行中一切正常，**一重启预设就消失**。
$cordisYml = Join-Path $ProfileDir 'cordis.yml'
$profilePatch = Join-Path $ProfileDir 'cordis.patch.yml'

$inSnapshot = $false
$inProfileLayer = $false
if (Test-Path $cordisYml) {
    $snap = Get-Content $cordisYml -Raw -Encoding UTF8
    $inSnapshot = ([regex]::Matches($snap, 'preset-comfyui')).Count -gt 0
}
if (Test-Path $profilePatch) {
    $lay = Get-Content $profilePatch -Raw -Encoding UTF8
    $inProfileLayer = ([regex]::Matches($lay, 'preset-comfyui')).Count -gt 0
}

if ($inSnapshot -and $inProfileLayer) {
    WARN "快照与 profile 补丁层**都**含 preset-comfyui —— 可能重复定义。建议二选一（删掉 profile 补丁里那段 insert）"
} elseif ($inProfileLayer) {
    OK "profile 补丁层含 preset-comfyui（**每次启动都会应用，重启后仍在**）"
} elseif ($inSnapshot) {
    OK "组合快照含 preset-comfyui（重启后仍在）"
} else {
    BAD "快照与 profile 补丁层**都不含** preset-comfyui —— 重启后预设会消失！"
    "     → 处置：把 bundle 的 `- insert:` 块原样并入 profile 的 cordis.patch.yml（见 INSTALL.md §1）"
    "     ⚠️ **不要**用「禁用→启用」来重应用 —— 那正是造成这个状态的操作"
}

# ── 结论 ────────────────────────────────────────────────────────────────────
""
if ($fail -eq 0) {
    "🎉 自检通过 —— 可以启用预设。"
    "   启用方式：plugin_manager → set_bundle dsh-comfyui-preset（或先 install_bundle 再 set_bundle）"
    "   然后**新开一个会话**选择【ComfyUI 创作模式】。"
} else {
    "❌ 有 $fail 项未通过，先按上面的提示修，再启用。"
    exit 1
}
