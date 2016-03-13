FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run Plexus3 IRC daemon" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN yum update -y
RUN yum install -y sudo gcc git openssl openssl-devel openssl-libs autogen autoconf automake which libtool libtool-ltdl libtool-ltdl-devel byacc flex flex-devel nano mlocate
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/plexus.git
WORKDIR plexus
RUN ./configure --prefix=/var/ircd --enable-openssl
RUN make; make install; cd contrib; make install
WORKDIR /var/ircd/etc
RUN openssl genrsa -out rsa.key 2048; openssl rsa -in rsa.key -pubout -out rsa.pub; chmod 0600 rsa.key; openssl req -new -days 3650 -x509 -key rsa.key -out cert.pem -subj "/C=US/ST=California/L=Sacramento/O=Rizon Network/OU=IT department/CN=irc.rizon.net"
COPY ircd.conf owner.conf services_cline.conf acid_cline.conf config.sh ./
RUN source /var/ircd/etc/config.sh; sed -i "s/___owner_name___/$OWNER_NAME/g;s/___owner_password___/$OWNER_PASSWORD/g" owner.conf
RUN cat owner.conf services_cline.conf acid_cline.conf >> ircd.conf; rm config.sh; chown -R ircd /var/ircd
COPY start_ircd.sh /usr/bin/
EXPOSE 6630 6631 6632 6633 6634 6635 6636 6637 6638 6639 6660 6661 6662 6663 6664 6665 6666 6667 6668 6669 6670 6697 7000 9999
ENTRYPOINT /bin/bash /usr/bin/start_ircd.sh
