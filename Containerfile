FROM centos:8

RUN dnf install -y epel-release && dnf install -y tor git make gcc nmap-ncat

# Download and install `proxychains`
RUN git clone https://github.com/haad/proxychains && cd proxychains && ./configure && make && make install

COPY files/start.sh /
COPY files/torrc_template /etc/tor
COPY files/proxychains.conf /tmp/

CMD /bin/bash /start.sh
