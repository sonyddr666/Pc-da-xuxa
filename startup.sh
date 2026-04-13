#!/usr/bin/env bash
# Removido set -euo pipefail para nao matar o container
# se algum servico demorar para subir

export USER=app
export HOME=/home/app
export DISPLAY=${DISPLAY:-:1}

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
chown -R app:app /home/app

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
