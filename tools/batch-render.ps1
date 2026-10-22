#requires -Version 7
<#
.SYNOPSIS
    一次跑完「多个 ComfyUI 任务」—— 逐项提交、逐项等待、逐项收图，**中途不叫醒模型**。

.DESCRIPTION
    🔴 什么时候用：**同一个任务要出 ≥2 张图 / ≥2 条视频**（N 张变体、一组镜头、一组种子）。
    只有一张时用单任务流程（MCP 提交 + `wait-job.ps1`），不要用本脚本。

    为什么存在（本脚本要解决的两个浪费）：

      ① **每一次「模型被唤醒」都是钱。**
         逐张走「提交→等→唤醒→取图」的话，N 张就是 N 次唤醒、N 轮上下文重建。
         本脚本把 N 张压成**一次唤醒**：模型只在全部跑完后醒一次。

      ② **每张之间不清理显存，长批次会越跑越窄。**
         本脚本在每张之间调 `/free`（unload_models + free_memory），
         可选地执行一条重启命令把 ComfyUI **重新拉起**，让下一张从干净显存开始。

    与 MCP 的分工（重要，别搞混）：

      · **本脚本自己提交**（HTTP `POST /prompt`）、**自己等**（复用 `wait-job.ps1` 的事件流）、
        **自己下载产物**（HTTP `/view`）—— 整个批次 **0 次 MCP 调用**。
      · 这**不是**绕过 MCP：MCP 仍然是「查工具、拼工作流、调参、排错」的正路。
        本脚本只负责**已经定好的一批活**的批量执行。

    🔴 等待机制不变：每项仍由 `wait-job.ps1` 阻塞在 ComfyUI 的 WebSocket 上，
    **不设超时、不轮询、成功失败都由服务端事件判定**。

    一次运行的生命周期：

      读计划 → 逐项：提交 → 等（事件驱动）→ 收产物 → 清显存/重启 → 下一项
             → 全部结束 → 写报告 → 退出（**这时 DSH 才唤醒模型**）

    退出码（机器可读，末行是同义的一行文本）：

      0  BATCH_DONE     全部成功
      1  BATCH_PARTIAL  跑完了，但有项失败（默认不中断，继续跑完剩下的）
      2  BATCH_FAILED   一项都没成功，或计划/环境不合法
      3  中止           重启命令失败 / 服务没回来（批次提前终止）

.PARAMETER PlanPath
    计划文件（JSON）。见 `skills/comfyui-batch/SKILL.md` 的格式说明。核心结构：

        {
          "workflow": "02_env/workflows/qwen21_t2i.json",
          "seedAddress": "7.seed", "seedBase": 1000, "seedStep": 1,
          "items": [
            { "name": "shot0010_a", "params": { "6.text": "……", "9.filename_prefix": "shot0010_a" } },
            { "name": "shot0010_b", "params": { "6.text": "……" } }
          ]
        }

    路径（`workflow`）相对**计划文件所在目录**解析。
    `params` 的键是 `"<节点id>.<输入名>"`，值原样写进工作流 —— 不做任何猜测。

.PARAMETER OutDir
    给了就把每项的产物**下载**到这个目录（文件名前缀项名，避免重名）。
    不给就只记录文件名，产物仍在 ComfyUI 的 output 目录里。

.PARAMETER NoFree
    关掉「每项之间清显存」。默认开启。

.PARAMETER FreeWaitSeconds
    调 `/free` 之后，最多等多少秒让显存真的掉下来（默认 25）。等到就提前结束。

.PARAMETER RestartCommand
    🔴 真正的「重新拉起」：一条**同步**执行的命令行（例如停掉并重启 ComfyUI 的脚本）。
    每项之间执行一次，然后轮询 `/system_stats` 直到服务回来。
    不给则只做 `/free`（多数场景够用；重启只在显存真的碎片化时才需要）。

.PARAMETER RestartWaitSeconds
    重启后最多等多少秒让服务回来（默认 180）。超时 → 中止批次（退出码 3）。

.PARAMETER StopOnError
    任何一项失败就停（默认继续跑完剩下的，最后汇总）。

.PARAMETER DryRun
    只解析计划、打印每项最终参数，不提交任何任务。写计划后**先这样验一遍**。

.PARAMETER Quiet
    不打印过程，只输出末行机器可读结果。

.EXAMPLE
    # 先验计划
    ./batch-render.ps1 -PlanPath ./batch/plan.json -DryRun

    # 真跑（模型侧用 run_in_background 起，跑完 DSH 叫醒）
    ./batch-render.ps1 -PlanPath ./batch/plan.json -OutDir ./01_projects/ep01/.../30_key

    # 显存吃紧的模型：每项之间重启
    ./batch-render.ps1 -PlanPath ./batch/plan.json -RestartCommand 'pwsh -File C:\comfy\restart.ps1'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 1)]
    [string]$PlanPath,

    [string]$HostName = '127.0.0.1',
    [int]$Port = 8188,
    [string]$OutDir,

    [switch]$NoFree,
    [int]$FreeWaitSeconds = 25,

    # 每项之间是否**重启 ComfyUI**（换进程，显存回到初始值）
    [switch]$RestartEach,
    [switch]$NoRestart,
    [string]$RestartCommand,
    [int]$RestartWaitSeconds = 180,

    # 桌面状态栏（默认开；读状态文件，不参与渲染。-NoProgressWindow 关掉）
    [switch]$NoProgressWindow,

    # 单项也允许走批量（默认拒绝：单项该走单任务流程）
    [switch]$AllowSingle,

    [switch]$StopOnError,
    [switch]$DryRun,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$base = "http://${HostName}:${Port}"
$waitJob = Join-Path $PSScriptRoot 'wait-job.ps1'

function Say([string]$m) { if (-not $Quiet) { Write-Host $m } }
function Fail([string]$m, [int]$code) {
    Say "❌ $m"
    Write-Output "BATCH_FAILED`t$m"
    exit $code
}

# ── 计划 ──────────────────────────────────────────────────────────────────
if (-not (Test-Path $PlanPath)) { Fail "计划文件不存在：$PlanPath" 2 }
$PlanPath = (Resolve-Path $PlanPath).Path
$planDir = Split-Path $PlanPath -Parent

try {
    $plan = Get-Content $PlanPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Fail "计划文件不是合法 JSON：$($_.Exception.Message)" 2
}

$items = @($plan.items)
if ($items.Count -eq 0) { Fail "计划里没有 items" 2 }
if (-not $plan.workflow) { Fail "计划缺少 workflow（基础工作流路径）" 2 }

$baseWorkflowPath = if ([IO.Path]::IsPathRooted($plan.workflow)) { $plan.workflow }
                     else { Join-Path $planDir $plan.workflow }
if (-not (Test-Path $baseWorkflowPath)) { Fail "基础工作流不存在：$baseWorkflowPath" 2 }
$baseWorkflowText = Get-Content $baseWorkflowPath -Raw -Encoding UTF8

$freeBetween = -not $NoFree
if ($plan.freeBetween -eq $false) { $freeBetween = $false }

# ── 每项之间怎么复位显存 ───────────────────────────────────────────────────
# 默认：**重启 ComfyUI**（换进程，显存真正回到初始值，主模型能整块吃下显存）。
# 显式 -RestartEach 或 -RestartCommand 也算开；-NoRestart 改回只 /free。
$restartScript = Join-Path $PSScriptRoot 'comfy-restart.ps1'
$restartMode = $false
if ($NoRestart) {
    $restartMode = $false
} elseif ($RestartCommand -or $RestartEach) {
    $restartMode = $true
} elseif (Test-Path $restartScript) {
    $restartMode = $true        # 默认开：有重启器就用
}
if ($restartMode -and $RestartCommand) { $freeBetween = $false }   # 重启本身就是最强清理

# ── 进度状态（给桌面状态栏读，不占上下文）──────────────────────────────────
$progressPath = [IO.Path]::ChangeExtension($PlanPath, '.progress.json')
$progress = [ordered]@{
    plan         = $PlanPath
    total        = 0
    done         = 0
    ok           = 0
    failed       = 0
    currentIndex = 0
    current      = $null
    phase        = 'starting'
    statusText   = '准备中'
    startedAt    = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    totalSeconds = 0
}

function Save-Progress {
    try {
        $progress['totalSeconds'] = [math]::Round(([Diagnostics.Stopwatch]::GetTimestamp() - $script:startTs) / [Diagnostics.Stopwatch]::Frequency, 1)
    } catch { }
    try {
        $json = $progress | ConvertTo-Json -Depth 5 -Compress
        $tmp = "$progressPath.tmp"
        [IO.File]::WriteAllText($tmp, $json, (New-Object Text.UTF8Encoding $false))
        Move-Item $tmp $progressPath -Force
    } catch { }

    # 指针文件：给 DSH 界面里的浮层卡片用。
    # Host 半（plugin/batch-progress.js）只读这个固定位置的指针，不扫盘找工作根。
    try {
        $ptrDir = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)) 'dsh-comfy-batch'
        New-Item -ItemType Directory -Force -Path $ptrDir | Out-Null
        $ptrJson = @{
            statePath = $progressPath
            updatedAt = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
            plan      = $PlanPath
        } | ConvertTo-Json -Compress
        $ptmp = Join-Path $ptrDir 'active.tmp'
        [IO.File]::WriteAllText($ptmp, $ptrJson, (New-Object Text.UTF8Encoding $false))
        Move-Item $ptmp (Join-Path $ptrDir 'active.json') -Force
    } catch { }
}
$script:startTs = [Diagnostics.Stopwatch]::GetTimestamp()

$progressWindowProc = $null
function Start-ProgressWindow {
    if ($NoProgressWindow) { return }
    $pw = Join-Path $PSScriptRoot 'progress-window.ps1'
    if (-not (Test-Path $pw)) { return }
    try {
        # 用 cmd /c start /b 脱离本进程树 —— 否则批次结束时作业被清理，状态窗会一起消失，
        # 「全部完成 12/12」这个最终画面你就看不到了。
        $inner = "pwsh -STA -NoProfile -ExecutionPolicy Bypass -File `"$pw`" -StatePath `"$progressPath`""
        Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', "start `"`" /b $inner") -WindowStyle Hidden | Out-Null
    } catch { }
}

# ── 工具函数 ──────────────────────────────────────────────────────────────
function Get-VramFree {
    try {
        $s = Invoke-RestMethod "$base/system_stats" -TimeoutSec 5
        return [int64]$s.devices[0].vram_free
    } catch { return $null }
}

function Set-WorkflowParam {
    param($Workflow, [string]$Address, $Value)
    $dot = $Address.IndexOf('.')
    if ($dot -lt 1) { throw "参数地址必须是 '<节点id>.<输入名>'，收到：$Address" }
    $nodeId = $Address.Substring(0, $dot)
    $inputName = $Address.Substring($dot + 1)
    $node = $Workflow.$nodeId
    if ($null -eq $node) { throw "工作流里没有节点 $nodeId（地址 $Address）" }
    if ($null -eq $node.inputs) { throw "节点 $nodeId 没有 inputs（地址 $Address）" }
    $node.inputs | Add-Member -NotePropertyName $inputName -NotePropertyValue $Value -Force
}

function Submit-Prompt {
    param($Workflow, [string]$ClientId)
    $body = @{ prompt = $Workflow; client_id = $ClientId } | ConvertTo-Json -Depth 40 -Compress
    $resp = Invoke-RestMethod "$base/prompt" -Method Post -ContentType 'application/json; charset=utf-8' `
        -Body ([Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 30
    return $resp
}

function Get-HistoryEntry {
    param([string]$PromptId)
    try {
        $h = Invoke-RestMethod "$base/history/$PromptId" -TimeoutSec 10
        $keys = @($h.PSObject.Properties.Name)
        if ($keys.Count -gt 0) { return $h.$($keys[0]) }
    } catch { }
    return $null
}

# 从 history 里抠出人话错误：status.messages 是 [类型, 数据] 对，数据里可能带 exception_message。
# 只挑非空的，去重后拼一行 —— 不要 dump 整个对象（模型看了也没用，还占 token）。
function Get-ErrorDetail {
    param($Entry)
    if (-not $Entry) { return $null }
    $bits = @()
    $statusStr = [string]$Entry.status.status_str
    if ($statusStr -and $statusStr -ne 'success') { $bits += "status=$statusStr" }
    foreach ($m in @($Entry.status.messages)) {
        $arr = @($m)
        if ($arr.Count -ge 1 -and $arr[0]) { $bits += [string]$arr[0] }
        if ($arr.Count -ge 2 -and $arr[1]) {
            $d = $arr[1]
            if ($d -is [string]) { $bits += $d }
            elseif ($d.exception_message) { $bits += [string]$d.exception_message }
            elseif ($d.node_type) { $bits += "node=$($d.node_type)" }
        }
    }
    $clean = @($bits | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ } | Select-Object -Unique)
    if ($clean.Count -eq 0) { return $null }
    return ($clean -join ' · ')
}

# 产出条目：images / gifs / videos / audio 都收，形状统一成 {filename, subfolder, type}
function Get-OutputFiles {
    param($Entry)
    $files = @()
    if (-not $Entry -or -not $Entry.outputs) { return $files }
    foreach ($nodeId in @($Entry.outputs.PSObject.Properties.Name)) {
        $outs = $Entry.outputs.$nodeId
        foreach ($prop in @($outs.PSObject.Properties.Name)) {
            foreach ($f in @($outs.$prop)) {
                if ($f -and $f.filename) {
                    $files += [pscustomobject]@{
                        node      = $nodeId
                        kind      = $prop
                        filename  = [string]$f.filename
                        subfolder = [string]$f.subfolder
                        type      = if ($f.type) { [string]$f.type } else { 'output' }
                    }
                }
            }
        }
    }
    return $files
}

function Save-Outputs {
    param([string]$ItemName, $Files, [string]$Dir)
    $saved = @()
    foreach ($f in $Files) {
        $q = "filename=$([uri]::EscapeDataString($f.filename))&subfolder=$([uri]::EscapeDataString($f.subfolder))&type=$([uri]::EscapeDataString($f.type))"
        $dest = Join-Path $Dir ("{0}__{1}" -f $ItemName, $f.filename)
        try {
            Invoke-WebRequest "$base/view?$q" -OutFile $dest -TimeoutSec 300
            $saved += $dest
        } catch {
            Say "   ⚠️  下载失败 $($f.filename)：$($_.Exception.Message.Split([char]10)[0])"
        }
    }
    return $saved
}

function Reset-Vram {
    param([string]$Tag)
    $before = Get-VramFree
    try {
        $body = '{"unload_models":true,"free_memory":true}'
        Invoke-RestMethod "$base/free" -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 30 | Out-Null
    } catch {
        Say "   ⚠️  /free 调用失败：$($_.Exception.Message.Split([char]10)[0])"
        return
    }

    $deadline = (Get-Date).AddSeconds($FreeWaitSeconds)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Milliseconds 700
        $now = Get-VramFree
        if ($null -ne $now -and $null -ne $before -and $now -gt $before) { break }
        if ($null -eq $now) { continue }
    }
    $after = Get-VramFree
    if ($null -ne $before -and $null -ne $after) {
        Say ("   ♻️  {0}：显存 {1:N1} → {2:N1} GB 可用" -f $Tag, ($before / 1GB), ($after / 1GB))
        return ($after - $before)
    }
    Say "   ♻️  $Tag：已请求释放显存"
    return $null
}

function Restart-Comfy {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $progress['phase'] = 'restarting'
    $progress['statusText'] = '重启 ComfyUI'
    Save-Progress

    if ($RestartCommand) {
        Say "   🔄 重启 ComfyUI（自定义命令）：$RestartCommand"
        & pwsh -NoProfile -Command $RestartCommand | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "自定义重启命令退出码 $LASTEXITCODE" }
    } else {
        Say "   🔄 重启 ComfyUI（换进程，显存回到初始值）…"
        $out = & pwsh -NoProfile -File $restartScript -Port $Port -WaitSeconds $RestartWaitSeconds -Quiet 2>&1
        $code = $LASTEXITCODE
        if ($code -ne 0) {
            $tail = @($out | Where-Object { $_ -is [string] } | Select-Object -Last 2) -join ' / '
            throw "comfy-restart 失败（exit $code）：$tail"
        }
    }

    # 等 /system_stats 真的可用（自定义命令走这条；内置脚本已在内部等过）
    $deadline = (Get-Date).AddSeconds($RestartWaitSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Get-VramFree) {
            Say ("   ✅ ComfyUI 已就绪（{0:N1}s），可用显存 {1:N1} GB" -f $sw.Elapsed.TotalSeconds, ((Get-VramFree) / 1GB))
            return
        }
        Start-Sleep -Milliseconds 700
    }
    throw "重启后 ${RestartWaitSeconds}s 内 /system_stats 仍不可用"
}

# ── 解析每项（DryRun 也用这一份逻辑，保证「验过的就是跑的」）────────────────
function Resolve-Items {
    $resolved = @()
    $i = 0
    $seen = @{}
    foreach ($it in $items) {
        $i++
        $name = if ($it.name) { [string]$it.name } else { "item{i}" -replace '\{i\}', $i }
        if ($seen.ContainsKey($name)) { throw "items 里名字重复：$name（产物会互相覆盖）" }
        $seen[$name] = $true

        $wfPath = if ($it.workflow) {
            if ([IO.Path]::IsPathRooted($it.workflow)) { $it.workflow } else { Join-Path $planDir $it.workflow }
        } else { $baseWorkflowPath }
        if (-not (Test-Path $wfPath)) { throw "第 $i 项的工作流不存在：$wfPath" }

        $wf = Get-Content $wfPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $applied = [ordered]@{}

        if ($it.params) {
            foreach ($addr in @($it.params.PSObject.Properties.Name)) {
                Set-WorkflowParam -Workflow $wf -Address $addr -Value $it.params.$addr
                $applied[$addr] = $it.params.$addr
            }
        }

        # 种子便利机制：没在 params 里写种子的项，按 seedBase + (i-1)*seedStep 自动填
        if ($plan.seedAddress -and -not $applied.Contains([string]$plan.seedAddress)) {
            $baseSeed = if ($null -ne $plan.seedBase) { [int64]$plan.seedBase } else { 0 }
            $step = if ($null -ne $plan.seedStep) { [int64]$plan.seedStep } else { 1 }
            $seed = $baseSeed + ($i - 1) * $step
            Set-WorkflowParam -Workflow $wf -Address ([string]$plan.seedAddress) -Value $seed
            $applied[[string]$plan.seedAddress] = $seed
        }

        $resolved += [pscustomobject]@{
            index    = $i
            name     = $name
            workflow = $wfPath
            params   = $applied
            body     = $wf
        }
    }
    return $resolved
}

try {
    $resolved = Resolve-Items
} catch {
    Fail "计划解析失败：$($_.Exception.Message)" 2
}

# 🔴 单项护栏：先报结构错误（地址/路径/查重），再报这条策略 —— 别把真错误盖住。
#    一项就该走单任务流程（MCP 提交 + wait-job）：批量不会更省，还多一层进程和一个状态窗。
if ($resolved.Count -eq 1 -and -not $AllowSingle) {
    Fail "只有 1 项 —— 单项请走单任务流程（comfyui-mcp-ops + wait-job.ps1），不要用批量。确认要走请加 -AllowSingle" 2
}

# ── DryRun ────────────────────────────────────────────────────────────────
if ($DryRun) {
    Write-Output "🧪 干跑：共 $($resolved.Count) 项，不提交"
    Write-Output "   基础工作流：$baseWorkflowPath"
    if ($restartMode) {
        Write-Output ("   每项之间：重启 ComfyUI（{0}）" -f $(if ($RestartCommand) { '自定义命令' } else { 'comfy-restart.ps1 自动推断启动器' }))
    } else {
        Write-Output ("   每项之间清显存：{0}" -f $(if ($freeBetween) { '是（/free）' } else { '否' }))
    }
    Write-Output ("   桌面状态栏：{0}" -f $(if ($NoProgressWindow) { '关' } else { "开（$([IO.Path]::GetFileName($progressPath))）" }))
    Write-Output ("   进度文件：{0}" -f $progressPath)
    if (-not $OutDir) { Write-Output "   产物：只记录文件名（未给 -OutDir）" } else { Write-Output "   产物下载到：$OutDir" }
    foreach ($r in $resolved) {
        Write-Output ""
        Write-Output ("   [{0}/{1}] {2}" -f $r.index, $resolved.Count, $r.name)
        Write-Output ("      工作流：{0}" -f (Split-Path $r.workflow -Leaf))
        foreach ($k in $r.params.Keys) {
            $v = [string]$r.params[$k]
            if ($v.Length -gt 90) { $v = $v.Substring(0, 90) + '…' }
            Write-Output ("      {0} = {1}" -f $k, $v)
        }
    }
    Write-Output "BATCH_DRYRUN`titems=$($resolved.Count)"
    exit 0
}

# ── 环境自检 ──────────────────────────────────────────────────────────────
try { Invoke-RestMethod "$base/system_stats" -TimeoutSec 8 | Out-Null }
catch { Fail "连不上 ComfyUI（$base）：$($_.Exception.Message.Split([char]10)[0])" 2 }
if (-not (Test-Path $waitJob)) { Fail "找不到 wait-job.ps1（应与本脚本同目录）：$waitJob" 2 }
if ($OutDir) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

$total = $resolved.Count
Say "🚀 批次开始：$total 项$(if ($restartMode) { '，每项之间重启 ComfyUI' } elseif ($freeBetween) { '，每项之间清显存' })"

$batchSw = [Diagnostics.Stopwatch]::StartNew()
$results = @()
$ok = 0; $failCount = 0
$aborted = $false

# 进度：初始化 + 拉起状态栏（只读状态文件，不参与渲染）
$progress['total'] = $total
$progress['done'] = 0
$progress['ok'] = 0
$progress['failed'] = 0
$progress['phase'] = 'running'
$progress['statusText'] = '渲染中'
Save-Progress
Start-ProgressWindow

for ($idx = 0; $idx -lt $total; $idx++) {
    $r = $resolved[$idx]
    $label = "[$($idx + 1)/$total] $($r.name)"
    if ($aborted) {
        $results += [pscustomobject]@{ name = $r.name; status = 'SKIPPED'; seconds = 0; promptId = $null; files = @(); saved = @(); error = '批次已中止' }
        continue
    }

    $itemSw = [Diagnostics.Stopwatch]::StartNew()
    $clientId = [guid]::NewGuid().ToString()
    Say ""
    Say "▶ $label  提交中（工作流 $(Split-Path $r.workflow -Leaf)）"

    $progress['current'] = $r.name
    $progress['currentIndex'] = $idx + 1
    $progress['phase'] = 'running'
    $progress['statusText'] = '渲染中'
    Save-Progress

    $promptId = $null
    $status = 'FAILED'
    $errorText = $null
    $files = @()
    $saved = @()

    try {
        $resp = Submit-Prompt -Workflow $r.body -ClientId $clientId

        # node_errors / prompt_id 缺失 —— 提交阶段就被拒，不用等
        # ⚠️ 必须数 .PSObject.Properties（集合）而不是 .Name：空对象下 .Name 是 $null，
        #    而 @($null).Count 等于 1 —— 会把「没有错误」误判成「有错误」。
        $nodeErrors = $resp.node_errors
        if ($nodeErrors -and @($nodeErrors.PSObject.Properties).Count -gt 0) {
            $parts = @()
            foreach ($p in $nodeErrors.PSObject.Properties) {
                foreach ($e in @($p.Value.errors)) {
                    $msg = @($e.message, $e.type, $e.details) | Where-Object { $_ } | Select-Object -First 2
                    $parts += "[$($p.Name)] $($msg -join ' ')"
                }
            }
            throw "工作流校验失败：$($parts -join '; ')"
        }
        $promptId = [string]$resp.prompt_id
        if (-not $promptId) { throw "服务端没返回 prompt_id：$($resp | ConvertTo-Json -Depth 5 -Compress)" }

        Say "   prompt_id=$promptId  client_id=$($clientId.Substring(0,8))…  等待中（事件驱动，不设超时）"

        # 复用单任务等待器：同一个 client_id，事件才能定向送达
        $waitOut = & pwsh -NoProfile -File $waitJob -PromptId $promptId -ClientId $clientId -HostName $HostName -Port $Port -Quiet 2>&1
        $waitCode = $LASTEXITCODE
        $lastLine = @($waitOut | Where-Object { $_ -is [string] } | Select-Object -Last 1)
        $lastLine = if ($lastLine) { [string]$lastLine[0] } else { '' }
        $verdict = ($lastLine -split "`t")[0]

        if ($waitCode -eq 0 -and $verdict -eq 'DONE') {
            $status = 'DONE'
        } else {
            $entry = Get-HistoryEntry -PromptId $promptId
            $detail = Get-ErrorDetail -Entry $entry
            $errorText = (@($verdict, $detail) | Where-Object { $_ }) -join ' · '
            $status = if ($verdict -eq 'INTERRUPTED') { 'INTERRUPTED' } elseif ($verdict -eq 'TIMEOUT') { 'TIMEOUT' } else { 'FAILED' }
            Say "   ❌ $status：$errorText"
        }

        # 成功失败都尽量收产物（部分节点可能已经跑完并落盘）
        $entry = Get-HistoryEntry -PromptId $promptId
        $files = @(Get-OutputFiles -Entry $entry)
        if ($OutDir -and $files.Count -gt 0) {
            $saved = @(Save-Outputs -ItemName $r.name -Files $files -Dir $OutDir)
        }
        if ($files.Count -gt 0) {
            Say ("   📦 {0} 个产物{1}" -f $files.Count, $(if ($OutDir) { "，已下载 $($saved.Count) 个 → $OutDir" } else { '' }))
        }

    } catch {
        $errorText = $_.Exception.Message.Split([char]10)[0]
        $status = 'FAILED'
        Say "   ❌ FAILED：$errorText"
    }

    $itemSw.Stop()
    if ($status -eq 'DONE') { $ok++ } else { $failCount++ }
    $results += [pscustomobject]@{
        name     = $r.name
        status   = $status
        seconds  = [math]::Round($itemSw.Elapsed.TotalSeconds, 1)
        promptId = $promptId
        files    = @($files | ForEach-Object { if ($_.subfolder) { "$($_.subfolder)/$($_.filename)" } else { $_.filename } })
        saved    = @($saved)
        error    = $errorText
        params   = $r.params
    }
    Say ("   ⏱  {0}  ·  {1:N1}s  ·  累计 {2:N1}s" -f $status, $itemSw.Elapsed.TotalSeconds, $batchSw.Elapsed.TotalSeconds)

    $progress['done'] = $idx + 1
    $progress['ok'] = $ok
    $progress['failed'] = $failCount
    $progress['current'] = $null
    Save-Progress

    if ($status -ne 'DONE' -and $StopOnError) {
        Say "   ⛔ -StopOnError：停止批次"
        $aborted = $true
        continue
    }

    # 最后一项之后不清理（没有下一项要用显存）
    if ($idx -lt $total - 1) {
        if ($restartMode) {
            try { Restart-Comfy }
            catch {
                Say "   ⚠️ 重启失败：$($_.Exception.Message)"
                Say "   → 退回 /free 继续（下一项可能显存偏紧）"
                [void](Reset-Vram -Tag "清显存（重启失败兜底）")
            }
        } elseif ($freeBetween) {
            $progress['phase'] = 'freeing'
            $progress['statusText'] = '清显存'
            Save-Progress
            [void](Reset-Vram -Tag "清显存")
        }
    }
}

$batchSw.Stop()
$totalSeconds = [math]::Round($batchSw.Elapsed.TotalSeconds, 1)

# 终态写进进度（状态栏会显示最终结果并停在那里，方便你回看）
if ($aborted) { $progress['phase'] = 'aborted' }
elseif ($ok -eq $total) { $progress['phase'] = 'done' }
elseif ($ok -gt 0) { $progress['phase'] = 'partial' }
else { $progress['phase'] = 'failed' }
$progress['done'] = [Math]::Min($total, $ok + $failCount)
$progress['ok'] = $ok
$progress['failed'] = $failCount
$progress['current'] = $null
Save-Progress

# ── 报告 ──────────────────────────────────────────────────────────────────
$reportPath = [IO.Path]::ChangeExtension($PlanPath, '.result.json')
$report = [ordered]@{
    plan       = $PlanPath
    startedAt  = (Get-Date).AddSeconds(-$totalSeconds).ToString('yyyy-MM-dd HH:mm:ss')
    totalSeconds = $totalSeconds
    ok         = $ok
    failed     = $failCount
    total      = $total
    outDir     = $OutDir
    items      = $results
}
try {
    $report | ConvertTo-Json -Depth 8 | Set-Content -Path $reportPath -Encoding utf8
} catch { Say "⚠️  报告写入失败：$($_.Exception.Message)" }

Say ""
Say "════════ 批次结果 ════════"
foreach ($res in $results) {
    $marker = switch ($res.status) { 'DONE' { '✅' } 'SKIPPED' { '⏭ ' } default { '❌' } }
    Say ("  {0} {1,-22} {2,-11} {3,7:N1}s  {4}" -f $marker, $res.name, $res.status, $res.seconds, $(if ($res.error) { $res.error } else { "$(@($res.files).Count) 个产物" }))
}
Say ""
Say ("  成功 {0} / 失败 {1} / 共 {2}    总耗时 {3:N1}s（{4:N1} 分钟）" -f $ok, $failCount, $total, $totalSeconds, ($totalSeconds / 60))
if ($OutDir) { Say "  产物目录：$OutDir" }
Say "  报告：$reportPath"
Say ""
Say "  📌 模型侧只需要读这一屏 + 报告文件，不需要逐项 fetch_outputs。"

$machineOut = if ($ok -eq $total) { 'BATCH_DONE' } elseif ($ok -gt 0) { 'BATCH_PARTIAL' } else { 'BATCH_FAILED' }
Write-Output ("{0}`tok={1}`tfail={2}`ttotal={3}s`tout={4}`treport={5}" -f $machineOut, $ok, $failCount, $totalSeconds, $(if ($OutDir) { $OutDir } else { '-' }), $reportPath)

if ($aborted) { exit 3 }
if ($ok -eq $total) { exit 0 }
if ($ok -gt 0) { exit 1 }
exit 2