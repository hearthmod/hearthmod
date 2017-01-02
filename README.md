# hearthmod
hearthmod is a software stack that allows you to modify game of HearthStone, including mechanics, cards, etc. If you intend to run it, I highly recommend that you run a linux OS, preferably debian or ubuntu distribution, since everything was tested there.

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
## Components
[hm_lobbyserver](https://github.com/farb3yonddriv3n/hm_lobbyserver) - hearthmod lobby server

[hm_gameserver](https://github.com/farb3yonddriv3n/hm_gameserver) - hearthmod game server

[hm_base](https://github.com/farb3yonddriv3n/hm_base) - hearthmod base library

[hm_client](https://github.com/farb3yonddriv3n/hm_client) - hearthmod client

[hm_database](https://github.com/farb3yonddriv3n/hm_database) - hearthmod latest database snapshot

[hm_sunwell](https://github.com/farb3yonddriv3n/hm_sunwell) - hearthsim custom card generation

[hm_stud](https://github.com/farb3yonddriv3n/hm_stud) - tls un/wrapper

[hm_nginx](https://github.com/farb3yonddriv3n/hm_nginx) - nginx web server

[hm_web](https://github.com/farb3yonddriv3n/hm_web) - hearthmod web interface

## Guide
1. Clone hearthmod software stack

git clone https://github.com/hearthmod/hearthmod.git

2. Get all dependencies mentioned in hearthmod/Dockerfile, if you find out that you miss some dependencies during the installation you can always start over.

3. Run host installation scripts:
- ```bash host_ctl.sh``` and one of the following parameters:

a) ```clone``` - clone the entire hearthmod software stack

b) ```hearthstone_download``` - download hearthstone client

c) ```hearthstone_install``` - once downloaded install hearthstone client

d) ```bucket_create``` - create couchbase bucket

e) ```bucket_restore``` - load couchbase bucket with latest data

f) ```compile (all)``` - compile nginx, stud when 'all' and compile lobby and game server by default

g) ```start``` - start entire stack

h) ```stop``` - stop entire stack

i) ```restart``` - stop and start


Before you run it, there are several things you should know. host ctl compile option erases your nginx configuration folder /usr/local/nginx. Also, if you run any service on port 80, you should stop it first. When started correctly, the following ports are used by hearthmod: 80(nginx), 1119(stud), 3724(gameserver), 45678(lobbyserver). Host ctl bucket_restore creates two hearthmod users on your system with username/password: john/doe, mike/doe.

hearthmod/hs_client is the only part you have to compile manually using qtcreator.

Once compiled, you can play. Go to hearthmod/hs_client1/hearthmod_client/linux and hearthmod/hs_client2/hearthmod_client/linux. By running two instances of hearthstone you can play by yourself and develop or test stuff.

To create or modify cards, go to http://localhost/mod .

## Troubleshooting:

web server error log file:
```sh
tail -f /usr/local/nginx/logs/error.log
```
gameserver and lobbyserver log files:
```sh
./hearthmod/hm_log/*
```

Pull requests are more than welcome.

## Contact:

join IRC channel #hearthmod @ irc.freenode.org
