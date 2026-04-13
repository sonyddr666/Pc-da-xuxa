@echo off
setlocal
chcp 65001 >nul

:: 🔧 CONFIGURAÇÕES
set IMAGE_NAME=ubuntu-desktop-custom
set CONTAINER_NAME=desktop-custom-app
set PLATFORM_ARG=

:: 🛠️ PARSE ARGUMENTOS
if "%~1"=="--amd64" (
    set PLATFORM_ARG=--platform linux/amd64
)

:: Se a plataforma foi fixada no gerador, prioriza ela
if not "auto"=="auto" (
    set PLATFORM_ARG=--platform linux/auto
)

echo 🔨 Buildando imagem Docker...
docker build %PLATFORM_ARG% -t %IMAGE_NAME% .
if %errorlevel% neq 0 (
    echo ❌ Erro no build! Verifique a mensagem acima.
    pause
    exit /b %errorlevel%
)

echo 🧹 Verificando container antigo...
for /f "tokens=*" %%i in ('docker ps -aq -f name^=%CONTAINER_NAME%') do set OLD_CONTAINER=%%i
if not "%OLD_CONTAINER%"=="" (
    echo ⚠️ Container existente encontrado. Removendo...
    docker rm -f %CONTAINER_NAME%
)

echo 🚀 Subindo novo container...
docker run -d ^
    %PLATFORM_ARG% ^
    --name %CONTAINER_NAME% ^
    --hostname pc-da-xuxa ^
    --security-opt seccomp=unconfined ^
    -p 9999:8080 ^
    -p 5905:5900 ^
    --shm-size=2g ^
    --restart unless-stopped ^
    %IMAGE_NAME%

echo ✅ Container iniciado com sucesso!
echo 🌐 Acesse: http://localhost:9999 
pause
