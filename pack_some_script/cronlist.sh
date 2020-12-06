#Docker镜像版本检查更新通知任务
2 * * * * wget https://raw.sevencdn.com/iouAkira/someDockerfile/master/pack_some_script/update_notify.py -O /checkUpdate/update_notify.py
2 * * * * wget https://raw.sevencdn.com/iouAkira/someDockerfile/master/pack_some_script/cronlist.sh -O /checkUpdate/cronlist.sh && crontab /checkUpdate/cronlist.sh
5 * * * * cd /checkUpdate && python3 update_notify.py  >> update_notify.log 2>&1
#喜马拉雅极速版相关任务
*/30 * * * * cd /xmly_speed && python3 xmly_speed.py |ts >> /logs/xmly_speed.log 2>&1
##企鹅阅读小程序相关任务
57 * * * * cd /qqread && git pull |ts >> /logs/qqread.log 2>&1
*/11 * * * * cd /qqread && node Task/qqreads.js |ts >> /logs/qqread.log 2>&1
