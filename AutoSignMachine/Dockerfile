FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" 

ENV UPDATE_AT_STARTUP=True \
        REPO_URL=git@github.com:ioToast/AutoSignMachine.git

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata git moreutils nodejs openssh-client npm jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && mkdir -p /root/.ssh

#此处./AutoSignMachine/id_rsa文件由GitHub Action生成
COPY ./AutoSignMachine/id_rsa /root/.ssh/id_rsa

RUN set -ex \
        && cat /root/.ssh/id_rsa \
        && chmod 600 /root/.ssh/id_rsa \
        && ssh-keyscan github.com > /root/.ssh/known_hosts

RUN git clone $REPO_URL /AutoSignMachine

# github action 构建
COPY ./AutoSignMachine/docker_entrypoint.sh /usr/local/bin/
COPY ./AutoSignMachine/task_shell_script.sh /AutoSignMachine/
# 本地构建
# COPY ./docker_entrypoint.sh /usr/local/bin/
# COPY ./task_shell_script.sh /AutoSignMachine/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh 


WORKDIR /AutoSignMachine

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
