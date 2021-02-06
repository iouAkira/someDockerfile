FROM alpine
LABEL AUTHOR="iouAkira <e.akimoto.akira@gmail.com>" \
        VERSION=0.1.3 \
        UPDATE_CONTENT="akyakya/jd_script后续不提供使用咨询和帮助，仅为自己用，请尽快切换到 https://hub.docker.com/r/lxk0301/jd_scripts/tags?page=1&ordering=last_updated 镜像使用"

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        REPO_URL=https://gitee.com/lxk0301/jd_scripts.git
RUN set -ex \
        && apk update && apk upgrade\
        && apk add --no-cache tzdata  git  nodejs  moreutils  npm  python3-dev  py3-pip  py3-cryptography curl jq \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && echo "180.97.125.228 gitee.com" >> /etc/hosts 

RUN git clone ${REPO_URL} /scripts \
        && cd /scripts \
        && git checkout master \
        && mkdir logs \
        && npm install

RUN mkdir /jds \
        && cd  /jds \
        && git init \
        && git remote add -f origin https://github.com/iouAkira/someDockerfile.git \
        && git config core.sparsecheckout true \
        && echo jd_scripts/* >> /jds/.git/info/sparse-checkout \
        && git pull origin master \
        && cd /jds/jd_scripts/bot \
        && ls -a \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt \
        && python3 setup.py install

RUN cp /jds/jd_scripts/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
