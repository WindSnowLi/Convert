@echo off
REM ##############################################################################
REM 项目结构重组脚本 - Windows 版本
REM ##############################################################################

echo ================================================== 
echo   项目结构重组工具
echo ==================================================
echo.

echo 此脚本将重组项目为标准 Python 项目结构
echo.
echo media-converter/
echo   src/
echo     media_converter/          # 主程序包
echo   tests/                      # 测试文件
echo   docs/                       # 文档
echo   scripts/                    # 脚本
echo     windows/                  # Windows 脚本
echo     linux/                    # Linux 脚本
echo   docker/                     # Docker 配置
echo   [配置文件]                  # 项目配置
echo.

set /p confirm="是否继续? [y/N]: "
if /i not "%confirm%"=="y" (
    echo 已取消
    exit /b 0
)

echo.
echo ==================================================
echo   创建目录结构
echo ==================================================
echo.

REM 创建主目录结构
mkdir src\media_converter\templates 2>nul
mkdir tests 2>nul
mkdir docs 2>nul
mkdir scripts\windows 2>nul
mkdir scripts\linux 2>nul
mkdir docker 2>nul
mkdir config 2>nul

echo [SUCCESS] 目录结构创建完成

echo.
echo ==================================================
echo   移动文件
echo ==================================================
echo.

REM 移动 Python 代码
if exist "app.py" (
    move app.py src\media_converter\ >nul
    echo [INFO] 移动: app.py -^> src\media_converter\
)

if exist "ncm_decrypt.py" (
    move ncm_decrypt.py src\media_converter\ >nul
    echo [INFO] 移动: ncm_decrypt.py -^> src\media_converter\
)

REM 创建 __init__.py
(
echo """
echo Media Converter - 多媒体格式转换工具
echo.
echo 支持音频、视频、图片格式转换，以及网易云音乐 NCM 格式解密
echo """
echo.
echo __version__ = "1.0.0"
echo __author__ = "Your Name"
echo __email__ = "your.email@example.com"
echo.
echo from .app import app
echo from .ncm_decrypt import ^(
echo     decrypt_ncm_file,
echo     decrypt_ncm_to_format,
echo     get_ncm_metadata
echo ^)
echo.
echo __all__ = [
echo     "app",
echo     "decrypt_ncm_file",
echo     "decrypt_ncm_to_format",
echo     "get_ncm_metadata",
echo ]
) > src\media_converter\__init__.py

echo [SUCCESS] 创建: src\media_converter\__init__.py

REM 移动模板
if exist "templates" (
    xcopy /E /I /Y templates src\media_converter\templates >nul 2>&1
    rmdir /S /Q templates 2>nul
    echo [INFO] 移动: templates\ -^> src\media_converter\templates\
)

REM 移动测试文件
if exist "test_ncm.py" (
    move test_ncm.py tests\ >nul
    echo [INFO] 移动: test_ncm.py -^> tests\
)

if exist "test_deployment.sh" (
    move test_deployment.sh tests\ >nul
    echo [INFO] 移动: test_deployment.sh -^> tests\
)

REM 创建 tests/__init__.py
echo. > tests\__init__.py
echo [SUCCESS] 创建: tests\__init__.py

REM 移动文档
for %%f in ("使用指南.md" "NCM格式说明.md" "Linux部署指南.md" "快速部署参考.md" "部署脚本说明.md") do (
    if exist %%f (
        move %%f docs\ >nul
        echo [INFO] 移动: %%f -^> docs\
    )
)

REM 移动 Windows 脚本
for %%f in ("启动.bat" "安装FFmpeg.bat" "安装FFmpeg.ps1") do (
    if exist %%f (
        move %%f scripts\windows\ >nul
        echo [INFO] 移动: %%f -^> scripts\windows\
    )
)

REM 移动 Linux 脚本
for %%f in ("deploy_linux.sh" "deploy_docker.sh" "deploy_menu.sh" "setup.sh") do (
    if exist %%f (
        move %%f scripts\linux\ >nul
        echo [INFO] 移动: %%f -^> scripts\linux\
    )
)

REM 移动 Docker 文件
for %%f in ("Dockerfile" "docker-compose.yml" ".dockerignore") do (
    if exist %%f (
        move %%f docker\ >nul
        echo [INFO] 移动: %%f -^> docker\
    )
)

echo [SUCCESS] 文件移动完成

echo.
echo ==================================================
echo   重组完成
echo ==================================================
echo.
echo [SUCCESS] 项目结构已重组为规范格式！
echo.
echo 新的项目结构已创建
echo.
echo 后续步骤：
echo   1. 检查路径引用是否正确
echo   2. 更新文档中的路径
echo   3. 运行测试: python -m pytest tests/
echo   4. 安装开发模式: pip install -e .
echo.

pause
