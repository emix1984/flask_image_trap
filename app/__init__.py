from flask import Flask
import os
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

# 配置数据库
def init_database(app):
    # 初始化数据库连接
    db.init_app(app)
    print('初始化 { Flask-SQLAlchemy数据库连接 } 完毕！')

    # 初始化 Flask-Migrate
    migrate.init_app(app, db)
    print('初始化 { Flask-Migrate } 完毕！')

    with app.app_context():
        try:
            # 导入模型
            # from .models import table_mail_ts  # 显式导入每个模型
            from . import models  # 确保 models 模块被加载
            
            # 创建所有未存在的表
            db.create_all()
            # 打印创建的表名
            print("已创建的表：")
            for table_name in db.metadata.tables:
                print(table_name)
                print(f'>>> 自定义数据库-创建数据库表 {table_name} 完毕！')
            
            # 在应用上下文中执行操作
            print(f"当前数据库URI配置: {app.config['SQLALCHEMY_DATABASE_URI']}")
            print('>>> 初始化 { 自定义数据库-创建数据库表 } 完毕！<<<\n')
        except Exception as e:
            print('> Error: DBMS Exception: ' + str(e))
            # Fallback to SQLite if necessary
            basedir = os.path.abspath(os.path.dirname(__file__))
            app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'track_visitor_data_error.db')
            print('> Fallback to SQLite')
            db.create_all()
            # 在应用上下文中执行操作
            print(f"当前数据库URI配置: {app.config['SQLALCHEMY_DATABASE_URI']}")
            print('>>> 初始化 { 自定义数据库-创建数据库表 } 完毕！<<<\n')
            

def create_app():
    app = Flask(__name__)
    
    # 配置数据库URI - 使用data文件夹
    basedir = os.path.abspath(os.path.dirname(__file__))
    db_path = os.path.join(basedir, '..', 'data', 'track_visitor_data.db')
    
    # 确保data文件夹存在
    os.makedirs(os.path.dirname(db_path), exist_ok=True)

    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + db_path
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # 初始化数据库
    init_database(app)
    print('初始化 { 自定义数据库-初始化数据库 } 完毕！')
    
    return app
