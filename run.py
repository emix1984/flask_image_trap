from app import create_app, db
from app.routes import register_routes

app = create_app()
register_routes(app)

if __name__ == '__main__':
    print("开始启动flask")
    app.run(host='0.0.0.0', port=5001, debug=True) # 开启Flask调试模式
    # app.run(host='0.0.0.0', port=5002, debug=False) # 关闭Flask调试模式
