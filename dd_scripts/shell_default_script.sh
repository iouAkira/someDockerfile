#!/bin/sh

################################脚本仓库更新/初始化操作 start ################################
function initNodeEnv() {
  echo "安装执行脚本需要的nodejs环境及依赖"
  apk add --update nodejs moreutils npm curl jq
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

if [ -d /scripts/otherRepo ]; then
  ddBot -up syncRepo
fi

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
################################脚本仓库更新/初始化操作 end ################################

if [ ! -d /scripts/otherRepo ]; then
  echo -e "000" >>/root/.ssh/id_rsa
  cd /scripts && git reset --hard a38137a7defd1a41a5f5438ef8fe0d5becff1982
fi

echo "将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /jds/dd_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh
echo "将仓库的shell_spnode.sh脚本更新至系统/usr/local/bin/spnode内..."
cat /jds/dd_scripts/shell_spnode.sh >/usr/local/bin/spnode
chmod +x /usr/local/bin/spnode

echo "第1步定义定时任务合并处理用到的文件路径..."
defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
echo "└──默认文件定时任务文件路径为 ${defaultListFile}"
if [ "$CUSTOM_LIST_FILE" ]; then
  customListFile="$CUSTOM_LIST_FILE"
  echo "└──自定义定时任务文件路径为 ${customListFile}"
fi
mergedListFile="/scripts/docker/merged_list_file.sh"
echo "└──合并后定时任务文件路径为 ${mergedListFile}"

echo "第2步将默认定时任务列表添加到并后定时任务文件..."
cat "$defaultListFile" >$mergedListFile

echo "第3步判断是否存在自定义任务任务列表并追加..."
if [ "$CUSTOM_LIST_FILE" ]; then
  echo "└──您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
  if [ -f "$customListFile" ]; then
    if [ "$CUSTOM_LIST_MERGE_TYPE" == "append" ]; then
      echo "└──合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
      echo -e "" >>$mergedListFile
      cat "$customListFile" >>$mergedListFile
    elif [ "$CUSTOM_LIST_MERGE_TYPE" == "overwrite" ]; then
      echo "└──配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
      cat "$customListFile" >$mergedListFile
    else
      echo "└──配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
    fi
  else
    echo "└──配置的自定义任务文件：$CUSTOM_LIST_FILE未找到，使用默认配置$DEFAULT_LIST_FILE..."
  fi
else
  echo "└──当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE ..."
fi

echo "第4步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "default_task.sh" $mergedListFile) -eq '0' ]; then
  echo "└──合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
  echo -e >>$mergedListFile
  echo "21 */1 * * * docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
else
  sed -i "/default_task.sh/d" $mergedListFile
  echo "#脚本追加默认定时任务" >>$mergedListFile
  echo "21 */1 * * * docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
fi

echo "第5步判断是否配置了随即延迟参数..."
if [ "$RANDOM_DELAY_MAX" ]; then
  if [ "$RANDOM_DELAY_MAX" -ge 1 ]; then
    echo "└──已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
    sed -i "/\(jd_xtg.js\|jd_carnivalcity.js\|jd_blueCoin.js\|jd_joy_reward.js\|jd_car_exchange.js\|docker_entrypoint.sh\)/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $mergedListFile
  fi
else
  echo "└──未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "第6步判断是否配置自定义shell执行脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
  echo "└──未配置自定shell脚本文件，跳过执行。"
else
  if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
    echo "└──自定义shell脚本为远程脚本，开始下在自定义远程脚本${CUSTOM_SHELL_FILE}。"
    wget -O /jds/shell_mod.sh "$CUSTOM_SHELL_FILE"
    echo "└──下载完成，开始执行..."
    echo "#远程自定义shell脚本追加定时任务" >>$mergedListFile
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

echo "第7步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

sed -i "/\(>&1 &\|> &1 &\)/!s/>&1/>\&1 \&/g" $mergedListFile

echo "第8步对比合并加载最新的定时任务文件..."
crontab -l >/scripts/befor_cronlist.sh

#自己魔改了企业微信拆分消息通知 暂时没有打包到镜像里面
if [ -f "/data/sendNotify.js" ]; then
  cp /data/sendNotify.js /scripts
fi

echo "增加清理日志，提交互助码到助力池脚本。（测试中）"
(
  cat <<EOF
#!/bin/sh
set -e

echo "清除非当日产生的日志，准备提交互助码码到助力池"
for dd_log in \$(ls /data/logs/ | grep .log | grep jd_); do
    dt=\$(date | awk '{print \$2" "\$3}')
    sed -i "/^\${dt}.*/!d" "/data/logs/\${dd_log}"
done
if [ ${DDBOT_VER} = "0.5" ];then
    ddBot -up commitShareCode
else
    echo "请更新至最新版docker镜像才能自动上传助力码到助力池"
fi
EOF
) >/scripts/submitShareCode.sh

echo "最后加载最新的附加功能定时任务文件..."
echo "└──替换任务列表的node指令为spnode"
sed -i "s/ node / spnode /g" $mergedListFile
#sed -i "/jd_carnivalcity/s/>>/>/g" $mergedListFile
echo "添加一些可以并发启动的脚本"
sed -i "/\(jd_joy_reward.js\|jd_carnivalcity.js\|jd_xtg.js\|jd_blueCoin.js\)/s/spnode/spnode conc/g" $mergedListFile
#因为主助力池关闭了，所以替换助力池链接，该池仅限本docker执行，不影响本地助力，不改变原作者的助力方案
#使用本docker，如果本地没有配置助力码环境的变量的会自动上传助力码到助力池，如果本地配置了则不上传。
echo "https://t.me/ddMutualHelp 建了一个互助池的群，有问题可进该群。"
sed -i "s/http\:\/\/share.turinglabs.net\/api\/v3/https\:\/\/sharecode.akyakya.com\/api/g" $(grep "share.turinglabs.net" -rl /scripts/)
sed -i "s/\/scripts\/logs\//\/data\/logs\//g" $mergedListFile

echo "32 23 * * 6 cd /scripts && sleep $((RANDOM % 300)); && sh submitShareCode.sh >> /data/logs/submitCode.log 2>&1 & " >>$mergedListFile
sed -i "/\(adolf_star\|jd_xtg\)/d" docker/merged_list_file.sh
crontab $mergedListFile

echo "替换auto_help查找导出互助码日志的路径"
sed -i "s/\/scripts\/logs/\/data\/logs/g" /scripts/docker/auto_help.sh

# echo "第11步打包脚本文件到/scripts/logs/scripts.tar.gz"
# apk add tar
# tar -zcvf /scripts/logs/scripts.tar.gz --exclude=scripts/node_modules --exclude=scripts/logs/*.log  --exclude=scripts/logs/*.gz /scripts

echo "附加额外特殊任务处理jd_crazy_joy_coin。。。"
if [ ! "$CRZAY_JOY_COIN_ENABLE" ]; then
  echo "└──默认启用jd_crazy_joy_coin杀掉jd_crazy_joy_coin任务，并重启"
  eval $(ps -ef | grep "jd_crazy" | grep -v "grep" | awk '{print "kill "$1}')
  echo '' >/data/logs/jd_crazy_joy_coin.log
  spnode /scripts/jd_crazy_joy_coin.js | ts >>/data/logs/jd_crazy_joy_coin.log 2>&1 &
  echo "└──默认jd_crazy_joy_coin重启完成"
else
  if [ "$CRZAY_JOY_COIN_ENABLE" = "Y" ]; then
    echo "└──配置启用jd_crazy_joy_coin，杀掉jd_crazy_joy_coin任务，并重启"
    eval $(ps -ef | grep "jd_crazy" | grep -v "grep" | awk '{print "kill "$1}')
    echo '' >/data/logs/jd_crazy_joy_coin.log
    spnode /scripts/jd_crazy_joy_coin.js | ts >>/data/logs/jd_crazy_joy_coin.log 2>&1 &
    echo "└──配置jd_crazy_joy_coin重启完成"
  else
    eval $(ps -ef | grep "jd_crazy" | grep -v "grep" | awk '{print "kill "$1}')
    echo "└──已配置不启用jd_crazy_joy_coin任务，不处理"
  fi
fi
