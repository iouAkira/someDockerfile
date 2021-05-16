# -*- coding: utf-8 -*-
from asyncio import sleep

from telethon import TelegramClient, events, utils
import logging
import sys

logging.basicConfig(level=logging.INFO)

api_id = 100003
api_hash = '48991**************30242'

client = TelegramClient('lof', api_id, api_hash).start()
client.start()

# 水果群ID -10000000000
group_id = -10000000000
# IF🐱频道ID
chnl_id = -1000000000000
# 狼头机器人ID 160000000
from_bot_id = [160000000]
# 我的bot ID
forward_bot_id = 50000000
# 接受消息的群
incoming_group_list = [-10000000000]
incoming_chnl_list = [-1000000000000]

@client.on(events.NewMessage(incoming=True, chats=incoming_group_list,from_users=from_bot_id))
async def live_lottery_group(event):
    sender = await event.get_sender()
    from_name = utils.get_display_name(sender)
    from_id = utils.get_peer_id(sender)
    logging.info(f'来自{event.chat_id}: {from_id} | {from_name}说的>>{event.message.text}')
    if event.chat_id == group_id:
        await client.forward_messages(forward_bot_id, event.message)

@client.on(events.NewMessage(incoming=True, chats=incoming_chnl_list))
async def live_lottery_chnl(event):
    sender = await event.get_sender()
    from_name = utils.get_display_name(sender)
    from_id = utils.get_peer_id(sender)
    # print(f'来自{event.chat_id}: {from_id} | {from_name}说的>>{event.message.text}')
    logging.info(f'来自{event.chat_id}: {from_id} | {from_name}说的>>{event.message.text}')
    if event.chat_id == chnl_id:
        await client.forward_messages(forward_bot_id, event.message)

if len(sys.argv) < 2:
    client.run_until_disconnected()
