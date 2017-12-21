#!/usr/bin/env bash

mkdir /usr/local/siwapp
curl -o /usr/local/siwapp/provisioningVars.sh ${FILE_SERVER}/pod_${POD}_variables.sh
. /usr/local/siwapp/provisioningVars.sh

yum -y update
yum install -y epel-release
yum install -y python-pip
yum install -y python-devel gcc
pip install pip --upgrade
pip install locustio lxml requests

curl -o /usr/share/systemd/siwapp-locust-file.py ${FILE_SERVER}/siwapp-locust-file.py
curl -o /usr/share/systemd/siwapp-locust-service.sh ${FILE_SERVER}/siwapp-locust-service.sh

echo $'
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

systemctl daemon-reload
systemctl enable siwapp-simulator
systemctl start siwapp-simulator
