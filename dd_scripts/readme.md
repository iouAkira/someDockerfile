### 使用说明
```shell
/help 查看帮助获取快捷指令
/spnode 选择执行JS脚本文件 
/logs 选择下载日志文件 
/bl 查看对应cookie收支图表 例如：/bl 1 查看第一个cookie
/env 更新或者替换env.sh内的环境变量 例：/env aaa="bbb"
/cmd 执行任何想要执行的命令 例：/cmd ls -l 
/ak 添加/更新快捷回复键盘 例：/ak 键盘显示===/cmd echo 'show reply keyboard' 
/dk 删除快捷回复键盘 例：/dk 键盘显示 
/clk 清空快捷回复键盘 例：/clk
/dl 通过链接下载文件 例：/dl https://raw.githubusercontent.com/iouAkira/someDockerfile/master/dd_scripts/shell_mod_script.sh
/renew 通过cookies_wskey.list的wskey更新cookies.list 例如：/renew 1  更行cookies_wskey.list里面的第一个ck
```
- 配置参考
```sh
dd
├── data
│   ├── logs
│   │   └── xxxxx.log
│   ├── env.sh
│   ├── cookies_wskey.list
│   ├── cookies.list
│   ├── genCodeConf.list
│   ├── my_crontab_list.sh
│   └── replyKeyboard.list
└── docker-compose.yml
```
- `env.sh`文件参考（https://github.com/iouAkira/someDockerfile/blob/master/dd_scripts/env.sh）
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
    - TG_BOT_TOKEN=14*******************Q2Y
    - TG_USER_ID=1*********6
    - RANDOM_DELAY_MAX=20
```
