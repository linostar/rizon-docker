FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run Anope 2 IRC Services" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN yum update -y
RUN yum install -y sudo gcc gcc-c++ make which git cmake sendmail sendmail-cf m4 crontabs nano mlocate
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir /var/ircd; git clone http://github.com/anope/anope.git
WORKDIR anope
RUN git checkout 2.0
COPY config.cache ./
RUN ./Config -nointro -quick
WORKDIR build
RUN make && make install
WORKDIR /var/ircd/services/conf
COPY services.conf operserv.example.conf owner.conf acid_bots.conf moo.conf config.sh ./
RUN source /var/ircd/services/conf/config.sh; sed -i "s/___owner_name___/$OWNER_NAME/g" owner.conf
RUN cat owner.conf acid_bots.conf >> services.conf; chown -R ircd /var/ircd
COPY anope.db /var/ircd/services/data/
RUN source /var/ircd/services/conf/config.sh; sed -i "s/___owner_name___/$OWNER_NAME/g;s/___owner_password___/`echo -n $OWNER_PASSWORD | base64`/g" /var/ircd/services/data/anope.db; rm config.sh
WORKDIR /etc/mail
RUN echo "localhost" >> local-host-names; ./make
COPY start_services.sh /usr/bin
ENTRYPOINT /bin/bash /usr/bin/start_services.sh
