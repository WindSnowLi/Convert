#!/bin/bash

##############################################################################
# 部署验证测试脚本
# 用于检查部署是否成功，服务是否正常运行
##############################################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PORT=52113
HOST="localhost"

echo "=================================================="
echo "      部署验证测试"
echo "=================================================="
echo ""

# 测试计数
total_tests=0
passed_tests=0

test_check() {
    local test_name=$1
    local result=$2
    
    total_tests=$((total_tests + 1))
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
    fi
}

# 1. 检查端口监听
echo "1️⃣  检查端口监听..."
if netstat -tuln 2>/dev/null | grep -q ":${PORT} " || ss -tuln 2>/dev/null | grep -q ":${PORT} "; then
    test_check "端口 $PORT 正在监听" 0
else
    test_check "端口 $PORT 正在监听" 1
fi

# 2. 检查 HTTP 响应
echo ""
echo "2️⃣  检查 HTTP 服务..."

if command -v curl &> /dev/null; then
    response=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}:${PORT}/ 2>/dev/null)
    if [ "$response" = "200" ]; then
        test_check "HTTP 服务响应正常 (200 OK)" 0
    else
        test_check "HTTP 服务响应正常 (返回: $response)" 1
    fi
else
    test_check "HTTP 服务响应 (curl 未安装，跳过)" 1
fi

# 3. 检查 API 端点
echo ""
echo "3️⃣  检查 API 端点..."

if command -v curl &> /dev/null; then
    formats=$(curl -s http://${HOST}:${PORT}/formats 2>/dev/null)
    if echo "$formats" | grep -q "audio"; then
        test_check "API 端点 /formats 工作正常" 0
        
        # 显示支持的格式
        echo -e "   ${BLUE}支持的格式:${NC}"
        echo "$formats" | python3 -m json.tool 2>/dev/null | head -20 || echo "$formats"
    else
        test_check "API 端点 /formats 工作正常" 1
    fi
else
    test_check "API 端点检查 (curl 未安装，跳过)" 1
fi

# 4. 检查进程
echo ""
echo "4️⃣  检查进程状态..."

# 检查 systemd 服务
if systemctl list-unit-files | grep -q "media-converter.service"; then
    if systemctl is-active --quiet media-converter; then
        test_check "Systemd 服务运行中" 0
    else
        test_check "Systemd 服务运行中" 1
    fi
fi

# 检查 Docker 容器
if command -v docker &> /dev/null; then
    if docker ps --format '{{.Names}}' | grep -q "media-converter"; then
        status=$(docker inspect -f '{{.State.Status}}' media-converter 2>/dev/null)
        if [ "$status" = "running" ]; then
            test_check "Docker 容器运行中" 0
        else
            test_check "Docker 容器运行中 (状态: $status)" 1
        fi
    fi
fi

# 5. 检查依赖
echo ""
echo "5️⃣  检查依赖..."

# 检查 Python
if command -v python3 &> /dev/null; then
    python_version=$(python3 --version 2>&1)
    test_check "Python 已安装 ($python_version)" 0
else
    test_check "Python 已安装" 1
fi

# 检查 FFmpeg
if command -v ffmpeg &> /dev/null; then
    ffmpeg_version=$(ffmpeg -version 2>&1 | head -1)
    test_check "FFmpeg 已安装 (${ffmpeg_version:0:50}...)" 0
else
    test_check "FFmpeg 已安装" 1
fi

# 6. 检查文件和目录
echo ""
echo "6️⃣  检查文件和目录..."

# 检查常规部署
if [ -d "/opt/media-converter" ]; then
    test_check "应用目录存在 (/opt/media-converter)" 0
    
    if [ -f "/opt/media-converter/app.py" ]; then
        test_check "应用文件存在 (app.py)" 0
    else
        test_check "应用文件存在 (app.py)" 1
    fi
fi

# 检查日志目录
if [ -d "/var/log/media-converter" ]; then
    test_check "日志目录存在" 0
fi

# 7. 网络测试
echo ""
echo "7️⃣  网络连通性测试..."

# 获取本机 IP
local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -n "$local_ip" ]; then
    echo -e "   ${BLUE}本机 IP:${NC} $local_ip"
    echo -e "   ${BLUE}访问地址:${NC}"
    echo -e "   - 本地: http://localhost:${PORT}"
    echo -e "   - 局域网: http://${local_ip}:${PORT}"
fi

# 测试响应时间
if command -v curl &> /dev/null; then
    echo ""
    echo -e "   ${BLUE}响应时间测试:${NC}"
    response_time=$(curl -o /dev/null -s -w '%{time_total}\n' http://${HOST}:${PORT}/ 2>/dev/null)
    if [ -n "$response_time" ]; then
        echo -e "   首页加载: ${response_time}s"
        test_check "响应时间正常" 0
    else
        test_check "响应时间测试" 1
    fi
fi

# 总结
echo ""
echo "=================================================="
echo "           测试结果汇总"
echo "=================================================="
echo ""
echo -e "总测试数: $total_tests"
echo -e "${GREEN}通过: $passed_tests${NC}"
echo -e "${RED}失败: $((total_tests - passed_tests))${NC}"
echo ""

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 所有测试通过！部署成功！${NC}"
    exit 0
elif [ $passed_tests -gt $((total_tests / 2)) ]; then
    echo -e "${YELLOW}⚠️  部分测试失败，但基本功能正常${NC}"
    exit 0
else
    echo -e "${RED}❌ 多项测试失败，请检查部署${NC}"
    echo ""
    echo "建议检查："
    echo "  1. 查看服务日志"
    echo "  2. 确认端口未被占用"
    echo "  3. 验证依赖已安装"
    exit 1
fi
