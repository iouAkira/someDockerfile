### Docker image status:
![Automated build](https://img.shields.io/docker/cloud/build/akyakya/efb-v2?label=&style=flat-square)   
![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/akyakya/efb-v2?&style=flat-square)   
![Docker Pulls](https://img.shields.io/docker/pulls/akyakya/efb-v2?&style=flat-square)
### Usage
> 推荐使用`docker-compose`所以这里只介绍`docker-compose`使用方式

- `docker-compose` 安装
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
### 创建一个目录`ews-v2`用于存放备份配置等数据，迁移重装的时候只需要备份整个ews-v2目录即可
需要新建的目录文件结构参考如下:
```
ews-v2
├── blueset.telegram
│   ├── config.yaml
├── blueset.wechat
│   ├── config.yaml
├── config.yaml
└── docker-compose.yml
```
- `ews-v2/docker-compose.yml` 参考内容如下：
```yaml
ews_v2:
    image: akyakya/efb-v2
    container_name: ews-v2
    restart: always
    volumes:
        - .:/root/.ehforwarderbot/profiles/default/
        - /etc/localtime:/etc/localtime:ro
        - /etc/timezone:/etc/timezone:ro
```
- `ews-v2/config.yaml` 参考内容如下：
```yaml
master_channel: blueset.telegram
slave_channels:
    - blueset.wechat
middlewares:
    #- catbaron.link_preview    #根据自己的情况决定是否启用[使用参考]
    #- catbaron.mp_instanceview #根据自己的情况决定是否启用[使用参考](https://github.com/catbaron0/efb-mp-instanceview-middleware#enable)
```
- `ews-v2/blueset.wechat/config.yaml` 参考内容如下：
```yaml
flags:
    refresh_friends: true #每当请求会话列表时，强制刷新会话列表。默认值: false
    first_link_only: false #在收到多链接消息时，仅发送第一条链接。默认多链接会发送多条消息。默认值: false
    max_quote_length: -1 #引用消息中引文的长度限制。设置为 0 关闭引文功能。设置为 -1 则对引文长度不做限制。默认值: -1
    qr_reload: "master_qr_code" #重新登录时使用的登录方式 "console_qr_code": 将二维码和提示输出到系统标准输出（stdout）。默认"master_qr_code": 将二维码和提示发送到主端。 注意登录时二维码会频繁刷新，请注意二维码可能会导致刷屏.
    on_log_out: "command" #"idle": 仅通知用户。 "reauth": 通知用户，并立即开始重新登录。默认"command": 通知用户，并等待用户启动重新登录过程。
    imgcat_qr: false #使用 iTerm2 图像协议 显示二维码。本功能只适用于 iTerm2 用户。默认false
    delete_on_edit: true #以撤回并重新发送的方式代替编辑消息。默认禁止编辑消息。默认false
    app_shared_link_mode: "image" #"ignore"：忽略附带的缩略图"upload"：将缩略图上传到公开图床（https://sm.ms），并在日志中输出图片的删除链接.默认"image"：将消息以图片形式发送（不推荐）
    puid_logs: null # 输出 PUID 相关日志到指定日志路径。请使用绝对路径。PUID 日志可能会根据会话数量和消息吞吐量而占用大量存储空间。默认null
    send_stickers_and_gif_as_jpeg: false #以 JPEG 图片方式发送自定义表情和 GIF，用于临时绕过微信网页版的自定义表情限制。默认false
    system_chats_to_include: "filehelper" # 在默认会话列表中显示的特殊系统会话。其内容仅能为 默认 filehelper（文件传输助手）、fmessage（朋友推荐消息）、newsapp（腾讯新闻）、weixin（微信团队）其中零到四个选项。
    user_agent: null #指定登陆网页版微信时所使用的「用户代理」（user agent）字符串。不指定则使用 itchat 提供的默认值。 默认null
```

- `ews-v2/blueset.telegram/config.yaml` 参考内容如下
```yaml
token: "1111111:AAGFhy874QdsfdsfdsBPEomYgeGJUE"#替换为自己的bot Token
admins:
    - 2132132312 #替换为自己的Telegram UID 
flags:
    chats_per_page: 20 #选择/ chat和/ link命令时显示的聊天次数。过大的值可能导致这些命令的故障
    network_error_prompt_interval: 100 #每收到n个错误后再通知用户有关网络错误的信息。 设置为0可禁用它
    multiple_slave_chats: true #默认true #将多个远程聊天链接到一个Telegram组。使用未关联的聊天功能发送和回复。禁用以远程聊天和电报组一对一链接。
    prevent_message_removal: true  #当从通道需要删除消息时，如果此值为true，EFB将忽略该请求。
    auto_locale: true #自动从管理员的消息中检测区域设置。否则将使用在环境变量中定义的区域设置。
    retry_on_error: false #在向Telegram Bot API发送请求时发生错误时无限重试。请注意，这可能会导致重复的消息传递，因为Telegram Bot API的响应不可靠，并且可能无法反映实际结果
    send_image_as_file: false #将所有图片消息以文件发送，以积极避免 Telegram 对于图片的压缩。
    message_muted_on_slave: "mute" #normal:作为普通信息发送给Telegram silent:发送给Telegram作为正常消息，但没有通知声音 mute:不要发送给Telegram
    your_message_on_slave: "silent" #在从属通道平台上收到消息时的行为。这将覆盖message_muted_on_slave中的设置。
    animated_stickers: true #启用对动态贴纸的实验支持。注意：您可能需要安装二进制依赖 ``libcairo`` 才能启用此功能。
    send_to_last_chat: true #在未绑定的会话中快速回复。enabled：启用此功能并关闭警告。warn：启用该功能，并在自动发送至不同收件人时发出警告。disabled：禁用此功能。
```
- 目录文件配置好之后在 `ews-v2`目录执行  
 `docker-compose up -d` 启动；  
 `docker-compose logs` 打印日志扫码登录；  
 `docker-compose pull` 更新镜像；  
 `docker-compose stop` 停止容器；  
 `docker-compose restart` 重启容器；  
 `docker-compose down` 停止并删除容器；  
