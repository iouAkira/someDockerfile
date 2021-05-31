#!/bin/sh

function initNodeEnv() {
  echo "安装执行脚本需要的nodejs环境及依赖"
  apk add --update nodejs moreutils npm curl jq
}
function syncRepo() {
  echo "设定远程仓库地址..."
  cd /scripts
  git remote set-url origin "$REPO_URL"
  git reset --hard
  echo "git pull拉取最新代码..."
  git -C /scripts pull --rebase
}
#获取配置的自定义参数,如果有为
if [ "$1" ]; then
  initNodeEnv
  if [ $? -ne 0 ]; then
    echo "安装执行脚本需要的nodejs环境及依赖出错❌，exit，restart"
    exit 1
  else
    echo "安装执行脚本需要的nodejs环境及依赖成功✅"
  fi
  run_cmd=$1
fi

[ -f /scripts/package.json ] && before_package_json=$(cat /scripts/package.json)

if [ -f $ID_RSA_PATH ]; then
  cp -rf $ID_RSA_PATH /root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

syncRepo
if [ $? -ne 0 ]; then
  echo "更新仓库代码出错❌，跳过"
else
  echo "更新仓库代码成功✅"
fi

if [ ! -d /scripts/node_modules ]; then
  echo "容器首次启动，执行npm install..."
  npm install --loglevel error --prefix /scripts
  if [ $? -ne 0 ]; then
    echo "npm首次启动安装依赖失败❌，exit，restart"
    exit 1
  else
    echo "npm首次启动安装依赖成功✅"
  fi
else
  if [[ "${before_package_json}" != "$(cat /scripts/package.json)" ]]; then
    echo "package.json有更新，执行npm install..."
    npm install --loglevel error --prefix /scripts
    if [ $? -ne 0 ]; then
      echo "npackage.json有更新，执行安装依赖失败❌，跳过"
      exit 1
    else
      echo "npackage.json有更新，执行安装依赖成功✅"
    fi
  else
    echo "package.json无变化，跳过npm install..."
  fi
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
