# 网站发布目录规则

本目录是全国外加剂招标监测平台的网站发布目录，也是 GitHub 仓库目录：

`/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static`

本目录用于：
- index.html
- 404.html
- latest.json
- meta.json
- changes.json
- publish.sh
- git add
- git commit
- git push origin main

凡是涉及 GitHub 发布、git status、git commit、git push，必须先进入本目录：

cd "/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/outputs/tencent-static"

禁止在项目根目录执行 git status、git commit 或 git push。

发布脚本必须支持从项目根目录或本目录执行，并在执行 git add / commit / push 前自动切换到本目录。

发布前必须输出：
- 当前目录
- Git 分支
- 最近一次 commit

发布后必须输出：
- commit id
- push 是否成功
- Cloudflare 部署状态

任何发布错误必须写入项目根目录：

`/Users/q/AIWorkspace/03_AI项目/全国外加剂招标监测平台/logs/publish.log`
