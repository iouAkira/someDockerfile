FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" \
        VERSION=0.0.7 \
        UPDATE_CONTENT="增加汽车之家极速版及相关配置更新,修正汽车之家极速版多账号执行异常bug，请参考dockerhub仓库(https://hub.docker.com/r/akyakya/pack_some_script)readme配置"

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

# 配置镜像仓库配置相关文件夹
# 创建工作目录
RUN mkdir /logs \
        && mkdir /pss \
        && cd  /pss \
        && git init \
        && git remote add -f origin https://github.com/iouAkira/someDockerfile.git \
        && git config core.sparsecheckout true \
        && echo pack_some_script/* >> /pss/.git/info/sparse-checkout \
        && git pull origin master \
        && cp /pss/pack_some_script/crontab_list.sh /pss/crontab_list.sh

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

# 支持多账号汽车之家的仓库
RUN git clone https://github.com/ziye12/QCZJSPEED.git /QCZJSPEED


# github action 构建
COPY ./pack_some_script/docker_entrypoint.sh /usr/local/bin/
# 本地构建
# COPY ./docker_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh \
        &&  crontab /pss/crontab_list.sh


#镜像构建版本,每次调整构建文件更新
ENV BUILD_VERSION=0.0.7 \
        DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        # 喜马拉雅极速配置-默认0关闭刷时长
        XMLY_ACCUMULATE_TIME=0 \
        XMLY_NOTIFY_TIME=19 \
        # 企鹅阅读必须配置-默认仓库地址
        COOKIES_SPLIT=| \
        QQREAD_NOTIFY_TIME=19

ENTRYPOINT ["docker_entrypoint.sh"]