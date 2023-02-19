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

兜兜转转了一下午（比较两个`commit`，甚至重新在本地构建了一个新博客[^2]来`hexo d --debug`寻找构造的不同）。实际上我很快找到缺少了依赖包的问题，但是并没有立刻对依赖包进行下载，浪费了大量时间。

`hexo` 根目录的`node_modules`存储着项目所需要的依赖包，但是并不需要上传，因为过于庞大，而`package-lock.json`里已经存储了依赖包的名称和版本。

refs:

学会`git log`, `git reset`等命令

[1]: https://blog.csdn.net/luobeihai/article/details/128171764?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-128171764-blog-108067196.pc_relevant_vip_default&spm=1001.2101.3001.4242.1&utm_relevant_index=4

[2]: https://cloud.tencent.com/developer/article/1173652#:~:text=Hexo%2Bgithub%E6%90%AD%E5%BB%BA%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A2%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE%E5%92%8C%E5%8F%91%E5%B8%83%EF%BC%88%E5%9B%BE%E6%96%87%E8%AF%A6%E8%A7%A3%EF%BC%89%201%202.1%20Hexo%E8%AE%BE%E7%BD%AE%20%E8%BF%99%E4%B8%AA%E5%85%B6%E5%AE%9E%E5%B0%B1%E6%98%AF%E5%8D%9A%E5%AE%A2%E6%A0%B9%E7%9B%AE%E5%BD%95%E4%B8%8B%E7%9A%84%20_config.yml%20%E6%96%87%E4%BB%B6%EF%BC%8C%E4%B8%BB%E8%A6%81%E6%98%AF%E5%AF%B9Hexo%E7%9A%84%E9%85%8D%E7%BD%AE%E4%BB%A5%E5%8F%8A%E7%AB%99%E7%82%B9%E7%9A%84%E7%9B%B8%E5%85%B3%E9%85%8D%E7%BD%AE%EF%BC%8C%E4%B8%8B%E9%9D%A2%E5%BC%80%E5%A7%8B%E8%BF%9B%E8%A1%8C%E5%88%86%E6%AE%B5%E8%AF%A6%E7%BB%86%E7%9A%84%E8%AF%B4%E6%98%8E%201%EF%BC%89,...%204%205.2%20%E6%B7%BB%E5%8A%A0SSH%20Key%20%E6%B3%A8%E5%86%8C%E5%AE%8C%E4%BB%A5%E5%90%8E%EF%BC%8C%E4%B8%BA%E4%BA%86%E8%AE%A9%E6%88%91%E4%BB%AC%E7%9A%84%E7%94%B5%E8%84%91%E8%83%BD%E7%9B%B4%E6%8E%A5%E5%85%8D%E5%AF%86%E7%A0%81%E9%80%9A%E8%BF%87SSH%E8%AE%BF%E9%97%AEGitHub%EF%BC%8C%E9%9C%80%E8%A6%81%E5%B0%86%E6%88%91%E4%BB%AC%E7%9A%84SSH%20Key%E6%B7%BB%E5%8A%A0%E5%88%B0GitHub%E4%B8%8A%E3%80%82%20

