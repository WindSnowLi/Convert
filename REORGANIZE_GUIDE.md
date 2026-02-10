# 📦 Media Converter 项目结构重组指南

## 🎯 为什么要重组？

将项目从扁平结构重组为标准的 Python 项目结构，具有以下优势：

### ✅ 规范化
- 符合 Python 社区最佳实践
- 便于其他开发者理解和贡献
- 支持标准的 pip 安装方式

### ✅ 可维护性
- 清晰的模块划分
- 代码、测试、文档分离
- 易于扩展和重构

### ✅ 可发布
- 可以发布到 PyPI
- 支持 `pip install media-converter`
- 版本管理规范

---

## 📁 新的项目结构

重组后的标准结构：

```
media-converter/
├── src/
│   └── media_converter/          # 主程序包
│       ├── __init__.py
│       ├── app.py
│       ├── ncm_decrypt.py
│       └── templates/
│           └── index.html
│
├── tests/                        # 测试文件
│   ├── __init__.py
│   ├── test_ncm.py
│   └── test_deployment.sh
│
├── docs/                         # 文档
│   ├── README.md
│   ├── 使用指南.md
│   ├── NCM格式说明.md
│   ├── Linux部署指南.md
│   ├── 快速部署参考.md
│   └── 部署脚本说明.md
│
├── scripts/                      # 脚本工具
│   ├── windows/                  # Windows 脚本
│   │   ├── 启动.bat
│   │   ├── 安装FFmpeg.bat
│   │   └── 安装FFmpeg.ps1
│   └── linux/                    # Linux 脚本
│       ├── deploy_linux.sh
│       ├── deploy_docker.sh
│       ├── deploy_menu.sh
│       └── setup.sh
│
├── docker/                       # Docker 配置
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── .dockerignore
│
├── requirements.txt              # 基础依赖
├── requirements-prod.txt         # 生产环境依赖
├── requirements-dev.txt          # 开发环境依赖
├── setup.py                      # 安装配置（传统）
├── pyproject.toml                # 项目配置（现代）
├── MANIFEST.in                   # 打包清单
├── Makefile                      # 快速命令
├── LICENSE                       # MIT 许可证
├── CHANGELOG.md                  # 变更日志
├── CONTRIBUTING.md               # 贡献指南
├── PROJECT_STRUCTURE.md          # 结构说明
├── .editorconfig                 # 编辑器配置
├── .gitignore                    # Git 忽略
└── README.md                     # 项目说明
```

---

## 🚀 如何重组？

### 方式一：自动重组（推荐） ⭐

#### Windows:
```batch
# 双击运行
reorganize_project.bat

# 或在命令行
reorganize_project.bat
```

#### Linux/macOS:
```bash
# 添加执行权限
chmod +x reorganize_project.sh

# 运行脚本
bash reorganize_project.sh
```

脚本会自动：
1. ✅ 创建标准目录结构
2. ✅ 移动文件到对应位置
3. ✅ 创建 `__init__.py` 文件
4. ✅ 设置正确的权限

### 方式二：手动重组

如果你想手动操作：

1. **创建目录结构**
   ```bash
   mkdir -p src/media_converter/templates
   mkdir -p tests
   mkdir -p docs
   mkdir -p scripts/{windows,linux}
   mkdir -p docker
   ```

2. **移动代码文件**
   ```bash
   # 移动 Python 代码
   mv app.py src/media_converter/
   mv ncm_decrypt.py src/media_converter/
   mv templates/* src/media_converter/templates/
   ```

3. **移动测试文件**
   ```bash
   mv test_ncm.py tests/
   mv test_deployment.sh tests/
   ```

4. **移动文档**
   ```bash
   mv 使用指南.md docs/
   mv NCM格式说明.md docs/
   mv Linux部署指南.md docs/
   mv 快速部署参考.md docs/
   mv 部署脚本说明.md docs/
   ```

5. **移动脚本**
   ```bash
   # Windows 脚本
   mv 启动.bat scripts/windows/
   mv 安装FFmpeg.* scripts/windows/
   
   # Linux 脚本
   mv deploy_*.sh scripts/linux/
   mv setup.sh scripts/linux/
   ```

6. **移动 Docker 文件**
   ```bash
   mv Dockerfile docker/
   mv docker-compose.yml docker/
   mv .dockerignore docker/
   ```

---

## 📦 安装和使用

重组后的项目支持标准的 Python 包安装方式：

### 开发模式安装

```bash
# 创建虚拟环境（推荐）
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# 可编辑安装（修改代码立即生效）
pip install -e .

# 安装开发依赖
pip install -r requirements-dev.txt
```

### 生产环境安装

```bash
# 从源码安装
pip install .

# 安装生产依赖
pip install -r requirements-prod.txt
```

### 运行应用

```bash
# 方式 1: 直接运行模块
python -m media_converter.app

# 方式 2: 使用命令行入口（安装后）
media-converter

# 方式 3: 使用 Makefile
make run
```

---

## 🔄 迁移注意事项

### 1. 导入路径变化

**旧的导入：**
```python
from ncm_decrypt import decrypt_ncm_file
```

**新的导入：**
```python
from media_converter.ncm_decrypt import decrypt_ncm_file
```

### 2. 模板路径

Flask 会自动在 `media_converter/templates/` 查找模板。
无需修改 `render_template('index.html')`。

### 3. 脚本路径更新

**Windows 启动：**
```batch
# 旧的
启动.bat

# 新的
scripts\windows\启动.bat

# 或使用 Makefile
make run
```

**Linux 部署：**
```bash
# 旧的
bash deploy_linux.sh

# 新的
bash scripts/linux/deploy_linux.sh

# 或使用 Makefile
make deploy-linux
```

### 4. Docker 配置更新

**Docker 构建：**
```bash
# 旧的
docker build -t media-converter .

# 新的
docker build -f docker/Dockerfile -t media-converter .

# 或使用 Docker Compose
docker compose -f docker/docker-compose.yml up -d
```

---

## 🧪 验证重组结果

### 1. 检查目录结构

```bash
# Linux/macOS
tree -L 3 -I '__pycache__|*.pyc|.git'

# Windows
dir /s /b | findstr /v ".git __pycache__"
```

### 2. 测试安装

```bash
# 开发模式安装
pip install -e .

# 检查是否能导入
python -c "from media_converter import app; print('✓ OK')"
```

### 3. 运行测试

```bash
# 运行测试套件
pytest tests/

# 或使用 Makefile
make test
```

### 4. 启动应用

```bash
# 启动 Web 应用
python -m media_converter.app

# 访问 http://localhost:52113
```

---

## 📋 更新 Makefile

重组后 Makefile 的新路径：

```makefile
# 运行应用
run:
	python -m media_converter.app

# 部署（Linux）
deploy-linux:
	bash scripts/linux/deploy_linux.sh

# 部署（Docker）
deploy-docker:
	bash scripts/linux/deploy_docker.sh

# 测试
test:
	pytest tests/ -v
```

---

## 🎓 最佳实践

### 开发工作流

1. **创建分支**
   ```bash
   git checkout -b feature/new-feature
   ```

2. **修改代码**
   - 编辑 `src/media_converter/` 中的文件
   - 添加测试到 `tests/`

3. **运行测试**
   ```bash
   make test
   ```

4. **格式化代码**
   ```bash
   black src/ tests/
   isort src/ tests/
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能"
   ```

### 版本发布

1. **更新版本号**
   - 修改 `src/media_converter/__init__.py` 中的 `__version__`
   - 更新 `CHANGELOG.md`

2. **构建分发包**
   ```bash
   python -m build
   ```

3. **发布到 PyPI**
   ```bash
   twine upload dist/*
   ```

---

## 🆘 常见问题

### Q: 重组后原来的脚本不能用了？

**A:** 更新脚本路径即可：
```bash
# Windows
scripts\windows\启动.bat

# Linux
bash scripts/linux/deploy_linux.sh

# 或使用 Makefile（推荐）
make run
make deploy-linux
```

### Q: 导入模块报错？

**A:** 确保已安装项目：
```bash
pip install -e .
```

### Q: 测试找不到模块？

**A:** 需要设置 PYTHONPATH 或使用 pytest：
```bash
# 方式 1: 安装项目
pip install -e .

# 方式 2: 设置 PYTHONPATH
export PYTHONPATH=src:$PYTHONPATH  # Linux/macOS
set PYTHONPATH=src;%PYTHONPATH%    # Windows

# 方式 3: 使用 pytest（推荐）
pytest tests/
```

### Q: Docker 构建失败？

**A:** 更新 Dockerfile 路径：
```bash
# 方式 1: 指定 Dockerfile
docker build -f docker/Dockerfile -t media-converter .

# 方式 2: 在 docker 目录构建
cd docker && docker build -t media-converter .

# 方式 3: 使用 Docker Compose（推荐）
docker compose -f docker/docker-compose.yml up -d
```

---

## 📚 相关文档

- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 详细的结构说明
- [CONTRIBUTING.md](CONTRIBUTING.md) - 贡献指南
- [CHANGELOG.md](CHANGELOG.md) - 变更日志
- [docs/](docs/) - 完整文档目录

---

## 💡 下一步

重组完成后，建议：

1. ✅ 查看 [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) 了解详细结构
2. ✅ 阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 学习开发规范
3. ✅ 运行 `make test` 确保一切正常
4. ✅ 更新你的 Git 仓库

---

**祝你重组顺利！** 🎉

如有问题，请查看文档或提交 Issue。
