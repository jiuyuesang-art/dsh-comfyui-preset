#requires -Version 7
<#
.SYNOPSIS
    把 ComfyUI 停掉再拉起来 —— 让下一个任务从**整块显存**开始。

.DESCRIPTION
    为什么需要它：12GB 卡上连续跑不同模型/分辨率，`/free` 之后显存往往**没有完全回到初始值**
    （碎片、CUDA 上下文、缓存分配器各留一点）。批量渲染要让「主模型完全跑在显存上」，
    最彻底的办法是**换一个进程** —— 本脚本就是把这件事做成一条命令。

    做的事（三步，都带兜底）：

      ① 找到监听端口的进程 → 停掉（连同它的子进程）
      ② 等端口空出来；若外部管理器自己把它拉起来了（EasyManager 之类会这么做），直接采用它
      ③ 端口仍空 → 用启动器拉起新进程（输出重定向到日志），等 `/system_stats` 可用

    🔴 **不会猜你的安装方式**：启动器按这个顺序确定

      1. `-Launcher` 显式传入
      2. 从在跑的进程反推：`<envs 的上一级>\start_latest.ps1`（EasyManager 布局）
      3. 同目录的 `start_latest.bat`
      4. 用原命令行重建：`python main.py <原参数>`（工作目录按 main.py 定位）

    都对不上就**明确报错**，让你传 `-Launcher` —— 不瞎启动。

.PARAMETER Port
    ComfyUI 端口，默认 8188。

.PARAMETER Launcher
    启动脚本路径（.ps1 / .bat）。不传则自动推断。

.PARAMETER WaitSeconds
    等新进程可用的上限，默认 180 秒（大模型加载慢，别设太小）。

.PARAMETER StopWaitSeconds
    停掉之后等端口空出来的时间，默认 15 秒（绕开外部管理器的自动重启）。

.PARAMETER LogDir
    新进程的 stdout/stderr 落盘目录，默认系统临时目录下的 `comfy-restart/`。

.PARAMETER Quiet
    只输出末行。

.EXAMPLE
    ./comfy-restart.ps1
    ./comfy-restart.ps1 -Port 8188 -Launcher 'C:\comfy\start_latest.ps1'
#>
[CmdletBinding()]
param(
    [int]$Port = 8188,
    [string]$Launcher,
    [int]$WaitSeconds = 180,
    [int]$StopWaitSeconds = 15,
    [string]$LogDir,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$base = "http://127.0.0.1:$Port"
function Say([string]$m) { if (-not $Quiet) { Write-Host $m } }

# ── 探测 ──────────────────────────────────────────────────────────────────
function Get-Listener {
    $c = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $c) { return $null }
    $p = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
    $ci = Get-CimInstance Win32_Process -Filter "ProcessId=$($c.OwningProcess)" -ErrorAction SilentlyContinue
    return [pscustomobject]@{
        Pid         = $c.OwningProcess
        Name        = if ($p) { $p.ProcessName } else { '?' }
        CommandLine = if ($ci) { [string]$ci.CommandLine } else { '' }
        ExePath     = if ($ci) { [string]$ci.ExecutablePath } else { '' }
    }
}

function Test-Up {
    try {
        $s = Invoke-RestMethod "$base/system_stats" -TimeoutSec 3
        return [bool]$s.devices
    } catch { return $false }
}

function Resolve-Launcher {
    param($Listener)
    if ($Launcher) {
        if (-not (Test-Path $Launcher)) { throw "指定的启动器不存在：$Launcher" }
        return (Resolve-Path $Launcher).Path
    }
    # EasyManager 之类的布局：envs\comfyui\python.exe 的上一级 = 安装根
    if ($Listener -and $Listener.CommandLine) {
        $m = [regex]::Match($Listener.CommandLine, '"?([A-Za-z]:\\[^"]*?)\\envs\\[^\\]+\\(pythonw?)\.exe"?')
        if ($m.Success) {
            $root = $m.Groups[1].Value
            foreach ($cand in @('start_latest.ps1', 'start_latest.bat', 'start.ps1', 'start.bat')) {
                $p = Join-Path $root $cand
                if (Test-Path $p) { return $p }
            }
        }
    }
    return $null
}

# 重建启动命令：python.exe + main.py + 原参数
function Resolve-CommandLine {
    param($Listener)
    if (-not $Listener -or -not $Listener.CommandLine) { return $null }
    $m = [regex]::Match($Listener.CommandLine, '^\s*"?([A-Za-z]:\\[^"]*?pythonw?\.exe)"?\s+(.*)$')
    if (-not $m.Success) { return $null }
    $python = $m.Groups[1].Value
    $rest = $m.Groups[2].Value
    if (-not (Test-Path $python)) { return $null }

    # main.py 的目录：从 python 位置推 ComfyUI 目录
    $exeDir = Split-Path $python -Parent
    $root = Split-Path (Split-Path $exeDir -Parent) -Parent
    $comfyDir = Join-Path $root 'ComfyUI'
    if (-not (Test-Path (Join-Path $comfyDir 'main.py'))) {
        # 退一步：python 同级找 main.py
        if (Test-Path (Join-Path $exeDir 'main.py')) { $comfyDir = $exeDir } else { return $null }
    }
    return [pscustomobject]@{ File = $python; Args = $rest; WorkingDirectory = $comfyDir }
}

# ── 主流程 ────────────────────────────────────────────────────────────────
$sw = [Diagnostics.Stopwatch]::StartNew()
$listener = Get-Listener

if (-not $listener) {
    Say "ℹ️  端口 $Port 上没有进程 —— 直接拉起"
} else {
    Say "🔻 停止 ComfyUI（PID $($listener.Pid)）"
    try { Stop-Process -Id $listener.Pid -Force -ErrorAction Stop }
    catch { Say "   ⚠️ 停止失败：$($_.Exception.Message)"; }

    # 等端口空出来；外部管理器可能抢着重启它
    $deadline = (Get-Date).AddSeconds($StopWaitSeconds)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 400
        $now = Get-Listener
        if (-not $now) { break }
        if ($now.Pid -ne $listener.Pid) {
            # 换了 PID = 外部已重启。等它就绪即可，不再自己拉。
            Say "   ↻ 外部管理器已重启（新 PID $($now.Pid)），采用它"
            $waitUntil = (Get-Date).AddSeconds($WaitSeconds)
            while ((Get-Date) -lt $waitUntil) {
                if (Test-Up) {
                    $secs = [math]::Round($sw.Elapsed.TotalSeconds, 1)
                    Say "   ✅ 已就绪（${secs}s，外部重启）"
                    "RESTART_OK`tpid=$($now.Pid)`t${secs}s`texternal"
                    exit 0
                }
                Start-Sleep -Milliseconds 700
            }
            Say "   ❌ 外部重启后 ${WaitSeconds}s 内没就绪"
            "RESTART_FAILED`texternal-not-ready"
            exit 1
        }
    }
    if (Get-Listener) { Say "   ⚠️ 端口仍被占用" } else { Say "   ✅ 端口已释放" }
}

if (-not $LogDir) { $LogDir = Join-Path ([IO.Path]::GetTempPath()) 'comfy-restart' }
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outLog = Join-Path $LogDir "comfy-$stamp.out.log"
$errLog = Join-Path $LogDir "comfy-$stamp.err.log"

$launcherPath = Resolve-Launcher -Listener $listener

# 🔴 必须脱离调用者的进程树：批量渲染跑在 DSH 的后台作业里，
#    若新 ComfyUI 是该作业的子进程，作业一结束 ComfyUI 会被一起带走。
#
# 实测结论（本机 2026-10-22）：
#   · Win32_Process.Create  —— 返回 8/9（PATH/引号问题），不可靠，弃用
#   · Start-Process 直接拉   —— 随父作业一起没了
#   · cmd /c start "" /b …  —— ✅ 能活下来（start 创建新进程组，cmd 立即退出）
# 所以用最后一种。代价：拿不到子进程 PID，只能靠「端口是否起来」判断成败。
function Start-Detached {
    param([string]$Inner, [string]$WorkDir)
    $wrapped = "start `"`" /b $Inner > `"$outLog`" 2> `"$errLog`""
    if ($WorkDir) {
        Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', $wrapped) -WorkingDirectory $WorkDir -WindowStyle Hidden | Out-Null
    } else {
        Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', $wrapped) -WindowStyle Hidden | Out-Null
    }
}

if ($launcherPath) {
    Say "▶ 用启动器拉起：$launcherPath"
    $ext = [IO.Path]::GetExtension($launcherPath).ToLower()
    $inner = if ($ext -eq '.ps1') {
        "pwsh -NoProfile -ExecutionPolicy Bypass -File `"$launcherPath`" $Port"
    } else {
        "`"$launcherPath`" $Port"
    }
    Start-Detached -Inner $inner -WorkDir (Split-Path $launcherPath -Parent)
} else {
    $cmd = Resolve-CommandLine -Listener $listener
    if (-not $cmd) {
        Say "❌ 找不到启动器，也无法从原进程重建启动命令。"
        Say "   请显式指定：-Launcher <你的 start.ps1 / start.bat>"
        "RESTART_FAILED`tno-launcher"
        exit 1
    }
    Say "▶ 用原命令行重建：$($cmd.File) $($cmd.Args)（cwd=$($cmd.WorkingDirectory)）"
    Start-Detached -Inner "`"$($cmd.File)`" $($cmd.Args)" -WorkDir $cmd.WorkingDirectory
}

Say "   日志：$outLog"
Say "   等待 /system_stats 可用（上限 ${WaitSeconds}s）…"

$deadline = (Get-Date).AddSeconds($WaitSeconds)
while ((Get-Date) -lt $deadline) {
    if (Test-Up) {
        $secs = [math]::Round($sw.Elapsed.TotalSeconds, 1)
        Say "   ✅ 已就绪（${secs}s）"
        "RESTART_OK`tpid=0`t${secs}s`tspawned"
        exit 0
    }
    Start-Sleep -Milliseconds 700
}

Say "   ❌ ${WaitSeconds}s 内没就绪。日志尾部："
Get-Content $outLog -Tail 12 -ErrorAction SilentlyContinue | ForEach-Object { Say "      $_" }
Get-Content $errLog -Tail 12 -ErrorAction SilentlyContinue | ForEach-Object { Say "      $_" }
"RESTART_FAILED`ttimeout"
exit 1

Say "   ❌ ${WaitSeconds}s 内没就绪；日志：$outLog"
"RESTART_FAILED`ttimeout"
exit 1
