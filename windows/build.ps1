param(
    [Parameter(Mandatory = $true)]
    [string]$AutoItRoot,

    [Parameter(Mandatory = $true)]
    [string]$ZigPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repositoryRoot 'src\ReduceMemory.au3'
$nativeBuildScript = Join-Path $PSScriptRoot 'native\build.ps1'
$autoIt32 = Join-Path $AutoItRoot 'AutoIt3.exe'
$autoIt64 = Join-Path $AutoItRoot 'AutoIt3_x64.exe'
$compiler32 = Join-Path $AutoItRoot 'Aut2Exe\Aut2exe.exe'
$compiler64 = Join-Path $AutoItRoot 'Aut2Exe\Aut2exe_x64.exe'
$au3Check = Join-Path $AutoItRoot 'Au3Check.exe'

foreach ($requiredPath in @($sourcePath, $nativeBuildScript, $autoIt32, $autoIt64, $compiler32, $compiler64, $au3Check, $ZigPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required build input is missing: $requiredPath"
    }
}

$versionMatch = Select-String -LiteralPath $sourcePath -Pattern '^\$A1090900A56\s*=\s*"([0-9]+\.[0-9]+)"\s*$' | Select-Object -First 1
if ($null -eq $versionMatch) { throw 'Project version was not found in src\ReduceMemory.au3' }
$projectVersion = $versionMatch.Matches[0].Groups[1].Value

$scratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('ReduceMemoryBuild-' + [guid]::NewGuid().ToString('N'))
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$scratchSource = Join-Path $scratchRoot 'ReduceMemory.au3'
$stagedFiles = @(
    'ReduceMemory.exe',
    'ReduceMemory_x64.exe',
    'ReduceMemoryWorker.exe',
    'ReduceMemoryWorker_x64.exe'
)

function Invoke-CheckedProcess {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Description
    )

    try {
        $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    }
    catch {
        throw "$Description could not start $FilePath`: $($_.Exception.Message)"
    }
    try {
        if (-not $process.WaitForExit(120000)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            throw "$Description timed out after 120 seconds"
        }
        if ($process.ExitCode -ne 0) {
            throw "$Description failed with exit code $($process.ExitCode)"
        }
    }
    finally {
        $process.Dispose()
    }
}

function Get-Sha256Hex {
    param([Parameter(Mandatory = $true)][string]$Path)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try { return ([BitConverter]::ToString($sha.ComputeHash($stream)) -replace '-', '') }
        finally { $stream.Dispose() }
    }
    finally { $sha.Dispose() }
}

try {
    New-Item -ItemType Directory -Path $scratchRoot -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $scratchSource -Force

    Invoke-CheckedProcess -FilePath $au3Check -Arguments @('-q', $scratchSource) `
        -Description 'AutoIt syntax validation'

    Invoke-CheckedProcess -FilePath $compiler32 `
        -Arguments @('/in', $scratchSource, '/out', (Join-Path $scratchRoot 'ReduceMemory.exe'), '/x86', '/gui', '/nopack') `
        -Description 'AutoIt x86 frontend compilation'
    Invoke-CheckedProcess -FilePath $compiler64 `
        -Arguments @('/in', $scratchSource, '/out', (Join-Path $scratchRoot 'ReduceMemory_x64.exe'), '/x64', '/gui', '/nopack') `
        -Description 'AutoIt x64 frontend compilation'

    & $nativeBuildScript -ZigPath $ZigPath -OutputDirectory $scratchRoot
    if ($LASTEXITCODE -ne 0) { throw "Native worker build returned exit code $LASTEXITCODE" }

    if (Test-Path -LiteralPath $OutputDirectory -PathType Leaf) {
        throw "OutputDirectory points to a file: $OutputDirectory"
    }
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    foreach ($fileName in $stagedFiles) {
        Copy-Item -LiteralPath (Join-Path $scratchRoot $fileName) `
            -Destination (Join-Path $OutputDirectory $fileName) -Force
    }

    $sourceCommit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $sourceCommit -notmatch '^[0-9a-fA-F]{40}$') {
        throw 'Unable to resolve the source Git commit'
    }
    $trackedChanges = @(& git -C $repositoryRoot status --porcelain -- `
        'src/ReduceMemory.au3' 'windows/native/reduce_memory_worker.c' `
        'windows/native/build.ps1' 'windows/build.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect the source worktree' }

    $artifacts = @()
    foreach ($fileName in $stagedFiles) {
        $artifactPath = Join-Path $OutputDirectory $fileName
        $artifacts += [ordered]@{
            file = $fileName
            bytes = (Get-Item -LiteralPath $artifactPath).Length
            sha256 = Get-Sha256Hex $artifactPath
            architecture = if ($fileName -like '*_x64.exe') { 'x86_64' } else { 'x86' }
        }
    }

    $autoItVersion = (Get-Item -LiteralPath $autoIt32).VersionInfo.FileVersion
    $zigVersion = (& $ZigPath version).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($zigVersion)) {
        throw 'Unable to resolve the Zig version'
    }

    $buildInputPaths = @(
        $sourcePath,
        (Join-Path $repositoryRoot 'windows\native\reduce_memory_worker.c'),
        $nativeBuildScript,
        $au3Check,
        $compiler32,
        $compiler64,
        $ZigPath
    )
    $buildInputs = @($buildInputPaths | ForEach-Object {
        $resolvedInput = [System.IO.Path]::GetFullPath($_)
        [ordered]@{
            path = $resolvedInput
            bytes = (Get-Item -LiteralPath $resolvedInput).Length
            sha256 = Get-Sha256Hex $resolvedInput
        }
    })

    $manifest = [ordered]@{
        schemaVersion = 1
        projectVersion = $projectVersion
        sourceCommit = $sourceCommit.ToLowerInvariant()
        sourceDirty = $trackedChanges.Count -gt 0
        sourceSha256 = Get-Sha256Hex $sourcePath
        buildInputs = $buildInputs
        toolchain = [ordered]@{
            autoIt = $autoItVersion
            zig = $zigVersion
        }
        artifacts = $artifacts
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content `
        -LiteralPath (Join-Path $OutputDirectory 'BUILD-MANIFEST.json') -Encoding UTF8

    Write-Output "Windows build $projectVersion staged at $OutputDirectory"
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratchRoot = [System.IO.Path]::GetFullPath($scratchRoot)
        $scratchLeaf = Split-Path -Leaf $resolvedScratchRoot
        if (-not $resolvedScratchRoot.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            -not $scratchLeaf.StartsWith('ReduceMemoryBuild-', [System.StringComparison]::Ordinal)) {
            throw "Refusing to remove unexpected build directory: $resolvedScratchRoot"
        }
        Remove-Item -LiteralPath $resolvedScratchRoot -Recurse -Force
    }
}
