FROM alpine:latest
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV VERSION 1.4.1

RUN set -ex \
        && apk update \
        && apk upgrade \
        && apk add --no-cache \
                --virtual .build-deps \
                git \
                jansson-dev \
                libconfig-dev \
                libevent-dev \
                readline-dev \
                zlib-dev \
                gcc \
                g++ \
                make \
                libffi-dev \
                openssl-dev \
                libgcrypt-dev \
                libressl-dev \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
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
                libgcrypt \
                tzdata \
        && rm -rf /var/lib/apt/lists/*

VOLUME /root/.telegram-cli

ENTRYPOINT ["/tg/bin/telegram-cli"]
CMD []