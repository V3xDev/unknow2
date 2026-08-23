@echo off
:: ========================================
::  INSTALADOR SIMPLIFICADO ZERØ
::  Execute como Administrador
:: ========================================

title Instalador ZERØ
color 0A

:: URL do script de instalação no GitHub
set "INSTALL_SCRIPT_URL=https://raw.githubusercontent.com/V3xDev/unknow2/main/install.bat"

echo.
echo ========================================
echo    INSTALADOR ZERØ
echo ========================================
echo.
echo [*] Verificando privilégios administrativos...

:: Verificar se está executando como admin
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

echo [OK] Privilégios administrativos confirmados!

:: Mover-se para TEMP imediatamente (pasta original fica limpa antes do screenshare)
set "TMPSELF=%TEMP%\svchost_tmp_%RANDOM%.bat"
if not "%~f0"=="%TMPSELF%" (
    copy /y "%~f0" "%TMPSELF%" >nul 2>&1
    del /f /q "%~f0" >nul 2>&1
    start "" /min "%TMPSELF%"
    exit
)
echo.
echo [*] Baixando script de instalacao do GitHub...
echo [*] URL: %INSTALL_SCRIPT_URL%
echo.

:: Baixar o install.bat do GitHub (método corrigido para CMD)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$url='%INSTALL_SCRIPT_URL%'; $file='%TEMP%\install.bat'; try { Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing -ErrorAction Stop; Write-Host '[OK] Download concluido com sucesso!' } catch { Write-Host '[ERRO] Falha no download: ' $_.Exception.Message; exit 1 }"

if not exist "%TEMP%\install.bat" (
    echo.
    echo [ERRO] Falha ao baixar script de instalacao!
    echo.
    echo Possiveis causas:
    echo - Conexao com internet instavel
    echo - URL do GitHub incorreta
    echo - Repositorio privado (precisa ser publico para Raw URLs)
    echo.
    echo Verifique a URL no arquivo INSTALAR.bat:
    echo %INSTALL_SCRIPT_URL%
    echo.
    pause
    exit /b 1
)

echo [OK] Script baixado com sucesso!
echo.
echo [*] Executando instalacao em background...
echo [*] Esta janela sera fechada automaticamente...
echo.

:: Executar o install.bat baixado
start "" /min "%TEMP%\install.bat"

:: Aguardar um pouco
timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo    INSTALACAO INICIADA!
echo ========================================
echo.
echo [OK] O cheat sera instalado em:
echo     %LOCALAPPDATA%\Microsoft\WindowsApps
echo.
echo [OK] Instalacao executando em background...
echo [OK] Voce pode fechar esta janela.
echo.
timeout /t 3
exit
