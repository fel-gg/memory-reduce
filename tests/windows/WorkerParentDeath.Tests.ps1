param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath
)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $FrontendPath).Path
$workerName = [IO.Path]::GetFileNameWithoutExtension($resolved) -replace '^ReduceMemory$', 'ReduceMemoryWorker'
$before = @(Get-Process -Name 'ReduceMemoryWorker*' -ErrorAction SilentlyContinue | ForEach-Object Id)
$parent = Start-Process -FilePath $resolved -ArgumentList '/RMWORKERLIFECYCLESELFTEST' -PassThru -WindowStyle Hidden
try {
    Start-Sleep -Milliseconds 500
    if ($parent.HasExited) { throw "Lifecycle parent exited before parent-death probe: $($parent.ExitCode)" }
    $children = @(Get-Process -Name 'ReduceMemoryWorker*' -ErrorAction SilentlyContinue |
        Where-Object { $before -notcontains $_.Id } | ForEach-Object Id)
    if ($children.Count -eq 0) { throw 'No lifecycle worker was observed before parent termination' }
    Stop-Process -Id $parent.Id -Force
    Start-Sleep -Milliseconds 750
    foreach ($pid in $children) {
        if (Get-Process -Id $pid -ErrorAction SilentlyContinue) {
            throw "Worker $pid survived parent termination"
        }
    }
    Write-Output "Parent-death Job Object cleanup passed: workers=$($children.Count)"
}
finally {
    if (-not $parent.HasExited) { Stop-Process -Id $parent.Id -Force -ErrorAction SilentlyContinue }
    $parent.Dispose()
}
