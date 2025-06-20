# 使用 Node.js 官方镜像作为基础镜像
FROM node:18-alpine

# 安装构建依赖和字体支持
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    # 添加字体和语言支持
    fontconfig \
    ttf-dejavu \
    ttf-liberation \
    font-noto \
    font-noto-cjk \
    font-noto-emoji \
    # 添加中文支持
    icu-libs \
    icu-data-full \
    font-wqy-zenhei

# 设置语言环境
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json
COPY ./gpt-vis-ssr/package*.json ./
COPY ./gpt-vis-ssr/index.js ./
# 安装依赖
RUN npm install

# 暴露端口（根据你的应用需要调整）
EXPOSE 3000

# 启动应用
CMD ["npm", "start"]