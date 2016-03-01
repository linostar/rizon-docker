#! /bin/bash

sleep 5

export LD_PRELOAD=/usr/local/lib/libpython2.7.so
cd /var/ircd/acid; ./run.sh
tail -f /var/ircd/acid/geoserv.log
read
