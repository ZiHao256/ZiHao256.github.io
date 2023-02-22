---
title: Linux 入门学习3
categories: 
  - 个人提升
  - 操作系统学习
tags:
  - 操作系统
  - Linux
abbrlink: a525d295
date: 2021-03-12
---
# Linux 入门学习3

[toc]

> 学习使用 Vim 编辑器，编辑、保存文件，以及查看、浏览文件

# 1 使用文本编辑器 Vim

## 1.1 基本命令

![这里写图片描述](https://img-blog.csdn.net/20171206113916293?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZG92ZTEyMDJseQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

* 任何文件需要编辑默认化的编辑器
* 功能强大的全屏幕文本编辑器
* 新建、编辑、显示文件
* Vim只有 `命令`，没有 `菜单`
* 命令：
  * `vi`: 新建一个文件
    * 语法：`vi 文件名`
  * 编辑：回车后进入全屏幕的**命令模式**
    * 进入**命令模式**：`Vim` 等待输入指令
    * 输入 `i`, `a`, `o`， 进入**输入模式**（左下角会有 `insert`）
      * `i`: 在当前光标所在字符的前面，转为输入模式
      * `I`： 在当前光标所在行的行首转换为输入模式
      * `a`: 在当前光标所在字符的后面，转为输入模式
      * `A`:
      * `o`: 在当前光标所在行的下方，新建一行，并转为输入模式
      * `O`:
      * `s`: 删除光标所在字符
      * `r`: 替换光标处字符
    * 退出编辑：按 `ESC`
    * `ESC` 后进入**命令模式**，==先输入 `冒号`==：
      * `w`: 保存不退出
      * `w!`: 强制保存不退出
      * `wq`或 `x`: 保存并退出
      * `wq!`: **强制保存并退出**
      * `q`: **不保存退出**
      * `q!`: 不保存强制退出
      * `e!`: **放弃所有修改，从上次保存文件开始编辑**
* 遇到的问题：由于我在插入模式编辑完后，按 `ESC`退回不到命令模式，把虚拟机关掉后，`1.txt`文件转换成了 `.1.txt.swp`。再次创建1.txt并用vim打开：
  * ![image-20210312201009164](E:\LearningNotes\Linux\Linux 3.assets\image-20210312201009164.png)
  * Analysis：
    * `.` 是说明其是隐藏文件
    * 猜测是由于我未能成功保存文件，产生的依然正在被编辑中的文件，被占用了
  * solution：
    * 使用 `rm -rf .1.txt.swp`可以删除

## 1.2 g++和gdb的安装

**==遇到的下载安装问题仍然未解决，最后选择下载安装CentOS7，下载安装无任何问题？？？==**

* **检查gcc是否存在**：`which gcc`

  * 若没有安装，输入 `yum install gcc-c++`
* **检查gdb是否存在**：`which gdb`

  * 若没有安装，输入 `yum install gdb`
* 检查g++是否存在：`which g++`

  * 若没有安装，输入 `yum install gcc-c++ libstdc++devel`
* * [ ] 遇到了**问题**：未安装gcc，尝试用命令安装时出现：`

  * ![image-20210313192827363](E:\LearningNotes\Linux\Linux 入门学习3.assets\image-20210313192827363.png)
  * **analysis:** 似乎是网络问题
  * **solution1**:
    * [参考博客](https://blog.csdn.net/qq_34430649/article/details/51474730?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&dist_request_id=1328642.24663.16156346773373449&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control)
    * 输入内容后不能保存：`Cant open the file for writing`
      * **analysis**:可能权限不足或者文件被占用
      * **solution1:** 用vi时，加上 `sudo`来临时提供管理员权限
      * 仍然不行。。
  * **solution2**:
    * 改变思路，应该网络配置
  * **solution3**:
    * 在刚开始新建Linux系统的时候，选择 `镜像系统安装`，`gcc`和 `g++`似乎已被安装
* **问题：**`yum install g++`

  * > Loaded plugins: fastestmirror, refresh-packagekit, security
    > You need to be root to perform this command.
    >
  * **solution**：[参考 ](https://blog.csdn.net/qq_26963433/article/details/78222506)

    * 尝试使用 `su`命令切换到root用户，获取更大权限
    * result:

      * > Loaded plugins: fastestmirror, refresh-packagekit, security
        > Setting up Install Process
        > YumRepo Error: All mirror URLs are not using ftp, http[s] or file.
        > Eg. Invalid release/repo/arch combination/
        > removing mirrorlist with no valid mirrors: /var/cache/yum/i386/6/base/mirrorlist.txt
        > Error: Cannot retrieve repository metadata (repomd.xml) for repository: base. Please verify its path and try again
        >
  * **analysis:**

    * `YumRepo Error: All mirror URLs are not using ftp, http[s] or file.`

      * [参考博客](https://blog.csdn.net/weixin_44160584/article/details/110872926)
    * `http://mirror.centos.org/centos/6/os/i386/repodata/repomd.xml: [Errno 14] PYCURL ERROR 22 - "The requested URL returned error: 404 Not Found"`
    * 
    * 1. 没网，`ping www.baidu.com`
      2. ping通了的话，若还是用不了yum命令，说明yum镜像无了，那么需要就得下载一个来更新。
  * 

## 1.3 编译与运行

* 编译 `.c`文件：输入指令 `gcc 文件名.c -o 可执行程序名`

  * `gcc`: 编译该文件
  * `-o`: 在当前目录下
* 运行可执行文件：输入 `./文件名`
* 编译 `.cpp`文件：输入指令：``

## 1.4 简单配置 Vim

* 使用root权限进入根目录下的 `etc/`目录，列出所有文件，`vimrc`即是存放Linux默认配置的地方
* 可以用命令 `vim vimrc`进入文件，但一般自己进行配置时，选择在当前用户的主工作目录下新建一个 `.vimrc`文件来存放我们新增的配置
* > set number
  > filetype on
  > set history=1000
  > set nocompatible
  > set shiftwidth=4
  > color evening
  > syntax on
  > set autoindent
  > set smartindent
  > set tabstop=4
  > set showmatch
  > set guioptions-=T
  > set vb t_vb=
  > set ruler
  > set nohls
  > set incsearch
  > if has(“vms”)
  > set nobackup
  > else
  > set backup
  > endif
  >

  * > set nocompatible 注释掉讨厌的有关vi一致性模式，避免以前版本的一些bug和局限
    > set number 显示行号
    > filetype on 检测文件的类型
    > set history=1000 记录历史行数
    > color eveing 夜间背景模式
    > syntax on 语法高亮度显示
    > set autoindent
    > vim使用自动对起，也就是把当前行的对起格式应用到下一行；
    > set smartindent依据上面的对起格式，智能的选择对起方式
    > set tabstop=4 第一行设置tab键为4个空格
    > set shiftwidth=4 设置当行之间交错时使用4个空格
    > set showmatch 设置匹配模式，类似当输入一个左括号时会匹配相应的那个右括号
    > set guioptions=T 去除vim的GUI版本中的toolbar
    > set vb t_vb= 当vim进行编辑时，如果命令错误，会发出一个响声，该设置去掉响声
    > set ruler 在编辑过程中，在右下角显示光标位置的状态行
    > set nohls 默认情况下，寻找匹配是高亮度显示的，该设置关闭高亮显示
    > set incsearch 查询时非常方便，如要查找book单词，当输入到/b 会自动找到第一个b开头的单词，使用此设置会快速找到答案
    > if has(“vms”) 修改一个文件后，自动进行备份，备份的文件名为原文件名加“~“后缀
    > set nobackup
    > else
    > set backup
    > endif
    >

# 2 查看文件的方式

## 2.1 `cat` 命令

* 作用：查看浏览文件
* 语法：`cat 文件名`
* 选项：`-n`: 显示行号

## 2.2 `tac`命令

* 作用：从最后一行浏览文件内容
* 无 `-n`选项

## 2.3 `more`命令

* 语法 `more 文件路径`
* 作用：对一些长的内容可以进行翻页显示，左下角有进度百分比
* 按空格或 `f`进行翻页
* 按 `Enter`换行
* 按 `q`退出

## 2.4 `less`命令

* 作用：有着 `more`的功能
* 更多功能：
  * `pageup`或者 `up`,向前翻页
  * 查关键字：
    * 语法：`/关键字`
    * 按 `n`查找下一个关键字所在位置

## 2.5 `head` 命令

* 作用：查看文件的前几行
* 默认显示前十行
* 选项：`-n`
  * `head -n 显示行数`

## 2.6 `tail`命令

* 作用：查看文件最后几行
* 默认显示最后十行
* 选项：`-n`
  * `tail -n 显示行数`
