param(
    [Parameter(Mandatory = $true)] [string]$WindowsStaging,
    [Parameter(Mandatory = $true)] [string]$LinuxRoot,
    [Parameter(Mandatory = $true)] [string]$OutputDirectory,
    [string]$Version = '3.0',
    [switch]$RequireClean
)
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
function Get-Sha256Hex([string] $Path) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant() }
        finally { $stream.Dispose() }
    } finally { $sha.Dispose() }
}
if ($RequireClean -or ([string]$env:GITHUB_REF -like 'refs/tags/v*')) {
    $dirty = @(& git -C $repositoryRoot status --porcelain)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect repository cleanliness' }
    if ($dirty.Count -gt 0) { throw 'Release packaging requires a clean source tree' }
}
$windowsManifest = Join-Path $WindowsStaging 'BUILD-MANIFEST.json'
$verifier = Join-Path (Split-Path -Parent $PSScriptRoot) 'windows\Verify-BuildManifest.ps1'
if (-not (Test-Path -LiteralPath $windowsManifest -PathType Leaf)) { throw "Windows manifest missing: $windowsManifest" }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $verifier -ManifestPath $windowsManifest
if ($LASTEXITCODE -ne 0) { throw 'Windows manifest verification failed' }
foreach ($path in @('ReduceMemory.exe','ReduceMemory_x64.exe','ReduceMemoryWorker.exe','ReduceMemoryWorker_x64.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $WindowsStaging $path) -PathType Leaf)) { throw "Windows package input missing: $path" }
}
foreach ($path in @('ReduceMemory_Linux.sh','native\reduce-memory-native','desktop\Install_Desktop.sh','server\Install_Server.sh')) {
    if (-not (Test-Path -LiteralPath (Join-Path $LinuxRoot $path) -PathType Leaf)) { throw "Linux package input missing: $path" }
}
$root = Join-Path $OutputDirectory ("ReduceMemory-$Version")
if (Test-Path -LiteralPath $root) {
    $resolvedRoot = [IO.Path]::GetFullPath($root)
    $resolvedOutput = [IO.Path]::GetFullPath($OutputDirectory)
    if (-not $resolvedRoot.StartsWith($resolvedOutput + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolvedRoot) -ne "ReduceMemory-$Version") {
        throw "Refusing to clean an unexpected release directory: $resolvedRoot"
    }
    Remove-Item -LiteralPath $resolvedRoot -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $root 'windows'),(Join-Path $root 'linux') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $WindowsStaging 'ReduceMemory.exe'),(Join-Path $WindowsStaging 'ReduceMemory_x64.exe'),(Join-Path $WindowsStaging 'ReduceMemoryWorker.exe'),(Join-Path $WindowsStaging 'ReduceMemoryWorker_x64.exe') -Destination (Join-Path $root 'windows') -Force
$config = Join-Path $WindowsStaging 'ReduceMemory.ini'
if (-not (Test-Path -LiteralPath $config -PathType Leaf)) { $config = Join-Path (Split-Path -Parent $PSScriptRoot) 'windows\ReduceMemory.ini' }
if (Test-Path -LiteralPath $config -PathType Leaf) { Copy-Item -LiteralPath $config -Destination (Join-Path $root 'windows\ReduceMemory.ini') -Force }
Copy-Item -LiteralPath (Join-Path $LinuxRoot 'ReduceMemory_Linux.sh'),(Join-Path $LinuxRoot 'native'),(Join-Path $LinuxRoot 'desktop'),(Join-Path $LinuxRoot 'server'),(Join-Path $LinuxRoot 'README.md') -Destination (Join-Path $root 'linux') -Recurse -Force
Copy-Item -LiteralPath $windowsManifest -Destination (Join-Path $root 'windows\BUILD-MANIFEST.json') -Force
# Reusing an output directory must not feed metadata from the previous package
# back into the next manifest. Both files are generated below from the actual
# payload and cannot safely contain their own hash.
$metadataNames = @('SHA256SUMS', 'RELEASE-MANIFEST.json')
$files = Get-ChildItem -LiteralPath $root -File -Recurse |
    Where-Object { $_.Name -notin $metadataNames } |
    Sort-Object FullName
$checks = $files | ForEach-Object { "{0}  {1}" -f (Get-Sha256Hex $_.FullName), ($_.FullName.Substring($root.Length + 1)) }
$checks | Set-Content -LiteralPath (Join-Path $root 'SHA256SUMS') -Encoding ASCII
$sourceCommit = (& git -C $repositoryRoot rev-parse HEAD 2>$null).Trim()
$sourceDirty = @(& git -C $repositoryRoot status --porcelain).Count -gt 0
$releaseFiles = $files | ForEach-Object {
    $relative = $_.FullName.Substring($root.Length + 1)
    $architecture = if ($relative -match 'ReduceMemory(?:Worker)?_x64\.exe$') { 'x86_64' } elseif ($relative -match '\.exe$') { 'x86' } else { 'any' }
    [ordered]@{ file = $relative; bytes = $_.Length; sha256 = (Get-Sha256Hex $_.FullName); architecture = $architecture }
}
[ordered]@{ schemaVersion = 1; version = $Version; sourceCommit = $sourceCommit; sourceDirty = $sourceDirty; windowsManifest = (Get-Content -LiteralPath (Join-Path $root 'windows\BUILD-MANIFEST.json') -Raw | ConvertFrom-Json); files = $releaseFiles } |
    ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $root 'RELEASE-MANIFEST.json') -Encoding UTF8
$zip = Join-Path $OutputDirectory ("ReduceMemory-$Version.zip")
Compress-Archive -LiteralPath $root -DestinationPath $zip -Force
Write-Output ("SHA256 {0}  {1}" -f (Get-Sha256Hex $zip), $zip)
Write-Output "Release package created: $zip"
