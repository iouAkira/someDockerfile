# 使用方式
### Docker image status:
![Automated build](https://img.shields.io/docker/cloud/automated/akyakya/gclone-tg-bot?style=flat-square)![Build Status](https://img.shields.io/docker/cloud/build/akyakya/gclone-tg-bot?label=&style=flat-square)   ![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/akyakya/gclone-tg-bot?&style=flat-square)   ![Docker Pulls](https://img.shields.io/docker/pulls/akyakya/gclone-tg-bot?&style=flat-square)
### Usage
> 推荐使用`docker-compose`所以这里只介绍`docker-compose`使用方式

- `docker-compose` 安装
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
# 你要使用这个docker镜像的前提是你必须知道在linux使用rclone或者gclone
### 创建一个目录`gclone-tg-bot`用于存放备份配置等数据，迁移重装的时候只需要备份整个`gclone-tg-bot`目录即可
需要新建的目录文件结构参考如下:
```
gclone-tg-bot
├── docker-compose.yml
├── rclone.conf
├── accounts
│   ├── 01f4a792*******************0ee008c9a296d.json
│   ├── 02b2f51d*******************877b7d7a054e3.json
│   ├── 02c190f0*******************cea418c3c2abc.json
│   ├── 03528429*******************2c8bd3e2c5b6b.json
│   ├── 0be4abd6*******************cac659419cecd.json
│   └── 0fbc8d02*******************1a10b2ed4bd6d.json

```
- `gclone-tg-bot/docker-compose.yml` 参考内容如下：
```yaml
gclone:
  image: akyakya/gclone-tg-bot
  container_name: gclone
  restart: always
  privileged: true
  volumes:
    - ./:/root/.config/rclone/
  command: ["admin_id","bot_token"] #admin_id:使用这个bot的tg用户id,bot_token:你的bot的token
```
- `gclone-tg-bot/rclone.conf` 参考内容如下（事实上你要使用这个docker镜像的前提是你必须会在linux使用rclone或者gclone）：
```
#该文件存放目录为 /root/.config/rclone/rclone.conf
#gclone可以使用的配置
[gc]
type = drive
scope = drive
service_account_file = /root/.config/rclone/accounts/01f4a792*******************0ee008c9a296d.json
service_account_file_path = /root/.config/rclone/accounts/
root_folder_id = 0A**********9PVA
#rclone可以使用的配置
[rc]
type = drive
client_id = 763***********************.apps.googleusercontent.com
client_secret = c8br*********4Q4A
scope = drive
token = {"access_token":"************","token_type":"Bearer","refresh_token":"******************","expiry":"2020-06-11T15:38:53.38274+08:00"}
team_drive = 0A**********9PVA
```
- 目录文件配置好之后在 `gclone-tg-bot`目录执行  
 `docker-compose up -d` 启动；  
 `docker-compose logs` 查看打印日志；  
 `docker-compose pull` 更新镜像；  
 `docker-compose stop` 停止容器；  
 `docker-compose restart` 重启容器；  
 `docker-compose down` 停止并删除容器；  
- 私聊你的`bot`发送`/start`指令开始使用