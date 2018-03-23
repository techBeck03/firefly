#sed -i 's/enforcing/permissive/g' /etc/selinux/config /etc/selinux/config
#reboot
export FILE_SERVER="https://raw.githubusercontent.com/techBeck03/firefly/master/testing"
export POD="3"
export TIER="load-sim"
curl -o /tmp/siwapp-${TIER}.sh ${FILE_SERVER}/siwapp-${TIER}.sh
chmod +x /tmp/siwapp-${TIER}.sh
cd /tmp
