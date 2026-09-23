#!/bin/bash

echo "=== Passos 8 e 12: Dump das Tabelas de Fluxo ==="
echo "Exibindo entradas de fluxo instaladas no switch s1..."
echo "---------------------------------------------------------"

sudo ovs-ofctl dump-flows s1 -O OpenFlow13
