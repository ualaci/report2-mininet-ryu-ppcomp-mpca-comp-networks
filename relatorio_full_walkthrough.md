# Relatório do Mininet Walkthrough
Este relatório contém a execução de TODAS as etapas do tutorial oficial.

## Parte 1: Display Startup Options
> Comando: `sudo mn -h`
```text
Usage: mn [options]
(type mn -h for details)

The mn utility creates Mininet network from the command line. It can create
parametrized topologies, invoke the Mininet CLI, and run tests.

Options:
  -h, --help            show this help message and exit
  --switch=SWITCH       default|ivs|lxbr|ovs|ovsbr|ovsk|user[,param=value...]
                        ovs=OVSSwitch default=OVSSwitch ovsk=OVSSwitch
                        lxbr=LinuxBridge user=UserSwitch ivs=IVSSwitch
                        ovsbr=OVSBridge
  --host=HOST           cfs|proc|rt[,param=value...]
                        rt=CPULimitedHost{'sched': 'rt'} proc=Host
                        cfs=CPULimitedHost{'sched': 'cfs'}
  --controller=CONTROLLER
                        default|none|nox|ovsc|ref|remote|ryu[,param=value...]
                        ovsc=OVSController none=NullController
                        remote=RemoteController default=DefaultController
                        nox=NOX ryu=Ryu ref=Controller
  --link=LINK           default|ovs|tc|tcu[,param=value...] default=Link
                        ovs=OVSLink tcu=TCULink tc=TCLink
  --topo=TOPO           linear|minimal|reversed|single|torus|tree[,param=value
                        ...] linear=LinearTopo torus=TorusTopo tree=TreeTopo
                        single=SingleSwitchTopo
                        reversed=SingleSwitchReversedTopo minimal=MinimalTopo
  -c, --clean           clean and exit
  --custom=CUSTOM       read custom classes or params from .py file(s)
  --test=TESTS          cli|build|pingall|pingpair|iperf|all|iperfudp|none|pin
                        gpair|iperfudp|pingall|iperfUDP
  -x, --xterms          spawn xterms for each node
  -i IPBASE, --ipbase=IPBASE
                        base IP address for hosts
  --mac                 automatically set host MACs
  --arp                 set all-pairs ARP entries
  -v VERBOSITY, --verbosity=VERBOSITY
                        info|warning|critical|error|debug|output
  --innamespace         sw and ctrl in namespace?
  --listenport=LISTENPORT
                        base port for passive switch listening
  --nolistenport        don't use passive listening port
  --pre=PRE             CLI script to run before tests
  --post=POST           CLI script to run after tests
  --pin                 pin hosts to CPU cores (requires --host cfs or --host
                        rt)
  --nat                 [option=val...] adds a NAT to the topology that
                        connects Mininet hosts to the physical network.
                        Warning: This may route any traffic on the machine
                        that uses Mininet's IP subnet into the Mininet
                        network. If you need to change Mininet's IP subnet,
                        see the --ipbase option.
  --version             prints the version and exits
  --cluster=server1,server2...
                        run on multiple servers (experimental!)
  --placement=block|random
                        node placement for --cluster (experimental!)
```

## Parte 1: Interact with Hosts and Switches / Test Connectivity / Web Server
Executando sessão interativa no Mininet...
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Starting CLI:
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
available nodes are: 
c0 h1 h2 s1
invalid syntax (<string>, line 1)
h1 h1-eth0:s1-eth1
h2 h2-eth0:s1-eth2
s1 lo:  s1-eth1:h1-eth0 s1-eth2:h2-eth0
c0
invalid syntax (<string>, line 1)
<Host h1: h1-eth0:10.0.0.1 pid=11273> 
<Host h2: h2-eth0:10.0.0.2 pid=11275> 
<OVSSwitch s1: lo:127.0.0.1,s1-eth1:None,s1-eth2:None pid=11280> 
<RemoteController c0: 127.0.0.1:6653 pid=11254> 
invalid syntax (<string>, line 1)
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

invalid syntax (<string>, line 1)
br-955cf13c8d74: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
        ether f6:a1:a3:18:2d:08  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 1a:35:79:95:64:4f  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 60 overruns 0  carrier 0  collisions 0

enp59s0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 04:bf:1b:4d:8b:21  txqueuelen 1000  (Ethernet)
        RX packets 6190  bytes 1241816 (1.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 8175  bytes 701464 (701.4 KB)
        TX errors 0  dropped 41 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 222964  bytes 15842816 (15.8 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 222964  bytes 15842816 (15.8 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ovs-system: flags=4098<BROADCAST,MULTICAST>  mtu 1500
        ether aa:27:68:3e:6f:ac  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

s1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
        ether 06:13:f0:5a:c8:4c  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

s1-eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::94c5:c8ff:fee3:95bb  prefixlen 64  scopeid 0x20<link>
        ether 96:c5:c8:e3:95:bb  txqueuelen 1000  (Ethernet)
        RX packets 1  bytes 90 (90.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2  bytes 180 (180.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

s1-eth2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::18b1:b0ff:fe1e:1af  prefixlen 64  scopeid 0x20<link>
        ether 1a:b1:b0:1e:01:af  txqueuelen 1000  (Ethernet)
        RX packets 1  bytes 90 (90.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1  bytes 90 (90.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

tailscale0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1280
        inet6 fe80::265a:e0ed:39b9:815  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 938  bytes 160554 (160.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1468  bytes 115880 (115.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlp0s20f3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.19.148.168  netmask 255.255.240.0  broadcast 172.19.159.255
        inet6 fe80::46ec:1aa4:ce49:b830  prefixlen 64  scopeid 0x20<link>
        ether f0:d4:15:78:bb:a8  txqueuelen 1000  (Ethernet)
        RX packets 1271405  bytes 1131608186 (1.1 GB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 652975  bytes 398711841 (398.7 MB)
        TX errors 0  dropped 124 overruns 0  carrier 0  collisions 0

invalid syntax (<string>, line 1)
    PID TTY          TIME CMD
    645 pts/1    00:00:02 ryu-manager
   1064 pts/2    00:00:44 wireshark
  11183 pts/2    00:00:00 bash
  11230 pts/2    00:00:00 sudo
  11231 pts/2    00:00:00 grep
  11232 pts/2    00:00:00 tee
  11250 pts/2    00:00:00 mn
  11355 pts/2    00:00:00 dumpcap
  11364 pts/4    00:00:00 ps
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=3.91 ms

--- 10.0.0.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 3.912/3.912/3.912/0.000 ms
invalid syntax (<string>, line 1)
*** Ping: testing ping reachability
h1 -> h2 
h2 -> h1 
*** Results: 0% dropped (2/2 received)
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
[1] 11369
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 6.965 seconds
```

## Parte 2: Run a Regression Test (Pingpair)
> Comando: `sudo mn --test pingpair --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Waiting for switches to connect
s1 
h1 -> h2 
h2 -> h1 
*** Results: 0% dropped (2/2 received)
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 12.217 seconds
```

## Parte 2: Run a Regression Test (Iperf)
> Comando: `sudo mn --test iperf --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Waiting for switches to connect
s1 
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['32.1 Gbits/sec', '32.2 Gbits/sec']
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 13.379 seconds
```

## Parte 2: Changing Topology Size and Type (Single, 3)
> Comando: `sudo mn --test pingall --topo single,3 --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 h3 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) (h3, s1) 
*** Configuring hosts
h1 h2 h3 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Waiting for switches to connect
s1 
*** Ping: testing ping reachability
h1 -> h2 h3 
h2 -> h1 h3 
h3 -> h1 h2 
*** Results: 0% dropped (6/6 received)
*** Stopping 1 controllers
c0 
*** Stopping 3 links
...
*** Stopping 1 switches
s1 
*** Stopping 3 hosts
h1 h2 h3 
*** Done
completed in 7.939 seconds
```

## Parte 2: Changing Topology Size and Type (Linear, 4)
> Comando: `sudo mn --test pingall --topo linear,4 --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 h3 h4 
*** Adding switches:
s1 s2 s3 s4 
*** Adding links:
(h1, s1) (h2, s2) (h3, s3) (h4, s4) (s2, s1) (s3, s2) (s4, s3) 
*** Configuring hosts
h1 h2 h3 h4 
*** Starting controller
c0 
*** Starting 4 switches
s1 s2 s3 s4 ...
*** Waiting for switches to connect
s1 s2 s3 s4 
*** Ping: testing ping reachability
h1 -> h2 h3 h4 
h2 -> h1 h3 h4 
h3 -> h1 h2 h4 
h4 -> h1 h2 h3 
*** Results: 0% dropped (12/12 received)
*** Stopping 1 controllers
c0 
*** Stopping 7 links
.......
*** Stopping 4 switches
s1 s2 s3 s4 
*** Stopping 4 hosts
h1 h2 h3 h4 
*** Done
completed in 13.045 seconds
```

## Parte 2: Link variations (Testando Iperf com Delay e Bandwidth)
> Comando: `sudo mn --link tc,bw=10,delay=10ms --test iperf --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h1, s1) (10.00Mbit 10ms delay) (10.00Mbit 10ms delay) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...(10.00Mbit 10ms delay) (10.00Mbit 10ms delay) 
*** Waiting for switches to connect
s1 
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['9.50 Mbits/sec', '12.0 Mbits/sec']
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 18.931 seconds
```

## Parte 2: Adjustable Verbosity (Debug)
> Comando: `sudo mn -v debug --test none --controller remote`
```text
*** errRun: ['grep', '-c', 'processor', '/proc/cpuinfo'] 
20
  0*** Setting resource limits
*** Creating network
*** Adding controller
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ifconfig'] 
/usr/sbin/ifconfig
  0*** c0 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
*** c0 : ('echo A | telnet -e A 127.0.0.1 6653',)
Telnet escape character is 'A'.
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is 'A'.

telnet> Connection closed.
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ifconfig'] 
/usr/sbin/ifconfig
  0*** h1 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
h1 *** h2 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
h2 
*** Adding switches:
*** errRun: ['which', 'ovs-vsctl'] 
/usr/bin/ovs-vsctl
  0*** errRun: ['ovs-vsctl', '-t', '1', 'show'] 
05835b93-a06d-4f04-afc6-79f0e02fea71
    ovs_version: "2.13.8"
  0*** errRun: ['ovs-vsctl', '--version'] 
ovs-vsctl (Open vSwitch) 2.13.8
DB Schema 8.2.0
  0*** s1 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m

added intf lo (0) to node s1
*** s1 : ('ifconfig', 'lo', 'up')
s1 
*** Adding links:
*** h1 : ('ip link add name h1-eth0 address 7a:77:d0:74:6c:a8 type veth peer name s1-eth1 address 5e:6b:d2:d8:c1:3d netns 13014',)

added intf h1-eth0 (0) to node h1
moving h1-eth0 into namespace for h1 
*** h1 : ('ifconfig', 'h1-eth0', 'up')

added intf s1-eth1 (1) to node s1
*** s1 : ('ifconfig', 's1-eth1', 'up')
(h1, s1) *** h2 : ('ip link add name h2-eth0 address 66:31:a8:bc:73:e8 type veth peer name s1-eth2 address c2:30:1f:e6:ad:93 netns 13014',)

added intf h2-eth0 (0) to node h2
moving h2-eth0 into namespace for h2 
*** h2 : ('ifconfig', 'h2-eth0', 'up')

added intf s1-eth2 (2) to node s1
*** s1 : ('ifconfig', 's1-eth2', 'up')
(h2, s1) 
*** Configuring hosts
h1 *** h1 : ('ifconfig', 'h1-eth0', '10.0.0.1/8', 'up')
*** h1 : ('ifconfig lo up',)
h2 *** h2 : ('ifconfig', 'h2-eth0', '10.0.0.2/8', 'up')
*** h2 : ('ifconfig lo up',)

*** Starting controller
c0 
*** Starting 1 switches
s1 ...*** errRun: ovs-vsctl -- --id=@s1c0 create Controller target=\"tcp:127.0.0.1:6653\" max_backoff=1000 -- --id=@s1-listen create Controller target=\"ptcp:6654\" max_backoff=1000 -- --if-exists del-br s1 -- add-br s1 -- set bridge s1 controller=[@s1c0,@s1-listen] other_config:datapath-id=0000000000000001 fail_mode=secure other-config:disable-in-band=true -- add-port s1 s1-eth1 -- set Interface s1-eth1 ofport_request=1 -- add-port s1 s1-eth2 -- set Interface s1-eth2 ofport_request=2 
f319df53-16f5-4c11-a00b-1d77dd468b5b
cc12806c-c10f-4485-86de-3671931b91e8
  0
*** Stopping 1 controllers
c0 
*** Stopping 2 links
.*** h1 : ('ip link del h1-eth0',)
.*** h2 : ('ip link del h2-eth0',)

*** Stopping 1 switches
*** errRun: ['ovs-vsctl', '--if-exists', 'del-br', 's1'] 
  0*** errRun: ['kill', '-HUP', '13014'] 
  0s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 7.019 seconds
```

## Parte 2: ID = MAC (Forçando MACs legíveis)
> Comando: `sudo mn --mac --test pingall --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Waiting for switches to connect
s1 
*** Ping: testing ping reachability
h1 -> h2 
h2 -> h1 
*** Results: 0% dropped (2/2 received)
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 12.361 seconds
```

## Parte 2: Other Switch Types (User Space Switch)
> Comando: `sudo mn --switch user --test iperf --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
Cannot find required executable ofdatapath.
Please make sure that the OpenFlow reference user switch(openflow.org) is installed and available in your $PATH:
(/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin)
```

## Parte 2: Other Switch Types (OVS Kernel Switch)
> Comando: `sudo mn --switch ovsk --test iperf --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Waiting for switches to connect
s1 
*** Iperf: testing TCP bandwidth between h1 and h2 
*** Results: ['31.2 Gbits/sec', '31.3 Gbits/sec']
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 16.305 seconds
```

## Parte 2: Mininet Benchmark
> Comando: `sudo mn --test none --controller remote`
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 6.211 seconds
```

## Parte 3: CLI Commands (Python Interpreter e Link Up/Down)
Executando sessão interativa para a Parte 3...
```text
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 
*** Adding switches:
s1 
*** Adding links:
(h1, s1) (h2, s1) 
*** Configuring hosts
h1 h2 
*** Starting controller
c0 
*** Starting 1 switches
s1 ...
*** Starting CLI:
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
hello world
invalid syntax (<string>, line 1)
['IP', 'MAC', 'OVSVersion', 'TCReapply', '__class__', '__delattr__', '__dict__', '__doc__', '__format__', '__getattribute__', '__hash__', '__init__', '__module__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_popen', '_uuids', 'addIntf', 'argmax', 'attach', 'batch', 'batchShutdown', 'batchStartup', 'bridgeOpts', 'checkSetup', 'cleanup', 'cmd', 'cmdPrint', 'cmds', 'commands', 'config', 'configDefault', 'connected', 'connectionsTo', 'controlIntf', 'controllerUUIDs', 'datapath', 'defaultDpid', 'defaultIntf', 'deleteIntfs', 'detach', 'dpctl', 'dpid', 'dpidLen', 'execed', 'failMode', 'fdToNode', 'inNamespace', 'inToNode', 'inband', 'intf', 'intfIsUp', 'intfList', 'intfNames', 'intfOpts', 'intfs', 'isOldOVS', 'isSetup', 'lastCmd', 'lastPid', 'linkTo', 'listenPort', 'monitor', 'mountPrivateDirs', 'name', 'nameToIntf', 'newPort', 'opts', 'outToNode', 'params', 'pexec', 'pid', 'pollOut', 'popen', 'portBase', 'ports', 'privateDirs', 'protocols', 'read', 'readbuf', 'readline', 'reconnectms', 'sendCmd', 'sendInt', 'setARP', 'setDefaultRoute', 'setHostRoute', 'setIP', 'setMAC', 'setParam', 'setup', 'shell', 'start', 'startShell', 'stdin', 'stdout', 'stop', 'stp', 'terminate', 'unmountPrivateDirs', 'vsctl', 'waitOutput', 'waitReadable', 'waiting', 'write']
invalid syntax (<string>, line 1)
10.0.0.1
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
*** Ping: testing ping reachability
h1 -> X 
h2 -> X 
*** Results: 100% dropped (0/2 received)
invalid syntax (<string>, line 1)
invalid syntax (<string>, line 1)
*** Ping: testing ping reachability
h1 -> h2 
h2 -> h1 
*** Results: 0% dropped (2/2 received)
*** Stopping 1 controllers
c0 
*** Stopping 2 links
..
*** Stopping 1 switches
s1 
*** Stopping 2 hosts
h1 h2 
*** Done
completed in 9.953 seconds
```
