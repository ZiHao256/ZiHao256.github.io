---
title: Overleaf
toc: true
categories:
  - 利器酷
  - 工具
tags:
  - LaTeX
abbrlink: 26d71884
date: 2023-05-15 19:11:58
---
记录一下最近尝试学习在`Overleaf`上使用LaTeX撰写论文。为了符合`XDU`毕设论文格式的要求，可以基于[note286学长提供的一些文档类和宏包](https://github.com/note286/xduts)。

- 对于本地系统
  - 学长在`README`中将基于不同`Tex`发行版的使用教程写得很详尽。
  - 在使用命令`xetex xduts.ins`后，可能会在全局将文档类和宏包安装，因此不需要再重复将其加入到自己的LaTeX项目目录下。
- 而对于`Overleaf`
  - 则必须将文档类和宏包加入到自己的项目根目录后，再打包上传至`Overleaf`的项目管理处
  - 还需要将`Compiler`设置为`XeLaTeX`

后面正式使用`LaTeX`写硕士研究生论文时，再根据自己的具体需要，调用`texdoc xduts`查阅`XDUTS`文档。

先记录到这里，Over。