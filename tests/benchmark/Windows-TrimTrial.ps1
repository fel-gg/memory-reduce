param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('trim', 'noop')]
    [string]$Action,

    [int]$Megabytes = 256
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$resolvedFrontend = [IO.Path]::GetFullPath($FrontendPath)
if (-not (Test-Path -LiteralPath $resolvedFrontend -PathType Leaf)) {
    throw "Frontend missing: $resolvedFrontend"
}
if ($Megabytes -lt 128 -or $Megabytes -gt 512) {
    throw 'Megabytes must remain in the bounded 128..512 fixture range'
}

$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('ReduceMemory-benchmark-trial-' + [guid]::NewGuid().ToString('N'))
$resultPath = Join-Path $fixtureRoot 'trim.result'
$target = $null

try {
    New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
    $targetCode = @"
`$bytes = [byte[]]::new($($Megabytes)MB)
for (`$offset = 0; `$offset -lt `$bytes.Length; `$offset += 4096) { `$bytes[`$offset] = 1 }
Start-Sleep -Seconds 30
"@
    $encodedTarget = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($targetCode))
    $target = Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encodedTarget
    ) -WindowStyle Hidden -PassThru

    $readyDeadline = [DateTime]::UtcNow.AddSeconds(15)
    $resident = 0L
    do {
        if ($target.HasExited) { throw 'Disposable target exited before it became resident' }
        $resident = (Get-Process -Id $target.Id -ErrorAction SilentlyContinue).WorkingSet64
        if ($resident -ge [int64]$Megabytes * 1MB / 2) { break }
        Start-Sleep -Milliseconds 100
    } while ([DateTime]::UtcNow -lt $readyDeadline)
    if ($resident -lt [int64]$Megabytes * 1MB / 2) {
        throw "Disposable target resident set stayed below the fixture floor: $resident"
    }

    if ($Action -eq 'trim') {
        $probe = Start-Process -FilePath $resolvedFrontend -ArgumentList @(
            '/RMTRIMTEST', [string]$target.Id, $resultPath
        ) -WindowStyle Hidden -Wait -PassThru
        if ($probe.ExitCode -ne 0) { throw "Targeted trim exited with $($probe.ExitCode)" }
        if ($target.HasExited) { throw 'Targeted trim terminated the disposable target' }
        $measurements = @(Get-Content -LiteralPath $resultPath | ForEach-Object { [int64]$_ })
        if ($measurements.Count -ne 2) { throw 'Targeted trim did not return two measurements' }
        if (($measurements[0] - $measurements[1]) -lt 64MB) {
            throw "Targeted trim released less than 64 MiB: $($measurements[0] - $measurements[1])"
        }
    }
    else {
        Start-Sleep -Milliseconds 250
    }

    # Keep setup/action/teardown ownership inside this process tree. The
    # benchmark collector records the action command terminal time separately
    # from its delayed +3/+15/+60 observations.
    Start-Sleep -Milliseconds 250
    Write-Output "trial=$Action target_pid=$($target.Id) resident_before=$resident"
}
finally {
    if ($null -ne $target -and -not $target.HasExited) {
        Stop-Process -Id $target.Id -Force -ErrorAction SilentlyContinue
        $target.WaitForExit(5000) | Out-Null
    }
    if (Test-Path -LiteralPath $fixtureRoot) {
        Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
