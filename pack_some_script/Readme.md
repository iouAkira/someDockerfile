[![dockeri.co](https://dockeri.co/image/akyakya/pack_some_script)](https://hub.docker.com/r/akyakya/pack_some_script)
# 打包一些比较好薅的羊毛脚本
> ### Cookie获取相关教程请查看原作者仓库教程
- ### 喜马拉雅极速版 作者：[__@Zero-S1__](https://github.com/Zero-S1)｜[__仓库地址__](https://github.com/Zero-S1/xmly_speed)
- ### 企鹅阅读(QQ小程序) 作者：[__@ziye12__](https://github.com/ziye12)｜[__仓库地址__](https://github.com/ziye12/JavaScript)
- ### 汽车之家极速版 作者：[__@ziye12__](https://github.com/ziye12)｜[__仓库地址__](https://github.com/ziye12/QCZJSPEED)
___
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
