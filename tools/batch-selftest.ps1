#requires -Version 7
<#
.SYNOPSIS
    batch-render.ps1 的离线干跑自检 —— 不需要 ComfyUI 在跑。

.DESCRIPTION
    只验证「计划解析」这一层：地址解析、种子递增、名字查重、路径校验、错误信息。
    这些错误如果漏到提交之后才发现，代价是白等一整轮 —— 所以用干跑覆盖。

    实测提交/等待/清显存/收产物需要真的 ComfyUI，不在本自检范围内
    （见 README「批量渲染」一节的实测记录）。

.EXAMPLE
    ./batch-selftest.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot 'batch-render.ps1'
if (-not (Test-Path $script)) { Write-Host "❌ 找不到 batch-render.ps1"; exit 1 }

$pass = 0; $fail = 0
function Ok([string]$name) { $script:pass++; Write-Host "  ✓ $name" }
function No([string]$name, [string]$why) { $script:fail++; Write-Host "  ✗ $name`n      $why" }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("batchsel-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $tmp | Out-Null

# 最小工作流夹具
$wf = @{
    '1' = @{ class_type = 'CheckpointLoaderSimple'; inputs = @{ ckpt_name = 'x.safetensors' } }
    '7' = @{ class_type = 'KSampler'; inputs = @{ seed = 0; steps = 4 } }
    '9' = @{ class_type = 'SaveImage'; inputs = @{ filename_prefix = 'a'; images = @('8', 0) } }
}
$wf | ConvertTo-Json -Depth 10 | Set-Content "$tmp\wf.json" -Encoding utf8
$wf2 = $wf.Clone(); $wf2.'9'.inputs.filename_prefix = 'b'
$wf2 | ConvertTo-Json -Depth 10 | Set-Content "$tmp\wf2.json" -Encoding utf8

function WritePlan([string]$name, $obj) {
    $p = Join-Path $tmp $name
    $obj | ConvertTo-Json -Depth 10 | Set-Content $p -Encoding utf8
    return $p
}
function RunDry([string]$plan) {
    $out = & pwsh -NoProfile -File $script -PlanPath $plan -DryRun -Quiet 2>&1
    return [pscustomobject]@{ code = $LASTEXITCODE; text = ($out -join "`n") }
}

Write-Host ""
Write-Host "batch-render 离线干跑自检"
Write-Host ("─" * 56)

# ── 1. 合法计划：种子递增 + 参数写入 ─────────────────────────────────────
$p1 = WritePlan 'p1.json' @{
    workflow = 'wf.json'; seedAddress = '7.seed'; seedBase = 500; seedStep = 10
    items = @(
        @{ name = 'a'; params = @{ '9.filename_prefix' = 'A' } }
        @{ name = 'b'; params = @{ '9.filename_prefix' = 'B'; '7.seed' = 99 } }
        @{ name = 'c'; params = @{ '9.filename_prefix' = 'C' } }
    )
}
$r = RunDry $p1
if ($r.code -eq 0 -and $r.text -match 'BATCH_DRYRUN\s+items=3') { Ok '合法计划：退出 0 且报 items=3' } else { No '合法计划：退出 0 且报 items=3' "code=$($r.code) text=$($r.text)" }
if ($r.text -match '7\.seed = 500' -and $r.text -match '7\.seed = 520') { Ok '种子按 seedBase+step 递增（500 / 520）' } else { No '种子按 seedBase+step 递增（500 / 520）' $r.text }
if ($r.text -match '7\.seed = 99') { Ok 'params 里写死的种子不被覆盖' } else { No 'params 里写死的种子不被覆盖' $r.text }
if ($r.text -match '9\.filename_prefix = A' -and $r.text -match '9\.filename_prefix = C') { Ok '显式参数写入工作流' } else { No '显式参数写入工作流' $r.text }

# ── 2. 每项覆盖工作流 ───────────────────────────────────────────────────
$p2 = WritePlan 'p2.json' @{
    workflow = 'wf.json'
    items = @(
        @{ name = 'a' }
        @{ name = 'b'; workflow = 'wf2.json' }
    )
}
$r = RunDry $p2
if ($r.code -eq 0 -and $r.text -match '\[2/2\] b' -and $r.text -match 'wf2\.json') { Ok '每项可覆盖工作流（wf2.json 生效）' } else { No '每项可覆盖工作流（wf2.json 生效）' "code=$($r.code) $($r.text)" }

# ── 3. 名字重复 ─────────────────────────────────────────────────────────
$p3 = WritePlan 'p3.json' @{
    workflow = 'wf.json'
    items = @(@{ name = 'same' }, @{ name = 'same' })
}
$r = RunDry $p3
if ($r.code -eq 2 -and $r.text -match '名字重复') { Ok '名字重复 → 退出 2 并说明原因' } else { No '名字重复 → 退出 2 并说明原因' "code=$($r.code) $($r.text)" }

# ── 4. 工作流文件不存在 ──────────────────────────────────────────────────
$p4 = WritePlan 'p4.json' @{ workflow = 'nope.json'; items = @(@{ name = 'a' }) }
$r = RunDry $p4
if ($r.code -eq 2 -and $r.text -match '基础工作流不存在') { Ok '工作流不存在 → 退出 2' } else { No '工作流不存在 → 退出 2' "code=$($r.code) $($r.text)" }

# ── 5. 节点地址写错 ─────────────────────────────────────────────────────
$p5 = WritePlan 'p5.json' @{
    workflow = 'wf.json'
    items = @(@{ name = 'a'; params = @{ '99.seed' = 1 } })
}
$r = RunDry $p5
if ($r.code -eq 2 -and $r.text -match '没有节点 99') { Ok '节点地址写错 → 退出 2 并指明节点' } else { No '节点地址写错 → 退出 2 并指明节点' "code=$($r.code) $($r.text)" }

# ── 6. 地址格式非法（没有点）─────────────────────────────────────────────
$p6 = WritePlan 'p6.json' @{
    workflow = 'wf.json'
    items = @(@{ name = 'a'; params = @{ 'badaddr' = 1 } })
}
$r = RunDry $p6
if ($r.code -eq 2 -and $r.text -match '节点id') { Ok '地址缺节点前缀 → 退出 2 并说明格式' } else { No '地址缺节点前缀 → 退出 2 并说明格式' "code=$($r.code) $($r.text)" }

# ── 7. 空 items ─────────────────────────────────────────────────────────
$p7 = WritePlan 'p7.json' @{ workflow = 'wf.json'; items = @() }
$r = RunDry $p7
if ($r.code -eq 2 -and $r.text -match '没有 items') { Ok '空 items → 退出 2' } else { No '空 items → 退出 2' "code=$($r.code) $($r.text)" }

# ── 8. 计划文件不是 JSON ────────────────────────────────────────────────
$p8 = Join-Path $tmp 'p8.json'; Set-Content $p8 '{ this is not json' -Encoding utf8
$r = RunDry $p8
if ($r.code -eq 2 -and $r.text -match '不是合法 JSON') { Ok '非法 JSON → 退出 2' } else { No '非法 JSON → 退出 2' "code=$($r.code) $($r.text)" }

# ── 9. 省略 name 自动命名 ───────────────────────────────────────────────
$p9 = WritePlan 'p9.json' @{ workflow = 'wf.json'; items = @(@{}, @{}) }
$r = RunDry $p9
if ($r.code -eq 0 -and $r.text -match '\[1/2\] item1' -and $r.text -match '\[2/2\] item2') { Ok '省略 name → 自动 item1/item2' } else { No '省略 name → 自动 item1/item2' "code=$($r.code) $($r.text)" }

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host ("─" * 56)
Write-Host "  结果：$pass 通过 / $fail 失败"
if ($fail -gt 0) { exit 1 }
exit 0
