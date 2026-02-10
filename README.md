# 💝 Media Converter - 多媒体格式转换工具

[![Python Version](https://img.shields.io/badge/python-3.7%2B-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

一个美观实用的音视频图片格式转换网页工具，专为你的女朋友打造！

## ✨ 功能特性

- 🎵 **音频转换** - 支持 MP3, WAV, AAC, FLAC, OGG, WMA, M4A, OPUS
- 🎬 **视频转换** - 支持 MP4, AVI, MKV, MOV, WMV, FLV, WebM, MPEG
- 🖼️ **图片转换** - 支持 JPG, PNG, GIF, BMP, WebP, ICO, TIFF
- ☁️ **网易云音乐** - 支持 NCM 格式解密转换（自动识别歌曲信息）
- 💝 **美观界面** - 渐变色设计，简洁优雅
- 📱 **响应式** - 支持手机、平板、电脑访问
- 🚀 **快速转换** - 本地处理，安全高效
- 🎯 **拖拽上传** - 支持点击或拖拽文件

## 📋 项目结构

本项目采用标准的 Python 项目结构：

```
media-converter/
├── src/media_converter/     # 主程序包
├── tests/                   # 测试文件
├── docs/                    # 文档
├── s0. 项目重组（可选）

如果你从旧版本升级，运行重组脚本：
```batch
reorganize_project.bat
```

#### 1. 安装项目

```bash
# 开发模式安装（推荐）
pip install -e .

# 或安装生产依赖文件]               # 项目配置
```

详细说明请查看 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

## 📋 环境要求

- Python 3.7+
- FFmpeg（用于音视频转换）

## 🚀 快速开始

### Windows 部署

#### 1. 安装 Python 依赖

```bash
pip install -r requirements.txt
```

#### 2. 安装 FFmpeg
#### 3. 运行应用

```bash
# 方式 1: 双击脚本
scripts\windows\启动.bat

# 方式 2: 命令行
python -m media_converter.app

# 方式 3: 命令行入口（安装后）
media-converterg.ps1` → "使用 PowerShell 运行"

**方式 2：手动安装**
- 下载 FFmpeg: https://ffmpeg.org/download.html
- 解压后将 `bin` 目录添加到系统环境变量 PATH 中
- 或使用 chocolatey: `choco install ffmpeg`

#### 3. 运行应用

双击 `启动.bat` 或运行：
```bash
python app.py
#### 0. 项目重组（可选）

如果你从旧版本升级，运行重组脚本：
```bash
bash reorganize_project.sh
```

提供两种部署方式：

#### 方式 1：一键部署脚本（推荐生产环境）

```bash
# 添加执行权限
chmod +x scripts/linux/deploy_linux.sh

# 运行部署脚本
sudo bash scripts/linux/deploy_linux.sh

# 或使用 Makefile
make deploy-linux
#### 方式 1：一键部署脚本（推荐生产环境）
方式 1: 使用部署脚本
chmod +x scripts/linux/deploy_docker.sh
bash scripts/linux/deploy_docker.sh

# 方式 2: 使用 Docker Compose
docker compose -f docker/docker-compose.yml up -d --build

# 方式 3: 使用 Makefile
make deploy-docker
```

**详细部署文档：** 查看 [docs/Linux部署指南.md](docs/
- ✅ 开机自启动

#### 方式 2：Docker 部署（推荐快速体验）

```bash
# 添加执行权限
chmod +x deploy_docker.sh

# 运行 Docker 部署
bash deploy_docker.sh
```

或使用 Docker Compose：
``1. 安装 FFmpeg
brew install ffmpeg

# 2. 安装项目
pip install -e .

# 3. 运行应用
python -m media_converter.app

# 或使用 Makefile
make run
```bash
# 安装 FFmpeg
brew install ffmpeg

# 安装 Python 依赖
pip install -r requirements.txt

# 运行应用
python app.py
```

### 访问应用


详细使用指南：[docs/使用指南.md](docs/使用指南.md)
在浏览器中打开: `http://localhost:52113`

如果要在局域网中访问（比如手机访问电脑上的应用）：
1. 查看电脑的 IP 地址（如 192.168.1.100）
2. 在手机浏览器中访问: `http://192.168.1.100:52113`

## 🎨 使用方法

1. 点击上传区域或拖拽文件到页面
2. 选� 开发安装

### 克隆项目

```bash
git clone https://github.com/yourusername/media-converter.git
cd media-converter
```

### 创建虚拟环境

```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows
```

### 安装开发依赖

```bash
pip install -e ".[dev]"
# 或
pip install -r requirements-dev.txt
```

### 运行测试

```bash
pytest tests/ -v
# 或
make test
```

### 代码格式化

```bash
black src/ tests/
isort src/ tests/
# 或
make format
```

## �择想要转换的输出格式
3. 点击"开始转换"按钮
4. 等待转换完成，文件会自动下载

## 📝 注意事项

- 最大支持 500MB 的文件上传
- 转换过程在服务器端进行，请确保有足够的磁盘空间
- 转换完成后临时文件会自动清理
- 建议在良好的网络环境下使用

## 🛠️ 技术栈

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🌟 Star History

如果这个项目对你有帮助，请给一个 ⭐️ Star！

## 🙏 致谢

- [Flask](https://flask.palletsprojects.com/) - Web 框架
- [FFmpeg](https://ffmpeg.org/) - 音视频处理
- [Pillow](https://python-pillow.org/) - 图片处理
- 所有贡献者和使用者

## 📞 联系方式

- 问题反馈：[GitHub Issues](https://github.com/yourusername/media-converter/issues)
- 邮箱：your.email@example.com

---

用 ❤️ 制作 | Made with ❤️*: HTML5 + CSS3 + JavaScript
- **设计**: 渐变色 + 现代化 UI
- **部署**: Systemd / Docker / Docker Compose

## 💖 特别说明

这个工具专门为你的女朋友设计，界面采用温馨的紫色渐变配色，操作简单直观，不需要任何技术背景就能轻松使用。

### 修改端口

编辑 `app.py` 文件的最后几行：

```python
app.run(debug=True, host='0.0.0.0', port=52113)  # 修改 port 参数
```

### 生产环境配置

建议使用：
- **Nginx** 作为反向代理
- **Gunicorn** 或 **uWSGI** 作为 WSGI 服务器
- **Supervisor** 或 **Systemd** 管理进程

详见 [Linux部署指南.md](Linux部署指南.md)

## 📋 部署方式对比

| 特性 | Windows | Linux (常规) | Linux (Docker) |
|------|---------|--------------|----------------|
| 部署难度 | ⭐ 简单 | ⭐⭐ 中等 | ⭐ 简单 |
| 性能 | 良好 | 最优 | 良好 |
| 开机自启 | ❌ 需配置 | ✅ 自动 | ✅ 自动 |
| 环境隔离 | ❌ | ❌ | ✅ 完全隔离 |
| 易于迁移 | ❌ | ⭐⭐ | ⭐⭐⭐ 容易 |
| 推荐场景 | 个人使用 | 生产服务器 | 测试/开发 |python
app.run(debug=True, host='0.0.0.0', port=52113)  # 修改 port 参数
```

## 📄 许可证

MIT License - 随意使用和修改！

---

用 ❤️ 制作
