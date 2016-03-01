FROM centos:7
MAINTAINER linostar
LABEL Description="Configure and run acid bots" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y sudo which wget gcc gcc-c++ make git which maven2 mariadb mariadb-devel java-1.8.0-openjdk java-1.8.0-openjdk-devel readline-devel lbzip2-utils sqlite-devel
ADD https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz ./
RUN tar xfz Python-2.7.11.tgz; cd Python-2.7.11; ./configure --enable-shared --prefix=/usr/local; make; make install
RUN yum install -y python-pip
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/acid.git /var/ircd/acid
WORKDIR /var/ircd/acid
RUN git clone http://gitlab.com/rizon/pyva.git pyva/libpyva
RUN sed -i 's/^py-dom-xpath.*//' pyva/requirements.txt; pip install --prefix /usr/local -r pyva/requirements.txt
RUN wget 'http://py-dom-xpath.googlecode.com/files/py-dom-xpath-0.1.tar.gz'; tar zxf py-dom-xpath-0.1.tar.gz; cd py-dom-xpath-0.1; /usr/local/bin/python setup.py install; cd ..; rm -rf py-dom-xpath-0.1*
COPY make.properties pyva/libpyva/pyva-native/
RUN mvn install
RUN ln -s pyva/libpyva/pyva-native/libpyva.so libpyva.so
COPY start_acid.sh /usr/bin
COPY acidictive.yml pyva.yml pypsd.yml ./
#ENTRYPOINT /bin/bash /usr/bin/start_acid.sh
ENTRYPOINT /bin/bash
