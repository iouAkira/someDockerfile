FROM alpine as goBuild

LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add --no-cache go

COPY ./dd_api/GolangCode.tar.gz /

RUN set -ex \
    && cd / \
    && tar -zxvf GolangCode.tar.gz \
    && rm -rf /GolangCode.tar.gz \
    && go version \
    && cd /GolangCode/ddapi \
    && CGO_ENABLED=1 go build -o ddapi api.go

FROM alpine:latest
LABEL AUTHOR="iouAkira <ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==>"

RUN set -ex \
    && apk update \
    && apk add --no-cache tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

COPY --from=goBuild /GolangCode/ddapi/ddapi /usr/local/bin/ddapi

RUN set -ex \
    && mkdir /data \
    && chmod +x /usr/local/bin/ddapi 

WORKDIR /data

ENTRYPOINT ["ddapi"]
