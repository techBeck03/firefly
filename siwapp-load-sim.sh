#!/usr/bin/env bash

sudo mkdir /usr/local/siwapp
sudo curl -o /usr/local/siwapp/provisioningVars.sh ${FILE_SERVER}/pod_${POD}_variables.sh
. /usr/local/siwapp/provisioningVars.sh

sudo yum -y update
sudo yum install -y epel-release
sudo yum install -y python-pip
sudo yum install -y python-devel gcc
sudo pip install pip --upgrade
sudo pip install locustio lxml requests

sudo curl -o /usr/share/systemd/siwapp-locust-file.py ${FILE_SERVER}/siwapp-locust-file.py
sudo curl -o /usr/share/systemd/siwapp-locust-service.sh ${FILE_SERVER}/siwapp-locust-service.sh

sudo su -c "echo $'
[Unit]
Description=siwapp-simulator

[Service]
Type=simple
User=root
ExecStart=/usr/bin/bash /usr/share/systemd/siwapp-locust-service.sh
Restart=on-abort


[Install]
WantedBy=multi-user.target'\
>> /etc/systemd/system/siwapp-simulator.service
" 
sudo systemctl daemon-reload
sudo systemctl enable siwapp-simulator
sudo systemctl start siwapp-simulator

sudo mv ~/cliqr.repo /etc/yum.repos.d/