#!/bin/sh
set -e
cd /opt/hm/hm_gameserver

# Build is deferred to runtime: `make` runs python codegen
# (script/mechanics/main.py) that pulls cards from Couchbase, so it needs the
# live, restored DB — couchbase-init must have completed (enforced via
# depends_on in docker-compose.yml). Skip the build on container restart.
if [ ! -x ./hm_gameserver ]; then
    echo "[gameserver] building (codegen reads Couchbase at ${HM_COUCHBASE_HOST:-localhost}) ..."
    make
fi

# Run in the FOREGROUND. Passing --log would make hm_gameserver daemonize and
# the container would exit; without it, logs go to stdout for `docker logs`.
echo "[gameserver] Couchbase host: ${HM_COUCHBASE_HOST:-localhost}; listening on 0.0.0.0:3724"
exec ./hm_gameserver
