# 🐧 Linux 部署指南

本项目提供两种 Linux 部署方式：**常规部署**和 **Docker 部署**。

---

## 📋 部署前准备

### 系统要求

**支持的系统：**
- Ubuntu 18.04 / 20.04 / 22.04
- Debian 9 / 10 / 11
- CentOS 7 / 8
- RHEL 7 / 8

**硬件要求：**
- CPU: 2 核心以上
- 内存: 2GB 以上
- 磁盘: 10GB 以上可用空间

---

## 🚀 方式一：常规部署（推荐用于生产环境）

### 特点
- ✅ 直接安装在系统上
- ✅ 使用 systemd 管理服务
- ✅ 开机自启动
- ✅ 性能最优

### 快速部署

```bash
# 1. 上传项目文件到服务器
scp -r convert/ user@your-server:/tmp/

# 2. 登录服务器
ssh user@your-server

# 3. 进入项目目录
cd /tmp/convert

# 4. 添加执行权限
chmod +x deploy_linux.sh

# 5. 运行部署脚本（需要 root 权限）
sudo bash deploy_linux.sh
```

### 部署过程

脚本会自动完成以下步骤：

1. **检测系统** - 识别操作系统类型
2. **检查重复部署** - 如果已部署，提供选项：
   - 重新部署（删除旧版）
   - 更新部署（保留数据）
   - 退出
3. **安装依赖** - 安装 Python3、FFmpeg 等
4. **部署应用** - 复制文件到 `/opt/media-converter`
5. **配置环境** - 创建虚拟环境，安装依赖
6. **创建服务** - 配置 systemd 服务
7. **启动应用** - 自动启动并设置开机自启

### 服务管理

```bash
# 查看状态
systemctl status media-converter

# 启动服务
systemctl start media-converter

# 停止服务
systemctl stop media-converter

# 重启服务
systemctl restart media-converter

# 查看日志
journalctl -u media-converter -f

# 查看应用日志
tail -f /var/log/media-converter/app.log
```

### 卸载

```bash
sudo bash deploy_linux.sh uninstall
```

---

## 🐳 方式二：Docker 部署（推荐用于快速体验）

### 特点
- ✅ 环境隔离，不污染系统
- ✅ 一键部署，快速启动
- ✅ 易于迁移和扩展
- ✅ 自动检测重复部署

### 前置要求

确保已安装 Docker：

```bash
# 检查 Docker
docker --version

# 如果未安装，执行以下命令
curl -fsSL https://get.docker.com | sh

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker

# 添加当前用户到 docker 组（可选，避免使用 sudo）
sudo usermod -aG docker $USER
# 重新登录生效
```

### 快速部署

```bash
# 1. 上传项目文件到服务器
scp -r convert/ user@your-server:/tmp/

# 2. 登录服务器
ssh user@your-server

# 3. 进入项目目录
cd /tmp/convert

# 4. 添加执行权限
chmod +x deploy_docker.sh

# 5. 运行 Docker 部署脚本
bash deploy_docker.sh
```

### 部署选项

脚本支持两种 Docker 部署方式：

#### 选项 1: Docker Compose（推荐）

自动检测到 Docker Compose 时会提示选择。优点：
- 配置清晰
- 易于管理
- 支持多服务编排

```bash
# 手动使用 Docker Compose
docker compose up -d --build

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

#### 选项 2: Docker 命令

使用单个 Docker 命令运行，适合简单场景。

### Docker 管理命令

```bash
# 查看容器状态
docker ps -f name=media-converter

# 查看日志
docker logs -f media-converter

# 停止容器
docker stop media-converter

# 启动容器
docker start media-converter

# 重启容器
docker restart media-converter

# 进入容器
docker exec -it media-converter bash

# 查看资源占用
docker stats media-converter
```

### 卸载

```bash
bash deploy_docker.sh uninstall
```

---

## 🔧 重复部署处理

两个部署脚本都会**自动检测现有部署**，并提供选项：

### 常规部署检测项
- ✓ 应用目录是否存在
- ✓ systemd 服务是否存在
- ✓ 端口是否被占用
- ✓ 进程是否运行

### Docker 部署检测项
- ✓ 容器是否存在
- ✓ 镜像是否存在
- ✓ 端口是否被占用

### 处理选项

1. **重新部署** - 删除所有旧资源，全新安装
2. **更新部署** - 保留数据，更新应用
3. **重启服务** - 仅重启（Docker）
4. **退出** - 取消操作

---

## 📊 部署对比

| 特性 | 常规部署 | Docker 部署 |
|------|---------|------------|
| 部署速度 | 较慢 | 快速 |
| 资源占用 | 低 | 略高 |
| 环境隔离 | 无 | 完全隔离 |
| 易于迁移 | 较难 | 容易 |
| 系统集成 | 深度集成 | 轻度集成 |
| 性能 | 最优 | 略低（可忽略）|
| 维护难度 | 中等 | 简单 |
| 推荐场景 | 生产环境 | 测试/开发 |

---

## 🔍 故障排除

### 常规部署问题

**Q: 权限不足？**
```bash
# 确保使用 sudo
sudo bash deploy_linux.sh
```

**Q: 端口被占用？**
```bash
# 查看占用端口的进程
sudo netstat -tlnp | grep 52113

# 或使用 ss
sudo ss -tlnp | grep 52113

# 修改 app.py 中的端口
```

**Q: FFmpeg 安装失败？**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install ffmpeg

# CentOS/RHEL
sudo yum install epel-release
sudo yum install ffmpeg
```

**Q: Python 版本不兼容？**
```bash
# 检查 Python 版本（需要 3.7+）
python3 --version

# Ubuntu 安装 Python 3.9
sudo apt-get install python3.9 python3.9-venv
```

### Docker 部署问题

**Q: Docker 守护进程未运行？**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

**Q: 权限被拒绝？**
```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER
# 重新登录
```

**Q: 镜像构建失败？**
```bash
# 清理缓存重新构建
docker system prune -a
docker compose build --no-cache
```

**Q: 容器无法启动？**
```bash
# 查看详细日志
docker logs media-converter

# 检查端口占用
docker ps -a
```

---

## 🔐 安全建议

### 防火墙配置

**UFW (Ubuntu/Debian):**
```bash
sudo ufw allow 52113/tcp
sudo ufw reload
```

**Firewalld (CentOS/RHEL):**
```bash
sudo firewall-cmd --permanent --add-port=52113/tcp
sudo firewall-cmd --reload
```

### HTTPS 配置（生产环境推荐）

使用 Nginx 作为反向代理：

```bash
# 安装 Nginx
sudo apt-get install nginx

# 配置示例
sudo nano /etc/nginx/sites-available/media-converter
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:52113;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size 500M;
    }
}
```

```bash
# 启用配置
sudo ln -s /etc/nginx/sites-available/media-converter /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📈 性能优化

### 系统优化

```bash
# 增加文件描述符限制
sudo nano /etc/security/limits.conf
# 添加：
* soft nofile 65535
* hard nofile 65535
```

### Docker 优化

```yaml
# docker-compose.yml 中配置资源限制
services:
  media-converter:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
```

---

## 💡 使用建议

1. **开发/测试环境** → Docker 部署
2. **生产环境** → 常规部署 + Nginx
3. **个人使用** → 任意方式
4. **多实例部署** → Docker Compose

---

## 🆘 获取帮助

部署过程中遇到问题？

1. 查看日志文件
2. 检查防火墙和端口
3. 验证依赖安装
4. 查阅本文档的故障排除部分

---

**祝部署顺利！** 🎉
