#!/bin/sh
set -e

if [ -f /data/env.sh ]; then
    source /data/env.sh
fi

first=$1
cmd=$*
# 判断命令是否需要执行混淆后的js脚本
if [ -n "$(echo $cmd | grep "_hx.js")" ]; then
    if [ $DEFAULT_EXEC_HX_SCRIPT ] && [ $DEFAULT_EXEC_HX_SCRIPT == "Y" ]; then
        echo "配置了 DEFAULT_EXEC_HX_SCRIPT=Y，混淆脚本执行命令继续..."
    else
        echo '执行的为混淆脚本，退出执行。如需启用请配置【export DEFAULT_EXEC_HX_SCRIPT="Y"】'
        exit 0
    fi
fi
# 指令交给node后台执行
if [ "$1" == "conc" ]; then
    for job in $(cat $COOKIE_LIST | grep -v "#" | paste -s -d ' '); do
        {
            export JD_COOKIE=$job && node ${cmd/$1/}
        } &
    done
elif [ "$1" == "concs" ]; then
    for job in $(cat $COOKIE_LIST | grep -v "#" | paste -s -d ' '); do
        {
            export JD_COOKIE=$job && sleep $((RANDOM % 120)) && node ${cmd/$1/}
        } &
    done
elif [ -n "$(echo $first | sed -n "/^[0-9]\+$/p")" ]; then
    if [ "$2" == "all" ]; then
        for job in $(ls *_*.js | grep -v "JS_*\|JD_DailyBonus\|JD_extra_cookie\|USER_AGENTS\|jd_crazy_joy\|jd_beauty" | sed "s/.js//g" | tr "\n" " "); do
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p") && node ${job} | tee -a "${LOGS_DIR}/${job}.log"
        done
    else
        {
            echo "执行的js脚本命令为[node${cmd/$1/}]"
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p") && node ${cmd/$1/}
        } &
    fi
elif [ -n "$(cat $COOKIE_LIST | grep "pt_pin=$first")" ]; then
    if [ "$2" == "all" ]; then
        for job in $(ls *_*.js | grep -v "JS_*\|JD_DailyBonus\|JD_extra_cookie\|USER_AGENTS\|jd_crazy_joy\|jd_beauty" | sed "s/.js//g" | tr "\n" " "); do
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p" | paste -s -d '&') && node ${job} | tee -a "${LOGS_DIR}/${job}.log"
        done
    else
        {   
            echo "执行的js脚本命令为[node${cmd/$1/}]"
            export JD_COOKIE=$(cat $COOKIE_LIST | grep "pt_pin=$first") && node ${cmd/$1/}
        } &
    fi
else
    {
        echo "执行的js脚本命令为[node ${cmd}]"
        export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | paste -s -d '&') && node $cmd
    } &
fi
