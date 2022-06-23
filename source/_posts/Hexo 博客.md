---
title: Hexo LearningNote
categories: '-Blog'
abbrlink: e9b15daf
---



# Hexo 博客

[最全详细（🗡）](https://io-oi.me/tech/hexo-next-optimization/)

[toc]

[参考博客](https://blog.csdn.net/gdutxiaoxu/article/details/53576018?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522161853970416780255223015%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=161853970416780255223015&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-53576018.first_rank_v2_pc_rank_v29&utm_term=Hexo+Github)

# 环境搭建的准备

* **Node.js 的安装和准备**
  * ![image-20210416102842874](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416102842874.png)

* 关于`Node.js`和`npm`的介绍: [参考博客](https://www.cnblogs.com/duanweishi/p/7729292.html)

  * npm 是 javascript 的**包管理工具**

  * npm 与 Node.js 一起发布

    * npm 更新频率快，需单独更新npm`npm install npm@latest -g`

  * **安装包**：安装对应的包至当前目录，并创建`node_modules`文件，下载包进去

    * `npm install <package_name`

  * **`package.json`:**

    * 可以知道项目中用了什么包
    * 基本的`package.json`文件：至少包含
      * 包名 name
      * 版本信息 version

  * **创建 `package.json`**

    * `npm init` : 初始化`package.json`文件
      * 运行后，如实回答基本信息
    * 主要字段含义：
      * name : 模块名，
      * version: 模块版本信息
      * description:关于模块功能简单描述，若为空，默认葱当前目录的`README.md`或者`README`读取第一行作为默认值
      * main : 模块被引入后，首先加载的文件，默认为`index.js`
      * scripts : 定义一些常用命令入口
    * npm 可以进行简单配置常用信息
      * `npm set init.author.email "2638779206@qq.com"`
      * `npm set init.author.name "zihao"` 
      * `npm set init.license "XDU"`

  * **安装模块**

    * `npm install` 会读取`package.json`以安装模块
      * 安装的模块分为两类: 生产环境需要的安装包`dependencies`.， 开发环境需要的安装包`devDependencies`
    * 在安装模块时，修改`package.json`
      * `npm install <packagename> --save`

  * **配置npm源：**

    * 配置国内镜像加快下载速度

    * 临时使用 

      * 通过`--registry`: `npm install express --registry https://registry.npm.taobao.org`

    * 全局使用：

      * ```bash
        config set registry https://registry.npm.taobao.org
          // 配置后可通过下面方式来验证是否成功
          npm config get registry
          // 或
          npm info express
        ```





* **git 的安装和准备**
  * ![image-20210416102902488](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416102902488.png)
* **Github账户的配置**
  * 使用了佛跳墙VPN，解决了加载Github慢的问题
  * 注册
  * 创建代码库
  * 代码库设置
    * `Setting`
    * `Pages`
    * `Automatic page generator`



# 安装 Hexo

* 创建`Hexo` 目录
* `gitbash` 该目录：
  * `npm install hexo-cli -g` ： 
    * hexo 本身是一个静态博客生成工具，具备编译markdown、凭借主题模板、生成HTML、上传Gti等基本功能，`hexo-cli`将这些功能封装为命令，提供给用户通过`hexo s`等命令调用的模块
    * problem:![image-20210416110241054](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416110241054.png)
    * solution ：[博客](https://blog.csdn.net/m0_46256147/article/details/104725439)
  * `npm install hexo --save`
    * problem :![image-20210416110617131](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416110617131.png)
    * solution [参考博客](![image-20210416110631231](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416110631231.png))
    * problem ![image-20210416110804200](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416110804200.png)
    * solution [参考](https://blog.csdn.net/JZevin/article/details/107865683)
    * problem ![image-20210416113337859](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416113337859.png)
    * solution : [参考](https://blog.csdn.net/weixin_42677762/article/details/112554832?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-0&spm=1001.2101.3001.4242)
  * `hexo -v` 检查是否安装好
    * ![image-20210416113525387](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416113525387.png)



# 相关配置

进行本地的配置

* **初始化 Hexo**

  * `hexo init`

    * problem : ![image-20210416113819617](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416113819617.png)

      * 该博客说接着上面的操作，但是上面的操作创建了json文件等，不是空的，是否可以直接在该目录下在创建一个新的文件？

    * problem : 创建新文件夹后：`hexo init`

      * ![image-20210416114034172](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416114034172.png)

        `fatal: unable to access 'https://github.com/hexojs/hexo-starter.git/': Failed to connect to github.com port 443: Timed out`

      * solution : [参考博客](https://blog.csdn.net/weixin_44041700/article/details/115599817)

        * 果真是网络的问题，再查查看完此博客后，再次输入`hexo init` 
        * ![image-20210416115639944](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416115639944.png)

      * 但是很慢

        * 可以切换npm源至淘宝源加速：
          * `npm install express --registry https://registry.npm.taobao.org`
        * 半分钟就好：
          * ![image-20210416121021641](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210416121021641.png)

  * `npm install`自动安装组件

    * 无报错

* **首次体验hexo**

  * `hexo g`：generate 生成网站静态文件至 public 文件夹
    * 便于查看网站生成的静态文件或者手动部署网站
  * `hexo s`：server 启动本地服务器，用于预览主题
    * 默认地址 : http://localhost:4000/
    * 预览的同时可以修改文章内容或主题代码，保存后刷新页面即可
    * 对 Hexo 根目录 `_config.yml` 的修改，需要重启本地服务器后才能预览效果
  * `hexo new"学习笔记 一" `
    * 新建标题为的文章
    * 文章标题可在对应的md文件改
  * `hexo d `deploy
    * 自动生成网站静态文件，并部署到设定的仓库
  * `hexo clean`
    * 清除缓存文件 `db.json` 和已生成的静态文件`public`

# 将 hexo 与 github page 联系起来

* **配置 git 个人信息**

  * 设置 GIT 的 user name 和 email

    * ```bash
      git config --global user.name "ZiHao256"
      git config --global user.email "2638779206@qq.com"
      ```

  * 生成密钥

    * ```bash
       ssh-keygen -t rsa -C "2638779206@qq.com"
      ```

      

* **配置 Deployment**

  * 在`_config.yml`文件中，找到Deployment：

    * ```bash
      deploy:
        type: git
        repo: git@github.com:ZiHao256/ZiHao256.github.io.git
        branch: master
      ```

# 写博客、发布文章

* 新建一篇博客

  * `hexo new post "title"`
  * 可在`source\_posts` 中看到`title.md`文件

* 新建好后，修改md文件

* 运行生成、部署文章：

  * 生成：`hexo g`

  * 部署：`hexo d`

    * problem 1 : 

      ![image-20210416124223198](E:\LearningNotes\Hexo\Hexo 博客.assets\image-20210416124223198.png)

    * solution : 未安装`hexo-deployer-git`插件，在**站点目录**(hexo init 目录)输入`npm install hexo-deployer-git --save`

    * [参考博客](https://blog.csdn.net/qq_21808961/article/details/84476504)

    * problem 2:

      ![image-20210416125451770](E:\LearningNotes\Hexo\Hexo 博客.assets\image-20210416125451770.png) solution:	`Please make sure you have the correct access rights and the repository exist`: 确保您具有正确的访问权限并且存储库存在

      原因：公钥出现问题

      [参考博客](https://blog.csdn.net/qq_43705131/article/details/107965888)

      1. 删除.ssh文件
      2. 重新设置用户名和邮箱
      3. 重新生成ssh公钥
      4. 配置github

  * 或直接在部署前生成：

    * `hexo d -g #在部署前先生成`

* 部署成功后，在`https://ZiHao256.github.io`看到生成的文章



# 主题推荐

* 主题配置文件在`_config.yml`

## NexT主题配置

* 简洁美观
* 支持不同风格
* 提供完善配置说明
* Hexo 两份主要配置文件：名称都是`_config.yml`
  * **站点配置文件**站点根目录下 ：Hexo 本身的配置
  * **主题配置文件**主题目录下 ：由主题作者提供，用于配置主题相关选项

### 1 安装NexT

* 只需要将主题文件拷贝至 `themes` 目录下，然后修改一下配置文件
* 若熟悉 git ，建议使用 克隆最新版本的方式，之后更新可以使用 `git pull` 快速更新
* 定位至Hexo 站点目录 `cd 至站点目录文件`
* 使用git checkout `git clone https://github.com/iissnan/hexo-theme-next themes/next`
  * **problem** : git clone 很慢
  * **solution**  : 使用国内镜像网站:`github.com.cnpnjs.org`
    * 将命令中的`github.com`换成这个
    * 效果拔群



### 2 启用主题

* 当 克隆/下载 至`themes`下后，打开 **站点配置文件**，找到 **theme** 字段，将其值改为**主题名**
* 验证是否启用成功之前，需要使用`hexo clean`清除缓存



### 3 验证主题

* 首先，`hexo g`生成静态文件
* 其次，启动 Hexo 本地站点，并开启调试模式(`--debug`)
  * `hexo s --debug`, 若有异常可从命令行输出，帮助debug
* 然后，`https://localhost:4000`，检查是否运行正常
* **problem:** ![image-20210416144717418](E:\LearningNotes\Hexo\Hexo 博客.assets\image-20210416144717418.png)
  * **solution** : ![image-20210416145430740](E:\LearningNotes\Hexo\Hexo 博客.assets\image-20210416145430740.png)
  * 1. 手动配置：文件名和配置文件都无问题
    2. 更新主题文件：

### 4 主题设定

* scheme : NexT 提供的一种特性，可提供多种外观
  * Muse - 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白 
  * Mist - Muse 的紧凑版本，整洁有序的单栏外观 
  * Pisces - 双栏 Scheme，小家碧玉似的清新



### 5 设置语言

* 编辑站点配置文件，将`language`字段设置成需要的语言：
  * `language: zh-Hans`



### 6 设置菜单

* **菜单配置**三个部分：**主题配置文件** 中 对应的字段`menu`

  * **菜单项：**名称和链接
    * `item name:link`
      * item name 是一个名称，不直接显示在页面，而是用于匹配图标和翻译
  * **菜单项的显示文本**
  * **菜单项对应的图标**
    * NexT 使用 `Font Awesome`提供的图标

* 示例：若站点在子目录中，去掉连接前的 `/`

  * ```
    menu:
      home: /
      archives: /archives
      #about: /about
      #categories: /categories
      tags: /tags
      #commonweal: /404.html
    ```

* **NexT 默认的菜单项：**

  * *键值*：**home**
    * *设定值*：home:/
    * *显示文本*：主页
  * **archives**
    * archives:/archives
    * 归档页
  * **categories**
    * categories:/categories
    * 分类页
  * **tags**
    * tags:/tags
    * 标签页
  * **about**
    * about:/about
    * 关于页
  * **commonweal**
    * commonweal:/404.html
    * 公益 404

* 设置菜单项的**显示文本：**

  * Hexo 生成的时候，使用**菜单项的名称**查找对应的语言翻译，并且提取显示文本
  * 显示文本在NexT 主题目录下的`language/{language}.yml`

* 设置菜单项的**图标**，对应的字段`menu_icons`

  * 设定格式`item name:icon name`

    * icon name是Font Awesome 图表的名字
    * enable 可用于是否显示图标

  * 示例

    * ```
      menu_icons:
        enable: true
        # Icon Mapping.
        home: home
        about: user
        categories: th
        tags: tags
        archives: archive
        commonweal: heartbeat
      
      ```

      

### 7 侧栏

* **默认情况**：侧栏仅在文章页面（拥有目录列表时）才显示，放于右侧

* 可通过控制 主题配置文件 `sidebar`字段控制侧栏

  * **侧栏的位置**，`sidebar.position`, 目前仅Pisces Scheme支持

    * left
    * right

  * **侧栏显示的时机**，`sidebar.display`

    * **post :** 默认行为，在文章页面（拥有目录列表）时显示

    * **always:** 在所有页面中都显示

    * **remove:** 完全移除

      

### 8 头像

* 编辑 站点配置文件， 新增`avatar`字段，将其值设置为头像的链接地址：
  * 完整的互联网URL：
  * 站点内的地址：`将头像放置主题目录下的 source/uploads/ （新建uploads目录若不存在） 配置为：avatar: /uploads/avatar.png 或者 放置在 source/images/ 目录下 , 配置为：avatar: /images/avatar.png`



# 分类

## 生成 分类 页并添加 type 属性

* `hexo new page categories`: 生成分类页
* 找到`source/categories/index.md`
  * 添加`type: "xxx"`

## 给文章添加 categories 属性

* 打开文章，写入`categories : -xxx`
* hexo 不会产生两个分类，**而是把分类嵌套**





# 标签

与分类类似





# 个人博客主题优化

[参考博客](https://www.jianshu.com/p/efbeddc5eb19)

[参考博客](https://zhuanlan.zhihu.com/p/60424755)

[cankao](https://itrhx.blog.csdn.net/article/details/85420403?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-2.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-2.control)

## 统计站点的总访问量

## 让百度收录 blog

## 底部小心心增加点击动画



博客1：

### 3.1 添加头像

### 3.2 设置头像边框为圆形

### 3.3 特效：鼠标放置头像上旋转

## 4 浏览页面时，显示当前浏览进度

## 5 侧边栏设置

### 5.1 设置侧边栏社交链接

### 5.2 设置侧边栏社交图标

### 5.3 RSS

配置

### 5.4 友情链接

## 6 主页文章添加边框阴影效果

## 7 修改文章间分割线

## 8 代码块自定义样式

## 9 开启版权声明

## 10 自定义文章底部版权声明

## 11 在右上角或者左上角实现`fork me on github`

## 12 修改文章底部带 # 号的标签

## 13 添加顶部加载条

## 14 

## 15 修改网页底部

### 1 修改桃心

## 16

## 23 新建404界面

## 32 修改打赏字体不闪动

## 39 添加网易云音乐

## 设置显示目录

## 统计字数



博客2

## 加宠物

## 网页底部的动态桃心图像



## 404 页面



# 访客数访问次数

https://blog.csdn.net/baidu_34310405/article/details/102665373

# 添加背景图片

https://tding.top/archives/761b6f4d.html

# 添加跳动的心

https://io-oi.me/tech/hexo-next-optimization/#%E8%AE%A9%E9%A1%B5%E8%84%9A%E7%9A%84%E5%BF%83%E8%B7%B3%E5%8A%A8%E8%B5%B7%E6%9D%A5

# 侧栏加入运行时间

https://io-oi.me/tech/hexo-next-optimization/#%E4%BE%A7%E6%A0%8F%E5%8A%A0%E5%85%A5%E5%B7%B2%E8%BF%90%E8%A1%8C%E7%9A%84%E6%97%B6%E9%97%B4



# 本地搜索

https://zhuanlan.zhihu.com/p/266119565

# 夜间模式切换‘

https://www.techgrow.cn/posts/abf4aee1.html