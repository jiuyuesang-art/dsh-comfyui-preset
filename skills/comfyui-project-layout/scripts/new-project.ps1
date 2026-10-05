#requires -Version 7
<#
.SYNOPSIS
  按专业动画项目的目录规范，创建/扩展一个制作项目的骨架。

.DESCRIPTION
  固化的结构（依据 CGWire 管线提案 + Blender Studio 官方命名规范）：

    <工作根>/01_projects/<project>/
    ├─ project.json               项目元数据（fps / 基准分辨率 / 风格 / 模型基线）
    ├─ 00_dev/                    企划与设定
    │   ├─ reference/             参考资料
    │   └─ style/                 风格板、色彩基调
    ├─ （资产不在这里：见 <工作根>/00_assets/ 与 02_env/）
    │   ├─ characters/<asset>/
    │   ├─ props/<asset>/
    │   └─ environments/<asset>/
    ├─ 10_pre/                    前期
    │   ├─ script/                剧本
    │   ├─ storyboard/            分镜
    │   └─ previz/                动态分镜
    ├─ 20_shots/<ep>/<seq>/<shot>/ 镜头主树（各环节见下）
    ├─ 30_editorial/              剪辑与声音
    │   ├─ audio/
    │   ├─ export/
    │   └─ deliver/
    └─ 90_deliver/                成片交付

  单个镜头的环节目录：

    20_shots/<ep>/<seq>/<shot>/
    ├─ 10_ref/      参考、设定图
    ├─ 20_layout/   构图/关键帧草稿
    ├─ 30_key/      关键帧定稿
    ├─ 40_video/    视频片段
    └─ 50_audio/    配音/音效
    （old/ 会在各环节目录下按需出现，由 safe-write.ps1 自动建）

.PARAMETER Project
  项目 slug：全小写、只用字母数字和连字符。例：`my-anime`

.PARAMETER Sequence
  序列，格式 `NNN_name`，例：`010_intro`。省略则只建项目骨架。

.PARAMETER Shot
  镜头，格式 `NNN_NNNN`（序列号_镜头号），例：`010_0010`。需同时给 -Sequence。

.PARAMETER Title
  项目中文名/标题，写进 project.json。

.PARAMETER Root
  项目根目录，默认 `<当前目录>/projects`。

.EXAMPLE
  ./new-project.ps1 my-anime -Title "我的动画"
  ./new-project.ps1 my-anime -Sequence 010_intro
  ./new-project.ps1 my-anime -Sequence 010_intro -Shot 010_0010
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][string]$Project,
    [string]$Sequence,
    [string]$Shot,
    [string]$Title,
    [string]$Root,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
function Say([string]$m) { if (-not $Quiet) { Write-Host $m } }

# ── 校验命名（业界规范：全小写、无空格、无特殊字符）──────────────────────
if ($Project -notmatch '^[a-z0-9][a-z0-9-]*$') {
    throw "项目 slug 不合法：'$Project'。要求全小写，只用字母/数字/连字符，例：my-anime"
}
if ($Sequence -and $Sequence -notmatch '^\d{3}_[a-z0-9][a-z0-9_]*$') {
    throw "序列名不合法：'$Sequence'。要求 NNN_name，例：010_intro"
}
if ($Shot -and $Shot -notmatch '^\d{3}_\d{4}$') {
    throw "镜头名不合法：'$Shot'。要求 NNN_NNNN（序列号_镜头号），例：010_0010"
}
if ($Shot -and -not $Sequence) {
    throw "给 -Shot 时必须同时给 -Sequence。"
}

if (-not $Root) {
    # 探测工作根：当前目录或向上 8 层里含 00_assets / 01_projects / 02_env 的那层。
    # 找不到就把当前目录当工作根（首次使用时会在它下面新建三个根）。
    $probe = (Get-Location).Path
    $found = $null
    for ($i = 0; $i -lt 8; $i++) {
        foreach ($m in @('00_assets', '01_projects', '02_env')) {
            if (Test-Path -LiteralPath (Join-Path $probe $m)) { $found = $probe; break }
        }
        if ($found) { break }
        $p = Split-Path $probe -Parent
        if (-not $p -or $p -eq $probe) { break }
        $probe = $p
    }
    $Root = Join-Path ($(if ($found) { $found } else { (Get-Location).Path })) '01_projects'
}
$projRoot = Join-Path $Root $Project
$created  = [System.Collections.Generic.List[string]]::new()

function EnsureDir([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) {
        New-Item -ItemType Directory -Force -Path $p | Out-Null
        $created.Add($p)
    }
}

# ── 0) 按需生长：**不预建任何空目录** ───────────────────────────────────────
# 🔴 本项目的文件结构是**固定的**（三根 / 类型 / 环节，名字都不变），
#    但**什么时候建**是按需的：**没有东西要放，就不建。**
#    · 这次任务没有音频 → 不建 50_audio/
#    · 这次不用 3D   → 不建 04_3d/
#    · 还没做审查     → 不建 60_review/
#    要建某个目录时用 ensure.ps1（幂等，已存在会直接返回）：
#      ensure.ps1 -Dir  01_projects/<p>/20_shots/ep01/sq010/sh0010/30_key
#      ensure.ps1 -Asset characters -Name kirito -Sub ref
$workRoot = Split-Path (Split-Path $projRoot -Parent) -Parent   # 工作根
if (-not $Episode) { $Episode = 'ep01' }

# 只建到"项目"这一层 —— 其余全部按需
EnsureDir (Split-Path $projRoot -Parent) | Out-Null   # 01_projects/
EnsureDir $projRoot | Out-Null

$metaPath = Join-Path $projRoot 'project.json'
if (-not (Test-Path -LiteralPath $metaPath)) {
    $meta = [ordered]@{
        slug          = $Project
        title         = if ($Title) { $Title } else { $Project }
        created       = (Get-Date -Format 'yyyy-MM-dd')
        episode       = $Episode
        fps           = 24
        baseWidth     = 1024
        baseHeight    = 1024
        aspect        = '1:1'
        style         = ''
        modelBaseline = [ordered]@{
            image = 'qwen_image_2.1_Q6_K.gguf'
            video = 'MiniMax-H3-Ref2VA-Pruned-Q4_K_M.gguf'
        }
        shotCode      = '<ep>_<sq>_<sh>'
        naming        = '<shotCode>-<element>-v<NNN>[-<frame>].<ext>'
        lazyDirs      = $true
        note          = '目录按需生长：没有东西要放就不建（用 scripts/ensure.ps1 建）。命名全小写、无空格；层级用 _ 分隔，字段用 - 分隔；版本 3 位零填充。更新同名产物前先跑 scripts/safe-write.ps1 归档到同目录 old/。'
    }
    $meta | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metaPath -Encoding utf8
    Say "📄 已写 project.json → $metaPath"
}

# ── 1) 可选：按需建序列 / 镜头（只建点名的那些，不铺全套）──────────────────
if ($Sequence) {
    # 分镜图目录 —— 只有真的要放分镜图时才需要，所以只在点名序列时建
    EnsureDir (Join-Path $projRoot "10_pre/storyboard/$Sequence") | Out-Null
    EnsureDir (Join-Path $projRoot "20_shots/$Episode/$Sequence") | Out-Null
}

if ($Shot) {
    # 只建镜头这一层。下面的环节目录（10_ref / 30_key / …）等**真正要放东西时**
    # 由 ensure.ps1 按需创建 —— 见上方 §0 说明。
    $shotRoot = Join-Path $projRoot "20_shots/$Episode/$Sequence/$Shot"
    EnsureDir $shotRoot | Out-Null
    $cli = Join-Path $shotRoot 'shot.json'
    if (-not (Test-Path -LiteralPath $cli)) {
        [ordered]@{
            sequence = $Sequence
            shot     = $Shot
            created  = (Get-Date -Format 'yyyy-MM-dd')
            duration = 5
            frames   = 124
            fps      = 24
            status   = 'wip'
            note     = "文件名只用数字段，不要带序列的描述部分：${Shot}-<element>-v<NNN>.<ext>（例：${Shot}-key-v001.png）"
        } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $cli -Encoding utf8
    }
}

# ── 输出 ───────────────────────────────────────────────────────────────────
Say ""
Say "✅ 项目根：$projRoot"
if ($created.Count -gt 0) {
    Say "   新建 $($created.Count) 个目录："
    $created | ForEach-Object { Say ("     " + $_.Replace($projRoot, '.')) }
} else {
    Say "   （目录已存在，未新建）"
}
if ($Quiet) { "OK`t$projRoot" }
