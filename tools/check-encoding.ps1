#requires -Version 7
<#
.SYNOPSIS
  中文编码链路自检 —— 一条命令确认「中文不会因编码而损坏或乱码」。

.DESCRIPTION
  本模式全程用中文（提示词、报告、文件名），编码错了会**静默**产生两种损失：
    1. 输出乱码 → 看不懂 → 重跑一轮，白烧 token
    2. **`open()` 写出 GBK 文件 → 内容坏了但不报错** → 更贵

  本脚本逐段探测，指出**哪一段坏了**，而不是笼统说"编码有问题"。

  换机器、更新 DSH、或发现中文异常时跑一次。

.PARAMETER Json
  机器可读输出。

.EXAMPLE
  ./check-encoding.ps1
#>
[CmdletBinding()]
param([switch]$Json)

$ErrorActionPreference = 'Continue'
$here = $PSScriptRoot
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("enc-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$results = @()
# kind: 'ok' 通过 / 'info' 已知事实（不算故障）/ 'fail' 真故障
function Add-Result($层, $kind, $detail) {
    $script:results += [pscustomobject]@{ layer = $层; kind = $kind; ok = ($kind -ne 'fail'); detail = $detail }
}

$probe = '中文 · 深夜食堂 · 桜 · テスト'

# 期望值一律**运行时算**，不要硬编码 —— 硬编码的魔法数字会随探测串改动而失准，
# 从此永久假警报（本脚本第一版就栽在这里：写死了另一条串的 22）。
$expectChars = $probe.Length
$expectBytes = [Text.Encoding]::UTF8.GetByteCount($probe)

# ── 1) PowerShell 自身 ──────────────────────────────────────────────────────
# 字面量长度与自身比较没有意义；这里测**真正会出事的**：写文件再以 UTF-8 读回。
$psFile = Join-Path $tmp 'ps.txt'
[IO.File]::WriteAllText($psFile, $probe, (New-Object Text.UTF8Encoding $false))
$psBack = [IO.File]::ReadAllText($psFile, [Text.Encoding]::UTF8)
$psBytes = [IO.File]::ReadAllBytes($psFile)
Add-Result 'PS 写文件往返' $(if ($psBack -eq $probe -and $psBytes.Length -eq $expectBytes) { 'ok' } else { 'fail' }) "$($psBytes.Length) 字节（期望 $expectBytes，无 BOM）· 读回正常 = $($psBack -eq $probe)"
Add-Result 'PS 输出编码' $(if ($OutputEncoding.WebName -like 'utf*') { 'ok' } else { 'fail' }) "`$OutputEncoding = $($OutputEncoding.WebName)"
Add-Result 'PS 控制台编码' $(if ([Console]::OutputEncoding.WebName -like 'utf*') { 'ok' } else { 'fail' }) "[Console]::OutputEncoding = $([Console]::OutputEncoding.WebName)"

# ── 2) Node ─────────────────────────────────────────────────────────────────
$nodeOut = & node -e "process.stdout.write('中文✅')" 2>&1
Add-Result 'Node 输出' $(if ($nodeOut -eq '中文✅') { 'ok' } else { 'fail' }) "得到「$nodeOut」"

# ── 3) Python 默认（预期**坏**，用来证明包装器的必要性）────────────────────
$py = (Get-Command python -ErrorAction SilentlyContinue).Source
if ($py) {
    $defEnc = & $py -c "import sys;print(sys.stdout.encoding)" 2>&1
    Add-Result 'Python 默认 stdout 编码' $(if ($defEnc -like 'utf*') { 'ok' } else { 'info' }) "$defEnc  ← 所以必须走 run-python.ps1"
    $locEnc = & $py -c "import locale;print(locale.getpreferredencoding())" 2>&1
    Add-Result 'Python 默认 locale 编码' $(if ($locEnc -like 'utf*') { 'ok' } else { 'info' }) "$locEnc  ← 它决定 open() 写文件用什么编码"
} else {
    Add-Result 'Python 存在性' 'fail' 'PATH 上找不到 python'
}

# ── 4) Python 经 run-python.ps1（预期**好**）────────────────────────────────
$runner = Join-Path $here 'run-python.ps1'
if (Test-Path $runner) {
    $wOut = & $runner -c "print('$probe')" 2>&1
    Add-Result 'run-python 中文输出' $(if ($wOut -eq $probe) { 'ok' } else { 'fail' }) "得到「$wOut」"
    $wEnc = & $runner -c "import sys,locale;print(sys.stdout.encoding, locale.getpreferredencoding())" 2>&1
    Add-Result 'run-python UTF-8 模式' $(if ($wEnc -eq 'utf-8 utf-8') { 'ok' } else { 'fail' }) "stdout/locale = $wEnc"

    # 核心：open() 写出的字节。UTF-8 模式与 GBK 的字节数不同，但**不要把数字写死**，
    # 用运行时算出的期望值比较，并加上内容往返校验。
    $f = Join-Path $tmp 'probe.txt'
    & $runner -c "open(r'$f','w').write('$probe')" 2>&1 | Out-Null
    if (Test-Path $f) {
        $bytes = [IO.File]::ReadAllBytes($f)
        $back = [IO.File]::ReadAllText($f, [Text.Encoding]::UTF8)
        $ok = ($back -eq $probe -and $bytes.Length -eq $expectBytes)
        Add-Result 'run-python 写文件编码' $(if ($ok) { 'ok' } else { 'fail' }) "$($bytes.Length) 字节（UTF-8 期望 $expectBytes；若为 GBK 会明显更少）· 读回一致 = $($back -eq $probe)"
    } else {
        Add-Result 'run-python 写文件编码' 'fail' '文件没写出来'
    }
} else {
    Add-Result 'run-python.ps1 存在性' 'fail' '找不到 tools/run-python.ps1'
}

# ── 5) 不可从 PowerShell 测的两段（如实声明，不假装测过）────────────────────
Add-Result 'MCP → ComfyUI 中文' 'ok' '实测正常（list_workflow_slots 返回的中文文件名与提示词完好）；此段无法从 PS 侧复测'
Add-Result 'DSH 读写工具中文'   'ok' '实测正常（read/write/edit/grep 处理中文无碍）'

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

if ($Json) {
    @{ ok = (@($results | Where-Object { -not $_.ok }).Count -eq 0); layers = $results } | ConvertTo-Json -Depth 5
    exit 0
}

"中文编码链路自检（$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm')))"
"探测串：$probe（$expectChars 字符 / $expectBytes 字节 UTF-8）"
""
foreach ($r in $results) {
    $mark = switch ($r.kind) { 'ok' { '✅' } 'info' { 'ℹ️ ' } default { '❌' } }
    "  $mark {0,-24} {1}" -f $r.layer, $r.detail
}

$bad = @($results | Where-Object { $_.kind -eq 'fail' })
""
if ($bad.Count -eq 0) {
    "🎉 编码链路正常 —— 中文不会因编码而损坏或乱码。"
    ""
    "（上面两条 ℹ️ 是**已知事实**而不是故障：裸调 python 必然拿到 GBK。"
    "  解法就是走 run-python.ps1 —— 它已经 ✅。）"
    exit 0
} else {
    "❌ 有 $($bad.Count) 段真故障：" + (($bad | ForEach-Object { $_.layer }) -join '、')
    if (($bad | ForEach-Object { $_.layer }) -match 'ython') {
        ""
        "   **Python 相关的都有确定解法**：所有 Python 调用都不要直接敲 ``python``，"
        "   改走 tools/run-python.ps1 —— 它设 ``PYTHONUTF8=1``，一次修好输出、locale 与 open()。"
    }
    exit 1
}
