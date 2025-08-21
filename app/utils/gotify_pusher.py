from dotenv import load_dotenv
import os
import requests

# 加载 .env 文件
load_dotenv()

def push_to_gotify(title="Notification", message="This is a test message", priority=0):
    """
    发送消息到 Gotify
    :param title: 消息标题，默认为 "Notification"
    :param message: 消息内容，默认为 "This is a test message"
    :param priority: 消息优先级，默认为 0
    :return: 布尔值，表示消息是否发送成功
    """
    try:
        base_url = os.getenv('GOTIFY_BASE_URL', '').rstrip('/')
        app_token = os.getenv('GOTIFY_APP_TOKEN', '')
        if not base_url or not app_token:
            print("GOTIFY_BASE_URL 或 GOTIFY_APP_TOKEN 未设置")
            return False

        response = requests.post(
            f'{base_url}/message',
            params={'token': app_token},  # 使用 params 正确传递 token
            json={
                "message": message,
                "priority": priority,
                "title": title
            }
        )
        
        response.raise_for_status()  # 检查响应状态
        # print(f"消息发送成功: {response.status_code}") # 调试用
        # print(response.json()) # 调试用
        return True
        
    except requests.RequestException as e:
        print(f"消息发送失败: {str(e)}")
        return False

def push_notice(msg_content):
    title_prefix = os.getenv('GOTIFY_TITLE', 'TEST')
    success = push_to_gotify(
        title=f"{title_prefix}_Notice",
        message=f"{msg_content}",
        priority=0
    )
    # print(f"发送结果: {'成功' if success else '失败'}")
    return


# 使用示例
if __name__ == "__main__":
    success = push_to_gotify(
        title="测试通知",
        message="这是一条测试消息",
        priority=5
    )
    print(f"发送结果: {'成功' if success else '失败'}")