#requires -Version 7
<#
.SYNOPSIS
  按专业动画项目的目录规范，创建/扩展一个制作项目的骨架。

.DESCRIPTION
  固化的结构（依据 CGWire 管线提案 + Blender Studio 官方命名规范）：

    projects/<project>/
    ├─ project.json               项目元数据（fps / 基准分辨率 / 风格 / 模型基线）
    ├─ 00_dev/                    企划与设定
    │   ├─ reference/             参考资料
    │   └─ style/                 风格板、色彩基调
    ├─ 10_assets/                 可复用资产（与镜头严格分离）
    │   ├─ characters/<asset>/
    │   ├─ props/<asset>/
    │   └─ environments/<asset>/
    ├─ 20_pre/                    前期
    │   ├─ script/                剧本
    │   ├─ storyboard/            分镜
    │   └─ previz/                动态分镜
    ├─ 30_shots/<seq>/<shot>/     镜头主树（各环节见下）
    ├─ 40_editorial/              剪辑与声音
    │   ├─ audio/
    │   ├─ export/
    │   └─ deliver/
    └─ 90_deliver/                成片交付

  单个镜头的环节目录：

    30_shots/<seq>/<shot>/
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

if (-not $Root) { $Root = Join-Path (Get-Location).Path 'projects' }
$projRoot = Join-Path $Root $Project
$created  = [System.Collections.Generic.List[string]]::new()

function EnsureDir([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) {
        New-Item -ItemType Directory -Force -Path $p | Out-Null
        $created.Add($p)
    }
}

# ── 1) 项目骨架 ────────────────────────────────────────────────────────────
EnsureDir $projRoot
foreach ($d in @(
    '00_dev/reference', '00_dev/style',
    '10_assets/characters', '10_assets/props', '10_assets/environments',
    '20_pre/script', '20_pre/storyboard', '20_pre/previz',
    '30_shots',
    '40_editorial/audio', '40_editorial/edit', '40_editorial/export',
    '40_editorial/edl', '40_editorial/current', '40_editorial/deliver',
    '90_deliver'
)) { EnsureDir (Join-Path $projRoot $d) }

$metaPath = Join-Path $projRoot 'project.json'
if (-not (Test-Path -LiteralPath $metaPath)) {
    $meta = [ordered]@{
        slug          = $Project
        title         = if ($Title) { $Title } else { $Project }
        created       = (Get-Date -Format 'yyyy-MM-dd')
        fps           = 24
        baseWidth     = 1024
        baseHeight    = 1024
        aspect        = '1:1'
        style         = ''
        modelBaseline = [ordered]@{
            image = 'qwen_image_2.1_Q6_K.gguf'
            video = 'MiniMax-H3-Ref2VA-Pruned-Q4_K_M.gguf'
        }
        naming        = '<seq>_<shot>-<element>-v<NNN>[-<frame>].<ext>'
        note          = '命名全小写、无空格；层级用 _ 分隔，字段用 - 分隔；版本 3 位零填充。更新同名文件前先跑 scripts/safe-write.ps1 归档到同目录 old/。'
    }
    $meta | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $metaPath -Encoding utf8
    Say "📄 已写 project.json → $metaPath"
}

# ── 2) 序列 ────────────────────────────────────────────────────────────────
if ($Sequence) {
    EnsureDir (Join-Path $projRoot "20_pre/storyboard/$Sequence")
    EnsureDir (Join-Path $projRoot "30_shots/$Sequence")
}

# ── 3) 镜头 ────────────────────────────────────────────────────────────────
if ($Shot) {
    $shotRoot = Join-Path $projRoot "30_shots/$Sequence/$Shot"
    foreach ($d in @('10_ref', '20_layout', '30_key', '40_video', '50_audio', '60_review')) {
        EnsureDir (Join-Path $shotRoot $d)
    }
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
