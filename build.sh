#!/bin/bash

# 构建脚本 - 自动安装图标包、复制图标、生成静态网站
# 所有文件直接生成到根目录，因为 EdgeOne 在根目录构建

set -e

echo "🚀 开始构建 LobeHub Icons 静态网站..."
echo ""

# 1. 安装最新的 @lobehub/icons-static-webp 包
echo "📦 正在安装 @lobehub/icons-static-webp..."
npm install @lobehub/icons-static-webp --save-dev

# 2. 清理旧的图标目录
echo "🧹 清理旧的图标目录..."
rm -rf light dark main.js index.html

# 3. 复制图标文件
echo "📦 复制图标文件..."
mkdir -p light dark
cp node_modules/@lobehub/icons-static-webp/light/*.webp light/
cp node_modules/@lobehub/icons-static-webp/dark/*.webp dark/

# 统计数量
ICON_COUNT=$(ls light/*.webp | wc -l)
echo "   已复制 $ICON_COUNT 个图标"

# 4. 生成图标列表 JS 文件
echo "📝 生成图标列表 JS..."

# 生成 light 图标列表
LIGHT_LIST=$(ls light/*.webp | sed 's|light/||' | sort | sed "s/'/\\\\\\\\'/g" | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# 生成 dark 图标列表
DARK_LIST=$(ls dark/*.webp | sed 's|dark/||' | sort | sed "s/'/\\\\\\\\'/g" | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# 生成 main.js
cat > main.js << JSEOF
// 自动生成的图标列表 - $(date +"%Y-%m-%d %H:%M:%S")
// 总图标数: $ICON_COUNT

let lightIcons = [
  $LIGHT_LIST
];

let darkIcons = [
  $DARK_LIST
];

let currentTheme = 'light';
let currentIcons = [...lightIcons];

const grid = document.getElementById('grid');
const stats = document.getElementById('stats');
const search = document.getElementById('search');
const tabs = document.querySelectorAll('.tab');
const toast = document.getElementById('toast');

function renderIcons(icons) {
  if (icons.length === 0) {
    grid.innerHTML = '<div class="empty">未找到匹配的图标</div>';
    stats.textContent = '0 个图标';
    return;
  }

  grid.innerHTML = icons.map(name => {
    const cleanName = name.replace('.webp', '');
    const path = `/${currentTheme}/${name}`;
    return `
      <div class="icon-card" data-path="${path}" onclick="copyPath('${path}')">
        <img src="${path}" alt="${cleanName}" loading="lazy" />
        <div class="name">${cleanName}</div>
        <div class="path">/${currentTheme}/</div>
      </div>
    `;
  }).join('');

  stats.textContent = `${icons.length} 个图标`;
}

function copyPath(path) {
  const fullUrl = window.location.origin + path;
  navigator.clipboard.writeText(fullUrl).then(() => {
    toast.textContent = `已复制: ${fullUrl}`;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2000);
  });
}

function filterIcons(query) {
  if (!query.trim()) {
    renderIcons(currentIcons);
    return;
  }
  const filtered = currentIcons.filter(name =>
    name.toLowerCase().includes(query.toLowerCase())
  );
  renderIcons(filtered);
}

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    tabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    currentTheme = tab.dataset.theme;
    currentIcons = currentTheme === 'light' ? [...lightIcons] : [...darkIcons];
    search.value = '';
    renderIcons(currentIcons);
  });
});

search.addEventListener('input', (e) => filterIcons(e.target.value));

// 暴露到全局
window.copyPath = copyPath;

// 初始加载
renderIcons(currentIcons);
JSEOF

# 5. 生成 index.html
echo "📝 生成 index.html..."
cat > index.html << HTMLEOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LobeHub Icons - 静态图标库</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: system-ui, -apple-system, sans-serif; background: #f5f5f5; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; }
    .header h1 { font-size: 32px; margin-bottom: 10px; }
    .header p { opacity: 0.9; font-size: 16px; }
    .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
    .tabs { display: flex; gap: 10px; margin-bottom: 20px; }
    .tab { padding: 12px 24px; background: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s; }
    .tab:hover { background: #f0f0f0; }
    .tab.active { background: #667eea; color: white; }
    .search-box { width: 100%; padding: 14px 18px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 16px; margin-bottom: 20px; }
    .search-box:focus { outline: none; border-color: #667eea; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 16px; }
    .icon-card { background: white; border-radius: 10px; padding: 16px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.08); transition: all 0.2s; cursor: pointer; }
    .icon-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.12); }
    .icon-card img { width: 64px; height: 64px; object-fit: contain; margin-bottom: 8px; }
    .icon-card .name { font-size: 12px; color: #666; word-break: break-all; line-height: 1.4; }
    .icon-card .path { font-size: 10px; color: #999; margin-top: 4px; font-family: monospace; }
    .stats { text-align: center; color: #666; margin-bottom: 16px; font-size: 14px; }
    .toast { position: fixed; bottom: 20px; right: 20px; background: #333; color: white; padding: 12px 20px; border-radius: 8px; opacity: 0; transition: opacity 0.3s; pointer-events: none; }
    .toast.show { opacity: 1; }
    .empty { text-align: center; padding: 60px 20px; color: #999; font-size: 16px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>🖼️ LobeHub Icons</h1>
    <p>$ICON_COUNT 个精美的 WebP 图标，支持 Light/Dark 主题</p>
  </div>

  <div class="container">
    <div class="tabs">
      <button class="tab active" data-theme="light">Light 主题</button>
      <button class="tab" data-theme="dark">Dark 主题</button>
    </div>

    <input type="text" class="search-box" id="search" placeholder="🔍 搜索图标名称 (例如: adobe, ai, code...)">

    <div class="stats" id="stats">加载中...</div>
    <div class="grid" id="grid"></div>
  </div>

  <div class="toast" id="toast">已复制到剪贴板</div>

  <script type="module" src="/main.js"></script>
</body>
</html>
HTMLEOF

echo ""
echo "✅ 构建完成！"
echo "📁 输出文件: index.html, main.js, light/, dark/"
echo "📊 图标总数: $ICON_COUNT"
echo ""
echo "🚀 部署说明:"
echo "   1. 提交代码到 Git"
echo "   2. EdgeOne 会自动检测并构建"
echo "   3. 在 EdgeOne 规则引擎中添加:"
echo "      - 当 404 时，重定向到 /index.html (用于 SPA 路由)"
echo ""
echo "📋 根目录结构:"
ls -lh 2>/dev/null | tail -n +2