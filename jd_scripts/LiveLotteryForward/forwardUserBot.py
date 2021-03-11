# -*- coding: utf-8 -*-

from telethon import TelegramClient, events, utils
import logging
import sys

logging.basicConfig(level=logging.INFO)

api_id = 1000000003
api_hash = '48990000000000000000242'

client = TelegramClient('lof', api_id, api_hash).start()
client.start()

# 要监控群ID
group_id = -10000000000
# 要监控的频道ID
chnl_id = -100000000001
# 消息发送人的ID
from_bot_id = 1666666
# 自己要接收bot ID
forward_bot_id = 55555555


@client.on(events.NewMessage(incoming=True))
async def spam_tracker(event):
    sender = await event.get_sender()
    from_name = utils.get_display_name(sender)
    from_id = utils.get_peer_id(sender)
    # print(f'来自{event.chat_id}: {from_id} | {from_name}说的>>{event.message.text}')
    if event.chat_id == chnl_id:
        print(f'来自{event.chat_id}: {from_id} | {from_name}说的>>{event.message.text}')
        await client.forward_messages(forward_bot_id, event.message)
        if str(event.message.text).find('直达抽奖链接') > 0:
            await client.forward_messages(forward_bot_id, event.message)


if len(sys.argv) < 2:
    client.run_until_disconnected()
