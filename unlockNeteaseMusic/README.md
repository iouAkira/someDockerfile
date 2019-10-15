## 原有项目镜像的基础上加了`glider`将`http`服务转为`ss`服务，方便一些移动端APP使用。
### Usage
使用`docker-compose up -d`启动
`docker-compose.yml`文件参考：
```
unblockneteasemusic:
  image: akyakya/unlockneteasemusic-ss
  container_name: unem
  restart: always
  ports:
    - 8082:8082
  command:
    - /bin/sh
    - -c
    - |
      nohup ./glider -listen ss://AES-256-CFB:ss123456@:8082 -forward http://0.0.0.0:8080 -verbose >> glider.output.log 2>&1 &
      node app.js
```
启动后你就会有得到一个解锁网易云的`ss`服务，加密方式`AES-256-CFB`,密码`ss123456`,端口`8082`，IP`你的宿主机IP`
> glider 还可以转`SSR`、`VMess`等。具体可以看[Glider Usage](https://github.com/nadoo/glider#usage)，然后修改`nohup ./glider -listen ` 后面的参数就行。
