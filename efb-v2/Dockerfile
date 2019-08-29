FROM alpine:edge
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns \
        && apk add --no-cache --virtual .build-deps \
                ca-certificates \
                ffmpeg \
                libmagic \
                python3 \
                tiff \
                libwebp \
                freetype \
                lcms2 \
                openjpeg \
                py3-olefile \
                openblas \
                py3-numpy \
                py3-pillow \
                py3-yaml \
                py3-requests \
                py3-cryptography \
                py3-decorator \
                git \
                jpeg-dev \
                zlib-dev \
                tzdata \
                iproute2 \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
        && pip3 install --upgrade pip \
        && pip install ehforwarderbot==2.0.0b17  \
        && pip install efb-wechat-slave==2.0.0a22 \
        && pip install efb-telegram-master==2.0.0b22 \
        && pip3 install python-telegram-bot==10.1.0 --upgrade

CMD ["ehforwarderbot"]
