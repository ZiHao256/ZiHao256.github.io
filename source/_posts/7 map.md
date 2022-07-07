---
title: 7 map
categories: 
  - 个人提升
  - 编程语言学习
tags:
  - The Go Programming Language
abbrlink: 19fd4f1c
date: 2021-05-06 14:23:30
typora-copy-images-to:
---
## 7 map

* 无序的基于`key-value`的数据结构
* 内部使用`散列表(hash)`实现
* Go 中的map是引用类型，必须初始化才能使用

### map 定义

* Go 中map基本语法
  * `map[KeyType]ValueType`
  * KeyType : 键的类型
  * ValueType ：键对应的值得类型
* 默认初始值：`nil` 需要使用make 分配内存
  * `make(map[KeyType]ValueType, [cap])`
    * cap ：容量，可省略。但应该在初始化时指定一个合适的容量

### map 基本使用

* map 中的数据都是成对出现

  * 示例

  * ```go
    scoreMap := make(map[string]int, 8)
    scoreMap["小明"] = 90
    fmt.Println(scoreMap)
    fmt.Println(scoreMap["小明"])
    ```

* map 支持在声明时，列表初始化

  * ```go
    userInfo := map[string]string{
    	"username": "马子豪",
    	"password":"122"
    }
    ```

    

### map 的遍历

* 判断 map 中键是否存在的特殊写法：

  * `value,ok := mapname[key]`

    * 如果key存在，则 ok 为 true，value 为对应的 **值**
    * 若key不存在，则ok 为false

  * exampe

    * ```go
      	scoreMap := make(map[string]int)
      	scoreMap["张三"] = 90
      	scoreMap["小明"] = 100
      	// 如果key存在ok为true,v为对应的值；不存在ok为false,v为值类型的零值
      	v, ok := scoreMap["张三"]
      	if ok {
      		fmt.Println(v)
      	} else {
      		fmt.Println("查无此人")
      	}
      ```

      

### map 的遍历

* `for range`键值遍历，同字符串和数组，可以使用匿名变量`_`省略key或者value
  * 注意：遍历map时，元素顺序与添加时顺序无关
  * 示例, 

```go
	scoreMap := make(map[string]int)
	scoreMap["张三"] = 90
	scoreMap["小明"] = 100
	scoreMap["娜扎"] = 60
	for k, v := range scoreMap {
		fmt.Println(k, v)
	}
```

### 使用 delete() 函数删除键值对

* 使用内置函数`delete()` 从map删除一组 键值对 ，

  * 语法：`delete(mapname,key)`
  * mapname: 要删除的键值对的 map
  * key：要删除的键值对的键

* 示例

  * ```go
    	scoreMap := make(map[string]int)
    	scoreMap["张三"] = 90
    	scoreMap["小明"] = 100
    	scoreMap["娜扎"] = 60
    	delete(scoreMap, "小明")//将小明:100从map中删除
    ```



### 按照指定顺序遍历map

```go
func main() {
	rand.Seed(time.Now().UnixNano()) //初始化随机数种子

	var scoreMap = make(map[string]int, 200)

	for i := 0; i < 100; i++ {
		key := fmt.Sprintf("stu%02d", i) //生成stu开头的字符串
		value := rand.Intn(100)          //生成0~99的随机整数
		scoreMap[key] = value
	}
	//取出map中的所有key存入切片keys
	var keys = make([]string, 0, 200)
	for key := range scoreMap {
		keys = append(keys, key)
	}
	//对切片进行排序
	sort.Strings(keys)
	//按照排序后的key遍历map
	for _, key := range keys {
		fmt.Println(key, scoreMap[key])
	}
}
```

* 先对key值排序，
* 再输出对应顺序的`mapname[key]`



### 元素为 map 类型的切片

```go
func main() {
	var mapSlice = make([]map[string]string, 3)
	for index, value := range mapSlice {
		fmt.Printf("index:%d value:%v\n", index, value)
	}
	fmt.Println("after init")
	// 对切片中的map元素进行初始化
	mapSlice[0] = make(map[string]string, 10)
	mapSlice[0]["name"] = "小王子"
	mapSlice[0]["password"] = "123456"
	mapSlice[0]["address"] = "沙河"
	for index, value := range mapSlice {
		fmt.Printf("index:%d value:%v\n", index, value)
	}
}
```



### 值为切片类型的 map

* 键为`string`
* 值为`[]string`, 切片

```go
func main() {
	var sliceMap = make(map[string][]string, 3)
    
	fmt.Println(sliceMap)
	fmt.Println("after init")
	key := "中国"
    
	value, ok := sliceMap[key]
	if !ok {
        
		value = make([]string, 0, 2)
        
	}
	value = append(value, "北京", "上海")
	sliceMap[key] = value
	fmt.Println(sliceMap)
}
```

### 练习题

#### 练习一

* 写一个程序，统计一个字符串中每个单词出现的次数。比如：”how do you do”中how=1 do=2 you=1。

* 分析：给一个字符串，以某个符号分隔：使用`strings`包中的Split方法

* ```go
  package main
  
  import (
  	"fmt"
  	"strings"
  )
  
  func main() {
  	a := "how do you do"
  	result := make(map[string]int, 10)
  	b := strings.Split(a, " ")
  	for _, s := range b {
  		result[s]++
  	}
  	fmt.Println(result)
  }
  
  ```

  



#### 练习二

* ```go
  func main() {
  	type Map map[string][]int   //值为切片（元素为int类型）的map类型
  	m := make(Map)				//初始化
  	s := []int{1, 2}			//切片
      s = append(s, 3)			//s : [1 2 3]
  	fmt.Printf("%+v\n", s)		//[1 2 3]
      m["q1mi"] = s				//m : ["qlmi":[1 2 3]]
      s = append(s[:1], s[2:]...)	//s : [1 3]
  	fmt.Printf("%+v\n", s)		//[1 3]
  	fmt.Printf("%+v\n", m["q1mi"])	//[1 2 3]
  }
  ```

* 目测结果: 

  * `[1 2 3]`
  * `[1 3]`
  * `[1 2 3]`

* 运行结果：

  ```go
  [1 2 3]
  [1 3]
  [1 3 3]
  ```

  * 为什么最后一行`[1 3 3]