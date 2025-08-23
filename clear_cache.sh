#!/bin/bash

# clear_cache.sh

# 描述：清理 Python 项目中产生的缓存文件和文件夹

# 启用对隐藏文件的匹配
shopt -s dotglob

# 删除所有 .pyc 文件和 __pycache__ 文件夹
find . -type f -name '*.pyc' -delete
find . -type d -name '__pycache__' -exec rm -rf {} +

# 删除 IDE 或其他工具可能生成的临时文件
rm -rf .idea

# 删除 Python 虚拟环境（如果需要）
rm -rf venv

# 删除数据库迁移文件（如果需要）
# rm -rf migrations

# 删除其他可能的缓存文件或日志文件
rm -rf log/*
rm -rf .cache
rm -rf .pytest_cache
rm -rf .tox

# 输出清理完成的消息
echo "缓存文件和文件夹清理完成。"

# 检查 tree 命令是否存在
if ! command -v tree &> /dev/null; then
    echo "tree 命令未安装。请先安装 tree 命令。"
    exit 1
fi

# 检查 tree.txt 文件是否存在，如果存在则清空内容，不存在则创建文件
> tree.txt

# 输出目录结构并追加到 tree.txt 文件中
echo "清理后目录结构："

tree -I '.*|__*' >> tree.txt

# 输出目录结构
tree -I '.*|__*'
