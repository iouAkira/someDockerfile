#!/bin/sh
set -e

if !timeout 5s wget https://raw.githubusercontent.com/iouAkira/someDockerfile/master/pack_some_script/default_task.sh -O /pss/default_task.sh >/dev/null 2>&1; then
    if !timeout 5s wget https://cdn.jsdelivr.net/gh/iouAkira/someDockerfile@master/pack_some_script/default_task.sh -O /pss/default_task.sh >/dev/null 2>&1; then
        echo "get latest default_task.sh file timeout..."
        echo "获取最新default_task.sh文件超时..."
    fi
fi

echo "##############################################################################"
echo "git 拉取企鹅阅读最新代码..."
git -C /qqread reset --hard
git -C /qqread pull
npm install --prefix /qqread

echo "替换企鹅阅读脚本相关内容以兼容环境变量配置..."
sed -i "s/const d =.*$/const d = new Date(new Date().getTime());/g" /qqread/Task/qqreads.js
sed -i "s/(d.getHours() == 12.*$//g" /qqread/Task/qqreads.js
sed -i "s/(d.getHours() == 23/(d.getHours() == process.env.QQREAD_NOTIFY_TIME/g" /qqread/Task/qqreads.js

echo "Pull the qczj latest code..."
echo "git 拉取汽车之家极速版最新代码..."
git -C /QCZJSPEED reset --hard
git -C /QCZJSPEED pull

echo "Replace some qczj scripts content to be compatible with env configuration ..."
echo "替换汽车之间内容修正错误..."
sed -i "s/middleaccountManageEADER/middleaccountManageHEADER/g" /QCZJSPEED/Task/qczjspeed.js
cp /QCZJSPEED/Task/qczjspeed.js /qqread/Task/

echo "git 拉取喜马拉雅最新代码..."
git -C /xmly_speed reset --hard
git -C /xmly_speed pull
cd /xmly_speed
pip3 install -r requirements.txt

echo "替换喜马拉雅脚本相关内容以兼容环境变量配置..."
sed -i 's/BARK/BARK_PUSH/g' /xmly_speed/xmly_speed.py
sed -i 's/SCKEY/PUSH_KEY/g' /xmly_speed/xmly_speed.py
sed -i 's/if\ XMLY_ACCUMULATE_TIME.*$/if\ os.environ["XMLY_ACCUMULATE_TIME"]=="1":/g' /xmly_speed/xmly_speed.py
sed -i "s/\(xmly_speed_cookie\.split('\)\\\n/\1\|/g" /xmly_speed/xmly_speed.py
sed -i 's/cookiesList.append(line)/cookiesList.append(line.replace(" ",""))/g' /xmly_speed/xmly_speed.py
sed -i 's/_notify_time.split.*$/_notify_time.split()[0]==os.environ["XMLY_NOTIFY_TIME"]\ and\ int(_notify_time.split()[1])<30:/g' /xmly_speed/xmly_speed.py

echo "##############################################################################"

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
echo "检查docker镜像更新更新..."
if type jq >/dev/null 2>&1; then
    echo "获取dockerhub仓库镜像labels信息..."
    labels=$(getDockerImageLabel)
    export IMAGE_UPDATE_CONTENT=$(echo $labels | jq -r .IMAGE_UPDATE_CONTENT)
    # export CONFIG_CHANGE_CONTENT=$(echo $labels | jq -r .CONFIG_CHANGE_CONTENT)
    version=$(echo $labels | jq -r .VERSION)
else
    # 第一版通知逻辑无法包含在上面判断里面，镜像构建好直接开启通知
    echo "当前版本过旧，发送镜像更新通知"
    export IMAGE_UPDATE_CONTENT="调整镜像启动入口文件，增加一些自定义，如要更新使用请重新阅读一遍dockerhub镜像地址的readme(https://hub.docker.com/repository/docker/akyakya/pack_some_script)"
    cd /pss
    python3 send_notify.py
fi

#通知通知用户更新镜像
if [ ! $BUILD_VERSION ]; then
    if [ $version ]; then
        echo "当前容器版本为空，dockerhub仓库版本为$version，发送更新通知"
        cd /pss
        python3 send_notify.py
    fi
else
    if version_gt $version $BUILD_VERSION; then
        echo "当前容器版本为$BUILD_VERSION，dockerhub仓库版本为$version，发送通知"
        cd /pss
        python3 send_notify.py
    fi
fi
#######################################通知用户更新镜像-end#####################################################################

##兼容旧镜像的环境变量
if [ !$DEFAULT_LIST_FILE ]; then
    defaultListFile="/pss/crontab_list.sh"
else
    defaultListFile="/pss/$DEFAULT_LIST_FILE"
fi

customListFile="/pss/$CUSTOM_LIST_FILE"
mergedListFile="/pss/merged_list_file.sh"

if type ts >/dev/null 2>&1; then
    echo '系统已安装moreutils工具包，默认定时任务增加｜ts 输出'
    ##复制一个新文件来追加|ts，防止git pull的时候冲突
    cp $defaultListFile /pss/default_list.sh
    defaultListFile="/pss/default_list.sh"

    sed -i '/|ts/!s/>>/|ts >>/g' $defaultListFile
fi

#判断 自定义文件是否存在 是否存在
if [ $CUSTOM_LIST_FILE ]; then
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
            cat $defaultListFile >$mergedListFile
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ $CUSTOM_LIST_MERGE_TYPE == "overwrite" ]; then
            cat $customListFile >$mergedListFile
            echo "合并自定义任务文件：$CUSTOM_LIST_FILE"
            touch "$customListFile"
        else
            echo "配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
            cat $defaultListFile >$mergedListFile
        fi
    else
        echo "自定义任务文件：$CUSTOM_LIST_FILE 未找到，使用默认配置$DEFAULT_LIST_FILE..."
        cat $defaultListFile >$mergedListFile
    fi
else
    echo "当前使用的为默认定时任务文件 $DEFAULT_LIST_FILE ..."
    cat $defaultListFile >$mergedListFile
fi

# 判断最后要加载的定时任务是否包含默认定时任务，不包含的话就加进去
if [ $(grep -c "default_task.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo -e >>$mergedListFile
    echo "52 */1 * * * sh /pss/default_task.sh |ts >> /logs/default_task.log 2>&1" >>$mergedListFile
fi

echo "Load the latest crontab task file..."
echo "加载最新的定时任务文件..."
crontab $mergedListFile
