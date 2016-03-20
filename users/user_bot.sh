#!/bin/bash

# Syntax: user_bot.sh <server_index> <user_number> <comma-separated list of channels>

BOT_HOST="127.0.0.1"
BOT_PORT="666$1"
BOT_NICK="user$2"
BOT_USER="${BOT_NICK} 0 * :${BOT_NICK}"
BOT_CMD=""

trap "echo" SIGINT SIGTERM SIGHUP
trap "kill 0" EXIT

function _send {
	echo "$*" >&3
}

function _output {
	echo "$*"
}

exec 3<>/dev/tcp/${BOT_HOST}/${BOT_PORT} || exit 1

{
	while read LINE; do
		_output "$LINE"
		LINE="`echo $LINE | tr -d '\001\r\n'`"
		if [ "${LINE%% *}" = "PING" ]; then
			_send "`echo $LINE | sed 's/PING :/PONG /'`"
		elif [ "${LINE##* }" = ':VERSION' ]; then
			# LIAR BOT
			TARGET="${LINE%% *}"
			TARGET="${TARGET:1}"
			TARGET="${TARGET%\!*}"
			_send "NOTICE $TARGET :VERSION irssi v0.8.15"
		fi
	done
} <&3 &

_send "NICK ${BOT_NICK}"
_send "USER ${BOT_USER}"

sleep 2

for CH in `echo $3 | sed 's/,/ /g'`; do
	_send "JOIN $CH"
done

wait

read
