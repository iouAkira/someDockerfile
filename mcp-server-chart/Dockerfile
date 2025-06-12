# 使用一个轻量级的官方 Node.js 镜像作为基础
FROM node:20-alpine

# 安装 @antv/mcp-server-chart 包
RUN npm install -g @antv/mcp-server-chart

# 暴露服务运行的端口
EXPOSE 1122

# 设置入口点命令，固定 transport 参数
ENTRYPOINT ["mcp-server-chart", "--transport"]

# 设置默认参数为 SSE 模式
CMD ["streamable"]
