# 🚀 快速开始指南

欢迎使用 Media Converter！本指南将帮助你在几分钟内完成部署。

---

## 📝 前提条件

- **Python**: 3.7 或更高版本
- **FFmpeg**: 音视频转换依赖
- **磁盘空间**: 至少 1GB 可用空间

---

## ⚡ 5 分钟快速部署

### Windows 用户

#### 方式 1: 一键启动（最简单）

1. **安装 FFmpeg**
   ```bash
   # 双击运行
   安装FFmpeg.bat
   ```

2. **安装依赖**
   ```bash
   pip install -r requirements.txt
   ```

3. **启动应用**
   ```bash
   # 双击运行
   启动.bat
   ```

4. **访问应用**
   
   打开浏览器访问：http://localhost:52113

#### 方式 2: 命令行

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 运行应用
python app.py
```

### Linux 用户

#### 方式 1: 一键部署（推荐）

```bash
# 添加执行权限并运行
chmod +x deploy_linux.sh
sudo bash deploy_linux.sh
```

这将自动：
- ✅ 检测并安装依赖
- ✅ 创建 systemd 服务
- ✅ 配置开机自启动
- ✅ 检测端口冲突

#### 方式 2: Docker 部署

```bash
# 使用部署脚本
chmod +x deploy_docker.sh
bash deploy_docker.sh

# 或使用 Docker Compose
docker compose up -d --build
```

#### 方式 3: 手动部署

```bash
# 1. 安装 FFmpeg
# Ubuntu/Debian
sudo apt update
sudo apt install ffmpeg python3-pip

# CentOS/RHEL
sudo yum install ffmpeg python3-pip

# 2. 安装 Python 依赖
pip3 install -r requirements.txt

# 3. 运行应用
python3 app.py
```

### macOS 用户

```bash
# 1. 安装 FFmpeg
brew install ffmpeg

# 2. 安装 Python 依赖
pip install -r requirements.txt

# 3. 运行应用
python app.py
```

---

## 🎯 使用演示

### 上传文件

1. **打开首页**: http://localhost:52113

2. **选择文件**:
   - 点击上传区域
   - 或拖拽文件到页面

3. **选择格式**:
   - 点击音频/视频/图片/NCM 标签
   - 选择目标格式

4. **开始转换**:
   - 点击"开始转换"按钮
   - 等待转换完成
   - 文件自动下载

### 支持的格式

| 类型 | 格式 |
|------|------|
| 🎵 音频 | MP3, WAV, AAC, FLAC, OGG, WMA, M4A, OPUS |
| 🎬 视频 | MP4, AVI, MKV, MOV, WMV, FLV, WebM, MPEG |
| 🖼️ 图片 | JPG, PNG, GIF, BMP, WebP, ICO, TIFF |
| ☁️ NCM | 网易云音乐加密格式 |

---

## 🔧 常见问题

### Q1: 运行时提示 "FFmpeg not found"？

**A:** FFmpeg 未正确安装或未在 PATH 中。

**解决方法**:
- **Windows**: 运行 `安装FFmpeg.bat` 或 `安装FFmpeg.ps1`
- **Linux**: `sudo apt install ffmpeg` (Ubuntu/Debian)
- **macOS**: `brew install ffmpeg`

验证安装:
```bash
ffmpeg -version
```

### Q2: 访问 http://localhost:52113 无法打开？

**A:** 检查应用是否正常运行。

**解决方法**:
1. 查看终端输出是否有错误
2. 确认端口 52113 未被占用:
   ```bash
   # Windows
   netstat -ano | findstr :52113
   
   # Linux/macOS
   netstat -an | grep 52113
   ```
3. 尝试更改端口（修改 app.py 中的 `port=52113`）

### Q3: 转换失败或出错？

**A:** 可能原因：
1. 文件格式不支持
2. 文件损坏
3. FFmpeg 版本问题

**解决方法**:
1. 查看应用日志
2. 确认文件完整性
3. 更新 FFmpeg 到最新版本

### Q4: 如何修改端口？

**A:** 编辑 `app.py` 文件最后一行:

```python
# 修改端口号
app.run(host='0.0.0.0', port=8080, debug=True)
```

### Q5: 如何部署到公网？

**A:** 生产环境部署建议：

1. **使用 Linux 部署脚本**:
   ```bash
   sudo bash deploy_linux.sh
   ```

2. **配置反向代理** (Nginx):
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:52113;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. **配置 HTTPS** (Let's Encrypt):
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

### Q6: NCM 文件转换失败？

**A:** 确保安装了必要的依赖:

```bash
pip install pycryptodome pyncm mutagen
```

---

## 📦 项目重组（可选）

如果你想将项目整理为标准的 Python 包结构：

### Windows
```bash
reorganize_project.bat
```

### Linux/macOS
```bash
bash reorganize_project.sh
```

重组后的结构：
```
media-converter/
├── src/media_converter/     # 主程序包
├── tests/                   # 测试文件
├── docs/                    # 文档
├── scripts/                 # 脚本工具
└── docker/                  # Docker 配置
```

详细说明请查看 [REORGANIZE_GUIDE.md](REORGANIZE_GUIDE.md)

---

## 🎓 进阶配置

### 修改上传限制

编辑 `app.py`:

```python
# 修改最大上传大小（默认 500MB）
app.config['MAX_CONTENT_LENGTH'] = 1000 * 1024 * 1024  # 1GB
```

### 添加鉴权保护

```python
from functools import wraps
from flask import request, Response

def check_auth(username, password):
    return username == 'admin' and password == 'secret'

def authenticate():
    return Response('Could not verify your access', 401)

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/')
@requires_auth
def index():
    return render_template('index.html')
```

### 使用 Gunicorn（生产环境）

```bash
# 安装 Gunicorn
pip install gunicorn

# 运行
gunicorn -w 4 -b 0.0.0.0:52113 app:app
```

### 配置日志

```python
import logging

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
```

---

## 🛠️ Makefile 快捷命令

安装后可以使用以下命令：

```bash
make install        # 安装依赖
make install-dev    # 安装开发依赖
make run           # 运行应用
make test          # 运行测试
make format        # 格式化代码
make lint          # 代码检查
make clean         # 清理临时文件

# 部署相关
make deploy-linux   # Linux 一键部署
make deploy-docker  # Docker 部署
make docker-build   # 构建 Docker 镜像
make docker-run     # 运行 Docker 容器
```

---

## 📚 更多文档

- [使用指南.md](使用指南.md) - 详细功能说明
- [Linux部署指南.md](Linux部署指南.md) - Linux 部署详解
- [NCM格式说明.md](NCM格式说明.md) - NCM 格式支持
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 项目结构
- [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南

---

## 🎉 部署成功！

恭喜！你已经成功部署了 Media Converter。

现在可以：
1. 📱 分享链接给你的女朋友
2. 🎨 自定义界面样式（编辑 templates/index.html）
3. ⚡ 优化性能（使用 Gunicorn + Nginx）
4. 🔒 添加安全措施（HTTPS + 鉴权）

**祝你使用愉快！** 💝

---

## 💬 需要帮助？

- 📖 查看文档：[docs/](docs/)
- 🐛 报告问题：[GitHub Issues](https://github.com/yourusername/media-converter/issues)
- 💬 讨论交流：[GitHub Discussions](https://github.com/yourusername/media-converter/discussions)
