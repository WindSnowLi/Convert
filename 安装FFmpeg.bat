@echo off
echo.
echo ========================================
echo    安装 FFmpeg（音视频转换必需）
echo ========================================
echo.
echo 正在检查 FFmpeg 是否已安装...
ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ FFmpeg 已经安装！
    pause
    exit /b 0
)

echo.
echo FFmpeg 未安装。请选择安装方式：
echo.
echo 1. 使用 Chocolatey 自动安装（推荐，需要管理员权限）
echo 2. 手动下载安装
echo 3. 退出
echo.
set /p choice="请输入选项 (1-3): "

if "%choice%"=="1" goto chocolatey
if "%choice%"=="2" goto manual
if "%choice%"=="3" exit /b 0
goto end

:chocolatey
echo.
echo 正在检查 Chocolatey 是否已安装...
choco -v >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Chocolatey 已安装
    echo.
    echo 正在安装 FFmpeg...
    choco install ffmpeg -y
    echo.
    echo ✅ FFmpeg 安装完成！
    echo 请重新打开终端，然后运行 启动.bat
) else (
    echo.
    echo ❌ Chocolatey 未安装
    echo.
    echo 请先安装 Chocolatey，然后重新运行此脚本
    echo 安装命令（需要管理员权限）：
    echo.
    echo Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    echo.
    echo 或者访问: https://chocolatey.org/install
)
pause
exit /b 0

:manual
echo.
echo 手动安装步骤：
echo.
echo 1. 访问 FFmpeg 官网: https://ffmpeg.org/download.html
echo 2. 下载 Windows 版本（推荐: gyan.dev 或 BtbN 构建版本）
echo 3. 解压到任意目录（如 C:\ffmpeg）
echo 4. 将 bin 目录添加到系统环境变量 PATH
echo    - 右键"此电脑" - 属性 - 高级系统设置
echo    - 环境变量 - 系统变量 - Path - 编辑
echo    - 新建 - 输入 FFmpeg 的 bin 目录路径
echo 5. 重新打开终端，运行: ffmpeg -version
echo.
echo 或者直接点击下面的链接下载：
echo https://github.com/BtbN/FFmpeg-Builds/releases
echo.
pause
exit /b 0

:end
echo.
echo 安装已取消
pause
