#! /bin/bash

sleep 5
export LD_PRELOAD=/usr/lib64/libpython2.7.so
cd /var/ircd/acid; ./run.sh
read
