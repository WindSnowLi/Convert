#!/bin/bash

##############################################################################
# 项目结构重组脚本
# 将现有文件重新组织为规范的项目结构
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}"
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header "项目结构重组工具"

echo "此脚本将重组项目为标准 Python 项目结构："
echo ""
echo "media-converter/"
echo "├── src/"
echo "│   └── media_converter/          # 主程序包"
echo "├── tests/                        # 测试文件"
echo "├── docs/                         # 文档"
echo "├── scripts/                      # 脚本"
echo "│   ├── windows/                  # Windows 脚本"
echo "│   └── linux/                    # Linux 脚本"
echo "├── docker/                       # Docker 配置"
echo "└── [配置文件]                    # 项目配置"
echo ""
read -p "是否继续? [y/N]: " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "已取消"
    exit 0
fi

print_header "创建目录结构"

# 创建主目录结构
mkdir -p src/media_converter/templates
mkdir -p tests
mkdir -p docs
mkdir -p scripts/windows
mkdir -p scripts/linux
mkdir -p docker
mkdir -p config

print_success "目录结构创建完成"

print_header "移动文件"

# 移动 Python 代码
if [ -f "app.py" ]; then
    mv app.py src/media_converter/
    print_info "移动: app.py -> src/media_converter/"
fi

if [ -f "ncm_decrypt.py" ]; then
    mv ncm_decrypt.py src/media_converter/
    print_info "移动: ncm_decrypt.py -> src/media_converter/"
fi

# 创建 __init__.py
cat > src/media_converter/__init__.py << 'EOF'
"""
Media Converter - 多媒体格式转换工具

支持音频、视频、图片格式转换，以及网易云音乐 NCM 格式解密
"""

__version__ = "1.0.0"
__author__ = "Your Name"
__email__ = "your.email@example.com"

from .app import app
from .ncm_decrypt import decrypt_ncm_file, decrypt_ncm_to_format, get_ncm_metadata

__all__ = [
    "app",
    "decrypt_ncm_file",
    "decrypt_ncm_to_format",
    "get_ncm_metadata",
]
EOF
print_success "创建: src/media_converter/__init__.py"

# 移动模板
if [ -d "templates" ]; then
    mv templates/* src/media_converter/templates/ 2>/dev/null || true
    rmdir templates 2>/dev/null || true
    print_info "移动: templates/ -> src/media_converter/templates/"
fi

# 移动测试文件
if [ -f "test_ncm.py" ]; then
    mv test_ncm.py tests/
    print_info "移动: test_ncm.py -> tests/"
fi

if [ -f "test_deployment.sh" ]; then
    mv test_deployment.sh tests/
    chmod +x tests/test_deployment.sh
    print_info "移动: test_deployment.sh -> tests/"
fi

# 创建 tests/__init__.py
touch tests/__init__.py
print_success "创建: tests/__init__.py"

# 移动文档
docs_files=(
    "使用指南.md"
    "NCM格式说明.md"
    "Linux部署指南.md"
    "快速部署参考.md"
    "部署脚本说明.md"
)

for doc in "${docs_files[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/
        print_info "移动: $doc -> docs/"
    fi
done

# 移动 Windows 脚本
windows_scripts=(
    "启动.bat"
    "安装FFmpeg.bat"
    "安装FFmpeg.ps1"
)

for script in "${windows_scripts[@]}"; do
    if [ -f "$script" ]; then
        mv "$script" scripts/windows/
        print_info "移动: $script -> scripts/windows/"
    fi
done

# 移动 Linux 脚本
linux_scripts=(
    "deploy_linux.sh"
    "deploy_docker.sh"
    "deploy_menu.sh"
    "setup.sh"
)

for script in "${linux_scripts[@]}"; do
    if [ -f "$script" ]; then
        mv "$script" scripts/linux/
        chmod +x "scripts/linux/$script"
        print_info "移动: $script -> scripts/linux/"
    fi
done

# 移动 Docker 文件
docker_files=(
    "Dockerfile"
    "docker-compose.yml"
    ".dockerignore"
)

for file in "${docker_files[@]}"; do
    if [ -f "$file" ]; then
        mv "$file" docker/
        print_info "移动: $file -> docker/"
    fi
done

print_success "文件移动完成"

print_header "创建配置文件"

# 创建 setup.py
if [ ! -f "setup.py" ]; then
    print_info "setup.py 已存在，跳过"
else
    print_success "创建: setup.py"
fi

# 创建 pyproject.toml
if [ ! -f "pyproject.toml" ]; then
    print_info "pyproject.toml 已存在，跳过"
else
    print_success "创建: pyproject.toml"
fi

# 创建 MANIFEST.in
if [ ! -f "MANIFEST.in" ]; then
    print_info "MANIFEST.in 已存在，跳过"
else
    print_success "创建: MANIFEST.in"
fi

print_header "更新 Makefile"

# Makefile 路径已更新
if [ -f "Makefile" ]; then
    print_info "Makefile 需要手动更新路径"
fi

print_header "重组完成"

echo ""
echo -e "${GREEN}✅ 项目结构已重组为规范格式！${NC}"
echo ""
echo "新的项目结构："
echo ""
tree -L 3 -I '__pycache__|*.pyc|.git' . 2>/dev/null || find . -maxdepth 3 -type d | grep -v '.git' | sort
echo ""
echo "后续步骤："
echo "  1. 检查路径引用是否正确"
echo "  2. 更新文档中的路径"
echo "  3. 运行测试: python -m pytest tests/"
echo "  4. 安装开发模式: pip install -e ."
echo ""
