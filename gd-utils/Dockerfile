FROM alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update \
        && apk add --no-cache nodejs npm curl\
        && apk add --no-cache --virtual .build-deps make gcc g++ python3 git \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
        && git clone https://github.com/iwestlin/gd-utils /root/gd-utils \
        && cd /root/gd-utils \
        && npm audit fix \
        && npm install \
        && apk del .build-deps

EXPOSE 23333

VOLUME ["/root/gd-utils/sa"]

WORKDIR /root/gd-utils

CMD ["node", "server.js"]
