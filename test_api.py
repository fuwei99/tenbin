import requests
import json
import sys

# 检查API是否正常运行
def check_api_status():
    try:
        # 检查模型列表API
        response = requests.get("http://localhost:8000/models", timeout=5)
        if response.status_code == 200:
            models = response.json()
            print(f"✅ API服务正常运行")
            print(f"📊 可用模型数量: {len(models['data'])}")
            print(f"🔍 部分可用模型: {', '.join([m['id'] for m in models['data'][:5]])}")
            return True
        else:
            print(f"❌ API服务响应异常: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到API服务 (http://localhost:8000)")
        print("   请确保已运行 main.py")
        return False
    except Exception as e:
        print(f"❌ 检查API状态时出错: {str(e)}")
        return False

# 检查Turnstile-Solver是否正常运行
def check_solver_status():
    try:
        # 简单检查Turnstile-Solver是否响应
        response = requests.get("http://127.0.0.1:5000/status", timeout=5)
        if response.status_code == 200:
            print("✅ Turnstile-Solver服务正常运行")
            return True
        else:
            print(f"❌ Turnstile-Solver服务响应异常: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到Turnstile-Solver服务 (http://127.0.0.1:5000)")
        print("   请确保已运行 api_solver.py")
        return False
    except Exception as e:
        print(f"❌ 检查Turnstile-Solver状态时出错: {str(e)}")
        return False

# 发送测试消息
def test_chat_completion():
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer sk-example-api-key"
    }
    
    payload = {
        "model": "Claude-3.7-Sonnet",  # 可以根据你的models.json中的模型进行修改
        "messages": [
            {"role": "user", "content": "用一句话介绍你自己"}
        ],
        "stream": False
    }
    
    try:
        print("\n🔄 正在发送测试消息...")
        response = requests.post("http://localhost:8000/v1/chat/completions", 
                                headers=headers, 
                                json=payload,
                                timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            content = result["choices"][0]["message"]["content"]
            print(f"✅ 测试成功! 模型响应:")
            print(f"💬 {content}")
            return True
        else:
            print(f"❌ 测试失败: {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"❌ 测试过程中出错: {str(e)}")
        return False

if __name__ == "__main__":
    print("==== Tenbin API 测试工具 ====")
    
    print("\n[1] 检查API服务状态...")
    api_ok = check_api_status()
    
    print("\n[2] 检查Turnstile-Solver状态...")
    solver_ok = check_solver_status()
    
    if api_ok and solver_ok:
        print("\n[3] 执行API调用测试...")
        test_chat_completion()
    else:
        print("\n❌ 服务检查失败，无法执行API测试")
        if not solver_ok:
            print("   提示: 请先启动Turnstile-Solver服务")
        if not api_ok:
            print("   提示: 请确保主API服务正常运行")
    
    print("\n==== 测试完成 ====") 