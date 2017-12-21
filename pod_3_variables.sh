﻿#!/bin/sh
HAPROXY_APP_IP="192.168.113.207"
HAPROXY_DB_IP="192.168.113.208"
APP_TIER_IPS="192.168.113.201,192.168.113.202,192.168.113.203"
APP_TIER_HOSTNAMES="app-1-pod-3,app-2-pod-3,app-3-pod-3"
APP_PORT="8081"
DB_TIER_IPS="192.168.113.204,192.168.113.205,192.168.113.206"
DB_TIER_HOSTNAMES="db-1-pod-3,db-2-pod-3,db-3-pod-3"
GALERA_DB_USER="siwapp"
GALERA_DB_USER_PWD="siwapp"
GALERA_DB_ROOT_PWD="siwapp"
GALERA_CLUSTER_NAME="siwapp"
