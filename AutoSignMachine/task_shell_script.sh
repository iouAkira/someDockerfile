#!/bin/sh
set -e

if [ $1 ]; then
  echo "更换为清华大学的源..."
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
  echo "容器启动，补充安装一些系统组件包..."
  apk add perl openssl libjpeg-turbo-dev libpng-dev libtool libgomp tesseract-ocr graphicsmagick rsync
  echo "npm更换为淘宝镜像源"
  npm config set registry http://registry.npm.taobao.org/
fi

[ -f /AutoSignMachine/package.json ] && PackageListOld=$(cat /AutoSignMachine/package.json)

echo "更新仓库代码..."
cd /AutoSignMachine
git reset --hard
echo "git pull拉取最新代码..."
git -C /AutoSignMachine pull --rebase
git checkout azmodan
echo "npm install 安装最新依赖..."
if [ ! -d /AutoSignMachine/node_modules ]; then
  echo -e "检测到首次部署, 运行 npm install...\n"
  npm install --loglevel error --prefix /AutoSignMachine
else
  if [[ "${PackageListOld}" != "$(cat /AutoSignMachine/package.json)" ]]; then
    echo -e "检测到package.json有变化，运行 npm install...\n"
    npm install --loglevel error --prefix /AutoSignMachine
  else
    echo -e "检测到package.json无变化，跳过...\n"
  fi
fi

# echo "增加一个莫名其妙的脚本"
# (
#   cat <<EOF
# #!/bin/sh
# set -e

# if [ "\$1" ]; then
#   JOBS=\$1
# else
#   echo "执行SequentialTryRunJob.sh请正确传入参数。"
#   echo "示例: 第一个参数为要执行的jobs，多个用,隔开，第二个参数为账户目录多个用,隔开，第二个参数不则自动取/根目录下的账户/asm****目录"
#   echo "sh SequentialTryRunJob.sh job1,job2 /asm7225,/asm7123"
#   exit 0
# fi

# if [ "\$2" ]; then
#   for acc in \$(echo "\$2" | sed "s/,/ /g"); do
#     echo "正在为\${acc}账户,执行\${JOBS}任务..."
#     node "\${acc}"/index.js unicom --tryrun --tasks "\$JOBS"
#   done
# else

#   for acc in \$(ls / | grep asm | tr "\n" " "); do
#     echo "正在为/\${acc}账户,执行\${JOBS}任务..."
#     node /"\${acc}"/index.js unicom --tryrun --tasks "\$JOBS"
#   done
# fi

# EOF
# ) >/AutoSignMachine/SequentialTryRunJob.sh

mergedListFile="/AutoSignMachine/merged_list_file.sh"
envFile="/root/.AutoSignMachine/.env"
echo "定时任务文件路径为 ${mergedListFile}"
echo '' >${mergedListFile}

if [ $ENABLE_52POJIE ]; then
  echo "10 13 * * * sleep \$((RANDOM % 120)); node /AutoSignMachine/index.js 52pojie --htVD_2132_auth=${htVD_2132_auth} --htVD_2132_saltkey=${htVD_2132_saltkey} >> /logs/52pojie.log 2>&1 &" >>${mergedListFile}
else
  echo "未配置启用52pojie签到任务环境变量ENABLE_52POJIE，故不添加52pojie定时任务..."
fi

if [ $ENABLE_BILIBILI ]; then
  echo "*/30 7-22 * * * sleep \$((RANDOM % 120)); node /AutoSignMachine/index.js bilibili --username ${BILIBILI_ACCOUNT} --password ${BILIBILI_PWD} >> /logs/bilibili.log 2>&1 &" >>${mergedListFile}
else
  echo "未配置启用bilibi签到任务环境变量ENABLE_BILIBILI，故不添加Bilibili定时任务..."
fi

if [ $ENABLE_IQIYI ]; then
  echo "*/30 7-22 * * * sleep \$((RANDOM % 120)); node /AutoSignMachine/index.js iqiyi --P00001 ${P00001} --P00PRU ${P00PRU} --QC005 ${QC005}  --dfp ${dfp} >> /logs/iqiyi.log 2>&1 &" >>${mergedListFile}
else
  echo "未配置启用iqiyi签到任务环境变量ENABLE_IQIYI，故不添加iqiyi定时任务..."
fi

if [ $ENABLE_UNICOM ]; then
  if [ -f $envFile ]; then
    cp -f $envFile /AutoSignMachine/config/.env
    if [ -n "$UNICOM_SUBDIR_MODE" ]; then
      echo "联通配置了UNICOM_SUBDIR_MODE参数，所以使用每个账户自动创建单独目录及配置来执行任务"
      pwds=$(cat ~/.AutoSignMachine/.env | grep UNICOM_PASSWORD | sed -n "s/.*'\(.*\)'.*/\1/p")
      appids=$(cat ~/.AutoSignMachine/.env | grep UNICOM_APPID | sed -n "s/.*'\(.*\)'.*/\1/p")
      bookReadFlows=$(cat ~/.AutoSignMachine/.env | grep ENABLE_BOOK_READ | sed -n "s/.*'\(.*\)'.*/\1/p")
      goodIndexs=$(cat ~/.AutoSignMachine/.env | grep GOOD_INDEX | sed -n "s/.*'\(.*\)'.*/\1/p")
      i=1
      bookReadFlowAccs=""
      for username in $(cat ~/.AutoSignMachine/.env | grep UNICOM_USERNAME | sed -n "s/.*'\(.*\)'.*/\1/p" | sed "s/,/ /g"); do
        sub_dir="asm${username:7:4}"
        if [ ! -d "/$sub_dir/node_modules/" ]; then
          cp -rf /AutoSignMachine /"$sub_dir"
        else
          if type rsync >/dev/null 2>&1; then
            echo " " >/dev/null
          else
            apk add async
          fi
          rsync -a /AutoSignMachine/* /"$sub_dir" --exclude node_modules
        fi

        echo "$sub_dir"
        pwd=$(echo "$pwds" | cut -d ',' -f$i)
        appid="$(echo "$appids" | cut -d ',' -f$i)"
        bookReadFlow="$(echo "$bookReadFlows" | cut -d ',' -f$i)"
        goodIndex="$(echo "$goodIndexs" | cut -d ',' -f$i)"
        #echo $appid
        echo "UNICOM_USERNAME = '$username'" >/"$sub_dir"/config/.env
        echo "UNICOM_PASSWORD = '$pwd'" >>/"$sub_dir"/config/.env
        echo "UNICOM_APPID = '$appid'" >>/"$sub_dir"/config/.env
        echo "ASYNC_TASKS = true" >>/"$sub_dir"/config/.env
        echo "GOOD_INDEX = '$goodIndex'" >>/"$sub_dir"/config/.env
        echo "*/30 7-22 * * * sleep \$((RANDOM % 10)); node /$sub_dir/index.js unicom >> /logs/unicom${username:7:4}.log 2>&1 &" >>${mergedListFile}
        if [[ -n "${bookReadFlow}" && "${bookReadFlow}" == "true" ]]; then
          if [ "$bookReadFlowAccs" == "" ]; then
            bookReadFlowAccs="/${sub_dir}"
          else
            bookReadFlowAccs="${bookReadFlowAccs},/${sub_dir}"
          fi
        fi
        i=$(expr $i + 1)
      done
      # echo "17 10,16 * * * sh /AutoSignMachine/SequentialTryRunJob.sh dailyBookRead10doDraw ${bookReadFlowAccs} >> /logs/seq_book_read.log 2>&1 &" >>${mergedListFile}
    elif [ $UNICOM_TRYRUN_MODE ]; then
      echo "联通配置了UNICOM_TRYRUN_NODE参数，所以定时任务以tryrun模式生成"
      minute=$((RANDOM % 10 + 4))
      hour=8
      n_hour="$(date +%H)"
      n_minute="$(date +%M)"
      #job_interval=6
      for job in $(awk '/scheduler.regTask/{getline a;print a}' /AutoSignMachine/commands/tasks/unicom/unicom.js | sed "/\//d" | sed "s/\( \|,\|\"\|\\t\)//g" | tr "\n" " "); do

        minute2=$(expr $minute + $((RANDOM % 10 + 3)))
        if [ $minute2 -ge 60 ]; then
          minute2=59
        fi
        echo "$minute,$minute2 $hour * * * sleep \$((RANDOM % 40)); node /AutoSignMachine/index.js unicom --tryrun --tasks $job >>/logs/unicom_$job.log 2>&1 &" >>${mergedListFile}
        minute=$(expr $minute + $((RANDOM % 10 + 4)))
        if [ $minute -ge 60 ]; then
          minute=0
          hour=$(expr $hour + 1)
        fi
        if [ -z "$(crontab -l | grep $job)" ]; then
          echo "  ->发现新增加任务$job所以在当前时间后面增加一个 $n_hour时$n_minute分 的单次任务，防止今天漏跑"
          echo "$n_minute $n_hour * * * sleep \$((RANDOM % 60)); node /AutoSignMachine/index.js unicom --tryrun --tasks $job >>/logs/unicom_$job.log 2>&1 &" >>${mergedListFile}
          n_minute=$(expr $n_minute + $((RANDOM % 10 + 4)))
          if [ $n_minute -ge 60 ]; then
            n_minute=0
            n_hour=$(expr $n_hour + 1)
          fi
          if [ $n_hour -ge 24 ]; then
            n_hour=0
          fi
        fi
      done
    else
      echo "*/10 6-23 * * * sleep \$((RANDOM % 120)); node /AutoSignMachine/index.js unicom >> /logs/unicom.log 2>&1 &" >>${mergedListFile}
    fi
  else
    echo "未找到 .env配置文件，故不添加unicom定时任务。"
  fi
else
  echo "未配置启用unicom签到任务环境变量ENABLE_UNICOM，故不添加unicom定时任务..."
fi

# if [ -z "${otherRewardVideo}" ]; then
#   #为所有账户执行 dailyOtherRewardVideo 大水任务，执行方式单次单账户执行（耗时长，易出错）
#   echo "$((RANDOM % 30)) 1,10 * * * sh /AutoSignMachine/SequentialTryRunJob.sh dailyOtherRewardVideo >> /logs/otherRewardVideo.log 2>&1 &" >>$mergedListFile
# else
#   echo "${otherRewardVideo} sh /AutoSignMachine/SequentialTryRunJob.sh dailyOtherRewardVideo >> /logs/otherRewardVideo.log 2>&1 &" >>$mergedListFile
# fi

#为所有账户执行所有任务，执行方式单次单账户单任务执行 all 里面排除了jflottery，dailyOtherRewardVideo，playiosgame，dailygameIntegral，dailyBookRead10doDraw
#20点的时候查缺补漏
#echo "01 20 * * * sh /AutoSignMachine/SequentialTryRunJob.sh all >> /logs/all.log 2>&1 &" >>$mergedListFile
#为所有账户执行 jflottery 看脸任务，执行方式单次单账户执行（玄学时间点）
#echo "29 6 * * * sh /AutoSignMachine/SequentialTryRunJob.sh jflottery >> /logs/jflottery.log 2>&1 &" >>$mergedListFile
#为所有账户执行 playiosgame 任务，执行方式单次单账户执行（耗时长）
#echo "$((RANDOM % 30)) 7,12 * * * sh /AutoSignMachine/SequentialTryRunJob.sh playiosgame >> /logs/playiosgame.log 2>&1 &" >>$mergedListFile
#为所有账户执行 dailygameIntegral 任务，执行方式单次单账户执行（耗时长）
#echo "$((RANDOM % 30)) 9,14 * * * sh /AutoSignMachine/SequentialTryRunJob.sh dailygameIntegral >> /logs/dailygameIntegral.log 2>&1 &" >>$mergedListFile
#为所有账户执行 dailyBookRead10doDraw 任务，执行方式单次单账户执行（耗时长，看需要在自定shell里面加开启）
#echo "$((RANDOM % 30)) 15,19 * * * sh /AutoSignMachine/SequentialTryRunJob.sh dailyBookRead10doDraw >> /logs/dailyBookRead10doDraw.log 2>&1 &" >>$mergedListFile

echo "增加默认脚本更新任务..."
echo "55 */1 * * * docker_entrypoint.sh >> /logs/default_task.log 2>&1" >>$mergedListFile

echo "默认任务里面不执行dailyBookRead10doDraw"
for taskFile in $(ls ~/.AutoSignMachine/ | grep taskFile_unicom_1 | tr "\n" " ");do
	echo "${taskFile}"
  sed -i "s/dailyBookRead10doDraw\",\"taskState\":0/dailyBookRead10doDraw\",\"taskState\":1/g" ~/.AutoSignMachine/${taskFile}
  #sed -i "s/dailyOtherRewardVideo\",\"taskState\":0/dailyOtherRewardVideo\",\"taskState\":1/g" ~/.AutoSignMachine/${taskFile}
  #sed -i "s/playiosgame\",\"taskState\":0/playiosgame\",\"taskState\":1/g" ~/.AutoSignMachine/${taskFile}
  #sed -i "s/dailygameIntegral\",\"taskState\":0/dailygameIntegral\",\"taskState\":1/g" ~/.AutoSignMachine/${taskFile}
done

echo "判断是否配置自定义shell执行脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
  echo "未配置自定shell脚本文件，跳过执行。"
else
  if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
    echo "自定义shell脚本为远程脚本，开始下在自定义远程脚本。"
    wget -O /AutoSignMachine/shell_script_mod.sh "$CUSTOM_SHELL_FILE"
    echo "下载完成，开始执行..."
    echo "#远程自定义shell脚本追加定时任务" >>$mergedListFile
    sh /AutoSignMachine/shell_script_mod.sh
    echo "自定义远程shell脚本下载并执行结束。"
  else
    if [ ! -f $CUSTOM_SHELL_FILE ]; then
      echo "自定义shell脚本为docker挂载脚本文件，但是指定挂载文件不存在，跳过执行。"
    else
      echo "docker挂载的自定shell脚本，开始执行..."
      echo "#docker挂载自定义shell脚本追加定时任务" >>$mergedListFile
      sh "$CUSTOM_SHELL_FILE"
      echo "docker挂载的自定shell脚本，执行结束。"
    fi
  fi
fi

#echo "判断是否配置了随即延迟参数..."
#if [ "$RANDOM_DELAY_MAX" ]; then
#  if [ "$RANDOM_DELAY_MAX" -ge 1 ]; then
#    echo "已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
#    sed -i "/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)) && node/g" $mergedListFile
#  fi
#else
#  echo "未配置随即延迟对应的环境变量，故不设置延迟任务..."
#fi

echo "增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "加载最新的定时任务文件..."
crontab $mergedListFile

echo "启动asmbot..."
sh /AutoSignMachine/docker/bot/asmbot.sh
