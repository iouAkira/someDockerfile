#!/bin/sh
# 这是一个符合 POSIX 标准的 shell 脚本，用于启动应用

# 如果任何命令失败，立即退出脚本
set -e

# 将脚本接收到的所有参数（来自 Dockerfile 的 CMD 或 docker run 的命令）
# 设置为位置参数，以便后续添加新的参数
set -- "$@"

# 检查环境变量，如果设置了，就将其作为命令行参数追加
# 这样就可以在 `docker run` 时通过 -e 灵活配置数据库连接
if [ -n "$DB_HOST" ]; then
  set -- "$@" --db-host "$DB_HOST"
fi
if [ -n "$DB_PORT" ]; then
  set -- "$@" --db-port "$DB_PORT"
fi
if [ -n "$DB_USER" ]; then
  set -- "$@" --db-user "$DB_USER"
fi
if [ -n "$DB_PASSWORD" ]; then
  set -- "$@" --db-password "$DB_PASSWORD"
fi
if [ -n "$DB_DATABASE" ]; then
  set -- "$@" --db-database "$DB_DATABASE"
fi

# 使用 exec 执行主命令，它会用 doris-mcp-server 进程替换掉 shell 进程。
# 这是最佳实践，能确保容器正确接收和处理来自 Docker 的信号（如 SIGTERM 用于 docker stop）
exec doris-mcp-server "$@"