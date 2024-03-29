---
title: 5 Array
categories: 
  - 学无止境
  - 编程语言学习
tags:
  - The Go Programming Language
abbrlink: c6746613
date: 2021-05-06 10:22:06
---



## 5 Array 数组

* 同一种数据类型的集合
* Go 中，数组从声明时就确定，使用时可以修改数组成员，但是**数组大小不可变**
  * 语法：`var a [3]int`

### 数组定义

* `var name [size]T`
  * size 必须是常量
  * 长度是数组类型的一部分，定义后不可变
  * 不同长度，不可相互赋值
* 数组可以使用下标访问，`0 - size-1`
* 若越界，会触发访问越界，panic



### 数组的初始化

#### 方法一

* 可以使用 初始化列表 设置数组元素的值

  * ```go
    var a [3]int						//数组元素初始化为int类型的0
    var b = [3]int{1,2}					//使用指定的初始值完成成初始化
    var c = [3]string{"北京","上海"}	 //指定的值完成初始化
    ```

    

#### 方法二

* 我们可以让编译器根据初始值的个数自行推断长度

  * ```go
    var a = [...]int{1,2}
    var b = [...]string{"ss"}
    ```

    

#### 方法三

* 使用指定索引值的方式，初始化数组
  * 

```go
a := [...]int{1:1, 3:5}
//[0 1 0 5]
//type : [4]int
```



### 数组的遍历

两种方法

* for循环

  * ```go
    a := [...]string{"x", "y"}
    for i:=0; i<len(a); i++{
        fmt.Println(a[i])
    }
    ```

* for range键值循环

  * ```go
    a := [...]string{"x", "y"}
    for index, value := range a{
        fmt.Println(index,value)
    }
    ```



### 多维数组

* Go 支持多维数组，数组中嵌套数组

#### 二维数组的定义

```go
a := [3][2]string{
	{"x", "y"},
	{"z", "j"},
	{"a", "b"},
}
fmt.Println(a[2][1]) //支持索引取值
```



#### 二维数组的遍历

```go
for _, i := range a{
    for _, j := range i{
        fmt.Printf("%s\t\n",j)
    }
}
```



==注意==：多维数组只有第一层可以使用`...` 来让编译器推导数组的长度

```go
a := [...][2]{
    {"x", "y"},
	{"z", "j"},
	{"a", "b"},
}
```



### 数组是值类型

* 数组的**赋值和传参**会 **复制整个数组**，改变副本的值不会影响到本身
* ==注意：==
  * 数组支持`==` `!=`操作符，因为**内存总是被初始化过的**
  * `[n]*T`表示**指针数组**，`*[n]T`表示**数组指针**



### 练习题

#### 练习一

* 求数组`[1, 3, 5, 7, 8]`所有元素的和



#### 练习二

* 找出数组中和为指定值的两个元素的下标，比如从数组`[1, 3, 5, 7, 8]`中找出和为8的两个元素的下标分别为`(0,3)`和`(1,2)`。

* ```go
  package main
  
  import "fmt"
  
  func main() {
  
  	a := [...]int{1, 3, 5, 7, 8}
  	for i := 0; i < len(a); i++ {
  		for j := i + 1; j < len(a); j++ {
  			if a[i]+a[j] == 8 {
  				fmt.Printf("%d %d\n", i, j)
  			}
  		}
  
  	}
  }
  
  ```

  