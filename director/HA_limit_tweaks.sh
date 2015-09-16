#!/bin/bash

#RabbitMQ FD Limit
echo "ulimit -S -n 8192" >> /etc/rabbitmq/rabbitmq-env.conf

#DB Limitations to fix:
sed  -i.bak_`date +%s` -e 's/max_connections.*/max_connections=15360/g' /etc/my.cnf.d/galera.cnf

#Restart Cluster
pcs cluster stop --all
pcs cluster start --all
