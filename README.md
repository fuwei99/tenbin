# Tenbin OpenAI API 适配器

这个项目允许你通过OpenAI兼容的API接口免费使用Tenbin上的AI模型（Claude、GPT-4等）。它使用Turnstile-Solver来自动解决Cloudflare的Turnstile验证。

## 准备工作

1. 你需要一个Tenbin账户，并获取其`sessionId`
2. 将`sessionId`填入`tenbin.json`文件中

## 文件说明

- `tenbin.json` - 存储Tenbin账户的sessionId
- `models.json` - AI模型映射表
- `client_api_keys.json` - 客户端API密钥列表
- `getCaptcha.py` - 用于获取Turnstile验证的工具
- `main.py` - 主程序，提供OpenAI兼容的API服务
- `start_services.cmd` - 一键启动所有服务的脚本

## 使用方法

### 一键启动（推荐）

1. 双击运行`start_services.cmd`
2. 系统会自动启动两个命令窗口:
   - Turnstile-Solver服务（端口5000）
   - Tenbin API适配器（端口8000）

### 手动启动

如果一键启动脚本不起作用，你可以手动启动服务：

1. 启动Turnstile-Solver:
```
cd Turnstile-Solver
venv\Scripts\activate
python api_solver.py
```

2. 在另一个命令窗口启动主程序:
```
cd <项目根目录>
venv\Scripts\activate
python main.py
```

## API使用

服务启动后，你可以像使用OpenAI API一样使用这个服务:

```python
import openai

# 设置API基础URL和密钥
openai.api_base = "http://localhost:8000/v1"
openai.api_key = "sk-example-api-key"  # 在client_api_keys.json中设置

# 创建聊天完成
response = openai.ChatCompletion.create(
    model="Claude-3.7-Sonnet",  # 从models.json中选择模型
    messages=[
        {"role": "user", "content": "你好，请介绍一下自己"}
    ],
    stream=True  # 支持流式响应
)

# 打印结果
for chunk in response:
    content = chunk.choices[0].delta.get("content", "")
    print(content, end="", flush=True)
```

## 支持的模型

所有在`models.json`中定义的模型都可以使用，包括但不限于:
- Claude系列（Claude-3-Opus, Claude-3.7-Sonnet等）
- GPT系列（GPT-4, GPT-4o等）
- Gemini系列
- Llama系列
- 更多...

## 故障排除

- 如果服务无法启动，请检查你的虚拟环境是否正确安装
- 确保tenbin.json中的sessionId是有效的
- 检查端口5000和8000是否被其他应用占用 