.PHONY: help install run clean test deploy-linux deploy-docker docker-up docker-down status logs

# 默认目标
help:
	@echo "==========================================="
	@echo "  多媒体格式转换工具 - 快速命令"
	@echo "==========================================="
	@echo ""
	@echo "开发命令："
	@echo "  make install        安装依赖"
	@echo "  make run            运行应用"
	@echo "  make test           测试应用"
	@echo "  make clean          清理临时文件"
	@echo ""
	@echo "Linux 部署："
	@echo "  make deploy-linux   常规部署"
	@echo "  make deploy-docker  Docker 部署"
	@echo "  make deploy-menu    显示部署菜单"
	@echo ""
	@echo "Docker 命令："
	@echo "  make docker-build   构建镜像"
	@echo "  make docker-up      启动容器"
	@echo "  make docker-down    停止容器"
	@echo "  make docker-logs    查看日志"
	@echo ""
	@echo "管理命令："
	@echo "  make status         查看状态"
	@echo "  make logs           查看日志"
	@echo "  make restart        重启服务"
	@echo "  make uninstall      卸载应用"
	@echo ""

# 安装依赖
install:
	pip3 install -r requirements.txt

# 运行应用
run:
	python3 app.py

# 测试
test:
	@if [ -f test_ncm.py ]; then python3 test_ncm.py; fi
	@if [ -f test_deployment.sh ]; then bash test_deployment.sh; fi

# 清理临时文件
clean:
	rm -rf __pycache__/
	rm -rf *.pyc
	rm -rf uploads/*
	rm -rf outputs/*
	rm -rf data/uploads/*
	rm -rf data/outputs/*
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

# Linux 常规部署
deploy-linux:
	@if [ ! -f deploy_linux.sh ]; then echo "错误: deploy_linux.sh 不存在"; exit 1; fi
	chmod +x deploy_linux.sh
	sudo bash deploy_linux.sh

# Docker 部署
deploy-docker:
	@if [ ! -f deploy_docker.sh ]; then echo "错误: deploy_docker.sh 不存在"; exit 1; fi
	chmod +x deploy_docker.sh
	bash deploy_docker.sh

# 部署菜单
deploy-menu:
	@if [ ! -f deploy_menu.sh ]; then echo "错误: deploy_menu.sh 不存在"; exit 1; fi
	chmod +x deploy_menu.sh
	sudo bash deploy_menu.sh

# Docker 构建
docker-build:
	docker build -t media-converter:latest .

# Docker Compose 启动
docker-up:
	docker compose up -d --build

# Docker Compose 停止
docker-down:
	docker compose down

# Docker 日志
docker-logs:
	@if docker ps -a | grep -q media-converter; then \
		docker logs -f media-converter; \
	else \
		docker compose logs -f; \
	fi

# 查看状态
status:
	@echo "检查部署状态..."
	@echo ""
	@if systemctl list-unit-files 2>/dev/null | grep -q "media-converter.service"; then \
		echo "Systemd 服务:"; \
		systemctl status media-converter --no-pager | grep -E "Active:|Main PID:" || true; \
		echo ""; \
	fi
	@if command -v docker >/dev/null 2>&1 && docker ps -a 2>/dev/null | grep -q media-converter; then \
		echo "Docker 容器:"; \
		docker ps -a -f name=media-converter --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
		echo ""; \
	fi
	@if netstat -tuln 2>/dev/null | grep -q ":52113 " || ss -tuln 2>/dev/null | grep -q ":52113 "; then \
		echo "✓ 端口 52113 正在监听"; \
	else \
		echo "✗ 端口 52113 未监听"; \
	fi

# 查看日志
logs:
	@if systemctl list-unit-files 2>/dev/null | grep -q "media-converter.service"; then \
		echo "查看 Systemd 日志..."; \
		journalctl -u media-converter -f; \
	elif command -v docker >/dev/null 2>&1 && docker ps 2>/dev/null | grep -q media-converter; then \
		echo "查看 Docker 日志..."; \
		docker logs -f media-converter; \
	else \
		echo "未找到正在运行的服务"; \
	fi

# 重启服务
restart:
	@if systemctl list-unit-files 2>/dev/null | grep -q "media-converter.service"; then \
		echo "重启 Systemd 服务..."; \
		sudo systemctl restart media-converter; \
		echo "服务已重启"; \
	elif command -v docker >/dev/null 2>&1 && docker ps -a 2>/dev/null | grep -q media-converter; then \
		echo "重启 Docker 容器..."; \
		docker restart media-converter; \
		echo "容器已重启"; \
	else \
		echo "未找到已部署的服务"; \
	fi

# 卸载
uninstall:
	@echo "卸载应用..."
	@if [ -f deploy_linux.sh ]; then sudo bash deploy_linux.sh uninstall; fi
	@if [ -f deploy_docker.sh ]; then bash deploy_docker.sh uninstall; fi
	@echo "卸载完成"
