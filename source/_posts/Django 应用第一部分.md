---
title: Django 应用第一部分
categories: 
  - 个人提升
  - 开发框架学习
tags: 
  - Python
  - Django
description: Django 最初被设计用于具有快速开发需求的新闻类站点，目的是要实现简单快捷的网站开发
abbrlink: 497f9043
date: 2021-05-07
---
# 编写第一个 Django 应用，第一部分

[官方文档]([初识 Django | Django 文档 | Django (djangoproject.com)](https://docs.djangoproject.com/zh-hans/3.2/intro/overview/))

* 目标：创建一个基本的投票应用

  * 让人们 查看和投票 的**公共站点**
  * 让开发者能 添加、修改、删除投票的**管理站点**
* 环境：

  * `pycharm 2019`
  * `python 3.6`
  * `Django 3.2.1`支持Python 和后续版本

## 创建项目

* 初始化设置：

  * 生成Django项目需要的 设置项集合：数据库配置、Django 配置和应用程序配置

  ```
  django-admin startproject mysite(项目名)
  ```

  * 需要注意的是，须提前将django-admin加入环境变量，因为使用的是 `Pycharm Professional` 所以可以一键创建Django项目
* `startproject` 所创建的：

  * ![image-20210507200938455](E:\LearningNotes\python\编写第一个 Django 应用，第一部分.assets\image-20210507200938455-1620389380924.png)
* 根据官方文档：

  * 最外层 `mysite`：是我们项目的容器
  * `manage.py`: 可以让我们用各种方式管理项目的命令行工具
  * 内层 `mysite`：是一个纯Python包。当需要引用其内部的内容时的包名
  * `mysite/__init__.py`: 空文件，告知Python这个目录是一个Python包
  * `mysite/settings.py`: Django 项目的配置文件
  * `mysite/urls.py`: 项目的 URL 声明，类似于网站的目录
  * `mysite/asgi.py`: 作为你的项目的运行在 ASGI 兼容的 Web 服务器上的入口
  * `mysite/wsgi.py`: 作为你的项目的运行在 WSGI 兼容的Web服务器上的入口

## 用于开发的简易服务器

* 测试项目是否创建成功：在项目容器目录运行 `py manage.py runserver`
* 出现报错：

  * ```
    Traceback (most recent call last):
      File "manage.py", line 22, in <module>
        main()
      File "manage.py", line 18, in main
        execute_from_command_line(sys.argv)
      File "E:\Django_tests\mysite\venv\lib\site-packages\django\core\management\__init__.py", line 419,
     in execute_from_command_line
        utility.execute()
      File "E:\Django_tests\mysite\venv\lib\site-packages\django\core\management\__init__.py", line 363,
     in execute
        settings.INSTALLED_APPS
      File "E:\Django_tests\mysite\venv\lib\site-packages\django\conf\__init__.py", line 82, in __getatt
    r__
        self._setup(name)
      File "E:\Django_tests\mysite\venv\lib\site-packages\django\conf\__init__.py", line 69, in _setup
        self._wrapped = Settings(settings_module)
      File "E:\Django_tests\mysite\venv\lib\site-packages\django\conf\__init__.py", line 170, in __init_
    _
        mod = importlib.import_module(self.SETTINGS_MODULE)
      File "C:\Users\Light\AppData\Local\Programs\Python\Python36\lib\importlib\__init__.py", line 126,
    in import_module
        return _bootstrap._gcd_import(name[level:], package, level)
      File "<frozen importlib._bootstrap>", line 994, in _gcd_import
      File "<frozen importlib._bootstrap>", line 971, in _find_and_load
      File "<frozen importlib._bootstrap>", line 955, in _find_and_load_unlocked
      File "<frozen importlib._bootstrap>", line 665, in _load_unlocked
      File "<frozen importlib._bootstrap_external>", line 678, in exec_module
      File "<frozen importlib._bootstrap>", line 219, in _call_with_frames_removed
      File "E:\Django_tests\mysite\mysite\settings.py", line 57, in <module>
        'DIRS': [os.path.join(BASE_DIR, 'templates')]
    NameError: name 'os' is not defined

    ```
  * 分析：`xxxx\settings.py` `os not defined`, 可能是该文件未导入os模块导入后成功
  * solution：导入后成功

    * ```
      Watching for file changes with StatReloader
      Performing system checks...

      System check identified no issues (0 silenced).

      You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
      Run 'python manage.py migrate' to apply them.
      May 07, 2021 - 20:20:20
      Django version 3.2.2, using settings 'mysite.settings'
      Starting development server at http://127.0.0.1:8000/
      Quit the server with CTRL-BREAK.
      ```
* 至此，我们启动了Django自带的 **用于开发的简易服务器**

  * 用纯python写的轻量级Web服务器
  * 注意：

    * > **千万不要** 将这个服务器用于和生产环境相关的任何地方。这个服务器只是为了开发而设计的。(我们在 Web 框架方面是专家，在 Web 服务器方面并不是。)
      >
* 更换端口：

  * 默认runserver命令会将服务器设置为监听本机内部 IP 的8000端口
  * 若想更换端口：
    * `py manage.py runserver 8080`
  * 若想修改服务器监听的 IP：
    * `py manage.py runserver 0:8080`

## 创建投票应用

* 开发环境——项目配置初始化成功
* > Django 中，每一个应用都是一个Python包
  >
* > **项目 VS 应用**
  >
  > 项目和应用有什么区别？
  >
  > **应用**是一个专门做某件事的**网络应用程序**——比如博客系统，或者公共记录的数据库，或者小型的投票程序。
  >
  > **项目**则是**一个网站使用的配置和应用的集合**。项目可以包含很多个应用。应用可以被很多个项目使用。
  >
* 应用可以存放任何Python路径中定义的路径
* 在此项目，须在 `manage.py`同级目录下创建应用

  * 可以作为顶级模块导入，而不是mysite的子模块
* 创建应用：

  * ```
    py manage.py startapp polls
    ```
* 命令会创建polls目录：包含了应用的全部内容

  * ![image-20210507203223797](E:\LearningNotes\python\编写第一个 Django 应用，第一部分.assets\image-20210507203223797-1620390751727.png)

## 编写第一个视图

首先：

* 在 `polls/views.py`：

  * ```python
    from django.http import HttpResponse


    def index(request):
        return HttpResponse("Hello, world. You're at the polls index.")
    ```

  其次：
* 需要将一个 `URL` 映射到它

  * 因此需要 `URLconf`
* 在polls目录里创建 `urls.py`文件，并输入：

  * ```python
    from django.urls import path

    from . import views

    urlpatterns = [
        path('', views.index, name='index'),
    ]
    ```

然后：

* 在根 `URLconf`文件中，指定刚刚创建的 `polls.urls`模块

  * 在 `mysite/urls.py`中的 `urlpatterns`列表中插入 `include()`
  * ```python
    from django.contrib import admin
    from django.urls import include, path

    urlpatterns = [
        path('polls/', include('polls.urls')),
        path('admin/', admin.site.urls),
    ]
    ```
* 函数 include 允许引用其他 `URLconfs`, 当包括其他 `URL`模式时，就使用该函数

  * 当 Django 遇到该函数时，会截断与此项匹配的 URL 部分，将剩余的字符串发送到 `URLconf`一共进一步处理
  * > 我们设计 [`include()`](https://docs.djangoproject.com/zh-hans/3.2/ref/urls/#django.urls.include) 的理念是使其可以即插即用。因为投票应用有它自己的 URLconf( `polls/urls.py` )，他们能够被放在 "/polls/" ， "/fun_polls/" ，"/content/polls/"，或者其他任何路径下，这个应用都能够正常工作。
    >
* 现在已经将index视图 天加入了根URLconf

最后，

* 验证是否能正常工作：`py manage.py runserver`
* 访问：`http://localhost:8000/polls/ `

  * 成功

## 函数path（）

函数的四个参数：

* 必须参数：`route` `view`
* 可选参数：`kwargs` `name`
* `route`: 一个匹配 URL 的准则（类似于正则表达式）

  * > 当 Django 响应一个**请求request**时，它会从 `urlpatterns` 的第一项开始，按顺序依次匹配列表中的项，直到找到匹配的项。
    >
  * > 这些准则不会匹配 GET 和 POST 参数或域名。例如，URLconf 在处理请求 `https://www.example.com/myapp/` 时，它会尝试匹配 `myapp/` 。处理请求 `https://www.example.com/myapp/?page=3` 时，也只会尝试匹配 `myapp/`。
    >
* `view`: 当Django 找到一个匹配的准则，会调用这个特定的视图函数，并传入一个 `HttpRequest`对象作为第一个参数

  * 被“捕获”的参数以**关键字参数**的形式传入
* `kwargs`: 任意关键字参数 可以作为一个字典传递给目标视图函数，本此项目不会使用
* `name`:

  * > 为 URL 取名能使你在 Django 的**任意地方唯一地引用**它，尤其是在模板中。这个有用的特性允许你只改一个文件就能全局地修改某个 URL 模式。
    >
