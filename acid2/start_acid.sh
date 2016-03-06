#! /bin/bash

sleep 10

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libpython2.7.so
cd /var/ircd/acid; ./run.sh
/bin/bash
