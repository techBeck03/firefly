#!/bin/bash -x
sudo curl -o /tmp/provisioningVars ${FILE_SERVER}/pod_${POD}_variables.sh
. /tmp/provisioningVars.sh

app "Starting app install script"
sudo yum -y update
sudo yum -y install git httpd php php-mysql php-xml php-mbstring
sudo yum clean all

sudo git clone https://github.com/siwapp/siwapp-sf1.git /var/www/html/

sudo mkdir /var/www/html/cache
sudo chmod 777 /var/www/html/cache
sudo chmod 777 /var/www/html/web/config.php
sudo chmod 777 /var/www/html/config/databases.yml

sudo mkdir /var/www/html/web/uploads
sudo chmod 777 /var/www/html/web/uploads

sudo chown -R apache:apache /var/www/html/

sudo sed -i -e '57,63d' /var/www/html/web/pre_installer_code.php

sudo sed -i "s/80/${APP_PORT}/" /etc/httpd/conf/httpd.conf
sudo sed -i "s/LogFormat \"%h/LogFormat \"%a/g" /etc/httpd/conf/httpd.conf

NODE_HOSTNAME = $(hostname)
sudo sed -i "21s%.*%${NODE_HOSTNAME}%g" /var/www/html/apps/siwapp/templates/layout.php

sudo su -c "echo $'<Directory /var/www/html/web>
	Options FollowSymLinks
	AllowOverride All
</Directory>
<VirtualHost *:${APP_PORT}>
	DocumentRoot /var/www/html/web
	RewriteEngine On
</VirtualHost>'\
>> /etc/httpd/conf/httpd.conf"

sudo su -c "cat << EOF > /var/www/html/config/databases.yml
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

sudo sed -i.bak "s#false#true#g" /var/www/html/web/config.php

echo "Restarting http services"
sudo systemctl enable httpd
sudo systemctl start httpd
echo "App install script complete"

sudo mv ~/cliqr.repo /etc/yum.repos.d/
