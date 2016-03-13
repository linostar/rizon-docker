#!/bin/bash


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
			cp config.sh mysqld/
			docker build -t db "./$2"
			rm mysqld/config.sh
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
			echo "Container 'acid_anope$2' is built."
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
	all)
		build ircd plexus3
		build ircd plexus4
		build services anope1
		build services anope2
		build acid 1
		build acid 2
		build moo
		build users
		;;
	esac
}


# Example: start ircd 0
function start {
	case "$1" in
	ircd)
		declare ircdtype="SERVER_${2}_IRCD"
		if [ ${!ircdtype} = "plexus3" -o ${!ircdtype} = "plexus4" ]; then
			name="server_${2}_ircd"
			docker run -dit -p "666${2}:666${2}" --name $name ${!ircdtype}
			echo "Container '$name' started."
		else
			echo "Error: '${!ircdtype}' is not a supported ircd type."
		fi
		;;
	services)
		declare servicestype="SERVER_${2}_SERVICES"
		if [ ${!servicestype} = "anope1" -o ${!servicestype} = "anope2" ]; then
			name="server_${2}_services"
			docker run -dit --net=container:server_${2}_ircd --name $name ${!servicestype}
			echo "Container '$name' started."
		elif [ ${!servicestype} != "none" ]; then
			echo "Error: '$3' is not a supported services type."
		fi
		;;
	db)
		name="server_${2}_db"
		docker run -dit -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --net=container:server_${2}_ircd --name $name db
		echo "Container '$name' started."
		;;
	acid)
		declare servicestype="SERVER_${2}_SERVICES"
		if [ ${!servicestype} = "anope1" -o ${!servicestype} = "anope2" ]; then
			docker ps -a | grep server_${2}_db | grep -qv Exited
			if [ $? -ne 0 ]; then
				start db $2
			fi
			name="server_${2}_acid"
			docker run -dit --net=container:server_${2}_ircd --name $name "acid_${!servicestype}"
			echo "Container '$name' started."
		else
			echo "Error: There is no acid container built against anope version '$3'."
		fi
		;;
	moo)
		docker ps -a | grep server_${2}_db | grep -qv Exited
		if [ $? -ne 0 ]; then
			start db $2
		fi
		name="server_${2}_moo"
		docker run -dit --net=container:server_${2}_ircd --name $name moo
		echo "Container '$name' started."
		;;
	users)
		name="server_${2}_users"
		docker run -dit --name $name users
		echo "Container '$name' started."
		;;
	server)
		if [ $2 -eq 0 ]; then
			start ircd 0
			start services 0
			if [ $SERVER_0_ACID -eq 1 -a $SERVER_0_SERVICES != "none" ]; then
				start acid 0
			fi
			if [ $SERVER_0_MOO -eq 1 ]; then
				start moo 0
			fi
			if [ $SERVER_0_USERS -gt 0 ]; then
				start users 0
			fi
		elif [ $2 -gt 0 ]; then
			declare users="SERVER_${2}_USERS"
			start ircd $2
			if [ ${!users} -gt 0 ]; then
				start users $2
			fi
		fi
		echo "All containers of 'server $2' started."
		;;
	all)
		for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
			start server $i
		done
		echo "All servers started."
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
        if [ $2 -eq 0 ]; then
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
        elif [ $2 -gt 0 ]; then
            declare users="SERVER_${2}_USERS"
            if [ ${!users} -gt 0 ]; then
                docker stop server_${2}_users
            fi
            docker stop server_${2}_ircd
        fi
        echo "All containers of 'server $2' stopped."
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
		if [ $2 -eq 0 ]; then
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
		elif [ $2 -gt 0 ]; then
			declare users="SERVER_${2}_USERS"
			if [ ${!users} -gt 0 ]; then
				docker rm -f server_${2}_users
			fi
			docker rm -f server_${2}_ircd
		fi
		echo "All containers of 'server $2' deleted."
	elif [ $1 = "all" ]; then
		for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
			delete server $i
		done
		echo "All servers deleted."
	else
		echo "Error: container '$name' does not exist."
	fi
}


# Example: list server 0
function list {
	if [ $# -eq 0 ]; then
		docker ps -a | grep -e "\bserver_[0-9]_\(ircd\|services\|acid\|moo\|db\|users\)\b"
	elif [ $1 = "server" ]; then
		if [ $2 -ge 0 ]; then
			docker ps -a | grep -e "\bserver_$2_\(ircd\|services\|acid\|moo\|db\|users\)\b"
		fi
	else
		echo "Error: incorrect command syntax."
	fi
}


source config.sh

case "$1" in
start)
	start $2 $3
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
list)
	list $2 $3
	;;
*)
	echo "Error: Bad argument(s)."
	exit 65
	;;
esac

exit 0
