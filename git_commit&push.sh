#!/bin/bash
SPLITE_LINE="=========="

echo "$SPLITE_LINE git add $SPLITE_LINE"
git add .

echo "$SPLITE_LINE git commit $SPLITE_LINE"
git commit -m 'update Hexo source code'

echo "$SPLITE_LINE git push github $SPLITE_LINE"
git push github

echo "$SPLITE_LINE git push gitee $SPLITE_LINE"
git push gitee