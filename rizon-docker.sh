#!/bin/bash


# Internal function
function replace_branchcommit {
    if [ -n "$1" ]; then
        BRANCH="${1%%:*}"
        COMMIT="${1##*:}"
        sed -i "s|#___gitbranch___||;s|___branch___|${BRANCH}|" ${2}/Dockerfile
        if [ -n "$COMMIT" ]; then
            sed -i "s|#___gitcommit___||;s|___commit___|${COMMIT}|" ${2}/Dockerfile
        fi
    fi
}


# Internal function for building ircd config from templates. Example: ircd_templater 0 plexus4
function ircd_templater {
	declare serverlinks="SERVER_${1}_LINKS"
	declare ishub="SERVER_${1}_HUB"
	declare gitbranch="SERVER_${1}_IRCD_BRANCHCOMMIT"
	mkdir -p tmp
	rm -f tmp/ircd${1}_clines.conf tmp/ircd${1}_info.conf ${2}/Dockerfile
	touch tmp/ircd${1}_clines.conf
	if [ ${!ishub} -eq 1 ]; then
		sed 's/^#//g' "${2}/clines.conf.template" > tmp/clines.conf.template
		sed "s/___is_hub___/yes/" "${2}/server_info.conf.template" > tmp/ircd${1}_info.conf
	else
		cp "${2}/clines.conf.template" tmp/clines.conf.tempate
		sed "s/___is_hub___/no/" "${2}/server_info.conf.template" > tmp/ircd${1}_info.conf
	fi
	sed -i "s/___server_index___/${1}/g" tmp/ircd${1}_info.conf
	if [ $1 -eq 0 ]; then
		# Allow SSL ports in server_0_ircd
		sed -i 's/^#___ssl___//g' tmp/ircd${1}_info.conf
	fi
	for i in `echo ${!serverlinks} | sed 's/,/ /g'`; do
		sed "s/___server_index___/${i}/g" tmp/clines.conf.template >> tmp/ircd${1}_clines.conf
	done
	sed "s/___server_index___/${1}/g" ${2}/Dockerfile.template > ${2}/Dockerfile
	if [ $1 -eq 0 -a $SERVER_0_SERVICES != "none" ]; then
		sed -i "s/___services_included___/services_cline.conf/g" ${2}/Dockerfile
	else
		sed -i "s/___services_included___//g" ${2}/Dockerfile
	fi
	if [ $1 -eq 0 -a $SERVER_0_ACID -eq 1 ]; then
		sed -i "s/___acid_included___/acid_cline.conf/g" ${2}/Dockerfile
	else
		sed -i "s/___acid_included___//g" ${2}/Dockerfile
	fi
	if [ $1 -eq 0 ]; then
		sed -i 's/^#EXPOSE/EXPOSE/' ${2}/Dockerfile
	fi
	replace_branchcommit ${!gitbranch} $2
	cp tmp/ircd${1}_info.conf ${2}/
	cp tmp/ircd${1}_clines.conf ${2}/
}


# Internal function for building services config from templates. Example: services_templater 0 anope2
function services_templater {
	declare gitbranch="SERVER_${1}_SERVICES_BRANCHCOMMIT"
	cp -f ${2}/Dockerfile.template ${2}/Dockerfile
	replace_branchcommit ${!gitbranch} $2
}


# Internal function for building acid/moo config from templates. Example: servicebot_templater 0 acid
function servicebot_templater {
	declare gitbranch="SERVER_${1}_${2^^}_BRANCHCOMMIT"
	cp -f ${2}/Dockerfile.template ${2}/Dockerfile
	replace_branchcommit ${!gitbranch} $2
}


# Example: build ircd 0
function build {
	case "$1" in
	ircd)
		declare ircdtype="SERVER_$2_IRCD"
		if [ "${!ircdtype}" = "plexus3" -o "${!ircdtype}" = "plexus4" ]; then
			cp config.sh "${!ircdtype}/"
			ircd_templater $2 ${!ircdtype}
			docker build -t "server_${2}_ircd" "./${!ircdtype}"
			rm "${!ircdtype}/config.sh"
			echo "Container 'server_${2}_ircd' is built."
		else
			echo "Error: container type '${!ircdtype}' does not exist."
		fi
		;;
	services)
		declare servicestype="SERVER_$2_SERVICES"
		if [ "${!servicestype}" = "anope1" -o "${!servicestype}" = "anope2" ]; then
			cp config.sh "${!servicestype}/"
			services_templater $2 ${!servicestype}
			docker build -t "server_${2}_services" "./${!servicestype}"
			rm "${!servicestype}/config.sh"
			echo "Container 'server_${2}_services' is built."
		elif [ -n "${!servicestype}" ]; then
			echo "Error: container type '${!servicestype}' does not exist."
		fi
		;;
	db)
		if [ $2 -eq 0 ]; then
			cp config.sh mysqld/
			docker build -t server_0_db "./mysqld"
			rm mysqld/config.sh
			echo "Container 'server_0_db' is built."
		else
			echo "Error: container type 'db' can be built only for 'server 0'."
		fi
		;;
	acid)
		if [ $2 -eq 0 ]; then
			if [ $SERVER_0_ACID -eq 1 ]; then
				build db 0
				cp config.sh acid/
				servicebot_templater 0 acid
				docker build -t "server_0_acid" acid/
				rm acid/config.sh
				echo "Container 'server_0_acid' is built."
			fi
		else
			echo "Error: container type 'acid' can be built only for 'server 0'."
		fi
		;;
	moo)
		if [ $2 -eq 0 ]; then
			if [ $SERVER_0_MOO -eq 1 ]; then
				build db 0
				cp config.sh moo/
				servicebot_templater 0 moo
				docker build -t server_0_moo moo/
				rm moo/config.sh
				echo "Container 'server_0_moo' is built."
			fi
		else
			echo "Error: container type 'moo' can be built only for 'server 0'."
		fi
		;;
	users)
		declare users="SERVER_${2}_USERS"
		declare channels="SERVER_${2}_USER_CHANNELS"
		if [ ${!users:-0} -gt 0 ]; then
			echo $2 > users/BOT_IRCD
			echo "${!channels}" > users/BOT_CHANNELS
			echo ${!users} > users/BOT_NB
			docker build -t "server_${2}_users" users/
			echo "Container 'server_${2}_users' is built."
		fi
		;;
	server)
		build ircd $2
		if [ $2 -eq 0 ]; then
			build services $2
			build acid $2
			build moo $2
		fi
		build users $2
		echo "All containers of 'server $2' are built."
		;;
	all)
		for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
			build server $i
		done
		echo "All servers are built."
		;;
	esac
}


# Example: create ircd 0
function create {
	case "$1" in
	ircd)
		declare ircdtype="SERVER_${2}_IRCD"
		if [ "${!ircdtype}" = "plexus3" -o "${!ircdtype}" = "plexus4" ]; then
			name="server_${2}_ircd"
			if [ $2 -eq 0 ]; then
				docker create -it -p 6630-6639:6630-6639 -p 6660-6669:6660-6669 -p 6697:6697 -p 9999:9999 --name $name $name
			else
				docker create -it --net=container:server_0_ircd --name $name $name
			fi
			echo "Container '$name' created."
		else
			echo "Error: '${!ircdtype}' is not a supported ircd type."
		fi
		;;
	services)
		declare servicestype="SERVER_${2}_SERVICES"
		if [ "${!servicestype}" = "anope1" -o "${!servicestype}" = "anope2" ]; then
			name="server_${2}_services"
			docker create -it --net=container:server_0_ircd --name $name $name
			echo "Container '$name' created."
		elif [ "${!servicestype}" != "none" ]; then
			echo "Error: '$3' is not a supported services type."
		fi
		;;
	db)
		name="server_${2}_db"
		docker create -it -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --net=container:server_0_ircd --name $name $name
		echo "Container '$name' created."
		;;
	acid)
		declare servicestype="SERVER_${2}_SERVICES"
		if [ "${!servicestype}" = "anope1" -o "${!servicestype}" = "anope2" ]; then
			docker ps -a | grep server_${2}_db
			if [ $? -ne 0 ]; then
				create db $2
			fi
			name="server_${2}_acid"
			docker create -it --net=container:server_0_ircd --name $name $name
			echo "Container '$name' created."
		else
			echo "Error: There is no acid container built against anope version '$3'."
		fi
		;;
	moo)
		docker ps -a | grep server_${2}_db
		if [ $? -ne 0 ]; then
			create db $2
		fi
		name="server_${2}_moo"
		docker create -it --net=container:server_0_ircd --name $name $name
		echo "Container '$name' created."
		;;
	users)
		name="server_${2}_users"
		docker create -it --net=container:server_0_ircd --name $name $name
		echo "Container '$name' created."
		;;
	server)
		if [ $2 -eq 0 ]; then
			create ircd 0
			create services 0
			if [ $SERVER_0_ACID -eq 1 -a $SERVER_0_SERVICES != "none" ]; then
				create acid 0
			fi
			if [ $SERVER_0_MOO -eq 1 ]; then
				create moo 0
			fi
			if [ $SERVER_0_USERS -gt 0 ]; then
				create users 0
			fi
		elif [ $2 -gt 0 ]; then
			declare users="SERVER_${2}_USERS"
			create ircd $2
			if [ ${!users:-0} -gt 0 ]; then
				create users $2
			fi
		fi
		echo "All containers of 'server $2' created."
		;;
	all)
		for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
			create server $i
		done
		echo "All servers created."
		;;
	esac
}


# Example: start ircd 0
function start {
    name="server_$2_$1"
    echo "ircd services acid moo users" | grep -q "\b$1\b"
    if [ $? -eq 0 ]; then
        docker start $name
        echo "Container '$name' started."
    elif [ $1 = "server" ]; then
        if [ $2 -eq 0 ]; then
			docker start server_0_ircd
            if [ $SERVER_0_SERVICES != "none" ]; then
                docker start server_0_services
            fi
            if [ $SERVER_0_ACID -eq 1 ]; then
				docker start server_0_db
				SERVER_0_DB_STARTED=1
                docker start server_0_acid
            fi
            if [ $SERVER_0_MOO -eq 1 ]; then
				if [ $SERVER_0_DB_STARTED -ne 1 ]; then
					docker start server_0_db
				fi
                docker start server_0_moo
            fi
            if [ $SERVER_0_USERS -gt 0 ]; then
                docker start server_0_users
            fi
        elif [ $2 -gt 0 ]; then
            declare users="SERVER_${2}_USERS"
            docker start server_${2}_ircd
            if [ ${!users:-0} -gt 0 ]; then
                docker start server_${2}_users
            fi
        fi
        echo "All containers of 'server $2' started."
    elif [ $1 = "all" ]; then
        for i in `seq 0 $[${NUMBER_OF_SERVERS}-1]`; do
            start server $i
        done
        echo "All servers started."
    else
        echo "Error: container '$name' does not exist."
    fi
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
				docker stop server_0_db
				SERVER_0_DB_STOPPED=1
            fi
            if [ $SERVER_0_MOO -eq 1 ]; then
                docker stop server_0_moo
				if [ $SERVER_0_DB_STOPPED -ne 1 ]; then
					docker stop server_0_db
				fi
            fi
            if [ $SERVER_0_SERVICES != "none" ]; then
                docker stop server_0_services
            fi
            docker stop server_0_ircd
        elif [ $2 -gt 0 ]; then
            declare users="SERVER_${2}_USERS"
            if [ ${!users:-0} -gt 0 ]; then
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


# Example: restart ircd 0
function restart {
	stop $1 $2
	start $1 $2
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
			if [ ${!users:-0} -gt 0 ]; then
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


# Example: shell ircd 0
function _shell {
	name="server_${2}_${1}"
	echo "Attaching to shell of '$name'. Press RETURN to start the shell."
	echo "When you finish, press Ctrl-P Ctrl-Q to detach without stopping the container."
	docker attach $name
}


source config.sh

case "$1" in
start)
	start $2 $3
	;;
stop)
	stop $2 $3
	;;
restart)
	restart $2 $3
	;;
build)
	build $2 $3
	;;
create)
	create $2 $3
	;;
delete)
	delete $2 $3
	;;
list)
	list $2 $3
	;;
shell)
	_shell $2 $3
	;;
*)
	echo "Error: Bad argument(s)."
	exit 65
	;;
esac

exit 0
