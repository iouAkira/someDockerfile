FROM alpine as builder
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

RUN set -ex \
    && apk update && apk upgrade \
    && apk add --no-cache udns ca-certificates py-pygments \
    && apk add --virtual .build-deps \
    git \
    nodejs \
    yarn \
    go \
    musl-dev

RUN set -ex \
    && git clone --recurse-submodules https://github.com/cloudreve/Cloudreve.git

WORKDIR /Cloudreve/assets

RUN set -ex \
    && yarn install \
    && yarn run build

WORKDIR /Cloudreve

RUN set -ex \
    && git pull \
    && export COMMIT_SHA=$(git rev-parse --short HEAD) \
    && export VERSION=$(git describe --tags) \
    && (cd && go get github.com/rakyll/statik) \
    && statik -src=assets/build/ -include=*.html,*.js,*.json,*.css,*.png,*.svg,*.ico -f \
    && go install -ldflags "-X 'Cloudreve/pkg/conf.BackendVersion=${VERSION}' \
    -X 'Cloudreve/pkg/conf.LastCommit=${COMMIT_SHA}'\
    -w -s"

FROM alpine
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

ENV LANG C.UTF-8

COPY --from=builder /go/bin/cloudreve /cloudreve/cloudreve

RUN set -ex \
    && apk update && apk upgrade\
    && apk add --no-cache tzdata bash \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && ln -s /cloudreve/cloudreve /usr/bin/cloudreve

EXPOSE 5212/tcp

VOLUME /data

ENTRYPOINT ["cloudreve"]
