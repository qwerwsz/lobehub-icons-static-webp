#!/bin/bash

# 从 @lobehub/icons-static-webp 包复制图片到当前目录

set -e

echo "📦 正在安装 @lobehub/icons-static-webp..."
npm install @lobehub/icons-static-webp --save-dev

echo ""
echo "📁 正在复制图标文件..."

# 创建目录
mkdir -p light dark

# 复制 light 主题图标
echo "  - 复制 light 主题图标..."
cp node_modules/@lobehub/icons-static-webp/light/*.webp light/

# 复制 dark 主题图标
echo "  - 复制 dark 主题图标..."
cp node_modules/@lobehub/icons-static-webp/dark/*.webp dark/

# 统计数量
LIGHT_COUNT=$(ls light/*.webp 2>/dev/null | wc -l)
DARK_COUNT=$(ls dark/*.webp 2>/dev/null | wc -l)

echo ""
echo "✅ 复制完成！"
echo "   Light 主题: $LIGHT_COUNT 个图标"
echo "   Dark 主题: $DARK_COUNT 个图标"
echo ""
echo "📁 目录结构:"
ls -lh light/ | head -5
echo "   ..."
ls -lh dark/ | head -5
echo "   ..."
