#! /bin/bash

sleep 10

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libpython2.7.so
cd /var/ircd/acid; ./run.sh

sleep 5
grep -q "Access denied for user 'acid'@'localhost'" /var/ircd/acid/geoserv.log

while [ $? -eq 0 ]; do
	cd /var/ircd/acid; ./run.sh
	sleep 5
	grep -q "Access denied for user 'acid'@'localhost'" /var/ircd/acid/geoserv.log
done

/bin/bash
