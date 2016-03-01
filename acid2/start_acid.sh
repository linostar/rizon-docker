#! /bin/bash

sleep 5
if [ ! -f /var/ircd/acid/db_configured ]; then
  sed -i "s/___mysql_ip___/$DB_PORT_3306_TCP_ADDR/g;s/___mysql_port___/$DB_PORT_3306_TCP_PORT/g" /var/ircd/acid/acidictive.yml
  sed -i "s/___mysql_ip___/$DB_PORT_3306_TCP_ADDR/g" /var/ircd/acid/pypsd.yml
  touch /var/ircd/acid/db_configured
fi

export LD_PRELOAD=/usr/lib64/libpython2.7.so
cd /var/ircd/acid; ./run.sh
read
