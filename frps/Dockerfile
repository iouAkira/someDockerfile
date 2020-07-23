FROM alpine
MAINTAINER Akyakya <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai
ENV FRP_VERSION 0.33.0

RUN apk add --update --no-cache curl tzdata

RUN curl -L -o frp.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz \
    && tar -xf frp.tar.gz \
    && mv frp_${FRP_VERSION}_linux_amd64/ /frp \
    && rm -rf frp.tar.gz /var/cache/apk/*

WORKDIR /frp

CMD ["./frps","-c","/frp/frps.ini"]
