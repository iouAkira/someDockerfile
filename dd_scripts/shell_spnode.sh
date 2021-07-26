#!/bin/sh
set -e

if [ -f /data/env.sh ]; then
    source /data/env.sh
fi

first=$1
cmd=$*
#echo ${cmd/$1/}
if [ "$1" == "conc" ]; then
    for job in $(cat $COOKIE_LIST | grep -v "#" | paste -s -d ' '); do
        {
            export JD_COOKIE=$job && node ${cmd/$1/}
        } &
    done
elif [ -n "$(echo $first | sed -n "/^[0-9]\+$/p")" ]; then
    if [ "$2" == "all" ]; then
        for job in $(ls *_*.js | grep -v "JS_*\|JD_DailyBonus\|JD_extra_cookie\|USER_AGENTS\|jd_crazy_joy\|jd_beauty" | sed "s/.js//g" | tr "\n" " "); do
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p") && node ${job} | tee -a "${LOGS_DIR}/${job}.log"
        done
    else
        {
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p") && node ${cmd/$1/}
        } &
    fi
elif [ -n "$(echo $first | sed -n "/[0-9]p/p")" ]; then
    if [ "$2" == "all" ]; then
        for job in $(ls *_*.js | grep -v "JS_*\|JD_DailyBonus\|JD_extra_cookie\|USER_AGENTS\|jd_crazy_joy\|jd_beauty" | sed "s/.js//g" | tr "\n" " "); do
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${startl},999p" | paste -s -d '&') && node ${job} | tee -a "${LOGS_DIR}/${job}.log"
        done
    elif [[ "$2" =~ "smiek_jd_zdjr" ]]; then
        startl=$(echo ${first} | sed -n "s/\(.*\)p/\1/p")
        {
            export JD_COOKIE=$(cat $COOKIE_LIST | sed "s/\(#pt_key\|# pt_key\)/pt_key/" | grep -v "#\|^$" | sed -n "${startl},999p" | paste -s -d '&') && node ${cmd/$1/}
        } &
    else
        startl=$(echo ${first} | sed -n "s/\(.*\)p/\1/p")
        {
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${startl},999p" | paste -s -d '&') && node ${cmd/$1/}
        } &
    fi
elif [ -n "$(cat $COOKIE_LIST | grep "pt_pin=$first")" ]; then
    if [ "$2" == "all" ]; then
        for job in $(ls *_*.js | grep -v "JS_*\|JD_DailyBonus\|JD_extra_cookie\|USER_AGENTS\|jd_crazy_joy\|jd_beauty" | sed "s/.js//g" | tr "\n" " "); do
            export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | sed -n "${first}p" | paste -s -d '&') && node ${job} | tee -a "${LOGS_DIR}/${job}.log"
        done
    else
        {
            export JD_COOKIE=$(cat $COOKIE_LIST | grep "pt_pin=$first") && node ${cmd/$1/}
        } &
    fi
elif [[ "$1" =~ "smiek_jd_zdjr" ]]; then
    {
        export JD_COOKIE=$(cat $COOKIE_LIST | sed "s/\(#pt_key\|# pt_key\)/pt_key/" | grep -v "#\|^$" | paste -s -d '&') && node $*
    } &
else
    {
        export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#\|^$" | paste -s -d '&') && node $*
    } &
fi
