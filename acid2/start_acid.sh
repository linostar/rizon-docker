#! /bin/bash

sudo -u mysql /usr/libexec/mysqld &
export LD_PRELOAD=/usr/lib64/libpython2.7.so
sudo -u ircd /var/ircd/acid/run.sh
read
