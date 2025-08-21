from flask import Flask, render_template, request
from app.routes import register_routes  # Import the register_routes function


app = Flask(__name__)
register_routes(app) # Register the routes with the app

if __name__ == '__main__':
    print("开始启动flask")
    app.run(host='0.0.0.0', port=5001, debug=True) # 开启Flask调试模式
    # app.run(host='0.0.0.0', port=5002, debug=False) # 关闭Flask调试模式
