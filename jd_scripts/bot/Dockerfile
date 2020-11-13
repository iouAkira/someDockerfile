FROM alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata \
                                git \
                                nodejs \
                                moreutils \
                                npm \
                                python3-dev \
                                py3-pip \
                                py3-cryptography \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://github.com/lxk0301/jd_scripts /scripts \
        && cd /scripts \
        && mkdir logs \
        && npm install \
        && cd ~ \
        && npm install request

RUN cd /scripts/docker/ \
        && mkdir bot

COPY ./jd_scripts/bot/* /scripts/docker/bot/

RUN cd /scripts/docker/bot \
        && ls -a \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt \
        && python3 setup.py install

ENV CDN_JD_DAILYBONUS true
ENV CRONTAB_LIST_FILE crontab_list_ts.sh

RUN crontab /scripts/docker/crontab_list_ts.sh

WORKDIR /scripts

CMD ["node"]
