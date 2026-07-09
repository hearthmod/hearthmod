# node-sunwell card renderer. Uses an old native canvas (^1.3.x) that needs an
# older Node + cairo/pango/gif headers, so we pin node:8 (Debian stretch).
FROM node:8

# Debian stretch is EOL — its packages moved to archive.debian.org and the
# Release files are expired, so repoint apt there and skip the validity check.
RUN sed -i -e 's|deb.debian.org/debian|archive.debian.org/debian|g' \
           -e 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' \
           -e 's|security.debian.org|archive.debian.org/debian-security|g' \
           -e '/stretch-updates/d' /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential git ca-certificates \
        libcairo2-dev libjpeg-dev libpango1.0-dev libgif-dev libpng-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hm_sunwell
RUN git clone -b v0.1 https://github.com/farb3yonddriv3n/hm_sunwell.git .

# Decouple from the old sibling-directory layout (server.js assumed hm_web and
# the carddata file were siblings on one host):
#  - read the card JSON from the shared /shared/carddata
#  - write the rendered image to /opt/hm_web/static/custom (shared with web)
#  - don't crash the process on a missing carddata / render error (it used
#    `throw err` in an async callback and an undefined `next`)
RUN sed -i "s@process.cwd() + '/examples/carddata'@'/shared/carddata'@" examples/server.js \
 && sed -i "s@process.cwd() + '/../hm_web/static/custom/'@'/opt/hm_web/static/custom/'@" examples/server.js \
 && perl -0777 -i -pe "s/if \(err\) throw err;/if (err) { res.writeHead(500); res.end('no carddata queued'); return; }/" examples/server.js \
 && perl -0777 -i -pe "s/if \(err\) next\(err\);/if (err) { console.log(err); res.writeHead(500); res.end('render error'); return; }/" examples/server.js \
 && grep -q "/shared/carddata" examples/server.js

# The repo vendors a 2016 node_modules whose prebuilt canvas binary links the
# old libpng12 (absent on this base) — "libpng12.so.0: cannot open shared
# object file". Remove it so canvas is recompiled against this image's libpng.
RUN rm -rf node_modules \
 && npm install --unsafe-perm

ENV PORT=8081
EXPOSE 8081
CMD ["node", "examples/server.js"]
