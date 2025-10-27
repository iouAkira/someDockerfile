# 使用一个轻量级的官方 Node.js 镜像作为基础
FROM node:20-alpine

# 安装 @antv/mcp-server-chart 包
RUN npm install -g @antv/mcp-server-chart

# 暴露服务运行的端口
EXPOSE 1122

# ENTRYPOINT 保持不变
ENTRYPOINT ["mcp-server-chart"]

CMD ["--transport=streamable", "--host", "0.0.0.0"]
