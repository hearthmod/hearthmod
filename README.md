# hearthmod
hearthmod is a software stack that allows you to modify game of HearthStone, including mechanics, cards, etc. If you intend to run it, it's recommended that you run a linux OS, preferably debian or ubuntu distribution (tested on ubuntu-16.04.7-desktop-amd64).

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

Clone hearthmod software stack

```sh
git clone https://github.com/hearthmod/hearthmod.git
```

Run 

```sh
cd hearthmod/
bash host_ctl_ubuntu.sh uninstalled
```

which compiles and installs the entire hearthmod stack. Also, it doesn't check for you local couchbase, nginx or stud instances. If you don't want to mess them, consider using virtual environment or modify installation script. If you don't run ubuntu or debian, please consider installation script alteration that suits your distro and creating an upstream pull request. Script host_ctl_ubuntu.sh was only tested on Ububtu 16.04.

Once compiled, run:
```sh
bash host_ctl_ubuntu.sh start [ip]
``` 
where IP is address of your gameserver (your current IP in most cases) and you can play.

Then run clients:
```sh
hearthmod/hs_client1/hearthmod_client/linux
```
and
```sh
hearthmod/hs_client2/hearthmod_client/linux
```

By running two instances of hearthstone you can play by yourself and develop or test stuff.

To create or modify cards, accounts, decks; go to http://localhost/ .

## Hosts file:

If you don't want your hearthstone client to connect to hearthmod.com you must edit your hosts file by adding the following line:

```sh
<yourip> hearthmod.com
```

Hosts file location varies depending on OS.

Linux:
```sh
/etc/hosts
```

Windows:
```sh
c:\Windows\System32\Drivers\etc\hosts
```

## Video Installation Guide:


[Full Installation Guide](https://www.youtube.com/watch?v=gq7h9zRmrHs)

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
