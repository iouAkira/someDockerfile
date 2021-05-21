#!/bin/sh
set -e

first=$1
cmd=$*
#echo ${cmd/$1/}
if [ $1 == "conc" ]; then
    for job in $(cat $COOKIE_LIST | grep -v "#" | paste -s -d ' '); do
        { export JD_COOKIE=$job && node ${cmd/$1/}
        }&
    done
elif [ -n "$(echo $first | sed -n "/^[0-9]\+$/p")" ]; then
    #echo "$(echo $first | sed -n "/^[0-9]\+$/p")"
    { export JD_COOKIE=$(sed -n "${first}p" $COOKIE_LIST) && node ${cmd/$1/}
    }&
elif [ -n "$(cat $COOKIE_LIST  | grep "pt_pin=$first")" ];then
    #echo "$(cat $COOKIE_LIST  | grep "pt_pin=$first")"
    { export JD_COOKIE=$(cat $COOKIE_LIST | grep "pt_pin=$first") && node ${cmd/$1/}
    }&
else
    { export JD_COOKIE=$(cat $COOKIE_LIST | grep -v "#" | paste -s -d '&') && node $*
    }&
fi