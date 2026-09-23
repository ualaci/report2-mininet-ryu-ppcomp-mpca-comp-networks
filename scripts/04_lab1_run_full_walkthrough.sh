#!/bin/bash

LOG_FILE="relatorio_full_walkthrough.md"

echo "=== Iniciando execução COMPLETA do Walkthrough do Mininet ==="
echo "O log será salvo no arquivo: $LOG_FILE"
echo "Lembre-se de deixar o Ryu rodando em outro terminal."
echo ""

# Limpa o arquivo de log se já existir
> "$LOG_FILE"

echo "# Relatório do Mininet Walkthrough" >> "$LOG_FILE"
echo "Este relatório contém a execução de TODAS as etapas do tutorial oficial." >> "$LOG_FILE"

# Função auxiliar para rodar comandos fora do CLI do Mininet (como os de teste)
run_external_cmd() {
    local desc="$1"
    local cmd="$2"
    echo -e "\n## $desc" | tee -a "$LOG_FILE"
    echo "> Comando: \`$cmd\`" | tee -a "$LOG_FILE"
    echo '```text' >> "$LOG_FILE"
    eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
    echo '```' >> "$LOG_FILE"
}

# ==========================================
# PART 1: Everyday Mininet Usage
# ==========================================
run_external_cmd "Parte 1: Display Startup Options" "sudo mn -h"

echo -e "\n## Parte 1: Interact with Hosts and Switches / Test Connectivity / Web Server" | tee -a "$LOG_FILE"
echo "Executando sessão interativa no Mininet..." | tee -a "$LOG_FILE"

# Função para enviar os comandos pausadamente (0.2s) para o Mininet.
# Isso resolve o famoso bug de corrida de buffer (onde as letras sumiam ou se misturavam).
slow_feed() {
    while IFS= read -r line; do
        echo "$line"
        sleep 0.2
    done
}

# Limpa sujeira antes de iniciar
sudo mn -c >/dev/null 2>&1

echo '```text' >> "$LOG_FILE"
# Executa os comandos interativos usando o slow_feed
slow_feed << 'EOF' | sudo mn --controller remote 2>&1 | grep -v "mininet>" | tee -a "$LOG_FILE"

py print("\n--- Interact with Hosts and Switches ---")
py print(">> Comando: nodes")
nodes
py print(">> Comando: net")
net
py print(">> Comando: dump")
dump
py print(">> Comando: h1 ifconfig -a")
h1 ifconfig -a
py print(">> Comando: s1 ifconfig -a")
s1 ifconfig -a
py print(">> Comando: h1 ps -a")
h1 ps -a

py print("\n--- Test connectivity between hosts ---")
py print(">> Comando: h1 ping -c 1 h2")
h1 ping -c 1 h2
py print(">> Comando: pingall")
pingall

py print("\n--- Run a simple web server and client ---")
py print(">> Comando: h1 python3 -m http.server 80 &")
h1 python3 -m http.server 80 </dev/null >/dev/null 2>&1 &
py print(">> Comando: h2 curl -s h1")
h2 curl -s h1
py print(">> Comando: h1 kill %python3")
h1 kill %python3

exit
EOF
echo '```' >> "$LOG_FILE"


# ==========================================
# PART 2: Advanced Startup Options
# ==========================================
# Aqui os comandos são todos passados diretamente pro executável do mininet,
# o que é muito mais limpo do que usar o CLI interativo.

run_external_cmd "Parte 2: Run a Regression Test (Pingpair)" "sudo mn --test pingpair --controller remote"
run_external_cmd "Parte 2: Run a Regression Test (Iperf)" "sudo mn --test iperf --controller remote"

run_external_cmd "Parte 2: Changing Topology Size and Type (Single, 3)" "sudo mn --test pingall --topo single,3 --controller remote"
run_external_cmd "Parte 2: Changing Topology Size and Type (Linear, 4)" "sudo mn --test pingall --topo linear,4 --controller remote"

run_external_cmd "Parte 2: Link variations (Testando Iperf com Delay e Bandwidth)" "sudo mn --link tc,bw=10,delay=10ms --test iperf --controller remote"

run_external_cmd "Parte 2: Adjustable Verbosity (Debug)" "sudo mn -v debug --test none --controller remote"

run_external_cmd "Parte 2: ID = MAC (Forçando MACs legíveis)" "sudo mn --mac --test pingall --controller remote"

run_external_cmd "Parte 2: Other Switch Types (User Space Switch)" "sudo mn --switch user --test iperf --controller remote"
run_external_cmd "Parte 2: Other Switch Types (OVS Kernel Switch)" "sudo mn --switch ovsk --test iperf --controller remote"

run_external_cmd "Parte 2: Mininet Benchmark" "sudo mn --test none --controller remote"


# ==========================================
# PART 3: Mininet CLI Commands
# ==========================================
echo -e "\n## Parte 3: CLI Commands (Python Interpreter e Link Up/Down)" | tee -a "$LOG_FILE"
echo "Executando sessão interativa para a Parte 3..." | tee -a "$LOG_FILE"

sudo mn -c >/dev/null 2>&1

echo '```text' >> "$LOG_FILE"
slow_feed << 'EOF' | sudo mn --controller remote 2>&1 | grep -v "mininet>" | tee -a "$LOG_FILE"

py print("\n--- Python Interpreter ---")
py print(">> Comando: py 'hello ' + 'world'")
py 'hello ' + 'world'
py print(">> Comando: py dir(s1)")
py dir(s1)
py print(">> Comando: py h1.IP()")
py h1.IP()

py print("\n--- Link Up/Down ---")
py print(">> Comando: link s1 h1 down")
link s1 h1 down
py print(">> Comando: pingall (Com link caido)")
pingall
py print(">> Comando: link s1 h1 up")
link s1 h1 up
py print(">> Comando: pingall (Com link restaurado)")
pingall

exit
EOF
echo '```' >> "$LOG_FILE"

echo ""
echo "=== Execução Concluída com Sucesso! ==="
echo "O relatório completo e limpo foi gerado em: $LOG_FILE"
