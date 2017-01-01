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
