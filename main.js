// 动态获取图标列表
let lightIcons = [];
let darkIcons = [];

async function loadIcons() {
  try {
    // 使用 fetch 获取 light 目录的文件列表
    const response = await fetch('/light/');
    const text = await response.text();

    // 解析 HTML 获取 .webp 文件
    const parser = new DOMParser();
    const doc = parser.parseFromString(text, 'text/html');
    const links = doc.querySelectorAll('a[href$=".webp"]');

    lightIcons = Array.from(links)
      .map(a => a.getAttribute('href').replace('./', ''))
      .filter(name => !name.includes('-dark.webp'))
      .sort();

    darkIcons = lightIcons.map(f => f.replace('.webp', '-dark.webp'));

    currentIcons = [...lightIcons];
    renderIcons(currentIcons);
  } catch (error) {
    console.error('加载图标列表失败:', error);
    grid.innerHTML = '<div class="empty">加载失败，请刷新页面重试</div>';
  }
}

let currentTheme = 'light';
let currentIcons = [];

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
loadIcons();
