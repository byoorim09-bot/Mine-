#!/usr/bin/env bash
# 「50대중년 세련미 풀풀 코디법」 GitHub Pages 재배포 스크립트
# 저장소: byoorim09-bot/Mine-   공개 URL: https://byoorim09-bot.github.io/Mine-/
#
# ★ 중요: 이 저장소의 GitHub Pages는 `gh-pages` 브랜치를 바라보고 있습니다.
#   (Pickle의 GitHub 연결에는 Pages 설정 변경 권한이 없어, gh-pages 브랜치를 푸시해
#    Pages가 자동 활성화된 상태입니다. API로 소스 브랜치를 main으로 바꾸는 것은 403/404로 불가)
#   따라서 수정 후에는 main과 gh-pages 두 브랜치에 모두 푸시해야 사이트가 갱신됩니다.
set -u
OWNER=byoorim09-bot
REPO=Mine-
cd "$(dirname "$0")" || exit 1

echo "== 1) main + gh-pages 동시 푸시 =="
git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
git remote set-url origin "https://github.com/$OWNER/$REPO.git"
git add -A && git commit -m "${1:-Update site}" || echo "(변경 사항 없음)"
git push origin main || { echo "PUSH(main) FAILED"; exit 1; }
git push origin main:gh-pages || { echo "PUSH(gh-pages) FAILED"; exit 1; }

echo "== 2) Pages 상태 =="
gh api "/repos/$OWNER/$REPO/pages" 2>&1 | head -5

echo "== 3) 공개 URL 응답 확인 =="
for i in $(seq 1 20); do
  code=$(curl -s -o /tmp/coordi.html -w "%{http_code}" "https://$OWNER.github.io/$REPO/")
  echo "attempt $i: HTTP $code"
  if [ "$code" = "200" ]; then
    grep -o "<title>[^<]*</title>" /tmp/coordi.html
    break
  fi
  sleep 15
done
