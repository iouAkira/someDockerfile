### 使用说明须知
- 该版本bot功能虽然提供了cookie扫码自动写入生效并测试的功能，但是代码 __`不开源`__、__`不开源`__、__`不开源`__， __请慎重__、 __请慎重__、 __请慎重__(不排除被我钓鱼的可能呢🎣)，而且有判断如果是奸商牟利的并无法使用该功能
- 配置参考
![image](https://user-images.githubusercontent.com/6993269/119672910-8b236f00-be6d-11eb-8786-f58eff84c039.png)
```sh
dd
├── data
│   ├── logs
│   │   └── xxxxx.log
│   ├── env.sh
│   ├── cookies.list
│   ├── genCodeConf.list
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
    - TG_BOT_TOKEN=14*******************Q2Y
    - TG_USER_ID=1*********6
    #随机延迟配置该配置在spnode之外,如果要使用不能配置在env.sh,需要配置在docker-compose里面
    - RANDOM_DELAY_MAX=20
```
