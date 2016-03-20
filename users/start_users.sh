#!/bin/bash

for i in `seq 1 $(cat BOT_NB)`; do
	./user_bot.sh $(cat BOT_IRCD) $i "$(cat BOT_CHANNELS)" &
	sleep 1
done

wait

/bin/bash

