---
title: Obsidian
post_asset_folder: true
toc: true
categories:
  - 利器酷 
  - 工具方法
tags:
  - 科研
  - 论文
  - 笔记
abbrlink: b58cbef5
date: 2022-07-07 08:26:27
---


# 基本 markdown 语法
## 脚注
hello world[^长脚注] ^968640

## 高亮
==高亮==





# 建立笔记与笔记之间的连接

>形成知识网，可以使用左侧进行 graph view


## 内部链接
> 链接库中某篇笔记

输入 `[[` 即可选择要链接的某篇库内文章：[Obsidian和Typora之间的权衡](Obsidian和Typora之间的权衡.md)
1. 输入 # 可以选择链接文章某个段落：[基本 markdown 语法](Obsidian.md#基本%20markdown%20语法)
2. 输入 ^ 可以选择链接文章某个文字段落：[链接hello world](Obsidian.md#^968640)

## 反向链接
> 具体显示了哪些笔记链接了当前笔记，哪些笔记提到了当前笔记的名字但并未进行链接
> 在正文中提到了当前笔记的文件名，但没有链接当前笔记（没有用方括号括起来）

1. 同 `链接当前文件` 一样在右侧边栏显示，可以将其转换为**链接**


# 在 Hexo 博客中插入本地图片
1. 图片保存于同一目录下的文件夹中；
2. 使用 `Hexo3` 支持的语法 `{% asset_img example.jpg hello%}` 进行插入图片；

缺点是无法在本地渲染图片


# 检索和管理
> 文件夹、标签、链接

1. 点击左侧的 🔍 可以搜索文件夹、文件、链接等内容
2. 在阅读视图里点击 front matter 的某个标签即可搜索到拥有该标签的所有文章


# 可以使用 $Latex$ 公式
> 同 typora


$$D(x) = \begin{cases}
\lim\limits_{x \to 0} \frac{a^x}{b+c}, & x<3 \\
\pi, & x=3 \\
\int_a^{3b}x_{ij}+e^2 \mathrm{d}x,& x>3 \\
\end{cases}$$



# 好用的插件
## slide
用  `---` 来分割页面，制作为一个一个 slide 页面，然后点击右上角的 `开始演示`









`refs`：

- [Obsidian 中文帮助 - Obsidian Publish](https://publish.obsidian.md/help-zh)
- [Obsidian：一款完美的科研笔记/知识管理软件 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/349638221)
- [Obsidian：目前我们眼中最美最好用的免费笔记/知识管理软件_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1SA411i7BG?vd_source=de5d636c079ac45214bd34891ede8c4b)
- [超好用笔记软件！神奇的Obsidian黑曜石Markdown文本编辑知识管理工具，成为你的第二大脑【方俊皓同学】_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Ya4y1E7Mo?vd_source=de5d636c079ac45214bd34891ede8c4b)


[^长脚注]:很长的脚注