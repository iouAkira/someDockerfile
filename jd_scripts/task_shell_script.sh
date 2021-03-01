#!/bin/sh
set -e

# 取消镜像自动通知
# ######################################获取docker构建文件里面的自定义信息方法-start#####################################################
# function getDockerImageLabel() {
#     repo=akyakya/jd_scripts
#     imageTag=latest
#     token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r '.token')
#     digest=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/manifests/${imageTag}" | jq .config.digest -r)
#     labels=$(curl -s -L -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/blobs/$digest" | jq .config.Labels)
#     echo $labels
# }
# ######################################获取docker构建文件里面的自定义信息方法-end#####################################################

# ######################################对比版本版本号大小方法-start###################################################################
# function version_gt() {
#     test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
# }
# ######################################对比版本版本号大小方法-end###################################################################

# #######################################通知用户更新镜像-start#####################################################################
# echo "check docker images update..."
# echo "检查docker镜像更新更新..."
# if type jq >/dev/null 2>&1; then
#     echo "get dockerhub repo images labels..."
#     echo "获取dockerhub仓库镜像labels信息..."
#     labels=$(getDockerImageLabel)
#     export NOTIFY_CONTENT=$(echo $labels | jq -r .UPDATE_CONTENT)
#     version=$(echo $labels | jq -r .VERSION)
# else
#     # 第一版通知逻辑无法包含在上面判断里面，镜像构建好直接开启通知
#     echo "Current container version is too old, send update notification"
#     echo "当前版本过旧，发送镜像更新通知"
#     export NOTIFY_CONTENT="更新内容较多，重新阅读仓库Readme(https://github.com/lxk0301/jd_scripts/tree/master/docker)，更新镜像并更新配置后使用。"
#     cd /scripts/docker
#     node notify_docker_user.js
# fi

# #通知通知用户更新镜像
# if [ ! $BUILD_VERSION ]; then
#     if [ $version ]; then
#         echo "Current container version is empty, dockerhub lastet $version, send update notification"
#         echo "当前容器版本为空，dockerhub仓库版本为$version，发送更新通知"
#         cd /scripts/docker
#         node notify_docker_user.js
#     fi
# else
#     if version_gt $version $BUILD_VERSION; then
#         echo "Current container version $BUILD_VERSION, dockerhub lastet version $version, send update notification"
#         echo "当前容器版本为$BUILD_VERSION，dockerhub仓库版本为$version，发送通知"
#         cd /scripts/docker
#         node notify_docker_user.js
#     fi
# fi
# #######################################通知用户更新镜像-end#####################################################################

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
        sed -i "/\(jd_bean_sign.js\|jd_blueCoin.js\|jd_5g.js\|jd_818.js\|jd_newYearMoney.js\|jd_newYearMoney_lottery.js\|jd_joy_reward.js\|jd_joy_steal.js\|jd_joy_feedPets.js\|jd_car_exchange.js\)/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $mergedListFile
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

echo "第9步加载最新的定时任务文件..."
crontab $mergedListFile
# cp /local_scripts/cookies*.sh  /root/
# source /root/cookies*.sh

echo "第10步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /jds/jd_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh

if [ $GEN_CODE_CONF ]; then
  cp /jds/jd_scripts/gen_code_conf.list $GEN_CODE_CONF
fi 

# echo "第11步打包脚本文件到/scripts/logs/scripts.tar.gz"
# apk add tar
# tar -zcvf /scripts/logs/scripts.tar.gz --exclude=scripts/node_modules --exclude=scripts/logs/*.log  --exclude=scripts/logs/*.gz /scripts

# 附加京喜工厂参团
sed -i "s/https:\/\/gitee.com\/shylocks\/updateTeam\/raw\/main\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/raw.githubusercontent.com\/LXK9301\/updateTeam\/master\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/https:\/\/gitee.com\/lxk0301\/updateTeam\/raw\/master\/shareCodes\/jd_updateFactoryTuanId.json/https:\/\/raw.githubusercontent.com\/iouAkira\/updateGroup\/master\/shareCodes\/jd_updateFactoryTuanId.json/g" /scripts/jd_dreamFactory.js
sed -i "s/\(.*\/\/.*joinLeaderTuan.*\)/  await joinLeaderTuan();/g" /scripts/jd_dreamFactory.js
