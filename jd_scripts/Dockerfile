FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>"

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata moreutils git nodejs npm\
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://github.com/lxk0301/jd_scripts /scripts \
        && cd /scripts \
        && git checkout master \
        && mkdir logs \
        && npm install \
        && cd /tmp \
        && npm install request

ENV BUILD_VERSION=0.1.0 \
#     DEFAULT_LIST_FILE=crontab_list.sh \
    CUSTOM_LIST_MERGE_TYPE=append

COPY ./docker_entrypoint.sh /usr/local/bin
COPY ./load_crontab_file.sh /scripts/docker
RUN chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]
