#requires -Version 7
<#
.SYNOPSIS
  艺术参考站点可达性探针 —— 探测当前网络（含代理开关）下哪些站点真能通。

.DESCRIPTION
  站点可达性会随**代理开关**变化：代理关着时 Pixiv / ArtStation / Wikimedia 等不可达，
  开了代理可能就通了。与其让模型反复踩空，不如一条命令把当前状态测出来。

  同时报告**代理当前状态**（读注册表 Internet Settings）。

.PARAMETER Group
  只测某一组：传统 / 镜像 / 日系 / 工具 / 全部（默认）。

.PARAMETER Timeout
  单站超时秒数，默认 8。

.PARAMETER Json
  机器可读输出。

.EXAMPLE
  ./check-sites.ps1                 # 测全部，看当前哪些能通
  ./check-sites.ps1 -Group 传统      # 只测传统艺术类
  ./check-sites.ps1 -Json           # 供自动化消费
#>
[CmdletBinding()]
param(
    [ValidateSet('传统', '镜像', '日系', '工具', '全部')][string]$Group = '全部',
    [int]$Timeout = 8,
    [switch]$Json
)

$ErrorActionPreference = 'Continue'

# ── 站点清单（脚本是「当前可达性」的唯一事实来源；用途注解见 art-reference 手册）────
$SITES = @(
    # 传统艺术 / 博物馆 —— 这是艺术根基：解剖、建筑、衣纹、光影、构图一脉相承
    @{ g = '传统'; n = 'Met Museum API';    u = 'https://collectionapi.metmuseum.org/public/collection/v1/objects/45734' }
    @{ g = '传统'; n = 'Art Institute API'; u = 'https://api.artic.edu/api/v1/artworks?limit=1' }
    @{ g = '传统'; n = 'WikiArt';           u = 'https://www.wikiart.org' }
    @{ g = '传统'; n = 'Europeana API';     u = 'https://api.europeana.eu/record/v2/search.json?query=rembrandt&rows=1&wskey=api2demo' }
    @{ g = '传统'; n = 'Web Gallery of Art';u = 'https://www.wga.hu' }
    @{ g = '传统'; n = 'National Gallery UK';u = 'https://www.nationalgallery.org.uk' }
    @{ g = '传统'; n = 'V&A (服饰设计)';     u = 'https://www.vam.ac.uk' }
    @{ g = '传统'; n = 'Getty';             u = 'https://www.getty.edu' }
    @{ g = '传统'; n = 'Theoi (希腊神话)';   u = 'https://www.theoi.com' }
    @{ g = '传统'; n = 'David Rumsey (地图建筑)'; u = 'https://www.davidrumsey.com' }
    @{ g = '传统'; n = 'ArchDaily';         u = 'https://www.archdaily.com' }
    @{ g = '传统'; n = 'Google Arts';       u = 'https://artsandculture.google.com' }
    @{ g = '传统'; n = 'Louvre';            u = 'https://www.louvre.fr' }
    @{ g = '传统'; n = 'Smithsonian';       u = 'https://www.si.edu' }
    @{ g = '传统'; n = 'Internet Archive';  u = 'https://archive.org' }

    # 中文古画 / 古籍高清 —— 中国传统绘画与服饰考据
    @{ g = '镜像'; n = '中华珍宝馆';         u = 'https://www.ltfc.net' }
    @{ g = '镜像'; n = '书格 shuge';         u = 'https://www.shuge.org' }
    @{ g = '镜像'; n = '故宫博物院';         u = 'https://www.dpm.org.cn' }
    @{ g = '镜像'; n = '上海博物馆';         u = 'https://www.shanghaimuseum.net' }
    @{ g = '镜像'; n = '雅昌艺术网';         u = 'https://www.artron.net' }
    @{ g = '镜像'; n = '台北故宫';           u = 'https://www.npm.gov.tw' }

    # 外网内容的可达替代（源站被墙时走这些）
    @{ g = '镜像'; n = 'Pixivision (Pixiv官方)'; u = 'https://www.pixivision.net' }
    @{ g = '镜像'; n = 'pixiv.re 图床';      u = 'https://pixiv.re' }
    @{ g = '镜像'; n = 'ArchDaily 中文';     u = 'https://www.archdaily.cn' }
    @{ g = '镜像'; n = '萌娘百科';           u = 'https://zh.moegirl.org.cn' }
    @{ g = '镜像'; n = 'wikiwand (维基镜像)'; u = 'https://www.wikiwand.com' }
    @{ g = '镜像'; n = 'Wikimedia Commons';  u = 'https://commons.wikimedia.org' }

    # 日系 / 二次元
    @{ g = '日系'; n = 'Safebooru (词表)';   u = 'https://safebooru.org' }
    @{ g = '日系'; n = 'Sakugabooru (作画)'; u = 'https://www.sakugabooru.com' }
    @{ g = '日系'; n = 'Zerochan';           u = 'https://www.zerochan.net' }
    @{ g = '日系'; n = 'MyAnimeList';        u = 'https://myanimelist.net' }
    @{ g = '日系'; n = 'Pixiv';              u = 'https://www.pixiv.net' }
    @{ g = '日系'; n = 'Danbooru';           u = 'https://danbooru.donmai.us' }
    @{ g = '日系'; n = 'ArtStation';         u = 'https://www.artstation.com' }

    # 检索 / 素材工具
    @{ g = '工具'; n = '百度图片';           u = 'https://image.baidu.com' }
    @{ g = '工具'; n = 'Bing 图片';          u = 'https://cn.bing.com/images' }
    @{ g = '工具'; n = '花瓣 huaban';        u = 'https://huaban.com' }
    @{ g = '工具'; n = 'Poly Haven (CC0)';   u = 'https://api.polyhaven.com/types' }
    @{ g = '工具'; n = 'Civitai';            u = 'https://civitai.com' }
)

if ($Group -ne '全部') { $SITES = @($SITES | Where-Object { $_.g -eq $Group }) }

# ── 代理状态 ────────────────────────────────────────────────────────────────
$proxy = [pscustomobject]@{ enabled = $false; server = $null; env = $null }
try {
    $ie = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction Stop
    $proxy.enabled = ($ie.ProxyEnable -eq 1)
    $proxy.server = $ie.ProxyServer
} catch { }
if ($env:HTTPS_PROXY) { $proxy.env = $env:HTTPS_PROXY }
elseif ($env:HTTP_PROXY) { $proxy.env = $env:HTTP_PROXY }

# ── 并发探测 ────────────────────────────────────────────────────────────────
$sw = [Diagnostics.Stopwatch]::StartNew()
$results = $SITES | ForEach-Object -Parallel {
    $s = $_
    $t = $using:Timeout
    try {
        $r = Invoke-WebRequest -Uri $s.u -TimeoutSec $t -MaximumRedirection 3 `
             -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120' `
             -ErrorAction Stop
        [pscustomobject]@{ group = $s.g; name = $s.n; url = $s.u; ok = $true; code = $r.StatusCode; note = '' }
    } catch {
        $c = $_.Exception.Response.StatusCode.value__
        # 403/405/429 说明**站点可达但拒绝爬虫**；与"网络不通"是两回事，必须分开报。
        $botBlocked = $c -in 401, 403, 405, 429
        [pscustomobject]@{
            group = $s.g; name = $s.n; url = $s.u
            ok = $botBlocked; code = $c
            note = if ($botBlocked) { '可达但挡爬虫（403/405/429）' } else { '网络不可达/超时' }
        }
    }
} -ThrottleLimit 12
$sw.Stop()

$results = @($results | Sort-Object group, @{Expression = { -not $_.ok }}, name)

if ($Json) {
    @{
        proxy = $proxy
        elapsedSec = [math]::Round($sw.Elapsed.TotalSeconds, 1)
        reachable = @($results | Where-Object { $_.ok }).Count
        total = $results.Count
        sites = $results
    } | ConvertTo-Json -Depth 6
    exit 0
}

"代理状态：$(if ($proxy.enabled) { "✅ 已启用 → $($proxy.server)" } else { "❌ 未启用（注册表里配置为 $($proxy.server)）" })"
if ($proxy.env) { "        环境变量代理：$($proxy.env)" }
""
$last = ''
foreach ($r in $results) {
    if ($r.group -ne $last) { if ($last) { "" }; "── $($r.group) ──"; $last = $r.group }
    $mark = if ($r.ok -and -not $r.note) { '✅' } elseif ($r.ok) { '⚠️' } else { '❌' }
    "  {0} {1,-28} {2}" -f $mark, $r.name, $(if ($r.note) { $r.note } else { "HTTP $($r.code)" })
}
""
$okc = @($results | Where-Object { $_.ok }).Count
"可达 $okc / $($results.Count)   （耗时 $([math]::Round($sw.Elapsed.TotalSeconds,1))s）"
if (-not $proxy.enabled) {
    ""
    "提示：上面 ❌ 的站点多是外网。**用户启用代理后重跑本脚本**，会出现一批新可达的站点。"
}
