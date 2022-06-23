---
title: SQL
categories: '-分布式数据库'
tags: '-SQL'
abbrlink: 4d712855
---



# SQL

[toc]

* 什么是 `SQL `
  * 访问和处理 **关系数据库 **的 **计算机标准语言**
* 编写程序时，只要涉及 **操作关系数据库**，就必须通过 SQL 完成



* `NoSQL`: 非SQL的数据库，都不是关系数据库



# 1 关系数据库概述

* 为什么需要数据库

  * 应用程序 需要保存用户的数据
  * 随着应用程序功能越来越复杂，数据量也越来越大
    * 读写文件并解析出数据，需要大量重复代码
    * 从大量数据中 快速查询出 指定数据，需要复杂的逻辑
  * 每个应用程序**访问数据的接口**不同，数据难以复用

* **数据库**：专门**管理数据**的软件

  * 应用程序通过数据库软件提供的接口来读写数据

  * 数据库软件来管理数据如何存储进文件

  * ```ascii
     ──────────────┐
    │ application  │
    └──────────────┘
           ▲│
           ││
       read││write
           ││
           │▼
    ┌──────────────┐
    │   database   │
    └──────────────┘
    ```

## 数据模型

* 数据库按照 **数据结构** 来**组织、存储和管理数据**，三种模型

  * 层次模型
  * 网状模型
  * 关系模型

* **层次模型：**上下级的层次关系 来组织数据

  * ```ascii
        		┌─────┐
                │     │
                └─────┘
                   │
           ┌───────┴───────┐
           │               │
        ┌─────┐         ┌─────┐
        │     │         │     │
        └─────┘         └─────┘
           │               │
       ┌───┴───┐       ┌───┴───┐
       │       │       │       │
    ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
    │     │ │     │ │     │ │     │
    └─────┘ └─────┘ └─────┘ └─────┘
    ```

* **网状模型：**把每个数据节点和其他很多节点都连接起来

  * ```ascii
         ┌─────┐      ┌─────┐
       ┌─│     │──────│     │──┐
       │ └─────┘      └─────┘  │
       │    │            │     │
       │    └──────┬─────┘     │
       │           │           │
    ┌─────┐     ┌─────┐     ┌─────┐
    │     │─────│     │─────│     │
    └─────┘     └─────┘     └─────┘
       │           │           │
       │     ┌─────┴─────┐     │
       │     │           │     │
       │  ┌─────┐     ┌─────┐  │
       └──│     │─────│     │──┘
          └─────┘     └─────┘
    ```

* **关系模型：**将数据当作二维表格，任何数据通过 行号+列号 唯一确定

  * ```ascii
    ┌─────┬─────┬─────┬─────┬─────┐
    │     │     │     │     │     │
    ├─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │
    ├─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │
    ├─────┼─────┼─────┼─────┼─────┤
    │     │     │     │     │     │
    └─────┴─────┴─────┴─────┴─────┘
    ```

* 关系模型获得了绝对市场份额
  * 理解和使用起来最简单
  * 关系数据库 的 关系模型：基于数学理论建立
* 简而言之，通过给定一个班级名称，可以查到一条班级记录，根据班级ID，又可以查到多条学生记录，这样，二维表之间就通过ID映射建立了 **“一对多”** 关系。

## 数据类型

* 一个**关系表：**

  * 须定义 **每一列的名称**和**每一列的数据类型**

  * 关系数据库支持的标准数据类型：数值、字符串、时间等：

    * | 名称         | 类型           | 说明                                                         |
      | :----------- | :------------- | :----------------------------------------------------------- |
      | INT          | 整型           | 4字节整数类型，范围约+/-21亿                                 |
      | BIGINT       | 长整型         | 8字节整数类型，范围约+/-922亿亿                              |
      | REAL         | 浮点型         | 4字节浮点数，范围约+/-1038                                   |
      | DOUBLE       | 浮点型         | 8字节浮点数，范围约+/-10308                                  |
      | DECIMAL(M,N) | 高精度小数     | 由用户指定精度的小数，例如，DECIMAL(20,10)表示一共20位，其中小数10位，通常用于财务计算 |
      | CHAR(N)      | 定长字符串     | 存储指定长度的字符串，例如，CHAR(100)总是存储100个字符的字符串 |
      | VARCHAR(N)   | 变长字符串     | 存储可变长度的字符串，例如，VARCHAR(100)可以存储0~100个字符的字符串 |
      | BOOLEAN      | 布尔类型       | 存储True或者False                                            |
      | DATE         | 日期类型       | 存储日期，例如，2018-06-22                                   |
      | TIME         | 时间类型       | 存储时间，例如，12:20:59                                     |
      | DATETIME     | 日期和时间类型 | 存储日期+时间，例如，2018-06-22 12:20:59                     |

* 许多数据类型有别名：
  
  * 例如`REAL` : `FLOAT(24)`
* 需要根据业务规则 选择合适的类型：
  * `BIGINT` : 满足整数存储的需求
  * `VARCHAR(N)` ：满足字符串存储的需求



## 主流关系数据库

* **主流的关系数据库**：
  * 商用数据库：
    * `Oracle`, `SQL Server`, `DB2`
  * 开源数据库：
    * `MySQL`, `PostgreSQL`
  * 桌面数据库：
    * `Access` ，适合桌面应用程序使用
  * 嵌入式数据库：
    * `Sqlite`, 适合手机应用 和桌面程序



## SQL

* **结构化查询语言** ：用来访问和操作 **数据库系统**
  * 可以 **查询、添加、更新、和删除数据库中的数据**
  * 可以 **对数据库进行管理和维护操作**

* 不同的数据库 都支持 SQL
* 不同的数据库 对 标准的SQL支持 不太一致
  * 大部分数据库在标准的SQL做了**扩展**
* 只使用ANSI 组织定义的标准SQL，所有数据库都可以支持



* SQL 定义的对 数据库 的操作：
  * `DDL` : **Data Definition Language**
    * 用户自定义数据：创建表、删除表、修改表结构等操作
    * DDL 通常由数据库管理员执行
  * `DML` : **Data Manipulation Language**
    * 用户添加、删除、更新数据的能力
    * 应用程序对数据库的日常操作
  * `DQL` : **Data Query Language**
    * 用户查询数据，最频繁



## 语法特点

* 关键字不区分大小写
* 对于表明和列名：有的数据库区分大小写
* 同一个数据库：不同操作系统大小写不同
* 约定：SQL 关键字总是大写，表名和列名均使用小写



# 2 安装 MySQL

* MySQL **应用最广泛的 开源关系数据库**
* 与其他关系数据库不同：MySQL 本身实际上是一个**SQL 接口**，内部包含**多种数据库引擎**
  * `InnoDB` :  **支持事务的数据库引擎**
  * `MyISAM` : MySQL 早期集成的默认数据库引擎，**不支持事务**

* 切换 **MySQL 引擎**不影响自己写的应用程序使用 **MySQL 接口**
* 使用 MySQL 时，不同的表可以使用不同的**数据库引擎**
  * 总是选择`InnoDB` 就好
* MySQL 一开始便是**开源**的，基于此，衍生出各种版本：
  * `MariaDB`
    * MySQL 创始人创建的开源分支版本，使用`XtraDB` 引擎
  * `Aurora`
    * 由Amazon改进的一个MySQL版本，专门提供给在`AWS`托管`MySQL`用户，号称5倍的性能提升。
  * `PolarDB`
    * 由`Alibaba`改进的一个MySQL版本，专门提供给在[阿里云](https://promotion.aliyun.com/ntms/yunparter/invite.html?userCode=cz36baxa)托管的MySQL用户，号称6倍的性能提升。

* MySQL 官方版本分出的版本：功能依次递增，增加的主要功能：监控和集群等管理功能，对基本的SQL功能一样
  * `Community Edition` : 社区开源版本，免费
  * `Standard Edition` : 标准版
  * `Enterprise Edition` : 企业版
  * `Cluster Carrier Grade Edition` : 集群版
* 可以安装免费的`Community Edition` ，进行学习、开发、测试
  * 部署的时候，选择高级版本，或者云服务商提供的兼容版本



## 安装MySQL

* 安装过程中，MySQL 自动创建一个`root` 用户，并提示输入`root`口令
* 账号：`ZiHaO`
  * 密码 : `qazedc12 `



## 运行 MySQL

* MySQL 安装后自动在后台运行



* 下载安装后，需要配置环境变量
  * 通过`任务管理器`找到 `mysql.exe` 查看属性，找到`bin`目录
  * 将路径加入环境变量



* 通过命令行程序连接 MySQL服务器，命令提示符下输入`mysql -u root -p`, 输入口令，
  * 若连接到 MySQL 服务器，提示符变成 `mysql>`

* 输入`exit` 退出 MySQL 命令行
* MySQL 服务器依然在后台运行



# 3 关系模型

* 关系数据库 建立在关系模型上
* 关系模型本质：若干个存储数据的二维表
  * 表的每一行：`记录Record`, 一个逻辑意义上的数据
  * 表的每一列：`字段Column`，同一个表的每一行**记录**，拥有相同的若干**字段**

* **字段**：定义数据类型（整型，浮点型，字符串，日期等），以及是否允许`NULL`
  * `NULL` 表示字段数据**不存在**，为空，而非为数据类型的零值

* 一般情况，应避免允许数据为`NULL` , 可以简化查询条件，加快查询速度，有利于应用程序读取数据后无需判断是否为`NULL`



* 和Excel表不同：关系数据库的表和表之间 需要建立 `一对多`，`多对一`和`一对一`的关系
  * 才能按照 **应用程序的逻辑** 来组织和存储数据



* **一对多：**
  * 一个表中的一个记录，对应着另一个表中多个记录
* **多对一：**
  * 一个表中的多个记录，对应着另一个表中一个记录
* **一对一：**
  * 一个表中的一个记录，对应着另一个表中一个记录

* **关系数据库**中，关系 是 通过 `主键` 和 `外键` 来维护



## 主键

* **关系数据库中**：
  * 一张表的每一行数据：**一条记录**
  * 一条记录**由多个字段组成**
  * 同一个表中每一条记录都有相同的字段定义

* **关系数据库中**，很重要的约束：任意两条记录不能重复
  * 不是指 两条记录不完全相同
  * 指 能通过某个字段，**唯一区分出不同的记录**，该字段为 **主键**
  * 因此，同一张表中 任意两条记录的 主键字段 的值都不相同
* **对主键的要求**：记录一旦插入表中，主键最好不要修改，唯一定位记录的
* **选取业务的基本原则：**不使用任何**业务相关**的字段作为主键
  * 身份证号、手机号、邮箱地址等



* 一般将主键字段命名为 `id`。常见的`id`字段的类型
  * 自增整数类型：数据库 会在插入数据时 自动 为每一条记录分配一个自增整数，不需要担心主键重复，不用预先生成主键
  * 全局唯一`GUID` 类型：使用一种 全局唯一 的字符串作为主键，``
    * `GUID` 算法通过 网卡MAC地址、时间戳、随机数 保证任意计算机在任意时间生成的字符串不同，大部分编程语言都内置了`GUID`算法，预算出主键

* 一般，通常 自增类型 的主键就能满足需求



* 注意： 如果使用`INT`自增类型，那么当一张表的记录数超过2147483647（约21亿）时，会达到上限而出错。使用`BIGINT`自增类型则可以最多约922亿亿条记录。



### 联合主键

* **联合主键**：关系数据库，允许通过多个字段 唯一标识记录，即多个字段都设置为主键
  * 允许一列有重复，只要不是所有主键列都重复即可

* 联合主键要求 任意两条记录 的主键组合都不相同
* 尽量不使用 联合主键，给关系表带来了 **复杂度的上升**



## 一对多

* **主键** 唯一标识记录时，可以在表中确定任意记录

* 确定`student` 表的一条记录，属于哪个班级

  * 在`student` 表中，添加字段`class_id` ，使得其与`class` 表的某条记录对应

* **外键：**在一张表中，通过`xx_id`字段，将**该表数据 与 另一张表关联起来的字段**

* **外键** 通过定义 **外键约束** 实现

  * ```mysql
    ALTER TABLE students
    ADD CONSTRAINT fk_class_id
    FOREIGN KEY (class_id)
    REFERENCES classes (id);
    ```

  * `ADD CONSTRAINT fk_class_id`：**外键约束名称**，可以任意
  * `FOREIGN KEY (class_id)` : 指定`class_id` 为外键
  * `REFERENCES classes (id)`: 指定这个外键 将关联到`classes` 表的 `id` 列（即`classes` 的主键

* 通过**定义 外键约束**，**关系数据库可以保证 无法穿插如无效的数据**：
  * 即外键所绑定的另一张表的主键数据，约束着外键的数据范围



* **外键约束** 会降低数据库的性能，为了追求速度，并不设置外键约束，仅依靠应用程序自身来保证 逻辑的正确性
  * 这种情况下，外键仅是一个普通的列



* 要**删除一个 外键约束**，通过`ALTER TABLE`

  * ```mysql
    ALTER TABLE students
    DROP FOREIGN KEY fk_class_id;
    ```

* 注意：删除 外键约束 并没有删除外键这一列
  * 删除列通过：`DROP COLUMN ,..` 实现



## 多对多

* 通过一个表的 外键 关联到另一个表，可以定义出 一对多 关系
* 定义**多对多关系**：
  * 通过 两个一对多关系 实现：即通过**一个中间表**，**关联两个一对多关系**，就形成了多对多关系

* 示例：

  * `teachers`表：

    | id   | name   |
    | :--- | :----- |
    | 1    | 张老师 |
    | 2    | 王老师 |
    | 3    | 李老师 |
    | 4    | 赵老师 |

  * `classes`表：

    | id   | name |
    | :--- | :--- |
    | 1    | 一班 |
    | 2    | 二班 |

  * 中间表`teacher_class`关联两个一对多关系：

    | id   | teacher_id | class_id |
    | :--- | :--------- | :------- |
    | 1    | 1          | 1        |
    | 2    | 1          | 2        |
    | 3    | 2          | 1        |
    | 4    | 2          | 2        |
    | 5    | 3          | 1        |
    | 6    | 4          | 2        |

* 通过`teacher_class` 表，可知`teachers` 到`classes` 的关系 和 `classes` 到 `teachers` 的关系

## 一对一

* **一对一关系**：一个表的记录 对应到另一个表 的唯一一个记录
* 既然是 一对一关系 为什么不直接合并为同一个表
  * 如果业务允许，可以将两个表合并
    * 但若某些数据是缺失，就不存在对应的记录
    * 只能说 子集表 一一对应 另一个表
  * 将大表 **拆分成**两个 一对一 的表：把经常读取和不经常读取的字段分开，**获得高性能**



## 索引

* 在 **关系数据库** 中，若有上万上亿条记录，需要使用**索引**，才能获得高速度

* 索引：关系数据库 中，对某一列或多个列的值 **进行预排序的 数据结构**

  * 使用索引，可以让数据库系统不必扫描整个表，而是**直接定位到符合条件的记录**

* 示例：

  * `students` 表

  * | id   | class_id | name | gender | score |
    | :--- | :------- | :--- | :----- | :---- |
    | 1    | 1        | 小明 | M      | 90    |
    | 2    | 1        | 小红 | F      | 95    |
    | 3    | 1        | 小军 | M      | 88    |

  * 更具`score`列进行查询，对`score`列创建索引：

  * ```mysql
    ALTER TABLE students
    ADD INDEX idx_score (score);
    ```

  * 使用`ADD INDEX idx_score (score)` : 创建一个名称为`idx_score` ，使用列`score` 的索引

    * 索引名称任意，若索引有很多列，在括号里 依次写上：

      * ```
        ALTER TABLE students
        ADD INDEX idx_name_score (name, score);
        ```

* **索引的效率** 取决于 索引列的表 是否散列，即 该列的值互不相同的程度越高，索引效率越高
* 可以对一张表 创建多个索引
  * 索引的优点：提高查询效率
  * 索引的缺点：插入、更新、删除记录时，同时修改索引
    * 因此，索引越多，插入、删除、更新记录的速度越慢



* 对于主键，**关系数据库** 会自动对其创建**主键索引**
  * 使用 主键索引的效率最高，因为主键会保证 绝对唯一



### 唯一索引

* 设计关系数据库的表时，看上去唯一的列，通常具有业务含义，不能作为主键

  * 身份证号

* 这些列根据业务要求，又**具有唯一性约束**：任意两条记录的该字段不能相同

  * 此时，可以为该列添加一个唯一索引

* 例如，假设`students` 表的 `name` 不能重复

  * ```mysql
    ALTER TABLE students
    ADD UNIQUE INDEX uni_name (name);
    ```

* 通过关键字`UNIQUE` 添加了唯一索引

* 也可以只对某一列添加一个 **唯一约束**，而不创建 **唯一索引**：

  * ```mysql
    ALTER TABLE students
    ADD CONSTRAINT uni_name UNIQUE (name);
    ```

  * 此时，`name` 列没有索引，但具有唯一性保证

* 无论是否创建索引，对于用户和应用程序来说，使用关系数据库不会有任何区别

  * 即，当我们在数据库中查询时，如果有相应的索引可用，**数据库系统就会自动使用索引来提高查询效率**，如果没有索引，查询也能正常执行，只是速度会变慢。
  * 因此，索引可以在使用数据库的过程中逐步优化



# 4 在线 SQL

* 便于在线练习，提供的在线运行 SQL 的功能
* 在浏览器页面 运行 的一个`JS` 编写的内存型SQL数据库 `AlaSQL` 
  * 不必运行 MySQL 等实际的数据库软件，即可在线编写并执行 SQL 语句



# 5 查询数据

* 对数据库 最常用的操作



## 准备数据

* 事先准备`students` 和 `classes` 表

  * `students`表存储了学生信息：

    | id   | class_id | name | gender | score |
    | :--- | :------- | :--- | :----- | :---- |
    | 1    | 1        | 小明 | M      | 90    |
    | 2    | 1        | 小红 | F      | 95    |
    | 3    | 1        | 小军 | M      | 88    |
    | 4    | 1        | 小米 | F      | 73    |
    | 5    | 2        | 小白 | F      | 81    |
    | 6    | 2        | 小兵 | M      | 55    |
    | 7    | 2        | 小林 | M      | 85    |
    | 8    | 3        | 小新 | F      | 91    |
    | 9    | 3        | 小王 | M      | 89    |
    | 10   | 3        | 小丽 | F      | 85    |

  * `classes`表存储了班级信息：

    | id   | name |
    | :--- | :--- |
    | 1    | 一班 |
    | 2    | 二班 |
    | 3    | 三班 |
    | 4    | 四班 |

## MySQL

* `AlaSQL` 是**内存数据库**，和`MySQL` 的**持久化存储**不同，内存数据库的表数据在页面加载时导入，并且只存在于浏览器的内存

* 用 MySQL 练习：
  * 下载[SQL脚本](https://github.com/michaelliao/learn-sql/blob/master/mysql/init-test-data.sql)
  * 在命令行运行：`$ mysql -u root -p < init-test-data.sql`
* 自动创建`test` 数据库，并且在`test` 数据库下，创建`students` 和 `classes` 表，并进行必要的初始化数据
* 对 MySQL 数据库的修改都会保存，若希望恢复到初始状态：再次运行：`$ mysql -u root -p < init-test-data.sql`





* **problem**：`ERROR 1366 (HY000)`
  * solution：对于`Win10`，只要将脚本用`GBK` 格式重新保存，再用` CMD` 调用即可

* `mysql workbench` , MySQL 的桌面集成环境, 可视化MySQL数据库软件



## 基本查询

* 查看已存在的 数据库：`mysql> show databases;`
* 切换数据库：`use test;`



* 查询 数据库表 中的数据：
  * `SELECT * FROM <表名>` ：查询该表的所有数据

* `SELECT * FROM students`
  * `SELECT` 关键字：执行一个查询
  * `*` ：所有列
  * `FROM` ：从哪个表查询



* 可以使用`SELECT` 语句计算，但不是 SQL 的强项
* `SELECT` : 判断当前到数据库的连接是否有效
  * `SELECT 1;`



## 条件查询

* SELECT 关键字 可以通过 `WHERE` 条件来设定查询条件，查询结果 是满足 查询条件的记录
  * 语法：`SELECT * FROM <表名> WHERE 条件表达式`
  * 例如`SELECT * FROM students WHERE score>=80;`
  * WHERE 关键字后的为条件

### 三个条件表达式

* 条件表达式可以用 `<条件1> AND <条件2>` : 满足两个条件
  * 例如判断 即大于80又是男生：
    * `WHERE score>=80 AND gender='M'`
    * 字符串用 单引号括起来

* 条件表达式可以用`<条件1> AND <条件2>`：满足两者之一

* 条件表达式可以用`NOT <条件>`：不符合该条件的记录
  * 例如：不是二班的
  * `WHERE NOT class_id = 2`

* `NOT class_id=2` 等价于 `class_id <> 2`
  * `NOT` 查询不常用
* 组合三个以上的条件：用小括号`()` 来说明如何条件运算



### 常用的条件表达式

| 条件                 | 表达式举例1     | 表达式举例2      | 说明                                              |
| :------------------- | :-------------- | :--------------- | :------------------------------------------------ |
| 使用=判断相等        | score = 80      | name = 'abc'     | 字符串需要用单引号括起来                          |
| 使用>判断大于        | score > 80      | name > 'abc'     | 字符串比较根据ASCII码，中文字符比较根据数据库设置 |
| 使用>=判断大于或相等 | score >= 80     | name >= 'abc'    |                                                   |
| 使用<判断小于        | score < 80      | name <= 'abc'    |                                                   |
| 使用<=判断小于或相等 | score <= 80     | name <= 'abc'    |                                                   |
| **使用<>判断不相等** | score <> 80     | name <> 'abc'    |                                                   |
| **使用LIKE判断相似** | name LIKE 'ab%' | name LIKE '%bc%' | %表示任意字符，例如'ab%'将匹配'ab'，'abc'，'abcd' |



## 投影查询

* `SELECT * FROM <表名>` : 返回的二维表和原表一样
  * `*` ：查询所有列
* `SELECT 列1，列2 FROM ...` : 仅包含指定列，成为投影查询



* 这样返回的结果集 只包含了指定的列，并且 结果集 的列的是顺序可以和原表不一样

* `SELECT 列1 别名1，列2 别名2 FROM ...` : 为指定列起别名



* 投影查询 同样可以使用 `WHERE` 关键字：
  * 语法：`SELECT 列1，列2 FROM <表名> WHERE ..`



## 排序

* 使用  关键字`SELECT` 时，查询的结果通常按照`id` 排序，即根据 主键 排序
* 使用 关键字`ORDER BY 列名 (ASC)` : 根据其他条件正序, `ASC` 可以省略
  * 例如：按照成绩从低到高：
  * `SELECT id,name,score FROM students ORDER BY score`
* 可以给`ORDER BY` 加上关键字`DESC` 表示倒序：从高到低排序
  * 例如：`SELECT id,name,score FROM students ORDER BY score DESC`

* 在`ORDER BY` 关键字后添加 列名 ：先按照，再按照下一列排序
  * l例如：先按照分数倒序，再按照gender正序
  * `ORDER BY score DESC,gender`



* 若有条件`WHERE` , 需将`ORDER BY` 语句放于 `WHERE` 后
  * 例如 查询一班的成绩，并按照倒序
  * `SELECT * FROM students WHERE class_id = 1 ORDER BY score DESC;`
  * 这样的话，先筛选满足`WHERE` 条件的记录，再排序



## 分页查询

* 使用`SELECT` 查询时，若结果集 很大，需要分页显示，每次显示 100 条
* 分页 实际上是从 结果集 中截取 `M-N` 条记录
* 语法`LIMIT <M> OFFSET <N>`

* 先使用`SELECT` 关键词查询出结果集，再使用`LIMIT` 关键字截取记录
  * 例如：先把学生按成绩 倒序，再把结果集 分页，每页 三条记录，
  * `LIMIT 3 OFFSET 0`
    * `OFFSET 0`从结果集 0 号记录开始，`LIMIT 3`最多 3 条



* 分页查询的关键：
  * 首先确定每页需要显示的记录数量`PageSize`
  * 然后根据当前页的索引`PageIndex` 确定`LIMIT` 和 `OFFSET` 设定的值
    * `LIMIT` 总是设定为 `PageSize`
    * `OFFSET` 总是设定为 `PageSize*(PageIndex - 1)`

* 在 MySQL 中，`LIMIT 15 OFFSET 30` 可以简写成`LIMIT 30,15`



## 聚合查询

* SQL 提供了专门的**聚合函数**： 统计总数、平均数等计算
* 使用 聚合函数 进行查询就是 聚合查询，可以快速获得结果



* `COUNT()` 函数：查询表中 一共多少记录
  * `SELECT COUNT(*) FROM students;`
    * `COUNT(*)` 表示查询所有列的行数，
    * 聚合的计算结果虽然是一个数字，但查询的结果仍然是一个二维表（一行一列），列名为`COUNT(*)`
    * 通常使用聚合查询时，给列名一个别名，便于处理结果

* `COUNT(*)` 其实和 `COUNT(列1)` 效果一样
* 聚合查询时，也可以使用`WHERE` 条件关键字，方便我们统计符合条件的记录条数



* 除了`COUNT()` SQL 还提供了其他聚合函数：

  * | 函数 | 说明                                   |
    | :--- | :------------------------------------- |
    | SUM  | 计算某一列的合计值，该列必须为数值类型 |
    | AVG  | 计算某一列的平均值，该列必须为数值类型 |
    | MAX  | 计算某一列的最大值                     |
    | MIN  | 计算某一列的最小值                     |

  * 注意：`MAX()` 和 `MIN` 函数不限于数值类型

* 例如，计算男生平均成绩：
  * `SELECT AVG(score) average FROM students WHERE gender='M';`



* 注意：若聚合查询的 `WHERE` 条件关键字没有匹配到任何数据，
  * `COUNT()` 返回0
  * `SUM(),AVG(),MAX(),MIN()` 返回`NULL` 



### 分组

* 对于 **聚合查询**，SQL 提供了 **分组聚合** 的功能

* 使用关键字 `GROUP BY 列名`
  * 执行 SELECT 语句时，会先把记录按照`列名` 分组，然后再分别计算
* 可以给分组聚合的结果集 加上对应的列值：
  * `SELECT class_id, COUNT(*) num FROM students GROUP BY class_id;`
* 注意：不能将其他列放入结果集中，因为不能将多个值放入同一行记录中



* 可以使用多个列进行分组：
  * 例如：统计各班的男生和女生：
  * `SELECT class_id,gender,COUNT(*) FROM students GROUP BY class_id,gender;`



### 练习

* 查询出每个班级的平均分
* `SELECT class_id,AVG(score) average FROM students GROUP BY class_id;`



* 查询出 每个班级男生女生的平均分
* `SELECT class_id,gender,AVG(score) FROM students GROUP BY class_id,gender;`



## 多表查询

* `SELECT` 关键字可以从多张表同时查询寻数据，同时从`students` 和`classes` 表的**乘积**
  * 语法：`SELECT * FROM <表1>, <表2>`
* 一次查询两个表，查询的结果也是 一个二维表，是两个表的乘积
  * 返回的列数是两个表之和，返回的行数是两个行数之积
* 多表查询 ： 又称`笛卡尔查询`
  * 需要注意：返回的行数
  * 并且列的名称可能重复

* 我们可以利用投影查询来给列起别名：
  * `SELECT students.id sid, classes.id cid FROM students,classes;`



* 多表查询时，需要使用`表名.列名` 引用指定列 和 为其设定别名
* 还可以为表设置别名：`SELECT students.id sid, classes.id cid FROM students s, classes c;`



* 多表查询 可以添加`WHERE` 条件
* `SELECT s.id sid, c.id cid FROM students s, classes c WHERE s.gender = "M" AND c.id = 1;`



## 连接查询

* 连接查询 是另一种类型的多表查询，
* 对多个表进行`JOIN` 运算
  * 先确定一个主表作为结果集，然后将其他表 选择性地 `连接` 到主表结果集上

* 选出`students` 中所有学生信息：
  * `SELECT s.id, s.name, ... FROM students s;`



* 存放班级名称的 `name` 存在`classes` 表中，只有根据`students` 的`classes_id` 找到`classes`中对应的记录，再取出`name`列，才能获得班级名称
* 可以使用`INNER JOIN`来实现
  * `SELECT s.id, s.class_id, c.name class_name FROM students s INNER JOIN classes c ON s.class_id = c.id`

* `INNER JOIN` 语法：
  * 先确定主表，`FROM 表1`
  * 确定要连接的表，`INNER JOIN 表2`
  * 确定连接条件：`ON 条件`
  * 可选：`WHERE`, `ORDER BY`



* `OUTER JOIN`
  * `INNER JOIN`
    * 只返回同时存在两表的行数据
  * `RIGHT OUTER JOIN`
    * 返回右表都存在的行，若记录仅在一行存在，则结果集中会以`NULL`填充
  * `LEFT OUTER JOIN`
    * 返回左表都存在的记录，
  * `FULL OUTER JOIN`
    * 返回两张表都存在的记录，自动将对方不存在的记录填充为`NULL`

# 6 修改数据

* 对关系数据库的基本操作：**增删改查**
  * `CRUD` : Create、 Retrieve、Update、Delete
  * 查询：`SELECT`
* 增删改：
  * `INSERT`: 插入新记录
  * `UPDATE`: 更新已有记录
  * `DELETE`: 删除已有记录



## INSERT

* `INSERT` 语句：向数据库表 插入一条新记录
* `INSERT`基本语法：`INSERT INTO 表名 (字段1，字段2...) VALUES (值1，值2...)`

* 向`students`插入一条新记录：
  * 先列举出需要插入的字段名
  * 再在`VALUES` 子句中依次写出对应字段的值
* 例如 `INSERT INTO students (class_id, name, gender, score) VALUES (2, '大牛', 'M', 80);`



* `id` 字段是一个 自增主键，不需要列为 段名称
* **基本语法**：字段名 需要和 值 一一对应
* 一次性添加多条记录：在`VALUES`子句指定多个记录值，每个记录由`(...)`包含



## UPDATE

* **基本语法**：`UPDATE 表名 SET 字段1=值1，字段2=值2... WHERE ... ; `

* 例如：更新`students`表中`id=1`的记录的`name`和`score`这两个字段
  * `UPDATE students SET name='大牛', score=6 WHERE id=1`

* 在`UPDATE` 语句中，更新字段时可以使用表达式：`UPDATE students SET score=score+10 WHERE score<80;`

* 当没有`WHERE` 关键字时，更新所有记录



### MySQL

* 在使用 MySQL 这类真正的关系数据库时，`UPDATE` 会返回更新的行数以及`WHERE` 条件匹配的行数



## DELETE

* **基本语法**： `DELETE FROM student WHERE ...`

* 删除`students` 表中`id=1`的记录：
  * `DELETE FROM students WHERE id=1;`

* 不带`WHERE ` 语句：删除整个表的数据



### MySQL

* `DELETE` 语句会返回删除的行数以及`WHERE` 匹配的行数



# 7 MySQL

* MySQL安装之后：

  * `MySQL Server` ,即真正的 MySQL 服务器
  * `MySQL Client` , 命令行客户端，可以通过`MySQL Client` 登录 MySQL，输入SQL语句并执行

* `MySQL Server` 和 `MySQL Client` 关系：

  * ```ascii
    ┌──────────────┐  SQL   ┌──────────────┐
    │ MySQL Client │───────>│ MySQL Server │
    └──────────────┘  TCP   └──────────────┘
    ```

* `MySQL Client` 中输入的SQL语句通过TCP连接发送到MySQL Server
  * 默认端口号 3306
  * 即发送到本机MySQL Server , 地址`127.0.0.1:3306`

* 也可以只安装`MySQL Client` ，然后连接到远程`MySQL Server` 
  * 假设 远程`MySQL Server` 的 IP 地址`10.0.1.99`, 那么可以使用`-h`指定 IP 或 域名
    * `mysql -h 10.0.1.99 -u root -p`



## 管理 MySQL

* 管理 MySQL，可以使用 **可视化图形界面软件**  `MySQL Workbench`
  * 用可视化的方式 查询、创建、修改 数据库表

* `Workbench` 对MySQL的操作依然是发送 SQL 语句并执行，
  * Workbench 和 Client命令行都是客户端，和 MySQL 交互，唯一的接口就是 SQL
* 虽然可以使用`MySQL Workbench` 图形界面来直接管理 MySQL
  * 一般，通过`SSH`远程连接时，只能使用SQL命令

### 数据库

* 在一个运行 MySQL 的服务器上，实际上可以创建多个数据库`Database`
  * 列出所有数据库：`SHOW DATABASES;`

* `information_schema`, `mysql`, `performance_schema` 和 `sys` 是系统库，不要去改动

* 创建新数据库：`CREATE DATABASE test;`

* 删除一个数据库`DROP DATABASE test;`

* 切换为当前数据库`USE test;`

### 表

* 列出当前数据库的 **所有表**： `SHOW TABLES;`

  * ```mysql
    +----------------+
    | Tables_in_test |
    +----------------+
    | classes        |
    | students       |
    +----------------+
    ```

    

* 查看**一个表的结构**：`DESC students;`

  * ```mysql
    +----------+--------------+------+-----+---------+----------------+
    | Field    | Type         | Null | Key | Default | Extra          |   
    +----------+--------------+------+-----+---------+----------------+   
    | id       | bigint       | NO   | PRI | NULL    | auto_increment |   
    | class_id | bigint       | NO   |     | NULL    |                |   
    | name     | varchar(100) | NO   |     | NULL    |                |   
    | gender   | varchar(1)   | NO   |     | NULL    |                |   
    | score    | int          | NO   |     | NULL    |                |
    +----------+--------------+------+-----+---------+----------------+  
    ```

    

* 查看 **创建表** 的SQL语句：`SHOW CREATE TABLE students;`
* **创建表**使用`CREATE TABLE`
* **删除表**使用`DROP TABLE`
* **修改表**
  * 给`students`表新增一列`birth` : `ALTER TABLE students ADD COLUMN birth VARCHAR(10) NOT NULL;`
* **修改`birth` 列，**
  * 将列名改为`birthday`, 类型改为`VARCHAR(20)` : `ALTER TABLE students CHANGE COLUMN birth birthday VARCHAR(20) NOT NULL;`

* **删除列：**
  * `ALTER TABLE students DROP COLUMN birthday;`

### 退出MySQL

* 使用`EXIT`命令退出 MySQL
  * 仅仅断开了 客户端与服务器的连接，MySQL 服务器仍然在运行



## 实用 SQL 语句

### 插入或替换

* 插入一条新的记录，若记录已经存在，就先删除原纪录，再插入新记录
  * 不必先查询
* `REPLACE` 语法：`INSERT INTO ... VALUES`
  * `REPLACE INTO students (id,class_id,name,gender,score) VALUES (1,1,'xiaoming','F',99);`

### 插入或更新

* 插入一条新记录，若记录已经存在，就更新该记录

* `INSERT INTO ... ON DUPLICATE KEY UPDATE ...`

* ```mysql
  INSERT INTO students (id, class_id, name, gender, score) VALUES (1, 1, '小明', 'F', 99) ON DUPLICATE KEY UPDATE name='小明', gender='F', score=99;
  ```

  * 若`id=1`不存在，插入新记录，若存在，则由`UPDATE`更新字段

### 插入或忽略

* 插入一条新数据，若已经存在，就忽略

* `INSERT IGNORE INTO...`

  * ```mysql
    INSERT IGNORE INTO students (id, class_id, name, gender, score) VALUES (1, 1, '小明', 'F', 99);
    ```



### 快照

* 对一个表进行快照，即 复制一份当前表的数据到一个新表，结合`CREATE TABLE` 和 `SELECT`
* `CREATE TABLE students_of_class1 SELECT * FROM students WHERE class_id=1;`
* 创建的表结构和原表一样

### 写入查询结果集

* 将 查询结果集 写入表中，结合`INSERT` 和 `SELECT`

* 例如，创建一个统计成绩的表`statistics`，记录各班的平均成绩：

  * ```sql
    CREATE TABLE statistics (
        id BIGINT NOT NULL AUTO_INCREMENT,
        class_id BIGINT NOT NULL,
        average DOUBLE NOT NULL,
        PRIMARY KEY (id)
    );
    ```

* 写入各班的平均成绩：

  * ```sql
    INSERT INTO statistics (class_id, average) SELECT class_id, AVG(score) FROM students GROUP BY class_id;
    ```

### 强制使用指定索引

* 查询时，数据库系统会自动分析查询语句，并选择一个最合适的索引

* 有时，并不一定是最优索引，可以使用`FORCE INDEX` 强制查询使用指定的索引

  * ```sql
    SELECT * FROM students FORCE INDEX (idx_class_id) WHERE class_id = 1 ORDER BY id DESC;
    ```

