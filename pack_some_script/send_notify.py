import os
from os import replace
import time
import hmac
import hashlib
import base64
import urllib.parse
import json
import logging

import requests
from requests.exceptions import RequestException

# 参考@lxk0301仓库的https://github.com/lxk0301/jd_scripts/blob/master/sendNotify.js
# @iouAkira 参照改写的Python版本
# =======================================微信server酱通知设置区域===========================================
# 此处填你申请的SCKEY.
# 注：此处设置github action用户填写到Settings-Secrets里面(Name输入PUSH_KEY)
SCKEY = ''

# =======================================Bark App通知设置区域===========================================
# 此处填你BarkAPP的信息(IP/设备码，例如：https://api.day.app/XXXXXXXX)
# 注：此处设置github action用户填写到Settings-Secrets里面（Name输入BARK_PUSH）
BARK_PUSH = ''
# BARK app推送铃声,铃声列表去APP查看复制填写
# 注：此处设置github action用户填写到Settings-Secrets里面（Name输入BARK_SOUND , Value输入app提供的铃声名称，例如:birdsong）
BARK_SOUND = ''


# =======================================telegram机器人通知设置区域===========================================
# 此处填你telegram bot 的Token，例如：1077xxx4424:AAFjv0FcqxxxxxxgEMGfi22B4yh15R5uw
# 注：此处设置github action用户填写到Settings-Secrets里面(Name输入TG_BOT_TOKEN)
TG_BOT_TOKEN = ''
# 此处填你接收通知消息的telegram用户的id，例如：129xxx206
# 注：此处设置github action用户填写到Settings-Secrets里面(Name输入TG_USER_ID)
TG_USER_ID = ''

# =======================================钉钉机器人通知设置区域===========================================
# 此处填你钉钉 bot 的webhook，例如：5a544165465465645d0f31dca676e7bd07415asdasd
# 注：此处设置github action用户填写到Settings-Secrets里面(Name输入DD_BOT_TOKEN)
DD_BOT_TOKEN = ''
# 密钥，机器人安全设置页面，加签一栏下面显示的SEC开头的字符串
DD_BOT_SECRET = ''

# =======================================iGot聚合推送通知设置区域===========================================
# 此处填您iGot的信息(推送key，例如：https://push.hellyw.com/XXXXXXXX)
# 注：此处设置github action用户填写到Settings-Secrets里面（Name输入IGOT_PUSH_KEY）
IGOT_PUSH_KEY = ''

# Server酱环境变量
if ("PUSH_KEY" in os.environ):
    SCKEY = os.environ["PUSH_KEY"]

# BARK环境变量
if ("BARK_PUSH" in os.environ):
    if (os.environ["BARK_PUSH"].startswith('https') or os.environ["BARK_PUSH"].startswith('http')):
        # 兼容BARK自建用户
        BARK_PUSH = os.environ["BARK_PUSH"]
    else:
        BARK_PUSH = "https://api.day.app/%s" % os.environ["BARK_PUSH"]

    if ("BARK_SOUND" in os.environ):
        BARK_SOUND = os.environ["BARK_SOUND"]

# Telegram环境变量
if ("TG_BOT_TOKEN" in os.environ):
    TG_BOT_TOKEN = os.environ["TG_BOT_TOKEN"]

if ("TG_USER_ID" in os.environ):
    TG_USER_ID = os.environ["TG_USER_ID"]

# 钉钉环境变量
if ("DD_BOT_TOKEN" in os.environ):
    DD_BOT_TOKEN = os.environ["DD_BOT_TOKEN"]
    if ("DD_BOT_SECRET" in os.environ):
        DD_BOT_SECRET = os.environ["DD_BOT_SECRET"]

# iGot环境变量
if ("IGOT_PUSH_KEY" in os.environ):
    IGOT_PUSH_KEY = os.environ["IGOT_PUSH_KEY"]


def server_notify(title, content):
    '''
    Server酱发送通知
    '''
    if SCKEY:
        try:
            data = {
                "text": title,
                "desp": content.replace("\n", "\n\n")
            }
            resp = requests.post(
                "https://sc.ftqq.com/%s.send" % SCKEY, data=data).json()
            if (resp.get("errno") == 0):
                logger.info("server酱发送通知消息成功")
            elif (resp.errno == 1024):
                logger.error("PUSH_KEY 错误")
            else:
                logger.error("server酱发送通知消息失败\n%s" % resp)

        except Exception as err:
            logger.exception("server酱发送通知消息异常\n%s" % err)
    else:
        logger.info("您未提供server酱的SCKEY，取消微信推送消息通知")


def bark_notify(title, content):
    '''
    Bark发送通知
    '''
    if BARK_PUSH:
        try:
            resp = requests.get("%s/%s/%s" %
                                (BARK_PUSH, title, content)).json()
            if resp.get("code") == 200:
                logger.info("Bark APP发送通知消息成功")
            else:
                logger.error("Bark APP发送通知消息失败\n%s" % resp)
        except Exception as err:
            logger.exception("Bark发送通知消息异常\n%s" % err)
    else:
        logger.info("您未提供Bark的APP推送BARK_PUSH，取消Bark推送消息通知")


def tg_bot_notify(title, content):
    '''
    Telegram Bot发送通知
    '''
    if TG_BOT_TOKEN and TG_USER_ID:
        try:
            send_data = {"chat_id": TG_USER_ID, "text": title +
                         '\n\n'+content, "disable_web_page_preview": "true", "parse_mode": "MarkdownV2"}
            resp = requests.post(
                url="https://api.telegram.org/bot%s/sendMessage" % (TG_BOT_TOKEN), data=send_data).json()
            if resp.get("ok") == True:
                logger.info("Telegram发送通知消息完成。")
            elif resp.get("error_code") == 400:
                logger.error("请主动给bot发送一条消息并检查接收用户ID是否正确。")
            elif resp.get("error_code") == 401:
                logger.error("Telegram bot token 填写错误。")
            elif resp.get("error_code") == 429:
                logger.error("请求过多，请稍后重试。")
            else:
                logger.error("Telegram发送通知消息失败\n%s" % resp)
        except Exception as err:
            logger.exception("Telegram发送通知消息异常\n%s" % err)
    else:
        logger.info(
            "您未提供telegram机器人推送所需的TG_BOT_TOKEN和TG_USER_ID，取消telegram推送消息通知")
        return


def dd_bot_notify(title, content):
    '''
    钉钉Bot发送通知
    '''
    if DD_BOT_TOKEN:
        try:

            send_data = {
                "msgtype": "markdown",
                "markdown": {
                    "title": title,
                    "text": content,
                },
            }
            headers = {'Content-Type': 'application/json;charset=utf-8'}
            if DD_BOT_SECRET:
                timestamp = str(round(time.time() * 1000))
                secret_enc = DD_BOT_SECRET.encode('utf-8')
                string_to_sign = '{}\n{}'.format(timestamp, DD_BOT_SECRET)
                string_to_sign_enc = string_to_sign.encode('utf-8')
                hmac_code = hmac.new(secret_enc, string_to_sign_enc,
                                     digestmod=hashlib.sha256).digest()
                sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))

                resp = requests.post(
                    url="https://oapi.dingtalk.com/robot/send?access_token=%s&timestamp=%s&sign=%s" % (DD_BOT_TOKEN, timestamp, sign), data=json.dumps(send_data), headers=headers).json()
                if resp.get("errcode") == 0:
                    logger.info("钉钉发送通知消息完成。")
                else:
                    logger.error("钉钉发送通知消息失败\n%s" % resp)
            else:
                resp = requests.post(
                    url='https://oapi.dingtalk.com/robot/send?access_token=%s' % (DD_BOT_TOKEN), data=json.dumps(send_data), headers=headers).json
                if resp.get("errcode") == 0:
                    logger.info("钉钉发送通知消息完成。")
                else:
                    logger.error("钉钉发送通知消息失败\n%s" % resp)

        except Exception as err:
            logger.exception("钉钉发送通知消息异常\n%s" % err)
    else:
        logger.info('您未提供钉钉机器人推送所需的DD_BOT_TOKEN或者DD_BOT_SECRET，取消钉钉推送消息通知')


def igot_notify(title, content):
    '''
    iGot发送通知5fcb9db2f981cd049c0cf4a6
    '''
    if IGOT_PUSH_KEY:
        try:
            resp = requests.post(
                url="https://push.hellyw.com/%s?title=%s&content=%s" % (IGOT_PUSH_KEY.lower(), title, content)).json()
            if resp.get("ret") == 0:
                logger.info("iGot发送通知消息成功")
            elif resp.get("ret") == 201:
                logger.info("iGot发送通知消息失败，请使用系统分配的有效key")
            else:
                logger.error("iGot发送通知消息失败\n%s" % resp)
        except Exception as err:
            logger.exception("iGot发送通知消息异常\n%s" % err)
    else:
        logger.info('您未提供iGot的推送IGOT_PUSH_KEY，取消iGot推送消息通知')


def compare(a: str, b: str):
    '''
    比较两个版本的大小，需要按.分割后比较各个部分的大小
    '''
    lena = len(a.split('.'))  # 获取版本字符串的组成部分
    lenb = len(b.split('.'))
    a2 = a + '.0' * (lenb-lena)  # b比a长的时候补全a
    b2 = b + '.0' * (lena-lenb)

    for i in range(max(lena, lenb)):  # 对每个部分进行比较，需要转化为整数进行比较
        if int(a2.split('.')[i]) > int(b2.split('.')[i]):
            return a
        elif int(a2.split('.')[i]) < int(b2.split('.')[i]):
            return b
        else:  # 比较到最后都相等，则返回第一个版本
            if i == max(lena, lenb)-1:
                return a


def send_notify(title, content, fn_name):
    """
    统一发送
    """
    notified = ""
    # 文件可能不存在，默认初始化
    init_file = open("/pss/%s.txt" % fn_name, 'a')
    init_file.close()

    with open("/pss/%s.txt" % fn_name, 'r') as lines:
        array = lines.readlines()
        for i in array:
            items = i.split("=")
            if(items[0] == "NOTIFIED"):
                logger.info(items)
                notified = items[1]
    if(notified != time.strftime("%Y%m%d", time.localtime()) and time.localtime().tm_hour < 22 and time.localtime().tm_hour >= 8):
        with open("/pss/%s.txt" % fn_name, 'w+') as wf:
            wf.write("NOTIFIED=%s" %
                     time.strftime("%Y%m%d", time.localtime()))
        server_notify(title, content)
        bark_notify(title, content)
        tg_bot_notify(title, content)
        dd_bot_notify(title, content)
        igot_notify(title, content)
    else:
        logger.info("当日已发送，或者不在发送通知时间段内，取消发送通知。")


# 启用日志
logging.basicConfig(
    format='%(asctime)s-%(name)s-%(levelname)s==> %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)


def get_remote_context(check_name, file_name):
    """
    获取远程仓库里指定文件的内容

    参数
    check_name: 需要获取的数据名称，自定义，方便日志区分
    file_name: 要获取的文件名
    """
    get_success = True
    resp = ''
    try:
        resp = requests.get(
            url="https://github.com/iouAkira/someDockerfile/raw/master/pack_some_script/"+file_name, timeout=10)
    except RequestException as error:
        logger.warning(f"获取{check_name}内容时发生网络请求异常，尝试使用镜像仓库")
        try:
            resp = requests.get(
                url="https://raw.fastgit.org/iouAkira/someDockerfile/master/pack_some_script/"+file_name, timeout=10)
        except Exception as errot:
            logger.warning(f"使用镜像仓库网络请求异常，获取{check_name}内容失败。")
            get_success = False
    except Exception as error:
        logger.warning(f"网络请求错错误，获取{check_name}容失败。")
        get_success = False

    return resp, get_success


def normal_notify():
    """
    其他类普通的通知
    想好通知内容维护方式再写
    """
    if "NORMAL_CONTENT" in os.environ:
        send_notify("Docker镜像普通通知", "\n\n```%s```" %
                    os.environ["NORMAL_CONTENT"], "normal_notify")


def config_change_notify():
    """
    检查配置更新版本判断是否需要提醒用户更新更新配置
    想好通知内容维护方式再写
    """
    if "CONFIG_CHANGE_CONTENT" in os.environ:
        send_notify("⚠️Docker镜像配置参数更新通知", "\n\n```%s```" %
                    os.environ["CONFIG_CHANGE_CONTENT"], "config_change_notify")


def image_update_notify():
    """
    检查对比构建版本判断是否需要提醒用户更新镜像
    """
    if "IMAGE_UPDATE_CONTENT" in os.environ:
        send_notify("⚠️Docker镜像版本更新通知⚠️", "\n\n```%s```" %
                    os.environ["IMAGE_UPDATE_CONTENT"], "image_update_notify")


def main():
    normal_notify()
    image_update_notify()
    config_change_notify()


if __name__ == '__main__':
    main()
