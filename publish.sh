#!/bin/bash
set -euo pipefail

PUBLISH_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static"

if [ ! -d "$PUBLISH_DIR" ]; then
  echo "发布目录不存在：$PUBLISH_DIR"
  exit 1
fi

cd "$PUBLISH_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "当前目录不是 Git 仓库，自动切换到发布目录：$PUBLISH_DIR"
  cd "$PUBLISH_DIR"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "发布目录不是 Git 仓库：$PUBLISH_DIR"
  exit 1
fi

git add .

git commit --allow-empty -m "auto update $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo "✅ GitHub发布成功"
echo "✅ Cloudflare自动部署中"
echo "✅ 网站地址：https://www.yzbids.cn"
