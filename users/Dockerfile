FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run bot users" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN yum update -y
RUN yum install -y sudo nano mlocate
WORKDIR /usr/bin
COPY start_users.sh user_bot.sh BOT_NB BOT_IRCD BOT_CHANNELS ./
ENTRYPOINT /bin/bash /usr/bin/start_users.sh
