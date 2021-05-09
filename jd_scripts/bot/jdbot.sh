#!/bin/sh
set -e

JDS_DIR='/jds/jd_scripts'
BASE_DIR='/scripts'

# bot更新了新功能的话只需要重启容器就完成更新
function initBotPythonEnv() {
  echo "开始安装运行jdbot需要的python环境及依赖..."
  # py3-multidict py3-yarl 为aiogram需要依赖的pip，但是alpine配置gcc编译环境才能安装这两个包，有点浪费，所以直接使用alpine提供的版本
  # 注释一下省的自己忘了为什么 #gcc musl-dev 为
  apk add --update python3-dev py3-pip py3-pillow py3-numpy py3-multidict py3-yarl py3-cryptography gcc musl-dev
  echo "开始安装jdbot依赖..."
  cd "$JDS_DIR/bot"
  pip3 install --upgrade pip
  pip3 install -r requirements.txt
  python3 setup.py install
}

function start() {
  if type python3 >/dev/null 2>&1; then
    echo "jdbot所需环境已经存在，跳过安装依赖环境"
    if [[ "$(pip3 list | grep numpy)" == "" || "$(pip3 list | grep pillow)" == "" ]]; then
      cd "$BASE_DIR"
      apk add --update python3-dev py3-pip py3-pillow py3-numpy py3-multidict py3-yarl py3-cryptography gcc musl-dev
      pip3 install --upgrade pip
      pip3 install -r requirements.txt
    fi
  else
    echo "jdbot所需环境不存在，初始化所需python3及依赖环境"
    initBotPythonEnv
  fi
  echo '更新bot代码...'
  cd "$JDS_DIR/bot"
  python3 setup.py install

  AS=$(ps -ef | grep "jdbot.py" | grep -v "grep" | awk '{print $1}')
  if [ -n "$AS" ]; then
    echo "jd bot 已经启动，跳过..."
  else
    echo "启动jd bot..."
    echo " " >"$BASE_DIR/logs/jdbot.log"
    jdbot.py >>"$BASE_DIR/logs/jdbot.log" 2>&1 &
    echo "jd bot已启动..."
  fi
}

function stop() {
  AP=$(ps -ef | grep "jdbot.py" | grep -v "grep" | awk '{print $1}')
  if [ -n "$AP" ]; then
    echo "停止jd bot..."
    kill -9 $(ps -ef | grep "jdbot.py" | grep -v "grep" | awk '{print $1}')
  fi
  echo "进程已停止..."
}
function restart() {
  echo "准备重启..."
  stop
  start
  echo "重启已完成..."
}
function restart_bot() {
  echo "准备重启自己..."
  stop
  start
  echo "重启自己完成..."
  curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=jd bot重启已完成..." >>/dev/null
}
if [ $1 ]; then
  opt=$1
  $opt
else
  start
fi
