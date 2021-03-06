FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" 

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata git moreutils nodejs openssh-client npm jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && mkdir -p /root/.ssh

# 创建工作目录
RUN mkdir /AutoSignMachine \
        && mkdir /logs \
        && mkdir /pss \
        && cd  /pss \
        && git init \
        && git remote add -f origin https://github.com/iouAkira/someDockerfile.git \
        && git config core.sparsecheckout true \
        && echo AutoSignMachine/* >> /pss/.git/info/sparse-checkout \
        && git pull origin master
        
# github action 构建
COPY ./AutoSignMachine/docker_entrypoint.sh /usr/local/bin/
# 本地构建
# COPY ./docker_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh 

WORKDIR /AutoSignMachine

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
