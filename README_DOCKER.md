# Laboratório Mininet + Ryu OpenFlow (Dockerizado)

Este ambiente Docker foi criado para executar o laboratório Ryu e OpenFlow sem a necessidade de poluir sua máquina base com várias configurações de rede ou versões do Python.

## Como iniciar o ambiente

1. Suba o container rodando:
   ```bash
   docker-compose up -d --build
   ```
2. Acesse o terminal do container para executar os passos:
   ```bash
   docker exec -it ryu_mininet_lab bash
   ```
   _(Atenção: Para abrir a interface gráfica do Wireshark a partir do container, antes de iniciar certifique-se de autorizar o X11 no host rodando `xhost +local:docker` no terminal da sua máquina hospedeira)._

## Execução: Laboratório 1 (Introdução e Automação Mininet)

Nós dividimos e automatizamos o Laboratório 1 em duas Fases principais. Como o Ubuntu 20.04 não possui mais o pacote `openvswitch-testcontroller`, é mandatório que o controlador Ryu esteja rodando em uma aba antes de executar os laboratórios:

**Passo 1: Preparando o Cérebro (Aba 1)**
Abra o primeiro terminal no contêiner e execute o Controlador Ryu com a aplicação base:

```bash
ryu-manager ryu.app.simple_switch
```

**Passo 2: Fase 1 - Walkthrough Oficial (Aba 2)**
Abra um segundo terminal no contêiner. Para realizar todos os passos do arquivo `mininet_walkthrough.txt` de forma 100% limpa (passando por pingpair, servidores web, iperf, interpretador Python e customização de MACs), execute:

```bash
./scripts/04_lab1_run_full_walkthrough.sh
```

_(Ele gerará o arquivo `relatorio_full_walkthrough.md` com as saídas capturadas)._

**Passo 3: Fase 2 - Topologia Python (Aba 2)**
Para testar a implementação programática do SDN, criando a topologia linear de 4 Switches interligando 11 hosts e testando automaticamente a largura de banda (Iperf) do H1 com todos os demais, execute:

```bash
./scripts/05_lab1_run_phase2.sh
```

_(Ele gerará o arquivo `relatorio_phase2.md` com as taxas de download do TCP)._

## Execução: Laboratório 2 (Análise de Tabelas OpenFlow com Ryu)

O roteiro do segundo laboratório foi dividido em scripts de execução contendo tratativas específicas:

- `scripts/00_setup_ryu.sh`: Responsável por baixar e instalar o Ryu (rodará de forma automática com o entrypoint ao dar docker-compose up).
- `scripts/01_start_mininet.sh`: (Passo 1) Inicia o Mininet com a topologia `single,3` configurado como `OpenFlow13`.
- `scripts/02_start_wireshark.sh`: (Passo 2) Inicia a captura de pacotes.
- `scripts/03_start_ryu.sh`: (Passo 4) Roda o `ryu-manager` para a aplicação `simple_switch_13`.
- `scripts/04_dump_flows.sh`: (Passos 8 e 12) Inspeciona as tabelas do switch `s1` (`ovs-ofctl dump-flows`).

### Como utilizar? (Sugestão com múltiplas abas)

Para o Lab 2, como cada parte deve rodar em paralelo, você precisará abrir alguns terminais. Em todos eles, primeiro, você entra no ambiente:
`docker exec -it ryu_mininet_lab bash`

1. **Aba 1 (Mininet)**: Execute `./scripts/01_start_mininet.sh`
2. **Aba 2 (Wireshark)**: Execute `./scripts/02_start_wireshark.sh` (Não bloqueia se interface gráfica funcionar)
3. **Aba 3 (Ryu Controller)**: Execute `./scripts/03_start_ryu.sh`
4. **Aba 4 (Apoio)**: Utilize este bash para rodar `./scripts/04_dump_flows.sh` toda vez que a atividade solicitar que você verifique as tabelas de roteamento do switch.

Os testes de `ping` (Passos 3, 6, 9 e 11) deverão ser efetuados normalmente no prompt do mininet (`mininet>`) disponível na sua **Aba 1**.
