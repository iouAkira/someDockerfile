*/30 * * * * cd /xmly_speed && python3 xmly_speed.py >> /logs/xmly_speed.log 2>&1
*/11 * * * * cd /qeyd && node Scripts/qeyd_replace.js |ts >> /logs/qeyd.log 2>&1
