# utils/ua_utils.py
from user_agents import parse

def parse_user_agent(ua_string):
    ua = parse(ua_string)
    device_type = (
        "手机" if ua.is_mobile else
        "平板" if ua.is_tablet else
        "电脑" if ua.is_pc else
        "其他设备"
    )
    return {
        "device_type": device_type,
        "os": ua.os.family + " " + ua.os.version_string,
        "browser": ua.browser.family + " " + ua.browser.version_string,
        "raw": ua_string
    }
