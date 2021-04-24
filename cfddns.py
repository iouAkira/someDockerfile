import json

import requests as req
import re


def home_ddns():
    # DNS记录名
    record_name = "aaa.bbb.com"
    # 区域ID，可以在域名Overview中看到
    zone_id = "85************073"
    # 可以编辑DNS记录的API Token
    cftoken = "rh2*******************ox7"
    # dns记录ID
    record_id = get_dns_record_id(zone_id, record_name, cftoken)
    if record_id.startswith("error"):
        return record_id
    # 公网IP
    ip = get_my_ip()
    if ip.startswith("error"):
        return ip
    # 更新DNS解析
    result = update_dns_record_ip(zone_id=zone_id,
                                  record_id=record_id,
                                  token=cftoken,
                                  record_name=record_name,
                                  ip=ip)
    return result


def get_dns_record_id(zone_id, record_name, token):
    get_url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?name={record_name}&type=A"
    get_header = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    resp = req.get(url=get_url, headers=get_header)
    try:
        record_id = resp.json().get("result")[-1].get("id")
    except Exception as e:
        record_id = "error,获取DNS解析记录ID出错。" + e
    return record_id


def get_my_ip():
    try:
        dyndns_url = "http://checkip.dyndns.com/"
        resp_dyndns = req.get(url=dyndns_url)
        ip_dyndns = re.findall(r"Address: (.+?)<", resp_dyndns.text)[-1]

        # ipify_url = "https://api.ipify.org/"
        # resp_ipify = req.get(url=ipify_url)
        # print(resp_ipify.text)
        # ip_ipify = resp_ipify.text

        ip = ip_dyndns
    except Exception as e:
        ip = "error,获取公网IP出错。" + e
    return ip


def update_dns_record_ip(zone_id, record_id, token, record_name, ip):
    post_url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    post_header = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    post_data = {
        "type": "A",
        "name": record_name,
        "content": ip,
        "ttl": 120
    }
    resp = req.put(url=post_url, headers=post_header, data=json.dumps(post_data))
    try:
        result = ""
        print(resp.json())
        if resp.json().get("success"):
            result = f"DNS记录更新成功。\n\nRecord Name:{record_name}\nRecord IP:{ip}"
    except Exception as e:
        result = "error,更新DNS记录出错。" + e
    return result


if __name__ == "__main__":
    print(home_ddns())
