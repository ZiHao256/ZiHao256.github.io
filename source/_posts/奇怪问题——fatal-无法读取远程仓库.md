---
title: '奇怪问题——fatal:无法读取远程仓库'
toc: true
categories:
  - 个人提升
  - 博客更新
tags:
  - Blog
  - Bug
date: 2023-02-18 23:29:43
---

# 问题描述

连接校园网，运行`hexo d`得到如下报错：

![image-20230218233114978](https://raw.githubusercontent.com/ZiHao256/Gallery/master/uPic/2023/02/image-20230218233114978.png)

试图将博客源码推送至Github，也报如下错误：在连接手机热点之后才能成功推送

![image-20230218233129157](https://raw.githubusercontent.com/ZiHao256/Gallery/master/uPic/2023/02/image-20230218233129157.png)

也成功将博客部署到Github：

![image-20230218233138553](https://raw.githubusercontent.com/ZiHao256/Gallery/master/uPic/2023/02/image-20230218233138553.png)

# 思考

- 看报错是被github.com服务器的22端口关闭了连接，可能和这个端口有关
- ~~VPN 有关？~~关闭VPN 的话，操作超时



# 解决方法1

`attempt to clone using an SSH connection made over the HTTPS port.`

- 可以成功访问主机名为`ssh.github.com`的端口`443`
  - 但不知为何，访问响应时间很久。。。。。。。。。。。。。。。。



# 解决方法2

把 rsa 密钥删掉，关闭VPN，重新创建 rsa 密钥对，并将公钥加入github，重新用ssh连接。

可以成功连接。。。



# **refs：**

情况与下文一致：

[ssh远程登录报错：kex_exchange_identification: Connection closed by remote host - 腾讯云开发者社区-腾讯云 (tencent.com)](https://cloud.tencent.com/developer/article/1946906)



官方解决方法：

- [【求助】开启OpenClash之后，无法使用 git clone/push，kex ssh 密钥错误 · Issue #1960 · vernesong/OpenClash (github.com)](https://github.com/vernesong/OpenClash/issues/1960#issuecomment-1115732292)
  - [Using SSH over the HTTPS port - GitHub Docs](https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port)



方法2:

[(252条消息) 连接GitHub提示远程主机关闭连接_week@eight的博客-CSDN博客_github 关闭连接](https://blog.csdn.net/qq_43431735/article/details/106031021)



对`SSH`的拓展知识

[Github配置ssh key的步骤（大白话+包含原理解释）_风中一匹狼v的博客-CSDN博客_github ssh key](https://blog.csdn.net/weixin_42310154/article/details/118340458)



