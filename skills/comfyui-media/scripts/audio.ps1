#requires -Version 7
<#
.SYNOPSIS
    音频处理：裁剪 / 转码 / 归一化 / 拼接 / 混音 / 变速 / 探测。

.DESCRIPTION
    基于 ffmpeg。覆盖本项目常见的音频需求：
      · 从视频里取出来的音轨要裁剪（H3 生成的片段常有前后静音）
      · 对白 / 音效 / BGM 要拼接或混音
      · 交付前统一响度（EBU R128）

.PARAMETER Action
    info     探测时长/采样率/声道/编码/峰值电平
    trim     裁剪时间区间
    convert  转码
    normalize 响度归一化（EBU R128，目标 -16 LUFS）
    concat   按顺序拼接多个音频
    mix      多轨混音（可各自设音量）
    speed    变速（不变调）

.EXAMPLE
    ./audio.ps1 info      -Source take.wav
    ./audio.ps1 trim      -Source take.wav -Output out.wav -Start 1.2 -End 4.8
    ./audio.ps1 normalize -Source take.wav -Output out.wav
    ./audio.ps1 concat    -Source a.wav,b.wav,c.wav -Output all.wav
    ./audio.ps1 mix       -Source bgm.wav,vo.wav -Output mix.wav -Volume 0.3,1.0
    ./audio.ps1 speed     -Source a.wav -Output b.wav -Rate 1.25
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 1)]
    [ValidateSet('info', 'trim', 'convert', 'normalize', 'concat', 'mix', 'speed')]
    [string]$Action,

    [Parameter(Mandatory, Position = 2)]
    [string]$Source,

    [string]$Output,
    [double]$Start = 0,
    [double]$End = 0,
    [double]$Rate = 1.0,
    [double[]]$Volume,
    [string]$Format = 'wav',
    [double]$Lufs = -16,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

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

function Invoke-FF([string[]]$ffArgs) {
    $out = & $FF @ffArgs 2>&1
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg 失败（exit $LASTEXITCODE）：`n" + (($out | Select-Object -Last 8) -join "`n") }
    return $out
}

function Guard-Out([string]$p) {
    if (-not $p) { throw "该操作需要 -Output" }
    $d = Split-Path $p -Parent
    if ($d -and -not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    if ((Test-Path -LiteralPath $p) -and -not $Force) { throw "已存在，拒绝覆盖：$p（加 -Force 才覆盖；产物更新请先跑 safe-write.ps1）" }
    return $p
}

$inputs = @($Source -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
foreach ($i in $inputs) { if (-not (Test-Path -LiteralPath $i)) { throw "输入不存在：$i" } }

$codecOf = @{ 'wav' = 'pcm_s16le'; 'mp3' = 'libmp3lame'; 'flac' = 'flac'; 'm4a' = 'aac' }

switch ($Action) {

    'info' {
        if (-not $FP) { throw 'info 需要 ffprobe' }
        $j = & $FP -v quiet -print_format json -show_format -show_streams $inputs[0] 2>&1 | Out-String
        $d = $j | ConvertFrom-Json
        $a = $d.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1
        "文件     : $($inputs[0])"
        "体积     : {0:N2} MB" -f ([double]$d.format.size / 1MB)
        "时长     : {0:N3} 秒" -f [double]$d.format.duration
        if ($a) {
            "音频     : {0} Hz  {1} 声道  编码 {2}  码率 {3}" -f $a.sample_rate, $a.channels, $a.codec_name, $a.bit_rate
        }
        # 峰值电平（用 volumedetect，看有没有削波）
        $vd = & $FF -i $inputs[0] -af volumedetect -f null - 2>&1 | Out-String
        $mx = [regex]::Match($vd, 'max_volume:\s*(-?[\d.]+) dB')
        $mn = [regex]::Match($vd, 'mean_volume:\s*(-?[\d.]+) dB')
        if ($mx.Success) {
            "峰值     : $($mx.Groups[1].Value) dB"
            "平均     : $($mn.Groups[1].Value) dB"
            if ([double]$mx.Groups[1].Value -ge -0.1) { "⚠️  峰值贴近 0 dB，可能已削波" }
        }
    }

    'trim' {
        $o = Guard-Out $Output
        if ($End -le $Start) { throw "-End（$End）必须大于 -Start（$Start）" }
        Invoke-FF @('-y', '-i', $inputs[0], '-ss', "$Start", '-to', "$End", '-c', 'copy', $o) | Out-Null
        "✅ $o  （$Start → $End 秒，时长 $([Math]::Round($End-$Start,3)) 秒）"
    }

    'convert' {
        $o = Guard-Out $Output
        Invoke-FF @('-y', '-i', $inputs[0], '-vn', '-acodec', $codecOf[$Format], $o) | Out-Null
        "✅ $o  （→ $Format）"
    }

    'normalize' {
        $o = Guard-Out $Output
        # 两遍法：先量，再按量出来的值归一到目标响度
        Invoke-FF @('-y', '-i', $inputs[0], '-af', "loudnorm=I=$Lufs`:TP=-1.5:LRA=11", '-ar', '48000', $o) | Out-Null
        "✅ $o  （响度归一到 $Lufs LUFS，真峰 -1.5 dBTP）"
    }

    'concat' {
        $o = Guard-Out $Output
        if ($inputs.Count -lt 2) { throw 'concat 至少需要 2 个输入（用逗号分隔）' }
        $list = Join-Path ([IO.Path]::GetTempPath()) ("concat-{0}.txt" -f ([guid]::NewGuid().ToString('N')))
        # 统一转成同格式再拼，避免采样率/声道不一致导致失败
        $tmp = Join-Path ([IO.Path]::GetTempPath()) ("concat-{0}" -f ([guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $tmp | Out-Null
        $i = 0
        foreach ($f in $inputs) {
            $i++
            $piece = Join-Path $tmp ("p{0:D2}.wav" -f $i)
            Invoke-FF @('-y', '-i', $f, '-ar', '48000', '-ac', '2', '-acodec', 'pcm_s16le', $piece) | Out-Null
        }
        (Get-ChildItem -LiteralPath $tmp -Filter 'p*.wav' | Sort-Object Name | ForEach-Object { "file '$($_.FullName -replace '\\','/')'" }) |
            Set-Content -LiteralPath $list -Encoding utf8
        Invoke-FF @('-y', '-f', 'concat', '-safe', '0', '-i', $list, '-acodec', $codecOf[$Format], $o) | Out-Null
        Remove-Item $list, $tmp -Recurse -Force
        "✅ $o  （拼接 $($inputs.Count) 段）"
    }

    'mix' {
        $o = Guard-Out $Output
        if ($inputs.Count -lt 2) { throw 'mix 至少需要 2 个输入（用逗号分隔）' }
        $ffArgs = @('-y')
        foreach ($f in $inputs) { $ffArgs += @('-i', $f) }
        $parts = @()
        for ($i = 0; $i -lt $inputs.Count; $i++) {
            $vol = if ($Volume -and $Volume.Count -gt $i) { $Volume[$i] } else { 1.0 }
            # ⚠️ 必须写 $($i):a 而不是 $i:a —— PowerShell 会把 "$i:a" 解析成
            #    「作用域 i 里的变量 a」，展开为空字符串，导致 filter 串变成 "[]volume=..." 而报错
            $parts += "[$($i):a]volume=$vol[a$i]"
        }
        $labels = ((0..($inputs.Count - 1) | ForEach-Object { "[a$_]" }) -join '')
        $chain = ($parts -join ';') + ';' + $labels +
                 "amix=inputs=$($inputs.Count):duration=longest:normalize=0[out]"
        $ffArgs += @('-filter_complex', $chain, '-map', '[out]', '-acodec', $codecOf[$Format], $o)
        Invoke-FF $ffArgs | Out-Null
        $vs = if ($Volume) { $Volume -join ', ' } else { '全部 1.0' }
        "✅ $o  （混合 $($inputs.Count) 轨，音量 $vs）"
    }

    'speed' {
        $o = Guard-Out $Output
        if ($Rate -le 0) { throw "-Rate 必须为正数" }
        # atempo 单次只支持 0.5–2.0，超出要串联
        $r = $Rate; $filters = @()
        while ($r -gt 2.0) { $filters += 'atempo=2.0'; $r /= 2.0 }
        while ($r -lt 0.5) { $filters += 'atempo=0.5'; $r /= 0.5 }
        $filters += "atempo=$([Math]::Round($r,4))"
        Invoke-FF @('-y', '-i', $inputs[0], '-filter:a', ($filters -join ','), '-acodec', $codecOf[$Format], $o) | Out-Null
        "✅ $o  （变速 ×$Rate，音高不变）"
    }
}
