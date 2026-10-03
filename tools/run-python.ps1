#requires -Version 7
<#
.SYNOPSIS
  Python 调用的**统一入口** —— 强制 UTF-8，杜绝中文乱码与静默损坏。

.DESCRIPTION
  为什么必须有这个东西（实测，不是理论）：

  这台机器的控制台代码页是 **936（GBK）**，而 Python 在 Windows 上会跟随它：
  - `sys.stdout.encoding` = `gbk`  → 中文输出**全乱码**
  - `locale.getpreferredencoding()` = `cp936` → **`open()` 不带 encoding 时写出的文件是 GBK**

  第二条更危险：它**不报错**。用 Python 写任何含中文的文件（JSON 参数、报告、笔记），
  写出来就是坏字节，直到有人用 UTF-8 读它才发现。

  实测对照（6 个汉字）：
    默认          → 16 字节  D6 D0 CE C4 C4 DA   （GBK，UTF-8 读回是乱码）
    PYTHONUTF8=1  → 22 字节  E4 B8 AD E6 96 87   （UTF-8，读回正常）

  注意 `PYTHONIOENCODING=utf-8` **不够**：它只改 stdout/stderr，
  `locale.getpreferredencoding()` 仍是 cp936，`open()` 照样写 GBK。
  **只有 `PYTHONUTF8=1`（Python UTF-8 模式）能同时修好输出、locale 与 open()。**

  本脚本设置好这两组变量后再转发给 Python，是所有 Python 调用的唯一正确姿势。

.PARAMETER PythonPath
  指定 python.exe。省略则自动探测：PATH → 捆绑运行时 → 常见安装位置。

.PARAMETER PyArgs
  原样转发给 Python 的所有参数（脚本路径、`-c`、以及脚本自己的参数）。

.EXAMPLE
  ./run-python.ps1 ../comfyui-review/scripts/review.py frames <视频> <目录> --count 9
  ./run-python.ps1 -c "print('中文测试 ✅')"
#>
[CmdletBinding()]
param(
    [string]$PythonPath,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)][string[]]$PyArgs
)

$ErrorActionPreference = 'Continue'

# ── 1) 强制 UTF-8（本脚本存在的全部理由）────────────────────────────────────
$env:PYTHONUTF8       = '1'       # Python UTF-8 模式：stdout + locale + open() 一起修
$env:PYTHONIOENCODING = 'utf-8'   # 双保险（单独用不够，但配上无害）
# PowerShell 自己这端也要对齐，否则它按 GBK 解码子进程的 UTF-8 输出
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding           = [Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# ── 2) 找 Python ────────────────────────────────────────────────────────────
if (-not $PythonPath) {
    $cmd = Get-Command python -ErrorAction SilentlyContinue
    if ($cmd) { $PythonPath = $cmd.Source }
}
if (-not $PythonPath) {
    $cands = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python311\python.exe'),
        'C:\Python312\python.exe',
        'C:\Python311\python.exe',
        (Join-Path $env:USERPROFILE '.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe')
    )
    $PythonPath = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $PythonPath -or -not (Test-Path $PythonPath)) {
    Write-Error @"
找不到 python.exe。可选处置：
  1) 让 agent 调 load_workspace_dependencies 取捆绑 Python 的绝对路径，再用 -PythonPath 传进来
  2) 把 Python 加进 PATH
  3) 显式指定：./run-python.ps1 -PythonPath <路径> <脚本> <参数...>
"@
    exit 127
}

if ($PyArgs.Count -eq 0) {
    Write-Error "没给 Python 参数。用法：./run-python.ps1 <脚本.py> [参数...]  或  ./run-python.ps1 -c ""<代码>"""
    exit 2
}

# ── 3) 转发 ─────────────────────────────────────────────────────────────────
& $PythonPath @PyArgs
$code = $LASTEXITCODE
if ($code -ne 0) { Write-Host "（python 退出码 $code）" -ForegroundColor Yellow }
exit $code
