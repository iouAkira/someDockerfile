FROM alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update \
        && apk add --no-cache nodejs npm \
        && apk add --no-cache --virtual .build-deps make gcc g++ python3 git \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
        && git clone https://github.com/iwestlin/gd-utils /gd-utils \
        && cd /gd-utils \
        && npm audit fix \
        && npm install \
        && apk del .build-deps

EXPOSE 23333

WORKDIR /gd-utils

CMD ["node", "server.js"]