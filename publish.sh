#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台"
PUBLISH_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static"
RETRY_PUSH="$PROJECT_DIR/retry_push.sh"
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

echo "commit id：$COMMIT_ID"
echo "push 是否成功：后台重试已启动"
echo "Cloudflare 部署状态：retry_push.sh 推送成功后自动触发"

nohup "$RETRY_PUSH" >/tmp/yzbids_retry_push.log 2>&1 &
RETRY_PID=$!
echo "retry_push.sh PID：$RETRY_PID"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] publish.sh 已创建 commit ${COMMIT_ID}，并启动 retry_push.sh，PID=${RETRY_PID}。" >> "$ERROR_LOG"

echo "✅ 本地发布成功"
echo "✅ Cloudflare自动部署中"
echo "✅ 网站地址：https://www.yzbids.cn"
