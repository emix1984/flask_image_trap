# utils/geo_utils.py
import geoip2.database

reader = geoip2.database.Reader("./app/GeoLite2-City.mmdb")

def get_geo_info(ip):
    try:
        response = reader.city(ip)
        country = response.country.names.get("zh-CN", response.country.name)
        city = response.city.names.get("zh-CN", response.city.name)
        region = response.subdivisions[0].names.get("zh-CN", "") if response.subdivisions else ""

        # 添加经纬度信息
        latitude = response.location.latitude
        longitude = response.location.longitude

        return {
            "country": country or "未知",
            "city": city or "未知",
            "region": region or "未知",
            "latitude": latitude,
            "longitude": longitude
        }
    except Exception:
        return {
            "country": "未知",
            "city": "未知",
            "region": "未知",
            "latitude": None,
            "longitude": None
        }
