#!/bin/bash

# =============================================================================
# Flask Image Trap - Gunicorn 关闭脚本
# 描述: 模块化管理 Flask 应用的 Gunicorn 服务器关闭
# =============================================================================

# -----------------------------------------------------------------------------
# 全局配置常量
# -----------------------------------------------------------------------------
readonly SCRIPT_NAME="Gunicorn关闭脚本"
readonly DEFAULT_PORT=5001
readonly PID_FILE="/tmp/gunicorn-image-trap.pid"
readonly MAX_WAIT_TIME=10

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
    read -p "请输入要关闭的Gunicorn服务端口号 (默认: $DEFAULT_PORT): " USER_PORT
    PORT=${USER_PORT:-$DEFAULT_PORT}
    
    log_message "INFO" "配置信息 - 端口: $PORT"
}

# -----------------------------------------------------------------------------
# 通过PID文件关闭服务
# 返回值: 0-成功, 1-失败
# -----------------------------------------------------------------------------
shutdown_by_pid_file() {
    log_message "INFO" "尝试通过PID文件关闭服务..."
    
    # 检查PID文件是否存在
    if [ ! -f "$PID_FILE" ]; then
        log_message "INFO" "PID文件不存在: $PID_FILE"
        return 1
    fi
    
    # 读取PID
    local pid=$(cat "$PID_FILE")
    if [ -z "$pid" ]; then
        log_message "WARN" "PID文件为空"
        rm -f "$PID_FILE"
        return 1
    fi
    
    # 检查进程是否存在
    if ! ps -p $pid > /dev/null 2>&1; then
        log_message "INFO" "进程不存在 (PID: $pid)，清理PID文件"
        rm -f "$PID_FILE"
        return 1
    fi
    
    log_message "INFO" "发送终止信号到进程 (PID: $pid)"
    kill -TERM $pid
    
    # 等待进程结束
    log_message "INFO" "等待进程结束 (最多等待 ${MAX_WAIT_TIME} 秒)..."
    for i in $(seq 1 $MAX_WAIT_TIME); do
        if ! ps -p $pid > /dev/null 2>&1; then
            log_message "INFO" "进程已正常终止"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
    done
    
    # 强制终止
    log_message "WARN" "进程未正常终止，发送强制终止信号"
    kill -KILL $pid 2>/dev/null
    rm -f "$PID_FILE"
    return 0
}

# -----------------------------------------------------------------------------
# 通过端口关闭服务
# 返回值: 0-成功, 1-失败
# -----------------------------------------------------------------------------
shutdown_by_port() {
    log_message "INFO" "尝试通过端口 $PORT 关闭服务..."
    
    # 查找监听指定端口的Gunicorn进程
    local pids=$(lsof -i :$PORT -t -sTCP:LISTEN 2>/dev/null)
    
    if [ -z "$pids" ]; then
        log_message "INFO" "未找到监听端口 $PORT 的进程"
        return 1
    fi
    
    log_message "INFO" "找到进程 PID: $pids"
    
    # 发送终止信号
    log_message "INFO" "发送终止信号到进程"
    kill -TERM $pids 2>/dev/null
    
    # 等待进程结束
    log_message "INFO" "等待进程结束 (最多等待 ${MAX_WAIT_TIME} 秒)..."
    for i in $(seq 1 $MAX_WAIT_TIME); do
        if ! kill -0 $pids 2>/dev/null; then
            log_message "INFO" "进程已正常终止"
            return 0
        fi
        sleep 1
    done
    
    # 强制终止
    log_message "WARN" "进程未正常终止，发送强制终止信号"
    kill -KILL $pids 2>/dev/null
    return 0
}

# -----------------------------------------------------------------------------
# 验证关闭结果
# -----------------------------------------------------------------------------
verify_shutdown() {
    log_message "INFO" "验证关闭结果..."
    
    # 检查端口是否仍然被占用
    if lsof -i :$PORT -sTCP:LISTEN > /dev/null 2>&1; then
        log_message "WARN" "端口 $PORT 仍然被占用"
        return 1
    else
        log_message "INFO" "端口 $PORT 已释放"
        return 0
    fi
}

# -----------------------------------------------------------------------------
# 主函数
# -----------------------------------------------------------------------------
main() {
    log_message "INFO" "=== $SCRIPT_NAME 开始 ==="
    
    # 获取用户配置
    get_user_configuration
    
    # 尝试通过PID文件关闭
    if shutdown_by_pid_file; then
        verify_shutdown
        log_message "INFO" "=== $SCRIPT_NAME 完成 ==="
        exit 0
    fi
    
    # 尝试通过端口关闭
    if shutdown_by_port; then
        verify_shutdown
        log_message "INFO" "=== $SCRIPT_NAME 完成 ==="
        exit 0
    fi
    
    log_message "ERROR" "无法关闭服务"
    log_message "INFO" "=== $SCRIPT_NAME 完成 ==="
    exit 1
}

# -----------------------------------------------------------------------------
# 脚本入口点
# -----------------------------------------------------------------------------
# 检查是否直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi