#!/bin/sh
HAPROXY_APP_IP="192.168.138.207"
HAPROXY_DB_IP="192.168.138.208"
APP_TIER_IPS="192.168.138.201,192.168.138.202,192.168.138.203"
APP_TIER_HOSTNAMES="app-1-pod-18,app-2-pod-18,app-3-pod-18"
APP_PORT="8081"
DB_TIER_IPS="192.168.138.204,192.168.138.205,192.168.138.206"
DB_TIER_HOSTNAMES="db-1-pod-18,db-2-pod-18,db-3-pod-18"
GALERA_DB_USER="siwapp"
GALERA_DB_USER_PWD="siwapp"
GALERA_DB_ROOT_PWD="siwapp"
GALERA_CLUSTER_NAME="siwapp"
