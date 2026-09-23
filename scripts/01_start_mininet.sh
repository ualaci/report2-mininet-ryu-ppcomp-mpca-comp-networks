#!/bin/bash

echo "=== Passo 1: Iniciar Mininet ==="
echo "Topologia: 1 switch (ovsk, OpenFlow 1.3), 3 hosts"
echo "Controlador: Remoto"
echo ""
echo "[Aviso] A emulação bloqueará este terminal aguardando comandos do mininet (mininet>)."
echo "Para executar os demais passos do laboratório, abra outros terminais com:"
echo "docker exec -it ryu_mininet_lab bash"
echo "---------------------------------------------------------"

# Limpa sujeiras de execuções anteriores do Mininet
mn -c 2>/dev/null

# Inicia a topologia
mn --topo single,3 --mac --controller remote --switch ovsk,protocols=OpenFlow13
