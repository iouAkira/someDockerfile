#!/bin/sh
set -e

function start() {
  stop
  echo "启动userBot..."
  echo " " > /local_scripts/LiveLotteryForward/forwardUserBot.log
  python3 /local_scripts/LiveLotteryForward/forwardUserBot.py >>/local_scripts/LiveLotteryForward/forwardUserBot.log 2>&1 &
  echo "启动exec node bot..."
  echo " " > /local_scripts/LiveLotteryForward/drawLiveLottery.log
  python3 /local_scripts/LiveLotteryForward/drawLiveLottery.py >>/local_scripts/LiveLotteryForward/drawLiveLottery.log 2>&1 &
}
function stop() {
  A=$(ps -ef | grep "forwardUserBot.py" | grep -v "grep" | awk '{print $1}')
  if [ -n "$A" ]; then
    echo "停止userBot..."
    kill -9 $(ps -ef | grep "forwardUserBot.py" | grep -v "grep" | awk '{print $1}')
  fi
  B=$(ps -ef | grep "drawLiveLottery.py" | grep -v "grep" | awk '{print $1}')
  if [ -n "$B" ]; then
    echo "停止exec node bot..."
    kill -9 $(ps -ef | grep "drawLiveLottery.py" | grep -v "grep" | awk '{print $1}')
  fi
  echo "进程已停止..."
}
function restart() {
  echo "准备重启..."
  stop
  start
  echo "重启已完成..."
}
if [ $1 ]; then
  opt=$1
  $opt
else
  restart
fi
