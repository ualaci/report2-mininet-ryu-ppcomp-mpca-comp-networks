# Relatório: Laboratórios de Redes (Mininet e Ryu)

## Laboratório 1: Introdução ao Mininet

### 1. Ambiente de Execução
Para a realização das atividades, optou-se por utilizar um ambiente conteinerizado via Docker em vez de uma Máquina Virtual (VM) completa. A abordagem provou ser mais leve e igualmente funcional, configurando o Mininet, Open vSwitch e Wireshark no Ubuntu 20.04 através de um `Dockerfile` e `docker-compose.yml`.

### 2. Interação e Captura de Tráfego OpenFlow
Durante a execução do *walkthrough* oficial do Mininet, o objetivo era instanciar a topologia minimalista e visualizar a troca inicial de mensagens OpenFlow através do Wireshark.

Inicialmente, ao rodar o comando padrão `sudo mn`, notou-se a ausência de tráfego OpenFlow no Wireshark.

**Diagnóstico:**
Analisando os logs de inicialização do Mininet, foi identificado o seguinte comportamento:
```
*** No default OpenFlow controller found for default switch!
*** Falling back to OVS Bridge
```
Devido à ausência do pacote do controlador padrão (`openvswitch-testcontroller`) nas versões mais recentes do Ubuntu (20.04), o Mininet realizava um *fallback*, configurando o switch para atuar de forma autônoma (como uma *bridge* tradicional L2). Sem um controlador para se comunicar, o protocolo OpenFlow não era utilizado na rede, explicando a ausência de pacotes na captura.

**Solução:**
Para restabelecer o comportamento SDN e capturar o tráfego OpenFlow, utilizou-se o controlador Ryu como alternativa imediata. O procedimento adotado foi:

1. Inicialização do controlador Ryu básico em segundo plano:
   ```bash
   ryu-manager ryu.app.simple_switch
   ```
2. Inicialização da topologia do Mininet informando a presença do controlador externo:
   ```bash
   sudo mn -c
   sudo mn --controller remote
   ```

**Resultados Obtidos:**
Com a configuração correta, a conexão entre o *Open vSwitch* e o controlador Ryu foi estabelecida com sucesso. Aplicando o filtro `openflow` na interface `any` do Wireshark, foi possível visualizar perfeitamente o *handshake* do protocolo, registrando as mensagens iniciais como `HELLO`, `FEATURES_REQUEST` e `FEATURES_REPLY`.

![Captura de pacotes OpenFlow no Wireshark](INSIRA_A_IMAGEM_AQUI)
*Figura 1: Captura no Wireshark demonstrando a troca de mensagens OpenFlow entre o Switch e o Controlador Ryu.*

### 3. Execução Integral do Tutorial Mininet (Walkthrough)
Dando continuidade à primeira fase do laboratório, procedeu-se com a execução sistemática de **todos** os comandos e experimentos apresentados no tutorial oficial (`mininet_walkthrough.txt`). 

A validação contemplou integralmente as seguintes etapas:
* **Parte 1 (Uso Cotidiano):** Verificação de opções de inicialização, inspeção de estado de hosts e switches (via `ifconfig` e `ps` dentro dos *namespaces* virtuais), testes de conectividade simples (`ping`, `pingall`) e teste de tráfego de aplicação hospedando um servidor web HTTP Python em um host virtual.
* **Parte 2 (Opções Avançadas):** Execução de testes de regressão automatizados (`pingpair` e `iperf`), customização do tamanho e forma da topologia (`linear` e `single`), aplicação de variações de link (restrição de largura de banda e injeção de latência simulada) e a substituição do tipo do switch virtual (*OVS Kernel Switch* vs *User Space Switch*).
* **Parte 3 (Comandos de CLI):** Interação direta com a API do Mininet através do interpretador Python integrado (`py`) e testes de resiliência desativando e reativando as interfaces de rede (`link down` / `link up`).

**Adaptação Necessária nos Testes de Regressão:**
Conforme diagnosticado na Seção 2, o ambiente utilizado carece do controlador padrão do Mininet. Por isso, ao longo da execução de todas as etapas do *walkthrough* que exigiam a instanciação de redes ou testes automatizados, foi necessário um pequeno ajuste: a inclusão explícita do parâmetro `--controller remote` em todos os comandos (ex: `sudo mn --test pingall --topo linear,4 --controller remote`). 

Esse ajuste garantiu que, em todos os cenários testados, a rede operasse no paradigma SDN autêntico com o protocolo OpenFlow, delegando a inteligência para a aplicação `simple_switch` do controlador Ryu instanciado em segundo plano.

### 4. Fase 2: Automação e Topologias Customizadas (API Python)
A segunda fase do laboratório exigiu a transição do uso do CLI (Interface de Linha de Comando) para a **API Python do Mininet**. O objetivo central foi demonstrar o paradigma principal de SDN: a definição programática de redes.

O script fornecido na documentação original foi adaptado para atender a dois novos requisitos:
1. **Nova Topologia (`CustomTopo`)**: A rede foi expandida de 1 switch para um design linear contendo **4 switches** interligados. Ao longo desses switches, foram instanciados e distribuídos **11 hosts** (3 no Switch 1, 3 no Switch 2, 3 no Switch 3 e 2 no Switch 4).
2. **Automação de Teste de Largura de Banda (`perfTest`)**: Substituiu-se a verificação estática entre dois nós (h1 e h4) por um laço de repetição (`for host in net.hosts:`) que executa automaticamente o teste de taxa de transferência TCP (Iperf) do nó gerador `h1` em direção a **todos** os outros 10 nós da topologia.

**Resultados do Script:**
Durante a execução, o *PingAll* demonstrou conectividade funcional (com as esperadas perdas eventuais devido ao gargalo e ao parâmetro artificial `loss=2` configurado nos links). Em seguida, os 10 testes Iperf foram acionados sequencialmente de forma automática. O Controlador Ryu foi capaz de instalar os fluxos adequados (Learning Switch) para acomodar a comunicação inter-switch dos 11 hosts gerados pela topologia programada em Python.
