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

# rebuild native deps (canvas) against this image's libraries
RUN npm install --unsafe-perm

ENV PORT=8081
EXPOSE 8081
CMD ["node", "examples/server.js"]
