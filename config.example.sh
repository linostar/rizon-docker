# IRCDs and Services root credentials
export OWNER_NAME=owner
export OWNER_PASSWORD=ChangeMe123

# Number of IRCDs deployed
# only servers with index less than this variable will be deployed
# server indexes must be consecutive positive integers with no gaps
# servers with indexes greater or equal to this variable will be ignored
# possible values: any integer between 1 and 10 inclusive
export NUMBER_OF_SERVERS=1

# Main IRCD server, always with index 0
# possible values for SERVER_*_IRCD: plexus3, plexus4
export SERVER_0_IRCD=plexus4
# OPTIONAL: decides which branch/tag/commit to checkout
# acceptable forms: '<branch>:<commit>', '<branch>:', 'tags/<tag>:<commit>', 'tags/<tag>:'
# for example: 'master:34f56e2', 'master:', 'tags/2016_06:32ad43a', 'tags/2015_11:'
export SERVER_0_IRCD_BRANCHCOMMIT=''
# possible values for SERVER_0_SERVICES: none, anope1, anope2
# note that the anope1 container is not full-featured yet, and therefore not recommended
export SERVER_0_SERVICES=anope2
# possible values for SERVER_0_ACID: 0, 1 (1 means deployed, 0 otherwise)
export SERVER_0_ACID=1
# possible values for SERVER_0_MOO: 0, 1 (1 means deployed, 0 otherwise)
export SERVER_0_MOO=0
# number of fake users connecting to this server
export SERVER_0_USERS=0
# comma-separated list of channels that the fake users, if any, will join
export SERVER_0_USER_CHANNELS='#chat'
# comma-separated list of indexes of servers to connect to
export SERVER_0_LINKS=''
# whether the ircd of this server is hub or leaf
export SERVER_0_HUB=1

# Other IRCD servers (you need to change the value of $NUMBER_OF_SERVERS accordingly)
export SERVER_1_IRCD=plexus3
export SERVER_1_USERS=0
export SERVER_1_CHANNELS=''
export SERVER_1_LINKS='0'
export SERVER_1_HUB=0
