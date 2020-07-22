FROM golang:latest as builder
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache ca-certificates \
        && apk add git bash wget
WORKDIR /go/src/v2ray.com/core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=docker-fly abpathtgz=/tmp/v2ray.tgz


FROM alpine
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8
RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates tzdata\
        && mkdir -p /usr/bin/v2ray && \
ENV TZ=Asia/Shanghai

COPY --from=builder /tmp/v2ray.tgz /tmp
RUN set -ex \
        && tar xvfz /tmp/v2ray.tgz -C /usr/bin/v2ray \
        && rm -rf /tmp/v2ray.tgz

ENV PATH /usr/bin/v2ray:$PATH

CMD ["v2ray", "-config=/etc/v2ray/config.json"]