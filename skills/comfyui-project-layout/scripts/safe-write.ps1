#requires -Version 7
<#
.SYNOPSIS
  归档守卫：覆盖/更新任何文件之前，先把已存在的旧文件移进【同目录下的 old/】。

.DESCRIPTION
  本脚本固化的是这条项目规范：

      更新同名文件之前，必须先把旧文件移到 <该文件所在目录>/old/<原名>.<时间戳><扩展名>

  目的是让 old/ 里保留**完整历史**，随时可以：
    - 回滚到旧版本
    - 取旧文件当基准，在此基础上改出新版

  为什么带时间戳：如果 old/ 里也叫同一个名字，第二次更新就会把第一次的备份冲掉，
  等于白做。时间戳保证每一代都留得住。

  为什么不用「全局 archive 目录」：按你的要求，old/ 与文件**同级**，
  这样一次 mv/复制就能完成回滚，不需要跨树找文件。

  优先策略（重要）：
    正常迭代请用**版本递增**（-v001 → -v002），根本不覆盖 = 不需要归档。
    本脚本用于"确实必须替换同一路径文件"的场合（例如交给下游的固定文件名）。

.PARAMETER Path
  要被写入/更新的目标路径。可以是文件，也可以是目录。

.PARAMETER DryRun
  只报告会发生什么，不真的移动。

.PARAMETER Quiet
  只输出一行机器可读结果（供 Agent 解析），不打印人类可读说明。

.EXAMPLE
  # 写文件之前先调用它；无论它有没有移动东西，之后都照常写你的文件
  ./safe-write.ps1 "projects/demo/30_shots/010_intro/010_0010/30_key/010_0010-key-v001.png"
  # 输出示例：
  # ARCHIVED\tprojects/.../old/010_0010-key-v001.20261003-183012.png
  # NOOP\t\t(目标不存在，无需归档)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Path,

    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Say([string]$msg) { if (-not $Quiet) { Write-Host $msg } }

# ── 解析目标 ────────────────────────────────────────────────────────────────
$target = $Path
if (-not [System.IO.Path]::IsPathRooted($target)) {
    $target = Join-Path (Get-Location).Path $target
}
$target = [System.IO.Path]::GetFullPath($target)

if (-not (Test-Path -LiteralPath $target)) {
    if ($Quiet) { "NOOP`t(目标不存在，无需归档)" } else { Say "✅ 无需归档：目标不存在 → $target" }
    exit 0
}

$item    = Get-Item -LiteralPath $target -Force
$dir     = Split-Path -Parent $target
$oldDir  = Join-Path $dir 'old'
$leaf    = $item.Name
$stamp   = Get-Date -Format 'yyyyMMdd-HHmmss'

# 自我保护：目标是 old/ 目录本身时直接拒绝。
# 否则 $oldDir 会等于 $target，脚本会试图把目录移进它自己的子目录，抛出一个很难看懂的异常。
if ($item.PSIsContainer -and $leaf -eq 'old') {
    throw "拒绝归档：目标是 old/ 目录本身（$target）。归档的目的是保护历史，不是把历史搬走。"
}
if ([System.IO.Path]::GetFileName($dir) -eq 'old') {
    Write-Warning "目标已经在某个 old/ 里面（$dir）；继续会在其下再建一层 old/。确认这是你要的吗？"
}

if ($item.PSIsContainer) {
    $newName = "$leaf.$stamp"
} else {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($leaf)
    $ext  = [System.IO.Path]::GetExtension($leaf)
    $newName = "$base.$stamp$ext"
}

$dest = Join-Path $oldDir $newName

# 同一秒内重复调用也不冲突：加序号
$n = 1
while (Test-Path -LiteralPath $dest) {
    if ($item.PSIsContainer) { $newName = "$leaf.$stamp-$n" }
    else { $newName = "$base.$stamp-$n$ext" }
    $dest = Join-Path $oldDir $newName
    $n++
}

# ── 执行 ────────────────────────────────────────────────────────────────────
if ($DryRun) {
    if ($Quiet) { "DRYRUN`t$dest" } else { Say "🔎 [DryRun] 会把`n     $target`n   移到`n     $dest" }
    exit 0
}

New-Item -ItemType Directory -Force -Path $oldDir | Out-Null
Move-Item -LiteralPath $target -Destination $dest

# ── 连带归档可复现侧车 ──────────────────────────────────────────────────────
# 若旁边有 <base>.meta.json，必须跟着一起进 old/ 并保持**同名时间戳**，
# 否则新产物的侧车会把旧参数冲掉，old/ 里的旧图就失去"可当基准"的价值。
$archivedSidecar = $null
if (-not $item.PSIsContainer) {
    $sidecar = Join-Path $dir "$base.meta.json"
    if (Test-Path -LiteralPath $sidecar) {
        # 从**最终的 $dest** 派生 stem，保证与图片归档名严格配对。
        # 若从 $base.$stamp 重算，当图片因碰撞拿到 "-1" 后缀、而侧车恰好没碰撞时，两边 stem 会对不上。
        $archivedStem = [System.IO.Path]::GetFileNameWithoutExtension($dest)
        $sidecarDest  = Join-Path $oldDir "$archivedStem.meta.json"
        $m = 1
        while (Test-Path -LiteralPath $sidecarDest) {
            $sidecarDest = Join-Path $oldDir "$archivedStem-$m.meta.json"
            $m++
        }
        Move-Item -LiteralPath $sidecar -Destination $sidecarDest
        $archivedSidecar = $sidecarDest
    }
}

if ($Quiet) {
    "ARCHIVED`t$dest"
    if ($archivedSidecar) { "SIDECAR`t$archivedSidecar" }
} else {
    Say "📦 已归档旧文件"
    Say "   原位置 : $target"
    Say "   old/   : $dest"
    if ($archivedSidecar) { Say "   侧车   : $archivedSidecar  （保持同名时间戳，与新图配对）" }
    Say ""
    Say "   → 现在可以安全地写入新文件。回滚只要把它移回来即可："
    Say "     Move-Item -LiteralPath '$dest' -Destination '$target'"
    if ($archivedSidecar) {
        Say "     （若要连参数一起回滚，把侧车也移回 $dir\$base.meta.json）"
    }
}
exit 0
