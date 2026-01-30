import { defineConfig } from 'vite';
import { resolve } from 'path';
import { copyFileSync, mkdirSync, readdirSync, existsSync } from 'fs';

// 复制图标文件到输出目录
function copyIconsPlugin() {
  return {
    name: 'copy-icons',
    closeBundle() {
      const iconsDir = resolve(process.cwd(), 'node_modules/@lobehub/icons-static-webp');
      const outputDir = resolve(process.cwd(), 'dist');

      if (!existsSync(iconsDir)) {
        console.warn('⚠️  Icons package not found, skipping copy');
        return;
      }

      // 创建输出目录
      mkdirSync(outputDir, { recursive: true });
      mkdirSync(resolve(outputDir, 'light'), { recursive: true });
      mkdirSync(resolve(outputDir, 'dark'), { recursive: true });

      // 复制 light 图标
      const lightDir = resolve(iconsDir, 'light');
      if (existsSync(lightDir)) {
        const files = readdirSync(lightDir);
        files.forEach(file => {
          copyFileSync(
            resolve(lightDir, file),
            resolve(outputDir, 'light', file)
          );
        });
        console.log(`✅ Copied ${files.length} light icons`);
      }

      // 复制 dark 图标
      const darkDir = resolve(iconsDir, 'dark');
      if (existsSync(darkDir)) {
        const files = readdirSync(darkDir);
        files.forEach(file => {
          copyFileSync(
            resolve(darkDir, file),
            resolve(outputDir, 'dark', file)
          );
        });
        console.log(`✅ Copied ${files.length} dark icons`);
      }
    }
  };
}

export default defineConfig({
  plugins: [copyIconsPlugin()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html')
      }
    }
  },
  publicDir: false
});
