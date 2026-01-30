#!/bin/bash

# 构建脚本 - 从 node_modules 读取图标并生成 main.js

set -e

echo "🚀 生成图标列表..."

# 检查 node_modules 中的图标包
LIGHT_DIR="node_modules/@lobehub/icons-static-webp/light"
DARK_DIR="node_modules/@lobehub/icons-static-webp/dark"

if [ ! -d "$LIGHT_DIR" ] || [ ! -d "$DARK_DIR" ]; then
  echo "❌ 错误: @lobehub/icons-static-webp 包未安装"
  echo "   请先运行: npm install @lobehub/icons-static-webp"
  exit 1
fi

# 统计数量
ICON_COUNT=$(ls "$LIGHT_DIR"/*.webp | wc -l)
echo "📊 图标数量: $ICON_COUNT"

# 生成 light 图标列表
LIGHT_LIST=$(ls "$LIGHT_DIR"/*.webp | sed 's|.*light/||' | sort | sed "s/'/\\\\\\\\'/g" | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# 生成 dark 图标列表
DARK_LIST=$(ls "$DARK_DIR"/*.webp | sed 's|.*dark/||' | sort | sed "s/'/\\\\\\\\'/g" | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# 生成 main.js
echo "📝 生成 main.js..."

# 写入文件
{
  echo "// 自动生成的图标列表 - $(date +"%Y-%m-%d %H:%M:%S")"
  echo "// 总图标数: $ICON_COUNT"
  echo ""
  echo "let lightIcons = ["
  echo "  $LIGHT_LIST"
  echo "];"
  echo ""
  echo "let darkIcons = ["
  echo "  $DARK_LIST"
  echo "];"
  echo ""
  echo "let currentTheme = 'light';"
  echo "let currentIcons = [...lightIcons];"
  echo ""
  echo "const grid = document.getElementById('grid');"
  echo "const stats = document.getElementById('stats');"
  echo "const search = document.getElementById('search');"
  echo "const tabs = document.querySelectorAll('.tab');"
  echo "const toast = document.getElementById('toast');"
  echo ""
  echo "function renderIcons(icons) {"
  echo "  if (icons.length === 0) {"
  echo "    grid.innerHTML = '<div class=\"empty\">未找到匹配的图标</div>';"
  echo "    stats.textContent = '0 个图标';"
  echo "    return;"
  echo "  }"
  echo ""
  echo "  grid.innerHTML = icons.map(name => {"
  echo "    const cleanName = name.replace('.webp', '');"
  echo "    const path = \`/\${currentTheme}/\${name}\`;"
  echo "    return \`"
  echo "      <div class=\"icon-card\" data-path=\"\${path}\" onclick=\"copyPath('\${path}')\">"
  echo "        <img src=\"\${path}\" alt=\"\${cleanName}\" loading=\"lazy\" />"
  echo "        <div class=\"name\">\${cleanName}</div>"
  echo "        <div class=\"path\">/\${currentTheme}/</div>"
  echo "      </div>"
  echo "    \`;"
  echo "  }).join('');"
  echo ""
  echo "  stats.textContent = \`\${icons.length} 个图标\`;"
  echo "}"
  echo ""
  echo "function copyPath(path) {"
  echo "  const fullUrl = window.location.origin + path;"
  echo "  navigator.clipboard.writeText(fullUrl).then(() => {"
  echo "    toast.textContent = \`已复制: \${fullUrl}\`;"
  echo "    toast.classList.add('show');"
  echo "    setTimeout(() => toast.classList.remove('show'), 2000);"
  echo "  });"
  echo "}"
  echo ""
  echo "function filterIcons(query) {"
  echo "  if (!query.trim()) {"
  echo "    renderIcons(currentIcons);"
  echo "    return;"
  echo "  }"
  echo "  const filtered = currentIcons.filter(name =>"
  echo "    name.toLowerCase().includes(query.toLowerCase())"
  echo "  );"
  echo "  renderIcons(filtered);"
  echo "}"
  echo ""
  echo "tabs.forEach(tab => {"
  echo "  tab.addEventListener('click', () => {"
  echo "    tabs.forEach(t => t.classList.remove('active'));"
  echo "    tab.classList.add('active');"
  echo "    currentTheme = tab.dataset.theme;"
  echo "    currentIcons = currentTheme === 'light' ? [...lightIcons] : [...darkIcons];"
  echo "    search.value = '';"
  echo "    renderIcons(currentIcons);"
  echo "  });"
  echo "});"
  echo ""
  echo "search.addEventListener('input', (e) => filterIcons(e.target.value));"
  echo ""
  echo "// 暴露到全局"
  echo "window.copyPath = copyPath;"
  echo ""
  echo "// 初始加载"
  echo "renderIcons(currentIcons);"
} > main.js

echo "✅ 完成！main.js 已更新"
echo "📊 图标总数: $ICON_COUNT"
