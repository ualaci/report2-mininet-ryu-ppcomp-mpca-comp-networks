# Relatório : Laboratórios de Redes (Mininet e Ryu + OpenFlow)

Este documento apresenta a explicação detalhada e passo a passo dos procedimentos realizados e dos resultados obtidos nos laboratórios 1 (Mininet) e 2 (Ryu + OpenFlow).

**Repositório Web Base**: [GitHub - ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks)

---

## SUMÁRIO

1. [Introdução e Preparação do Ambiente](#1-introducao-e-preparacao-do-ambiente)
2. [Laboratório 1: Emulação de Redes com Mininet](#2-laboratorio-1-emulacao-de-redes-com-mininet)
   2.1. [Fase 1: Uso Cotidiano do Mininet (Everyday Mininet Usage)](#21-fase-1-uso-cotidiano-do-mininet-everyday-mininet-usage)
   2.2. [Fase 1: Opções Avançadas de Inicialização (Advanced Startup Options)](#22-fase-1-opcoes-avancadas-de-inicializacao-advanced-startup-options)
   2.3. [Fase 1: Interação com a API via CLI (Mininet CLI Commands)](#23-fase-1-interacao-com-a-api-via-cli-mininet-cli-commands)
   2.4. [Fase 2: Automação e Topologia Customizada em Python](#24-fase-2-automacao-e-topologia-customizada-em-python)
3. [Laboratório 2: SDN com Controlador Ryu e OpenFlow](#3-laboratorio-2-sdn-com-controlador-ryu-e-openflow)
   3.1. [Configuração da Topologia Base](#31-configuracao-da-topologia-base)
   3.2. [Comportamento do Datapath sem Controlador SDN (Falha Isolada)](#32-comportamento-do-datapath-sem-controlador-sdn-falha-isolada)
   3.3. [Ativação do Ryu e Handshake OpenFlow 1.3](#33-ativacao-do-ryu-e-handshake-openflow-13)
   3.4. [Testes Iniciais e a Reação do Learning Switch](#34-testes-iniciais-e-a-reacao-do-learning-switch)
   3.5. [A Tabela de Fluxos (Flow Tables) e o Cache de Hardware](#35-a-tabela-de-fluxos-flow-tables-e-o-cache-de-hardware)
   3.6. [Análise Aprofundada do Código simple_switch_13](#36-analise-aprofundada-do-codigo-simple_switch_13)
4. [Considerações sobre a Topologia Híbrida e Escalonabilidade](#4-consideracoes-sobre-a-topologia-hibrida-e-escalonabilidade)
5. [Conclusão Final](#5-conclusao-final)
6. [Anexos e Referências de Código](#6-anexos-e-referencias-de-codigo)

---

## 1. Introdução e Preparação do Ambiente

A execução de todos os testes deste laboratório foi projetada de forma a ser reprodutível, garantindo a replicabilidade dos experimentos a partir dos scripts disponíveis no repositório. O ambiente rodou sob uma imagem do Ubuntu 20.04, embarcando todas as ferramentas essenciais como Open vSwitch, Mininet 2.3 e Wireshark.

Durante os testes iniciais de subida da infraestrutura com o comando nativo `sudo mn`, foi diagnosticado o seguinte comportamento inesperado nos logs de inicialização do emulador:

```text
*** No default OpenFlow controller found for default switch!
*** Falling back to OVS Bridge
```

Esse erro ocorre pois os pacotes recentes do Ubuntu 20.04 descontinuaram o controlador leve `openvswitch-testcontroller`. Sem um controlador disponível no sistema, o switch virtual (Open vSwitch) realizava um _fallback_, regredindo o seu comportamento SDN para o de uma bridge puramente Layer-2 convencional.

**A Solução Adotada:**
Para restabelecer o funcionamento da SDN, a arquitetura foi corrigida mediante o uso do controlador Ryu rodando simultaneamente em background. Assim, em absolutamente todas as etapas descritas a seguir, o Mininet foi instruído a se conectar ao Ryu usando a flag `--controller remote`. Dessa forma, evitou-se que o OVS caísse em modo de operação _standalone_ bridge.

---

## 2. Laboratório 1: Emulação de Redes com Mininet

A primeira fase consistiu em exercitar comandos vitais de emulação do Mininet e, a seguir, realizar implementações programáticas mais elaboradas.

### 2.1. Fase 1: Uso Cotidiano do Mininet (Everyday Mininet Usage)

Nesta etapa, o ambiente foi submetido às validações presentes no _Walkthrough_ Oficial do Mininet como proposto pelo enunciado do laboratório 1.

- **Logs de Referência Web:**
  - [relatorio_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_walkthrough.md)
  - [relatorio_full_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_full_walkthrough.md)

Primeiramente, verificou-se o painel de ajuda e parâmetros embutidos (`sudo mn -h`). A seguir, o comando de inicialização base foi executado para criar a topologia "minimal" (um switch conectado a dois hosts, regidos pelo controlador Ryu instanciado em background na porta 6653).

A CLI interna nos permitiu listar os nós da topologia:

```text
mininet> nodes
available nodes are:
c0 h1 h2 s1
```

E posteriormente extrair os endereços MACs e IPs configurados em cada interface de rede das máquinas emuladas, detalhando os seus links lógicos:

```text
mininet> dump
<Host h1: h1-eth0:10.0.0.1 pid=11273>
<Host h2: h2-eth0:10.0.0.2 pid=11275>
<OVSSwitch s1: lo:127.0.0.1,s1-eth1:None,s1-eth2:None pid=11280>
<RemoteController c0: 127.0.0.1:6653 pid=11254>
```

O isolamento oferecido pelo Kernel Linux provou-se formidável. Ao acionar o comando de sistema `ifconfig -a` dentro do nodo `h1`, percebeu-se que o host opera dentro do seu próprio _network namespace_, alheio a qualquer interface existente no sistema operacional host ou no nodo `h2`:

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

A etapa foi concluída demonstrando estabilidade completa de tráfego usando a verificação agregada (`pingall`):

```text
mininet> pingall
*** Ping: testing ping reachability
h1 -> h2
h2 -> h1
*** Results: 0% dropped (2/2 received)
```

### 2.2. Fase 1: Opções Avançadas de Inicialização (Advanced Startup Options)

O _Walkthrough_ avançou abordando ferramentas de testes de regressão que evitam que o usuário precise invocar comandos `ping` de forma manual. Tudo foi acionado através dos argumentos do binário principal.

**Testes em Batch via Argumentos:**
Utilizou-se a flag `--test` para invocar varreduras diretamente da linha de comando base:

```text
$ sudo mn --test pingpair --controller remote
*** Waiting for switches to connect
s1
h1 -> h2
h2 -> h1
*** Results: 0% dropped (2/2 received)
```

Para aferir se a largura de banda virtual seria satisfatória, o teste Iperf foi conduzido e obteve excelente êxito, uma vez que não impusemos limites e o OVS agiu nativamente em Kernel Mode (atingindo marcas acima de 30 Gbits/sec):

```text
$ sudo mn --test iperf --controller remote
*** Iperf: testing TCP bandwidth between h1 and h2
*** Results: ['32.1 Gbits/sec', '32.2 Gbits/sec']
```

**Alterações na Forma da Topologia:**
A malha foi expandida dinamicamente para alocar novos dispositivos através do parâmetro `--topo`.

- Topologia Single Switch englobando 3 hosts:
  ```text
  $ sudo mn --test pingall --topo single,3 --controller remote
  *** Ping: testing ping reachability
  h1 -> h2 h3
  h2 -> h1 h3
  h3 -> h1 h2
  *** Results: 0% dropped (6/6 received)
  ```
- Topologia Linear de 4 switches empilhados em cascata (daisy chain):
  ```text
  $ sudo mn --test pingall --topo linear,4 --controller remote
  *** Ping: testing ping reachability
  h1 -> h2 h3 h4
  h2 -> h1 h3 h4
  h3 -> h1 h2 h4
  h4 -> h1 h2 h3
  *** Results: 0% dropped (12/12 received)
  ```

**Configurações de Estrangulamento da Malha Física (Traffic Control Link):**
A grande inovação que SDN e Mininet proporcionam a desenvolvedores é a de mimetizar ambientes comutados degradados (redes longas, via rádio ou links saturados). Foi utilizado o `TCLink` do Linux para injetar latência de 10 milissegundos por nó e capar a conexão nos limites estritos de 10 Megabits por segundo. O controlador permaneceu o Ryu.

```text
$ sudo mn --link tc,bw=10,delay=10ms --test iperf --controller remote
*** Adding links:
(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h1, s1)
(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h2, s1)
*** Iperf: testing TCP bandwidth between h1 and h2
*** Results: ['9.50 Mbits/sec', '12.0 Mbits/sec']
```

Este teste garantiu as credenciais do `TCLink`. Os valores finais medidos corresponderam fielmente aos limites impostos no CLI.

### 2.3. Fase 1: Interação com a API via CLI (Mininet CLI Commands)

O Mininet possui em sua base uma shell interativa Python. Executar rotinas internas de código durante a fase ativa do Mininet é possível ao adicionar na entrada pelo prefixo `py`.

Utilizou-se a interface interativa em Python para descobrir variáveis do controlador remoto e da topologia rodando ao vivo. Outra funcionalidade marcante demonstrada nesta etapa do relatório foi o controle manual sobre interfaces (Links de Down/Up), muito eficazes para testes de robustez de sistemas distribuídos:

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

Dessa forma, foi demonstrada a integração do emulador em derrubar uma rota de dados L2 virtual apenas por um comando da API do Mininet.

### 2.4. Fase 2: Automação e Topologia Customizada em Python

No laboratório de Mininet, a construção visual e interpretada cede espaço ao real desenvolvimento. O arquivo `lab1_phase2.py` desenvolve a Fase 2 do laboratório, a qual solicita a execução do script, ajustando-o com melhorias para o contexto do laboratório. O log de execução do script python pode ser analisado pelo link abaixo:

**Log de Referência Web:** [relatorio_phase2.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_phase2.md)

**A. Construção do Diagrama de Redes (`CustomTopo`)**
Para suprir o enunciado que exigia um mínimo de 4 Switches e 11 Hosts, a classe base `Topo` foi herdada e a sua função central `build()` foi alterada.
As instanciações do script envolveram a criação dos 4 switches (s1 a s4), ligados numa estrutura Backbone em cadeia (Daisy Chain):

```python
self.addLink( s1, s2 )
self.addLink( s2, s3 )
self.addLink( s3, s4 )
```

O preenchimento populacional se deu por laço de repetição forjando 11 hosts de (h1 a h11). As máquinas foram distribuídas da seguinte forma nos equipamentos:

- O Switch `s1` absorveu as interfaces de tráfego de h1, h2 e h3.
- O Switch `s2` absorveu as interfaces de h4, h5 e h6.
- O Switch `s3` interconectou h7, h8 e h9.
- O Switch `s4` agregou em suas portas lógicas os hosts remanescentes h10 e h11.

**B. Conexões Node-Link Customizadas:**
O sistema Mininet validou as interfaces conectadas demonstrando o dump das referências físicas e os respectivos cabos unindo as portas dos switches no backend do OVS como esperado:

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

Nessa impressão, nota-se que a construção de malha atendeu aos requisitos do laboratório, espalhando uniformemente os terminais pelo datapath backbone. Adicionalmente, todos os _hosts_ sofreram penalidades simuladas de Traffic Control, operando sobre cabos de apenas 10 Mbps de throughput, injetados com 5ms de delay e 2% de perdas aleatórias de pacote.

**C. Teste Customizado Global de Iperf (`perfTest`)**
O roteiro do laboratório exigiu o abandono do pingpair estático em detrimento de uma malha iterativa de análise. Foi elaborada a função `perfTest(net)` contendo o host principal ("Pivot") fixado como "h1".
O script percorre iterativamente todas as instâncias hospedadas (`net.hosts`). Se o host em questão diferir do "h1", o script injeta no Mininet o comando assíncrono para verificar o throughput de ponta-a-ponta via API Python Iperf:

```python
for host in net.hosts:
    if host.name != 'h1':
        result = net.iperf( (h1, host) )
```

**Resultados do Código Baseado em Python:**
As métricas validadas atestam que a topologia foi construída com sucesso.
No evento geral do `PingAll`, as perdas em cascata (`loss=2%`) resultaram no total realístico de 9% de perdas contabilizadas nos 110 pings trafegados:

```text
*** Ping: testing ping reachability
h1 -> h2 h3 X h5 X h7 h8 h9 h10 h11
h2 -> h1 h3 h4 h5 X h7 h8 h9 h10 h11
...
*** Results: 9% dropped (100/110 received)
```

No teste iterativo de bandas do Host 1, todas as negociações TCP relataram a degradação prevista pela métrica original de 10 Mbps de throughput capado, flutuando em taxas marginais devido às múltiplas simulações de ruído no cabo e perdas artificiais de enfileiramento (HTB max queue size):

```text
[>] Testando iperf (Banda TCP) entre h1 e h2...
*** Results: ['3.12 Mbits/sec', '3.15 Mbits/sec']
[>] Testando iperf (Banda TCP) entre h1 e h3...
*** Results: ['3.13 Mbits/sec', '3.41 Mbits/sec']
...
[>] Testando iperf (Banda TCP) entre h1 e h11...
*** Results: ['3.08 Mbits/sec', '3.56 Mbits/sec']
```

---

## 3. Laboratório 2: SDN com Controlador Ryu e OpenFlow

A segunda etapa aborda não mais a emulação do hardware, e sim a inspeção de uma Rede Definida por Software utilizando a ferramenta Wireshark e a framework controladora externa Ryu.
O paradigma provado aqui consiste na dissociação do "Control-Plane" (Controlador Inteligente Ryu) e do "Data-Plane" (Switches Virtuais OpenFlow).

### 3.1. Configuração da Topologia Base

Toda a bateria de testes de pacotes do laboratório 2 foi gerada executando o comando base que estipula topologia minimalista e dita que o tráfego OpenFlow deve imperar num switch "burro":

```bash
sudo mn --topo single,3 --mac --controller remote --switch ovsk,protocols=OpenFlow13
```

Foi importante a inclusão da tag `--mac`, que substituiu os MAC Addresses hexadecimais aleatórios do emulador por endereços de numeração sequencial simplificada (`00:00:00:00:00:01` = h1), facilitando a visibilidade nas capturas geradas pelo analisador Wireshark e tornando mais cômoda a depuração humana dos pacotes ARP transitórios. O protocolo exigido na flag foi exclusivamente o OpenFlow 1.3 (OF1.3).

(adicionar placeholder de imagem aqui)

### 3.2. Comportamento do Datapath sem Controlador SDN (Falha Isolada)

Com o Mininet e Wireshark abertos — porém, crucialmente, mantendo o serviço de roteamento do controlador Ryu **Desligado** de propósito no painel host —, foi gerado um teste de injeção de pacotes pelo ICMP:

```text
mininet> h1 ping -c 1 h2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
--- 10.0.0.2 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
```

**Problema e Constatação Prática:** O pacote foi reportado como inacessível com falha completa da comunicação (100% de perda reportada).
**Por Que Acontece?** Um Switch virtual OVS configurado no modo Remote Controller para ambientes OpenFlow 1.3 não toma iniciativa própria. Sem o Ryu instanciado na porta 6653 TCP e sem fluxo instalado nas `Flow Tables` nativas, o switch atua como um tijolo isolado na rede.
O ping ICMP não avança porque o host "h1", desconhecendo a rota destino, inicialmente grita em L2 com um `ARP Request Broadcast (Who has 10.0.0.2)`. O pacote acerta a interface física do switch, mas, como não existe nenhuma rota estipulando "Encaminhe isto" e nem o fallback mestre atrelado, a rede virtual puramente emudece e morre por inanição e silêncio.

### 3.3. Ativação do Ryu e Handshake OpenFlow 1.3

Diante do colapso da camada Datapath (Switches sem Controlador), procedeu-se o restabelecimento imediato das tabelas provendo inteligência central ativando a framework SDN.

```bash
$ ryu-manager --verbose ryu.app.simple_switch_13
```

Tão logo o Python assumiu o servidor Ryu e abriu o conector na porta especificada, a _Interface Any_ do Wireshark testemunhou a chuva de transações corecionais OpenFlow entre o OVS e o Servidor SDN:

(Adicionar placeholder de imagem aqui)

1. **Mensagens `HELLO`:** Ambas as extremidades dispararam mensagens OpenFlow tipo HELLO para acordar mutuamente que operariam nas regras sintáticas da versão 1.3 (e recusariam emissores 1.0 ou 1.1 desatualizados).
2. **`FEATURES_REQUEST` (Controlador para o Switch):** O controlador interrogou formalmente as capacidades computacionais do equipamento (Perguntou sobre Buffers, Tabelas disponíveis e o Datapath ID numérico global).
3. **`FEATURES_REPLY` (Switch para o Controlador):** O Switch detalhou suas métricas ativas numa string compreensiva de resposta técnica OFPT. O payload inclui o `datapath_id`, os `n_buffers` disponíveis para retenção de pacotes em miss e o limite da `n_tables` ativas.
4. **Estabelecimento de Tabela - Flow Mod Base (`Table-Miss`):** A mensagem OpenFlow mais relevante do aperto de mãos. Imediatamente após a sincronização OFPT, o script `simple_switch_13` despachou um pacote `OFPFlowMod` preenchedor obrigando o Switch OVS a colocar em sua _Tabela 0_ a pior regra possível, chamada popularmente de Table-Miss de Prioridade Nula.
   Essa instrução disse ao Hardware: "Quando houver casos que você não saiba mapear pelas minhas futuras regras rigorosas, nunca descarte o lixo silenciosamente. Redirecione esse pacote problemático inteiramente a mim (OUTPUT: CONTROLLER)."

### 3.4. Testes Iniciais e a Reação do Learning Switch

No Mininet interativo, o mesmo comando ICMP antes abortado foi enviado novamente, tendo tendo êxito dessa vez:

```text
mininet> h1 ping -c 1 h2
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=3.91 ms
```

**Análise Minuciosa no Wireshark da Dinâmica e Passos:**
A captura decodificou os dados de uma controladora atuando perante eventos aleatórios do Switch (o que define o Learning Switch). O passo a passo ocorreu como mostrado abaixo:

1. `h1` emitiu pacote ARP tentando descobrir "h2" (ff:ff:ff:ff:ff:ff).
2. O Switch acolheu o frame L2. Por ser um pacote que nunca havia sido roteado anteriormente e bater na sua Table-Miss de prioridade zero, o Switch o envelopou em um protocolo OpenFlow `PACKET_IN` remetendo-o ao Ryu para instruções adicionais de contingência.
3. **Controlador Aprende Origem:** O script do Ryu analisou esse `PACKET_IN`. Olhou e deduziu que a máquina `h1` (`00:00:00:00:00:01`) estava associada à porta que o switch informou (Porta `1`).
4. **Inundação Ordenada:** O controlador não conhecia o "h2". Portanto, ele injetou esse quadro inteiro dentro de um cabeçalho OpenFlow de retorno e o transcreveu como `PACKET_OUT` instruindo o datapath a cometer _Flooding_ com urgência naquelas imediações e descobrir quem seria.
5. "h2" escutou a inundação e prontamente submeteu aos cabos sua réplica (o famoso ARP Reply destilando que o `00:00:00:00:00:02` era ele).
6. O Switch novamente repassou para cima pois desconhecia como guiar para "h1" (não havia tabela estática). Outro `PACKET_IN` na tela do Wireshark.
7. **Controlador Aprende a Resposta e Altera a Rede:** Ryu anotou a porta do MAC de h2. Ponderou: "Ok, h1 e h2 existem." Neste instante do tempo ele não precisa mais enviar pacotes em `PACKET_OUT` e afogar a controladora, ele tem o gabarito. Ele enviou ao switch comandos via estrutura `FLOW_MOD` de OpenFlow em caráter definitivo. criou duas instruções simultâneas ("Se for h1 manda porta 1", e vice-versa).
8. Com o ARP resolvido e Regras atualizadas, o "h1" enviou sem atrasos o payload do seu Ping (ICMP Echo), o qual cruzou o caminho de comunicação sem acionar as esferas mais altas.

### 3.5. A Tabela de Fluxos (Flow Tables) e o Cache de Hardware

Para resumir, na aba OFPT do Wireshark, o hardware do kernel Open vSwitch teve suas camadas inspecionadas localmente via porta shell administrativa OVS-OFCTL.
As tabelas espelham todas as requisições ativadas pelas diretrizes do SDN da fase anterior.

**Comando Inserido e Resultado:**

```bash
$ sudo ovs-ofctl dump-flows s1 -O OpenFlow13

 cookie=0x0, duration=15.1s, table=0, n_packets=4, n_bytes=340, priority=0 actions=CONTROLLER:65535
 cookie=0x0, duration=3.5s, table=0, n_packets=2, n_bytes=196, priority=1,in_port=1,dl_dst=00:00:00:00:00:02,dl_src=00:00:00:00:00:01 actions=output:2
 cookie=0x0, duration=3.5s, table=0, n_packets=1, n_bytes=98, priority=1,in_port=2,dl_dst=00:00:00:00:00:01,dl_src=00:00:00:00:00:02 actions=output:1
```

O _dump_ exibe com fidelidade três entradas na tabela principal do datapath `s1`:

- **Regra Mestra Base (Table-Miss):** Cujas métricas garantem que tudo de bizarro seja direcionado a API central `actions=CONTROLLER`, amparada pela humilde e submissa `priority=0`. Essa regra garante que o tráfego jamais seja perdido, apenas redirecionado ao cérebro SDN.
- **Fluxo de Ida (Regra Reativa Injetada):** Assinatura recém atrelada pela memória do Ryu que exige obrigatoriamente prioridade de força 1 para se sobrepor perante o Table Miss, informando aos cabos que quando houver correspondência de "Origem h1" e de "Destino h2" e "Porta de Origem 1", que ele direcione a energia em bits cegamente para a saída da porta 2 (`actions=output:2`).
- **Fluxo Reverso de Voltas:** Condicionante diametralmente contrária mapeando que quando pacotes reacionários saem do h2 voltando a h1, eles devam bater na ação `actions=output:1`.
  Esses fluxos gravados explicam inteiramente como o OVS se tornou um aparelho gerenciável em tão pouco lapso temporal.

### 3.6. Análise Aprofundada do Código simple_switch_13

Após o exaustivo laboratório das ramificações físicas do OpenFlow, o estudo minucioso de software do script embarcado `simple_switch_13.py` é essencial para entender as vísceras da framework Ryu SDN.
Nativamente, switches burros são regidos pelos métodos assíncronos e orientados a Eventos (Handlers) da documentação do OpenFlow através das amarrações da livraria nativa do OS.

O Controller possui um Dicionário nativo chamado `self.mac_to_port` que trabalha de forma centralizadora como Tabela CAM Master de redes interconectadas em software.

**Decorators e Manipuladores Globais de Eventos:**

1. **`switch_features_handler`:** Quando ocorre instâncias do tipo `EventOFPSwitchFeatures`, quer dizer que Switch novo ativou na linha e disse alô de suas propriedades de datapath. O método atrelado neste momento faz um dump imutável mandando pacotes injetores na Tabela do roteador determinando regras `priority=0` em alusão ao fluxo `Table-Miss` discutido previamente e que comanda a ação global direcionada as portas controladoras de exceções base. O trecho crucial do código em Python responsável por injetar essa regra formadora possui a seguinte assinatura:
   ```python
   match = parser.OFPMatch()
   actions = [parser.OFPActionOutput(ofproto.OFPP_CONTROLLER,
                                     ofproto.OFPCML_NO_BUFFER)]
   self.add_flow(datapath, 0, match, actions)
   ```
2. **`packet_in_handler`:** Quando as Table-Miss atuam em falhas (como nos Pings inéditos), elas invocam em Software a classe de Evento Baseada em Recebimento de Pacotes (`EventOFPPacketIn`).
3. O controlador inspeciona todos os bits do Ethernet Header da execeção recém invocada. Captura seu destino e remetente em Strings base, gravando e alterando em estado mutável o Dicionário `mac_to_port`. Adiciona que a MAC Address original "Surgiu" naquela referida indexação de cabo conectante do switch (`in_port`). Efetivando-se aí a capacidade do "Learning Switch":
   ```python
   self.mac_to_port[dpid][src] = in_port
   ```
4. Como segundo ato do algorítimo "PacketIn", este indaga no banco recém alterado pela CAM Dictionary: O MAC destino a quem se reflete este pacote estaria lá? Se as amarras atestam que "não está" (ex: pacotes Broadcast FF:FF:FF:FF:FF:FF ou Unicast desconhecido), o algorítmo aponta `OFPActionOutput` destinadas as métricas genéricas universais para `OFPP_FLOOD`. E envia as estruturas OpenFlow num recipiente de saída `OFPPacketOut`.
   ```python
   if dst in self.mac_to_port[dpid]:
       out_port = self.mac_to_port[dpid][dst]
   else:
       out_port = ofproto.OFPP_FLOOD
   ```
5. Se a resposta no Dicionário disser "Sim", então o Ryu atesta a porta de silício do destino de hardware real. O controlador aciona seu método auxiliar customizado de Flow (`add_flow()`) que molda o injetor imutável OpenFlow de `OFPFlowMod` combinando de fato num _Match Field_ irrefutável o Destino, Origem e Porta de saída, estancando eventuais falhas futuras.

---

## 4. Considerações sobre a Topologia Híbrida e Escalonabilidade

Este relatório demonstra cabalmente o principal fator positivo da arquitetura SDN: Escalonabilidade Otimizada. Ao contrário do que poderia se intuir inicialmente, o fato do Ryu atuar num host remoto Python centralizador **não causa lentidão de processamento na rede como um todo**. Isso ocorre devido à genial mecânica atestada através dos rastros de Wireshark na etapa de Teste de Ping Replicado.

Ao testar a topologia pela segunda vez (no segundo acionamento do Ping), presenciamos o absoluto silêncio da aba OFPT no painel Network Analyzer. Como o `simple_switch_13` atua através das injeções cirúrgicas de `FLOW_MOD` no evento primordial de ocorrência, ele essencialmente treina os switches mudos a agirem com autonomia temporária de _Line Rate_. Isso alivia a placa de rede do servidor mestre Controlador e delega o processamento exaustivo a quem mais sabe lidá-lo com destreza: os microcontroladores internos ASICs do Datapath OVS.

Adicionalmente, as experimentações com a flag `protocols=OpenFlow13` demonstraram uma estabilidade que iterações antigas do protocolo careciam, lidando com pacotes mutilados e métricas de portas múltiplas de forma muito mais estruturada através dos relatórios de recursos do `FEATURES_REPLY`. O uso da Controladora externa em detrimento da controladora teste nativa OVS mostrou-se de fato um mal necessário benéfico, expondo ao desenvolvedor a realidade operacional que se oculta através dos bastidores das abstrações virtuais.

---

## 5. Conclusão Final

Os dois laboratórios práticos cumpriram com exatidão sua meta educacional de clarificar a separação arquitetural da infraestrutura e a da automação SDN e API.

Pela camada do Mininet (Laboratório 1), confirmou-se que não há limites tangíveis quanto a experimentação das redes; O _walkthrough_ básico atestou a manipulação individualística de processos de SO como pontes exclusivas virtuais, sendo a elaboração programática em Python (Topologia com 4 Switches e 11 Hosts controlando perda simulada dos cabos) de incomensurável valor para comprovar quão poderoso é automatizar ecossistemas robustos em menos de 100 linhas de código do Mininet `Topo` Class.

Pela camada do Ryu e do protocolo (Laboratório 2), desvendou-se a complexidade oculta de cada ping efetuado em um link virtual. As dissecções aprofundadas com o _Network Packet Analyzer (Wireshark)_ corroboram sem margem a dúvida como o silício atua sem instruções: Despachando o caos do _Table-Miss_ via `PACKET_IN` para ser intepretado na lógica em Python que, após entender o ecossistema construído pelo tráfego passante atrelado à porta de acesso (`mac_to_port`), otimiza perpetuamente futuras transações injetando micro-regras diretas no Switch com o uso dos pacotes gerenciais `FLOW_MOD` de forma a construir e atuar como um _Learning Switch_ resiliente, passivo e independente.

---

## 6. Anexos e Referências de Código

Todos os artefatos de software desenvolvidos e os logs completos gerados ao longo destes experimentos, bem como os arquivos estáticos de captura do Wireshark (.pcapng), encontram-se dispostos e públicos no repositório vinculado a esta entrega. Abaixo seguem as ligações diretas (links) para o código em nuvem:

- **Projeto e Documentação Original**: [project_description.txt](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/project_description.txt)
- **Scripts Shell do Lab 2 Ryu**: [Pasta scripts/](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/tree/main/scripts)
- **Código Fonte Python da Topologia Custom (Lab 1)**: [lab1_phase2.py](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/scripts/lab1_phase2.py)
- **Logs da Execução - Parte 1 Básica**: [relatorio_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_walkthrough.md)
- **Logs da Execução - Parte 1 Avançada**: [relatorio_full_walkthrough.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_full_walkthrough.md)
- **Logs da Execução - Parte 2 Python Custom**: [relatorio_phase2.md](https://github.com/ualaci/report2-mininet-ryu-ppcomp-mpca-comp-networks/blob/main/relatorio_phase2.md)
  """

with open("C:/Users/Ualaci/Documents/Git/report2-mininet-ryu-ppcomp-mpca-comp-networks/relatorio.md", "w", encoding="utf-8") as f:
f.write(content)
