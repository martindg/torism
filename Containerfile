FROM alpine

RUN apk add tor proxychains-ng haproxy && apk cache clean

COPY files/start.sh /
COPY files/torrc_template /etc/tor
COPY files/proxychains.conf /tmp/
COPY files/haproxy.cfg /tmp/

CMD /bin/sh /start.sh
