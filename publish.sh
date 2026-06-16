#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台"
PUBLISH_DIR="/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static"
RETRY_PUSH="$PROJECT_DIR/retry_push.sh"
LOG_DIR="$PROJECT_DIR/logs"
ERROR_LOG="$LOG_DIR/publish.log"
DAILY_REPORT="$LOG_DIR/daily_report.log"
SSH_REMOTE="git@github.com:y1234567Z/national-admixture-bids.git"

mkdir -p "$LOG_DIR"

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$ERROR_LOG"
}

ensure_ssh_remote() {
  local current_remote
  current_remote="$(git remote get-url origin 2>/dev/null || true)"
  echo "当前 origin remote：${current_remote:-未设置}"
  if [ "$current_remote" != "$SSH_REMOTE" ]; then
    echo "origin 不是 SSH remote，自动修复为 $SSH_REMOTE"
    if git remote | grep -qx "origin"; then
      git remote set-url origin "$SSH_REMOTE"
    else
      git remote add origin "$SSH_REMOTE"
    fi
  fi
  git remote -v
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

ensure_ssh_remote

echo "当前目录：$(pwd)"
echo "Git 分支：$(git branch --show-current)"
echo "最近一次 commit：$(git log -1 --oneline)"

git add .

git commit --allow-empty -m "auto update $(date '+%Y-%m-%d %H:%M')"
COMMIT_ID="$(git rev-parse --short HEAD)"
FETCH_COUNT="${YZBIDS_FETCH_COUNT:-unknown}"
NEW_COUNT="${YZBIDS_NEW_COUNT:-unknown}"
RUN_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

{
  echo "执行时间：$RUN_TIME"
  echo "抓取数量：$FETCH_COUNT"
  echo "新增数量：$NEW_COUNT"
  echo "commit id：$COMMIT_ID"
  echo "push结果：本地生成成功，等待 GitHub 推送"
  echo "Cloudflare结果：等待 GitHub push 成功后自动部署"
  echo "网站地址：https://www.yzbids.cn"
  echo "---"
} >> "$DAILY_REPORT"

awk '
  /^执行时间：/ {
    date = substr($0, 16, 10)
    if (!(date in seen)) {
      seen[date] = 1
      dates[++count] = date
    }
  }
  { lines[NR] = $0; line_date[NR] = date }
  END {
    start = count - 29
    if (start < 1) start = 1
    for (i = start; i <= count; i++) keep[dates[i]] = 1
    for (i = 1; i <= NR; i++) {
      if (line_date[i] == "" || keep[line_date[i]]) print lines[i]
    }
  }
' "$DAILY_REPORT" > "$DAILY_REPORT.tmp" && mv "$DAILY_REPORT.tmp" "$DAILY_REPORT"

echo "commit id：$COMMIT_ID"
echo "正在执行 git push origin main..."
set +e
PUSH_OUTPUT="$(git push origin main 2>&1)"
PUSH_CODE=$?
set -e

if [ "$PUSH_CODE" -eq 0 ]; then
  echo "$PUSH_OUTPUT"
  echo "push 是否成功：是"
  echo "Cloudflare 部署状态：GitHub push 成功后自动触发"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] publish.sh commit ${COMMIT_ID} 已成功 push，等待 Cloudflare 部署。" >> "$ERROR_LOG"
  echo "✅ GitHub发布成功"
  echo "✅ Cloudflare自动部署中"
  echo "✅ 网站地址：https://www.yzbids.cn"
  exit 0
fi

echo "push 是否成功：否"
echo "push 失败原因：$PUSH_OUTPUT"
echo "Cloudflare 部署状态：等待 GitHub 推送成功后自动触发"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] publish.sh commit ${COMMIT_ID} push 失败，启动 retry_push.sh。失败原因：$PUSH_OUTPUT" >> "$ERROR_LOG"

nohup "$RETRY_PUSH" "$COMMIT_ID" >/tmp/yzbids_retry_push.log 2>&1 &
RETRY_PID=$!
echo "retry_push.sh PID：$RETRY_PID"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] publish.sh 已启动 retry_push.sh，PID=${RETRY_PID}。" >> "$ERROR_LOG"

echo "本地生成成功，等待 GitHub 推送"
echo "✅ 网站地址：https://www.yzbids.cn"
