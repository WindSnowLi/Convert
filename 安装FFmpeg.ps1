# FFmpeg 自动下载安装脚本（PowerShell）
Write-Host ""
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host "   自动下载安装 FFmpeg" -ForegroundColor Cyan
Write-Host "========================================"  -ForegroundColor Cyan
Write-Host ""

# 检查是否已经安装
$ffmpegInstalled = Get-Command ffmpeg -ErrorAction SilentlyContinue
if ($ffmpegInstalled) {
    Write-Host "✅ FFmpeg 已经安装！" -ForegroundColor Green
    ffmpeg -version | Select-Object -First 1
    Write-Host ""
    Read-Host "按 Enter 键退出"
    exit 0
}

Write-Host "正在检查 FFmpeg 安装状态..." -ForegroundColor Yellow
Write-Host ""

# 设置下载路径
$ffmpegDir = "C:\ffmpeg"
$downloadUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
$zipFile = "$env:TEMP\ffmpeg.zip"

Write-Host "📥 准备下载 FFmpeg..." -ForegroundColor Yellow
Write-Host "下载地址: $downloadUrl" -ForegroundColor Gray
Write-Host ""

try {
    # 下载 FFmpeg
    Write-Host "正在下载 FFmpeg（约 100MB，请稍候）..." -ForegroundColor Yellow
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "✅ 下载完成！" -ForegroundColor Green
    Write-Host ""

    # 解压
    Write-Host "正在解压文件..." -ForegroundColor Yellow
    if (Test-Path $ffmpegDir) {
        Remove-Item $ffmpegDir -Recurse -Force
    }
    Expand-Archive -Path $zipFile -DestinationPath "$env:TEMP\ffmpeg_extract" -Force
    
    # 移动文件
    $extractedFolder = Get-ChildItem "$env:TEMP\ffmpeg_extract" | Select-Object -First 1
    Move-Item $extractedFolder.FullName $ffmpegDir -Force
    Write-Host "✅ 解压完成！" -ForegroundColor Green
    Write-Host ""

    # 添加到系统 PATH
    Write-Host "正在配置环境变量..." -ForegroundColor Yellow
    $binPath = "$ffmpegDir\bin"
    
    # 获取当前 PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    
    if ($currentPath -notlike "*$binPath*") {
        try {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "Machine")
            Write-Host "✅ 环境变量配置完成！" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  需要管理员权限来配置环境变量" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "请手动添加到 PATH：$binPath" -ForegroundColor Yellow
        }
    }
    
    # 清理临时文件
    Remove-Item $zipFile -Force
    Remove-Item "$env:TEMP\ffmpeg_extract" -Recurse -Force
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ FFmpeg 安装成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "安装位置: $ffmpegDir" -ForegroundColor Gray
    Write-Host ""
    Write-Host "请重新打开终端窗口，然后运行 启动.bat" -ForegroundColor Yellow
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ 安装失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请尝试手动安装：" -ForegroundColor Yellow
    Write-Host "1. 访问: https://ffmpeg.org/download.html" -ForegroundColor Gray
    Write-Host "2. 下载 Windows 版本" -ForegroundColor Gray
    Write-Host "3. 解压并添加到系统 PATH" -ForegroundColor Gray
    Write-Host ""
}

Read-Host "按 Enter 键退出"
