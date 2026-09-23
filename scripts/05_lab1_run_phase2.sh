#!/bin/bash

LOG_FILE="relatorio_phase2.md"

echo "=== Iniciando a Execução da Fase 2 (Topologia Customizada) ==="
echo "O log detalhado será salvo no arquivo: $LOG_FILE"
echo ""

# Limpa o arquivo de log
> "$LOG_FILE"

echo "# Relatório da Fase 2 do Mininet" >> "$LOG_FILE"
echo "Este relatório contém a execução do script Python customizado de 4 Switches e 11 Hosts." >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo '```text' >> "$LOG_FILE"

# Rodando o script Python e espelhando a saída para o console e para o arquivo de log
# 2>&1 garante que todos os logs de INFO do Mininet (que saem em stderr) também sejam salvos
sudo python3 -u ./scripts/lab1_phase2.py 2>&1 | tee -a "$LOG_FILE"

echo '```' >> "$LOG_FILE"

echo ""
echo "=== Execução Concluída! ==="
echo "Verifique o arquivo $LOG_FILE para ver os resultados do iperf e pingall."
