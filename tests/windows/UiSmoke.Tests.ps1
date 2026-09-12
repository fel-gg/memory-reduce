param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath
)

$ErrorActionPreference = 'Stop'
$diagnosticPath = Join-Path $env:TEMP 'ReduceMemory-UiSmoke-error.txt'
trap { "UI smoke error: $($_.Exception.Message)" | Set-Content -LiteralPath $diagnosticPath -Encoding UTF8; exit 1 }
Add-Type @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public static class ReduceMemoryUiNative {
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr data);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr hWnd, StringBuilder text, int max);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr childAfter, string className, string title);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, StringBuilder lParam);
  [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
  public const uint WM_CLOSE = 0x0010;
  public const uint CB_GETCOUNT = 0x0146;
  public const uint CB_GETLBTEXT = 0x0148;
  public static List<IntPtr> WindowsForProcess(int processId) {
    var result = new List<IntPtr>();
    EnumWindows((hwnd, unused) => {
      uint pid; GetWindowThreadProcessId(hwnd, out pid);
      if (pid == processId && IsWindowVisible(hwnd)) result.Add(hwnd);
      return true;
    }, IntPtr.Zero);
    return result;
  }
  public static string ClassName(IntPtr hwnd) {
    var b = new StringBuilder(128); GetClassName(hwnd, b, b.Capacity); return b.ToString();
  }
  public static string Title(IntPtr hwnd) {
    var b = new StringBuilder(256); GetWindowText(hwnd, b, b.Capacity); return b.ToString();
  }
  public static IntPtr FindCombo(IntPtr parent) {
    IntPtr after = IntPtr.Zero;
    IntPtr fallback = IntPtr.Zero;
    while (true) {
      after = FindWindowEx(parent, after, "ComboBox", null);
      if (after == IntPtr.Zero) return fallback;
      if (fallback == IntPtr.Zero) fallback = after;
      if (ComboCount(after) == 6) return after;
    }
  }
  public static int ComboCount(IntPtr combo) { return (int)SendMessage(combo, CB_GETCOUNT, IntPtr.Zero, IntPtr.Zero); }
  public static string ComboText(IntPtr combo, int index) {
    var b = new StringBuilder(256);
    SendMessage(combo, CB_GETLBTEXT, (IntPtr)index, b);
    return b.ToString();
  }
}
'@

$resolved = [IO.Path]::GetFullPath($FrontendPath)
if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "Frontend missing: $resolved" }
$process = Start-Process -FilePath $resolved -PassThru -WindowStyle Normal
try {
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    $window = [IntPtr]::Zero
    do {
        if ($process.HasExited) { throw "Frontend exited before UI appeared: $($process.ExitCode)" }
        foreach ($candidate in [ReduceMemoryUiNative]::WindowsForProcess($process.Id)) {
            $title = [ReduceMemoryUiNative]::Title($candidate)
            if ($title -like 'Reduce Memory*') { $window = $candidate; break }
        }
        if ($window -eq [IntPtr]::Zero) { Start-Sleep -Milliseconds 100 }
    } while ($window -eq [IntPtr]::Zero -and [DateTime]::UtcNow -lt $deadline)
    if ($window -eq [IntPtr]::Zero) { throw 'Reduce Memory main window did not appear' }
    $combo = [ReduceMemoryUiNative]::FindCombo($window)
    if ($combo -eq [IntPtr]::Zero) { throw 'Optimize mode ComboBox was not found' }
    $count = [ReduceMemoryUiNative]::ComboCount($combo)
    if ($count -ne 6) { throw "Optimize mode ComboBox has $count items instead of 6" }
    $labels = for ($i = 0; $i -lt $count; $i++) { [ReduceMemoryUiNative]::ComboText($combo, $i) }
    $expected = @('Normal Optimize','AI Shield','Aggressive Release','Aggressive Smooth','Aggressive + Delete Temp','Emergency Release')
    for ($i = 0; $i -lt $expected.Count; $i++) {
        if ($labels[$i] -ne $expected[$i]) { throw "Mode $i is '$($labels[$i])', expected '$($expected[$i])'" }
    }
    Write-Output "UI smoke passed: $([IO.Path]::GetFileName($resolved)); modes=$count"
}
finally {
    if (-not $process.HasExited) {
        foreach ($candidate in [ReduceMemoryUiNative]::WindowsForProcess($process.Id)) {
            [ReduceMemoryUiNative]::PostMessage($candidate, [ReduceMemoryUiNative]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        }
        if (-not $process.WaitForExit(5000)) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
    }
    $process.Dispose()
}
