# -*- coding: utf-8 -*-
# @Author    : iouAkira(lof)
# @mail      : ZS5ha2ltb3RvLmFraXJhQGdtYWlsLmNvbQ==
# @CreateTime: 2021-03-31
# @UpdateTime: 2021-04-03
import asyncio
import logging
import math
import os
import re
import subprocess
import time
from pathlib import Path

import requests
from MyQR import myqr
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
    logger.info(file_dir)
    if Path(file_dir).is_dir():
        files = Path(file_dir).absolute().iterdir()
        for full_path_name in files:
            split_full_name = re.split(r"\W+", str(full_path_name))
            # logger.info(full_path_name)
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
                    if 'RANDOM_DELAY_MAX' in os.environ:
                        btn_data_list.append(
                            ' '.join(line.split(">>")[0].split()[5:]).replace(".js", "").replace("|ts", "").split(";")[
                                -1])
                    else:
                        btn_data_list.append(
                            ' '.join(line.split(">>")[0].split()[5:]).replace(".js", "").replace("|ts", ""))
                    btn_cnt += 1

    return btn_cnt, btn_data_list


async def gen_reply_markup_btn(interactive_cmd="",
                               scripts_file_path="",
                               row_btn_cnt=2,
                               keyboard_type="inline"):
    """
    根据传入的指令/或者callback data生成不同的keyboard_markup
    :param keyboard_type:
    :param interactive_cmd
    :param scripts_file_path
    :param row_btn_cnt
    :return keyboard_markup
    """

    if keyboard_type == "reply":
        keyboard_markup = types.ReplyKeyboardMarkup(row_width=10, resize_keyboard=True, one_time_keyboard=False)
        button_cnt, button_data_list = 0, []
        try:
            with open("/data/replyKeyboard.list", "r") as keyboardf:
                lines = keyboardf.readlines()
                for line in lines:
                    if line.startswith("#") \
                            or line.strip() == "":
                        pass
                    else:
                        button_data_list.append(line)
                        button_cnt += 1

            for i in range(math.ceil(len(button_data_list) / row_btn_cnt)):
                ret = button_data_list[0:row_btn_cnt]
                row_btn = []
                for ii in ret:
                    row_btn.append(types.KeyboardButton(ii))
                    button_data_list.remove(ii)
                keyboard_markup.row(*row_btn)
        except Exception as e:
            logger.error(e)
            keyboard_markup.add(types.KeyboardButton(text="获取出错，请检查你的配置文件"))
        return keyboard_markup
    else:
        keyboard_markup = types.InlineKeyboardMarkup(row_width=10)
        button_cnt, button_data_list = await get_path_file(scripts_file_path)
        button_data_list.sort()
        for i in range(math.ceil(len(button_data_list) / row_btn_cnt)):
            ret = button_data_list[0:row_btn_cnt]
            row_btn = []
            for ii in ret:
                # logger.info(ii.split("/")[-1].split()[-1])
                row_btn.append(
                    types.InlineKeyboardButton(text=ii.split("/")[-1].split()[-1],
                                               callback_data=f"{interactive_cmd} {ii}"))
                button_data_list.remove(ii)
            keyboard_markup.row(*row_btn)
        return keyboard_markup


async def exec_script(command="", log_dir="/scripts/logs"):
    """
    指令按钮选中的要执行
    :param command: 执行的指令
    :param log_dir: 超长时候输出的日志目录
    :return: 是否超长，执行结果/日志路径
    """
    sp_cmd = ["sh", "docker_entrypoint.sh"]
    is_long = False
    out_text = ""
    cmd = command + " |ts " if command.split()[0] not in sp_cmd else command
    try:
        if not cmd.endswith("|ts"):
            logger.info(cmd)
            p = subprocess.Popen(cmd,
                                 shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
            while p.poll() is None:
                line = p.stdout.readline()
                logger.info(line.decode('utf-8'))
                out_text = out_text + line.decode('utf-8')
        else:
            proc = await asyncio.create_subprocess_shell(cmd=cmd,
                                                         stdout=asyncio.subprocess.PIPE,
                                                         stderr=asyncio.subprocess.PIPE)
            stdout, stderr = await proc.communicate()
            logger.info(stdout)
            logger.info(stderr)
            if stdout:
                out_text = stdout.decode("utf-8")
            if stderr:
                out_text = "stderr：" + stderr.decode("utf-8")

        if len(out_text.split('\n')) > 50:
            is_long = True
            file_name = re.split(r"\W+", command)
            logger.info(file_name)
            if 'js' in file_name:
                file_name.remove('js')
            log_name = f'{log_dir}/bot_{file_name[-1]}.log'
            with open(log_name, 'w') as wf:
                wf.write(out_text)
            out_text = log_name
    except Exception as e:
        out_text = f" {command} `任务执行出错：{e}`"
    # logger.info(out_text)
    return is_long, out_text


async def exec_sys_cmd(sh_cmd="node", log_dir="/scripts/logs"):
    """
    执行系统相关指令
    """
    sp_cmd = ["docker_entrypoint.sh"]
    is_long = False
    out_text = ''
    try:
        if sh_cmd.split()[0] in sp_cmd:
            p = subprocess.Popen(sh_cmd,
                                 shell=True,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
            while p.poll() is None:
                line = p.stdout.readline()
                logger.info(line.decode('utf-8'))
                out_text = out_text + line.decode('utf-8')
        else:
            proc = await asyncio.create_subprocess_shell(sh_cmd,
                                                         stdout=asyncio.subprocess.PIPE,
                                                         stderr=asyncio.subprocess.PIPE)
            stdout, stderr = await proc.communicate()
            logger.info(sh_cmd)
            if stdout:
                out_text = stdout.decode("utf-8")
            if stderr:
                out_text = "stderr：" + stderr.decode("utf-8")

        if len(out_text.split('\n')) > 50:
            is_long = True
            log_name = f'{log_dir}/bot_{sh_cmd.split()[0]}.log'
            with open(log_name, 'w') as wf:
                wf.write(out_text)
            out_text = log_name
    except Exception as e:
        out_text = f"任务执行出错：{e}"
    # logger.info(out_text)
    return is_long, out_text


def gen_code_msg_list(gen_code_cmd: str, gen_code_conf):
    """
    生成互助提交的消息
    """
    msg_list = []
    cmd_split = gen_code_cmd.split()
    try:
        bot_list, code_conf_list = get_code_conf(code_type=cmd_split[0].split("_")[1],
                                                 gen_code_conf=gen_code_conf,
                                                 activity_list=' '.join(cmd_split[1:]) if len(cmd_split) > 1 else '')
        for bot in list(set(bot_list)):
            for cf in code_conf_list:
                if cf.bot_id == bot:
                    msg_list.append(cf.get_submit_msg())
            msg_list.append(f"以上为 {bot} 可以提交的活动互助码")
    except Exception as e:
        msg_list.append(f"执行`{gen_code_cmd}`生成互助码消息失败，请查看日志/检查`{gen_code_conf}`文件\n{e}")

    return msg_list


def get_code_conf(code_type, gen_code_conf, activity_list):
    bot_list = []
    code_conf_list = []
    try:
        with open(gen_code_conf, 'r') as lines:
            array = lines.readlines()
            for i in array:
                if i.startswith(code_type):
                    i_split = i.split("-")
                    if True if activity_list == '' else False:
                        bot_list.append(i_split[1])
                        code_conf = CodeConf(bot_id=i_split[1],
                                             submit_code=i_split[2],
                                             log_name=i_split[3],
                                             activity_code=i_split[4],
                                             find_split_char=i_split[5].replace('\n', ''))
                        code_conf_list.append(code_conf)
                    else:
                        if i_split[4] in activity_list.split() or i_split[2].lstrip("/") in activity_list.split():
                            bot_list.append(i_split[1])
                            code_conf = CodeConf(bot_id=i_split[1],
                                                 submit_code=i_split[2],
                                                 log_name=i_split[3],
                                                 activity_code=i_split[4],
                                                 find_split_char=i_split[5].replace('\n', ''))
                            code_conf_list.append(code_conf)
    except Exception as e:
        logger.info(f"读取生成互助代码配置文件出错{e},请检查格式配置是否正确。")
    return bot_list, code_conf_list


class CodeConf(object):
    def __init__(self, bot_id, submit_code, log_name, activity_code, find_split_char):
        self.bot_id = bot_id
        self.submit_code = submit_code
        self.log_name = log_name
        self.activity_code = activity_code
        self.find_split_char = find_split_char

    def get_submit_msg(self):
        code_list = []
        ac = self.activity_code if self.activity_code != "@N" else ""
        try:
            with open(f"/scripts/logs/{self.log_name}", 'r') as lines:
                array = lines.readlines()
                for i in array:
                    # print(self.find_split_char)
                    if i.find(self.find_split_char) > -1:
                        code_list.append(i.split(self.find_split_char)[
                                             1].replace('\n', ''))
            if self.activity_code == "@N":
                return f"{self.submit_code} {'&'.join(list(set(code_list)))}"
            else:
                return f"{self.submit_code} {ac} {'&'.join(list(set(code_list)))}"
        except Exception as e:
            return f"{self.submit_code} {ac}活动获取系统日志文件异常：{e}"


def get_glc():
    s_token, cookie = get_stk_ccc()
    token, okl_token = get_okl_tk(s_token, cookie)
    glcimg = gen_qrcode(token)
    return token, okl_token, cookie, glcimg


async def chk_glc(token, okl_token, cookie):
    expired_time = time.time() + 60 * 3
    while True:
        check_time_stamp = int(time.time() * 1000)
        check_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=%s&ou_state=0&okl_token=%s' % (
            token, okl_token)
        check_data = {
            'lang': 'chs',
            'appid': 300,
            'returnurl': 'https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action' % check_time_stamp,
            'source': 'wq_passport'

        }
        check_header = {
            'Referer': f'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % check_time_stamp,
            'Cookie': cookie,
            # 'Connection': 'Keep-Alive',
            'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
            'Accept': 'application/json, text/plain, */*',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',

        }
        resp = requests.post(url=check_url, headers=check_header, data=check_data, timeout=30)
        headers, data = resp.headers, resp.json()
        if data.get("errcode") == 0:
            logger.info("Scan success")
            set_cookie = headers.get('Set-Cookie')
            pt_key = re.findall(r"pt_key=(.+?);", set_cookie)[0]
            pt_pin = re.findall(r"pt_pin=(.+?);", set_cookie)[0]
            jlc = 'pt_key=' + pt_key + ';pt_pin=' + pt_pin + ';'
            return data.get("errcode"), jlc
        if data.get("errcode") == 21:
            return data.get("errcode"), 'QRCode has expired, get it again'
        if time.time() > expired_time:
            return 555, "Timeout,QRCode has expired."


def get_stk_ccc():
    time_stamp = int(time.time() * 1000)
    get_url = 'https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%s&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % time_stamp
    get_header = {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-cn',
        'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=%s&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % time_stamp,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
        'Host': 'plogin.m.jd.com'
    }
    try:
        resp = requests.get(url=get_url, headers=get_header)
        get_headers, get_data = resp.headers, resp.json()
        s_token = get_data.get('s_token')
        set_cookies = get_headers.get('set-cookie')
        logger.info(set_cookies)

        guid = re.findall(r"guid=(.+?);", set_cookies)[0]
        lsid = re.findall(r"lsid=(.+?);", set_cookies)[0]
        lstoken = re.findall(r"lstoken=(.+?);", set_cookies)[0]

        cookies = f"guid={guid}; lang=chs; lsid={lsid}; lstoken={lstoken}; "
        logger.info(cookies)
        return s_token, cookies
    except Exception as error:
        logger.exception("Get网络请求异常", error)


def get_okl_tk(s_token, cookie):
    post_time_stamp = int(time.time() * 1000)
    post_url = 'https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=%s&v=%s&remember=true' % (
        s_token, post_time_stamp)
    post_data = {
        'lang': 'chs',
        'appid': 300,
        'returnurl': 'https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action' % post_time_stamp,
        'source': 'wq_passport'
    }
    post_header = {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
        'Accept': 'application/json, text/plain, */*',
        'Cookie': cookie,
        'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=%s&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport' % post_time_stamp,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
        'Host': 'plogin.m.jd.com',
    }
    try:
        resp = requests.post(url=post_url, headers=post_header, data=post_data, timeout=20)
        post_resp_headers, post_resp_data = resp.headers, resp.json()
        logger.info(post_resp_headers)
        logger.info(post_resp_data)
        token = post_resp_data.get('token')
        okl_token = re.findall(r"okl_token=(.+?);", post_resp_headers.get('set-cookie'))[0]

        return token, okl_token
    except Exception as error:
        logger.exception("Post网络请求错误", error)


def gen_qrcode(token):
    cookie_url = f'https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=%s' % token
    version, level, qr_name = myqr.run(
        words=cookie_url,
        # 扫描二维码后，显示的内容，或是跳转的链接
        version=5,  # 设置容错率
        level='H',  # 控制纠错水平，范围是L、M、Q、H，从左到右依次升高
        picture='/scripts/docker/bot/jd.png',  # 图片所在目录，可以是动图
        colorized=True,  # 黑白(False)还是彩色(True)
        contrast=1.0,  # 用以调节图片的对比度，1.0 表示原始图片。默认为1.0。
        brightness=1.0,  # 用来调节图片的亮度，用法同上。
        save_name='/scripts/docker/genQRCode.png',  # 控制输出文件名，格式可以是 .jpg， .png ，.bmp ，.gif
    )
    return qr_name
