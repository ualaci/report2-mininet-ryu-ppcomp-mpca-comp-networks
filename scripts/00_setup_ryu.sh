#!/bin/bash

echo "=== [Setup] Configuração do Ambiente Ryu ==="

RYU_DIR="/workspace/ryu"

# Verifica se o repositório do Ryu já foi clonado
if [ ! -d "$RYU_DIR" ]; then
    echo "[Setup] Clonando repositório do Ryu..."
    git clone https://github.com/osrg/ryu.git "$RYU_DIR"
else
    echo "[Setup] Repositório do Ryu já existe em $RYU_DIR. Pulando clone."
fi

# Verifica se a biblioteca Ryu já está instalada
if pip3 show ryu > /dev/null 2>&1; then
    echo "[Setup] Controlador Ryu já está instalado no ambiente Python. Pulando instalação."
else
    echo "[Setup] Atualizando pip e instalando Ryu..."
    python3 -m pip install --upgrade pip
    
    cd "$RYU_DIR"
    python3 -m pip install .
    
    # Prevenção de compatibilidade: dependências antigas do ryu podem quebrar em versões recentes do eventlet
    echo "[Setup] Ajustando dependências para garantir compatibilidade (eventlet)..."
    python3 -m pip install eventlet==0.30.2
    echo "[Setup] Instalação concluída!"
fi

echo "=== [Setup] Ambiente de dependências pronto! ==="
