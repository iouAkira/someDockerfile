## 原有项目镜像的基础上加了`glider`将`http`服务转为`ss`服务，方便一些移动端APP使用。
### Usage
使用`docker-compose up -d`启动
`docker-compose.yml`文件参考：
```
unblockneteasemusic:
  image: akyakya/unblockneteasemusic
  container_name: unem
  restart: always
  ports:
    - 8082:8082
  environment:
    ## sspassword替换为自己的密码
    - SS_PWD=sspassword
  command:
    - /bin/sh
    - -c
    - |
      nohup ./glider -listen ss://AES-256-CFB:$SS_PWD@:8082 -forward http://0.0.0.0:8080 -verbose >> glider.output.log 2>&1 &
      node app.js
```