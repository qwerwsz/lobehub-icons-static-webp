#!/bin/bash

# LobeHub Icons 静态文件同步脚本
# 支持腾讯云 COS、阿里云 OSS、自定义服务器等

set -e

# 配置区 - 请根据实际情况修改
# ============================================================================
# 1. 腾讯云 COS (推荐)
COS_BUCKET="your-bucket-1234567890"  # 替换为你的 COS 存储桶名称
COS_REGION="ap-guangzhou"            # 替换为你的区域，如 ap-guangzhou
COS_SECRET_ID=""                     # 替换为你的 SecretId
COS_SECRET_KEY=""                    # 替换为你的 SecretKey

# 2. 阿里云 OSS
OSS_BUCKET="your-bucket"
OSS_REGION="oss-cn-hangzhou"
OSS_ACCESS_KEY_ID=""
OSS_ACCESS_KEY_SECRET=""

# 3. 自定义服务器 (SSH/SCP)
SSH_USER="root"
SSH_HOST="your-server.com"
SSH_PORT="22"
SSH_DIR="/var/www/html/icons"

# 4. 腾讯云 EdgeOne (通过 COS 同步后配置加速)
EDGEONE_SITE_ID=""
# ============================================================================

# 使用说明
usage() {
  echo "用法: $0 [选项]"
  echo ""
  echo "选项:"
  echo "  cos          同步到腾讯云 COS"
  echo "  oss          同步到阿里云 OSS"
  echo "  ssh          同步到自定义服务器"
  echo "  edgeone      同步到腾讯云 EdgeOne (通过 COS)"
  echo "  local        本地预览"
  echo "  help         显示帮助信息"
  echo ""
  echo "示例:"
  echo "  $0 cos        # 同步到腾讯云 COS"
  echo "  $0 local      # 启动本地服务器"
  exit 1
}

# 检查依赖
check_deps() {
  local tool=$1
  if ! command -v $tool &> /dev/null; then
    echo "❌ 错误: 未找到 $tool，请先安装"
    echo "   coscli: https://github.com/tencentyun/coscli"
    echo "   ossutil: https://help.aliyun.com/document_detail/121341.html"
    exit 1
  fi
}

# 同步到腾讯云 COS
sync_to_cos() {
  echo "🚀 开始同步到腾讯云 COS..."
  echo "   存储桶: $COS_BUCKET"
  echo "   区域: $COS_REGION"
  echo ""

  # 检查 coscli
  check_deps "coscli"

  # 配置 coscli (如果未配置)
  if [ -z "$COS_SECRET_ID" ] || [ -z "$COS_SECRET_KEY" ]; then
    echo "❌ 请在脚本中配置 COS_SECRET_ID 和 COS_SECRET_KEY"
    exit 1
  fi

  # 执行同步
  coscli sync ./ "cos://$COS_BUCKET/" \
    --region "$COS_REGION" \
    --secret-id "$COS_SECRET_ID" \
    --secret-key "$COS_SECRET_KEY" \
    --delete \
    --recursive

  echo ""
  echo "✅ 同步完成！"
  echo "   访问地址: https://$COS_BUCKET.cos.$COS_REGION.myqcloud.com/index.html"
  echo ""
  echo "💡 提示: 如果需要加速访问，可以在 EdgeOne 控制台绑定此 COS 存储桶"
}

# 同步到阿里云 OSS
sync_to_oss() {
  echo "🚀 开始同步到阿里云 OSS..."
  echo "   存储桶: $OSS_BUCKET"
  echo "   区域: $OSS_REGION"
  echo ""

  check_deps "ossutil"

  if [ -z "$OSS_ACCESS_KEY_ID" ] || [ -z "$OSS_ACCESS_KEY_SECRET" ]; then
    echo "❌ 请在脚本中配置 OSS_ACCESS_KEY_ID 和 OSS_ACCESS_KEY_SECRET"
    exit 1
  fi

  # 执行同步
  ossutil sync ./ "oss://$OSS_BUCKET/" \
    -r \
    -u \
    --delete

  echo ""
  echo "✅ 同步完成！"
  echo "   访问地址: https://$OSS_BUCKET.$OSS_REGION.aliyuncs.com/index.html"
}

# 同步到自定义服务器
sync_to_ssh() {
  echo "🚀 开始同步到服务器..."
  echo "   服务器: $SSH_USER@$SSH_HOST:$SSH_PORT"
  echo "   目录: $SSH_DIR"
  echo ""

  check_deps "rsync"

  # 使用 rsync 同步
  rsync -avz --delete \
    -e "ssh -p $SSH_PORT" \
    ./ \
    "$SSH_USER@$SSH_HOST:$SSH_DIR/"

  echo ""
  echo "✅ 同步完成！"
  echo "   访问地址: http://$SSH_HOST/index.html"
}

# 同步到 EdgeOne (通过 COS)
sync_to_edgeone() {
  echo "🚀 开始同步到 EdgeOne..."
  echo "   步骤 1: 先同步到腾讯云 COS"
  echo ""

  sync_to_cos

  echo ""
  echo "   步骤 2: 在 EdgeOne 控制台配置"
  echo "   1. 登录腾讯云 EdgeOne 控制台"
  echo "   2. 选择你的站点"
  echo "   3. 进入'源站配置'"
  echo "   4. 选择'对象存储(COS)'"
  echo "   5. 选择你的存储桶: $COS_BUCKET"
  echo ""
  echo "✅ 完成！你的 EdgeOne 站点现在可以访问这些图标了"
}

# 本地预览
local_preview() {
  echo "🚀 启动本地服务器..."
  echo "   访问地址: http://localhost:8080"
  echo "   按 Ctrl+C 停止"
  echo ""

  if command -v python3 &> /dev/null; then
    python3 -m http.server 8080
  elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer 8080
  else
    echo "❌ 未找到 Python，请安装或使用其他方式启动服务器"
    exit 1
  fi
}

# 显示帮助
show_help() {
  echo "LobeHub Icons 静态文件同步脚本"
  echo ""
  echo "用法: $0 [选项]"
  echo ""
  echo "选项:"
  echo "  cos          同步到腾讯云 COS"
  echo "  oss          同步到阿里云 OSS"
  echo "  ssh          同步到自定义服务器"
  echo "  edgeone      同步到腾讯云 EdgeOne (通过 COS)"
  echo "  local        本地预览"
  echo "  help         显示帮助信息"
  echo ""
  echo "配置:"
  echo "  编辑脚本文件，修改对应的配置变量"
  echo "  例如: COS_BUCKET, COS_REGION, COS_SECRET_ID, COS_SECRET_KEY"
  echo ""
  echo "依赖工具:"
  echo "  - coscli: 用于腾讯云 COS"
  echo "  - ossutil: 用于阿里云 OSS"
  echo "  - rsync: 用于 SSH 同步"
  echo ""
  echo "安装 coscli:"
  echo "  curl -L https://github.com/tencentyun/coscli/releases/latest/download/coscli-linux -o coscli"
  echo "  chmod +x coscli"
  echo "  sudo mv coscli /usr/local/bin/"
}

# 主逻辑
case "$1" in
  cos)
    sync_to_cos
    ;;
  oss)
    sync_to_oss
    ;;
  ssh)
    sync_to_ssh
    ;;
  edgeone)
    sync_to_edgeone
    ;;
  local)
    local_preview
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    usage
    ;;
esac
