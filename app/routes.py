from flask import send_from_directory, request
import os
from .visitor_info import log_visitor_info
from .utils.gotify_pusher import push_to_gotify
from .models import table_ImageTrap_mail  # 导入模型
from .app import db  # 导入数据库实例

BASE_IMAGE_FOLDER = 'static/images'

def register_routes(app):
    @app.route('/mail/ts_liuying.jpg')
    def serve_namecard():
        folder_path = os.path.join(BASE_IMAGE_FOLDER, 'mail')
        filename = 'ts_liuying.JPG'
        print(f"Serving image from: {folder_path}, filename: {filename}")
        
        # 获取访客信息（扁平结构）
        visitor_data = log_visitor_info()
        print(f"Visitor data logged: {visitor_data}")
        
        # 存储到数据库
        imagetrap_mail = table_ImageTrap_mail(**visitor_data)  # 使用扁平字典结构创建 Subscription 实例
        db.session.add(imagetrap_mail)
        db.session.commit()
        
        # 推送到 Gotify（适配扁平字典结构）
        push_to_gotify(
            title="新访客访问",
            message=f"场景: mail\nIP: {visitor_data['ip_address']}\n地理位置: {visitor_data['geo_country']} {visitor_data['geo_city']}\n设备: {visitor_data['ua_device']}\nOS: {visitor_data['ua_os']}\n浏览器: {visitor_data['ua_browser']}\n来源: {visitor_data['referrer']}",
            priority=1
        )
        
        return send_from_directory(folder_path, filename)
