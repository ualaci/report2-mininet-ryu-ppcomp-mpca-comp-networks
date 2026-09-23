# Relatório da Fase 2 do Mininet
Este relatório contém a execução do script Python customizado de 4 Switches e 11 Hosts.

```text

[Topologia] Criando 4 Switches...
[Topologia] Interligando os switches em linha (s1-s2-s3-s4)...
[Topologia] Instanciando 11 hosts...
[Topologia] Distribuindo hosts nas portas dos switches...
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 
*** Adding switches:
s1 s2 s3 s4 
*** Adding links:
(10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h1, s1) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h2, s1) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h3, s1) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h4, s2) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h5, s2) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h6, s2) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h7, s3) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h8, s3) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h9, s3) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h10, s4) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (h11, s4) (s1, s2) (s2, s3) (s3, s4) 
*** Configuring hosts
h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 
*** Starting controller
c0 
*** Starting 4 switches
s1 s2 s3 s4 ...(10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) (10.00Mbit 5ms delay 2.00000% loss) 

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

--- Testando a Conectividade da Rede (PingAll) ---
*** Ping: testing ping reachability
h1 -> h2 h3 X h5 X h7 h8 h9 h10 h11 
h2 -> h1 h3 h4 h5 X h7 h8 h9 h10 h11 
h3 -> h1 X h4 h5 h6 h7 h8 h9 h10 h11 
h4 -> h1 h2 h3 h5 h6 h7 h8 h9 h10 h11 
h5 -> h1 h2 h3 h4 h6 h7 h8 h9 h10 h11 
h6 -> h1 h2 h3 h4 X h7 h8 h9 h10 h11 
h7 -> h1 h2 h3 h4 h5 h6 h8 h9 h10 h11 
h8 -> h1 h2 h3 h4 X h6 X X h10 h11 
h9 -> h1 h2 h3 h4 h5 h6 h7 h8 h10 h11 
h10 -> h1 h2 h3 h4 X h6 h7 h8 h9 h11 
h11 -> h1 h2 h3 X h5 h6 h7 h8 h9 h10 
*** Results: 9% dropped (100/110 received)

=============================================
Iniciando teste de banda: h1 vs Todos os Hosts
=============================================

[>] Testando iperf (Banda TCP) entre h1 e h2...
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['3.12 Mbits/sec', '3.15 Mbits/sec']
    Resultado: TX = 3.12 Mbits/sec, RX = 3.15 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h3...
*** Iperf: testing TCP bandwidth between h1 and h3 
*** Results: ['3.13 Mbits/sec', '3.41 Mbits/sec']
    Resultado: TX = 3.13 Mbits/sec, RX = 3.41 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h4...
*** Iperf: testing TCP bandwidth between h1 and h4 
*** Results: ['3.12 Mbits/sec', '3.30 Mbits/sec']
    Resultado: TX = 3.12 Mbits/sec, RX = 3.30 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h5...
*** Iperf: testing TCP bandwidth between h1 and h5 
*** Results: ['3.14 Mbits/sec', '3.68 Mbits/sec']
    Resultado: TX = 3.14 Mbits/sec, RX = 3.68 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h6...
*** Iperf: testing TCP bandwidth between h1 and h6 
*** Results: ['4.20 Mbits/sec', '5.29 Mbits/sec']
    Resultado: TX = 4.20 Mbits/sec, RX = 5.29 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h7...
*** Iperf: testing TCP bandwidth between h1 and h7 
*** Results: ['2.94 Mbits/sec', '3.18 Mbits/sec']
    Resultado: TX = 2.94 Mbits/sec, RX = 3.18 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h8...
*** Iperf: testing TCP bandwidth between h1 and h8 
*** Results: ['3.16 Mbits/sec', '4.22 Mbits/sec']
    Resultado: TX = 3.16 Mbits/sec, RX = 4.22 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h9...
*** Iperf: testing TCP bandwidth between h1 and h9 
*** Results: ['2.73 Mbits/sec', '2.85 Mbits/sec']
    Resultado: TX = 2.73 Mbits/sec, RX = 2.85 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h10...
*** Iperf: testing TCP bandwidth between h1 and h10 
*** Results: ['3.45 Mbits/sec', '4.24 Mbits/sec']
    Resultado: TX = 3.45 Mbits/sec, RX = 4.24 Mbits/sec

[>] Testando iperf (Banda TCP) entre h1 e h11...
*** Iperf: testing TCP bandwidth between h1 and h11 
*** Results: ['3.08 Mbits/sec', '3.56 Mbits/sec']
    Resultado: TX = 3.08 Mbits/sec, RX = 3.56 Mbits/sec
*** Stopping 1 controllers
c0 
*** Stopping 14 links
..............
*** Stopping 4 switches
s1 s2 s3 s4 
*** Stopping 11 hosts
h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 
*** Done
```
