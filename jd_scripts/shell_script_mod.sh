#!/bin/sh
#@shylocks仓库脚本
function initShylocks() {
#     git clone https://github.com/shylocks/Loon.git /shylocks
    git clone https://github.com/Tartarus2014/Script.git /shylocks
}

 if [ ! -d "/shylocks/" ]; then
    echo "未检查到shylocks仓库脚本，初始化下载相关脚本"
    initShylocks
else
    echo "更新shylocks脚本相关文件"
    git -C /shylocks reset --hard
    git -C /shylocks pull --rebase
    #npm install --loglevel error
fi

##复制文件
cp -f /shylocks/jd*.js /scripts/

# #临时增加红包雨
echo "59,0,1,2,3,4,5 0,9,11,13,15,17,19,20,21,22,23 * * *  node /scripts/jd_live_redrain_offical.js|ts >> /scripts/logs/jd_live_redrain_offical.log 2>&1" >> /scripts/docker/merged_list_file.sh
echo "59,0,1,2,3,4,5 0,9,11,13,15,17,19,20,21,23 3,5,20-30/1 1,2 * node /scripts/jd_live_redrain_nian.js|ts >> /scripts/logs/jd_live_redrain_nian.log 2>&1" >> /scripts/docker/merged_list_file.sh
echo "29,30,31,32,33 12-23/1 * * * node /scripts/jd_live_redrain_half.js |ts >> /scripts/logs/jd_live_redrain_half.log 2>&1" >> /scripts/docker/merged_list_file.sh
echo "59,0,1,2,3,4,5 19-21/1 * * * node /scripts/jd_live_redrain2.js |ts >> /scripts/logs/jd_live_redrain2.log 2>&1" >> /scripts/docker/merged_list_file.sh
echo "29,30,31,32,33 20-23/1 28 1 * node /scripts/jd_live_redrain.js |ts >> /scripts/logs/jd_live_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh

#由于bookshop作者还没有增加互助码环境变量，就自己手动sed进去了
sed -i "s/shareCodesArr = \[\]/shareCodesArr = \['a25442c9de1a47ddbe4cd3c4828bd8ea@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@aba172068b7a46e2b6cf89563b919053','ed23af1e5a5946b381266b2192f8d4a2@a25442c9de1a47ddbe4cd3c4828bd8ea'\]/g" /scripts/jd_bookshop.js
