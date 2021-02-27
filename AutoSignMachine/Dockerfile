FROM alpine
LABEL AUTHOR="Akira <e.akimoto.akira@gmail.com>" 

ENV UPDATE_AT_STARTUP=True \
        REPO_URL=git@github.com:ioToast/AutoSignMachine.git \ 
        GIT_SSH_KEY="-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW\nQyNTUxOQAAACCvw98+8BVZXUtKhaa36MXonzHHwn21TAqfSDlxNHJ8kwAAAKBWKOpZVijq\nWQAAAAtzc2gtZWQyNTUxOQAAACCvw98+8BVZXUtKhaa36MXonzHHwn21TAqfSDlxNHJ8kw\nAAAEAeaFin+wvDfSqSLYffhHc6prPGWYiNc7wV14BIJUdtYa/D3z7wFVldS0qFprfoxeif\nMcfCfbVMCp9IOXE0cnyTAAAAG2UuYWtpbW90by5ha2lyYUBvdXRsb29rLmNvbQEC\n-----END OPENSSH PRIVATE KEY-----"

RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata git moreutils nodejs openssh-client npm jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone
        && mkdir -p /root/.ssh \
        && echo -e $GIT_SSH_KEY > /root/.ssh/id_rsa \
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
