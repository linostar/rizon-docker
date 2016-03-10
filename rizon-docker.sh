#!/bin/bash

function build_all {
  cp config.sh plexus4/
  cp config.sh anope2/
  cp config.sh mysqld/
  cp config.sh acid/
  docker build -t plexus4 ./plexus4
  docker build -t anope2 ./anope2
  docker build -t db ./mysqld
  docker build -t acid_anope2 ./acid
  rm plexus4/config.sh anope2/config.sh mysqld/config.sh acid/config.sh
  echo "Containers built."
}

function start_all {
  docker run -dit -p 6660-6670:6660-6670 -p 7000:7000 -p 6697:6697 -p 9999:9999 -p 6633:6633 --name plexus4 plexus4
  docker run -dit --name anope2 --net=container:plexus4 anope2
  docker run -dit -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --name db --net=container:plexus4 db
  docker run -dit --name acid_anope2 --net=container:plexus4 acid_anope2
  echo "Containers started."
}

function stop_all {
  docker stop acid_anope2 db anope2 plexus4
  echo "Containers stopped."
}

function delete_all {
  docker rm -f acid_anope2 db anope2 plexus4
  echo "Deleting completed."
}

source config.sh

if [ $# -eq 1 ]; then
  if [ $1 = "start" ]; then
    start_all
  elif [ $1 = "stop" ]; then
    stop_all
  elif [ $1 = "build" ]; then
    build_all
  elif [ $1 = "delete" ]; then
    delete_all
  fi
else
  echo "No args provided."
  exit 65
fi
exit 0
