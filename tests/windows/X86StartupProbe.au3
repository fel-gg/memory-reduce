; Diagnostic-only staged x86 startup probe. Each marker is flushed so a
; bounded run can identify a runtime/API boundary without touching product
; state, registry settings, memory, or other processes.
#include <Crypt.au3>
Global $sMarker = @TempDir & "\ReduceMemory-x86-startup-probe-" & @AutoItPID & ".txt"

Func Mark($sValue)
	Local $h = FileOpen($sMarker, 1 + 8)
	If $h <> -1 Then
		FileWriteLine($h, $sValue)
		FileClose($h)
	EndIf
EndFunc

Mark("start")
AutoItWinSetTitle("ReduceMemory x86 startup probe")
Mark("title")
Local $sOsArch = Execute(" @OSArch ")
Mark("execute-osarch")
Local $oAutoItError = ObjEvent("AutoIt.Error", "ProbeError")
Mark("objevent")
Local $oDictionary = ObjCreate("Scripting.Dictionary")
Mark("objcreate-dictionary")
Local $hKernel = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", @AutoItExe, "ptr", 0, "dword", 2)
Mark("loadlibrary")
If IsArray($hKernel) And $hKernel[0] <> 0 Then DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hKernel[0])
Mark("freelibrary")
Local $hResources = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", @AutoItExe, "ptr", 0, "dword", 2)
If IsArray($hResources) And $hResources[0] <> 0 Then
	For $i = 1 To 30
		DllCall("user32.dll", "int", "LoadStringW", "handle", $hResources[0], "uint", $i, "wstr", "", "int", 4096)
	Next
	DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hResources[0])
EndIf
Mark("loadstring-resources")
Local $sReg = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Startup")
Mark("regread")
FileChangeDir(@ScriptDir)
Mark("changedir")
Local $sIni = IniRead(@ScriptDir & "\ReduceMemory.ini", "Main", "OptimizeMode", @LF)
Mark("iniread")
Local $sFixtureIni = @TempDir & "\ReduceMemory-x86-startup-probe.ini"
IniWrite($sFixtureIni, "Main", "Language", "Auto")
IniWrite($sFixtureIni, "Language_English", "Optimize", "Optimize")
Local $aSections = IniReadSectionNames($sFixtureIni)
Mark("ini-sections")
FileDelete($sFixtureIni)
Local $tSid = DllStructCreate("byte SID[256]")
Local $pSid = DllStructGetPtr($tSid)
Local $aSid = DllCall("advapi32.dll", "bool", "LookupAccountNameW", "wstr", "", "wstr", "SystemUser", "ptr", $pSid, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
Mark("sid-lookup")
Local $sConfig = @TempDir & "\ReduceMemory-x86-startup-probe-config.ini"
IniWrite($sConfig, "Main", "HideWindowOnStartup", "0")
IniWrite($sConfig, "Main", "Language", "Auto")
IniWrite($sConfig, "Language_English", "Optimize", "Optimize")
IniWrite($sConfig, "Language_English", "Options", "Options")
For $i = 1 To 30
	IniRead($sConfig, "Language_English", "Key" & $i, "")
Next
Mark("config-language")
FileDelete($sConfig)
Local $aVersion = StringRegExp(@OSVersion, "_(XP|200(0|3))", 0)
Mark("regex")
Opt("GUIOnEventMode", 1)
Local $hWindow = GUICreate("ReduceMemory x86 UI probe", 420, 120)
Local $nCombo = GUICtrlCreateCombo("", 10, 20, 390, 25, 3)
GUICtrlSetData($nCombo, "Normal Optimize|AI Shield|Aggressive Release|Aggressive Smooth|Aggressive + Delete Temp|Emergency Release", "Normal Optimize")
GUISetState(@SW_SHOW, $hWindow)
Sleep(100)
Local $hCombo = GUICtrlGetHandle($nCombo)
Local $aCount = DllCall("user32.dll", "int", "SendMessageW", "hwnd", $hCombo, "uint", 326, "ptr", 0, "ptr", 0)
Mark("ui-combo-count=" & (IsArray($aCount) ? $aCount[0] : -1))
GUIDelete($hWindow)
Mark("ui-done")
Mark("done")
Exit 0

Func ProbeError($oError)
	Mark("autoit-error")
EndFunc
