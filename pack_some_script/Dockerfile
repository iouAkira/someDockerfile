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
        #替换喜马拉雅脚本相关内容以兼容环境变量配置
        && sed -i 's/BARK/BARK_PUSH/g' /xmly_speed/xmly_speed.py \
        && sed -i 's/SCKEY/PUSH_KEY/g' /xmly_speed/xmly_speed.py \
        && sed -i 's/if\ XMLY_ACCUMULATE_TIME/if\ os.environ["XMLY_ACCUMULATE_TIME"]/g' /xmly_speed/xmly_speed.py \
        && sed -i "s/\(xmly_speed_cookie\.split('\)\\\n/\1\|/g" /xmly_speed/xmly_speed.py \
        && sed -i 's/cookiesList.append(line)/cookiesList.append(line.replace(" ",""))/g' /xmly_speed/xmly_speed.py \
        #替换企鹅阅读脚本相关内容以兼容环境变量配置
        && sed -i 's/COOKIE_QEYD.split("\\n")/COOKIE_QEYD.split("|")/g' /qeyd/Scripts/qeyd_replace.js

COPY ./cronlist.sh /cron_list/

# 喜马拉雅极速配置-默认0关闭刷时长
ENV XMLY_ACCUMULATE_TIME 0
# 企鹅阅读必须配置-默认仓库地址
ENV SYNCURL https://raw.githubusercontent.com/ziye12/JavaScript/master/qqread.js

RUN crontab /cron_list/cronlist.sh

CMD ["node"]
