#!/bin/bash

##############################################################################
# 快速部署菜单 - 选择你的部署方式
##############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        💝  多媒体格式转换工具  💝                         ║
║              Linux 快速部署菜单                           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_menu() {
    echo -e "${CYAN}请选择部署方式：${NC}\n"
    
    echo -e "${GREEN}1)${NC} 🚀 常规部署（推荐生产环境）"
    echo -e "   - 使用 systemd 管理服务"
    echo -e "   - 性能最优"
    echo -e "   - 开机自启动"
    echo ""
    
    echo -e "${GREEN}2)${NC} 🐳 Docker 部署（推荐快速体验）"
    echo -e "   - 环境隔离"
    echo -e "   - 快速部署"
    echo -e "   - 易于迁移"
    echo ""
    
    echo -e "${GREEN}3)${NC} 🐋 Docker Compose 部署"
    echo -e "   - 配置管理"
    echo -e "   - 易于扩展"
    echo -e "   - 支持多服务"
    echo ""
    
    echo -e "${GREEN}4)${NC} 📊 查看部署状态"
    echo ""
    
    echo -e "${GREEN}5)${NC} 🗑️  卸载应用"
    echo ""
    
    echo -e "${GREEN}6)${NC} 📖 查看帮助文档"
    echo ""
    
    echo -e "${GREEN}0)${NC} 🚪 退出"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}[ERROR]${NC} 请使用 root 权限运行"
        echo "尝试: sudo bash $0"
        exit 1
    fi
}

check_status() {
    echo -e "${BLUE}检查部署状态...${NC}\n"
    
    # 检查常规部署
    if systemctl list-unit-files | grep -q "media-converter.service"; then
        echo -e "${GREEN}✓${NC} 常规部署已安装"
        if systemctl is-active --quiet media-converter; then
            echo -e "  状态: ${GREEN}运行中${NC}"
        else
            echo -e "  状态: ${YELLOW}已停止${NC}"
        fi
        systemctl status media-converter --no-pager | grep "Active:" || true
        echo ""
    else
        echo -e "${YELLOW}✗${NC} 未检测到常规部署"
        echo ""
    fi
    
    # 检查 Docker 部署
    if command -v docker &> /dev/null; then
        if docker ps -a --format '{{.Names}}' | grep -q "media-converter"; then
            echo -e "${GREEN}✓${NC} Docker 部署已安装"
            local status=$(docker inspect -f '{{.State.Status}}' media-converter 2>/dev/null)
            if [ "$status" = "running" ]; then
                echo -e "  状态: ${GREEN}运行中${NC}"
            else
                echo -e "  状态: ${YELLOW}已停止${NC}"
            fi
            docker ps -a -f name=media-converter --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || true
            echo ""
        else
            echo -e "${YELLOW}✗${NC} 未检测到 Docker 部署"
            echo ""
        fi
    fi
    
    # 检查端口
    if netstat -tuln 2>/dev/null | grep -q ":52113 " || ss -tuln 2>/dev/null | grep -q ":52113 "; then
        echo -e "${GREEN}✓${NC} 端口 52113 已被占用（服务可能正在运行）"
    else
        echo -e "${YELLOW}✗${NC} 端口 52113 未被占用"
    fi
    
    echo ""
    read -p "按 Enter 键继续..."
}

uninstall_all() {
    echo -e "${RED}⚠️  警告: 这将卸载所有部署${NC}"
    read -p "确认卸载? [y/N]: " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        return
    fi
    
    echo ""
    
    # 卸载常规部署
    if [ -f "deploy_linux.sh" ]; then
        echo -e "${BLUE}卸载常规部署...${NC}"
        bash deploy_linux.sh uninstall
    fi
    
    # 卸载 Docker 部署
    if [ -f "deploy_docker.sh" ] && command -v docker &> /dev/null; then
        echo -e "${BLUE}卸载 Docker 部署...${NC}"
        bash deploy_docker.sh uninstall
    fi
    
    echo ""
    read -p "按 Enter 键继续..."
}

show_help() {
    echo -e "${CYAN}📖 部署文档${NC}\n"
    
    if [ -f "Linux部署指南.md" ]; then
        echo "详细文档: Linux部署指南.md"
        echo ""
        echo "快速链接："
        echo "  - 常规部署: bash deploy_linux.sh"
        echo "  - Docker 部署: bash deploy_docker.sh"
        echo "  - Docker Compose: docker compose up -d"
        echo ""
        
        read -p "是否查看完整文档? [y/N]: " view_doc
        if [ "$view_doc" = "y" ] || [ "$view_doc" = "Y" ]; then
            if command -v less &> /dev/null; then
                less Linux部署指南.md
            elif command -v more &> /dev/null; then
                more Linux部署指南.md
            else
                cat Linux部署指南.md
            fi
        fi
    else
        echo -e "${YELLOW}未找到部署文档${NC}"
    fi
    
    echo ""
    read -p "按 Enter 键继续..."
}

main() {
    check_root
    
    while true; do
        print_header
        show_menu
        
        read -p "请输入选项 [0-6]: " choice
        echo ""
        
        case $choice in
            1)
                if [ -f "deploy_linux.sh" ]; then
                    bash deploy_linux.sh
                else
                    echo -e "${RED}错误: deploy_linux.sh 文件不存在${NC}"
                fi
                read -p "按 Enter 键继续..."
                ;;
            2)
                if [ -f "deploy_docker.sh" ]; then
                    bash deploy_docker.sh
                else
                    echo -e "${RED}错误: deploy_docker.sh 文件不存在${NC}"
                fi
                read -p "按 Enter 键继续..."
                ;;
            3)
                if [ -f "docker-compose.yml" ]; then
                    if command -v docker &> /dev/null; then
                        echo -e "${BLUE}使用 Docker Compose 部署...${NC}"
                        docker compose up -d --build
                        echo ""
                        echo -e "${GREEN}部署完成！${NC}"
                        echo "访问: http://localhost:52113"
                    else
                        echo -e "${RED}错误: Docker 未安装${NC}"
                    fi
                else
                    echo -e "${RED}错误: docker-compose.yml 文件不存在${NC}"
                fi
                read -p "按 Enter 键继续..."
                ;;
            4)
                check_status
                ;;
            5)
                uninstall_all
                ;;
            6)
                show_help
                ;;
            0)
                echo -e "${GREEN}再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选项${NC}"
                sleep 2
                ;;
        esac
    done
}

main
