#!/bin/bash -x
curl -o /tmp/provisioningVars.sh ${FILE_SERVER}/pod_${POD}_variables.sh
. /tmp/provisioningVars.sh

app "Starting app install script"
yum -y update
yum -y install git httpd php php-mysql php-xml php-mbstring
yum clean all

git clone https://github.com/siwapp/siwapp-sf1.git /var/www/html/

mkdir /var/www/html/cache
chmod 777 /var/www/html/cache
chmod 777 /var/www/html/web/config.php
chmod 777 /var/www/html/config/databases.yml

mkdir /var/www/html/web/uploads
chmod 777 /var/www/html/web/uploads

chown -R apache:apache /var/www/html/

sed -i -e '57,63d' /var/www/html/web/pre_installer_code.php

sed -i "s/80/${APP_PORT}/" /etc/httpd/conf/httpd.conf
sed -i "s/LogFormat \"%h/LogFormat \"%a/g" /etc/httpd/conf/httpd.conf

NODE_HOSTNAME = $(hostname)
sed -i "21s%.*%${NODE_HOSTNAME}%g" /var/www/html/apps/siwapp/templates/layout.php

su -c "echo $'<Directory /var/www/html/web>
	Options FollowSymLinks
	AllowOverride All
</Directory>
<VirtualHost *:${APP_PORT}>
	DocumentRoot /var/www/html/web
	RewriteEngine On
</VirtualHost>'\
>> /etc/httpd/conf/httpd.conf"

su -c "cat << EOF > /var/www/html/config/databases.yml
all:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn: 'mysql:host=${HAPROXY_DB_IP};dbname=siwapp'
      username: '${GALERA_DB_USER}'
      password: '${GALERA_DB_USER_PWD}'

test:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn: 'mysql:host=${HAPROXY_DB_IP};dbname=siwapp_test'
      username: '${GALERA_DB_USER}'
      password: '${GALERA_DB_USER_PWD}'
EOF
"
sed -i.bak "s#false#true#g" /var/www/html/web/config.php

echo "Restarting http services"
systemctl enable httpd
systemctl start httpd
echo "App install script complete"
