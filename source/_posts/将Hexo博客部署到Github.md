---
title: 将Hexo博客部署到Github
toc: true
categories:
  - 个人提升
  - 博客更新
tags:
  - Blog
abbrlink: '82975e94'
date: 2023-02-18 22:26:11
---

1. 在 Github 创建一个公开仓库
2. 创建一个 `hexo` 分支用于存储 `Hexo`博客 的文件源码，将其设置为默认分支，这样可以用来在多个终端上进行博客书写。
   1. 注意：需要自己手动去提交最新源码
3. 在本地 Hexo 根目录的配置文件中，设置部署的仓库和分支，分支为 master。这样在本地使用命令`hexo d`时，会自动将生成的 HTML 静态文件覆盖并部署到 master 分支

refs：
https://zhuanlan.zhihu.com/p/71544809