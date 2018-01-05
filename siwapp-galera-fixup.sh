#!/bin/bash -x

. /usr/local/siwapp/provisioningVars.sh

temp_ifs=${IFS}
IFS=','
dbHosts=(${DB_TIER_HOSTNAMES}) # Array of nodes in my tier.
dbIps=(${DB_TIER_IPS}) # Array of IPs in my tier.
master=${dbHosts[0]} # Let the first node in the service tier be the master.
master_addr=${dbIps[0]} # Let the first node in the service tier be the master.

IFS=${temp_ifs}

if [ "${master}" == "${HOSTNAME}" ]; then
    sed -i "s/safe_to_bootstrap.*/safe_to_bootstrap: 1/" /var/lib/mysql/grastate.dat
    systemctl set-environment _WSREP_NEW_CLUSTER='--wsrep-new-cluster'

else
    echo  "Waiting for master node to be initialized..."
    COUNT=0
    MAX=50
    SLEEP_TIME=5
    ERR=0

    # Keep checking for port 3306 on the master to be open
    until $(mysql -h $master_addr -u root -p"${GALERA_DB_ROOT_PWD}" -e ""); do
      sleep ${SLEEP_TIME}
      let "COUNT++"
      echo ${COUNT}
      if [ ${COUNT} -gt ${MAX} ]; then
        ERR=1
        break
      fi
    done
    if [ ${ERR} -ne 0 ]; then
        echo "Failed to find port 3306 open on master node, so guessing something is wrong."
        exit 1
    else
        echo "starting slave"
    fi
fi