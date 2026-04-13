#!/usr/bin/env bash
set -euo pipefail

export USER=app
export HOME=/home/app
export DISPLAY=${DISPLAY:-:1}

mkdir -p /tmp/.X11-unix
chown -R app:app /home/app

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
