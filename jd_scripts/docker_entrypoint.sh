#!/bin/sh
set -e

#获取配置的自定义参数
if [ $1 ]; then
    run_cmd=$1
fi


hostsPath="/etc/hosts"

if [ $HOSTS_GITEE ]; then
    if [ $(grep -c "gitee.com" $hostsPath) -eq '0' ]; then
        echo $HOSTS_GITEE >>$hostsPath
    else
        sed -i "/gitee.com/d" $hostsPath
        echo $HOSTS_GITEE >>$hostsPath
    fi
fi

if [ $HOSTS_GITHUB ]; then
    if [ $(grep -c "github.com" $hostsPath) -eq '0' ]; then
        echo $HOSTS_GITHUB >>$hostsPath
    else
        sed -i "/github.com/d" $hostsPath
        echo $HOSTS_GITHUB >>$hostsPath
    fi
fi

if [ $HOSTS_GITHUB_RAW ]; then
    if [ $(grep -c "raw.githubusercontent.com" $hostsPath) -eq '0' ]; then
        echo $HOSTS_GITHUB_RAW >>$hostsPath
    else
        sed -i "/raw.githubusercontent.com/d" $hostsPath
        echo $HOSTS_GITHUB_RAW >>$hostsPath
    fi
fi

echo "设定远程仓库地址..."
cd /scripts
git remote set-url origin $REPO_URL
git reset --hard
echo "git pull拉取最新代码..."
git -C /scripts pull
echo "npm install 安装最新依赖"
npm install --prefix /scripts

#任务脚本shell仓库
cd /jds
git pull origin master

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh -x /jds/jd_scripts/task_shell_script.sh
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ $run_cmd ]; then
    if [ $run_cmd == 'jd_bot' ]; then
        echo "Start crontab task main process..."
        echo "启动crondtab定时任务主进程..."
        crond
        echo "Start crontab task main process..."
        echo "启动jd_bot..."
        jd_bot
    fi
    if [ $run_cmd == 'crond' ]; then
        echo "Start crontab task main process..."
        echo "启动crondtab定时任务主进程..."
        crond -f
    fi
else
    echo "默认定时任务执行结束。"
fi
