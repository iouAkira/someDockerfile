#!/bin/sh
set -e

######################################获取docker构建文件里面的自定义信息方法-start#####################################################
function getDockerImageLabel() {
    repo=akyakya/pack_some_script
    imageTag=latest
    token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r '.token')
    digest=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/manifests/${imageTag}" | jq .config.digest -r)
    labels=$(curl -s -L -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/blobs/$digest" | jq .config.Labels)
    echo $labels
}
######################################获取docker构建文件里面的自定义信息方法-end#####################################################

######################################对比版本版本号大小方法-start###################################################################
function version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}
######################################对比版本版本号大小方法-end###################################################################

#######################################通知用户更新镜像-start#####################################################################
echo "check docker images update..."
echo "检查docker镜像更新更新..."
if type jq >/dev/null 2>&1; then
    echo "get dockerhub repo images labels..."
    echo "获取dockerhub仓库镜像labels信息..."
    labels=$(getDockerImageLabel)
    export IMAGE_UPDATE_CONTENT=$(echo $labels | jq -r .UPDATE_CONTENT)
    # export CONFIG_CHANGE_CONTENT=$(echo $labels | jq -r .CONFIG_CHANGE_CONTENT)
    version=$(echo $labels | jq -r .VERSION)
else
    # 第一版通知逻辑无法包含在上面判断里面，镜像构建好直接开启通知
    echo "Current container version is too old, send update notification"
    echo "当前版本过旧，发送镜像更新通知"
    export IMAGE_UPDATE_CONTENT="调整镜像启动入口文件，增加一些自定义，如要更新使用请重新阅读一遍dockerhub镜像地址的readme(https://hub.docker.com/repository/docker/akyakya/pack_some_script)"
    cd /pss
    python3 send_notify.py
fi

#通知通知用户更新镜像
if [ ! $BUILD_VERSION ]; then
    if [ $version ]; then
        echo "Current container version is empty, dockerhub lastet $version, send update notification"
        echo "当前容器版本为空，dockerhub仓库版本为$version，发送更新通知"
        cd /pss
        python3 send_notify.py
    fi
elif version_gt $version $BUILD_VERSION; then
    echo "Current container version $BUILD_VERSION, dockerhub lastet version $version, send update notification"
    echo "当前容器版本为$BUILD_VERSION，dockerhub仓库版本为$version，发送通知"
    cd /pss
    python3 send_notify.py
else
    echo "The docker image update content is not checked"
    echo "未检查到docker镜像更新内容"
fi
#######################################通知用户更新镜像-end#####################################################################

#sunert 仓库的百度极速版
function initBaidu() {
    mkdir /baidu_speed
    cd /baidu_speed
    git init
    git remote add -f origin https://github.com/Sunert/Scripts.git
    git config core.sparsecheckout true
    echo Task/package.json >>/baidu_speed/.git/info/sparse-checkout
    echo Task/baidu_speed.js >>/baidu_speed/.git/info/sparse-checkout
    echo Task/sendNotify.js >>/baidu_speed/.git/info/sparse-checkout
    git pull origin master
    cd Task
    npm install
}

#sunert 仓库的聚看点
function initJUKAN() {
    mkdir /jukan
    cd /jukan
    git init
    git remote add -f origin https://github.com/Sunert/Scripts.git
    git config core.sparsecheckout true
    echo Task/package.json >>/jukan/.git/info/sparse-checkout
    echo Task/jukan.js >>/jukan/.git/info/sparse-checkout
    echo Task/sendNotify.js >>/jukan/.git/info/sparse-checkout
    git pull origin master
    cd Task
    npm install
}

#@shylocks仓库的聚看点
function initJKD() {
    mkdir /jkd
    cd /jkd
    git init
    git remote add -f origin https://github.com/shylocks/Loon.git
    git config core.sparsecheckout true
    echo package.json >>/jkd/.git/info/sparse-checkout
    echo jkd.js >>/jkd/.git/info/sparse-checkout
    echo sendNotify.js >>/jkd/.git/info/sparse-checkout
    git pull origin main
    npm install
}

##定义定合并定时任务相关文件路径变量
defaultListFile="/pss/$DEFAULT_LIST_FILE"
customListFile="/pss/$CUSTOM_LIST_FILE"
mergedListFile="/pss/merged_list_file.sh"

##判断喜马拉雅COOKIE配置之后才会更新相关任务脚本
if [ 0"$XMLY_SPEED_COOKIE" = "0" ]; then
    echo "没有喜马拉雅极速版Cookie，相关环境变量参数，跳过配置定时任务"
else
    echo "Pull the xmly_speed latest code..."
    echo "git 拉取喜马拉雅最新代码..."
    git -C /xmly_speed reset --hard
    git -C /xmly_speed pull
    cd /xmly_speed
    pip3 install -r requirements.txt

    echo "Replace some xmly scripts content to be compatible with env configuration ..."
    echo "替换喜马拉雅脚本相关内容以兼容环境变量配置..."
    sed -i 's/BARK/BARK_PUSH/g' /xmly_speed/xmly_speed.py
    sed -i 's/SCKEY/PUSH_KEY/g' /xmly_speed/xmly_speed.py
    sed -i 's/if\ XMLY_ACCUMULATE_TIME.*$/if\ os.environ["XMLY_ACCUMULATE_TIME"]=="1":/g' /xmly_speed/xmly_speed.py
    sed -i "s/\(xmly_speed_cookie\.split('\)\\\n/\1\|/g" /xmly_speed/xmly_speed.py
    sed -i 's/cookiesList.append(line)/cookiesList.append(line.replace(" ",""))/g' /xmly_speed/xmly_speed.py
    sed -i 's/_notify_time.split.*$/_notify_time.split()[0]==os.environ["XMLY_NOTIFY_TIME"]\ and\ int(_notify_time.split()[1])<30:/g' /xmly_speed/xmly_speed.py

    if [ 0"$XMLY_CRON" = "0" ]; then
        XMLY_CRON="*/30 * * * *"
    fi

    echo -e >>$defaultListFile
    ##喜马拉雅极速版任务
    echo "$XMLY_CRON sleep \$((RANDOM % 120)); cd /xmly_speed && python3 xmly_speed.py >> /logs/xmly_speed.log 2>&1" >>$defaultListFile
fi

##企鹅阅读COOKIE配置之后才会更新相关任务脚本
if [ 0"$QQREAD_BODY" = "0" ]; then
    echo "没有企鹅阅读Cookie，相关环境变量参数，跳过配置定时任务"
else
    echo "Pull the qqreader latest code..."
    echo "git 拉取企鹅阅读最新代码..."
    git -C /qqread reset --hard
    #git -C /qqread pull
    #npm install --prefix /qqread

    echo "Replace some qqread scripts content to be compatible with env configuration ..."
    echo "替换企鹅阅读脚本相关内容以兼容环境变量配置..."
    sed -i "s/notifyttt = 1/notifyttt = process.env.QQREAD_NOTIFYTTT || 1/g" /qqread/Task/qqreadnode.js
    sed -i "s/notifyInterval = 2/notifyInterval = process.env.QQREAD_NOTIFY_INTERVAL || 2/g" /qqread/Task/qqreadnode.js

    # echo "复制一份企鹅阅读文件单独执行开宝箱任务....."
    # cp /qqread/Task/qqreadnode.js /qqread/Task/qqreads_openbox.js
    # sed -i "s/BOX = 0/BOX = 1/g" /qqread/Task/qqreads_openbox.js

    if [ 0"$QQREAD_CRON" = "0" ]; then
        QQREAD_CRON="*/20 * * * *"
    fi
    echo -e >>$defaultListFile
    ##企鹅阅读小程序阅读任务
    echo "$QQREAD_CRON sleep \$((RANDOM % 180)); node /qqread/Task/qqreadnode.js >> /logs/qqreadnode.log 2>&1" >>$defaultListFile

    # if [ 0"$QQREAD_OPENBOX_CRON" = "0" ]; then
    #     QQREAD_OPENBOX_CRON="*/10 * * * *"
    # fi
    # echo -e >>$defaultListFile
    # ##企鹅阅读小程序宝箱任务
    # echo "$QQREAD_OPENBOX_CRON node /qqread/Task/qqreads_openbox.js >> /logs/qqreads_openbox.log 2>&1" >>$defaultListFile
fi

##判断汽车之家COOKIE配置之后才会更新相关任务脚本
if [ 0"$QCZJ_GetUserInfoHEADER" = "0" ]; then
    echo "没有汽车之家Cookie，相关环境变量参数，跳过配置定时任务"
else
    echo "Pull the qczj latest code..."
    echo "git 拉取汽车之家极速版最新代码..."
    git -C /QCZJSPEED reset --hard
    git -C /QCZJSPEED pull
    npm install --prefix /QCZJSPEED

    echo "Replace some qczj scripts content to be compatible with env configuration ..."
    echo "替换汽车之间内容修正错误..."
    sed -i "s/=\ GetUserInfourlArr\[i\]/=\ GetUserInfourlArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ GetUserInfoheaderArr\[i\]/=\ GetUserInfoheaderArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ coinbodyArr\[i\]/=\ coinbodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ taskbodyArr\[i\]/=\ taskbodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ activitybodyArr\[i\]/=\ activitybodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ GoldcoinbodyArr\[i\]/=\ GoldcoinbodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ videobodyArr\[i\]/=\ videobodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ WelfarevideobodyArr\[i\]/=\ WelfarevideobodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ WelfarebodyArr\[i\]/=\ WelfarebodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ addCoinbodyArr\[i\]/=\ addCoinbodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ addCoin2bodyArr\[i\]/=\ addCoin2bodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ reportAssheaderArr\[i\]/=\ reportAssheaderArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/=\ reportAssbodyArr\[i\]/=\ reportAssbodyArr\[i\].trim()/g" /QCZJSPEED/Task/qczjspeed.js
    sed -i "s/cointowalletbodyVal.replace/cointowalletbodyVal.trim().replace/g" /QCZJSPEED/Task/qczjspeed.js

    if [ 0"$QCZJ_CRON" = "0" ]; then
        QCZJ_CRON="*/30 * * * *"
    fi
    echo -e >>$defaultListFile
    ##汽车之家相关任务
    echo "$QCZJ_CRON sleep \$((RANDOM % 120)); node /QCZJSPEED/Task/qczjspeed.js >> /logs/qczjspeed.log 2>&1" >>$defaultListFile
fi

##判断百度极速版COOKIE配置之后才会更新相关任务脚本
if [ 0"$BAIDU_COOKIE" = "0" ]; then
    echo "没有配置百度Cookie，相关环境变量参数，跳过下载配置定时任务"
else
    if [ ! -d "/baidu_speed/" ]; then
        echo "未检查到baidu_speed脚本相关文件，初始化下载相关脚本"
        initBaidu
    else
        echo "更新baidu_speed脚本相关文件"
        git -C /baidu_speed reset --hard
        git -C /baidu_speed pull origin master
    fi
    cp -r /baidu_speed/Task/baidu_speed.js /baidu_speed/Task/baidu_speed_use.js
    sed -i "s/StartBody/BDCookie/g" /baidu_speed/Task/baidu_speed_use.js
    #直接插入提现，
    sed -i "/await\ userInfo/i\\      if (\$.time(\"HH\") == \"06\") { await withDraw(withcash); } ;" /baidu_speed/Task/baidu_speed_use.js
    #sed -i "s/.*process.env.BAIDU_COOKIE.indexOf('\\\n')/else&/g" /baidu_speed/Task/baidu_speed_use.js

    if [ 0"$BAIDU_CRON" = "0" ]; then
        BAIDU_CRON="10 7-22 * * *"
    fi
    echo -e >>$defaultListFile
    echo "$BAIDU_CRON sleep \$((RANDOM % 120)); node /baidu_speed/Task/baidu_speed_use.js >> /logs/baidu_speed.log 2>&1" >>$defaultListFile
    #增加一个不带随机延迟任务是为了6点抢提现使用
    echo "0 6 * * * node /baidu_speed/Task/baidu_speed_use.js >> /logs/baidu_speed.log 2>&1" >>$defaultListFile
fi

##判断聚看点@sunert版本COOKIE配置之后才会更新相关任务脚本
if [ 0"$JUKAN_BODY" = "0" ]; then
    echo "没有配置JUKAN_BODY聚看点，相关环境变量参数，跳过下载下载脚本、配置定时任务"
else
    echo "配置了JUKAN_BODY所以使用 @sunert 仓库的脚本执行任务"

    if [ ! -d "/jukan/" ]; then
        echo "未检查到jukan脚本相关文件，初始化下载相关脚本"
        initJUKAN
    else
        echo "更新jukan脚本相关文件"
        git -C /jukan reset --hard
        git -C /jukan pull origin master
    fi

    if [ 0"$JUKAN_CRON" = "0" ]; then
        JUKAN_CRON="*/20 7-22 * * *"
    fi
    echo -e >>$defaultListFile
    echo "$JUKAN_CRON sleep \$((RANDOM % 120)); node /jukan/Task/jukan.js >> /logs/jukan.log 2>&1" >>$defaultListFile
fi

##判断聚看点@shylocks版本COOKIE配置之后才会更新相关任务脚本
if [ 0"$JKD_COOKIE" = "0" ]; then
    echo "没有配置JKD_COOKIE聚看点，相关环境变量参数，跳过下载下载脚本、配置定时任务"
else
    echo "配置了JKD_COOKIE所以使用 @shylocks 仓库的脚本执行任务"

    if [ ! -d "/jkd/" ]; then
        echo "未检查到jukan脚本相关文件，初始化下载相关脚本"
        initJKD
    else
        echo "更新jkd脚本相关文件"
        echo sendNotify.js >>/jkd/.git/info/sparse-checkout
        git -C /jkd reset --hard
        git -C /jkd pull origin main
    fi

    if [ 0"$JKD_CRON" = "0" ]; then
        JKD_CRON="*/20 7-22 * * *"
    fi
    echo -e >>$defaultListFile
    echo "$JKD_CRON sleep \$((RANDOM % 120)); node /jkd/jkd.js >> /logs/jkd.log 2>&1" >>$defaultListFile
fi

###追加|ts 任务日志时间戳
if type ts >/dev/null 2>&1; then
    echo 'moreutils tools installed, default task append |ts output'
    echo '系统已安装moreutils工具包，默认定时任务增加｜ts 输出'
    ##复制一个新文件来追加|ts，防止git pull的时候冲突
    cp $defaultListFile /pss/default_list.sh
    defaultListFile="/pss/default_list.sh"

    sed -i '/|ts/!s/>>/|ts >>/g' $defaultListFile
fi

#判断 自定义文件是否存在 是否存在
if [ $CUSTOM_LIST_FILE ]; then
    echo "You have configured a custom list file: $CUSTOM_LIST_FILE, custom list merge type: $CUSTOM_LIST_MERGE_TYPE..."
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "merge default list file: $DEFAULT_LIST_FILE and custom list file: $CUSTOM_LIST_FILE"
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
            cat $defaultListFile >$mergedListFile
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ $CUSTOM_LIST_MERGE_TYPE == "overwrite" ]; then
            cat $customListFile >$mergedListFile
            echo "merge custom list file: $CUSTOM_LIST_FILE..."
            echo "合并自定义任务文件：$CUSTOM_LIST_FILE"
            touch "$customListFile"
        else
            echo "配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
            cat $defaultListFile >$mergedListFile
        fi
    else
        echo "Not found custom list file: $CUSTOM_LIST_FILE ,use default list file: $DEFAULT_LIST_FILE"
        echo "自定义任务文件：$CUSTOM_LIST_FILE 未找到，使用默认配置$DEFAULT_LIST_FILE..."
        cat $defaultListFile >$mergedListFile
    fi
else
    echo "The currently used is the default crontab task file: $DEFAULT_LIST_FILE ..."
    echo "当前使用的为默认定时任务文件 $DEFAULT_LIST_FILE ..."
    cat $defaultListFile >$mergedListFile
fi

##增加自定义shell脚本
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下在自定义远程脚本。"
        wget -O /pss/pss_shell_mod.sh $CUSTOM_SHELL_FILE
        echo "下载完成，开始执行..."
        sh -x /pss/pss_shell_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f $CUSTOM_SHELL_FILE ]; then
            echo "自定义shell脚本为docker挂载脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "docker挂载的自定shell脚本，开始执行..."
            sh -x $CUSTOM_SHELL_FILE
            echo "docker挂载的自定shell脚本，执行结束。"
        fi
    fi
fi


# 判断最后要加载的定时任务是否包含默认定时任务，不包含的话就加进去
if [ $(grep -c "default_task.sh" $mergedListFile) -eq '0' ]; then
    echo "Merged crontab task file，the required default task is not included, append default task..."
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo -e >>$mergedListFile
    echo "52 */1 * * * sh /pss/default_task.sh |ts >> /logs/default_task.log 2>&1" >>$mergedListFile
fi
echo "Load the latest crontab task file..."
echo "加载最新的定时任务文件..."
crontab $mergedListFile
