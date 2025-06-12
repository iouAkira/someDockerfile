# SomeDockerfile

这是一个包含多个自定义 Docker 镜像的 Dockerfile 文件集合，用于快速部署各种服务和工具。

## 项目结构

### 数据可视化
- `mcp-server-chart`: AntV MCP 图表服务，支持 SSE 和 Streamable 两种传输模式

### 自动化脚本
- `jd_scripts`: 京东自动化脚本
- `dd_scripts`: 签到脚本集合
- `AutoSignMachine`: 自动签到机器

### 网络服务
- `frp`: 内网穿透工具
- `cfddns.py`: Cloudflare DDNS 动态域名解析脚本
- `cloudreve`: 云存储服务

### 社交媒体和通讯
- `telegram-cli`: Telegram 命令行客户端
- `efb-v1` 和 `efb-v2`: Telegram 机器人框架
- `gclone-tg-bot`: Google Drive 克隆 Telegram 机器人

### 其他工具
- `unlockNeteaseMusic`: 网易云音乐解锁服务
- `valine-admin`: 评论系统管理工具
- `gd-utils`: Google Drive 实用工具集
- `hugo`: 静态网站生成器
- `doris-manager`: Doris 数据库管理工具

## 使用说明

每个目录下都包含相应的 Dockerfile 和使用说明，请参考具体目录下的文档。

### mcp-server-chart 使用示例

```bash
# 使用默认的 SSE 模式
docker run <image-name>

# 使用 Streamable 模式
docker run <image-name> streamable
```

## 更新日志

### 2024-03-xx
- 新增 mcp-server-chart 服务支持

## 待办

## 感谢
[![Powered by DartNode](https://dartnode.com/branding/DN-Open-Source-sm.png)](https://dartnode.com "Powered by DartNode - Free VPS for Open Source")
<a target="_blank" href="https://jb.gg/OpenSourceSupport"><img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.svg" style="border-radius: 5px;" width="10%">

## 许可
Copyright © 2019-present [@iouAkira](https://github.com/iouAkira). Licensed under [GPL](https://github.com/iouAkira/someDockerfile/blob/master/LICENSE) License.
