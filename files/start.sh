#!/bin/sh

# Usage:
# NUM=<number_of_proxies> start.sh

BEGIN_PORT=9050
CONF_PROXYCHAINS="/tmp/proxychains.conf"
export CONF_HAPROXY="/tmp/haproxy.cfg"
CONF_SUPERVISORD="/tmp/supervisord.conf"
SUPERVISORD_TEMPLATE="/tmp/supervisord_template"

if test -z "${PROXY_PORT}"
then
	PROXY_PORT=9999
fi

if test -z "${NUM}" 
then
	printf "Please specify environment variable NUM=x\n"
	exit 1
fi

mkdir /run/tor
chmod 700 /run/tor
chown nobody:nobody /run/tor

for i in $(seq "${NUM}")
do
	CONF_DATA_DIR=$(printf "/var/lib/tor%d" "${i}")
	CONF_PORT=$((BEGIN_PORT + i))
	CONF_FILE=$(printf "/etc/tor/torrc-%d" "${i}")

	# create new tor data folder
	cp -r /var/lib/tor "${CONF_DATA_DIR}"
	chown nobody:nobody "${CONF_DATA_DIR}"

	# create new tor config file
	cp /etc/tor/torrc_template "${CONF_FILE}"

	# edit configuration
	sed "s:CONF_PORT:${CONF_PORT}:" -i "${CONF_FILE}"
	sed "s:CONF_DATA_DIR:${CONF_DATA_DIR}:" -i "${CONF_FILE}"

	#su -s /bin/sh nobody -c "tor -f ${CONF_FILE}" >"${CONF_DATA_DIR}/log" 2>&1 &
	cat "${SUPERVISORD_TEMPLATE}" | \
		sed \
			-e "s:_CONF_PORT_:${CONF_PORT}:g" \
			-e "s:_CONF_FILE_:${CONF_FILE}:g" \
			-e "s:_CONF_DATA_DIR_:${CONF_DATA_DIR}:g" \
		>> "${CONF_SUPERVISORD}"
	printf "socks5 127.0.0.1 %s\n" "${CONF_PORT}" >> "${CONF_PROXYCHAINS}"
	printf "\tserver tor-%s 127.0.0.1:%s\n" "${CONF_PORT}" "${CONF_PORT}" >> "${CONF_HAPROXY}"

done

#haproxy -f "${CONF_HAPROXY}"

supervisord -c "${CONF_SUPERVISORD}"

#cd "$(dirname ${CONF_PROXYCHAINS})" && \
#  su -s /bin/sh nobody -c "proxychains4 nc --proxy-type http -l ${PROXY_PORT} -k"
