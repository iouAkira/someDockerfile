# 使用方式
### Usage
> 推荐使用`docker-compose`所以这里只介绍`docker-compose`使用方式

- `docker-compose` 安装
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
# 你要使用这个docker镜像的前提是你必须知道在linux使用rclone或者gclone
### 创建一个目录`gd-utils`用于存放备份配置等数据，迁移重装的时候只需要备份整个`gd-utils`目录即可
需要新建的目录文件结构参考如下:
```
gd-utils
├── docker-compose.yml
├── config.js
├── gdurl.sqlite
└── sa
    ├── 01f4a79*******************8c9a296d.json
    ├── 02b2f51*******************d7a054e3.json
    ├── 02c190f*******************ce3c2abc.json
    └── 0352842*******************2c3e2b6b.json
```

- `gd-utils/docker-compose.yml` 参考内容如下：
```yaml
gd-utils:
  image: akyakya/gd-utils
  container_name: gd-utils
  restart: always
  privileged: true
  volumes:
    - ./sa/:/root/gd-utils/sa/
    - ./config.js:/root/gd-utils/config.js
    - ./gdurl.sqlite:/root/gd-utils/gdurl.sqlite
  ports:
    - 23333:23333
```
- `gd-utils/config.js` 参考 作者项目里面的[__*cnofig.js*__](https://github.com/iwestlin/gd-utils/blob/master/config.js)

- `gd-utils/gdurl.sqlite` 直接下载 作者项目里面的[__*gdurl.sqlite*__](https://github.com/iwestlin/gd-utils/blob/master/config.js)
- `gd-utils/sa` 文件夹里面里面的json应该不用的赘述了。

- 目录文件配置好之后在 `gd-utils`目录执行  
 `docker-compose up -d` 启动；  
 `docker-compose logs` 查看打印日志；  
 `docker-compose pull` 更新镜像；  
 `docker-compose stop` 停止容器；  
 `docker-compose restart` 重启容器；  
 `docker-compose down` 停止并删除容器；  

- 这个docker镜像只启动服务，nginx webhook 等还需要参考是原作者的 [【说明文档】](https://github.com/iwestlin/gd-utils#bot%E9%85%8D%E7%BD%AE)

