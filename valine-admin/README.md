# Usage
使用`dockercc-compse up -d`,`yaml`文件参考如下
```
valine_admin:
  image: akyakya/valine-admin
  container_name: valine_admin
  restart: always
  ports:
    - 3000:3000
  environment:
    #认证
    - LEANCLOUD_APP_ID=xxxx-xxx
    - LEANCLOUD_APP_KEY=xxxx
    - LEANCLOUD_APP_MASTER_KEY=xxxx
    #站点
    - SITE_NAME=xxxx
    - SITE_URL=https://xxxx.com
    #Email配置
    - SMTP_SERVICE=Gmail
    - SMTP_HOST=smtp.gmail.com
    - SMTP_PORT=465
    - SMTP_USER=xxxx
    - SMTP_PASS=xxxx
    #邮件配置
    - SENDER_NAME=xxxx
    - SENDER_EMAIL=xxxx
    - BLOGGER_EMAIL=xxxx
    - ADMIN_URL=https://xxxx.xxxx.com
    #邮件主题模版,内容模版因为太长了，环境变量还要转译，所以就用默认的了
    - MAIL_SUBJECT_ADMIN=\${SITE_NAME}上有新评论了
    - MAIL_SUBJECT=\${PARENT_NICK}，您在\${SITE_NAME}上的评论收到了回复
  extra_hosts:
    - "mainhost:172.17.0.1"
  command:
    - /bin/sh
    - -c
    - |
      crond
      node server.js
```
`environment:`下面的环境变量跟在`leancloud`里面配的一样就行.
