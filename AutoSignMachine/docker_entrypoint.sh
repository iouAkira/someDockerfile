#!/bin/sh
set -e

#获取配置的自定义参数
if [ $1 ]; then
    run_cmd=$1
fi

echo "更新仓库代码..."
cd /AutoSignMachine
git reset --hard
echo "git pull拉取最新代码..."
git -C /AutoSignMachine pull --rebase
git checkout dev
echo "npm install 安装最新依赖"
npm install --loglevel error --prefix /AutoSignMachine

if [ $TASK_SHELL_SCRIPT ]; then
    wget -O /AutoSignMachine/task_shell_script.sh $TASK_SHELL_SCRIPT
else
    wget -O /AutoSignMachine/task_shell_script.sh https://raw.githubusercontent.com/iouAkira/someDockerfile/master/AutoSignMachine/task_shell_script.sh
fi
echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh /AutoSignMachine/task_shell_script.sh
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ $run_cmd ]; then
    echo "启动crondtab定时任务主进程..."
    crond -f
else
    echo "默认定时任务执行结束。"
fi
