from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackQueryHandler
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
import telegram.utils.helpers as helpers
import logging
import sys
import subprocess

# 启用日志
logging.basicConfig(format='%(asctime)s-%(name)s-%(levelname)s-%(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

admin_id = '---'


# 日志装饰器
def lof_logger(func):
    def wrapper(update, context, *args):
        logging.info(" Message Info ==> %s \n error ==> %s" % (update.message, context.error))
        func(update, context, *args)

    return wrapper


def start(update, context):
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        context.bot.send_message(chat_id=update.effective_chat.id,
                                 text='%s\n%s\n%s\n%s' % ('限制自己使用的Google Drive 转存机器人',
                                                        '/start 开始',
                                                        '/copy 转存Google drive文件。参考：/copy 要复制的文件夹ID 自己盘ID /绝对路径目录/',
                                                        '/bash 执行执行命令 /bash完整的命令就行。参考：/bash ls -l'))
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


@lof_logger
def copy(update, context):
    from_user_id = update.message.from_user.id

    if admin_id == str(from_user_id):
        commands = update.message.text.split()
        commands.remove('/copy')
        if len(commands) == 3:
            command = 'gclone copy gc:{%s} gc:{%s}%s --drive-server-side-across-configs -v' % (
                commands[0], commands[1], commands[2])
            rsl = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE,
                                   universal_newlines=True)

            while True:
                next_line = rsl.stdout.readline()
                update.message.reply_text(text=str(next_line.strip()))
                if next_line == '' and rsl.poll() is not None:
                    break
        else:
            update.message.reply_text(text='copy指令格式错误，请重新发送！\n 参考：/copy 要复制的文件夹ID 自己盘ID /绝对路径目录/')
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


@lof_logger
def bash(update, context):
    from_user_id = update.message.from_user.id

    if admin_id == str(from_user_id):
        commands = update.message.text.split()
        commands.remove('/bash')
        if len(commands) > 1:
            command_list = ['ls', 'rclone', 'gclone', 'cat', 'history']
            if commands[0] in command_list:
                rsl = subprocess.Popen(' '.join(commands), shell=True, stdout=subprocess.PIPE,
                                       universal_newlines=True)

                while True:
                    next_line = rsl.stdout.readline()
                    update.message.reply_text(text=str(next_line.strip()))
                    if next_line == '' and rsl.poll() is not None:
                        break
            else:
                update.message.reply_text(text='bot 暂时不支持执行%s指令' % (commands[0]))
        else:
            update.message.reply_text(text='bash 指令格式错误，请重新发送！\n 参考：/bash ls -l')
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


@lof_logger
def unknown(update, context):
    from_user_id = update.message.from_user.id
    if admin_id == str(from_user_id):
        tg_user_name = "%s%s" % (
            update.message.from_user.last_name if update.message.from_user.last_name is not None else '',
            update.message.from_user.first_name)
        update.message.reply_text(text="🈲️%s 瞎输什么东西，是不是想挨揍。" % helpers.mention_html(from_user_id, tg_user_name),
                                  parse_mode=ParseMode.HTML)
    else:
        update.message.reply_text(text='此为私人使用bot,不能执行您的指令！')


def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)


def main():
    if len(sys.argv) < 3:
        print("Usage: cmd <admin telegram user id> <bot Token> ")
        exit(0)

    global admin_id
    admin_id = sys.argv[1]
    bot_token = sys.argv[2]

    # 创建更新程序并参数为你Bot的TOKEN。
    updater = Updater(bot_token, use_context=True)

    # 获取调度程序来注册处理程序
    dp = updater.dispatcher

    # 通过 start 函数 响应 '/start' 命令
    dp.add_handler(CommandHandler('start', start))

    # 通过 lucky 函数 响应 '/copy' 命令
    dp.add_handler(CommandHandler('copy', copy))

    # 通过 lucky 函数 响应 '/copy' 命令
    dp.add_handler(CommandHandler('bash', bash))

    # unknown函数来响应普通文本消息
    # dp.add_handler(MessageHandler(Filters.text, unknown))

    # unknown函数来响应普通文本消息
    # dp.add_handler(MessageHandler(Filters.photo, unknown))

    # 没找到对应指令
    dp.add_handler(MessageHandler(Filters.command, unknown))

    dp.add_error_handler(error)

    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    main()
