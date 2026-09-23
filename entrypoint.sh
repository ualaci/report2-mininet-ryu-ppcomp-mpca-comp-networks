#!/bin/bash
set -e

echo "[Entrypoint] Iniciando serviço openvswitch-switch..."
service openvswitch-switch start

echo "[Entrypoint] Executando script de configuração inicial (Setup)..."
if [ -f "/workspace/scripts/00_setup_ryu.sh" ]; then
    bash /workspace/scripts/00_setup_ryu.sh
fi

echo "[Entrypoint] Configuração concluída! Container pronto."
exec "$@"
