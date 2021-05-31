FROM node:12-alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache udns \
        && apk add --no-cache --virtual .build-deps \
                                git \
                                autoconf \
                                automake \
                                make \
                                build-base \
                                curl \
                                libev-dev \
                                c-ares-dev \
                                libtool \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                tar \
                                udns-dev \
                                tzdata \
                                iproute2 \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone\

        && cd /tmp/ \
        && git clone https://github.com/shadowsocks/shadowsocks-libev.git \
        && cd shadowsocks-libev \
        && git submodule update --init --recursive \
        && ./autogen.sh \
        && ./configure --prefix=/usr --disable-documentation \
        && make install \

        && cd /tmp/ \
        && git clone https://github.com/shadowsocks/simple-obfs.git shadowsocks-obfs \
        && cd shadowsocks-obfs \
        && git submodule update --init --recursive \
        && ./autogen.sh \
        && ./configure --prefix=/usr --disable-documentation \
        && make install \

        && cd .. \
        && runDeps="$( \
                scanelf --needed --nobanner /usr/bin/ss-* \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | xargs -r apk info --installed \
                    | sort -u \
            )" \
        && apk add --no-cache --virtual .run-deps $runDeps \
        && apk del .build-deps \
        && rm -rf /tmp/*
RUN npm i -g shadowsocks-manager --unsafe-perm

ENTRYPOINT ["ssmgr","-c"]

CMD ["/root/.ssmgr/shad.yml","-r"]
