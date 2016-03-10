# IRCDs and Services root credentials
export OWNER_NAME=owner
export OWNER_PASSWORD=ChangeMe123

# Number of IRCDs deployed
# only servers with index less than this variable will be deployed
# server indexes must be consecutive positive integers with no gaps
# servers with indexes greater or equal to this variable will be ignored
export NUMBER_OF_SERVERS=1

# Main IRCD server, always with index 0
# possible values for *_IRCD: plexus3, plexus4
export SERVER_0_IRCD=plexus4
# possible values for *_SERVICES: none, anope1, anope2
# note that the anope1 container is not full-featured yet and therefore not recommended
export SERVER_0_SERVICES=anope2
# possible values for *_BOTS (can accept comma-separated list): none, acid, moo
export SERVER_0_BOTS='acid'
# number of fake users connecting to this server
export SERVER_0_USERS=0
# comma-separated list of channels that the fake users will join
export SERVER_0_USER_CHANNELS='#help'

# Other IRCD servers (should reflect the value of $NUMBER_OF_SERVERS)
export SERVER_1_IRCD=plexus3
# the index of the server to which this server will be directly connected
export SERVER_1_LINK=0
