# hearthmod
hearthmod software stack

To clone the entire stack:
```sh
bash host_ctl.sh clone
```

Create Couchbase bucket (Couchbase server must be running):
```sh
bash host_ctl.sh bucket_create
```

Fill couchbase bucket with hearthmod information:
```sh
bash host_ctl.sh bucket_restore
```

Compile gameserver, lobbyserver, stud and nginx:
```sh
bash host_ctl.sh compile
```

Start hearthmod:
```sh
bash host_ctl.sh start
```
# Components
[hm_lobbyserver](https://github.com/farb3yonddriv3n/hm_lobbyserver) - hearthmod lobby server

[hm_gameserver](https://github.com/farb3yonddriv3n/hm_gameserver) - hearthmod game server

[hm_base](https://github.com/farb3yonddriv3n/hm_base) - hearthmod base library

[hm_client](https://github.com/farb3yonddriv3n/hm_client) - hearthmod client

[hm_database](https://github.com/farb3yonddriv3n/hm_database) - hearthmod latest database snapshot

[hm_sunwell](https://github.com/farb3yonddriv3n/hm_sunwell) - hearthsim custom card generation

[hm_stud](https://github.com/farb3yonddriv3n/hm_stud) - tls un/wrapper

[hm_nginx](https://github.com/farb3yonddriv3n/hm_nginx) - nginx web server

[hm_web](https://github.com/farb3yonddriv3n/hm_web) - hearthmod web interface

