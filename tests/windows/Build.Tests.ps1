param(
    [Parameter(Mandatory = $true)]
    [string]$AutoItRoot,

    [Parameter(Mandatory = $true)]
    [string]$ZigPath,

    [string]$OutputDirectory = '',

    [switch]$SkipFrontendExecution
)

$ErrorActionPreference = 'Stop'
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$buildScript = Join-Path $repositoryRoot 'windows\build.ps1'
$baselineScript = Join-Path $PSScriptRoot 'Capture-Baseline.ps1'
$ownsOutput = [string]::IsNullOrWhiteSpace($OutputDirectory)
$outputRoot = if ($ownsOutput) {
    Join-Path ([System.IO.Path]::GetTempPath()) ('ReduceMemory-build-test-' + [guid]::NewGuid().ToString('N'))
} else {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
}
$sourceCheckRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('ReduceMemory-source-test-' + [guid]::NewGuid().ToString('N'))

function Remove-OwnedTemporaryDirectory {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ExpectedPrefix
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return }
    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $leafName = Split-Path -Leaf $resolvedPath
    if (-not $resolvedPath.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not $leafName.StartsWith($ExpectedPrefix, [System.StringComparison]::Ordinal)) {
        throw "Refusing to remove unexpected test directory: $resolvedPath"
    }
    Remove-Item -LiteralPath $resolvedPath -Recurse -Force
}

function Get-PeMachine {
    param([Parameter(Mandatory = $true)][string]$Path)

    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    $reader = [System.IO.BinaryReader]::new($stream)
    try {
        if ($reader.ReadUInt16() -ne 0x5A4D) { throw "Not a PE executable: $Path" }
        $stream.Position = 0x3C
        $peOffset = $reader.ReadUInt32()
        if ($peOffset -gt ($stream.Length - 6)) { throw "Invalid PE header offset: $Path" }
        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x00004550) { throw "Invalid PE signature: $Path" }
        return $reader.ReadUInt16()
    }
    finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

function Invoke-BoundedProcess {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [int]$TimeoutMs = 30000
    )
    $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    try {
        if (-not $process.WaitForExit($TimeoutMs)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            throw "Process timed out after $TimeoutMs ms: $FilePath"
        }
        return $process.ExitCode
    }
    finally {
        $process.Dispose()
    }
}

try {
    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    $baselinePath = Join-Path $outputRoot 'M0-BASELINE.json'
    & $baselineScript -AutoItRoot $AutoItRoot -ZigPath $ZigPath -OutputPath $baselinePath
    if ($LASTEXITCODE -ne 0) { throw "Baseline capture returned exit code $LASTEXITCODE" }

    New-Item -ItemType Directory -Path $sourceCheckRoot -Force | Out-Null
    $sourceCopy = Join-Path $sourceCheckRoot 'ReduceMemory.au3'
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'src\ReduceMemory.au3') -Destination $sourceCopy
    foreach ($interpreter in @('AutoIt3.exe', 'AutoIt3_x64.exe')) {
        $interpreterPath = Join-Path $AutoItRoot $interpreter
        if (-not (Test-Path -LiteralPath $interpreterPath -PathType Leaf)) {
            throw "AutoIt interpreter is missing: $interpreterPath"
        }
        foreach ($selfTest in @('/RMSELFTEST', '/RMMONITORSELFTEST', '/RMMEASUREMENTSELFTEST')) {
            $processExit = Invoke-BoundedProcess -FilePath $interpreterPath `
                -Arguments @('/ErrorStdOut',$sourceCopy,$selfTest)
            if ($processExit -ne 0) {
                throw "$interpreter source $selfTest failed with $processExit"
            }
        }
    }

    & $buildScript -AutoItRoot $AutoItRoot -ZigPath $ZigPath -OutputDirectory $outputRoot
    if ($LASTEXITCODE -ne 0) { throw "Build returned exit code $LASTEXITCODE" }

    $expectedFiles = @(
        'ReduceMemory.exe',
        'ReduceMemory_x64.exe',
        'ReduceMemoryWorker.exe',
        'ReduceMemoryWorker_x64.exe',
        'BUILD-MANIFEST.json',
        'M0-BASELINE.json'
    )

    foreach ($fileName in $expectedFiles) {
        $path = Join-Path $outputRoot $fileName
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Build output is missing $fileName"
        }
        if ((Get-Item -LiteralPath $path).Length -le 0) {
            throw "Build output is empty: $fileName"
        }
    }

    $manifest = Get-Content -LiteralPath (Join-Path $outputRoot 'BUILD-MANIFEST.json') -Raw | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 1) { throw 'Unexpected build manifest schema' }
    if ($manifest.projectVersion -ne '3.0') { throw 'The staged build must produce project version 3.0' }
    if ($manifest.sourceCommit -notmatch '^[0-9a-f]{40}$') { throw 'Manifest source commit is invalid' }
    if ($manifest.sourceSha256 -notmatch '^[A-F0-9]{64}$') { throw 'Manifest source hash is invalid' }
    if ($manifest.buildInputs.Count -lt 7) { throw 'Manifest must describe all compiler and source inputs' }
    foreach ($input in $manifest.buildInputs) {
        if ($input.bytes -le 0 -or $input.sha256 -notmatch '^[A-F0-9]{64}$') {
            throw "Manifest build input is incomplete: $($input.path)"
        }
    }
    if ($manifest.artifacts.Count -ne 4) { throw 'Manifest must describe four Windows executables' }
    $manifestVerifier = Join-Path $repositoryRoot 'windows\Verify-BuildManifest.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $manifestVerifier -ManifestPath (Join-Path $outputRoot 'BUILD-MANIFEST.json')
    if ($LASTEXITCODE -ne 0) { throw 'Build manifest hash verification failed' }

    $baseline = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
    if ($baseline.schemaVersion -ne 1) { throw 'Unexpected M0 baseline schema' }
    if ($baseline.source.commit -notmatch '^[0-9a-f]{40}$') { throw 'Baseline source commit is invalid' }
    if ($baseline.storedWindowsArtifacts.Count -ne 4) { throw 'Baseline must record four stored Windows artifacts' }
    if ($baseline.toolchain.includeFileCount -lt 1) { throw 'Baseline did not record the AutoIt include set' }
    if ($baseline.benchmarkFixture.globalMemoryMutationAllowed -ne $false) {
        throw 'M0 benchmark fixture must not allow global memory mutation'
    }

    foreach ($artifact in $manifest.artifacts) {
        $artifactPath = Join-Path $outputRoot $artifact.file
        $actualHash = (Get-FileHash -LiteralPath $artifactPath -Algorithm SHA256).Hash
        if ($actualHash -ne $artifact.sha256) { throw "Hash mismatch for $($artifact.file)" }
        if ($artifact.bytes -ne (Get-Item -LiteralPath $artifactPath).Length) {
            throw "Size mismatch for $($artifact.file)"
        }
        $expectedMachine = if ($artifact.architecture -eq 'x86_64') { 0x8664 } else { 0x014C }
        $actualMachine = Get-PeMachine -Path $artifactPath
        if ($actualMachine -ne $expectedMachine) {
            throw "Architecture mismatch for $($artifact.file): PE machine 0x$($actualMachine.ToString('X4'))"
        }
    }

    if (-not $SkipFrontendExecution) {
        foreach ($frontend in @('ReduceMemory.exe', 'ReduceMemory_x64.exe')) {
            foreach ($selfTest in @('/RMSELFTEST', '/RMMONITORSELFTEST', '/RMMEASUREMENTSELFTEST', '/RMWORKERLIFECYCLESELFTEST')) {
                $frontendPath = Join-Path $outputRoot $frontend
                if (-not (Test-Path -LiteralPath $frontendPath -PathType Leaf)) {
                    throw "$frontend disappeared before $selfTest. Check endpoint-security quarantine history for the staged build."
                }
                $processExit = Invoke-BoundedProcess -FilePath $frontendPath -Arguments @($selfTest)
                if ($selfTest -eq '/RMWORKERLIFECYCLESELFTEST' -and $processExit -eq 62) {
                    # A cold runner can race native image startup. Retry once
                    # after the frontend's own bounded lifecycle probe; a
                    # second failure remains fatal and is not hidden.
                    Start-Sleep -Milliseconds 500
                    $processExit = Invoke-BoundedProcess -FilePath $frontendPath -Arguments @($selfTest)
                }
                if ($processExit -ne 0) { throw "$frontend $selfTest failed with $processExit" }
            }
        }

    }
    else {
        Write-Warning 'Compiled frontend execution was skipped. Source checks, compilation, manifest validation, and worker tests continue; compiled frontend runtime behavior remains unverified.'
    }

    foreach ($worker in @('ReduceMemoryWorker.exe', 'ReduceMemoryWorker_x64.exe')) {
        foreach ($selfTest in @('/selftest', '/measurement-selftest')) {
            $processExit = Invoke-BoundedProcess -FilePath (Join-Path $outputRoot $worker) -Arguments @($selfTest)
            if ($processExit -ne 0) { throw "$worker $selfTest failed with $processExit" }
        }
    }

    Write-Output "Windows staged build contract passed: $outputRoot"
}
finally {
    if ($ownsOutput) { Remove-OwnedTemporaryDirectory -Path $outputRoot -ExpectedPrefix 'ReduceMemory-build-test-' }
    Remove-OwnedTemporaryDirectory -Path $sourceCheckRoot -ExpectedPrefix 'ReduceMemory-source-test-'
}
