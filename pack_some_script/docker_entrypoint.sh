#!/bin/sh
set -e

if [ $1 ]; then
    echo "Currently does not support specifying startup parameters"
    echo "Please delete the last command attached to $(docker run) or the configured $(command:) parameter in $(docker-compose.yml)"
    echo "暂时不支持指定启动参数，请删除 docker run时最后附带的命令 或者 docker-compose.yml中的配置的command:指令 "
fi


echo "Container start"
echo "Get the latest task related code ..."
echo "获取最新定时任务相关代码"
echo "##############################################################################"
cd /pss
git pull origin master
cd pack_some_script
cp crontab_list.sh default_task.sh scripts_update.sh scripts_update.sh send_notify.py /pss
echo "##############################################################################"
echo "Get the latest task related code completion..."
echo "获取最新定时任务相关代码完成"


echo "Initialize a scheduled task for the first time..."
echo "首次初始化定时任务..."
echo "=============================================================================="
sh -x /pss/scripts_update.sh
echo "=============================================================================="
echo "Initialization complete..."
echo "初始化完成..."

echo "Start crontab task main process..."
echo "启动crondtab定时任务主进程..."
crond -f
