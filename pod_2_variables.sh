#!/bin/sh
HAPROXY_APP_IP="192.168.112.207"
HAPROXY_DB_IP="192.168.112.208"
APP_TIER_IPS="192.168.112.201,192.168.112.202,192.168.112.203"
APP_TIER_HOSTNAMES="app-1-pod-2,app-2-pod-2,app-3-pod-2"
APP_PORT="8081"
DB_TIER_IPS="192.168.112.204,192.168.112.205,192.168.112.206"
DB_TIER_HOSTNAMES="db-1-pod-2,db-2-pod-2,db-3-pod-2"
GALERA_DB_USER="siwapp"
GALERA_DB_USER_PWD="siwapp"
GALERA_DB_ROOT_PWD="siwapp"
GALERA_CLUSTER_NAME="siwapp"
