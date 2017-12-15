#!/bin/bash -x

curl -o /tmp/provisioningVars ${FILE_SERVER}/pod_${POD}_variables.sh
. /tmp/provisioningVars.sh

echo "Installing haproxy."
yum -y update
yum install -y haproxy

echo "Configuring haproxy"
echo "
#---------------------------------------------------------------------
# Siwapp App Server Backend
#---------------------------------------------------------------------
listen galera 0.0.0.0:3306
balance roundrobin
mode tcp
option tcpka
option mysql-check user haproxy
" >> /etc/haproxy/haproxy.cfg

# Set internal seperator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
IFS=','
# nodeArr=(${CliqrTier_siwapp_mariadb_NODE_ID}) # Array of nodes in my tier.
ipArr=(${DB_TIER_IPS}) # Array of IPs in my tier.

echo "Creating haproxy config files"
# Iterate through list of hosts to add hosts and corresponding IPs to haproxy config file.
host_index=0
for host in $DB_TIER_HOSTNAMES ; do
    echo 'server ${host} ${ipArr[${host_index}]}:3306 check inter 5s' >> /etc/haproxy/haproxy.cfg
    echo '${ipArr[${host_index}]} ${host}' >> /etc/hosts
    let host_index=${host_index}+1
done
# Set internal separator back to original.
IFS=${temp_ifs}

systemctl start haproxy
systemctl enable haproxy

echo "DB HAProxy install complete"