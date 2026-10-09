#requires -Version 7
<#
.SYNOPSIS
    检查 study 条目是否合规 —— 「三件套」缺一不可。

.DESCRIPTION
    🔴 存在的理由：实测事故 —— 用户清空 study/ 后让 agent 用 ComfyUI + Qwen 2.1，
    它加载了手册、也知道该往 study/ 放，却**跳过了「去抓」这一步**，
    直接凭记忆写了一份 summary.md，没有 source.md、没有 refs/。**它自己觉得完成了。**

    没有任何东西会拦住它 —— 没有报错、没有失败。所以需要一个**机械的检查**。

    一个合规的 study 条目必须有：
      · summary.md   从 refs/ 总结出的要点
      · source.md    真实 URL + 抓取时间 + 可信度
      · refs/        🔴 **从网上抓下来的原文**（不能是空的，也不能是自己写的）

    lessons.md 可选（我们自己的经验，与外部知识分开存放）。

.PARAMETER Path
    工作根（含 00_assets / 01_projects / 02_env 的那层），或某个 study 条目目录。
    默认向上探测工作根。

.PARAMETER Quiet
    只输出汇总。

.EXAMPLE
    ./check-study.ps1                    # 检查整个工作根的 study
    ./check-study.ps1 -Path 02_env/study/qwen-image-2-1
#>
[CmdletBinding()]
param(
    [string]$Path,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Find-WorkRoot {
    $d = (Get-Location).Path
    for ($i = 0; $i -lt 8; $i++) {
        foreach ($m in @('00_assets', '01_projects', '02_env')) {
            if (Test-Path -LiteralPath (Join-Path $d $m)) { return $d }
        }
        $p = Split-Path $d -Parent
        if (-not $p -or $p -eq $d) { break }
        $d = $p
    }
    return $null
}

if (-not $Path) {
    $wr = Find-WorkRoot
    if (-not $wr) { throw '找不到工作根。用 -Path 指定。' }
    $Path = $wr
}
$Path = (Resolve-Path -LiteralPath $Path).Path

# 收集要检查的 study 条目
$entries = @()
if (Test-Path -LiteralPath (Join-Path $Path 'summary.md')) {
    # 直接给了一个条目目录
    $entries += Get-Item -LiteralPath $Path
} else {
    foreach ($root in @((Join-Path $Path '02_env\study'), (Join-Path $Path 'study'))) {
        if (Test-Path -LiteralPath $root) {
            $entries += Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue
        }
    }
    # 项目级
    $pr = Join-Path $Path '01_projects'
    if (Test-Path -LiteralPath $pr) {
        $entries += Get-ChildItem -LiteralPath $pr -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq 'study' } |
            ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue }
    }
}

if ($entries.Count -eq 0) {
    Write-Host "  ⚠️  没找到任何 study 条目"
    exit 0
}

$ok = 0; $bad = 0; $badList = @()

foreach ($e in ($entries | Sort-Object FullName -Unique)) {
    $sum = Join-Path $e.FullName 'summary.md'
    $src = Join-Path $e.FullName 'source.md'
    $ref = Join-Path $e.FullName 'refs'
    $les = Join-Path $e.FullName 'lessons.md'

    $hasSum = Test-Path -LiteralPath $sum
    $hasSrc = Test-Path -LiteralPath $src
    $hasRef = Test-Path -LiteralPath $ref
    $refFiles = if ($hasRef) { @(Get-ChildItem -LiteralPath $ref -File -Recurse -ErrorAction SilentlyContinue) } else { @() }
    $hasRefContent = $refFiles.Count -gt 0

    # source.md 里有没有真 URL
    $srcUrl = ''
    if ($hasSrc) {
        $st = Get-Content -LiteralPath $src -Raw -Encoding UTF8
        $m = [regex]::Match($st, 'https?://[^\s\)\]<>"]+')
        if ($m.Success) { $srcUrl = $m.Value }
        # 是否如实声明了「无官方文档」
        $noOfficial = $st -match '无官方文档|无官方'
    } else { $noOfficial = $false }

    $problems = @()
    if (-not $hasSum) { $problems += '缺 summary.md' }
    if (-not $hasSrc) { $problems += '🔴 缺 source.md（不知道东西从哪来）' }
    elseif (-not $srcUrl -and -not $noOfficial) { $problems += '🔴 source.md 里没有 URL，也没声明「无官方文档」' }
    if (-not $hasRef) { $problems += '🔴 缺 refs/（很可能是凭记忆写的，不是抓来的）' }
    elseif (-not $hasRefContent) { $problems += '🔴 refs/ 是空的（同上）' }

    $rel = $e.FullName
    if ($problems.Count -eq 0) {
        $ok++
        if (-not $Quiet) {
            $lesMark = if (Test-Path -LiteralPath $les) { ' +lessons' } else { '' }
            Write-Host ("  ✅ {0}  refs={1}{2}" -f $rel, $refFiles.Count, $lesMark)
        }
    } else {
        $bad++
        $badList += [pscustomobject]@{ Dir = $rel; Problems = $problems }
        if (-not $Quiet) {
            Write-Host ("  ❌ {0}" -f $rel)
            foreach ($p in $problems) { Write-Host ("       · {0}" -f $p) }
        }
    }
}

Write-Host ""
if ($bad -eq 0) {
    Write-Host "  🎉 全部合规（$ok 个条目）"
    exit 0
} else {
    Write-Host "  ❌ $bad 个不合规 / 共 $($ok + $bad) 个"
    Write-Host ""
    Write-Host "  ── 怎么修 ──"
    Write-Host "     1. 先抓：把官方原文存进 refs/（web_fetch 抓下来，不要自己写）"
    Write-Host "     2. 写 source.md：真实 URL + 抓取时间 + 可信度 + 交叉验证记录"
    Write-Host "     3. 再写 summary.md：从 refs/ 总结，每条带指向 refs 的指针"
    Write-Host "     4. 自己的经验另放 lessons.md，不要混进 summary.md"
    Write-Host ""
    Write-Host "     🔴 自问：refs/ 里的东西是我从网上抓的，还是我自己写的？"
    Write-Host "        自己写的 → 这不是 study 条目，是笔记。"
    exit 1
}
