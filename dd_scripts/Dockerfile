FROM alpine as goBuild
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"
ENV DEFAULT_LIST_FILE=crontab_list.sh
RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add --no-cache go

COPY ./dd_scripts/GolangCode.tar.gz /

RUN set -ex \
    && cd / \
    && tar -zxvf GolangCode.tar.gz \
    && rm -rf /GolangCode.tar.gz \
    && go version \
    && cd /GolangCode/ddbot \
    && go build ddBot.go

FROM alpine
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

ENV DEFAULT_LIST_FILE=crontab_list.sh \
    CUSTOM_LIST_MERGE_TYPE=append \
    COOKIE_LIST=/data/cookies.list \
    GEN_CODE_LIST=/data/genCodeConf.list \
    LOGS_DIR=/data/logs \
    DDBOT_VER=0.5

COPY --from=goBuild /GolangCode/ddbot/ddBot /usr/local/bin/ddBot

RUN set -ex \
    && apk update && apk upgrade\
    && apk add --no-cache tzdata git \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir /jds \
    && cd  /jds \
    && git init \
    && git remote add -f origin https://github.com/iouAkira/someDockerfile.git \
    && git config core.sparsecheckout true \
    && echo dd_scripts/* >> /jds/.git/info/sparse-checkout \
    && git pull origin master \
    && cp /jds/dd_scripts/docker_entrypoint.sh /usr/local/bin \
    && chmod +x /usr/local/bin/docker_entrypoint.sh \
    && chmod +x /usr/local/bin/ddBot \
    && ddBot -up syncRepo

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
