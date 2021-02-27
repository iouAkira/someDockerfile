# 打包 AutoSignMachine 签到脚本
- ### AutoSignMachine 作者：[__@lunnlew__](https://github.com/lunnlew)｜[__仓库地址__](https://github.com/lunnlew/AutoSignMachine/)


目录参考
```shell
autosign
├── cookies
│   └── unicom.json
├── custom_shell.sh
├── docker-compose.yml
└── logs
    ├── 52pojie.log
    ├── bilibili.log
    ├── default_task.log
    ├── unicom1.log
    ├── unicom2.log
    ├── unicom3.log
    └── unicom4.log
```
docker-compose 参考
```
autoSign:
  image: akyakya/autosign:latest
  container_name: autosign
  restart: always
  tty: true
  volumes:
    - ./cookies:/root/.AutoSignMachine
    - ./logs:/AutoSignMachine/logs
  environment:
    - ENABLE_UNICOM=True
    - UNICOM_CONFIG=/root/.AutoSignMachine/unicom.json #多账号配置json需要放在本地cookies文件夹里挂载到容器的/root/.AutoSignMachine文件件
    - UNICOM_PHONE=18*******5
    - UNICOM_PWD=9****5
    - UNICOM_APPID=1f7af72a********8808a045
    - ENABLE_BILIBILI=True
    - BILIBILI_ACCOUNT=e*******@gmail.com
    - BILIBILI_PWD=p******s
    - ENABLE_52POJIE=True
    - htVD_2132_auth=d9bdYfS*********ojcyLOu
    - htVD_2132_saltkey=M*******3
```
