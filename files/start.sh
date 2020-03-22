#!/bin/sh

# Usage:
# NUM=<number_of_proxies> start.sh

BEGIN_PORT=9050
CONF_PROXYCHAINS="/tmp/proxychains.conf"

if test -z "${PROXY_PORT}"
then
	PROXY_PORT=9999
fi

if test -z "${NUM}" 
then
	printf "Please specify environment variable NUM=x\n"
	exit 1
fi

for i in $(seq "${NUM}")
do
	CONF_DATA_DIR=$(printf "/var/lib/tor%d" "${i}")
	CONF_PORT=$((BEGIN_PORT + i))
	CONF_FILE=$(printf "/etc/tor/torrc-%d" "${i}")

	# create new tor data folder
	cp -r /var/lib/tor "${CONF_DATA_DIR}"
	chown toranon:toranon "${CONF_DATA_DIR}"

	# create new tor config file
	cp /etc/tor/torrc_template "${CONF_FILE}"

	# edit configuration
	sed "s:CONF_PORT:${CONF_PORT}:" -i "${CONF_FILE}"
	sed "s:CONF_DATA_DIR:${CONF_DATA_DIR}:" -i "${CONF_FILE}"

	runuser -c "tor -f ${CONF_FILE}" -s /bin/sh toranon >"${CONF_DATA_DIR}/log" 2>&1 &
	printf "socks5 127.0.0.1 %s\n" "${CONF_PORT}" >> "${CONF_PROXYCHAINS}"

done

cd "$(dirname ${CONF_PROXYCHAINS})" && \
  runuser -c "proxychains4 nc --proxy-type http -l ${PROXY_PORT} -k" -s /bin/sh nobody
