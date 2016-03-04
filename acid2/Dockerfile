FROM ubuntu:15.10
MAINTAINER linostar
LABEL Description="Configure and run acid bots" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN apt-get update; apt-get upgrade -y
RUN apt-get install -y sudo wget gcc g++ make git maven2 mysql-client libmysqld-dev openjdk-8-jdk openjdk-7-jdk python python-dev libpython-dev python-pip
RUN update-ca-certificates -f
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/acid.git /var/ircd/acid
WORKDIR /var/ircd/acid
RUN git clone http://gitlab.com/rizon/pyva.git pyva/libpyva
RUN sed -i 's/^py-dom-xpath.*//' pyva/requirements.txt; pip install -U pip; pip install -r pyva/requirements.txt
RUN wget 'http://py-dom-xpath.googlecode.com/files/py-dom-xpath-0.1.tar.gz'; tar zxf py-dom-xpath-0.1.tar.gz; cd py-dom-xpath-0.1; python setup.py install; cp -rv build/lib.linux-x86_64-2.7/xpath/ /usr/local/lib/python2.7/dist-packages/; cd ..
COPY make.properties pyva/libpyva/pyva-native/
RUN mvn install
RUN ln -s pyva/libpyva/pyva-native/libpyva.so libpyva.so
COPY start_acid.sh /usr/bin
COPY acidictive.yml pyva.yml pypsd.yml ./
ENTRYPOINT /bin/bash /usr/bin/start_acid.sh
