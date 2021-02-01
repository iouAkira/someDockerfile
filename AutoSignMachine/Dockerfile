FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" 

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata \
        git \
        moreutils \
        nodejs \
        npm \
        jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN git clone https://github.com/lunnlew/AutoSignMachine.git /AutoSignMachine 

# github action 构建
COPY ./AutoSignMachine/docker_entrypoint.sh /usr/local/bin/
COPY ./AutoSignMachine/task_shell_script.sh /AutoSignMachine/
# 本地构建
# COPY ./docker_entrypoint.sh /usr/local/bin/
# COPY ./task_shell_script.sh /AutoSignMachine/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh 

ENV UPDATE_AT_STARTUP=True

WORKDIR /AutoSignMachine

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
