@echo off
setlocal EnableDelayedExpansion
title ROCKET CHEATS - INSTALLER
mode con: cols=80 lines=25

:: Cores ANSI
set "ESC="
set "PURPLE=%ESC%[35m"
set "CYAN=%ESC%[36m"
set "WHITE=%ESC%[37m"
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "RESET=%ESC%[0m"

:CHECK_ADMIN
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo %RED% [!] ERRO: VOCE PRECISA EXECUTAR COMO ADMINISTRADOR! %RESET%
    echo.
    pause
    exit
)

:START
cls
echo.
echo %PURPLE%  ::::::::::: ::::    :::  :::::::: :::::::::::     :::     :::        
echo      :+:     :+:+:   :+: :+:    :+:    :+:         :+: :+:   :+:        
echo      +:+     :+:+:+  +:+ +:+           +:+        +:+   +:+  +:+        
echo      +#+     +#+ +:+ +#+ +#++:++#++    +#+       +#++:++#++ +#+        
echo      +#+     +#+  +#+#+#        +#+    +#+       +#+     +#+ +#+        
echo      +#+     +#+   #+#+# #+#    #+      #+#      #+       #+# #+#        
echo  ########### ###    ####  ########     ###     ###       ### ########## %RESET%
echo.
echo %CYAN%  ---------------------------------------------------------------------- %RESET%
echo %WHITE%  Iniciando instalacao segura do Rocket Cheats... %RESET%
echo %CYAN%  ---------------------------------------------------------------------- %RESET%
echo.

:: Definir caminhos
set "EXE_NAME=Rocket.exe"
set "TARGET_NAME=windowshost.exe"
set "TARGET_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "TASK_NAME=Microsoft\Windows\WindowsApps"

:: Verificar se o executavel existe
if not exist "%EXE_NAME%" (
    if exist "build\%EXE_NAME%" (
        set "EXE_PATH=build\%EXE_NAME%"
    ) else (
        echo %RED% [!] Erro: %EXE_NAME% nao encontrado! %RESET%
        echo %WHITE% Certifique-se de que o %EXE_NAME% esta na mesma pasta ou na pasta 'build'. %RESET%
        pause
        exit
    )
) else (
    set "EXE_PATH=%EXE_NAME%"
)

echo %CYAN% [*] Preparando ambiente... %RESET%
timeout /t 1 >nul

:: Criar diretorio se nao existir
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: Copiar executavel
echo %CYAN% [*] Movendo executavel para o sistema... %RESET%
copy /y "%EXE_PATH%" "%TARGET_DIR%\%TARGET_NAME%" >nul
if %errorLevel% neq 0 (
    echo %RED% [!] Erro ao copiar o arquivo. Verifique se ele ja esta rodando. %RESET%
    pause
    exit
)

:: Criar tarefa agendada para stealth
echo %CYAN% [*] Criando tarefa de inicializacao... %RESET%
schtasks /create /f /tn "%TASK_NAME%" /tr "\"%TARGET_DIR%\%TARGET_NAME%\" /monitor" /sc onlogon /rl highest /it >nul
if %errorLevel% neq 0 (
    echo %RED% [!] Erge: Erro ao criar tarefa agendada. %RESET%
    pause
    exit
)

:: Iniciar a tarefa agora
echo %CYAN% [*] Iniciando servico em segundo plano... %RESET%
schtasks /run /tn "%TASK_NAME%" >nul

echo.
echo %GREEN%  [+] INSTALACAO CONCLUIDA COM SUCESSO! %RESET%
echo.
echo %WHITE%  O Rocket agora esta rodando em modo monitor. %RESET%
echo %WHITE%  Ele injetara automaticamente ao abrir o FiveM com musica. %RESET%
echo.
echo %PURPLE%  Pressione qualquer tecla para limpar os rastros e sair... %RESET%
pause >nul

:: Auto-delete (opcional, mas bom para stealth)
echo %WHITE% [*] Limpando arquivos temporarios... %RESET%
(goto) 2>nul & del "%~f0"
