FROM centos:7 AS build

# 工作目录
# COPY 可以替换为wget -o
# COPY ./selectdb-doris-2.0.4-b01-bin-x64.tar.gz /opt/software/
# COPY ./doris-manager-23.11.3-x64-bin.tar.gz /opt/software/
# COPY ./apache-doris-2.0.4-bin-x64.tar.gz /opt/software/

RUN yum update -y \
    && yum install -y wget

WORKDIR /opt/software/
RUN wget -O /opt/software/selectdb-doris-2.0.4-b01-bin-x64.tar.gz -c https://doris-build-1308700295.cos.ap-beijing.myqcloud.com/enterprise-doris-release-output/selectdb-doris-2.0.4-b01-bin-x64.tar.gz
RUN wget -O /opt/software/doris-manager-23.11.3-x64-bin.tar.gz -c https://selectdb-doris-1308700295.cos.ap-beijing.myqcloud.com/doris-manager/release/23.11.3/doris-manager-23.11.3-x64-bin.tar.gz
RUN wget -O /opt/software/apache-doris-2.0.4-bin-x64.tar.gz -c https://apache-doris-releases.oss-accelerate.aliyuncs.com/apache-doris-2.0.4-bin-x64.tar.gz

RUN mkdir doris-manager \
    && mkdir selectdb-core \
    && mkdir apache-doris \
    && tar -zxvf apache-doris-2.0.4-bin-x64.tar.gz -C ./apache-doris --strip-components 1 \
    && tar -zxvf doris-manager-23.11.3-x64-bin.tar.gz -C ./doris-manager --strip-components 1 \
    && tar -zxvf selectdb-doris-2.0.4-b01-bin-x64.tar.gz -C ./selectdb-core --strip-components 1 \
    && ls -l \
    && mv -f ./selectdb-core/webui/ ./doris-manager

FROM centos:7

WORKDIR /opt/app/
# 文件复制
COPY --from=build /opt/software/doris-manager-23.11.3-x64-bin.tar.gz /opt/software/
# COPY --from=build /opt/software/apache-doris-2.0.4-bin-x64.tar.gz /opt/software/
COPY --from=build /opt/software/selectdb-doris-2.0.4-b01-bin-x64.tar.gz /opt/software/
# 文件夹复制
COPY --from=build /opt/software/doris-manager /opt/app/doris-manager

# 镜像启动命令脚本
COPY ./doris-manager/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN yum update -y \
    && yum install -y cronie \
    && chmod +x /usr/local/bin/entrypoint.sh

# PORT
EXPOSE 8004
EXPOSE 8010

ENTRYPOINT ["entrypoint.sh"]

CMD ["keep-run"]
