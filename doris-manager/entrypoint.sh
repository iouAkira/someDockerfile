#! /bin/bash

up_cmd=$1

if [ "$up_cmd" == "doris-manager" ]; then
    echo "${Date}==>执行 bash /opt/app/doris-manager/webserver/bin/start.sh 启动 Doris Manager服务" >>/logs/entry.log
    bash /opt/app/doris-manager/webserver/bin/start.sh
    echo "${Date}==>Doris Manager服务已启动" >>/logs/entry.log
    tail -f /logs/entry.log
elif [ "$up_cmd" == "doris-webui" ]; then
    echo "${Date}==>执行 bash /opt/app/doris-manager/webui/bin/start.sh 启动 Doris webui服务"
    bash /opt/app/doris-manager/webui/bin/start.sh
    echo "${Date}==>Doris webui服务已启动" >>/logs/entry.log
    tail -f /logs/entry.log
else
    echo "keep running..." >>/logs/entry.log
    tail -f /logs/entry.log
fi
