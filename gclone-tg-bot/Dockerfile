FROM alpine:latest AS rclone
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update \
        && apk upgrade \
        && apk add --no-cache \
                --virtual .build-deps \
                git \
                go \
                gcc \
                g++ \
                make \
                libffi-dev \
                openssl-dev \
                libtool \
                musl-dev \
        && git clone https://github.com/rclone/rclone.git /usr/src/rclone 

WORKDIR /usr/src/rclone/

RUN set -ex \
        && CGO_ENABLED=0 \
        && make \
        && apk del .build-deps

RUN ./rclone version


FROM alpine:latest AS gclone
ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN set -ex \
        && apk update \
        && apk upgrade \
        && apk add --no-cache \
                --virtual .build-deps \
                git \
                go \
                upx \
        && git clone https://github.com/donwa/gclone.git /usr/src/gclone

WORKDIR /usr/src/gclone/

RUN set -ex \
        && LDFLAGS="-s -w" \
        && go build -ldflags "$LDFLAGS" -v -o /usr/bin/gclone \
        && upx --lzma /usr/bin/gclone \
        && apk del .build-deps


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

COPY --from=rclone /usr/src/rclone/rclone /usr/local/bin/rclone
COPY --from=gclone /usr/bin/gclone /usr/local/bin/gclone

COPY gclone_telegram_bot.py /usr/bot/

ENTRYPOINT ["python3","/usr/bot/gclone_telegram_bot.py"]

CMD ['admin_id',"tocken"]