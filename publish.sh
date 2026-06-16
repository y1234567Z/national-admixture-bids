#!/bin/bash
set -e

git add .

if git diff --cached --quiet; then
  echo "没有检测到文件变化，无需发布。"
  exit 0
fi

git commit -m "auto update $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo "发布完成：GitHub 已更新，Cloudflare Pages 会自动部署。"
