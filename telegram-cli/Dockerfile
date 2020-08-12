FROM alpine:latest AS build
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
        && cd /tmp \
        && git clone --recursive https://github.com/vysheng/tg.git \
        && cd /tmp/tg \
        && ./configure --disable-liblua --disable-openssl --prefix=/usr CFLAGS="$CFLAGS -w" \
        && make \
        && cp -r /tmp/tg/bin/ /usr/tg/ \
        && rm -rf /tmp/tg \
        && rm -rf /var/lib/apt/lists/* \
        && apk del .build-deps

WORKDIR /usr/tg/


FROM alpine:latest
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN apk --no-cache add ca-certificates fuse \
                jansson \
                libconfig \
                libcrypto1.1 \
                libevent \
                libressl \
                readline \
                tzdata \
        && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/tg/* /usr/local/bin/

ARG USER=user
ARG UID=1000
ENV USER $USER

RUN mkdir /home/$USER \
  && addgroup -g $UID -S $USER \
  && adduser -u $UID -D -S -G $USER $USER \
  && chown -R $USER:$USER /home/$USER

USER $USER

VOLUME /home/$USER/.telegram-cli

CMD []
ENTRYPOINT ["/usr/local/bin/telegram-cli"]