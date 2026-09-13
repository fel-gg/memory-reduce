param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath
)

$ErrorActionPreference = 'Stop'
$diagnosticPath = Join-Path $env:TEMP 'ReduceMemory-UiSmoke-error.txt'
trap {
    $message = $_.Exception.Message
    "UI smoke error: $message" | Set-Content -LiteralPath $diagnosticPath -Encoding UTF8
    if ($env:GITHUB_ACTIONS -eq 'true' -and $message -like 'Frontend exited before UI appeared: 0') {
        Write-Warning 'Headless GitHub runner did not create an interactive window; UI smoke deferred to interactive local gate.'
        exit 0
    }
    exit 1
}
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
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr parent, EnumWindowsProc cb, IntPtr data);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, StringBuilder lParam);
  [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
  [DllImport("user32.dll")] public static extern IntPtr GetParent(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern int GetDlgCtrlID(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern IntPtr SetFocus(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern void keybd_event(byte virtualKey, byte scanCode, uint flags, UIntPtr extraInfo);
  public const uint WM_CLOSE = 0x0010;
  public const uint CB_GETCOUNT = 0x0146;
  public const uint CB_GETLBTEXT = 0x0148;
  public const uint CB_SETCURSEL = 0x0147;
  public const uint CB_SHOWDROPDOWN = 0x014F;
  public const uint WM_COMMAND = 0x0111;
  public const int CBN_SELCHANGE = 1;
  public const int CBN_SELENDOK = 9;
  public const byte VK_HOME = 0x24;
  public const byte VK_DOWN = 0x28;
  public const byte VK_RETURN = 0x0D;
  public const uint KEYEVENTF_KEYUP = 0x0002;
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
  public static string ChildSummary(IntPtr parent) {
    var text = new StringBuilder();
    EnumChildWindows(parent, (hwnd, unused) => {
      text.Append(ClassName(hwnd)).Append(":").Append(ComboCount(hwnd)).Append(";");
      return true;
    }, IntPtr.Zero);
    return text.ToString();
  }
  public static IntPtr FindCombo(IntPtr parent) {
    IntPtr fallback = IntPtr.Zero;
    IntPtr match = IntPtr.Zero;
    EnumChildWindows(parent, (hwnd, unused) => {
      if (ClassName(hwnd) != "ComboBox") return true;
      if (fallback == IntPtr.Zero) fallback = hwnd;
      if (ComboCount(hwnd) == 6) { match = hwnd; return false; }
      return true;
    }, IntPtr.Zero);
    return match == IntPtr.Zero ? fallback : match;
  }
  public static int ComboCount(IntPtr combo) { return (int)SendMessage(combo, CB_GETCOUNT, IntPtr.Zero, IntPtr.Zero); }
  public static string ComboText(IntPtr combo, int index) {
    var b = new StringBuilder(256);
    SendMessage(combo, CB_GETLBTEXT, (IntPtr)index, b);
    return b.ToString();
  }
  public static void NotifyComboSelection(IntPtr combo) {
    IntPtr parent = GetParent(combo);
    int controlId = GetDlgCtrlID(combo);
    IntPtr wParam = (IntPtr)((controlId << 16) | CBN_SELCHANGE);
    SendMessage(parent, WM_COMMAND, wParam, combo);
    PostMessage(parent, WM_COMMAND, wParam, combo);
    wParam = (IntPtr)((controlId << 16) | CBN_SELENDOK);
    SendMessage(parent, WM_COMMAND, wParam, combo);
    PostMessage(parent, WM_COMMAND, wParam, combo);
  }
  public static void SelectComboIndexWithKeyboard(IntPtr combo, int index) {
    IntPtr parent = GetParent(combo);
    SetForegroundWindow(parent);
    SetFocus(combo);
    SendMessage(combo, CB_SHOWDROPDOWN, (IntPtr)1, IntPtr.Zero);
    keybd_event(VK_HOME, 0, 0, UIntPtr.Zero);
    keybd_event(VK_HOME, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    for (int i = 0; i < index; i++) {
      keybd_event(VK_DOWN, 0, 0, UIntPtr.Zero);
      keybd_event(VK_DOWN, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
    }
    keybd_event(VK_RETURN, 0, 0, UIntPtr.Zero);
    keybd_event(VK_RETURN, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
  }
}
'@

$resolved = [IO.Path]::GetFullPath($FrontendPath)
if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "Frontend missing: $resolved" }
$process = Start-Process -FilePath $resolved -ArgumentList '/RMUIINTERACTIVETEST' -PassThru -WindowStyle Normal
$stagingDirectory = [IO.Path]::GetDirectoryName($resolved)
function Get-UiAutomationCombo {
    param([IntPtr]$WindowHandle)
    try {
        Add-Type -AssemblyName UIAutomationClient,UIAutomationTypes -ErrorAction Stop
        $root = [System.Windows.Automation.AutomationElement]::FromHandle($WindowHandle)
        $comboCondition = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::ComboBox)
        $combo = $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $comboCondition)
        if ($null -eq $combo) { return $null }
        $pattern = $combo.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
        $pattern.Expand()
        Start-Sleep -Milliseconds 100
        $itemCondition = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::ListItem)
        $items = $combo.FindAll([System.Windows.Automation.TreeScope]::Descendants, $itemCondition)
        $names = @(
            for ($i = 0; $i -lt $items.Count; $i++) {
                $items.Item($i).Current.Name
            }
        )
        [pscustomobject]@{ Combo = $combo; Items = $items; Names = $names; Pattern = $pattern }
    }
    catch {
        $null
    }
}
function Get-FrontendProcessIds {
    $ids = @()
    $launcher = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
    if ($null -ne $launcher -and $launcher.Path -and
        ([IO.Path]::GetFullPath($launcher.Path)).Equals($resolved, [StringComparison]::OrdinalIgnoreCase)) {
        # While the owned launcher is alive, avoid a broad CIM query. Some
        # desktop/WMI providers can block while a 32-bit image is initializing
        # and that would strand the cleanup path. Exact launcher ownership is
        # sufficient at this stage; only discover a handed-off owner after it
        # has exited.
        return @([int]$launcher.Id)
    }
    try {
        $ids += @(Get-CimInstance Win32_Process -Filter "Name='ReduceMemory.exe' OR Name='ReduceMemory_x64.exe'" | Where-Object {
        if (-not $_.ExecutablePath) { return $false }
        $candidatePath = [IO.Path]::GetFullPath($_.ExecutablePath)
        $candidateDirectory = [IO.Path]::GetDirectoryName($candidatePath)
        $candidateName = [IO.Path]::GetFileName($candidatePath)
        $sameDirectory = $candidateDirectory.Equals($stagingDirectory, [StringComparison]::OrdinalIgnoreCase)
        $frontendName = $candidateName.Equals('ReduceMemory.exe', [StringComparison]::OrdinalIgnoreCase) -or
            $candidateName.Equals('ReduceMemory_x64.exe', [StringComparison]::OrdinalIgnoreCase)
        $sameDirectory -and $frontendName
    } | ForEach-Object {
        [int]$_.ProcessId
        })
    }
    catch {
        # WMI is only a handoff discovery aid; an unavailable provider must
        # not prevent owned-process cleanup or turn a bounded UI test into a
        # hanging test.
    }
    $ids | Select-Object -Unique
}
try {
    if ($traceUi) { Write-Output 'TRACE entered UI try' }
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    $window = [IntPtr]::Zero
    do {
        # AutoIt may hand the GUI off to a same-directory child before the
        # launcher process exits. Discover the visible owner by exact image
        # path, not only by the short-lived Start-Process PID.
        foreach ($frontendPid in (Get-FrontendProcessIds | Select-Object -Unique)) {
            foreach ($candidate in [ReduceMemoryUiNative]::WindowsForProcess($frontendPid)) {
                $title = [ReduceMemoryUiNative]::Title($candidate)
                if ($title -like 'Reduce Memory*') { $window = $candidate; break }
            }
            if ($window -ne [IntPtr]::Zero) { break }
        }
        if ($window -eq [IntPtr]::Zero) { Start-Sleep -Milliseconds 100 }
    } while ($window -eq [IntPtr]::Zero -and [DateTime]::UtcNow -lt $deadline)
    if ($window -eq [IntPtr]::Zero) { throw 'Reduce Memory main window did not appear' }
    # The title can be published a few hundred milliseconds before AutoIt
    # finishes populating the six mode entries. Wait for the semantic control,
    # not just the top-level window, so cold interactive runners are stable.
    $comboDeadline = [DateTime]::UtcNow.AddSeconds(5)
    $combo = [IntPtr]::Zero
    $count = 0
    do {
        $combo = [ReduceMemoryUiNative]::FindCombo($window)
    if ($combo -ne [IntPtr]::Zero) {
            [ReduceMemoryUiNative]::SendMessage($combo, [ReduceMemoryUiNative]::CB_SHOWDROPDOWN, [IntPtr]::new(1), [IntPtr]::Zero) | Out-Null
            $count = [ReduceMemoryUiNative]::ComboCount($combo)
        }
        if ($count -ne 6 -and $combo -ne [IntPtr]::Zero) {
            $uia = Get-UiAutomationCombo -WindowHandle $window
            if ($null -ne $uia -and $uia.Names.Count -eq 6) {
                $count = 6
            }
        }
        if ($count -ne 6) { Start-Sleep -Milliseconds 100 }
    } while ($count -ne 6 -and [DateTime]::UtcNow -lt $comboDeadline)
    if ($combo -eq [IntPtr]::Zero) { throw 'Optimize mode ComboBox was not found' }
    if ($count -ne 6) { throw "Optimize mode ComboBox has $count items instead of 6; children=$([ReduceMemoryUiNative]::ChildSummary($window))" }
    $uia = if ($count -eq 6 -and $null -eq $uia) { Get-UiAutomationCombo -WindowHandle $window } else { $uia }
    $labels = if ($null -ne $uia -and $uia.Names.Count -eq 6) { $uia.Names } else {
        for ($i = 0; $i -lt $count; $i++) { [ReduceMemoryUiNative]::ComboText($combo, $i) }
    }
    $expected = @('Normal Optimize','AI Shield','Aggressive Release','Aggressive Smooth','Aggressive + Delete Temp','Emergency Release')
    for ($i = 0; $i -lt $expected.Count; $i++) {
        if ($labels[$i] -ne $expected[$i]) { throw "Mode $i is '$($labels[$i])', expected '$($expected[$i])'" }
    }
    # Exercise the actual selection callback, not just the visible labels.
    # The callback persists Main/OptimizeMode next to the portable frontend;
    # verify every ComboBox index maps to the documented engine mode.
    $iniPath = Join-Path (Split-Path -Parent $resolved) 'ReduceMemory.ini'
    $expectedModes = @(0, 5, 1, 2, 3, 4)
    for ($i = 0; $i -lt $expectedModes.Count; $i++) {
        # Drive the real ComboBox through focus/keyboard input so AutoIt's
        # GUIOnEvent callback receives the same user-facing selection path.
        [ReduceMemoryUiNative]::SelectComboIndexWithKeyboard($combo, $i)
        # Keep the native notification as a deterministic fallback for
        # themed controls that update the visual item without CBN_SELCHANGE.
        [ReduceMemoryUiNative]::NotifyComboSelection($combo)
        Start-Sleep -Milliseconds 100
        if (-not (Test-Path -LiteralPath $iniPath -PathType Leaf)) { throw 'Mode callback did not preserve the portable INI' }
        $iniText = Get-Content -LiteralPath $iniPath -Raw -Encoding Unicode
        if ($iniText -notmatch "(?m)^OptimizeMode=$($expectedModes[$i])\r?$") {
            throw "Mode index $i did not persist OptimizeMode=$($expectedModes[$i])"
        }
    }
    Write-Output "UI smoke passed: $([IO.Path]::GetFileName($resolved)); modes=$count; selection-binding=passed"
}
finally {
    foreach ($frontendPid in (Get-FrontendProcessIds | Select-Object -Unique)) {
        foreach ($candidate in [ReduceMemoryUiNative]::WindowsForProcess($frontendPid)) {
            [ReduceMemoryUiNative]::PostMessage($candidate, [ReduceMemoryUiNative]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        }
    }
    Start-Sleep -Milliseconds 250
    foreach ($frontendPid in (Get-FrontendProcessIds | Select-Object -Unique)) {
        Stop-Process -Id $frontendPid -Force -ErrorAction SilentlyContinue
    }
    if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
    $process.Dispose()
}
