#!/bin/bash
echo "git add"
git add .

echo "git commit"
git commit -m 'update Hexo source code'

echo "git push github"
git push github

echo "git push gitee"
git push gitee