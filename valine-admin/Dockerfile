FROM alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache git nodejs npm\
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://github.com/iouAkira/Valine-Admin.git /Valine-Admin \
        && cd /Valine-Admin \
        && npm audit fix \
        && npm install
COPY ./crontabList.txt  /Valine-Admin/crontabList.txt 

RUN crontab /Valine-Admin/crontabList.txt 

WORKDIR /Valine-Admin

CMD ["node", "server.js"]
