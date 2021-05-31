# -*- coding: utf-8 -*-
# @Author    : iouAkira(lof)
# @mail      : e.akimoto.akira@gmail.com

import os
import subprocess
from subprocess import TimeoutExpired
import logging
import re
from urllib.parse import quote, unquote

import telegram.utils.helpers as helpers
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackQueryHandler

# 启用日志
logging.basicConfig(format='%(asctime)s-%(name)s-%(levelname)s=> [%(funcName)s] %(message)s ', level=logging.INFO)
logger = logging.getLogger(__name__)

_base_dir = '/scripts/'
_logs_dir = '%slogs/' % _base_dir
_docker_dir = '%sdocker/' % _base_dir
_bot_dir = '%sbot/' % _docker_dir
_share_code_conf = '%sgen_code_conf.list' % _logs_dir


def resp_text(update, context):
    """
    监听用户输入的文本消息
    """
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        global url, body, shop_name
        logger.info(update.message)
        msg_text = update.message.text
        shop_name = re.findall(r"^(.+?) ", msg_text)

        for ent in update.message.entities:
            if str(ent.url).startswith("https://api.m.jd.com/client.action?functionId=liveDrawLotteryV842"):
                url = ent.url
                break

        if str(update.message.text).startswith("https://api.m.jd.com/client.action?functionId=liveDrawLotteryV842"):
            url = re.findall(r"已登陆京东）：(.+?)?$", msg_text)[0]
            body = re.findall(r"&body=(.+?)&", msg_text)[0]
            url = url.replace(body, quote(body))

        # logger.info(url)
        if str(url).startswith("https://api.m.jd.com/client.action?functionId=liveDrawLotteryV842"):
            try:
                logger.info(url)
                os.putenv('LIVE_LOTTERY_URL', url)
                cmd = f'node {_base_dir}jd_live_lottery.js {shop_name}'
                out_bytes = subprocess.check_output(
                    cmd, shell=True, timeout=600, stderr=subprocess.STDOUT)
                out_text = out_bytes.decode('utf-8')
                context.bot.sendMessage(text='```{}```'.format(
                    helpers.escape_markdown(out_text)),
                    chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
            except TimeoutExpired:
                context.bot.sendMessage(text='```{}```'.format(helpers.escape_markdown(f' →→→ {cmd} 执行超时 ←←← ')),
                                        chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
            except Exception as e:
                context.bot.sendMessage(
                    text='```{}```'.format(helpers.escape_markdown(f' →→→ {cmd} 执行出错，请检查确认命令是否正确 ←←← ')),
                    chat_id=update.effective_chat.id, parse_mode=ParseMode.MARKDOWN_V2)
                raise
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')



def main():
    global admin_id, bot_token, crontab_list_file

    bot_token = '505000000005:AAFcb0WIdfsdfsfsdf***********5Nvv9E'
    admin_id = '129702206'
    # 创建更新程序并参数为你Bot的TOKEN。
    updater = Updater(bot_token, use_context=True)
    # 获取调度程序来注册处理程序
    dp = updater.dispatcher
    # 响应普通文本消息
    dp.add_handler(MessageHandler(Filters.text, resp_text))

    dp.add_error_handler(error)
    updater.start_polling()
    updater.idle()


# 生成依赖安装列表
# pip3 freeze > requirements.txt
# 或者使用pipreqs
# pip3 install pipreqs
# 在当前目录生成
# pipreqs . --encoding=utf8 --force
# 使用requirements.txt安装依赖
# pip3 install -r requirements.txt
if __name__ == '__main__':
    main()
