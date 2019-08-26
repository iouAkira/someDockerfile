FROM golang:alpine
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates py-pygments \
        && apk add py-pygments --virtual .build-deps \
                git \
                tzdata \
                iproute2 \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

RUN set -ex \
        && cd \
        && mkdir $HOME/src \
        && cd $HOME/src \
        && git clone https://github.com/gohugoio/hugo.git \
        && cd hugo \
        && go install \
        && rm -rf $HOME/src/hugo/

EXPOSE 1313

WORKDIR /hugosite

ENTRYPOINT ["hugo"]

CMD ["server"]