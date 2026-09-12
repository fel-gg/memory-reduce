param(
    [Parameter(Mandatory = $true)]
    [string]$FrontendPath
)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $FrontendPath).Path
$parent = Start-Process -FilePath $resolved -ArgumentList '/RMWORKERLIFECYCLESELFTEST' -PassThru -WindowStyle Hidden
try {
    Start-Sleep -Milliseconds 500
    if ($parent.HasExited) { throw "Lifecycle parent exited before parent-death probe: $($parent.ExitCode)" }
    $children = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($parent.Id)" |
        Where-Object { $_.Name -like 'ReduceMemoryWorker*.exe' } | ForEach-Object ProcessId)
    if ($children.Count -eq 0) { throw 'No lifecycle worker was observed before parent termination' }
    Stop-Process -Id $parent.Id -Force
    Start-Sleep -Milliseconds 750
    foreach ($workerPid in $children) {
        if (Get-Process -Id $workerPid -ErrorAction SilentlyContinue) {
            throw "Worker $workerPid survived parent termination"
        }
    }
    Write-Output "Parent-death Job Object cleanup passed: workers=$($children.Count)"
}
finally {
    if (-not $parent.HasExited) { Stop-Process -Id $parent.Id -Force -ErrorAction SilentlyContinue }
    $parent.Dispose()
}
