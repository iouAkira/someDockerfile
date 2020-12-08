#!/bin/sh
set -e

export LANG="zh_CN.UTF-8"

if [ $1 ]; then
    echo "Currently does not support specifying startup parameters"
    echo "Please delete the last command attached to `docker run` or the configured `command:` parameter in `docker-compose.yml`"
    # echo "暂时不支持指定启动参数，请删除 docker run时最后附带的命令 或者 docker-compose.yml中的配置的command:指令 "
fi

echo "Container start , Pull the latest code..."
# echo "容器启动，git 拉取最新代码..."
git -C /scripts pull
echo "##########################################"

if [ $CRONTAB_LIST_FILE == "crontab_list_ts.sh" ]; then
    echo "The currently used is the default crontab task file: ${CRONTAB_LIST_FILE} ..."
    # echo "当前使用的为默认定时任务文件 ${CRONTAB_LIST_FILE} ..."
else
    echo "The currently used is the custom crontab task file: ${CRONTAB_LIST_FILE} ..."
    # echo "当前使用的为自定义定时任务文件 ${CRONTAB_LIST_FILE} ..."
fi

echo "Load the currently used crontab task file: ${CRONTAB_LIST_FILE} ..."
# echo "加载最新的定时任务文件 ${CRONTAB_LIST_FILE} ..."
crontab /scripts/docker/$CRONTAB_LIST_FILE

echo "Start crontab task main process..."
# echo "启动crondtab定时任务主进程..."
crond -f
