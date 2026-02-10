#!/bin/bash

##############################################################################
# Docker 一键部署脚本
# 功能：检测重复部署、Docker 环境检查、容器管理
##############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 配置
CONTAINER_NAME="media-converter"
IMAGE_NAME="media-converter:latest"
PORT=52113

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}"
    echo "=============================================="
    echo "  $1"
    echo "=============================================="
    echo -e "${NC}"
}

# 检查 Docker 是否安装
check_docker() {
    print_info "检查 Docker 环境..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        echo ""
        echo "请先安装 Docker："
        echo "  Ubuntu/Debian: curl -fsSL https://get.docker.com | sh"
        echo "  或访问: https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    print_success "Docker 已安装: $(docker --version)"
    
    # 尝试连接 Docker 守护进程
    if ! docker ps &> /dev/null; then
        print_warning "当前用户无法直接访问 Docker"
        
        # 尝试使用 sudo
        if sudo docker ps &> /dev/null; then
            print_info "可以使用 sudo 访问 Docker"
            DOCKER_CMD="sudo docker"
            COMPOSE_CMD="sudo docker compose"
        else
            print_error "无法连接到 Docker 守护进程"
            echo "请确保："
            echo "  1. Docker 服务正在运行: sudo systemctl start docker"
            echo "  2. 当前用户有 Docker 权限: sudo usermod -aG docker $USER && newgrp docker"
            echo "  3. 或使用 sudo 运行本脚本"
            exit 1
        fi
    else
        print_success "Docker 环境正常"
        DOCKER_CMD="docker"
        COMPOSE_CMD="docker compose"
    fi
}

# 检查 Docker Compose
check_docker_compose() {
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        if ! docker compose version &> /dev/null; then
            COMPOSE_CMD="docker-compose"
        fi
        print_success "Docker Compose 已安装"
        return 0
    else
        print_warning "Docker Compose 未安装（可选）"
        return 1
    fi
}

# 检查是否已部署
check_existing_deployment() {
    print_info "检查现有部署..."
    
    local is_deployed=false
    local deployment_info=""
    
    # 检查容器
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        is_deployed=true
        local status=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME)
        deployment_info="${deployment_info}\n  🐳 容器: $CONTAINER_NAME (状态: $status)"
    fi
    
    # 检查镜像
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        is_deployed=true
        local image_id=$(docker images --format '{{.ID}}' $IMAGE_NAME | head -1)
        deployment_info="${deployment_info}\n  📦 镜像: $IMAGE_NAME (ID: ${image_id:0:12})"
    fi
    
    # 检查端口
    if docker ps --format '{{.Ports}}' | grep -q ":${PORT}->"; then
        is_deployed=true
        deployment_info="${deployment_info}\n  🔌 端口 $PORT 已被 Docker 容器占用"
    fi
    
    if [ "$is_deployed" = true ]; then
        print_warning "检测到已存在的部署:"
        echo -e "$deployment_info"
        echo ""
        echo "请选择操作:"
        echo "  1) 重新部署 (删除旧容器和镜像)"
        echo "  2) 重启容器"
        echo "  3) 更新容器 (重新构建)"
        echo "  4) 退出"
        echo ""
        read -p "请输入选项 [1-4]: " choice
        
        case $choice in
            1)
                print_info "准备重新部署..."
                cleanup_docker
                ;;
            2)
                print_info "重启容器..."
                restart_container
                exit 0
                ;;
            3)
                print_info "更新容器..."
                stop_container
                ;;
            4)
                print_info "退出部署"
                exit 0
                ;;
            *)
                print_error "无效的选项"
                exit 1
                ;;
        esac
    else
        print_success "未检测到已有部署，继续全新安装"
    fi
}

# 清理 Docker 资源
cleanup_docker() {
    print_info "清理 Docker 资源..."
    
    # 停止并删除容器
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        print_success "已删除容器: $CONTAINER_NAME"
    fi
    
    # 删除镜像
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        docker rmi $IMAGE_NAME 2>/dev/null || true
        print_success "已删除镜像: $IMAGE_NAME"
    fi
    
    # 清理未使用的资源（可选）
    # docker system prune -f
    
    print_success "清理完成"
}

# 停止容器
stop_container() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "停止容器..."
        docker stop $CONTAINER_NAME
        print_success "容器已停止"
    fi
}

# 重启容器
restart_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_info "重启容器..."
        docker restart $CONTAINER_NAME
        print_success "容器已重启"
        show_container_info
    else
        print_error "容器不存在"
        exit 1
    fi
}

# 使用 Docker Compose 部署
deploy_with_compose() {
    print_header "使用 Docker Compose 部署"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml 文件不存在"
        exit 1
    fi
    
    # 创建数据目录
    mkdir -p data/uploads data/outputs
    
    print_info "构建并启动服务..."
    $COMPOSE_CMD up -d --build
    
    print_success "Docker Compose 部署完成"
}

# 使用 Docker 命令部署
deploy_with_docker() {
    print_header "使用 Docker 部署"
    
    print_info "构建 Docker 镜像..."
    docker build -t $IMAGE_NAME .
    
    print_success "镜像构建完成"
    
    # 创建数据目录
    mkdir -p data/uploads data/outputs
    
    print_info "启动容器..."
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p $PORT:52113 \
        -v "$(pwd)/data/uploads:/app/uploads" \
        -v "$(pwd)/data/outputs:/app/outputs" \
        -e TZ=Asia/Shanghai \
        --memory="2g" \
        --cpus="2.0" \
        $IMAGE_NAME
    
    print_success "容器启动完成"
}

# 显示容器信息
show_container_info() {
    print_header "部署完成"
    
    # 获取容器 IP
    local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
    local host_ip=$(hostname -I | awk '{print $1}')
    
    echo -e "${GREEN}"
    echo "✅ 应用已成功部署并启动！"
    echo ""
    echo "📍 访问地址:"
    echo "   本地: http://localhost:$PORT"
    echo "   局域网: http://$host_ip:$PORT"
    echo ""
    echo "🐳 Docker 信息:"
    echo "   容器名称: $CONTAINER_NAME"
    echo "   容器 IP: $container_ip"
    echo "   镜像: $IMAGE_NAME"
    echo ""
    echo "📁 数据目录:"
    echo "   上传: $(pwd)/data/uploads"
    echo "   输出: $(pwd)/data/outputs"
    echo ""
    echo "🔧 常用命令:"
    echo "   查看状态: docker ps -f name=$CONTAINER_NAME"
    echo "   查看日志: docker logs -f $CONTAINER_NAME"
    echo "   停止服务: docker stop $CONTAINER_NAME"
    echo "   启动服务: docker start $CONTAINER_NAME"
    echo "   重启服务: docker restart $CONTAINER_NAME"
    echo "   进入容器: docker exec -it $CONTAINER_NAME bash"
    echo "   删除容器: docker rm -f $CONTAINER_NAME"
    echo ""
    echo "🗑️  卸载应用:"
    echo "   bash deploy_docker.sh uninstall"
    echo -e "${NC}"
}

# 检查容器健康状态
check_container_health() {
    print_info "检查容器健康状态..."
    
    sleep 5
    
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        local status=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME)
        if [ "$status" = "running" ]; then
            print_success "容器运行正常"
            
            # 测试端点
            if curl -f http://localhost:$PORT/formats >/dev/null 2>&1; then
                print_success "应用响应正常"
            else
                print_warning "应用可能还在启动中，请稍候..."
            fi
        else
            print_error "容器状态异常: $status"
            print_info "查看日志: docker logs $CONTAINER_NAME"
        fi
    else
        print_error "容器未运行"
        print_info "查看日志: docker logs $CONTAINER_NAME"
    fi
}

# 卸载
uninstall() {
    print_header "卸载应用"
    
    echo "⚠️  警告: 这将删除容器、镜像和数据"
    read -p "确认卸载? [y/N]: " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_info "取消卸载"
        exit 0
    fi
    
    print_info "开始卸载..."
    cleanup_docker
    
    # 删除数据目录
    if [ -d "data" ]; then
        read -p "是否删除数据目录? [y/N]: " del_data
        if [ "$del_data" = "y" ] || [ "$del_data" = "Y" ]; then
            rm -rf data
            print_success "已删除数据目录"
        fi
    fi
    
    print_success "应用已完全卸载"
}

# 主函数
main() {
    print_header "多媒体格式转换工具 - Docker 部署"
    
    # 检查是否为卸载操作
    if [ "$1" = "uninstall" ]; then
        check_docker
        uninstall
        exit 0
    fi
    
    # 正常部署流程
    check_docker
    check_existing_deployment
    
    # 检查 Docker Compose
    if check_docker_compose; then
        echo ""
        echo "检测到 Docker Compose，请选择部署方式:"
        echo "  1) Docker Compose (推荐)"
        echo "  2) Docker 命令"
        echo ""
        read -p "请输入选项 [1-2]: " deploy_choice
        
        case $deploy_choice in
            1)
                deploy_with_compose
                ;;
            2)
                deploy_with_docker
                ;;
            *)
                print_warning "无效选项，使用 Docker 命令部署"
                deploy_with_docker
                ;;
        esac
    else
        deploy_with_docker
    fi
    
    check_container_health
    show_container_info
}

# 执行主函数
main "$@"
