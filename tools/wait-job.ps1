#requires -Version 7
<#
.SYNOPSIS
    等待 ComfyUI 作业完成 —— **事件驱动（WebSocket），不是轮询**。

.DESCRIPTION
    🔴 本模式等待长任务的标准方式。**不要用模型反复调 MCP 去问，也不要用定时轮询。**

    为什么：MCP 是同步模型，comfy-mcp 不推进度（SEP-1686 的 Tasks 原语尚未进规范）。
    客户端要么阻塞到传输层超时，要么轮询 —— 而**让模型轮询是最贵的**。

    本脚本走 ComfyUI 自己的 **WebSocket（/ws）**：服务端**主动推**执行事件，
    本脚本阻塞在 socket 上等，**一个定时器都不用**。

    完整链路：

      ① 模型用 MCP 提交（run_workflow wait=false）→ prompt_id，秒回
      ② 模型用 run_in_background 起本脚本
      ③ 本脚本连 /ws，阻塞等这个 prompt_id 的完成事件（**服务端推，不是我们问**）
      ④ 事件到达 → 本脚本退出 → **DSH 主动通知模型**
      ⑤ 模型被唤醒后继续：fetch_outputs（MCP）→ 审查 → 落盘

    关于卡住：**默认不设超时。** 任务卡住就卡住 —— 本脚本一直等，
    由**人**决定要不要终止（kill 掉这个后台作业即可）。不重试、不放弃、不自作主张。

    边界（重要）：本脚本**只做"等待"**，不做任何"干活"的事。
      · 提交 / 校验 / 取产物 —— 一律走 MCP
      · 本脚本只监听 ComfyUI 的事件流判断"跑完没有"
    这不是绕过 MCP —— 它是**通知通道**，不是工作路径。

.PARAMETER PromptId
    作业的 prompt_id（run_workflow 的返回值）。

.PARAMETER ClientId
    🔴 **必须传** —— run_workflow 返回值里的 `client_id`。
    这是真推送能成立的关键：ComfyUI 的执行事件是**定向发送**的
    （源码 `execution.py`：`send_sync("executing", {...}, server.client_id)`），
    **只发给提交时用的那个 client_id**。用别的 id 连上去**一条事件都收不到**（实测验证过）。
    不传的话本脚本会警告并退化为轮询式兜底。

.PARAMETER TimeoutSeconds
    0 = 不设超时（默认，卡住就等人终止）。给了值才在到点时放弃。
    视频任务实测最长 3469 秒（58 分钟）—— 默认会一直等。

.PARAMETER HostName
    ComfyUI 地址，默认 127.0.0.1。

.PARAMETER Port
    端口，默认 8188。

.PARAMETER Quiet
    只输出末行机器可读结果。

.EXAMPLE
    # 后台等（推荐）—— 用 run_workflow 返回的 client_id，不设超时
    ./wait-job.ps1 -PromptId 0ef667b4-... -ClientId f58c0995-...

    # 前台等（调试）
    ./wait-job.ps1 -PromptId 0ef667b4-... -ClientId f58c0995-... -Quiet
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 1)]
    [string]$PromptId,

    [string]$ClientId,

    [int]$TimeoutSeconds = 0,
    [string]$HostName = '127.0.0.1',
    [int]$Port = 8188,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$base = "http://${HostName}:${Port}"
function Say([string]$m) { if (-not $Quiet) { Write-Host $m } }

$sw = [Diagnostics.Stopwatch]::StartNew()

# ── 竞态保护：连 WS 之前先查一次 history ──────────────────────────────────
# 任务可能在"提交"和"连上 WS"之间就跑完了。这不是轮询，只是一次竞态检查。
try {
    $h = Invoke-RestMethod "$base/history/$PromptId" -TimeoutSec 10
    $keys = @($h.PSObject.Properties.Name)
    if ($keys.Count -gt 0) {
        $e = $h.$($keys[0])
        $st = [string]$e.status.status_str
        $n = @($e.outputs.PSObject.Properties.Name).Count
        if ($e.status.completed -eq $true) {
            Say "✅ 作业已完成（连上 WS 前就结束了）"
            "DONE`t$PromptId`t$([math]::Round($sw.Elapsed.TotalSeconds,1))s`t${n}nodes"
            exit 0
        }
        if ($st -and $st -ne 'success') {
            Say "❌ 作业已结束但状态异常：$st"
            "FAILED`t$PromptId`t$st`t$([math]::Round($sw.Elapsed.TotalSeconds,1))s"
            exit 1
        }
    }
} catch { }

# ── 连 WebSocket ──────────────────────────────────────────────────────────
# 🔴 必须用**提交时那个 client_id** —— ComfyUI 的执行事件是定向发送的
#    （execution.py: send_sync("executing", {...}, server.client_id)），
#    用别的 id 连上去收不到任何执行事件。这是实测踩出来的。
if (-not $ClientId) {
    $ClientId = [guid]::NewGuid().ToString()
    Say "⚠️  没传 -ClientId —— ComfyUI 的执行事件是定向发的，随机 id 收不到事件。"
    Say "    请把 run_workflow 返回的 client_id 传进来。本次退化为「只查一次 history」的兜底。"
    $fallbackOnly = $true
} else {
    $fallbackOnly = $false
}

$uri = [Uri]"ws://${HostName}:${Port}/ws?clientId=$ClientId"
$ws = [System.Net.WebSockets.ClientWebSocket]::new()
$ws.Options.KeepAliveInterval = [TimeSpan]::FromSeconds(20)

try {
    $ws.ConnectAsync($uri, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
} catch {
    Say "❌ 连不上 WebSocket：$($_.Exception.Message.Split([char]10)[0])"
    "ERROR`t$PromptId`tws-connect-failed"
    exit 4
}

Say "⏳ 等待作业 $PromptId（client_id=$($ClientId.Substring(0,[Math]::Min(8,$ClientId.Length)))…，事件驱动$(if ($TimeoutSeconds) { "，超时 ${TimeoutSeconds}s" } else { '，不设超时' })）"

if ($fallbackOnly) {
    # 没有 client_id → 收不到事件。只能用"连上后定期看一眼 history"兜底。
    $deadline = if ($TimeoutSeconds -gt 0) { (Get-Date).AddSeconds($TimeoutSeconds) } else { [datetime]::MaxValue }
    while ((Get-Date) -lt $deadline) {
        try {
            $h = Invoke-RestMethod "$base/history/$PromptId" -TimeoutSec 10
            $k = @($h.PSObject.Properties.Name)
            if ($k.Count -gt 0 -and $h.$($k[0]).status.completed -eq $true) {
                $n = @($h.$($k[0]).outputs.PSObject.Properties.Name).Count
                Say "✅ 作业完成（兜底模式）"
                "DONE`t$PromptId`t$([math]::Round($sw.Elapsed.TotalSeconds,1))s`t${n}nodes"
                exit 0
            }
        } catch { }
        Start-Sleep -Seconds 5
    }
    Say "⏰ 超时（兜底模式）"
    "TIMEOUT`t$PromptId"
    exit 2
}

$buf = New-Object byte[] 262144
$sb = [System.Text.StringBuilder]::new()
$doneNodes = 0
$cached = $false
$deadline = if ($TimeoutSeconds -gt 0) { (Get-Date).AddSeconds($TimeoutSeconds) } else { [datetime]::MaxValue }

# 🔴 关键：ReceiveAsync 的任务**只能有一个在飞**。
#    早期版本每轮都新建 ReceiveAsync，一旦某轮 Wait 超时就留下一个悬挂的接收任务，
#    后续 ReceiveAsync 全部失效 —— 实测表现为"任务明明成功了却一条事件都收不到"。
#    正确做法：把 pending 任务存下来复用，消费掉之后才重建。
$pending = $null

try {
    while ($ws.State -eq 'Open') {

        if ((Get-Date) -ge $deadline) {
            Say "⏰ 超时（${TimeoutSeconds}s）"
            "TIMEOUT`t$PromptId`t$([math]::Round($sw.Elapsed.TotalSeconds,1))s"
            exit 2
        }

        if (-not $pending) {
            $seg = [ArraySegment[byte]]::new($buf)
            $pending = $ws.ReceiveAsync($seg, [Threading.CancellationToken]::None)
        }

        # 无超时模式 → 无限期阻塞等服务端推（这是真推送，不是轮询）
        # 有超时模式 → 分段等，但**复用同一个 pending**
        if ($TimeoutSeconds -gt 0) {
            if (-not $pending.Wait(1000)) {
                if ($ws.State -ne 'Open') { break }
                continue
            }
        } else {
            $pending.Wait()
        }

        $res = $pending.Result
        $pending = $null        # 已消费，下一轮重建

        if ($res.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
            Say "⚠️  WebSocket 被服务端关闭"
            break
        }
        if ($res.MessageType -ne [System.Net.WebSockets.WebSocketMessageType]::Text) { continue }

        [void]$sb.Append([Text.Encoding]::UTF8.GetString($buf, 0, $res.Count))
        if (-not $res.EndOfMessage) { continue }
        $raw = $sb.ToString(); [void]$sb.Clear()

        $m = $null
        try { $m = $raw | ConvertFrom-Json } catch { continue }
        $type = [string]$m.type
        $d = $m.data

        # 只关心我们这个 prompt_id 的事件
        if ($d -and $d.prompt_id -and $d.prompt_id -ne $PromptId) { continue }

        switch ($type) {
            'execution_start' {
                Say "   ▶ 开始执行"
            }
            'execution_cached' {
                $cached = $true
                Say "   ⚡ 部分节点命中缓存"
            }
            'progress' {
                # 有进度就报一次，但没有也不影响 —— 不依赖它
                if ($d.value -and $d.max -and ($d.value % 10 -eq 0)) {
                    Say "   … $($d.value)/$($d.max)"
                }
            }
            'executed' {
                if ($d.output) { $doneNodes += @($d.output.PSObject.Properties.Name).Count }
            }
            'executing' {
                # node 为 null 且 prompt_id 是我们的 → 这一轮执行结束
                if ($null -eq $d.node) {
                    $secs = [math]::Round($sw.Elapsed.TotalSeconds, 1)
                    Say "✅ 作业完成（耗时 ${secs}s，产出 $doneNodes 个节点$(if ($cached) { '，含缓存' }))"
                    Say "   → 下一步：mcp__comfymcp__fetch_outputs  prompt_id=$PromptId"
                    "DONE`t$PromptId`t${secs}s`t${doneNodes}nodes"
                    exit 0
                }
            }
            'execution_error' {
                $secs = [math]::Round($sw.Elapsed.TotalSeconds, 1)
                $msg = if ($d.exception_message) { $d.exception_message } else { 'unknown' }
                Say "❌ 执行出错：$msg（耗时 ${secs}s）"
                "FAILED`t$PromptId`t$msg`t${secs}s"
                exit 1
            }
            'execution_interrupted' {
                Say "⛔ 执行被中断"
                "INTERRUPTED`t$PromptId"
                exit 5
            }
        }
    }
} finally {
    try { if ($ws.State -eq 'Open') { $ws.CloseAsync('NormalClosure', '', [Threading.CancellationToken]::None).Wait(2000) | Out-Null } } catch { }
    $ws.Dispose()
}

# 循环退出但没拿到终态
Say "⚠️  连接结束但没收到完成事件 —— 用 MCP 查一次状态确认"
"UNKNOWN`t$PromptId"
exit 6
