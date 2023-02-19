---
title: hexo博客使用markdown脚注语法
toc: true
categories:
  - 个人提升
  - 博客更新
tags:
  - Blog
  - Markdown
abbrlink: ef4419f0
date: 2023-02-19 10:49:13
---

typora 的脚注功能类似于论文中的对文献引用。在学习或Debug后书写博客不免也要参考多篇网页，这时用脚注功能可以将引用到的所有网页统一写在博文最下方，使得文章看起来不会那么杂乱。

typora 支持的markdown脚注功能，但实际上markdown原生语法中并不支持，写入只支持原生 markdown 语法的hexo博客里也不会成功显示
- typora: 支持的脚注功能
  - 在引用处使用`[^x]`，被引用处使用`[^x]: description`
- butterfly[^1]: 可以使用markdown的 `Links` 来实现类似的功能：
  - 引用处使用`[连接的文本，可不填][x]`，被引用处使用`[x]: Links`

这使得使用 typora 脚注语法后，在hexo博客里不会显示被引用的链接。尽管很奇怪，但是好在可以统一写法。


refs:

[^1]: https://markdown.com.cn/basic-syntax/links.html#%E5%BC%95%E7%94%A8%E7%B1%BB%E5%9E%8B%E9%93%BE%E6%8E%A5