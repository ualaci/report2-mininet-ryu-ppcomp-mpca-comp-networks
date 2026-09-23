FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalação das dependências principais (Python 3, Git, Mininet, OpenvSwitch, etc.)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python-is-python2 \
    iperf \
    git \
    mininet \
    openvswitch-switch \
    openvswitch-common \
    wireshark-qt \
    tshark \
    iproute2 \
    net-tools \
    iputils-ping \
    curl \
    sudo \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Instalação das bibliotecas Python via PIP
RUN pip3 install mininet

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Entrypoint será responsável por subir os serviços do Open vSwitch
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
