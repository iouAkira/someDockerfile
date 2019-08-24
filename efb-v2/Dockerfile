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
        && pip3 install ehforwarderbot  \
        && pip3 install efb-wechat-slave \
        && pip3 install efb-telegram-master \
        && pip3 install python-telegram-bot==10.1.0 --upgrade \
        && git clone https://github.com/catbaron0/efb-voice_recog-middleware \
        && git clone https://github.com/catbaron0/efb-link_preview-middleware \
        && git clone https://github.com/catbaron0/efb-msg_blocker-middleware \
        && cd /efb-voice_recog-middleware \
        && python3 setup.py install \
        && cd /efb-link_preview-middleware \
        && python3 setup.py install \
        && cd /efb-msg_blocker-middleware \
        && python3 setup.py install

CMD ["ehforwarderbot"]