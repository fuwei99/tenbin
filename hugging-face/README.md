---
title: Tenbin OpenAI API Adapter
emoji: 🚀
colorFrom: blue
colorTo: green
sdk: docker
app_port: 8000
license: apache-2.0
---

# Tenbin OpenAI API 适配器 - Hugging Face 部署

这个 Hugging Face Space 部署了一个与 OpenAI API 兼容的 Tenbin 适配器。它通过拉取一个预先构建好的私有 Docker 镜像来运行两个核心服务。配置完全通过 **Hugging Face Secrets** 完成，无需上传任何配置文件。

1.  **Turnstile-Solver**: 自动解决 Cloudflare 验证码的服务 (运行在端口 5000，仅内部访问)。
2.  **API 适配器**: 将 OpenAI 请求转换为 Tenbin 请求的主服务 (暴露在端口 8000)。

## 🚀 部署和配置指南

### 1. 设置仓库 Secrets (必需)

为了让应用正常工作，你**必须**在你的 Space 的 **Settings -> Repository secrets** 页面中设置以下 Secrets。

#### 基础镜像拉取凭证
-   **`DOCKER_USERNAME`**: 你的 GitHub 用户名 (例如: `fuwei99`)
-   **`DOCKER_PASSWORD`**: 你的 GitHub Personal Access Token (PAT)。
    -   你可以在 [GitHub Tokens 页面](https://github.com/settings/tokens/new) 创建一个新的 PAT。
    -   创建时，必须授予 `read:packages` 权限。

#### 应用运行配置
-   **`SESSION_ID`**: 你的 Tenbin 账户 `session_id`。
    -   **支持多个**: 你可以提供一个或多个 session_id，用逗号分隔。
    -   示例: `id_123abc,id_456def`
-   **`API_KEY`**: 你自定义的、用于访问此 API 服务的密钥。
    -   **支持多个**: 你可以提供一个或多个密钥，用逗号分隔。
    -   示例: `sk-mykey1,sk-mykey2`

### 2. 等待构建

完成以上 Secrets 设置后，Hugging Face 会自动使用 `Dockerfile` 进行构建并启动服务。你可以在 "Logs" 标签页查看启动进度。当看到 API 服务成功启动的日志时，即表示部署完成。

**注意**: 你不再需要手动创建 `tenbin.json`, `client_api_keys.json`, 或 `models.json` 文件。

## ⚙️ API 使用

服务启动后，API 端点是你的 Space URL，例如: `https://your-username-your-space-name.hf.space/v1`

```python
import openai

client = openai.OpenAI(
    api_key="sk-mykey1", # 使用你在 API_KEY secret 中设置的密钥
    base_url="https://your-username-your-space-name.hf.space/v1"
)

response = client.chat.completions.create(
    model="claude-3.7-sonnet", # 使用内置的默认模型之一
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```
