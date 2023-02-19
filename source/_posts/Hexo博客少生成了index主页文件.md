---
title: Hexo博客少生成了index主页文件
toc: true
categories:
  - 个人提升
  - 博客更新
tags:
  - Blog
  - Debug
abbrlink: 6de7b885
date: 2023-02-19 17:57:13
---

# 问题描述

在进行 `node` 和 `npm` 的版本更新之后，再以此运行`hexo g`和`hexo s`，发现访问主页为`404`，而其他页面均正常。

# 思考

对比近几次的`commit`发现少生成了`index.html`文件，并且在`package.json`等文件中少了一行`generator-inex`，可能和`node`及`npm`的更新相关？

但是，使用`git reset --hard`[1]命令回溯到以上配置文件未改动后，依然发现不会生成`index.html`，咋么回事。。。


# 解决方法

使用 `npm install hexo-generator-index` 命令将依赖包重新下载回来。。。（

很快找到缺少了依赖包，但是并没有立刻对依赖包进行下载，而是兜兜转转了一下午（比较两个`commit`）

refs:

学会`git log`, `git reset`等命令

[1]: https://blog.csdn.net/luobeihai/article/details/128171764?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-128171764-blog-108067196.pc_relevant_vip_default&spm=1001.2101.3001.4242.1&utm_relevant_index=4

