![Docker Pulls](https://img.shields.io/docker/pulls/akyakya/pack_some_script?style=for-the-badge)
## 只是打包一些🐑🐑脚本 
```diff
! tip：Cookie获取相关请移步原作者仓库查看教程
```
- ### 喜马拉雅极速版 作者：[__@Zero-S1__](https://github.com/Zero-S1)｜[__仓库地址__](https://github.com/Zero-S1/xmly_speed)
  > 4个环境变量 `XMLY_SPEED_COOKIE`为cookie必须配置；后面3个为可选配置 `XMLY_ACCUMULATE_TIME`#设置为1开启刷时长，0为关闭刷时长、`XMLY_NOTIFY_TIME`通知时间，例 (9点) XMLY_NOTIFY_TIME=09、`XMLY_CRON`喜马拉雅自定义定时任务，不配置默认为`*/30 * * * *`

- ### 企鹅阅读(QQ小程序) 作者：[__@ziye12__](https://github.com/ziye12)｜[__仓库地址__](https://github.com/ziye12/JavaScript)
  > 9个环境变量 `QQREAD_BODY`、`QQREAD_TIMEURL`、`QQREAD_TIMEHD`为cookie必须配置；后面6个为可选配置`COOKIES_SPLIT`多账号cookies连接符号，不配置默认为|，如果需要配置使用汽车之家请配置为 `COOKIES_SPLIT=|&|`、~通知时间`QQREAD_NOTIFY_TIME`不再支持，使用原作定义的通知时间~、提现金额`QQREAD_CASH`不配置默认为0不自动提现，可配置为(1、2、10、30、50、100)、`QQREAD_CRON`企鹅阅读自定义定时任务，不配置默认为 `*/20 * * * *`不建议自定义，20分钟可以开满72个、`QQREAD_NOTIFYTTT`0为关闭外部推送，1为12 23 点外部推送,默认为1、`QQREAD_NOTIFY_INTERVAL`0为关闭通知，1为所有通知，2为12 23 点通知  ， 3为 6 12 18 23 点通知，默认为2
- ### 汽车之家极速版 作者：[__@ziye12__](https://github.com/ziye12)｜[__仓库地址__](https://github.com/ziye12/QCZJSPEED)
  > 12个环境变量`QCZJ_GetUserInfoURL`、`QCZJ_GetUserInfoHEADER`、`QCZJ_coinBODY`、`QCZJ_taskBODY`、`QCZJ_activityBODY`、`QCZJ_GoldcoinBODY`、`QCZJ_videoBODY`、`QCZJ_WelfarevideoBODY`、`QCZJ_WelfareBODY`、`QCZJ_addCoinBODY`、`QCZJ_addCoin2BODY`、`QCZJ_reportAssBODY`、`QCZJ_reportAssHEADER`为必须配置；`QCZJ_CRON`汽车之家自定义定时任务，不配置默认为`*/30 * * * *`
    ```diff 
    ! tip：COOKIES_SPLIT 只针对企鹅阅读和汽车之家生效
    ```
- ### 百度极速版 作者：[__@Sunert__](https://github.com/Sunert)｜[__仓库地址__](https://github.com/Sunert/Scripts/blob/master/Task/baidu_speed.js)
  > 2个环境变量 `BAIDU_COOKIE`如果需要使用百度极速版刷任务，必须配置(多cookies使用 `&`链接 )；`BAIDU_CRON`汽车之家自定义定时任务，不配置默认为`10 7-22 * * *`
- ### Sunert的聚看点 作者：[__@Sunert__](https://github.com/Sunert)｜[__仓库地址__](https://github.com/Sunert/Scripts/blob/master/Task/jukan.js)
  > 3个环境变量变量 `JUKAN_COOKIE`，`JUKAN_BODY`，如果要使用Sunert的聚看点刷任务2个必须配置(多cookies使用 `&`链接 )；`JUKAN_CRON`聚看点自定义定时任务，不配置默认为`*/20 7-22 * * *`
- ### shylocks的聚看点 作者：[__@shylocks__](https://github.com/shylocks)｜[__仓库地址__](https://github.com/shylocks/Loon/blob/main/jkd.js)
  > 4个环境变量 `JKD_COOKIE`如果要使用shylocks的聚看点刷任务必须配置(多cookies使用`&`或者`@`链接)；后面3个为可选配置`JKD_USER_AGENT`用户ua默认为ios、`JKD_WITHDRAW`提现金额、`JKD_CRON`聚看点自定义定时任务，不配置默认为`*/20 7-22 * * *`
    ```diff
    ! tip：聚看点二选一配置即可
    ```
___
```diff
+ 2021-01-10更新 增加 CUSTOM_SHELL_FILE 参数配置执行自定义shell脚本
+ 例1:配置远程shell脚本, 我自己写了一个shell脚本https://raw.githubusercontent.com/iouAkira/someDockerfile/master/pack_some_script/pss_shell_mod.sh
+ CUSTOM_SHELL_FILE=https://raw.githubusercontent.com/iouAkira/someDockerfile/master/pack_some_script/pss_shell_mod.sh
+
+ 例2:配置docker挂载本地自定义shell脚本,/pss/pss_shell_mod.sh 为你在docker-compose.yml里面挂载到容器里面绝对路径
+ CUSTOM_SHELL_FILE=/pss/pss_shell_mod.sh
+
+ tip：如果使用远程自定义，请保证网络畅通或者选择合适的国内仓库，例如有部分人的容器里面就下载不到github的raw文件，那就可以把自己的自定义shell写在gitee上，或者换本地挂载
+      如果是 docker 挂载本地，请保重文件挂载进去了，并且配置的是绝对路径。
+      自定义 shell 脚本里面如果要加 crontab 任务请使用 echo 追加到 /pss/merged_list_file.sh 里面否者不生效
+ 注⚠️ 建议无shell能力的不要轻易使用，当然你可以找别人写好适配了这个docker镜像的脚本直接远程配置
+     上面写了这么多如果还看不懂，不建议使用该变量功能。
_______
! 2021-01-04更新
! 企鹅阅读作者更新脚本后不再需要单独的开箱任务所以去掉对应相关配置
! 增企鹅阅读通知开关控制环境变量QQREAD_NOTIFYTTT(0为关闭外部推送，1为12 23 点外部推送,默认为1)、QQREAD_NOTIFY_INTERVAL(0为关闭通知，1为所有通知，2为12 23 点通知  ， 3为 6 12 18 23 点通知，默认为2)
_______
! 2021-01-04更新 增加每个脚本对应的自定义定时任务的环境变量
! 喜马拉雅极速版：XMLY_CRON、企业阅读：QQREAD_CRON、企鹅阅读开箱：QQREAD_OPENBOX_CRON、汽车之家：QCZJ_CRON、百度极速版：BAIDU_CRON、sunert的聚看点：JUKAN_CRON、shylocks的聚看点：JKD_CRON
! 具体说明看每个上面每个脚本的环境变量解释
_______
! 2021-01-02更新
! 所有脚本脚本定时任务都由脚本判断环境变量是否存在来决定增加定时任务
_______
! 2020-12-19更新
! 增加自定义任务配置
! 使用自定义定任务之后，上面volumes挂载之后这里配置对应的文件名
! CUSTOM_LIST_FILE=my_crontab_list.sh #自定任务文件名
! CUSTOM_LIST_MERGE_TYPE=append #默认值append自定文件的使用方式append追加默认之后，overwrite覆盖默认任务
```
# 使用说明
> 前提：   
> 一台安装好docker的主机   
> 这里只介绍`docker-compose`使用方式

### `docker-compose` 安装
```shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 1. 创建一个目录`my_scripts`用于存放备份配置等数据，迁移重装的时候只需要备份整个`my_scripts`目录即可（`my_scripts`目录名字自己随意定义）
> 需要新建的目录文件结构参考如下:
```
my_scripts
├── logs/
└── docker-compose.yml
```
### 1. 在`my_scripts`目录创建`logs`目录存放日志;
### 2. 在`my_scripts`目录创建`docker-compose.yml` ~command:参数不再需要~参考内容如下([或者直接复制这个文件内容修改](https://raw.githubusercontent.com/iouakira/someDockerfile/master/pack_some_script/docker-compose.yml))：
```yaml
my_script:
  image: akyakya/pack_some_script:latest
  container_name: my_script
  restart: always
  tty: true
  volumes:
    - ./logs:/logs
    # - ./my_crontab_list.sh:/pss/my_crontab_list.sh #挂载自定义任务文件
  environment:
    #20201219增加自定义任务配置
    #使用自定义定任务之后，上面volumes挂载之后这里配置对应的文件名
    # - CUSTOM_LIST_FILE=my_crontab_list.sh #自定任务文件名
    # - CUSTOM_LIST_MERGE_TYPE=append #默认值append自定文件的使用方式append追加默认之后，overwrite覆盖默认任务
    # 注意环境变量填写值的时候一律不需要引号（""或者''）下面这些只是事例，根据自己的需求增加删除
    # 公用通知相关环境变量
    # server酱服务
    - PUSH_KEY=
    # bark服务
    - BARK_PUSH=
    # bark服务通知声音
    - BARK_SOUND=
    # tg通知bot token
    - TG_BOT_TOKEN=
    # tg通知用户id
    - TG_USER_ID=
    # 钉钉通知bot token
    - DD_BOT_TOKEN=
    - DD_BOT_SECRET=
    # 喜马拉雅极速版相关，原作者使用\n换行传入多个cookie，脚本里面没有处理环境变量转译，改为用|来连接多个cookies
    - XMLY_ACCUMULATE_TIME=1 #设置为1开启刷时长，0为关闭刷时长
    - XMLY_NOTIFY_TIME=18 #喜马拉雅通知时间，要填写2位，例如8点就写08，默认为19
    - XMLY_SPEED_COOKIE=cookie1
                        | cookie2
                        | cookie2
    # 企鹅阅读相关
    #多账号 cookies连接符号，不配置默认为|，自己有能力调整排错的可以尝试自定义,因为汽车之家body里面呢包含| ,使用汽车之家建议改为|&|，否则会汽车之家任务无法执行
    - COOKIES_SPLIT=|&|
    - QQREAD_NOTIFY_TIME=19  #企鹅阅读通知时间，默认为19
    #上面COOKIES_SPLIT配置的什么下面用什么连接多个qqreadbodyVal
    - QQREAD_BODY=qqreadbodyVal1
                   |qqreadbodyVal2
                   |qqreadbodyVal3
    #上面COOKIES_SPLIT配置的什么下面用什么连接多个qqreadtimeurlVal
    - QQREAD_TIMEURL=qqreadtimeurlVal1
                    |qqreadtimeurlVal2
                    |qqreadtimeurlVal3
    #上面COOKIES_SPLIT配置的什么下面用什么连接多个qqreadtimeheaderVal
    - QQREAD_TIMEHD=qqreadtimeheaderVal1
                   |qqreadtimeheaderVal2
                   |qqreadtimeheaderVal3docke
    # 汽车之家需要抓包配置的环境变量
    # GetUserInfourl  对应环境变量配置为：QCZJ_GetUserInfoURL
    # GetUserInfoheader  对应环境变量配置为：QCZJ_GetUserInfoHEADER
    # coinbody  对应环境变量配置为：QCZJ_coinBODY
    # accountManageheader  对应环境变量配置为：QCZJ_accountManageHEADER
    # taskbody  对应环境变量配置为：QCZJ_taskBODY
    # activitybody  对应环境变量配置为：QCZJ_activityBODY
    # addCoinbody  对应环境变量配置为：QCZJ_addCoinBODY
    # addCoin2body  对应环境变量配置为：QCZJ_addCoin2BODY
    # reportAssbody  对应环境变量配置为：QCZJ_reportAssBODY
    # reportAssheader  对应环境变量配置为：QCZJ_reportAssHEADER
    # cointowalletbody  对应环境变量配置为：QCZJ_cointowalletBODY
    - QCZJ_GetUserInfoURL=QCZJ_GetUserInfoURL1
                      |&|QCZJ_GetUserInfoURL2
    - QCZJ_GetUserInfoHEADER=QCZJ_GetUserInfoHEADER1
                      |&|QCZJ_GetUserInfoHEADER2
    - QCZJ_coinBODY=QCZJ_coinBODY1
                  |&|QCZJ_coinBODY2
    - QCZJ_accountManageHEADER=QCZJ_accountManageHEADER1
                  |&|QCZJ_accountManageHEADER2
    - QCZJ_taskBODY=QCZJ_taskBODY1
                  |&|QCZJ_taskBODY2
    - QCZJ_activityBODY=QCZJ_activityBODY1
                  |&|QCZJ_activityBODY2
    - QCZJ_addCoinBODY=QCZJ_addCoinBODY1
                  |&|QCZJ_addCoinBODY2
    - QCZJ_addCoin2BODY=QCZJ_addCoin2BODY1
                  |&|QCZJ_addCoin2BODY2
    - QCZJ_reportAssHEADER=QCZJ_reportAssHEADER1
                  |&|QCZJ_reportAssHEADER2
    - QCZJ_reportAssBODY=QCZJ_reportAssBODY1
                  |&|QCZJ_reportAssBODY2
    - QCZJ_cointowalletBODY=QCZJ_cointowalletBODY1
                  |&|QCZJ_cointowalletBODY2
```
### 目录文件配置好之后在 `my_scripts`目录执行  
 `docker-compose up -d` 启动；  
 `docker-compose logs` 打印日志；(中文乱码可看英文输出就行，或者使用 `docker logs my_script` 查看)  
 `docker-compose pull` 更新镜像；  
 `docker-compose stop` 停止容器；  
 `docker-compose restart` 重启容器；  
 `docker-compose down` 停止并删除容器；  
