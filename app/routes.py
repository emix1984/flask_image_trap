from flask import send_from_directory, request
import os
from .visitor_info import log_visitor_info
from .utils.gotify_pusher import push_to_gotify
from .models import table_mail_ts  # 导入模型
from . import db  # 导入数据库实例

BASE_IMAGE_FOLDER = 'static/images'

def register_routes(app):
    # @app.route('/mail/ts_liuying.jpg') # 测试专用简化路径
    @app.route('/e2gqUjviWsN/ts_liuying.jpg')
    def track_visitor_mail_ts(filename='ts_liuying.jpg'):
        # 使用相对于应用根目录的路径
        project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        folder_path = os.path.join(project_root, 'static', 'images', 'mail')
        # filename = 'ts_liuying.jpg'
        full_path = os.path.join(folder_path, filename)
        
        # 检查文件是否存在
        if not os.path.exists(full_path):
            print(f"Image file not found: {full_path}")
            return "Image not found", 404
            
        # print(f"Serving image from: {folder_path}, filename: {filename}")
        
        # 获取访客信息（扁平结构）
        visitor_data = log_visitor_info()
        # print(f"Visitor data logged: {visitor_data}")
        
        # 存储到数据库
        data = table_mail_ts(**visitor_data)  # 使用扁平字典结构创建 Subscription 实例
        db.session.add(data)
        db.session.commit()
        
        # 推送到 Gotify（适配扁平字典结构）
        push_to_gotify(
            title="新访客访问",
            message=f"场景: mail\nIP: {visitor_data['ip_address']}\n地理位置: {visitor_data['geo_country']} {visitor_data['geo_city']}\n设备: {visitor_data['ua_device']}\nOS: {visitor_data['ua_os']}\n浏览器: {visitor_data['ua_browser']}\n来源: {visitor_data['referrer']}",
            priority=1
        )
        print(f"🌐 IP 地址: {visitor_data['ip_address']}")
        print(f"📍 地理位置: {visitor_data['geo_country']} {visitor_data['geo_city']}")
        print(f"🧭 User-Agent: {visitor_data['ua_device']} {visitor_data['ua_os']} {visitor_data['ua_browser']}")
        print(f"🔗 来源页面: {visitor_data['referrer']}\n\n")
        return send_from_directory(folder_path, filename)
