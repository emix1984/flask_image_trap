from flask import send_from_directory, request
import os
# from .utils.ip_utils import get_real_ip
# from .utils.geo_utils import get_geo_info
# from .utils.ua_utils import parse_user_agent
from .visitor_info import log_visitor_info
from .utils.gotify_pusher import push_to_gotify

BASE_IMAGE_FOLDER = 'static/images'

def register_routes(app):
    @app.route('/mail/namecard.png')
    def serve_namecard():
        folder_path = os.path.join(BASE_IMAGE_FOLDER, 'mail')
        filename = 'namecard.png'
        print(f"Serving image from: {folder_path}, filename: {filename}")
        
        # 获取访客信息
        visitor_data = log_visitor_info()
        print(f"Visitor data logged: {visitor_data}")
        # 推送到 Gotify
        push_to_gotify(
            title="新访客访问",
            message=f"场景: mail\nIP: {visitor_data['ip_address']}\n地理位置: {visitor_data['geo_info']['country']} {visitor_data['geo_info']['city']}\n设备: {visitor_data['user_agent']['device_type']}\nOS: {visitor_data['user_agent']['os']}\n浏览器: {visitor_data['user_agent']['browser']}\n来源: {visitor_data['referrer']}",
            priority=1
        )
        
        return send_from_directory(folder_path, filename)
