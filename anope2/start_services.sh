#!/bin/bash

if [ -n "$SERVER_IP" ]; then
  sed -i "s/server_ip_here/$SERVER_IP/g" /var/ircd/services/conf/services.conf
fi

sudo -u ircd /var/ircd/services/bin/services

