﻿#!/bin/sh
HAPROXY_APP_IP="192.168.114.207"
HAPROXY_DB_IP="192.168.114.208"
APP_TIER_IPS="192.168.114.201,192.168.114.202,192.168.114.203"
APP_TIER_HOSTNAMES="app-1-pod-4,app-2-pod-4,app-3-pod-4"
APP_TIER_PORT="8081"
DB_TIER_IPS="192.168.114.204,192.168.114.205,192.168.114.206"
DB_TIER_HOSTNAMES="db-1-pod-4,db-2-pod-4,db-3-pod-4"
GALERA_DB_USER="siwapp"
GALERA_DB_USER_PWD="siwapp"
GALERA_DB_ROOT_PWD="siwapp"
GALERA_CLUSTER_NAME="siwapp"