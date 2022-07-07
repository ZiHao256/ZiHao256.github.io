---
title: VS2019 下 C++ 项目访问MySQL数据库
categories: 
  - 个人提升
  - 编程语言学习
tags:
  - SQL
descriptions: 学习在VS中创建C++新项目并连接数据库
abbrlink: 22861f12
---

[参考博客]([(5条消息) MySQL数据库---VS019 C++访问MySQL_买代码的小猪猪的博客-CSDN博客](https://blog.csdn.net/weixin_49324123/article/details/116493884))

CMD 命令行窗口进入mysql数据库：

`mysql -hlocalhost -uroot -p`:

* `-hlocalhost`：-h表示服务器名, localhost表示本地
* `-uroot`: -u表示数据库用户名，root是MySQL默认用户名
* `-p`: 为密码

# 1 配置

* 项目->属性->==平台为 `x64`==

* 项目 -> 属性 -> VC++ 目录
  * 将所安装的MySQL目录下的`include` `lib`文件夹目录分别输入包含目录库目录
  * ![image-20210522160110645](E:\Hexo\Blog\source\_posts\VS2019-C++-MySQL.assets\image-20210522160110645.png)
* 链接器 -> 输入
  * 将 MySQL 的lib目录下的`libmysql.lib`文件名输入附加依赖项，只需输入文件名
  * ![image-20210522160248341](E:\Hexo\Blog\source\_posts\VS2019-C++-MySQL.assets\image-20210522160248341.png)

* 将 lib 目录下的`libmysql.dll` 文件复制`C:\Windows\System32`目录下



# 2 C++ 中 MySQL 的基本操作

一个对已创建的数据库的访问代码，例如：

```c++
#include <stdio.h>
#include <mysql.h> // mysql文件
int main(void)
{
	MYSQL mysql;    //数据库句柄
	MYSQL_RES* res; //查询结果集
	MYSQL_ROW row;  //记录结构体
	//初始化数据库
	mysql_init(&mysql);
	//设置字符编码
	mysql_options(&mysql, MYSQL_SET_CHARSET_NAME, "gbk");
	//连接数据库
	if (mysql_real_connect(&mysql, "127.0.0.1", "root", "qazedc12", "test", 3306, NULL, 0) == NULL) {
		printf("错误原因： %s\n", mysql_error(&mysql));
		printf("连接失败！\n");
		exit(-1);
	}
	//查询数据
	int ret = mysql_query(&mysql, "select * from students;");
	printf("ret: %d\n", ret);
	//获取结果集
	res = mysql_store_result(&mysql);
	//给ROW赋值，判断ROW是否为空，不为空就打印数据。
	while (row = mysql_fetch_row(res))
	{
		printf("%s  ", row[0]);   //打印ID
		printf("%s  ", row[1]);   //打印姓名
		printf("%s  ", row[2]);  //打印班级
		printf("%s  ", row[3]);  //打印性别
		printf("\n");
	}
	//释放结果集
	mysql_free_result(res);
	//关闭数据库
	mysql_close(&mysql);
	system("pause");
	return 0;
}

```

从实例代码中可以了解到访问数据库的步骤：

* 需要包含的**头文件** `mysql.h`

* **初始化**数据库：
  * **数据库句柄** `MYSQL mysql`
  * 定义**查询结果集** `MYSQL_RES* res`
  * 定义**记录结构体** `MYSQL_ROW row`
  * 初始化数据库： `mysql_init(&mysql)`
* 设置字符编码：`mysql_options(&mysql, MYSQL_SET_CHARSET_NAME, "gbk");`

* 连接数据库：`mysql_real_connect(&mysql, "127.0.0.1", "root", "123456Aa", "school", 3306, NULL, 0)`
* 查询数据：`mysql_query(&mysql, "select * from students;")`
* 获取结果集`res = mysql_store_result(&mysql)`
* 打印数据：`while(row = mysql_fetch_row(res))`
* 释放结果集：`mysql_free_result(res)`
* 关闭数据库：`mysql_close(&mysql)`



## 常用的连接 MySQL 和 从MySQL中取出数据的API

`mysql_real_connect()`

* **函数原型**：`MYSQL *mysql_real_connect(MYSQL *mysql, const char *host, const char* user, const char* password, const char* db, unsigned int port, const char* unix_socket, unsigned int client_flag)`
  * mysql: 现存MYSQL结构的地址
  * host : 一个主机名或IP地址
  * user: 用户ID
  * password: 用户密码
  * db: 数据库名 
  * port: 若非0，则作TCP/IP 连接用作端口号
  * unix_socket: 若非NULL，则指定套接字或应该被使用的命名管道
  * clident_flag: 通常为0
* 返回值：
  * 成功：MYSQL* 连接句柄
  * 失败：NULL



`mysql_select_db()`

* **函数原型**：`int mysql_select_db(MYSQL* mysql, const char *db)`
  * 使得由 **db 指定的数据库**成为在由 mysql 指定的连接上的当前数据库
* 返回值：
  * 成功：0
  * 失败：非零



`mysql_query`

* 函数原型：`int mysql_query(MYSQL* mysql, const char*query)`
  * 执行由 query 指向的 **SQL查询语句**
  * 必须包含一条的 SQL 语句；若允许多语句执行，字符串可包含多条由分号隔开的语句
  * 不需要加终止的分号
  * **注意**：对于包含二进制数据的查询，你必须使用mysql_real_query()而不是mysql_query()，因为二进制代码数据可能包含“\0”字符，而且，mysql_real_query()比mysql_query()更快，因为它对查询字符串调用strlen()



`mysql_store_result`

* 函数原型：`MYSQL_RES *mysql_store_result(MYSQL *mysql)`

* 对于成功检索了数据的每个查询（SELECT, SHOW, DESCRIBE,等），必须调用mysql_store_result 或 mysql_use_result

* 对于其他查询，不需要调用mysql_store_result 或

* > mysql_store_result()将查询的全部结果读取到客户端，分配1个MYSQL_RES结构，并将结果置于该结构中。
  >
  > 如果查询未返回结果集，mysql_store_result()将返回Null指针（例如，如果查询是INSERT语句）。
  >
  > 如果读取结果集失败，mysql_store_result()还会返回Null指针。通过检查mysql_error()是否返回非空字符串，mysql_errno()是否返回非0值，或mysql_field_count()是否返回0，可以检查是否出现了错误。
  >
  > 如果未返回行，将返回空的结果集。（空结果集设置不同于作为返回值的空指针）。
  >
  > 一旦调用了mysql_store_result()并获得了不是Null指针的结果，可调用mysql_num_rows()来找出结果集中的行数。
  >
  > 可以调用mysql_fetch_row()来获取结果集中的行，或调用mysql_row_seek()和mysql_row_tell()来获取或设置结果集中的当前行位置。
  >
  > 一旦完成了对结果集的操作，必须调用mysql_free_result()。



`mysql_fetch_row`

## INSERT 、UPDATE语句

[参考博客](https://www.cnblogs.com/fnlingnzb-learner/p/5829556.htmls)