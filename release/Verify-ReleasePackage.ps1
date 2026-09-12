param([Parameter(Mandatory = $true)][string]$PackagePath)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) { throw "Package missing: $PackagePath" }
$root = Join-Path ([IO.Path]::GetTempPath()) ('ReduceMemory-package-verify-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root | Out-Null
try {
    Expand-Archive -LiteralPath $PackagePath -DestinationPath $root -Force
    $packageRoot = Get-ChildItem -LiteralPath $root -Directory | Select-Object -First 1
    if ($null -eq $packageRoot) { throw 'Package root directory is missing' }
    $manifestPath = Join-Path $packageRoot.FullName 'RELEASE-MANIFEST.json'
    $checksPath = Join-Path $packageRoot.FullName 'SHA256SUMS'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'Release manifest missing' }
    if (-not (Test-Path -LiteralPath $checksPath -PathType Leaf)) { throw 'SHA256SUMS missing' }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    foreach ($entry in @($manifest.files)) {
        $path = Join-Path $packageRoot.FullName ([string]$entry.file)
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Release file missing: $($entry.file)" }
        $item = Get-Item -LiteralPath $path
        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        if ([int64]$item.Length -ne [int64]$entry.bytes -or $hash -ne ([string]$entry.sha256).ToLowerInvariant()) { throw "Release file mismatch: $($entry.file)" }
    }
    $listed = @{}
    foreach ($line in Get-Content -LiteralPath $checksPath) {
        if ($line -notmatch '^([0-9a-fA-F]{64})  (.+)$') { throw "Malformed checksum line: $line" }
        $listed[$Matches[2]] = $Matches[1].ToLowerInvariant()
    }
    foreach ($entry in @($manifest.files)) {
        if (-not $listed.ContainsKey([string]$entry.file) -or $listed[[string]$entry.file] -ne ([string]$entry.sha256).ToLowerInvariant()) { throw "Checksum list mismatch: $($entry.file)" }
    }
    Write-Output "Release package verified: $PackagePath"
}
finally {
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
