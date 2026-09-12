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

& $ZigPath cc -target x86_64-windows-gnu -Os -municode `
    -o (Join-Path $OutputDirectory 'ReduceMemoryWorker_x64.exe') $source -lpsapi -lshell32 -luser32
if ($LASTEXITCODE -ne 0) { throw "x64 native worker build failed: $LASTEXITCODE" }

& $ZigPath cc -target x86-windows-gnu -Os -municode `
    -o (Join-Path $OutputDirectory 'ReduceMemoryWorker.exe') $source -lpsapi -lshell32 -luser32
if ($LASTEXITCODE -ne 0) { throw "x86 native worker build failed: $LASTEXITCODE" }
