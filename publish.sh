#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台"
PUBLISH_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static"
LOG_DIR="$PROJECT_DIR/logs"
ERROR_LOG="$LOG_DIR/publish.log"

mkdir -p "$LOG_DIR"

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$ERROR_LOG"
}

trap 'log_error "publish.sh 第 $LINENO 行失败，退出码 $?"' ERR

if [ ! -d "$PUBLISH_DIR" ]; then
  echo "发布目录不存在：$PUBLISH_DIR" | tee -a "$ERROR_LOG"
  exit 1
fi

if [ "$(pwd)" != "$PUBLISH_DIR" ] || [ ! -d ".git" ]; then
  echo "当前目录不是 Git 仓库，自动切换到发布目录：$PUBLISH_DIR"
fi

cd "$PUBLISH_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "发布目录不是 Git 仓库：$PUBLISH_DIR" | tee -a "$ERROR_LOG"
  exit 1
fi

echo "当前目录：$(pwd)"
echo "Git 分支：$(git branch --show-current)"
echo "最近一次 commit：$(git log -1 --oneline)"

git add .

git commit --allow-empty -m "auto update $(date '+%Y-%m-%d %H:%M')"
COMMIT_ID="$(git rev-parse --short HEAD)"

set +e
PUSH_OUTPUT="$(git push origin main 2>&1)"
PUSH_CODE=$?
set -e

echo "$PUSH_OUTPUT"

echo "commit id：$COMMIT_ID"

if [ "$PUSH_CODE" -eq 0 ]; then
  echo "push 是否成功：成功"
  echo "Cloudflare 部署状态：已触发自动部署"
else
  echo "push 是否成功：失败"
  echo "Cloudflare 部署状态：未触发（git push 失败）"
  log_error "git push origin main 失败：$PUSH_OUTPUT"
  exit "$PUSH_CODE"
fi

echo "✅ GitHub发布成功"
echo "✅ Cloudflare自动部署中"
echo "✅ 网站地址：https://www.yzbids.cn"
