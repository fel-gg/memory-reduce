param(
    [string[]]$Binaries = @(
        'windows\ReduceMemory_x64.exe',
        'windows\ReduceMemory.exe'
    )
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$fixtureRoot = Join-Path $tempRoot ('ReduceMemory-real-trim-' + [guid]::NewGuid().ToString('N'))
$targetScript = Join-Path $fixtureRoot 'target.ps1'

function Remove-OwnedFixtureDirectory {
    if (-not (Test-Path -LiteralPath $fixtureRoot -PathType Container)) { return }
    $resolvedPath = [System.IO.Path]::GetFullPath($fixtureRoot)
    if (-not $resolvedPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Split-Path -Leaf $resolvedPath).StartsWith('ReduceMemory-real-trim-', [System.StringComparison]::Ordinal)) {
        throw "Refusing to remove unexpected fixture directory: $resolvedPath"
    }
    Remove-Item -LiteralPath $resolvedPath -Recurse -Force
}

try {
    New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
    @'
$buffer = [byte[]]::new(256MB)
for ($offset = 0; $offset -lt $buffer.Length; $offset += 4096) { $buffer[$offset] = 1 }
Start-Sleep -Seconds 30
'@ | Set-Content -LiteralPath $targetScript -Encoding UTF8

    foreach ($binary in $Binaries) {
        $binaryPath = if ([System.IO.Path]::IsPathRooted($binary)) {
            $binary
        } else {
            Join-Path $repositoryRoot $binary
        }
        if (-not (Test-Path -LiteralPath $binaryPath -PathType Leaf)) {
            throw "Trim-test binary is missing: $binaryPath"
        }

        $target = $null
        $resultPath = Join-Path $fixtureRoot ("trim-{0}.result" -f [IO.Path]::GetFileName($binaryPath))
        try {
            $target = Start-Process -FilePath powershell.exe `
                -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',$targetScript `
                -WindowStyle Hidden -PassThru
            $deadline = [DateTime]::UtcNow.AddSeconds(15)
            $resident = 0L
            do {
                if ($target.HasExited) { throw "$binary disposable target exited before trim" }
                $resident = (Get-Process -Id $target.Id).WorkingSet64
                if ($resident -ge 128MB) { break }
                Start-Sleep -Milliseconds 100
            } while ([DateTime]::UtcNow -lt $deadline)
            if ($resident -lt 128MB) { throw "$binary disposable target never became resident" }

            $probe = Start-Process -FilePath $binaryPath `
                -ArgumentList '/RMTRIMTEST',$target.Id,$resultPath -Wait -PassThru
            if ($probe.ExitCode -ne 0) { throw "$binary real trim failed with exit code $($probe.ExitCode)" }
            if ($target.HasExited) { throw "$binary terminated the disposable target" }

            $measurements = @(Get-Content -LiteralPath $resultPath | ForEach-Object { [int64]$_ })
            if ($measurements.Count -ne 2) { throw "$binary did not return structured measurements" }
            $reduced = $measurements[0] - $measurements[1]
            if ($reduced -lt 64MB) {
                throw "$binary reduced only $reduced bytes from a disposable 256 MB target"
            }
            Write-Output "$binary measured working-set reduction: $([math]::Round($reduced / 1MB, 1)) MB"
        }
        finally {
            if ($null -ne $target -and -not $target.HasExited) {
                Stop-Process -Id $target.Id -Force
                $target.WaitForExit(5000) | Out-Null
            }
        }
    }
}
finally {
    Remove-OwnedFixtureDirectory
}
