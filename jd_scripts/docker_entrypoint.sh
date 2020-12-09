#!/bin/sh
set -e

export LANG="zh_CN.UTF-8"

if [ $1 ]; then
    echo "Currently does not support specifying startup parameters"
    echo "Please delete the last command attached to $(docker run) or the configured $(command:) parameter in $(docker-compose.yml)"
    echo "暂时不支持指定启动参数，请删除 docker run时最后附带的命令 或者 docker-compose.yml中的配置的command:指令 "
fi

echo "##############################################################################"
echo "Container start , Pull the latest code..."
echo "容器启动，git 拉取最新代码..."
git -C /scripts pull
echo "##############################################################################"

##兼容旧镜像的环境变量
if [ $CRONTAB_LIST_FILE && !$DEFAULT_LIST_FILE ]; then
    $DEFAULT_LIST_FILE=$CRONTAB_LIST_FILE
fi

defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
customListFile="/scripts/docker/$CUSTOM_LIST_FILE"
mergedListFile="/scripts/docker/merged_list_file.sh"

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

echo "Load the latest crontab task file..."
echo "加载最新的定时任务文件..."
crontab $mergedListFile

echo "Start crontab task main process..."
echo "启动crondtab定时任务主进程..."
crond -f
