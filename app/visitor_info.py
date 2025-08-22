# visitor_info.py

from flask import request  # Import request here
from .utils.ip_utils import get_real_ip
from .utils.geo_utils import get_geo_info
from .utils.ua_utils import parse_user_agent


def log_visitor_info():  # Remove request parameter
    visitor_ip = get_real_ip()
    geo_info = get_geo_info(visitor_ip)
    user_agent_string = request.headers.get('User-Agent', '')  # Access request here
    ua_info = parse_user_agent(user_agent_string)
    referrer = request.referrer or '无来源信息'  # Access request here

    # 扁平化字典
    visitor_data = {
        "ip_address": visitor_ip,
        "referrer": referrer,
        # geo_info 扁平化
        "geo_country": geo_info.get("country"),
        "geo_region": geo_info.get("region"),
        "geo_city": geo_info.get("city"),
        "geo_latitude": geo_info.get("latitude"),
        "geo_longitude": geo_info.get("longitude"),
        # ua_info 扁平化
        "ua_browser": ua_info.get("browser"),
        "ua_browser_version": ua_info.get("browser_version"),
        "ua_os": ua_info.get("os"),
        "ua_os_version": ua_info.get("os_version"),
        "ua_device": ua_info.get("device"),
    }

    print(f"🌐 IP 地址: {visitor_ip}")
    print(f"📍 地理位置: {geo_info}")
    print(f"🧭 User-Agent: {ua_info}")
    print(f"🔗 来源页面: {referrer}")

    return visitor_data
