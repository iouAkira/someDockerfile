FROM nondanee/unblockneteasemusic
MAINTAINER Akira <e.akimoto.akira@gmail.com>

RUN wget https://github.com/nadoo/glider/releases/download/v0.7.0/glider-v0.7.0-linux-amd64.tar.gz \
    && tar zxvf glider-v0.7.0-linux-amd64.tar.gz \
    && mv glider-v0.7.0-linux-amd64/* . \
    && chmod 777 glider \
    && rm -rf glider-v0.7.0-linux-amd64*

EXPOSE 8080 8081 8082

ENTRYPOINT [""]

CMD ["node","app.js"]
