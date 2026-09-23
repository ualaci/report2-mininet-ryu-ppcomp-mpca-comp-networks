#!/bin/bash

echo "=== Passo 4: Iniciar Controlador Ryu ==="
echo "Aplicação: simple_switch_13"
echo "[Pressione Ctrl+C para encerrar o controlador]"
echo "---------------------------------------------------------"

# Como instalamos o Ryu com pip, o ryu-manager estará disponível no path
ryu-manager --verbose ryu.app.simple_switch_13
