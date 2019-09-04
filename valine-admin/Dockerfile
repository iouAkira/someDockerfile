FROM alpine
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache git nodejs npm\
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://github.com/DesertsP/Valine-Admin.git /Valine-Admin \
        && cd /Valine-Admin \
        && npm audit fix \
        && npm install 

WORKDIR /Valine-Admin

ENTRYPOINT ["node"]

#请使用command参数覆盖此CMD
CMD ["server.js"]