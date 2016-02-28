#!/bin/bash

source config.sh
sudo -u mysql /usr/libexec/mysqld &

if [ ! -f db_created ]; then
  sudo -u mysql mysql_install_db
  sleep 5
  mysql -u root -e "create database acidcore; create database pypsd; grant all privileges on acidcore.* to 'acid'@'%' identified by 'moo'; grant all privileges on pypsd.* to 'acid'@'%' identified by 'moo'; flush privileges;"
  mysql -u root -D acidcore < acidcore.sql
  mysql -u root -D acidcore -e "insert into access values (\"$OWNER_NAME\", '1', '');"
  touch db_created
fi

/bin/bash
