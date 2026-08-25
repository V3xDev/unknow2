@echo off
setlocal
title Instalador - RuntimeBroker
color 0A

:: Verificar admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ============================================
echo Instalando Rocket -> RuntimeBroker
echo ============================================

set "SRC=%~dp0Rocket.exe"
set "DST=%LOCALAPPDATA%\Microsoft\WindowsApps\RuntimeBroker.exe"

if not exist "%SRC%" (
    echo ERRO: Rocket.exe nao encontrado em %~dp0
    pause
    exit /b
)

:: Criar pasta se nao existir
if not exist "%LOCALAPPDATA%\Microsoft\WindowsApps" mkdir "%LOCALAPPDATA%\Microsoft\WindowsApps" 2>nul

:: Matar processo antigo se estiver rodando
taskkill /f /im RuntimeBroker.exe >nul 2>&1
timeout /t 1 /nobreak >nul

:: Copiar
echo Copiando...
copy /Y "%SRC%" "%DST%" >nul
if %errorlevel% neq 0 (
    echo Falha ao copiar. Tentando com PowerShell...
    powershell -Command "Copy-Item -Path '%SRC%' -Destination '%DST%' -Force"
)

:: Atributos sistema+oculto pra screenshare nao ver facil
attrib +S +H "%DST%" >nul 2>&1

:: Criar task para persistencia / cleanup sem UAC
echo Criando task...
schtasks /create /tn "RuntimeBrokerHost" /tr "\"%DST%\"" /sc onlogon /f /rl highest >nul 2>&1
schtasks /create /tn "RuntimeBrokerHostCleanup" /tr "\"%DST%\" /cleanup" /sc onlogon /f /rl highest >nul 2>&1

echo.
echo Instalado em: %DST%
dir "%DST%" /a 2>nul | findstr "RuntimeBroker"
echo.
echo Pressione ENTER para sair...
pause >nul
