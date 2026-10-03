#requires -Version 7
<#
.SYNOPSIS
  把 ComfyUI 创作模式预设打包成可分发的 zip（含清单与校验和）。

.DESCRIPTION
  产物落在 <bundle>/dist/ 下：

    dsh-comfyui-preset-<version>.zip
    dsh-comfyui-preset-<version>.zip.sha256
    dsh-comfyui-preset-<version>.manifest.json

  清单记录：版本、打包时间、**验证过它的 DSH 版本**、它依赖的 DSH 内部模块名、
  以及每个文件的 SHA256。更新后的环境里 `verify-preset.ps1` 会拿它逐项核对。

  实现要点（都是踩过的坑）：
    * **用 package.json 的 files 声明决定装什么** —— 不要直接把整个目录 zip 进去，
      否则 dist/ 会被套进 dist/，每打一次包就臃肿一层。
    * **MANIFEST.json 不参与哈希** —— 它是要被写出来的东西，自我引用会导致
      每次重打包都报"1 个文件与清单不符"。
    * 打包在**暂存目录**里进行，不污染源目录。

.PARAMETER OutDir
  产物目录，默认 <bundle>/dist。

.PARAMETER AsarPath
  用于把"打包时验证过的 DSH 版本"写进清单。

.EXAMPLE
  ./pack-preset.ps1
#>
[CmdletBinding()]
param(
    [string]$OutDir,
    [string]$AsarPath = 'D:\Deepseek\resources\app.asar'
)

$ErrorActionPreference = 'Stop'

$bundle = Split-Path $PSScriptRoot -Parent
if (-not $OutDir) { $OutDir = Join-Path $bundle 'dist' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$pkg = Get-Content (Join-Path $bundle 'package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$ver = $pkg.version
$name = $pkg.name
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

# ── 依赖的 DSH 内部模块（从补丁里抓 name: '@deepseek-ai/...'）────────────────
$patch = Get-Content (Join-Path $bundle 'cordis.patch.yml') -Raw -Encoding UTF8
$modules = @([regex]::Matches($patch, "name:\s*'(@deepseek-ai/[^']+)'") |
    ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
"  依赖的 DSH 内部模块：$($modules.Count) 个"

$dshVerifiedOn = if (Test-Path $AsarPath) { (Get-Item $AsarPath).LastWriteTime.ToString('yyyy-MM-dd') } else { $null }

# ── 暂存：只装入 package.json 的 files 声明的项 ─────────────────────────────
$stage = Join-Path ([IO.Path]::GetTempPath()) ("dshpack-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
$stageBundle = Join-Path $stage $name
New-Item -ItemType Directory -Force -Path $stageBundle | Out-Null

$declared = @($pkg.files)
foreach ($item in $declared) {
    $clean = $item.TrimEnd('/')
    $src = Join-Path $bundle $clean
    if (-not (Test-Path $src)) { "  ⚠️  files 里声明了但不存在，跳过：$item"; continue }
    $dst = Join-Path $stageBundle $clean
    if ((Get-Item $src).PSIsContainer) {
        Copy-Item $src $dst -Recurse -Force
    } else {
        Copy-Item $src $dst -Force
    }
}
"  暂存完成：$(($declared | Measure-Object).Count) 项声明"

# ── 逐文件算哈希（MANIFEST.json 还没写，天然不会被算进去）──────────────────
$files = @()
Get-ChildItem $stageBundle -Recurse -File | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($stageBundle.Length + 1).Replace('\', '/')
    $files += [ordered]@{
        path   = $rel
        bytes  = $_.Length
        sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower()
    }
}
"  纳入文件：$($files.Count) 个"

$manifest = [ordered]@{
    name             = $name
    version          = $ver
    builtAt          = $stamp
    dshVerifiedOn    = $dshVerifiedOn
    dshEngines       = $pkg.dsh.engines.dsh
    dshCompatibility = $pkg.dsh.compatibility.dshReleases
    dshModules       = $modules
    fileCount        = $files.Count
    totalBytes       = ($files | Measure-Object -Property bytes -Sum).Sum
    files            = $files
}

# 清单写进暂存的 bundle（MANIFEST.json 本身不进 files 列表，避免自我引用）
$manifest | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $stageBundle 'MANIFEST.json') -Encoding utf8
# 源目录也留一份，供 verify-preset.ps1 在"就地检查"时使用
$manifest | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $bundle 'MANIFEST.json') -Encoding utf8

# ── 打包 ────────────────────────────────────────────────────────────────────
$zip = Join-Path $OutDir "$name-$ver.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $stageBundle -DestinationPath $zip -CompressionLevel Optimal
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
"$hash  $name-$ver.zip" | Set-Content "$zip.sha256" -Encoding ascii
Copy-Item (Join-Path $bundle 'MANIFEST.json') (Join-Path $OutDir "$name-$ver.manifest.json") -Force

Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue

""
"✅ 打包完成"
"   $zip"
"   大小 $([math]::Round((Get-Item $zip).Length / 1KB, 1)) KB   文件 $($files.Count) 个"
"   SHA256 $hash"
""
"分发：zip + .sha256 + INSTALL.md 一起给对方。"
