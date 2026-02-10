# 贡献指南

感谢你考虑为 Media Converter 做贡献！

## 🤝 如何贡献

### 报告 Bug

如果你发现了 Bug，请创建一个 Issue，包含以下信息：

- 清晰的标题和描述
- 重现步骤
- 预期行为和实际行为
- 系统环境（操作系统、Python 版本等）
- 相关的日志或错误信息

### 建议新功能

我们欢迎功能建议！请创建一个 Issue，描述：

- 功能的用途和价值
- 预期的工作方式
- 可能的实现方法（可选）

### 提交代码

1. **Fork 项目**
   ```bash
   git clone https://github.com/yourusername/media-converter.git
   cd media-converter
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **设置开发环境**
   ```bash
   # 创建虚拟环境
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   # 或
   venv\Scripts\activate  # Windows
   
   # 安装开发依赖
   pip install -e ".[dev]"
   ```

4. **进行更改**
   - 编写代码
   - 添加测试
   - 更新文档

5. **运行测试**
   ```bash
   # 运行测试
   pytest tests/
   
   # 代码格式化
   black src/
   isort src/
   
   # 代码检查
   flake8 src/
   mypy src/
   ```

6. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   ```

   提交信息格式：
   - `feat:` 新功能
   - `fix:` Bug 修复
   - `docs:` 文档更新
   - `style:` 代码格式调整
   - `refactor:` 代码重构
   - `test:` 测试相关
   - `chore:` 构建/工具相关

7. **推送到 GitHub**
   ```bash
   git push origin feature/your-feature-name
   ```

8. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 清晰描述你的更改
   - 关联相关的 Issue

## 📋 开发规范

### 代码风格

- 使用 [Black](https://black.readthedocs.io/) 格式化代码
- 使用 [isort](https://pycqa.github.io/isort/) 排序导入
- 遵循 [PEP 8](https://pep8.org/) 规范
- 使用类型提示（Type Hints）

### 测试

- 为新功能编写测试
- 确保测试覆盖率不降低
- 运行所有测试并确保通过

### 文档

- 更新相关文档
- 为新功能添加使用说明
- 更新 CHANGELOG.md

### 提交消息

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <subject>

<body>

<footer>
```

示例：
```
feat(ncm): 添加 NCM 格式批量转换支持

支持一次性选择多个 NCM 文件进行批量转换，
提高用户体验。

Closes #123
```

## 🔍 代码审查

所有的 Pull Request 都需要经过代码审查。审查者会检查：

- 代码质量和可维护性
- 测试覆盖率
- 文档完整性
- 是否符合项目规范

请耐心等待审查，并根据反馈进行修改。

## 📚 开发资源

### 项目结构

```
media-converter/
├── src/media_converter/    # 主代码
├── tests/                  # 测试文件
├── docs/                   # 文档
├── scripts/                # 脚本工具
└── docker/                 # Docker 配置
```

### 有用的命令

```bash
# 安装开发模式
pip install -e ".[dev]"

# 运行测试
make test
pytest tests/ -v

# 代码格式化
make format
black src/ tests/
isort src/ tests/

# 代码检查
make lint
flake8 src/
mypy src/

# 构建文档
cd docs && make html

# 本地运行
python src/media_converter/app.py

# Docker 测试
docker build -t media-converter:test .
docker run -p 52113:52113 media-converter:test
```

## 🐛 调试技巧

### 启用调试模式

```python
# 在 app.py 中
app.run(debug=True, host='0.0.0.0', port=52113)
```

### 查看日志

```bash
# Systemd 服务
journalctl -u media-converter -f

# Docker 容器
docker logs -f media-converter

# 文件日志
tail -f /var/log/media-converter/app.log
```

### 测试特定功能

```bash
# 测试 NCM 解密
python tests/test_ncm.py

# 测试部署
bash tests/test_deployment.sh
```

## 💡 开发建议

1. **小步提交** - 频繁提交小的、逻辑清晰的更改
2. **测试先行** - 先写测试，再写实现（TDD）
3. **代码审查** - 认真对待代码审查反馈
4. **文档同步** - 代码和文档保持同步更新
5. **保持简单** - KISS 原则，避免过度设计

## ❓ 获取帮助

如果你有任何问题：

- 查看 [文档](docs/)
- 搜索现有的 [Issues](https://github.com/yourusername/media-converter/issues)
- 创建新的 Issue 提问
- 加入讨论区交流

## 📜 行为准则

请遵守我们的 [行为准则](CODE_OF_CONDUCT.md)，营造友好、包容的社区环境。

## 🙏 致谢

感谢所有贡献者的付出！你们的贡献让这个项目变得更好。

---

再次感谢你的贡献！ ❤️
