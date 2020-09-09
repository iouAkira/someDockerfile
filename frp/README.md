### Docker image status:
![Automated build](https://img.shields.io/docker/cloud/build/akyakya/frp?label=&style=flat-square) 
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/akyakya/frp?&style=flat-square) 
![Docker Pulls](https://img.shields.io/docker/pulls/akyakya/frp?&style=flat-square)
### Usage
> 推荐使用`docker-compose`所以这里只介绍`docker-compose`使用方式

- `docker-compose` 安装
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
### 创建一个目录`frp`用于存放备份配置等数据，迁移重装的时候只需要备份整个`frp`目录即可
需要新建的目录文件结构参考如下:
```
frp
├── docker-compose.yml
├── frpc.ini
└── frps.ini
```
- `frp/docker-compose.yml` 做服务端参考内容如下：
```yaml
frp:
  image: akyakya/frp
  container_name: frp
  restart: always
  ports:
    - 3389:3389
    - 32400:32400
    - 60000:60000
    - 60001:60001
    - 60080:60080
    - 60443:60443
  volumes:
    - ./frps.ini:/frp/frps.ini
  command: ["-c", "/frp/frps.ini"]
```
- `frp/docker-compose.yml` 做客户端参考内容如下：
```yaml
frp:
  image: akyakya/frp
  container_name: frp
  restart: always
  ports:
    - 3389:3389
    - 32400:32400
    - 60000:60000
    - 60001:60001
    - 60080:60080
    - 60443:60443
  volumes:
    - ./frpc.ini:/frp/frpc.ini
  command: ["-c", "/frp/frpc.ini"]
```
- `frp/frps.ini` 参考内容如下：
```ini
# frps.ini
[common]
#与客户端绑定的进行通信的端口
bind_port = 60000
vhost_http_port = 60080
vhost_https_port = 60443
#管理面板端口
dashboard_port = 60001
# dashboard 管理面板用户名密码
dashboard_user = username
dashboard_pwd = password
#秘钥,客户端与服务端链接认证
token = token123

[x.frp]
type = http
custom_domains = x.frp.ayaya.com
```
- `frp/frpc.ini` 参考内容如下：
```ini
[common]
#VPS服务器ip  
server_addr = ip地址
#与VPS服务端frps.ini里配置bind_port一致
server_port = 60000
#与VPS服务端frps.ini里配置token
token = token123

[pc-rdp]
#pc穿透3389端口方便远程桌面使用
type = tcp
#PC的内网IP地址
local_ip = IP地址
local_port = 3389
remote_port = 3389

#公网通过ssh访问内部服务器  
[ssh]
#连接协议
type = tcp
#家里内网服务器ip
local_ip = IP地址
#家里ssh默认端口号
local_port = 22
#自定义的访问内部ssh端口号服务端里面不需要配置此端口，但是需要在docker-compose.yaml配置把这个端口映射出去
remote_port = 60022

#公网通过访问内部web服务器以http方式  
[x.frp]
type = http
#家里内网服务器ip
local_ip = IP地址
#家里内网web服务的端口号
local_port = 80
#外网通过 “域名 + frps.ini里面配置的 vhost_http_port ”访问内网80端口的服务 例如：http://x.frp.ayaya.com:60080
custom_domains = x.frp.ayaya.com
```

- 目录文件配置好之后在 `frp`目录执行  
 `docker-compose up -d` 启动；  
 `docker-compose logs` 查看打印日志；  
 `docker-compose pull` 更新镜像；  
 `docker-compose stop` 停止容器；  
 `docker-compose restart` 重启容器；  
 `docker-compose down` 停止并删除容器；  
