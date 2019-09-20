FROM alpine
MAINTAINER Akyakya <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8

RUN apk add --update --no-cache ca-certificates

RUN set -ex \
        && apk add --no-cache --virtual .run-deps \
                ffmpeg \
                libmagic \
                python3 \
                py3-numpy \
                py3-pillow \
                gcc

RUN set -ex \
        && apk add --update --no-cache --virtual .fetch-deps \
                curl \
                tar \
        && curl -L -o EFB-latest.tar.gz \
                $(curl -s https://api.github.com/repos/blueset/ehForwarderBot/tags \
                    | grep tarball_url | head -n 1 | cut -d '"' -f 4) \
        && mkdir -p /opt/ehForwarderBot/storage \
        && tar -xzf EFB-latest.tar.gz --strip-components=1 -C /opt/ehForwarderBot \
        && rm EFB-latest.tar.gz \
        && apk del .fetch-deps \
        && pip3 install --upgrade pip \
        && pip3 install -r /opt/ehForwarderBot/requirements.txt \
        && rm -rf /root/.cache

WORKDIR /opt/ehForwarderBot

CMD ["python3", "main.py"]
