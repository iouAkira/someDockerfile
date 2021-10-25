FROM alpine
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

ENV LANG C.UTF-8

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns \
        && apk add --no-cache --virtual .run-deps \
        ca-certificates \
        ffmpeg \
        libmagic \
        tiff \
        libwebp \
        freetype \
        lcms2 \
        openjpeg \
        py3-olefile \
        openblas \
        py3-numpy \
        py3-pillow \
        py3-requests \
        python3-dev \
        py3-pip \
        py3-cryptography \
        py3-decorator \
        git \
        jpeg-dev \
        zlib-dev \
        tzdata \
        iproute2 \
        cairo-dev \
        cairo \
        cairo-tools \
        jpeg-dev \
        freetype-dev \
        lcms2-dev \
        openjpeg-dev \
        tiff-dev \
        tk-dev \
        tcl-dev \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

COPY ./efb-v2/docker_entrypoint.sh /usr/local/bin/

RUN set -ex \
        && pip3 install --upgrade pip \
        && pip3 install ehforwarderbot \
        && pip3 install efb-telegram-master \
        && pip3 install efb-wechat-slave \
        && pip3 install efb-qq-slave \
        && pip3 install lottie \
        && pip3 install cairosvg \
        && cd / \
        && mkdir /cust \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["docker_entrypoint.sh"]
