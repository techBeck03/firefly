#!/bin/bash -x

curl -o /tmp/provisioningVars.sh ${FILE_SERVER}/pod_${POD}_variables.sh
. /tmp/provisioningVars.sh

yum -y update
yum install -y haproxy

echo "Configuring haproxy"
su -c 'echo "
#---------------------------------------------------------------------
# http frontend
#---------------------------------------------------------------------
frontend  http_in
        mode http
        bind *:80
        default_backend siwapp_apps
#---------------------------------------------------------------------
# Siwapp App Server Backend
#---------------------------------------------------------------------
backend siwapp_apps
	balance roundrobin
	cookie SERVERID insert indirect nocache
" >> /etc/haproxy/haproxy.cfg'

# Set internal separator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
IFS=','
ipArr=(${APP_TIER_IPS}) # Array of IPs in my tier.

echo "Creating haproxy config files"
# Iterate through list of hosts to add hosts and corresponding IPs to haproxy config file.
host_index=0
for host in $APP_TIER_HOSTNAMES ; do
    su -c "echo 'server ${host} ${ipArr[${host_index}]}:8081 check cookie ${host} inter 5s' >> /etc/haproxy/haproxy.cfg"
    su -c "echo '${ipArr[${host_index}]} ${host}' >> /etc/hosts"
    let host_index=${host_index}+1
done
# Set internal separator back to original.
IFS=${temp_ifs}

systemctl start haproxy
systemctl enable haproxy
echo "App HAProxy install complete"
