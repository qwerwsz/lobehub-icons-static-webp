// 从 npm 包读取图标列表
import icons from '@lobehub/icons-static-webp/package.json' assert { type: 'json' };

// 生成图标列表
const lightIcons = [];
const darkIcons = [];

// 读取 light 目录下的所有 .webp 文件
const lightDir = import.meta.glob('./node_modules/@lobehub/icons-static-webp/light/*.webp');
const darkDir = import.meta.glob('./node_modules/@lobehub/icons-static-webp/dark/*.webp');

// 提取文件名
for (const path in lightDir) {
  const filename = path.split('/').pop();
  if (filename) lightIcons.push(filename);
}

for (const path in darkDir) {
  const filename = path.split('/').pop();
  if (filename) darkIcons.push(filename);
}

// 按字母排序
lightIcons.sort();
darkIcons.sort();

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

// 初始渲染
renderIcons(currentIcons);

// 暴露到全局
window.copyPath = copyPath;
