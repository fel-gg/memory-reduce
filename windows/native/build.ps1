param(
    [Parameter(Mandatory = $true)]
    [string]$ZigPath
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'reduce_memory_worker.c'
$outputRoot = Split-Path -Parent $PSScriptRoot

& $ZigPath cc -target x86_64-windows-gnu -Os -municode `
    -o (Join-Path $outputRoot 'ReduceMemoryWorker_x64.exe') $source -lpsapi -lshell32 -luser32
if ($LASTEXITCODE -ne 0) { throw "x64 native worker build failed: $LASTEXITCODE" }

& $ZigPath cc -target x86-windows-gnu -Os -municode `
    -o (Join-Path $outputRoot 'ReduceMemoryWorker.exe') $source -lpsapi -lshell32 -luser32
if ($LASTEXITCODE -ne 0) { throw "x86 native worker build failed: $LASTEXITCODE" }
