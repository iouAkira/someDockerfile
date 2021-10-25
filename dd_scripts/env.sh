################################################################################
### 该文件内不要配置任何cookie ， cookie配置请写入 cookies.list
### spnode运行脚本会优取该文件配置的值
### 参考现有的格式增加/删除/更新，弄错可能会影响spnode执行出错
################################################################################
export JD_DEBUG="true"
#账户cookie文件配置路径
export COOKIE_LIST="/data/cookies.list"
#互助码消息格式配置文件
export GEN_CODE_LIST="/data/genCodeConf.list"
#追加自定义任务
export CUSTOM_LIST_FILE="/data/my_crontab_list.sh"
#追加自定义任务追加方式
export CUSTOM_LIST_MERGE_TYPE="append"
#自定义shell脚本路径
export CUSTOM_SHELL_FILE="/jds/dd_scripts/shell_mod_script.sh"
#以上为相关数据文件配置
export JD_IMMORTAL_LATLON="{\"lat\":31.13,\"lng\":121.31}"
#随机延迟配置该配置在spnode之外所以不能实时
export RANDOM_DELAY_MAX=20
#通过wskey更新ck 自定UA和签名
# export RENEW_FULL_BODY_SIGN='body={"to":"https://plogin.m.jd.com/jd-mlogin/static/html/appjmp_blank.html","action":"to"}&client=apple&clientVersion=10.1.2&uuid=3c7eec4e5252480a84971e43f5656d44&st=1630596215025&sign=a877d2369e1f282404fa0cc870e9019d&sv=111'
# export RENEW_UA="JD4iPhone/167761 (iPhone; iOS 15.0; Scale/3.00)"
# export RENEW_SLEEP="N"
#环境变量名 QYWX_AM依次填入 corpid,corpsecret,touser(注:多个成员ID使用|隔开),agentid,消息类型(选填,不填默认文本消息类型)
export QYWX_AM="ww40df9bb76c016fdd,xFKdV9g1TMpu2lH2czbF5fU-H_CnDMpQYW_WlBiEk4U,@N,1000002"
# export QYWX_AM="ww40df9bb76c016fdd,xFKdV9g1TMpu2lH2czbF5fU-H_CnDMpQYW_WlBiEk4U,@N|jd_RgxgkRLNcfqM@LOF|jd_eScTMMDvNXZG@LOF|FangHaiXi|Juan@LOF|zhengxy@LOF|@N|@N|@N|FangHaiXi|summerBuChiCong|elaineChen|XiangFeiZi|@N|YinWei|LanLan|211fa89ee309c048d05990c0386ae78b|YuQin|ZhuangLiQin|yuyu0521@LOF|YinWei|@N|elaineChen,1000002"
export QYWX_AM_LOF="ww986ff3b882539e31,00VRGFSOP7Z9IERupbB8S40xFEr9f8tAPOFOLK71fMM,@N,1000002"
#取消订阅配置
export UN_SUBSCRIBES="100&100&iPhone12&Apple京东自营旗舰店"
#签到领现金兑换红包
export exchangeAccounts="luwei900915@10&jd_RgxgkRLNcfqM@10&jd_eScTMMDvNXZG@10&101014537-618445@2&jd_LtelonMDeZsU@2&jd_BzoDAYlMPUCR@2&jd_WUUpyTwsAIqX@2&jd_SgGoapwGbKAW@2&jd_dYURnveHFAug@2&summersnow_1@2&qq_dsy@2&jd_73fd0e435d092@2&YEGUO616@2&375370544-188782@2&jd_4cd5dce095f17@2&chenxiaoqin5181@2&jd_41cf6498ecaaf@2&jd_62024aee894a1@2&620311248_114904850@10"
#剔除的任务
export EXCLUDE_CRON="JS_USER_AGENTS.js,JD_DailyBonus.js,jd_live_redrain.js,jd_jxnc.js,jd_bean_change.js"
#jd_bean_sign.js脚本运行后推送签到结果简洁版通知，默认推送全部签到结果，填true表示推送简洁通知
export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
#自动升级,顺序:解锁升级商品、升级货架,true表示自动升级,false表示关闭自动升级
export SUPERMARKET_UPGRADE="true"
#控制京东萌宠是否静默运行,false为否(发送推送通知消息),true为是(即：不发送推送通知消息)
export PET_NOTIFY_CONTROL="true"
#控制jd_joy_feedPets.js脚本喂食数量 ,可以填的数字10,20,40,80 , 其他数字不可
export JOY_FEED_COUNT="40"
#jd_joy脚本用到的，
export invokeKey="JL1VTNRadM68cIMQ"
# 东东超市兑换
export MARKET_COIN_TO_BEANS="超值京豆包"
#控制jd_joy_steal.js脚本是否给好友喂食,false为否,true为是(给好友喂食)
export JOY_HELP_FEED="true"

##curtinlv东东超市兑换
export coinToBeans='京豆包'
export blueCoin_Cc=True
####其他脚本参数配置
# export Cupexid="38"
# export JD_USER_AGENT="jdltapp;iPhone;3.1.0;14.4;3b6e79334551fc6f31952d338b996789d157c4e8"
# export summer_movement_joinjoinjoinhui=true
# export IOU_MSG_TITLE="其他类优惠消息"
##互助码环境变量配置，想偷懒自用shell去githubAction.md文档哪查找循环
#东东农场 FRUITSHARECODES 需要偷懒试用本地助力的配置
# if [ -z $FRUITSHARECODES ]; then
#     shareCodes=""
#     for line in $(cat /data/logs/sharecodeCollection.log | grep 东东农场 | sed s/[[:space:]]//g); do
#         if [[ -z "${shareCodes}" || "${shareCodes}" == "" ]]; then
#             shareCodes=$(cat /data/logs/sharecodeCollection.log | grep 东东农场 | sed s/[[:space:]]//g | grep -v "${line}" | sed -n "s/.*互助码】\(.*\)$/\1/p" | tr -s "\n" "@" | sed "s/@$//")
#         else
#             shareCodes=${shareCodes}"&"$(cat /data/logs/sharecodeCollection.log | grep 东东农场 | sed s/[[:space:]]//g | grep -v "${line}" | sed -n "s/.*互助码】\(.*\)$/\1/p" | tr -s "\n" "@" | sed "s/@$//")
#         fi
#     done
#     export FRUITSHARECODES="$shareCodes"
# fi