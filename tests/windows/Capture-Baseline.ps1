param(
    [Parameter(Mandatory = $true)]
    [string]$AutoItRoot,

    [Parameter(Mandatory = $true)]
    [string]$ZigPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (Test-Path -LiteralPath $OutputPath) {
    throw "Refusing to overwrite an existing baseline: $OutputPath"
}
$autoItCompiler32 = Join-Path $AutoItRoot 'Aut2Exe\Aut2exe.exe'
$autoItCompiler64 = Join-Path $AutoItRoot 'Aut2Exe\Aut2exe_x64.exe'
$autoItIncludeRoot = Join-Path $AutoItRoot 'Include'
foreach ($requiredPath in @($autoItCompiler32, $autoItCompiler64, $ZigPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Baseline input is missing: $requiredPath"
    }
}
if (-not (Test-Path -LiteralPath $autoItIncludeRoot -PathType Container)) {
    throw "AutoIt include directory is missing: $autoItIncludeRoot"
}

function Get-FileRecord {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $fullPath = Join-Path $repositoryRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        return [ordered]@{ path = $RelativePath; present = $false }
    }
    return [ordered]@{
        path = $RelativePath
        present = $true
        bytes = (Get-Item -LiteralPath $fullPath).Length
        sha256 = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash
    }
}

$sourceCommit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $sourceCommit -notmatch '^[0-9a-fA-F]{40}$') {
    throw 'Unable to resolve the source Git commit for the baseline'
}
$worktreeState = @(& git -C $repositoryRoot status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect the source worktree for the baseline' }

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$memory = [ordered]@{ status = 'unknown' }
$pageFiles = @()
try {
    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $memory = [ordered]@{
        status = 'measured'
        totalPhysicalKiB = [int64]$operatingSystem.TotalVisibleMemorySize
        availablePhysicalKiB = [int64]$operatingSystem.FreePhysicalMemory
    }
    $pageFiles = @(Get-CimInstance -ClassName Win32_PageFileUsage | ForEach-Object {
        [ordered]@{
            name = $_.Name
            allocatedMiB = [int64]$_.AllocatedBaseSize
            currentUsageMiB = [int64]$_.CurrentUsage
            peakUsageMiB = [int64]$_.PeakUsage
        }
    })
}
catch {
    $memory = [ordered]@{ status = 'unavailable'; error = $_.Exception.Message }
}

$includeFiles = @(Get-ChildItem -LiteralPath $autoItIncludeRoot -File -Filter '*.au3')
$zigVersion = (& $ZigPath version).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($zigVersion)) {
    throw 'Unable to resolve the Zig version for the baseline'
}

$baseline = [ordered]@{
    schemaVersion = 1
    capturedAtUtc = [DateTime]::UtcNow.ToString('o')
    source = [ordered]@{
        commit = $sourceCommit.ToLowerInvariant()
        dirty = $worktreeState.Count -gt 0
        files = @(
            Get-FileRecord 'src\ReduceMemory.au3'
            Get-FileRecord 'windows\native\reduce_memory_worker.c'
            Get-FileRecord 'linux\ReduceMemory_Linux.sh'
            Get-FileRecord 'linux\native\reduce-memory-native'
        )
    }
    storedWindowsArtifacts = @(
        Get-FileRecord 'windows\ReduceMemory.exe'
        Get-FileRecord 'windows\ReduceMemory_x64.exe'
        Get-FileRecord 'windows\ReduceMemoryWorker.exe'
        Get-FileRecord 'windows\ReduceMemoryWorker_x64.exe'
    )
    configuration = [ordered]@{
        record = Get-FileRecord 'windows\ReduceMemory.ini'
        privateContentCaptured = $false
    }
    toolchain = [ordered]@{
        autoItVersion = (Get-Item -LiteralPath (Join-Path $AutoItRoot 'AutoIt3.exe')).VersionInfo.FileVersion
        compilerX86Sha256 = (Get-FileHash -LiteralPath $autoItCompiler32 -Algorithm SHA256).Hash
        compilerX64Sha256 = (Get-FileHash -LiteralPath $autoItCompiler64 -Algorithm SHA256).Hash
        includeFileCount = $includeFiles.Count
        zigVersion = $zigVersion
        zigSha256 = (Get-FileHash -LiteralPath $ZigPath -Algorithm SHA256).Hash
    }
    environment = [ordered]@{
        os = [Environment]::OSVersion.VersionString
        osArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        processArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString()
        administrator = $isAdministrator
        memory = $memory
        pageFiles = $pageFiles
    }
    benchmarkFixture = [ordered]@{
        targetWorkingSetMiB = 256
        readinessFloorMiB = 128
        minimumMeasuredReductionMiB = 64
        readinessDeadlineSeconds = 15
        globalMemoryMutationAllowed = $false
    }
}

$outputParent = Split-Path -Parent $OutputPath
if ([string]::IsNullOrWhiteSpace($outputParent)) { $outputParent = $repositoryRoot }
New-Item -ItemType Directory -Path $outputParent -Force | Out-Null
$baseline | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "M0 baseline recorded at $OutputPath"
