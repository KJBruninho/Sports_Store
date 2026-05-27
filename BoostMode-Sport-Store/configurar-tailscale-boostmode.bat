@echo off
setlocal enabledelayedexpansion

REM =========================================================
REM Configurar Tailscale Serve para BoostMode
REM Spring Boot local: http://127.0.0.1:8080
REM Tailscale externo: https://boostmode.paradise-byzantine.ts.net/
REM =========================================================

set SERVICE_NAME=svc:boostmode
set LOCAL_APP=http://127.0.0.1:8080
set TAG=tag:SD-group
set PUBLIC_URL=https://boostmode.paradise-byzantine.ts.net/

cls
echo ========================================
echo   BoostMode - Configurar Tailscale
echo ========================================
echo.

REM Verificar se esta em modo administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Este ficheiro deve ser executado como Administrador.
    echo.
    echo Fecha esta janela, clica com o botao direito no .bat
    echo e escolhe "Executar como administrador".
    echo.
    pause
    exit /b 1
)

REM Verificar se Tailscale existe
where tailscale >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Tailscale nao foi encontrado no PATH.
    echo Instala o Tailscale ou reinicia o terminal depois da instalacao.
    echo.
    pause
    exit /b 1
)

echo [1/5] A verificar se a app local esta ativa em %LOCAL_APP% ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%LOCAL_APP%' -UseBasicParsing -TimeoutSec 5 | Out-Null; exit 0 } catch { exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] A app Spring Boot nao respondeu em %LOCAL_APP%.
    echo Se continuares, o Tailscale pode abrir mas devolver 502 Bad Gateway.
    echo.
    choice /C SN /M "Queres continuar mesmo assim? S=Sim N=Nao"
    if errorlevel 2 exit /b 1
)

echo.
echo [2/5] A aplicar tag %TAG% ao dispositivo...
tailscale up --advertise-tags=%TAG% --advertise-exit-node
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] Falhou com a configuracao atual. Vou tentar com --reset.
    echo Isto pode remover flags antigas do Tailscale neste dispositivo.
    echo.
    choice /C SN /M "Continuar com reset? S=Sim N=Nao"
    if errorlevel 2 exit /b 1

    tailscale up --reset --advertise-tags=%TAG%
    if !errorlevel! neq 0 (
        echo.
        echo [ERRO] Nao foi possivel aplicar a tag %TAG%.
        echo Confirma no painel Tailscale se a tag existe nos ACLs.
        echo.
        pause
        exit /b 1
    )
)

echo.
echo [3/5] A limpar configuracao anterior do service...
tailscale serve --service=%SERVICE_NAME% --https=443 off >nul 2>&1
tailscale serve clear %SERVICE_NAME% >nul 2>&1

echo.
echo [4/5] A configurar HTTPS 443 para %LOCAL_APP% ...
tailscale serve --bg --service=%SERVICE_NAME% --https=443 %LOCAL_APP%
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falhou ao configurar o Tailscale Serve.
    echo.
    pause
    exit /b 1
)

echo.
echo [5/5] Estado atual do Tailscale Serve:
echo ----------------------------------------
tailscale serve status
echo ----------------------------------------

echo.
echo ========================================
echo   Configuracao concluida.
echo ========================================
echo.
echo URL esperado:
echo %PUBLIC_URL%
echo.
echo Notas:
echo - No painel Tailscale, o service boostmode deve ter endpoint tcp:443.
echo - Se aparecer "approval required", aprova o host no painel Tailscale.
echo - Se aparecer 502 Bad Gateway, arranca a app Spring Boot em 127.0.0.1:8080.
echo.
echo A abrir o site no browser...
start %PUBLIC_URL%
echo.
pause
