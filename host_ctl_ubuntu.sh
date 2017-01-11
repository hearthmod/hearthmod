#!/bin/bash

repos=( base database gameserver lobbyserver stud nginx web sunwell client )

start_web() {
    # fcgi
    spawn-fcgi -d `pwd`/./hm_web/ -f `pwd`/./hm_web/app.py -a 127.0.0.1 -p 9002
    # nginx
    sudo ./hm_nginx/objs/nginx
}

start() {
    #for i in ${repos[@]}; do
    #    if [ ! -d "hm_${i}" ]; then
    #        echo "Directory hm_${i} doesn't exist, do uninstalled() first"
    #        exit 1
    #    fi
    #done
    if [ "$#" -ne 1 ]; then
        echo 'Please, specify IP of gameserver' $#
        exit 1
    fi
    echo 'Starting hearthmod'
    mkdir -p ./hm_log
    valgrind --log-file=./hm_log/hm_gameserver_valgrind_$(date +%s) --trace-children=yes ./hm_gameserver/hm_gameserver --log=./hm_log/hm_gameserver_$(date +%s)
    valgrind --log-file=./hm_log/hm_lobbyserver_valgrind_$(date +%s) --trace-children=yes ./hm_lobbyserver/hm_lobbyserver --gameserver=$1 --log=./hm_log/hm_lobbyserver_$(date +%s)
    # stud
    ./hm_stud/stud ./hm_stud/cert/test.com.pem
    start_web
}

stop() {
    echo 'Stopping hearthmod'
    ps -ef | grep hm_web | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_gameserver | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_lobbyserver | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_stud | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep nginx | grep -v grep | awk '{print $2}' | xargs sudo kill -9
}

clone() {
    for i in ${repos[@]}; do
        git clone https://github.com/farb3yonddriv3n/hm_$i.git
    done
}

hearthstone_download() {
    echo 'Downloading hearthmod HearthStone client'
    if [ ! -f "hearthmod.zip" ]; then
        wget -O hearthmod.zip https://www.dropbox.com/s/bmdiv3xn81tjwyg/hearthmod.zip?dl=0
    fi
    # create 2 instances so user can play locally
    rm -rf hs_client1/ hs_client2/ hearthmod/
    unzip hearthmod.zip
    mv hearthmod hs_client1
    cp -r hs_client1 hs_client2
}

hearthstone_install() {
    if [ ! -d "hs_client1" ] || [ ! -d "hs_client2" ]; then
        echo "Run 'heaarthstone_download first so both directories hs_client1 and hs_client2 are created"
        exit 1
    fi

    if [ `find . -name "hearthmod"|wc -l` -lt 1 ]; then
        echo "Compile hs_client first so 'hearthmod' executable is created"
        exit 1
    fi

    d1="hs_client1/hearthmod_client/linux/"
    d2="hs_client2/hearthmod_client/linux/"
    rm -rf $d1
    rm -rf $d2
    mkdir -p $d1
    mkdir -p $d2
    cp -f `find . -name "hearthmod"` $d1
    cp -f `find . -name "hearthmod"` $d2
}

couchbase_bucket_create() {
    /opt/couchbase/bin/couchbase-cli bucket-create -c localhost:8091 -u $1 -p $2 --bucket=hbs --bucket-password=aci --bucket-type=couchbase --bucket-ramsize=200 --bucket-replica=1 --wait
}

couchbase_bucket_restore() {
    /opt/couchbase/bin/cbrestore ./hm_database/hbs/ http://localhost:8091/ --bucket-source=hbs -u $1 -p $2
}

build() {
    #if [ "$#" -eq 2 ]; then
        cd ./hm_stud && make && rm -rf cert/test* && cd cert && sh gen_cert.sh && cd ../..
        sudo rm -rf /usr/local/nginx/
  	cd ./hm_nginx && sed "s@\/usr\/local\/web@$(pwd)\/..\/hm_web\/@" conf/hm_nginx.conf > conf/nginx.conf && ./configure && make && sudo make install && cd ..
    #fi
    make -C ./hm_gameserver
    make -C ./hm_lobbyserver
    cd ./hm_client/src && qmake hearthmod.pro && make && cd ../..
    cd ./hm_sunwell/examples && npm install && cd ../..
}

case $1 in
    clone)
        clone
        ;;
    hearthstone_download)
        hearthstone_download
        ;;
    hearthstone_install)
        hearthstone_install
        ;; 
    bucket_create)
        couchbase_bucket_create $2 $3
        ;;
    bucket_restore)
        couchbase_bucket_restore $2 $3
        ;;
    build)
        build
        ;;
    start)
        start $2
        ;;
    start_web)
        start_web
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    uninstalled)
        # remove left overs
        rm -rf libcouchbase/
        # dependencies and couchbase
        sudo apt-get -y update && sudo apt-get install -y libev-dev tar wget libevent-dev build-essential libnet-ifconfig-wrapper-perl cmake python-pip libjson-c-dev curl valgrind zlib1g-dev python-webpy qt5-default qt5-qmake libssl-dev spawn-fcgi python-flup libpcre3-dev npm nodejs-legacy libgif-dev wine
        if [ ! -f "cb.deb" ]; then
            wget -O cb.deb http://packages.couchbase.com/releases/4.5.0/couchbase-server-enterprise_4.5.0-ubuntu14.04_amd64.deb
        fi
        sudo dpkg -i cb.deb
        git clone https://github.com/couchbase/libcouchbase.git
        cd libcouchbase && git checkout 2.7.0 && cmake . && make && sudo make install && cd ..
        wget http://packages.couchbase.com/clients/c/libcouchbase-2.5.8_ubuntu1404_amd64.tar && tar xvf *.tar && cd libcouchbase-2.5.8_ubuntu1404_amd64/ && sudo dpkg -i *.deb && cd ..
        sudo pip install couchbase
        # clone
        clone
        # hs download
        hearthstone_download
        # couchbase
    	echo 'Starting couchbase server'
        sudo service couchbase-server start
        sleep 5
        couchbase_bucket_create Administrator password
        sleep 5
        couchbase_bucket_restore Administrator password
    	# build all
    	build
        # hs install
        hearthstone_install
        echo 'Installation finished'
        ;;
    *)
        echo "Usage: ctl.sh {uninstalled|clone|bucket_create|bucket_restore|build|start|stop}" >&2
        exit 3
esac
