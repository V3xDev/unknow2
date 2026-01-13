@echo off
:: ========================================
::  CRIAR TAREFA AGENDADA
::  Script dedicado para criar apenas a tarefa
:: ========================================

title Criar Tarefa Agendada
color 0B

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    pause
    exit /b 1
)

:: Configurações
set "PASTA=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "ARQUIVO=windowshost.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"

echo.
echo ========================================
echo    CRIAR TAREFA AGENDADA
echo ========================================
echo.

:: Verificar se arquivo existe
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao encontrado: %CAMINHO%
    echo [INFO] Execute install.bat primeiro para instalar o Rocket.exe
    echo.
    pause
    exit /b 1
)

echo [INFO] Arquivo encontrado: %CAMINHO%
echo [INFO] Criando tarefa: %TAREFA%
echo.

:: Remover tarefa antiga se existir
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Removendo tarefa antiga...
    schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
    timeout /t 2 /nobreak >nul
)

:: Método 1: schtasks (mais confiável)
echo [1/3] Tentando metodo schtasks...
schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f
if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    schtasks /query /tn "%TAREFA%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada com sucesso via schtasks!
        echo.
        echo [INFO] Verificando detalhes da tarefa:
        schtasks /query /tn "%TAREFA%" /fo list | findstr /i "TaskName\|Status\|Task To Run"
        echo.
        goto :SUCCESS
    )
)

:: Método 2: PowerShell
echo [2/3] Tentando metodo PowerShell...
powershell -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force | Out-Null; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED: ' $_.Exception.Message; exit 1 }"

if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    schtasks /query /tn "%TAREFA%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada com sucesso via PowerShell!
        echo.
        echo [INFO] Verificando detalhes da tarefa:
        schtasks /query /tn "%TAREFA%" /fo list | findstr /i "TaskName\|Status\|Task To Run"
        echo.
        goto :SUCCESS
    )
)

:: Método 3: XML
echo [3/3] Tentando metodo XML...
powershell -ExecutionPolicy Bypass -Command "$xml='<?xml version=\"1.0\" encoding=\"UTF-16\"?><Task version=\"1.2\" xmlns=\"http://schemas.microsoft.com/windows/2004/02/mit/task\"><RegistrationInfo><Date>2020-01-01T00:00:00</Date><Description>Componente de Host de Aplicativos do Windows</Description></RegistrationInfo><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger></Triggers><Principals><Principal id=\"Author\"><UserId>%USERNAME%</UserId><RunLevel>Highest</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable><IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><RunOnlyIfIdle>false</RunOnlyIfIdle><WakeToRun>false</WakeToRun><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Priority>7</Priority></Settings><Actions Context=\"Author\"><Exec><Command>%CAMINHO%</Command></Exec></Actions></Task>'; $xmlFile='%TEMP%\task_rocket.xml'; $xml | Out-File -FilePath $xmlFile -Encoding Unicode -Force; $result=schtasks /create /tn '%TAREFA%' /xml $xmlFile /f 2>&1; Remove-Item $xmlFile -Force -ErrorAction SilentlyContinue; if ($LASTEXITCODE -eq 0) { Write-Host 'SUCCESS' } else { Write-Host 'FAILED'; exit 1 }"

if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    schtasks /query /tn "%TAREFA%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada com sucesso via XML!
        echo.
        echo [INFO] Verificando detalhes da tarefa:
        schtasks /query /tn "%TAREFA%" /fo list | findstr /i "TaskName\|Status\|Task To Run"
        echo.
        goto :SUCCESS
    )
)

:: Falha
echo.
echo [ERRO] Todos os metodos falharam!
echo.
echo [DEBUG] Informacoes:
echo   Caminho: %CAMINHO%
echo   Tarefa: %TAREFA%
echo   Usuario: %USERNAME%
echo.
echo [SOLUCAO MANUAL] Execute este comando:
echo   schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f
echo.
pause
exit /b 1

:SUCCESS
echo ========================================
echo    TAREFA CRIADA COM SUCESSO!
echo ========================================
echo.
echo [OK] Tarefa: %TAREFA%
echo [OK] Arquivo: %CAMINHO%
echo [OK] Executara 30 segundos apos o proximo logon
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
exit
