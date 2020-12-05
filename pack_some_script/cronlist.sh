#Docker镜像版本检查更新通知任务
5 * * * * cd /checkUpdate && python3 update_notify.py
#喜马拉雅极速版相关任务
*/30 * * * * cd /xmly_speed && python3 xmly_speed.py |ts >> /logs/xmly_speed.log 2>&1
##企鹅阅读小程序相关任务
57 * * * * cd /qqread && git pull |ts >> /logs/qqread.log 2>&1
*/11 * * * * cd /qqread && node Task/qqreads.js |ts >> /logs/qqread.log 2>&1
