param(
    [Parameter(Mandatory = $true)]
    [string]$ZigPath
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$outputRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('ReduceMemory-worker-measurement-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    & (Join-Path $repositoryRoot 'windows\native\build.ps1') -ZigPath $ZigPath -OutputDirectory $outputRoot
    if ($LASTEXITCODE -ne 0) { throw "Native build failed: $LASTEXITCODE" }
    foreach ($worker in @('ReduceMemoryWorker.exe', 'ReduceMemoryWorker_x64.exe')) {
        $process = Start-Process -FilePath (Join-Path $outputRoot $worker) -ArgumentList '/measurement-selftest' -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "$worker measurement contract failed with $($process.ExitCode)" }
    }
    Write-Output 'Windows worker measurement contract passed.'
}
finally {
    if (Test-Path -LiteralPath $outputRoot -PathType Container) {
        $resolved = [System.IO.Path]::GetFullPath($outputRoot)
        $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if (-not $resolved.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not (Split-Path -Leaf $resolved).StartsWith('ReduceMemory-worker-measurement-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to remove unexpected fixture directory: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
