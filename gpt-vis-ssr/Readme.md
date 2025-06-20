# GPT-Vis-SSR
项目参考的 https://github.com/luler/gpt_vis_ssr.git 
一个基于 Docker 的服务器端渲染（SSR）服务，用于生成可视化图表。

## 功能

- **Docker 镜像支持**：提供预构建的 Docker 镜像，方便快速部署。
- **静态文件服务**：自动保存和提供渲染的图表图片。
- **中文支持**：内置中文字体和语言环境。

## 快速开始

### 1. 构建镜像

```bash
docker build -t gpt-vis-ssr .
```

### 2. 运行容器

```bash
docker run -p 3000:3000 -v $(pwd)/images:/app/public/images gpt-vis-ssr
```

或者使用 `docker-compose`：

```bash
docker-compose up -d
```

### 3. 访问服务

服务默认运行在 `http://localhost:3000`。

## API 使用

### 渲染图表

**端点**: `POST /render`

**请求体**:
```json
{
  "type": "图表类型",
  "data": {}
}
```

**响应**:
```json
{
  "url": "http://localhost:3000/images/渲染图片.png"
}
```

## 示例

```bash
curl -X POST http://localhost:3000/render \
  -H "Content-Type: application/json" \
  -d '{"type": "柱状图", "data": {"values": [1, 2, 3]}}'
```

## 环境变量

- `PORT`: 服务运行的端口（默认：`3000`）。
- `TZ`: 时区设置（默认：`Asia/Shanghai`）。

## 许可证

MIT