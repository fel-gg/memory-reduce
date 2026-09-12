param(
    [Parameter(Mandatory = $true)]
    [string]$AutoItPath
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$owned = Join-Path ([IO.Path]::GetTempPath()) ('ReduceMemory-temp-test-' + [guid]::NewGuid().ToString('N'))
$root = Join-Path $owned 'inside'
$outside = Join-Path $owned 'outside'
$result = Join-Path $owned 'result.txt'
$junction = ''
$lockedStream = $null

try {
    New-Item -ItemType Directory -Path $root,$outside | Out-Null
    $invalidResult = Join-Path $owned 'invalid-root-result.txt'
    $invalidProbe = Start-Process -FilePath $AutoItPath -ArgumentList '/ErrorStdOut',(Join-Path $repositoryRoot 'src\ReduceMemory.au3'),'/RMTEMPTEST',('"C:\"'),('"{0}"' -f $invalidResult) -PassThru
    if (-not $invalidProbe.WaitForExit(15000)) {
        Stop-Process -Id $invalidProbe.Id -Force -ErrorAction SilentlyContinue
        throw 'Invalid broad-root probe timed out'
    }
    $invalidProbe.Dispose()
    if (-not (Test-Path -LiteralPath $invalidResult -PathType Leaf)) { throw 'Invalid broad-root probe produced no report' }
    $invalidFields = Get-Content -LiteralPath $invalidResult
    if ($invalidFields.Count -lt 2 -or [int]$invalidFields[0] -ne 0 -or [int]$invalidFields[1] -lt 1) { throw 'Broad root was not rejected without mutation' }
    Set-Content -LiteralPath (Join-Path $root 'delete-me.tmp') -Value 'temporary'
    $locked = Join-Path $root 'locked.tmp'
    Set-Content -LiteralPath $locked -Value 'locked'
    $sentinel = Join-Path $outside 'sentinel.keep'
    Set-Content -LiteralPath $sentinel -Value 'must survive'
    $junction = Join-Path $root 'outside-link'
    cmd.exe /d /c "mklink /J `"$junction`" `"$outside`"" | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $junction)) { throw 'Could not create junction fixture' }

    $lockedStream = [IO.File]::Open($locked,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    $process = Start-Process -FilePath $AutoItPath -ArgumentList '/ErrorStdOut',(Join-Path $repositoryRoot 'src\ReduceMemory.au3'),'/RMTEMPTEST',("`"$root`""),("`"$result`"") -PassThru
    if (-not $process.WaitForExit(15000)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        throw 'Temp containment probe timed out'
    }
    if ($process.ExitCode -ne 0) { throw "Temp containment probe failed with $($process.ExitCode)" }
    $process.Dispose()
    if (Test-Path -LiteralPath (Join-Path $root 'delete-me.tmp')) { throw 'Ordinary Temp file was not deleted' }
    if (-not (Test-Path -LiteralPath $locked)) { throw 'Locked file was deleted' }
    if (-not (Test-Path -LiteralPath $sentinel)) { throw 'Junction traversal deleted the outside sentinel' }
    if (-not (Test-Path -LiteralPath $junction)) { throw 'Reparse point should be skipped, not removed' }

    # Repeat the reparse-point boundary with fresh entries. This is a bounded
    # stress probe for enumeration/cleanup ordering; every iteration keeps its
    # sentinel outside the allowed tree and must leave the junction untouched.
    for ($iteration = 1; $iteration -le 8; $iteration++) {
        $raceRoot = Join-Path $root ("race-{0}" -f $iteration)
        $raceLink = Join-Path $raceRoot 'link'
        New-Item -ItemType Directory -Path $raceRoot | Out-Null
        Set-Content -LiteralPath (Join-Path $raceRoot 'ordinary.tmp') -Value 'temporary'
        cmd.exe /d /c "mklink /J `"$raceLink`" `"$outside`"" | Out-Null
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $raceLink)) { throw "Could not create bounded race fixture $iteration" }
        $raceResult = Join-Path $owned ("race-{0}.txt" -f $iteration)
        $raceProbe = Start-Process -FilePath $AutoItPath -ArgumentList '/ErrorStdOut',(Join-Path $repositoryRoot 'src\ReduceMemory.au3'),'/RMTEMPTEST',("`"$raceRoot`""),("`"$raceResult`"") -PassThru
        if (-not $raceProbe.WaitForExit(15000)) {
            Stop-Process -Id $raceProbe.Id -Force -ErrorAction SilentlyContinue
            throw "Bounded Temp race probe $iteration timed out"
        }
        if ($raceProbe.ExitCode -ne 0) { throw "Bounded Temp race probe $iteration failed with $($raceProbe.ExitCode)" }
        $raceProbe.Dispose()
        if (-not (Test-Path -LiteralPath $raceLink)) { throw "Reparse link $iteration was removed or followed" }
        if (-not (Test-Path -LiteralPath $sentinel)) { throw "Outside sentinel was changed in iteration $iteration" }
        cmd.exe /d /c "rmdir `"$raceLink`"" | Out-Null
    }
    Write-Output 'Windows Temp containment and locked-file behavior passed.'
}
finally {
    if ($null -ne $lockedStream) { $lockedStream.Dispose() }
    if ($junction -and (Test-Path -LiteralPath $junction)) { cmd.exe /d /c "rmdir `"$junction`"" | Out-Null }
    if (Test-Path -LiteralPath $owned) {
        $resolved = [IO.Path]::GetFullPath($owned)
        $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        if (-not $resolved.StartsWith($temp,[StringComparison]::OrdinalIgnoreCase) -or
            -not (Split-Path -Leaf $resolved).StartsWith('ReduceMemory-temp-test-',[StringComparison]::Ordinal)) {
            throw "Refusing to remove unexpected fixture root: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
