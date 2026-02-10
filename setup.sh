#!/bin/bash

##############################################################################
# 一次性设置脚本
# 用于为所有部署脚本添加执行权限
##############################################################################

echo "=================================================="
echo "      为部署脚本添加执行权限"
echo "=================================================="
echo ""

# 脚本列表
scripts=(
    "deploy_linux.sh"
    "deploy_docker.sh"
    "deploy_menu.sh"
    "test_deployment.sh"
    "test_ncm.py"
)

# 添加执行权限
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "✓ $script"
    else
        echo "✗ $script (文件不存在)"
    fi
done

echo ""
echo "=================================================="
echo "      设置完成！"
echo "=================================================="
echo ""
echo "现在你可以运行："
echo ""
echo "  常规部署:     sudo bash deploy_linux.sh"
echo "  Docker 部署:  bash deploy_docker.sh"
echo "  部署菜单:     sudo bash deploy_menu.sh"
echo "  部署测试:     bash test_deployment.sh"
echo ""
echo "或使用 Makefile："
echo "  make deploy-menu"
echo ""
