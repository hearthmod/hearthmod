#!/bin/bash

start() {
    echo 'Starting hearthmod'
    mkdir -p ./hm_log
    valgrind --log-file=./hm_log/hm_gameserver_valgrind_$(date +%s) --trace-children=yes ./hm_gameserver/hm_gameserver --log=./hm_log/hm_gameserver_$(date +%s)
    valgrind --log-file=./hm_log/hm_lobbyserver_valgrind_$(date +%s) --trace-children=yes ./hm_lobbyserver/hm_lobbyserver --log=./hm_log/hm_lobbyserver_$(date +%s)
    # fcgi
    spawn-fcgi -d `pwd`/./hm_web/ -f `pwd`/./hm_web/app.py -a 127.0.0.1 -p 9002
    # nginx
    sudo nginx
    # stud
    ./hm_stud/stud ./hm_stud/cert/test.com.pem
}

stop() {
    echo 'Stopping hearthmod'
    ps -ef | grep hm_web | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_gameserver | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_lobbyserver | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep hm_stud | grep -v grep | awk '{print $2}' | xargs kill -9
    ps -ef | grep nginx | grep -v grep | awk '{print $2}' | xargs sudo kill -9
}

case $1 in
    clone)
        repos=( base database gameserver lobbyserver stud nginx web sunwell client )
        for i in ${repos[@]}; do
            git clone https://github.com/farb3yonddriv3n/hm_$i.git
        done
        ;;
    hearthstone_download)
        echo 'Downloading hearthmod HearthStone client'
        wget -O hearthmod.zip https://www.dropbox.com/s/bmdiv3xn81tjwyg/hearthmod.zip?dl=0
        unzip hearthmod.zip
        # create 2 instances so user can play locally
        rm -rf hs_client1 hs_client2
        mv hearthmod hs_client1
        cp -r hs_client1 hs_client2
        ;;
    hearthstone_install)
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
        ;; 
    bucket_create)
        if [ "$#" -ne 3 ]; then
            echo "Usage: host_ctl.sh bucket_create username password"
            exit 1
        fi

        /opt/couchbase/bin/couchbase-cli bucket-create -c localhost:8091 -u $2 -p $3 --bucket=hbs --bucket-password=aci --bucket-type=couchbase --bucket-ramsize=200 --bucket-replica=1 --wait
        ;;
    bucket_restore)
        if [ "$#" -ne 3 ]; then
            echo "Usage: host_ctl.sh bucket_restore username password"
            exit 1
        fi

        /opt/couchbase/bin/cbrestore ./hm_database/ http://localhost:8091/ --bucket-source=hbs -u $2 -p $3
        ;;
    compile)
        if [ "$#" -eq 2 ]; then
            cd ./hm_stud && make && rm -rf cert/test* && cd cert && sh gen_cert.sh && cd ../..
            cd ./hm_nginx && sed "s@\/usr\/local\/web@$(pwd)/../hm_web/@" conf/hm_nginx.conf > conf/nginx.conf && ./configure && make && sudo make install
        fi
        make -C ./hm_gameserver
        make -C ./hm_lobbyserver
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: ctl.sh {clone|bucket_create|bucket_restore|compile|start|stop}" >&2
        exit 3
esac
