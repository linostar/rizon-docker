FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run Anope 2 IRC Services"
RUN yum update
RUN yum install -y sudo gcc gcc-c++ make which git cmake sendmail sendmail-cf m4
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir /var/ircd; git clone http://github.com/anope/anope.git
WORKDIR anope
RUN git checkout 2.0
COPY config.cache ./
RUN ./Config -nointro -quick
WORKDIR build
RUN make && make install
WORKDIR /var/ircd/services/conf
COPY services.conf ./
RUN chown -R ircd /var/ircd
WORKDIR /etc/mail
RUN echo "localhost" >> local-host-names; ./make
WORKDIR /usr/bin
COPY start_services.sh ./
ENTRYPOINT /bin/bash /usr/bin/start_services.sh
