# hearthmod — Dockerized backend stack

A `docker compose` stack that runs the full hearthmod **backend** (everything
except the desktop game client) as one container per component. It supersedes
the manual `host_ctl_ubuntu.sh` flow for server-side use; the old scripts and
root `Dockerfile` are left in place for reference.

## Architecture

```
                player's machine
        Hearthstone client (hearthmod.com)
                       │ TLS :1119
                       ▼
   ┌───────────────────────────────────────────────┐
   │ stud  (TLS terminator)  :1119 ──► lobbyserver  │
   │ lobbyserver  :45678  ──relays──► gameserver IP │
   │ gameserver   :3724  ◄── client connects direct │
   │ web (nginx :80 + web.py fcgi :9002)            │
   │ sunwell (card renderer :8081)                  │
   │ couchbase  :8091 / 11210   (+ one-shot init)   │
   └───────────────────────────────────────────────┘
        all on the "hearthmod" bridge network
```

Connection flow: the client dials **stud:1119** over TLS; stud forwards to the
**lobbyserver**, which authenticates against Couchbase and relays the
**gameserver address** back to the client; the client then connects directly to
**gameserver:3724**. The **web** UI manages cards/accounts/decks in Couchbase.

| Service          | Image / build                | Host ports | Notes |
|------------------|------------------------------|-----------|-------|
| `couchbase`      | `couchbase:enterprise-4.5.0` | 8091      | data store, bucket `hbs` |
| `couchbase-init` | built (from couchbase image) | –         | one-shot: cluster init + bucket + restore |
| `gameserver`     | `hearthmod/native` (builder) | 3724      | foreground, logs to stdout |
| `lobbyserver`    | `hearthmod/native` (builder) | –         | behind stud |
| `stud`           | `hearthmod/native` (builder) | 1119      | TLS entrypoint |
| `web`            | built (ubuntu16.04)          | 80        | nginx + web.py |
| `sunwell`        | built (node:8)               | 8081      | card image renderer |

## Run

> **Requires Compose v2** — use `docker compose` (with a space). The legacy
> `docker-compose` (hyphen, v1) is EOL and cannot run this stack: it rejects the
> config and lacks the `depends_on` conditions used for init ordering. Check with
> `docker compose version`; if missing, install the Compose v2 plugin.

```sh
cd hearthmod/
cp .env.example .env
# edit .env: set GAMESERVER_PUBLIC_IP to this host's LAN IP (what clients use)

docker compose build           # first build is slow (compiles libcouchbase, nginx, canvas)
docker compose up -d
docker compose logs -f couchbase-init   # watch the bucket get created + restored
docker compose ps
```

Then, on each **client** machine, point `hearthmod.com` at this host in the
hosts file (see the main `README.md`) and launch the client.

```sh
docker compose down       # stop
docker compose down -v    # stop + wipe the Couchbase volume (fresh DB next time)
```

## What was changed vs. the bare-metal stack

Two source-level hardcodes blocked splitting Couchbase into its own container;
both are patched **at build time** (the upstream repos are untouched):

- **`hm_gameserver` / `hm_lobbyserver`** had `const char *hosts[1] = { "localhost" }`
  in `main.c`. `docker/builder/patch-couchbase-host.sh` rewrites this to read
  `$HM_COUCHBASE_HOST` (set to `couchbase` in compose) and adds `#include <stdlib.h>`
  for `getenv`. The patch fails the build loudly if the pattern moves.
- **`hm_web/app.py:48`** had `Bucket('couchbase://localhost/hbs', ...)`; the web
  Dockerfile rewrites it to read `$HM_COUCHBASE_HOST`.

Other notes:
- **gameserver is compiled at runtime, not at image build.** Its Makefile runs
  python codegen (`script/mechanics/main.py`) that pulls cards from a live,
  restored Couchbase, so the build can only happen once `couchbase-init` has
  completed. The entrypoint runs `make` on first start (skipped on restart if
  the binary exists), so the gameserver container takes ~30–60s the first time.
  That codegen script also hardcoded `localhost`, so it gets the same
  `$HM_COUCHBASE_HOST` patch as `main.c`. lobbyserver (v0.1, no codegen) and stud
  are built in the image.
- Servers run in the **foreground** (no `--log`): passing `--log` makes them
  daemonize and the container would exit. Logs go to `docker compose logs`.
- `stud` is pointed at the lobbyserver via its `-b host,port` flag (no patch),
  and its TLS cert is generated **non-interactively** in the builder (the repo's
  `gen_cert.sh` prompts and is broken).
- `lobbyserver --gameserver=` is set from `GAMESERVER_PUBLIC_IP`, because that
  address is relayed to the client and must be reachable from the player's box —
  not the internal `gameserver` service name.

## Known risks / first-run gotchas

This stack is reconstructed from 2016-era pinned versions and has **not been
run end-to-end here** — likely friction points, in rough order:

1. **`sunwell`/`canvas` native build** — `canvas@1.3.x` on `node:8` is the most
   fragile piece; if `npm install` fails, bump the canvas/node versions in
   `docker/sunwell/Dockerfile`.
2. **`couchbase:enterprise-4.5.0` image availability** — if the tag is gone, try
   `couchbase:community-4.5.1` (update both `docker-compose.yml` and
   `docker/couchbase-init/Dockerfile`).
3. **`couchbase-init` provisioning** — uses the REST API for cluster-init; if the
   bucket/restore step misbehaves, run `docker compose logs couchbase-init` and
   re-run `docker compose up couchbase-init` (it's idempotent).
4. **python2 pip on Ubuntu 16.04** (`web`) — old pip/TLS to PyPI can fail; if so,
   pin an index mirror or pre-vendor the wheels.
5. **Build-time `git clone`** — the Dockerfiles fetch the component repos at the
   tags from `host_ctl_ubuntu.sh`. Needs network during `docker compose build`.

Report what `docker compose build` / `up` and `docker compose logs` show and
we can iterate on whichever stage breaks first.
