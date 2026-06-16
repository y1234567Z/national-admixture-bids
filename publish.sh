#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

git add .

if git diff --cached --quiet; then
  echo "没有检测到文件变化，跳过发布。"
  exit 0
fi

git commit -m "auto update $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo "✅ GitHub发布成功"
echo "✅ Cloudflare自动部署中"
echo "✅ 网站地址：https://www.yzbids.cn"
