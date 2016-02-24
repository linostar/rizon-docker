FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run Plexus4 IRC daemon"
ENV SERVER_IP="127.0.0.1"
RUN yum update
RUN yum install -y sudo gcc g++ git openssl openssl-devel openssl-libs autogen autoconf automake which libtool libtool-ltdl libtool-ltdl-devel byacc flex flex-devel
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/plexus4.git
WORKDIR plexus4
RUN ./autogen.sh; ./configure --prefix=/var/ircd
RUN make && make install
COPY start_ircd.sh /usr/bin/
WORKDIR /var/ircd/etc
COPY ircd.conf ./
RUN sed -i "s/server_ip_here/$SERVER_IP/g" ircd.conf
RUN openssl genrsa -out rsa.key 2048; chmod 0600 rsa.key; openssl req -new -days 3650 -x509 -key rsa.key -out cert.pem -subj "/C=US/ST=California/L=Sacramento/O=Rizon Network/OU=IT department/CN=irc.rizon.net"; openssl dhparam -out dhparam.pem 2048; chown ircd *
RUN chown -R ircd /var/ircd
EXPOSE 6633 6660 6661 6662 6663 6664 6665 6666 6667 6668 6669 6670 6697 7000
ENTRYPOINT ["/bin/sh", "/usr/bin/start_ircd.sh"]
