# Flask Image Trap

一个基于 Flask 的图像陷阱应用，用于追踪访客信息并记录到数据库。

## 功能特性

- 📷 图像陷阱功能：通过提供图像链接追踪访客
- 🌍 IP 地理位置解析：使用 GeoIP2 数据库获取访客地理位置信息
- 🖥️ User-Agent 解析：识别访客设备、操作系统和浏览器信息
- 🗄️ 数据存储：将访客信息存储到 SQLite 数据库
- 🔔 Gotify 推送通知：实时推送访客访问通知
- 📊 数据可视化：记录访客详细信息用于分析

## 项目结构

```
flask_image_trap/
├── app/
│   ├── utils/
│   │   ├── geo_utils.py      # 地理位置工具
│   │   ├── gotify_pusher.py  # Gotify 推送通知工具
│   │   ├── ip_utils.py       # IP 工具
│   │   └── ua_utils.py       # User-Agent 解析工具
│   ├── __init__.py           # Flask 应用初始化
│   ├── models.py             # 数据库模型
│   ├── routes.py             # 路由定义
│   └── visitor_info.py       # 访客信息收集
├── data/                     # 数据库存储目录
├── static/                   # 静态文件目录
│   └── images/
│       └── mail/
│           └── ts_liuying.jpg
├── .env                      # 环境变量配置文件
├── requirements.txt          # 项目依赖
└── run.py                    # 应用启动文件
```

## 安装与配置

### 1. 环境要求

- Python 3.7+
- GeoIP2 数据库文件 (GeoLite2-City.mmdb)
- Gotify 服务器（可选）

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 配置环境变量

创建 `.env` 文件并配置以下变量：

```env
# Gotify 配置（可选）
GOTIFY_BASE_URL=http://your-gotify-server-url
GOTIFY_APP_TOKEN=your-gotify-app-token
GOTIFY_TITLE=ImageTrap
```

### 4. 准备 GeoIP2 数据库

将 GeoLite2-City.mmdb 文件放置在 `app/` 目录下。

### 5. 准备图像文件

将要追踪的图像文件放置在 `static/images/mail/` 目录下。

## 使用方法

### 启动应用

```bash
python run.py
```

应用将在 `http://0.0.0.0:5001` 上运行。

### 访问图像

访问 `http://your-server:5001/mail/ts_liuying.jpg` 提供图像，当有人访问该链接时，系统会记录访客信息。

## 数据库

### 数据库结构

访客信息存储在 SQLite 数据库中，包含以下字段：

- `id`: 主键
- `ip_address`: 访客IP地址
- `geo_country`: 国家
- `geo_region`: 地区
- `geo_city`: 城市
- `geo_latitude`: 纬度
- `geo_longitude`: 经度
- `ua_device`: 设备类型
- `ua_os`: 操作系统
- `ua_browser`: 浏览器
- `referrer`: 来源页面
- `timestamp`: 访问时间

### 数据库文件位置

数据库文件存储在项目根目录的 `data/` 文件夹中，文件名为 `visitor_data.db`。

## 技术栈

- **Flask**: Web 框架
- **Flask-SQLAlchemy**: ORM 数据库工具
- **Flask-Migrate**: 数据库迁移工具
- **geoip2**: IP 地理位置解析
- **user-agents**: User-Agent 解析
- **requests**: HTTP 请求库
- **python-dotenv**: 环境变量管理

## Gotify 推送通知

当有访客访问图像时，系统会通过 Gotify 发送通知，包含以下信息：

- 访客IP地址
- 地理位置信息
- 设备和浏览器信息
- 来源页面

## 开发说明

### 添加新的追踪图像

1. 将图像文件放置在 `static/images/` 目录下相应子目录中
2. 在 [routes.py](file:///Users/lark/Desktop/flask_image_trap/app/routes.py) 中添加新的路由处理函数

### 自定义数据模型

修改 [models.py](file:///Users/lark/Desktop/flask_image_trap/app/models.py) 文件来自定义数据库表结构。

### 扩展功能

- 可以添加更多的追踪路由
- 可以集成更多的通知方式
- 可以添加数据统计和分析功能

## 注意事项

1. 确保 GeoIP2 数据库文件存在且路径正确
2. 如需使用 Gotify 推送功能，请正确配置环境变量
3. 生产环境中建议关闭调试模式
4. 定期备份数据库文件


## Gunicorn 管理脚本

### 启动脚本 (gunicorn_run_app.sh)

用于启动 Flask 应用的 Gunicorn 服务器，具有以下功能：

1. 自动检查和创建日志目录
2. 管理 Python 虚拟环境（创建/激活）
3. 自动安装和更新项目依赖
4. 支持自定义端口和工作进程数
5. 自动检查端口可用性
6. 提供启动状态验证

### 状态检查脚本 (gunicorn_status.sh)

用于检查 Gunicorn 服务器运行状态：

1. 通过 PID 文件检查进程状态
2. 通过端口检查服务监听状态
3. 显示详细的进程信息

### 关闭脚本 (gunicorn_shutdown.sh)

用于优雅地关闭 Gunicorn 服务器：

1. 优先通过 PID 文件终止进程
2. 备选通过端口查找并终止进程
3. 支持优雅终止和强制终止
4. 自动验证关闭结果

### 脚本特性

- **模块化设计**：每个功能都封装在独立的函数中
- **详细日志**：完整的操作日志记录，便于问题排查
- **错误处理**：完善的错误检查和处理机制
- **用户友好**：清晰的交互提示和配置选项
- **健壮性**：多种检查和终止方式，确保操作可靠性