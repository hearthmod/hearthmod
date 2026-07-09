#!/bin/sh
set -e
cd /opt/hm/hm_lobbyserver
# Built at image time (v0.1 has no DB-backed codegen). It still connects to
# Couchbase at startup, so depends_on waits for couchbase-init to finish.
#
# Foreground (no --log) so logs reach `docker compose logs lobbyserver`.
# --gameserver is the address the lobby RELAYS to the client, so it must be
# reachable from the player's machine (the Docker host's IP), NOT the internal
# "gameserver" service name. Set GAMESERVER_PUBLIC_IP in .env.
# (v0.1 takes only --gameserver=; the gameserver port is fixed at 3724.)
echo "[lobbyserver] Couchbase host: ${HM_COUCHBASE_HOST:-localhost}; listening on 0.0.0.0:45678"
echo "[lobbyserver] relaying gameserver address ${GAMESERVER_PUBLIC_IP:-127.0.0.1}:3724 to clients"
exec ./hm_lobbyserver \
    --gameserver="${GAMESERVER_PUBLIC_IP:-127.0.0.1}"
