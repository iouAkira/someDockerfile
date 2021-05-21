### 使用说明须知
- 该版本bot功能虽然提供了cookie扫码自动写入生效并测试的功能，但是代码 __`不开源`__、__`不开源`__、__`不开源`__， __请慎重__、 __请慎重__、 __请慎重__(不排除被我钓鱼的可能呢🎣)，而且有判断如果是奸商牟利的并无法使用该功能
- 配置参考
```sh
dd_scripts
├── data
│   ├── logs
│   │   └── xxxxx.log
│   ├── cookies.list
│   ├── gen_code_conf.list
│   ├── my_crontab_list.sh
│   └── replyKeyboard.list
└── docker-compose.yml
```
- docker-compose.yml
```yml
dd_scripts:
  image: akyakya/jd_scripts
  container_name: dd
  restart: always
  volumes:
    - ./data:/data
  tty: true
  extra_hosts:
    - "mainhost:172.17.0.1"
  environment:
    - COOKIE_LIST=/data/cookies.list
    - GEN_CODE_LIST=/data/gen_code_conf.list
    - CUSTOM_LIST_FILE=/data/my_crontab_list.sh
    - CUSTOM_SHELL_FILE=/jds/dd_scripts/shell_mod_script.sh
    #以上为相关数据文件配置
    - TG_BOT_TOKEN=14*******************Q2Y
    - TG_USER_ID=1*********6
    - RANDOM_DELAY_MAX=20
    - UN_SUBSCRIBES=100&100&iPhone12&Apple京东自营旗舰店
    #jd_bean_sign.js脚本运行后推送签到结果简洁版通知，默认推送全部签到结果，填true表示推送简洁通知
    - JD_BEAN_SIGN_NOTIFY_SIMPLE=true
    #自动升级,顺序:解锁升级商品、升级货架,true表示自动升级,false表示关闭自动升级
    - SUPERMARKET_UPGRADE=true
    #控制京东萌宠是否静默运行,false为否(发送推送通知消息),true为是(即：不发送推送通知消息)
    - PET_NOTIFY_CONTROL=true
    #控制jd_joy_feedPets.js脚本喂食数量 ,可以填的数字10,20,40,80 , 其他数字不可
    - JOY_FEED_COUNT=40
    #目前可填值为20或者500,脚本默认20,0表示不兑换京豆
    - JD_JOY_REWARD_NAME=500
    - MARKET_COIN_TO_BEANS=1000
    #控制jd_joy_steal.js脚本是否给好友喂食,false为否,true为是(给好友喂食)
    - JOY_HELP_FEED=true
    #自定义延迟签到,单位毫秒. 默认分批并发无延迟. 延迟作用于每个签到接口, 如填入延迟则切换顺序签到(耗时较长),如需填写建议输入数字1
    - JD_BEAN_STOP=1
    - BUY_JOY_LEVEL=27
    #提供心仪商品名称
    - FACTORAY_WANTPRODUCT_NAME=红米note9
    - JD_DEBUG=true
    - CUSTOM_LIST_MERGE_TYPE=append
```
