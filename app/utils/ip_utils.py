from flask import request

def get_real_ip():
    # 优先检查 X-Forwarded-For 头部
    if request.headers.get('X-Forwarded-For'):
        # X-Forwarded-For 可能包含多个 IP，取第一个（最原始的客户端 IP）
        return request.headers.get('X-Forwarded-For').split(',')[0].strip()
    
    # 检查 X-Real-IP 头部
    if request.headers.get('X-Real-IP'):
        return request.headers.get('X-Real-IP')
    
    # 回退到直接连接的 IP
    return request.remote_addr