FROM alpine
MAINTAINER AKira <e.akimoto.akira@gmail.com>

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

RUN set -ex \
        && pip3 install --upgrade pip \
        && pip3 install ehforwarderbot \
        && pip3 install efb-telegram-master \
        && pip3 install efb-wechat-slave \
        && pip3 install efb-qq-slave \
        && pip3 install lottie \
        && pip3 install cairosvg \
        && sed -i 's/channel_emoji = "💬"/channel_emoji = "𝙒𝙚𝙘𝙝𝙖𝙩"/g' /usr/lib/python3.8/site-packages/efb_wechat_slave/__init__.py \
        && sed -i "s/{self.chat_type_emoji}/丨/g" /usr/lib/python3.8/site-packages/efb_telegram_master/chat.py \
        && cd ~ \
        && git clone https://github.com/catbaron0/efb-mp-instanceview-middleware.git \
        && git clone https://github.com/catbaron0/efb-link_preview-middleware.git \
        && cd ~/efb-mp-instanceview-middleware/ && python3 setup.py install \
        && cd ~/efb-link_preview-middleware/ && python3 setup.py install \
        && rm -rf ~/efb-mp-instanceview-middleware/ ~/efb-link_preview-middleware/

CMD ["ehforwarderbot"]
