# utils/ua_utils.py
from user_agents import parse

def parse_user_agent(ua_string):
    ua = parse(ua_string)
    device_type = (
        "Mobile" if ua.is_mobile else
        "Tablet" if ua.is_tablet else
        "PC" if ua.is_pc else
        "Other"
    )
    return {
        "device": device_type,
        "os": ua.os.family + " " + ua.os.version_string,
        "browser": ua.browser.family + " " + ua.browser.version_string,
        "raw": ua_string
    }
