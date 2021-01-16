#!/bin/sh

##下面只是做一个示例
##使用自定义shell下载并配置执行农场
# wget -O /scripts/jx_nc.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_nc.js
# echo -e >> /scripts/docker/merged_list_file.sh
# echo "10 9,18 * * * node /scripts/jx_nc.js |ts >> /scripts/logs/jx_nc.log 2>&1" >> /scripts/docker/merged_list_file.sh

# #临时增加红包雨
# echo "28,29 20-23/1 * * * wget -O /scripts/jd_live_redrain.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_live_redrain.js " >> /scripts/docker/merged_list_file.sh
# echo "30,31 20-23/1 * * * node /scripts/jd_live_redrain.js |ts >> /scripts/logs/jd_live_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh

##使用自定义shell下载并配置执行美妆
wget -O /scripts/jd_mh.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_mh.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "10 8,9,10 * * * node /scripts/jd_mh.js |ts >> /scripts/logs/jd_mh.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行宝洁美发屋
wget -O /scripts/jd_bj.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_bj.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "1 8,9 14-31/1 1 * node /scripts/jd_bj.js |ts >> /scripts/logs/jd_bj.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行京东粉丝专享
wget -O /scripts/jd_wechat_sign.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_wechat_sign.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "1 7 * * * node /scripts/jd_wechat_sign.js |ts >> /scripts/logs/jd_wechat_sign.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行京东粉丝专享
wget -O /scripts/jd_ms.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_ms.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "1 7 * * * node /scripts/jd_ms.js |ts >> /scripts/logs/jd_ms.log 2>&1" >> /scripts/docker/merged_list_file.sh
#神券京豆
wget -O /scripts/jd_super_coupon.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_super_coupon.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "1 7 13 1 * node /scripts/jd_super_coupon.js |ts >> /scripts/logs/jd_super_coupon.log 2>&1" >> /scripts/docker/merged_list_file.sh
#神券京豆
wget -O /scripts/jd_mh_super.js https://raw.githubusercontent.com/shylocks/Loon/main/jd_mh_super.js
echo -e >> /scripts/docker/merged_list_file.sh
echo "10 20 15 1 * node /scripts/jd_mh_super.js |ts >> /scripts/logs/jd_mh_super.log 2>&1" >> /scripts/docker/merged_list_file.sh


#由于bookshop作者还没有增加互助码环境变量，就自己手动sed进去了
sed -i "s/shareCodesArr = \[\]/shareCodesArr = \['a25442c9de1a47ddbe4cd3c4828bd8ea@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@a25442c9de1a47ddbe4cd3c4828bd8ea'\]/g" /scripts/jd_bookshop.js
