#requires -Version 7
<#
.SYNOPSIS
  管线状态探针 —— 把「工程进度」变成一条命令就能拿到的事实，供激活路由判定。

.DESCRIPTION
  MoE 式稀疏激活的门控输入有两路：**意图信号**（用户说了什么）和**进度信号**（工程走到哪一步）。
  意图信号本来就有；进度信号以前得靠模型自己翻目录猜，既贵又不可靠。本脚本补上这一路。

  它扫描 projects/<slug>/30_shots/<seq>/<shot>/，为每个镜头判定**当前阶段**，
  并直接给出**该激活哪些专家（skill）**，以及**下一个动作**。

  阶段判定（按顺序，先命中先算）：

    empty              什么都没有
    ref                只有参考图，还没出构图
    layout             有构图草稿，还没定关键帧
    key-needs-meta     有关键帧但**缺 .meta.json 侧车** → 不可复现
    key-needs-review   有关键帧+侧车，但**还没有审查报告** → 交付前必须审
    key-rework         最新审查判定是 NEEDS_WORK / FAIL → 要改
    key-done           审查通过，可交付
    video-needs-review 有视频但没审
    video-done         视频审过
    delivered          已进交付目录

.PARAMETER Project
  项目 slug。省略则扫描 Root 下所有项目，并优先报告最近有活动的那个。

.PARAMETER Root
  项目根目录，默认 `<当前目录>/projects`。

.PARAMETER Json
  输出机器可读 JSON（供自动化消费）。

.EXAMPLE
  ./pipeline-status.ps1                    # 扫全部项目，给出当前该激活什么
  ./pipeline-status.ps1 my-anime           # 只看一个项目
  ./pipeline-status.ps1 my-anime -Json     # 机器可读
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Project,
    [string]$Root,
    [switch]$Json,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

if (-not $Root) { $Root = Join-Path (Get-Location).Path 'projects' }
if (-not (Test-Path -LiteralPath $Root)) {
    if ($Json) {
        @{ root = $Root; exists = $false; projects = @(); experts = @('comfyui-project-layout'); next = '还没有任何项目：先跑 new-project.ps1 立项' } |
            ConvertTo-Json -Depth 6
    } else {
        "📂 项目根不存在：$Root"
        ""
        "▶ 阶段：empty（还没有任何项目）"
        "▶ 该激活：comfyui-project-layout"
        "▶ 下一步：& scripts/new-project.ps1 <slug> -Title `"<片名>`""
    }
    exit 0
}

# 环节目录（排除 old/）
$ELEMENTS = [ordered]@{
    '10_ref'    = 'ref'
    '20_layout' = 'layout'
    '30_key'    = 'key'
    '40_video'  = 'video'
    '50_audio'  = 'audio'
    '60_review' = 'review'
}

function Get-Artifacts([string]$dir) {
    if (-not (Test-Path -LiteralPath $dir)) { return @() }
    @(Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '*.meta.json' -and $_.Name -ne 'shot.json' })
}

function Get-Verdict([string]$reviewDir) {
    if (-not (Test-Path -LiteralPath $reviewDir)) { return $null }
    $rep = Get-ChildItem -LiteralPath $reviewDir -File -Filter '*review*.md' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $rep) { return $null }
    $m = Select-String -LiteralPath $rep.FullName -Pattern '判定[：:]\s*\**\s*(PASS_WITH_NOTES|PASS|NEEDS_WORK|FAIL)' -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($m) { return $m.Matches[0].Groups[1].Value }
    return 'UNKNOWN'
}

function Resolve-Stage($shotDir) {
    $a = @{}
    foreach ($k in $ELEMENTS.Keys) { $a[$ELEMENTS[$k]] = Get-Artifacts (Join-Path $shotDir $k) }

    $hasKey   = $a['key'].Count -gt 0
    $hasVideo = $a['video'].Count -gt 0
    $reviewDir = Join-Path $shotDir '60_review'
    $verdict = Get-Verdict $reviewDir

    if ($a['ref'].Count -eq 0 -and $a['layout'].Count -eq 0 -and -not $hasKey -and -not $hasVideo) {
        return [pscustomobject]@{ stage = 'empty'; detail = '镜头目录是空的' }
    }

    if ($hasVideo) {
        if (-not $verdict) { return [pscustomobject]@{ stage = 'video-needs-review'; detail = "视频 $($a['video'].Count) 个，尚无审查报告" } }
        if ($verdict -in @('NEEDS_WORK', 'FAIL')) { return [pscustomobject]@{ stage = 'video-rework'; detail = "视频审查判定 $verdict" } }
        return [pscustomobject]@{ stage = 'video-done'; detail = "视频审查 $verdict" }
    }

    if ($hasKey) {
        $newest = $a['key'] | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $sidecar = Join-Path $shotDir ('30_key\' + [IO.Path]::GetFileNameWithoutExtension($newest.Name) + '.meta.json')
        if (-not (Test-Path -LiteralPath $sidecar)) {
            return [pscustomobject]@{ stage = 'key-needs-meta'; detail = "$($newest.Name) 缺 .meta.json 侧车（不可复现）" }
        }
        if (-not $verdict) {
            return [pscustomobject]@{ stage = 'key-needs-review'; detail = "关键帧 $($a['key'].Count) 个已就绪，尚无审查报告" }
        }
        if ($verdict -in @('NEEDS_WORK', 'FAIL')) {
            return [pscustomobject]@{ stage = 'key-rework'; detail = "审查判定 $verdict，需改后重出" }
        }
        return [pscustomobject]@{ stage = 'key-done'; detail = "审查 $verdict" }
    }

    if ($a['layout'].Count -gt 0) {
        return [pscustomobject]@{ stage = 'layout'; detail = "构图 $($a['layout'].Count) 个，未定关键帧" }
    }
    return [pscustomobject]@{ stage = 'ref'; detail = "参考图 $($a['ref'].Count) 个，未出构图" }
}

# 阶段 → 该激活的专家（这就是门控网络的输出）
$ROUTE = @{
    'empty'              = @{ experts = @('comfyui-project-layout'); next = '建镜头：new-project.ps1 <slug> -Sequence <seq> -Shot <shot>' }
    'ref'                = @{ experts = @('comfyui-project-layout', 'comfyui-prompt-craft', 'comfyui-mcp-ops'); next = '写构图提示词并出草图，落到 20_layout' }
    'layout'             = @{ experts = @('comfyui-mcp-ops', 'comfyui-review'); next = '审构图，过则定关键帧到 30_key' }
    'key-needs-meta'     = @{ experts = @('comfyui-project-layout'); next = '补 .meta.json 侧车（write-meta.ps1），否则不可复现' }
    'key-needs-review'   = @{ experts = @('comfyui-review'); next = '🔴 强制：read_image 真看图 → 落盘 60_review 报告 → 交人 review' }
    'key-rework'         = @{ experts = @('comfyui-prompt-craft', 'comfyui-mcp-ops'); next = '按报告建议改参数重出；覆盖前先 safe-write.ps1' }
    'key-done'           = @{ experts = @(); next = '可交付：present 给用户；若还要出视频则继续 40_video' }
    'video-needs-review' = @{ experts = @('comfyui-review', 'minimax-h3-docs'); next = '🔴 抽帧审查（回看显存告警），报告落 60_review' }
    'video-rework'       = @{ experts = @('comfyui-prompt-craft', 'minimax-h3-docs'); next = '按报告改参数重出' }
    'video-done'         = @{ experts = @(); next = '可交付' }
}

# ── 收集 ────────────────────────────────────────────────────────────────────
$projects = if ($Project) {
    $p = Join-Path $Root $Project
    if (Test-Path -LiteralPath $p) { @(Get-Item -LiteralPath $p) } else { @() }
} else {
    @(Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue)
}

if ($projects.Count -eq 0) {
    if ($Json) { @{ root = $Root; exists = $true; projects = @(); experts = @('comfyui-project-layout'); next = '项目根是空的，先立项' } | ConvertTo-Json -Depth 6 }
    else { "📂 $Root 下没有项目`n`n▶ 该激活：comfyui-project-layout`n▶ 下一步：new-project.ps1 <slug>" }
    exit 0
}

$result = @()
foreach ($proj in $projects) {
    $shotsRoot = Join-Path $proj.FullName '30_shots'
    $shots = @()
    if (Test-Path -LiteralPath $shotsRoot) {
        foreach ($seq in (Get-ChildItem -LiteralPath $shotsRoot -Directory -ErrorAction SilentlyContinue)) {
            foreach ($sh in (Get-ChildItem -LiteralPath $seq.FullName -Directory -ErrorAction SilentlyContinue)) {
                $st = Resolve-Stage $sh.FullName
                $shots += [pscustomobject]@{
                    sequence = $seq.Name
                    shot     = $sh.Name
                    stage    = $st.stage
                    detail   = $st.detail
                    experts  = @($ROUTE[$st.stage].experts)
                    next     = $ROUTE[$st.stage].next
                }
            }
        }
    }
    $stages = @($shots | ForEach-Object { $_.stage })
    # 项目级：取"最落后但已开工"的那个阶段作为项目当前主战场；空项目则 empty
    $order = @('key-rework','video-rework','key-needs-review','video-needs-review','key-needs-meta','layout','ref','key-done','video-done','empty')
    $primary = ($order | Where-Object { $stages -contains $_ } | Select-Object -First 1)
    if (-not $primary) { $primary = 'empty' }

    $result += [pscustomobject]@{
        project      = $proj.Name
        path         = $proj.FullName
        shotCount    = $shots.Count
        primaryStage = $primary
        experts      = @($ROUTE[$primary].experts)
        next         = $ROUTE[$primary].next
        shots        = $shots
        lastActivity = if ($shots.Count) { ($shots | ForEach-Object { $_ } | Measure-Object).Count } else { 0 }
    }
}

# 无参时按"最需要动手"排序：待审查/待改 排在前面
$prio = @{ 'key-rework'=0; 'video-rework'=1; 'key-needs-review'=2; 'video-needs-review'=3; 'key-needs-meta'=4; 'layout'=5; 'ref'=6; 'empty'=7; 'key-done'=8; 'video-done'=9 }
$result = @($result | Sort-Object { $prio[$_.primaryStage] }, project)

if ($Json) {
    @{ root = $Root; exists = $true; projects = $result } | ConvertTo-Json -Depth 8
    exit 0
}

# ── 人类可读 ────────────────────────────────────────────────────────────────
foreach ($r in $result) {
    ""
    "════ $($r.project) ════  $($r.shotCount) 个镜头 · 主战场阶段：$($r.primaryStage)"
    if ($r.shotCount -gt 0) {
        foreach ($s in ($r.shots | Sort-Object sequence, shot)) {
            "   {0}/{1,-12} {2,-18} {3}" -f $s.sequence, $s.shot, $s.stage, $s.detail
        }
    }
    if ($r.experts.Count -gt 0) {
        "   ▶ 该激活：" + ($r.experts -join ' + ')
    } else {
        "   ▶ 该激活：（无 —— 该阶段不需要额外手册）"
    }
    "   ▶ 下一步：$($r.next)"
}
""
"提示：不要一次加载全部手册。按上面的「该激活」只取需要的；配方这类重内容在真正出图时才读。"
