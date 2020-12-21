#!/bin/sh
set -e

echo "##############################################################################"
echo "获取最新定时任务相关代码"
cd /pss
git pull origin master
cd pack_some_script
cp crontab_list.sh default_task.sh scripts_update.sh send_notify.py /pss
echo "获取最新定时任务相关代码完成"
echo "##############################################################################"

echo "Initialize a scheduled task for the first time..."
echo "执行脚本更新相关任务..."
sh -x /pss/default_task.sh
echo "Initialization complete..."
echo "执行脚本更新相关任务完成..."