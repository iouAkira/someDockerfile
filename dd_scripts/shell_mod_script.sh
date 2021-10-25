#!/bin/sh

if [ -d "/data/rebateBot/" ]; then
    cd /data/rebateBot/
    sh execBot.sh
fi

mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

# echo "附加功能2，拉取@monk-coder的dust仓库的代码，并增加相关任务"
# if [ ! -d "/data/cust_repo/monk/" ]; then
#     echo "未检查到monk-coder仓库脚本，初始化下载相关脚本..."
#     #   cp -rf /local_scripts/data/cust_repo/monk/ /data/cust_repo/monk
#     git clone https://github.com/data/cust_repo/monk-coder/dust /data/cust_repo/monk
# else
#     echo "更新monk-coder脚本相关文件..."
#     git -C /data/cust_repo/monk reset --hard
#     git -C /data/cust_repo/monk pull --rebase
# fi

# if [ -n "$(ls /data/cust_repo/monk/car/*_*.js)" ]; then
#     cp -f /data/cust_repo/monk/car/*_*.js /scripts
#     cd /data/cust_repo/monk/car/
#     for scriptFile in $(ls *_*.js | grep -v monk_shop_add_to_car | tr "\n" " "); do
#         if [[ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" && -z $1 ]]; then
#             cp $scriptFile /scripts
#             if [ ! -n "$(crontab -l | grep $scriptFile)" ]; then
#                 echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
#                 spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
#             fi
#             echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
#             echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
#         fi
#     done
# fi

# if [ -n "$(ls /data/cust_repo/monk/i-chenzhe/*_*.js | grep -v carnivalcity)" ]; then
#     cp -f /data/cust_repo/monk/i-chenzhe/*_*.js /scripts
#     cd /data/cust_repo/monk/i-chenzhe/
#     for scriptFile in $(ls *_*.js | tr "\n" " "); do
#         if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
#             cp $scriptFile /scripts
#             if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
#                 echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
#                 spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
#             fi
#             echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
#             echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
#         fi
#     done
# fi
# if [ -n "$(ls /data/cust_repo/monk/member/*_*.js)" ]; then
#     cp -f /data/cust_repo/monk/member/*_*.js /scripts
#     cd /data/cust_repo/monk/member/
#     for scriptFile in $(ls *_*.js | tr "\n" " "); do
#         if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
#             cp $scriptFile /scripts
#             if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
#                 echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
#                 spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
#             fi
#             echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
#             echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
#         fi
#     done
# fi
# if [ -n "$(ls /data/cust_repo/monk/normal/*_*.js)" ]; then
#     cp -f /data/cust_repo/monk/normal/*_*.js /scripts
#     cd /data/cust_repo/monk/normal/
#     for scriptFile in $(ls *_*.js | tr "\n" " "); do
#         if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
#             cp $scriptFile /scripts
#             if [[ ! -n "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
#                 echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
#                 spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
#             fi
#             echo "#monk-coder仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
#             echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
#         fi
#     done
# fi

# echo "附加功能3，拉取@nianyuguai的longzhuzhu仓库的代码，并增加相关任务"
# if [ ! -d "/data/cust_repo/longzhuzhu/" ]; then
#     echo "未检查到longzhuzhu仓库脚本，初始化下载相关脚本..."
#     git clone https://github.com/nianyuguai/data/cust_repo/longzhuzhu.git /data/cust_repo/longzhuzhu
# else
#     echo "更新@nianyuguai的longzhuzhu脚本相关文件..."
#     git -C /data/cust_repo/longzhuzhu reset --hard
#     git -C /data/cust_repo/longzhuzhu pull --rebase
# fi

# if [ -n "$(ls /data/cust_repo/longzhuzhu/qx/*_*.js)" ]; then
#     cp -f /data/cust_repo/longzhuzhu/qx/*_*.js /scripts
#     cd /data/cust_repo/longzhuzhu/qx/
#     for scriptFile in $(ls *_*.js | tr "\n" " "); do
#         if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
#             cp $scriptFile /scripts
#             if [[ -z "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
#                 echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
#                 spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
#             fi
#             echo "#longzhuzhu仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
#             echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode conc /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
#         fi
#     done
# fi

#同步自定义脚本文件里面脚本任务
if [ -n "$(ls /data/custom_scripts/*_*.js)" ]; then
    cp -f /data/custom_scripts/*_*.js /scripts
    cd /data/custom_scripts/
    for scriptFile in $(ls *_*.js | tr "\n" " "); do
        if [ -n "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile)" ]; then
            cp $scriptFile /scripts
            if [[ -z "$(crontab -l | grep $scriptFile)" && -z $1 ]]; then
                echo "发现以前crontab里面不存在的任务，先跑为敬 $scriptFile"
                spnode /scripts/$scriptFile | ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &
            fi
            echo "#custom_scripts保存文件任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >>$mergedListFile
            echo "$(sed -n "s/.*cronexpr=\"\(.*\)\".*/\1/p" $scriptFile) spnode /scripts/$scriptFile |ts >>/data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1 &" >>$mergedListFile
        fi
    done
fi

echo "附加功能4，拉取@curtinlv的 JD-Script仓库的代码，并增加相关任务"
if [ ! -d "/data/cust_repo/curtinlv/" ]; then
    echo "未检查到@curtinlv的会员开卡仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/curtinlv/JD-Script.git /data/cust_repo/curtinlv
else
    echo "更新@curtinlv的会员开卡脚本相关文件..."
    git -C /data/cust_repo/curtinlv reset --hard
    git -C /data/cust_repo/curtinlv pull --rebase
fi

# if type pip3 >/dev/null 2>&1; then
#     echo "会员开卡脚本需环境经存在，跳过安装依赖环境"
#     if [[ "$(pip3 list | grep Telethon)" == "" || "$(pip3 list | grep APScheduler)" == "" ]]; then
#         pip3 install requests
#     fi
# else
#     echo "会员开卡脚本需要python3环境，安装所需python3及依赖环境"
#     apk add --update python3-dev py3-pip
#     pip3 install requests
# fi

# cd /data/cust_repo/curtinlv/OpenCard
# rn=1
# for ck in $(cat /data/cookies.list | grep -v "//" | tr "\n" " "); do
#     if [ ${#ck} -gt 10 ];then
#         if [ $rn == 1 ]; then
#             echo "账号$rn【$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")】$ck" >/data/cust_repo/curtinlv/JDCookies.txt
#             sed -i "/qjd_zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_qjd.py
#             sed -i "/zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_zjd.py
#             sed -i "/cash_zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_cashHelp.py
#         else
#             if [ $rn == 4 ] || [ $rn == 3 ]; then
#                 sed -i "/qjd_zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_qjd.py
#                 sed -i "/zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_zjd.py
#                 sed -i "/cash_zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_cashHelp.py
#             fi
#             echo "账号$rn【$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")】$ck" >>/data/cust_repo/curtinlv/JDCookies.txt
#         fi
#         rn=$(expr $rn + 1)
#     fi
# done
# OpenCardCookies=$(cat /data/cookies.list | grep -v "#\|jd_WUUpyT\|jd_SgGoap\|620311248_" | tr "\n" "&" | sed "s/&$//")
# sed -i "/JD_COOKIE =/s/= \(.*\)/= '$OpenCardCookies'/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
# sed -i "/openCardBean =/s/= \(.*\)/= 20/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
# sed -i "/memory =/s/= \(.*\)/= no/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
# sed -i "/TG_BOT_TOKEN =/s/= \(.*\)/= $TG_BOT_TOKEN/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
# sed -i "/TG_USER_ID =/s/= \(.*\)/= $TG_USER_ID/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini


# echo "#curtinlv的赚京豆 " >>$mergedListFile
# echo "05 0,7,23 * * * cd /data/cust_repo/curtinlv && python3 jd_zjd.py |ts >>/data/logs/jd_zjd.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv抢京豆" >>$mergedListFile
# echo "11 0 * * * cd /data/cust_repo/curtinlv && python3 jd_qjd.py |ts >>/data/logs/jd_qjd.log 2>&1 &" >>$mergedListFile

echo "#curtinlv东东超市兑换" >>$mergedListFile
sed -i "/coinToBeans =/s/''/'京豆包'/g" /data/cust_repo/curtinlv/jd_blueCoin.py
sed -i "/blueCoin_Cc = /s/False/True/g" /data/cust_repo/curtinlv/jd_blueCoin.py
echo "59 23 * * * cd /data/cust_repo/curtinlv && python3 jd_blueCoin.py |ts >>/data/logs/jd_blueCoinPy.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv的会员开卡仓库任务 " >>$mergedListFile
# echo "2 8,15 * * * cd /data/cust_repo/curtinlv/OpenCard && python3 jd_OpenCard.py |ts >>/data/logs/jd_OpenCard.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv的关注有礼任务 " >>$mergedListFile
# cat /data/cookies.list >/data/cust_repo/curtinlv/getFollowGifts/JDCookies.txt
# echo "15 8,15 * * * cd /data/cust_repo/curtinlv/getFollowGifts && python3 jd_getFollowGift.py |ts >>/data/logs/jd_getFollowGift.log 2>&1 &" >>$mergedListFile
