$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$taskPidFile = Join-Path $taskRoot '.data\processes.json'
if (Test-Path -LiteralPath $taskPidFile) {
    foreach ($taskRecord in @(Get-Content -LiteralPath $taskPidFile -Raw | ConvertFrom-Json)) {
        $taskProcess = Get-CimInstance Win32_Process -Filter "ProcessId=$($taskRecord.id)" -ErrorAction SilentlyContinue
        if ($taskProcess -and $taskProcess.Name -eq 'node.exe' -and $taskProcess.CommandLine -like "*$taskRoot*") { Stop-Process -Id $taskRecord.id }
    }
}
& (Join-Path $taskRoot '.data\pg-runtime\pgsql\bin\pg_ctl.exe') -D (Join-Path $taskRoot '.data\postgres17') -m fast -w stop
Write-Output '金融早报已停止。'
