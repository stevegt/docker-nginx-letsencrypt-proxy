#!/bin/bash

i="1"

ingress_address=$(hostname -i)

certbot_hosts=""

while : ; do
    ingress_port="INGRESS_PORT_$i"
    context="SERVICE_CONTEXT_$i"
    host="SERVICE_HOST_$i"
    address="SERVICE_ADDRESS_$i"
    port="SERVICE_PORT_$i"

    cdir=/etc/nginx/${!context}.d
    mkdir -p $cdir
    conf=$cdir/${!host}-${!port}.conf

    if [[ -z "${!context}" || -z "${!host}" || -z "${!address}" || -z "${!port}" ]] && [ !  -e $conf ]
    then
        break
    fi

    if [ ! -e $conf ]
    then
        cp ${!context}.conf $conf
        sed -i "s|listen addr:port|listen ${ingress_address}:${!ingress_port}|g" $conf
        sed -i "s|example.com|${!host}|g" $conf
        sed -i "s|0.0.0.0|${!address}|g" $conf
        sed -i "s|0000|${!port}|g" $conf
        if [ ${!context} == "http" ]
        then
            certbot_hosts="$certbot_hosts ${!host}"
        fi
    fi

    if [ -e /etc/letsencrypt/live/"${!host}"/fullchain.pem ] && [ "${!context}" == "http" ] 
    then
        echo "Certificate is already created for host ${!host}" 
    else
        certbot_hosts="$certbot_hosts ${!host}"
    fi
    i=$[$i+1]
done

for host in $(echo $certbot_hosts | tr ' ' '\n' | sort -u)
do
    certbot $CERTBOT_FLAGS -n --nginx -d ${host} --agree-tos --email $EMAIL
done

nginx -s stop
sleep 1
killall nginx
sleep 1
netstat -tulpn
ps -eaf

service cron start
crontab /crontab
exec nginx -g 'daemon off;'
