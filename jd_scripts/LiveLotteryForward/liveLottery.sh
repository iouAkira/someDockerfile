#!/bin/sh
set -e

cp /local_scripts/LiveLotteryForward/jd_live_lottery.js /scripts/

function start() {
  TA=$(ps -ef | grep "forwardUserBot.py" | grep -v "grep" | awk '{print $1}')
  TB=$(ps -ef | grep "drawLiveLottery.py" | grep -v "grep" | awk '{print $1}')

  if [ -n "$TA" ]; then
    echo "forward userBot已经启动，跳过..."
  else
    echo "启动forward userBot..."
    echo " " >/local_scripts/LiveLotteryForward/forwardUserBot.log
    python3 /local_scripts/LiveLotteryForward/forwardUserBot.py >>/local_scripts/LiveLotteryForward/forwardUserBot.log 2>&1 &
  fi

  if [ -n "$TB" ]; then
    echo "dreawLivelottery bot 已经启动，跳过..."
  else
    echo "启动dreawLivelottery bot..."
    echo " " >/local_scripts/LiveLotteryForward/drawLiveLottery.log
    python3 /local_scripts/LiveLotteryForward/drawLiveLottery.py >>/local_scripts/LiveLotteryForward/drawLiveLottery.log 2>&1 &
  fi
  echo "启动已完成..."
}
function stop() {
  PA=$(ps -ef | grep "forwardUserBot.py" | grep -v "grep" | awk '{print $1}')
  PB=$(ps -ef | grep "drawLiveLottery.py" | grep -v "grep" | awk '{print $1}')

  if [ -n "$PA" ]; then
    echo "停止forward userBot..."
    kill -9 $(ps -ef | grep "forwardUserBot.py" | grep -v "grep" | awk '{print $1}')
  fi
  if [ -n "$PB" ]; then
    echo "停止dreawLivelottery bot..."
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
