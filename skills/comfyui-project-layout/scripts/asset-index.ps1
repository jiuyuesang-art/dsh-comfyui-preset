#requires -Version 7
<#
.SYNOPSIS
    生成资产路径表 —— 总资产根一张，每个镜头一张。

.DESCRIPTION
    资产多了就不好找。本脚本扫描目录并生成**自动维护的索引表**：

      ① 总资产表  <工作根>/00_assets/资产表.md
         列出每个资产：中文名 / 英文名 / 类型 / 路径 / 预览图 / 文件数 / 最近更新

      ② 分镜资产表 <镜头目录>/资产表.md
         列出**这个镜头用到哪些资产**，来源两处合并：
           · 镜头 shot.json 的 assets[] （显式声明）
           · 镜头 10_ref/ 里出现的资产名（从文件名反查）

    表里嵌**缩略图**（生成到 <工作根>/00_assets/.index/thumbs/），
    这样表本身保持轻量 —— 100 个资产也不会拖垮打开速度。

    中文名来源：每个资产目录下可选的 asset.json
      { "name_zh": "桐人", "name_en": "kirito", "source": "刀剑神域", "tags": ["主角"] }
    没填就只显示英文名，并在表里标 ⚠️ 提示补填。

.PARAMETER Root
    工作根（含 00_assets 的那层）。默认向上探测。

.PARAMETER Shot
    镜头目录的绝对或相对路径。给了就只生成该镜头的表。

.PARAMETER All
    生成总资产表 + 扫描所有项目的所有镜头，各生成一张。

.PARAMETER ThumbWidth
    缩略图宽度，默认 240。

.EXAMPLE
    ./asset-index.ps1 -All
    ./asset-index.ps1 -Shot 01_projects/demo/20_shots/ep01/sq010_temple/sh0010_arrive
#>
[CmdletBinding(DefaultParameterSetName = 'Root')]
param(
    [Parameter(ParameterSetName = 'Root')]
    [switch]$All,

    [Parameter(ParameterSetName = 'Shot')]
    [string]$Shot,

    [string]$Root,
    [int]$ThumbWidth = 240
)

$ErrorActionPreference = 'Stop'

$IMG_EXT = @('.png', '.jpg', '.jpeg', '.webp', '.bmp', '.gif')

function Find-WorkRoot {
    $d = (Get-Location).Path
    for ($i = 0; $i -lt 8; $i++) {
        foreach ($m in @('00_assets', '01_projects', '02_env')) {
            if (Test-Path -LiteralPath (Join-Path $d $m)) { return $d }
        }
        $p = Split-Path $d -Parent
        if (-not $p -or $p -eq $d) { break }
        $d = $p
    }
    return $null
}

if (-not $Root) { $Root = Find-WorkRoot }
if (-not $Root) { throw '找不到工作根（向上 8 层内没有 00_assets / 01_projects / 02_env）。用 -Root 指定。' }
$Root = (Resolve-Path -LiteralPath $Root).Path
$assetsRoot = Join-Path $Root '00_assets'

# ── 工具 ──────────────────────────────────────────────────────────────────
function Get-Images([string]$dir) {
    if (-not (Test-Path -LiteralPath $dir)) { return @() }
    return @(Get-ChildItem -LiteralPath $dir -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $IMG_EXT -contains $_.Extension.ToLower() } |
        Where-Object { $_.FullName -notmatch '\\\.index\\' } |
        Sort-Object LastWriteTime -Descending)
}

function Get-Preview([string]$assetDir) {
    # 优先 sheet/（设定图就是拿来当预览的），否则资产目录下最新的图
    $sheet = Get-Images (Join-Path $assetDir 'sheet')
    if ($sheet.Count) { return $sheet[0] }
    $any = Get-Images $assetDir
    if ($any.Count) { return $any[0] }
    return $null
}

function Resolve-Python {
    foreach ($p in @(
        'C:\easyaiforcomfyui\ComfyUI-EasyManager\win\envs\comfyui\python.exe',
        "$env:USERPROFILE\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"
    )) { if (Test-Path -LiteralPath $p) { return $p } }
    $c = Get-Command python -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    return $null
}

$thumbDir = Join-Path $assetsRoot '.index\thumbs'
$py = Resolve-Python
# media.py 在**兄弟 skill** comfyui-media 下（不在本 skill 里）——
# 本脚本 $PSScriptRoot = skills/comfyui-project-layout/scripts
$thumbScript = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'comfyui-media\scripts\media.py'
$thumbsMade = 0
$thumbsFailed = 0
$thumbError = $null

function Get-Thumb([string]$src) {
    # 缩略图按源文件内容哈希命名 —— 源改了会自动生成新的一张
    if (-not $py) { $script:thumbError = '找不到 Python（缩略图跳过）'; return $null }
    if (-not (Test-Path -LiteralPath $thumbScript)) { $script:thumbError = "找不到 media.py：$thumbScript"; return $null }
    $hash = (Get-FileHash -LiteralPath $src -Algorithm MD5).Hash.Substring(0, 12).ToLower()
    $dst = Join-Path $thumbDir "$hash.jpg"
    if (-not (Test-Path -LiteralPath $dst)) {
        if (-not (Test-Path -LiteralPath $thumbDir)) { New-Item -ItemType Directory -Force -Path $thumbDir | Out-Null }
        $out = & $py $thumbScript resize $src -o $dst --width $ThumbWidth --fit contain --bg 24,24,28 --quality 82 2>&1
        if ($LASTEXITCODE -ne 0) {
            $script:thumbsFailed++
            $script:thumbError = ($out | Select-Object -First 1)
            return $null
        }
        $script:thumbsMade++
    }
    return $dst
}

# 相对路径：交给 .NET 算，别手写 ../../ （深度一变就断）
function RelPath([string]$fromDir, [string]$toPath) {
    try {
        return ([IO.Path]::GetRelativePath($fromDir, $toPath)) -replace '\\', '/'
    } catch {
        return ($toPath -replace '\\', '/')
    }
}

function Esc([string]$s) {
    if ($null -eq $s) { return '' }
    return ($s -replace '\|', '\|' -replace "`r?`n", ' ')
}

# ── 扫描资产 ──────────────────────────────────────────────────────────────
function Scan-Assets {
    $rows = @()
    if (-not (Test-Path -LiteralPath $assetsRoot)) { return $rows }
    foreach ($type in (Get-ChildItem -LiteralPath $assetsRoot -Directory -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -notmatch '^\.' } | Sort-Object Name)) {
        foreach ($asset in (Get-ChildItem -LiteralPath $type.FullName -Directory -ErrorAction SilentlyContinue |
                            Where-Object { $_.Name -match '^\d{4}_' } | Sort-Object Name)) {
            $zh = ''
            $en = ($asset.Name -replace '^\d{4}_', '')
            $source = ''
            $tags = ''
            $metaPath = Join-Path $asset.FullName 'asset.json'
            if (Test-Path -LiteralPath $metaPath) {
                try {
                    $m = Get-Content -LiteralPath $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($m.name_zh) { $zh = $m.name_zh }
                    if ($m.name_en) { $en = $m.name_en }
                    if ($m.source)  { $source = $m.source }
                    if ($m.tags)    { $tags = (@($m.tags) -join ' / ') }
                } catch { }
            }
            $files = @(Get-ChildItem -LiteralPath $asset.FullName -File -Recurse -ErrorAction SilentlyContinue |
                       Where-Object { $_.FullName -notmatch '\\\.index\\' })
            $last = if ($files.Count) { ($files | Sort-Object LastWriteTime -Descending)[0].LastWriteTime } else { $asset.LastWriteTime }
            $prev = Get-Preview $asset.FullName
            $thumb = if ($prev) { Get-Thumb $prev.FullName } else { $null }

            $rows += [pscustomobject]@{
                Type     = $type.Name
                Code     = $asset.Name
                En       = $en
                Zh       = $zh
                Source   = $source
                Tags     = $tags
                Dir      = $asset.FullName
                RelDir   = $asset.FullName.Substring($Root.Length).TrimStart('\')
                Files    = $files.Count
                Updated  = $last
                Preview  = $prev
                Thumb    = $thumb
            }
        }
    }
    return $rows
}

# ── 生成总资产表 ──────────────────────────────────────────────────────────
function Write-AssetIndex {
    $rows = Scan-Assets
    $outPath = Join-Path $assetsRoot '资产表.md'
    if (-not (Test-Path -LiteralPath $assetsRoot)) { New-Item -ItemType Directory -Force -Path $assetsRoot | Out-Null }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('# 资产表')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('> ⚙️ **本文件由 `scripts/asset-index.ps1` 自动生成，请勿手改** —— 改了下次会被覆盖。')
    [void]$sb.AppendLine('>')
    [void]$sb.AppendLine("> 生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')　·　资产数：**$($rows.Count)**")
    [void]$sb.AppendLine('>')
    [void]$sb.AppendLine('> 要改中文名 / 出处 / 标签，改该资产目录下的 `asset.json`，然后重跑脚本。')
    [void]$sb.AppendLine()

    if ($rows.Count -eq 0) {
        [void]$sb.AppendLine('_（还没有任何资产）_')
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('建第一个资产：')
        [void]$sb.AppendLine('```powershell')
        [void]$sb.AppendLine('& scripts/ensure.ps1 -Asset characters -Name kirito -NameZh 桐人 -Sub ref')
        [void]$sb.AppendLine('```')
    } else {
        # 按类型分组
        foreach ($grp in ($rows | Group-Object Type | Sort-Object Name)) {
            [void]$sb.AppendLine("## $($grp.Name)　（$($grp.Count) 个）")
            [void]$sb.AppendLine()
            [void]$sb.AppendLine('| 预览 | 中文名 | 英文名 | 编号 | 出处 | 标签 | 文件 | 最近更新 | 路径 |')
            [void]$sb.AppendLine('|---|---|---|---|---|---|---|---|---|')
            foreach ($r in $grp.Group) {
                $pv = if ($r.Thumb) {
                    "![](<$(Esc (RelPath $assetsRoot $r.Thumb))>)"
                } elseif ($r.Preview) {
                    "![](<$(Esc (RelPath $assetsRoot $r.Preview.FullName))>)"    # 缩略图失败时退回原图
                } else { '_无_' }

                $zhCell = if ($r.Zh) { Esc $r.Zh } else { '⚠️ 待填' }
                $code   = ($r.Code -split '_')[0]
                $relDir = Esc ($r.RelDir -replace '\\', '/')
                [void]$sb.AppendLine("| $pv | $zhCell | $(Esc $r.En) | $code | $(Esc $r.Source) | $(Esc $r.Tags) | $($r.Files) | $($r.Updated.ToString('MM-dd HH:mm')) | ``$relDir`` |")
            }
            [void]$sb.AppendLine()
        }
    }

    [IO.File]::WriteAllText($outPath, $sb.ToString(), (New-Object Text.UTF8Encoding $false))
    return [pscustomobject]@{ Path = $outPath; Count = $rows.Count }
}

# ── 生成分镜资产表 ────────────────────────────────────────────────────────
function Write-ShotIndex([string]$shotDir) {
    if (-not (Test-Path -LiteralPath $shotDir)) { throw "镜头目录不存在：$shotDir" }
    $shotDir = (Resolve-Path -LiteralPath $shotDir).Path
    $shotName = Split-Path $shotDir -Leaf
    $outPath = Join-Path $shotDir '资产表.md'

    # 来源①：shot.json 的 assets[]
    $declared = @()
    $sj = Join-Path $shotDir 'shot.json'
    if (Test-Path -LiteralPath $sj) {
        try {
            $j = Get-Content -LiteralPath $sj -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($j.assets) { $declared = @($j.assets) }
        } catch { }
    }

    # 来源②：10_ref/ 里出现的资产名（从文件名反查）
    $refDir = Join-Path $shotDir '10_ref'
    $fromFiles = @()
    foreach ($f in (Get-ChildItem -LiteralPath $refDir -File -Recurse -ErrorAction SilentlyContinue)) {
        # 资产名出现在文件名里即算命中（如 ep01_sq010_sh0010-ref-kirito-v001.png）
        $fromFiles += $f.Name
    }

    # 用总资产表做反查字典
    $all = Scan-Assets
    $matched = @()
    foreach ($a in $all) {
        $hit = $false
        if ($declared -contains $a.En -or $declared -contains $a.Code) { $hit = $true }
        if (-not $hit) {
            foreach ($fn in $fromFiles) {
                if ($fn -match [regex]::Escape($a.En) -or $fn -match [regex]::Escape($a.Code)) { $hit = $true; break }
            }
        }
        if ($hit) { $matched += $a }
    }

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# 资产表 —— $shotName")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('> ⚙️ **本文件由 `scripts/asset-index.ps1` 自动生成，请勿手改。**')
    [void]$sb.AppendLine("> 生成时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')　·　命中资产：**$($matched.Count)**")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## 这个镜头用到的资产')
    [void]$sb.AppendLine()
    if ($matched.Count -eq 0) {
        [void]$sb.AppendLine('_（没识别到资产）_')
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('两种让本表认出资产的办法：')
        [void]$sb.AppendLine('1. **显式声明**：在 `shot.json` 里加 `"assets": ["kirito", "temple"]`')
        [void]$sb.AppendLine('2. **文件名带资产名**：把参考图命名成 `' + $shotName + '-ref-kirito-v001.png` 放进 `10_ref/`')
    } else {
        [void]$sb.AppendLine('| 预览 | 中文名 | 英文名 | 类型 | 路径 |')
        [void]$sb.AppendLine('|---|---|---|---|---|')
        foreach ($r in $matched) {
            $pv = if ($r.Thumb) {
                $rel = RelPath $shotDir $r.Thumb
                "![](<$rel>)"
            } elseif ($r.Preview) {
                $rel = RelPath $shotDir $r.Preview.FullName
                "![](<$rel>)"
            } else { '_无_' }
            $zhCell = if ($r.Zh) { Esc $r.Zh } else { '⚠️ 待填' }
            $relDir = Esc ($r.RelDir -replace '\\', '/')
            [void]$sb.AppendLine("| $pv | $zhCell | $(Esc $r.En) | $(Esc $r.Type) | ``$relDir`` |")
        }
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('> 📖 完整资产清单见 `00_assets/资产表.md`')

    [IO.File]::WriteAllText($outPath, $sb.ToString(), (New-Object Text.UTF8Encoding $false))
    return [pscustomobject]@{ Path = $outPath; Count = $matched.Count }
}

# ── 执行 ──────────────────────────────────────────────────────────────────
if ($PSCmdlet.ParameterSetName -eq 'Shot') {
    $sd = if ([IO.Path]::IsPathRooted($Shot)) { $Shot } else { Join-Path $Root ($Shot -replace '/', '\') }
    $r = Write-ShotIndex $sd
    "✅ 分镜资产表 → $($r.Path)　（命中 $($r.Count) 个资产）"
    if ($thumbsMade -or $thumbsFailed) { "   缩略图：新建 $thumbsMade" + $(if ($thumbsFailed) { "，失败 $thumbsFailed" } else { '' }) }
    exit 0
}

$r = Write-AssetIndex
"✅ 总资产表 → $($r.Path)　（$($r.Count) 个资产）"
if ($thumbsMade -or $thumbsFailed) { "   缩略图：新建 $thumbsMade" + $(if ($thumbsFailed) { "，失败 $thumbsFailed" } else { '' }) }

if ($All) {
    $projRoot = Join-Path $Root '01_projects'
    $n = 0
    if (Test-Path -LiteralPath $projRoot) {
        # 认"长得像镜头"的目录：含 10_ref / 30_key / 60_review 任一
        $stageDirs = @('10_ref', '20_layout', '30_key', '40_video', '50_audio', '60_review')
        $shots = Get-ChildItem -LiteralPath $projRoot -Directory -Recurse -Depth 4 -ErrorAction SilentlyContinue |
            Where-Object {
                $kids = Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
                @($kids | Where-Object { $stageDirs -contains $_ }).Count -gt 0 -or
                (Test-Path -LiteralPath (Join-Path $_.FullName 'shot.json'))
            }
        foreach ($s in $shots) {
            $rr = Write-ShotIndex $s.FullName
            "   · $($s.Name) → 命中 $($rr.Count)"
            $n++
        }
    }
    "✅ 分镜资产表：$n 张"
}
exit 0
