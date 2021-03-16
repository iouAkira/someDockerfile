#!/bin/sh
set -e

echo "增加一个命令组合spnode ，使用该命令spnode jd_xxxx.js 执行js脚本会读取cookies.conf里面的jd cokie账号来执行脚本"
(
cat <<EOF
#!/bin/sh
set -e

first=\$1
cmd=\$*
echo \${cmd/\$1/}
if [ \$1 == "conc" ]; then
    for job in \$(paste -d" " -s - <\$COOKIES_CONF); do
        { export JD_COOKIE=\$job && node \${cmd/\$1/} 
        }&
    done
elif [ -n "\$(echo \$first | sed -n "/^[0-9]\+\$/p")" ]; then
    echo "\$(echo \$first | sed -n "/^[0-9]\+\$/p")"
    { export JD_COOKIE=\$(sed -n "\${first}p" \$COOKIES_CONF) && node \${cmd/\$1/}
    }&
elif [ -n "\$(cat \$COOKIES_CONF  | grep "pt_pin=\$first")" ];then
    echo "\$(cat \$COOKIES_CONF  | grep "pt_pin=\$first")"
    { export JD_COOKIE=\$(cat \$COOKIES_CONF | grep "pt_pin=\$first") && node \${cmd/\$1/}
    }&
else
    { export JD_COOKIE=\$(cat \$COOKIES_CONF | paste -s -d '&') && node \$*
    }&
fi
EOF
) > /usr/local/bin/spnode

chmod +x /usr/local/bin/spnode

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 ${defaultListFile}"
if [ $CUSTOM_LIST_FILE ]; then
    customListFile="/scripts/docker/$CUSTOM_LIST_FILE"
    echo "自定义定时任务文件路径为 ${customListFile}"
fi
mergedListFile="/scripts/docker/merged_list_file.sh"
echo "合并后定时任务文件路径为 ${mergedListFile}"

echo "第3步将默认定时任务列表添加到并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步判断是否存在自定义任务任务列表并追加..."
if [ $CUSTOM_LIST_FILE ]; then
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ $CUSTOM_LIST_MERGE_TYPE == "overwrite" ]; then
            echo "配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
            cat $customListFile >$mergedListFile
        else
            echo "配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
        fi
    else
        echo "配置的自定义任务文件：$CUSTOM_LIST_FILE未找到，使用默认配置$DEFAULT_LIST_FILE..."
    fi
else
    echo "当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE ..."
fi

echo "第3步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "default_task.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo -e >>$mergedListFile
    echo "21 */1 * * * sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
else
    sed -i "/default_task.sh/d" $mergedListFile
    echo "#脚本追加默认定时任务" >>$mergedListFile
    echo "21 */1 * * * sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
fi

echo "第5步判断是否配置了随即延迟参数..."
if [ $RANDOM_DELAY_MAX ]; then
    if [ $RANDOM_DELAY_MAX -ge 1 ]; then
        echo "已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
        sed -i "/\(jd_xtg.js\|jd_bean_sign.js\|jd_blueCoin.js\|jd_5g.js\|jd_818.js\|jd_newYearMoney.js\|jd_newYearMoney_lottery.js\|jd_joy_reward.js\|jd_joy_steal.js\|jd_joy_feedPets.js\|jd_car_exchange.js\)/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $mergedListFile
    fi
else
    echo "未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "第6步判断是否配置自定义shell执行脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下在自定义远程脚本。"
        wget -O /jds/shell_script_mod.sh $CUSTOM_SHELL_FILE
        echo "下载完成，开始执行..."
        echo "#远程自定义shell脚本追加定时任务" >>$mergedListFile
        sh /jds/shell_script_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f $CUSTOM_SHELL_FILE ]; then
            echo "自定义shell脚本为docker挂载脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "docker挂载的自定shell脚本，开始执行..."
            echo "#docker挂载自定义shell脚本追加定时任务" >>$mergedListFile
            sh $CUSTOM_SHELL_FILE
            echo "docker挂载的自定shell脚本，执行结束。"
        fi
    fi
fi

echo "第7步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

sed -i "/\(>&1 &\|> &1 &\)/!s/>&1/>\&1 \&/g" $mergedListFile

echo "第8步执行原仓库的附属脚本proc_file.sh"
sh /scripts/docker/proc_file.sh

echo "替换node使用spnode执行任务"
sed -i "s/node/spnode/g" $mergedListFile
sed -i "/\(jd_xtg.js\|jd_bean_change.js\)/s/spnode/spnode conc/g" $mergedListFile

echo "第9步加载最新的定时任务文件..."
crontab $mergedListFile
# cp /local_scripts/cookies*.sh  /root/
# source /root/cookies*.sh

echo "第10步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /jds/jd_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh

if [ $GEN_CODE_CONF ]; then
  cp /jds/jd_scripts/gen_code_conf.list $GEN_CODE_CONF
fi 

echo "附加功能1，京东直播间抽奖监控"
if [ -d '/local_scripts/LiveLotteryForward/' ];then
  cd /local_scripts/LiveLotteryForward/
  pip3 install -r requirements.txt
  sh liveLottery.sh start
fi

echo "附加功能2，cookie写入文件，为jd_bot扫码获自动取cookies服务"
if [ 0"$JD_COOKIE" = "0" ]; then
    if [ -f "$COOKIES_CONF" ];then
        echo '' > $COOKIES_CONF
        echo "未配置JD_COOKIE环境变量，$COOKIES_CONF文件已生成,请将cookies写入$COOKIES_CONF文件，格式每个Cookie一行"
    fi
else
    if [ -f "$COOKIES_CONF" ];then
        echo "cookies.conf文件已经存在跳过,如果需要更新cookie请修改$COOKIES_CONF文件内容"
    else
        echo "环境变量 cookies写入$COOKIES_CONF文件,如果需要更新cookie请修改cookies.conf文件内容"
        echo $JD_COOKIE | sed "s/\( &\|&\)/\\n/g" > $COOKIES_CONF
    fi
fi

# echo "第11步打包脚本文件到/scripts/logs/scripts.tar.gz"
# apk add tar
# tar -zcvf /scripts/logs/scripts.tar.gz --exclude=scripts/node_modules --exclude=scripts/logs/*.log  --exclude=scripts/logs/*.gz /scripts

# 附加京喜工厂参团
sed -i "s/https:\/\/gitee.com\/shylocks\/updateTeam\/raw\/main\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/raw.githubusercontent.com\/LXK9301\/updateTeam\/master\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/gitee.com\/lxk0301\/updateTeam\/raw\/master\/shareCodes\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/\(.*\/\/.*joinLeaderTuan.*\)/   await joinLeaderTuan();/g" /scripts/jd_dreamFactory.js
sed -i "s/6S9y4sJUfA2vPQP6TLdVIQ==/MUdRsCXI13_DDYMcnD8v7g==/g" /scripts/jd_dreamFactory.js
 
