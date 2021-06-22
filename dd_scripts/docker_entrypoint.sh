#!/bin/sh

if [ "$1" ]; then
  if [ "${APK_REPO}" ]; then
    #清华源 mirrors.tuna.tsinghua.edu.cn
    #阿里源 mirrors.aliyun.com
    #中科大 mirrors.ustc.edu.cn
    sed -i "s/dl-cdn.alpinelinux.org/${APK_REPO}/g" /etc/apk/repositories
  fi
  run_cmd=$1
fi
#任务脚本shell仓库
cd /jds
git pull origin master --rebase

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh /jds/dd_scripts/shell_default_script.sh "$run_cmd"
if [ $? -ne 0 ]; then
  echo "定时任务任务shell脚本执行失败❌，exit，restart"
  exit 1
else
  echo "定时任务任务shell脚本执行成功✅"
fi
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ "$run_cmd" ]; then
  if [[ -n "$TG_BOT_TOKEN" && -n "$TG_USER_ID" && -z "$DISABLE_BOT_COMMAND" && -z "$TG_API_HOST" && -f /usr/local/bin/ddBot ]]; then
    echo "后台启动ddBot程序..."
    cd /scripts
    ddBot >>"$LOGS_DIR/dd_bot.log" 2>&1 &
  fi
  echo "启动crontab定时任务主进程..."
  crond -f
else
  echo "默认定时任务执行结束。"
fi
