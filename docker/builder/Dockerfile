# Shared build image for the native C components:
#   hm_base (static lib) + hm_gameserver + hm_lobbyserver + hm_stud
# Pinned to the toolchain the stack was last tested against
# (Ubuntu 16.04, libcouchbase 2.9.0) — see ../../host_ctl_ubuntu.sh.
#
# NOTE: hm_gameserver / hm_lobbyserver compilation is DEFERRED to runtime (see
# the entrypoints). Their Makefiles run python codegen that reads cards from a
# live, restored Couchbase (script/mechanics/main.py, script/main.py), which is
# only available once couchbase-init has run. stud has no DB dependency and is
# built here.
FROM ubuntu:16.04

# --- toolchain + libraries --------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates build-essential cmake \
        libev-dev libevent-dev libjson-c-dev zlib1g-dev libssl-dev \
        python python-pip python-dev wget tar \
    && rm -rf /var/lib/apt/lists/*

# --- libcouchbase 2.9.0 from source (matches host_ctl_ubuntu.sh) -----------
RUN git clone https://github.com/couchbase/libcouchbase.git /tmp/libcouchbase \
 && cd /tmp/libcouchbase && git checkout 2.9.0 \
 && cmake . && make && make install && ldconfig \
 && rm -rf /tmp/libcouchbase

# --- python couchbase SDK (the codegen scripts import it) ------------------
RUN pip install --no-cache-dir "setuptools<45" \
 && pip install --no-cache-dir couchbase==2.2.4

WORKDIR /opt/hm

# --- components as SIBLINGS (Makefiles reference ../hm_base) ----------------
# Tags match host_ctl_ubuntu.sh's clone() (stud tracks master).
RUN git clone -b v0.1 https://github.com/farb3yonddriv3n/hm_base.git        hm_base \
 && git clone -b v0.2 https://github.com/farb3yonddriv3n/hm_gameserver.git  hm_gameserver \
 && git clone -b v0.1 https://github.com/farb3yonddriv3n/hm_lobbyserver.git hm_lobbyserver \
 && git clone        https://github.com/farb3yonddriv3n/hm_stud.git         hm_stud

# --- make the runtime Couchbase host configurable via $HM_COUCHBASE_HOST ----
COPY docker/builder/patch-couchbase-host.sh /tmp/patch.sh
RUN sh /tmp/patch.sh /opt/hm/hm_gameserver/src/main.c \
 && sh /tmp/patch.sh /opt/hm/hm_lobbyserver/src/main.c

# --- same for gameserver's build-time codegen (hardcodes localhost too) -----
# Only hm_gameserver (v0.2) has DB-backed codegen; hm_lobbyserver (v0.1) has none.
RUN sed -i "s@'couchbase://localhost/hbs'@'couchbase://%s/hbs' % __import__('os').environ.get('HM_COUCHBASE_HOST','localhost')@" \
        /opt/hm/hm_gameserver/script/mechanics/main.py \
 && grep -q "HM_COUCHBASE_HOST" /opt/hm/hm_gameserver/script/mechanics/main.py

# --- build the DB-independent components now (gameserver is deferred) -------
RUN make -C hm_lobbyserver     # v0.1: no codegen, builds hm_base (target=lobby)

# stud defaults DAEMONIZE=1 (and has no CLI flag to disable it), so it forks to
# the background — which makes its container exit and restart-loop, never
# holding port 1119. Default it to foreground so it runs as PID 1.
RUN sed -i 's/\(DAEMONIZE *= *\)1;/\10;/' hm_stud/configuration.c \
 && grep -q 'DAEMONIZE          = 0;' hm_stud/configuration.c
RUN make -C hm_stud

# --- TLS cert for stud (repo's gen_cert.sh is interactive/broken) ----------
RUN cd hm_stud/cert \
 && openssl genrsa -out test.com.key 2048 \
 && openssl req -new -x509 -days 3650 -key test.com.key -out test.com.crt \
        -subj "/CN=hearthmod.com" \
 && cat test.com.key test.com.crt > test.com.pem

# --- entrypoints (selected per service in docker-compose.yml) ---------------
# gameserver/lobbyserver entrypoints run `make` on first start (needs the DB).
COPY docker/gameserver/entrypoint.sh  /usr/local/bin/gameserver-entrypoint.sh
COPY docker/lobbyserver/entrypoint.sh /usr/local/bin/lobbyserver-entrypoint.sh
COPY docker/stud/entrypoint.sh        /usr/local/bin/stud-entrypoint.sh
RUN chmod +x /usr/local/bin/gameserver-entrypoint.sh \
             /usr/local/bin/lobbyserver-entrypoint.sh \
             /usr/local/bin/stud-entrypoint.sh
