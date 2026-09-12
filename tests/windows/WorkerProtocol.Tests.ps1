param(
    [Parameter(Mandatory = $true)]
    [string]$WorkerPath
)

$ErrorActionPreference = 'Stop'
$ownedRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('ReduceMemory-protocol-' + [guid]::NewGuid().ToString('N'))

function Invoke-Worker {
    param([string[]]$Arguments)
    $process = Start-Process -FilePath $WorkerPath -ArgumentList $Arguments -PassThru -WindowStyle Hidden
    try {
        if (-not $process.WaitForExit(15000)) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
            throw "Worker timed out: $WorkerPath"
        }
        return $process.ExitCode
    }
    finally {
        $process.Dispose()
    }
}

try {
    New-Item -ItemType Directory -Path $ownedRoot | Out-Null

    foreach ($invalid in @(
        @('/pid=0','/profile=2','/profile=3','/protocol=2','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=-1','/protocol=2','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=4294967296','/protocol=2','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=2','/protocol=2','/session=','/result=x','/handshake=y'),
        @('/pid=0','/profile=2','/protocol=1','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=2','/protect-foreground=2','/protocol=2','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=2','/protect-foreground=1','/protect-foreground=0','/protocol=2','/session=abc','/result=x','/handshake=y'),
        @('/pid=0','/profile=2','/protocol=2','/session=abc','/result=x','/handshake=y','/unknown')
    )) {
        $exitCode = Invoke-Worker -Arguments $invalid
        if ($exitCode -ne 2) { throw "Invalid argument set returned $exitCode instead of 2: $($invalid -join ' ')" }
    }

    $session = [guid]::NewGuid().ToString('N')
    $targetScript = Join-Path $ownedRoot 'disposable-target.ps1'
    @'
$buffer = [byte[]]::new(64MB)
for ($offset = 0; $offset -lt $buffer.Length; $offset += 4096) { $buffer[$offset] = 1 }
Start-Sleep -Seconds 20
'@ | Set-Content -LiteralPath $targetScript -Encoding UTF8
    $target = Start-Process -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',$targetScript -PassThru -WindowStyle Hidden
    $result = Join-Path $ownedRoot 'worker result.txt'
    $handshake = Join-Path $ownedRoot 'worker handshake.txt'
    try {
        Start-Sleep -Milliseconds 500
        if ($target.HasExited) { throw 'Disposable target exited before protocol probe' }
        $arguments = @(
        "/pid=$($target.Id)", '/profile=3', '/protect-foreground=0', '/protocol=2', "/session=$session",
        ('/result="{0}"' -f $result), ('/handshake="{0}"' -f $handshake)
        )
        $exitCode = Invoke-Worker -Arguments $arguments
    }
    finally {
        if (-not $target.HasExited) {
            Stop-Process -Id $target.Id -Force -ErrorAction SilentlyContinue
            $target.WaitForExit(5000) | Out-Null
        }
        $target.Dispose()
    }
    if ($exitCode -ne 0) { throw "Protocol fixture returned $exitCode" }
    if (-not (Test-Path -LiteralPath $handshake -PathType Leaf)) { throw 'Pre-mutation handshake was not created' }
    if (-not (Test-Path -LiteralPath $result -PathType Leaf)) { throw 'Terminal result was not created' }

    $handshakeFields = @{}
    foreach ($line in Get-Content -LiteralPath $handshake) {
        $parts = $line -split '=',2
        if ($parts.Count -eq 2) { $handshakeFields[$parts[0]] = $parts[1] }
    }
    if ($handshakeFields.protocol -ne '2' -or $handshakeFields.session -ne $session -or $handshakeFields.state -ne 'ready') {
        throw 'Handshake protocol/session/state mismatch'
    }

    $lines = @(Get-Content -LiteralPath $result)
    $fields = @{}
    foreach ($line in $lines) {
        $parts = $line -split '=',2
        if ($parts.Count -eq 2 -and $parts[0] -ne 'record') { $fields[$parts[0]] = $parts[1] }
    }
    if ($fields.protocol -ne '2' -or $fields.session -ne $session) { throw 'Result protocol/session mismatch' }
    if ($fields.terminal -notin @('done','partial')) { throw "Invalid terminal status: $($fields.terminal)" }
    if ($fields.mutated -notin @('0','1')) { throw 'Result omitted mutation state' }
    $records = @($lines | Where-Object { $_ -like 'record=*' })
    if ([int]$fields.record_count -ne $records.Count) { throw 'Declared record count does not match payload' }
    $measuredRecords = 0
    $unmeasuredRecords = 0
    foreach ($record in $records) {
        $parts = ($record.Substring(7)) -split '\|',7
        if ($parts.Count -ne 7) { throw "Malformed target record: $record" }
        if ($parts[0] -notmatch '^\d+$' -or $parts[1] -notmatch '^[0-9A-Fa-f]{16}$') { throw 'Target identity lacks PID/creation time' }
        if ($parts[5] -notin @('measured','after_unknown','identity_changed')) { throw "Unknown target status: $($parts[5])" }
        if ($parts[5] -eq 'measured') { $measuredRecords++ } else { $unmeasuredRecords++ }
    }
    $metricValues = @{}
    foreach ($line in $lines) {
        $parts = $line -split '=',2
        if ($parts.Count -eq 2 -and $parts[0] -in @('measured','unmeasured')) { $metricValues[$parts[0]] = [int]$parts[1] }
    }
    if (-not $metricValues.ContainsKey('measured') -or -not $metricValues.ContainsKey('unmeasured') -or
        $metricValues.measured -ne $measuredRecords -or $metricValues.unmeasured -ne $unmeasuredRecords) {
        throw 'Measured/unmeasured metrics do not reconcile with target records'
    }

    Write-Output "Windows worker protocol v2 passed: $([IO.Path]::GetFileName($WorkerPath))"
}
finally {
    if (Test-Path -LiteralPath $ownedRoot) {
        $resolved = [IO.Path]::GetFullPath($ownedRoot)
        $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        if (-not $resolved.StartsWith($temp, [StringComparison]::OrdinalIgnoreCase) -or
            -not (Split-Path -Leaf $resolved).StartsWith('ReduceMemory-protocol-', [StringComparison]::Ordinal)) {
            throw "Refusing to remove unexpected fixture directory: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
