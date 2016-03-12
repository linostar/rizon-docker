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

# Example: build ircd plexus4
function build {
	case "$1" in
	ircd)
		if [ $2 = "plexus3" -o $2 = "plexus4" ]; then
			cp config.sh "${2}/"
			docker build -t $2 "./$2"
			rm "${2}/config.sh"
			echo "Container '$2' is built."
		else
			echo "Error: container '$2' does not exist."
		fi
		;;
	services)
		if [ $2 = "anope1" -o $2 = "anope2" ]; then
			cp config.sh "${2}/"
			docker build -t $2 "./$2"
			rm "{$2}/config.sh"
			echo "Container '$2' is built."
		else
			echo "Error: container '$2' does not exist."
		fi
		;;
	db)
		if [ $2 = "mysqld" ]; then
			docker build -t db "./$2"
			echo "Container '$2' is built."
		else
			echo "Error: container '$2' does not exist."
		fi
		;;
	acid)
		if [ $2 = "1" -o $2 = "2" ]; then
			build db mysqld
			cp config.sh acid/
			docker build -t "acid_anope$2" acid/
			rm acid/config.sh
			echo "Container '$2' is built."
		else
			echo "Error: acid container cannot be built against anope version '$2'."
		fi
		;;
	moo)
		build db mysqld
		cp config.sh moo/
		docker build -t moo moo/
		rm moo/config.sh
		echo "Container 'moo' is built."
		;;
	users)
		cp config.sh users/
		docker build -t users users/
		rm users/config.sh
		echo "Container 'users' is built."
		;;
	esac
}

# Example: start ircd 0 plexus4
function start {
	case "$1" in
	ircd)
		if [ $3 = "plexus3" -o $3 = "plexus4" ]; then
			name="server_$2_ircd"
			docker run -dit -p "666${2}:666${2}" --name $name $3
			echo "Container '$name' started."
		else
			echo "Error: '$3' is not a supported ircd type."
		fi
		;;
	esac
}

# Example: stop ircd 0
function stop {
    name="server_$2_$1"
    echo "ircd services acid moo users" | grep -q "\b$1\b"
	if [ $? -eq 0 ]; then
        docker stop $name
        echo "Container '$name' stopped."
    elif [ $1 = "server" ]; then
        if [ $2 -gt 0 ]; then
            if [ $SERVER_0_USERS -gt 0 ]; then
                docker stop server_0_users
            fi
            if [ $SERVER_0_ACID -eq 1 ]; then
                docker stop server_0_acid
            fi
            if [ $SERVER_0_MOO -eq 1 ]; then
                docker stop server_0_moo
            fi
            if [ $SERVER_0_SERVICES != "none" ]; then
                docker stop server_0_services
            fi
            docker stop server_0_db
            docker stop server_0_ircd
        elif [ $2 -eq 0 ]; then
            declare users="SERVER_${2}_USERS"
            if [ ${!users} -gt 0 ]; then
                docker stop server_${2}_users
            fi
            docker stop server_${2}_ircd
        fi
        echo "All containers of server $2 stopped."
    elif [ $1 = "all" ]; then
        for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
            stop server $i
        done
        echo "All servers stopped."
    else
        echo "Error: container '$name' does not exist."
    fi
}


# Example: delete ircd 0
function delete {
	name="server_$2_$1"
	echo "ircd services acid moo users" | grep -q "\b$1\b"
	if [ $? -eq 0 ]; then
		docker rm -f $name
		echo "Container '$name' deleted."
	elif [ $1 = "server" ]; then
		if [ $2 -gt 0 ]; then
			if [ $SERVER_0_USERS -gt 0 ]; then
				docker rm -f server_0_users
			fi
            if [ $SERVER_0_ACID -eq 1 ]; then
                docker rm -f server_0_acid
            fi
            if [ $SERVER_0_MOO -eq 1 ]; then
                docker rm -f server_0_moo
            fi
            if [ $SERVER_0_SERVICES != "none" ]; then
                docker rm -f server_0_services
            fi
			docker rm -f server_0_db
			docker rm -f server_0_ircd
		elif [ $2 -eq 0 ]; then
			declare users="SERVER_${2}_USERS"
			if [ ${!users} -gt 0 ]; then
				docker rm -f server_${2}_users
			fi
			docker rm -f server_${2}_ircd
		fi
		echo "All containers of server $2 deleted."
	elif [ $1 = "all" ]; then
		for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
			delete server $i
		done
		echo "All servers deleted."
	else
		echo "Error: container '$name' does not exist."
	fi
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

case "$1" in
start)
	start $2 $3 $4
	;;
stop)
	stop $2 $3
	;;
build)
	build $2 $3
	;;
delete)
	delete $2 $3
	;;
*)
	echo "Error: No args provided."
	exit 65
	;;
esac

exit 0
