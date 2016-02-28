FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run acid bots" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN yum update
RUN yum install -y epel-release
RUN yum install -y sudo which wget gcc gcc-c++ make python python-devel python-pip git which maven2 mariadb mariadb-devel mariadb-server java-1.8.0-openjdk java-1.8.0-openjdk-devel
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
COPY start_acid.sh /usr/bin
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/acid.git; mv acid /var/ircd/
WORKDIR /var/ircd/acid
RUN git clone http://gitlab.com/rizon/pyva.git pyva/libpyva
RUN sed -i 's/^py-dom-xpath.*//' pyva/requirements.txt; pip install -r pyva/requirements.txt
RUN wget 'http://py-dom-xpath.googlecode.com/files/py-dom-xpath-0.1.tar.gz'; tar zxf py-dom-xpath-0.1.tar.gz; cd py-dom-xpath-0.1; python setup.py install; cd ..; rm -rf py-dom-xpath-0.1*
COPY acidictive.yml pyva.yml pypsd.yml config.sh ./
COPY make.properties pyva/libpyva/pyva-native/
RUN mvn install
RUN ln -s pyva/libpyva/pyva-native/libpyva.so libpyva.so
RUN rm -rf /var/lib/mysql; mkdir /var/lib/mysql; chown mysql /var/lib/mysql
USER mysql
RUN mysql_install_db
USER root
RUN mysql -u root -e "create database acidcore; create database pypsd; grant all privileges on acidcore.* to 'acid'@'localhost' identified by 'moo'; grant all privileges on pypsd.* to 'acid'@'localhost' identified by 'moo'; flush privileges;"
RUM mysql -u root -D acidcore < acid/acidcore.sql; mysql -u root -D acidcore -e "insert into access values (\"`./config.sh OWNER_NAME`\", '1', '');"
RUN rm config.sh
ENTRYPOINT /bin/bash /usr/bin/start_acid.sh
