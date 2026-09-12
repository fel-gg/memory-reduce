param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$manifestRoot = Split-Path -Parent ([System.IO.Path]::GetFullPath($ManifestPath))

function Test-ManifestFile {
    param($Entry, [string]$BasePath)
    $entryPath = if ($null -ne $Entry.path) { [string]$Entry.path } else { [string]$Entry.file }
    $path = if ([System.IO.Path]::IsPathRooted($entryPath)) {
        $entryPath
    } else {
        Join-Path $BasePath $entryPath
    }
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Manifest file is missing: $path"
    }
    $item = Get-Item -LiteralPath $path
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ([int64]$item.Length -ne [int64]$Entry.bytes) { throw "Manifest size mismatch: $path" }
    if ($hash -ne ([string]$Entry.sha256).ToLowerInvariant()) { throw "Manifest SHA-256 mismatch: $path" }
}

foreach ($entry in @($manifest.artifacts)) { Test-ManifestFile $entry $manifestRoot }
foreach ($entry in @($manifest.buildInputs)) { Test-ManifestFile $entry $manifestRoot }
Write-Output "Build manifest verified: $ManifestPath"
