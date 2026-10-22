#requires -Version 7
<#
.SYNOPSIS
    批量渲染的桌面状态栏 —— 显示「已完成 / 总任务」，与批次进度实时同步。

.DESCRIPTION
    一个置顶的小窗，读批次写出的状态文件（默认 `<计划名>.progress.json`），每 400ms 刷新：

        已完成 3 / 12      [■■■■■□□□□□□□]  25%
        正在渲染：shot0010_c · 00:42
        成功 3 · 失败 0 · 总耗时 05:12

    🔴 它**只读**状态文件，不参与渲染、不写任何东西、不影响批次。
    批次崩了它也只是停在最后一个状态（不会假装成功）。

    本脚本由 `batch-render.ps1 -ProgressWindow` 自动拉起（隐藏控制台）；
    也可以手工启动来盯一个正在跑的批次。

.PARAMETER StatePath
    状态文件路径。默认 `<计划名>.progress.json`。

.PARAMETER AutoCloseSeconds
    批次结束后再过多少秒自动关闭（0 = 不自动关，默认 0）。

.PARAMETER TopMost
    是否置顶，默认是。

.EXAMPLE
    pwsh -STA -File ./progress-window.ps1 -StatePath ./batch/plan.progress.json
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 1)][string]$StatePath,
    [int]$AutoCloseSeconds = 0,
    [switch]$TopMost = $true
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$StatePath = [IO.Path]::GetFullPath($StatePath)

function Read-State {
    try {
        if (-not (Test-Path $StatePath)) { return $null }
        $raw = [IO.File]::ReadAllText($StatePath, [Text.Encoding]::UTF8)
        if (-not $raw.Trim()) { return $null }
        return $raw | ConvertFrom-Json
    } catch { return $null }
}

# ── UI ────────────────────────────────────────────────────────────────────
$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Width="440" SizeToContent="Height" WindowStyle="None" ResizeMode="NoResize"
        AllowsTransparency="True" Background="Transparent" ShowInTaskbar="True"
        Title="ComfyUI 批量渲染">
  <Border CornerRadius="14" Background="#0F1626" BorderBrush="#22D3EE" BorderThickness="1" Padding="18,14">
    <StackPanel>
      <!-- 标题行 -->
      <Grid Margin="0,0,0,10">
        <TextBlock x:Name="TxtTitle" Text="ComfyUI 批量渲染" Foreground="#E6EDF7"
                   FontFamily="Microsoft YaHei UI" FontSize="14" FontWeight="SemiBold"/>
        <Border x:Name="Pill" HorizontalAlignment="Right" CornerRadius="9" Background="#1B2A44" Padding="9,2">
          <TextBlock x:Name="TxtPill" Text="等待中" Foreground="#7DD3FC" FontSize="11"
                     FontFamily="Microsoft YaHei UI"/>
        </Border>
      </Grid>

      <!-- 主数字：已完成 / 总任务 -->
      <StackPanel Orientation="Horizontal" Margin="0,0,0,6">
        <TextBlock x:Name="TxtDone" Text="0" Foreground="#22D3EE"
                   FontFamily="Consolas" FontSize="40" FontWeight="Bold"/>
        <TextBlock x:Name="TxtTotal" Text=" / 0" Foreground="#64748B"
                   FontFamily="Consolas" FontSize="40" FontWeight="Bold"/>
        <TextBlock x:Name="TxtPct" Text="   0%" Foreground="#94A3B8" VerticalAlignment="Bottom"
                   Margin="6,0,0,8" FontFamily="Consolas" FontSize="15"/>
      </StackPanel>

      <!-- 进度条 -->
      <Grid Height="10" Margin="0,0,0,12">
        <Border CornerRadius="5" Background="#1B2A44"/>
        <Border x:Name="BarFill" CornerRadius="5" Background="#22D3EE" HorizontalAlignment="Left" Width="0"/>
      </Grid>

      <!-- 当前项 -->
      <TextBlock x:Name="TxtCurrent" Text="等待批次启动…" Foreground="#CBD5E1" TextTrimming="CharacterEllipsis"
                 FontFamily="Microsoft YaHei UI" FontSize="12.5" Margin="0,0,0,4"/>
      <TextBlock x:Name="TxtDetail" Text="" Foreground="#64748B"
                 FontFamily="Microsoft YaHei UI" FontSize="11.5"/>
    </StackPanel>
  </Border>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$win = [Windows.Markup.XamlReader]::Load($reader)

$txtTitle = $win.FindName('TxtTitle')
$pill = $win.FindName('Pill')
$txtPill = $win.FindName('TxtPill')
$txtDone = $win.FindName('TxtDone')
$txtTotal = $win.FindName('TxtTotal')
$txtPct = $win.FindName('TxtPct')
$barFill = $win.FindName('BarFill')
$txtCurrent = $win.FindName('TxtCurrent')
$txtDetail = $win.FindName('TxtDetail')
$rootBorder = $win.Content

# 置顶 + 贴右下角
$win.Topmost = [bool]$TopMost
$work = [System.Windows.SystemParameters]::WorkArea
$win.Left = $work.Right - $win.Width - 28
$win.Top = $work.Bottom - 220

# 无边框窗口：按住拖动
$rootBorder.Add_MouseLeftButtonDown({ try { $win.DragMove() } catch { } })

$script:closing = $false
$win.Add_KeyDown({ if ($_.Key -eq 'Escape') { $win.Close() } })

function Update-Ui {
    $s = Read-State
    if (-not $s) {
        $txtPill.Text = '等待中'
        $txtCurrent.Text = '等待批次启动…'
        return
    }

    $total = [int]$s.total
    $done = [int]$s.done
    $pct = if ($total -gt 0) { [math]::Round(100.0 * $done / $total) } else { 0 }

    $txtDone.Text = [string]$done
    $txtTotal.Text = " / $total"
    $txtPct.Text = "   $pct%"

    # 进度条宽度（父容器宽度 - 0；用窗口内宽估算）
    $trackWidth = [Math]::Max(0, $win.Width - 40)
    $barFill.Width = [Math]::Max(0, $trackWidth * ($done / [Math]::Max(1, $total)))

    $phase = [string]$s.phase
    switch ($phase) {
        'running' { $txtPill.Text = '渲染中'; $txtPill.Foreground = '#7DD3FC'; $pill.Background = '#1B2A44' }
        'freeing' { $txtPill.Text = '清显存'; $txtPill.Foreground = '#FDE68A'; $pill.Background = '#33260F' }
        'restarting' { $txtPill.Text = '重启 ComfyUI'; $txtPill.Foreground = '#FCA5A5'; $pill.Background = '#3A1717' }
        'done' { $txtPill.Text = '全部完成'; $txtPill.Foreground = '#6EE7B7'; $pill.Background = '#0F2B22'; $barFill.Background = '#34D399' }
        'partial' { $txtPill.Text = '部分失败'; $txtPill.Foreground = '#FDBA74'; $pill.Background = '#3A2410' }
        'failed' { $txtPill.Text = '全部失败'; $txtPill.Foreground = '#FCA5A5'; $pill.Background = '#3A1717'; $barFill.Background = '#F87171' }
        'aborted' { $txtPill.Text = '已中止'; $txtPill.Foreground = '#FCA5A5'; $pill.Background = '#3A1717' }
        default { $txtPill.Text = [string]$s.statusText }
    }

    if ($s.current) {
        $txtCurrent.Text = ("正在处理：{0}（第 {1}/{2} 项）" -f $s.current, [int]$s.currentIndex, $total)
    } elseif ($phase -in @('done', 'partial', 'failed', 'aborted')) {
        $txtCurrent.Text = "全部任务已结束"
    } else {
        # 没有「当前项」时按阶段说人话，别一律写「提交中」
        $txtCurrent.Text = switch ($phase) {
            'restarting' { '正在重启 ComfyUI（换进程，显存归零）…' }
            'freeing' { '正在清理显存…' }
            'running' { '提交下一项…' }
            'starting' { '准备中…' }
            default { [string]$s.statusText }
        }
    }

    $bits = @("成功 $([int]$s.ok)", "失败 $([int]$s.failed)")
    if ($null -ne $s.totalSeconds) { $bits += ("总耗时 {0}" -f ([TimeSpan]::FromSeconds([double]$s.totalSeconds)).ToString('hh\:mm\:ss')) }
    if ($s.startedAt) { $bits += "开始于 $($s.startedAt)" }
    $txtDetail.Text = ($bits -join '  ·  ')

    if ($phase -in @('done', 'partial', 'failed', 'aborted') -and $AutoCloseSeconds -gt 0 -and -not $script:closing) {
        $script:closing = $true
        $t = [Windows.Threading.DispatcherTimer]::new()
        $t.Interval = [TimeSpan]::FromSeconds($AutoCloseSeconds)
        $t.Add_Tick({ $t.Stop(); $win.Close() })
        $t.Start()
        $script:autoTimer = $t
    }
}

$timer = [Windows.Threading.DispatcherTimer]::new()
$timer.Interval = [TimeSpan]::FromMilliseconds(400)
$timer.Add_Tick({ try { Update-Ui } catch { } })
$timer.Start()

Update-Ui
[void]$win.ShowDialog()
