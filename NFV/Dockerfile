FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nftables \
    iproute2 \
    iputils-ping \
    tcpdump \
    curl \
    procps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /firewall

COPY firewall.sh /firewall.sh
COPY nftables.conf /etc/nftables.conf

RUN chmod +x /firewall.sh

CMD ["/bin/bash", "/firewall.sh"]
