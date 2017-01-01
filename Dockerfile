# os
FROM ubuntu:16.04
RUN apt-get -y update && apt-get install -y git vim libev-dev tar wget libevent-dev build-essential libnet-ifconfig-wrapper-perl cmake python-pip libjson-c-dev curl valgrind zlib1g-dev python-webpy
# couchbase
RUN cd ~ && wget http://packages.couchbase.com/releases/4.5.0/couchbase-server-enterprise_4.5.0-ubuntu14.04_amd64.deb
RUN cd ~ && dpkg -i couchbase-server-enterprise_4.5.0-ubuntu14.04_amd64.deb
RUN cd ~ && git clone https://github.com/couchbase/libcouchbase.git
RUN cd ~ && cd libcouchbase && cmake . && make && make install
RUN cd ~ && wget http://packages.couchbase.com/clients/c/libcouchbase-2.5.8_ubuntu1404_amd64.tar && tar xvf *.tar && cd libcouchbase-2.5.8_ubuntu1404_amd64/ && dpkg -i *.deb
RUN pip install couchbase
# hearthmod
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_database.git
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_base.git
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_gameserver.git
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_lobbyserver.git
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_ctl.git
RUN cd ~ && git clone https://github.com/farb3yonddriv3n/hm_stud.git
# cleanup
RUN rm -rf ~/couchbase-server-enterprise_4.5.0-ubuntu14.04_amd64.deb ~/libcouchb*
