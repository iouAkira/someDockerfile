FROM alpine AS builder
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates py-pygments \
        && apk add --virtual .build-deps \
                git \
                go \
                gcc \
                g++ \
                make \
                libffi-dev \
                openssl-dev \
                libtool \
                musl-dev

RUN set -ex \
        && mkdir -p /usr/src \
        && cd /usr/src \
        && git clone https://github.com/rclone/rclone.git

WORKDIR /usr/src/rclone/

RUN \
  CGO_ENABLED=0 \
  make
RUN ./rclone version


FROM alpine:latest
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN apk --no-cache add ca-certificates fuse \
                python3-dev \
                py3-pip \
                py3-wheel \
                gcc \
                musl-dev \
                libffi-dev \
                openssl-dev \
                tzdata
RUN set -ex \
        && pip3 install --upgrade setuptools \
        && pip3 install --upgrade pip \
        && pip3 install python-telegram-bot \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "user_allow_other" >> /etc/fuse.conf

RUN set -ex apk del gcc musl-dev libffi-dev openssl-dev

COPY --from=builder /usr/src/rclone/rclone /usr/local/bin/
COPY gclone_telegram_bot.py /usr/bot/

ENTRYPOINT ["python3","/usr/bot/gclone_telegram_bot.py"]

CMD ['admin_id',"tocken"]