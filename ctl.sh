#!/bin/sh

case $1 in
    bucket_create)
        /opt/couchbase/bin/couchbase-cli bucket-create -c localhost:8091 -u Administrator -p password --bucket=hbs --bucket-password=aci --bucket-type=couchbase --bucket-ramsize=200 --bucket-replica=1 --wait
        ;;
    bucket_restore)
        /opt/couchbase/bin/cbrestore ~/hm_database/ http://localhost:8091/ --bucket-source=hbs
        ;;
    compile)
        make -C ~/hm_gameserver
        make -C ~/hm_lobbyserver
        ;;
    start)
        mkdir -p ~/hm_log
        valgrind --log-file=/root/hm_log/hm_gameserver_valgrind_$(date +%s) --trace-children=yes ~/hm_gameserver/hm_gameserver --log=/root/hm_log/hm_gameserver_$(date +%s)
        valgrind --log-file=/root/hm_log/hm_lobbyserver_valgrind_$(date +%s) --trace-children=yes ~/hm_lobbyserver/hm_lobbyserver --log=/root/hm_log/hm_lobbyserver_$(date +%s)
        ;;
    stop)
        ps -ef | grep hm_ | grep -v grep | awk '{print $2}' | xargs kill -9
        ;;
    *)
        echo "Usage: ctl.sh {bucket_create|bucket_restore|compile|start|stop}" >&2
        exit 3
esac
