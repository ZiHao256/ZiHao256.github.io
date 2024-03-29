---
title: Django应用第二部分
categories: 
  - 学无止境
  - 开发框架学习
tags: 
  - Python
  - Django
description: 模型是真实数据的简单明确的描述。
abbrlink: 77fbe329
date: 2021-05-08
---
该部分将建立数据库，创建第一个模型module, 并主要关注Django提供的自动生成的管理页面

## 数据库配置

* `mysite/settings.py`: 包含了项目配置的python模块
* 一般，这个配置文件使用 `SQLite` 作为默认数据库

> **更换 数据库** ——[官方文档]([编写你的第一个 Django 应用，第 2 部分 | Django 文档 | Django (djangoproject.com)](https://docs.djangoproject.com/zh-hans/3.2/intro/tutorial02/))
>
> 如果你想使用其他数据库，你需要安装合适的 [database bindings](https://docs.djangoproject.com/zh-hans/3.2/topics/install/#database-installation) ，然后改变设置文件中 [`DATABASES`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-DATABASES) `'default'` 项目中的一些键值：
>
> * [`ENGINE`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-DATABASE-ENGINE) -- 可选值有 `'django.db.backends.sqlite3'`，`'django.db.backends.postgresql'`，`'django.db.backends.mysql'`，或 `'django.db.backends.oracle'`。其它 [可用后端](https://docs.djangoproject.com/zh-hans/3.2/ref/databases/#third-party-notes)。
> * [`NAME`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-NAME) -- 数据库的名称。如果你使用 SQLite，数据库将是你电脑上的一个文件，在这种情况下，[`NAME`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-NAME) 应该是此文件完整的绝对路径，包括文件名。默认值 `BASE_DIR / 'db.sqlite3'` 将把数据库文件储存在项目的根目录。
>
> 如果你不使用 SQLite，则必须添加一些额外设置，比如 [`USER`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-USER) 、 [`PASSWORD`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-PASSWORD) 、 [`HOST`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-HOST) 等等。想了解更多数据库设置方面的内容，请看文档：[`DATABASES`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-DATABASES) 。

* 在编辑 `settings.py`文件前，需要先设置 `TIME_ZONE`为自己的时区

  * [TIME_ZONE](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-TIME_ZONE)
  * 中国时区：`CN`
* `setting.py`头部 `INSTALLED_APPS`设置项：包括了会在项目中启动的所有应用

  * > 应用能在多个项目中使用，你也可以打包并且发布应用，让别人使用它们
    >
* `INSTALLED_APPS`默认包括了Django自带应用：

  * [`django.contrib.admin`](https://docs.djangoproject.com/zh-hans/3.2/ref/contrib/admin/#module-django.contrib.admin) -- **管理员站点**， 你很快就会使用它。
  * [`django.contrib.auth`](https://docs.djangoproject.com/zh-hans/3.2/topics/auth/#module-django.contrib.auth) -- **认证授权系统**。
  * [`django.contrib.contenttypes`](https://docs.djangoproject.com/zh-hans/3.2/ref/contrib/contenttypes/#module-django.contrib.contenttypes) -- **内容类型框架**。
  * [`django.contrib.sessions`](https://docs.djangoproject.com/zh-hans/3.2/topics/http/sessions/#module-django.contrib.sessions) -- **会话框架**。
  * [`django.contrib.messages`](https://docs.djangoproject.com/zh-hans/3.2/ref/contrib/messages/#module-django.contrib.messages) -- **消息框架**。
  * [`django.contrib.staticfiles`](https://docs.djangoproject.com/zh-hans/3.2/ref/contrib/staticfiles/#module-django.contrib.staticfiles) -- **管理静态文件的框架**。
* 默认开启的应用至少需要一个数据库表，因此需在使用他们之前，在数据库中创建一些表：

  * ```python
    py manage.py migrate
    ```
  * `migrate`命令:  检查 [`INSTALLED_APPS`](https://docs.djangoproject.com/zh-hans/3.2/ref/settings/#std:setting-INSTALLED_APPS) 设置，为其中的每个应用创建需要的数据表，至于具体会创建什么，这取决于 `mysite/settings.py` 设置文件和每个应用的**数据库迁移文件**

    * 该命令会将所**执行**的每个**迁移**操作在终端显示

## 创建模型

在Django中写一个数据库驱动的 Web 应用的**第一步**：==定义模型==——即**数据库结构设计和附加的其他元数据**

> 模型是真实数据的简单明确的描述
>
> 包含了存储的数据所必要的字段和行为

在该应用中，将建立两个模型：Question和Choice

* Question模型：包括两个字段：问题描述和发布时间
* Choice模型：有两个字段，选项描述和当前得票数。每个Choice属于一个问题

这些概念都可以通过 Python 类来描述：

编辑 `polls/models.py`:

```python
from django.db import models

class Question(models.Model):
    question_text = models.CharField(max_length=200)
    pub_date = models.DateTimeField('date published')


class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)
```

* 每个模型都被表示为 `django.db.models.Model`类的子类

  * 子类内有许多类变量：表示模型里的一个**数据库字段**
  * 每个字段都是 `Field`类的实例：将告诉Django每个字段要处理的数据类型
    * 字符字段：`CharField`
    * 日期时间字段：`DateTimeField`
    * 整型字段：`IntegerField`
    * 更多[`Field`](https://docs.djangoproject.com/zh-hans/3.2/ref/models/fields/#django.db.models.Field)
  * 每个Field类的实例名也是字段名
* 定义一些 Field 类实例 需要参数：

  * `CharField` 需要 `max_length`参数：用于定义数据库结构，也用于验证数据
* 注意，使用 `ForeignKey`定义关系

  * 这将告诉Django，每一个 Choice 对象都关联到一个 Question 对象

## 激活模型

* 创建模型的代码给予了 Django 许多信息：
  * 为应用创建数据库 schema：生成 `CTEATE TABLE`语句
  * 创建可以与Question和Choice对象 进行交互的**Python数据库API**

**首先**，将 polls 应用安装至Django项目中

* 为了工程中包含该应用，在 `settings.py`的 `INSTALLED_APPS` 中添加设置

  * `PollsConfig` 类 写在 `polls/apps.py`中，因此点式路径：`polls.apps.PollsConfig`
  * 在 `settings.py`的 `INSTALLED_APPS` 子项添加点式路径

    * ```python
      INSTALLED_APPS = [
          'polls.apps.PollsConfig',
          'django.contrib.admin',
          'django.contrib.auth',
          'django.contrib.contenttypes',
          'django.contrib.sessions',
          'django.contrib.messages',
          'django.contrib.staticfiles',
      ]
      ```

现在项目中包含了polls应用

**接着**，运行 `py manage.py makemigrations polls`

* **终端输出**：

  * ```
    Migrations for 'polls':
      polls/migrations/0001_initial.py
        - Create model Question
        - Create model Choice
    ```
* `makemigrations` : Django 检测对模型文件 `polls/models.py`的修改，并且将修改的部分**存储**为一次 **迁移**

  * **迁移**是 Django 对于**模型**定义（也就是你的数据库结构）的**变化的储存形式** - 它们其实也只是一些你磁盘上的文件
* [`migrate`](https://docs.djangoproject.com/zh-hans/3.2/ref/django-admin/#django-admin-migrate): 自动**执行数据库迁移** 并 **同步管理数据库结构**的命令。

  * 迁移命令执行的SQL语句：[`sqlmigrate`](https://docs.djangoproject.com/zh-hans/3.2/ref/django-admin/#django-admin-sqlmigrate)命令接收一个迁移的名称，然后返回对应的SQL
    * `py manage.py sqlmigrate polls 0001`
* 输出是迁移所对应的SQL语句

  * 表名是由应用名和模型名的小写形式连接而成
  * 主键被自动创建

**然后**，运行migrate命令，将在数据库里创建 新定义的模型的数据表：`py manage.py migrate`

* 该 migrate 命令会选中未执行过的迁移并应用在数据库中
* > 迁移是非常强大的功能，它能让你在开发过程中持续的改变数据库结构而不需要重新删除和创建表 - 它专注于使数据库平滑升级而不会丢失数据
  >
* 注意：改变模型需要三步：

  * 编辑 models 文件，改变模型
  * 运行 `makemigrations` 命令生成迁移
  * 运行 migrate 命令 应用迁移

## 初试 API

**首先**，进入 交互式 Python 命令行，以使用Django创建的各种 API

* `py manage.py shell`
  * manage 会设置 `DJANGO_SETTINGS_MODULE` 环境变量，根据 `settings`文件设置包的导入路径

**然后**，尝试 [数据库 API](https://docs.djangoproject.com/zh-hans/3.2/topics/db/queries/)

* ```
  from polls.models import Choice, Question  # Import the model classes we just wrote.
  from django.utils import timezone
  q = Question(question_text="What's new?", pub_date=timezone.now())
  q.save()
  ```
* 编辑模型代码，可以更了解模型对象的细节：给模型增加 `__str__()`方法

  * ```
    from django.db import models

    class Question(models.Model):
        # ...
        def __str__(self):
            return self.question_text

    class Choice(models.Model):
        # ...
        def __str__(self):
            return self.choice_text
    ```
* ```
  Question.objects.filter(id=1)
  q = Question.objects.get(pk=1)
  q.choice_set.all()
  q.choice_set.create(choice_text='Not much', votes=0)
  ```

## Django 管理页面

> 为你的员工或客户生成一个用户添加，修改和删除内容的后台是一项缺乏创造性和乏味的工作。因此，Django 全自动地根据模型创建后台界面。

管理页面默认开启

### 创建管理员账号

* `py manage.py createsuperuser`

### 启动开发服务器

* `py manage.py runserver`
* 访问：`http://127.0.0.1:8000/admin/`

### 管理站点页面

* 进入管理页面的索引页后，可编辑的 `Groups`和 `Users` 是Django 开发的认证框架

### 向管理页面加入投票应用

* 需要在管理文件 `polls/admin.py`加入应用的模型

  * ```
    from django.contrib import admin

    from .models import Question

    admin.site.register(Question)
    ```
