# 项目结构

本文档介绍 Media Converter 项目的目录结构和组织方式。

```
media-converter/
├── src/                            # 源代码目录
│   └── media_converter/            # 主程序包
│       ├── __init__.py             # 包初始化文件
│       ├── app.py                  # Flask 应用主文件
│       ├── ncm_decrypt.py          # NCM 格式解密模块
│       └── templates/              # HTML 模板
│           └── index.html          # 主页面模板
│
├── tests/                          # 测试目录
│   ├── __init__.py                 # 测试包初始化
│   ├── test_ncm.py                 # NCM 功能测试
│   └── test_deployment.sh          # 部署验证测试
│
├── docs/                           # 文档目录
│   ├── README.md                   # 文档首页
│   ├── 使用指南.md                 # 用户使用指南
│   ├── NCM格式说明.md              # NCM 格式详细说明
│   ├── Linux部署指南.md            # Linux 部署教程
│   ├── 快速部署参考.md             # 快速参考卡
│   ├── 部署脚本说明.md             # 部署脚本文档
│   └── PROJECT_STRUCTURE.md        # 本文档
│
├── scripts/                        # 脚本工具目录
│   ├── windows/                    # Windows 脚本
│   │   ├── 启动.bat                # Windows 启动脚本
│   │   ├── 安装FFmpeg.bat          # FFmpeg 安装助手
│   │   └── 安装FFmpeg.ps1          # FFmpeg 自动安装
│   └── linux/                      # Linux 脚本
│       ├── deploy_linux.sh         # Linux 常规部署
│       ├── deploy_docker.sh        # Docker 部署
│       ├── deploy_menu.sh          # 交互式部署菜单
│       └── setup.sh                # 权限设置脚本
│
├── docker/                         # Docker 配置目录
│   ├── Dockerfile                  # Docker 镜像定义
│   ├── docker-compose.yml          # Docker Compose 配置
│   └── .dockerignore               # Docker 构建忽略
│
├── config/                         # 配置文件目录（可选）
│
├── .github/                        # GitHub 配置（可选）
│   └── workflows/                  # GitHub Actions
│       └── ci.yml                  # CI/CD 配置
│
├── requirements.txt                # 生产环境依赖
├── setup.py                        # 安装配置（传统）
├── pyproject.toml                  # 项目配置（现代）
├── MANIFEST.in                     # 打包清单
├── Makefile                        # 快速命令工具
├── .gitignore                      # Git 忽略文件
├── LICENSE                         # 开源许可证
├── README.md                       # 项目说明
├── CHANGELOG.md                    # 变更日志
├── CONTRIBUTING.md                 # 贡献指南
├── reorganize_project.sh           # 重组脚本（Linux）
└── reorganize_project.bat          # 重组脚本（Windows）
```

## 📂 目录说明

### `src/media_converter/`
**主程序包** - 包含所有核心业务逻辑

- `__init__.py` - 定义包版本、导出接口
- `app.py` - Flask Web 应用，路由定义，业务逻辑
- `ncm_decrypt.py` - NCM 格式解密算法实现
- `templates/` - Jinja2 HTML 模板文件

### `tests/`
**测试代码** - 所有测试相关文件

- 单元测试
- 集成测试
- 部署验证测试
- 遵循 pytest 规范

### `docs/`
**文档中心** - 用户和开发者文档

- 使用文档
- 部署指南
- API 说明
- 开发文档

### `scripts/`
**工具脚本** - 部署和管理脚本

#### `scripts/windows/`
- Windows 平台脚本
- `.bat` 和 `.ps1` 文件
- 启动、安装工具

#### `scripts/linux/`
- Linux 平台脚本
- Bash shell 脚本
- 部署、管理工具

### `docker/`
**容器化配置** - Docker 相关文件

- `Dockerfile` - 镜像构建定义
- `docker-compose.yml` - 多容器编排
- `.dockerignore` - 构建排除规则

### 配置文件

#### `requirements.txt`
生产环境 Python 依赖包列表

#### `setup.py`
传统的 Python 包安装配置（向后兼容）

#### `pyproject.toml`
现代 Python 项目配置（推荐）：
- 构建系统配置
- 项目元数据
- 依赖管理
- 工具配置（black, pytest, mypy 等）

#### `MANIFEST.in`
定义打包时包含的额外文件

#### `Makefile`
快速命令封装，简化常用操作

## 🎯 设计原则

### 1. 关注点分离
- 代码、测试、文档、脚本分离
- 每个模块职责单一

### 2. 可扩展性
- 模块化设计
- 便于添加新功能
- 插件化架构预留

### 3. 跨平台支持
- Windows 和 Linux 脚本分离
- 平台无关的核心代码
- Docker 容器化部署

### 4. 开发友好
- 清晰的目录结构
- 完善的文档
- 易于本地开发调试

### 5. 生产就绪
- 完整的部署方案
- 日志和监控
- 错误处理

## 📦 包管理

### 安装方式

#### 开发模式安装
```bash
# 可编辑安装，修改代码立即生效
pip install -e .

# 安装开发依赖
pip install -e ".[dev]"
```

#### 生产安装
```bash
# 从源码安装
pip install .

# 从 PyPI 安装（发布后）
pip install media-converter
```

#### 构建分发包
```bash
# 构建 wheel 和 sdist
python -m build

# 生成的文件在 dist/ 目录
dist/
├── media_converter-1.0.0-py3-none-any.whl
└── media-converter-1.0.0.tar.gz
```

## 🔄 工作流程

### 开发流程

1. **克隆项目**
   ```bash
   git clone https://github.com/yourusername/media-converter.git
   cd media-converter
   ```

2. **创建虚拟环境**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   venv\Scripts\activate     # Windows
   ```

3. **安装开发依赖**
   ```bash
   pip install -e ".[dev]"
   ```

4. **开发代码**
   - 编辑 `src/media_converter/` 中的文件
   - 添加测试到 `tests/`
   - 更新文档到 `docs/`

5. **运行测试**
   ```bash
   pytest tests/
   ```

6. **代码格式化**
   ```bash
   black src/ tests/
   isort src/ tests/
   ```

7. **提交代码**
   ```bash
   git add .
   git commit -m "feat: 添加新功能"
   git push
   ```

### 部署流程

#### 本地开发
```bash
# 直接运行
python src/media_converter/app.py

# 或使用 Makefile
make run
```

#### Linux 生产环境
```bash
# 使用部署脚本
sudo bash scripts/linux/deploy_linux.sh
```

#### Docker 部署
```bash
# 使用 Docker 脚本
bash scripts/linux/deploy_docker.sh

# 或使用 Docker Compose
docker compose -f docker/docker-compose.yml up -d
```

## 🎨 代码组织

### 模块职责

#### `app.py`
- Flask 应用初始化
- 路由定义
- 请求处理
- 文件转换调度
- 错误处理

#### `ncm_decrypt.py`
- NCM 文件解密算法
- 元数据提取
- 格式转换接口

#### `templates/index.html`
- 用户界面
- 前端交互逻辑
- 样式定义

### 导入规范

```python
# 标准库
import os
import sys

# 第三方库
from flask import Flask, request
from PIL import Image

# 本地模块
from media_converter.ncm_decrypt import decrypt_ncm_file
```

## 📝 命名约定

### 文件命名
- Python 文件：`snake_case.py`
- 测试文件：`test_*.py`
- 脚本文件：`kebab-case.sh`
- 文档文件：`PascalCase.md` 或 `kebab-case.md`

### 代码命名
- 类名：`PascalCase`
- 函数/方法：`snake_case`
- 常量：`UPPER_SNAKE_CASE`
- 私有成员：`_leading_underscore`

## 🔧 环境变量

项目支持的环境变量（可选）：

```bash
# Flask 配置
FLASK_ENV=production
FLASK_DEBUG=0

# 应用配置
APP_PORT=52113
APP_HOST=0.0.0.0
MAX_CONTENT_LENGTH=524288000  # 500MB

# 路径配置
UPLOAD_FOLDER=uploads
OUTPUT_FOLDER=outputs
LOG_DIR=/var/log/media-converter
```

## 📊 依赖关系

```
media-converter
├── Flask (Web 框架)
├── Pillow (图片处理)
├── pycryptodome (加密解密)
├── pyncm (网易云音乐)
└── Werkzeug (WSGI 工具)

开发依赖
├── pytest (测试框架)
├── black (代码格式化)
├── flake8 (代码检查)
├── mypy (类型检查)
└── isort (导入排序)

外部依赖
└── FFmpeg (音视频处理)
```

## 🚀 扩展建议

### 添加新功能

1. 在 `src/media_converter/` 创建新模块
2. 在 `__init__.py` 中导出接口
3. 在 `app.py` 中添加路由
4. 编写测试用例
5. 更新文档

### 添加新格式支持

1. 在 `app.py` 中添加格式定义
2. 实现转换函数
3. 更新前端格式列表
4. 添加测试用例

### 集成新服务

1. 创建新的模块文件
2. 实现服务接口
3. 在主应用中集成
4. 添加配置选项

## 📚 参考资源

- [Python 包结构最佳实践](https://packaging.python.org/)
- [Flask 项目结构](https://flask.palletsprojects.com/en/2.3.x/tutorial/layout/)
- [Python 风格指南 PEP 8](https://pep8.org/)
- [语义化版本](https://semver.org/)

---

有问题或建议？请查看 [CONTRIBUTING.md](../CONTRIBUTING.md) 或提交 Issue。
