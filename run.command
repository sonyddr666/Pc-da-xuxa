#!/usr/bin/env bash
set -e

# Muda o diretório atual para a pasta do script (Necessário no macOS ao dar duplo-clique no run.command)
cd "$(dirname "$0")"

# 🔧 CONFIGURAÇÕES
IMAGE_NAME="ubuntu-desktop-custom"
CONTAINER_NAME="desktop-custom-app"
PLATFORM_VAL=""

# 🛠️ PARSE ARGUMENTOS
for arg in "$@"; do
  case $arg in
    --amd64)
      PLATFORM_VAL="linux/amd64"
      shift
      ;;
  esac
done

# Se a plataforma foi fixada no gerador, prioriza ela
if [ "auto" != "auto" ]; then
    PLATFORM_VAL="linux/auto"
fi

# Monta o argumento de plataforma se necessário
PLATFORM_ARG=""
if [ -n "$PLATFORM_VAL" ]; then
    PLATFORM_ARG="--platform $PLATFORM_VAL"
fi

echo "🔨 Buildando imagem Docker..."
# Usamos eval para garantir que o PLATFORM_ARG seja expandido corretamente em múltiplos argumentos se necessário
eval "docker build $PLATFORM_ARG -t $IMAGE_NAME ." || { 
    echo "❌ Erro no build! Verifique a mensagem acima."
    printf "Pressione Enter para fechar..."
    read -r
    exit 1
}

echo "🧹 Verificando container antigo..."

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "⚠️ Container existente encontrado. Removendo..."
    docker rm -f $CONTAINER_NAME
fi

echo "🚀 Subindo novo container..."

eval "docker run -d $PLATFORM_ARG --name $CONTAINER_NAME --hostname pc-da-xuxa --security-opt seccomp=unconfined -p 9999:8080 -p 5905:5900  --shm-size=2g --restart unless-stopped $IMAGE_NAME"

echo "✅ Container iniciado com sucesso!"
echo "🌐 Acesse: http://localhost:9999 "
