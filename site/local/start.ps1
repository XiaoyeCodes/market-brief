$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$taskNode = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
if (!(Test-Path -LiteralPath $taskNode)) { $taskNode = (Get-Command node).Source }
$taskPg = Join-Path $taskRoot '.data\pg-runtime\pgsql\bin\pg_ctl.exe'
$taskData = Join-Path $taskRoot '.data\postgres17'
$taskLog = Join-Path $taskRoot '.data'
$env:NODE_ENV = 'production'
$env:API_HOST = '127.0.0.1'
$env:WEB_HOST = '127.0.0.1'
& $taskPg -D $taskData status *> $null
if ($LASTEXITCODE -ne 0) {
    if (Get-NetTCPConnection -State Listen -LocalPort 55437 -ErrorAction SilentlyContinue) { throw 'Database port 55437 is occupied.' }
    & $taskPg -D $taskData -l (Join-Path $taskLog 'postgres17.log') -o '-h 127.0.0.1 -p 55437 -c max_connections=120' -w start
    if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL failed to start.' }
}
$taskProcesses = @()
foreach ($taskService in @(@{name='api'; file='apps/api/src/main.ts'; dir=$taskRoot; port=3001}, @{name='web'; file='server.ts'; dir=(Join-Path $taskRoot 'apps\web'); port=3000})) {
    $taskListener = Get-NetTCPConnection -State Listen -LocalPort $taskService.port -ErrorAction SilentlyContinue
    if ($taskListener) {
        $taskExisting = Get-CimInstance Win32_Process -Filter "ProcessId=$($taskListener.OwningProcess)"
        if ($taskExisting.ExecutablePath -ne $taskNode -or $taskExisting.CommandLine -notlike "*$taskRoot*") { throw "Port $($taskService.port) is occupied by another application." }
        $taskProcesses += @{name=$taskService.name;id=$taskListener.OwningProcess}
        continue
    }
    $taskEnvFile = Join-Path $taskRoot '.env'
    $taskEntryFile = Join-Path $taskService.dir $taskService.file
    $taskProcess = Start-Process -FilePath $taskNode -ArgumentList @("--env-file=`"$taskEnvFile`"", "`"$taskEntryFile`"") -WorkingDirectory $taskService.dir -WindowStyle Hidden -RedirectStandardOutput (Join-Path $taskLog ($taskService.name+'.out.log')) -RedirectStandardError (Join-Path $taskLog ($taskService.name+'.err.log')) -PassThru
    $taskProcesses += @{name=$taskService.name;id=$taskProcess.Id}
}
# The preview deliberately runs no worker: configure a model API before enabling automatic processing.
$taskProcesses | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskLog 'processes.json')
for ($taskTry=0; $taskTry -lt 30; $taskTry++) {
    try { $taskResponse=Invoke-WebRequest 'http://127.0.0.1:3000/api/health' -UseBasicParsing -TimeoutSec 2; if ($taskResponse.StatusCode -eq 200) { Write-Output 'Finance Morning is running: http://localhost:3000'; exit 0 } } catch { Start-Sleep -Milliseconds 500 }
}
throw 'Startup check failed. Inspect .data/api.err.log and .data/web.err.log.'
