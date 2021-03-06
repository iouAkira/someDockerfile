#!/bin/sh
set -e

#获取配置的自定义参数
if [ $1 ]; then
	run_cmd=$1
	echo "配置仓库更新密钥"
	mkdir -p /root/.ssh
	echo -e ${CUST_SSH_KEY} >/root/.ssh/id_rsa
	chmod 600 /root/.ssh/id_rsa
	ssh-keyscan github.com >/root/.ssh/known_hosts
	echo "容器启动，拉取脚本仓库代码..."
	git clone ${CUST_REPO_URL} /AutoSignMachine
fi

if [ $TASK_SHELL_SCRIPT ]; then
	wget -O /AutoSignMachine/task_shell_script.sh $TASK_SHELL_SCRIPT
else
	cd /pss
	git pull origin master
	cp /pss/AutoSignMachine/task_shell_script.sh /AutoSignMachine/task_shell_script.sh
fi
echo "------------------------------------------------执行定时任务任务shell脚本------------------------------------------------"
sh /AutoSignMachine/task_shell_script.sh $run_cmd
echo "--------------------------------------------------默认定时任务执行完成---------------------------------------------------"

if [ $run_cmd ]; then
	echo "启动crondtab定时任务主进程..."
	crond -f
else
	echo "默认定时任务执行结束。"
fi
