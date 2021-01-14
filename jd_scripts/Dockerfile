FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" \
        VERSION=0.1.3 \
        UPDATE_CONTENT="最后构建一个Gitee仓库版本的供大家过渡使用，后续请迁移使用其他仓库镜像，或者其他使用方式。"

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata moreutils git nodejs npm curl jq\
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://gitee.com/lxk0301/jd_scripts /scripts \
        && cd /scripts \
        && git checkout master \
        && mkdir logs \
        && npm install \
        && cd /tmp \
        && npm install request

ENV BUILD_VERSION=0.1.3 \
        DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append

# github action 构建    
COPY ./jd_scripts/docker_entrypoint.sh /usr/local/bin
# 本地构建
# COPY ./docker_entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]
