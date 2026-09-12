param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath
)

$ErrorActionPreference = 'Stop'
$domain = [string]$env:USERDOMAIN
$user = [string]$env:USERNAME
$scope = ($domain + '_' + $user).ToLowerInvariant() -replace '[^a-z0-9._-]', '_'
if ([string]::IsNullOrWhiteSpace($scope)) { $scope = 'unknown-user' }
$name = 'Local\ReduceMemory.Optimize.v3.' + $scope
$created = $false
$mutex = [Threading.Mutex]::new($false, $name, [ref]$created)
try {
    if (-not $created) { throw "Could not reserve test mutex: $name" }
    $process = Start-Process -FilePath (Resolve-Path -LiteralPath $FrontendPath).Path `
        -ArgumentList '/RMSMOOTH' -PassThru -WindowStyle Hidden
    if (-not $process.WaitForExit(15000)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        throw 'Contended optimization process timed out'
    }
    if ($process.ExitCode -ne 7) {
        throw "Contended optimization returned $($process.ExitCode), expected lock rejection exit 7"
    }
    Write-Output "Optimization lock contention passed: $name"
}
finally {
    if ($null -ne $process) { $process.Dispose() }
    if ($null -ne $mutex) { $mutex.Dispose() }
}
