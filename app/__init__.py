from flask import Flask
# from .routes import register_routes

from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

# 配置数据库
def init_database(app):
    with app.app_context():
        try:
            # 导入模型
            from .models import MailLogStepA, Subscription  # 导入所有模型
            # print('MailLogStepA', MailLogStepA)
            # 初始化数据库连接
            db.init_app(app)
            print('初始化 { Flask-SQLAlchemy数据库连接 } 完毕！')

            # 初始化 Flask-Migrate
            migrate.init_app(app, db)
            print('初始化 { Flask-Migrate } 完毕！')

            # 创建所有未存在的表
            db.create_all()
            # 打印创建的表名
            print("已创建的表：")
            for table_name in db.metadata.tables:
                print(table_name)
                print(f'自定义数据库-创建数据库表 {table_name} 完毕！')
            print('初始化 { 自定义数据库-创建数据库表 } 完毕！')
            # 在应用上下文中执行操作
            print(f"Database URI inside app context: {app.config['SQLALCHEMY_DATABASE_URI']}")
        except Exception as e:
            print('> Error: DBMS Exception: ' + str(e))
            # Fallback to SQLite if necessary
            basedir = os.path.abspath(os.path.dirname(__file__))
            app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'db.sqlite3')
            print('> Fallback to SQLite')
            db.create_all()
            print("已创建的表：")
            for table_name in db.metadata.tables.keys():
                print(table_name)
                print(f'自定义数据库-创建数据库表 {table_name} 完毕！')
            print('初始化 { 自定义数据库-创建数据库表 } 完毕！')

def create_app():
    app = Flask(__name__)
    
     # 初始化数据库
    init_database(app)
    print('初始化 { 自定义数据库-初始化数据库 } 完毕！')
    
    # register_routes(app)
    return app
