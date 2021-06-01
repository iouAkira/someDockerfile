#!/bin/sh

if [ -d "/data/rebateBot/" ]; then
    cd /data/rebateBot/
    sh execBot.sh
fi

mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

# echo "附加功能2，拉取@monk-coder的dust仓库的代码，并增加相关任务"
# if [ ! -d "/monk/" ]; then
#     echo "未检查到monk-coder仓库脚本，初始化下载相关脚本..."
#     #   cp -rf /local_scripts/monk/ /monk
#     git clone https://github.com/monk-coder/dust /monk
# else
#     echo "更新monk-coder脚本相关文件..."
#     git -C /monk reset --hard
#     git -C /monk pull --rebase
# fi

if [ -n "$(ls /monk/car/*_*.js)" ]; then
    cp -f /monk/car/*_*.js /scripts
    cd /monk/car/
    for scriptFile in $(ls *_*.js | grep -v monk_shop_add_to_car | tr "\n" " "); do
        if [[ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" && -z $1 ]]; then
            cp $scriptFile /scripts
            if [ ! -n "$(crontab -l | grep $scriptFile)" ]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi

if [ -n "$(ls /monk/i-chenzhe/*_*.js)" ]; then
    cp -f /monk/i-chenzhe/*_*.js /scripts
    cd /monk/i-chenzhe/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
            cp $scriptFile /scripts
            if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi
if [ -n "$(ls /monk/member/*_*.js)" ]; then
    cp -f /monk/member/*_*.js /scripts
    cd /monk/member/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
            cp $scriptFile /scripts
            if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi
if [ -n "$(ls /monk/normal/*_*.js)" ]; then
    cp -f /monk/normal/*_*.js /scripts
    cd /monk/normal/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
            cp $scriptFile /scripts
            if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi

echo "附加功能3，拉取@nianyuguai的longzhuzhu仓库的代码，并增加相关任务"
if [ ! -d "/longzhuzhu/" ]; then
    echo "未检查到longzhuzhu仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/nianyuguai/longzhuzhu.git /longzhuzhu
else
    echo "更新@nianyuguai的longzhuzhu脚本相关文件..."
    git -C /longzhuzhu reset --hard
    git -C /longzhuzhu pull --rebase
fi
if [ -n "$(ls /longzhuzhu/qx/*_*.js)" ]; then
    cp -f /longzhuzhu/qx/*_*.js /scripts
    cd /longzhuzhu/qx/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
            cp $scriptFile /scripts
            if [[ -z "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#longzhuzhu仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode conc /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi

echo "附加功能4，拉取@curtinlv的 JD-Script仓库的代码，并增加相关任务"
if [ ! -d "/data/curtinlv/" ]; then
    echo "未检查到@curtinlv的会员开卡仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/curtinlv/JD-Script.git /data/curtinlv
else
    echo "更新@curtinlv的会员开卡脚本相关文件..."
    git -C /data/curtinlv reset --hard
    git -C /data/curtinlv pull --rebase
fi


if type python3 >/dev/null 2>&1; then
    echo "会员开卡脚本需环境经存在，跳过安装依赖环境"
    if [[ "$(pip3 list | grep Telethon)" == "" || "$(pip3 list | grep APScheduler)" == "" ]]; then
        pip3 install requests
    fi
else
    echo "会员开卡脚本需要python3环境，安装所需python3及依赖环境"
    apk add --update python3-dev py3-pip
    pip3 install requests
fi
cd /data/curtinlv/OpenCard
OpenCardCookies=$(cat /data/cookies.list  | grep -v "jd_WUUpyT\|jd_SgGoap\|620311248_" |tr "\n" "&" | sed "s/&$//")
sed -i "/JD_COOKIE =/s/= \(.*\)/= '$OpenCardCookies'/g" /data/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/openCardBean =/s/= \(.*\)/= 20/g" /data/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/TG_BOT_TOKEN =/s/= \(.*\)/= $TG_BOT_TOKEN/g" /data/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/TG_USER_ID =/s/= \(.*\)/= $TG_USER_ID/g" /data/curtinlv/OpenCard/OpenCardConfig.ini

echo "#curtinlv的会员开卡仓库任务 " >>$mergedListFile
echo "0 8 * * * cd /data/curtinlv/OpenCard && python3 jd_OpenCard.py |ts >>/data/logs/jd_OpenCard.log 2>&1 &" >>$mergedListFile
echo "15 15 * * * cd /data/curtinlv/OpenCard && python3 jd_OpenCard.py |ts >>/data/logs/jd_OpenCard.log 2>&1 &" >>$mergedListFile
