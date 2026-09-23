#!/bin/bash

echo "=== Passo 2: Iniciar Captura de Pacotes (Wireshark) ==="

if [ -n "$DISPLAY" ]; then
    echo "Ambiente gráfico detectado (DISPLAY=$DISPLAY)."
    echo "Iniciando Wireshark..."
    echo "[Dica] No Wireshark, aplique o filtro de captura 'openflow_v4' na barra verde."
    
    # Suprime output de console e roda no fundo
    wireshark -k -i any -f "tcp port 6633 or tcp port 6653" >/dev/null 2>&1 &
else
    echo "AVISO: DISPLAY gráfico não configurado."
    echo "Iniciando captura via Tshark em modo texto no terminal..."
    echo "[Pressione Ctrl+C para encerrar a captura de rede]"
    echo ""
    
    tshark -i any -d tcp.port==6633,openflow "tcp port 6633 or tcp port 6653 or openflow"
fi
