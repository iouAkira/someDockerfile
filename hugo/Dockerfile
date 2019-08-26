FROM alpine as builder
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates py-pygments \
        && apk add --virtual .build-deps \
                git \
                go \
                musl-dev

RUN set -ex \
        && cd \
        && mkdir $HOME/src \
        && cd $HOME/src \
        && git clone https://github.com/gohugoio/hugo.git \
        && cd hugo \
        && go install \
        && mv $HOME/go/bin/hugo /

FROM alpine
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates py-pygments tzdata \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone

COPY --from=builder /hugo /usr/local/bin/hugo

EXPOSE 1313

WORKDIR /site

ENTRYPOINT ["hugo"]

CMD ["server"]
