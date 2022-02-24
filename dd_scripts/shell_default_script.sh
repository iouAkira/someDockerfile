#!/bin/sh

# CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ~/someDockerfile/dd_scripts/bot/ddBot-amd64 ddBot.go
# CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o ~/someDockerfile/dd_scripts/bot/ddBot-arm64 ddBot.go
# CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -o ~/someDockerfile/dd_scripts/bot/ddBot-arm ddBot.go

################################脚本仓库更新/初始化操作 start ################################

###为了使用env.sh里面配置的环境变量，放在最开始为了
if [ -d "/data" ]; then
  if [ -f "/data/env.sh" ]; then
    echo "检查道环境变量配置文件 /data/env.sh 存在，使用该文件内环境变量。"
    source "/data/env.sh"
  fi
  if [ -d "/data/logs" ]; then
    echo "/data/logs目录已存在，跳过创建。"
  else
    echo "/data/logs目录不存在，执行创建。"
    mkdir -p /data/logs
  fi
fi

SCRIPTS_REPO_BASE_DIR=/scripts
LOGS_DIR=/data/logs

###判断平台架构使用对应平台版本的ddBot
echo "目前只构建三个平台（and64,arm64,arm）的ddBot，其他架构平台暂未发现使用者，如果有欢迎上报，并且只知道arch为x86_64(amd64)，aarch64(arm64)所以其他的就归到arm上"
if [ "$(arch)" == "x86_64" ]; then
  echo "amd64"
  cmp -s /jds/dd_scripts/bot/ddBot-amd64 /usr/local/bin/ddBot
  
  if [ $? -ne 0 ] ;then
    cp /jds/dd_scripts/bot/ddBot-amd64 /usr/local/bin/ddBot

    ddP=$(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print $1}')
    if [ "$ddP" != "" ];then
      echo "停止ddBot......"
      eval $(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print "kill "$1}')
      echo "启动ddBot......"
      ddBot >>"$LOGS_DIR/dd_bot.log" 2>&1 &
    fi
  fi
elif [ "$(arch)" == "aarch64" ]; then
  echo "arm64"
  cmp -s /jds/dd_scripts/bot/ddBot-arm64 /usr/local/bin/ddBot
  
  if [ $? -ne 0 ] ;then
    cp /jds/dd_scripts/bot/ddBot-arm64 /usr/local/bin/ddBot

    ddP=$(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print $1}')
    if [ "$ddP" != "" ];then
      echo "停止ddBot......"
      eval $(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print "kill "$1}')
      echo "启动ddBot......"
      ddBot >>"$LOGS_DIR/dd_bot.log" 2>&1 &
    fi
  fi
else
  echo "arm"
  cmp -s /jds/dd_scripts/bot/ddBot-arm64 /usr/local/bin/ddBot
  
  if [ $? -ne 0 ] ;then
    cp /jds/dd_scripts/bot/ddBot-arm /usr/local/bin/ddBot

    ddP=$(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print $1}')
    if [ "$ddP" != "" ];then
      echo "停止ddBot......"
      eval $(ps -ef | grep -w "ddBot" | grep -v "grep\|webapi]" | awk '{print "kill "$1}')
      echo "启动ddBot......"
      ddBot >>"$LOGS_DIR/dd_bot.log" 2>&1 &
    fi
  fi
fi

###初始化nodejs环境及依赖
function initNodeEnv() {
  echo "安装执行脚本需要的nodejs环境及依赖"
  apk add --update nodejs moreutils npm curl jq
}

#获取配置的自定义参数,如果有为一次启动需要安装nodejs环境及依赖
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

###package.json更新前备份
[ -f /scripts/package.json ] && before_package_json=$(cat /scripts/package.json)

###仓库更新相关
echo "防止更新冲突，还原本地修改。。。"
git -C /scripts reset --hard
ddBot -up syncRepo


if [ $? -ne 0 ]; then
  echo "更新仓库代码出错❌，跳过"
else
  echo "更新仓库代码成功✅"
fi

###npm依赖安装相关
if [ ! -d /scripts/node_modules/ ]; then
  echo "容器首次启动，执行npm install..."
  npm install --loglevel error --prefix /scripts
  if [ $? -ne 0 ]; then
    echo "npm首次启动安装依赖失败❌，exit，restart"
    exit 1
  else
    echo "npm首次启动安装依赖成功✅"
  fi
else
  if [ "${before_package_json}" != "$(cat /scripts/package.json)" ] || [ ! -d /scripts/node_modules/async ]; then
    echo "package.json或者node_modules 有变化，执行npm install..."
    npm install --loglevel error --prefix /scripts
    if [ $? -ne 0 ]; then
      echo "npackage.json有更新，执行安装依赖失败❌，跳过"
      exit 0
    else
      echo "npackage.json有更新，执行安装依赖成功✅"
    fi
  else
    echo "package.json无变化，跳过npm install..."
  fi
fi


################################脚本仓库更新/初始化操作 end ################################
###同步docker仓库里面更新的相关文件
echo "将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /jds/dd_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh
echo "将仓库的shell_spnode.sh脚本更新至系统/usr/local/bin/spnode内..."
cat /jds/dd_scripts/shell_spnode.sh >/usr/local/bin/spnode
chmod +x /usr/local/bin/spnode
echo "将仓库的genCodeConf.list配置同步到到${GEN_CODE_LIST}..."
cat /jds/dd_scripts/genCodeConf.list >${GEN_CODE_LIST}

###定时任务相关处理
echo "定义定时任务合并处理用到的文件路径..."
DD_CRON_FILE_PATH="/scripts/merged_list_file.sh"
echo "└──合并后定时任务文件路径为 ${DD_CRON_FILE_PATH}"
# 查找指定目录下脚本内的定时任务配置信息
findDirCronFile() {
    if [ $1 ]; then
        findDir=$SCRIPTS_REPO_BASE_DIR/$1
    else
        findDir=$SCRIPTS_REPO_BASE_DIR
    fi
    echo "[$DD_CRON_FILE_PATH]   开始查找$findDir目录下脚本文件内的crontab任务定义..."
    for scriptFile in $(ls -l $findDir | grep "^-" | awk '{print $9}' | tr "\n" " "); do
        cron=$(sed -n "s/.*crontab=[\"\|']\(.*\)[\"\|'].*/\1/p" "$findDir/$scriptFile")
        if [ "$cron" != "" ] && [ "$(echo $EXCLUDE_CRON | grep "$scriptFile")" == "" ]; then
            cronName=$(sed -n "s/.*new Env([\"\|']\(.*\)[\"\|']).*/\1/p" "$findDir/$scriptFile")
            # echo "      #$cronName($findDir/$scriptFile)"
            # echo "      $cron node $findDir/$scriptFile >> $LOGS_DIR/$(echo $scriptFile | sed "s/\.js/.log/g") 2>&1 &"
            echo "#$cronName($findDir/$scriptFile)" >>$DD_CRON_FILE_PATH
            echo "$cron node $findDir/$scriptFile >>$LOGS_DIR/$(echo $scriptFile | sed "s/\.js/.log/g") 2>&1 &" >>$DD_CRON_FILE_PATH
            echo "" >>$DD_CRON_FILE_PATH
            CRONFILES="$CRONFILES\|$scriptFile"
        fi
    done
}

# 循环查找dd_scripts仓库目录下的脚本文件夹
cd $SCRIPTS_REPO_BASE_DIR

echo "#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ [$SCRIPTS_REPO_BASE_DIR] 仓库任务列表 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓#" >$DD_CRON_FILE_PATH
echo "添加默认更新仓库的定时任务..."
echo "21 */1 * * * docker_entrypoint.sh >> /data/logs/default_task.log 2>&1" >>$DD_CRON_FILE_PATH
for scriptDir in $(ls -l $SCRIPTS_REPO_BASE_DIR | grep "^d" | grep "dd" | awk '{print $9}' | tr "\n" " "); do
    findDirCronFile $scriptDir
done

echo "[$DD_CRON_FILE_PATH]   "
findDirCronFile

echo "判断是否配置了随即延迟参数..."
if [ "$RANDOM_DELAY_MAX" ]; then
  if [ "$RANDOM_DELAY_MAX" -ge 1 ]; then
    echo "└──已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
    sed -i "/\(jd_xtg.js\|jd_carnivalcity.js\|jd_blueCoin.js\|jd_joy\|jd_task\|jd_car_exchange.js\|docker_entrypoint.sh\)/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $DD_CRON_FILE_PATH
  fi
else
  echo "└──未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "判断是否配置自定义shell执行脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
  echo "└──未配置自定shell脚本文件，跳过执行。"
else
  if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
    echo "└──自定义shell脚本为远程脚本，开始下在自定义远程脚本${CUSTOM_SHELL_FILE}。"
    wget -O /jds/shell_mod.sh "$CUSTOM_SHELL_FILE"
    echo "└──下载完成，开始执行..."
    echo "#远程自定义shell脚本追加定时任务" >>$DD_CRON_FILE_PATH
    sh /jds/shell_mod.sh
    echo "└──自定义远程shell脚本下载并执行结束。"
  else
    if [ ! -f "$CUSTOM_SHELL_FILE" ]; then
      echo "└──自定义shell脚本为docker挂载脚本文件，但是指定挂载文件${CUSTOM_SHELL_FILE}不存在，跳过执行。"
    else
      echo "┌───────────────────────docker挂载的自定shell脚本，开始执行。───────────────────────┐"
      sh "$CUSTOM_SHELL_FILE" $1 | sed 's/^/    ─> &/g'
      echo "└───────────────────────docker挂载的自定shell脚本，执行结束。───────────────────────┘"
    fi
  fi
fi

#同步自定义脚本文件里面脚本任务
if [ -n "$(ls /data/custom_scripts/*_*.js)" ]; then
    cp -f /data/custom_scripts/jd_*.js /scripts
    cd /data/custom_scripts/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
          cp $scriptFile /scripts
          if [[ -z "$(cat $DD_CRON_FILE_PATH | grep $scriptFile)" && -z $1 ]]; then
              echo "#custom_scripts保存文件任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$DD_CRON_FILE_PATH
              echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>$LOGS_DIR/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$DD_CRON_FILE_PATH
              echo "" >>$DD_CRON_FILE_PATH
          fi
        elif [ -n "$(sed -n "s/.*crontab=[\"\|']\(.*\)[\"\|'].*/\1/p" "$scriptFile")" ] && [ "$(cat $DD_CRON_FILE_PATH | grep "$scriptFile")" == "" ]; then
            cp $scriptFile /scripts
            echo "#$cronName($scriptFile)--custom_scripts保存文件任务" >>$DD_CRON_FILE_PATH
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile >>$LOGS_DIR/$(echo $scriptFile | sed "s/\.js/.log/g") 2>&1 &" >>$DD_CRON_FILE_PATH
            echo "" >>$DD_CRON_FILE_PATH
        fi 
    done
fi

#根据EXCLUDE_CRON配置的关键字剔除相关任务 EXCLUDE_CRON="cfd,joy"
echo "第6步根据EXCLUDE_CRON配置的关键字剔除相关任务..."
if [ $EXCLUDE_CRON ]; then
    for kw in $(echo $EXCLUDE_CRON | tr "," " "); do
        matchCron=$(cat ${DD_CRON_FILE_PATH} | grep "$kw")
        if [ -z "$matchCron" ]; then
            echo "关键词 ${kw} 未匹配到任务"
        else
            echo "根据关键词 ${kw} 剔除的任务..."
            echo "$matchCron"
            sed -i '/'"${kw}"'/d' ${DD_CRON_FILE_PATH}
        fi
    done
fi

echo "第7步判断是否存在自定义任务任务列表并追加..."
if [ "$CUSTOM_LIST_FILE" ]; then
  echo "└──您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
  if [ -f "$CUSTOM_LIST_FILE" ]; then
    if [ "$CUSTOM_LIST_MERGE_TYPE" == "append" ]; then
      echo "└──合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
      echo -e "" >>$DD_CRON_FILE_PATH
      cat "$CUSTOM_LIST_FILE" >>$DD_CRON_FILE_PATH
    elif [ "$CUSTOM_LIST_MERGE_TYPE" == "overwrite" ]; then
      echo "└──配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
      cat "$CUSTOM_LIST_FILE" >$DD_CRON_FILE_PATH
    else
      echo "└──配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
    fi
  else
    echo "└──配置的自定义任务文件：$CUSTOM_LIST_FILE未找到，使用默认配置$DEFAULT_LIST_FILE..."
  fi
else
  echo "└──当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE ..."
fi

echo "" >>$DD_CRON_FILE_PATH
echo "#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ [$SCRIPTS_REPO_BASE_DIR] 仓库任务列表 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑#" >>$DD_CRON_FILE_PATH

echo "增加 |ts 任务日志输出时间戳..."
sed -i "/\(ddBot\| ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $DD_CRON_FILE_PATH

echo "增加清理日志，提交互助码到助力池脚本。（测试中）"
(
  cat <<EOF
#!/bin/sh
set -e

curr_dt=\$(date -R | awk '{print \$3" "\$2}')
echo "清除非当日(\${curr_dt})产生的日志，准备提交互助码码到助力池"
for dd_log in \$(ls /data/logs/ | grep "^jd.*log\$"); do
      sed -i "/^\${curr_dt}.*/!d" "/data/logs/\${dd_log}"
done
if [ \${DDBOT_VER} = "0.5" ];then
    ddBot -up commitShareCode
else
    echo "请更新至最新版docker镜像才能自动上传助力码到助力池"
fi
EOF
) >/scripts/submitShareCode.sh

echo "增加kcron kill 指定关键字的任务"
(
  cat <<EOF
#!/bin/sh
set -e

ps -eo pid,user,etime,args | grep "\$1" | grep -v "\/ts" | grep -v "grep" 

if [ \$1 ];then
  kill -9  \$(ps -ef | grep "\$1" | grep -v "grep" | awk '{print \$1}')
fi
EOF
) >/usr/local/bin/kcron
chmod +x /usr/local/bin/kcron

echo "最后加载最新的附加功能定时任务文件..."
echo "└──替换任务列表的node指令为spnode"
sed -i "s/ node / spnode /g" $DD_CRON_FILE_PATH

##12点55分测试一下提交
#echo "35 17 * * * cd /scripts && sleep \$((RANDOM % 400)); sh submitShareCode.sh >> $LOGS_DIR/submitCode.log 2>&1 & " >>$DD_CRON_FILE_PATH
echo "20 23 * * * cd /scripts && sleep \$((RANDOM % 400)); sh submitShareCode.sh >> $LOGS_DIR/submitCode.log 2>&1 & " >>$DD_CRON_FILE_PATH

echo "#每3天的23:50分清理一次日志(互助码不清理，proc_file.sh对该文件进行了去重) " >>$DD_CRON_FILE_PATH
echo "50 23 */3 * * find $LOGS_DIR -name '*.log' | grep -v 'sharecodeCollection' | xargs rm -rf " >>$DD_CRON_FILE_PATH
echo "#收集助力码 " >>$DD_CRON_FILE_PATH
echo "30 * * * * sh +x /scripts/utils/auto_help.sh collect >> $LOGS_DIR/auto_help_collect.log 2>&1 " >>$DD_CRON_FILE_PATH

# 生效定时任务
crontab $DD_CRON_FILE_PATH

# 家里路由失联零时加任务发给我自己
# if [ $TG_USER_ID == "129702206" ]; then
#     ip_regex="[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"
#     aa=$(curl http://checkip.dyndns.com/ | egrep -o $ip_regex | sort | uniq)
#     curl -F "chat_id=129702206" \
#         -F "text=$aa" \
#         https://tmp.akyakya.workers.dev/msg
# fi
