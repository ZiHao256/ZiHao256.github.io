---
title: LinuxLearning
categories: 
  - 学无止境
  - 操作系统学习
tags:
  - 操作系统
  - Linux
abbrlink: 9750b399
date: 2021-03-05
---
# LinuxLearning

[toc]

# 0 Linux 系统简介

## 0.0 历史

* 操作系统始于二十世纪五十年代，当时的操作系统能运行批处理程序。批处理程序不需要用户的交互，它从文件或者穿孔卡片读取数据，然后输出到另外一个文件或者打印机
* 二十世纪六十年代初，交互式操作系统开始流行。它不仅仅可以交互，还能使多个用户从不同的终端同时操作主机。这样的操作系统被称作分时操作系统，它的出现对批处理操作系统是个极大的挑战。
* UNIX 最初免费发布并因此在大学里受到欢迎。后来，UNIX 实现了 TCP/IP 协议栈
* Linux 本身只是操作系统的内核。内核是使其它程序能够运行的基础。它实现了多任务和硬件管理，用户或者系统管理员交互运行的所有程序实际上都运行在内核之上
  * 其中有些程序是必需的，比如说，命令行解释器（shell），它用于用户交互和编写 shell 脚本。
* 许多重要的软件，包括 C 编译器，都来自于自由软件基金 GNU 项目。GNU 项目开始于 1984 年，目的是为了开发一个完全类似于 UNIX 的免费操作系统。为了表扬 GNU 对 Linux 的贡献，许多人把 Linux 称为 GNU/Linux（GNU 有自己的内核）
* 1992－1993 年，Linux 内核具备了挑战 UNIX 的所有本质特性，包括 TCP/IP 网络，图形界面系统（X window )，Linux 同样也吸引了许多行业的关注。一些小的公司开始开发和发行 Linux，有几十个 Linux 用户社区成立。1994 年，Linux 杂志也开始发行。
* Linux 内核 1.0 在 1994 年 3 月发布，内核的发布要经历许多开发周期，直至达到一个稳定的版本。

## 0.1 简介

* 是一种自由和开放源码的操作系统，有着不同的Linux版本，但都是用了Linux内核。

  * ![这里写图片描述](https://img-blog.csdn.net/20180527120259589?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2Nja2V2aW5jeWg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
* Linux 可安装在各种计算机硬件设备中：手机、平板电脑、路由器、台式计算机

  * ![img](https://img-blog.csdn.net/2018090315211355?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQwNTMwOTQz/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## 0.2 特点

* 多用户，多任务，
* 丰富的网络功能，
* 可靠的系统安全，
* 良好的可移植性，
* 具有标准兼容性，
* 良好的用户界面，
* 出色的速度性能

## 0.3 CentOS

* 主流：目前的Linux操作系统主要应用于生产环境，主流企业级Linux系统仍旧是RedHat或者CentOS
* 免费：RedHat 和CentOS差别不大
* 更新方便：CentOS独有的yum命令支持在线升级，可以即时更新系统，不像RedHat 那样需要花钱购买支持服务！

## 0.4 Linux 目录结构

![这里写图片描述](https://img-blog.csdn.net/20180527120637267?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2Nja2V2aW5jeWg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

* bin(binaries): 二进制可执行文件
* sbin(super user binaries)：存放二进制可执行文件，只有root能访问
* etc(etcetera)：存放系统配置文件
* usr(unix shared resources)：存放共享的系统资源
* home： 存放用户文件的根目录
* root：超级用户目录
* dev(devices)：存放设备文件
* lib(library)：存放跟文件系统中的程序运行所需要的共享库及内核模块
* mnt(mount：系统管理员安装临时文件系统的安装点
* boot：存放用于系统引导时使用的各种文件
* tmp(temporary)：用于存放各种临时文件
* var(variable)：存放运行时需要改变数据的文件

## 0.5 Linux 与 Windows的区别

1. 免费与收费
   * 最新正版Windows10需付费
   * Linux 免费或少许费用
2. 软件与支持
3. 安全性
4. 使用习惯
   * Windows：普通用户基本都是纯图形界面下操作使用，依靠鼠标和键盘完成一切操作，用户上手容易，入门简单；
   * Linux：兼具图形界面操作（需要使用带有桌面环境的发行版）和完全的命令行操作，可以只用键盘完成一切操作，新手入门较困难，需要一些学习和指导（这正是我们要做的事情），一旦熟练之后效率极高。
5. 可定制性
6. 应用范畴
   * 在 Windows 使用百度、谷歌，上淘宝，聊 QQ 时，支撑这些软件和服务的，是后台成千上万的 Linux 服务器主机，它们时时刻刻都在忙碌地进行着数据处理和运算，可以说世界上大部分软件和服务都是运行在 Linux 之上的。
7. Windows 没有的：
   * 稳定的系统
   * 安全性和漏洞的快速修补
   * 多用户
   * 用户和用户组的规划
   * 相对较少的资源占用
   * 可定制裁剪，移植到嵌入式平台
   * 可选择的多种图形用户界面
8. Linux 没有的：
   * 特定的支持厂商
   * 足够的游戏娱乐支持度
   * 足够的专业软件支持度

# 1 VMware 虚拟机

## 1.1 介绍

## 1.2 下载及安装

[参考博客](https://www.cnblogs.com/98han/p/13170117.html)

**安装版本：**` VMware-workstation-full-15.5.0-14665864`

使用第一个密钥成功！

![image-20210306193651528](E:\LearningNotes\Linux\LinuxLearning.assets\image-20210306193651528.png)

# 2 Linux 系统下载及安装

[参考博客](https://jiannan.blog.csdn.net/article/details/79417947?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control&dist_request_id=1328603.29514.16150273040264577&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control)

[Linux 安装包（百度云盘）](https://pan.baidu.com/s/1HVKs4tQaghwxF215LXpWyg)

~~花了九块钱，买了百度云盘加速券，呜呜呜~~

## 2.1 虚拟机的创建

[参考博客](https://jiannan.blog.csdn.net/article/details/79417947?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control&dist_request_id=1328603.29514.16150273040264577&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control)

## 2.2 安装Linux 系统

[参考博客](https://jiannan.blog.csdn.net/article/details/79417947?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control&dist_request_id=1328603.29514.16150273040264577&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-5.control)

**遇到的问题：**

* * [X] 问题一：![img](https://img-blog.csdn.net/2018030316140063?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2VpeGluXzM4MTExOTU3/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

  * 我选择将 D 盘压缩 30G ，新建空的简单卷来装此系统
* * [X] 问题二：`have no enough available....`

  * 最后在给 `根目录`分区，根目录就是在选择挂载点的第一个 `/`，然后下面有个选择框 `选择最大的值`，分区4个就够了。
* **password**：`ZihaoMa123`
* **Congratulations**![image-20210306213821201](E:\LearningNotes\Linux\LinuxLearning.assets\image-20210306213821201.png)
* 在输入密码（*密码就是在安装系统时输入的密码*）的时候是不会出现 `****`

虚拟机挂起和关机的区别

* 挂起：相当于物理机中的休眠到内存功能
* 关机：执行普通关机操作

# 3 学习 Linux 的好习惯

* 善于使用 `man 命令`查看帮助文档
* 利用好 `Tab`键
* 掌握好：
  * `ctrl + c` 停止当前进程
  * `ctrl + r 查看命令历史`
  * `ctrl + l` 清屏

# 如何学习 Linux

## 1 心态

* 明确目的：用Linux来干什么（搭建服务器，做程序开发，日常办公，还是娱乐游戏）
* 面对现实：Linux 大都在命令行下操作，能否接受不用图形化界面
* 是学习Linux操作系统本身，还是某一个发行版（Ubuntu，CentOS，Fedora，OpenSUSE等）

  * [Linux发行版](https://baike.baidu.com/item/Linux%E7%89%88%E6%9C%AC)
* > 一个典型的Linux发行版包括：[Linux内核](https://baike.baidu.com/item/Linux内核)，一些[GNU](https://baike.baidu.com/item/GNU)[程序库](https://baike.baidu.com/item/程序库/7662317)和工具，命令行shell，图形界面的[X Window](https://baike.baidu.com/item/X Window)系统和相应的[桌面环境](https://baike.baidu.com/item/桌面环境/3373875)，如[KDE](https://baike.baidu.com/item/KDE)或[GNOME](https://baike.baidu.com/item/GNOME)，并包含数千种从办公套件，[编译器](https://baike.baidu.com/item/编译器/8853067)，[文本编辑器](https://baike.baidu.com/item/文本编辑器/8853160)到科学工具的应用软件。
  >

## 2 注重基础，从头开始

![img](https://img-blog.csdn.net/20180903153014660?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQwNTMwOTQz/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
