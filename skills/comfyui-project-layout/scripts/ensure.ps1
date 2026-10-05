#requires -Version 7
<#
.SYNOPSIS
    按需创建目录 —— 本项目的「生长式」文件结构核心工具。

.DESCRIPTION
    本项目的文件结构是**固定的**（三根 / 类型 / 环节，名字都不变），
    但**什么时候建**是按需的：**没有东西要放，就不建。**

    本脚本是那条规则的唯一入口。它是**幂等**的 —— 重复调用不会出错、不会重复建。

    两种用法：

      ① 资产：自动分配编号，已存在则直接返回（不重复建）
         ensure.ps1 -Asset characters -Name kirito
         → <工作根>/00_assets/01_characters/0001_kirito

      ② 任意目录：按需建一条路径
         ensure.ps1 -Dir 01_projects/my-anime/20_shots/ep01/sq010/sh0010
         → <工作根>/01_projects/my-anime/20_shots/ep01/sq010/sh0010

.PARAMETER Asset
    资产类型。可以写全名 `01_characters`，也可以只写 `characters`（会模糊匹配）。
    不存在该类型目录时会**新建**（这正是按需生长的意思）。

.PARAMETER Name
    资产名（小写、无空格）。会与自动分配的 4 位编号拼成 `0001_名称`。

.PARAMETER Sub
    要一并建的子目录，逗号分隔。**只写你这次真的要往里放东西的**。
    常见：ref（参考图）、sheet（设定图）、old（归档）

.PARAMETER Dir
    相对于工作根的目录路径（用 / 分隔）。按需建整条链。

.PARAMETER Root
    工作根。默认自动探测：从当前目录向上找含 00_assets / 01_projects / 02_env 的那层。

.EXAMPLE
    # 建一个角色资产（含参考图目录）
    ./ensure.ps1 -Asset characters -Name kirito -Sub ref

    # 建一个镜头目录（只建这一层，子环节等真正用到再建）
    ./ensure.ps1 -Dir 01_projects/guofeng/20_shots/ep01/sq010_temple/sh0010_arrive

    # 幂等：再跑一次返回同一个路径，不报错、不重复建
    ./ensure.ps1 -Asset characters -Name kirito
#>
[CmdletBinding(DefaultParameterSetName = 'Asset')]
param(
    [Parameter(Mandatory, Position = 1, ParameterSetName = 'Asset')]
    [string]$Asset,

    [Parameter(Mandatory, Position = 2, ParameterSetName = 'Asset')]
    [string]$Name,

    [Parameter(ParameterSetName = 'Asset')]
    [string[]]$Sub,

    [Parameter(Mandatory, Position = 1, ParameterSetName = 'Dir')]
    [string]$Dir,

    [string]$Root
)

$ErrorActionPreference = 'Stop'

# ── 探测工作根 ────────────────────────────────────────────────────────────
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

if (-not $Root) { $Root = Find-WorkRoot }
if (-not $Root) {
    throw @"
找不到工作根（向上 8 层内没有 00_assets / 01_projects / 02_env 任一）。
请用 -Root 显式指定，或先在目标位置跑一次：
  new-project.ps1 <项目名>
"@
}
if (-not (Test-Path -LiteralPath $Root)) { throw "工作根不存在：$Root" }
$Root = (Resolve-Path -LiteralPath $Root).Path

function EnsureDir([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) {
        New-Item -ItemType Directory -Force -Path $p | Out-Null
        return $true     # 新建了
    }
    return $false        # 本来就存在
}

# ── 模式 ①：任意目录 ──────────────────────────────────────────────────────
if ($PSCmdlet.ParameterSetName -eq 'Dir') {
    $rel = $Dir -replace '/', '\'
    if ([IO.Path]::IsPathRooted($rel)) { throw "-Dir 要写相对路径（相对工作根），收到绝对路径：$Dir" }
    $full = Join-Path $Root $rel
    # 逐级建，但只报"最终那层是不是新建的"
    $created = EnsureDir $full
    $tag = if ($created) { 'CREATED' } else { 'EXISTS' }
    "  目录  : $full"
    "$tag`t$full"
    exit 0
}

# ── 模式 ②：资产（自动编号 + 幂等） ───────────────────────────────────────
$assetsRoot = Join-Path $Root '00_assets'
EnsureDir $assetsRoot | Out-Null

# 模糊匹配类型目录
$typeDir = $null
if (Test-Path -LiteralPath (Join-Path $assetsRoot $Asset)) {
    $typeDir = Join-Path $assetsRoot $Asset
} else {
    $cand = Get-ChildItem -LiteralPath $assetsRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $Asset -or $_.Name -like "*_$Asset" -or $_.Name -like "*$Asset*" }
    if ($cand.Count -eq 1) { $typeDir = $cand[0].FullName }
    elseif ($cand.Count -gt 1) {
        throw "类型 `"$Asset`" 匹配到多个：$(($cand.Name) -join ', ')。请写全名。"
    } else {
        # 没有该类型 → 按需新建，编号取下一个空位
        $used = Get-ChildItem -LiteralPath $assetsRoot -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { if ($_.Name -match '^(\d{2})_') { [int]$Matches[1] } }
        $next = 1
        while ($used -contains $next) { $next++ }
        $typeName = "{0:D2}_{1}" -f $next, $Asset
        $typeDir = Join-Path $assetsRoot $typeName
        EnsureDir $typeDir | Out-Null
        "  ⚠️  类型目录原本不存在，已按需新建：$typeName"
    }
}

# 幂等：已有同名资产就直接返回（不新建第二个）
$existing = Get-ChildItem -LiteralPath $typeDir -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{4}_(.+)$' -and $Matches[1] -eq $Name }
if ($existing) {
    $assetDir = $existing[0].FullName
    $tag = 'EXISTS'
} else {
    $used = Get-ChildItem -LiteralPath $typeDir -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { if ($_.Name -match '^(\d{4})_') { [int]$Matches[1] } }
    $next = 1
    while ($used -contains $next) { $next++ }
    $assetDir = Join-Path $typeDir ("{0:D4}_{1}" -f $next, $Name)
    EnsureDir $assetDir | Out-Null
    $tag = 'CREATED'
}

# 子目录：只建明确要用的
$made = @()
foreach ($s in $Sub) {
    if (-not $s) { continue }
    if (EnsureDir (Join-Path $assetDir $s)) { $made += $s }
}

"  资产  : $assetDir"
if ($made.Count) { "  子目录: $($made -join ', ')" }
"$tag`t$assetDir"
exit 0
