*/30 * * * * cd /xmly_speed && python3 xmly_speed.py |ts >> /logs/xmly_speed.log 2>&1
*/11 * * * * cd /qeyd/Script && node qeyd_replace.js |ts >> /logs/qeyd.log 2>&1