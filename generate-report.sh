#!/usr/bin/env bash
set -x
mkdir -p reports
DATENAME=$(date +"%Y-%m-%d")
REPORT=reports/$DATENAME.md
ncu-ci walk pr --stats=true --markdown $REPORT
awk '/^### / {exit} {print}' $REPORT > progress.md
echo "Open https://github.com/$GITHUB_REPOSITORY/blob/main/$REPORT to see failure details" >> progress.md
echo -en "\n" >> progress.md

awk '/^### Progress/ {found=1} found' $REPORT >> progress.md
echo -en "\n" >> progress.md

sed -i '/^### Progress/,$d' $REPORT

git config user.name "Node.js GitHub Bot"
git config user.email github-bot@iojs.org

git add ./reports
git commit -m "Add report for $DATENAME"
git --no-pager log -1 --stat

git push
