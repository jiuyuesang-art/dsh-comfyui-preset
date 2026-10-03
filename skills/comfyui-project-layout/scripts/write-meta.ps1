#requires -Version 7
<#
.SYNOPSIS
  为产物写"可复现侧车"：<名>.meta.json，记录生成它所需的一切参数。

.DESCRIPTION
  专业管线里，一个镜头画面背后是完整的参数链。AI 生成同理——
  只有图，没有参数，就**无法取旧文件当基准重做**，也就谈不上回滚。

  所以规范要求：每产出一个图/视频，就在**同目录、同名、后缀换成 .meta.json** 写一份参数快照。

  固定字段（脚本自动填）：
    file / sizeBytes / sha256 / created
  由调用方提供的字段（写进 "params"，随生成方式而定）：
    prompt, negative, seed, steps, cfg, sampler, scheduler, width, height,
    model, lora, workflow, template, durationSec, frames, fps, sourceShot

.PARAMETER For
  产物文件路径（如 010_0010-key-v001.png）。侧车会写成 010_0010-key-v001.meta.json

.PARAMETER Json
  参数 JSON 字符串。与 -From 二选一。

.PARAMETER From
  参数 JSON 文件路径。与 -Json 二选一。

.PARAMETER Force
  侧车已存在时也覆盖（默认保留已有侧车，避免误伤历史）。

.EXAMPLE
  ./write-meta.ps1 -For "010_0010-key-v001.png" -Json '{"prompt":"雨夜街头","seed":42,"steps":25,"cfg":1.5}'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][string]$For,
    [string]$Json,
    [string]$From,
    [switch]$Force,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
function Say([string]$m) { if (-not $Quiet) { Write-Host $m } }

if (-not $Json -and -not $From) { throw "必须给 -Json 或 -From 之一。" }
if ($Json -and $From)          { throw "-Json 与 -From 只能给一个。" }

$target = $For
if (-not [System.IO.Path]::IsPathRooted($target)) { $target = Join-Path (Get-Location).Path $target }
$target = [System.IO.Path]::GetFullPath($target)

if (-not (Test-Path -LiteralPath $target)) {
    throw "产物不存在：$target（侧车必须针对真实存在的文件）"
}

$raw = if ($From) { Get-Content -LiteralPath $From -Raw -Encoding utf8 } else { $Json }
try { $params = $raw | ConvertFrom-Json -AsHashtable } catch { throw "参数 JSON 解析失败：$($_.Exception.Message)" }

$dir  = Split-Path -Parent $target
$base = [System.IO.Path]::GetFileNameWithoutExtension($target)
$sidecar = Join-Path $dir "$base.meta.json"

if ((Test-Path -LiteralPath $sidecar) -and -not $Force) {
    Say "ℹ️  侧车已存在，未覆盖：$sidecar（要覆盖请加 -Force）"
    if ($Quiet) { "EXISTS`t$sidecar" }
    exit 0
}

$item = Get-Item -LiteralPath $target
$sha  = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLower()

$out = [ordered]@{
    file      = $item.Name
    created   = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    sizeBytes = $item.Length
    sha256    = $sha
    params    = $params
}

$out | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $sidecar -Encoding utf8
Say "🧾 已写可复现侧车 → $sidecar"
Say "   sha256 : $($sha.Substring(0,16))…"
Say "   字段   : $(($params.Keys | Sort-Object) -join ', ')"
if ($Quiet) { "WROTE`t$sidecar" }
