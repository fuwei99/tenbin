@echo off
chcp 65001 >nul
title Tenbin API 服务启动器

REM 设置变量
set "TENBIN_DIR=%~dp0"
set "SOLVER_DIR=%TENBIN_DIR%Turnstile-Solver"
set "VENV_ACTIVATE=%SOLVER_DIR%\venv\Scripts\activate.bat"
set "CLIENT_API_KEYS_FILE=%TENBIN_DIR%client_api_keys.json"

echo ================================================
echo             Tenbin API 服务启动器
echo ================================================
echo.

REM 检查python是否安装
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未检测到Python安装。请安装Python 3.8或更高版本。
    echo 你可以从 https://www.python.org/downloads/ 下载Python。
    pause
    exit /b 1
)

REM 检查Python版本
for /f "tokens=2" %%a in ('python --version 2^>^&1') do set "PYTHON_VERSION=%%a"
for /f "tokens=1 delims=." %%a in ("%PYTHON_VERSION%") do set "PYTHON_MAJOR=%%a"
for /f "tokens=2 delims=." %%a in ("%PYTHON_VERSION%") do set "PYTHON_MINOR=%%a"

if %PYTHON_MAJOR% LSS 3 (
    echo [错误] Python版本过低。需要Python 3.8或更高版本。
    echo 当前版本: %PYTHON_VERSION%
    pause
    exit /b 1
)

if %PYTHON_MAJOR% EQU 3 (
    if %PYTHON_MINOR% LSS 8 (
        echo [错误] Python版本过低。需要Python 3.8或更高版本。
        echo 当前版本: %PYTHON_VERSION%
        pause
        exit /b 1
    )
)

echo [✓] 检测到Python %PYTHON_VERSION%

REM 检查Turnstile-Solver目录
if not exist "%SOLVER_DIR%" (
    echo [错误] 未找到Turnstile-Solver目录
    echo 请确保已运行 git clone https://github.com/Theyka/Turnstile-Solver.git
    pause
    exit /b 1
)

echo [✓] 找到Turnstile-Solver目录

REM 检查虚拟环境
if not exist "%VENV_ACTIVATE%" (
    echo [i] 未找到虚拟环境，正在创建...
    cd /d "%SOLVER_DIR%"
    python -m venv venv
    if %ERRORLEVEL% NEQ 0 (
        echo [错误] 创建虚拟环境失败
        pause
        exit /b 1
    )
    echo [✓] 虚拟环境创建成功
) else (
    echo [✓] 找到虚拟环境
)

REM 检查依赖文件
echo [i] 正在检查必要文件...

REM 检查getCaptcha.py
if not exist "%TENBIN_DIR%getCaptcha.py" (
    echo [错误] 未找到getCaptcha.py文件
    pause
    exit /b 1
)

REM 检查models.json
if not exist "%TENBIN_DIR%models.json" (
    echo [错误] 未找到models.json文件
    pause
    exit /b 1
)

REM 检查tenbin.json
if not exist "%TENBIN_DIR%tenbin.json" (
    echo [错误] 未找到tenbin.json文件
    pause
    exit /b 1
)

REM 检查main.py
if not exist "%TENBIN_DIR%main.py" (
    echo [错误] 未找到main.py文件
    pause
    exit /b 1
)

echo [✓] 所有必要文件检查完成

REM 询问是否需要修改API密钥
if not exist "%CLIENT_API_KEYS_FILE%" (
    echo [i] 未找到client_api_keys.json文件，将创建默认文件
    echo [ > "%CLIENT_API_KEYS_FILE%"
    echo     "sk-example-api-key" >> "%CLIENT_API_KEYS_FILE%"
    echo ] >> "%CLIENT_API_KEYS_FILE%"
    echo [✓] 已创建默认API密钥文件
)

echo.
echo 当前API密钥配置:
type "%CLIENT_API_KEYS_FILE%"
echo.

set /p MODIFY_KEYS=是否需要修改API密钥? (y/n): 
if /i "%MODIFY_KEYS%"=="y" goto :MODIFY_API_KEYS
if /i "%MODIFY_KEYS%"=="n" goto :SKIP_API_KEYS
goto :SKIP_API_KEYS

:MODIFY_API_KEYS
echo.
echo 请输入新的API密钥 (多个密钥请用逗号分隔，不要包含空格):
set /p NEW_KEYS=

REM 处理输入的密钥
echo [ > "%CLIENT_API_KEYS_FILE%"

set "IS_FIRST=1"
for /f "tokens=1 delims=," %%a in ("%NEW_KEYS%") do (
    if "%IS_FIRST%"=="1" (
        echo     "%%a" >> "%CLIENT_API_KEYS_FILE%"
        set "IS_FIRST=0"
    ) else (
        echo     ,"%%a" >> "%CLIENT_API_KEYS_FILE%"
    )
)

echo ] >> "%CLIENT_API_KEYS_FILE%"
echo [✓] API密钥已更新

:SKIP_API_KEYS

REM 检查tenbin.json中的session_id
findstr /C:"your_session_id_here" "%TENBIN_DIR%tenbin.json" >nul 2>nul
if %ERRORLEVEL% EQU 0 goto :UPDATE_SESSION_PROMPT
goto :SKIP_SESSION_PROMPT

:UPDATE_SESSION_PROMPT
echo.
echo [!] 检测到tenbin.json中的session_id是默认值
echo     你需要用真实的session_id替换它才能使用API
echo.

set /p UPDATE_SESSION=是否现在更新session_id? (y/n): 
if /i "%UPDATE_SESSION%"=="y" goto :UPDATE_SESSION_ID
if /i "%UPDATE_SESSION%"=="n" goto :SKIP_SESSION_ID
goto :SKIP_SESSION_ID

:UPDATE_SESSION_ID
echo.
echo 请输入你的Tenbin session_id:
set /p SESSION_ID=

REM 更新tenbin.json
echo [ > "%TENBIN_DIR%tenbin.json"
echo     { >> "%TENBIN_DIR%tenbin.json"
echo         "session_id": "%SESSION_ID%" >> "%TENBIN_DIR%tenbin.json"
echo     } >> "%TENBIN_DIR%tenbin.json"
echo ] >> "%TENBIN_DIR%tenbin.json"

echo [✓] session_id已更新
goto :SKIP_SESSION_PROMPT

:SKIP_SESSION_ID
echo.
echo [i] 请记得稍后手动更新session_id
echo     否则API调用将会失败

:SKIP_SESSION_PROMPT

REM 安装依赖
echo.
echo [i] 正在安装Turnstile-Solver依赖...
cd /d "%SOLVER_DIR%"
call "%VENV_ACTIVATE%"
pip install -r requirements.txt >nul 2>nul
pip install patchright >nul 2>nul

REM 检查patchright是否已安装
python -c "import patchright" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 安装patchright失败
    pause
    exit /b 1
)

echo [✓] Turnstile-Solver依赖安装完成

REM 安装主程序依赖
echo.
echo [i] 正在安装主程序依赖...
cd /d "%TENBIN_DIR%"
pip install -r requirements.txt >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 安装主程序依赖失败
    pause
    exit /b 1
)

echo [✓] 主程序依赖安装完成

REM 检查是否需要安装chromium
python -c "import pyppeteer.chromium_downloader" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :INSTALL_CHROMIUM
python -c "from pyppeteer.chromium_downloader import check_chromium; import sys; sys.exit(0 if check_chromium() else 1)" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :INSTALL_CHROMIUM
goto :SKIP_CHROMIUM_INSTALL

:INSTALL_CHROMIUM
echo.
echo [i] 正在安装Chromium浏览器（首次运行需要下载，请耐心等待）...
cd /d "%SOLVER_DIR%"
python -m patchright install chromium
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 安装Chromium浏览器失败
    pause
    exit /b 1
)
echo [✓] Chromium浏览器安装完成
goto :CONTINUE_AFTER_CHROMIUM

:SKIP_CHROMIUM_INSTALL
echo [✓] Chromium浏览器已安装

:CONTINUE_AFTER_CHROMIUM
echo.
echo [i] 所有准备工作已完成，正在启动服务...
echo.

REM 首先确保没有之前运行的实例
echo [i] 确保没有旧的服务实例正在运行...
taskkill /F /FI "WINDOWTITLE eq Turnstile-Solver*" >nul 2>nul
taskkill /F /FI "WINDOWTITLE eq Tenbin API适配器*" >nul 2>nul

REM 创建两个窗口分别运行服务
echo [i] 正在启动Turnstile-Solver服务...
cd /d "%SOLVER_DIR%"
start "Turnstile-Solver" cmd /k "chcp 65001 >nul && call "%VENV_ACTIVATE%" && echo Turnstile-Solver服务正在启动... && python api_solver.py"

REM 等待Turnstile-Solver启动
echo [i] 等待Turnstile-Solver启动...
timeout /t 5 /nobreak >nul

REM 启动主程序
echo [i] 正在启动Tenbin API适配器...
cd /d "%TENBIN_DIR%"
start "Tenbin API适配器" cmd /k "chcp 65001 >nul && call "%SOLVER_DIR%\venv\Scripts\activate.bat" && echo Tenbin API适配器正在启动... && python main.py"

echo.
echo ================================================
echo             服务启动完成!
echo ================================================
echo.
echo Turnstile-Solver服务运行在: http://127.0.0.1:5000
echo Tenbin API适配器运行在: http://127.0.0.1:8000
echo.
echo 接下来，你可以运行测试脚本检查API是否正常工作:
echo   python test_api.py
echo.
echo 或者直接使用以下示例代码调用API:
echo   import openai
echo   openai.api_base = "http://localhost:8000/v1"
echo   openai.api_key = "sk-example-api-key"  # 使用你设置的API密钥
echo.
echo 如需了解更多信息，请查看README.md文件
echo.
echo 按任意键关闭所有服务并退出启动器...
pause >nul

echo.
echo [i] 正在关闭所有服务...

REM 关闭命令行窗口 - 使用窗口标题查找
echo [i] 正在关闭Turnstile-Solver窗口...
taskkill /F /FI "WINDOWTITLE eq Turnstile-Solver*" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [✓] 已关闭Turnstile-Solver窗口
) else (
    echo [!] 未找到Turnstile-Solver窗口
)

echo [i] 正在关闭Tenbin API适配器窗口...
taskkill /F /FI "WINDOWTITLE eq Tenbin API适配器*" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [✓] 已关闭Tenbin API适配器窗口
) else (
    echo [!] 未找到Tenbin API适配器窗口
)

REM 确保所有Python进程都已终止
echo [i] 确保所有Python进程已终止...
taskkill /F /IM python.exe /T >nul 2>nul

echo [i] 所有服务已关闭，感谢使用！ 