FROM alpine
MAINTAINER Akyakya <e.akimoto.akira@gmail.com>

ENV LANG C.UTF-8
ENV TZ=Asia/Shanghai
ENV FRP_VERSION 0.31.2

RUN apk add --update --no-cache curl tzdata

RUN curl -L -o frps.tar.gz https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz \
    && tar -xf frps.tar.gz \
    && mv frp_${FRP_VERSION}_linux_amd64/ /frps \
    && rm -rf frps.tar.gz /var/cache/apk/*

WORKDIR /frps

ENTRYPOINT ["./frps"]

CMD ["-c","/frps/frps.ini"]
