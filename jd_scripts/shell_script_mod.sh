#!/bin/sh
#@shylocks仓库脚本
function initShylocks() {
    git clone https://github.com/shylocks/Loon.git /shylocks
    npm install
}

 if [ ! -d "/shylocks/" ]; then
    echo "未检查到shylocks仓库脚本，初始化下载相关脚本"
    initShylocks
else
    echo "更新shylocks脚本相关文件"
    git -C /shylocks reset --hard
    git -C /shylocks pull --rebase
    npm install
fi

##复制两个文件
cp -f /shylocks/jd*.js /scripts/

##使用自定义shell下载并配置执行美妆
echo "10 8,9,10 * * * node /scripts/jd_mh.js |ts >> /scripts/logs/jd_mh.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行宝洁美发屋
echo "1 8,9 14-31/1 1 * node /scripts/jd_bj.js |ts >> /scripts/logs/jd_bj.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行京东粉丝专享
echo "1 7 * * * node /scripts/jd_wechat_sign.js |ts >> /scripts/logs/jd_wechat_sign.log 2>&1" >> /scripts/docker/merged_list_file.sh
##使用自定义shell下载并配置执行京东粉丝专享
echo "1 7 * * * node /scripts/jd_ms.js |ts >> /scripts/logs/jd_ms.log 2>&1" >> /scripts/docker/merged_list_file.sh
#神券京豆
echo "1 7 13 1 * node /scripts/jd_super_coupon.js |ts >> /scripts/logs/jd_super_coupon.log 2>&1" >> /scripts/docker/merged_list_file.sh
#工业爱消除
echo "30 * * * * node /scripts/jd_gyec.js |ts >> /scripts/logs/jd_gyec.log 2>&1" >> /scripts/docker/merged_list_file.sh
#小鸽有礼
echo "5 7 * * * node /scripts/jd_xg.js |ts >> /scripts/logs/jd_xg.log 2>&1" >> /scripts/docker/merged_list_file.sh

# #临时增加红包雨
echo "58,59 18-20/1 * * * git -C /shylocks reset --hard && git -C /shylocks pull --rebase" >> /scripts/docker/merged_list_file.sh
echo "0,1 19-21/1 * * * node /scripts/jd_live_redrain2.js |ts >> /scripts/logs/jd_live_redrain2.log 2>&1" >> /scripts/docker/merged_list_file.sh
echo "30,31 20-23/1 19 1 * node /scripts/jd_live_redrain.js |ts >> /scripts/logs/jd_live_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh

#由于bookshop作者还没有增加互助码环境变量，就自己手动sed进去了
sed -i "s/shareCodesArr = \[\]/shareCodesArr = \['a25442c9de1a47ddbe4cd3c4828bd8ea@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@a25442c9de1a47ddbe4cd3c4828bd8ea'\]/g" /scripts/jd_bookshop.js
