#!/bin/sh

if [ -n "$SERVER_IP" ]; then
  sed -i "s/server_ip_here/$SERVER_IP/g" /var/ircd/etc/ircd.conf
else
  sed -i "s/server_ip_here/127.0.0.1/g" /var/ircd/etc/ircd.conf
fi

sudo -u ircd /var/ircd/bin/ircd
read

