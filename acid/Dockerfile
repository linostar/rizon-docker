FROM debian:testing
MAINTAINER linostar
LABEL Description="Configure and run acid bots" \
      Warning="This container depends on external provision files and cannot be built on its own"
RUN apt-get update; apt-get upgrade -y
RUN apt-get install -y -f sudo wget gcc g++ make git mysql-client libmysqld-dev nano mlocate
RUN apt-get install -y python python-dev libpython-dev python-pip
RUN apt-get install -y openjdk-7-jdk maven
RUN update-ca-certificates -f
RUN adduser --system --home /var/ircd --shell /bin/bash ircd
RUN mkdir -p /var/ircd; git clone http://gitlab.com/rizon/acid.git /var/ircd/acid
WORKDIR /var/ircd/acid
RUN git clone http://gitlab.com/rizon/pyva.git pyva/libpyva
RUN sed -i 's/^py-dom-xpath.*//' pyva/requirements.txt; pip install -U pip; pip install -r pyva/requirements.txt
RUN wget 'http://py-dom-xpath.googlecode.com/files/py-dom-xpath-0.1.tar.gz'; tar zxf py-dom-xpath-0.1.tar.gz; cd py-dom-xpath-0.1; python setup.py install; cp -rv build/lib.linux-x86_64-2.7/xpath/ /usr/local/lib/python2.7/dist-packages/; cd ..; rm -rf py-dom-xpath*
COPY make.properties pyva/libpyva/pyva-native/
RUN mvn install
RUN ln -s pyva/libpyva/pyva-native/libpyva.so libpyva.so
COPY start_acid.sh /usr/bin
COPY acidictive.yml pyva.yml pypsd.yml config.sh ./
RUN source /var/ircd/acid/config.sh; sed -i "s/___anope_version___/${SERVER_0_SERVICES:5:1}/g" pypsd.yml
ENTRYPOINT /bin/bash /usr/bin/start_acid.sh
