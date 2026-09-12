param(
    [Parameter(Mandatory = $true)]
    [string]$ZigPath,

    [string]$OutputDirectory = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'reduce_memory_worker.c'
if (-not (Test-Path -LiteralPath $ZigPath -PathType Leaf)) {
    throw "Zig compiler is missing: $ZigPath"
}
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

function Invoke-ZigCompile {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Architecture
    )
    $process = Start-Process -FilePath $ZigPath -ArgumentList $Arguments -PassThru
    try {
        if (-not $process.WaitForExit(300000)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            throw "$Architecture native worker build timed out after 300 seconds"
        }
        if ($process.ExitCode -ne 0) {
            throw "$Architecture native worker build failed: $($process.ExitCode)"
        }
    }
    finally {
        $process.Dispose()
    }
}

Invoke-ZigCompile -Architecture 'x64' -Arguments @(
    'cc', '-target', 'x86_64-windows-gnu', '-Os', '-municode',
    '-o', (Join-Path $OutputDirectory 'ReduceMemoryWorker_x64.exe'), $source,
    '-lpsapi', '-lshell32', '-luser32'
)
Invoke-ZigCompile -Architecture 'x86' -Arguments @(
    'cc', '-target', 'x86-windows-gnu', '-Os', '-municode',
    '-o', (Join-Path $OutputDirectory 'ReduceMemoryWorker.exe'), $source,
    '-lpsapi', '-lshell32', '-luser32'
)
