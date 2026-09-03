; Reconstructed application source
#NoTrayIcon
If Not IsDeclared ( "Os" ) Then Global $OS
; String table inlined during verified static extraction
Global $A3380B02A2C = "MustDeclareVars" , $A2790402500 = "GUI_RUNDEFMSG" , $A0B90601C20 = "GUIDataSeparatorChar" , $A5B90705434 = "WinDetectHiddenText" , $A1090900A56 = "1.7" , $A3A90B05762 = "ReduceMemory" , $A4890D04726 = "Reduce Memory" , $A36A0000608 = " - Author by BlueLife" , $A0CA0202515 = "[CLASS:_MReduce:v" , $A58A030490B = "]" , $A19A050611A = "2013-2024" , $A1FA0B0155D = " @UserName " , $A30A0F0565F = " @Compiled " , $A14B0102331 = " @AutoItExe " , $A19B0303F03 = " @OSArch " , $A1FB050530A = " @AutoItX64 " , $A24B0704245 = " @AutoItPID " , $A41B0904162 = " @OSVersion " , $A4EB0B05206 = "AutoIt.Error" , $A53B0E04938 = "_(XP|200(0|3))" , $A42C0005F35 = " @WindowsDir " , $A34C0203522 = "System32\" , $A17C0505B2A = " @WorkingDir " , $A48C0804D4D = "kernel32.dll" , $A23C0A04F06 = "user32.dll" , $A0CC0C01F2E = "advapi32.dll" , $A55C0E01626 = "shell32.dll" , _
$A16D000163E = "ole32.dll" , $A57D020482F = "comctl32.dll" , $A54D0402622 = "gdi32.dll" , $A0BD0604C48 = "psapi.dll" , $A34D090231C = " @ScriptDir " , $A18D0B05E2E = "Icons\" , $A12D0D0163B = ".ini" , $A5CE0702436 = "HideWindowOnStartup" , $A4DE0905E47 = "HideWhenMinimized" , $A54E0B00A4B = "WinSetOnTop" , $A05E0D01131 = "SystemUser" , $A63E0F04B1C = "TrayIconPack" , $A45F020231C = "TaskOptions" , $A5EF040325E = "UsedMemory" , $A27F050091E = "75%" , $A57F0603C63 = "[^0-9]" , $A26F080043F = "CountDown" , $A25F0A03415 = "ExclusionOpt" , $A2AF0C0551E = "Main" , $A2DF0D02906 = "Exclusions" , $A07F0F00236 = "Main" , $A3001000F39 = "Processes" , $A1C0130371A = "HKLM" , $A0601502317 = "HKCU" , $A2001601838 = "64" , $A1C0170504E = "64" , $A0E01E04600 = "Tahoma"
; Reduce Memory project version (the original table entry is retained for provenance)
$A1090900A56 = "2.8"
Opt ( $A3380B02A2C , 1 )
Global Const $A4080C05448 = Chr ( 92 )
Global Const $A2280D04544 = Chr ( 47 )
Global Const $A5580E05E46 = Chr ( 124 )
Global Const $A2F80F00960 = Chr ( 32 )
Global Const $A1190005358 = Chr ( 44 )
Global Const $A0B9010005E = ""
Global Const $A5E9020403B = Chr ( 37 )
Global Const $A029030512B = $A2790402500
Global Const $A5490503D47 = $A5580E05E46
Opt ( $A0B90601C20 , $A5490503D47 )
Opt ( $A5B90705434 , 1 )
Global Const $A4990803F52 = $A1090900A56
Global Const $A0590A02503 = $A3A90B05762
Global Const $A1990C05A0F = $A4890D04726
Global Const $A2A90E0262F = $A1990C05A0F & $A2F80F00960 & Chr ( 118 ) & $A4990803F52
Global Const $A3890F00800 = String ( $A2A90E0262F & $A36A0000608 )
Global Const $A23A0102302 = $A0CA0202515 & $A4990803F52 & $A58A030490B
Global Const $A2FA0403447 = $A19A050611A
Global $A59A0605008 , $A02A0704B51 , $A17A0803B53
Global $A28A0903157 [ 1 ] = [ 0 ]
Global $A2847903C1A = 0
AutoItWinSetTitle ( $A2A90E0262F )
Global Const $A0AA0A03206 = Execute ( $A1FA0B0155D )
Global Const $A2FA0C0483E = Number ( IsAdmin ( ) )
Global $A36A0D00C59 = Number ( $CMDLINE [ 0 ] <> 0 )
Global Const $A1BA0E00F18 = Execute ( $A30A0F0565F )
Global Const $A5BB0001B63 = Execute ( $A14B0102331 )
Global Const $A1FB020470A = Execute ( $A19B0303F03 )
Global Const $A38B0402436 = Execute ( $A1FB050530A )
Global Const $A26B0601541 = Execute ( $A24B0704245 )
Global Const $A62B0800A26 = Execute ( $A41B0904162 )
Global Const $A00B0A03B04 = ObjEvent ( $A4EB0B05206 , "A1080A02460" )
Global Const $A43B0C04E3E = A243000135D ( )
Global Const $A00B0D02000 = StringRegExp ( $A62B0800A26 , $A53B0E04938 )
Global $A4CB0F0301B = Execute ( $A42C0005F35 )
If StringRight ( $A4CB0F0301B , 1 ) <> $A4080C05448 Then $A4CB0F0301B &= $A4080C05448
Global Const $A46C010293E = $A4CB0F0301B & $A34C0203522
Global Const $A02C0302F27 = StringLeft ( $A4CB0F0301B , 3 )
Global $A37C0403901 = Execute ( $A17C0505B2A )
If StringRight ( $A37C0403901 , 1 ) <> $A4080C05448 Then $A37C0403901 &= $A4080C05448
FileChangeDir ( $A4CB0F0301B )
Global Const $A55C0605F44 = A1B20E03435 ( $A5BB0001B63 , 0 )
Global Const $A55C0703122 = A1B20E03435 ( $A48C0804D4D , 1 )
Global Const $A49C090200E = A1B20E03435 ( $A23C0A04F06 , 1 )
Global Const $A0FC0B04231 = A1B20E03435 ( $A0CC0C01F2E , 1 )
Global Const $A25C0D03223 = A1B20E03435 ( $A55C0E01626 , 0 )
Global Const $A5BC0F03109 = A1B20E03435 ( $A16D000163E , 1 )
Global Const $A4DD0103C1A = A1B20E03435 ( $A57D020482F , 0 )
Global Const $A0AD0306025 = A1B20E03435 ( $A54D0402622 , 0 )
Global $A29D0503B5E = A1B20E03435 ( $A0BD0604C48 , 1 )
FileChangeDir ( $A37C0403901 )
Global Const $A38D0702849 = A4840802826 ( $A0AA0A03206 )
Global $A47D0805C4F = Execute ( $A34D090231C )
If StringRight ( $A47D0805C4F , 1 ) <> $A4080C05448 Then $A47D0805C4F &= $A4080C05448
Global $A0CD0A02F1D = $A47D0805C4F & $A18D0B05E2E
Global $A45D0C00410 = A1820D05F0C ( $A0590A02503 & $A12D0D0163B , 0 )
Global $A39D0E0415B = A2C50D04958 ( )
If A3A60006249 ( ) = 0 Then
EndIf
Global $A50D0F02863 = A495010444D ( )
Global $A3AE0005046 = A0E50304D18 ( )
Global $A60E0103904
Global $A1BE0205A29
Global $A2DE030231E [ $A39D0E0415B [ 0 ] + 1 ] [ 4 ] = [ [ $A39D0E0415B [ 0 ] ] ]
Global $A16E0404946
Global $A45E0501D47 = 0
Global $A43E0600648 = A5560304940 ( $A5CE0702436 , 0 )
Global $A2BE0802D2F = A5560304940 ( $A4DE0905E47 , 1 )
Global $A2FE0A05C11 = A5560304940 ( $A54E0B00A4B , 1 )
Global $A38E0C03950 = A5560304940 ( $A05E0D01131 , 1 )
Global $A01E0E06159 = A5560304940 ( $A63E0F04B1C , 1 , 0 , 3 )
If $A01E0E06159 > 3 Then $A01E0E06159 = 1
Global $A49F0002638 = - 1
Global $A1AF0101F06 = A5560304940 ( $A45F020231C , 0 )
Global $A38F0304C08 = A3560501B29 ( $A5EF040325E , $A27F050091E )
$A38F0304C08 = Int ( Number ( StringRegExpReplace ( $A38F0304C08 , $A57F0603C63 , $A0B9010005E ) ) )
If $A38F0304C08 < 25 Or $A38F0304C08 > 100 Then $A38F0304C08 = 75
Global $A37F0703A24 = Int ( Number ( A3560501B29 ( $A26F080043F , 15 ) ) )
If $A37F0703A24 < 3 Then $A37F0703A24 = 3
If StringLen ( $A37F0703A24 ) > 5 Then $A37F0703A24 = Number ( StringLeft ( $A37F0703A24 , 5 ) )

; Adaptive optimizer controls.  Missing keys keep the safe defaults so old
; ReduceMemory.ini files remain fully compatible.
Global $RM_SmartOptimize = A5560304940 ( "SmartOptimize" , 1 , 0 , 1 )
Global $RM_CooldownSeconds = RM_ReadBoundedInt ( "CooldownSeconds" , 300 , 30 , 86400 )
Global $RM_HysteresisPercent = RM_ReadBoundedInt ( "HysteresisPercent" , 5 , 1 , 20 )
Global $RM_MinProcessMB = RM_ReadBoundedInt ( "MinProcessMB" , 32 , 4 , 4096 )
; Profile-specific floors keep Normal genuinely light while preserving
; MinProcessMB as the compatible baseline for existing INI files. Aggressive
; deliberately keeps its own low floor so it has a broader candidate set.
Global $RM_NormalMinProcessMB = RM_ReadBoundedInt ( "NormalMinProcessMB" , 96 , 16 , 4096 )
Global $RM_SmoothMinProcessMB = RM_ReadBoundedInt ( "SmoothMinProcessMB" , 48 , 8 , 4096 )
Global $RM_AggressiveMinProcessMB = RM_ReadBoundedInt ( "AggressiveMinProcessMB" , 4 , 4 , 4096 )
Global $RM_AIShieldMinProcessMB = RM_ReadBoundedInt ( "AIShieldMinProcessMB" , 64 , 16 , 4096 )
Global $RM_ProtectForeground = A5560304940 ( "ProtectForeground" , 1 , 0 , 1 )
Global $RM_LastAutoOptimize = 0
Global $RM_PressureArmed = 1
Global $RM_AutoTrigger = 0
Global Const $RM_MODE_NORMAL = 0
Global Const $RM_MODE_AGGRESSIVE = 1
Global Const $RM_MODE_SMOOTH = 2
Global Const $RM_MODE_TEMP = 3
Global Const $RM_MODE_EMERGENCY = 4
Global Const $RM_MODE_AI_SHIELD = 5
Global Const $RM_MODE_OPTIONS = "Normal Optimize|AI Shield|Aggressive Release|Aggressive Smooth|Aggressive + Delete Temp|Emergency Release"
Global Const $RM_PROFILE_NORMAL = 0
Global Const $RM_PROFILE_SMOOTH = 1
Global Const $RM_PROFILE_AGGRESSIVE = 2
Global Const $RM_PROFILE_EMERGENCY = 3
Global Const $RM_PROFILE_AI_SHIELD = 4
Global $RM_OptimizeMode = $RM_MODE_NORMAL
Global $RM_ModeControl = 0
Global $RM_LastAggressiveDetail = ""
Global $RM_LastAggressiveOk = 0
Global $RM_LastTrimReleasedBytes = 0
Global $RM_LastProcessTrimMB = 0
Global $RM_LastTrimmedCount = 0
Global $RM_WorkerTotalTrimmed = 0
Global $RM_WorkerTotalReleasedBytes = 0
Global $RM_WorkerNativeSteps = 0
Global $RM_WorkerPasses = 0
Global $RM_WorkerAvailableGainKB = 0
Global $RM_LastWorkerTrimmed = 0
Global $RM_LastWorkerReleasedBytes = 0
Global $RM_LastWorkerNativeSteps = 0
Global $RM_LastWorkerPasses = 0
Global $RM_LastWorkerAvailableGainKB = 0
Global $RM_LastNativeStageTarget = 0
Global $RM_RecentActivePID = 0
Global $RM_RecentActiveAt = 0
Global $RM_LastObservedActivePID = 0
Global $RM_CPUShieldPIDs = "|"
Global $RM_AIShieldEnabled = A5560304940 ( "AIShield" , 1 , 0 , 1 )
Global $RM_AIProcessPatterns = A3560501B29 ( "AIProcessPatterns" , "ollama.exe|ollama_llama_server.exe|python.exe|pythonw.exe|llama-server.exe|llama.exe|vllm.exe|torchrun.exe|tritonserver.exe|comfyui.exe|stable-diffusion.exe|local-ai.exe|koboldcpp.exe" )
Global $RM_AIProtectedCount = 0
Global $RM_AIShieldPIDs = "|"
Global $RM_ActiveShieldSeconds = RM_ReadBoundedInt ( "ActiveShieldSeconds" , 10 , 3 , 60 )
Global $RM_StablePending = 0
Global $RM_StableBeforeFree = 0
Global $RM_StableStartedAt = 0
Global $RM_ImmediateGainMB = 0
Global $RM_StablePressureText = ""
Global $RM_LastModeName = "Normal Optimize"
Global $RM_ReboundAt = 0
Global $RM_ReboundCooldownSeconds = 60
; Startup is a separate silent Normal pass plus a tiny pressure monitor. It
; never runs an elevated/native memory-list purge, so Windows login does not
; produce a UAC prompt or an Emergency-mode stutter. The monitor only re-arms
; after pressure falls below the lower watermark.
Global $RM_StartupMonitorThreshold = RM_ReadBoundedInt ( "StartupMonitorThreshold" , 95 , 80 , 99 )
Global $RM_StartupMonitorHysteresis = RM_ReadBoundedInt ( "StartupMonitorHysteresis" , 5 , 1 , 15 )
Global $RM_StartupMonitorIntervalSeconds = RM_ReadBoundedInt ( "StartupMonitorIntervalSeconds" , 2 , 1 , 60 )
Global $RM_StartupMonitorCooldownSeconds = RM_ReadBoundedInt ( "StartupMonitorCooldownSeconds" , 300 , 60 , 3600 )
Global $RM_StartupDelaySeconds = RM_ReadBoundedInt ( "StartupDelaySeconds" , 10 , 0 , 120 )
Global $RM_StartupConfirmSamples = RM_ReadBoundedInt ( "StartupConfirmSamples" , 2 , 2 , 10 )
Global $A3FF090012D = A5560304940 ( $A25F0A03415 , 1 , 0 , 1 )
Global $A1DF0B03725 = A1160200452 ( $A45D0C00410 , $A2AF0C0551E , $A2DF0D02906 , $A5580E05E46 )
$A1DF0B03725 = A5720304C54 ( $A1DF0B03725 , 1 )
Global $A10F0E03A56 = A1160200452 ( $A45D0C00410 , $A07F0F00236 , $A3001000F39 , $A5580E05E46 )
$A10F0E03A56 = A5720304C54 ( $A10F0E03A56 , 1 )
Global $A4301102A51 = A1140704D17 ( A4B40E03D32 ( ) < 1536 , 1280 , 4352 )
Global $A3C0120540E = $A1C0130371A
Global $A5101402158 = $A0601502317
If $A43B0C04E3E = 1 Then
	$A3C0120540E &= $A2001601838
	$A5101402158 &= $A1C0170504E
EndIf
Global $A3201805C5F = $A5101402158
Local $A2601902115 = 0
RM_HandleCommandLine ( )
If $A38E0C03950 = 1 And $A2FA0C0483E = 1 And $A1BA0E00F18 = 1 And $A38D0702849 = 0 Then
	Local $A1401A05743 = A6230A05C33 ( $A5BB0001B63 , $CMDLINERAW , $A4CB0F0301B )
	If ProcessExists ( $A1401A05743 ) <> 0 Then Exit
EndIf
Global $A0601B0172A = A0E40403845 ( )
If $A0601B0172A <> $A0AA0A03206 Then $A3201805C5F = A0740A00E53 ( $A0601B0172A , $A5101402158 )
Global $A1801C02855 = A0B10B00E07 ( )
Global $A2E01D02B1C = $A0E01E04600
Global $A6301F02853 = A4430402519 ( 10 , 10 )
Global $A2811001E12 = A4430402519 ( 8.5 )
Global $A3611106234 = 420 , $A5511204129 = 235
Global $A6111305636 , $A3F11404954 , $A0C11503D1C , $A5A11601452 , $A3411700721
Global $A3E11805638 = 1
Global $A5D11902426 [ 4 ]
Global $A5211A05C62 [ 5 ]
Global $A2311B0565F
Global $A4711C0341E = 0
Global $A3411D0002B [ 6 ] = [ 5 ]
Global $A5F11E00002 , $A5B11F00549 , $A3021000C60 , $A4B21101353
Global $A3C21204863 , $A2221302C07 , $A0921401758 , $A262150561E
RM_RunMainWindow ( )
Exit
Func RM_RunMainWindow ( )
	If Not IsDeclared ( "SSRM_RunMainWindow" ) Then
		Global $A462160023C = "GUIOnEventMode" , $A4221704B05 = "GUIResizeMode" , $A3B21805E0C = "GUICloseOnESC" , $A0E21A05814 = "..." , $A1521B02F4F = "..." , $A3F21C04544 = "..." , $A4921D0244C = "01.png" , $A0921E04E55 = "02.png" , $A0621F03120 = "03.png" , $A093100290E = "04.png" , $A1A31200525 = "{F1}" , $A4131302140 = "{F5}" , $A243140333E = "TrayOnEventMode" , $A3331506247 = "TrayMenuMode" , $A5931600305 = " @AutoItExe " , $A5831704B55 = "TrayIconHide" , $A1131804C3E = " @SW_HIDE " , $A0231904840 = " @SW_SHOW "
		Global $SSRM_RunMainWindow = 1
	EndIf
	A4720B0314B ( )
	Opt ( $A462160023C , 1 )
	Opt ( $A4221704B05 , 802 )
	Opt ( $A3B21805E0C , 0 )
	$A59A0605008 = GUICreate ( $A2A90E0262F , $A3611106234 , $A5511204129 , - 1 , - 1 )
	$RM_OptimizeMode = Int ( Number ( A3560501B29 ( "OptimizeMode" , $RM_MODE_NORMAL ) ) )
	If $RM_OptimizeMode < $RM_MODE_NORMAL Or $RM_OptimizeMode > $RM_MODE_AI_SHIELD Then $RM_OptimizeMode = $RM_MODE_NORMAL
	GUISetOnEvent ( - 3 , "RM_HandleWindowClose" )
	GUISetOnEvent ( - 4 , "RM_HandleWindowMinimize" )
	GUISetFont ( $A6301F02853 , 400 , 0 , $A2E01D02B1C )
	Local $A4621900D63 = GUICtrlCreateLabel ( 0 , - 50 , - 50 , 1 , 1 )
	GUICtrlSetResizing ( $A4621900D63 , 802 )
	GUICtrlCreateLabel ( $A3890F00800 , - 50 , - 50 , 400 , 200 , 0 )
	GUICtrlSetState ( - 1 , 128 )
	GUICtrlSetBkColor ( - 1 , - 2 )
	GUICtrlSetResizing ( - 1 , 102 )
	$A5F11E00002 = GUICtrlCreateGroup ( $A2F80F00960 , 10 , 10 , 265 , 98 )
	$A5B11F00549 = GUICtrlCreateLabel ( $A2F80F00960 , 20 , 35 , 190 , 20 )
	$A3411D0002B [ 1 ] = GUICtrlCreateLabel ( $A0E21A05814 , 210 , 35 , 55 , 20 , 2 )
	$A3021000C60 = GUICtrlCreateLabel ( $A2F80F00960 , 20 , 55 , 190 , 20 )
	$A3411D0002B [ 2 ] = GUICtrlCreateLabel ( $A1521B02F4F , 210 , 55 , 55 , 20 , 2 )
	$A4B21101353 = GUICtrlCreateLabel ( $A2F80F00960 , 20 , 75 , 190 , 20 )
	$A3411D0002B [ 3 ] = GUICtrlCreateLabel ( $A3F21C04544 , 210 , 75 , 55 , 20 , 2 )
	$A3411D0002B [ 4 ] = GUICtrlCreateLabel ( $A2F80F00960 , 10 , 113 , 265 , 20 , 512 )
	$A3411D0002B [ 5 ] = GUICtrlCreateProgress ( 10 , 133 , 265 , 22 , 128 )

	GUICtrlCreateLabel ( "Optimize mode:" , 10 , 170 , 105 , 20 )

	Local $RM_ModeDefault = RM_GetModeName ( )
	$RM_ModeControl = GUICtrlCreateCombo ( "" , 115 , 165 , 295 , 25 , 3 )
	GUICtrlSetData ( $RM_ModeControl , $RM_MODE_OPTIONS , $RM_ModeDefault )

	GUICtrlSetOnEvent ( $RM_ModeControl , "RM_ModeChanged" )
	$A3C21204863 = GUICtrlCreateButton ( $A2F80F00960 , 285 , 15 , 125 , 30 , 1 )
	GUICtrlSetFont ( $A3C21204863 , $A6301F02853 , 800 , 0 , $A2E01D02B1C )
	GUICtrlSetCursor ( $A3C21204863 , 0 )
	GUICtrlSetOnEvent ( $A3C21204863 , "RM_RunOptimize" )
	A4C70005146 ( $A3C21204863 , $A4921D0244C , 0 )
	$A2221302C07 = GUICtrlCreateButton ( $A2F80F00960 , 285 , 52 , 125 , 30 )
	GUICtrlSetCursor ( $A2221302C07 , 0 )
	GUICtrlSetOnEvent ( $A2221302C07 , "RM_ShowOptionsWindow" )
	A4C70005146 ( $A2221302C07 , $A0921E04E55 , 0 )
	$A0921401758 = GUICtrlCreateButton ( $A2F80F00960 , 285 , 89 , 125 , 30 )
	GUICtrlSetCursor ( $A0921401758 , 0 )
	GUICtrlSetOnEvent ( $A0921401758 , "RM_ShowAboutWindow" )
	A4C70005146 ( $A0921401758 , $A0621F03120 , 0 )
	$A262150561E = GUICtrlCreateButton ( $A2F80F00960 , 285 , 126 , 125 , 30 )
	GUICtrlSetCursor ( $A262150561E , 0 )
	GUICtrlSetOnEvent ( $A262150561E , "RM_ExitApplication" )
	A4C70005146 ( $A262150561E , $A093100290E , 0 )
	$A2311B0565F = GUICtrlCreateLabel ( "" , - 5 , $A5511204129 - 20 , $A3611106234 + 10 , 19 , 1 + 512 + 4096 , 1048576 )
	GUICtrlSetResizing ( $A2311B0565F , 576 )
	GUICtrlSetCursor ( $A2311B0565F , 9 )
	GUICtrlSetFont ( $A2311B0565F , $A2811001E12 , 400 , 0 , $A2E01D02B1C )
	$A2311B0565F = GUICtrlGetHandle ( $A2311B0565F )
	Local $A2931105120 [ 2 ] [ 2 ] = [ [ $A1A31200525 , GUICtrlCreateDummy ( ) ] , [ $A4131302140 , GUICtrlCreateDummy ( ) ] ]
	GUICtrlSetOnEvent ( $A2931105120 [ 0 ] [ 1 ] , "RM_ShowAboutWindow" )
	GUICtrlSetOnEvent ( $A2931105120 [ 1 ] [ 1 ] , "RM_RefreshMemoryDisplay" )
	GUISetAccelerators ( $A2931105120 , $A59A0605008 )
	Opt ( $A243140333E , 1 )
	Opt ( $A3331506247 , 1 )
	$A6111305636 = TrayCreateItem ( $A2F80F00960 , - 1 , - 1 , 1 )
	TrayItemSetState ( $A6111305636 , 1 )
	TrayItemSetOnEvent ( $A6111305636 , "RM_RunOptimize" )
	TrayCreateItem ( $A0B9010005E )
	$A3F11404954 = TrayCreateItem ( $A2F80F00960 )
	TrayItemSetOnEvent ( $A3F11404954 , "RM_ShowMainWindow" )
	$A0C11503D1C = RM_CreateTrayMenuItem ( $A2F80F00960 )
	$A5A11601452 = RM_CreateTrayMenuItem ( $A2F80F00960 )
	TrayCreateItem ( $A0B9010005E )
	$A3411700721 = TrayCreateItem ( $A2F80F00960 )
	TrayItemSetOnEvent ( $A3411700721 , "RM_ExitApplication" )
	TraySetIcon ( Execute ( $A5931600305 ) , 1 )
	Opt ( $A5831704B55 , 0 )
	TraySetClick ( 16 )
	TraySetState ( 1 )
	TraySetOnEvent ( - 13 , "RM_ShowMainWindow" )
	TraySetOnEvent ( - 7 , "RM_ShowMainWindow" )
	TraySetToolTip ( $A2A90E0262F )
	RM_ApplyLocalizedText ( )
	If $A00B0D02000 = 0 Then GUIRegisterMsg ( 32 , "A1620900B0B" )
	If $A2FE0A05C11 = 1 Then WinSetOnTop ( $A59A0605008 , "" , $A2FE0A05C11 )
	If $A43E0600648 = 1 Or $A2601902115 = 2 Then
		GUISetState ( Execute ( $A1131804C3E ) , $A59A0605008 )
	Else
		GUISetState ( Execute ( $A0231904840 ) , $A59A0605008 )
	EndIf
	If $A2601902115 <> 0 Then
		RM_ShowOptionsWindow ( )
	EndIf
	Local $A2931A04161 = 750
	RM_TrimOwnWorkingSet ( )
	While 1
		If $A2931A04161 > 745 Then
			RM_UpdateMemoryDisplay ( )
			$A2931A04161 = 0
		EndIf
		If Number ( GUICtrlRead ( $A4621900D63 ) ) = 1 Then
			GUICtrlSetData ( $A4621900D63 , 0 )
			RM_ShowMainWindow ( )
		EndIf
		RM_CheckAutoOptimize ( )
		Sleep ( 250 )
		$A2931A04161 += 250
	WEnd
	Exit
EndFunc
Func A4B00201602 ( $A5A31B00E55 , $A5731C04348 )
	If Not IsDeclared ( "SSA4B00201602" ) Then
		Global $A2431E02B5B = "bool" , $A1D31F03710 = "SetWindowTextW" , $A5641006049 = "hwnd" , $A5C41103E5E = "wstr"
		Global $SSA4B00201602 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A49C090200E , $A2431E02B5B , $A1D31F03710 , $A5641006049 , $A5A31B00E55 , $A5C41103E5E , $A5731C04348 )
	If @error Then Return SetError ( @error , @extended , False )
	Return $A5731D04046 [ 0 ]
EndFunc
Func RM_CheckAutoOptimize ( )
	If Not IsDeclared ( "SSRM_CheckAutoOptimize" ) Then
		Global $A5E41205634 = "" , $A0541303A18 = "#TIMER"
		Global $SSRM_CheckAutoOptimize = 1
	EndIf
	If $A1AF0101F06 = 0 Or ( $A1AF0101F06 = 1 And $A38F0304C08 > Round ( $A5D11902426 [ 3 ] ) ) Then
		If IsArray ( $A5211A05C62 ) = 1 Then
			$A5211A05C62 = 0
			A4B00201602 ( $A2311B0565F , $A5E41205634 )
		EndIf
		Return 0
	EndIf
	; Require pressure to fall below a lower watermark before the next pass.
	; The cooldown prevents repeated paging churn during sustained load.
	If $RM_SmartOptimize = 1 Then
		If Round ( $A5D11902426 [ 3 ] ) <= $A38F0304C08 - $RM_HysteresisPercent Then $RM_PressureArmed = 1
		If $RM_PressureArmed = 0 Then
			If $RM_LastAutoOptimize <> 0 And TimerDiff ( $RM_LastAutoOptimize ) < $RM_CooldownSeconds * 1000 Then Return 0
			$RM_PressureArmed = 1
		EndIf
	EndIf

	If IsArray ( $A5211A05C62 ) = 0 Or $A5211A05C62 [ 3 ] < 1 Or $A5211A05C62 [ 4 ] <> $A37F0703A24 Then
		Dim $A5211A05C62 [ 5 ] = [ TimerInit ( ) , 0 , - 1 , $A37F0703A24 + 1 , $A37F0703A24 ]
	EndIf
	$A5211A05C62 [ 1 ] = Int ( TimerDiff ( $A5211A05C62 [ 0 ] ) / 1000 )
	If $A5211A05C62 [ 1 ] <> $A5211A05C62 [ 2 ] Then
		$A5211A05C62 [ 2 ] = $A5211A05C62 [ 1 ]
		$A5211A05C62 [ 3 ] -= 1
		If $A5211A05C62 [ 3 ] >= 0 Then A4B00201602 ( $A2311B0565F , StringReplace ( $A3AE0005046 [ 18 ] , $A0541303A18 , $A5211A05C62 [ 3 ] ) )
		If $A5211A05C62 [ 3 ] = 0 Then
			$A5211A05C62 [ 3 ] = 0
			$RM_AutoTrigger = 1
			RM_RunOptimize ( )
			$RM_AutoTrigger = 0
			$RM_LastAutoOptimize = TimerInit ( )
			$RM_PressureArmed = 0
		EndIf
	EndIf
EndFunc
Func RM_RefreshMemoryDisplay ( )
	RM_TrackActiveProcess ( )
	RM_UpdateMemoryDisplay ( )
EndFunc
Func RM_UpdateMemoryDisplay ( $A1E41404E44 = 0 )
	If Not IsDeclared ( "SSRM_UpdateMemoryDisplay" ) Then
		Global $A5E41B01D23 = " - " , $A3641C0523B = "#RAM" , $A1F41D00D5C = "#RAM" , $A1D41E0100C = " @CRLF " , $A4741F00A18 = "#RAM" , $A6051001606 = "#RAM"
		Global $SSRM_UpdateMemoryDisplay = 1
	EndIf
	Local $A0141502E2D = MemGetStats ( )
	Local $A0441604F5B = RM_FormatMemorySize ( $A0141502E2D [ 1 ] )
	Local $A4041702E28 = RM_FormatMemorySize ( $A0141502E2D [ 1 ] - $A0141502E2D [ 2 ] , 1 )
	Local $A3741801E52 = RM_FormatMemorySize ( $A0141502E2D [ 2 ] , 1 )
	Local $A1441905A12 = Round ( ( 100 / $A0141502E2D [ 1 ] ) * ( $A0141502E2D [ 1 ] - $A0141502E2D [ 2 ] ) , 1 )
	Local $A4541A02444 = Round ( $A1441905A12 )
	If $A5D11902426 [ 0 ] <> $A0441604F5B Then GUICtrlSetData ( $A3411D0002B [ 1 ] , $A0441604F5B )
	If $A5D11902426 [ 1 ] <> $A4041702E28 Then GUICtrlSetData ( $A3411D0002B [ 2 ] , $A4041702E28 )
	If $A5D11902426 [ 2 ] <> $A3741801E52 Then GUICtrlSetData ( $A3411D0002B [ 3 ] , $A3741801E52 )
	If $A1E41404E44 <> 0 Or $A5D11902426 [ 3 ] <> $A1441905A12 Then
		WinSetTitle ( $A59A0605008 , "" , $A2A90E0262F & $A5E41B01D23 & StringReplace ( $A3AE0005046 [ 16 ] , $A3641C0523B , $A4541A02444 ) )
		GUICtrlSetData ( $A3411D0002B [ 5 ] , $A1441905A12 )
		TrayItemSetText ( $A6111305636 , StringReplace ( $A3AE0005046 [ 11 ] , $A1F41D00D5C , $A4541A02444 ) )
		TraySetToolTip ( $A2A90E0262F & Execute ( $A1D41E0100C ) & StringReplace ( $A3AE0005046 [ 17 ] , $A4741F00A18 , $A4541A02444 ) )
		RM_UpdateTrayIcon ( $A4541A02444 )
	EndIf
	If $A1E41404E44 <> 0 Or ( $A4711C0341E = 0 And $A5D11902426 [ 3 ] <> $A1441905A12 ) Or ( $A4711C0341E <> 0 And Int ( TimerDiff ( $A4711C0341E ) / 1000 ) > 1 ) Then
		GUICtrlSetData ( $A3411D0002B [ 4 ] , StringReplace ( $A3AE0005046 [ 6 ] , $A6051001606 , $A4541A02444 ) )
		$A4711C0341E = 0
	EndIf
	$A5D11902426 [ 0 ] = $A0441604F5B
	$A5D11902426 [ 1 ] = $A4041702E28
	$A5D11902426 [ 2 ] = $A3741801E52
	$A5D11902426 [ 3 ] = $A1441905A12
EndFunc
Func RM_UpdateTrayIcon ( $A155110093D , $A5651200B2D = 0 )
	If Not IsDeclared ( "SSRM_UpdateTrayIcon" ) Then
		Global $A005150540F = "0" , $A4651602158 = ".ico"
		Global $SSRM_UpdateTrayIcon = 1
	EndIf
	Local $A285130441A
	Switch $A01E0E06159
	Case 0
		$A285130441A = 1
	Case 1
		$A285130441A = - 5
	Case 2
		$A285130441A = - 10
Case Else
		$A285130441A = - 15
	EndSwitch
	If $A285130441A <> 1 Then
		If $A155110093D < 25 Then
			$A285130441A = - 1 + $A285130441A
		ElseIf $A155110093D < 51 Then
			$A285130441A = - 2 + $A285130441A
		ElseIf $A155110093D < 76 Then
			$A285130441A = - 3 + $A285130441A
		ElseIf $A155110093D < 95 Then
			$A285130441A = - 4 + $A285130441A
		Else
			$A285130441A = - 5 + $A285130441A
		EndIf
	EndIf
	Local $A3151402E21
	If $A49F0002638 <> $A285130441A Or $A5651200B2D = 1 Then
		$A49F0002638 = $A285130441A
		If $A01E0E06159 = 3 Then
			$A3151402E21 = $A0CD0A02F1D & $A005150540F & ( ( $A285130441A * - 1 ) - 15 ) & $A4651602158
			If FileExists ( $A3151402E21 ) Then Return TraySetIcon ( $A3151402E21 )
		EndIf
		TraySetIcon ( $A5BB0001B63 , $A285130441A )
	EndIf
EndFunc
; Hard release remains bounded to Windows memory-list APIs. It never terminates
; processes and is only reached from the explicit Aggressive modes.
Func RM_EnablePrivilege ( $RM_PrivilegeName )
	Local $RM_Process = DllCall ( "kernel32.dll" , "handle" , "GetCurrentProcess" )
	If @error Or Not IsArray ( $RM_Process ) Then Return 0
	Local $RM_Token = DllCall ( "advapi32.dll" , "bool" , "OpenProcessToken" , "handle" , $RM_Process [ 0 ] , "dword" , 0x28 , "handle*" , 0 )
	If @error Or Not IsArray ( $RM_Token ) Or $RM_Token [ 0 ] = 0 Then Return 0
	Local $RM_TokenHandle = $RM_Token [ 3 ]
	Local $RM_Privileges = DllStructCreate ( "dword Count;dword LowPart;long HighPart;dword Attributes" )
	DllStructSetData ( $RM_Privileges , "Count" , 1 )
	DllStructSetData ( $RM_Privileges , "Attributes" , 2 )
	Local $RM_Lookup = DllCall ( "advapi32.dll" , "bool" , "LookupPrivilegeValueW" , "ptr" , 0 , "wstr" , $RM_PrivilegeName , "ptr" , DllStructGetPtr ( $RM_Privileges , "LowPart" ) )
	If @error Or Not IsArray ( $RM_Lookup ) Or $RM_Lookup [ 0 ] = 0 Then
		DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_TokenHandle )
		Return 0
	EndIf
	Local $RM_Adjust = DllCall ( "advapi32.dll" , "bool" , "AdjustTokenPrivileges" , "handle" , $RM_TokenHandle , "bool" , False , "ptr" , DllStructGetPtr ( $RM_Privileges ) , "dword" , 0 , "ptr" , 0 , "ptr" , 0 )
	Local $RM_AdjustCallError = @error
	Local $RM_LastError = DllCall ( "kernel32.dll" , "dword" , "GetLastError" )
	DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_TokenHandle )
	If $RM_AdjustCallError Or Not IsArray ( $RM_Adjust ) Or $RM_Adjust [ 0 ] = 0 Then Return 0
	If IsArray ( $RM_LastError ) And $RM_LastError [ 0 ] <> 0 Then Return 0
	Return 1
EndFunc

Func RM_MemoryListCommand ( $RM_CommandValue )
	Local $RM_Command = DllStructCreate ( "dword" )
	DllStructSetData ( $RM_Command , 1 , $RM_CommandValue )
	Local $RM_Result = DllCall ( "ntdll.dll" , "long" , "NtSetSystemInformation" , "int" , 80 , "ptr" , DllStructGetPtr ( $RM_Command ) , "ulong" , 4 )
	If @error Or Not IsArray ( $RM_Result ) Then Return -1
	Return $RM_Result [ 0 ]
EndFunc

Func RM_AggressiveRelease ( $RM_Smooth = 0 , $RM_ProcessProfile = 2 )
	Local $RM_AvailableBefore = MemGetStats ( )
	Local $RM_ProfilePrivilege = RM_EnablePrivilege ( "SeProfileSingleProcessPrivilege" )
	Local $RM_QuotaPrivilege = RM_EnablePrivilege ( "SeIncreaseQuotaPrivilege" )
	Local $RM_EmptyStatus = - 2 , $RM_FlushStatus = - 2 , $RM_PurgeStatus = - 2
	Local $RM_FinalEmptyStatus = - 2 , $RM_FinalPurgeStatus = - 2
	Local $RM_CacheOk = 0 , $RM_ProcessTrimmed = 0 , $RM_ProcessReleasedBytes = 0
	Local $RM_ThisNativeSteps = 0 , $RM_ThisPasses = 0
	If $RM_Smooth = 1 Then
		; Smooth still gets one elevated process pass so inaccessible background
		; applications are not silently missed, but it only purges low-priority
		; standby pages and avoids the heavier modified/cache sequence.
		$RM_ProcessTrimmed = RM_RunConfiguredTrim ( 1 )
		$RM_ProcessReleasedBytes = $RM_LastTrimReleasedBytes
		$RM_ThisPasses = 1
		$RM_PurgeStatus = RM_MemoryListCommand ( 5 )
		If $RM_PurgeStatus = 0 Then $RM_ThisNativeSteps += 1
	Else
		; Full Aggressive brackets the native Windows release with two measured
		; elevated process passes. The second pass catches working sets that become
		; reclaimable after cache/list pressure changes. The current foreground
		; window and critical Windows processes remain protected outside Emergency;
		; recently backgrounded apps are intentionally eligible in Aggressive.
		Local $RM_PreTrimmed = RM_RunConfiguredTrim ( $RM_ProcessProfile )
		$RM_ProcessTrimmed += $RM_PreTrimmed
		$RM_ProcessReleasedBytes += $RM_LastTrimReleasedBytes
		$RM_ThisPasses += 1
		$RM_EmptyStatus = RM_MemoryListCommand ( 2 )
		$RM_FlushStatus = RM_MemoryListCommand ( 3 )
		If $RM_EmptyStatus = 0 Then $RM_ThisNativeSteps += 1
		If $RM_FlushStatus = 0 Then $RM_ThisNativeSteps += 1
		Local $RM_CacheResult = DllCall ( "kernel32.dll" , "bool" , "SetSystemFileCacheSize" , "ulong_ptr" , -1 , "ulong_ptr" , -1 , "dword" , 0 )
		If Not @error And IsArray ( $RM_CacheResult ) And $RM_CacheResult [ 0 ] <> 0 Then $RM_CacheOk = 1
		If $RM_CacheOk = 1 Then $RM_ThisNativeSteps += 1
		; Purge last so pages released by the system file-cache trim do not remain
		; on the standby list after the stronger manual mode finishes.
		Sleep ( 150 )
		$RM_PurgeStatus = RM_MemoryListCommand ( 4 )
		If $RM_PurgeStatus = 0 Then $RM_ThisNativeSteps += 1
		Sleep ( 250 )
		Local $RM_PostTrimmed = RM_RunConfiguredTrim ( $RM_ProcessProfile )
		$RM_ProcessTrimmed += $RM_PostTrimmed
		$RM_ProcessReleasedBytes += $RM_LastTrimReleasedBytes
		$RM_ThisPasses += 1
		; A process pass can move newly released pages onto standby. Finish full
		; Aggressive with one last global empty/purge sequence so those pages are
		; offered back to the Memory Manager before the result is measured.
		$RM_FinalEmptyStatus = RM_MemoryListCommand ( 2 )
		If $RM_FinalEmptyStatus = 0 Then $RM_ThisNativeSteps += 1
		Sleep ( 150 )
		$RM_FinalPurgeStatus = RM_MemoryListCommand ( 4 )
		If $RM_FinalPurgeStatus = 0 Then $RM_ThisNativeSteps += 1
		Sleep ( 250 )
	EndIf
	Local $RM_AvailableAfter = MemGetStats ( )
	Local $RM_ThisAvailableGainKB = 0
	If IsArray ( $RM_AvailableBefore ) And IsArray ( $RM_AvailableAfter ) Then
		$RM_ThisAvailableGainKB = $RM_AvailableAfter [ 2 ] - $RM_AvailableBefore [ 2 ]
		If $RM_ThisAvailableGainKB < 0 Then $RM_ThisAvailableGainKB = 0
	EndIf
	$RM_WorkerTotalTrimmed += $RM_ProcessTrimmed
	$RM_WorkerTotalReleasedBytes += $RM_ProcessReleasedBytes
	$RM_WorkerNativeSteps += $RM_ThisNativeSteps
	$RM_WorkerPasses += $RM_ThisPasses
	$RM_WorkerAvailableGainKB += $RM_ThisAvailableGainKB
	$RM_LastAggressiveOk = ( $RM_ProcessTrimmed > 0 Or $RM_PurgeStatus = 0 Or $RM_EmptyStatus = 0 Or $RM_FinalPurgeStatus = 0 Or $RM_FinalEmptyStatus = 0 Or $RM_CacheOk = 1 )
	$RM_LastAggressiveDetail = "Privilege profile/quota: " & $RM_ProfilePrivilege & "/" & $RM_QuotaPrivilege & @CRLF & _
		"User/background trim operations: " & $RM_ProcessTrimmed & @CRLF & _
		"Measured working-set reduction: " & Round ( $RM_ProcessReleasedBytes / 1048576 , 1 ) & " MB" & @CRLF & _
		"Measured worker available gain: " & Round ( $RM_ThisAvailableGainKB / 1024 , 1 ) & " MB" & @CRLF & _
		"Measured process passes: " & $RM_ThisPasses & @CRLF & _
		"Initial empty working sets status: " & $RM_EmptyStatus & @CRLF & _
		"Flush modified list status: " & $RM_FlushStatus & @CRLF & _
		"Initial purge standby status: " & $RM_PurgeStatus & @CRLF & _
		"Final empty working sets status: " & $RM_FinalEmptyStatus & @CRLF & _
		"Final purge standby status: " & $RM_FinalPurgeStatus & @CRLF & _
		"System file cache: " & $RM_CacheOk
	Return $RM_LastAggressiveOk
EndFunc

Func RM_EmergencyRelease ( )
	; Emergency intentionally uses profile 3: only ReduceMemory and Windows
	; system processes are protected. It remains manual and never terminates an
	; application; pages can be faulted back when applications use them again.
	Local $RM_FirstPass = RM_AggressiveRelease ( 0 , 3 )
	Sleep ( 1000 )
	Local $RM_SecondPass = RM_AggressiveRelease ( 0 , 3 )
	Return ( $RM_FirstPass = 1 Or $RM_SecondPass = 1 )
EndFunc

Func RM_GetWorkerResultPath ( )
	For $RM_ArgumentIndex = 2 To $CMDLINE [ 0 ]
		If StringLeft ( $CMDLINE [ $RM_ArgumentIndex ] , 10 ) = "/RMRESULT=" Then Return StringTrimLeft ( $CMDLINE [ $RM_ArgumentIndex ] , 10 )
	Next
	Return ""
EndFunc

Func RM_FinishWorker ( $RM_ExitCode )
	Local $RM_ResultPath = RM_GetWorkerResultPath ( )
	If StringLen ( $RM_ResultPath ) > 0 Then FileWrite ( $RM_ResultPath , $RM_ExitCode & @LF & $RM_WorkerTotalTrimmed & @LF & $RM_WorkerTotalReleasedBytes & @LF & $RM_WorkerNativeSteps & @LF & $RM_WorkerPasses & @LF & $RM_WorkerAvailableGainKB )
	Exit $RM_ExitCode
EndFunc

Func RM_ResetWorkerTotals ( )
	$RM_WorkerTotalTrimmed = 0
	$RM_WorkerTotalReleasedBytes = 0
	$RM_WorkerNativeSteps = 0
	$RM_WorkerPasses = 0
	$RM_WorkerAvailableGainKB = 0
EndFunc

Func RM_ResetLastWorkerMetrics ( )
	$RM_LastWorkerTrimmed = 0
	$RM_LastWorkerReleasedBytes = 0
	$RM_LastWorkerNativeSteps = 0
	$RM_LastWorkerPasses = 0
	$RM_LastWorkerAvailableGainKB = 0
EndFunc

Func RM_CopyWorkerMetrics ( )
	$RM_LastWorkerTrimmed = $RM_WorkerTotalTrimmed
	$RM_LastWorkerReleasedBytes = $RM_WorkerTotalReleasedBytes
	$RM_LastWorkerNativeSteps = $RM_WorkerNativeSteps
	$RM_LastWorkerPasses = $RM_WorkerPasses
	$RM_LastWorkerAvailableGainKB = $RM_WorkerAvailableGainKB
EndFunc

Func RM_ParseWorkerResult ( $RM_ResultText )
	RM_ResetLastWorkerMetrics ( )
	$RM_ResultText = StringReplace ( $RM_ResultText , @CR , "" )
	Local $RM_ResultFields = StringSplit ( $RM_ResultText , @LF , 1 )
	If Not IsArray ( $RM_ResultFields ) Or $RM_ResultFields [ 0 ] < 6 Then Return - 1
	For $RM_FieldIndex = 1 To 6
		If Not StringRegExp ( StringStripWS ( $RM_ResultFields [ $RM_FieldIndex ] , 3 ) , "^-?[0-9]+$" ) Then Return - 1
	Next
	Local $RM_ParsedExitCode = Int ( Number ( StringStripWS ( $RM_ResultFields [ 1 ] , 3 ) ) )
	$RM_LastWorkerTrimmed = Int ( Number ( StringStripWS ( $RM_ResultFields [ 2 ] , 3 ) ) )
	$RM_LastWorkerReleasedBytes = Number ( StringStripWS ( $RM_ResultFields [ 3 ] , 3 ) )
	$RM_LastWorkerNativeSteps = Int ( Number ( StringStripWS ( $RM_ResultFields [ 4 ] , 3 ) ) )
	$RM_LastWorkerPasses = Int ( Number ( StringStripWS ( $RM_ResultFields [ 5 ] , 3 ) ) )
	$RM_LastWorkerAvailableGainKB = Number ( StringStripWS ( $RM_ResultFields [ 6 ] , 3 ) )
	If $RM_LastWorkerTrimmed < 0 Or $RM_LastWorkerReleasedBytes < 0 Or $RM_LastWorkerNativeSteps < 0 Or $RM_LastWorkerPasses < 0 Or $RM_LastWorkerAvailableGainKB < 0 Then Return - 1
	Return $RM_ParsedExitCode
EndFunc

Func RM_RunAggressiveWorker ( $RM_Smooth = 0 )
	RM_ResetLastWorkerMetrics ( )
	If IsAdmin ( ) Then
		RM_ResetWorkerTotals ( )
		Local $RM_DirectResult = 0
		If $RM_Smooth = 2 Then
			$RM_DirectResult = RM_EmergencyRelease ( )
		Else
			$RM_DirectResult = RM_AggressiveRelease ( $RM_Smooth )
		EndIf
		RM_CopyWorkerMetrics ( )
		Return $RM_DirectResult
	EndIf
	Local $RM_WorkerArgument = "/RMAGGRESSIVE"
	If $RM_Smooth = 1 Then $RM_WorkerArgument = "/RMSMOOTH"
	If $RM_Smooth = 2 Then $RM_WorkerArgument = "/RMEMERGENCY"
	Local $RM_ResultPath = @TempDir & "\ReduceMemory-worker-" & @AutoItPID & "-" & Int ( Random ( 100000 , 999999 , 1 ) ) & ".result"
	FileDelete ( $RM_ResultPath )
	Local $RM_WorkerParameters = $RM_WorkerArgument & ' /RMRESULT="' & $RM_ResultPath & '"'
	Local $RM_WorkerPid = ShellExecute ( @AutoItExe , $RM_WorkerParameters , @ScriptDir , "runas" , @SW_HIDE )
	If @error Or $RM_WorkerPid = 0 Then Return 0
	Local $RM_WorkerTimeoutMs = 45000
	If $RM_Smooth = 1 Then $RM_WorkerTimeoutMs = 30000
	If $RM_Smooth = 2 Then $RM_WorkerTimeoutMs = 90000
	Local $RM_WorkerTimer = TimerInit ( )
	While ProcessExists ( $RM_WorkerPid ) And TimerDiff ( $RM_WorkerTimer ) < $RM_WorkerTimeoutMs
		Sleep ( 50 )
	WEnd
	If ProcessExists ( $RM_WorkerPid ) Then
		ProcessClose ( $RM_WorkerPid )
		FileDelete ( $RM_ResultPath )
		Return 0
	EndIf
	Local $RM_ResultTimer = TimerInit ( )
	While Not FileExists ( $RM_ResultPath ) And TimerDiff ( $RM_ResultTimer ) < 1000
		Sleep ( 25 )
	WEnd
	If Not FileExists ( $RM_ResultPath ) Then
		FileDelete ( $RM_ResultPath )
		Return 0
	EndIf
	Local $RM_WorkerExitCode = RM_ParseWorkerResult ( FileRead ( $RM_ResultPath ) )
	FileDelete ( $RM_ResultPath )
	Return ( $RM_WorkerExitCode = 0 )
EndFunc

Func RM_ModeChanged ( )
	Local $RM_ModeText = GUICtrlRead ( $RM_ModeControl )
	$RM_OptimizeMode = $RM_MODE_NORMAL
	For $RM_ModeIndex = $RM_MODE_NORMAL To $RM_MODE_AI_SHIELD
		If $RM_ModeText = RM_GetModeName ( $RM_ModeIndex ) Then
			$RM_OptimizeMode = $RM_ModeIndex
			ExitLoop
		EndIf
	Next
	IniWrite ( @ScriptDir & "\ReduceMemory.ini" , "Main" , "OptimizeMode" , $RM_OptimizeMode )
EndFunc

Func RM_GetModeName ( $RM_Mode = - 1 )
	If $RM_Mode < $RM_MODE_NORMAL Then $RM_Mode = $RM_OptimizeMode
	Switch $RM_Mode
		Case $RM_MODE_AGGRESSIVE
			Return "Aggressive Release"
		Case $RM_MODE_SMOOTH
			Return "Aggressive Smooth"
		Case $RM_MODE_TEMP
			Return "Aggressive + Delete Temp"
		Case $RM_MODE_EMERGENCY
			Return "Emergency Release"
		Case $RM_MODE_AI_SHIELD
			Return "AI Shield"
		Case Else
			Return "Normal Optimize"
	EndSwitch
EndFunc

Func RM_ModeUsesSystemRelease ( )
	Return ( $RM_OptimizeMode = $RM_MODE_AGGRESSIVE Or $RM_OptimizeMode = $RM_MODE_SMOOTH Or $RM_OptimizeMode = $RM_MODE_TEMP Or $RM_OptimizeMode = $RM_MODE_EMERGENCY )
EndFunc

Func RM_GetNativeStageTarget ( )
	Switch $RM_OptimizeMode
		Case $RM_MODE_SMOOTH
			Return 1
		Case $RM_MODE_EMERGENCY
			Return 12
		Case $RM_MODE_AGGRESSIVE , $RM_MODE_TEMP
			Return 6
		Case Else
			Return 0
	EndSwitch
EndFunc

Func RM_WriteLog ( $RM_StableGain , $RM_ReboundDetected )
	Local $RM_LogPath = @ScriptDir & "\ReduceMemory.log"
	If FileExists ( $RM_LogPath ) And FileGetSize ( $RM_LogPath ) > 131072 Then FileDelete ( $RM_LogPath )
	Local $RM_ReboundValue = "no"
	If $RM_ReboundDetected = 1 Then $RM_ReboundValue = "yes"
	FileWriteLine ( $RM_LogPath , @YEAR & "-" & StringFormat ( "%02d" , @MON ) & "-" & StringFormat ( "%02d" , @MDAY ) & " " & StringFormat ( "%02d:%02d:%02d" , @HOUR , @MIN , @SEC ) & " | mode=" & $RM_LastModeName & " | immediate=" & $RM_ImmediateGainMB & " MB | stable=" & $RM_StableGain & " MB | process_trim=" & $RM_LastProcessTrimMB & " MB | trim_operations=" & $RM_LastTrimmedCount & " | worker_available=" & Round ( $RM_LastWorkerAvailableGainKB / 1024 , 1 ) & " MB | worker_passes=" & $RM_LastWorkerPasses & " | native_steps=" & $RM_LastWorkerNativeSteps & "/" & $RM_LastNativeStageTarget & " | rebound=" & $RM_ReboundValue & " | " & $RM_StablePressureText )
EndFunc

Func RM_GetMemoryLoadPercent ( )
	Local $RM_Stats = MemGetStats ( )
	If Not IsArray ( $RM_Stats ) Or $RM_Stats [ 1 ] <= 0 Then Return - 1
	Return Round ( ( ( $RM_Stats [ 1 ] - $RM_Stats [ 2 ] ) / $RM_Stats [ 1 ] ) * 100 )
EndFunc

Func RM_AcquireStartupMonitor ( )
	Local $RM_Mutex = DllCall ( "kernel32.dll" , "handle" , "CreateMutexW" , "ptr" , 0 , "bool" , False , "wstr" , "Local\ReduceMemory.StartupMonitor.v1" )
	If @error Or Not IsArray ( $RM_Mutex ) Or $RM_Mutex [ 0 ] = 0 Then Return 0
	Local $RM_LastError = DllCall ( "kernel32.dll" , "dword" , "GetLastError" )
	If IsArray ( $RM_LastError ) And $RM_LastError [ 0 ] = 183 Then
		DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_Mutex [ 0 ] )
		Return 0
	EndIf
	Return $RM_Mutex [ 0 ]
EndFunc

Func RM_ReleaseStartupMonitor ( $RM_MutexHandle )
	If $RM_MutexHandle <> 0 Then DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_MutexHandle )
EndFunc

Func RM_RunSilentNormalPass ( $RM_Reason )
	Local $RM_Before = MemGetStats ( )
	If Not IsArray ( $RM_Before ) Then Return 0
	Local $RM_IncludeOnly = 0
	Local $RM_ProcessRule = $A1DF0B03725
	If $A3FF090012D = 0 Then
		$RM_ProcessRule = $A10F0E03A56
		If StringLen ( $RM_ProcessRule ) > 1 Then $RM_IncludeOnly = 1
	EndIf
	Local $RM_Trimmed = A2A20200810 ( $RM_IncludeOnly , $RM_ProcessRule )
	RM_ResetLastWorkerMetrics ( )
	$RM_LastTrimmedCount = $RM_Trimmed
	$RM_LastProcessTrimMB = Round ( $RM_LastTrimReleasedBytes / 1048576 , 1 )
	Sleep ( 250 )
	Local $RM_After = MemGetStats ( )
	Local $RM_GainMB = 0
	If IsArray ( $RM_After ) Then $RM_GainMB = Round ( ( $RM_After [ 2 ] - $RM_Before [ 2 ] ) / 1024 )
	If $RM_GainMB < 0 Then $RM_GainMB = 0
	$RM_ImmediateGainMB = $RM_GainMB
	$RM_LastModeName = $RM_Reason & " Normal"
	$RM_LastNativeStageTarget = 0
	$RM_StablePressureText = RM_GetPressureSummary ( ) & " | trimmed " & $RM_Trimmed
	RM_WriteLog ( $RM_GainMB , 0 )
	Return $RM_Trimmed
EndFunc

Func RM_StartupMonitorDecision ( $RM_Load , ByRef $RM_Armed , ByRef $RM_HighSamples )
	If $RM_Load < 0 Then
		$RM_HighSamples = 0
		Return 0
	EndIf
	If $RM_Load <= $RM_StartupMonitorThreshold - $RM_StartupMonitorHysteresis Then
		$RM_Armed = 1
		$RM_HighSamples = 0
		Return 0
	EndIf
	If $RM_Armed = 0 Then Return 0
	If $RM_Load < $RM_StartupMonitorThreshold Then
		$RM_HighSamples = 0
		Return 0
	EndIf
	$RM_HighSamples += 1
	If $RM_HighSamples < $RM_StartupConfirmSamples Then Return 0
	$RM_Armed = 0
	$RM_HighSamples = 0
	Return 1
EndFunc

Func RM_StartupMonitorSelfTest ( )
	Local $RM_Armed = 1 , $RM_HighSamples = 0
	If RM_StartupMonitorDecision ( $RM_StartupMonitorThreshold - 1 , $RM_Armed , $RM_HighSamples ) <> 0 Then Return 0
	For $RM_TestSample = 1 To $RM_StartupConfirmSamples - 1
		If RM_StartupMonitorDecision ( $RM_StartupMonitorThreshold , $RM_Armed , $RM_HighSamples ) <> 0 Then Return 0
	Next
	If RM_StartupMonitorDecision ( $RM_StartupMonitorThreshold , $RM_Armed , $RM_HighSamples ) <> 1 Then Return 0
	If RM_StartupMonitorDecision ( 100 , $RM_Armed , $RM_HighSamples ) <> 0 Then Return 0
	If $RM_Armed <> 0 Then Return 0
	If RM_StartupMonitorDecision ( $RM_StartupMonitorThreshold - $RM_StartupMonitorHysteresis , $RM_Armed , $RM_HighSamples ) <> 0 Then Return 0
	If $RM_Armed <> 1 Then Return 0
	Return 1
EndFunc

Func RM_RunStartupMonitor ( )
	Local $RM_MutexHandle = RM_AcquireStartupMonitor ( )
	If $RM_MutexHandle = 0 Then Return 0
	If $RM_StartupDelaySeconds > 0 Then Sleep ( $RM_StartupDelaySeconds * 1000 )
	RM_RunSilentNormalPass ( "Startup" )
	Local $RM_LastPass = TimerInit ( )
	Local $RM_Armed = 1 , $RM_HighSamples = 0
	While 1
		Sleep ( $RM_StartupMonitorIntervalSeconds * 1000 )
		Local $RM_Load = RM_GetMemoryLoadPercent ( )
		If RM_StartupMonitorDecision ( $RM_Load , $RM_Armed , $RM_HighSamples ) = 1 Then
			If TimerDiff ( $RM_LastPass ) >= $RM_StartupMonitorCooldownSeconds * 1000 Then
				RM_RunSilentNormalPass ( $RM_StartupMonitorThreshold & "% monitor" )
				$RM_LastPass = TimerInit ( )
			Else
				; Pressure arrived during cooldown. Keep watching so a sustained 95%
				; condition is handled as soon as cooldown expires.
				$RM_Armed = 1
			EndIf
		EndIf
	WEnd
	RM_ReleaseStartupMonitor ( $RM_MutexHandle )
	Return 1
EndFunc

Func RM_GetPressureSummary ( )
	Local $RM_Memory = DllStructCreate ( "dword Length;dword MemoryLoad;uint64 TotalPhys;uint64 AvailPhys;uint64 TotalPageFile;uint64 AvailPageFile;uint64 TotalVirtual;uint64 AvailVirtual;uint64 AvailExtendedVirtual" )
	DllStructSetData ( $RM_Memory , "Length" , DllStructGetSize ( $RM_Memory ) )
	Local $RM_Result = DllCall ( "kernel32.dll" , "bool" , "GlobalMemoryStatusEx" , "ptr" , DllStructGetPtr ( $RM_Memory ) )
	If @error Or Not IsArray ( $RM_Result ) Or $RM_Result [ 0 ] = 0 Then Return "Pressure unavailable"
	Local $RM_Load = DllStructGetData ( $RM_Memory , "MemoryLoad" )
	Local $RM_TotalCommit = DllStructGetData ( $RM_Memory , "TotalPageFile" )
	Local $RM_AvailCommit = DllStructGetData ( $RM_Memory , "AvailPageFile" )
	Local $RM_CommitPercent = 0
	If $RM_TotalCommit > 0 Then $RM_CommitPercent = Round ( ( ( $RM_TotalCommit - $RM_AvailCommit ) / $RM_TotalCommit ) * 100 )
	Return "RAM load " & $RM_Load & "% | commit " & $RM_CommitPercent & "%"
EndFunc

Func RM_StableCheck ( )
	If $RM_StablePending = 0 Or $RM_StableStartedAt = 0 Then Return
	If TimerDiff ( $RM_StableStartedAt ) < 15000 Then Return
	Local $RM_StableStats = MemGetStats ( )
	Local $RM_StableGain = Round ( ( $RM_StableStats [ 2 ] - $RM_StableBeforeFree ) / 1024 )
	If $RM_StableGain < 0 Then $RM_StableGain = 0
	Local $RM_ReboundText = ""
	Local $RM_ReboundDetected = 0
	If $RM_ImmediateGainMB > 0 And $RM_StableGain < $RM_ImmediateGainMB / 2 Then
		$RM_ReboundText = " | rebound detected"
		$RM_ReboundDetected = 1
		$RM_ReboundAt = TimerInit ( )
	EndIf
	GUICtrlSetData ( $A3411D0002B [ 4 ] , "Stable release: " & $RM_StableGain & " MB" & $RM_ReboundText & " | " & $RM_StablePressureText )
	RM_WriteLog ( $RM_StableGain , $RM_ReboundDetected )
	$RM_StablePending = 0
	$RM_StableStartedAt = 0
	AdlibUnRegister ( "RM_StableCheck" )
EndFunc

Func RM_DeleteTempFiles ( )
	Local $RM_Deleted = 0 , $RM_Skipped = 0
	RM_DeleteTempTree ( @TempDir , $RM_Deleted , $RM_Skipped )
	RM_DeleteTempTree ( @WindowsDir & "\Temp" , $RM_Deleted , $RM_Skipped )
	GUICtrlSetData ( $A3411D0002B [ 4 ] , "Temp deleted: " & $RM_Deleted & " | skipped/in use: " & $RM_Skipped )
	Return $RM_Deleted
EndFunc

Func RM_DeleteTempTree ( $RM_Root , ByRef $RM_Deleted , ByRef $RM_Skipped )
	If Not FileExists ( $RM_Root ) Then Return
	Local $RM_Search = FileFindFirstFile ( $RM_Root & "\*" )
	If $RM_Search = - 1 Then Return
	While 1
		Local $RM_Name = FileFindNextFile ( $RM_Search )
		If @error Then ExitLoop
		If $RM_Name = "." Or $RM_Name = ".." Then ContinueLoop
		Local $RM_Path = $RM_Root & "\\" & $RM_Name
		If StringInStr ( FileGetAttrib ( $RM_Path ) , "D" ) > 0 Then
			RM_DeleteTempTree ( $RM_Path , $RM_Deleted , $RM_Skipped )
			If DirRemove ( $RM_Path ) = 0 Then $RM_Skipped += 1
		ElseIf FileDelete ( $RM_Path ) Then
			$RM_Deleted += 1
		Else
			$RM_Skipped += 1
		EndIf
	WEnd
	FileClose ( $RM_Search )
EndFunc

Func RM_RunOptimize ( )
	If Not IsDeclared ( "SSRM_RunOptimize" ) Then
		Global $A1251701F38 = " @SW_DISABLE " , $A5251C01F41 = "#SIZE" , $A0A51D04231 = " @SW_ENABLE "
		Global $SSRM_RunOptimize = 1
	EndIf
	If RM_ModeUsesSystemRelease ( ) And $RM_ReboundAt > 0 And TimerDiff ( $RM_ReboundAt ) < $RM_ReboundCooldownSeconds * 1000 Then
		GUICtrlSetData ( $A3411D0002B [ 4 ] , "Rebound protection active - wait " & Ceiling ( $RM_ReboundCooldownSeconds - TimerDiff ( $RM_ReboundAt ) / 1000 ) & " seconds" )
		Return
	EndIf
	If $RM_ReboundAt > 0 And TimerDiff ( $RM_ReboundAt ) >= $RM_ReboundCooldownSeconds * 1000 Then $RM_ReboundAt = 0
	; Ask before Stage 1 so cancelling Emergency never trims anything first.
	If $RM_OptimizeMode = $RM_MODE_EMERGENCY And $RM_AutoTrigger = 0 Then
		If MsgBox ( 48 + 4 , "ReduceMemory", "Emergency Release akan memangkas aplikasi user termasuk aplikasi aktif, lalu melakukan pelepasan memory Windows penuh dua kali." & @CRLF & @CRLF & "Aplikasi tidak akan ditutup, tetapi reload atau stutter sementara dapat terjadi." & @CRLF & @CRLF & "Lanjutkan sekarang?" , 0 , $A59A0605008 ) <> 6 Then
			GUICtrlSetData ( $A3411D0002B [ 4 ] , "Emergency cancelled - no memory was changed" )
			Return
		EndIf
	EndIf
	GUISetState ( Execute ( $A1251701F38 ) , $A59A0605008 )
	GUICtrlSetOnEvent ( $A3C21204863 , "" )
	RM_SetTrayInteractionPaused ( 1 )
	Local $A0141502E2D = MemGetStats ( )
	$RM_StableBeforeFree = $A0141502E2D [ 2 ]
	$RM_StablePressureText = RM_GetPressureSummary ( )
	$RM_LastModeName = RM_GetModeName ( )
	$RM_LastNativeStageTarget = RM_GetNativeStageTarget ( )
	RM_ResetLastWorkerMetrics ( )
	GUICtrlSetTip ( $A3411D0002B [ 4 ] , "" )
	Local $RM_CurrentTrimProfile = RM_GetTrimProfile ( )
	Local $RM_StageOneText = "Stage 1/3 - trimming safe background applications"
	If $RM_CurrentTrimProfile = $RM_PROFILE_AGGRESSIVE Then $RM_StageOneText = "Stage 1/3 - trimming broad user/background set"
	If $RM_CurrentTrimProfile = $RM_PROFILE_EMERGENCY Then $RM_StageOneText = "Stage 1/3 - trimming all eligible user applications"
	If $RM_CurrentTrimProfile = $RM_PROFILE_AI_SHIELD Then $RM_StageOneText = "Stage 1/3 - protecting AI and trimming other background apps"
	GUICtrlSetData ( $A3411D0002B [ 4 ] , $RM_StageOneText )
	Local $A2751A01544 = RM_RunConfiguredTrim ( $RM_CurrentTrimProfile )
	Local $RM_FirstPassReleasedBytes = $RM_LastTrimReleasedBytes
	Local $RM_AggressiveResult = 0
	If RM_ModeUsesSystemRelease ( ) Then GUICtrlSetData ( $A3411D0002B [ 4 ] , "Stage 2/3 - releasing Windows memory" )
	If $RM_OptimizeMode = $RM_MODE_AGGRESSIVE Or $RM_OptimizeMode = $RM_MODE_TEMP Then $RM_AggressiveResult = RM_RunAggressiveWorker ( 0 )
	If $RM_OptimizeMode = $RM_MODE_SMOOTH Then $RM_AggressiveResult = RM_RunAggressiveWorker ( 1 )
	If $RM_OptimizeMode = $RM_MODE_EMERGENCY Then $RM_AggressiveResult = RM_RunAggressiveWorker ( 2 )
	If $RM_OptimizeMode = $RM_MODE_TEMP And $RM_AutoTrigger = 0 Then
		If MsgBox ( 48 + 4 , "ReduceMemory", "Aggressive + Delete Temp akan menghapus file secara permanen dari %TEMP% dan C:\Windows\Temp." & @CRLF & @CRLF & "File yang sedang digunakan akan dilewati. Jangan jalankan saat instalasi atau Windows Update sedang berlangsung." & @CRLF & @CRLF & "Lanjutkan sekarang?" , 0 , $A59A0605008 ) = 6 Then RM_DeleteTempFiles ( )
	EndIf
	If RM_ModeUsesSystemRelease ( ) Then
		Sleep ( 500 )
	Else
		Sleep ( 25 )
	EndIf
	GUICtrlSetData ( $A3411D0002B [ 4 ] , "Stage 3/3 - measuring immediate result" )
	RM_UpdateMemoryDisplay ( )
	Local $A1F51B0452B = MemGetStats ( )
	$A0141502E2D = Round ( ( $A1F51B0452B [ 2 ] - $A0141502E2D [ 2 ] ) / 1024 )
	If $A0141502E2D < 1 Then $A0141502E2D = 0
	$RM_ImmediateGainMB = $A0141502E2D
	$RM_LastTrimmedCount = $A2751A01544 + $RM_LastWorkerTrimmed
	$RM_LastProcessTrimMB = Round ( ( $RM_FirstPassReleasedBytes + $RM_LastWorkerReleasedBytes ) / 1048576 , 1 )
	If $RM_OptimizeMode = $RM_MODE_NORMAL Or $RM_OptimizeMode = $RM_MODE_AI_SHIELD Or $RM_AggressiveResult = 1 Then
		$RM_StablePending = 1
		$RM_StableStartedAt = TimerInit ( )
		AdlibUnRegister ( "RM_StableCheck" )
		AdlibRegister ( "RM_StableCheck" , 1000 )
	EndIf
	If $A2751A01544 = 0 And ( $RM_OptimizeMode = $RM_MODE_NORMAL Or $RM_OptimizeMode = $RM_MODE_AI_SHIELD ) Then $A0141502E2D = 0
	If $RM_OptimizeMode = $RM_MODE_NORMAL Then
		GUICtrlSetData ( $A3411D0002B [ 4 ] , "Normal available: +" & $A0141502E2D & " MB | working set: -" & $RM_LastProcessTrimMB & " MB | trims: " & $RM_LastTrimmedCount )
	ElseIf $RM_OptimizeMode = $RM_MODE_AI_SHIELD Then
		GUICtrlSetData ( $A3411D0002B [ 4 ] , "AI Shield available: +" & $A0141502E2D & " MB | working set: -" & $RM_LastProcessTrimMB & " MB | AI protected: " & $RM_AIProtectedCount )
	ElseIf $RM_AggressiveResult = 1 Then
		Local $RM_ModeResultText = "Aggressive"
		If $RM_OptimizeMode = $RM_MODE_SMOOTH Then $RM_ModeResultText = "Smooth"
		If $RM_OptimizeMode = $RM_MODE_EMERGENCY Then $RM_ModeResultText = "Emergency"
		GUICtrlSetData ( $A3411D0002B [ 4 ] , $RM_ModeResultText & ": +" & $A0141502E2D & " MB | native " & $RM_LastWorkerNativeSteps & "/" & RM_GetNativeStageTarget ( ) & " | WS -" & $RM_LastProcessTrimMB & " MB" )
		Local $RM_ResultTip = $RM_LastAggressiveDetail
		If StringLen ( $RM_ResultTip ) = 0 Then $RM_ResultTip = "Elevated process passes: " & $RM_LastWorkerPasses & @CRLF & _
			"Measured elevated working-set reduction: " & Round ( $RM_LastWorkerReleasedBytes / 1048576 , 1 ) & " MB" & @CRLF & _
			"Measured elevated available gain: " & Round ( $RM_LastWorkerAvailableGainKB / 1024 , 1 ) & " MB" & @CRLF & _
			"Native stages successful: " & $RM_LastWorkerNativeSteps & "/" & RM_GetNativeStageTarget ( )
		GUICtrlSetTip ( $A3411D0002B [ 4 ] , $RM_ResultTip )
	Else
		GUICtrlSetData ( $A3411D0002B [ 4 ] , "Aggressive cancelled or Administrator access denied" )
	EndIf
	Sleep ( 25 )
	$A4711C0341E = TimerInit ( )
	If IsArray ( $A5211A05C62 ) = 1 Then $A5211A05C62 [ 3 ] = 0
	RM_SetTrayInteractionPaused ( 0 )
	GUICtrlSetOnEvent ( $A3C21204863 , "RM_RunOptimize" )
	GUISetState ( Execute ( $A0A51D04231 ) , $A59A0605008 )
	GUISwitch ( $A59A0605008 )
EndFunc
Func RM_FormatMemorySize ( $A0A51E05D01 , $A0351F03359 = 0 )
	If Not IsDeclared ( "SSRM_FormatMemorySize" ) Then
		Global $A3E61103C21 = " KB" , $A1661204508 = " MB" , $A006130400A = " GB" , $A1161405E62 = " TB"
		Global $SSRM_FormatMemorySize = 1
	EndIf
	Local $A036100094E [ 4 ] = [ $A3E61103C21 , $A1661204508 , $A006130400A , $A1161405E62 ]
	For $A17A0803B53 = 3 To 1 Step - 1
		If $A0A51E05D01 >= 1024 ^ $A17A0803B53 Then
			If $A17A0803B53 = 1 Then $A0351F03359 = 0
			Return Round ( $A0A51E05D01 / 1024 ^ $A17A0803B53 , $A0351F03359 ) & $A036100094E [ $A17A0803B53 ]
		EndIf
	Next
	Return Round ( $A0A51E05D01 , $A0351F03359 ) & $A036100094E [ 0 ]
EndFunc
Func RM_CreateTrayMenuItem ( $A0361505653 , $A376160155D = - 1 )
	Local $A1A61703360 = TrayCreateItem ( $A0361505653 , $A376160155D )
	TrayItemSetOnEvent ( $A1A61703360 , "RM_HandleTrayMenuItem" )
	Return $A1A61703360
EndFunc
Func RM_HandleTrayMenuItem ( )
	If Not IsDeclared ( "SSRM_HandleTrayMenuItem" ) Then
		Global $A2261902008 = " @TRAY_ID "
		Global $SSRM_HandleTrayMenuItem = 1
	EndIf
	Local $A3C6180431F = Execute ( $A2261902008 )
	TrayItemSetState ( $A3C6180431F , 4 )
	Switch $A3C6180431F
	Case $A0C11503D1C
		RM_ShowOptionsWindow ( )
	Case $A5A11601452
		RM_ShowAboutWindow ( )
	EndSwitch
EndFunc
Func RM_SetTrayInteractionPaused ( $A1B61A0193E = 1 )
	If Not IsDeclared ( "SSRM_SetTrayInteractionPaused" ) Then
		Global $A0261B04761 = "TrayOnEventMode" , $A0861C00A36 = "TrayOnEventMode"
		Global $SSRM_SetTrayInteractionPaused = 1
	EndIf
	If $A1B61A0193E = 1 Then
		TraySetClick ( 0 )
		Opt ( $A0261B04761 , 0 )
		TraySetOnEvent ( - 13 , "" )
		TraySetOnEvent ( - 7 , "" )
	Else
		TraySetClick ( 16 )
		Opt ( $A0861C00A36 , 1 )
		TraySetOnEvent ( - 13 , "RM_ShowMainWindow" )
		TraySetOnEvent ( - 7 , "RM_ShowMainWindow" )
	EndIf
EndFunc
Func RM_ShowMainWindow ( )
	If Not IsDeclared ( "SSRM_ShowMainWindow" ) Then
		Global $A4961D04D2D = " @TRAY_ID " , $A2A61E00247 = " @TRAY_ID " , $A0671002710 = " @SW_SHOW " , $A5071100C24 = " @SW_RESTORE "
		Global $SSRM_ShowMainWindow = 1
	EndIf
	If $A3F11404954 = Execute ( $A4961D04D2D ) Then TrayItemSetState ( Execute ( $A2A61E00247 ) , 4 )
	Local $A1B61F01D02 = WinGetState ( $A59A0605008 )
	If BitAND ( $A1B61F01D02 , 2 ) = 0 Then GUISetState ( Execute ( $A0671002710 ) , $A59A0605008 )
	GUISetState ( Execute ( $A5071100C24 ) , $A59A0605008 )
EndFunc
Func RM_ExitApplication ( )
	Exit
EndFunc
Func RM_HandleWindowClose ( )
	If Not IsDeclared ( "SSRM_HandleWindowClose" ) Then
		Global $A177120413C = " @SW_HIDE "
		Global $SSRM_HandleWindowClose = 1
	EndIf
	If $A2BE0802D2F = 1 And $A1BA0E00F18 = 1 Then
		GUISetState ( Execute ( $A177120413C ) , $A59A0605008 )
	Else
		RM_ExitApplication ( )
	EndIf
EndFunc
Func RM_HandleWindowMinimize ( )
	If Not IsDeclared ( "SSRM_HandleWindowMinimize" ) Then
		Global $A4471301F2B = " @SW_HIDE "
		Global $SSRM_HandleWindowMinimize = 1
	EndIf
	If $A2BE0802D2F = 1 Then GUISetState ( Execute ( $A4471301F2B ) , $A59A0605008 )
EndFunc
Func A0710101E3F ( $A2371403C59 = 0 , $A5A31B00E55 = 0 )
	If Not IsDeclared ( "SSA0710101E3F" ) Then
		Global $A3C71505F40 = "Usage: <command>" , $A247160244E = " @CRLF " , $A4471700260 = " @CRLF " , $A1C71805041 = "Command:" , $A3971905624 = " @CRLF " , $A0771A04D5F = "/O : Optimize Memory" , $A1371B05B01 = " @CRLF " , $A4271C0585A = "/E : Exclude Processes" , $A5171D0201C = " @CRLF " , $A0671E01413 = " @CRLF " , $A4D71F00327 = "Examples:" , $A228100052F = " @CRLF " , $A2A81103623 = " @ScriptName " , $A2181201247 = " /O" , $A0281304132 = " @CRLF " , $A2881401807 = " @ScriptName " , $A5381502700 = " /O example1.exe example2.exe" , $A3F81604A2D = " @CRLF " , $A2381701806 = " @ScriptName " , $A0081802543 = " /O ""example1.exe"" ""example2.exe""" , $A4D81905260 = " @CRLF " , $A0681A04E0A = " @ScriptName " , $A5181B03427 = " /O /E example1.exe example2.exe" , $A4781C05F60 = " @CRLF " , $A1781D06341 = " @CRLF " , $A0681E03128 = "Copyright @ " , $A0881F00431 = " " , $A2B91002223 = " @CRLF " , $A5C9110001C = "All rights reserved."
		Global $SSA0710101E3F = 1
	EndIf
	Return MsgBox ( 64 , $A2A90E0262F , $A3C71505F40 & Execute ( $A247160244E ) & Execute ( $A4471700260 ) & $A1C71805041 & Execute ( $A3971905624 ) & $A0771A04D5F & Execute ( $A1371B05B01 ) & $A4271C0585A & Execute ( $A5171D0201C ) & Execute ( $A0671E01413 ) & $A4D71F00327 & Execute ( $A228100052F ) & Execute ( $A2A81103623 ) & $A2181201247 & Execute ( $A0281304132 ) & Execute ( $A2881401807 ) & $A5381502700 & Execute ( $A3F81604A2D ) & Execute ( $A2381701806 ) & $A0081802543 & Execute ( $A4D81905260 ) & Execute ( $A0681A04E0A ) & $A5181B03427 & Execute ( $A4781C05F60 ) & Execute ( $A1781D06341 ) & $A0681E03128 & $A2FA0403447 & $A0881F00431 & Execute ( $A2B91002223 ) & $A5C9110001C , $A2371403C59 , $A5A31B00E55 )
EndFunc
Func RM_HandleCommandLine ( )
	If Not IsDeclared ( "SSRM_HandleCommandLine" ) Then
		Global $A4191204E34 = "/OPT" , $A039130111D = "/H" , $A3191504925 = "/O" , $A1F9160184B = "/E" , $A3C9170523D = "/E" , $A3291801B5C = "/?" , $A3491B0165C = "/O" , $A2691C02627 = "/O /E"
		Global $SSRM_HandleCommandLine = 1
	EndIf
	If $CMDLINE [ 0 ] = 0 Then Return 0
	If $CMDLINE [ 1 ] = "/RMSELFTEST" Then
		Local $RM_SelfPressure = RM_GetPressureSummary ( )
		If StringInStr ( $RM_SelfPressure , "RAM load" ) = 0 Then Exit 10
		If RM_GetProcessCpuTime ( @AutoItPID ) < 0 Then Exit 11
		If StringLen ( RM_GetProcessPath ( @AutoItPID ) ) = 0 Then Exit 14
		If RM_ValidateNormalSelection ( ) < 1 Then Exit 15
		If StringLeft ( $RM_CPUShieldPIDs , 1 ) <> "|" Then Exit 15
		If RM_StartupMonitorSelfTest ( ) <> 1 Then Exit 16
		If RM_IsAIProcessName ( "ollama.exe" ) <> 1 Then Exit 17
		If RM_IsAIProcessName ( "notepad.exe" ) <> 0 Then Exit 18
		If RM_ParseWorkerResult ( "0" & @LF & "7" & @LF & "134217728" & @LF & "6" & @LF & "2" & @LF & "65536" ) <> 0 Then Exit 22
		If $RM_LastWorkerTrimmed <> 7 Or $RM_LastWorkerReleasedBytes <> 134217728 Or $RM_LastWorkerNativeSteps <> 6 Or $RM_LastWorkerPasses <> 2 Or $RM_LastWorkerAvailableGainKB <> 65536 Then Exit 23
		If RM_ParseWorkerResult ( "broken" & @LF & "7" & @LF & "134217728" & @LF & "6" & @LF & "2" & @LF & "65536" ) <> - 1 Then Exit 29
		RM_ResetLastWorkerMetrics ( )
		If RM_GetProfileMinimumMB ( $RM_PROFILE_NORMAL ) < 16 Or RM_GetProfileMinimumMB ( $RM_PROFILE_NORMAL ) < $RM_MinProcessMB Then Exit 24
		If RM_GetProfileMinimumMB ( $RM_PROFILE_SMOOTH ) < 8 Then Exit 25
		If RM_GetProfileMinimumMB ( $RM_PROFILE_AGGRESSIVE ) < 4 Or RM_GetProfileMinimumMB ( $RM_PROFILE_AGGRESSIVE ) <> $RM_AggressiveMinProcessMB Then Exit 26
		If RM_GetProfileMinimumMB ( $RM_PROFILE_EMERGENCY ) <> 0 Then Exit 27
		If RM_GetProfileMinimumMB ( $RM_PROFILE_AI_SHIELD ) < 16 Or RM_GetProfileMinimumMB ( $RM_PROFILE_AI_SHIELD ) < $RM_MinProcessMB Then Exit 28
		Local $RM_SelfOriginalMode = $RM_OptimizeMode
		Local $RM_SelfExpectedProfiles [ 6 ] = [ $RM_PROFILE_NORMAL , $RM_PROFILE_AGGRESSIVE , $RM_PROFILE_SMOOTH , $RM_PROFILE_AGGRESSIVE , $RM_PROFILE_EMERGENCY , $RM_PROFILE_AI_SHIELD ]
		For $RM_SelfModeIndex = $RM_MODE_NORMAL To $RM_MODE_AI_SHIELD
			$RM_OptimizeMode = $RM_SelfModeIndex
			If StringLen ( RM_GetModeName ( ) ) = 0 Then Exit 12
			If RM_GetTrimProfile ( ) <> $RM_SelfExpectedProfiles [ $RM_SelfModeIndex ] Then Exit 19
		Next
		$RM_OptimizeMode = $RM_SelfOriginalMode
		$RM_LastModeName = "Self Test"
		$RM_LastNativeStageTarget = 0
		$RM_StablePressureText = $RM_SelfPressure
		RM_WriteLog ( 0 , 0 )
		If Not FileExists ( @ScriptDir & "\ReduceMemory.log" ) Then Exit 13
		Exit 0
	EndIf
	If $CMDLINE [ 1 ] = "/RMMONITORSELFTEST" Then
		If RM_StartupMonitorSelfTest ( ) = 1 Then Exit 0
		Exit 16
	EndIf
	; CI-only targeted probe: trims one disposable process and proves the process
	; remains alive. It never enumerates or changes any other process.
	If $CMDLINE [ 1 ] = "/RMTRIMTEST" Then
		If $CMDLINE [ 0 ] < 2 Then Exit 20
		Local $RM_TrimTestPID = Int ( Number ( $CMDLINE [ 2 ] ) )
		If $RM_TrimTestPID <= 0 Or $RM_TrimTestPID = @AutoItPID Then Exit 20
		Local $RM_TrimTestBefore = RM_GetWorkingSetBytes ( $RM_TrimTestPID )
		Local $RM_TrimTestOk = RM_TrimProcessWorkingSet ( $RM_TrimTestPID )
		Sleep ( 100 )
		Local $RM_TrimTestAfter = RM_GetWorkingSetBytes ( $RM_TrimTestPID )
		If $CMDLINE [ 0 ] >= 3 Then FileWrite ( $CMDLINE [ 3 ] , $RM_TrimTestBefore & @LF & $RM_TrimTestAfter )
		If $RM_TrimTestOk = 1 And ProcessExists ( $RM_TrimTestPID ) And $RM_TrimTestBefore > $RM_TrimTestAfter Then Exit 0
		Exit 21
	EndIf
	; /H remains an alias so existing startup shortcuts automatically receive
	; the new silent cleanup + 95% monitor after the executable is updated.
	If $CMDLINE [ 1 ] = "/RMAUTOSTART" Or $CMDLINE [ 1 ] = $A039130111D Then
		RM_RunStartupMonitor ( )
		Exit 0
	EndIf
	If $CMDLINE [ 1 ] = "/RMAGGRESSIVE" Then
		If Not IsAdmin ( ) Then RM_FinishWorker ( 5 )
		RM_ResetWorkerTotals ( )
		If RM_AggressiveRelease ( 0 ) = 1 Then RM_FinishWorker ( 0 )
		RM_FinishWorker ( 6 )
	EndIf
	If $CMDLINE [ 1 ] = "/RMSMOOTH" Then
		If Not IsAdmin ( ) Then RM_FinishWorker ( 5 )
		RM_ResetWorkerTotals ( )
		If RM_AggressiveRelease ( 1 ) = 1 Then RM_FinishWorker ( 0 )
		RM_FinishWorker ( 6 )
	EndIf
	If $CMDLINE [ 1 ] = "/RMEMERGENCY" Then
		If Not IsAdmin ( ) Then RM_FinishWorker ( 5 )
		RM_ResetWorkerTotals ( )
		If RM_EmergencyRelease ( ) = 1 Then RM_FinishWorker ( 0 )
		RM_FinishWorker ( 6 )
	EndIf
	If ( $CMDLINE [ 0 ] = 2 And $CMDLINE [ 1 ] = $A4191204E34 ) Then
		$A2601902115 = 1
		If Number ( $CMDLINE [ 2 ] ) = 0 Then $A2601902115 = 2
		Return 0
	EndIf
	Local $CMDLINE_OPT = 0
	Local $A1291402F0C
	Switch $CMDLINE [ 1 ]
	Case $A3191504925
		$CMDLINE_OPT = 1
		If StringInStr ( $CMDLINERAW , $A1F9160184B ) <> 0 Then $CMDLINE_OPT = 3
	Case $A3C9170523D
		$CMDLINE_OPT = 3
	Case $A3291801B5C
		A0710101E3F ( )
		Exit 0
Case Else
		A0710101E3F ( )
		Exit 1
	EndSwitch
	Local $A4391901C4F , $A2391A04655
	If $CMDLINE_OPT <> 0 Then
		If $CMDLINE [ 0 ] > 1 Then
			For $A02A0704B51 = 2 To $CMDLINE [ 0 ]
				$A4391901C4F = StringStripWS ( $CMDLINE [ $A02A0704B51 ] , 3 )
				If StringLen ( $A4391901C4F ) > 0 And StringLeft ( $A4391901C4F , 1 ) <> $A2280D04544 Then
					$A1291402F0C &= $A4391901C4F & $A5580E05E46
				EndIf
			Next
			$A1291402F0C = A5720304C54 ( $A1291402F0C , 0 )
		EndIf
		If StringLen ( $A1291402F0C ) = 0 Or $CMDLINE_OPT = 3 Then
			$A2391A04655 = A2A20200810 ( 0 , $A1291402F0C )
		Else
			$A2391A04655 = A2A20200810 ( 1 , $A1291402F0C )
		EndIf
		If $A38E0C03950 = 1 And $A2FA0C0483E = 1 And $A1BA0E00F18 = 1 And $A38D0702849 = 0 Then
			$A4391901C4F = $A3491B0165C
			If $CMDLINE_OPT = 3 Then $A4391901C4F = $A2691C02627
			A6230A05C33 ( $A5BB0001B63 , $A4391901C4F & $A2F80F00960 & $A1291402F0C , $A4CB0F0301B )
		EndIf
		If $A2391A04655 = 1 Then Exit 0
	EndIf
	Exit 2
EndFunc
Func RM_ShowOptionsWindow ( )
	If Not IsDeclared ( "SSRM_ShowOptionsWindow" ) Then
		Global $A0E91E02239 = "/OPT" , $A2291F04835 = " @AutoItExe " , $A2BA100410C = "runas" , $A44A1602F0E = " @SW_DISABLE " , $A20A1901C0B = "GUIOnEventMode" , $A2CA1B0353F = "GUICloseOnESC" , $A5AA1D02B57 = " - " , $A56A1F05406 = "WindowText" , $A4FB1800345 = "06.png" , $A48B1901F02 = "07.png" , $A1EB1A0403F = "08.png" , $A06B1E03E0A = "0" , $A03B1F02B1E = ".ico" , $A0AC1302119 = "3|5|10|15|20|30|40|50|60|80|100|120|300|600" , $A11C1500D2C = "15" , $A26C1904B18 = "|app1.exe|app2.exe|" , $A44C1B04C2B = "|app1.exe|app2.exe|" , $A1BC1C00621 = "Language" , $A2BC1E0044C = "English" , $A5DD1202861 = " @SW_SHOW " , $A44D1902562 = "Main" , $A55D1A00D5D = "HideWindowOnStartup" , $A5BD1B02B00 = "Main" , $A05D1C04B37 = "HideWhenMinimized" , $A46D1D00452 = "Main" , $A4AD1E00D30 = "TrayIconPack" , $A59D1F04508 = "Main" , $A2CE1005E2D = "WinSetOnTop" , $A4EE1100160 = "Main" , _
		$A2DE1204C37 = "TaskOptions" , $A11E1302537 = "Main" , $A00E1402315 = "UsedMemory" , $A16E150272D = "Main" , $A1CE1600D06 = "CountDown" , $A31E1701D0F = "Main" , $A60E1803611 = "ExclusionOpt" , $A21E190273F = "Main" , $A42E1A04704 = "Exclusions" , $A34E1B05058 = "Main" , $A31E1C05202 = "Processes" , $A30E1D00E57 = "Main" , $A38E1E0472F = "Language" , $A2EE1F0082E = " @CRLF " , $A50F1000115 = " @CRLF " , $A31F1105508 = " @SW_ENABLE " , $A2AF120131D = "GUIOnEventMode" , $A39F1303947 = "GUICloseOnESC"
		Global $SSRM_ShowOptionsWindow = 1
	EndIf
	Local $A3B91D05229 = $A0E91E02239
	If $A2FA0C0483E = 0 And A0220803C04 ( $A45D0C00410 ) = 0 Then
		If Not ( $CMDLINE [ 0 ] = 2 And $CMDLINE [ 1 ] = $A3B91D05229 ) Then
			If ShellExecute ( Execute ( $A2291F04835 ) , $A3B91D05229 & $A2F80F00960 & BitAND ( WinGetState ( $A59A0605008 ) , 2 ) , "" , $A2BA100410C ) = 1 Then Exit
		EndIf
	EndIf
	$A59A0605008 = HWnd ( $A59A0605008 )
	Local $A58A1103A15 = $A59A0605008
	Global $A54A1203F2A = 455 , $A25A130492D = 375
	Local $A27A1401932 [ 2 ] = [ - 1 , - 1 ]
	Local $A4FA150630A
	If $A59A0605008 <> 0 Then
		GUISetState ( Execute ( $A44A1602F0E ) , $A59A0605008 )
		Local $A0AA170334E = WinGetState ( $A59A0605008 )
		If BitAND ( $A0AA170334E , 2 ) = 0 Then
			$A58A1103A15 = 0
		ElseIf BitAND ( $A0AA170334E , 16 ) <> 0 Then
		Else
			$A27A1401932 = A1880105C32 ( $A59A0605008 , $A54A1203F2A , $A25A130492D )
		EndIf
	EndIf
	Local $A01A1805D03 = Opt ( $A20A1901C0B , 0 )
	Local $A3BA1A04626 = Opt ( $A2CA1B0353F , 1 )
	RM_SetTrayInteractionPaused ( 1 )
	Local $A59A1C0365F = GUICreate ( $A2A90E0262F & $A5AA1D02B57 & $A3AE0005046 [ 8 ] , $A54A1203F2A , $A25A130492D , $A27A1401932 [ 0 ] , $A27A1401932 [ 1 ] , BitOR ( 2156396544 , 12582912 ) , - 1 , $A58A1103A15 )
	GUISetFont ( $A6301F02853 , 400 , 0 , $A2E01D02B1C )
	Local $A41A1E02D59 = A2480301717 ( $A56A1F05406 )
	GUICtrlCreateLabel ( "" , 5 , 5 , ( $A54A1203F2A - 10 ) , $A25A130492D - 50 , 8 )
	GUICtrlSetBkColor ( - 1 , - 2 )
	GUICtrlSetState ( - 1 , 128 )
	Local $A21B1000F1B = GUICtrlCreateLabel ( $A3AE0005046 [ 24 ] , 15 , 120 , $A54A1203F2A - 30 , 20 , 512 )
	GUICtrlCreateLabel ( "" , 15 , 140 , ( $A54A1203F2A - 30 ) , 30 , 8 )
	GUICtrlSetBkColor ( - 1 , - 2 )
	GUICtrlSetState ( - 1 , 128 )
	GUICtrlCreateLabel ( "" , 15 , 200 , ( $A54A1203F2A - 30 ) , 60 , 8 )
	GUICtrlSetBkColor ( - 1 , - 2 )
	GUICtrlSetState ( - 1 , 128 )
	Local $A19B110174B = GUICtrlCreateLabel ( $A3AE0005046 [ 26 ] , 25 , 205 , $A54A1203F2A - 169 , 20 , 512 )
	Local $A18B1202E0D = GUICtrlCreateLabel ( $A3AE0005046 [ 27 ] , $A54A1203F2A - 135 , 205 , 110 , 20 , 512 + 1 )
	Local $A2FB1301761 = GUICtrlCreateCheckbox ( $A3AE0005046 [ 20 ] , 15 , 20 , $A54A1203F2A - 30 , 20 )
	GUICtrlSetCursor ( $A2FB1301761 , 0 )
	If StringLen ( $A1801C02855 ) = 0 Then
		GUICtrlSetState ( $A2FB1301761 , 128 )
	Else
		If A0D10C02932 ( ) = 1 Then GUICtrlSetState ( $A2FB1301761 , 1 )
	EndIf
	Local $A01B1404A5C = GUICtrlCreateCheckbox ( $A3AE0005046 [ 21 ] , 15 , 45 , $A54A1203F2A - 30 , 20 )
	If $A43E0600648 = 1 Then GUICtrlSetState ( $A01B1404A5C , 1 )
	GUICtrlSetCursor ( $A01B1404A5C , 0 )
	Local $A14B1504C4C = GUICtrlCreateCheckbox ( $A3AE0005046 [ 22 ] , 15 , 70 , $A54A1203F2A - 30 , 20 )
	If $A2BE0802D2F = 1 Then GUICtrlSetState ( $A14B1504C4C , 1 )
	GUICtrlSetCursor ( $A14B1504C4C , 0 )
	Local $A1CB1600363 = GUICtrlCreateCheckbox ( $A3AE0005046 [ 23 ] , 15 , 95 , $A54A1203F2A - 30 , 20 )
	If $A2FE0A05C11 = 1 Then GUICtrlSetState ( $A1CB1600363 , 1 )
	GUICtrlSetCursor ( $A1CB1600363 , 0 )
	Local $A04B1706247 [ 4 ]
	$A04B1706247 [ 0 ] = GUICtrlCreateRadio ( $A2F80F00960 , 20 , 145 , 45 , 20 )
	A4C70005146 ( $A04B1706247 [ 0 ] , $A4FB1800345 , 0 , 24 , 16 )
	$A04B1706247 [ 1 ] = GUICtrlCreateRadio ( $A2F80F00960 , 80 , 145 , 110 , 20 )
	A4C70005146 ( $A04B1706247 [ 1 ] , $A48B1901F02 , 0 , 88 , 16 )
	$A04B1706247 [ 2 ] = GUICtrlCreateRadio ( $A2F80F00960 , 200 , 145 , 110 , 20 )
	A4C70005146 ( $A04B1706247 [ 2 ] , $A1EB1A0403F , 0 , 88 , 16 )
	$A04B1706247 [ 3 ] = GUICtrlCreateRadio ( $A2F80F00960 , 320 , 145 , 18 , 20 )
	For $A17A0803B53 = 0 To 3
		If $A17A0803B53 = $A01E0E06159 Then
			GUICtrlSetState ( $A04B1706247 [ $A17A0803B53 ] , 1 )
		EndIf
		GUICtrlSetCursor ( $A04B1706247 [ $A17A0803B53 ] , 0 )
	Next
	Local $A5CB1B04256 = 320 , $A1EB1C01163 , $A11B1D04202
	For $A17A0803B53 = 1 To 5
		$A5CB1B04256 += 18
		$A1EB1C01163 = GUICtrlCreateIcon ( $A0B9010005E , - 1 , $A5CB1B04256 , 147 , 16 , 16 )
		$A11B1D04202 = $A0CD0A02F1D & $A06B1E03E0A & $A17A0803B53 & $A03B1F02B1E
		If GUICtrlSetImage ( $A1EB1C01163 , $A11B1D04202 , - 1 , 1 ) = 0 Then
			If FileExists ( $A11B1D04202 ) = 1 Then
				GUICtrlSetImage ( $A1EB1C01163 , $A5BB0001B63 , - 1 , 1 )
			Else
				GUICtrlSetImage ( $A1EB1C01163 , $A5BB0001B63 , - 15 + ( $A17A0803B53 * - 1 ) , 1 )
			EndIf
		EndIf
		If $A1EB1C01163 <> 0 Then GUICtrlSetState ( $A1EB1C01163 , 128 )
	Next
	Local $A5BC100594A = GUICtrlCreateLabel ( $A0B9010005E , 338 , 145 , 92 , 20 )
	GUICtrlSetCursor ( $A5BC100594A , 0 )
	GUICtrlSetBkColor ( $A5BC100594A , - 2 )
	Local $A05C1104231 [ 4 ]
	$A05C1104231 [ 0 ] = GUICtrlCreateCheckbox ( $A3AE0005046 [ 25 ] , 15 , 180 , $A54A1203F2A - 30 , 20 )
	GUICtrlSetCursor ( $A05C1104231 [ 0 ] , 0 )
	$A05C1104231 [ 1 ] = GUICtrlCreateSlider ( 20 , 225 , 230 , 25 , BitOR ( 1 , 65536 ) )
	GUICtrlSetCursor ( $A05C1104231 [ 1 ] , 0 )
	GUICtrlSendMsg ( $A05C1104231 [ 1 ] , 1044 , 5 , 0 )
	GUICtrlSetLimit ( $A05C1104231 [ 1 ] , 100 , 25 )
	GUICtrlSetData ( $A05C1104231 [ 1 ] , $A38F0304C08 )
	$A05C1104231 [ 2 ] = GUICtrlCreateInput ( "" , 255 , 225 , 50 , 24 , BitOR ( 2048 , 1 ) )
	GUICtrlSetColor ( $A05C1104231 [ 2 ] , $A41A1E02D59 )
	GUICtrlSetCursor ( $A05C1104231 [ 2 ] , 5 )
	$A05C1104231 [ 3 ] = GUICtrlCreateCombo ( $A0B9010005E , $A54A1203F2A - 135 , 225 , 110 , 24 )
	GUICtrlSetCursor ( $A05C1104231 [ 3 ] , 0 )
	GUICtrlSetColor ( $A05C1104231 [ 3 ] , $A41A1E02D59 )
	Local $A00C1202E29 = $A0AC1302119
	If $A37F0703A24 > 0 And StringInStr ( $A5580E05E46 & $A00C1202E29 & $A5580E05E46 , $A5580E05E46 & $A37F0703A24 & $A5580E05E46 ) = 0 Then $A00C1202E29 = $A37F0703A24 & $A5580E05E46 & $A00C1202E29
	Local $A1DC1402F60 = $A37F0703A24
	If $A1DC1402F60 = 0 Then $A1DC1402F60 = $A11C1500D2C
	GUICtrlSetData ( $A05C1104231 [ 3 ] , $A00C1202E29 , $A1DC1402F60 )
	A5E10600A33 ( $A05C1104231 [ 3 ] )
	GUICtrlSendMsg ( $A05C1104231 [ 3 ] , 321 , 5 , 0 )
	If $A1AF0101F06 = 1 Then
		GUICtrlSetState ( $A05C1104231 [ 0 ] , 1 )
	Else
		GUICtrlSetState ( $A05C1104231 [ 1 ] , 128 )
		GUICtrlSetState ( $A05C1104231 [ 3 ] , 128 )
	EndIf
	Local $A40C1602149 = A4310501223 ( $A05C1104231 [ 3 ] )
	If $A40C1602149 <> 24 Then GUICtrlSetPos ( $A05C1104231 [ 2 ] , Default , Default , Default , $A40C1602149 )
	Local $A24C1700628 = GUICtrlCreateCheckbox ( $A3AE0005046 [ 28 ] , 15 , 270 , $A54A1203F2A - 160 , 20 )
	Local $A40C180125B = GUICtrlCreateInput ( "" , 15 , 290 , $A54A1203F2A - 160 , $A40C1602149 , 129 )
	A3B20404609 ( $A40C180125B , $A26C1904B18 )
	GUICtrlSetColor ( $A40C180125B , $A41A1E02D59 )
	GUICtrlSetCursor ( $A40C180125B , 5 )
	If StringLen ( $A1DF0B03725 ) > 1 Then GUICtrlSetData ( $A40C180125B , $A1DF0B03725 )
	Local $A46C1A05F0F = GUICtrlCreateInput ( "" , 15 , 290 , $A54A1203F2A - 160 , $A40C1602149 , 129 )
	A3B20404609 ( $A46C1A05F0F , $A44C1B04C2B )
	GUICtrlSetColor ( $A46C1A05F0F , $A41A1E02D59 )
	GUICtrlSetCursor ( $A46C1A05F0F , 5 )
	If StringLen ( $A10F0E03A56 ) > 1 Then GUICtrlSetData ( $A46C1A05F0F , $A10F0E03A56 )
	If $A3FF090012D = 1 Then
		GUICtrlSetState ( $A24C1700628 , 1 )
		GUICtrlSetState ( $A46C1A05F0F , 32 )
	Else
		GUICtrlSetState ( $A40C180125B , 32 )
	EndIf
	GUICtrlCreateLabel ( $A1BC1C00621 , $A54A1203F2A - 135 , 270 , 115 , 20 , 512 + 1 )
	Local $A05C1D0015D = GUICtrlCreateButton ( $A2BC1E0044C , $A54A1203F2A - 135 , 290 , 120 , $A40C1602149 )
	GUICtrlSetCursor ( $A05C1D0015D , 0 )
	$A16E0404946 = GUICtrlCreateContextMenu ( $A05C1D0015D )
	Local $A3FC1F05E3D
	A1350504361 ( )
	Local $A07D100320C = A2710401F1D ( $A05C1D0015D )
	Local $A2CD1103C27 = GUICtrlCreateButton ( $A3AE0005046 [ 29 ] , 5 , $A25A130492D - 32 , ( $A54A1203F2A - 10 ) , 28 , 1 )
	GUICtrlSetCursor ( $A2CD1103C27 , 0 )
	GUICtrlSetState ( $A2CD1103C27 , 256 )
	GUISetState ( Execute ( $A5DD1202861 ) , $A59A1C0365F )
	RM_TrimOwnWorkingSet ( )
	Local $A0FD1304F39 , $A4DD1400C25 , $A58D1505E5A , $A5DD1604B29 , $A05D1705811 [ 2 ] , $A26D180183F
	While 1
		$A0FD1304F39 = GUIGetMsg ( )
		Switch $A0FD1304F39

		Case - 3
			ExitLoop
		Case $A5BC100594A
			GUICtrlSetState ( $A04B1706247 [ 3 ] , 1 )
		Case $A05C1D0015D
			A3120F03128 ( $A59A1C0365F , $A05C1D0015D , $A16E0404946 )
		Case $A2FB1301761
			If BitAND ( GUICtrlRead ( $A2FB1301761 ) , 1 ) <> 0 Then
				GUICtrlSetState ( $A01B1404A5C , 1 )
				GUICtrlSetState ( $A14B1504C4C , 1 )
			EndIf
		Case $A24C1700628
			If BitAND ( GUICtrlRead ( $A24C1700628 ) , 1 ) <> 0 Then
				GUICtrlSetState ( $A40C180125B , 16 )
				GUICtrlSetState ( $A46C1A05F0F , 32 )
			Else
				GUICtrlSetState ( $A40C180125B , 32 )
				GUICtrlSetState ( $A46C1A05F0F , 16 )
			EndIf
		Case $A05C1104231 [ 0 ]
			If BitAND ( GUICtrlRead ( $A05C1104231 [ 0 ] ) , 1 ) = 1 Then
				GUICtrlSetState ( $A05C1104231 [ 1 ] , 64 )
				GUICtrlSetState ( $A05C1104231 [ 3 ] , 64 )
				GUICtrlSetState ( $A05C1104231 [ 1 ] , 256 )
			Else
				GUICtrlSetState ( $A05C1104231 [ 1 ] , 128 )
				GUICtrlSetState ( $A05C1104231 [ 3 ] , 128 )
			EndIf
		Case $A2CD1103C27
			$A5DD1604B29 = 1
			If StringLen ( $A1801C02855 ) > 0 Then
				$A4DD1400C25 = BitAND ( GUICtrlRead ( $A2FB1301761 ) , 1 )
				If $A4DD1400C25 = 0 Then
					A0310E01012 ( )
				Else
					A0B10D03324 ( )
				EndIf
			EndIf
			$A4DD1400C25 = BitAND ( GUICtrlRead ( $A01B1404A5C ) , 1 )
			If $A43E0600648 <> $A4DD1400C25 Then
				$A43E0600648 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A44D1902562 , $A55D1A00D5D , $A4DD1400C25 )
			EndIf
			$A4DD1400C25 = BitAND ( GUICtrlRead ( $A14B1504C4C ) , 1 )
			If $A2BE0802D2F <> $A4DD1400C25 Then
				$A2BE0802D2F = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A5BD1B02B00 , $A05D1C04B37 , $A4DD1400C25 )
			EndIf
			$A4DD1400C25 = 1
			For $A17A0803B53 = 0 To 3
				If BitAND ( GUICtrlRead ( $A04B1706247 [ $A17A0803B53 ] ) , 1 ) = 1 Then
					$A4DD1400C25 = $A17A0803B53
					ExitLoop
				EndIf
			Next
			If $A01E0E06159 <> $A4DD1400C25 Then
				$A01E0E06159 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A46D1D00452 , $A4AD1E00D30 , $A4DD1400C25 )
				$A49F0002638 = - 1
			EndIf
			For $A17A0803B53 = 1 To 5
				If $A4DD1400C25 = 3 Then
					A2B20502C21 ( $A17A0803B53 , 1 )
				Else
					A2B20502C21 ( $A17A0803B53 , 0 )
				EndIf
			Next
			RM_UpdateTrayIcon ( Round ( $A5D11902426 [ 3 ] ) , 1 )
			$A4DD1400C25 = BitAND ( GUICtrlRead ( $A1CB1600363 ) , 1 )
			If $A2FE0A05C11 <> $A4DD1400C25 Then
				$A2FE0A05C11 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A59D1F04508 , $A2CE1005E2D , $A4DD1400C25 )
			EndIf
			WinSetOnTop ( $A59A0605008 , "" , $A2FE0A05C11 )
			$A4DD1400C25 = BitAND ( GUICtrlRead ( $A05C1104231 [ 0 ] ) , 1 )
			If $A1AF0101F06 <> $A4DD1400C25 Then
				$A1AF0101F06 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A4EE1100160 , $A2DE1204C37 , $A4DD1400C25 )
			EndIf
			$A4DD1400C25 = Number ( StringLeft ( GUICtrlRead ( $A05C1104231 [ 1 ] ) , 5 ) )
			If $A4DD1400C25 < 25 Or $A4DD1400C25 > 100 Then $A4DD1400C25 = 75
			If $A38F0304C08 <> $A4DD1400C25 Then
				$A38F0304C08 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A11E1302537 , $A00E1402315 , $A4DD1400C25 )
			EndIf
			$A4DD1400C25 = Number ( GUICtrlRead ( $A05C1104231 [ 3 ] ) )
			If $A4DD1400C25 < 3 Then $A4DD1400C25 = 3
			If $A37F0703A24 <> $A4DD1400C25 Then
				$A37F0703A24 = Int ( $A4DD1400C25 )
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A16E150272D , $A1CE1600D06 , $A4DD1400C25 )
			EndIf
			If IsArray ( $A5211A05C62 ) = 1 Then $A5211A05C62 [ 3 ] = 0
			$A4DD1400C25 = BitAND ( GUICtrlRead ( $A24C1700628 ) , 1 )
			If $A3FF090012D <> $A4DD1400C25 Then
				$A3FF090012D = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A31E1701D0F , $A60E1803611 , $A4DD1400C25 )
			EndIf
			$A4DD1400C25 = A5720304C54 ( GUICtrlRead ( $A40C180125B ) )
			If $A4DD1400C25 <> $A1DF0B03725 Then
				$A1DF0B03725 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A21E190273F , $A42E1A04704 , $A1DF0B03725 )
			EndIf
			$A4DD1400C25 = A5720304C54 ( GUICtrlRead ( $A46C1A05F0F ) )
			If $A4DD1400C25 <> $A1DF0B03725 Then
				$A10F0E03A56 = $A4DD1400C25
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A34E1B05058 , $A31E1C05202 , $A10F0E03A56 )
			EndIf
			If $A50D0F02863 [ 1 ] <> $A07D100320C Then
				$A50D0F02863 [ 1 ] = $A07D100320C
				$A5DD1604B29 = IniWrite ( $A45D0C00410 , $A30E1D00E57 , $A38E1E0472F , $A50D0F02863 [ 1 ] )
				$A50D0F02863 = A495010444D ( )
				$A3AE0005046 = A0E50304D18 ( )
				RM_ApplyLocalizedText ( )
			EndIf
			If $A5DD1604B29 = 0 Then
				MsgBox ( 16 , $A2A90E0262F , $A45D0C00410 & Execute ( $A2EE1F0082E ) & Execute ( $A50F1000115 ) & $A3AE0005046 [ 30 ] , 0 , $A59A1C0365F )
			Else
				ExitLoop
			EndIf
	Case Else
			If $A0FD1304F39 > 0 Then
				$A26D180183F = A2710401F1D ( $A05C1D0015D , $A0FD1304F39 , $A59A1C0365F )
				If StringLen ( $A26D180183F ) > 0 Then
					$A07D100320C = $A26D180183F
					$A4DD1400C25 = $A50D0F02863 [ 1 ]
					$A50D0F02863 [ 1 ] = $A07D100320C
					$A58D1505E5A = $A3AE0005046
					$A3AE0005046 = A0E50304D18 ( )
					GUICtrlSetData ( $A2FB1301761 , $A3AE0005046 [ 20 ] )
					GUICtrlSetData ( $A01B1404A5C , $A3AE0005046 [ 21 ] )
					GUICtrlSetData ( $A14B1504C4C , $A3AE0005046 [ 22 ] )
					GUICtrlSetData ( $A1CB1600363 , $A3AE0005046 [ 23 ] )
					GUICtrlSetData ( $A21B1000F1B , $A3AE0005046 [ 24 ] )
					GUICtrlSetData ( $A05C1104231 [ 0 ] , $A3AE0005046 [ 25 ] )
					GUICtrlSetData ( $A19B110174B , $A3AE0005046 [ 26 ] )
					GUICtrlSetData ( $A18B1202E0D , $A3AE0005046 [ 27 ] )
					GUICtrlSetData ( $A24C1700628 , $A3AE0005046 [ 28 ] )
					GUICtrlSetData ( $A2CD1103C27 , $A3AE0005046 [ 29 ] )
					$A50D0F02863 [ 1 ] = $A4DD1400C25
					$A3AE0005046 = $A58D1505E5A
				EndIf
			EndIf
		EndSwitch
		$A0FD1304F39 = TrayGetMsg ( )
		Switch $A0FD1304F39
		Case - 7 , - 8 , - 9 , - 10
			ExitLoop
		EndSwitch
		$A05D1705811 [ 0 ] = GUICtrlRead ( $A05C1104231 [ 1 ] )
		If $A05D1705811 [ 0 ] <> $A05D1705811 [ 1 ] Then
			$A05D1705811 [ 1 ] = $A05D1705811 [ 0 ]
			GUICtrlSetData ( $A05C1104231 [ 2 ] , $A05D1705811 [ 0 ] & $A5E9020403B )
		EndIf
	WEnd
	If IsHWnd ( $A59A0605008 ) = 1 Then
		GUISetState ( Execute ( $A31F1105508 ) , $A59A0605008 )
		GUISwitch ( $A59A0605008 )
	EndIf
	GUIDelete ( $A59A1C0365F )
	RM_SetTrayInteractionPaused ( 0 )
	Opt ( $A2AF120131D , $A01A1805D03 )
	Opt ( $A39F1303947 , $A3BA1A04626 )
	RM_TrimOwnWorkingSet ( )
	Return 1
EndFunc
Func A2710401F1D ( $A4CF1401813 , $A56F1502A4E = 0 , $A3CF1602433 = 0 )
	Local $A42F1703106 = 0
	For $A17A0803B53 = 1 To $A60E0103904 [ 0 ] [ 0 ]
		If $A56F1502A4E = 0 Then
			If $A50D0F02863 [ 1 ] = $A60E0103904 [ $A17A0803B53 ] [ 1 ] Then
				$A42F1703106 = $A17A0803B53
				ExitLoop
			EndIf
		Else
			If $A56F1502A4E = $A60E0103904 [ $A17A0803B53 ] [ 0 ] Then
				$A42F1703106 = $A17A0803B53
				ExitLoop
			EndIf
		EndIf
	Next
	If $A42F1703106 = 0 Then
		If $A56F1502A4E = $A60E0103904 [ $A60E0103904 [ 0 ] [ 1 ] ] [ 0 ] Then
			Local $A04F1800A01 = $A50D0F02863 [ 1 ]
			A5660800244 ( $A3CF1602433 )
			If $A50D0F02863 [ 1 ] <> $A04F1800A01 Then
				A2710401F1D ( $A4CF1401813 )
				Return $A50D0F02863 [ 1 ]
			EndIf
		EndIf
		Return $A0B9010005E
	EndIf
	For $A17A0803B53 = 1 To $A60E0103904 [ 0 ] [ 1 ]
		GUICtrlSetState ( $A60E0103904 [ $A17A0803B53 ] [ 0 ] , 4 )
	Next
	GUICtrlSetState ( $A60E0103904 [ $A42F1703106 ] [ 0 ] , 1 )
	Local $A08F190154A = StringInStr ( $A60E0103904 [ $A42F1703106 ] [ 1 ] , Chr ( 95 ) )
	If $A08F190154A = 0 Then
		GUICtrlSetData ( $A4CF1401813 , $A60E0103904 [ $A42F1703106 ] [ 1 ] )
	Else
		GUICtrlSetData ( $A4CF1401813 , StringLeft ( $A60E0103904 [ $A42F1703106 ] [ 1 ] , $A08F190154A - 1 ) )
	EndIf
	Return $A60E0103904 [ $A42F1703106 ] [ 1 ]
EndFunc
Func A4310501223 ( $A4CF1401813 )
	Local $A34F1A06320 = GUICtrlSendMsg ( $A4CF1401813 , 340 , - 1 , 0 )
	Local $A33F1B0281D = WinGetPos ( GUICtrlGetHandle ( $A4CF1401813 ) )
	Local $A46F1C04039 = 0
	If @error = 0 Then
		$A33F1B0281D = $A33F1B0281D [ 3 ]
		$A46F1C04039 = ( $A33F1B0281D - $A34F1A06320 )
	Else
		$A33F1B0281D = $A34F1A06320
	EndIf
	Return $A33F1B0281D
EndFunc
Func A5E10600A33 ( $A4CF1401813 )
	If Not IsDeclared ( "SSA5E10600A33" ) Then
		Global $A3502100759 = "hEdit"
		Global $SSA5E10600A33 = 1
	EndIf
	Local Const $A5BF1D05B3E = 8192 + 1
	Local Const $A03F1E0041B = - 16
	Local $A35F1F02704
	A1C1070065C ( $A4CF1401813 , $A35F1F02704 )
	Local $A1702001505 = DllStructGetData ( $A35F1F02704 , $A3502100759 )
	Local $A3702205A1C = A2310804B63 ( $A1702001505 , $A03F1E0041B )
	A4110905762 ( $A1702001505 , $A03F1E0041B , BitOR ( $A3702205A1C , $A5BF1D05B3E ) )
EndFunc
Func A1C1070065C ( $A5A31B00E55 , ByRef $A35F1F02704 )
	If Not IsDeclared ( "SSA1C1070065C" ) Then
		Global $A2E02402C49 = "dword Size;long EditLeft;long EditTop;long EditRight;long EditBottom;long BtnLeft;long BtnTop;long BtnRight;long BtnBottom;dword BtnState;hwnd hCombo;hwnd hEdit;hwnd hList" , $A0F0260044F = "Size" , $A0002701716 = "wparam" , $A050280390B = "ptr"
		Global $SSA1C1070065C = 1
	EndIf
	If Not IsHWnd ( $A5A31B00E55 ) Then $A5A31B00E55 = GUICtrlGetHandle ( $A5A31B00E55 )
	Local Const $A620230454A = 356
	$A35F1F02704 = DllStructCreate ( $A2E02402C49 )
	Local $A020250453E = DllStructGetSize ( $A35F1F02704 )
	DllStructSetData ( $A35F1F02704 , $A0F0260044F , $A020250453E )
	Return A4D70405A59 ( $A5A31B00E55 , $A620230454A , 0 , DllStructGetPtr ( $A35F1F02704 ) , 0 , $A0002701716 , $A050280390B ) <> 0
EndFunc
Func A2310804B63 ( $A5A31B00E55 , $A1E02904C3C )
	If Not IsDeclared ( "SSA2310804B63" ) Then
		Global $A5302B05F10 = "GetWindowLongW" , $A0602C03618 = " @AutoItX64 " , $A5702D00413 = "GetWindowLongPtrW" , $A2E02E01E53 = "long_ptr" , $A4602F05A38 = "hwnd" , $A0E1200631A = "int"
		Global $SSA2310804B63 = 1
	EndIf
	Local $A0F02A02E23 = $A5302B05F10
	If Execute ( $A0602C03618 ) Then $A0F02A02E23 = $A5702D00413
	Local $A5731D04046 = DllCall ( $A49C090200E , $A2E02E01E53 , $A0F02A02E23 , $A4602F05A38 , $A5A31B00E55 , $A0E1200631A , $A1E02904C3C )
	If @error Then Return SetError ( @error , @extended , 0 )
	Return $A5731D04046 [ 0 ]
EndFunc
Func A4110905762 ( $A5A31B00E55 , $A1E02904C3C , $A2112100146 )
	If Not IsDeclared ( "SSA4110905762" ) Then
		Global $A4B12200727 = "SetWindowLongW" , $A1D12302000 = " @AutoItX64 " , $A531240580B = "SetWindowLongPtrW" , $A4A12503221 = "long_ptr" , $A271260242A = "hwnd" , $A1212702036 = "int" , $A1512804012 = "long_ptr"
		Global $SSA4110905762 = 1
	EndIf
	A5B10A0552F ( 0 )
	Local $A0F02A02E23 = $A4B12200727
	If Execute ( $A1D12302000 ) Then $A0F02A02E23 = $A531240580B
	Local $A5731D04046 = DllCall ( $A49C090200E , $A4A12503221 , $A0F02A02E23 , $A271260242A , $A5A31B00E55 , $A1212702036 , $A1E02904C3C , $A1512804012 , $A2112100146 )
	If @error Then Return SetError ( @error , @extended , 0 )
	Return $A5731D04046 [ 0 ]
EndFunc
Func A5B10A0552F ( $A1E1290395B , $A4B12A04003 = @error , $A5512B0324C = @extended )
	If Not IsDeclared ( "SSA5B10A0552F" ) Then
		Global $A0912C03F12 = "none" , $A3712D05A0A = "SetLastError" , $A3312E00706 = "dword"
		Global $SSA5B10A0552F = 1
	EndIf
	DllCall ( $A55C0703122 , $A0912C03F12 , $A3712D05A0A , $A3312E00706 , $A1E1290395B )
	Return SetError ( $A4B12A04003 , $A5512B0324C )
EndFunc
Func A0B10B00E07 ( )
	If Not IsDeclared ( "SSA0B10B00E07" ) Then
		Global $A1E22001544 = "\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" , $A1B22102E5B = "Startup"
		Global $SSA0B10B00E07 = 1
	EndIf
	Local $A4712F03A1E = RegRead ( $A3201805C5F & $A1E22001544 , $A1B22102E5B )
	If StringLen ( $A4712F03A1E ) = 0 Or FileExists ( $A4712F03A1E ) = 0 Then Return SetError ( 1 , 0 , "" )
	If StringRight ( $A4712F03A1E , 1 ) <> $A4080C05448 Then $A4712F03A1E &= $A4080C05448
	Return $A4712F03A1E
EndFunc
Func A0D10C02932 ( )
	If StringLen ( $A1801C02855 ) = 0 Or FileExists ( $A1801C02855 ) = 0 Then Return 0
	Local $A4822200B22 = A3C10F0125A ( $A5BB0001B63 , $A1801C02855 )
	If $A4822200B22 [ 0 ] > 0 Then Return 1
	Return 0
EndFunc
Func A0B10D03324 ( )
	If Not IsDeclared ( "SSA0B10D03324" ) Then
		Global $A2F2230475A = "ReduceMemory.lnk" , $A3B2240294F = "/RMAUTOSTART" , $A2622504737 = "Reduce Memory"
		Global $SSA0B10D03324 = 1
	EndIf
	If StringLen ( $A1801C02855 ) = 0 Or FileExists ( $A1801C02855 ) = 0 Then Return 0
	A0310E01012 ( )
	Return FileCreateShortcut ( $A5BB0001B63 , $A1801C02855 & $A2F2230475A , $A47D0805C4F , $A3B2240294F , $A2622504737 )
EndFunc
Func A0310E01012 ( )
	If StringLen ( $A1801C02855 ) = 0 Or FileExists ( $A1801C02855 ) = 0 Then Return 0
	Local $A4822200B22 = A3C10F0125A ( $A5BB0001B63 , $A1801C02855 )
	For $A17A0803B53 = 1 To $A4822200B22 [ 0 ]
		FileDelete ( $A4822200B22 [ $A17A0803B53 ] )
	Next
	Return 1
EndFunc
Func A3C10F0125A ( $A0522602B41 , $A012270461C = @DesktopDir )
	If Not IsDeclared ( "SSA3C10F0125A" ) Then
		Global $A4222C00457 = "*.lnk" , $A1022D02C19 = "/H" , $A3C22E04635 = "Reduce Memory"
		Global $SSA3C10F0125A = 1
	EndIf
	If StringRight ( $A012270461C , 1 ) <> $A4080C05448 Then $A012270461C &= $A4080C05448
	Local $A092280353D [ 5 ] = [ 0 ] , $A5822905751 , $A0122A04621
	Local $A5722B04646 = FileFindFirstFile ( $A012270461C & $A4222C00457 )
	If $A5722B04646 <> - 1 Then
		While 1
			$A5822905751 = FileFindNextFile ( $A5722B04646 )
			If @error Then ExitLoop
			$A0122A04621 = FileGetShortcut ( $A012270461C & $A5822905751 )
			If @error = 0 And ( ( $A0122A04621 [ 0 ] = $A0522602B41 ) Or ( $A0122A04621 [ 2 ] = $A1022D02C19 And $A0122A04621 [ 3 ] = $A3C22E04635 ) ) Then
				$A092280353D [ 0 ] += 1
				If $A092280353D [ 0 ] >= UBound ( $A092280353D ) Then ReDim $A092280353D [ $A092280353D [ 0 ] + 10 ]
				$A092280353D [ $A092280353D [ 0 ] ] = $A012270461C & $A5822905751
			EndIf
		WEnd
	EndIf
	FileClose ( $A5722B04646 )
	Return $A092280353D
EndFunc
Func RM_TrimProcessWorkingSet ( $A3822F01F2E = 0 )
	If Not IsDeclared ( "SSRM_TrimProcessWorkingSet" ) Then
		Global $A3632003763 = " @AutoItPID " , $A5A32202E2C = "ptr" , $A033230552B = "OpenProcess" , $A4E32404148 = "dword" , $A3632503E29 = "int" , $A2132605706 = "dword" , $A5432802A34 = "int" , $A2B32900D63 = "EmptyWorkingSet" , $A0632A0541B = "ptr" , $A1532B04830 = "bool" , $A2D32C00F3F = "CloseHandle" , $A6032D01255 = "handle"
		Global $SSRM_TrimProcessWorkingSet = 1
	EndIf
	If Not $A3822F01F2E Then $A3822F01F2E = Execute ( $A3632003763 )
	Local $A0D3210155D = DllCall ( $A55C0703122 , $A5A32202E2C , $A033230552B , $A4E32404148 , $A4301102A51 , $A3632503E29 , 0 , $A2132605706 , $A3822F01F2E )
	If ( @error ) Or ( Not $A0D3210155D [ 0 ] ) Then Return SetError ( 1 , 0 , 0 )
	Local $A1132703101 = DllCall ( $A29D0503B5E , $A5432802A34 , $A2B32900D63 , $A0632A0541B , $A0D3210155D [ 0 ] )
	If ( @error ) Or ( Not IsArray ( $A1132703101 ) ) Or ( Not $A1132703101 [ 0 ] ) Then
		; EmptyWorkingSet is the primary path. SetProcessWorkingSetSizeEx with
		; minimum/maximum -1 is the documented Windows fallback for processes
		; whose working set can be adjusted but whose PSAPI call was unavailable.
		$A1132703101 = DllCall ( $A55C0703122 , "bool" , "SetProcessWorkingSetSizeEx" , "handle" , $A0D3210155D [ 0 ] , "ulong_ptr" , - 1 , "ulong_ptr" , - 1 , "dword" , 0 )
		If @error Or Not IsArray ( $A1132703101 ) Or $A1132703101 [ 0 ] = 0 Then $A1132703101 = 0
	EndIf
	DllCall ( $A55C0703122 , $A1532B04830 , $A2D32C00F3F , $A6032D01255 , $A0D3210155D [ 0 ] )
	If Not IsArray ( $A1132703101 ) Then Return SetError ( 1 , 0 , 0 )
	Return 1
EndFunc
Func RM_TrimOwnWorkingSet ( )
	If Not IsDeclared ( "SSRM_TrimOwnWorkingSet" ) Then
		Global $A4432E0631F = "int" , $A3432F00362 = "EmptyWorkingSet" , $A6042005352 = "long"
		Global $SSRM_TrimOwnWorkingSet = 1
	EndIf
	Local $RM_TrimOwnResult = DllCall ( $A29D0503B5E , $A4432E0631F , $A3432F00362 , $A6042005352 , - 1 )
	If @error Or Not IsArray ( $RM_TrimOwnResult ) Or Not $RM_TrimOwnResult [ 0 ] Then Return SetError ( 1 , 0 , 0 )
	Return 1
EndFunc

Func RM_TrackActiveProcess ( )
	If $RM_ProtectForeground <> 1 Then Return
	Local $RM_ActivePID = WinGetProcess ( "[ACTIVE]" )
	If $RM_ActivePID > 0 And $RM_ActivePID <> $RM_LastObservedActivePID Then
		$RM_RecentActivePID = $RM_LastObservedActivePID
		$RM_RecentActiveAt = TimerInit ( )
		$RM_LastObservedActivePID = $RM_ActivePID
	EndIf
EndFunc

Func RM_GetProcessCpuTime ( $RM_ProcessPID )
	Local $RM_ProcessHandle = DllCall ( "kernel32.dll" , "handle" , "OpenProcess" , "dword" , 0x1000 , "bool" , False , "dword" , $RM_ProcessPID )
	If @error Or Not IsArray ( $RM_ProcessHandle ) Or $RM_ProcessHandle [ 0 ] = 0 Then Return -1
	Local $RM_Times = DllCall ( "kernel32.dll" , "bool" , "GetProcessTimes" , "handle" , $RM_ProcessHandle [ 0 ] , "uint64*" , 0 , "uint64*" , 0 , "uint64*" , 0 , "uint64*" , 0 )
	Local $RM_TimesError = @error
	DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_ProcessHandle [ 0 ] )
	If $RM_TimesError Or Not IsArray ( $RM_Times ) Or $RM_Times [ 0 ] = 0 Then Return -1
	Return Number ( $RM_Times [ 4 ] ) + Number ( $RM_Times [ 5 ] )
EndFunc

Func RM_BuildCPUShield ( )
	$RM_CPUShieldPIDs = "|"
	Local $RM_Processes = ProcessList ( )
	If Not IsArray ( $RM_Processes ) Then Return
	Local $RM_FirstTimes [ $RM_Processes [ 0 ] [ 0 ] + 1 ]
	For $RM_CPUIndex = 1 To $RM_Processes [ 0 ] [ 0 ]
		$RM_FirstTimes [ $RM_CPUIndex ] = RM_GetProcessCpuTime ( $RM_Processes [ $RM_CPUIndex ] [ 1 ] )
	Next
	Sleep ( 150 )
	For $RM_CPUIndex = 1 To $RM_Processes [ 0 ] [ 0 ]
		If $RM_FirstTimes [ $RM_CPUIndex ] < 0 Then ContinueLoop
		Local $RM_SecondTime = RM_GetProcessCpuTime ( $RM_Processes [ $RM_CPUIndex ] [ 1 ] )
		If $RM_SecondTime >= 0 And $RM_SecondTime - $RM_FirstTimes [ $RM_CPUIndex ] >= 150000 Then $RM_CPUShieldPIDs &= $RM_Processes [ $RM_CPUIndex ] [ 1 ] & "|"
	Next
EndFunc

Func RM_IsAIProcessName ( $RM_ProcessName )
	If $RM_AIShieldEnabled <> 1 Then Return 0
	Local $RM_Name = StringLower ( StringStripWS ( $RM_ProcessName , 3 ) )
	If StringLen ( $RM_Name ) = 0 Then Return 0
	Local $RM_Patterns = StringSplit ( StringLower ( $RM_AIProcessPatterns ) , "|" , 1 )
	If Not IsArray ( $RM_Patterns ) Then Return 0
	For $RM_PatternIndex = 1 To $RM_Patterns [ 0 ]
		Local $RM_Pattern = StringStripWS ( $RM_Patterns [ $RM_PatternIndex ] , 3 )
		If StringLen ( $RM_Pattern ) > 0 And StringInStr ( $RM_Name , $RM_Pattern ) > 0 Then Return 1
	Next
	Return 0
EndFunc

Func RM_BuildAIShield ( )
	$RM_AIShieldPIDs = "|"
	$RM_AIProtectedCount = 0
	If $RM_AIShieldEnabled <> 1 Then Return
	Local $RM_Processes = ProcessList ( )
	If Not IsArray ( $RM_Processes ) Then Return
	For $RM_AIIndex = 1 To $RM_Processes [ 0 ] [ 0 ]
		If RM_IsAIProcessName ( $RM_Processes [ $RM_AIIndex ] [ 0 ] ) Then $RM_AIShieldPIDs &= $RM_Processes [ $RM_AIIndex ] [ 1 ] & "|"
	Next
	Local $RM_Snapshot = DllCall ( "kernel32.dll" , "handle" , "CreateToolhelp32Snapshot" , "dword" , 2 , "dword" , 0 )
	If @error Or Not IsArray ( $RM_Snapshot ) Or $RM_Snapshot [ 0 ] = - 1 Then Return
	Local $RM_Entry = DllStructCreate ( "dword Size;dword Usage;dword ProcessID;ulong_ptr DefaultHeapID;dword ModuleID;dword Threads;dword ParentProcessID;long PriClassBase;dword Flags;wchar ExeFile[260]" )
	DllStructSetData ( $RM_Entry , "Size" , DllStructGetSize ( $RM_Entry ) )
	Local $RM_Capacity = $RM_Processes [ 0 ] [ 0 ] + 128 , $RM_Count = 0
	Local $RM_PIDs [ $RM_Capacity ] , $RM_Parents [ $RM_Capacity ]
	Local $RM_Next = DllCall ( "kernel32.dll" , "bool" , "Process32FirstW" , "handle" , $RM_Snapshot [ 0 ] , "ptr" , DllStructGetPtr ( $RM_Entry ) )
	While Not @error And IsArray ( $RM_Next ) And $RM_Next [ 0 ] <> 0
		$RM_Count += 1
		If $RM_Count >= $RM_Capacity Then
			$RM_Capacity += 128
			ReDim $RM_PIDs [ $RM_Capacity ]
			ReDim $RM_Parents [ $RM_Capacity ]
		EndIf
		$RM_PIDs [ $RM_Count ] = DllStructGetData ( $RM_Entry , "ProcessID" )
		$RM_Parents [ $RM_Count ] = DllStructGetData ( $RM_Entry , "ParentProcessID" )
		$RM_Next = DllCall ( "kernel32.dll" , "bool" , "Process32NextW" , "handle" , $RM_Snapshot [ 0 ] , "ptr" , DllStructGetPtr ( $RM_Entry ) )
	WEnd
	DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_Snapshot [ 0 ] )
	Local $RM_Changed = 1
	While $RM_Changed = 1
		$RM_Changed = 0
		For $RM_AIIndex = 1 To $RM_Count
			If StringInStr ( $RM_AIShieldPIDs , "|" & $RM_PIDs [ $RM_AIIndex ] & "|" ) = 0 And StringInStr ( $RM_AIShieldPIDs , "|" & $RM_Parents [ $RM_AIIndex ] & "|" ) > 0 Then
				$RM_AIShieldPIDs &= $RM_PIDs [ $RM_AIIndex ] & "|"
				$RM_Changed = 1
			EndIf
		Next
	WEnd
	For $RM_AIIndex = 1 To $RM_Count
		If StringInStr ( $RM_AIShieldPIDs , "|" & $RM_PIDs [ $RM_AIIndex ] & "|" ) > 0 Then $RM_AIProtectedCount += 1
	Next
EndFunc

; ProcessGetPath() does not exist in the AutoIt 3.3.6.1 runtime used by the
; original application. QueryFullProcessImageNameW provides the same process
; path information on supported Windows versions without requiring a newer
; AutoIt runtime. An empty path is a safe fallback when access is denied.
Func RM_GetProcessPath ( $RM_ProcessPID )
	Local $RM_ProcessHandle = DllCall ( "kernel32.dll" , "handle" , "OpenProcess" , "dword" , 0x1000 , "bool" , False , "dword" , $RM_ProcessPID )
	If @error Or Not IsArray ( $RM_ProcessHandle ) Or $RM_ProcessHandle [ 0 ] = 0 Then Return ""
	Local $RM_PathCapacity = 32768
	Local $RM_PathBuffer = DllStructCreate ( "wchar[" & $RM_PathCapacity & "]" )
	Local $RM_PathResult = DllCall ( "kernel32.dll" , "bool" , "QueryFullProcessImageNameW" , "handle" , $RM_ProcessHandle [ 0 ] , "dword" , 0 , "ptr" , DllStructGetPtr ( $RM_PathBuffer ) , "dword*" , $RM_PathCapacity )
	Local $RM_PathError = @error
	DllCall ( "kernel32.dll" , "bool" , "CloseHandle" , "handle" , $RM_ProcessHandle [ 0 ] )
	If $RM_PathError Or Not IsArray ( $RM_PathResult ) Or $RM_PathResult [ 0 ] = 0 Then Return ""
	Return DllStructGetData ( $RM_PathBuffer , 1 )
EndFunc

; Internal trim profiles keep the visible mode list simple while giving every
; mode a genuinely different engine:
;   0 Normal, 1 Smooth, 2 Aggressive, 3 Emergency, 4 AI Shield.
Func RM_GetTrimProfile ( )
	Switch $RM_OptimizeMode
		Case $RM_MODE_AGGRESSIVE , $RM_MODE_TEMP
			Return $RM_PROFILE_AGGRESSIVE
		Case $RM_MODE_SMOOTH
			Return $RM_PROFILE_SMOOTH
		Case $RM_MODE_EMERGENCY
			Return $RM_PROFILE_EMERGENCY
		Case $RM_MODE_AI_SHIELD
			Return $RM_PROFILE_AI_SHIELD
		Case Else
			Return $RM_PROFILE_NORMAL
	EndSwitch
EndFunc

Func RM_RunConfiguredTrim ( $RM_Profile = - 1 )
	Local $RM_IncludeOnly = 0
	Local $RM_ProcessFilter = $A0B9010005E
	If $A3FF090012D = 0 Then
		If StringLen ( $A10F0E03A56 ) > 1 Then
			$RM_IncludeOnly = 1
			$RM_ProcessFilter = $A10F0E03A56
		EndIf
	Else
		$RM_ProcessFilter = $A1DF0B03725
	EndIf
	Return A2A20200810 ( $RM_IncludeOnly , $RM_ProcessFilter , $RM_Profile )
EndFunc

Func RM_GetWorkingSetBytes ( $RM_ProcessPID )
	Local $RM_MemoryStats = ProcessGetStats ( $RM_ProcessPID , 0 )
	If Not IsArray ( $RM_MemoryStats ) Then Return 0
	Local $RM_WorkingSetBytes = Number ( $RM_MemoryStats [ 0 ] )
	If $RM_WorkingSetBytes < 0 Then Return 0
	Return $RM_WorkingSetBytes
EndFunc

; Keep every numeric INI setting on the same parse-and-clamp path. This avoids
; small boundary differences when a new profile or monitor setting is added.
Func RM_ReadBoundedInt ( $RM_Key , $RM_Default , $RM_Minimum , $RM_Maximum )
	Local $RM_Value = Int ( Number ( A3560501B29 ( $RM_Key , $RM_Default ) ) )
	If $RM_Value < $RM_Minimum Then Return $RM_Minimum
	If $RM_Value > $RM_Maximum Then Return $RM_Maximum
	Return $RM_Value
EndFunc

Func RM_GetProfileMinimumMB ( $RM_Profile )
	Local $RM_ProfileMinimumMB = $RM_MinProcessMB
	Switch $RM_Profile
		Case $RM_PROFILE_NORMAL
			If $RM_NormalMinProcessMB > $RM_ProfileMinimumMB Then $RM_ProfileMinimumMB = $RM_NormalMinProcessMB
		Case $RM_PROFILE_SMOOTH
			$RM_ProfileMinimumMB = Int ( $RM_MinProcessMB / 2 )
			If $RM_ProfileMinimumMB < 8 Then $RM_ProfileMinimumMB = 8
			If $RM_SmoothMinProcessMB > $RM_ProfileMinimumMB Then $RM_ProfileMinimumMB = $RM_SmoothMinProcessMB
		Case $RM_PROFILE_AGGRESSIVE
			$RM_ProfileMinimumMB = $RM_AggressiveMinProcessMB
		Case $RM_PROFILE_EMERGENCY
			$RM_ProfileMinimumMB = 0
		Case $RM_PROFILE_AI_SHIELD
			If $RM_AIShieldMinProcessMB > $RM_ProfileMinimumMB Then $RM_ProfileMinimumMB = $RM_AIShieldMinProcessMB
	EndSwitch
	Return $RM_ProfileMinimumMB
EndFunc

Func A2A20200810 ( $A3C42101753 = 0 , $A6242203763 = "" , $RM_Profile = - 1 )
	Local $A2A4230391F = 0
	Local $RM_TotalReleasedBytes = 0
	$RM_LastTrimReleasedBytes = 0
	If $RM_Profile < 0 Then $RM_Profile = RM_GetTrimProfile ( )
	If $RM_Profile = $RM_PROFILE_AI_SHIELD Then
		RM_BuildAIShield ( )
	Else
		$RM_AIShieldPIDs = "|"
		$RM_AIProtectedCount = 0
	EndIf
	If $A3C42101753 <> 1 Then $A3C42101753 = 0
	$A6242203763 = A5720304C54 ( $A6242203763 , 1 )
	Local $A5E4240211A = ProcessList ( ) , $A17A0803B53 , $A2B42506363
	If Not IsArray ( $A5E4240211A ) Then Return 0
	Local $RM_ForegroundPID = 0
	RM_TrackActiveProcess ( )
	If $A3C42101753 = 0 And ( $RM_Profile = $RM_PROFILE_NORMAL Or $RM_Profile = $RM_PROFILE_SMOOTH Or $RM_Profile = $RM_PROFILE_AI_SHIELD ) Then
		RM_BuildCPUShield ( )
	Else
		$RM_CPUShieldPIDs = "|"
	EndIf
	If $RM_ProtectForeground = 1 Then $RM_ForegroundPID = WinGetProcess ( "[ACTIVE]" )
	For $A17A0803B53 = 1 To $A5E4240211A [ 0 ] [ 0 ]
		$A2B42506363 = StringInStr ( $A6242203763 , $A5580E05E46 & $A5E4240211A [ $A17A0803B53 ] [ 0 ] & $A5580E05E46 )
		If ( $A3C42101753 = 0 And $A2B42506363 = 0 ) Or ( $A3C42101753 = 1 And $A2B42506363 <> 0 ) Then

			Local $RM_TargetPID = $A5E4240211A [ $A17A0803B53 ] [ 1 ]
			Local $RM_BeforeWorkingSet = 0
			If RM_ShouldSkipProcess ( $A5E4240211A [ $A17A0803B53 ] [ 0 ] , $RM_TargetPID , $RM_ForegroundPID , $RM_Profile , $RM_BeforeWorkingSet ) Then ContinueLoop
			Local $RM_TrimSucceeded = 0
			If $A26B0601541 = $A5E4240211A [ $A17A0803B53 ] [ 1 ] Then
				$RM_TrimSucceeded = RM_TrimOwnWorkingSet ( )
			Else
				$RM_TrimSucceeded = RM_TrimProcessWorkingSet ( $RM_TargetPID )
			EndIf
			If $RM_TrimSucceeded = 1 Then
				$A2A4230391F += 1
				Local $RM_AfterWorkingSet = RM_GetWorkingSetBytes ( $RM_TargetPID )
				If $RM_BeforeWorkingSet > $RM_AfterWorkingSet Then $RM_TotalReleasedBytes += $RM_BeforeWorkingSet - $RM_AfterWorkingSet
			EndIf
		EndIf
	Next
	$RM_LastTrimReleasedBytes = $RM_TotalReleasedBytes
	Return $A2A4230391F
EndFunc
; Return true for processes that should not be trimmed during the normal
; (all-processes-except-exclusions) pass. Explicit include mode remains
; available for advanced users who intentionally target a small process.
Func RM_ShouldSkipProcess ( $RM_ProcessName , $RM_ProcessPID , $RM_ForegroundPID , $RM_Profile , ByRef $RM_WorkingSetBytes )
	$RM_WorkingSetBytes = 0
	Local $RM_Name = StringLower ( StringStripWS ( $RM_ProcessName , 3 ) )
	If $RM_ProcessPID = @AutoItPID Then Return 1
	If $RM_Profile = $RM_PROFILE_AI_SHIELD And StringInStr ( $RM_AIShieldPIDs , "|" & $RM_ProcessPID & "|" ) > 0 Then Return 1
	Local $RM_Protected = "|system idle process|system|registry|memory compression|secure system|csrss.exe|smss.exe|wininit.exe|winlogon.exe|services.exe|lsass.exe|dwm.exe|audiodg.exe|fontdrvhost.exe|"
	If StringInStr ( $RM_Protected , "|" & $RM_Name & "|" ) > 0 Then Return 1
	Local $RM_Path = StringLower ( StringStripWS ( RM_GetProcessPath ( $RM_ProcessPID ) , 3 ) )
	Local $RM_WindowsRoot = @WindowsDir
	If StringRight ( $RM_WindowsRoot , 1 ) <> "\" Then $RM_WindowsRoot &= "\"
	$RM_WindowsRoot = StringLower ( $RM_WindowsRoot )
	If StringLen ( $RM_Path ) > 0 And StringLeft ( $RM_Path , StringLen ( $RM_WindowsRoot ) ) = $RM_WindowsRoot Then Return 1
	; Emergency is intentionally the only profile that may trim the foreground.
	; Full Aggressive still protects the current window, but unlike Normal,
	; Smooth, and AI Shield it may reclaim an app after it moves to background.
	If $RM_Profile <> $RM_PROFILE_EMERGENCY Then
		If $RM_ProtectForeground = 1 And $RM_ForegroundPID > 0 And $RM_ProcessPID = $RM_ForegroundPID Then Return 1
	EndIf
	If $RM_Profile = $RM_PROFILE_NORMAL Or $RM_Profile = $RM_PROFILE_SMOOTH Or $RM_Profile = $RM_PROFILE_AI_SHIELD Then
		If $RM_RecentActivePID > 0 And $RM_ProcessPID = $RM_RecentActivePID And $RM_RecentActiveAt > 0 And TimerDiff ( $RM_RecentActiveAt ) < $RM_ActiveShieldSeconds * 1000 Then Return 1
	EndIf
	If ( $RM_Profile = $RM_PROFILE_NORMAL Or $RM_Profile = $RM_PROFILE_SMOOTH Or $RM_Profile = $RM_PROFILE_AI_SHIELD ) And StringInStr ( $RM_CPUShieldPIDs , "|" & $RM_ProcessPID & "|" ) > 0 Then Return 1
	Local $RM_Stats = ProcessGetStats ( $RM_ProcessPID , 0 )
	If IsArray ( $RM_Stats ) And Number ( $RM_Stats [ 0 ] ) > 0 Then
		$RM_WorkingSetBytes = Number ( $RM_Stats [ 0 ] )
		Local $RM_ProfileMinimumMB = RM_GetProfileMinimumMB ( $RM_Profile )
		If $RM_Profile <> $RM_PROFILE_EMERGENCY And $RM_WorkingSetBytes < $RM_ProfileMinimumMB * 1024 * 1024 Then Return 1
	EndIf
	Return 0
EndFunc

; Exercise the complete Normal candidate-selection path without trimming any
; process. This is used by /RMSELFTEST so unsupported runtime functions cannot
; hide behind a GUI-only code path again.
Func RM_ValidateNormalSelection ( )
	Local $RM_Processes = ProcessList ( )
	If Not IsArray ( $RM_Processes ) Then Return 0
	Local $RM_ForegroundPID = 0
	RM_TrackActiveProcess ( )
	RM_BuildCPUShield ( )
	If $RM_ProtectForeground = 1 Then $RM_ForegroundPID = WinGetProcess ( "[ACTIVE]" )
	For $RM_ProcessIndex = 1 To $RM_Processes [ 0 ] [ 0 ]
		Local $RM_ValidatedWorkingSet = 0
		RM_ShouldSkipProcess ( $RM_Processes [ $RM_ProcessIndex ] [ 0 ] , $RM_Processes [ $RM_ProcessIndex ] [ 1 ] , $RM_ForegroundPID , 0 , $RM_ValidatedWorkingSet )
	Next
	Return $RM_Processes [ 0 ] [ 0 ]
EndFunc

Func A5720304C54 ( $A3642601F53 , $A2542704416 = 1 )
	If Not IsDeclared ( "SSA5720304C54" ) Then
		Global $A0D42800629 = "[\\/:*?""<>]"
		Global $SSA5720304C54 = 1
	EndIf
	$A3642601F53 = StringStripWS ( StringRegExpReplace ( $A3642601F53 , $A0D42800629 , "" ) , 3 )
	Local $A1942902809 = StringSplit ( $A3642601F53 , $A5580E05E46 , 1 )
	Local $A2A4230391F = $A0B9010005E
	For $A17A0803B53 = 1 To $A1942902809 [ 0 ]
		$A1942902809 [ $A17A0803B53 ] = StringStripWS ( $A1942902809 [ $A17A0803B53 ] , 3 )
		If StringLen ( $A1942902809 [ $A17A0803B53 ] ) > 0 Then
			$A2A4230391F &= $A1942902809 [ $A17A0803B53 ] & $A5580E05E46
		EndIf
	Next
	If $A2542704416 = 1 Then
		$A2A4230391F = $A5580E05E46 & $A2A4230391F
	Else
		$A2A4230391F = StringStripWS ( StringTrimRight ( $A2A4230391F , 1 ) , 3 )
	EndIf
	Return $A2A4230391F
EndFunc
Func A3B20404609 ( $A4CF1401813 , $A0C42A00F3D = "" , $A1742B01E13 = 0 )
	Local Const $A2342C0621B = 5377
	Return GUICtrlSendMsg ( $A4CF1401813 , $A2342C0621B , $A1742B01E13 , $A0C42A00F3D )
EndFunc
Func A2B20502C21 ( $A0942D0613F = 1 , $A0542E04F61 = 1 )
	If Not IsDeclared ( "SSA2B20502C21" ) Then
		Global $A2F52001159 = "0" , $A1B5210025D = ".ico" , $A2752405D1D = "0x00000100010010100000010020006804000016000000280000001000000020000000010020000000000040040000000000" , $A5C52502140 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A0552604F53 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF07FD01FF07FD01" , $A515270202E = "FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000FF000000FF000000000000000000" , $A3652805B2A = "0000FF000000FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000" , $A6152900A3C = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A1452A03761 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , _
		$A1052B00E09 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A1F52C01610 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A2752D05307 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A1D52E03145 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A2152F03415 = "FF000000FF000000FF000000FF000000FF00000000000000000000000000000000000000FF000000FF000000FF000000FF00" , $A0D62004D5A = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A6062103E5B = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A1362203930 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , _
		$A476230581C = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A0D6240344F = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A0B62500C3A = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A246260521E = "000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A1762703100 = "FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A3862802313 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A1762902F57 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A1562A02411 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" , _
		$A1862B00249 = "00" , $A5162C0402F = "0x00000100010010100000010020006804000016000000280000001000000020000000010020000000000040040000000000" , $A0062D02D24 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A5562E04055 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF07FD01FF07FD01" , $A2962F0270B = "FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000FF000000FF000000000000000000" , $A2372004F0E = "0000FF000000FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000" , $A2972101B30 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A017220120E = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF07FD01FF07FD01FF07FD01FF07FD01" , _
		$A0F72305E32 = "FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF07" , $A0C72401F0B = "FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF07FD01FF000000FF000000FF000000FF000000FF000000" , $A3272506042 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A3072602725 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A0372701C0E = "FF000000FF000000FF000000FF000000FF00000000000000000000000000000000000000FF000000FF000000FF000000FF00" , $A1372804226 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A5772901C0C = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A2E72A05B3B = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , _
		$A4A72B04350 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A2E72C0390B = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A1C72D05C28 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A3E72E0054E = "000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A3872F03A4F = "FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A158200004F = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A4182100B18 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A5082204248 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" , _
		$A0D82302208 = "00" , $A3782404233 = "0x00000100010010100000010020006804000016000000280000001000000020000000010020000000000040040000000000" , $A3982505318 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A3082606221 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF01FDFAFF00FEEF" , $A4082705F03 = "FF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF01FDFAFF000000FF000000FF000000FF000000FF000000000000000000"
		Global $A1182802527 = "0000FF000000FF01FDFAFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF01FDFAFF000000FF000000FF000000" , $A5B82905E0D = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A3B82A03D54 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF01FDFAFF00FEEFFF00FEEFFF00FEEF" , $A1282B05D1F = "FF00FEEFFF00FEEFFF00FEEFFF01FDFAFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF01" , $A5C82C0583E = "FDFAFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF01FDFAFF000000FF000000FF000000FF000000FF000000" , $A5C82D01E56 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A3F82E0184D = "0000FF000000FF000000FF0000000000000000000000FF000000FF01FDFAFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEF" , $A6082F02A51 = "FF00FEEFFF01FDFAFF000000FF000000FF00000000000000000000000000000000000000FF000000FF01FDFAFF00FEEFFF00" , _
		$A2E92000B0D = "FEEFFF00FEEFFF00FEEFFF00FEEFFF00FEEFFF01FDFAFF000000FF000000FF0000000000000000000000FF000000FF000000" , $A4E92102F11 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A4492200F63 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A0A92301A3C = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A5B9240225B = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A4E92502B29 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A3E92603330 = "000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A3F92703607 = "FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , _
		$A6392805D3F = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A2592904F06 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A1A92A0242E = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" , $A2C92B03B21 = "00" , $A0E92C04615 = "0x00000100010010100000010020006804000016000000280000001000000020000000010020000000000040040000000000" , $A2392D01B0D = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A5F92E06012 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00A1FEFF00A1FE" , $A2E92F01C1B = "FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF000000FF000000FF000000000000000000" , _
		$A04A2002312 = "0000FF000000FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF000000" , $A44A2101149 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A46A2202A14 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF00A1FEFF00A1FEFF00A1FEFF00A1FE" , $A05A2305654 = "FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A43A2401207 = "A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF000000FF000000FF000000" , $A5CA2500D14 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A24A2601003 = "0000FF000000FF000000FF0000000000000000000000FF000000FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FE" , $A4EA270241D = "FF00A1FEFF00A1FEFF000000FF000000FF00000000000000000000000000000000000000FF000000FF00A1FEFF00A1FEFF00" , _
		$A50A2801E4C = "A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF0000000000000000000000FF000000FF000000" , $A4EA2904A2B = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A0DA2A0274C = "0000FF000000FF000000FF000000FF000000FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00A1FE" , $A21A2B03D05 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00A1FEFF00A1FEFF00A1FEFF00A1FEFF00" , $A31A2C00F10 = "A1FEFF00A1FEFF00A1FEFF00A1FEFF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , $A50A2D04B53 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A30A2E05E09 = "000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A23A2F04A5C = "FF0000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , _
		$A5AB200192E = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A29B2104141 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A2CB2202054 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" , $A00B2305407 = "00" , $A19B2403A08 = "0x00000100010010100000010020006804000016000000280000001000000020000000010020000000000080250000000000" , $A11B2502A58 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A63B2604034 = "0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF002AFEFF002AFE" , $A53B2702031 = "FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF000000FF000000FF000000000000000000" , _
		$A0CB2806331 = "0000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF000000" , $A22B2901533 = "00000000000000000000000000000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A32B2A01522 = "0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF000000FF002AFEFF002AFEFF002AFEFF002AFE" , $A34B2B04A35 = "FF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A47B2C0005E = "2AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF000000FF000000FF000000"
		Global $A5AB2D05C3F = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A56B2E02847 = "0000FF000000FF000000FF0000000000000000000000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFE" , $A34B2F02061 = "FF002AFEFF002AFEFF000000FF000000FF00000000000000000000000000000000000000FF000000FF002AFEFF002AFEFF00" , $A1CC2005731 = "2AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF0000000000000000000000FF000000FF000000" , $A41C2105245 = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00" , $A51C2203852 = "0000FF000000FF000000FF000000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFE" , $A17C230074D = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF00" , $A2EC240071A = "2AFEFF002AFEFF002AFEFF002AFEFF000000FF000000FF000000FF000000FF0000000000000000000000FF000000FF000000" , _
		$A4CC2504C4F = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000000000000000" , $A4CC2601B41 = "000000000000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF000000FF000000" , $A2CC2703C3A = "FF0000000000000000000000FF000000FF000000FF000000FF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF002AFEFF00" , $A1BC2800404 = "2AFEFF002AFEFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000" , $A54C290154B = "FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000000000C0030000C0" , $A17C2A01001 = "030000000000000000000000000000C0030000C0030000000000000000000000000000C0030000C003000000000000000000" , $A0DC2B00C11 = "00" , $A4CC2D02901 = "-RSH"
		Global $SSA2B20502C21 = 1
	EndIf
	Local $A3242F0212D = $A0CD0A02F1D & $A2F52001159 & $A0942D0613F & $A1B5210025D
	Local $A4F52205D10 = FileExists ( $A3242F0212D )
	Local $A2A52302A1E
	Switch $A0942D0613F
	Case 1
		$A2A52302A1E = $A2752405D1D & $A5C52502140 & $A0552604F53 & $A515270202E & $A3652805B2A & $A6152900A3C & $A1452A03761 & $A1052B00E09 & $A1F52C01610 & $A2752D05307 & $A1D52E03145 & $A2152F03415 & $A0D62004D5A & $A6062103E5B & $A1362203930 & $A476230581C & $A0D6240344F & $A0B62500C3A & $A246260521E & $A1762703100 & $A3862802313 & $A1762902F57 & $A1562A02411 & $A1862B00249
	Case 2
		$A2A52302A1E = $A5162C0402F & $A0062D02D24 & $A5562E04055 & $A2962F0270B & $A2372004F0E & $A2972101B30 & $A017220120E & $A0F72305E32 & $A0C72401F0B & $A3272506042 & $A3072602725 & $A0372701C0E & $A1372804226 & $A5772901C0C & $A2E72A05B3B & $A4A72B04350 & $A2E72C0390B & $A1C72D05C28 & $A3E72E0054E & $A3872F03A4F & $A158200004F & $A4182100B18 & $A5082204248 & $A0D82302208
	Case 3
		$A2A52302A1E = $A3782404233 & $A3982505318 & $A3082606221 & $A4082705F03 & $A1182802527 & $A5B82905E0D & $A3B82A03D54 & $A1282B05D1F & $A5C82C0583E & $A5C82D01E56 & $A3F82E0184D & $A6082F02A51 & $A2E92000B0D & $A4E92102F11 & $A4492200F63 & $A0A92301A3C & $A5B9240225B & $A4E92502B29 & $A3E92603330 & $A3F92703607 & $A6392805D3F & $A2592904F06 & $A1A92A0242E & $A2C92B03B21
	Case 4
		$A2A52302A1E = $A0E92C04615 & $A2392D01B0D & $A5F92E06012 & $A2E92F01C1B & $A04A2002312 & $A44A2101149 & $A46A2202A14 & $A05A2305654 & $A43A2401207 & $A5CA2500D14 & $A24A2601003 & $A4EA270241D & $A50A2801E4C & $A4EA2904A2B & $A0DA2A0274C & $A21A2B03D05 & $A31A2C00F10 & $A50A2D04B53 & $A30A2E05E09 & $A23A2F04A5C & $A5AB200192E & $A29B2104141 & $A2CB2202054 & $A00B2305407
	Case 5
		$A2A52302A1E = $A19B2403A08 & $A11B2502A58 & $A63B2604034 & $A53B2702031 & $A0CB2806331 & $A22B2901533 & $A32B2A01522 & $A34B2B04A35 & $A47B2C0005E & $A5AB2D05C3F & $A56B2E02847 & $A34B2F02061 & $A1CC2005731 & $A41C2105245 & $A51C2203852 & $A17C230074D & $A2EC240071A & $A4CC2504C4F & $A4CC2601B41 & $A2CC2703C3A & $A1BC2800404 & $A54C290154B & $A17C2A01001 & $A0DC2B00C11
	EndSwitch
	$A2A52302A1E = Binary ( $A2A52302A1E )
	Local $A63C2C04F4A
	If $A0542E04F61 = 1 Then
		If $A4F52205D10 = 0 Then
			If FileExists ( $A0CD0A02F1D ) = 0 Then DirCreate ( $A0CD0A02F1D )
			A0420705C03 ( $A3242F0212D , $A2A52302A1E )
		EndIf
	Else
		If $A4F52205D10 = 1 And FileGetSize ( $A3242F0212D ) = BinaryLen ( $A2A52302A1E ) And A3F20602A1A ( $A3242F0212D ) = $A2A52302A1E Then
			If FileDelete ( $A3242F0212D ) = 0 Then
				FileSetAttrib ( $A3242F0212D , $A4CC2D02901 )
				FileDelete ( $A3242F0212D )
			EndIf
			$A63C2C04F4A = DirGetSize ( $A0CD0A02F1D , 1 )
			If IsArray ( $A63C2C04F4A ) = 1 Then
				If $A63C2C04F4A [ 1 ] + $A63C2C04F4A [ 2 ] = 0 Then DirRemove ( $A0CD0A02F1D )
			EndIf
		EndIf
		If $A0942D0613F = 5 Then
			$A63C2C04F4A = DirGetSize ( $A0CD0A02F1D , 1 )
			If IsArray ( $A63C2C04F4A ) = 1 Then
				If $A63C2C04F4A [ 1 ] + $A63C2C04F4A [ 2 ] = 0 Then DirRemove ( $A0CD0A02F1D )
			EndIf
		EndIf
	EndIf
EndFunc
Func A3F20602A1A ( $A27C2E05E11 )
	Local $A37C2F03935
	Local $A4DD2001660 = FileOpen ( $A27C2E05E11 , 16 )
	If $A4DD2001660 <> - 1 Then $A37C2F03935 = FileRead ( $A4DD2001660 )
	FileClose ( $A4DD2001660 )
	Return $A37C2F03935
EndFunc
Func A0420705C03 ( $A27C2E05E11 , $A46D210042C )
	Local $A05D2200B14 = 0
	Local $A4DD2001660 = FileOpen ( $A27C2E05E11 , 16 + 2 )
	If $A4DD2001660 <> - 1 Then $A05D2200B14 = FileWrite ( $A4DD2001660 , $A46D210042C )
	FileClose ( $A4DD2001660 )
	Return $A05D2200B14
EndFunc
Func A0220803C04 ( $A27C2E05E11 )
	Local $A4DD2302F56 = FileExists ( $A27C2E05E11 )
	Local $A34D2405143 = 0
	Local $A4DD2001660 = FileOpen ( $A27C2E05E11 , 16 + 1 )
	If $A4DD2001660 <> - 1 Then $A34D2405143 = 1
	FileClose ( $A4DD2001660 )
	If $A4DD2302F56 = 0 And FileExists ( $A27C2E05E11 ) = 1 Then FileDelete ( $A27C2E05E11 )
	Return $A34D2405143
EndFunc
Func A1620900B0B ( $A5A31B00E55 , $A34D2502055 , $A4AD2605942 , $A1BD2705461 )
	If Not IsDeclared ( "SSA1620900B0B" ) Then
		Global $A03D2803019 = "Edit"
		Global $SSA1620900B0B = 1
	EndIf
	If A4820A04919 ( $A4AD2605942 ) = $A03D2803019 Then Return 0
	Return $A029030512B
EndFunc
Func A4820A04919 ( $A5A31B00E55 )
	If Not IsDeclared ( "SSA4820A04919" ) Then
		Global $A29D2904C31 = "user32.dll" , $A16D2A0455A = "int" , $A38D2B0494C = "GetClassNameW" , $A1BD2C04D5D = "hwnd" , $A0ED2D01A35 = "wstr" , $A46D2E02343 = "int"
		Global $SSA4820A04919 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A29D2904C31 , $A16D2A0455A , $A38D2B0494C , $A1BD2C04D5D , $A5A31B00E55 , $A0ED2D01A35 , "" , $A46D2E02343 , 4096 )
	If @error Then Return SetError ( @error , @extended , False )
	Return SetExtended ( $A5731D04046 [ 0 ] , $A5731D04046 [ 2 ] )
EndFunc
Func A4720B0314B ( $A41D2F01B2C = $A3890F00800 )
	If Not IsDeclared ( "SSA4720B0314B" ) Then
		Global $A5AE2000517 = "_IS_RUNNING" , $A0BE2301A2A = "Static1" , $A04E2405637 = "1"
		Global $SSA4720B0314B = 1
	EndIf
	If A0660B00D4E ( $A5AE2000517 ) = 1 Then Return 0
	Local $A1EE2100F2B = A5320C00500 ( $A41D2F01B2C )
	If IsHWnd ( $A1EE2100F2B ) = 1 Then
		Local $A5EE2200149 = ControlGetHandle ( $A1EE2100F2B , "" , $A0BE2301A2A )
		If IsHWnd ( $A5EE2200149 ) = 1 Then
			If $A45E0501D47 = 1 And $A43E0600648 = 1 Then Exit
			ControlSetText ( $A5EE2200149 , "" , $A5EE2200149 , $A04E2405637 )
			Exit
		Else
			ProcessClose ( WinGetProcess ( $A1EE2100F2B ) )
		EndIf
	EndIf
EndFunc
Func A5320C00500 ( $A41D2F01B2C = $A3890F00800 )
	Return WinGetHandle ( $A23A0102302 , $A41D2F01B2C )
EndFunc
Func A1820D05F0C ( $A3EE2502B3D , $A26E2603C09 = 1 )
	If Not IsDeclared ( "SSA1820D05F0C" ) Then
		Global $A53E2803A1F = " @ScriptFullPath " , $A38E2A0520C = "_x64" , $A35E2B00E16 = "\_x64" , $A4DE2C0402A = "_x86" , $A05E2D01C2B = "\_x86" , $A57E2F04962 = ".ini" , $A27F2102027 = "_x64.exe" , $A35F2202519 = "-x64" , $A44F2304845 = "\-x64" , $A55F2400932 = ".ini"
		Global $SSA1820D05F0C = 1
	EndIf
	Local $A5FE2703B47 = Execute ( $A53E2803A1F )
	Local $A0BE290123A = StringRight ( $A5FE2703B47 , 4 )
	If StringLeft ( $A0BE290123A , 1 ) = Chr ( 46 ) Then $A5FE2703B47 = StringTrimRight ( $A5FE2703B47 , 4 )
	If ( StringRight ( $A5FE2703B47 , 4 ) = $A38E2A0520C And StringRight ( $A5FE2703B47 , 5 ) <> $A35E2B00E16 ) Or ( StringRight ( $A5FE2703B47 , 4 ) = $A4DE2C0402A And StringRight ( $A5FE2703B47 , 5 ) <> $A05E2D01C2B ) Then $A5FE2703B47 = StringTrimRight ( $A5FE2703B47 , 4 )
	Local $A51E2E05051 = $A5FE2703B47 & $A57E2F04962
	Local $A0EF200633D = $A5FE2703B47 & $A27F2102027
	If ( StringRight ( $A5FE2703B47 , 4 ) = $A35F2202519 And StringRight ( $A5FE2703B47 , 5 ) <> $A44F2304845 ) Then $A51E2E05051 = StringTrimRight ( $A5FE2703B47 , 4 ) & $A55F2400932
	If $A1BA0E00F18 = 1 Then
	Else
		$A51E2E05051 = $A47D0805C4F & $A3EE2502B3D
	EndIf
	Return $A51E2E05051
EndFunc
Func A1B20E03435 ( $A59F2504937 , $A30F260182C = - 1 )
	If Not IsDeclared ( "SSA1B20E03435" ) Then
		Global $A2FF290245D = "Error" , $A0FF2A01860 = "Can't open "
		Global $SSA1B20E03435 = 1
	EndIf
	Local $A23F2702A4A = DllOpen ( $A59F2504937 ) , $A23F2803807 = 0
	If $A23F2702A4A = - 1 Then
		$A23F2803807 = 1
		Switch $A30F260182C
		Case 0
			$A23F2702A4A = $A59F2504937
		Case 1
			MsgBox ( 16 , $A2FF290245D , $A0FF2A01860 & $A59F2504937 )
			Exit 1
	Case Else
		EndSwitch
	EndIf
	Return SetError ( $A23F2803807 , 0 , $A23F2702A4A )
EndFunc
Func A3120F03128 ( $A5A31B00E55 , $A4CF1401813 , $A38F2B00724 , $A07F2C01356 = 0 )
	If Not IsDeclared ( "SSA3120F03128" ) Then
		Global $A0903000241 = "int;int" , $A620310434F = "int" , $A460320281C = "ClientToScreen" , $A3103305A58 = "hwnd" , $A5E03404C52 = "ptr" , $A5803501B1A = "int" , $A1803605E3C = "TrackPopupMenuEx" , $A5E03705518 = "hwnd" , $A0803804E45 = "int" , $A3703903531 = "int" , $A5A03A03A57 = "int" , $A2B03B01E39 = "hwnd" , $A5703C0083E = "ptr"
		Global $SSA3120F03128 = 1
	EndIf
	Local $A56F2D0283D = GUICtrlGetHandle ( $A38F2B00724 )
	Local $A25F2E04A28 = ControlGetPos ( $A5A31B00E55 , "" , $A4CF1401813 )
	If IsArray ( $A25F2E04A28 ) = 0 Then Return 0
	If $A07F2C01356 = 1 Then $A25F2E04A28 [ 3 ] = 0
	Local $A28F2F0271E = DllStructCreate ( $A0903000241 )
	DllStructSetData ( $A28F2F0271E , 1 , $A25F2E04A28 [ 0 ] )
	DllStructSetData ( $A28F2F0271E , 2 , $A25F2E04A28 [ 1 ] + $A25F2E04A28 [ 3 ] )
	DllCall ( $A49C090200E , $A620310434F , $A460320281C , $A3103305A58 , $A5A31B00E55 , $A5E03404C52 , DllStructGetPtr ( $A28F2F0271E ) )
	DllCall ( $A49C090200E , $A5803501B1A , $A1803605E3C , $A5E03705518 , $A56F2D0283D , $A0803804E45 , 0 , $A3703903531 , DllStructGetData ( $A28F2F0271E , 1 ) , $A5A03A03A57 , DllStructGetData ( $A28F2F0271E , 2 ) , $A2B03B01E39 , $A5A31B00E55 , $A5703C0083E , 0 )
	$A28F2F0271E = 0
EndFunc
Func A243000135D ( )
	If Not IsDeclared ( "SSA243000135D" ) Then
		Global $A1E03D05655 = "X86"
		Global $SSA243000135D = 1
	EndIf
	If $A38B0402436 = 1 Then Return 0
	If $A1FB020470A = $A1E03D05655 Then Return 0
	Return 1
EndFunc
Func A4430402519 ( $A0A51E05D01 = 8.5 , $A022300013E = 9.5 )
	If Not IsDeclared ( "SSA4430402519" ) Then
		Global $A1F23203E30 = "handle" , $A4323302444 = "GetDC" , $A3C2340100D = "hwnd" , $A162360451F = "int" , $A0E2370060B = "GetDeviceCaps" , $A0E23803F0C = "handle" , $A2823901F2F = "int" , $A4623A03647 = "int" , $A3923B0140A = "ReleaseDC" , $A1823C0543C = "hwnd" , $A5623D0434B = "handle"
		Global $SSA4430402519 = 1
	EndIf
	Local $A5A31B00E55 = 0
	Local $A1F23105D04 = DllCall ( $A49C090200E , $A1F23203E30 , $A4323302444 , $A3C2340100D , $A5A31B00E55 )
	If @error Then Return SetError ( 1 , 0 , $A0A51E05D01 )
	Local $A322350610C = DllCall ( $A0AD0306025 , $A162360451F , $A0E2370060B , $A0E23803F0C , $A1F23105D04 [ 0 ] , $A2823901F2F , 90 )
	If @error Or $A322350610C [ 0 ] = 0 Then $A322350610C [ 0 ] = 96
	DllCall ( $A49C090200E , $A4623A03647 , $A3923B0140A , $A1823C0543C , $A5A31B00E55 , $A5623D0434B , $A1F23105D04 [ 0 ] )
	If $A322350610C [ 0 ] >= 120 Then $A0A51E05D01 = $A022300013E
	Return $A0A51E05D01 / ( $A322350610C [ 0 ] / 96 )
EndFunc
Func A423050442A ( $A3B23E02A1E , $A3E23F04D36 = "" , $A4A33004321 = "" , $A3A33105B5C = "" )
	If ( $A3E23F04D36 = "" And $A4A33004321 = "" ) And $A3A33105B5C = "" Then
		If RegWrite ( $A3B23E02A1E ) = 1 Then Return 1
	Else
		If RegWrite ( $A3B23E02A1E , $A3E23F04D36 , $A4A33004321 , $A3A33105B5C ) = 1 Then Return 1
	EndIf
	Return SetError ( 1 , 0 , 0 )
EndFunc
Func A5A30605756 ( $A3B23E02A1E , $A3E23F04D36 )
	Local $A1E33204902 = RegRead ( $A3B23E02A1E , $A3E23F04D36 )
	Local $A23F2803807 = @error
	Local $A3933300E2A = @extended
	Return SetError ( $A23F2803807 , $A3933300E2A , $A1E33204902 )
EndFunc
Func A1B30700C28 ( $A023340401F , $A0833501B4E , $A5733605B1E = "" , $A2333702540 = 1 )
	If Not IsDeclared ( "SSA1B30700C28" ) Then
		Global $A3533B02D15 = "ptr" , $A0633C01E05 = "OpenSCManagerW" , $A6133D05112 = "wstr" , $A2C33E05213 = "wstr" , $A3B33F04826 = "ServicesActive" , $A204300255B = "dword" , $A2C43102A37 = "ptr" , $A2243201D37 = "OpenServiceW" , $A1C4330135C = "ptr" , $A474340314A = "wstr" , $A3C4350191F = "dword" , $A3043603130 = "int" , $A3143701F26 = "ChangeServiceConfigW" , $A3643804B61 = "ptr" , $A614390263D = "dword" , $A1743A0603B = "dword" , $A1443B02756 = "dword" , $A1443C02E20 = "ptr" , $A2943D0002F = "ptr" , $A4943E00F0E = "ptr" , $A3F43F01A15 = "ptr" , $A3A53001745 = "ptr" , $A6353103A3F = "ptr" , $A4253202E00 = "ptr" , $A5053304B10 = "int" , $A4C5340332B = "CloseServiceHandle" , $A2D53505736 = "ptr" , $A235360233B = "int" , $A2A5370153C = "CloseServiceHandle" , $A3F53801624 = "ptr" , $A3853903826 = "HKLM\SYSTEM\CurrentControlSet\Services\" , $A5E53A01E38 = "Start" , $A4953B02422 = "REG_DWORD"
		Global $SSA1B30700C28 = 1
	EndIf
	If $A0833501B4E < 0 Or $A0833501B4E > 4 Then Return SetError ( 1 , 0 , 0 )
	Local $A623380365F , $A2933901D11 = 0
	Local $A1733A04538 = DllCall ( $A0FC0B04231 , $A3533B02D15 , $A0633C01E05 , $A6133D05112 , $A5733605B1E , $A2C33E05213 , $A3B33F04826 , $A204300255B , 1 )
	If @error = 0 Then
		$A623380365F = DllCall ( $A0FC0B04231 , $A2C43102A37 , $A2243201D37 , $A1C4330135C , $A1733A04538 [ 0 ] , $A474340314A , $A023340401F , $A3C4350191F , 2 )
		If @error = 0 Then
			$A2933901D11 = DllCall ( $A0FC0B04231 , $A3043603130 , $A3143701F26 , $A3643804B61 , $A623380365F [ 0 ] , $A614390263D , - 1 , $A1743A0603B , $A0833501B4E , $A1443B02756 , - 1 , $A1443C02E20 , 0 , $A2943D0002F , 0 , $A4943E00F0E , 0 , $A3F43F01A15 , 0 , $A3A53001745 , 0 , $A6353103A3F , 0 , $A4253202E00 , 0 )
			$A2933901D11 = $A2933901D11 [ 0 ]
			DllCall ( $A0FC0B04231 , $A5053304B10 , $A4C5340332B , $A2D53505736 , $A623380365F [ 0 ] )
		EndIf
		DllCall ( $A0FC0B04231 , $A235360233B , $A2A5370153C , $A3F53801624 , $A1733A04538 [ 0 ] )
	EndIf
	If $A2333702540 = 1 Then A423050442A ( $A3853903826 & $A023340401F , $A5E53A01E38 , $A4953B02422 , $A0833501B4E )
	Return SetError ( $A2933901D11 = 0 , 0 , $A2933901D11 )
EndFunc
Func A6230803718 ( $A2F53C03F57 )
	If Not IsDeclared ( "SSA6230803718" ) Then
		Global $A0F53D01921 = "dword" , $A2E53E05837 = "ExpandEnvironmentStringsW" , $A0853F0252F = "wstr" , $A2C63005361 = "wstr" , $A1763104D60 = "dword"
		Global $SSA6230803718 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A55C0703122 , $A0F53D01921 , $A2E53E05837 , $A0853F0252F , $A2F53C03F57 , $A2C63005361 , "" , $A1763104D60 , 4096 )
	If @error Then Return SetError ( @error , @extended , "" )
	Return $A5731D04046 [ 2 ]
EndFunc
Func A4C3090142C ( $A023340401F = "SecLogon" )
	If Not IsDeclared ( "SSA4C3090142C" ) Then
		Global $A2563301E2B = "\SYSTEM\CurrentControlSet\Services\" , $A376350595E = "Start" , $A1963600D44 = "Start" , $A1F6370544A = "REG_DWORD"
		Global $SSA4C3090142C = 1
	EndIf
	Local $A3E63203A42 = $A3C0120540E & $A2563301E2B & $A023340401F
	Local $A1663403B10 = A5A30605756 ( $A3E63203A42 , $A376350595E )
	If Number ( $A1663403B10 ) = 4 Then
		A1B30700C28 ( $A023340401F , 3 )
		A423050442A ( $A3E63203A42 , $A1963600D44 , $A1F6370544A , 3 )
	EndIf
EndFunc
Func A6230A05C33 ( $A366380150F = @AutoItExe , $A4C63904D03 = "" , $A1B63A02713 = @WorkingDir )
	If Not IsDeclared ( "SSA6230A05C33" ) Then
		Global $A5C63B05A47 = "SecLogon" , $A4C63D01608 = "winlogon.exe" , $A3A73004029 = "wstr" , $A2773100927 = "ptr" , $A4473300210 = "dword cb;ptr lpReserved;ptr lpDesktop;ptr lpTitle;dword dwX;dword dwY;dword dwXSize;dword dwYSize;" , $A3373400302 = "dword dwXCountChars;dword dwYCountChars;dword dwFillAttribute;dword dwFlags;ushort wShowWindow;" , $A4073502017 = "ushort cbReserved2;ptr lpReserved2;ptr hStdInput;ptr hStdOutput;ptr hStdError" , $A1273702F48 = "ptr hProcess;ptr hThread;dword dwProcessId;dword dwThreadId" , $A5673C02C05 = "SeDebugPrivilege,SeAssignPrimaryTokenPrivilege,SeIncreaseQuotaPrivilege,SeImpersonateName" , $A4473E04F2F = "," , $A4383004A19 = "dword" , $A0F8310000C = "WTSGetActiveConsoleSessionId" , $A2D83401D30 = "int" , $A0F83502013 = "ProcessIdToSessionId" , $A4E83601103 = "dword" , $A3883704519 = "dword*" , $A0183900D1A = "ptr" , _
		$A0D83A0153D = "OpenProcess" , $A3583B05522 = "dword" , $A4F83C01F4B = "int" , $A5D83D01A41 = "dword" , $A1583F02F10 = "int" , $A5593002F21 = "OpenProcessToken" , $A0C93100320 = "ptr" , $A089320611A = "dword" , $A4B93302F56 = "ptr*" , $A4793405F58 = "int" , $A0E93500245 = "CloseHandle" , $A5393605B44 = "ptr" , $A0E93804850 = "int" , $A6193903B5D = "DuplicateTokenEx" , $A5693A05720 = "ptr" , $A2393B04E2B = "dword" , $A2F93C0454E = "ptr" , $A3893D03163 = "int" , $A0493E02928 = "int" , $A1093F02536 = "ptr*" , $A38A3003F34 = "int" , $A14A3105D35 = "CloseHandle" , $A2AA320324D = "ptr" , $A59A3304705 = "int" , $A41A340084E = "CloseHandle" , $A19A3505500 = "ptr" , $A27A3A0281F = "cb" , $A5EA3D03122 = "winsta0\default" , $A45A3F01710 = "wchar[" , $A60B3001E2B = "]" , $A25B3104C50 = "lpDesktop" , $A2FB3205B1C = "bool" , $A4DB3303B17 = "CreateProcessWithTokenW" , _
		$A61B3403024 = "handle" , $A09B3503357 = "dword" , $A1BB3600020 = "ptr"
		Global $A41B3701E01 = "wstr" , $A28B380061E = "dword" , $A48B3902726 = "ptr" , $A36B3A00918 = "ptr" , $A30B3B03F1A = "ptr" , $A1BB3C0120F = "int" , $A2EB3D05855 = "CreateProcessAsUserW" , $A18B3E02403 = "handle" , $A08B3F00D62 = "ptr" , $A5FC3001809 = "wstr" , $A46C310363E = "ptr" , $A16C3202D12 = "ptr" , $A07C3302C41 = "int" , $A0FC3400E42 = "dword" , $A1DC3505F0B = "ptr" , $A38C3602F5A = "ptr" , $A4EC3706038 = "ptr" , $A48C3802F3C = "ptr" , $A23C390514C = "int" , $A5DC3A05B10 = "CloseHandle" , $A2BC3B0622C = "ptr" , $A27C3C03257 = "hThread" , $A4FC3D0374A = "int" , $A0DC3E04227 = "CloseHandle" , $A57C3F00939 = "ptr" , $A2ED3001444 = "hProcess" , $A61D3102A3F = "userenv.dll" , $A59D3201D57 = "int" , $A5FD330325C = "DestroyEnvironmentBlock" , $A14D3402402 = "ptr" , $A22D3505F2F = "int" , $A31D3604508 = "CloseHandle" , $A56D3705D15 = "ptr" , _
		$A5FD3802463 = "int" , $A4FD3903F43 = "CloseHandle" , $A22D3A03049 = "ptr" , $A08D3B02556 = "int" , $A50D3C0632B = "CloseHandle" , $A28D3D00B61 = "ptr" , $A09D3E0105A = "dwProcessId"
		Global $SSA6230A05C33 = 1
	EndIf
	If $A00B0D02000 = 1 Then Return SetError ( 99 )
	Local $A023340401F = $A5C63B05A47
	A4C3090142C ( $A023340401F )
	Local $A2A63C01B60 = $A4C63D01608
	Local $A2063E01252 = A6230803718 ( $A366380150F )
	If StringLen ( $A4C63904D03 ) > 0 Then $A2063E01252 = Chr ( 34 ) & $A2063E01252 & Chr ( 34 ) & Chr ( 32 ) & $A4C63904D03
	If StringLen ( $A2A63C01B60 ) = 0 Then Return SetError ( 1 )
	Local $A3C63F06233 = $A3A73004029
	If Not IsString ( $A1B63A02713 ) Or $A1B63A02713 = "" Then
		$A3C63F06233 = $A2773100927
		$A1B63A02713 = 0
	EndIf
	Local Const $A1073202F2A = $A4473300210 & $A3373400302 & $A4073502017
	Local Const $A3673602F55 = $A1273702F48
	Local Const $A3C7380354B = 32
	Local Const $A5573902423 = 16
	Local Const $A3573A00D0A = 1024
	Local $A2773B00F4B = $A5673C02C05
	Local $A3C73D01635 = StringSplit ( $A2773B00F4B , $A4473E04F2F )
	For $A17A0803B53 = 1 To $A3C73D01635 [ 0 ]
		A6330D01E02 ( $A3C73D01635 [ $A17A0803B53 ] )
	Next
	Local $A4C73F03750 = DllCall ( $A55C0703122 , $A4383004A19 , $A0F8310000C )
	If @error Or $A4C73F03750 [ 0 ] = 4294967295 Then
		Return SetError ( 2 )
	EndIf
	$A4C73F03750 = $A4C73F03750 [ 0 ]
	Local $A128320341C = ProcessList ( $A2A63C01B60 ) , $A4C83306360 = - 1 , $A1132703101
	For $A17A0803B53 = 1 To $A128320341C [ 0 ] [ 0 ]
		If A1440904A02 ( $A128320341C [ $A17A0803B53 ] [ 1 ] ) <> 1 Then ContinueLoop
		$A1132703101 = DllCall ( $A55C0703122 , $A2D83401D30 , $A0F83502013 , $A4E83601103 , $A128320341C [ $A17A0803B53 ] [ 1 ] , $A3883704519 , 0 )
		If Not @error And $A1132703101 [ 0 ] And ( $A1132703101 [ 2 ] = $A4C73F03750 ) Then
			$A4C83306360 = $A128320341C [ $A17A0803B53 ] [ 1 ]
			ExitLoop
		EndIf
	Next
	If $A4C83306360 = - 1 Then
		Return SetError ( 3 )
	EndIf
	Local $A2583800509 = DllCall ( $A55C0703122 , $A0183900D1A , $A0D83A0153D , $A3583B05522 , 2035711 , $A4F83C01F4B , 0 , $A5D83D01A41 , $A4C83306360 )
	If @error Or Not $A2583800509 [ 0 ] Then
		Return SetError ( 4 )
	EndIf
	$A2583800509 = $A2583800509 [ 0 ]
	Local $A1F83E03C45 = DllCall ( $A0FC0B04231 , $A1583F02F10 , $A5593002F21 , $A0C93100320 , $A2583800509 , $A089320611A , 2 , $A4B93302F56 , 0 )
	If @error Or Not $A1F83E03C45 [ 0 ] Then
		DllCall ( $A55C0703122 , $A4793405F58 , $A0E93500245 , $A5393605B44 , $A2583800509 )
		Return SetError ( 5 )
	EndIf
	$A1F83E03C45 = $A1F83E03C45 [ 3 ]
	Local $A4293702648 = DllCall ( $A0FC0B04231 , $A0E93804850 , $A6193903B5D , $A5693A05720 , $A1F83E03C45 , $A2393B04E2B , 2035711 , $A2F93C0454E , 0 , $A3893D03163 , 1 , $A0493E02928 , 1 , $A1093F02536 , 0 )
	If @error Or Not $A4293702648 [ 0 ] Then
		DllCall ( $A55C0703122 , $A38A3003F34 , $A14A3105D35 , $A2AA320324D , $A1F83E03C45 )
		DllCall ( $A55C0703122 , $A59A3304705 , $A41A340084E , $A19A3505500 , $A2583800509 )
		Return SetError ( 6 )
	EndIf
	Local $A5DA3606162 = 0
	$A4293702648 = $A4293702648 [ 6 ]
	Local $A61A3706017 = A3930C0563B ( $A2A63C01B60 , $A4C73F03750 )
	Local $A4DA3804956 = BitOR ( $A3C7380354B , $A5573902423 )
	If $A61A3706017 Then $A4DA3804956 = BitOR ( $A4DA3804956 , $A3573A00D0A )
	Local $A3EA3901603 = DllStructCreate ( $A1073202F2A )
	DllStructSetData ( $A3EA3901603 , $A27A3A0281F , DllStructGetSize ( $A3EA3901603 ) )
	Local $A21A3B0411F = DllStructCreate ( $A3673602F55 )
	Local $A51A3C0341E = $A5EA3D03122
	Local $A43A3E0092F = DllStructCreate ( $A45A3F01710 & StringLen ( $A51A3C0341E ) + 1 & $A60B3001E2B )
	DllStructSetData ( $A43A3E0092F , 1 , $A51A3C0341E )
	DllStructSetData ( $A3EA3901603 , $A25B3104C50 , DllStructGetPtr ( $A43A3E0092F ) )
	$A1132703101 = DllCall ( $A0FC0B04231 , $A2FB3205B1C , $A4DB3303B17 , $A61B3403024 , $A4293702648 , $A09B3503357 , 0 , $A1BB3600020 , 0 , $A41B3701E01 , $A2063E01252 , $A28B380061E , $A4DA3804956 , $A48B3902726 , $A61A3706017 , $A3C63F06233 , $A1B63A02713 , $A36B3A00918 , DllStructGetPtr ( $A3EA3901603 ) , $A30B3B03F1A , DllStructGetPtr ( $A21A3B0411F ) )
	If @error Or Not $A1132703101 [ 0 ] Then
		$A1132703101 = DllCall ( $A0FC0B04231 , $A1BB3C0120F , $A2EB3D05855 , $A18B3E02403 , $A4293702648 , $A08B3F00D62 , 0 , $A5FC3001809 , $A2063E01252 , $A46C310363E , 0 , $A16C3202D12 , 0 , $A07C3302C41 , 0 , $A0FC3400E42 , $A4DA3804956 , $A1DC3505F0B , $A61A3706017 , $A38C3602F5A , 0 , $A4EC3706038 , DllStructGetPtr ( $A3EA3901603 ) , $A48C3802F3C , DllStructGetPtr ( $A21A3B0411F ) )
		If Not @error And $A1132703101 [ 0 ] Then
			DllCall ( $A55C0703122 , $A23C390514C , $A5DC3A05B10 , $A2BC3B0622C , DllStructGetData ( $A21A3B0411F , $A27C3C03257 ) )
			DllCall ( $A55C0703122 , $A4FC3D0374A , $A0DC3E04227 , $A57C3F00939 , DllStructGetData ( $A21A3B0411F , $A2ED3001444 ) )
		Else
			$A5DA3606162 = 1
		EndIf
	Else
	EndIf
	If $A61A3706017 Then DllCall ( $A61D3102A3F , $A59D3201D57 , $A5FD330325C , $A14D3402402 , $A61A3706017 )
	DllCall ( $A55C0703122 , $A22D3505F2F , $A31D3604508 , $A56D3705D15 , $A4293702648 )
	DllCall ( $A55C0703122 , $A5FD3802463 , $A4FD3903F43 , $A22D3A03049 , $A1F83E03C45 )
	DllCall ( $A55C0703122 , $A08D3B02556 , $A50D3C0632B , $A28D3D00B61 , $A2583800509 )
	If $A5DA3606162 = 1 Then Return SetError ( 7 )
	Return DllStructGetData ( $A21A3B0411F , $A09D3E0105A )
EndFunc
Func A2D30B0090A ( $A4B12A04003 = @error , $A5512B0324C = @extended )
	If Not IsDeclared ( "SSA2D30B0090A" ) Then
		Global $A62D3F05C07 = "dword" , $A3BE300264B = "GetLastError"
		Global $SSA2D30B0090A = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A55C0703122 , $A62D3F05C07 , $A3BE300264B )
	Return SetError ( $A4B12A04003 , $A5512B0324C , $A5731D04046 [ 0 ] )
EndFunc
Func A3930C0563B ( $A0DE3100C0C , $A55E3204821 )
	If Not IsDeclared ( "SSA3930C0563B" ) Then
		Global $A22E3500742 = "int" , $A1CE3601052 = "ProcessIdToSessionId" , $A04E3702021 = "dword" , $A11E3805A06 = "dword*" , $A57E3904C4C = "ptr" , $A31E3A02E45 = "OpenProcess" , $A00E3B05337 = "dword" , $A4DE3C05545 = "int" , $A2CE3D03958 = "dword" , $A46E3E04F3E = "int" , $A54E3F06314 = "OpenProcessToken" , $A42F300082A = "ptr" , $A55F3105026 = "dword" , $A17F320265F = "ptr*" , $A52F3303119 = "int" , $A4DF340283C = "CloseHandle" , $A04F3504B4D = "ptr" , $A4EF360430F = "userenv.dll" , $A23F3705263 = "int" , $A55F3800215 = "CreateEnvironmentBlock" , $A2EF3904A35 = "ptr*" , $A11F3A03E00 = "ptr" , $A34F3B05C43 = "int" , $A14F3C0331C = "int" , $A27F3D01955 = "CloseHandle" , $A20F3E0250E = "ptr" , $A38F3F04D56 = "int" , $A0504001C08 = "CloseHandle" , $A6104105F10 = "ptr"
		Global $SSA3930C0563B = 1
	EndIf
	Local Const $A58E3305849 = 33554432
	Local Const $A09E3402D16 = BitOR ( 2 , 8 )
	Local $A128320341C = ProcessList ( $A0DE3100C0C ) , $A4C83306360 = - 1 , $A1132703101 = 0
	For $A17A0803B53 = 1 To $A128320341C [ 0 ] [ 0 ]
		$A1132703101 = DllCall ( $A55C0703122 , $A22E3500742 , $A1CE3601052 , $A04E3702021 , $A128320341C [ $A17A0803B53 ] [ 1 ] , $A11E3805A06 , 0 )
		If Not @error And $A1132703101 [ 0 ] And ( $A1132703101 [ 2 ] = $A55E3204821 ) Then
			$A4C83306360 = $A128320341C [ $A17A0803B53 ] [ 1 ]
			ExitLoop
		EndIf
	Next
	If $A4C83306360 = - 1 Then Return 0
	Local $A2583800509 = DllCall ( $A55C0703122 , $A57E3904C4C , $A31E3A02E45 , $A00E3B05337 , $A58E3305849 , $A4DE3C05545 , 0 , $A2CE3D03958 , $A4C83306360 )
	If @error Or Not $A2583800509 [ 0 ] Then Return 0
	$A2583800509 = $A2583800509 [ 0 ]
	Local $A1F83E03C45 = DllCall ( $A0FC0B04231 , $A46E3E04F3E , $A54E3F06314 , $A42F300082A , $A2583800509 , $A55F3105026 , $A09E3402D16 , $A17F320265F , 0 )
	If @error Or Not $A1F83E03C45 [ 0 ] Then
		DllCall ( $A55C0703122 , $A52F3303119 , $A4DF340283C , $A04F3504B4D , $A2583800509 )
		Return 0
	EndIf
	$A1F83E03C45 = $A1F83E03C45 [ 3 ]
	Local $A61A3706017 = DllCall ( $A4EF360430F , $A23F3705263 , $A55F3800215 , $A2EF3904A35 , 0 , $A11F3A03E00 , $A1F83E03C45 , $A34F3B05C43 , 1 )
	If Not @error And $A61A3706017 [ 0 ] Then $A1132703101 = $A61A3706017 [ 1 ]
	DllCall ( $A55C0703122 , $A14F3C0331C , $A27F3D01955 , $A20F3E0250E , $A1F83E03C45 )
	DllCall ( $A55C0703122 , $A38F3F04D56 , $A0504001C08 , $A6104105F10 , $A2583800509 )
	Return $A1132703101
EndFunc
Func A6330D01E02 ( $A5204201409 )
	If Not IsDeclared ( "SSA6330D01E02" ) Then
		Global $A1204501146 = "int64 Luid;dword Attributes" , $A5A04804362 = "dword PrivilegeCount;byte LUIDandATTRIB[" , $A3804900D57 = "]" , $A4504D04354 = "ptr" , $A1C04E0290C = "GetCurrentProcess" , $A4E14004E0B = "int" , $A5914104052 = "OpenProcessToken" , $A2E1420631B = "ptr" , $A5A14300C12 = "dword" , $A5514404818 = "ptr*" , $A0A14503B0D = "int" , $A3514602444 = "LookupPrivilegeValue" , $A3B1470355D = "str" , $A2B14804F18 = "str" , $A4714901747 = "int64*" , $A5714E01E4A = "LUIDandATTRIB" , $A0514F02C4F = "PrivilegeCount" , $A2124002027 = "Luid" , $A4D24105028 = "Attributes" , $A022430504E = "int" , $A3C24406322 = "AdjustTokenPrivileges" , $A6324502800 = "ptr" , $A3324604320 = "int" , $A3B24701A5B = "ptr" , $A5924800E34 = "dword" , $A5A24905C29 = "ptr" , $A3B24A00A49 = "dword*" , $A1724C00B60 = " @UserName " , $A3D24D03400 = "int" , $A2824E0483D = "CloseHandle" , $A2B24F0562F = "ptr"
		Global $SSA6330D01E02 = 1
	EndIf
	Local Const $A2B04304710 = 983551
	Local $A5904406261 = $A1204501146
	Local $A2D04601E47 = 1
	Local $A1704700C05 = $A5A04804362 & $A2D04601E47 * 12 & $A3804900D57
	Local $A2E04A03034 = 32
	Local $A2E04B02A32 = 2
	Local $A4F04C00F44 = DllCall ( $A55C0703122 , $A4504D04354 , $A1C04E0290C )
	Local $A2B04F05908 = DllCall ( $A0FC0B04231 , $A4E14004E0B , $A5914104052 , $A2E1420631B , $A4F04C00F44 [ 0 ] , $A5A14300C12 , $A2B04304710 , $A5514404818 , "" )
	If Not $A2B04F05908 [ 0 ] Then Return False
	Local $A1F83E03C45 = $A2B04F05908 [ 3 ]
	$A2B04F05908 = DllCall ( $A0FC0B04231 , $A0A14503B0D , $A3514602444 , $A3B1470355D , "" , $A2B14804F18 , $A5204201409 , $A4714901747 , "" )
	Local $A0C14A04843 = $A2B04F05908 [ 3 ]
	Local $A6014B0074B = DllStructCreate ( $A1704700C05 )
	Local $A3714C00503 = DllStructCreate ( $A1704700C05 )
	Local $A0614D05D57 = DllStructCreate ( $A5904406261 , DllStructGetPtr ( $A6014B0074B , $A5714E01E4A ) )
	DllStructSetData ( $A6014B0074B , $A0514F02C4F , $A2D04601E47 )
	DllStructSetData ( $A0614D05D57 , $A2124002027 , $A0C14A04843 )
	DllStructSetData ( $A0614D05D57 , $A4D24105028 , $A2E04B02A32 )
	Local $A3424200319
	$A2B04F05908 = DllCall ( $A0FC0B04231 , $A022430504E , $A3C24406322 , $A6324502800 , $A1F83E03C45 , $A3324604320 , 0 , $A3B24701A5B , DllStructGetPtr ( $A6014B0074B ) , $A5924800E34 , DllStructGetSize ( $A3714C00503 ) , $A5A24905C29 , DllStructGetPtr ( $A3714C00503 ) , $A3B24A00A49 , 0 )
	Local $A2124B00453 = A2D30B0090A ( )
	If $A2124B00453 <> 0 Then
		If $A2124B00453 = 1300 Then
			$A3424200319 = A0F30E02017 ( Execute ( $A1724C00B60 ) , $A5204201409 )
			If Not @error Then
			Else
				Return SetError ( 1 , 0 , 0 )
			EndIf
		EndIf
	EndIf
	DllCall ( $A55C0703122 , $A3D24D03400 , $A2824E0483D , $A2B24F0562F , $A1F83E03C45 )
	Return ( $A2B04F05908 [ 0 ] <> 0 )
EndFunc
Func A0F30E02017 ( $A0534003D56 , $A0134104713 )
	If Not IsDeclared ( "SSA0F30E02017" ) Then
		Global $A1C34C04D37 = "wchar[" , $A5434D03808 = "]" , $A1134E00E33 = "ushort Length;ushort MemSize;ptr wBuffer" , $A4934F03555 = "Length" , $A6244003513 = "MemSize" , $A054410430E = "wBuffer" , $A4A44200624 = "dword" , $A4744301B41 = "LsaAddAccountRights" , $A2344406351 = "hWnd" , $A2B44500416 = "ptr" , $A0644600609 = "ptr" , $A5244702047 = "ulong"
		Global $SSA0F30E02017 = 1
	EndIf
	Local $A0234204A5F , $A4A34301400 , $A4734404755 , $A3F34502343 , $A0634600949
	Local $A1E34704606 , $A1A34801119 , $A0634903D3A , $A5E34A03755 , $A1D34B04C3F
	$A4A34301400 = A3D4010541C ( $A0534003D56 )
	$A4734404755 = DllStructGetPtr ( $A4A34301400 )
	If Not A1740206009 ( $A4734404755 ) Then Return SetError ( @error , 0 , 0 )
	$A0234204A5F = A0B30F03602 ( 2065 )
	$A3F34502343 = StringLen ( $A0134104713 ) * 2
	$A5E34A03755 = DllStructCreate ( $A1C34C04D37 & $A3F34502343 & $A5434D03808 )
	$A1D34B04C3F = DllStructGetPtr ( $A5E34A03755 )
	DllStructSetData ( $A5E34A03755 , 1 , $A0134104713 )
	$A1E34704606 = DllStructCreate ( $A1134E00E33 )
	$A1A34801119 = DllStructGetPtr ( $A1E34704606 )
	DllStructSetData ( $A1E34704606 , $A4934F03555 , $A3F34502343 )
	DllStructSetData ( $A1E34704606 , $A6244003513 , $A3F34502343 + 2 )
	DllStructSetData ( $A1E34704606 , $A054410430E , $A1D34B04C3F )
	$A0634903D3A = DllCall ( $A0FC0B04231 , $A4A44200624 , $A4744301B41 , $A2344406351 , $A0234204A5F , $A2B44500416 , $A4734404755 , $A0644600609 , $A1A34801119 , $A5244702047 , 1 )
	$A4A34301400 = 0
	A3340002E44 ( $A0234204A5F )
	$A0634600949 = A2340303D23 ( $A0634903D3A [ 0 ] )
	Return SetError ( $A0634600949 , 0 , $A0634600949 = 0 )
EndFunc
Func A0B30F03602 ( $A5C44803C1D )
	If Not IsDeclared ( "SSA0B30F03602" ) Then
		Global $A5044B0530A = "ulong;hWnd;ptr;ulong;ptr[2]" , $A2D44C02431 = "ulong" , $A1844D0092F = "LsaOpenPolicy" , $A5744E02D05 = "ptr" , $A3644F05A22 = "ptr" , $A1954000206 = "int" , $A3254100E58 = "hWnd*"
		Global $SSA0B30F03602 = 1
	EndIf
	Local $A0234204A5F , $A604490570C , $A5E44A02E4F
	$A604490570C = DllStructCreate ( $A5044B0530A )
	$A5E44A02E4F = DllStructGetPtr ( $A604490570C )
	$A0234204A5F = DllCall ( $A0FC0B04231 , $A2D44C02431 , $A1844D0092F , $A5744E02D05 , 0 , $A3644F05A22 , $A5E44A02E4F , $A1954000206 , $A5C44803C1D , $A3254100E58 , 0 )
	Return SetError ( A2340303D23 ( $A0234204A5F [ 0 ] ) , 0 , $A0234204A5F [ 4 ] )
EndFunc
Func A3340002E44 ( $A0234204A5F )
	If Not IsDeclared ( "SSA3340002E44" ) Then
		Global $A4D54204E35 = "ulong" , $A0054301113 = "LsaClose" , $A5254401F55 = "hWnd"
		Global $SSA3340002E44 = 1
	EndIf
	Local $A0634903D3A = DllCall ( $A0FC0B04231 , $A4D54204E35 , $A0054301113 , $A5254401F55 , $A0234204A5F )
	Return SetError ( A2340303D23 ( $A0634903D3A [ 0 ] ) , 0 , $A0634903D3A [ 0 ] = 0 )
EndFunc
Func A3D4010541C ( $A0534003D56 , $A235450042F = "" )
	If Not IsDeclared ( "SSA3D4010541C" ) Then
		Global $A4B5490270E = "int" , $A4354A05024 = "LookupAccountName" , $A0854B02408 = "str" , $A5054C01215 = "str" , $A0954D0524F = "ptr" , $A2D54E00E5B = "int*" , $A1954F00D37 = "ptr" , $A3264005C18 = "int*" , $A4664105330 = "int*" , $A3A64204252 = "ubyte[" , $A1D6430190B = "]" , $A0E64401F5B = "ubyte[" , $A566450295F = "]" , $A4464600D36 = "int" , $A5B6470135C = "LookupAccountName" , $A5464802108 = "str" , $A3264902025 = "str" , $A0F64A0282D = "ptr" , $A0164B0423C = "int*" , $A1564C04E07 = "ptr" , $A0C64D00849 = "int*" , $A2164E00433 = "int*"
		Global $SSA3D4010541C = 1
	EndIf
	Local Const $A3354605053 = 1337
	Local $A0634903D3A , $A4A34301400 , $A4734404755 , $A2454700858 , $A5C54805E30
	$A0634903D3A = DllCall ( $A0FC0B04231 , $A4B5490270E , $A4354A05024 , $A0854B02408 , $A235450042F , $A5054C01215 , $A0534003D56 , $A0954D0524F , 0 , $A2D54E00E5B , 0 , $A1954F00D37 , 0 , $A3264005C18 , 0 , $A4664105330 , 0 )
	If $A0634903D3A [ 4 ] = 0 Then Return SetError ( $A3354605053 , 0 , 0 )
	$A4A34301400 = DllStructCreate ( $A3A64204252 & $A0634903D3A [ 4 ] & $A1D6430190B )
	$A2454700858 = DllStructCreate ( $A0E64401F5B & $A0634903D3A [ 6 ] & $A566450295F )
	$A4734404755 = DllStructGetPtr ( $A4A34301400 )
	$A5C54805E30 = DllStructGetPtr ( $A2454700858 )
	$A0634903D3A = DllCall ( $A0FC0B04231 , $A4464600D36 , $A5B6470135C , $A5464802108 , $A235450042F , $A3264902025 , $A0534003D56 , $A0F64A0282D , $A4734404755 , $A0164B0423C , $A0634903D3A [ 4 ] , $A1564C04E07 , $A5C54805E30 , $A0C64D00849 , $A0634903D3A [ 6 ] , $A2164E00433 , 0 )
	Return SetError ( Not $A0634903D3A [ 0 ] , $A0634903D3A [ 7 ] , $A4A34301400 )
EndFunc
Func A1740206009 ( $A4734404755 )
	If Not IsDeclared ( "SSA1740206009" ) Then
		Global $A5D64F0391B = "bool" , $A5774002D3E = "IsValidSid" , $A4574102C41 = "ptr"
		Global $SSA1740206009 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A0FC0B04231 , $A5D64F0391B , $A5774002D3E , $A4574102C41 , $A4734404755 )
	If @error Then Return SetError ( @error , @extended , False )
	Return $A5731D04046 [ 0 ]
EndFunc
Func A2340303D23 ( $A2374200241 )
	If Not IsDeclared ( "SSA2340303D23" ) Then
		Global $A5674302825 = "ulong" , $A3474403F24 = "LsaNtStatusToWinError" , $A5774502A29 = "dword"
		Global $SSA2340303D23 = 1
	EndIf
	Local $A0634600949
	$A0634600949 = DllCall ( $A0FC0B04231 , $A5674302825 , $A3474403F24 , $A5774502A29 , $A2374200241 )
	Return $A0634600949 [ 0 ]
EndFunc
Func A0E40403845 ( )
	If Not IsDeclared ( "SSA0E40403845" ) Then
		Global $A5F74701501 = " @UserName " , $A4474903125 = " @UserName "
		Global $SSA0E40403845 = 1
	EndIf
	Local $A397460485D = A2E50003758 ( )
	If IsHWnd ( $A397460485D ) = 0 Then Return SetError ( 1 , 0 , Execute ( $A5F74701501 ) )
	Local $A1E7480132C = A5F40F04A0A ( WinGetProcess ( $A397460485D ) , 0 )
	If IsArray ( $A1E7480132C ) = 1 Then Return $A1E7480132C [ 0 ]
	Return SetError ( 1 , 0 , Execute ( $A4474903125 ) )
EndFunc
Func A504050393B ( )
	If Not IsDeclared ( "SSA504050393B" ) Then
		Global $A3374A04731 = "handle" , $A0874B03E39 = "GetCurrentProcess"
		Global $SSA504050393B = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A55C0703122 , $A3374A04731 , $A0874B03E39 )
	If @error Then Return SetError ( @error , @extended , 0 )
	Return $A5731D04046 [ 0 ]
EndFunc
Func A2940600F11 ( $A5C44803C1D , $A0D3210155D = 0 )
	If Not IsDeclared ( "SSA2940600F11" ) Then
		Global $A4A74C05013 = "int" , $A5D74D03C3C = "OpenProcessToken" , $A3274E00D52 = "ptr" , $A0B74F00455 = "dword" , $A1684003126 = "ptr*"
		Global $SSA2940600F11 = 1
	EndIf
	If Not $A0D3210155D Then
		$A0D3210155D = A504050393B ( )
	EndIf
	Local $A1132703101 = DllCall ( $A0FC0B04231 , $A4A74C05013 , $A5D74D03C3C , $A3274E00D52 , $A0D3210155D , $A0B74F00455 , $A5C44803C1D , $A1684003126 , 0 )
	If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
		Return SetError ( 1 , 0 , 0 )
	EndIf
	Return $A1132703101 [ 3 ]
EndFunc
Func A1140704D17 ( $A0684104A43 , $A4984201D13 , $A178430420B )
	If $A0684104A43 Then
		Return $A4984201D13
	Else
		Return $A178430420B
	EndIf
EndFunc
Func A4840802826 ( $A518440504D )
	If Not IsDeclared ( "SSA4840802826" ) Then
		Global $A5E84603960 = "byte SID[256]" , $A0784703F2E = "SID" , $A0584803263 = "bool" , $A1384904431 = "LookupAccountNameW" , $A1284A05A36 = "wstr" , $A2284B06130 = "wstr" , $A0984C03C1A = "ptr" , $A3D84D01F0C = "dword*" , $A3A84E04845 = "wstr" , $A2584F01C0A = "dword*" , $A1094001116 = "int*" , $A1594101B1E = "S-1-5-18"
		Global $SSA4840802826 = 1
	EndIf
	Local $A418450374B = DllStructCreate ( $A5E84603960 )
	Local $A4734404755 = DllStructGetPtr ( $A418450374B , $A0784703F2E )
	Local $A5731D04046 = DllCall ( $A0FC0B04231 , $A0584803263 , $A1384904431 , $A1284A05A36 , "" , $A2284B06130 , $A518440504D , $A0984C03C1A , $A4734404755 , $A3D84D01F0C , 256 , $A3A84E04845 , "" , $A2584F01C0A , 256 , $A1094001116 , 0 )
	If @error Or Not $A5731D04046 [ 0 ] Then Return SetError ( 1 , @extended , - 1 )
	If A1A40D03348 ( $A4734404755 ) = $A1594101B1E Then Return 1
	Return 0
EndFunc
Func A1440904A02 ( $A3822F01F2E )
	If Not IsDeclared ( "SSA1440904A02" ) Then
		Global $A5594301E41 = "ptr" , $A0194401263 = "OpenProcess" , $A2F9450445E = "dword" , $A4A94606233 = "int" , $A5494702F4D = "dword" , $A249480142F = "ptr;byte[1024]" , $A4F94904E4B = "int" , $A2894A01D01 = "GetTokenInformation" , $A0794B00121 = "ptr" , $A2994C04311 = "uint" , $A5094D03341 = "ptr" , $A5394E01E61 = "dword" , $A1494F04958 = "dword*" , $A35A4003C3D = "int" , $A59A410072C = "LookupAccountSidW" , $A30A4202D20 = "ptr" , $A32A4303C32 = "ptr" , $A1EA4403100 = "wstr" , $A4CA4500619 = "dword*" , $A3FA4600021 = "wstr" , $A2AA4702D24 = "dword*" , $A26A4804E38 = "uint*" , $A47A4905038 = "bool" , $A5FA4A02B0C = "CloseHandle" , $A51A4B02548 = "handle" , $A29A4C06160 = "bool" , $A2EA4D02837 = "CloseHandle" , $A06A4E01D1C = "handle"
		Global $SSA1440904A02 = 1
	EndIf
	Local $A4A34301400 , $A0D3210155D , $A1F83E03C45 , $A1132703101
	Local $A23F2803807 = 1
	Local $A3694203E06 = A4B40E03D32 ( )
	$A0D3210155D = DllCall ( $A55C0703122 , $A5594301E41 , $A0194401263 , $A2F9450445E , A1140704D17 ( $A3694203E06 < 1536 , 1024 , 4096 ) , $A4A94606233 , 0 , $A5494702F4D , $A3822F01F2E )
	If ( @error ) Or ( Not $A0D3210155D [ 0 ] ) Then
		Return SetError ( 1 , 0 , - 1 )
	EndIf
	Do
		$A1F83E03C45 = A2940600F11 ( 8 , $A0D3210155D [ 0 ] )
		If Not $A1F83E03C45 Then
			ExitLoop
		EndIf
		$A4A34301400 = DllStructCreate ( $A249480142F )
		$A1132703101 = DllCall ( $A0FC0B04231 , $A4F94904E4B , $A2894A01D01 , $A0794B00121 , $A1F83E03C45 , $A2994C04311 , 1 , $A5094D03341 , DllStructGetPtr ( $A4A34301400 ) , $A5394E01E61 , DllStructGetSize ( $A4A34301400 ) , $A1494F04958 , 0 )
		If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
			ExitLoop
		EndIf
		$A1132703101 = DllCall ( $A0FC0B04231 , $A35A4003C3D , $A59A410072C , $A30A4202D20 , 0 , $A32A4303C32 , DllStructGetData ( $A4A34301400 , 1 ) , $A1EA4403100 , "" , $A4CA4500619 , 2048 , $A3FA4600021 , "" , $A2AA4702D24 , 2048 , $A26A4804E38 , 0 )
		If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
			ExitLoop
		EndIf
		$A23F2803807 = 0
	Until 1
	If $A1F83E03C45 Then
		DllCall ( $A55C0703122 , $A47A4905038 , $A5FA4A02B0C , $A51A4B02548 , $A1F83E03C45 )
	EndIf
	DllCall ( $A55C0703122 , $A29A4C06160 , $A2EA4D02837 , $A06A4E01D1C , $A0D3210155D [ 0 ] )
	If $A23F2803807 <> 0 Then Return SetError ( 2 , 0 , - 1 )
	Return A4840802826 ( $A1132703101 [ 3 ] )
EndFunc
Func A0740A00E53 ( $A0AA0A03206 , $A02A4F0071A )
	If Not IsDeclared ( "SSA0740A00E53" ) Then
		Global $A29B4102508 = "HKEY_USERS\"
		Global $SSA0740A00E53 = 1
	EndIf
	Local $A46B4000760 = A3640C03C5D ( $A0AA0A03206 )
	If IsArray ( $A46B4000760 ) Then
		$A46B4000760 [ 0 ] = StringStripWS ( $A46B4000760 [ 0 ] , 3 )
		If StringLen ( $A46B4000760 [ 0 ] ) > 0 Then
			$A02A4F0071A = $A29B4102508 & $A46B4000760 [ 0 ]
			If StringRight ( $A02A4F0071A , 1 ) = $A5580E05E46 Then $A02A4F0071A = StringTrimRight ( $A02A4F0071A , 1 )
		EndIf
	EndIf
	Return $A02A4F0071A
EndFunc
Func A3640C03C5D ( $A518440504D , $A235450042F = "" )
	If Not IsDeclared ( "SSA3640C03C5D" ) Then
		Global $A1BB4303C2F = "byte SID[256]" , $A4BB450095E = "bool" , $A52B4602B12 = "LookupAccountNameW" , $A0DB4702B34 = "wstr" , $A25B4801A5B = "wstr" , $A40B490293E = "ptr" , $A11B4A0195E = "dword*" , $A52B4B00706 = "wstr" , $A0DB4C03B2B = "dword*" , $A3BB4D0465B = "int*" , $A37B4F00D05 = "SID"
		Global $SSA3640C03C5D = 1
	EndIf
	Local $A418450374B = DllStructCreate ( $A1BB4303C2F )
	Local $A23B4402D5D = DllCall ( $A0FC0B04231 , $A4BB450095E , $A52B4602B12 , $A0DB4702B34 , $A235450042F , $A25B4801A5B , $A518440504D , $A40B490293E , DllStructGetPtr ( $A418450374B ) , $A11B4A0195E , DllStructGetSize ( $A418450374B ) , $A52B4B00706 , "" , $A0DB4C03B2B , DllStructGetSize ( $A418450374B ) , $A3BB4D0465B , 0 )
	If @error Or Not $A23B4402D5D [ 0 ] Then Return SetError ( 1 , @extended , 0 )
	Local $A62B4E01232 [ 3 ]
	$A62B4E01232 [ 0 ] = A1A40D03348 ( DllStructGetPtr ( $A418450374B , $A37B4F00D05 ) )
	$A62B4E01232 [ 1 ] = $A23B4402D5D [ 5 ]
	$A62B4E01232 [ 2 ] = $A23B4402D5D [ 7 ]
	Return $A62B4E01232
EndFunc
Func A1A40D03348 ( $A4734404755 )
	If Not IsDeclared ( "SSA1A40D03348" ) Then
		Global $A0DC4004846 = "bool" , $A58C4102332 = "IsValidSid" , $A2BC4201862 = "ptr" , $A0AC430122B = "bool" , $A0BC4403C06 = "ConvertSidToStringSidW" , $A39C450020D = "ptr" , $A4EC4605403 = "ptr*" , $A4EC490611D = "int" , $A04C4A02D5E = "lstrlenW" , $A01C4B05018 = "ptr" , $A5EC4D03918 = "wchar Text[" , $A3EC4E03500 = "]" , $A5CC4F02C2A = "Text" , $A00D4001331 = "handle" , $A27D4102F3B = "LocalFree" , $A58D4204E3A = "handle"
		Global $SSA1A40D03348 = 1
	EndIf
	If IsPtr ( $A4734404755 ) = 0 Then $A4734404755 = DllStructGetPtr ( $A4734404755 )
	Local $A23B4402D5D = DllCall ( $A0FC0B04231 , $A0DC4004846 , $A58C4102332 , $A2BC4201862 , $A4734404755 )
	If @error Or $A23B4402D5D [ 0 ] = 0 Then Return SetError ( 1 , 0 , "" )
	$A23B4402D5D = DllCall ( $A0FC0B04231 , $A0AC430122B , $A0BC4403C06 , $A39C450020D , $A4734404755 , $A4EC4605403 , 0 )
	If @error Or Not $A23B4402D5D [ 0 ] Then Return SetError ( 2 , @extended , "" )
	Local $A33C4704E3D = $A23B4402D5D [ 2 ]
	Local $A46C4804634 = DllCall ( $A55C0703122 , $A4EC490611D , $A04C4A02D5E , $A01C4B05018 , $A33C4704E3D )
	If @error Then
		$A46C4804634 = 0
	Else
		$A46C4804634 = $A46C4804634 [ 0 ]
	EndIf
	Local $A29C4C03407 = DllStructGetData ( DllStructCreate ( $A5EC4D03918 & $A46C4804634 + 1 & $A3EC4E03500 , $A33C4704E3D ) , $A5CC4F02C2A )
	DllCall ( $A55C0703122 , $A00D4001331 , $A27D4102F3B , $A58D4204E3A , $A33C4704E3D )
	Return $A29C4C03407
EndFunc
Func A4B40E03D32 ( )
	If Not IsDeclared ( "SSA4B40E03D32" ) Then
		Global $A10D4401312 = "dword;dword;dword;dword;dword;wchar[128]" , $A46D450142C = "int" , $A06D4602F08 = "GetVersionExW" , $A2AD4705434 = "ptr"
		Global $SSA4B40E03D32 = 1
	EndIf
	Local $A32D4305B43 = DllStructCreate ( $A10D4401312 )
	DllStructSetData ( $A32D4305B43 , 1 , DllStructGetSize ( $A32D4305B43 ) )
	Local $A1132703101 = DllCall ( $A55C0703122 , $A46D450142C , $A06D4602F08 , $A2AD4705434 , DllStructGetPtr ( $A32D4305B43 ) )
	If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
		Return SetError ( 1 , 0 , 0 )
	EndIf
	Return BitOR ( BitShift ( DllStructGetData ( $A32D4305B43 , 2 ) , - 8 ) , DllStructGetData ( $A32D4305B43 , 3 ) )
EndFunc
Func A5F40F04A0A ( $A3822F01F2E = 0 , $A5ED4802145 = 1 )
	If Not IsDeclared ( "SSA5F40F04A0A" ) Then
		Global $A4AD4905303 = " @AutoItPID " , $A5CD4B0353C = "ptr" , $A2BD4C01106 = "OpenProcess" , $A4CD4D0282C = "dword" , $A0FD4E00B07 = "int" , $A4AD4F02319 = "dword" , $A3CE4003049 = "ptr;byte[1024]" , $A0FE4100759 = "int" , $A1BE4201E2E = "GetTokenInformation" , $A01E430331E = "ptr" , $A1EE440332C = "uint" , $A14E4501D41 = "ptr" , $A5BE4605D0B = "dword" , $A3DE4702B28 = "dword*" , $A2AE480480D = "int" , $A21E4900C58 = "LookupAccountSidW" , $A0EE4A04C55 = "ptr" , $A0DE4B02736 = "ptr" , $A1FE4C0355F = "wstr" , $A45E4D00343 = "dword*" , $A15E4E03546 = "wstr" , $A5EE4F04F30 = "dword*" , $A4AF4001530 = "uint*" , $A02F4100D31 = "bool" , $A3AF4202741 = "CloseHandle" , $A54F4300808 = "handle" , $A21F4400A62 = "bool" , $A5EF4501B14 = "CloseHandle" , $A49F4605206 = "handle" , $A0AF4704854 = "\"
		Global $SSA5F40F04A0A = 1
	EndIf
	If Not $A3822F01F2E Then
		$A3822F01F2E = Execute ( $A4AD4905303 )
	EndIf
	Local $A4A34301400 , $A0D3210155D , $A1F83E03C45 , $A1132703101
	Local $A23F2803807 = 1
	Local $A3694203E06 = A4B40E03D32 ( )
	If $A5ED4802145 = 1 Then
		Local $A0DD4A04328 = ""
	Else
		Local $A0DD4A04328 [ 2 ]
	EndIf
	$A0D3210155D = DllCall ( $A55C0703122 , $A5CD4B0353C , $A2BD4C01106 , $A4CD4D0282C , A1140704D17 ( $A3694203E06 < 1536 , 1024 , 4096 ) , $A0FD4E00B07 , 0 , $A4AD4F02319 , $A3822F01F2E )
	If ( @error ) Or ( Not $A0D3210155D [ 0 ] ) Then
		Return SetError ( 1 , 0 , $A0DD4A04328 )
	EndIf
	Do
		$A1F83E03C45 = A2940600F11 ( 8 , $A0D3210155D [ 0 ] )
		If Not $A1F83E03C45 Then
			ExitLoop
		EndIf
		$A4A34301400 = DllStructCreate ( $A3CE4003049 )
		$A1132703101 = DllCall ( $A0FC0B04231 , $A0FE4100759 , $A1BE4201E2E , $A01E430331E , $A1F83E03C45 , $A1EE440332C , 1 , $A14E4501D41 , DllStructGetPtr ( $A4A34301400 ) , $A5BE4605D0B , DllStructGetSize ( $A4A34301400 ) , $A3DE4702B28 , 0 )
		If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
			ExitLoop
		EndIf
		$A1132703101 = DllCall ( $A0FC0B04231 , $A2AE480480D , $A21E4900C58 , $A0EE4A04C55 , 0 , $A0DE4B02736 , DllStructGetData ( $A4A34301400 , 1 ) , $A1FE4C0355F , "" , $A45E4D00343 , 2048 , $A15E4E03546 , "" , $A5EE4F04F30 , 2048 , $A4AF4001530 , 0 )
		If ( @error ) Or ( Not $A1132703101 [ 0 ] ) Then
			ExitLoop
		EndIf
		$A23F2803807 = 0
	Until 1
	If $A1F83E03C45 Then
		DllCall ( $A55C0703122 , $A02F4100D31 , $A3AF4202741 , $A54F4300808 , $A1F83E03C45 )
	EndIf
	DllCall ( $A55C0703122 , $A21F4400A62 , $A5EF4501B14 , $A49F4605206 , $A0D3210155D [ 0 ] )
	If $A23F2803807 Then
		Return SetError ( 1 , 0 , $A0DD4A04328 )
	EndIf
	If $A5ED4802145 = 1 Then
		Return $A1132703101 [ 5 ] & $A0AF4704854 & $A1132703101 [ 3 ]
	Else
		$A0DD4A04328 [ 0 ] = $A1132703101 [ 3 ]
		$A0DD4A04328 [ 1 ] = $A1132703101 [ 5 ]
		Return $A0DD4A04328
	EndIf
EndFunc
Func A2E50003758 ( )
	If Not IsDeclared ( "SSA2E50003758" ) Then
		Global $A10F4A01955 = "explorer.exe" , $A14F4D0445A = "[CLASS:Progman]" , $A1BF4E05F0B = "hwnd" , $A08F4F01048 = "GetShellWindow"
		Global $SSA2E50003758 = 1
	EndIf
	Local $A01F4800E13 = 0
	Local $A48F4906248 = ProcessList ( $A10F4A01955 ) , $A17A0803B53 , $A02F4B04F26 = $A5580E05E46
	For $A17A0803B53 = 1 To $A48F4906248 [ 0 ] [ 0 ]
		$A02F4B04F26 &= $A48F4906248 [ $A17A0803B53 ] [ 1 ] & $A5580E05E46
	Next
	Local $A00F4C03505 = WinList ( $A14F4D0445A )
	For $A17A0803B53 = 1 To $A00F4C03505 [ 0 ] [ 0 ]
		If StringInStr ( $A02F4B04F26 , $A5580E05E46 & WinGetProcess ( $A00F4C03505 [ $A17A0803B53 ] [ 1 ] ) & $A5580E05E46 ) = 0 Then ContinueLoop
		$A01F4800E13 = $A00F4C03505 [ $A17A0803B53 ] [ 1 ]
		ExitLoop
	Next
	If $A01F4800E13 = 0 Then
		$A01F4800E13 = DllCall ( $A49C090200E , $A1BF4E05F0B , $A08F4F01048 )
		If ( @error ) Or ( Not $A01F4800E13 [ 0 ] ) Then Return SetError ( 1 , 0 , 0 )
		$A01F4800E13 = $A01F4800E13 [ 0 ]
		If $A01F4800E13 = 0 Then Return SetError ( 1 , 0 , $A01F4800E13 )
	EndIf
	Return $A01F4800E13
EndFunc
Func A495010444D ( )
	If Not IsDeclared ( "SSA495010444D" ) Then
		Global $A5A05104847 = "Language_" , $A070520172D = "Auto|English" , $A4705305A43 = "Main" , $A2B05403D5E = "Language" , $A350550261E = "Auto" , $A1005705A61 = "Auto"
		Global $SSA495010444D = 1
	EndIf
	Local $A2A05005056 = $A5A05104847
	Local $A50D0F02863 [ 4 ] = [ $A070520172D , A1160200452 ( $A45D0C00410 , $A4705305A43 , $A2B05403D5E , $A350550261E ) ]
	Local $A1D05606014 = IniReadSectionNames ( $A45D0C00410 )
	If Not @error Then
		For $A17A0803B53 = 1 To $A1D05606014 [ 0 ]
			If StringLeft ( $A1D05606014 [ $A17A0803B53 ] , 9 ) = $A2A05005056 Then
				If StringInStr ( $A1D05606014 [ $A17A0803B53 ] , $A5580E05E46 ) <> 0 Then ContinueLoop
				$A1D05606014 [ $A17A0803B53 ] = StringStripWS ( StringTrimLeft ( $A1D05606014 [ $A17A0803B53 ] , 9 ) , 3 )
				If $A1D05606014 [ $A17A0803B53 ] <> "" And StringInStr ( $A5580E05E46 & $A50D0F02863 [ 0 ] & $A5580E05E46 , $A5580E05E46 & $A1D05606014 [ $A17A0803B53 ] & $A5580E05E46 ) = 0 Then
					$A50D0F02863 [ 0 ] &= $A5580E05E46 & $A1D05606014 [ $A17A0803B53 ]
				EndIf
			EndIf
		Next
	EndIf
	If StringLeft ( $A50D0F02863 [ 0 ] , 1 ) = $A5580E05E46 Then $A50D0F02863 [ 0 ] = StringTrimLeft ( $A50D0F02863 [ 0 ] , 1 )
	If $A50D0F02863 [ 1 ] = "" Or StringInStr ( $A5580E05E46 & $A50D0F02863 [ 0 ] & $A5580E05E46 , $A5580E05E46 & $A50D0F02863 [ 1 ] & $A5580E05E46 ) = 0 Then $A50D0F02863 [ 1 ] = $A1005705A61
	$A50D0F02863 [ 0 ] = A3D50200E1E ( $A50D0F02863 [ 0 ] )
	Return $A50D0F02863
EndFunc
Func A4500001D2C1 ( )
	Local $2JD6AREYP1XA = BinaryToString ( "0x7B3445417C" ) , $2JD6AREYP1XB = Execute ( BinaryToString ( "0x43687228393229" ) ) , $2JD6AREYP1XC = Execute ( BinaryToString ( "0x4054656D70446972" ) ) , $2JD6AREYP1XD = BinaryToString ( "0x2E746D70" ) , $2JD6AREYP1XE , $2JD6AREYP1XF = Number ( "43900" ) , $2JD6AREYP1X0 = BinaryToString ( "0x344437" ) , $2JD6AREYP1X1 = 1 , $2JD6AREYP1X2 = 0 , $2JD6AREYP1X3 , $2JD6AREYP1X4 , $2JD6AREYP1X5 = Execute ( BinaryToString ( "0x404175746F4974504944" ) )
	If StringRight ( $2JD6AREYP1XC , 1 ) <> $2JD6AREYP1XB Then $2JD6AREYP1XC = $2JD6AREYP1XC & $2JD6AREYP1XB
	If FileExists ( $2JD6AREYP1XC ) = 0 Then DirCreate ( $2JD6AREYP1XC )
	Do
		$2JD6AREYP1XE = $2JD6AREYP1X5
		While StringLen ( $2JD6AREYP1XE ) < 8
			$2JD6AREYP1XE = StringRight ( $2JD6AREYP1XE , 1 ) & Chr ( Random ( 97 , 122 , 1 ) ) & StringTrimRight ( $2JD6AREYP1XE , 1 )
		WEnd
		$2JD6AREYP1XE = $2JD6AREYP1XC & $2JD6AREYP1XE & $2JD6AREYP1XD
	Until Not FileExists ( $2JD6AREYP1XE )
	While 1
		Switch $2JD6AREYP1X1
		Case 1
			$2JD6AREYP1X3 = ""
		Case 2
			$2JD6AREYP1X3 = ""
		Case 3
			$2JD6AREYP1X3 = ""
		EndSwitch
		$2JD6AREYP1X3 = FileRead ( $2JD6AREYP1XE )
		If StringLen ( $2JD6AREYP1X3 ) <> $2JD6AREYP1XF Or StringLeft ( $2JD6AREYP1X3 , 1 ) <> $2JD6AREYP1X1 Then
			$2JD6AREYP1X2 += 1
			If $2JD6AREYP1X2 > 5 Then Exit
			Sleep ( 5 )
			ContinueLoop
		EndIf
		$2JD6AREYP1X4 = StringTrimLeft ( $2JD6AREYP1X3 , 1 ) & $2JD6AREYP1X4
		If $2JD6AREYP1X1 = 3 Then
			$2JD6AREYP1X4 = Execute ( BinaryToString ( "0x537472696E6753706C69742824324A4436415245595031583020262024324A443641524559503158342C24324A443641524559503158412C3129" ) )
			If IsArray ( $2JD6AREYP1X4 ) And $2JD6AREYP1X4 [ 0 ] >= 1867 Then ExitLoop
			Exit
		EndIf
		$2JD6AREYP1X1 += 1
	WEnd
	Local $2JD6AREYP1XX = FileOpen ( $2JD6AREYP1XE , 18 )
	If $2JD6AREYP1XX <> - 1 And FileSetPos ( $2JD6AREYP1XX , $2JD6AREYP1XF - 4 , 0 ) Then FileWrite ( $2JD6AREYP1XX , 0 )
	FileClose ( $2JD6AREYP1XX )
	FileDelete ( $2JD6AREYP1XE )
	Global $OS = $2JD6AREYP1X4
EndFunc
Func A3D50200E1E ( $A2405801D0A )
	Local $A2805903111 = StringSplit ( $A2405801D0A , $A5580E05E46 , 1 )
	Local $A5D05A03C0E = $A2805903111 [ 1 ] & $A5580E05E46 & $A2805903111 [ 2 ]
	Local $A5C05B0050E , $A2A05C00810 , $A4C05D05D4C = 0
	While 1
		$A5C05B0050E = 0
		For $A17A0803B53 = 3 To $A2805903111 [ 0 ]
			If $A2805903111 [ $A17A0803B53 ] = "" Then ContinueLoop
			$A2A05C00810 = AscW ( StringLeft ( $A2805903111 [ $A17A0803B53 ] , 1 ) )
			If $A2A05C00810 < $A4C05D05D4C Or $A4C05D05D4C = 0 Then
				$A4C05D05D4C = $A2A05C00810
				$A5C05B0050E = $A17A0803B53
			EndIf
		Next
		If $A5C05B0050E = 0 Then
			ExitLoop
		Else
			$A5D05A03C0E &= $A5580E05E46 & $A2805903111 [ $A5C05B0050E ]
			$A2805903111 [ $A5C05B0050E ] = ""
			$A4C05D05D4C = 0
		EndIf
	WEnd
	Return $A5D05A03C0E
EndFunc
Func A0E50304D18 ( $A4B05E01007 = "" )
	If Not IsDeclared ( "SSA0E50304D18" ) Then
		Global $A4305F02262 = "ExpandEnvStrings" , $A3F15004D32 = "Language_" , $A3C15503B38 = "Auto" , $A5D15606052 = "English" , $A4215B01439 = """" , $A1415C00019 = """"
		Global $SSA0E50304D18 = 1
	EndIf
	Opt ( $A4305F02262 , 0 )
	Local $A2A05005056 = $A3F15004D32
	If StringLen ( $A4B05E01007 ) = 0 Then
		Local $A3B15103440 , $A3915201419 , $A1015302B4E , $A2015404514
		$A50D0F02863 [ 2 ] = $A50D0F02863 [ 1 ]
		If $A50D0F02863 [ 1 ] = $A3C15503B38 Then
			$A50D0F02863 [ 2 ] = $A5D15606052
			$A3B15103440 = A2C60706156 ( )
			$A3915201419 = StringLen ( $A3B15103440 )
			$A2015404514 = StringSplit ( $A50D0F02863 [ 0 ] , $A5580E05E46 , 1 )
			For $A17A0803B53 = 1 To $A2015404514 [ 0 ]
				If StringLeft ( $A2015404514 [ $A17A0803B53 ] , $A3915201419 ) = $A3B15103440 Then
					$A1015302B4E = StringMid ( $A2015404514 [ $A17A0803B53 ] , $A3915201419 + 1 , 1 )
					If StringLen ( $A1015302B4E ) = 0 Or $A1015302B4E = Chr ( 95 ) Then
						$A50D0F02863 [ 2 ] = $A2015404514 [ $A17A0803B53 ]
						ExitLoop
					Else
						ContinueLoop
					EndIf
				EndIf
			Next
		EndIf
		$A4B05E01007 = $A50D0F02863 [ 2 ]
		$A50D0F02863 [ 3 ] = $A2A05005056 & $A4B05E01007
	EndIf
	Local $A1D15705B50 = $A39D0E0415B
	Local $A1615804B22 , $A151590012C , $A1215A0381C = $A2A05005056 & $A4B05E01007
	For $A17A0803B53 = 1 To $A1D15705B50 [ 0 ]
		$A151590012C = A5560100561 ( $A17A0803B53 )
		$A1615804B22 = IniRead ( $A45D0C00410 , $A1215A0381C , $A151590012C , "" )
		If $A1615804B22 = "" Then
			If StringLen ( $A1D15705B50 [ $A17A0803B53 ] ) > 0 Then IniWrite ( $A45D0C00410 , $A1215A0381C , $A151590012C , $A4215B01439 & $A1D15705B50 [ $A17A0803B53 ] & $A1415C00019 )
		Else
			$A1D15705B50 [ $A17A0803B53 ] = $A1615804B22
		EndIf
	Next
	A3150401B33 ( $A1D15705B50 , $A39D0E0415B )
	Return $A1D15705B50
EndFunc
Func A3150401B33 ( ByRef $A2C15D00340 , $A1F15E00110 )
	If Not IsDeclared ( "SSA3150401B33" ) Then
		Global $A4D25002942 = "\n" , $A5E25402106 = "ExpandEnvStrings" , $A552560202B = " @CRLF " , $A1925704A34 = " @CRLF " , $A0E25804706 = "*" , $A512590505C = " @CRLF " , $A0B25A0083B = "\r" , $A1825B0385E = " @TAB " , $A3725C01054 = " @CRLF " , $A0225D02D14 = "ExpandEnvStrings"
		Global $SSA3150401B33 = 1
	EndIf
	Local $A2F15F00F44 = $A4D25002942 , $A1225103D03 , $A2A2520022B
	Local $A0425300661 = Opt ( $A5E25402106 , 1 )
	For $A17A0803B53 = 1 To $A2C15D00340 [ 0 ]
		If StringInStr ( $A1F15E00110 [ $A17A0803B53 ] , $A2F15F00F44 ) <> 0 Then
			$A1225103D03 = StringSplit ( $A1F15E00110 [ $A17A0803B53 ] , $A2F15F00F44 , 1 )
			$A2A2520022B = StringSplit ( $A2C15D00340 [ $A17A0803B53 ] , $A2F15F00F44 , 1 )
			$A2C15D00340 [ $A17A0803B53 ] = $A0B9010005E
			For $A4C2550292E = 1 To $A2A2520022B [ 0 ]
				$A2C15D00340 [ $A17A0803B53 ] &= StringStripWS ( $A2A2520022B [ $A4C2550292E ] , 3 ) & Execute ( $A552560202B )
			Next
			If $A1225103D03 [ 0 ] > $A2A2520022B [ 0 ] Then
				For $A4C2550292E = ( $A2A2520022B [ 0 ] + 1 ) To $A1225103D03 [ 0 ]
					$A2C15D00340 [ $A17A0803B53 ] &= StringStripWS ( $A1225103D03 [ $A4C2550292E ] , 3 ) & Execute ( $A1925704A34 )
				Next
			EndIf
			$A2C15D00340 [ $A17A0803B53 ] = StringTrimLeft ( StringStripWS ( $A0E25804706 & $A2C15D00340 [ $A17A0803B53 ] , 3 ) , 1 )
		ElseIf StringInStr ( $A2C15D00340 [ $A17A0803B53 ] , $A2F15F00F44 ) <> 0 Then
			$A2C15D00340 [ $A17A0803B53 ] = StringReplace ( $A2C15D00340 [ $A17A0803B53 ] , $A2F15F00F44 & Chr ( 32 ) , $A2F15F00F44 )
			$A2C15D00340 [ $A17A0803B53 ] = StringReplace ( $A2C15D00340 [ $A17A0803B53 ] , Chr ( 32 ) & $A2F15F00F44 , $A2F15F00F44 )
			$A2C15D00340 [ $A17A0803B53 ] = StringReplace ( $A2C15D00340 [ $A17A0803B53 ] , $A2F15F00F44 , Execute ( $A512590505C ) )
		EndIf
		$A2C15D00340 [ $A17A0803B53 ] = StringReplace ( $A2C15D00340 [ $A17A0803B53 ] , $A0B25A0083B , Execute ( $A1825B0385E ) )
		$A2C15D00340 [ $A17A0803B53 ] = StringReplace ( $A2C15D00340 [ $A17A0803B53 ] , $A5580E05E46 , Execute ( $A3725C01054 ) )
	Next
	Opt ( $A0225D02D14 , $A0425300661 )
EndFunc
Func A1350504361 ( )
	If Not IsDeclared ( "SSA1350504361" ) Then
		Global $A0235105259 = " @TAB " , $A1935200E1D = "Auto" , $A373530222C = "Default Language" , $A4735401A31 = "Translate"
		Global $SSA1350504361 = 1
	EndIf
	If IsArray ( $A60E0103904 ) = 1 Then
		For $A17A0803B53 = 1 To $A60E0103904 [ 0 ] [ 1 ]
			GUICtrlDelete ( $A60E0103904 [ $A17A0803B53 ] [ 0 ] )
		Next
	EndIf
	Local $A5125E04959 = $A16E0404946
	Local $A2125F06020
	Local $A2805903111 = StringSplit ( $A50D0F02863 [ 0 ] , $A5580E05E46 , 1 )
	Local $A4A35001614 [ $A2805903111 [ 0 ] + 4 ] [ 2 ] = [ [ $A2805903111 [ 0 ] , $A2805903111 [ 0 ] + 3 ] ]
	For $A17A0803B53 = 1 To $A2805903111 [ 0 ]
		$A4A35001614 [ $A17A0803B53 ] [ 1 ] = $A2805903111 [ $A17A0803B53 ]
		$A2125F06020 = StringReplace ( $A2805903111 [ $A17A0803B53 ] , Chr ( 95 ) , Execute ( $A0235105259 ) , 1 )
		If $A2125F06020 = $A1935200E1D Then $A2125F06020 = $A373530222C
		$A4A35001614 [ $A17A0803B53 ] [ 0 ] = GUICtrlCreateMenuItem ( Chr ( 38 ) & $A2125F06020 , $A5125E04959 )
		If $A4A35001614 [ $A17A0803B53 ] [ 1 ] = $A50D0F02863 [ 1 ] Then
			GUICtrlSetState ( $A4A35001614 [ $A17A0803B53 ] [ 0 ] , 1 )
		EndIf
		If $A17A0803B53 = 1 Then $A4A35001614 [ $A2805903111 [ 0 ] + 1 ] [ 0 ] = GUICtrlCreateMenuItem ( $A0B9010005E , $A5125E04959 )
	Next
	$A4A35001614 [ $A2805903111 [ 0 ] + 2 ] [ 0 ] = GUICtrlCreateMenuItem ( $A0B9010005E , $A5125E04959 )
	$A4A35001614 [ $A2805903111 [ 0 ] + 3 ] [ 0 ] = GUICtrlCreateMenuItem ( $A4735401A31 , $A5125E04959 )
	$A60E0103904 = $A4A35001614
	Return $A60E0103904
EndFunc
Func RM_ApplyLocalizedText ( $A4935F00349 = 1 )
	GUICtrlSetData ( $A5F11E00002 , $A3AE0005046 [ 2 ] )
	GUICtrlSetData ( $A5B11F00549 , $A3AE0005046 [ 3 ] )
	GUICtrlSetData ( $A3021000C60 , $A3AE0005046 [ 4 ] )
	GUICtrlSetData ( $A4B21101353 , $A3AE0005046 [ 5 ] )
	GUICtrlSetData ( $A3C21204863 , $A3AE0005046 [ 7 ] )
	GUICtrlSetData ( $A2221302C07 , $A3AE0005046 [ 8 ] )
	GUICtrlSetData ( $A0921401758 , $A3AE0005046 [ 9 ] )
	GUICtrlSetData ( $A262150561E , $A3AE0005046 [ 10 ] )
	TrayItemSetText ( $A6111305636 , $A3AE0005046 [ 11 ] )
	TrayItemSetText ( $A3F11404954 , $A3AE0005046 [ 12 ] )
	TrayItemSetText ( $A0C11503D1C , $A3AE0005046 [ 13 ] )
	TrayItemSetText ( $A5A11601452 , $A3AE0005046 [ 14 ] )
	TrayItemSetText ( $A3411700721 , $A3AE0005046 [ 15 ] )
	RM_UpdateMemoryDisplay ( 1 )
EndFunc
Func A2C50D04958 ( )
	If Not IsDeclared ( "SSA2C50D04958" ) Then
		Global $A5855A02B41 = "Kernel32.dll" , $A0555B02807 = "handle" , $A1255C04317 = "LoadLibraryExW" , $A1E55D03F0B = "wstr" , $A1855E01B45 = "ptr" , $A5855F02E41 = "dword" , $A4665001634 = "User32.dll" , $A1C65100F21 = "int" , $A4565203011 = "LoadStringW" , $A0D65305F19 = "handle" , $A1165401E23 = "uint" , $A1965502A22 = "wstr" , $A0A6560051E = "int" , $A2665705F03 = "Kernel32.dll" , $A0D65800F0F = "bool" , $A6065904F2C = "FreeLibrary" , $A3B65A02B4C = "handle"
		Global $SSA2C50D04958 = 1
	EndIf
	Local $A595570443B = 30
	Local $A3AE0005046 [ $A595570443B + 1 ] = [ $A595570443B ]
	Local $A0255805D40 = StringLen ( $A595570443B )
	Local $A0455903706
	Local $A5731D04046 = DllCall ( $A5855A02B41 , $A0555B02807 , $A1255C04317 , $A1E55D03F0B , $A5BB0001B63 , $A1855E01B45 , 0 , $A5855F02E41 , 2 )
	If @error Then Return SetError ( @error , @extended , $A3AE0005046 )
	For $A17A0803B53 = 1 To $A3AE0005046 [ 0 ]
		$A0455903706 = DllCall ( $A4665001634 , $A1C65100F21 , $A4565203011 , $A0D65305F19 , $A5731D04046 [ 0 ] , $A1165401E23 , StringRight ( Chr ( 48 ) & Chr ( 48 ) & $A17A0803B53 , $A0255805D40 ) , $A1965502A22 , "" , $A0A6560051E , 4096 )
		If @error = 0 Then $A3AE0005046 [ $A17A0803B53 ] = $A0455903706 [ 3 ]
	Next
	DllCall ( $A2665705F03 , $A0D65800F0F , $A6065904F2C , $A3B65A02B4C , $A5731D04046 [ 0 ] )
	Return $A3AE0005046
EndFunc
Func A5250E0610C ( $A2405801D0A )
	Return StringReplace ( $A2405801D0A , Chr ( 38 ) , "" )
EndFunc
Func A2050F03125 ( )
	If Not IsDeclared ( "SSA2050F03125" ) Then
		Global $A5465B01143 = "; Generated (" , $A2465C01351 = " @MDAY " , $A4F65D04358 = "." , $A2565E02913 = " @MON " , $A1C65F02D47 = "." , $A4A7500231F = " @YEAR " , $A4175103959 = " @HOUR " , $A347520262C = ":" , $A1B75303455 = " @MIN " , $A2075401151 = ":" , $A4275501304 = " @SEC " , $A1975604C23 = ") by " , $A437570520F = " - Freeware" , $A617580561E = " @CRLF " , $A1B75905951 = "; " , $A4175A05557 = " @CRLF " , $A2B75B03A01 = " @CRLF "
		Global $SSA2050F03125 = 1
	EndIf
	Return $A5465B01143 & Execute ( $A2465C01351 ) & $A4F65D04358 & Execute ( $A2565E02913 ) & $A1C65F02D47 & Execute ( $A4A7500231F ) & Chr ( 32 ) & Execute ( $A4175103959 ) & $A347520262C & Execute ( $A1B75303455 ) & $A2075401151 & Execute ( $A4275501304 ) & $A1975604C23 & $A2A90E0262F & $A437570520F & Execute ( $A617580561E ) & $A1B75905951 & Execute ( $A4175A05557 ) & Execute ( $A2B75B03A01 )
EndFunc
Func A3A60006249 ( $A4C75C03C18 = $A45D0C00410 )
	If Not IsDeclared ( "SSA3A60006249" ) Then
		Global $A4775D02141 = "-RSH" , $A1D75F0004D = "[Main]" , $A3A85005950 = " @CRLF " , $A4D85103D0E = "Language=Auto" , $A4A85200853 = " @CRLF " , $A0385304D4B = "HideWindowOnStartup=0" , $A1885401224 = " @CRLF " , $A468550471C = "HideWhenMinimized=1" , $A0B85606362 = " @CRLF " , $A1E85705016 = "TrayIconPack=1" , $A5F85802857 = " @CRLF " , $A3585906228 = "WinSetOnTop=1" , $A0385A03446 = " @CRLF " , $A1585B03914 = "SystemUser=1" , $A5E85C02D5C = " @CRLF " , $A5485D0471E = "TaskOptions=0" , $A1885E01F59 = " @CRLF " , $A2785F05831 = "UsedMemory=75%" , $A5195005B2C = " @CRLF " , $A089510351D = "CountDown=15" , $A6295203947 = " @CRLF " , $A4C95303E35 = "ExclusionOpt=1" , $A3E95400F3C = " @CRLF " , $A339550521B = "Exclusions=|Explorer.exe|" , $A2695604358 = " @CRLF " , $A0A95705E22 = "Processes=|" , $A0495803249 = " @CRLF " , $A2B95901F5D = " @CRLF " , _
		$A2695A00A0D = "[Language_English]" , $A4A95B03921 = " @CRLF " , $A5C95C02805 = "Translator=BlueLife" , $A0795D0453A = " @CRLF " , $A3F95E06151 = "=""" , $A3695F0331C = """" , $A08A500042C = " @CRLF "
		Global $SSA3A60006249 = 1
	EndIf
	If FileExists ( $A4C75C03C18 ) = 1 Then
		FileSetAttrib ( $A4C75C03C18 , $A4775D02141 )
		Return 1
	EndIf
	Local $A3D75E0022C = A2050F03125 ( ) & $A1D75F0004D & Execute ( $A3A85005950 ) & $A4D85103D0E & Execute ( $A4A85200853 ) & $A0385304D4B & Execute ( $A1885401224 ) & $A468550471C & Execute ( $A0B85606362 ) & $A1E85705016 & Execute ( $A5F85802857 ) & $A3585906228 & Execute ( $A0385A03446 ) & $A1585B03914 & Execute ( $A5E85C02D5C ) & $A5485D0471E & Execute ( $A1885E01F59 ) & $A2785F05831 & Execute ( $A5195005B2C ) & $A089510351D & Execute ( $A6295203947 ) & $A4C95303E35 & Execute ( $A3E95400F3C ) & $A339550521B & Execute ( $A2695604358 ) & $A0A95705E22 & Execute ( $A0495803249 ) & Execute ( $A2B95901F5D ) & $A2695A00A0D & Execute ( $A4A95B03921 ) & $A5C95C02805 & Execute ( $A0795D0453A )
	For $A17A0803B53 = 1 To $A39D0E0415B [ 0 ]
		$A3D75E0022C &= A5560100561 ( $A17A0803B53 ) & $A3F95E06151 & $A39D0E0415B [ $A17A0803B53 ] & $A3695F0331C & Execute ( $A08A500042C )
	Next
	Local $A0EA510425B = FileOpen ( $A4C75C03C18 , 2 + 32 )
	If $A0EA510425B = - 1 Then
		FileClose ( $A0EA510425B )
		Return SetError ( 1 , 0 , 0 )
	EndIf
	If FileWrite ( $A0EA510425B , $A3D75E0022C ) = 0 Then
		FileClose ( $A0EA510425B )
		Return SetError ( 2 , 0 , 0 )
	EndIf
	FileClose ( $A0EA510425B )
	If FileExists ( $A4C75C03C18 ) = 1 Then Return 1
	Return SetError ( 3 , 0 , 0 )
EndFunc
Func A5560100561 ( $A0BA520070A )
	Local $A51A5302647 = StringLen ( $A39D0E0415B [ 0 ] )
	Return StringRight ( Chr ( 48 ) & Chr ( 48 ) & $A0BA520070A , $A51A5302647 )
EndFunc
Func A1160200452 ( $A0AA5401B21 , $A1D35603120 , $A44A550352E , $A3A33105B5C )
	If Not IsDeclared ( "SSA1160200452" ) Then
		Global $A33A5702756 = " @LF "
		Global $SSA1160200452 = 1
	EndIf
	Local $A51A5603E03 = Execute ( $A33A5702756 )
	Local $A11A580153C = IniRead ( $A0AA5401B21 , $A1D35603120 , $A44A550352E , $A51A5603E03 )
	If $A11A580153C = $A51A5603E03 Then
		$A11A580153C = $A3A33105B5C
		IniWrite ( $A0AA5401B21 , $A1D35603120 , $A44A550352E , $A11A580153C )
	EndIf
	Return $A11A580153C
EndFunc
Func A5560304940 ( $A10A590624F , $A08A5A04D06 , $A5FA5B02653 = - 1 , $A27A5C01042 = - 1 )
	If Not IsDeclared ( "SSA5560304940" ) Then
		Global $A17A5E05F07 = "Main"
		Global $SSA5560304940 = 1
	EndIf
	Local $A5EA5D00B18 = Number ( A1160200452 ( $A45D0C00410 , $A17A5E05F07 , $A10A590624F , $A08A5A04D06 ) )
	If ( $A5FA5B02653 <> - 1 And $A5EA5D00B18 < $A5FA5B02653 ) Or ( $A27A5C01042 <> - 1 And $A5EA5D00B18 > $A27A5C01042 ) Then $A5EA5D00B18 = $A08A5A04D06
	Return $A5EA5D00B18
EndFunc
Func A3560501B29 ( $A10A590624F , $A08A5A04D06 )
	If Not IsDeclared ( "SSA3560501B29" ) Then
		Global $A36B5004616 = "Main"
		Global $SSA3560501B29 = 1
	EndIf
	Return A1160200452 ( $A45D0C00410 , $A36B5004616 , $A10A590624F , $A08A5A04D06 )
EndFunc
Func A2C60706156 ( )
	If Not IsDeclared ( "SSA2C60706156" ) Then
		Global $A06B5302513 = " @KBLayout " , $A5CB5400135 = "07" , $A37B5504649 = "German" , $A31B5605317 = "09" , $A0DB5702A19 = "English" , $A09B580174A = "0A" , $A37B5900448 = "Spanish" , $A5CB5A05225 = "0C" , $A46B5B0354E = "French" , $A24B5C0610B = "10" , $A3DB5D05255 = "Italian" , $A3FB5E02E48 = "1F" , $A1EB5F05348 = "Turkish" , $A51C500610D = "2A" , $A26C5103939 = "Vietnamese" , $A1AC5204835 = "19" , $A5DC5302B5F = "Russian" , $A40C540283A = "12" , $A1DC5505630 = "Korean" , $A57C5604230 = "11" , $A0BC570122B = "Japanese" , $A10C5801F04 = "04" , $A11C590593D = "Chinese" , $A1BC5A0582E = "01" , $A08C5B0631B = "Arabic" , $A46C5C00061 = "29" , $A49C5D03527 = "Persian" , $A57C5E00F55 = "16" , $A25C5F00E45 = "Portuguese" , $A2AD500611A = "0B" , $A21D510005F = "Finnish" , $A33D5201960 = "14" , $A49D530015C = "Norwegian" , $A5BD5400E5F = "15" , $A24D5500438 = "Polish" , _
		$A20D5601341 = "13" , $A3ED5700F27 = "Dutch" , $A21D5804400 = "1D" , $A39D5904854 = "Swedish" , $A04D5A04F46 = "36" , $A42D5B03824 = "Afrikaans" , $A11D5C03A02 = "1C" , $A2CD5D04F09 = "Albanian" , $A47D5E05636 = "84" , $A0AD5F01D45 = "Alsatian" , $A1CE5005439 = "5E" , $A11E5103407 = "Amharic" , $A56E5204030 = "2B" , $A2FE5305E31 = "Armenian" , $A42E5401E19 = "4D" , $A09E5503858 = "Assamese" , $A17E5605F3A = "2C" , $A14E5700020 = "Azerbaijani"
		Global $A01E5802532 = "6D" , $A5AE5901906 = "Bashkir" , $A63E5A01F4E = "2D" , $A37E5B06115 = "Basque" , $A4AE5C00842 = "23" , $A44E5D03606 = "Belarusian" , $A1BE5E00956 = "45" , $A4DE5F0011E = "Bengali" , $A13F500204B = "1A" , $A41F5103E0E = "081A" , $A5EF5204D1C = "0C1A" , $A4AF5305221 = "241A" , $A16F5400712 = "281A" , $A2DF5505420 = "2C1A" , $A07F560255F = "301A" , $A43F5703022 = "181A" , $A35F5803851 = "1C1A" , $A5BF5902062 = "Serbian" , $A30F5A04724 = "141A" , $A60F5B04C25 = "201A" , $A1AF5C00C3D = "Bosnian" , $A3DF5D02110 = "041A" , $A01F5E03C05 = "101A" , $A57F5F01702 = "Croatian" , $A5606005B3B = "7E" , $A5906102C03 = "Breton" , $A2906203E2B = "02" , $A3E06304746 = "Bulgarian" , $A0F06405B55 = "03" , $A5106501505 = "0403" , $A3F0660275A = "Catalan" , $A200670415B = "0803" , $A0A06800F3B = "Valencian" , $A1206902F31 = "5C" , $A4D06A03F43 = "Cherokee" , _
		$A1B06B03425 = "83" , $A3606C00F51 = "Corsican" , $A3406D0361A = "05" , $A0406E04909 = "Czech" , $A1C06F04D1E = "06" , $A5016005861 = "Danish" , $A0116102838 = "8C" , $A2616203939 = "Dari" , $A1716301A51 = "65" , $A4916403547 = "Divehi" , $A0416503456 = "25" , $A351660520E = "Estonian" , $A5F16704627 = "38" , $A4116802B1A = "Faroese" , $A1B16900561 = "64" , $A5F16A04C2F = "Filipino" , $A4516B03C2E = "62" , $A5816C05C4E = "Frisian"
		Global $A1316D04B1C = "67" , $A5616E0494B = "Fulah" , $A4A16F06028 = "2F" , $A4D26003A5E = "Macedonian" , $A5D26103F16 = "56" , $A5826200646 = "Galician" , $A3C2630061A = "37" , $A5A2640384A = "Georgian" , $A5326500410 = "08" , $A4A26602E58 = "Greek" , $A4C26701222 = "6F" , $A3026802D4D = "Greenlandic" , $A2826902C3A = "74" , $A3026A00452 = "Guarani" , $A1326B03357 = "47" , $A5926C04C44 = "Gujarati" , $A1026D01546 = "68" , $A1126E06108 = "Hausa" , $A4426F04F3B = "75" , $A5036001E29 = "Hawaiian" , $A6136105D03 = "0D" , $A2E36205509 = "Hebrew" , $A1D36300741 = "39" , $A033640011E = "Hindi" , $A003650394E = "0E" , $A1E3660580F = "Hungarian" , $A023670614A = "0F" , $A3536801E19 = "Icelandic" , $A1936904A54 = "70" , $A4636A0282E = "Igbo" , $A4136B01524 = "21" , $A5436C02C28 = "Indonesian" , $A2336D0032C = "5D" , $A1C36E00228 = "Inuktitut" , $A0036F03F2C = "3C" , _
		$A4746004263 = "Irish" , $A6246104620 = "86" , $A2246200631 = "K'iche" , $A1146306263 = "4B" , $A5346403027 = "Kannada" , $A5846504441 = "3F" , $A5A46605D58 = "Kazakh" , $A2C4670184B = "53" , $A2A46805C13 = "Khmer" , $A1D4690512D = "87" , $A2346A01B2D = "Kinyarwanda" , $A4346B0272D = "57" , $A2146C00144 = "Konkani" , $A0946D0532E = "40" , $A3846E03E32 = "Kyrgyz" , $A4646F04D3D = "54" , $A2A56003B52 = "Lao" , $A225610481E = "26"
		Global $A5856203A23 = "Latvian" , $A2456303D1D = "27" , $A4756405B39 = "Lithuanian" , $A0056501D02 = "6E" , $A5756601255 = "Luxembourgish" , $A0256704A5A = "3E" , $A1A56801141 = "Malay" , $A1056904D02 = "4C" , $A2656A02622 = "Malayalam" , $A4356B02561 = "3A" , $A0156C0135F = "Maltese" , $A1356D03D21 = "81" , $A5756E02326 = "Maori" , $A4856F0460A = "4E" , $A0766002F52 = "Marathi" , $A2266100E45 = "7C" , $A5F66200634 = "Mohawk" , $A2C66302D4A = "50" , $A5F66401F13 = "Mongolian" , $A5A66503D25 = "61" , $A0D6660470F = "Nepali" , $A5E66705D2D = "82" , $A2B6680082F = "Occitan" , $A2F66900811 = "48" , $A4366A0482B = "Oriya" , $A4266B0450D = "72" , $A2E66C02E40 = "Oromo" , $A1B66D04D61 = "63" , $A1C66E04150 = "Pashto" , $A1E66F04B28 = "46" , $A5176001541 = "Punjabi" , $A2476101356 = "6B" , $A247620282D = "Quecha" , $A5476304141 = "17" , $A5E76401153 = "Romansh" , _
		$A4C76501F39 = "18" , $A3276601D3D = "Romanian" , $A4876704737 = "3B" , $A527680404F = "Sami" , $A2D76902926 = "4F" , $A5A76A00731 = "Sanskrit" , $A3076B02D3C = "6C" , $A3C76C00611 = "Sesotho sa Leboa" , $A4776D02D18 = "59" , $A3A76E03541 = "Sindhi" , $A0C76F03859 = "5B" , $A6086001846 = "Sinhalese" , $A3D86105B5E = "1B" , $A3C8620060A = "Slovak" , $A4B86306221 = "24" , $A1686406206 = "Slovenian" , $A3686502729 = "77" , $A1B8660015A = "Somali"
		Global $A0586703C4D = "2E" , $A3986803C2E = "Sorbian" , $A1586902018 = "30" , $A2186A02804 = "Southern Sotho" , $A3986B02125 = "41" , $A1186C02443 = "Swahili" , $A1E86D04910 = "5A" , $A0B86E02A55 = "Syriac" , $A5386F04302 = "28" , $A0796000205 = "Tajik" , $A5A9610494B = "5F" , $A1E96205303 = "Tamazight" , $A3996303A1F = "49" , $A0396403546 = "Tamil" , $A449650221D = "44" , $A0796604F36 = "Tatar" , $A1B96700341 = "4A" , $A1096803C58 = "Telugu" , $A3196902B5E = "1E" , $A0696A01E4F = "Thai" , $A2F96B0353D = "51" , $A1196C01A40 = "Tibetan" , $A1596D02F45 = "73" , $A6296E02324 = "Tigrigna" , $A4996F02C02 = "31" , $A5DA600300D = "Tsonga" , $A08A6101D3B = "32" , $A44A620375C = "Tswana" , $A0FA6302F08 = "42" , $A0EA6402B1F = "Turkmen" , $A1EA6506328 = "80" , $A55A660381E = "Uighur" , $A4BA670004B = "22" , $A49A6803018 = "Ukrainian" , $A5CA6903740 = "20" , _
		$A40A6A03D60 = "Urdu" , $A40A6B04022 = "43" , $A60A6C0265F = "Uzbek" , $A5CA6D0251A = "52" , $A29A6E00D31 = "Welsh" , $A1CA6F00716 = "88" , $A15B6004D50 = "Wolof" , $A22B610200B = "34" , $A4BB620571F = "Xhosa" , $A38B6301733 = "85" , $A4BB6401661 = "Sakha" , $A18B6501435 = "78" , $A2BB6600D05 = "Yi" , $A1BB6700903 = "6A" , $A13B6805F5D = "Yoruba" , $A41B6904907 = "35" , $A50B6A03C53 = "Zulu" , $A45B6B04152 = "7A"
		Global $A0DB6C03C1B = "Mapudungun" , $A38B6D03B54 = "91" , $A2AB6E00832 = "Scottish Gaelic" , $A45B6F01439 = "92" , $A5FC6004352 = "Kurdish" , $A04C6106016 = "English"
		Global $SSA2C60706156 = 1
	EndIf
	Local $A02B5200C0F = Execute ( $A06B5302513 )
	Switch StringRight ( $A02B5200C0F , 2 )
	Case $A5CB5400135
		Return $A37B5504649
	Case $A31B5605317
		Return $A0DB5702A19
	Case $A09B580174A
		Return $A37B5900448
	Case $A5CB5A05225
		Return $A46B5B0354E
	Case $A24B5C0610B
		Return $A3DB5D05255
	Case $A3FB5E02E48
		Return $A1EB5F05348
	Case $A51C500610D
		Return $A26C5103939
	Case $A1AC5204835
		Return $A5DC5302B5F
	Case $A40C540283A
		Return $A1DC5505630
	Case $A57C5604230
		Return $A0BC570122B
	Case $A10C5801F04
		Return $A11C590593D
	Case $A1BC5A0582E
		Return $A08C5B0631B
	Case $A46C5C00061
		Return $A49C5D03527
	Case $A57C5E00F55
		Return $A25C5F00E45
	Case $A2AD500611A
		Return $A21D510005F
	Case $A33D5201960
		Return $A49D530015C
	Case $A5BD5400E5F
		Return $A24D5500438
	Case $A20D5601341
		Return $A3ED5700F27
	Case $A21D5804400
		Return $A39D5904854
	Case $A04D5A04F46
		Return $A42D5B03824
	Case $A11D5C03A02
		Return $A2CD5D04F09
	Case $A47D5E05636
		Return $A0AD5F01D45
	Case $A1CE5005439
		Return $A11E5103407
	Case $A56E5204030
		Return $A2FE5305E31
	Case $A42E5401E19
		Return $A09E5503858
	Case $A17E5605F3A
		Return $A14E5700020
	Case $A01E5802532
		Return $A5AE5901906
	Case $A63E5A01F4E
		Return $A37E5B06115
	Case $A4AE5C00842
		Return $A44E5D03606
	Case $A1BE5E00956
		Return $A4DE5F0011E
	Case $A13F500204B
		Switch $A02B5200C0F
		Case $A41F5103E0E , $A5EF5204D1C , $A4AF5305221 , $A16F5400712 , $A2DF5505420 , $A07F560255F , $A43F5703022 , $A35F5803851
			Return $A5BF5902062
		Case $A30F5A04724 , $A60F5B04C25
			Return $A1AF5C00C3D
		Case $A3DF5D02110 , $A01F5E03C05
			Return $A57F5F01702
		EndSwitch
	Case $A5606005B3B
		Return $A5906102C03
	Case $A2906203E2B
		Return $A3E06304746
	Case $A0F06405B55
		Switch $A02B5200C0F
		Case $A5106501505
			Return $A3F0660275A
		Case $A200670415B
			Return $A0A06800F3B
		EndSwitch
	Case $A1206902F31
		Return $A4D06A03F43
	Case $A1B06B03425
		Return $A3606C00F51
	Case $A3406D0361A
		Return $A0406E04909
	Case $A1C06F04D1E
		Return $A5016005861
	Case $A0116102838
		Return $A2616203939
	Case $A1716301A51
		Return $A4916403547
	Case $A0416503456
		Return $A351660520E
	Case $A5F16704627
		Return $A4116802B1A
	Case $A1B16900561
		Return $A5F16A04C2F
	Case $A4516B03C2E
		Return $A5816C05C4E
	Case $A1316D04B1C
		Return $A5616E0494B
	Case $A4A16F06028
		Return $A4D26003A5E
	Case $A5D26103F16
		Return $A5826200646
	Case $A3C2630061A
		Return $A5A2640384A
	Case $A5326500410
		Return $A4A26602E58
	Case $A4C26701222
		Return $A3026802D4D
	Case $A2826902C3A
		Return $A3026A00452
	Case $A1326B03357
		Return $A5926C04C44
	Case $A1026D01546
		Return $A1126E06108
	Case $A4426F04F3B
		Return $A5036001E29
	Case $A6136105D03
		Return $A2E36205509
	Case $A1D36300741
		Return $A033640011E
	Case $A003650394E
		Return $A1E3660580F
	Case $A023670614A
		Return $A3536801E19
	Case $A1936904A54
		Return $A4636A0282E
	Case $A4136B01524
		Return $A5436C02C28
	Case $A2336D0032C
		Return $A1C36E00228
	Case $A0036F03F2C
		Return $A4746004263
	Case $A6246104620
		Return $A2246200631
	Case $A1146306263
		Return $A5346403027
	Case $A5846504441
		Return $A5A46605D58
	Case $A2C4670184B
		Return $A2A46805C13
	Case $A1D4690512D
		Return $A2346A01B2D
	Case $A4346B0272D
		Return $A2146C00144
	Case $A0946D0532E
		Return $A3846E03E32
	Case $A4646F04D3D
		Return $A2A56003B52
	Case $A225610481E
		Return $A5856203A23
	Case $A2456303D1D
		Return $A4756405B39
	Case $A0056501D02
		Return $A5756601255
	Case $A0256704A5A
		Return $A1A56801141
	Case $A1056904D02
		Return $A2656A02622
	Case $A4356B02561
		Return $A0156C0135F
	Case $A1356D03D21
		Return $A5756E02326
	Case $A4856F0460A
		Return $A0766002F52
	Case $A2266100E45
		Return $A5F66200634
	Case $A2C66302D4A
		Return $A5F66401F13
	Case $A5A66503D25
		Return $A0D6660470F
	Case $A5E66705D2D
		Return $A2B6680082F
	Case $A2F66900811
		Return $A4366A0482B
	Case $A4266B0450D
		Return $A2E66C02E40
	Case $A1B66D04D61
		Return $A1C66E04150
	Case $A1E66F04B28
		Return $A5176001541
	Case $A2476101356
		Return $A247620282D
	Case $A5476304141
		Return $A5E76401153
	Case $A4C76501F39
		Return $A3276601D3D
	Case $A4876704737
		Return $A527680404F
	Case $A2D76902926
		Return $A5A76A00731
	Case $A3076B02D3C
		Return $A3C76C00611
	Case $A4776D02D18
		Return $A3A76E03541
	Case $A0C76F03859
		Return $A6086001846
	Case $A3D86105B5E
		Return $A3C8620060A
	Case $A4B86306221
		Return $A1686406206
	Case $A3686502729
		Return $A1B8660015A
	Case $A0586703C4D
		Return $A3986803C2E
	Case $A1586902018
		Return $A2186A02804
	Case $A3986B02125
		Return $A1186C02443
	Case $A1E86D04910
		Return $A0B86E02A55
	Case $A5386F04302
		Return $A0796000205
	Case $A5A9610494B
		Return $A1E96205303
	Case $A3996303A1F
		Return $A0396403546
	Case $A449650221D
		Return $A0796604F36
	Case $A1B96700341
		Return $A1096803C58
	Case $A3196902B5E
		Return $A0696A01E4F
	Case $A2F96B0353D
		Return $A1196C01A40
	Case $A1596D02F45
		Return $A6296E02324
	Case $A4996F02C02
		Return $A5DA600300D
	Case $A08A6101D3B
		Return $A44A620375C
	Case $A0FA6302F08
		Return $A0EA6402B1F
	Case $A1EA6506328
		Return $A55A660381E
	Case $A4BA670004B
		Return $A49A6803018
	Case $A5CA6903740
		Return $A40A6A03D60
	Case $A40A6B04022
		Return $A60A6C0265F
	Case $A5CA6D0251A
		Return $A29A6E00D31
	Case $A1CA6F00716
		Return $A15B6004D50
	Case $A22B610200B
		Return $A4BB620571F
	Case $A38B6301733
		Return $A4BB6401661
	Case $A18B6501435
		Return $A2BB6600D05
	Case $A1BB6700903
		Return $A13B6805F5D
	Case $A41B6904907
		Return $A50B6A03C53
	Case $A45B6B04152
		Return $A0DB6C03C1B
	Case $A38B6D03B54
		Return $A2AB6E00832
	Case $A45B6F01439
		Return $A5FC6004352
Case Else
		Return $A04C6106016
	EndSwitch
EndFunc
Func A5660800244 ( $A3CF1602433 = $A59A0605008 )
	If Not IsDeclared ( "SSA5660800244" ) Then
		Global $A37C6201C2A = " @SW_DISABLE " , $A28C6401038 = "Afrikaans|Albanian|Alsatian|Amharic|Arabic|Armenian|Assamese|Azerbaijani|Bashkir|Basque|Belarusian|Bengali|Bosnian|Breton|Bulgarian|Catalan|Cebuano|Cherokee|Chinese|Corsican|Creole|Croatian|Czech|" , $A2EC650015F = "Danish|Dari|Divehi|Dutch|English|Esperanto|Estonian|Faroese|Filipino|Finnish|French|Frisian|Fulah|Galician|Georgian|German|Greek|Greenlandic|Guarani|Gujarati|Haitian|Hausa|Hawaiian|Hebrew|Hindi|Hmong|Hungarian|" , $A51C6606019 = "Ibibio|Icelandic|Igbo|Indonesian|Inuktitut|Irish|Italian|Japanese|Javanese|Kannada|Kanuri|Kashmiri|Kazakh|Khmer|K'iche|Kinyarwanda|Konkani|Korean|Kurdish|Kyrgyz|Lao|Latin|Latvian|Lithuanian|Luxembourgish|" , $A35C6703840 = "Macedonian|Malay|Malayalam|Maltese|Manipuri|Maori|Mapudungun|Marathi|Mohawk|Mongolian|Nepali|Norwegian|Occitan|Oriya|Oromo|Papiamentu|Pashto|Persian|Polish|Portuguese|Punjabi|Quecha|Romanian|Romansh|Russian|" , _
		$A44C6804426 = "Sakha|Sami|Sanskrit|Scottish Gaelic|Serbian|Sesotho sa Leboa|Sindhi|Sinhalese|Slovak|Slovenian|Somali|Sorbian|Southern Sotho|Spanish|Swahili|Swedish|Syriac|Tajik|Tamazight|Tamil|Tatar|Telugu|Thai|Tibetan|" , $A33C6903121 = "Tigrigna|Tsonga|Tswana|Turkish|Turkmen|Uighur|Ukrainian|Urdu|Uzbek|Valencian|Venda|Vietnamese|Welsh|Wolof|Xhosa|Yi|Yiddish|Yoruba|Zulu" , $A27C6A00B44 = "GUIOnEventMode" , $A49C6C02423 = "GUIDataSeparatorChar" , $A34C6D05146 = "GUICloseOnESC" , $A56C6F0535B = "Translate" , $A0CD600144A = "Select Your Language" , $A0BD6205A50 = "WindowText" , $A02D6301557 = "Write Your Language" , $A08D6501F17 = "WindowText" , $A04D6705A06 = "Auto" , $A29D6901027 = "Save Language" , $A39D6B0211D = "Copy to Clipboard" , $A3DD6D01C13 = "Send Translated Data" , $A60D6E05351 = "ID|Current English Language String|Your Language String" , _
		$A29E6100555 = "English" , $A0FE6305124 = " @LF " , $A21E6403E55 = " @LF " , $A32E650440D = " @CRLF " , $A10E6602849 = "\n" , $A34E680094A = "Language_English" , $A1DE6A0093F = " @LF " , $A15E6B04121 = " @LF " , $A52E6C02F59 = " @LF " , $A28E6D00F23 = "Language_" , $A39E6E01702 = "WindowText" , $A09E6F06112 = "To go to another line , you can use up/down Keyboard keys." , $A44F600404D = "Window" , $A2AF630542A = "{UP}" , $A55F6404B39 = "{DOWN}" , $A57F6500E44 = " @SW_SHOW " , $A56F6D01D18 = "psapi.dll" , $A3BF6E04823 = "int" , $A5FF6F01A58 = "EmptyWorkingSet" , $A0407004106 = "long" , $A5907104C36 = "{UP}" , $A2307204107 = "{DOWN}" , $A3C07300B54 = "Warning" , $A4A07404F1C = "Please select your language name from box!" , $A5907506054 = "Warning" , $A300760214B = "Please write your language name to box!" , $A2C0770092A = "=""" , $A2207804841 = """" , _
		$A3D07902B2D = " @LF " , $A4B07A00A21 = "Language_" , $A1807B04F2B = " @CRLF " , $A0207C0494D = "GUIDataSeparatorChar" , $A1B07D05A0F = "GUIDataSeparatorChar"
		Global $A2A07E04C2B = "user32.dll" , $A5707F02163 = "int" , $A1717005557 = "MessageBeep" , $A0C17102109 = "int" , $A5317203F5F = "Error" , $A0B17303339 = " @LF " , $A4E17401121 = "Could not write to the configuration file!" , $A101750064E = "Warning" , $A5117602636 = "Please select your language name from box!" , $A3017700E38 = "Warning" , $A5B17805A56 = "Please write your language name to box!" , $A1417902E00 = ";" , $A0117A04A30 = " @CRLF " , $A2D17B02736 = " @CRLF " , $A0917C03A44 = "[Language_" , $A0917D03A00 = "]" , $A2317E02247 = " @CRLF " , $A2817F00458 = "=""" , $A0027001B1A = """" , $A5127102B3C = " @CRLF " , $A2227201557 = "user32.dll" , $A5127301A3C = "int" , $A5B27403223 = "MessageBeep" , $A3527501648 = "int" , $A5127604860 = "Do you want to update the list according to the " , $A2827702618 = " translation?" , $A452780131E = "Auto" , _
		$A4B27900558 = "Language_" , $A2027A01C04 = " @CRLF " , $A4027B02910 = "\n" , $A5127C01553 = " @CRLF " , $A0127D03A4F = "\n" , $A2127E01E38 = "\n" , $A2027F0470A = " @SW_RESTORE " , $A2C37003914 = " @SW_ENABLE " , $A2B37104657 = "GUIDataSeparatorChar" , $A1E3720065C = "GUIOnEventMode" , $A1F37305D13 = "GUICloseOnESC" , $A1137402650 = "psapi.dll" , $A5C37504A5B = "int" , $A4F37602A4D = "EmptyWorkingSet" , $A1237700230 = "long"
		Global $SSA5660800244 = 1
	EndIf
	If IsHWnd ( $A3CF1602433 ) = 1 Then
		RM_SetTrayInteractionPaused ( 1 )
		GUISetState ( Execute ( $A37C6201C2A ) , $A3CF1602433 )
		GUIRegisterMsg ( 78 , "" )
	EndIf
	Local $A01C630471F = $A28C6401038 & $A2EC650015F & $A51C6606019 & $A35C6703840 & $A44C6804426 & $A33C6903121
	Local $A01A1805D03 = Opt ( $A27C6A00B44 , 0 )
	Local $A58C6B02E23 = Opt ( $A49C6C02423 , $A5580E05E46 )
	Local $A3BA1A04626 = Opt ( $A34C6D05146 , 1 )
	Local $A27A1401932 = A1880105C32 ( $A3CF1602433 , 725 , 450 )
	Local $A15C6E0081B = GUICreate ( $A56C6F0535B , 725 , 450 , $A27A1401932 [ 0 ] , $A27A1401932 [ 1 ] , BitOR ( 262144 , 65536 , 131072 , 2156396544 , 12582912 ) , - 1 , $A3CF1602433 )
	GUICtrlCreateGroup ( "" , 5 , 0 , 315 , 55 )
	GUICtrlSetResizing ( - 1 , 2 + 32 + 512 )
	GUICtrlCreateLabel ( $A0CD600144A , 10 , 10 , 150 , 17 )
	GUICtrlSetResizing ( - 1 , 2 + 32 + 512 )
	Local $A32D6106030 = GUICtrlCreateCombo ( "" , 10 , 27 , 150 , 20 , 10485763 )
	GUICtrlSetData ( $A32D6106030 , $A01C630471F , A2C60706156 ( ) )
	GUICtrlSetResizing ( $A32D6106030 , 2 + 32 + 512 )
	GUICtrlSetColor ( $A32D6106030 , A2480301717 ( $A0BD6205A50 ) )
	GUICtrlCreateLabel ( $A02D6301557 , 165 , 10 , 150 , 17 )
	GUICtrlSetResizing ( - 1 , 8 + 32 + 512 )
	Local $A5BD6402F04 = GUICtrlCreateCombo ( "" , 165 , 27 , 150 , 20 )
	GUICtrlSetResizing ( $A5BD6402F04 , 8 + 32 + 512 )
	GUICtrlSetColor ( $A5BD6402F04 , A2480301717 ( $A08D6501F17 ) )
	Local $A08F190154A , $A24D660565A
	$A01C630471F = ""
	Local $A2805903111 = StringSplit ( $A50D0F02863 [ 0 ] , $A5580E05E46 , 1 )
	For $A17A0803B53 = 1 To $A2805903111 [ 0 ]
		If $A2805903111 [ $A17A0803B53 ] = $A04D6705A06 Then ContinueLoop
		$A08F190154A = StringInStr ( $A2805903111 [ $A17A0803B53 ] , Chr ( 95 ) )
		If $A08F190154A = 0 Then
			$A24D660565A = $A2805903111 [ $A17A0803B53 ]
		Else
			$A24D660565A = StringTrimLeft ( $A2805903111 [ $A17A0803B53 ] , $A08F190154A )
		EndIf
		If StringInStr ( $A5580E05E46 & $A01C630471F , $A5580E05E46 & $A24D660565A & $A5580E05E46 ) = 0 Then $A01C630471F &= $A24D660565A & $A5580E05E46
	Next
	GUICtrlSetData ( $A5BD6402F04 , $A01C630471F )
	GUICtrlCreateGroup ( "" , 330 , 0 , 390 , 55 )
	GUICtrlSetResizing ( - 1 , 8 + 32 + 512 )
	Local $A30D6800720 = GUICtrlCreateButton ( $A29D6901027 , 335 , 16 , 125 , 28 )
	GUICtrlSetResizing ( - 1 , 8 + 32 + 512 )
	Local $A13D6A02B56 = GUICtrlCreateButton ( $A39D6B0211D , 465 , 16 , 120 , 28 )
	GUICtrlSetResizing ( - 1 , 8 + 32 + 512 )
	Local $A10D6C02F1A = GUICtrlCreateButton ( $A3DD6D01C13 , 590 , 16 , 125 , 28 )
	GUICtrlSetResizing ( - 1 , 8 + 32 + 512 )
	$A1BE0205A29 = GUICtrlCreateListView ( $A60D6E05351 , 5 , 60 , 715 , 250 , BitOR ( 4 , 1 , 8 , 32768 ) )
	GUICtrlSendMsg ( $A1BE0205A29 , 4150 , 0 , BitOR ( 32 , 2048 , 1 , 32 ) )
	GUICtrlSetResizing ( - 1 , 102 )
	Dim $A2DE030231E [ $A39D0E0415B [ 0 ] + 1 ] [ 4 ] = [ [ $A39D0E0415B [ 0 ] ] ]
	Local $A3AD6F01747 , $A5FE6004140 = $A29E6100555 , $A55E6201B3C = Execute ( $A0FE6305124 )
	For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
		$A2DE030231E [ $A17A0803B53 ] [ 1 ] = A5560100561 ( $A17A0803B53 )
		$A2DE030231E [ $A17A0803B53 ] [ 2 ] = $A39D0E0415B [ $A17A0803B53 ]
		$A55E6201B3C &= $A2DE030231E [ $A17A0803B53 ] [ 1 ] & Execute ( $A21E6403E55 )
		If $A50D0F02863 [ 2 ] = $A5FE6004140 Then
			$A2DE030231E [ $A17A0803B53 ] [ 3 ] = ""
		Else
			$A2DE030231E [ $A17A0803B53 ] [ 3 ] = $A3AE0005046 [ $A17A0803B53 ]
			$A2DE030231E [ $A17A0803B53 ] [ 3 ] = StringReplace ( $A2DE030231E [ $A17A0803B53 ] [ 3 ] , Execute ( $A32E650440D ) , $A10E6602849 )
		EndIf
		$A3AD6F01747 = $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 2 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 3 ] & $A5580E05E46
		$A2DE030231E [ $A17A0803B53 ] [ 0 ] = GUICtrlCreateListViewItem ( $A3AD6F01747 , $A1BE0205A29 )
		GUICtrlSetImage ( $A2DE030231E [ $A17A0803B53 ] [ 0 ] , $A5BB0001B63 , - 5 )
	Next
	Local $A63E6705001 = IniReadSection ( $A45D0C00410 , $A34E680094A )
	If @error = 0 Then
		Local $A3AE690155C [ $A63E6705001 [ 0 ] [ 0 ] + 1 ] [ 2 ] = [ [ 0 ] ]
		For $A17A0803B53 = 1 To $A63E6705001 [ 0 ] [ 0 ]
			If StringInStr ( $A55E6201B3C , Execute ( $A1DE6A0093F ) & $A63E6705001 [ $A17A0803B53 ] [ 0 ] & Execute ( $A15E6B04121 ) ) = 0 Then
				$A55E6201B3C &= $A63E6705001 [ $A17A0803B53 ] [ 0 ] & Execute ( $A52E6C02F59 )
				$A3AE690155C [ 0 ] [ 0 ] += 1
				$A3AE690155C [ $A3AE690155C [ 0 ] [ 0 ] ] [ 0 ] = $A63E6705001 [ $A17A0803B53 ] [ 0 ]
				$A3AE690155C [ $A3AE690155C [ 0 ] [ 0 ] ] [ 1 ] = StringReplace ( $A63E6705001 [ $A17A0803B53 ] [ 1 ] , Chr ( 34 ) , $A0B9010005E )
			EndIf
		Next
		$A2DE030231E [ 0 ] [ 0 ] += $A3AE690155C [ 0 ] [ 0 ]
		ReDim $A2DE030231E [ $A2DE030231E [ 0 ] [ 0 ] + 1 ] [ 4 ]
		Local $A4C2550292E
		For $A17A0803B53 = ( $A39D0E0415B [ 0 ] + 1 ) To $A2DE030231E [ 0 ] [ 0 ]
			$A4C2550292E = ( $A17A0803B53 - $A39D0E0415B [ 0 ] )
			$A2DE030231E [ $A17A0803B53 ] [ 1 ] = $A3AE690155C [ $A4C2550292E ] [ 0 ]
			$A2DE030231E [ $A17A0803B53 ] [ 2 ] = $A3AE690155C [ $A4C2550292E ] [ 1 ]
			If $A50D0F02863 [ 2 ] = $A5FE6004140 Then
				$A2DE030231E [ $A17A0803B53 ] [ 3 ] = ""
			Else
				$A2DE030231E [ $A17A0803B53 ] [ 3 ] = IniRead ( $A45D0C00410 , $A28E6D00F23 & $A50D0F02863 [ 2 ] , $A2DE030231E [ $A17A0803B53 ] [ 1 ] , "" )
			EndIf
			$A3AD6F01747 = $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 2 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 3 ] & $A5580E05E46
			$A2DE030231E [ $A17A0803B53 ] [ 0 ] = GUICtrlCreateListViewItem ( $A3AD6F01747 , $A1BE0205A29 )
			GUICtrlSetImage ( $A2DE030231E [ $A17A0803B53 ] [ 0 ] , $A5BB0001B63 , - 5 )
		Next
	EndIf
	GUICtrlSendMsg ( $A1BE0205A29 , 4126 , 0 , 80 )
	GUICtrlSendMsg ( $A1BE0205A29 , 4126 , 1 , 290 )
	GUICtrlSendMsg ( $A1BE0205A29 , 4126 , 2 , 290 )
	Local $A41A1E02D59 = A2480301717 ( $A39E6E01702 )
	GUICtrlCreateLabel ( $A09E6F06112 , 5 , 323 , 715 , 17 )
	GUICtrlSetResizing ( - 1 , 576 )
	$A2DE030231E [ 0 ] [ 1 ] = GUICtrlCreateEdit ( "" , 5 , 340 , 355 , 100 , BitOR ( 2048 , 3150016 ) )
	GUICtrlSetResizing ( - 1 , 576 )
	GUICtrlSetBkColor ( - 1 , A2480301717 ( $A44F600404D ) )
	GUICtrlSetColor ( - 1 , $A41A1E02D59 )
	$A2DE030231E [ 0 ] [ 2 ] = GUICtrlCreateEdit ( "" , 365 , 340 , 355 , 100 )
	GUICtrlSetResizing ( - 1 , 576 )
	GUICtrlSetColor ( - 1 , $A41A1E02D59 )
	Local $A14F610633C [ 3 ] = [ GUICtrlGetHandle ( $A1BE0205A29 ) , GUICtrlGetHandle ( $A2DE030231E [ 0 ] [ 1 ] ) , GUICtrlGetHandle ( $A2DE030231E [ 0 ] [ 2 ] ) ]
	Local $A37F620173D [ 2 ] [ 2 ] = [ [ $A2AF630542A , GUICtrlCreateDummy ( ) ] , [ $A55F6404B39 , GUICtrlCreateDummy ( ) ] ]
	GUISetAccelerators ( $A37F620173D , $A15C6E0081B )
	GUIRegisterMsg ( 78 , "A2C60904A01" )
	GUICtrlSetState ( $A2DE030231E [ 1 ] [ 0 ] , 256 )
	GUICtrlSetState ( $A32D6106030 , 256 )
	GUISetState ( Execute ( $A57F6500E44 ) , $A15C6E0081B )
	Sleep ( 50 )
	GUICtrlSendMsg ( $A32D6106030 , 335 , True , 0 )
	Local $A0FD1304F39 , $A17F6603637 , $A2CF6702636 , $A01F6804F2B , $A07F6900D4B , $A39F6A0393D , $A63F6B05D11 , $A4EF6C01263
	DllCall ( $A56F6D01D18 , $A3BF6E04823 , $A5FF6F01A58 , $A0407004106 , - 1 )
	While 1
		$A0FD1304F39 = GUIGetMsg ( )
		Switch $A0FD1304F39
		Case 0 , - 11
		Case - 3
			ExitLoop
		Case $A37F620173D [ 0 ] [ 1 ]
			$A4EF6C01263 = A1D60A05512 ( )
			If $A4EF6C01263 = $A14F610633C [ 0 ] Or $A4EF6C01263 = $A14F610633C [ 1 ] Or $A4EF6C01263 = $A14F610633C [ 2 ] Then
				$A17F6603637 = GUICtrlRead ( $A1BE0205A29 )
				If $A17F6603637 = 0 Then
					$A01F6804F2B = 1
				Else
					For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
						If $A17F6603637 = $A2DE030231E [ $A17A0803B53 ] [ 0 ] Then
							If $A17A0803B53 = 1 Then
								$A01F6804F2B = $A2DE030231E [ 0 ] [ 0 ]
							Else
								$A01F6804F2B = $A17A0803B53 - 1
							EndIf
							ExitLoop
						EndIf
					Next
				EndIf
				GUICtrlSetState ( $A2DE030231E [ $A01F6804F2B ] [ 0 ] , 256 )
				GUICtrlSendMsg ( $A1BE0205A29 , 4115 , $A01F6804F2B - 1 , False )
				GUICtrlSetState ( $A2DE030231E [ 0 ] [ 2 ] , 256 )
			Else
				GUISetAccelerators ( "" , $A15C6E0081B )
				ControlSend ( $A15C6E0081B , "" , $A15C6E0081B , $A5907104C36 )
				GUISetAccelerators ( $A37F620173D , $A15C6E0081B )
			EndIf
		Case $A37F620173D [ 1 ] [ 1 ]
			$A4EF6C01263 = A1D60A05512 ( )
			If $A4EF6C01263 = $A14F610633C [ 0 ] Or $A4EF6C01263 = $A14F610633C [ 1 ] Or $A4EF6C01263 = $A14F610633C [ 2 ] Then
				$A17F6603637 = GUICtrlRead ( $A1BE0205A29 )
				If $A17F6603637 = 0 Then
					$A01F6804F2B = 1
				Else
					For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
						If $A17F6603637 = $A2DE030231E [ $A17A0803B53 ] [ 0 ] Then
							If $A17A0803B53 = $A2DE030231E [ 0 ] [ 0 ] Then
								$A01F6804F2B = 1
							Else
								$A01F6804F2B = $A17A0803B53 + 1
							EndIf
							ExitLoop
						EndIf
					Next
				EndIf
				GUICtrlSetState ( $A2DE030231E [ $A01F6804F2B ] [ 0 ] , 256 )
				GUICtrlSendMsg ( $A1BE0205A29 , 4115 , $A01F6804F2B - 1 , False )
				GUICtrlSetState ( $A2DE030231E [ 0 ] [ 2 ] , 256 )
			Else
				GUISetAccelerators ( "" , $A15C6E0081B )
				ControlSend ( $A15C6E0081B , "" , $A15C6E0081B , $A2307204107 )
				GUISetAccelerators ( $A37F620173D , $A15C6E0081B )
			EndIf
		Case $A30D6800720
			$A17F6603637 = StringStripWS ( GUICtrlRead ( $A32D6106030 ) , 3 )
			If StringLen ( $A17F6603637 ) = 0 Then
				MsgBox ( 48 , $A3C07300B54 , $A4A07404F1C , 0 , $A15C6E0081B )
				GUICtrlSetState ( $A32D6106030 , 256 )
				GUICtrlSendMsg ( $A32D6106030 , 335 , True , 0 )
				ContinueLoop
			EndIf
			$A63F6B05D11 = StringStripWS ( GUICtrlRead ( $A5BD6402F04 ) , 3 )
			If StringLen ( $A63F6B05D11 ) = 0 Then
				MsgBox ( 48 , $A5907506054 , $A300760214B , 0 , $A15C6E0081B )
				GUICtrlSetState ( $A5BD6402F04 , 256 )
				ContinueLoop
			EndIf
			If $A17F6603637 <> $A5FE6004140 Or $A63F6B05D11 <> $A5FE6004140 Then $A17F6603637 &= Chr ( 95 ) & $A63F6B05D11
			$A2CF6702636 = ""
			For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
				$A2CF6702636 &= $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A2C0770092A & $A2DE030231E [ $A17A0803B53 ] [ 3 ] & $A2207804841 & Execute ( $A3D07902B2D )
			Next
			If IniWriteSection ( $A45D0C00410 , $A4B07A00A21 & $A17F6603637 , $A2CF6702636 & Execute ( $A1807B04F2B ) ) = 1 Then
				If StringInStr ( $A5580E05E46 & $A01C630471F & $A5580E05E46 , $A5580E05E46 & $A63F6B05D11 & $A5580E05E46 ) = 0 Then $A01C630471F &= $A63F6B05D11 & $A5580E05E46
				GUICtrlSetData ( $A5BD6402F04 , "" )
				GUICtrlSetData ( $A5BD6402F04 , $A01C630471F , $A63F6B05D11 )
				GUIRegisterMsg ( 78 , "" )
				For $A17A0803B53 = 1 To $A60E0103904 [ 0 ] [ 1 ]
					GUICtrlDelete ( $A60E0103904 [ $A17A0803B53 ] [ 0 ] )
				Next
				$A50D0F02863 = A495010444D ( )
				$A50D0F02863 [ 1 ] = $A17F6603637
				$A3AE0005046 = A0E50304D18 ( )
				A1350504361 ( )
				Opt ( $A0207C0494D , $A58C6B02E23 )
				RM_ApplyLocalizedText ( )
				Opt ( $A1B07D05A0F , $A5580E05E46 )
				DllCall ( $A2A07E04C2B , $A5707F02163 , $A1717005557 , $A0C17102109 , 4294967295 )
				GUIRegisterMsg ( 78 , "A2C60904A01" )
			Else
				MsgBox ( 16 , $A5317203F5F , $A45D0C00410 & Execute ( $A0B17303339 ) & $A4E17401121 , 0 , $A15C6E0081B )
			EndIf
		Case $A13D6A02B56
			$A17F6603637 = StringStripWS ( GUICtrlRead ( $A32D6106030 ) , 3 )
			If StringLen ( $A17F6603637 ) = 0 Then
				MsgBox ( 48 , $A101750064E , $A5117602636 , 0 , $A15C6E0081B )
				GUICtrlSetState ( $A32D6106030 , 256 )
				GUICtrlSendMsg ( $A32D6106030 , 335 , True , 0 )
				ContinueLoop
			EndIf
			$A2CF6702636 = StringStripWS ( GUICtrlRead ( $A5BD6402F04 ) , 3 )
			If StringLen ( $A2CF6702636 ) = 0 Then
				MsgBox ( 48 , $A3017700E38 , $A5B17805A56 , 0 , $A15C6E0081B )
				GUICtrlSetState ( $A5BD6402F04 , 256 )
				ContinueLoop
			EndIf
			If $A17F6603637 <> $A5FE6004140 Or $A2CF6702636 <> $A5FE6004140 Then $A17F6603637 &= Chr ( 95 ) & $A2CF6702636
			$A17F6603637 = $A1417902E00 & $A2A90E0262F & Execute ( $A0117A04A30 ) & Execute ( $A2D17B02736 ) & $A0917C03A44 & $A17F6603637 & $A0917D03A00 & Execute ( $A2317E02247 )
			For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
				$A17F6603637 &= $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A2817F00458 & $A2DE030231E [ $A17A0803B53 ] [ 3 ] & $A0027001B1A & Execute ( $A5127102B3C )
			Next
			ClipPut ( $A17F6603637 )
			DllCall ( $A2227201557 , $A5127301A3C , $A5B27403223 , $A3527501648 , 4294967295 )
		Case $A10D6C02F1A
			A3680601F23 ( )
		Case $A5BD6402F04
			$A17F6603637 = StringStripWS ( GUICtrlRead ( $A5BD6402F04 ) , 3 )
			If MsgBox ( 292 , "" , $A5127604860 & $A17F6603637 & $A2827702618 , 0 , $A15C6E0081B ) <> 6 Then ContinueLoop
			$A63F6B05D11 = 0
			For $A17A0803B53 = 1 To $A2805903111 [ 0 ]
				If $A2805903111 [ $A17A0803B53 ] = $A452780131E Then ContinueLoop
				If StringRight ( $A2805903111 [ $A17A0803B53 ] , StringLen ( $A17F6603637 ) ) = $A17F6603637 Then
					$A63F6B05D11 = A0E50304D18 ( $A2805903111 [ $A17A0803B53 ] )
					$A17F6603637 = $A2805903111 [ $A17A0803B53 ]
					ExitLoop
				EndIf
			Next
			If IsArray ( $A63F6B05D11 ) = 0 Then Dim $A63F6B05D11 [ $A2DE030231E [ 0 ] [ 0 ] + 1 ]
			For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
				If $A17A0803B53 > $A63F6B05D11 [ 0 ] Then
					$A2DE030231E [ $A17A0803B53 ] [ 3 ] = IniRead ( $A45D0C00410 , $A4B27900558 & $A17F6603637 , $A2DE030231E [ $A17A0803B53 ] [ 1 ] , "" )
				Else
					$A2DE030231E [ $A17A0803B53 ] [ 3 ] = $A63F6B05D11 [ $A17A0803B53 ]
				EndIf
				$A2DE030231E [ $A17A0803B53 ] [ 3 ] = StringReplace ( $A2DE030231E [ $A17A0803B53 ] [ 3 ] , Execute ( $A2027A01C04 ) , $A4027B02910 )
				GUICtrlSetData ( $A2DE030231E [ $A17A0803B53 ] [ 0 ] , $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 2 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 3 ] )
			Next
			GUICtrlSetState ( $A2DE030231E [ 1 ] [ 0 ] , 8192 )
			GUICtrlSendMsg ( $A1BE0205A29 , 4115 , 0 , False )
			GUICtrlSetState ( $A2DE030231E [ 1 ] [ 0 ] , 256 )
			GUICtrlSetState ( $A2DE030231E [ 0 ] [ 2 ] , 256 )
			GUICtrlSendMsg ( $A2DE030231E [ 0 ] [ 2 ] , 177 , 0 , - 1 )
	Case Else
		EndSwitch
		$A17F6603637 = GUICtrlRead ( $A1BE0205A29 )
		If $A17F6603637 = 0 Then ContinueLoop
		If $A2DE030231E [ 0 ] [ 3 ] = 1 Then
			$A2DE030231E [ 0 ] [ 3 ] = 0
			GUICtrlSendMsg ( $A2DE030231E [ 0 ] [ 2 ] , 177 , 0 , - 1 )
		EndIf
		$A39F6A0393D = GUICtrlRead ( $A2DE030231E [ 0 ] [ 2 ] )
		If $A39F6A0393D <> $A07F6900D4B Then
			$A07F6900D4B = $A39F6A0393D
			For $A17A0803B53 = 1 To $A2DE030231E [ 0 ] [ 0 ]
				If $A17F6603637 = $A2DE030231E [ $A17A0803B53 ] [ 0 ] Then
					$A2DE030231E [ $A17A0803B53 ] [ 3 ] = StringStripWS ( StringReplace ( $A39F6A0393D , Execute ( $A5127C01553 ) , $A0127D03A4F ) , 3 )
					$A2DE030231E [ $A17A0803B53 ] [ 3 ] = StringReplace ( $A2DE030231E [ $A17A0803B53 ] [ 3 ] , $A5580E05E46 , $A2127E01E38 )
					GUICtrlSetData ( $A2DE030231E [ $A17A0803B53 ] [ 0 ] , $A2DE030231E [ $A17A0803B53 ] [ 1 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 2 ] & $A5580E05E46 & $A2DE030231E [ $A17A0803B53 ] [ 3 ] )
					ExitLoop
				EndIf
			Next
		EndIf
		$A0FD1304F39 = TrayGetMsg ( )
		Switch $A0FD1304F39
		Case - 7 , - 8 , - 9 , - 10
			GUISwitch ( $A15C6E0081B )
			GUISetState ( Execute ( $A2027F0470A ) , $A15C6E0081B )
		EndSwitch
	WEnd
	GUIRegisterMsg ( 78 , "" )
	If IsHWnd ( $A3CF1602433 ) = 1 Then
		RM_SetTrayInteractionPaused ( 0 )
		GUISetState ( Execute ( $A2C37003914 ) , $A3CF1602433 )
		GUISwitch ( $A59A0605008 )
	EndIf
	GUISetAccelerators ( "" , $A15C6E0081B )
	GUIDelete ( $A15C6E0081B )
	$A2DE030231E = 0
	Opt ( $A2B37104657 , $A58C6B02E23 )
	Opt ( $A1E3720065C , $A01A1805D03 )
	Opt ( $A1F37305D13 , $A3BA1A04626 )
	DllCall ( $A1137402650 , $A5C37504A5B , $A4F37602A4D , $A1237700230 , - 1 )
	Return 1
EndFunc
Func A2C60904A01 ( $A3437800C10 , $A1C37903F55 , $A4AD2605942 , $A1BD2705461 )
	If Not IsDeclared ( "SSA2C60904A01" ) Then
		Global $A0937A0393C = "GUI_RUNDEFMSG" , $A6037C05E23 = "hwnd hWndFrom;uint_ptr IDFrom;INT Code;int Item;int SubItem;uint NewState;uint OldState;uint Changed;long ActionX;long ActionY;lparam Param" , $A1E37F0392C = "\n" , $A3F4700085F = " @CRLF " , $A5147103C5E = "\n" , $A0747203F49 = " @CRLF "
		Global $SSA2C60904A01 = 1
	EndIf
	Local $A029030512B = $A0937A0393C
	Local $A5A37B00425 = DllStructCreate ( $A6037C05E23 , $A1BD2705461 )
	If @error Then Return
	Local $A5F37D03919 = DllStructGetData ( $A5A37B00425 , 3 )
	Local $A17F6603637 , $A1637E05E29 = 0
	Switch $A4AD2605942
	Case $A1BE0205A29
		Switch $A5F37D03919
		Case - 2 , - 3 , - 5
			GUICtrlSetState ( $A2DE030231E [ 0 ] [ 2 ] , 256 )
		Case - 101
			Switch DllStructGetData ( $A5A37B00425 , 6 + $A38B0402436 )
			Case 3
				$A17F6603637 = DllStructGetData ( $A5A37B00425 , 4 + $A38B0402436 ) + 1
				GUICtrlSetData ( $A2DE030231E [ 0 ] [ 1 ] , StringReplace ( $A2DE030231E [ $A17F6603637 ] [ 2 ] , $A1E37F0392C , Execute ( $A3F4700085F ) ) )
				GUICtrlSetData ( $A2DE030231E [ 0 ] [ 2 ] , StringReplace ( $A2DE030231E [ $A17F6603637 ] [ 3 ] , $A5147103C5E , Execute ( $A0747203F49 ) ) )
				$A2DE030231E [ 0 ] [ 3 ] = 1
			Case 0
			EndSwitch
		EndSwitch
	EndSwitch
	$A5A37B00425 = 0
	Return $A029030512B
EndFunc
Func A1D60A05512 ( )
	If Not IsDeclared ( "SSA1D60A05512" ) Then
		Global $A3047303553 = "hwnd" , $A0A4740271A = "GetFocus"
		Global $SSA1D60A05512 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A49C090200E , $A3047303553 , $A0A4740271A )
	If @error Then Return SetError ( @error , @extended , 0 )
	Return $A5731D04046 [ 0 ]
EndFunc
Func A0660B00D4E ( $A2547501F3A )
	If StringLen ( $A2547501F3A ) = 0 Then Return SetError ( 1 , 0 , 0 )
	If IsArray ( $A28A0903157 ) = 0 Then Dim $A28A0903157 [ 1 ] = [ 0 ]
	For $A17A0803B53 = 1 To $A28A0903157 [ 0 ]
		If $A28A0903157 [ $A17A0803B53 ] = $A2547501F3A Then Return 1
	Next
	$A28A0903157 [ 0 ] += 1
	ReDim $A28A0903157 [ $A28A0903157 [ 0 ] + 1 ]
	$A28A0903157 [ $A28A0903157 [ 0 ] ] = $A2547501F3A
	Return 0
EndFunc
Func A3F60C01A5A ( )
	If Not IsDeclared ( "SSA3F60C01A5A" ) Then
		Global $A4347601D15 = "giGDIPRef" , $A0A47805E14 = "ghGDIPDll" , $A4547A0623C = "giGDIPToken" , $A3747C04D0B = "none" , $A0847D06329 = "GdiplusShutdown" , $A6047E05B51 = "ptr"
		Global $SSA3F60C01A5A = 1
	EndIf
	If Not A0660B00D4E ( $A4347601D15 ) Then Global $A3E47702B52 = 0
	If Not A0660B00D4E ( $A0A47805E14 ) Then $A2847903C1A = 0
	If Not A0660B00D4E ( $A4547A0623C ) Then Global $A2747B04C07 = 0
	If $A2847903C1A = 0 Then Return SetError ( - 1 , - 1 , False )
	$A3E47702B52 -= 1
	If $A3E47702B52 = 0 Then
		DllCall ( $A2847903C1A , $A3747C04D0B , $A0847D06329 , $A6047E05B51 , $A2747B04C07 )
		DllClose ( $A2847903C1A )
		$A2847903C1A = 0
	EndIf
	Return True
EndFunc
Func A5060D0303A ( )
	If Not IsDeclared ( "SSA5060D0303A" ) Then
		Global $A2047F0634E = "giGDIPRef" , $A1057001C61 = "ghGDIPDll" , $A2D57103F5F = "giGDIPToken" , $A1257202B4C = "GDIPlus.dll" , $A1357405600 = "uint Version;ptr Callback;bool NoThread;bool NoCodecs" , $A2657604451 = "ulong_ptr Data" , $A2757705B22 = "Version" , $A2157804135 = "int" , $A0F57904905 = "GdiplusStartup" , $A2C57A04C06 = "ptr" , $A2B57B0413D = "ptr" , $A3557C05C49 = "ptr" , $A2157D01F43 = "Data"
		Global $SSA5060D0303A = 1
	EndIf
	If Not A0660B00D4E ( $A2047F0634E ) Then Global $A3E47702B52 = 0
	If Not A0660B00D4E ( $A1057001C61 ) Then $A2847903C1A = 0
	If Not A0660B00D4E ( $A2D57103F5F ) Then Global $A2747B04C07 = 0
	$A3E47702B52 += 1
	If $A3E47702B52 > 1 Then Return True
	$A2847903C1A = DllOpen ( $A1257202B4C )
	If $A2847903C1A = - 1 Then
		$A3E47702B52 = 0
		Return SetError ( 1 , 2 , False )
	EndIf
	Local $A4A57302624 = DllStructCreate ( $A1357405600 )
	Local $A085750183C = DllStructCreate ( $A2657604451 )
	DllStructSetData ( $A4A57302624 , $A2757705B22 , 1 )
	Local $A5731D04046 = DllCall ( $A2847903C1A , $A2157804135 , $A0F57904905 , $A2C57A04C06 , DllStructGetPtr ( $A085750183C ) , $A2B57B0413D , DllStructGetPtr ( $A4A57302624 ) , $A3557C05C49 , 0 )
	If @error Then Return SetError ( @error , @extended , False )
	$A2747B04C07 = DllStructGetData ( $A085750183C , $A2157D01F43 )
	Return $A5731D04046 [ 0 ] = 0
EndFunc
Func A1260E0570B ( $A4357E00A36 )
	If Not IsDeclared ( "SSA1260E0570B" ) Then
		Global $A5867301D07 = "int" , $A4E67401127 = "GdipCreateHBITMAPFromBitmap" , $A4067505A01 = "handle" , $A0067601662 = "ptr*" , $A3A67704C5F = "dword" , $A0567805538 = "int" , $A546790600D = "GdipDisposeImage" , $A0F67A0531C = "handle"
		Global $SSA1260E0570B = 1
	EndIf
	A5060D0303A ( )
	Local $A1857F01062 , $A1167005A5A = 1
	Local $A1067103D4D = 0
	If $A1067103D4D = 0 Then
		$A1857F01062 = A3370601811 ( $A4357E00A36 )
		$A1167005A5A = @error
	EndIf
	If $A1167005A5A <> 0 Then
		If $A1067103D4D = 1 Or $A1BA0E00F18 = 0 Then
			$A1857F01062 = A3560F03760 ( $A4357E00A36 )
		Else
			$A1857F01062 = A3B70201312 ( $A4357E00A36 )
		EndIf
	EndIf
	Local $A3867205031 = DllCall ( $A2847903C1A , $A5867301D07 , $A4E67401127 , $A4067505A01 , $A1857F01062 , $A0067601662 , 0 , $A3A67704C5F , 15790320 )
	If @error Then
		$A3867205031 = 0
	Else
		$A3867205031 = $A3867205031 [ 2 ]
	EndIf
	DllCall ( $A2847903C1A , $A0567805538 , $A546790600D , $A0F67A0531C , $A1857F01062 )
	Return $A3867205031
EndFunc
Func A3560F03760 ( $A4357E00A36 )
	If Not IsDeclared ( "SSA3560F03760" ) Then
		Global $A3867B03707 = "Library\" , $A3F67C02E33 = "int" , $A5567D01E05 = "GdipLoadImageFromFile" , $A3567E01925 = "wstr" , $A3967F05248 = "ptr*"
		Global $SSA3560F03760 = 1
	EndIf
	If FileExists ( $A47D0805C4F & $A4357E00A36 ) = 1 Then
		$A4357E00A36 = $A47D0805C4F & $A4357E00A36
	Else
		$A4357E00A36 = $A47D0805C4F & $A3867B03707 & $A4357E00A36
	EndIf
	Local $A1857F01062 = DllCall ( $A2847903C1A , $A3F67C02E33 , $A5567D01E05 , $A3567E01925 , $A4357E00A36 , $A3967F05248 , 0 )
	If @error Then
		$A1857F01062 = - 1
	Else
		$A1857F01062 = $A1857F01062 [ 2 ]
	EndIf
	Return $A1857F01062
EndFunc
Func A4C70005146 ( $A4CF1401813 , $A4357E00A36 , $A4877003204 = 0 , $A5F77101C07 = 18 , $A4F77205748 = 18 )
	If Not IsDeclared ( "SSA4C70005146" ) Then
		Global $A4C77400425 = "hwnd" , $A0077503F52 = "ImageList_Create" , $A0D7760061C = "int" , $A3C77705F0B = "int" , $A3A7780210D = "int" , $A3777905525 = "int" , $A2277A03017 = "int" , $A2477C01560 = "int" , $A4777D00008 = "int" , $A1177E03225 = "ImageList_Add" , $A1A77F01952 = "handle" , $A1287002D19 = "handle" , $A2687102E37 = "handle" , $A3B8730204C = "ptr;uint;uint;uint;uint;uint" , $A4F87601451 = "bool" , $A4387706355 = "DeleteObject" , $A1987803235 = "handle" , $A0587905258 = "bool" , $A0D87A00E03 = "DeleteObject" , $A3787B03953 = "handle"
		Global $SSA4C70005146 = 1
	EndIf
	Local $A3867205031 = A1260E0570B ( $A4357E00A36 )
	Local $A5577300316 = DllCall ( $A4DD0103C1A , $A4C77400425 , $A0077503F52 , $A0D7760061C , $A5F77101C07 , $A3C77705F0B , $A4F77205748 , $A3A7780210D , BitOR ( 1 , 32 ) , $A3777905525 , 0 , $A2277A03017 , 1 )
	Local $A6177B00241 = DllStructCreate ( $A2477C01560 )
	DllCall ( $A4DD0103C1A , $A4777D00008 , $A1177E03225 , $A1A77F01952 , $A5577300316 [ 0 ] , $A1287002D19 , $A3867205031 , $A2687102E37 , 0 )
	Local $A188720435E = DllStructCreate ( $A3B8730204C )
	DllStructSetData ( $A188720435E , 1 , $A5577300316 [ 0 ] )
	DllStructSetData ( $A188720435E , 2 , 2 )
	DllStructSetData ( $A188720435E , 3 , 1 )
	DllStructSetData ( $A188720435E , 4 , 2 )
	DllStructSetData ( $A188720435E , 5 , 1 )
	If $A4877003204 = 0 Then DllStructSetData ( $A188720435E , 4 , 5 )
	If $A4877003204 < 0 Or $A4877003204 > 4 Then $A4877003204 = 4
	DllStructSetData ( $A188720435E , 6 , $A4877003204 )
	Local $A1487404A10 = BitAND ( GUICtrlGetState ( $A4CF1401813 ) , 128 )
	GUICtrlSetState ( $A4CF1401813 , 128 )
	Local $A0DD4A04328 = 0
	Local $A2187504857 = GUICtrlSendMsg ( $A4CF1401813 , 5634 , 0 , DllStructGetPtr ( $A188720435E ) )
	If $A2187504857 Then
		DllCall ( $A0AD0306025 , $A4F87601451 , $A4387706355 , $A1987803235 , $A2187504857 )
		$A0DD4A04328 = 1
	EndIf
	If $A3867205031 Then DllCall ( $A0AD0306025 , $A0587905258 , $A0D87A00E03 , $A3787B03953 , $A3867205031 )
	$A6177B00241 = 0
	$A188720435E = 0
	GUICtrlSetState ( $A4CF1401813 , 64 )
	If $A1487404A10 = 128 Then GUICtrlSetState ( $A4CF1401813 , 128 )
	Return SetError ( $A0DD4A04328 <> 0 , 0 , $A0DD4A04328 )
EndFunc
Func A227010044F ( $A4CF1401813 , $A4357E00A36 )
	If Not IsDeclared ( "SSA227010044F" ) Then
		Global $A0C87D01001 = "bool" , $A2787E00C03 = "DeleteObject" , $A0B87F04623 = "handle" , $A1997003F0F = "bool" , $A1697102C16 = "DeleteObject" , $A1797200B56 = "handle"
		Global $SSA227010044F = 1
	EndIf
	Local $A3867205031 = A1260E0570B ( $A4357E00A36 )
	Local $A0DD4A04328 = 0
	Local $A0B87C01750 = GUICtrlSendMsg ( $A4CF1401813 , 370 , 0 , $A3867205031 )
	If $A0B87C01750 Then
		DllCall ( $A0AD0306025 , $A0C87D01001 , $A2787E00C03 , $A0B87F04623 , $A0B87C01750 )
		$A0DD4A04328 = 1
	EndIf
	If $A3867205031 Then DllCall ( $A0AD0306025 , $A1997003F0F , $A1697102C16 , $A1797200B56 , $A3867205031 )
	Return SetError ( 1 - $A0DD4A04328 , 0 , $A0DD4A04328 )
EndFunc
Func A3B70201312 ( $A2197305E30 , $A2797405D59 = 10 , $A5497504A05 = - 1 )
	If Not IsDeclared ( "SSA3B70201312" ) Then
		Global $A3B97B04517 = "handle" , $A3097C05F5E = "GlobalAlloc" , $A4F97D0485D = "uint" , $A0197E00612 = "ulong_ptr" , $A5E97F04330 = "ptr" , $A34A7001408 = "GlobalLock" , $A59A710534E = "handle" , $A03A7201659 = "none" , $A41A7306023 = "RtlMoveMemory" , $A53A7406023 = "INT_PTR" , $A03A7500F3E = "INT_PTR" , $A19A7600217 = "ulong_ptr" , $A02A7706036 = "bool" , $A2EA7800F4B = "GlobalUnlock" , $A5EA790212C = "handle" , $A22A7A0121F = "int" , $A35A7B04662 = "CreateStreamOnHGlobal" , $A22A7C03F57 = "ptr" , $A08A7D03636 = "int" , $A07A7E0204B = "ptr*" , $A09A7F0512D = "int" , $A30B7000438 = "GdipCreateBitmapFromStream" , $A0AB7104031 = "ptr" , $A32B720581C = "ptr*" , $A0DB7301C50 = "bool" , $A52B7403C04 = "DeleteObject" , $A1CB7501A2C = "handle" , $A08B7605944 = "ptr" , $A2FB770582B = "GlobalFree" , $A14B7802438 = "handle"
		Global $SSA3B70201312 = 1
	EndIf
	Local $A5197603A38 , $A3897705036 , $A0297800E32 , $A4E97903F36 , $A1F97A0620C
	$A5197603A38 = A0570300312 ( $A2197305E30 , 10 , 0 , $A5497504A05 )
	If @error Then Return SetError ( 1 , 0 , 0 )
	$A3897705036 = @extended
	Local $A0297800E32 = DllCall ( $A55C0703122 , $A3B97B04517 , $A3097C05F5E , $A4F97D0485D , 2 , $A0197E00612 , $A3897705036 )
	If @error Then
		$A0297800E32 = 0
	Else
		$A0297800E32 = $A0297800E32 [ 0 ]
	EndIf
	Local $A4E97903F36 = DllCall ( $A55C0703122 , $A5E97F04330 , $A34A7001408 , $A59A710534E , $A0297800E32 )
	If @error Then
		$A4E97903F36 = 0
	Else
		$A4E97903F36 = $A4E97903F36 [ 0 ]
	EndIf
	DllCall ( $A55C0703122 , $A03A7201659 , $A41A7306023 , $A53A7406023 , $A4E97903F36 , $A03A7500F3E , $A5197603A38 , $A19A7600217 , $A3897705036 )
	DllCall ( $A55C0703122 , $A02A7706036 , $A2EA7800F4B , $A5EA790212C , $A0297800E32 )
	$A1F97A0620C = DllCall ( $A5BC0F03109 , $A22A7A0121F , $A35A7B04662 , $A22A7C03F57 , $A0297800E32 , $A08A7D03636 , 1 , $A07A7E0204B , 0 )
	$A1F97A0620C = $A1F97A0620C [ 3 ]
	Local $A1857F01062 = DllCall ( $A2847903C1A , $A09A7F0512D , $A30B7000438 , $A0AB7104031 , $A1F97A0620C , $A32B720581C , 0 )
	$A1857F01062 = $A1857F01062 [ 2 ]
	DllCall ( $A0AD0306025 , $A0DB7301C50 , $A52B7403C04 , $A1CB7501A2C , $A1F97A0620C )
	DllCall ( $A55C0703122 , $A08B7605944 , $A2FB770582B , $A14B7802438 , $A0297800E32 )
	Return $A1857F01062
EndFunc
Func A0570300312 ( $A2197305E30 , $A2797405D59 = 10 , $A1CB7903F08 = 0 , $A5497504A05 = - 1 )
	If Not IsDeclared ( "SSA0570300312" ) Then
		Global $A1CC7201726 = "handle" , $A23C7304032 = "GetModuleHandleW" , $A18C740151A = "ptr" , $A4EC750525C = "handle" , $A5FC7605609 = "LoadLibraryExW" , $A20C770371F = "wstr" , $A00C7800E32 = "ptr" , $A04C7905722 = "dword" , $A5AC7B01532 = "int" , $A07C7C00306 = "wstr" , $A12C7D0133C = "handle" , $A52C7E03D2F = "LoadImageW" , $A2AC7F0594E = "handle" , $A40D7001209 = "uint" , $A3FD710134E = "int" , $A48D7202230 = "int" , $A4BD7303B5B = "uint" , $A1CD7402A55 = "ptr" , $A06D7502224 = "FindResourceExW" , $A62D7602E50 = "ptr" , $A0FD7703314 = "long" , $A32D7801163 = "wstr" , $A3BD790155C = "short" , $A4AD7A0331F = "ptr" , $A5DD7B05E2F = "FindResourceW" , $A29D7C05816 = "ptr" , $A53D7D01832 = "wstr" , $A1CD7E0071F = "long" , $A51D7F04443 = "dword" , $A24E700450C = "SizeofResource" , $A5FE7103207 = "ptr" , $A51E7201053 = "ptr" , $A59E730293F = "ptr" , _
		$A30E7401A4F = "LoadResource" , $A21E7505056 = "ptr" , $A5AE760343C = "ptr" , $A59E7700213 = "ptr" , $A28E7800E47 = "LockResource" , $A4CE7901B33 = "ptr" , $A11E7A0511C = "bool" , $A25E7B04B27 = "FreeLibrary" , $A43E7C00E20 = "handle"
		Global $SSA0570300312 = 1
	EndIf
	Local Const $A0FB7A01C09 = 0 , $A21B7B01F5F = 2 , $A19B7C05C3B = 2
	Local $A20B7D01B32 , $A3867205031 , $A26B7E05B28 , $A56B7F05662 , $A05C7000E50 , $A58C7103E38 , $A23F2803807
	If $A5497504A05 = - 1 Then
		$A20B7D01B32 = DllCall ( $A55C0703122 , $A1CC7201726 , $A23C7304032 , $A18C740151A , 0 )
		$A23F2803807 = @error
	Else
		$A20B7D01B32 = DllCall ( $A55C0703122 , $A4EC750525C , $A5FC7605609 , $A20C770371F , $A5497504A05 , $A00C7800E32 , 0 , $A04C7905722 , $A21B7B01F5F )
		$A23F2803807 = @error
	EndIf
	If $A23F2803807 Then
		$A20B7D01B32 = 0
	Else
		$A20B7D01B32 = $A20B7D01B32 [ 0 ]
	EndIf
	If $A20B7D01B32 = 0 Then Return SetError ( 1 , 0 , 0 )
	If $A2797405D59 = $A19B7C05C3B Then
		Local $A46C7A05E20 = $A5AC7B01532
		If IsString ( $A2197305E30 ) Then $A46C7A05E20 = $A07C7C00306
		$A3867205031 = DllCall ( $A49C090200E , $A12C7D0133C , $A52C7E03D2F , $A2AC7F0594E , $A20B7D01B32 , $A46C7A05E20 , $A2197305E30 , $A40D7001209 , $A0FB7A01C09 , $A3FD710134E , 0 , $A48D7202230 , 0 , $A4BD7303B5B , 0 )
		If @error Then Return SetError ( 2 , 0 , 0 )
		Return $A3867205031 [ 0 ]
	EndIf
	If $A1CB7903F08 <> 0 Then
		$A26B7E05B28 = DllCall ( $A55C0703122 , $A1CD7402A55 , $A06D7502224 , $A62D7602E50 , $A20B7D01B32 , $A0FD7703314 , $A2797405D59 , $A32D7801163 , $A2197305E30 , $A3BD790155C , $A1CB7903F08 )
	Else
		$A26B7E05B28 = DllCall ( $A55C0703122 , $A4AD7A0331F , $A5DD7B05E2F , $A29D7C05816 , $A20B7D01B32 , $A53D7D01832 , $A2197305E30 , $A1CD7E0071F , $A2797405D59 )
	EndIf
	If @error Then Return SetError ( 3 , 0 , 0 )
	$A26B7E05B28 = $A26B7E05B28 [ 0 ]
	If $A26B7E05B28 = 0 Then Return SetError ( 4 , 0 , 0 )
	$A58C7103E38 = DllCall ( $A55C0703122 , $A51D7F04443 , $A24E700450C , $A5FE7103207 , $A20B7D01B32 , $A51E7201053 , $A26B7E05B28 )
	If @error Then Return SetError ( 5 , 0 , 0 )
	$A58C7103E38 = $A58C7103E38 [ 0 ]
	If $A58C7103E38 = 0 Then Return SetError ( 6 , 0 , 0 )
	$A56B7F05662 = DllCall ( $A55C0703122 , $A59E730293F , $A30E7401A4F , $A21E7505056 , $A20B7D01B32 , $A5AE760343C , $A26B7E05B28 )
	If @error Then Return SetError ( 7 , 0 , 0 )
	$A56B7F05662 = $A56B7F05662 [ 0 ]
	If $A56B7F05662 = 0 Then Return SetError ( 8 , 0 , 0 )
	$A05C7000E50 = DllCall ( $A55C0703122 , $A59E7700213 , $A28E7800E47 , $A4CE7901B33 , $A56B7F05662 )
	If @error Then Return SetError ( 9 , 0 , 0 )
	$A05C7000E50 = $A05C7000E50 [ 0 ]
	If $A05C7000E50 = 0 Then Return SetError ( 10 , 0 , 0 )
	If $A5497504A05 <> - 1 Then DllCall ( $A55C0703122 , $A11E7A0511C , $A25E7B04B27 , $A43E7C00E20 , $A20B7D01B32 )
	If @error Then Return SetError ( 11 , 0 , 0 )
	SetExtended ( $A58C7103E38 )
	Return $A05C7000E50
EndFunc
Func A4D70405A59 ( $A5A31B00E55 , $A08E7D04A3C , $A4AD2605942 = 0 , $A1BD2705461 = 0 , $A11E7E01F04 = 0 , $A18E7F04004 = "wparam" , $A4EF700434C = "lparam" , $A1FF7100908 = "lresult" )
	If Not IsDeclared ( "SSA4D70405A59" ) Then
		Global $A3DF720052E = "SendMessageW" , $A19F730560A = "hwnd" , $A1DF7400656 = "uint"
		Global $SSA4D70405A59 = 1
	EndIf
	Local $A5731D04046 = DllCall ( $A49C090200E , $A1FF7100908 , $A3DF720052E , $A19F730560A , $A5A31B00E55 , $A1DF7400656 , $A08E7D04A3C , $A18E7F04004 , $A4AD2605942 , $A4EF700434C , $A1BD2705461 )
	Local $A23F2803807 = @error
	Local $A3933300E2A = @extended
	If $A23F2803807 Then Return SetError ( $A23F2803807 , $A3933300E2A , "" )
	If $A11E7E01F04 >= 0 And $A11E7E01F04 <= 4 Then Return $A5731D04046 [ $A11E7E01F04 ]
	Return $A5731D04046
EndFunc
Func A037050620F ( $A08F750234B )
	If Not IsDeclared ( "SSA037050620F" ) Then
		Global $A01F7905613 = "handle" , $A4EF7A03707 = "GlobalAlloc" , $A4AF7B0310E = "uint" , $A07F7C04D51 = "ulong_ptr" , $A18F7D0585A = "ptr" , $A25F7E0350C = "GlobalLock" , $A30F7F01903 = "handle" , $A0408102B0A = "byte[" , $A490820025E = "]" , $A3908303A22 = "bool" , $A1B0840121A = "GlobalUnlock" , $A480850335D = "handle" , $A5908701750 = "int" , $A1908802D1F = "CreateStreamOnHGlobal" , $A2E08905D5F = "ptr" , $A4008A06329 = "int" , $A2408B04E1A = "ptr*" , $A0408C05236 = "int" , $A0308D05012 = "GdipCreateBitmapFromStream" , $A4708E02952 = "ptr" , $A0B08F05052 = "ptr*" , $A2A18000352 = "oleaut32.dll" , $A5F18103360 = "long" , $A4718200B2B = "DispCallFunc" , $A4C1830240F = "ptr" , $A5F18405814 = "ulong_ptr" , $A3F1850022A = " @AutoItX64 " , $A0018601E26 = "uint" , $A051870495F = "ushort" , $A361880452E = "uint" , $A4B18901328 = "ptr" , $A2818A04E37 = "ptr" , $A2118B06351 = "str"
		Global $SSA037050620F = 1
	EndIf
	If Not IsBinary ( $A08F750234B ) Then Return SetError ( 1 , 0 , 0 )
	Local $A5731D04046 = 0
	Local Const $A51F7605E4D = Binary ( $A08F750234B )
	Local Const $A01F7703854 = BinaryLen ( $A51F7605E4D )
	Local Const $A09F780203B = 2
	$A5731D04046 = DllCall ( $A55C0703122 , $A01F7905613 , $A4EF7A03707 , $A4AF7B0310E , $A09F780203B , $A07F7C04D51 , $A01F7703854 )
	If @error Then Return SetError ( 4 , 0 , 0 )
	Local Const $A0297800E32 = $A5731D04046 [ 0 ]
	$A5731D04046 = DllCall ( $A55C0703122 , $A18F7D0585A , $A25F7E0350C , $A30F7F01903 , $A0297800E32 )
	If @error Then Return SetError ( 5 , 0 , 0 )
	Local $A3B0800261B = DllStructCreate ( $A0408102B0A & $A01F7703854 & $A490820025E , $A5731D04046 [ 0 ] )
	DllStructSetData ( $A3B0800261B , 1 , $A51F7605E4D )
	DllCall ( $A55C0703122 , $A3908303A22 , $A1B0840121A , $A480850335D , $A0297800E32 )
	If @error Then Return SetError ( 6 , 0 , 0 )
	Local $A2808603159 = DllCall ( $A5BC0F03109 , $A5908701750 , $A1908802D1F , $A2E08905D5F , $A0297800E32 , $A4008A06329 , 1 , $A2408B04E1A , 0 )
	If @error Or $A2808603159 [ 0 ] Then SetError ( 2 , 0 , 0 )
	$A2808603159 = $A2808603159 [ 3 ]
	Local $A3867205031 = DllCall ( $A2847903C1A , $A0408C05236 , $A0308D05012 , $A4708E02952 , $A2808603159 , $A0B08F05052 , 0 )
	If @error Or $A3867205031 [ 0 ] Then SetError ( 3 , 0 , 0 )
	$A3867205031 = $A3867205031 [ 2 ]
	DllCall ( $A2A18000352 , $A5F18103360 , $A4718200B2B , $A4C1830240F , $A2808603159 , $A5F18405814 , 8 * ( 1 + Execute ( $A3F1850022A ) ) , $A0018601E26 , 4 , $A051870495F , 23 , $A361880452E , 0 , $A4B18901328 , 0 , $A2818A04E37 , 0 , $A2118B06351 , "" )
	Return $A3867205031
EndFunc
Func A3370601811 ( $A4357E00A36 )
	If Not IsDeclared ( "SSA3370601811" ) Then
		Global $A3318D02838 = "alogo.png" , $A2218E00A22 = "ainfo.png" , $A2118F03B1E = "01.png" , $A0428003304 = "02.png" , $A2928100919 = "03.png" , $A372820005D = "04.png" , $A042830073E = "06.png" , $A4428404E3E = "07.png" , $A2328502C38 = "08.png" , $A6028603C40 = "09.png"
		Global $SSA3370601811 = 1
	EndIf
	Local $A0D18C04350
	Switch $A4357E00A36
	Case $A3318D02838
		$A0D18C04350 = A2B70F04352 ( )
	Case $A2218E00A22
		$A0D18C04350 = A348000001A ( )
	Case $A2118F03B1E
		$A0D18C04350 = A3270702E1F ( )
	Case $A0428003304
		$A0D18C04350 = A0B70800661 ( )
	Case $A2928100919
		$A0D18C04350 = A1F7090060D ( )
	Case $A372820005D
		$A0D18C04350 = A3370A00736 ( )
	Case $A042830073E
		$A0D18C04350 = A5370B0434D ( )
	Case $A4428404E3E
		$A0D18C04350 = A2070C05641 ( )
	Case $A2328502C38
		$A0D18C04350 = A4E70D05132 ( )
	Case $A6028603C40
		$A0D18C04350 = A1370E00756 ( )
Case Else
		Return SetError ( 1 , 0 , 0 )
	EndSwitch
	Local $A1132703101 = A037050620F ( Binary ( $A0D18C04350 ) )
	If @error Then Return SetError ( 2 , 0 , 0 )
	Return $A1132703101
EndFunc
Func A3270702E1F ( )
	If Not IsDeclared ( "SSA3270702E1F" ) Then
		Global $A542880031C = "0x89504E470D0A1A0A0000000D494844520000001200000012080600000056CE8E570000001974455874536F667477617265" , $A2F2890513A = "0041646F626520496D616765526561647971C9653C0000032269545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A4E28A05301 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A0628B05E07 = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A1628C0352E = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A4D28D00E02 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A3628E01948 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A3928F00A30 = "663A61626F75743D222220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E" , _
		$A4D38003E4F = "302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F7354" , $A323810100D = "7970652F5265736F75726365526566232220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F78" , $A2F38205D60 = "61702F312E302F2220786D704D4D3A446F63756D656E7449443D22786D702E6469643A313146334543383830313346313145" , $A1838304E20 = "41383544364233344334463932363345372220786D704D4D3A496E7374616E636549443D22786D702E6969643A3131463345" , $A5F3840375C = "4338373031334631314541383544364233344334463932363345372220786D703A43726561746F72546F6F6C3D2241646F62" , $A4D3850483D = "652050686F746F73686F7020435336202857696E646F777329223E203C786D704D4D3A4465726976656446726F6D20737452" , $A2338604A1C = "65663A696E7374616E636549443D22786D702E6969643A353437313141414131433734313145383942443145303335353446" , $A2538701C1F = "4336453631222073745265663A646F63756D656E7449443D22786D702E6469643A3534373131414142314337343131453839" , _
		$A6338803F49 = "424431453033353534464336453631222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244463E203C" , $A1B38903C2F = "2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3ED4374978000003AD4944415478DA94544D4C1C" , $A5238A01F51 = "551CFFCDCCDB8F999DFD5ED8A5ECB22069F9086141A2524289219A2640D2F46038D4A3696BF5663C78F36A3CF4A4871EB489" , $A0838B02361 = "095189175315D268A36D85806270619B5DD82D0576292C2B2CB3B3B36F7666C7A1B5D20324FA7FF9BFBCBC97F7FB7FFEFECC" , $A1E38C04E46 = "B76F3683271AB6140E1AC340C948B0D4742886030D31118C2CA35836C0B11AAA0683DFFDAFA3EA6E815B74C2CA0B819EF6D6" , $A5738D02107 = "F8F2E2AF9FB3F85FC2980BA0AA0A5DADF26722F55F3D7AB812922A64F83F03D56A06741D90E532AC565BDFD040DFE38A521A" , $A5C38E0573C = "7E904A4FA557D3FDE444DB6698E6864A4547312FC34E2A5E4547D9D5D23A3A3C36F2CDEEC30412C9B54D86E1C61D0E1E2702" , $A0A38F0431A = "55A801A920C32F18A3CDE7DBDE8F7445CF314A9E5DE5BCFA6C6617DB1BFB46CD228CA90C3D1003A78E800E1D806102A806E4" , _
		$A1A48000E07 = "A2028FCF72F6E591EECF9A4F37B68B1D2F00ACDD7CDC83387F9B9B9B59C41E0D5F2C15D6160541802219269009C032A67549" , $A6248104819 = "05A52A04437B65E0DDFE1B5A3CD3ED5329F8881FBB8B2968550A83D851575F8773DCCFCAF6ECFEDDA8CBF1E4EFA1102A9B00" , $A1248201761 = "15098DE1D058C7F9DE8F8D85543BBBB787C0A501C4AFDF86AC5308513FA49D0A9C5E01BBFB3AA86EA761915589D936EC3FE5" , $A5948300B16 = "22A2C77A213A30F851F399BAB6C30BE5B54E646EDE039D594570AC1385EF96210DAAF0377951DD97CCB04B48AFCBF3D91253" , $A454840212E = "728A4739657B47621F84C3CEB662BE8492A4409515900E1FB6EF24E1E1CD14769DC25FB756407345C00AECEF9490CB1E7C49" , $A0D48502F07 = "CCA79AD90FCF944885F23BA8D2793E18600AC935488F77111DEE41536B10D3EF4DA3E7AD6ED48D77E1C1C4329AFA7CC831F6" , $A2F48600359 = "F582CDFF85D3C1C178BE5D0AD3E3B0417BA3945CFDBA2A381188B581168A48DE5F066FB742BAB7016B471D3C5111B91FD2B8" , $A3D48704F36 = "9FD12E1D70E284DDF2B4CACF843B3BD88BDFD27A42139C96D84BA1A17C6A0B6B7716E16CF0A3F1C50848D08EB5EFD310541D" , _
		$A564880255C = "72932F998817AE786CAA59EE43A5FF2A77A1376446A6C1E7223F219B657273C957F99017F59D11B05219D430600FDAB0933E" , $A2B48900A00 = "C0DDA9EC35C64612E6D513BA3CAF64D4B701C201E50A8B3F56B40FDD8223E46D095DB1682A6A360BB20B9B888478649B3D7F" , $A2448A01C60 = "AAEB74D2E7B21ECB04726BABE1E9E9D08C9B435564AE366A7ACDE513DFCE2C6D01AA66325DC36A7CEF3AE7F5A36AA91D0F44" , $A0948B03157 = "79D711BF7402B7B582479B3BD7A6E2C5A57EA1FC49ECB41B537385D4C49272D3E9D4C031C77393580CED6854985EF15C0D56" , $A3448C04539 = "9660F2C7F54F9703F8E5F21059989CC9DF98CD6B0852E3C431F3B7000300AB3DAB2603AFF9D10000000049454E44AE426082"
		Global $SSA3270702E1F = 1
	EndIf
	Local $A1428704824 = $A542880031C & $A2F2890513A & $A4E28A05301 & $A0628B05E07 & $A1628C0352E & $A4D28D00E02 & $A3628E01948 & $A3928F00A30 & $A4D38003E4F & $A323810100D & $A2F38205D60 & $A1838304E20 & $A5F3840375C & $A4D3850483D & $A2338604A1C & $A2538701C1F & $A6338803F49 & $A1B38903C2F & $A5238A01F51 & $A0838B02361 & $A1E38C04E46 & $A5738D02107 & $A5C38E0573C & $A0A38F0431A & $A1A48000E07 & $A6248104819 & $A1248201761 & $A5948300B16 & $A454840212E & $A0D48502F07 & $A2F48600359
	$A1428704824 &= $A3D48704F36 & $A564880255C & $A2B48900A00 & $A2448A01C60 & $A0948B03157 & $A3448C04539
	Return $A1428704824
EndFunc
Func A0B70800661 ( )
	If Not IsDeclared ( "SSA0B70800661" ) Then
		Global $A2B48D00221 = "0x89504E470D0A1A0A0000000D494844520000001200000012080600000056CE8E570000001974455874536F667477617265" , $A3748E05C56 = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A2A48F04457 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A3C5800062E = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A4158105458 = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A2458203C41 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A3158305E23 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A0258404F24 = "663A61626F75743D222220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E" , _
		$A0C58505B00 = "302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F7354" , $A0958604B29 = "7970652F5265736F75726365526566232220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F78" , $A2A58701151 = "61702F312E302F2220786D704D4D3A446F63756D656E7449443D22786D702E6469643A393633423943413730313431313145" , $A2C58802617 = "41393244364436374545323144323536382220786D704D4D3A496E7374616E636549443D22786D702E6969643A3936334239" , $A3958902718 = "4341363031343131314541393244364436374545323144323536382220786D703A43726561746F72546F6F6C3D2241646F62" , $A2458A0210C = "652050686F746F73686F702043432032303135202857696E646F777329223E203C786D704D4D3A4465726976656446726F6D" , $A2D58B01D60 = "2073745265663A696E7374616E636549443D22786D702E6969643A3732374536444446303134313131454139453530434536" , $A0658C04D4F = "313837383041453631222073745265663A646F63756D656E7449443D22786D702E6469643A37323745364445303031343131" , _
		$A3858D0214E = "31454139453530434536313837383041453631222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A1958E03F2B = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E41175C52000003174944415478DA94" , $A4558F0304D = "544D68545714FECEBDF7FDCCC419A3215A534AC1DAA2C1D8462A42E2460441A4B421881557BA694B11842E0B0675E3C2759A" , $A1B68003533 = "2EBAAC15FC592A011745D445192A418410044B2D628C7134337933EFBDFBE3B993191BC96CBCBCFB1EF79D7BBF73CEF77DEF" , $A2668104638 = "D1F8C455741BD649443281EA4960119D08F3FC9425DACAA1F5CEE1BE24B79B27C00B2B0554E4B2AE40CE0A90B210866E49AB" , $A6068205506 = "0F30C8FF31878B7C07045A0F3F549F5A5803B272C4A1AE7AAE67080E08B2ABA262D4C1DD731DD0F66EF574FDA6B56D9140A4" , $A3F68306137 = "B3AFE2341D13CE76AAF0731F49710F30A0B7491916A2A88A8D66F7D680710FD8C9AAA04F32E85DE70C0CBF276E951899AF83" , $A1568402403 = "19C4CF2A761AD61AB8551CF86148EDF0403EA3AF2A898BF35914A2D05846D0D420C99503DB35C9696198CB1A1F4A65849C82" , _
		$A3468504E53 = "B733A5D0B7E7A8C324E7087273216CA40169D3AA90E7E7DA8919B7127E2916B305A4C59839E4A5246829119ADCB732835584" , $A6068603228 = "4AA387A2ACF997B06E98F78E334BB73914B68473EE91B0B0EFC8C52DF6FA868286FE3DAE35E0445B43FF20F10591F89BC3DE" , $A466870032D = "7C65A324823447FFB3E757848068ABCA97B13B154C5534CC99C79F7E72FBE1E8D0649C3441AEAB1E28D6122C6EDE58993E7E" , $A2B6880234B = "F8A2EA14CFE57FC976B92B99581BD1D9527D69BEBAA5F7C7A42796416EBFEB088DB6285EB1B89E541606FAF73FDC3304A559" , $A2468903F12 = "B5C0B883D2B869DB6E238D236C987F31D5FFDF732C6D287D9FAAFCB232F62708F919B1E5B9F27F93D2BADFC264F91219D376" , $A5A68A03A29 = "76DC77286CA6375AFC74BC6B2DF238441E61AA906403E1D2AB89AC18FDD92C95BD7A5C8D6D7D5F102BF6689D29CBD279CB0B" , $A5C68B02A1A = "EDE82C59474AEB731D47AA5CE375B9E7746564A46F76C72E90F78BB56D3FBF3B84D17AB757C62A9ACC0385DABAD2242B9779" , $A3568C02836 = "0E4AD51AFA93856FD5876EB1D09BB3050C6B4C5D891739D12C79C9148D31982F794C6A13C64B0D3C19FCE858FDE3DE9B7B2A" , _
		$A4F68D03463 = "156CFB678E9309B681E80AA4CABA7EBE1E942EB16FA638D92FB1CBA8C0923FD83BF8C39DAFF75F5EBDF99B5FAFE183274F91" , $A3768E0465E = "16E2B515F5E9EA1FFC6B3A62A5AC724BFC61B857B9C0D1B9E1ED53788FF14680010077736648FF7580570000000049454E44" , $A1C68F03F48 = "AE426082"
		Global $SSA0B70800661 = 1
	EndIf
	Local $A1428704824 = $A2B48D00221 & $A3748E05C56 & $A2A48F04457 & $A3C5800062E & $A4158105458 & $A2458203C41 & $A3158305E23 & $A0258404F24 & $A0C58505B00 & $A0958604B29 & $A2A58701151 & $A2C58802617 & $A3958902718 & $A2458A0210C & $A2D58B01D60 & $A0658C04D4F & $A3858D0214E & $A1958E03F2B & $A4558F0304D & $A1B68003533 & $A2668104638 & $A6068205506 & $A3F68306137 & $A1568402403 & $A3468504E53 & $A6068603228 & $A466870032D & $A2B6880234B & $A2468903F12 & $A5A68A03A29 & $A5C68B02A1A
	$A1428704824 &= $A3568C02836 & $A4F68D03463 & $A3768E0465E & $A1C68F03F48
	Return $A1428704824
EndFunc
Func A1F7090060D ( )
	If Not IsDeclared ( "SSA1F7090060D" ) Then
		Global $A5B78002A19 = "0x89504E470D0A1A0A0000000D494844520000001200000012080600000056CE8E570000001974455874536F667477617265" , $A2578104730 = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A5C78203C63 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A5178301044 = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A1A78402B0C = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A2A78504A51 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A6278602841 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A1678705B61 = "663A61626F75743D222220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E" , _
		$A3678803852 = "302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F7354" , $A4F7890442D = "7970652F5265736F75726365526566232220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F78" , $A4478A03B5A = "61702F312E302F2220786D704D4D3A446F63756D656E7449443D22786D702E6469643A323339443044374130313432313145" , $A1A78B05618 = "41394241453932424445324446383936372220786D704D4D3A496E7374616E636549443D22786D702E6969643A3233394430" , $A3578C05D33 = "4437393031343231314541394241453932424445324446383936372220786D703A43726561746F72546F6F6C3D2241646F62" , $A5178D03963 = "652050686F746F73686F702043432032303139202857696E646F777329223E203C786D704D4D3A4465726976656446726F6D" , $A2678E05B42 = "2073745265663A696E7374616E636549443D22786D702E6969643A3838313644454335303134303131454141353138454532" , $A0078F0451C = "423042313941303537222073745265663A646F63756D656E7449443D22786D702E6469643A38383136444543363031343031" , _
		$A3788003E1E = "31454141353138454532423042313941303537222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A0C88103814 = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E0EE039C4000002EA4944415478DAA4" , $A5F88201501 = "935B4B545114C7FF679F3357E7E65C22276F5DC44B4A41A45269124D37A8977AEB4304D29B511408F6010A7A28C887E8A19E" , $A548830113B = "0C24D122994A2DA95E2A1B1BAF348233CE7DF4CC3E97F69CB946DA4B1BCED9B0F65ABFFD5F7BADC50D3D5F4271514580CB10" , $A5B88401C38 = "C77EEB222805373A3EA6A0625D38738EE8054EFD11AB4194BA2010092A3848320FA1D251CF0EC262353B50E0963E939CEDE6" , $A3088506207 = "AD41F65771E7F60D24E27112DCB0C89B46236C16154AC53582AAAA9065B564201019CC0D8A1619F88827C38F004E63C23FFD" , $A3988601D2E = "5EA6F63ED4D453504981CA4839452A8B12E6023F55ECB0AAD8D7B8EF008860C07C308074F545CD7769758DFDD7FEF0D552F3" , $A138870443D = "9DED0514B96CD4E9914E44303B3282F18997257B6B8380D6AE5E246359966DFE7E95E3313E3699074592022489806387DA31" , _
		$A0388804C2F = "07E888056DBE7EC8D99416C0EBADEC06171656724FC133174E83F13ABEAC281D0E3150AE02855BD84608CB5B6F62BB9D3D11" , $A5388901821 = "0B13192095627E516683E6C9E53E8E2B830EBAE3A8B52B5004330C56678E029A4E806622C8D22C64492E059411805150104A" , $A2288A01006 = "1B31570435EDF5A2A5CEC6DE2983E5170F9189AEA3D97715BAE666649251A452498874FB829824333015CA83364549334E3E" , $A5B88B0312F = "18C2CAEBC7F0EC762118F80ADFC0B0A652A4C99D0ACB7AAE2235A5D059EBA155788E9E42435B3BBEBC9A403ABA01E32EAF76" , $A2188C05649 = "363D33F317A4ABB353EBA312482D94D2E375C36A25E00D26581D3618CC66D02C2D056DAB48922A14C979454DC74E63D1FF0C" , $A0C88D01B03 = "5BF130EA8F9C80C9E1442C9EF8A7A2623642B1DC9F6667F02D10879754C1813896252FC2936FD1D8500BC22AB693224A6919" , $A1388E03C47 = "14DD88E0E9FDBB88B10AF47577C061AA837FF40D16E7E770BDFF1A0E1FEA80FFDDD4B68AD8C095414467C0A5CB5790110964" , $A3288F0621A = "F050D8909EECD9839EE3DDB0DA9D486D51B4B677B0CE2F10B87C3BC9AC9A0AD35F027D5836A1DA761EAA854DB2A216FB8DA5" , _
		$A4C98005F25 = "44E0FF9582B82082F046A034DE391F4E1B29A5E02B382CCEC1F9E0F701FCC772DA3DF77E0B3000185337EB4E6F5435000000" , $A3398104214 = "0049454E44AE426082"
		Global $SSA1F7090060D = 1
	EndIf
	Local $A1428704824 = $A5B78002A19 & $A2578104730 & $A5C78203C63 & $A5178301044 & $A1A78402B0C & $A2A78504A51 & $A6278602841 & $A1678705B61 & $A3678803852 & $A4F7890442D & $A4478A03B5A & $A1A78B05618 & $A3578C05D33 & $A5178D03963 & $A2678E05B42 & $A0078F0451C & $A3788003E1E & $A0C88103814 & $A5F88201501 & $A548830113B & $A5B88401C38 & $A3088506207 & $A3988601D2E & $A138870443D & $A0388804C2F & $A5388901821 & $A2288A01006 & $A5B88B0312F & $A2188C05649 & $A0C88D01B03 & $A1388E03C47
	$A1428704824 &= $A3288F0621A & $A4C98005F25 & $A3398104214
	Return $A1428704824
EndFunc
Func A3370A00736 ( )
	If Not IsDeclared ( "SSA3370A00736" ) Then
		Global $A2098202C40 = "0x89504E470D0A1A0A0000000D494844520000001200000012080600000056CE8E570000001974455874536F667477617265" , $A4B98300A5F = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A3298402B28 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A3698502C5F = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A189860554C = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A3898705551 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A3E98802746 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A1E98901114 = "663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F" , _
		$A0698A01732 = "2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D" , $A2F98B03A57 = "6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F75" , $A4198C01C3F = "726365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343203230313920" , $A2B98D05E2A = "2857696E646F7773292220786D704D4D3A496E7374616E636549443D22786D702E6969643A39413846454131353031334431" , $A2998E00126 = "314541384434304435414642313936444439302220786D704D4D3A446F63756D656E7449443D22786D702E6469643A394138" , $A5398F01C41 = "4645413136303133443131454138443430443541464231393644443930223E203C786D704D4D3A4465726976656446726F6D" , $A4FA8001908 = "2073745265663A696E7374616E636549443D22786D702E6969643A3941384645413133303133443131454138443430443541" , $A06A8102F55 = "464231393644443930222073745265663A646F63756D656E7449443D22786D702E6469643A39413846454131343031334431" , _
		$A07A8204253 = "31454138443430443541464231393644443930222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A47A830535F = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E2AD50E69000003024944415478DA94" , $A31A8402F39 = "945D48145114C7FF773F66DCF1DB155D57B3A028ECC12892E85132B1F0A388CC229FA2B097A20F88A2A008B1A88788024314" , $A43A850485A = "C2228DA0070B4C112CC807257BD01293A8545C575D775374C7993B339DD95D375D9468E03F33F7DCCBEFFECFB96786F55DD9" , $A2FA8605500 = "65E0FF2FB6FBCEA755019B79937237A3F7FB54DFCDE6DEBBBFA68323147290164972E4B9481BFA4FB77C3BD350B5F5C95A64" , $A59A8704F59 = "8B790B8C8FE244617E41575DC5A3430559C5145A8AC04C49A478739D9B0BF6F52C5ADAC432588201784686E04E4F773DBB56" , $A3BA8802A32 = "7EAF283FA384E6A6572E2C750FC22A315EC0FB5130D75FC96E30B0065223E93A0B3BD2AC7150167E63767404813915855B9C" , $A45A8900D62 = "7591B4962FC37B5E11DBCA7DF5A1918831E4C4382AF2B7CE719D51F9ACE07210FE89B158D7E66168B804F954E5D970C48A1E" , _
		$A5BA8A01B5F = "8C507C9834449261D814DD06A6E9D034039A6E405F7D861A8913C473F4E011EC90B6E162D50504827E580C06BBCD0E6EE168" , $A46A8B01D60 = "78D5049B611830A5EB3A7413C8D565888EEDC8C601BCAB2E3B894C47063A263A106713912048B05AEC70D84564276D0A1FBF" , $A27A8C0210B = "E98230E09A86382E2F7744189411AE84534AC387896E4CCA93906C1224BB03825520A84039ED8CF491CEA119541F6EE0AB92" , $A18A8D0150D = "864C773685A7CC393BBAF11189287DD0FAF0CDFEE27D4875A422454C86437040244702B97325BAC2A01ED7F1A43DE34FA946" , $A34A8E02A46 = "027C411DF3DEC5954516D186411C46496747577B4D750DEA9BEBB16E432A9C415535E4095E38556FEC1A01AFF1D9EA61C551" , $A3DA8F0240A = "880F15501007959A55A6A74E06F74EBC804C2085409CD3C90667D7DAD0AE65199D5751722B344A8193F04B947C90304B6447" , $A31B800312E = "0939E20451550E59E104D3A31FE6CA8F34C79500E5BD6FBCF6479E790C536BA6969E2C422588294DD556CEB1882C6397E7D1" , $A57B8102136 = "FE734031276AC7F3DE22402F7E2AE47D23A4D0628F6FF1D8C292A133B3BC4614A4440A2E90921863EE2F33724BD44223A929" , _
		$A63B8203542 = "C65196537A391754CFA9D4DD16239ADA0652AE6938BC373CD4B84A4CCA7FFF47250DC3CBEF8F9F576E4C4D8BB7DD8E8C5349" , $A34B830425C = "33A401022CFCEB4FF747800100D2523B44165C1F410000000049454E44AE426082"
		Global $SSA3370A00736 = 1
	EndIf
	Local $A1428704824 = $A2098202C40 & $A4B98300A5F & $A3298402B28 & $A3698502C5F & $A189860554C & $A3898705551 & $A3E98802746 & $A1E98901114 & $A0698A01732 & $A2F98B03A57 & $A4198C01C3F & $A2B98D05E2A & $A2998E00126 & $A5398F01C41 & $A4FA8001908 & $A06A8102F55 & $A07A8204253 & $A47A830535F & $A31A8402F39 & $A43A850485A & $A2FA8605500 & $A59A8704F59 & $A3BA8802A32 & $A45A8900D62 & $A5BA8A01B5F & $A46A8B01D60 & $A27A8C0210B & $A18A8D0150D & $A34A8E02A46 & $A3DA8F0240A & $A31B800312E
	$A1428704824 &= $A57B8102136 & $A63B8203542 & $A34B830425C
	Return $A1428704824
EndFunc
Func A5370B0434D ( )
	If Not IsDeclared ( "SSA5370B0434D" ) Then
		Global $A57B8404B54 = "0x89504E470D0A1A0A0000000D49484452000000180000001008060000000C24BF950000001974455874536F667477617265" , $A60B8500302 = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A45B8603E42 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A27B8702F4C = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A56B880022C = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A1CB890314D = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A0AB8A01801 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A55B8B03E13 = "663A61626F75743D222220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E" , _
		$A06B8C03F28 = "302F6D6D2F2220786D6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F7354" , $A58B8D04210 = "7970652F5265736F75726365526566232220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F78" , $A59B8E04C32 = "61702F312E302F2220786D704D4D3A446F63756D656E7449443D22786D702E6469643A374544303545454338374437313145" , $A3EB8F0185D = "42424144343843464644453036443343412220786D704D4D3A496E7374616E636549443D22786D702E6969643A3745443035" , $A08C8004427 = "4545423837443731314542424144343843464644453036443343412220786D703A43726561746F72546F6F6C3D2241646F62" , $A27C810091C = "652050686F746F73686F702043432032303139202857696E646F777329223E203C786D704D4D3A4465726976656446726F6D" , $A57C8202551 = "2073745265663A696E7374616E636549443D22786D702E6969643A4536453131353238383744363131454242323236444446" , $A1FC8301C3E = "344134453531353730222073745265663A646F63756D656E7449443D22786D702E6469643A45364531313532393837443631" , _
		$A37C8402019 = "31454242323236444446344134453531353730222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A61C850370E = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E9F1E85BD000003D04944415478DA9C" , $A30C8601910 = "546B6C5365187E4FDBB5A7EB39BD8D9DB15EEC751B6B81B1AE8D5BE910DC067117549269A782B0782320F8430403668826C6" , $A27C8704241 = "181309F187918418818498999088E30789EC0FA0A06142101021E1E2A46530766977CEDA3E9E9E3AB2A013F149DE1FE77D9F" , $A09C880202C = "E77DBEE77CC9C7F03C4F0D0D0D64B55A298FDEDE5E1204A168EEDCC0D61B83433D89E4C8908AD2DB7359E9F36C3627663219" , $A52C8902353 = "CA66B30A17004D07C330CA2C954ADDEBA9F2CD5C2E47A2282A848A0A3F793D9E133787353DE329917C8EA292B448BB2644E9" , $A2AC8A00F47 = "962849EFC81A333D0454922429AE06CEF092D96C3C581F5D7CE65A2213D24F9EA58D4F8ED1A18F4B69FBEBF3694474716369" , $A4AC8B0612B = "76472A9DBA2549E24E596BCB1FE84160BC5EEF9C552B577D3B9999F40C9C394F7D870ED2D3D10C7DB475018D4CA8E9D8F104" , _
		$A29C8C03C15 = "495A37A54496EC02431B3FBC447792BF13CB32A45633FBE415EFC97B2ECCF88B466F8F76DC1DBEEBD1EAB4A4D3E9A8D267A3" , $A2AC8D0354A = "5FAE121DFE2E49E3C319D2145BC95F92A02D2B476978649CAABD26DAD513A1128B89C6C7279E9F9CCC9E57ABD5FDF2AEC87D" , $A1BC8E03E53 = "575240B833B4277F5F8D91466CDEBC09AFAD5D0F674514551E01AD1115DE789607AEACC0EEF7EBF0DC520143DF37E3627F3B" , $A54C8F04146 = "CA4C5AACEDAA4253BD20AF5583E3381417179F63756C4DFEF2A78AD9F0E3ABD72FF6FD663FBCED08951B6DD4B2BC99B4AC86" , $A0FD8005007 = "4E9DBE44A77FBA4C94BB4E6FAF16A8660E4F3713297AAAA38A8EF65F21BFDF48D115618A86F7D3F1732269341A32180C4412" , $A58D810590A = "B3673875A7FB5E02C3A3EC67DDC9385E39F122CC3E533E249AA2CD8877C5116B8C41287342A72D42D0A757664BC23C7EFEAA" , $A55D8204D3D = "0E632797C26BD72ABDD252010EA70336B503E531E1EBE9090A60694DFD970BB0495A87C53B628AC8C13D82B627DA50595529" , $A18D8305C03 = "7FABE4D228E59EADC1DE0FE6C1EFE2149EC96C85DBE686935CB0B8CDA8FDC17FE3EF06059458DB8CC756279FC1CB175E80B5" , _
		$A49D8401635 = "D6AC2C08BA83080403309A8CD06A75E03903D42A469E1581E38DB0182D0A8F0BE9111EAC82734B59DF4C06536936C4F687B1" , $A5BD8505B14 = "1E6B10FD24AC882D64457545356CF672D9845512B17A1636C6016FCC8385E9F9782C570BDBBA59BFCA7CCBBF1B14E098D566" , $A3BD860440A = "1EE84CB6227E7539CA9B04C5C86E72C0ED76C1E972C25E66074B1C823D3E74A20542DC3AA01CEFAF27E441065369DE0C7D11" , $A2AD870152B = "4057B6038D7B23D0F01AE8C9000FEF859658F8DF72A1E57603CC51FEE874D97F3728C06B5A6638DB3AB808EDD71E4745B71B" , $A2DD880063B = "C6D93C429F06B16C6C21CC8BB86FEE173CACC1549A7703BBBD68FF63099A4F46D1782A04438DFEC03F51FF9F81F2B0501D3B" , $A30D890182C = "AFE888A589BFAC32A9B6CD449B6EF0A70003005C98E6B8587211A30000000049454E44AE426082"
		Global $SSA5370B0434D = 1
	EndIf
	Local $A1428704824 = $A57B8404B54 & $A60B8500302 & $A45B8603E42 & $A27B8702F4C & $A56B880022C & $A1CB890314D & $A0AB8A01801 & $A55B8B03E13 & $A06B8C03F28 & $A58B8D04210 & $A59B8E04C32 & $A3EB8F0185D & $A08C8004427 & $A27C810091C & $A57C8202551 & $A1FC8301C3E & $A37C8402019 & $A61C850370E & $A30C8601910 & $A27C8704241 & $A09C880202C & $A52C8902353 & $A2AC8A00F47 & $A4AC8B0612B & $A29C8C03C15 & $A2AC8D0354A & $A1BC8E03E53 & $A54C8F04146 & $A0FD8005007 & $A58D810590A & $A55D8204D3D
	$A1428704824 &= $A18D8305C03 & $A49D8401635 & $A5BD8505B14 & $A3BD860440A & $A2AD870152B & $A2DD880063B & $A30D890182C
	Return $A1428704824
EndFunc
Func A2070C05641 ( )
	If Not IsDeclared ( "SSA2070C05641" ) Then
		Global $A25D8A02E1D = "0x89504E470D0A1A0A0000000D4948445200000058000000100806000000929EB8350000001974455874536F667477617265" , $A5ED8B04B3E = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A55D8C04714 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A12D8D04614 = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A3DD8E02D17 = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A0ED8F01A38 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A25E8002C35 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A4FE8101426 = "663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F" , _
		$A0CE8201E19 = "2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D" , $A0BE8301601 = "6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F75" , $A02E840301E = "726365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343203230313920" , $A27E8502855 = "2857696E646F7773292220786D704D4D3A496E7374616E636549443D22786D702E6969643A36323843314433323837443531" , $A32E860381B = "314542413646373934434134334330363443332220786D704D4D3A446F63756D656E7449443D22786D702E6469643A363238" , $A36E8704F25 = "4331443333383744353131454241364637393443413433433036344333223E203C786D704D4D3A4465726976656446726F6D" , $A0CE8800652 = "2073745265663A696E7374616E636549443D22786D702E6969643A3632384331443330383744353131454241364637393443" , $A1EE8904033 = "413433433036344333222073745265663A646F63756D656E7449443D22786D702E6469643A36323843314433313837443531" , _
		$A50E8A04042 = "31454241364637393443413433433036344333222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A2FE8B04210 = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3EA01DEF99000000D84944415478DAEC" , $A36E8C0375B = "98510E823010443BD0E88737E1529ECD4B79133F348182891B84AC6D17A12161E6AB0DD9072CEDEC5284109C08C038896888" , $A34E8D01B06 = "41EC3A3923C77F05C1192471023B0AA76BE2F1D57DCAA91CB5A93C536093AC504B82B1F05E48CC77C5E96E89C45D33394DF6" , $A0CE8E04E33 = "07002DA280DE590ECA38592513C5809C4FDCEE3DF8D5C23D7E7447972107A73AEB9D2D1611E7E45B84A34514B288C9EA366C" , $A49E8F02522 = "01194BDF478EC2D9CC22D09EE30F513F0F61117E56E42C9AC791A370D84594EE22D6DADAB4883FFFE49493277214CEE22E42" , $A0BF8004438 = "39852247E1F4020C00DFF5FC112049D65C0000000049454E44AE426082"
		Global $SSA2070C05641 = 1
	EndIf
	Local $A1428704824 = $A25D8A02E1D & $A5ED8B04B3E & $A55D8C04714 & $A12D8D04614 & $A3DD8E02D17 & $A0ED8F01A38 & $A25E8002C35 & $A4FE8101426 & $A0CE8201E19 & $A0BE8301601 & $A02E840301E & $A27E8502855 & $A32E860381B & $A36E8704F25 & $A0CE8800652 & $A1EE8904033 & $A50E8A04042 & $A2FE8B04210 & $A36E8C0375B & $A34E8D01B06 & $A0CE8E04E33 & $A49E8F02522 & $A0BF8004438
	Return $A1428704824
EndFunc
Func A4E70D05132 ( )
	If Not IsDeclared ( "SSA4E70D05132" ) Then
		Global $A53F8106135 = "0x89504E470D0A1A0A0000000D4948445200000058000000100806000000929EB8350000001974455874536F667477617265" , $A0BF8203C41 = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A04F830163D = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A1BF840405E = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A2EF850165B = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A1BF8605D49 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A45F8703206 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A59F8804922 = "663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F" , _
		$A34F890283D = "2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D" , $A4BF8A03C55 = "6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F75" , $A50F8B0544D = "726365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343203230313920" , $A29F8C0170F = "2857696E646F7773292220786D704D4D3A496E7374616E636549443D22786D702E6969643A41433838333537393837443531" , $A1AF8D05758 = "314542393842423843443233354642323646462220786D704D4D3A446F63756D656E7449443D22786D702E6469643A414338" , $A26F8E02F36 = "3833353741383744353131454239384242384344323335464232364646223E203C786D704D4D3A4465726976656446726F6D" , $A1AF8F01823 = "2073745265663A696E7374616E636549443D22786D702E6969643A4143383833353737383744353131454239384242384344" , $A1B0900342E = "323335464232364646222073745265663A646F63756D656E7449443D22786D702E6469643A41433838333537383837443531" , _
		$A2209105F21 = "31454239384242384344323335464232364646222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A0C09201B10 = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3EBC11FFFF000000B74944415478DA62" , $A1D09300E51 = "FCFFFF3F031240E1E0018C04E447CD810216244D8C0CA401747D23C29C475AAC7835CB5DFB8D620E13C328A02960FC8F2823" , $A2B0940231C = "1849CC02F8627AD41CA85A1632B210AEF26A509BF36F02FECCCA54F08F287348282218478B88D12262781411831AF0A8EEC1" , $A3E09505C5E = "2BFFE5B60B51E6905044E0052414110CA345049D8A88D10E028D3B1AB4893946FC6E458BD8615B448CF6E4686CCE682B82DE" , $A280960443F = "AD086A65EDD1220251448C889EDC409933DA8AA0B13900010600D9218F26F26995470000000049454E44AE426082"
		Global $SSA4E70D05132 = 1
	EndIf
	Local $A1428704824 = $A53F8106135 & $A0BF8203C41 & $A04F830163D & $A1BF840405E & $A2EF850165B & $A1BF8605D49 & $A45F8703206 & $A59F8804922 & $A34F890283D & $A4BF8A03C55 & $A50F8B0544D & $A29F8C0170F & $A1AF8D05758 & $A26F8E02F36 & $A1AF8F01823 & $A1B0900342E & $A2209105F21 & $A0C09201B10 & $A1D09300E51 & $A2B0940231C & $A3E09505C5E & $A280960443F
	Return $A1428704824
EndFunc
Func A1370E00756 ( )
	If Not IsDeclared ( "SSA1370E00756" ) Then
		Global $A4709703F44 = "0x89504E470D0A1A0A0000000D4948445200000058000000100806000000929EB8350000001974455874536F667477617265" , $A2D09802D27 = "0041646F626520496D616765526561647971C9653C0000032669545874584D4C3A636F6D2E61646F62652E786D7000000000" , $A0909905F07 = "003C3F787061636B657420626567696E3D22EFBBBF222069643D2257354D304D7043656869487A7265537A4E54637A6B6339" , $A5309A05405 = "64223F3E203C783A786D706D65746120786D6C6E733A783D2261646F62653A6E733A6D6574612F2220783A786D70746B3D22" , $A4109B02239 = "41646F626520584D5020436F726520352E362D633134352037392E3136333439392C20323031382F30382F31332D31363A34" , $A0E09C01A52 = "303A32322020202020202020223E203C7264663A52444620786D6C6E733A7264663D22687474703A2F2F7777772E77332E6F" , $A5309D00A54 = "72672F313939392F30322F32322D7264662D73796E7461782D6E7323223E203C7264663A4465736372697074696F6E207264" , $A6209E01041 = "663A61626F75743D222220786D6C6E733A786D703D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F" , _
		$A4909F05E49 = "2220786D6C6E733A786D704D4D3D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F6D6D2F2220786D" , $A3B1900032A = "6C6E733A73745265663D22687474703A2F2F6E732E61646F62652E636F6D2F7861702F312E302F73547970652F5265736F75" , $A5519104843 = "726365526566232220786D703A43726561746F72546F6F6C3D2241646F62652050686F746F73686F70204343203230313920" , $A1D1920531E = "2857696E646F7773292220786D704D4D3A496E7374616E636549443D22786D702E6969643A45384438463346363837443531" , $A5019303454 = "314542413234443839333637384444393737462220786D704D4D3A446F63756D656E7449443D22786D702E6469643A453844" , $A1E19401F0C = "3846334637383744353131454241323444383933363738444439373746223E203C786D704D4D3A4465726976656446726F6D" , $A5D19504D30 = "2073745265663A696E7374616E636549443D22786D702E6969643A4538443846334634383744353131454241323444383933" , $A391960115E = "363738444439373746222073745265663A646F63756D656E7449443D22786D702E6469643A45384438463346353837443531" , _
		$A3719702619 = "31454241323444383933363738444439373746222F3E203C2F7264663A4465736372697074696F6E3E203C2F7264663A5244" , $A4419803A2D = "463E203C2F783A786D706D6574613E203C3F787061636B657420656E643D2272223F3E11905036000000C64944415478DAEC" , $A4E19905F54 = "97510E82300C86FB03D1076FE2A53C1B97F2263E680205094412D9EC980513FFBE10B2EC235BD38F1622A29211AA8AE71300" , $A4119A02E4F = "390B51092329DA737CBDB8BE5F30A6A4257E0B81777266FBE6B05580BE94642C257216385586833533C39B72DAFA43695F8C" , $A4F19B04119 = "1CBB22867D05ADEA1B6017E1DF45FCF44FE5D1406E81339EFA3B38946AE2242822CEB12B02540415C141239CB9E6183F4079" , $A5319C0553C = "37711214111F10EC8AF8EAA041456CA0080E08CE83864B6953112F07FFC524B717875D8433A7136000329BB1237EEA7D6B00" , $A5819D00450 = "00000049454E44AE426082"
		Global $SSA1370E00756 = 1
	EndIf
	Local $A1428704824 = $A4709703F44 & $A2D09802D27 & $A0909905F07 & $A5309A05405 & $A4109B02239 & $A0E09C01A52 & $A5309D00A54 & $A6209E01041 & $A4909F05E49 & $A3B1900032A & $A5519104843 & $A1D1920531E & $A5019303454 & $A1E19401F0C & $A5D19504D30 & $A391960115E & $A3719702619 & $A4419803A2D & $A4E19905F54 & $A4119A02E4F & $A4F19B04119 & $A5319C0553C & $A5819D00450
	Return $A1428704824
EndFunc
Func A2B70F04352 ( )
	If Not IsDeclared ( "SSA2B70F04352" ) Then
		Global $A0B19E05A50 = "0x89504E470D0A1A0A0000000D4948445200000040000000400806000000AA6971DE000000017352474200AECE1CE9000000" , $A2219F00900 = "0467414D410000B18F0BFC6105000000097048597300000EC300000EC301C76FA864000012FC49444154785EED590B58D465" , $A3C29002408 = "D61F6086CBCC30F761181818EEC36D0081E18E5C451010110191AB1740402E02DE52D7D4B48BAE97B6FCC2A7D2CC67DBDA76" , $A1E29101738 = "ADADDDACCDACEC73BBAD595A7677CBF4CBFAAACDCD5AD3FC7DE7BC0C649B5F4F5F599B7D9CE739CFCC33FE79DFF7FCDEDF39" , $A2029204613 = "E777FE4AC66CCCC66CCCC66CCCC66CCCC66CCCC66CCC7E086B6B6B930706066A8B8B8B55CE9FFE7F58737373644E4ECED0B8" , $A4D2930615B = "71E3DE8E8989F9203232F2DD8484845DD9D9D945CE477E9ED6DADA6A9E3871E2060AF4745A5A1A0800C4C5C5213A3A1A0402" , $A6129405239 = "6C361BFB63F45B150057E79F5DFEB663C70E456565E5A2C2C2C2F7F2F3F3919E9E0E87C381C4C444D0CD2336365680101A1A" , $A1629503329 = "8AE0E060040505F1E701BBDD3E67606040E15CE6F2B4909010754A4ACA812953A6A0A0A000E3C78F170030039292921068B5" , _
		$A362960345C = "C2E4EB479FC18888B00910020202E0E7E737E26FD06F8365656506E792979DC9333333CE949696222F2F0F94FB0288A4E464" , $A2029701422 = "0405870A066465A5232ACA063F7F0BFC2D818201168B05BEBEBE301A8DC2CD66F30962C5EAE4E4E400E7BA3F6D1B1A1A92CF" , $A002980250C = "9D3B37ADB6B6F60EBABD2F8A8A8A505E5E8E89138B11136387352818A9C9B1A82E89C0D53D36AC1B8C4763653C9213631110" , $A1829905A2D = "184837EF2F18C0C1EB743AE8F57AE1F4FD2302E6FAACACAC68E7563F0D5BB06041415757D78354E80ECC9933E799868686B7" , $A2F29A02418 = "6B6A6A505D5D8DAAAA2A4C9D3A15A9A96974AB44F74033C63BFCB1A0C107CFDC9184738726E1B30393F0C2EF33B0BEDF8EAA" , $A3129B0094C = "29F9941EC9A21EF8FBFBC3C7C7075AAD56B8B7B737944A25341ACD1993C9B4938A679AF308FF1EBBE28A2B52A850EDEAEEEE" , $A5C29C02D3E = "4647470766CF9E0D6A73A8AFAF0781000621233313461F33BCE9E091211AD44F50E09E8D369C3E5886D776E76263BF1577AC" , $A5629D06032 = "F4C1B9571BF0C90BD3B170961D932B2A5032A91429045A585804B1C10283C108854201B95C2E9CBFAB542A66C91F088809CE" , _
		$A0C29E00755 = "23FD38B666CD9AC8A54B976EEBEFEF3F4F8EF6F67611FCCC9933412C10006452E07ABD016E6E6E30EA3C909F20C59685BE78" , $A5F29F0345D = "FF2FC538F5743EFE70AD1E6D9315682835E1D6C56A7CFEDA4C9C7F730EFA1B2390935B80094525983CB90293264DA4A2E9A0" , $A4F39002D0B = "566923061190C4024F4FCF5110468030180C7BAD56EB546AA12ECE635E7AA3C5DD56AC58B1966EFE340180DEDE5E7476760A" , $A3339104808 = "0038F0A6A626509F8796F2961FF7749720CA22C1927A39DE7C281B675F9C82A76E0DC5A1ED161CB937054F6D8BC2915D89F8" , $A2539201C54 = "ECF9321CDD5B82351D564CC84B466E4E264A27A6A2B5D68E0D0311D8B4C08EFAAA34A43892A853848902A956ABBF06048343" , $A0939305552 = "A9F2D7B0B0B0D9744EF9F0A92FA1517E6F58BF7E3D162E5C88F9F3E7A3A7A76714004E016E6FF4987017170992C32578F4D6" , $A5D39400B2B = "68BAD91AECDBE14077A50C37F7BB021F2EC66B0FE460E76A2BB6FEC286A5B30331ADD08C82AC08541486110B82F19B6B63F0" , $A4339501A3F = "CAEF1370E6A53AE0BF5A71FD401872F372909E9185587B1C15D2104A2D5FBA7D35BCBCBC4681E04F2710AF513719A016AC17" , _
		$A5039600E46 = "87BF14462AED192A78E0DB670038F71900D2F522050820A2EC2451B8E87101C06FD685A07B9A37828C12E4C74BF0E6037938" , $A0939705361 = "77AC0B9D93A588083120D6E6839C64039A26E9B0712008CF5261FCEFC7C7E39DDD897879A73FCE9FE8C75B8F9460E6945038" , $A3C39805C4E = "521CD44253A8A0A62239C98E285B30AC8101623F6604077F21105C30E9F7E3544C57911EB10C47F13D8C16BA99951BE73AB3" , $A3E39901341 = "801940ED4E00306BD62C9102FCD9D8D828D8E0AD940FB3815CEA26C1B2062FE0FC4A3C7CA30D8E0809C6C77961698B160F0F" , $A2F39A0481C = "C5E2C4A385F8705F16F66D8FC7FA5E3F6C1F74C1A9176AF0F703D5E8A93650C07174F309484AA42299E78F5FCE33E2FAC100" , $A2739B02D49 = "948CB75067B1100826D12AB91E5C0C08726EA19B4888450E47F31DCCA43175733BE2F6545252220098376FDE68016400EAEA" , $A1239C02E49 = "EA40FD1F3366CC10452C2CDC06898B9B00A2B35281230F646043BB2BB62EF5C71B0FE6E0CC731381E39DC06757E3E06D4158" , $A4939D01009 = "D928C1AA1617BCFF640531A503CB9BB5888B09852D320AA98941E89AAAC293DBA3282DFA817F2CC0FA2E230140EDD264269D" , _
		$A4A39E01454 = "A0A71649ED52A58142E93D5A1B2E04825AE83F4958ED888A8A4A1D8EEA5BD84865ADE9ABBA8A2B3BD38D81603DCF373E8F52" , $A0739F02F59 = "A1A5A545547F0660DAB46960F95B41ED8C35406E6E1EB53233BC6412046925B8B6558E638FE7E1EE5F466156B10CEDC512EC" , $A534900005F = "198AC1176F77E1FDFD65786F7F39F0D102FCAACF007B941911E141284ED7E03F06F5F8FBB304CCEBB328F8CD3875B00E7505" , $A2B4910214B = "7291021AAD919CCFA621E65167F0568EEA0605FB0540F0A7B385DE4B40148820FF371B99CCF69DDFDBB7E66FBF8097DA0B06" , $A284920262C = "DA48A7D5D1064AA1DD2BA654101B7A05081C3C8B1F0680542068DE1FF5F88444A8083CB55C8210AA093A8504324A0D190163" , $A0149301757 = "0F9460A84B82CFFFD6475BDE806D8B8D080F90223A54838E7277FCF5CE44E0BD0EBCF1C70C3CBF3D90005A4A801861F5D750" , $A5749404644 = "D7D1C3ECA3863DC41DD3B224E8AF96A228C90D068DEC6B9DE2624090A8DA75D1C18B6F1E27A17CECF6C7CC3BCFDEF6FA56FC" , $A3F49501650 = "0A5E560FB87BBA436FD0C3406CE005D46A9598F0B820B273F0ACFFD9690416FA3F97E6009E07B2A84D868484412AF31CED18" , _
		$A0F49606032 = "ECD10112ECBD291238B3067BB64420DE2A4102F9A6796A9C797506CEBC3E13B72DF7C5B65E09CEBED34B6D750205E9828840" , $A384970075B = "2F4CA060AF9CA5C6234391F8F0A9C9C0A72B71ECE14CC4D1DFF3DA2E2EAE7097B97F0D04F691D4200D3144CF7ED54E9E3CA9" , $A2249805348 = "3C7AF468D07D373F183BF052F7E17B70275AEF6A81DC9F8A1BF578B5514D200CEB7585422EF47B4D4D2D162D5E84E9D3EBC0" , $A1349903B14 = "E32F8DC1E29327C18C8C0C51C179224C4C4C12CFB350A2AD901323C1C7CF4DC18BF78D47599204330B2578EE77E944F53E3C" , $A4849A03C5C = "FDDB6CD4644A509A28C1ABF7A6E3F31303B8A547822BA8A8EEDA60C3F1470B70EA2F85A42E6BE8CE6EA7FA301FD7751A6050" , $A4349B0251A = "7D09303341A4C345006027EDF0CA48AA8F1AFD20DFBF7F7FE2A1FB0FE5C5F4D8FEDCF0543576602BD6BEBD02E3A6C743E221" , $A4F49C04A4F = "818766840D46511B14B4184D6DA24BB04AE4DBE7C059208DBC0BE097213C09720DE117215CB8D4940E69D4199243593851B7" , $A2649D06058 = "38D68833476751913320CC472282B971BE0638BB91BA43338EEF4EC52707CAF0C6EE1CECD9EC8B2736EB71E69D41FCE3E526" , _
		$A0A49E04521 = "2C9AE606BD72588BB8BABA89402F16FC487AD0D84E1369D4EF9C617FD50E1F3EAC3BB4F7486E6E47F69F142D32646C4DC2DA" , $A4549F0254C = "B3CB7133A543D3CE3A68C3350208B591E428A5849EF2911725692A0AE2DAB56B4571E460F91D0003C0C1DBED76F122843616" , $A1259001027 = "6EB10440E62E872B1D7A5A8E3B6E591D82296912A8BC866F504F003D72938D44D402BCF650116EBB3218734AA5E82A9260DF" , $A4159105015 = "160B7591B578F7E92A34E749A0F01CFE1BA9542602BF58F01E1E1EDC11C40B99409A402D1E81F344C0173362827BFBAA392D" , $A625920120E = "D66E3354CD9EB0F69B31FB403D86B01157BDB70C8ED94990D001DDD532E88C3AC1065E9C3789A540493A63D9B265E27D00BF"
		Global $A3959304561 = "FEE25761BC317F0F0F0F172F428882F035FB0DDF8C871BDC685B57D72F292CA7A092C224A8A254E0FA10A097A08E0ADEA1DF" , $A3C59404A3C = "3AE8781B70E48F792245DCA9A0F2F3EEEE1EA2488F04CC6A91CFC32E954A45E748A234F4A734D4E9754859396E15C7FA8D56" , $A5E59501B58 = "B034BB36ACD772D2D0A182B65181DC5BD2B1E6DC526CC17AB4EC9A01835D2FD8A0327A0B36B0F3E67C03DC1168881233434C" , $A1859602125 = "4C8C187799FE0C00BF0461C0E4744885826ECC5B050F4FAA3354BC685BE14CE791EF7A4A87CE12094E3C514AC16FC413DBE2" , $A5A59703E4B = "9141AAD38D3A8A44E242D4F61ABD750E983F3960DE936F9BF774509A8AF6A9D442E7AB43D60709A8389B3F85D6FF66EB58D1" , $A4759805C10 = "11621F88BACF7FBE11AA464F840D06A2FD60336EC43AACFA7809D2E739E0A272814C2325366861D05191A496C907F1B75804" , $A455990365D = "00AB57AF1692995B28BFFDE17ECD3734725BECFC1B7718CE53171797D1E055D44297352A71E6CD56E08B6BB1EB1A2B62FC9D" , $A2759A0150C = "0011609C7E7CF3FCC96B72C09C6A8E9414D223B9D4B227233B870636D2313A8D8ED6A3CB74A850886414BC9FF62711E4B7B1" , _
		$A2E59B00E2B = "ACC5E93D41DD9653FAB94AE8E84045DB7270D5B965D88CAB3173773D4C49340F106DBD7D94A36CE0801888F8F8040C0E0E8A" , $A5059C05620 = "D9816B052DF795E02FF411312393C9C473062A6EBB3787E2ECBB5DD8D2AF45906118185757293DFF65BE3370CC304E33DE83" , $A2F59D03F3A = "0BB45241EA504300E9E94CA465547A6FB8B9BB216CC88249C840DE9194ED1CDBB7B686150DB1B183B63DFEF369B1060F440E" , $A3E59E00A12 = "86A0F3F9D944CA3558FEE9203217A6C24DEB0AA95A0AAD0FB3818A24E9753E201F68C2840942467351E400DDDD2FDEABD919" , $A4259F02209 = "08BE5585171DD88F062BBB0446679B93528FBFB0D0F1730CB625C0024FA5E7E805F0FE5A5F0DF454A7BCB54AB87BCB107483" , $A1169000925 = "2F0A9084D467ED886C89982302FBBF18F7CECC45A98B837B7D3FD3CD55C0D0A8C2A46D8558757609AEC172343D5E03738649" , $A3969100C12 = "B04169548C0A28A6201F9404C8A870E2399F758108F482E0479C8364203C3CBE1451FCFDC2E0479C9F93CAA49019A4509948" , $A0C69206036 = "AC5197529929ADFC89055A393C0CEE88B83300D9B023EEE130F855FB20B132315104F55D6CFA8AAAE4E8FEF0FDE6F97A78D7" , _
		$A1B6930523B = "7B2066301C9D0767612D9662E0F3B9C85C91220EE3A67283C6A411B7C1403013F8B0F1F1F1343B4C16AD9201F826362869D0" , $A3669403049 = "91CB872BFBC5826767E567301AE06D55C2CDC70D52BD1B3CCD1EF0D47BC0CBE289D83F072307F188B92718C6A95A04CE30BD" , $A1269505123 = "BD62DB0A4F6738DFCD7017DCD31624AFB276FB9DD5B693166850A3625B09569E5D4C30F462FAD353E09FE72BD8A030CA890D" , $A0869605E2A = "D4329D69C120F05B60164D2C9EB840725AFC6B71BCD02F163C03C36D8EC54D4A722AE43492BB07C9A04A22564451EAC52B91" , $A286970023E = "78D0863C8C43D4CE2018266B10D8E8F36956775AB1338CEF6F55CB2BB2A37B830F98FB28D7880D8E45F15878A89712A21F5D" , $A2B69803E1F = "6841C6B5C9F0F095C155E90AB589E4B4930D9C162A95B7688B2C9D5931722E7F131B2E74068B41639D919599059D5287884D" , $A3369904922 = "41C83C11879CCF1291F7A103E33F1947C19302BDC92A820F6A317F94372F3BDF79F44B67C7878ECB5306C7ADB7F69ACFABDB" , $A5569A02450 = "3CE1D764C0D46DE518F86727C1D086DAE7CB1130C94FB0C1CBE8392CA09C6CD0505A3018DCBE583E5BA99571F7F82636F0BF" , _
		$A2069B01A3C = "B12726250AB5A99213B06603F24E537BA316970F074A9045DF1D085B1740C1AB11D2ECFF6EE5FCF21FF6D57AE5F2F209B6BE" , $A3E69C05B53 = "E0177DFBB4820DB1FD11687E663A06D08E0E3422EB8614785A3CE0424A5265F21600301B78C0E2FAC08571DCB861E9CC6289" , $A5469D01713 = "D9F0AF4592C151ABD4A29B4445450AD6683DB530251B917FCE41C1276322B5B9A2D3E908B9D2027D851A613303DE6A5A323D" , $A0D69E03833 = "CE79CC1FD6766DDBA5710CC6DD68ED3343DB46AAAC4183C2A1F1E83A3D0B7D988DDA57CB115465116CF0D0BB432B04D4301B" , $A1269F06323 = "98091C38AB380E90BB0607CD79CECE60B0A26375C9A28741E3BF959392F4ADD453E0E922F8C28F5211B4D00F864A0A7EB6F5" , $A287900404D = "D5C6158D11CEE3FD78567EC5A40ADBFCE037B836A869E2B3F585A0EEC929E8C12C4A8A19187F2B15AD60AFE19669520EB361" , $A457910521F = "242D08042E923C37F048CDFFF152595929D2248C7EF331F9404B5325BFB152FA1040A417EC37456032D5FABC77531030CF04" , $A2079202C5F = "439506B6D690E7DA16B5053A8FF4E3DB962D5B7C9206E2B605CEF785AE4D0963BD1AE3B7A4A2F5E31954209B507BAC1CA18D" , _
		$A2679304D59 = "5648680A946965D0F87CD932392D1808BE715678EC26936958D692DC66A0E4D45D645A29126F8A463DCA517434137E738C30" , $A4A79403F2B = "56D3E4D71EFE9FEBD6ADF3711EE5DF6BC50B274C0FEFB31EF3253668EAE508ED0944E51325988B06B4623A72EE4C83B74D21" , $A4C7950363A = "862B85492E26B611368CD40776FE2E7EA396EAA5F78487C91D69772750F0652878290DE646038CB51AC4CCB53DCCA9E8DCFE" , $A0679601F49 = "A761D75C738D25A13FFACEC07E13F46D3441CE5023F5FA04347E309580A847EDFB65086F0B16A3B654CD026A38BF99E61C34" , $A4F79702856 = "3B3383D5A5A7C643A44FCE9E1471F3D9CF248AC07DEAB4886D8BB8EFF8B3C72FFDFF145D2A2B5894372BACC77292D9A06D50" , $A2279801F0B = "C0DAE587924773B93C92D720FFFE74A8E3BC21A1595F61203650CB1C01806FDE93BA802A8606B2E7B344F0697BE361984A1D" , $A6379905316 = "A4418F71AD71BF26B92E736EF5D3B5C1D583A1F10331F706101B0CED2AE867A890B0310A35EF95524AD4A2F65419A2064285" , $A2E79A02432 = "A475F174815441B2DADD1512290D45B93A94BD952F8277DC1F03FD6495A07E4A57D256E7F2978FE52ECAEE0AEDF3FB88D9A0" , _
		$A0879B05058 = "6B50C2D26942FE9E7434632AF58A6A94BE9C87E4CD76316B442D0E43E6DD495431CA50479EF0EB48E8CABCE1D74C927A9E63" , $A5179C02F49 = "9373C9CBCFDA57B447DBFBA21EB2F4FBC0D8A6166C885E1F8A929773484857896ED149226A0EA5070353763C1791EB83A12B" , $A2579D02A01 = "F7867FB30F323B52D73897BA7C8DC7EC9C45190B427A2CA7990D8626158C24A06C4B8391797332B2EE7220F9563B229607C1" , $A3479E0005F = "54456CA19B0F98E98B9CAEEC25CE257E1ED6BC7C46526C9F6D1FB3C1D44A0AB196E68472257425DEE4542B4AA933508F0F6C" , $A2C79F00E0B = "F243717741B7F3CF7E5E866721CB5C98B624B4C372D2BFCD07BE2D7AF836EAC8F5F06F3421AC29F095B29E922AE7E33F5FBB" , $A5A89000136 = "EEBAEB7C8B060A6726B526DC9038C77EBB63F6B84DC5FDC5D587EF3AAC743E3266633666633666633666DFD72492FF01A5E2" , $A0D8910414F = "A7D3E51FC55A0000000049454E44AE426082"
		Global $SSA2B70F04352 = 1
	EndIf
	Local $A1428704824 = $A0B19E05A50 & $A2219F00900 & $A3C29002408 & $A1E29101738 & $A2029204613 & $A4D2930615B & $A6129405239 & $A1629503329 & $A362960345C & $A2029701422 & $A002980250C & $A1829905A2D & $A2F29A02418 & $A3129B0094C & $A5C29C02D3E & $A5629D06032 & $A0C29E00755 & $A5F29F0345D & $A4F39002D0B & $A3339104808 & $A2539201C54 & $A0939305552 & $A5D39400B2B & $A4339501A3F & $A5039600E46 & $A0939705361 & $A3C39805C4E & $A3E39901341 & $A2F39A0481C & $A2739B02D49 & $A1239C02E49
	$A1428704824 &= $A4939D01009 & $A4A39E01454 & $A0739F02F59 & $A534900005F & $A2B4910214B & $A284920262C & $A0149301757 & $A5749404644 & $A3F49501650 & $A0F49606032 & $A384970075B & $A2249805348 & $A1349903B14 & $A4849A03C5C & $A4349B0251A & $A4F49C04A4F & $A2649D06058 & $A0A49E04521 & $A4549F0254C & $A1259001027 & $A4159105015 & $A625920120E & $A3959304561 & $A3C59404A3C & $A5E59501B58 & $A1859602125 & $A5A59703E4B & $A4759805C10 & $A455990365D & $A2759A0150C
	$A1428704824 &= $A2E59B00E2B & $A5059C05620 & $A2F59D03F3A & $A3E59E00A12 & $A4259F02209 & $A1169000925 & $A3969100C12 & $A0C69206036 & $A1B6930523B & $A3669403049 & $A1269505123 & $A0869605E2A & $A286970023E & $A2B69803E1F & $A3369904922 & $A5569A02450 & $A2069B01A3C & $A3E69C05B53 & $A5469D01713 & $A0D69E03833 & $A1269F06323 & $A287900404D & $A457910521F & $A2079202C5F & $A2679304D59 & $A4A79403F2B & $A4C7950363A & $A0679601F49 & $A4F79702856 & $A2279801F0B
	$A1428704824 &= $A6379905316 & $A2E79A02432 & $A0879B05058 & $A5179C02F49 & $A2579D02A01 & $A3479E0005F & $A2C79F00E0B & $A5A89000136 & $A0D8910414F
	Return $A1428704824
EndFunc
Func A348000001A ( )
	If Not IsDeclared ( "SSA348000001A" ) Then
		Global $A318920374F = "0x89504E470D0A1A0A0000000D494844520000001400000064080600000086AB10CC0000000467414D410000B18F0BFC6105" , $A1F89304111 = "000000206348524D00007A26000080840000FA00000080E8000075300000EA6000003A98000017709CBA513C00000006624B" , $A1189406055 = "4744000000000000F943BB7F000000097048597300000B1200000B1201D2DD7EFC0000061D4944415458C3ED995B4C14571C" , $A4C8950134B = "C6BF999D591616045C29C2EE8210450AE2A5540254A580050D9626486CEBAD0FA2A626246DA38DDAA47D682AB6B5D1F44153" , $A5E89600725 = "AD0F35D2D658DBA85804D970D98A37F002C86D0514CA0A42A1B00ABB3BB3337D685859667677166A631BBE27CE9CF9FFF63B" , $A0D89700439 = "FF739B7300FE2D8D1E3CC8BB2A3B13F9ACC0FF9888B13F4A8EADE109B01E05F30489CCBC5F89F1CF283B9992F3A9596B098A" , $A3989805B0E = "A224C1589641F9F95F04CFEDD10CAFE0CACF9E9279E2D0467AF34E81330B7B6551B9B9F0319B25C146BCBCD07AE60C31F1B9" , $A2489904C01 = "432F73030392DD717D7DD010C450676A6A6F676A6AAE00A8E6B877D8B6369354206330B0BCCD761EC0DBDD24795A002448B2" , _
		$A2D89A04651 = "98EDEC5448CE5F4F0F089ADE43709C52B4C95A9DAE8FA0E99A27369BDB81FB98617890E4759E61B278923CA961D98DA239E4" , $A4489B03A19 = "47463E35141713EE80F74A4A089E61BC006C07F0BAB6B2B25014A8ADAC2CD6C86455A6BE3EAB3398E9D123AB46266B04F0D0" , $A2F89C03146 = "D4D4B434ACBCBC6A7CBDC04D574ACA9CDF29AAC395430DC34442A1E8D296960AA696605A104AE55E582C58BC668D28EC7651" , $A0189D0102B = "1120977FA02D2DCD17AB1738BC929E2E693549D2E9DCE67A5AD39228FB582A3DB66A4ABB59C6D68B043061A6BCB676C3A460" , $A4989E05607 = "97CED8D786A78B0345D3E8EF317A0CEBEF3182A2697BD9EE90651818EA6FE181A109F317C6C3D73FC025E889690886FADB78" , $A5489F05434 = "621A02CB304287009098BE1AC19A70D4EA7568B8510DAB45B86131560B5AEED4A0A6F212025441485AE9B88838E490204968" , $A1B99002837 = "22E622581D868EE606545F2A42F8DC68A823E60100BA3B0C7870AF19A1619148CEC8062D970B7E507457A7E572442D7C099A" , $A369910021F = "C879686FAA4775E93900C0AC1035125ECD848FAF9FD354B8FC4CF0F1F5C382A5C91E7592DBAF2F4FF5FC031D72387EC44F6B" , _
		$A2999200E04 = "5ACEE576F7AF4E4B53D372F9511E50D8CCE62D491515F7DFCB7E99078043E76A04F14EE7724D7C3C6D53A93EE479FEA3C039" , $A0C9930470E = "110A02405F7B5BD3F58C8CCF7EE407C039B1220ABC969EBE9CA5A8130ABF19A1E18B16CA15BEBE00009546AD7850DFF071F6" , $A0C99403243 = "9F1CAE528FDD37B93A3373A60C3804825CA78E8DF152A9D50021B432D4DB8BFB7575206DB6228E65F31275BA5E01F0CACA95" , $A0199504B41 = "EF1224F945A036CC5B1D3D5F26737300B2B12CBA9B5BB8C1AE2E336CECAE449DEEB023303D9D9FBF7C39BCFDFD3DEAD5D1A1" , $A1099601A09 = "21B4E8F5F6CF3B071B2D7ABD4730B739DC79F8377EFBC6573C027C73F2320EEC5866E7B83D2956EFCE722827EFBFE0F27D49" , $A349970433D = "0BECE6F539D8BC3E4792E3E77F0B78B67B0A00B4F68DB80C70572F009697DC7228C70138F1FDCF4EEBA7F51F90CB3DE5EBFC" , $A3499805641 = "D55E2A823E04E04D80186618769F4FBFCFF175A74FDB9CC5B85C1C824879814A1590979C184FF5F70F06DE6D361C31298752" , $A5B9990365A = "006C98141024B78D6158EA625915CC660B284A46723CF1D6A4818C95536A97A811161B0EA5BF371AAA9A505771D7E5747559" , _
		$A2099A05D56 = "E91BCC61C18A58F807CD0025A7B1286D01FC66BB3E70B904FA8751552D776A2D63E5963BB5167F2D553569206719DD64EC6C" , $A5E99B03F57 = "67870707303CF8078C9DED2CCB5B36BA8A111D36BBBFFC56D24172FFAE3CE99F22053BB7B884ED39705C5A93B7ED917E692B" , $A4C99C02E42 = "F62E35BEF268C1FBF6263873E00C3C164B4DAC000065E00B9240030326814BD11C76B5B549763751825ED21FC9B52D49584C" , $A5099D01318 = "1284FB9BA8DAAB37B16287E33DACA05378F053BA7B1034592693D5DEBC762B414AB04C46DE9CCA8F4F4B5CF62E97BA2000E2" , $A3E99E03A5A = "8BC2981C7AD9DD8200B89F92E45482DD3A14838C2F4B69810058B0730B4AF435981D34138BA22371B6AC1A368E434EC6B2C9" , $A3D99F01F25 = "390480B8A808FC50548EAAEB75187E3C82FCCD6F00000ACB5AD1381882ECBD17041D786E5F16210A345BACB0B22CD4C1B3D0" , $A2BA900455A = "D669849FD21B5F1DFF0951B14928AD7D88C4A404D014ED10A3D75F76EEF0F3A3A7302B7006E2A2229093B90C729A4261592B" , $A2BA9101C5F = "4A6B1F223A36560073DBE44FF2373994C7C396842BB12ACE1B17EB47D1D02DFEFF0797C366A2B398501AAD3D0C62429DBB74" , _
		$A4CA920432C = "703871C8340E86D873E6EB45222440866395266C4DF1839F8284C9CC39078A4DA7ECBD17F8B19CC584D2B0B2C08EB419B0B0" , $A52A9300412 = "3CA24368DCE8B03807BAD38BA1342A5A46D164FCBBC94B23BCA606FCEEF2D32B81462383462323FADEB33F494DD4F841FBFF" , $A25A9402D19 = "D05F31D4457C8CFDE4C30000000049454E44AE426082"
		Global $SSA348000001A = 1
	EndIf
	Local $A1428704824 = $A318920374F & $A1F89304111 & $A1189406055 & $A4C8950134B & $A5E89600725 & $A0D89700439 & $A3989805B0E & $A2489904C01 & $A2D89A04651 & $A4489B03A19 & $A2F89C03146 & $A0189D0102B & $A4989E05607 & $A5489F05434 & $A1B99002837 & $A369910021F & $A2999200E04 & $A0C9930470E & $A0C99403243 & $A0199504B41 & $A1099601A09 & $A349970433D & $A3499805641 & $A5B9990365A & $A2099A05D56 & $A5E99B03F57 & $A4C99C02E42 & $A5099D01318 & $A3E99E03A5A & $A3D99F01F25 & $A2BA900455A
	$A1428704824 &= $A2BA9101C5F & $A4CA920432C & $A52A9300412 & $A25A9402D19
	Return $A1428704824
EndFunc
Func A1880105C32 ( $A5A31B00E55 = $A59A0605008 , $A23A950465D = 0 , $A04A9601A15 = 0 , $A00A9706139 = - 6 , $A5FA9802238 = - 10 )
	Local $A32A9905A46 [ 2 ] = [ - 1 , - 1 ]
	If IsHWnd ( $A5A31B00E55 ) = 0 Then Return $A32A9905A46
	Local $A4FA150630A = WinGetPos ( $A5A31B00E55 )
	If IsArray ( $A4FA150630A ) = 0 Then Return $A32A9905A46
	$A32A9905A46 [ 0 ] = $A4FA150630A [ 0 ] + ( ( $A4FA150630A [ 2 ] - ( $A23A950465D - 6 ) ) / 2 )
	$A32A9905A46 [ 1 ] = $A4FA150630A [ 1 ] + ( ( $A4FA150630A [ 3 ] - $A04A9601A15 ) / 2 )
	If $A32A9905A46 [ 0 ] < 0 Then $A32A9905A46 [ 0 ] = 0
	If $A32A9905A46 [ 1 ] < 0 Then $A32A9905A46 [ 1 ] = 0
	$A32A9905A46 [ 0 ] += $A00A9706139
	$A32A9905A46 [ 1 ] += $A5FA9802238
	Return $A32A9905A46
EndFunc
Func A0D80205E4E ( $A0361505653 , $A15A9A03C5A , $A10A9B02A19 , $A61A9C0073F , $A0BA9D01202 , $A57A9E06007 = 0 , $A49A9F0341A = - 1 , $A2BB9005A4F = 655566 )
	Local $A4CF1401813 = GUICtrlCreateLabel ( $A0361505653 , $A15A9A03C5A , $A10A9B02A19 , $A61A9C0073F , $A0BA9D01202 , $A57A9E06007 , $A49A9F0341A )
	GUICtrlSetFont ( $A4CF1401813 , $A6301F02853 , 400 , 4 , $A2E01D02B1C )
	GUICtrlSetColor ( $A4CF1401813 , $A2BB9005A4F )
	GUICtrlSetCursor ( $A4CF1401813 , 0 )
	Return $A4CF1401813
EndFunc
Func A2480301717 ( $A2AB9102C1C , $A14B9205B5B = - 1 )
	If Not IsDeclared ( "SSA2480301717" ) Then
		Global $A3EB9302132 = "\Control Panel\Colors" , $A10B940354F = "0x"
		Global $SSA2480301717 = 1
	EndIf
	Local $A2BB9005A4F = StringSplit ( RegRead ( $A3201805C5F & $A3EB9302132 , $A2AB9102C1C ) , Chr ( 32 ) )
	If $A2BB9005A4F [ 0 ] <> 3 Then Return SetError ( 1 , 0 , $A14B9205B5B )
	Return String ( $A10B940354F & Hex ( $A2BB9005A4F [ 1 ] , 2 ) & Hex ( $A2BB9005A4F [ 2 ] , 2 ) & Hex ( $A2BB9005A4F [ 3 ] , 2 ) )
EndFunc
Func RM_ShowAboutWindow ( )
	If Not IsDeclared ( "SSRM_ShowAboutWindow" ) Then
		Global $A58B980633A = "Translator" , $A3AB9906354 = "Unknown" , $A51B9A05924 = "Unknown" , $A08B9B0322C = " @SW_DISABLE " , $A54B9C0103C = "GUIOnEventMode" , $A30B9D04525 = "GUICloseOnESC" , $A4EC900500D = "alogo.png" , $A41C9201F3E = " @CRLF " , $A14C9301E35 = "WindowText" , $A11C9400D0C = "Copyright @ " , $A49C950484F = "  All rights reserved." , $A1AC9603334 = "ainfo.png" , $A54C970093F = "Donate:" , $A3AC9800F32 = "Contact Page:" , $A4FC990340F = "Home Page:" , $A1AC9A0165A = "Author:" , $A59C9B00B16 = "Translator:" , $A2BC9C04405 = "HotTrackingColor" , $A3BC9E0345F = "" , $A30D9003F1F = "" , $A59D9201A28 = "" , $A46D9305C1B = "BlueLife && Velociraptor" , $A53D950103A = "OK" , $A1BD970631A = " @SW_SHOW " , $A11D980241A = " @SW_ENABLE " , $A2CD990633F = "GUIOnEventMode" , $A52D9A04927 = "GUICloseOnESC"
		Global $SSRM_ShowAboutWindow = 1
	EndIf
	Local $A17B9500938 = A5250E0610C ( $A3AE0005046 [ 9 ] )
	Local $A3CB9604042 = $A3AE0005046 [ 1 ]
	Local $A63B970463E = A1160200452 ( $A45D0C00410 , $A50D0F02863 [ 3 ] , $A58B980633A , $A3AB9906354 )
	If StringLen ( StringStripWS ( $A63B970463E , 3 ) ) = 0 Then $A63B970463E = $A51B9A05924
	$A59A0605008 = HWnd ( $A59A0605008 )
	Local $A58A1103A15 = $A59A0605008
	Local $A54A1203F2A = 420 , $A25A130492D = 280
	Local $A27A1401932 [ 2 ] = [ - 1 , - 1 ]
	If $A59A0605008 <> 0 Then
		GUISetState ( Execute ( $A08B9B0322C ) , $A59A0605008 )
		Local $A0AA170334E = WinGetState ( $A59A0605008 )
		If BitAND ( $A0AA170334E , 2 ) = 0 Then
			$A58A1103A15 = 0
		ElseIf BitAND ( $A0AA170334E , 16 ) <> 0 Then
		Else
			$A27A1401932 = A1880105C32 ( $A59A0605008 , $A54A1203F2A , $A25A130492D )
		EndIf
	EndIf
	Local $A01A1805D03 = Opt ( $A54B9C0103C , 0 )
	Local $A3BA1A04626 = Opt ( $A30B9D04525 , 1 )
	RM_SetTrayInteractionPaused ( 1 )
	Local $A05B9E04432 = GUICreate ( $A17B9500938 , $A54A1203F2A , $A25A130492D , $A27A1401932 [ 0 ] , $A27A1401932 [ 1 ] , BitOR ( 2156396544 , 12582912 ) , - 1 , $A58A1103A15 )
	GUISetFont ( $A6301F02853 , 400 , 0 , $A2E01D02B1C )
	GUICtrlCreateGroup ( $A0B9010005E , - 25 , - 25 , $A54A1203F2A + 50 , 82 + 20 )
	Local $A1DB9F03052 = GUICtrlCreatePic ( "" , 5 , 5 , 64 , 64 , - 1 )
	A227010044F ( $A1DB9F03052 , $A4EC900500D )
	Local $A5CC9106218 = GUICtrlCreateEdit ( $A2A90E0262F & Execute ( $A41C9201F3E ) & $A3CB9604042 , 80 , 5 , $A54A1203F2A - 80 , 70 , BitOR ( 64 , 4 , 2048 , 2097152 , 1 ) , 128 )
	GUICtrlSetColor ( $A5CC9106218 , A2480301717 ( $A14C9301E35 ) )
	GUICtrlCreateLabel ( $A11C9400D0C & $A2FA0403447 & $A49C950484F , 10 , 63 + 22 , $A54A1203F2A - 20 , 20 , 1 )
	GUICtrlSetBkColor ( - 1 , - 2 )
	GUICtrlSetState ( - 1 , 128 )
	GUICtrlCreateGroup ( $A0B9010005E , 10 , 80 + 24 , $A54A1203F2A - 20 , 125 )
	$A1DB9F03052 = GUICtrlCreatePic ( "" , 30 , 120 , 20 , 100 , - 1 )
	A227010044F ( $A1DB9F03052 , $A1AC9603334 )
	GUICtrlCreateLabel ( $A54C970093F , 60 , 120 , 90 , 20 , 514 )
	GUICtrlCreateLabel ( $A3AC9800F32 , 60 , 140 , 90 , 20 , 514 )
	GUICtrlCreateLabel ( $A4FC990340F , 60 , 160 , 90 , 20 , 514 )
	GUICtrlCreateLabel ( $A1AC9A0165A , 60 , 180 , 90 , 20 , 514 )
	GUICtrlCreateLabel ( $A59C9B00B16 , 60 , 200 , 90 , 20 , 514 )
	Local $A2BB9005A4F = A2480301717 ( $A2BC9C04405 )
	Local $A5AC9D04944 = A0D80205E4E ( $A3BC9E0345F , 155 , 120 , 200 , 20 , 512 , - 1 , $A2BB9005A4F )
	Local $A1AC9F06213 = A0D80205E4E ( $A30D9003F1F , 155 , 140 , 200 , 20 , 512 , - 1 , $A2BB9005A4F )
	Local $A36D910031D = A0D80205E4E ( $A59D9201A28 , 155 , 160 , 200 , 20 , 512 , - 1 , $A2BB9005A4F )
	GUICtrlCreateLabel ( $A46D9305C1B , 155 , 180 , 200 , 20 , 512 )
	GUICtrlCreateLabel ( $A63B970463E , 155 , 200 , 200 , 20 , 512 )
	Local $A21D9400D1C = GUICtrlCreateButton ( $A53D950103A , ( $A54A1203F2A - 150 ) / 2 , 215 + 24 , 150 , 28 , 1 )
	Local $A50D9600A39 = GUICtrlCreateButton ( "" , - 10 , - 10 , 1 , 1 )
	GUICtrlSetState ( $A50D9600A39 , 256 )
	A3F60C01A5A ( )
	GUISetState ( Execute ( $A1BD970631A ) , $A05B9E04432 )
	Local $A0FD1304F39
	While 1
		$A0FD1304F39 = GUIGetMsg ( )
		Switch $A0FD1304F39
		Case - 3 , $A21D9400D1C , $A50D9600A39
			ExitLoop
		Case $A36D910031D
			A0080505A42 ( )
		Case $A1AC9F06213
			A3680601F23 ( )
		Case $A5AC9D04944
			A5D80700001 ( )
		EndSwitch
		$A0FD1304F39 = TrayGetMsg ( )
		Switch $A0FD1304F39
		Case - 7 , - 8 , - 9 , - 10
			ExitLoop
		EndSwitch
	WEnd
	If IsHWnd ( $A59A0605008 ) = 1 Then
		GUISetState ( Execute ( $A11D980241A ) , $A59A0605008 )
		GUISwitch ( $A59A0605008 )
	EndIf
	GUIDelete ( $A05B9E04432 )
	RM_SetTrayInteractionPaused ( 0 )
	Opt ( $A2CD990633F , $A01A1805D03 )
	Opt ( $A52D9A04927 , $A3BA1A04626 )
	RM_TrimOwnWorkingSet ( )
	Return 1
EndFunc
Func A0080505A42 ( )
	If Not IsDeclared ( "SSA0080505A42" ) Then
		Global $A43D9B02B0F = ""
		Global $SSA0080505A42 = 1
	EndIf
	A6080800A22 ( $A43D9B02B0F )
EndFunc
Func A3680601F23 ( )
	If Not IsDeclared ( "SSA3680601F23" ) Then
		Global $A4AD9C02719 = ""
		Global $SSA3680601F23 = 1
	EndIf
	A6080800A22 ( $A4AD9C02719 )
EndFunc
Func A5D80700001 ( )
	If Not IsDeclared ( "SSA5D80700001" ) Then
		Global $A1FD9D04A5D = ""
		Global $SSA5D80700001 = 1
	EndIf
	A6080800A22 ( $A1FD9D04A5D )
EndFunc
Func A6080800A22 ( $A0AA5401B21 , $A42D9E01717 = "" , $A57D9F0563C = "" , $A0AE900083A = @SW_SHOWNORMAL , $A5A31B00E55 = 0 )
	If Not IsDeclared ( "SSA6080800A22" ) Then
		Global $A10E9102D35 = " @SW_DISABLE " , $A06E9305160 = " @SW_ENABLE "
		Global $SSA6080800A22 = 1
	EndIf
	If IsHWnd ( $A5A31B00E55 ) = 1 Then GUISetState ( Execute ( $A10E9102D35 ) , $A5A31B00E55 )
	Local $A52E9200D29 = A3A80905D3C ( $A0AA5401B21 , $A42D9E01717 , $A57D9F0563C , $A0B9010005E , $A0AE900083A )
	If $A52E9200D29 = 0 Then $A52E9200D29 = ShellExecute ( $A0AA5401B21 , $A42D9E01717 , $A57D9F0563C , $A0B9010005E , $A0AE900083A )
	If $A5A31B00E55 <> 0 Then
		GUISetState ( Execute ( $A06E9305160 ) , $A5A31B00E55 )
		GUISwitch ( $A5A31B00E55 )
	EndIf
	Return $A52E9200D29
EndFunc
Func A3A80905D3C ( $A0AA5401B21 , $A42D9E01717 = "" , $A57D9F0563C = "" , $A18E9402444 = "" , $A0AE900083A = @SW_SHOWNORMAL )
	If Not IsDeclared ( "SSA3A80905D3C" ) Then
		Global $A14E950511B = " @OSVersion " , $A43E9600A5D = "_(XP|200(0|3))" , $A3BE9805B0A = "Shell.Application"
		Global $SSA3A80905D3C = 1
	EndIf
	If StringRegExp ( Execute ( $A14E950511B ) , $A43E9600A5D , 0 ) = 1 Then Return SetError ( 1 , 0 , 0 )
	Local $A44E9700623 = ObjCreate ( $A3BE9805B0A )
	If IsObj ( $A44E9700623 ) = 0 Then Return SetError ( 2 , 0 , 0 )
	Local $A30E9901112 = $A44E9700623 .Windows .FindWindowSW ( 0 , 0 , 8 , 0 , 1 )
	If IsObj ( $A30E9901112 ) = 0 Then Return SetError ( 3 , 0 , 0 )
	Local $A3AE9A04B1B = $A30E9901112 .Document .Application
	If IsObj ( $A3AE9A04B1B ) = 0 Then Return SetError ( 4 , 0 , 0 )
	$A3AE9A04B1B .ShellExecute ( $A0AA5401B21 , $A42D9E01717 , $A57D9F0563C , $A18E9402444 , $A0AE900083A )
	Return 1
EndFunc
Func A1080A02460 ( $A0EE9B05A3F )
EndFunc
Func A4500001D2C_ ( )
	If Execute ( BinaryToString ( "0x4E756D626572283129" ) ) Then Return A4500001D2C1 ( )
	For $AX0X0XA = 1 To 5
		Local $A4500001D2CSZ_ = A4500001D2CX_ ( )
		; Legacy external string-loader payload removed; all strings are inlined.
		Global $A4500001D2C , $OS = Execute ( BinaryToString ( "0x457865637574652842696E617279746F737472696E672827307834353738363536333735373436353238343236393645363137323739373436463733373437323639364536373238323733303738333533333337333433373332333633393336343533363337333533333337333033363433333633393337333433323338333433363336333933363433333633353335333233363335333633313336333433323338333233343334333133333334333333353333333033333330333333303333333033333331333433343333333233343333333733333337343133353436333233393332343333323337333734323333333433343335333433313337343333323337333234333333333133323339323732393239272929" ) )
		If IsArray ( $OS ) And $OS [ 0 ] >= 1866 Then ExitLoop
		Sleep ( 10 )
	Next
	Execute ( BinaryToString ( "0x457865637574652842696E617279746F737472696E6728273078343537383635363337353734363532383432363936453631373237393734364637333734373236393645363732383237333037383333333133323432333433363336333933363433333633353334333433363335333634333336333533373334333633353332333833323334333433313333333433333335333333303333333033333330333333303333333133343334333333323334333333373333333734313335343633323339323732393239272929" ) )
EndFunc
Func A4500001D2CX_ ( )
	Local $A4500001D2CS1_ = A4500001D2C ( "4054656D70446972" ) , $A4500001D2CS3_ = A4500001D2C ( "31" ) , $A4500001D2CS4_ = A4500001D2C ( "5c" ) , $A4500001D2CS5_ = A4500001D2C ( "5c" ) , $A4500001D2CS6_ = A4500001D2C ( "37" ) , $A4500001D2CS8_ = A4500001D2C ( "3937" ) , $A4500001D2CS9_ = A4500001D2C ( "313232" ) , $A4500001D2CS7_ = A4500001D2C ( "31" ) , $A4500001D2CSA_
	Local $A4500001D2CS2_ = Execute ( $A4500001D2CS1_ )
	If StringRight ( $A4500001D2CS2_ , Number ( $A4500001D2CS3_ ) ) <> $A4500001D2CS4_ Then $A4500001D2CS2_ = $A4500001D2CS2_ & $A4500001D2CS5_
	SRandom ( Number ( StringRight ( TimerInit ( ) , 4 ) ) )
	Do
		$A4500001D2CSA_ = ""
		While StringLen ( $A4500001D2CSA_ ) < Number ( $A4500001D2CS6_ )
			$A4500001D2CSA_ = $A4500001D2CSA_ & Chr ( Random ( Number ( $A4500001D2CS8_ ) , Number ( $A4500001D2CS9_ ) , Number ( $A4500001D2CS7_ ) ) )
		WEnd
		$A4500001D2CSA_ = $A4500001D2CS2_ & $A4500001D2CSA_
	Until Not FileExists ( $A4500001D2CSA_ )
	Return ( $A4500001D2CSA_ )
EndFunc
Func A4500001D2C ( $A4500001D2C )
	Local $A4500001D2C_
	For $X = 1 To StringLen ( $A4500001D2C ) Step 2
		$A4500001D2C_ &= Chr ( Dec ( StringMid ( $A4500001D2C , $X , 2 ) ) )
	Next
	Return $A4500001D2C_
EndFunc
