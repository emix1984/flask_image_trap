#!/bin/bash

# =============================================================================
# Flask Image Trap - Gunicorn 启动脚本
# 描述: 模块化管理 Flask 应用的 Gunicorn 服务器启动
# =============================================================================

# -----------------------------------------------------------------------------
# 全局配置常量
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="Gunicorn启动脚本"
readonly DEFAULT_PORT=5001
readonly DEFAULT_WORKERS=4
readonly VIRTUAL_ENV="./venv"
readonly LOG_DIR="./log"
readonly PID_FILE="/tmp/gunicorn-image-trap.pid"

# -----------------------------------------------------------------------------
# 日志输出函数
# 参数:
#   $1 - 日志级别 (INFO, WARN, ERROR)
#   $2 - 日志消息
# -----------------------------------------------------------------------------
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

# -----------------------------------------------------------------------------
# 检查并创建必要目录
# -----------------------------------------------------------------------------
setup_directories() {
    log_message "INFO" "检查并创建必要目录..."
    
    # 创建日志目录
    if [ ! -d "$LOG_DIR" ]; then
        log_message "INFO" "创建日志目录: $LOG_DIR"
        mkdir -p "$LOG_DIR"
        if [ $? -ne 0 ]; then
            log_message "ERROR" "无法创建日志目录: $LOG_DIR"
            exit 1
        fi
    else
        log_message "INFO" "日志目录已存在: $LOG_DIR"
    fi
}

# -----------------------------------------------------------------------------
# 设置虚拟环境
# -----------------------------------------------------------------------------
setup_virtual_environment() {
    log_message "INFO" "设置Python虚拟环境..."
    
    # 检查虚拟环境是否存在
    if [ ! -d "$VIRTUAL_ENV" ]; then
        log_message "INFO" "创建新的虚拟环境: $VIRTUAL_ENV"
        python3 -m venv "$VIRTUAL_ENV"
        if [ $? -ne 0 ]; then
            log_message "ERROR" "虚拟环境创建失败"
            exit 1
        fi
    else
        log_message "INFO" "使用现有虚拟环境: $VIRTUAL_ENV"
    fi
    
    # 激活虚拟环境
    log_message "INFO" "激活虚拟环境..."
    source "$VIRTUAL_ENV/bin/activate"
    if [ $? -ne 0 ]; then
        log_message "ERROR" "虚拟环境激活失败"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# 安装和更新依赖
# -----------------------------------------------------------------------------
install_dependencies() {
    log_message "INFO" "检查并安装依赖..."
    
    # 升级 pip
    log_message "INFO" "升级 pip..."
    pip install --upgrade pip > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log_message "ERROR" "pip 升级失败"
        exit 1
    fi
    
    # 安装项目依赖
    if [ -f "requirements.txt" ]; then
        log_message "INFO" "安装项目依赖..."
        pip install -r requirements.txt > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            log_message "ERROR" "依赖安装失败"
            exit 1
        fi
        log_message "INFO" "依赖安装完成"
    else
        log_message "WARN" "未找到 requirements.txt 文件"
    fi
}

# -----------------------------------------------------------------------------
# 获取用户配置
# -----------------------------------------------------------------------------
get_user_configuration() {
    log_message "INFO" "获取用户配置..."
    
    # 读取端口号
    read -p "请输入Gunicorn服务端口号 (默认: $DEFAULT_PORT): " USER_PORT
    PORT=${USER_PORT:-$DEFAULT_PORT}
    
    # 读取工作进程数
    read -p "请输入工作进程数 (默认: $DEFAULT_WORKERS): " USER_WORKERS
    WORKERS=${USER_WORKERS:-$DEFAULT_WORKERS}
    
    log_message "INFO" "配置信息 - 端口: $PORT, 工作进程数: $WORKERS"
}

# -----------------------------------------------------------------------------
# 检查端口可用性
# -----------------------------------------------------------------------------
check_port_availability() {
    log_message "INFO" "检查端口 $PORT 可用性..."
    
    # 检查端口是否已被占用
    if lsof -i :$PORT -sTCP:LISTEN > /dev/null 2>&1; then
        log_message "ERROR" "端口 $PORT 已被占用"
        exit 1
    fi
    
    log_message "INFO" "端口 $PORT 可用"
}

# -----------------------------------------------------------------------------
# 启动 Gunicorn 服务器
# -----------------------------------------------------------------------------
start_gunicorn() {
    log_message "INFO" "启动 Gunicorn 服务器..."
    
    # 构建 Gunicorn 命令
    local gunicorn_cmd="gunicorn -w $WORKERS -b 0.0.0.0:$PORT run:app"
    gunicorn_cmd+=" --access-logfile $LOG_DIR/access.log"
    gunicorn_cmd+=" --error-logfile $LOG_DIR/error.log"
    gunicorn_cmd+=" --pid $PID_FILE"
    gunicorn_cmd+=" --timeout 30"
    gunicorn_cmd+=" --keep-alive 2"
    
    # 执行启动命令
    log_message "INFO" "执行命令: $gunicorn_cmd"
    eval $gunicorn_cmd
    
    # 检查启动结果
    if [ $? -eq 0 ]; then
        log_message "INFO" "Gunicorn 服务器启动成功"
    else
        log_message "ERROR" "Gunicorn 服务器启动失败"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# 验证服务状态
# -----------------------------------------------------------------------------
verify_service() {
    log_message "INFO" "验证服务状态..."
    
    # 等待服务启动
    sleep 2
    
    # 检查进程是否存在
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            log_message "INFO" "服务运行中 (PID: $pid)"
        else
            log_message "WARN" "PID文件存在但进程不存在"
        fi
    else
        log_message "WARN" "未找到PID文件"
    fi
    
    # 检查端口监听状态
    if lsof -i :$PORT -sTCP:LISTEN > /dev/null 2>&1; then
        log_message "INFO" "端口 $PORT 正在监听"
    else
        log_message "WARN" "端口 $PORT 未监听"
    fi
}

# -----------------------------------------------------------------------------
# 主函数
# -----------------------------------------------------------------------------
main() {
    log_message "INFO" "=== $SCRIPT_NAME 开始 ==="
    
    # 执行各个模块
    setup_directories
    setup_virtual_environment
    install_dependencies
    get_user_configuration
    check_port_availability
    start_gunicorn
    verify_service
    
    log_message "INFO" "=== $SCRIPT_NAME 完成 ==="
}

# -----------------------------------------------------------------------------
# 脚本入口点
# -----------------------------------------------------------------------------
# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi