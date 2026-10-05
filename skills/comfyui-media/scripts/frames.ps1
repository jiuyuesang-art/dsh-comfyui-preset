#requires -Version 7
<#
.SYNOPSIS
    视频处理：抽帧 / 联系表 / 探测信息 / 提取音轨。

.DESCRIPTION
    基于 ffmpeg。视频审查的标准做法是**抽帧看**（见 comfyui-review 手册），
    本脚本提供那一步需要的全部操作。

.PARAMETER Action
    info    探测时长/分辨率/帧率/编码/音轨
    frames  按间隔抽帧，或均匀抽 N 帧
    sheet   抽帧并直接拼成联系表（缩略图总览，最快看清整段）
    frame   取指定时间点的单帧
    audio   提取音轨为 wav/mp3

.EXAMPLE
    ./frames.ps1 -Action info   -Source clip.mp4
    ./frames.ps1 -Action sheet  -Source clip.mp4 -OutDir ./60_review -Count 12 -Cols 4
    ./frames.ps1 -Action frames -Source clip.mp4 -OutDir ./tmp -Every 1.0
    ./frames.ps1 -Action frame  -Source clip.mp4 -OutDir ./tmp -At 3.5
    ./frames.ps1 -Action audio  -Source clip.mp4 -OutDir ./50_audio -Format wav
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 1)]
    [ValidateSet('info', 'frames', 'sheet', 'frame', 'audio')]
    [string]$Action,

    [Parameter(Mandatory, Position = 2)]
    [string]$Source,

    [string]$OutDir = '.',
    [double]$Every = 1.0,
    [int]$Count = 12,
    [int]$Cols = 4,
    [int]$Cell = 384,
    [double]$At = 0,
    [ValidateSet('wav', 'mp3', 'flac')]
    [string]$Format = 'wav',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

# ── 找 ffmpeg ─────────────────────────────────────────────────────────────
function Resolve-Tool([string]$name) {
    $c = Get-Command $name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($p in @("C:\ffmpeg\bin\$name.exe", "$env:LOCALAPPDATA\Microsoft\WinGet\Links\$name.exe")) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    throw "找不到 $name。装 ffmpeg 或把它的 bin 加进 PATH。"
}
$FF = Resolve-Tool 'ffmpeg'
$FP = try { Resolve-Tool 'ffprobe' } catch { $null }

if (-not (Test-Path -LiteralPath $Source)) { throw "输入不存在：$Source" }
$Source = (Resolve-Path -LiteralPath $Source).Path
$stem = [IO.Path]::GetFileNameWithoutExtension($Source)

function EnsureDir([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Force -Path $p | Out-Null }
    return (Resolve-Path -LiteralPath $p).Path
}

function Invoke-FF([string[]]$ffArgs) {
    $out = & $FF @ffArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "ffmpeg 失败（exit $LASTEXITCODE）：`n" + (($out | Select-Object -Last 8) -join "`n")
    }
    return $out
}

# ── info ──────────────────────────────────────────────────────────────────
if ($Action -eq 'info') {
    if (-not $FP) { throw 'info 需要 ffprobe' }
    $j = & $FP -v quiet -print_format json -show_format -show_streams $Source 2>&1 | Out-String
    $d = $j | ConvertFrom-Json
    $v = $d.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
    $a = $d.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1

    "文件     : $Source"
    "体积     : {0:N2} MB" -f ([double]$d.format.size / 1MB)
    "时长     : {0:N2} 秒" -f [double]$d.format.duration
    if ($v) {
        "视频     : {0}×{1}  {2}  {3} fps  编码 {4}" -f $v.width, $v.height, $v.pix_fmt, $v.r_frame_rate, $v.codec_name
    }
    if ($a) {
        "音频     : {0} Hz  {1} 声道  编码 {2}" -f $a.sample_rate, $a.channels, $a.codec_name
    }
    else { "音频     : 无音轨" }
    exit 0
}

# ── frame（单帧） ─────────────────────────────────────────────────────────
if ($Action -eq 'frame') {
    $dir = EnsureDir $OutDir
    $out = Join-Path $dir ("{0}-t{1:N2}.png" -f $stem, $At)
    if ((Test-Path -LiteralPath $out) -and -not $Force) { throw "已存在，拒绝覆盖：$out（加 -Force 才覆盖）" }
    Invoke-FF @('-y', '-ss', "$At", '-i', $Source, '-frames:v', '1', $out) | Out-Null
    "✅ $out"
    exit 0
}

# ── frames / sheet（抽帧） ────────────────────────────────────────────────
if ($Action -in 'frames', 'sheet') {
    $dir = EnsureDir $OutDir

    if ($Action -eq 'sheet') {
        # 均匀抽 Count 帧 → 直接拼联系表（最快看清整段）
        if (-not $FP) { throw 'sheet 需要 ffprobe' }
        $dur = [double](& $FP -v quiet -show_entries format=duration -of csv=p=0 $Source 2>&1 | Select-Object -First 1)
        if ($dur -le 0) { throw "拿不到时长" }
        $tmp = Join-Path $dir ("_frames_{0}" -f $stem)
        EnsureDir $tmp | Out-Null
        # 每 dur/Count 秒取一帧
        $step = [Math]::Max(0.04, $dur / $Count)
        Invoke-FF @('-y', '-i', $Source, '-vf', "fps=1/$step", '-frames:v', "$Count", (Join-Path $tmp 'f%03d.png')) | Out-Null

        $frames = Get-ChildItem -LiteralPath $tmp -Filter 'f*.png' | Sort-Object Name
        "  抽到 $($frames.Count) 帧（时长 $([Math]::Round($dur,2))s，每 $([Math]::Round($step,2))s 一帧）"

        $rows = [Math]::Ceiling($frames.Count / $Cols)
        $W = $Cols * $Cell
        $H = $rows * $Cell
        $out = Join-Path $dir ("{0}-sheet.png" -f $stem)
        if ((Test-Path -LiteralPath $out) -and -not $Force) {
            Remove-Item $tmp -Recurse -Force
            throw "已存在，拒绝覆盖：$out（加 -Force 才覆盖）"
        }
        # 用 tile 滤镜拼图
        Invoke-FF @('-y', '-i', (Join-Path $tmp 'f%03d.png'),
                    '-vf', "scale=$Cell`:$Cell`:force_original_aspect_ratio=decrease,pad=$Cell`:$Cell`:(ow-iw)/2:(oh-ih)/2:color=0x18181c,tile=$Cols`x$rows",
                    '-frames:v', '1', $out) | Out-Null
        Remove-Item $tmp -Recurse -Force
        "✅ $out  ($W×$H, $Cols 列 × $rows 行)"
        exit 0
    }

    # frames：按间隔导出全部帧
    $out = Join-Path $dir ("{0}-f%04d.png" -f $stem)
    $existing = Get-ChildItem -LiteralPath $dir -Filter ("{0}-f*.png" -f $stem) -ErrorAction SilentlyContinue
    if ($existing -and -not $Force) { throw "目录里已有 $($existing.Count) 张同名帧（加 -Force 才覆盖）：$dir" }
    Invoke-FF @('-y', '-i', $Source, '-vf', "fps=1/$Every", $out) | Out-Null
    $n = (Get-ChildItem -LiteralPath $dir -Filter ("{0}-f*.png" -f $stem)).Count
    "✅ 导出 $n 帧 → $dir（每 $Every 秒一帧）"
    exit 0
}

# ── audio（提取音轨） ─────────────────────────────────────────────────────
if ($Action -eq 'audio') {
    $dir = EnsureDir $OutDir
    $out = Join-Path $dir ("{0}.{1}" -f $stem, $Format)
    if ((Test-Path -LiteralPath $out) -and -not $Force) { throw "已存在，拒绝覆盖：$out（加 -Force 才覆盖）" }
    $codec = switch ($Format) { 'wav' { 'pcm_s16le' } 'mp3' { 'libmp3lame' } 'flac' { 'flac' } }
    Invoke-FF @('-y', '-i', $Source, '-vn', '-acodec', $codec, $out) | Out-Null
    "✅ $out"
    exit 0
}
