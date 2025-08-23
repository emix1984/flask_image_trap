#!/bin/bash

# =============================================================================
# Flask Image Trap - Gunicorn 状态检查脚本
# 描述: 检查 Flask 应用的 Gunicorn 服务器运行状态
# =============================================================================

# -----------------------------------------------------------------------------
# 全局配置常量
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="Gunicorn状态检查脚本"
readonly DEFAULT_PORT=5001
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
# 获取用户配置
# -----------------------------------------------------------------------------
get_user_configuration() {
    log_message "INFO" "获取用户配置..."
    
    # 读取端口号
    read -p "请输入要检查的Gunicorn服务端口号 (默认: $DEFAULT_PORT): " USER_PORT
    PORT=${USER_PORT:-$DEFAULT_PORT}
    
    log_message "INFO" "配置信息 - 端口: $PORT"
}

# -----------------------------------------------------------------------------
# 通过PID文件检查状态
# -----------------------------------------------------------------------------
check_by_pid_file() {
    log_message "INFO" "通过PID文件检查状态..."
    
    # 检查PID文件是否存在
    if [ ! -f "$PID_FILE" ]; then
        log_message "INFO" "PID文件不存在: $PID_FILE"
        return 1
    fi
    
    # 读取PID
    local pid=$(cat "$PID_FILE")
    if [ -z "$pid" ]; then
        log_message "WARN" "PID文件为空"
        return 1
    fi
    
    # 检查进程是否存在
    if ps -p $pid > /dev/null 2>&1; then
        log_message "INFO" "服务正在运行 (PID: $pid)"
        ps -p $pid -f
        return 0
    else
        log_message "WARN" "PID文件中的进程不存在 (PID: $pid)"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# 通过端口检查状态
# -----------------------------------------------------------------------------
check_by_port() {
    log_message "INFO" "通过端口 $PORT 检查状态..."
    
    # 查找监听指定端口的进程
    local pids=$(lsof -i :$PORT -t -sTCP:LISTEN 2>/dev/null)
    
    if [ -z "$pids" ]; then
        log_message "INFO" "端口 $PORT 未被监听"
        return 1
    fi
    
    log_message "INFO" "发现监听端口 $PORT 的进程:"
    for pid in $pids; do
        log_message "INFO" "  PID: $pid"
        ps -p $pid -f 2>/dev/null || log_message "WARN" "  无法获取进程详细信息"
    done
    
    return 0
}

# -----------------------------------------------------------------------------
# 主函数
# -----------------------------------------------------------------------------
main() {
    log_message "INFO" "=== $SCRIPT_NAME 开始 ==="
    
    # 获取用户配置
    get_user_configuration
    
    # 检查状态
    local status_found=0
    
    # 通过PID文件检查
    if check_by_pid_file; then
        status_found=1
    fi
    
    # 通过端口检查
    if check_by_port; then
        status_found=1
    fi
    
    if [ $status_found -eq 0 ]; then
        log_message "INFO" "服务未运行"
    fi
    
    log_message "INFO" "=== $SCRIPT_NAME 完成 ==="
}

# -----------------------------------------------------------------------------
# 脚本入口点
# -----------------------------------------------------------------------------
# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi