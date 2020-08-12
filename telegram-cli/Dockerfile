FROM alpine:latest
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update \
        && apk upgrade \
        && apk add --no-cache \
                --virtual .build-deps \
                git \
                jansson-dev \
                libconfig-dev \
                libevent-dev \
                make \
                openssl-dev \
                readline-dev \
                zlib-dev \
                gcc \
                g++ \
                make \
                libffi-dev \
                openssl-dev \
                libgcrypt-dev \
                libressl-dev \
        && git clone --recursive https://github.com/vysheng/tg.git /tg \
        && cd /tg \
        && ./configure --disable-liblua --disable-openssl --prefix=/usr CFLAGS="$CFLAGS -w" \
        && make \
        && rm -rf /var/lib/apt/lists/* \
        && apk del .build-deps

RUN apk --no-cache add ca-certificates fuse \
                jansson \
                libconfig \
                libcrypto1.1 \
                libevent \
                libressl \
                readline \
                tzdata \
        && rm -rf /var/lib/apt/lists/*

VOLUME /root/.telegram-cli

ENTRYPOINT ["/tg/bin/telegram-cli"]
CMD []