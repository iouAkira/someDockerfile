##下面只是做一个示例
##使用自定义shell下载并配置执行农场
wget -O /scripts/jx_nc.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_nc.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "10 9,18 * * * node /scripts/jx_nc.js |ts >> /scripts/logs/jx_nc.log 2>&1" >> /scripts/docker/merged_list_file.sh

#临时增加红包雨
echo "28,29 20-23/1 * * * wget -O /scripts/jd_live_redrain.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_live_redrain.js " >> /scripts/docker/merged_list_file.sh
echo "30,31 20-23/1 * * * node /scripts/jd_live_redrain.js |ts >> /scripts/logs/jd_live_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
