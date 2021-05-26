################################################################################
### 该文件内不要配置任何cookie ， cookie配置请写入 cookies.list
### spnode运行脚本会优取该文件配置的值
### 参考现有的格式增加/删除/更新，弄错可能会影响spnode执行出错
################################################################################
# export TG_USER_ID="6666666"

#账户cookie文件配置路径
export COOKIE_LIST="/data/cookies.list"
#互助码消息格式配置文件
export GEN_CODE_LIST="/data/genCodeConf.list"
#追加自定义任务
export CUSTOM_LIST_FILE="/data/my_crontab_list.sh"
#自定义shell脚本
export CUSTOM_SHELL_FILE="/jds/dd_scripts/shell_mod_script.sh"
#以上为相关数据文件配置
export JD_IMMORTAL_LATLON="{\"lat\":31.13,\"lng\":121.31}"
#随机延迟配置
export RANDOM_DELAY_MAX="20"
#取消订阅配置
export UN_SUBSCRIBES="100&100&iPhone12&Apple京东自营旗舰店"
#jd_bean_sign.js脚本运行后推送签到结果简洁版通知，默认推送全部签到结果，填true表示推送简洁通知
export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
#自动升级,顺序:解锁升级商品、升级货架,true表示自动升级,false表示关闭自动升级
export SUPERMARKET_UPGRADE="true"
#控制京东萌宠是否静默运行,false为否(发送推送通知消息),true为是(即：不发送推送通知消息)
export PET_NOTIFY_CONTROL="true"
#控制jd_joy_feedPets.js脚本喂食数量 ,可以填的数字10,20,40,80 , 其他数字不可
export JOY_FEED_COUNT="40"
#目前可填值为20或者500,脚本默认20,0表示不兑换京豆
if [[ $(date "+%-H") -ge 15 && $(date "+%-H") -lt 17 ]]; then
    export JD_JOY_REWARD_NAME="20"
else
    export JD_JOY_REWARD_NAME="500"
fi
export MARKET_COIN_TO_BEANS="1000"
#控制jd_joy_steal.js脚本是否给好友喂食,false为否,true为是(给好友喂食)
export JOY_HELP_FEED="true"
#自定义延迟签到,单位毫秒. 默认分批并发无延迟. 延迟作用于每个签到接口, 如填入延迟则切换顺序签到(耗时较长),如需填写建议输入数字1
export JD_BEAN_STOP="1"
export BUY_JOY_LEVEL="27"
#提供心仪商品名称
export FACTORAY_WANTPRODUCT_NAME="红米note9"
export JD_DEBUG="true"
export CUSTOM_LIST_MERGE_TYPE="append"
