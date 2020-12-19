#喜马拉雅极速版相关任务
*/30 * * * * cd /xmly_speed && python3 xmly_speed.py >> /logs/xmly_speed.log 2>&1
##企鹅阅读小程序相关任务
*/11 * * * * cd /qqread && node Task/qqreads.js >> /logs/qqread.log 2>&1
# 每2天的23:50分清理一次日志
50 23 */2 * * rm -rf /logs/*.log