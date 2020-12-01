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

# 支持喜马拉雅极速版仓库
RUN git clone https://github.com/Zero-S1/xmly_speed.git /xmly_speed \
        && cd /xmly_speed \
        && git checkout master \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt

# 支持多账号企鹅阅读的仓库
RUN git clone https://github.com/QCEnjoyLL/qeyd.git /qeyd \
        && cd /qeyd \
        && git checkout master \
        && npm install

# 创建工作目录，替换多Cookies链接符号
RUN mkdir /logs \
        && mkdir /cron_list \
        && sed -i 's/COOKIE_QEYD.split("\\n")/COOKIE_QEYD.split("||")/g' /qeyd/Scripts/qeyd_replace.js \
        && sed -i "s/xmly_speed_cookie.split('\\n')/xmly_speed_cookie.split('||')/g" /xmly_speed/xmly_speed.py

COPY ./cronlist.sh /cron_list/

# 企鹅默认仓库地址
ENV SYNCURL https://raw.githubusercontent.com/ziye12/JavaScript/master/qqread.js
# 生效的定时任务文件名
ENV CRONTAB_LIST_FILE cronlist.sh

RUN crontab /cron_list/cronlist.sh

CMD ["node"]
