#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

git add .

git commit --allow-empty -m "auto update $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo "✅ GitHub发布成功"
echo "✅ Cloudflare自动部署中"
echo "✅ 网站地址：https://www.yzbids.cn"
