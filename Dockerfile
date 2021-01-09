FROM rust:1.48.0-buster AS builder

ARG FLEXO_VERSION=1.0.12

WORKDIR /build/

ADD https://github.com/nroi/flexo/archive/$FLEXO_VERSION.tar.gz .

RUN \
    tar -xvf $FLEXO_VERSION.tar.gz flexo-$FLEXO_VERSION/flexo/ --strip 1 \
    && cd flexo \
    && cargo build --release

FROM archlinux:latest

ADD https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz /tmp
RUN \
    echo "installing s6overlay" \
    && cd /tmp \
    && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" \
    && tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin \
    && rm /tmp/s6-overlay-amd64.tar.gz \
    && echo "setting up flexo directory structure" \
    && mkdir -p /var/cache/flexo/state \
    && mkdir -p /var/cache/flexo/pkg/{community,community-staging,community-testing,core,extra,gnome-unstable,kde-unstable,multilib,multilib-testing,staging,testing}/os/x86_64


COPY --from=builder /build/flexo/target/release/flexo /usr/bin/flexo
COPY root/ /

ENV FLEXO_CACHE_DIRECTORY="/var/cache/flexo/pkg" \
    FLEXO_LOW_SPEED_LIMIT=128000 \
    FLEXO_LOW_SPEED_TIME_SECS=3 \
    FLEXO_MIRRORLIST_FALLBACK_FILE="/var/cache/flexo/state/mirrorlist" \
    FLEXO_PORT=7878 \
    FLEXO_MIRROR_SELECTION_METHOD="auto" \
    FLEXO_MIRRORS_PREDEFINED=[] \
    FLEXO_MIRRORS_BLACKLIST=[] \
    FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED=true \
    FLEXO_MIRRORS_AUTO_IPV4=true \
    FLEXO_MIRRORS_AUTO_IPV6=false \
    FLEXO_MIRRORS_AUTO_MAX_SCORE=2.5 \
    FLEXO_MIRRORS_AUTO_NUM_MIRRORS=8 \
    FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT="sort" \
    FLEXO_MIRRORS_AUTO_TIMEOUT=350 \
    # Every week on Monday at at 12:08
    CRON_PACCACHE_CLEAN="8 0 * * 1" \
    CRON_PACCACHE_KEEP="3" \
    RUST_LOG="info"

RUN pacman -Syu --noconfirm pacman-contrib cronie \
    && echo "cleaning up install" \
    && paccache --keep 0 --remove \
    && rm -rf /tmp/*

EXPOSE 7878
VOLUME [ "/etc/flexo", "/var/cache/flexo" ]

ENTRYPOINT ["/init"]
