FROM golang:latest as builder
MAINTAINER AKira <e.akimoto.akira@gmail.com>

RUN go get -u v2ray.com/core/...
RUN mkdir -p /usr/bin/v2ray/
RUN CGO_ENABLED=0 go build -o /usr/bin/v2ray/v2ray v2ray.com/core/main
RUN CGO_ENABLED=0 go build -o /usr/bin/v2ray/v2ctl v2ray.com/core/infra/control/main
RUN cp -r ${GOPATH}/src/v2ray.com/core/release/config/* /usr/bin/v2ray/


FROM alpine
MAINTAINER AKira <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8
RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache udns ca-certificates tzdata
ENV TZ=Asia/Shanghai

RUN rm -rf /var/cache/apk/*

RUN mkdir /usr/bin/v2ray/
RUN mkdir /etc/v2ray/
RUN mkdir /var/log/v2ray/

COPY --from=builder /usr/bin/v2ray  /usr/bin/v2ray

ENV PATH /usr/bin/v2ray/:$PATH

CMD ["/usr/bin/v2ray/v2ray", "-config=/etc/v2ray/config.json"]