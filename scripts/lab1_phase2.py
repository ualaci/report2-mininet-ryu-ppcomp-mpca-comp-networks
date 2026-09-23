#!/usr/bin/python
# -*- coding: utf-8 -*-

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Host, RemoteController
from mininet.link import TCLink
from mininet.util import dumpNodeConnections
from mininet.log import setLogLevel, info

class CustomTopo( Topo ):
    "Topologia customizada com 4 switches e 11 hosts."
    def build( self ):
        # 1. Criando os 4 switches
        info( "\n[Topologia] Criando 4 Switches...\n" )
        s1 = self.addSwitch( 's1' )
        s2 = self.addSwitch( 's2' )
        s3 = self.addSwitch( 's3' )
        s4 = self.addSwitch( 's4' )

        # 2. Conectando os switches entre si (formando uma linha s1-s2-s3-s4)
        info( "[Topologia] Interligando os switches em linha (s1-s2-s3-s4)...\n" )
        self.addLink( s1, s2 )
        self.addLink( s2, s3 )
        self.addLink( s3, s4 )

        # 3. Criando 11 hosts e os distribuindo pelos switches
        info( "[Topologia] Instanciando 11 hosts...\n" )
        hosts = []
        for i in range(1, 12):
            # Usando hosts normais ao invés de limitar CPU, pois cgroups não estão nativamente montados no Docker
            h = self.addHost( 'h%s' % i )
            hosts.append(h)

        info( "[Topologia] Distribuindo hosts nas portas dos switches...\n" )
        # Distribuindo as conexões (cabeamento)
        # 3 hosts no Switch 1
        for h in hosts[0:3]:
            self.addLink( h, s1, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        
        # 3 hosts no Switch 2
        for h in hosts[3:6]:
            self.addLink( h, s2, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        
        # 3 hosts no Switch 3
        for h in hosts[6:9]:
            self.addLink( h, s3, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )
        
        # 2 hosts no Switch 4
        for h in hosts[9:11]:
            self.addLink( h, s4, bw=10, delay='5ms', loss=2, max_queue_size=1000, use_htb=True )


def perfTest( net ):
    print("\n=============================================")
    print("Iniciando teste de banda: h1 vs Todos os Hosts")
    print("=============================================")
    
    # Captura o objeto do host h1
    h1 = net.get( 'h1' )
    
    # Itera sobre todos os hosts presentes na rede
    for host in net.hosts:
        # Pula o teste caso o host da vez seja o próprio h1
        if host.name != 'h1':
            print("\n[>] Testando iperf (Banda TCP) entre h1 e %s..." % host.name)
            # Executa o teste de banda entre a dupla e captura o resultado
            result = net.iperf( (h1, host) )
            print("    Resultado: TX = %s, RX = %s" % (result[0], result[1]))

if __name__ == '__main__':
    # Ativando log verbose do Mininet
    setLogLevel( 'info' )
    
    # Usando a topologia customizada
    topo = CustomTopo()
    
    # Inicializando o Mininet. 
    # Adicionamos controller=RemoteController para ele se conectar ao Ryu e não cair no erro do OVS Bridge.
    net = Mininet( 
          topo=topo,
          host=Host,
          link=TCLink,
          controller=RemoteController
         )
         
    net.start()
    
    print("\n--- Realizando o Dump das Conexoes ---")
    dumpNodeConnections( net.hosts ) 
    
    print("\n--- Testando a Conectividade da Rede (PingAll) ---")
    net.pingAll()
    
    perfTest( net )
    
    net.stop()
