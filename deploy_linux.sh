#!/bin/bash

##############################################################################
# 多媒体格式转换工具 - Linux 一键部署脚本
# 支持：Ubuntu/Debian/CentOS/RHEL
# 功能：自动检测重复部署、安装依赖、配置服务
##############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
APP_NAME="media-converter"
APP_DIR="/opt/${APP_NAME}"
SERVICE_NAME="${APP_NAME}.service"
PORT=52113
VENV_DIR="${APP_DIR}/venv"
LOG_DIR="/var/log/${APP_NAME}"
PID_FILE="/var/run/${APP_NAME}.pid"

# 打印带颜色的信息
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

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        print_error "无法检测操作系统"
        exit 1
    fi
    print_info "检测到操作系统: $OS $VER"
}

# 检查是否以 root 权限运行
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "请使用 root 权限运行此脚本"
        echo "尝试: sudo bash $0"
        exit 1
    fi
}

# 检查是否已经部署
check_existing_deployment() {
    print_info "检查是否已经部署..."
    
    local is_deployed=false
    local deployment_info=""
    
    # 检查应用目录
    if [ -d "$APP_DIR" ]; then
        is_deployed=true
        deployment_info="${deployment_info}\n  📁 应用目录存在: $APP_DIR"
    fi
    
    # 检查系统服务
    if systemctl list-unit-files | grep -q "$SERVICE_NAME"; then
        is_deployed=true
        deployment_info="${deployment_info}\n  🔧 系统服务存在: $SERVICE_NAME"
        
        # 检查服务状态
        if systemctl is-active --quiet $SERVICE_NAME; then
            deployment_info="${deployment_info}\n  ✅ 服务状态: 运行中"
        else
            deployment_info="${deployment_info}\n  ⚠️  服务状态: 已停止"
        fi
    fi
    
    # 检查端口占用
    if netstat -tuln 2>/dev/null | grep -q ":${PORT} " || ss -tuln 2>/dev/null | grep -q ":${PORT} "; then
        is_deployed=true
        deployment_info="${deployment_info}\n  🔌 端口 $PORT 已被占用"
    fi
    
    # 检查进程
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat $PID_FILE)
        if ps -p $pid > /dev/null 2>&1; then
            is_deployed=true
            deployment_info="${deployment_info}\n  🔄 进程运行中 (PID: $pid)"
        fi
    fi
    
    if [ "$is_deployed" = true ]; then
        print_warning "检测到已存在的部署:"
        echo -e "$deployment_info"
        echo ""
        echo "请选择操作:"
        echo "  1) 重新部署 (删除旧部署)"
        echo "  2) 更新部署 (保留数据)"
        echo "  3) 退出"
        echo ""
        read -p "请输入选项 [1-3]: " choice
        
        case $choice in
            1)
                print_info "准备重新部署..."
                cleanup_deployment
                ;;
            2)
                print_info "准备更新部署..."
                stop_service
                ;;
            3)
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

# 清理旧部署
cleanup_deployment() {
    print_info "清理旧部署..."
    
    # 停止服务
    if systemctl list-unit-files | grep -q "$SERVICE_NAME"; then
        systemctl stop $SERVICE_NAME 2>/dev/null || true
        systemctl disable $SERVICE_NAME 2>/dev/null || true
        rm -f /etc/systemd/system/$SERVICE_NAME
        systemctl daemon-reload
        print_success "已停止并删除系统服务"
    fi
    
    # 删除应用目录
    if [ -d "$APP_DIR" ]; then
        rm -rf $APP_DIR
        print_success "已删除应用目录"
    fi
    
    # 清理 PID 文件
    [ -f "$PID_FILE" ] && rm -f $PID_FILE
    
    print_success "清理完成"
}

# 停止服务
stop_service() {
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_info "停止现有服务..."
        systemctl stop $SERVICE_NAME
        print_success "服务已停止"
    fi
}

# 安装依赖
install_dependencies() {
    print_header "安装系统依赖"
    
    case $OS in
        ubuntu|debian)
            print_info "更新软件包列表..."
            apt-get update -qq
            
            print_info "安装依赖包..."
            apt-get install -y \
                python3 \
                python3-pip \
                python3-venv \
                ffmpeg \
                wget \
                curl \
                net-tools \
                || true
            ;;
            
        centos|rhel|fedora)
            print_info "安装 EPEL 仓库..."
            yum install -y epel-release || true
            
            print_info "安装依赖包..."
            yum install -y \
                python3 \
                python3-pip \
                ffmpeg \
                wget \
                curl \
                net-tools \
                || true
            ;;
            
        *)
            print_error "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
    
    print_success "系统依赖安装完成"
}

# 创建应用目录
setup_directories() {
    print_info "创建应用目录..."
    
    mkdir -p $APP_DIR
    mkdir -p $LOG_DIR
    mkdir -p $APP_DIR/uploads
    mkdir -p $APP_DIR/outputs
    mkdir -p $APP_DIR/templates
    
    print_success "目录创建完成"
}

# 部署应用文件
deploy_application() {
    print_header "部署应用文件"
    
    local source_dir=$(dirname "$(readlink -f "$0")")
    
    print_info "从 $source_dir 复制文件..."
    
    # 复制应用文件
    cp $source_dir/app.py $APP_DIR/
    cp $source_dir/ncm_decrypt.py $APP_DIR/
    cp $source_dir/requirements.txt $APP_DIR/
    cp -r $source_dir/templates/* $APP_DIR/templates/
    
    # 设置权限
    chmod 755 $APP_DIR
    chmod 644 $APP_DIR/*.py
    chmod 755 $APP_DIR/uploads
    chmod 755 $APP_DIR/outputs
    
    print_success "应用文件部署完成"
}

# 创建 Python 虚拟环境
setup_python_env() {
    print_header "配置 Python 环境"
    
    print_info "创建虚拟环境..."
    python3 -m venv $VENV_DIR
    
    print_info "安装 Python 依赖..."
    $VENV_DIR/bin/pip install --upgrade pip -q
    $VENV_DIR/bin/pip install -r $APP_DIR/requirements.txt -q
    
    print_success "Python 环境配置完成"
}

# 创建 systemd 服务
create_systemd_service() {
    print_header "配置系统服务"
    
    print_info "创建 systemd 服务文件..."
    
    cat > /etc/systemd/system/$SERVICE_NAME << EOF
[Unit]
Description=Media Converter Web Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
ExecStart=$VENV_DIR/bin/python app.py
Restart=always
RestartSec=10
StandardOutput=append:$LOG_DIR/app.log
StandardError=append:$LOG_DIR/error.log

# 资源限制
LimitNOFILE=65535
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载 systemd
    systemctl daemon-reload
    
    # 启用服务
    systemctl enable $SERVICE_NAME
    
    print_success "系统服务配置完成"
}

# 配置防火墙
configure_firewall() {
    print_info "配置防火墙..."
    
    # 检查 firewalld
    if command -v firewall-cmd &> /dev/null; then
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-port=$PORT/tcp 2>/dev/null || true
            firewall-cmd --reload 2>/dev/null || true
            print_success "firewalld: 已开放端口 $PORT"
        fi
    fi
    
    # 检查 ufw
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            ufw allow $PORT/tcp 2>/dev/null || true
            print_success "ufw: 已开放端口 $PORT"
        fi
    fi
}

# 启动服务
start_service() {
    print_header "启动应用服务"
    
    print_info "启动服务..."
    systemctl start $SERVICE_NAME
    
    sleep 3
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_success "服务启动成功！"
    else
        print_error "服务启动失败"
        print_info "查看日志: journalctl -u $SERVICE_NAME -n 50"
        exit 1
    fi
}

# 显示部署信息
show_deployment_info() {
    print_header "部署完成"
    
    local ip_address=$(hostname -I | awk '{print $1}')
    
    echo -e "${GREEN}"
    echo "✅ 应用已成功部署并启动！"
    echo ""
    echo "📍 访问地址:"
    echo "   本地: http://localhost:$PORT"
    echo "   局域网: http://$ip_address:$PORT"
    echo ""
    echo "📁 应用目录: $APP_DIR"
    echo "📋 日志目录: $LOG_DIR"
    echo ""
    echo "🔧 常用命令:"
    echo "   查看状态: systemctl status $SERVICE_NAME"
    echo "   停止服务: systemctl stop $SERVICE_NAME"
    echo "   启动服务: systemctl start $SERVICE_NAME"
    echo "   重启服务: systemctl restart $SERVICE_NAME"
    echo "   查看日志: journalctl -u $SERVICE_NAME -f"
    echo "   实时日志: tail -f $LOG_DIR/app.log"
    echo ""
    echo "🗑️  卸载应用:"
    echo "   bash deploy_linux.sh uninstall"
    echo -e "${NC}"
}

# 卸载应用
uninstall() {
    print_header "卸载应用"
    
    echo "⚠️  警告: 这将删除所有应用文件和配置"
    read -p "确认卸载? [y/N]: " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_info "取消卸载"
        exit 0
    fi
    
    print_info "开始卸载..."
    cleanup_deployment
    
    # 删除日志目录
    if [ -d "$LOG_DIR" ]; then
        rm -rf $LOG_DIR
        print_success "已删除日志目录"
    fi
    
    print_success "应用已完全卸载"
}

# 主函数
main() {
    print_header "多媒体格式转换工具 - Linux 部署脚本"
    
    # 检查是否为卸载操作
    if [ "$1" = "uninstall" ]; then
        check_root
        uninstall
        exit 0
    fi
    
    # 正常部署流程
    check_root
    detect_os
    check_existing_deployment
    install_dependencies
    setup_directories
    deploy_application
    setup_python_env
    create_systemd_service
    configure_firewall
    start_service
    show_deployment_info
}

# 执行主函数
main "$@"
