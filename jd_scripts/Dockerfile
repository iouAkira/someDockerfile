FROM alpine as goBuild
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add --no-cache --virtual .build-deps git openssh-client go gcc g++ make libffi-dev openssl-dev libtool musl-dev 

COPY ./jd_scripts/id_rsa /root/.ssh/id_rsa

RUN set -ex \
    && chmod 600 /root/.ssh/id_rsa \
    && ssh-keyscan github.com > /root/.ssh/known_hosts \
    && git clone git@github.com:iouAkira/GolangCode.git /GolangCode \
    && cd /GolangCode/repoSync \
    && go build repoSync.go \
    && cd /GolangCode/ddBot \
    && go build ddBot.go \
    && apk del .build-deps

FROM alpine
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

ENV DEFAULT_LIST_FILE=crontab_list.sh \
    CUSTOM_LIST_MERGE_TYPE=append \
    COOKIE_LIST=/scripts/logs/cookies.list \
    GEN_CODE_LIST=/scripts/logs/gen_code_conf.list \
    REPO_URL=git@gitee.com:lxk0301/jd_scripts.git \
    BOT_DIR=/jds/jd_scripts/bot \
    LOGS_DIR=/scripts/logs

RUN set -ex \
    && apk update && apk upgrade\
    && apk add --no-cache tzdata git \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
    && mkdir /jds \
    && cd  /jds \
    && git init \
    && git remote add -f origin https://github.com/iouAkira/someDockerfile.git \
    && git config core.sparsecheckout true \
    && echo jd_scripts/* >> /jds/.git/info/sparse-checkout \
    && git pull origin master

COPY --from=goBuild /GolangCode/repoSync/repoSync /usr/local/bin/repoSync
COPY --from=goBuild /GolangCode/repoSync/ddBot /usr/local/bin/ddBot

RUN cp /jds/jd_scripts/docker_entrypoint.sh /usr/local/bin \
    && chmod +x /usr/local/bin/docker_entrypoint.sh \
    && chmod +x /usr/local/bin/repoSync \
    && chmod +x /usr/local/bin/ddBot

RUN set -ex \
    && repoSync \
    && mkdir -p /scripts/logs 

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
