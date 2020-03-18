FROM nondanee/unblockneteasemusic
MAINTAINER Akira <e.akimoto.akira@gmail.com>

ENV VERSION v0.7.0

RUN wget https://github.com/nadoo/glider/releases/download/${VERSION}/glider-${VERSION}-linux-amd64.tar.gz \
    && tar zxvf glider-${VERSION}-linux-amd64.tar.gz \
    && mv glider-${VERSION}-linux-amd64/* . \
    && chmod 777 glider \
    && rm -rf glider-${VERSION}-linux-amd64*

EXPOSE 8080 8081 8082

ENTRYPOINT [""]

CMD ["node","app.js"]
