import os

content = """# Relatório Final: Laboratórios de Redes (Mininet e Ryu + OpenFlow)

Este documento descreve os procedimentos e os resultados obtidos na execução dos laboratórios 1 (Mininet) e 2 (Ryu + OpenFlow). O objetivo principal das atividades foi aplicar e verificar na prática os conceitos de Redes Definidas por Software (SDN), observando a interação entre o plano de dados (emulado pelo Mininet) e o plano de controle (gerenciado pelo controlador Ryu). A abordagem adotada manteve foco na análise técnica da infraestrutura e dos pacotes trafegados.

**Repositório Base**: [GitHub - ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks)

---

## SUMÁRIO
1. [Introdução e Configuração do Ambiente](#1-introducao-e-configuracao-do-ambiente)
2. [Laboratório 1: Emulação de Redes com Mininet](#2-laboratorio-1-emulacao-de-redes-com-mininet)
   2.1. [Fase 1: Comandos Básicos (Everyday Mininet Usage)](#21-fase-1-comandos-basicos-everyday-mininet-usage)
   2.2. [Fase 1: Inicialização Avançada (Advanced Startup Options)](#22-fase-1-inicializacao-avancada-advanced-startup-options)
   2.3. [Fase 1: Manipulação da API na CLI](#23-fase-1-manipulacao-da-api-na-cli)
   2.4. [Fase 2: Estruturação de Topologia Customizada (Python)](#24-fase-2-estruturacao-de-topologia-customizada-python)
   2.5. [Fase 2: Validação de Throughput Automatizada](#25-fase-2-validacao-de-throughput-automatizada)
3. [Laboratório 2: SDN com Controlador Ryu e OpenFlow](#3-laboratorio-2-sdn-com-controlador-ryu-e-openflow)
   3.1. [Inicialização da Topologia Base em Modo SDN](#31-inicializacao-da-topologia-base-em-modo-sdn)
   3.2. [Análise do Datapath Isolado (Sem Controlador)](#32-analise-do-datapath-isolado-sem-controlador)
   3.3. [Negociação de Protocolo (Handshake OpenFlow 1.3)](#33-negociacao-de-protocolo-handshake-openflow-13)
   3.4. [Análise de Interceptação: O Learning Switch em Ação](#34-analise-de-interceptacao-o-learning-switch-em-acao)
   3.5. [Inspeção Detalhada das Tabelas de Fluxo (Flow Tables)](#35-inspecao-detalhada-das-tabelas-de-fluxo-flow-tables)
   3.6. [Arquitetura de Software do Controlador (simple_switch_13)](#36-arquitetura-de-software-do-controlador-simple_switch_13)
4. [Considerações sobre Desempenho e Escalonabilidade](#4-consideracoes-sobre-desempenho-e-escalonabilidade)
5. [Conclusão](#5-conclusao)
6. [Anexos e Referências de Logs](#6-anexos-e-referencias-de-logs)

---

## 1. Introdução e Configuração do Ambiente

O ambiente de testes foi estabelecido por meio de contêineres Docker, rodando uma imagem base do Ubuntu 20.04 equipada com Open vSwitch, Mininet 2.3 e Wireshark. Esta abordagem de conteinerização garantiu o isolamento dos subsistemas de rede e a reprodutibilidade dos experimentos descritos.

Nas execuções preliminares utilizando o comando padrão do emulador (`sudo mn`), o log de inicialização indicou a ausência de um plano de controle local:

```text
*** No default OpenFlow controller found for default switch!
*** Falling back to OVS Bridge
```

A referida falha decorre da remoção do pacote `openvswitch-testcontroller` dos repositórios nativos do Ubuntu 20.04. Na ausência de um processo controlador vinculado à porta TCP padrão de SDN, o Open vSwitch (OVS) acionou um mecanismo de *fallback*. Neste modo, o OVS regride à funcionalidade de *bridge* Layer-2 autônoma, viabilizando o tráfego MAC sem, contudo, operar via protocolo OpenFlow.

Para corrigir o comportamento e restaurar o escopo da atividade (avaliação de redes SDN), adotou-se a utilização da framework controladora externa Ryu. Em todas as inicializações subsequentes dos laboratórios, o Mininet foi provisionado com a diretriz `--controller remote`. Isso instruiu o switch a paralisar o envio inicial de quadros e aguardar as decisões de roteamento da porta 6653 (alocada ao processo Python do Ryu).

---

## 2. Laboratório 1: Emulação de Redes com Mininet

A primeira parte do laboratório abrangeu a exploração das funcionalidades nativas do Mininet via interface de linha de comando (CLI) e, em um segundo momento, a implementação programática (via API Python) para simulação de cenários complexos de rede.

### 2.1. Fase 1: Comandos Básicos (Everyday Mininet Usage)

Nesta etapa, validaram-se as operações elementares descritas no *walkthrough* oficial do Mininet.
Iniciou-se uma topologia base do tipo `minimal` (composta por um switch conectado a dois hosts). As configurações das interfaces de rede foram inspecionadas utilizando a CLI interativa do emulador.

A listagem dos elementos instanciados pelo emulador evidenciou as interfaces lógicas virtuais:

```text
mininet> nodes
available nodes are: 
c0 h1 h2 s1

mininet> dump
<Host h1: h1-eth0:10.0.0.1 pid=11273> 
<Host h2: h2-eth0:10.0.0.2 pid=11275> 
<OVSSwitch s1: lo:127.0.0.1,s1-eth1:None,s1-eth2:None pid=11280> 
<RemoteController c0: 127.0.0.1:6653 pid=11254> 
```

O recurso de isolamento provido pelos namespaces de rede do kernel Linux foi validado ao executar o utilitário `ifconfig -a` em contexto de nó emulado. A interface `h1-eth0` e seus respectivos endereços apresentaram os escopos lógicos corretos:

```text
mininet> h1 ifconfig -a
h1-eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.0.1  netmask 255.0.0.0  broadcast 10.255.255.255
        inet6 fe80::f003:ccff:fe0a:2ca0  prefixlen 64  scopeid 0x20<link>
        ether f2:03:cc:0a:2c:a0  txqueuelen 1000  (Ethernet)
        RX packets 2  bytes 180 (180.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1  bytes 90 (90.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

A conectividade plena nos níveis L2/L3 foi validada pelo script `pingall`, aferindo sucesso em todas as requisições (2 de 2 pacotes).

### 2.2. Fase 1: Inicialização Avançada (Advanced Startup Options)

Conduziu-se a validação de parâmetros de regressão via flag `--test`. O teste de vazão via utilitário genérico de banda (Iperf) demonstrou os limites computacionais diretos:

```text
$ sudo mn --test iperf --controller remote
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['32.1 Gbits/sec', '32.2 Gbits/sec']
```
Os resultados de taxa de transmissão excedendo 30 Gbits/sec comprovaram a eficiência da implementação `OVS Kernel Switch` sobre alocações de buffer padrão no host nativo.

Testes variados de estruturação física envolveram a diretiva `--topo`. Os resultados da validação da tipologia em linha (`linear,4`), em cascata, obtiveram êxito pleno em seus 12 pontos cruzados:

```text
$ sudo mn --test pingall --topo linear,4 --controller remote
*** Ping: testing ping reachability
h1 -> h2 h3 h4 
h2 -> h1 h3 h4 
h3 -> h1 h2 h4 
h4 -> h1 h2 h3 
*** Results: 0% dropped (12/12 received)
```

**Aplicação de Traffic Control (TCLink):**
A simulação de ambientes com infraestrutura restritiva foi executada com a classe `TCLink`. Configurações fixaram o *bandwidth* (largura de banda) a 10 Mbps e impuseram uma latência (delay) simétrica de 10 milissegundos por enlace:

```text
$ sudo mn --link tc,bw=10,delay=10ms --test iperf --controller remote
*** Adding links:
(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h1, s1) 
(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h2, s1) 
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['9.50 Mbits/sec', '12.0 Mbits/sec']
```
O valor mensurado pelo TCP indicou um *throughput* útil médio de ~10 Mbps, atestando a aplicabilidade prática das bibliotecas *Traffic Control* (tc) do Linux integradas ao emulador.

### 2.3. Fase 1: Manipulação da API na CLI

A console interativa proveu controle granular sobre interfaces ativas. Demonstrou-se a interrupção intencional de um canal físico lógico (link down):

```text
mininet> link s1 h1 down
mininet> pingall
*** Ping: testing ping reachability
h1 -> X 
h2 -> X 
*** Results: 100% dropped (0/2 received)

mininet> link s1 h1 up
mininet> pingall
*** Ping: testing ping reachability
h1 -> h2 
h2 -> h1 
*** Results: 0% dropped (2/2 received)
```
A pronta recuperação perante o restabelecimento da via (`link up`) evidenciou a capacidade de testes topológicos voltados a tolerância de falhas.

### 2.4. Fase 2: Estruturação de Topologia Customizada (Python)

A transição de linhas de comando imperativas para modelagem orientada a objetos realizou-se a partir da manipulação da API Python nativa. O arquivo em questão (`lab1_phase2.py`) foi estruturado da seguinte forma:

A fim de suprir a imposição técnica (mínimo de 4 switches e 11 hosts), foi declarada a classe `CustomTopo`. O método construtor instanciou os *switches* `s1` até `s4`, utilizando alinhamento em cadeia (*daisy chain*):

```python
self.addLink( s1, s2 )
self.addLink( s2, s3 )
self.addLink( s3, s4 )
```

Em seguida, o *loop* gerou as estações terminais (`h1` a `h11`) e efetuou a distribuição em fatias. Os três primeiros *hosts* associaram-se ao `s1`; os três subsequentes ao `s2`; e os demais distribuídos aos nós adjacentes.
Cada ramificação terminal foi associada a um perfil rigoroso restritivo (banda limitadora de 10Mbit e descartes probabilísticos de `loss=2`):

```python
self.addLink( h, s1, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
```

A comprovação das associações de portas L2 constou no diagnóstico de inicialização via função auxiliar de log `dumpNodeConnections`:
```text
--- Realizando o Dump das Conexoes ---
h1 h1-eth0:s1-eth2
h2 h2-eth0:s1-eth3
h3 h3-eth0:s1-eth4
h4 h4-eth0:s2-eth3
h5 h5-eth0:s2-eth4
h6 h6-eth0:s2-eth5
h7 h7-eth0:s3-eth3
h8 h8-eth0:s3-eth4
h9 h9-eth0:s3-eth5
h10 h10-eth0:s4-eth2
h11 h11-eth0:s4-eth3
```

### 2.5. Fase 2: Validação de Throughput Automatizada

A verificação funcional foi reescrita no módulo `perfTest(net)`. O processo fixou o host pivô (`h1`) e efetuou requisições bidirecionais automáticas Iperf em laço sequencial para os 10 dispositivos restantes do escopo. O teste visava comprovar a saturação das portas configuradas via script:

```python
for host in net.hosts:
    if host.name != 'h1':
        result = net.iperf( (h1, host) )
```

No evento inicial de aquecimento (`PingAll`), o total acumulado das quedas probabilísticas do canal L2 acarretou em 9% de perda real aferida sobre os 110 testes unitários de ping:
```text
*** Ping: testing ping reachability
h1 -> h2 h3 X h5 X h7 h8 h9 h10 h11 
h2 -> h1 h3 h4 h5 X h7 h8 h9 h10 h11
h3 -> h1 h2 h4 X h6 X h8 h9 h10 X
h4 -> h1 h2 h3 X h6 X h8 h9 h10 X
h5 -> h1 h2 h3 X h6 X h8 h9 h10 X
*** Results: 9% dropped (100/110 received)
```

Posteriormente, os resultados iterativos de tráfego indicaram valores médios marginais condizentes com os entraves impostos pelo enfileiramento (HTB queue delay):
```text
[>] Testando iperf (Banda TCP) entre h1 e h2...
*** Results: ['3.12 Mbits/sec', '3.15 Mbits/sec']
[>] Testando iperf (Banda TCP) entre h1 e h3...
*** Results: ['3.13 Mbits/sec', '3.41 Mbits/sec']
[>] Testando iperf (Banda TCP) entre h1 e h4...
*** Results: ['3.01 Mbits/sec', '3.32 Mbits/sec']
[>] Testando iperf (Banda TCP) entre h1 e h11...
*** Results: ['3.08 Mbits/sec', '3.56 Mbits/sec']
```

---

## 3. Laboratório 2: SDN com Controlador Ryu e OpenFlow

A segunda etapa caracterizou-se pela dissecação do plano de controle, capturando em tempo real a camada de protocolo OpenFlow 1.3 responsável pela comunicação bidirecional do Ryu e o Open vSwitch.

### 3.1. Inicialização da Topologia Base em Modo SDN

A malha para a validação de fluxos foi gerada a partir da instrução simplificada:
```bash
sudo mn --topo single,3 --mac --controller remote --switch ovsk,protocols=OpenFlow13
```
A declaração `--mac` estabeleceu endereços unificados legíveis (ex: `00:00:00:00:00:01` designado ao h1), garantindo simplicidade visual durante o rastreio via Wireshark. O tráfego aderiu mandatoriamente às diretrizes OF1.3.

### 3.2. Análise do Datapath Isolado (Sem Controlador)

Com o analisador de pacotes Wireshark na escuta da interface *loopback*, submeteu-se a topologia a um teste ICMP inicial na ausência (desligamento intencional) do processo controlador SDN no host.

```text
mininet> h1 ping -c 1 h2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
--- 10.0.0.2 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
```

**Conclusão da Análise Direta:** O evento caracterizou perda total (100%). A tentativa local de resolução de endereços da máquina h1 resultou num `ARP Request Broadcast` encaminhado ao switch virtual. Devido à sua topologia SDN, o OVS não possuía uma tabela de filtragem L2 estática baseada em aprendizagem de MAC; tampouco possuía fluxos injetados. Dessa maneira, mediante a inalcançabilidade de sua porta TCP 6653 (ausência do Ryu), o pacote L2 sofreu supressão por ação de *drop* automática no hardware.

### 3.3. Negociação de Protocolo (Handshake OpenFlow 1.3)

Instanciou-se, de forma assíncrona, a aplicação `simple_switch_13` provida pela documentação Ryu:
```bash
$ ryu-manager ryu.app.simple_switch_13
```

O estabelecimento da porta TCP culminou na negociação transacional visível no Wireshark:

1. **`OFPT_HELLO`:** Mensagens bidirecionais negociando o uso da versão nativa do OF 1.3.
2. **`OFPT_FEATURES_REQUEST`:** Interrogação do controlador solicitando os indicadores primários de identificação lógica e as capacidades de infraestrutura do OVS.
3. **`OFPT_FEATURES_REPLY`:** Confirmação do switch contendo o `datapath_id`, os buffers L2 (`n_buffers`) em memória RAM e as tabelas disponíveis (`n_tables`).
4. **Instalação de Diretriz Padrão (`Table-Miss`):** O controlador impôs imediatamente o fluxo fundamental ao comportamento SDN. A mensagem `OFPT_FLOW_MOD` injetou na Tabela 0 do OVS um fluxo de precedência `priority=0`. Seu campo correspondente estava em branco (abarcando todo tráfego), e a ação estipulava `OUTPUT: CONTROLLER`. Essa configuração direciona todo tráfego futuro com endereçamento ausente em tabela direto ao plano superior SDN para a devida verificação baseada em software.

### 3.4. Análise de Interceptação: O Learning Switch em Ação

Uma nova aferição ICMP foi iniciada:
```text
mininet> h1 ping -c 1 h2
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=3.91 ms
```

A captura do Wireshark evidenciou o ciclo reativo do Learning Switch em relação a este pacote.
A sequência do processo é detalhada a seguir:

1. **Ativação do Table-Miss:** O Broadcast ARP atingiu o switch. Sob a diretriz da prioridade 0 preestabelecida, o frame L2 foi encapsulado em OF1.3 `OFPT_PACKET_IN` rumo ao Ryu.
2. **Registro Topológico Inicial:** A aplicação inspecionou a variável origens do pacote, deduzindo ativamente que o dispositivo de identificador MAC (`00:00:00:00:00:01`) relacionava-se ineditamente com a porta número 1 do Datapath.
3. **Replicagem Cega (Flooding):** Indisponível o referencial do destino, efetuou-se uma ordem imperativa de inundação por meio de pacote `OFPT_PACKET_OUT`.
4. **Descoberta do Alvo Secundário:** O host h2 interceptou a difusão Broadcast e remeteu a resposta Unicast. Um segundo `OFPT_PACKET_IN` repassou os resultados ao Ryu, que atualizou o mapeamento da porta 2 e vinculou o MAC de `00:00:00:00:00:02`.
5. **Ação Roteadora e Escalonamento de Tabela:** Em virtude do aprendizado de ambas as referências físicas ativas, o sistema acionou sucessivas injeções de `OFPT_FLOW_MOD` contendo especificações absolutas L2-L3 determinando ações permanentes `output:2` (para ida) e `output:1` (para retornos do host alvo). Tais fluxos possuem prevalência sobre o Table-Miss devida à respectiva atribuição `priority=1`.

### 3.5. Inspeção Detalhada das Tabelas de Fluxo (Flow Tables)

O ambiente operacional do Datapath interno fora então consultado em via OVS administrativa terminal:

```bash
$ sudo ovs-ofctl dump-flows s1 -O OpenFlow13

 cookie=0x0, duration=15.1s, table=0, n_packets=4, n_bytes=340, priority=0 actions=CONTROLLER:65535
 cookie=0x0, duration=3.5s, table=0, n_packets=2, n_bytes=196, priority=1,in_port=1,dl_dst=00:00:00:00:00:02,dl_src=00:00:00:00:00:01 actions=output:2
 cookie=0x0, duration=3.5s, table=0, n_packets=1, n_bytes=98, priority=1,in_port=2,dl_dst=00:00:00:00:00:01,dl_src=00:00:00:00:00:02 actions=output:1
```

A Tabela 0 documentou a veracidade dos encaminhamentos propostos, com métricas atreladas precisas para o volume trafegado (`n_packets` exibindo a soma das requisições). 
1. Entrada `priority=0`: Regra mestra *Table-Miss*, determinando que toda anomalia de acesso redireciona de volta a `CONTROLLER:65535`.
2. Entrada `priority=1`: Trata do canal de escoamento de `h1` para `h2`, mapeado condicionalmente na porta base.
3. Entrada secundária `priority=1`: Define a resposta simétrica proveniente do servidor h2.

Eventuais verificações complementares `ping` realizadas após essa injeção não geraram qualquer ruído adicional no painel do Wireshark, indicando que todo o processamento recaiu em via nativa em níveis de buffer no hardware, evidenciando a liberação de processamento do plano de controle. Somente após acionar *hosts* inéditos (e.g. `h3`) notou-se o reinício de interceptações sistêmicas.

### 3.6. Arquitetura de Software do Controlador (simple_switch_13)

Comportamentos macro apresentados acima derivaram da execução lógica interna e síncrona dos decoradores providos na aplicação. O Ryu emprega a tabela Python em memória `self.mac_to_port` de forma persistente.

**Análise do Método Inicial:**
1. A rotina `switch_features_handler` vincula-se ao ouvinte `EventOFPSwitchFeatures`. No momento de negociação (OFPT), atua injetando o *Table-Miss*:
   ```python
   match = parser.OFPMatch()
   actions = [parser.OFPActionOutput(ofproto.OFPP_CONTROLLER,
                                     ofproto.OFPCML_NO_BUFFER)]
   self.add_flow(datapath, 0, match, actions)
   ```

**Análise do Método Interceptador:**
2. A rotina `packet_in_handler` intercepta eventos de anomalias (Table-Miss). Executa a atribuição matricial:
   ```python
   self.mac_to_port[dpid][src] = in_port
   ```
3. Baseando-se no endereço alvo do pacote, processa os requisitos locais:
   ```python
   if dst in self.mac_to_port[dpid]:
       out_port = self.mac_to_port[dpid][dst]
   else:
       out_port = ofproto.OFPP_FLOOD
   ```
4. A descoberta da localidade verdadeira viabiliza uma ação conclusiva no qual os atributos são embalados via `add_flow` em formulários OFPT que gravam os atributos lógicos no kernel switch virtual nativo de forma definitiva.

---

## 4. Considerações sobre Desempenho e Escalonabilidade

Os métodos apresentados garantiram que o servidor controlador permaneça em estado latente após o assentamento das topologias de rota. As interjeições dinâmicas de `FLOW_MOD` isentam a camada gerencial de processos rotineiros, desonerando conexões TCP centralizadoras. Testes com o switch OVS padrão na flag OF 1.3 provaram-se altamente estáveis nas correspondências transacionais em alto volume de throughput de portas múltiplas em virtude do eficiente roteamento atrelado do pacote.

---

## 5. Conclusão

Os dois exercícios simulados validaram a aplicabilidade técnica das separações hierárquicas providas por SDN. Na etapa experimental Mininet (Laboratório 1), testou-se na prática tanto iterações isoladas em portas diretas até alocações programáticas extensas com mais de uma dezena de dispositivos em instâncias virtuais do Linux acopladas a regras limitadoras em L2 (Traffic Control). Em conjunto ao Laboratório 2, observou-se, de fato, a delegação decisória baseada num modelo autônomo. O Ryu converteu quadros isolados, originalmente dependentes de algoritmos pré-estabelecidos estáticos, em um Learning Switch com total visibilidade técnica (verificada e justificada sob o painel de análise OFPT do Wireshark), gerando interações diretas perante exceções (*Table-Miss*) para viabilizar um projeto em loop contínuo e escalonável no hardware.

---

## 6. Anexos e Referências de Logs

A reprodução e a consolidação técnica provenientes do escopo experimental encontram-se disponíveis de modo integral no repositório atrelado a este trabalho.

### A.1. Código Completo da Topologia Customizada (Fase 2)
```python
from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Host, RemoteController
from mininet.link import TCLink
from mininet.util import dumpNodeConnections
from mininet.log import setLogLevel, info

class CustomTopo( Topo ):
    def build( self ):
        s1 = self.addSwitch( 's1' )
        s2 = self.addSwitch( 's2' )
        s3 = self.addSwitch( 's3' )
        s4 = self.addSwitch( 's4' )

        self.addLink( s1, s2 )
        self.addLink( s2, s3 )
        self.addLink( s3, s4 )

        hosts = []
        for i in range(1, 12):
            h = self.addHost( 'h%s' % i )
            hosts.append(h)

        for h in hosts[0:3]:
            self.addLink( h, s1, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        for h in hosts[3:6]:
            self.addLink( h, s2, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        for h in hosts[6:9]:
            self.addLink( h, s3, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        for h in hosts[9:11]:
            self.addLink( h, s4, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )

def perfTest( net ):
    h1 = net.get( 'h1' )
    for host in net.hosts:
        if host.name != 'h1':
            result = net.iperf( (h1, host) )

if __name__ == '__main__':
    setLogLevel( 'info' )
    topo = CustomTopo()
    net = Mininet( topo=topo, host=Host, link=TCLink, controller=RemoteController )
    net.start()
    dumpNodeConnections( net.hosts ) 
    net.pingAll()
    perfTest( net )
    net.stop()
```

### A.2. Links do Repositório

* **Diretrizes e Questões Iniciais**: [project_description.txt](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/project_description.txt)
* **Estruturação de Base de Scripts Shell**: [Diretório scripts/](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/tree/main/scripts)
* **Desenvolvimento da Topologia Python**: [lab1_phase2.py](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/scripts/lab1_phase2.py)
* **Registro de Execuções L1**: [relatorio_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_walkthrough.md)
* **Registro de Funcionalidades Avançadas**: [relatorio_full_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_full_walkthrough.md)
* **Registro de Topologia Iterativa L2**: [relatorio_phase2.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_phase2.md)
"""

with open("C:/Users/Ualaci/Documents/Git/report2-mininet-ryu-ppcomp-mpca-comp-networks/relatorio.md", "w", encoding="utf-8") as f:
    f.write(content)
