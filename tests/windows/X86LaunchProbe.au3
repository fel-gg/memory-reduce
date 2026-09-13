; Diagnostic-only probe for the compiled AutoIt x86 launcher environment.
; It deliberately has no GUI, mutex, worker, registry, or product dependency.
Local $sMarker = @TempDir & "\ReduceMemory-x86-launch-probe-" & @AutoItPID & ".txt"
FileDelete($sMarker)
FileWrite($sMarker, "started|pid=" & @AutoItPID & "|x64=" & @AutoItX64 & @CRLF)
If $CMDLINE[0] > 0 Then FileWrite($sMarker, "arg1=" & $CMDLINE[1] & @CRLF)
Exit 0
