# -*- coding: utf-8 -*-
# @Author    : iouAkira(lof)
# @mail      : e.akimoto.akira@gmail.com
# @CreateTime: 2021-03-31
# @UpdateTime: 2021-03-31
import asyncio
import logging
import math
import re
from pathlib import Path

from aiogram import types

# 日志输出格式配置
logging.basicConfig(format='%(asctime)s-%(name)s-%(levelname)s=> [%(funcName)s] %(message)s ', level=logging.INFO)
logger = logging.getLogger(__name__)


async def get_path_file(file_dir):
    """
    返回一个目录下的js文件个数，文件名列表
    :param file_dir: 文件夹路径
    :return: js文件个数，文件名列表
    """

    btn_data_list = []
    btn_cnt = 0
    if Path(file_dir).is_dir():
        files = Path(file_dir).absolute().iterdir()
        for full_path_name in files:
            split_full_name = re.split(r"\W+", str(full_path_name))
            logger.info(full_path_name)
            if 'js' in split_full_name:
                split_full_name.remove('js')
                if split_full_name[-1].startswith('jd_') or split_full_name[-1].startswith('jx_'):
                    btn_data_list.append(str(full_path_name).replace(".js", ""))
                    btn_cnt += 1
    elif Path(file_dir).is_file():
        with open(file_dir, 'r') as taskf:
            lines = taskf.readlines()
            # logger.info(lines)
            for line in lines:
                if line.startswith("#") \
                        or line.strip() == "" \
                        or line.find("auto_help.sh") > -1 \
                        or line.find("sharecodeCollection") > -1:
                    pass
                else:
                    btn_data_list.append(
                        ' '.join(line.split(">>")[0].split()[5:]).replace(".js", "").replace("|ts", ""))

    return btn_cnt, btn_data_list


async def gen_reply_markup_btn(interactive_cmd, scripts_file_path, row_btn_cnt, callback_data_prefix=""):
    """
    根据传入的指令/或者callback data生成不同的keyboard_markup
    :param interactive_cmd
    :param scripts_file_path
    :param row_btn_cnt
    :param callback_data_prefix
    :return keyboard_markup
    """
    keyboard_markup = types.InlineKeyboardMarkup(row_width=10)
    button_cnt, button_data_list = await get_path_file(scripts_file_path)
    for i in range(math.ceil(len(button_data_list) / row_btn_cnt)):
        ret = button_data_list[0:row_btn_cnt]
        row_btn = []
        for ii in ret:
            logger.info(ii)
            row_btn.append(
                types.InlineKeyboardButton(text=ii.split("/")[-1], callback_data=f"{interactive_cmd} {ii}"))
            button_data_list.remove(ii)
        keyboard_markup.row(*row_btn)
    return keyboard_markup


async def exec_script(command="", log_dir="/scripts/logs"):
    """
    指令按钮选中的要执行
    :param command: 执行的指令
    :param log_dir: 超长时候输出的日志目录
    :return: 是超长，执行结果/日志路径
    """
    is_long = False
    cmd = command + "|ts"
    logger.info(cmd)
    try:
        proc = await asyncio.create_subprocess_shell(cmd,
                                                     stdout=asyncio.subprocess.PIPE,
                                                     stderr=asyncio.subprocess.PIPE)
        stdout, stderr = await proc.communicate()
        if stdout:
            out_text = stdout.decode("utf-8")
            if len(out_text.split('\n')) > 50:
                is_long = True
                file_name = re.split(r"\W+", cmd)
                if 'js' in file_name:
                    file_name.remove('js')
                log_name = '%s/bot_%s_%s.log' % (log_dir, file_name[-1])
                with open(log_name, 'w') as wf:
                    wf.write(out_text)
                out_text = log_name
        if stderr:
            out_text = "stderr：" + stderr.decode("utf-8")
    except Exception as e:
        out_text = "%s任务执行出错：%s" % (cmd, e)
    # logger.info(out_text)
    return is_long, out_text
