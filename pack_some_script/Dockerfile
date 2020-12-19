FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" \
        VERSION=0.0.6 \
        UPDATE_CONTENT="调整镜像启动入口文件，增加一些自定义，非必要更新，如果更新使用请重新阅读一遍dockerhub地址的readme(https://hub.docker.com/repository/docker/akyakya/pack_some_script)"

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
        jq \
        curl \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

# 支持喜马拉雅极速版仓库
RUN git clone https://github.com/Zero-S1/xmly_speed.git /xmly_speed \
        && cd /xmly_speed \
        && git checkout master \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt

# 支持多账号企鹅阅读的仓库
RUN git clone https://github.com/ziye12/JavaScript.git /qqread \
        && cd /qqread \
        && git checkout master \
        && npm install

# 创建工作目录
RUN mkdir /logs \
        && mkdir /pss

# github action 构建
COPY ./pack_some_script/crontab_list.sh ./pack_some_script/send_notify.py ./pack_some_script/default_task.sh /pss/
COPY ./pack_some_script/docker_entrypoint.sh /usr/local/bin/
# 本地构建
# COPY ./crontab_list.sh ./send_notify.py ./default_task.sh /pss/
# COPY ./docker_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh \
        &&  crontab /pss/crontab_list.sh


#镜像构建版本,每次调整构建文件更新
ENV BUILD_VERSION=0.0.6 \
        DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        # 喜马拉雅极速配置-默认0关闭刷时长
        XMLY_ACCUMULATE_TIME=0 \
        XMLY_NOTIFY_TIME=19 \
        # 企鹅阅读必须配置-默认仓库地址
        COOKIES_SPLIT=| \
        QQREAD_NOTIFY_TIME=19

ENTRYPOINT ["docker_entrypoint.sh"]