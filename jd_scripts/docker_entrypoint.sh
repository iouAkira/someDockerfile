#!/bin/sh
set -e

#获取配置的自定义参数,如果有为
if [ $1 ]; then
    run_cmd=$1
    echo -e $GIT_SSH_KEY >/root/.ssh/id_rsa
    if [ $GIT_PULL == 'true' ]; then
        echo "设定远程仓库地址..."
        cd /scripts
        git remote set-url origin $REPO_URL
        git reset --hard
        echo "git pull拉取最新代码..."
        git -C /scripts pull --rebase
        echo "npm install 安装最新依赖"
        npm install --loglevel error --prefix /scripts
    fi
else
    echo "设定远程仓库地址..."
    cd /scripts
    git remote set-url origin $REPO_URL
    git reset --hard
    echo "git pull拉取最新代码..."
    git -C /scripts pull --rebase
    echo "npm install 安装最新依赖"
    npm install --loglevel error --prefix /scripts
fi

#任务脚本shell仓库
cd /jds
git pull origin master --rebase

#将默认的互助码提交消息生成配置文件放入logs文件夹
if [ ! -f $GEN_CODE_CONF ]; then
    echo "将默认的互助码提交消息生成配置文件放入logs文件夹"
    cp /jds/jd_scripts/gen_code_conf.list $GEN_CODE_CONF
fi

echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh /jds/jd_scripts/task_shell_script.sh
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
