# -----------------------------------------------------------------------------
# Dockerfile to run doris-mcp-server
# -----------------------------------------------------------------------------

# Step 1: 使用官方的 Python 3.12 轻量级镜像作为基础
FROM python:3.12-slim

ARG APP_VERSION

# Step 2: 设置工作目录
# 容器内的所有后续操作都将在此目录下进行
WORKDIR /app

# Step 3: 安装 doris-mcp-server
# --no-cache-dir 减少镜像体积
# 升级 pip 是一个好习惯
# 升级 pip 是一个好习惯
RUN pip install --no-cache-dir --upgrade pip && \
    # 检查 APP_VERSION 是否被设置
    # 如果设置了，就安装指定版本；否则，安装最新版本
    if [ -n "$APP_VERSION" ]; then \
        echo "==> Installing doris-mcp-server version: $APP_VERSION" && \
        pip install --no-cache-dir doris-mcp-server==$APP_VERSION; \
    else \
        echo "==> APP_VERSION not set, installing latest version of doris-mcp-server" && \
        pip install --no-cache-dir doris-mcp-server; \
    fi


# Step 4: 复制并授权入口脚本
# 这个脚本将处理环境变量并启动服务
COPY ./doris-mcp-server/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Step 5: 声明容器将监听的端口
# 这主要用于文档目的，实际端口映射在 `docker run` 时指定
EXPOSE 3000

# Step 6: 设置入口点
# 容器启动时将执行这个脚本
ENTRYPOINT ["entrypoint.sh"]

# Step 7: 设置默认命令
# 如果 `docker run` 时未指定其他命令，则默认启动 HTTP 服务
# 这些参数会传递给 entrypoint.sh 脚本
CMD ["--transport", "http", "--host", "0.0.0.0", "--port", "3000"]