---
title: Obsidian和Zotero联动
typora-copy-images-to: Obsidian和Zotero联动
toc: true
categories:
  - 利器酷
  - 工具方法
tags:
  - 笔记
  - 论文
  - 科研
abbrlink: 52bffbc
date: 2022-07-07 15:36:47
---


# Mdnotes + Better-Bibtex + Zotfile
 [Obsidian：一款完美的科研笔记/知识管理软件 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/349638221)



# Obsidian MarkMind 插件
[mac版obsidian markmind基础教程_哔哩哔哩_bilibili](https://www.bilibili.com/video/av381778544?vd_source=de5d636c079ac45214bd34891ede8c4b)

使用步骤：
1. 在一个 markdown 文件的 fontmatter 中加入 `mindmap-plugin: basic` 生成一个思维导图文件
2. 打开为 markdown 文件
3. 使用 obsidian 的语法 `[[`加入一本 pdf 文件
4. 进入**预览模式**，点击 pdf 文件，生成并打开 pdf 注释文件
5. 在该注释文件中 注释会自动将内容复制到剪切板中，复制到原 markdown 中即可。

# 最终效果
1. 所有文献的 pdf/md 附件都保存在 `OneDrive` 中，不需要占用 `Zotero` 的空间；
2. 使用 Zotfile+Better-Bibtex 基于可修改模版对 Zotero 中的文献条目生成 md 文件，同时使用 Obsdian 对集中于同一库中的笔记进行编辑和管理，都保存于 OneDrive中；
3. 由于文献 pdf 附件和笔记保存于同一目录下，方便使用 Obsidian MarkMind 对 pdf 进行批注、记笔记和生成 思维导图。
	1. 需要注意的是，只需要在 md 笔记的 front matter 中加入 `mindmap-plugin: basic` 即可将 md 文件以思维导图的形式打开。  这对后续的复习有很大帮助 ~~猜的~~
