export FILE_SERVER="https://raw.githubusercontent.com/techBeck03/firefly/master"
export POD="1"
export TIER="load-sim"
curl -o /tmp/siwapp-${TIER}.sh ${FILE_SERVER}/siwapp-${TIER}.sh
chmod +x /tmp/siwapp-${TIER}.sh
cd /tmp
