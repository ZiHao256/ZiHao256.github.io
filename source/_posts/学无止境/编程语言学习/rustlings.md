---
title: rustlings
toc: true
categories:
  - 学无止境
  - 编程语言学习
tags:
  - Rust
abbrlink: 2acafc61
date: 2023-11-28 17:46:15
---
> 说来惭愧，大三寒假的时候学过一次Rust，但是只是过了一遍语法，并且没有真正有项目实践，所以很快就遗忘了。
>
> 这次开始尝试实践/项目驱动学习，正好最近需要写一个Web项目，尝试使用Rust来编写，以巩固对Rust的学习。
>
> 首先用rustlings对Rust的基本语法体系进行最小化学习
>
> 后续会根据需要来拓展对相关概念深入的学习（the book/async/rustdoc）

- [x] rustlings：需要完整做一遍，并把相关概念汇总到此页面，后续作为复习/字典查阅
- [ ] the book：根据需要对Rust中的概念进行复习，作为字典查看
- [ ] Asynchronous Programming：web编程中涉及到异步时再深入学习



---

[toc]



# Book Chapter Mapping

| Exercise        | Book Chapter |
|-----------------|--------------|
| variables       | §3.1         |
| functions       | §3.3         |
| if              | §3.5         |
| primitive_types | §3.2, §4.3   |
| vecs            | §8.1         |
| move_semantics  | §4.1-2       |
| structs         | §5.1, §5.3   |
| enums           | §6, §18.3    |
| strings         | §8.2         |
| modules         | §7           |
| hashmaps        | §8.3         |
| options         | §10.1        |
| error_handling  | §9           |
| generics        | §10          |
| traits          | §10.2        |
| tests           | §11.1        |
| lifetimes       | §10.3        |
| iterators       | §13.2-4      |
| threads         | §16.1-3      |
| smart_pointers  | §15, §16.3   |
| macros          | §19.6        |
| clippy          | §21.4        |
| conversions     | rustdoc          |

---
# 1.Intro

Rust uses the `print!` and `println!` macros to print text to the console.

## Further information

- [Hello World](https://doc.rust-lang.org/rust-by-example/hello.html)
- [Formatted print](https://doc.rust-lang.org/rust-by-example/hello/print.html)

# Formatted print
- Rust中可以通过一系列以`!`结尾的宏定义来字符串化变量、格式化，并将其写入`String`或者`io::stdout/stderr`
- Rust中字符串化变量的占位符（类似于C中的`%`）为`{}`
  - `{name}`指定字符串化变量的名字    
  - `{:}`在`:`后输入`format character`，可以指定字符串化的形式
  - 使用`>`或者`<`可以在左右两边使用空格或者0等填充至指定长度


- Rust中，使用类似于C++中的`interface`或者`abstract class`的`trait`来实现一部分多态性
  - 例如，实现了`fmt::Display`的类型才能使用`{}`标志符来字符串化该类型的变量
  - 只需要继承`fmt::Debug`就能使用`{}`标志

---

# 2. Variables

In Rust, variables are immutable by default.
When a variable is immutable, once a value is bound to a name, you can’t change that value.
You can make them mutable by adding `mut` in front of the variable name.

## Further information

- [✅] [Variables and Mutability](https://doc.rust-lang.org/book/ch03-01-variables-and-mutability.html)

# Variables and Mutability
mut
- Rust中使用let声明的变量默认是immutable
  - 保证并发安全
- 在变量名前`mut`使得其可以mutable
  

constant
- 类似于C/C++中的const
- 需要显式指定类型

shadow
- 可以在同一作用域，使用`let`声明名字相同的两个变量
- 第二个会把第一个`overshadow`
- 可以根据需要选择
  1. 直接声明为`mut`
  2. 使用`let`来overshadow

---

# 3.Functions

Here, you'll learn how to write functions and how the Rust compiler can help you debug errors even
in more complex code.

## Further information

- [✅] [How Functions Work](https://doc.rust-lang.org/book/ch03-03-how-functions-work.html)

# Functions
- 函数名：snake_case

## Parameters
- parameter和argument：函数定义和调用时
- 函数签名中，必须显式地给出parameter的类型

## Statement and Expressions
- Rust的一大特点：基于Expression的语言
  - 区别于Statement
    - 有返回值
    - 不以`;`结尾：expression以;结尾则会变为statement
- 区别于C/C++：Rust的赋值语句无返回值
- Rust中的Expression：
  - 基本操作符运算
  - 函数调用
  - macro:
    - print!等形式化字符串的宏则是返回为void？
  - 花括号创建的新作用域

## Functions with return values
- 必须在函数签名使用`->`显式地声明
- 函数中返回的方式
  - 显式return
  - 隐式地返回最后一个expresion的返回值



---

# 4.If

`if`, the most basic (but still surprisingly versatile!) type of control flow, is what you'll learn here.

## Further information

- [✅] [Control Flow - if expressions](https://doc.rust-lang.org/book/ch03-05-control-flow.html#if-expressions)

# Control Flow
## if Expression
- condition必须是bool
  - 强静态类型：不会自动将整型隐式地转换为bool
- Rust推荐最多使用一个`else if`分支，否则使用`match`来重构代码
- `if`是一个Expression，可以用在let声明的右侧
  - 但是需要确保每个分支的最后一行为Expression
  - 并且每个分支的Expression返回的类型需要一致

## Repetition with Loops
### loop
- break结束循环
  - `break value;`使得loop也可以像`if Expression`一样返回值
- continue进入下一次循环
- 对于嵌套loop语句
  - break和continue默认作用于当前作用域最内层的loop
  - 可以使用`'label: loop{}`来给loop加标签，并使用`break 'label;`来使得break作用于标签loop

### conditional loop with while
实现conditional loop

### Looping Through a Collection with for
- `for element in variable{}`来遍历一个Collection（实现了`Iterator`trait）变量
  - 更安全、更快
  - 类似于C++中的`for range`
- `for i in (lb..hb)`
  - 可以使用`Range`表达式（实现了`Iterator`trait）来进行特定数量的循环



---

# 5.Primitive Types

Rust has a couple of basic types that are directly implemented into the
compiler. In this section, we'll go through the most important ones.

## Further information

- [✅] [Data Types](https://doc.rust-lang.org/stable/book/ch03-02-data-types.html)
- [] [The Slice Type](https://doc.rust-lang.org/stable/book/ch04-03-slices.html)
# Data Types
- 虽然Rust在声明变量时很方便，不用指定类型（类似于C++中auto），因为编译器能够在编译时推断`let`声明的变量是什么
- Rust是强静态类型语言，即必须在编译时就推断出所有变量的类型
  - 推断需要足够多的信息：初始值、如何使用的
- 在一个值可能有多种类型的情况，必须使用`type annotation`显式地给出

## Scalar Types
- intergers, floating-point numbers, booleans, characters
- 仅仅代表一个值

### Interger Types
类似于C++中，只是类型名不同
- 其中有符号数底层使用`Two's Complement`，在`Release`模式允许`overflow`，会从最小值开始重新计算
- 可以使用标准库提供的一系列方法来判断是否overflow

### Floating-point numbers
- IEEE-754标准

### The Character Type
- Rust中的char类型占4 Bytes
- 使用Unicode编码

## Compound Types
- 将多个值组织到一个类型
- tuple, array

### tuple type
- 注意：
  - 一旦定义，大小就不可改动
  - 可以组织不同类型的值
- 访问：
  - `pattern matching`：解构一个tuple
  - 使用运算符`.`


### array type
- 声明/定义
  - `type annotation`: 
    - `[type; size]`
  - 初始化所有元素为同一值
    - `[inited_value; size]`
- 注意
  - 只能组织一种类型的值
  - Rust中array的大小固定
- 访问：
  - 运算符`[]`
  - 如果访问超出数组范围:`panic`
- `Array Slice`: 为了提高内存利用率，只能引用数组或者字符串来创建
  - 可以使用`&a[begin..end]`引用一个不可变的数组Slice
  - `&mut`引用元素可变数组的可变 数组Slice

---

# 6.Vectors

Vectors are one of the most-used Rust data structures. In other programming
languages, they'd simply be called Arrays, but since Rust operates on a
bit of a lower level, an array in Rust is stored on the stack (meaning it
can't grow or shrink, and the size needs to be known at compile time),
and a Vector is stored in the heap (where these restrictions do not apply).

Vectors are a bit of a later chapter in the book, but we think that they're
useful enough to talk about them a bit earlier. We shall be talking about
the other useful data structure, hash maps, later.

## Further information

- [✅] [Storing Lists of Values with Vectors](https://doc.rust-lang.org/stable/book/ch08-01-vectors.html)
- [ ] [`iter_mut`](https://doc.rust-lang.org/std/primitive.slice.html#method.iter_mut)
- [ ] [`map`](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.map)


# Storing Lists of Values with Vectors
- 相比于`Array`类型，`Vector`类型使用`Heap`内存来存储变量值

## Creating
- Vector类似于C++中的vector，都是模版类，因此在指定Vector类型时需要指定内部元素类型

1. 使用构造函数`new`: `Vec::new()`
   1. 必须使用`type annotation`
   2. 因为初始化时内部无初始值，编译器无法推断类型
2. 使用宏: `vec![x,x]`

## Updating
- 需要使用`mut`标识符初始化vector
- `push`方法

## Reading
- 因为vector存储在堆内存中，为了内存安全，只能通过引用来访问vector中的元素
  1. `&[]`：
     1. 超出界限会`panic`
  2. `get`方法：返回`Option<&T>`
     1. 可以处理`None`的情况

vector中元素的引用规则：
- 由于存储在heap中，并且vector需要实现可变长度，因此Rust需要确保对同一个数组元素多次引用/并发安全
  - `immutable reference`和`mutable reference`之间的关系类似于读写锁
  - 并且在有`immutabl reference`存在时，也不可以通过vec变量更改内容
    - 因为随时可能因为vector容量不够而需要更改存储位置

## Iterating
- `for i in &v{}`: 返回对vec中元素的不可变引用
- `for i in &mut v{}`: 返回可变引用
  - 在改变元素时：需要使用`*`解引用
  - 🙋：和C++相比：
    - Rust中访问一个引用元素不需要解引用，但是改变内容时需要解引用？
    - C++中似乎对引用元素直接访问和改变
  - `iter_mut`方法，可以以`&mut T`返回一个迭代器，在某些情况下可以替代`for i in &mut v{}`
- 可以对Iterator使用`iter().map()`组合拳，快速构建另一个`Collection`

## MostCommonWays: Using an Enum to Store Multiple Types
- `enum`可以在定义时指定内部的所有`enum variant`
  - `enum variant`可以初始化为不同类型
  - 但是所有`enum variant`都被视为同一种类型`enum EnumName`
- 因此可以使用vector存储`enum EnumName`类型的变量，因为该类型的存储大小在定义`enum variants`时就固定了
- 配合`match`来访问vector内部的`enum`元素



---

# 7.Move Semantics

These exercises are adapted from [pnkfelix](https://github.com/pnkfelix)'s [Rust Tutorial](https://pnkfelix.github.io/rust-examples-icfp2014/) -- Thank you Felix!!!

## Further information

For this section, the book links are especially important.

- [] [Ownership](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)
- [] [Reference and borrowing](https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html)

# Ownership
总的来说，Rust对堆内存数据的所有权机制，类似于C++中的`std::unique_ptr`
- References和Borrowing类似于`std::make_shared`

- Ownership是一系列规则：Rust用于确保程序如何正确的管理内存
  - Jvav: 使用Garbage Collection
  - C: 程序员手动分配和释放
- [Stack vs. Heap](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html#the-stack-and-the-heap)
  - Stack：LIFO，存储局部变量，编译时大小就已知
  - Heap：less organized，存储可变长度的结构内容，并将指向该内存的指针存入Stack

## Ownership Rules
> Each value in Rust has an owner.
> There can only be one owner at a time.
> When the owner goes out of scope, the value will be dropped.
- 类比C++中的`std::uniquer_ptr`, `std::unique_lock`等`RAII`机制

## Variable Scope
- 从该变量定义，到函数体或者`{}`的末端

## The String Type
- `String`类与`string literial`不同
  - `String`存储在Heap，并且是`mutable`
  - `String`直接硬编码到代码中，并且是`immutable`

## Memory and Allocation
- 对于能够主动申请heap空间的语言，正确的释放heap内存也很关键
  1. 使用Garbage Collection系统
  2. 手动主动释放：可能会错误释放
     1. double free
     2. 悬空指针
  3. Rust：使用所有权机制——确保能够在数据最后一次使用后正确释放内存一次
- Rust的实现：对堆内存数据的最后一个的引用出了作用域之后，Rust调用其drop函数完成对heap空间释放
  - 类似于C++中的RAII

## Variables and Data Interacting with Move
通过已有的String变量构造新String(直接赋值或者作为函数arguments)：
- 按理来说应该如下：两个指针同时指向一个对内存空间

![image](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/11/image.png)

但是由于Rust的所有权机制：会将堆内存空间的所有权Move给第二个String变量，避免两个String变量两次调用drop方法，导致double free错误
- 类似于C++中的`Move Assignment Operator`/`Constructor`
- ![image-1](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/11/image-1.png)

## Variables and Data Interacting with Clone
- Rust默认不会隐式地对任何堆数据对象使用deep copy
- 但是堆内存对象可以显式地调用`clone`方法来完成deep copy

## Stack-Only Data: Copy
- 对任何编译时期就已知大小的数据类型（内置类型），Rust默认其赋值操作使用Clone，因为开销可忽略不记
- Rust可以为希望使用Clone操作的自定义类型实现`Copy`trait
  - 类似于C++中`move assignment = delete`操作
  - `Copy`trait和`Drop`trait互斥

## Ownership and Functions
- 对于传入函数argument的变量，其所有权机制与赋值类似，即Move还是Copy这是一个问题

## Return Values and Scope
- 可以将函数内部获得的堆内存数据的所有权，通过返回值Move


# Reference and borrowing
- Rust的Borrowing：对某个own堆内存数据的变量创建Reference，可以在不Move所有权的情况下，使得可以通过另一个变量访问数据内容，即另一个变量并不拥有该数据
  - 因此当引用类型出scope时，并不会调用drop
  - 类似于指针，但是编译器确保其指向有效的内容
- ![image-2](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/11/image-2.png)

## Mutable References
- `&mut v`可以创建可变引用
  - 类似于变量定义，用于创建引用类型的`&`默认也是`immutable`

类似于读写锁：避免数据竞争，但是区别是Rust在编译期间就避免了
- 一个堆内存数据同一时间只能有一个`mutable reference`
  - > The restriction preventing multiple mutable references to the same data at the same time allows for mutation but in a very controlled fashion
- 可以同时有多个`immutabl references`
- `mutable reference`和`immutable reference`不能同时出现
- Hint：同一时间是指Scope是`overlap`的，Rust会将最后一次变量使用作为`end of scope`

## Dangling References
- 类似于C++中的悬空指针
- Rust的编译器会通过`ownership`和`borrowing`机制确保`reference`的正确性

---

# 8.Structs

Rust has three struct types: a classic C struct, a tuple struct, and a unit struct.

## Further information

- [✅] [Structures](https://doc.rust-lang.org/book/ch05-01-defining-structs.html)
- [✅] [Method Syntax](https://doc.rust-lang.org/book/ch05-03-method-syntax.html)

## Structures
- 与Rust的Tuple
  - 相同点：能够组织其多个类型不同的相关数据
  - 不同点：struct类型定义需要给每个filed变量名，并且访问使用变量名

- 定义和初始化一个struct对象：`T {t1: value1,}`
- 赋值操作则和其他数据类型一致：任何返回该类型的Expression

### Using the `Field Init Shorthand`
- 如果有已定义的变量名和struct类型中成员变量名相同，则可以直接使用变量名而不是`name:value`来初始化

### Creating Instances from other Instances with `Struct Update Syntax`
-  `struct update syntax`：`..v2`其他未显式地给新实例初始值的filed，使用v2的filed来初始化
    ```
    let v1 = T {
        field1: value,
        ..v2
    }
    ```
- Hint：本质上是Move了赋值实例的field
  - 因此该语法后，只能使用未被`move`的filed

## Tuple Struct: without named fields to create differenct types
- struct和tuple类型的拼接版
  - 可以使用Tuple Struct的类型名来区别不同的tuple struct实例
  - 不需要给filed命名，通过下标访问

## Unit Struct
- 定义Unit Struct：`struct T;`
- 定义实例：`let v = T;`
  
- 需要注意的是，三种Struct定义关键词相同，只是定义时struct类型名后的括号种类不同





# Method Syntax
- 类似于C++中的方法：定义于类内部
  - 定义于`struct`, `enum`, `trait object`内部
  - 显式地将`self`作为第一个参数

## Defining Methods
- Rust将一个`struct`的所有方法都实现在一个Block:`impl T {}`中
  - 类似于C++中的Class的命名空间：

- 一个`struct`的每个方法的第一个参数必须是`self/&self/&mut self`：分别对应于传入所有权，传入immutable reference，传入mutable reference
  - Rust中给被实现的`struct`名一个别名——`Self`
  - `self`实际上等效于——`self: Self`
    - 同理`&self`等效于`self: &Self`

- 通过运算符`.`来使用method

- Rust实现了`automatic referencing and dereferencing`：
  - 因此不同于`C++`对于类实例指针调用方法：使用`->`

## Associated Functions
定义在`impl T:{}`中的都叫做`associated functions`，因为与`T`都相关。类似于C++中的命名空间，定义于此的不一定以类实例为参数
- Method: 第一个参数为`Self`
- Tool Functions: 通常用于作`Constructor`，例如`String::new()`
  - 该函数的调用`T::f()`

---

# 9.Enums

Rust allows you to define types called "enums" which enumerate possible values.
Enums are a feature in many languages, but their capabilities differ in each language. Rust’s enums are most similar to algebraic data types in functional languages, such as F#, OCaml, and Haskell.
Useful in combination with enums is Rust's "pattern matching" facility, which makes it easy to run different code for different values of an enumeration.

## Further information

- [✅] [Enums](https://doc.rust-lang.org/book/ch06-00-enums.html)
- [] [Pattern syntax](https://doc.rust-lang.org/book/ch18-03-pattern-syntax.html)
# Enums(强大的很，内部enum varient有着struct的功能)
## Defining an Enum
- struct: 将一组fileds组织在一起
- enum：将一组可能的值，组织在一起
  - `enum varients`: 代表该`enum`类型可能的值，类似于子类与父类的关系，他们的类型一致（`enum`类型），但是值不同

### Enum Values
- 即`enum varients`，定义`enum`实例时：
  - `let v = E::varient`

- 每个`enum varient`可以有`assciated data`
  - 每个`associated data`实际上类似于`struct`类型：组织多种不同类型的值
    - 类似三种`struct`类型——十分强大，~~这还要什么自行车~~
  - 并且在初始化一个`enum varient`实例时，`E::varient()`成为了一个`Constructor`

- 类似于struct类型，也可以为`enum`类型实现Method

### `Optin` Enum: Advantages Over Null Values
- 标准库内置一个`enum`类型`Option`：强制或者确保程序猿处理所有情况（值为NULL）
  - ```
    enum Option<T> {
        Some(T),
        None
    }
    ```
- Rust是静态强类型语言，必然`Option<T>`和`T`是不同类型，也不能直接相互操作
  - 必须先从`Option<T>`转换为`T`:https://doc.rust-lang.org/std/option/enum.Option.html
    - 例如使用`match`比较`enum varients`，并在`match arm`中binding其内部的值
    - 这就是Rust确保程序猿处理None情况的策略
  - 与C++中的`Option`模版类不同：C++中可以直接使用`->`来访问其内部数据（首先确保不是None）

## `match` Control Flow Construct
- `match`可以将任意一个类型（通常为`enum`）的值与一系列`pattern`（通常为`enum varients`）进行匹配
  - 比`if`只能匹配布尔表达式强大的多

- 每个`pattern`对应一个`matching arm`
  - 每个`matching arm`是需要执行的代码，**需要确保每个`arm`返回类型一致的值**，即`matching arm`是一个`expression`

### Patterns That Bind to Values
- 对于`enum`类型的match，可以在`match arm`中将`enum varient`内部`associated data`绑定给一个局部变量，使得能在`match arm`中访问
  - 类似于`tuple`解构各个元素

### Matching with `Option<T>`
- `match` + `enum` 大法好
- > match against an enum, bind a variable to the data inside, and then execute code based on it.

### Matched Are Exhausive
- Rust中`match`会穷尽给定值的所有`pattern`

### Catch-all Patterns and the `_`
- Rust允许我们只显式地特殊处理一部分`pattern`，其他的则默认处理或者忽视
  - 在最后一个`pattern`
    - 使用一个变量名`other`：可以将值绑定到该变量
    - 使用`_`: 不绑定值
      - 但是需要确保每个`match arm`返回值类型一致：`()`则为返回void？

## Concise Control Flow with `if let`
- `if let`语法糖，适用于只希望处理一个值的一种情况
  - `if let pattern(binding) = matched_value {use binding} else {}`
  - 以更少的代码实现了下述`match`相同的功能
    ```
    let new_v = match matched_value{
        pattern(binding) => {use binding},
        _ => {}
    }
    ```

# Pattern
有一个比较有用:可以使用`tuple`包裹多个返回`Enum`类型的表达式，并使用`tuple`解构来同时`match`。
- 但需要注意的是，`match arm`的数量是多个表达式可能结果的全排列，可以使用`_`来忽略一些不需要的
- 可以当字典来查阅：[Pattern syntax](https://doc.rust-lang.org/book/ch18-03-pattern-syntax.html)

---

# 10.Strings

Rust has two string types, a string slice (`&str`) and an owned string (`String`).
We're not going to dictate when you should use which one, but we'll show you how
to identify and create them, as well as use them.

## Further information

- [✅] [Strings](https://doc.rust-lang.org/book/ch08-02-strings.html)

# Storing UTF-8 Encoded Test with Strings
- Rust中的String是`Collection`: 底层实现为
  - `a collection of Bytes`
  - `some methods to help interupt Bytes as text`

## What is String?
- `String`：
  - Rust标准库实现的
- `str`：`[..]`
  - string slice，
  - 由Rust Core实现，常以`&str`的形式使用
- Hint:
  - 两个不同的类型，但都是`UTF-8`编码
  - 可以将`&String`强制转换/隐式转换为`&[..]`即`&str`

## Creating a New String
- Rust中的String底层实现是基于`Vec<T>`，因此String可以使用类似的method

Create：
- 创建一个空String：`String::new()`
- 从一个`string literal`创建：
  - `.to_string()`
  - `String::from()`

## Updating a String
### Appending to a String with `push_str` and `push`
- 方法`push_str()`：将`str`append
  - 会以引用的方式传入，并append到尾部：即以`&str`string slice的形式
- 方法`push()`只能append一个char

### Concatenation with the `+` Operator or the `format!` Macro
`+`和`format!`的学习能加深对Rust所有权机制的理解
- 两种方法可以根据两个已定义的String拼接

```
+`: 底层实现为`fn add(self, s: &str) -> String
```

- 会将`+`左侧String的所有权拿走，
- 将右侧`&String`强制转换为`&[..]`即`&str`
- 并返回左侧String的所有权
- Hint：因此虽然看来新建了一个String，但实际上是在左侧String的基础上append

`format!`宏：
- 并不会拿去任何String的所有权
- 因此是在内部新建了一个String吧

## Indexing into Strings
- Rust中String不能直接使用`[]`来索引字符

### Internal Representation
Rust中String的底层实现`Vec<u8>`
- 并使用UTF-8编码
- 因此使用`[]`可能会获得无效的`Byte`值

### Bytes and Scalar Values and Grapheme Clusters! Oh My!
由于Rust以`Vec<u8>`的格式存储String，并编码为UTF-8
- Rust提供三个角度解析String：因此使用`[]`会混淆下面三种概念
  - Bytes
  - Scalar Values：即Unicode Scalar Values
  - Grapheme Clusters: 最接近我们认为的字符

### Slicing Strings
Rust不允许`[]`来索引单个字符
- Rust提供了`[]`+`Range`，允许获得String的`&str`切片
- 但是如果访问了无效的Byte会`panic`

### Methods for Iterating Over Strings
前面提到了Rust提供了String解析的三种视角：
- Byte：通过`bytes()`方法
- Scalar Values: `chars()`方法
- Grapheme Clusters: 标准库不提供

# `str`, `&str`和`String`
- `str`: 不可变字符串切片类型
- `&str`: 不可变字符串切片的引用类型
  - 对`String`或者`literal`的引用
- `String`: 可变、owned的字符串类型
  - 

# exercises
`strings4.rs`:
- `".into`和`".to_owned`
- 所以说`&str`只是对`String`一部分的引用吗
- str是指`literal`吗

---

# 11 Modules

In this section we'll give you an introduction to Rust's module system.

## Further information

- [✅] [The Module System](https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html)


# Managing Growing Projects with Packages, Crates and Modules
## Packages and Crates
Crates
- 是编译器一次性能编译的最小单位
- 由一系列module组成
- 有两种
  1. binary：有main函数，被编译为可执行文件
  2. library：无main函数，可以被binary crate（本项目或者其他项目）
- crate root:
  - 每个crate都有的一个rs源文件，是Rust编译器开始进入的文件
    - 对于binary crate: `src/main.rs`
    - 对于library crate: `src/lib.rs`
    Packages
- 由一系列`crate`组成，根部的`toml`文件会说明如何构建这些`crate`
  - 最多一个library crate
    - 放置于`src/lib.rs`
  - 多个binary crate
    - 需要放置于`src/bin`目录下

## Defining Modules to Control Scope and Privacy
### Modules备忘录（一系列规则）
https://doc.rust-lang.org/book/ch07-02-defining-modules-to-control-scope-and-privacy.html#modules-cheat-sheet
- 一个crate可能有多个modules

### Grouping Related Code in Modules
- 实际上一个crate就是一个以`crate`module为根的一个module tree
  - 类似于file system
- 其中`crate root`源文件即为`crate module`所在的位置，因此称为`crate root`

## Paths for Referring to an item in the Module Tree
在一个`crate`/`modules tree`中，如何访问一个item: struct, enum, constants, function, method, module
- `use path`：可以将`path`中的items带入到当前scope
  - `absolute path`
  - `relative path`
- module的目的之一是为了隐藏功能的实现，而只暴露接口
  - 因此module默认是private的，只能通过加pub关键词来暴露
- modules之间的访问权限
  - 子module可以访问父module
    - 反之则不行
  - 在同一个scope中的不同item之间可以相互访问public的item

### Exposing Paths with the pub Keyword
- pub作用的对象：`module, struct, enum, constrant, functon, method`
  - 作用于module时，只能说明能够引用这个module名字，尚且不能访问内部private items
- 子module可以访问父module
  - 反之不然
- 兄弟module可以相互访问
### Relative Paths with super
类似于文件系统中的`..`

### Making Structs and Enums Public
- `struct`：仅仅pub struct名
  - filed和associated function都默认private
- `enum`：pub enum名，会使得其内部`varients`都pub

## Bringing Paths Into Scope with the use Keyword
```
use`创建一个路径的`shortcut
```

- 需要注意的是，该`shortcut`只能被同一个scope中使用
- 如果在其他module中，
  1. 重新创建一个shortcut
  2. 以相对路径的形式使用该shortcut

### Creating Idiomatic `use` Paths
想要使用其他module中的不同item
- 对于`function`：use到其父module
- 对于`struct, enum, other items`: use full paths
  - 如果可能会有冲突，则use到其父module

### `use ... as` 
- 解决不同module中相同name的情况

### Re-exporting Names with `pub use`
- 被use的module就像是直接定义在了当前use所在的module
  - 因此可以将`use`所在的module当作是被use的module的父module

### Using External Packages
- `std`crate:
  - 默认嵌入在Rust中，因此不需要将其加入`toml`作为依赖
  - 但是需要使用`use`来将我们需要使用的item带入到当前scope
- `external`crate:
  - 从`crate.io`中找到
  - `Cargo.toml`中加入
  - 在自己的`crate`代码中使用use将其带入到需要的scope，需要使用绝对地址从对应的`crate`开始

### Using Nested Paths to Clean Up Large `use` Lists
- 可以使用`{}`来将多个path的不同部分区别，但是相同部分合并

### the Glob Operator
- use中可以使用`*`符号，来表示将该module下所有items都引入当前scope
  - 慎用

## Separating Modules into Different Files
可以将module的源码从单个crate root源文件，分割到真正意义上树形文件系统的形式
- 即，将每个module源码放入单个rs源文件，只需要在父module源文件中声明该mod即可
- 但是需要确保源文件名与mod名一致
- 通过文件夹来组织源文件的位置

---

# 12 Hashmaps

A *hash map* allows you to associate a value with a particular key.
You may also know this by the names [*unordered map* in C++](https://en.cppreference.com/w/cpp/container/unordered_map),
[*dictionary* in Python](https://docs.python.org/3/tutorial/datastructures.html#dictionaries) or an *associative array* in other languages.

This is the other data structure that we've been talking about before, when
talking about Vecs.

## Further information

- [✅] [Storing Keys with Associated Values in Hash Maps](https://doc.rust-lang.org/book/ch08-03-hash-maps.html)

# Storing Keys with Associated Values in Hash Maps
- 类似于Vec类型，传入Hash Map中的owned type会Move ownership
  - 如果传入引用，需要考虑`lifetime`

## Updating a Hash Map
对于value已经存在的key，处理value的情况有三种
1. overwrite：默认`insert()`实现
2. 只在key value不存在的情况才插入：`entry(&key).or_insert(value)`
   - entry方法返回类似于Option
3. 在key value存在时，基于存在的value更新：`let mut value = entry(&key).or_insert(value)`
   - `*value = new`

---

# 13 Options

Type Option represents an optional value: every Option is either Some and contains a value, or None, and does not.
Option types are very common in Rust code, as they have a number of uses:

- Initial values
- Return values for functions that are not defined over their entire input range (partial functions)
- Return value for otherwise reporting simple errors, where None is returned on error
- Optional struct fields
- Struct fields that can be loaned or "taken"
- Optional function arguments
- Nullable pointers
- Swapping things out of difficult situations

## Further Information

- [x] [Option Enum Format](https://doc.rust-lang.org/stable/book/ch10-01-syntax.html#in-enum-definitions)
- [ ] [Option Module Documentation](https://doc.rust-lang.org/std/option/)
- [ ] [Option Enum Documentation](https://doc.rust-lang.org/std/option/enum.Option.html)
- [x] [if let](https://doc.rust-lang.org/rust-by-example/flow_control/if_let.html)
- [x] [while let](https://doc.rust-lang.org/rust-by-example/flow_control/while_let.html)

# Option Enum Format
Option<T>
```rust
Option<T>{
    Some(T),
    None
}
```
- 主要用于处理None的情况

Result<T, E>
```rust
Result<T, E>{
    Ok(T),
    Err(E)
}
```

- 主要用于处理Error
# Documents
- Option Module
- Option Enum
  - 如何确保在match时不会转移Some(T)内部的所有权
    1. 在pattern中的binding变量前加`ref`
    2. match的变量使用`as_ref`方法从`&Option<T>`转换为`Option<&T>`

# if let
对于只有两三个`enum varients`的Enum类型，可以不使用match而是`if let`进行匹配

# while let
类似于while + if let

---

# 14 Error handling

Most errors aren’t serious enough to require the program to stop entirely.
Sometimes, when a function fails, it’s for a reason that you can easily interpret and respond to.
For example, if you try to open a file and that operation fails because the file doesn’t exist, you might want to create the file instead of terminating the process.

## Further information

- [x] [Error Handling](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html)
- [x] [Generics](https://doc.rust-lang.org/book/ch10-01-syntax.html)
- [] [Result](https://doc.rust-lang.org/rust-by-example/error/result.html)
- [] [Boxing errors](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html)

# Recoverable Errors with Result
```rust
enum Result<T, E> {
    Ok(T),
    Err(E)
}
```
- 类似于Option类型，`T`是`Generic Type Parameter`
- 配合`match`/`if let`等语法，来处理可能会失败的操作
## Matching on Differences Errors
两种方式处理`Result`类型变量：`unwrap_or_else`提供语法糖
1. 通过多层`match`语法，可以实现对`Result`中`Err(E)`中E类型的判断，并作出不同的处理
2. `closure`：通过对`Result`类型调用closure，可以以更少的代码来处理上述判断error的种类
  - `unwrap_or_else(|error|{})`：实际上可以想象该函数也是类似match，做出两种行为
    1. `unwrap`：如果是`Ok(T)`，则直接将T变量返回
    2. `else(|error|{})`：如果是`Err(E)`，则通过`closure`将E变量绑定到error变量，并在`{}`中处理

何为`closure`：函数式编程的概念
- 特性：
  - 捕获环境变量：以不同方式捕获
  - 匿名
  
## Shortcuts for Panic on Error: `unwrap` and `expect`
对于`Result`类型，Rust提供了许多语法糖：要么返回内部的数据，要么`panic!`或者程序猿自定义处理
- `unwrap`
- `expect`
- `unwrap_or_else`

## Propagating Errors
- 处理`Result`时，如果是`Err`
  - 则`early return`提前将结果返回给调用者，由调用者函数来进一步处理

## A shortcut for propogating Errors: the `?` operator
- 对于`Result`值后使用`?`可以实现向上传播`Err`的效果，即
  - 如果`?`作用的函数
    - 返回`Ok`，则正常执行下面的操作
    - 若返回`Err`，则直接返回该函数为`Err`类型
- 可以在`?`后接上其他函数（`?`前放函数返回的类型能调用的函数，甚至如果是返回`Result`，则可以在后面继续加`?`）

## Where The `?` Operator Can Be Used
- `?`也可用于返回`Option`类型的函数
- `?`只能用于返回类型为`Result`或者`option`的函数
- `main`函数也可以返回`Result<(), Box<dyn Error>>`类型
  - 

# Example for Results
## `map` for `Result`
- `Option`和`Result`类型都实现了很多`combinator`，可以省去写`match`的代码
  - `and_then`
  - `map`

## `early return`

# Generic Data Types
- 泛用数据类型：用于定义`struct`, `enum`,`function`,`muthod`
  - 类似于C++中的模版类型参数

## In Function Definition
- 将Generic Type Parameter使用尖括号写在函数名和参数列表之间：
  - `fn fun_name<T>() -> ()`：

- 如果在函数体有涉及到`T`类型变量的比较：
  - 必须限制该函数的调用范围:实现`std::cmp::PartialOrd` trait的类型才能传入


## In struct/enum Definitions
- 将Generic Type Parameter写在struct/enum名之后：
  - `struct Point<T>{}`
  - `enum Point<T>{}`

- 可以在尖括号内指定多个generic type parameters

## In method Definitions
- `impl<T> Stru<T>{}`
  - `impl`关键词后必须有generic type parameter，用于说明该`impl`块是为`Str<T>`实现的，

- 在`impl`后指定generic type parameter之后，就不需要在`method`名和参数列表之间加generic type parameter
- **Hint**：该`method`也可以额外在`method`名和参数列表之间加自己的`generic type para`

## Performance of Code Using Generics
- 使用`generic type parameters`不会减慢程序执行的顺序
- `Monomorphization`——单态化：会在程序编译时完成
  - 类似于C++：在编译时，推算出具体类型并将泛化函数实现为多个版本（对应于不同类型）

---

# 15 Generics

Generics is the topic of generalizing types and functionalities to broader cases.
This is extremely useful for reducing code duplication in many ways, but can call for rather involving syntax.
Namely, being generic requires taking great care to specify over which types a generic type is actually considered valid.
The simplest and most common use of generics is for type parameters.

## Further information

- [x] [Generic Data Types](https://doc.rust-lang.org/stable/book/ch10-01-syntax.html)
- [x] [Bounds](https://doc.rust-lang.org/rust-by-example/generics/bounds.html)

# Generic Data Types
- 泛用数据类型：用于定义`struct`, `enum`,`function`,`muthod`
    - 类似于C++中的模版类型参数

## In Function Definition
- 将Generic Type Parameter使用尖括号写在函数名和参数列表之间：
    - `fn fun_name<T>() -> ()`：

- 如果在函数体有涉及到`T`类型变量: `比较`或者调用某个`trait`中的`method`：
    - 必须使用`Bound`限制该函数的调用范围:
      - 例如，T的比较只能，实现`std::cmp::PartialOrd` trait的类型才能传入


## In struct/enum Definitions
- 将Generic Type Parameter写在struct/enum名之后：
    - `struct Point<T>{}`
    - `enum Point<T>{}`

- 可以在尖括号内指定多个generic type parameters

## In method Definitions
- `impl<T> Stru<T>{}`
    - `impl`关键词后必须有generic type parameter，用于说明该`impl`块是为`Str<T>`实现的，

- 在`impl`后指定generic type parameter之后，就不需要在`method`名和参数列表之间加generic type parameter
- **Hint**：该`method`也可以额外在`method`名和参数列表之间加自己的`generic type para`

## Performance of Code Using Generics
- 使用`generic type parameters`不会减慢程序执行的顺序
- `Monomorphization`——单态化：会在程序编译时完成
    - 类似于C++：在编译时，推算出具体类型并将泛化函数实现为多个版本（对应于不同类型）

# Bounds
`fn printer<T: Display> (){}`是对`Generic Type Parameter`的限制：
- 只有实现了`Diskplay`trait的具体类型才能作为参数
- 实现了`trait`，便可以使得T类型的变量调用`trait`中的method

---

# 16 Traits

A trait is a collection of methods.

Data types can implement traits. To do so, the methods making up the trait are defined for the data type. For example, the `String` data type implements the `From<&str>` trait. This allows a user to write `String::from("hello")`.

In this way, traits are somewhat similar to Java interfaces and C++ abstract classes.

Some additional common Rust traits include:

- `Clone` (the `clone` method)
- `Display` (which allows formatted display via `{}`)
- `Debug` (which allows formatted display via `{:?}`)

Because traits indicate shared behavior between data types, they are useful when writing generics.

## Further information

- [x] [Traits](https://doc.rust-lang.org/book/ch10-02-traits.html)

# Traits: Defining Shared Behavior
- 是一系列`methods`的集合，各种数据类型`struct`, `enum`等可以通过实现该`trait`来使用这些`method`
  - 类似于C++中的抽象类
- `shared behavior`: 实现了同一个trait的数据类型共享这些method
- 可以在`generic type parameter`中使用，作为`Bounds`来限制能够作为参数的类型（都实现了某个trait）

## Defining a Trait
- 类型的behavior: 由它能调用的methods组成
  - `trait`中定义的method则是shared behavior
- `pub trait TName{}`
  - 定义多条method的签名
  - 任何实现了该trait的数据类型必须要实现这些method

## Implementing a Trait on a Type
- 需要将要实现的trait引入当前`scope`
- 语法：`impl TName for StructName{}`
- trait和struct类型至少有一个需要时`local`定义的

## Default Implementation
- 可以在定义`tarit`时，定义部分`method`的默认函数体，作为`default implementation`
  - 其他类型实现该`trait`时可以选择使用默认或者自己定义来覆盖
  - 类似于C++中的虚函数？

## Traits as Parameters
- 类似于作为`generic type parameter`的`Bound`
  - 表示只有实现该trait才能作为generic type的实参
- `impl TraitName`能够以类型的作用定义函数签名：`fn notify(item: &impl Summary){}`
  - 表示实现了该trait的类型都可以作为实参

### Trait Bound Syntax
更好的语法：`fn notify<T: Summary>(item: &T)`
各有优缺点：
1. `impl Trait`语法：简洁
2. `<T: Trait>(item: T)`语法：能表示更复杂情况

### Specifying Multiple Trait Bounds with `+`
通过`+`，可以叠加`Trait Bound`：
1. `impl (T1 + T2)`
2. `<T: T1+T2>(item: T)`

### Clearer Trait Bounds with `where` clause
```rust
fn function<T, U>(item1:T, item2:U)
where
    T: T1+T2,
    U: T2+T3,
{}
```

## Returning Types that implement Traits
- 类似于`impl Trait`可以作为函数的参数类型
- `impl Trait`也可以作为函数的返回值类型
- **Hint:** 函数体内只能返回一种具体类型
  - 可能是因为编译期间无法判断是哪个具体类型
  - 而作为函数参数时是能够推断具体类型的

## Using Trait Bounds to Conditionally Implement Methods
一揽子实现：
> We can also conditionally implement a trait for any type that implements another trait. 
> Implementations of a trait on any type that satisfies the trait bounds are called blanket implementations 
> and are extensively used in the Rust standard library

---

# 17 Lifetimes

Lifetimes tell the compiler how to check whether references live long
enough to be valid in any given situation. For example lifetimes say
"make sure parameter 'a' lives as long as parameter 'b' so that the return
value is valid".

They are only necessary on borrows, i.e. references,
since copied parameters or moves are owned in their scope and cannot
be referenced outside. Lifetimes mean that calling code of e.g. functions
can be checked to make sure their arguments are valid. Lifetimes are
restrictive of their callers.

If you'd like to learn more about lifetime annotations, the
[lifetimekata](https://tfpk.github.io/lifetimekata/) project
has a similar style of exercises to Rustlings, but is all about
learning to write lifetime annotations.

## Further information

- [x] [Lifetimes (in Rust By Example)](https://doc.rust-lang.org/stable/rust-by-example/scope/lifetime.html)
- [x] [Validating References with Lifetimes](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html)

# Validating References with Lifetimes
- 并不会改变`argument`和`return value`的`lifetime`，只是指明关系，或者说是程序猿期望这个关系
- 通过显式地声明函数中`arguments`和`return value`/`struct instance`与`field`之间`lifetime`的关系，使得编译器能够推断出是否会发生`dangling reference`
  - Rust的`Borrow Checker`通过给定的`lifetime annotation`进行检查
- 也是一种`generics`
  - 类似于`generic type parameter`
## Preventing Dangling References with Lifetimes
- 类似于悬空指针
- 常常发生在：函数有多个引用类型的`parameter`，返回值类型也为引用，并且返回值引用为参数索引用的对象

## Borrow checker
- 通过比较`referenced value`与`reference`之间的scope，来判断是否发生`dangling reference`
  - `referenced value`能够涵盖`reference`的scope

## Generic Lifetimes in Functions
- 常常发生在：
  - 函数有多个引用类型的`parameter`，返回值类型也为引用，并且返回值引用为参数索引用的对象

## Lifetime Annotation Syntax
- `&'a i32`
- `&'a mut i32`

## Lifetime Annotation in Function Signatures
```
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str
```

- 首先，由于x和y的lifetime parameter都为'a，计算出引用对象中最小的scope
- 然后，由于return value的lifetime parameter也为'a，则表明程序猿期望：返回引用的scope只能在上面计算的scope中涵盖
- borrow checker通过检查返回引用是否如期望的那样使用了，确保不会dangling

## Thinking in Terms of Lifetimes
- lifetime用于指明实参和返回值之间scope的关系

## Lifetime Annotations in Struct Definitions

## Lifetime Elision
对于函数参数和返回值的lifetime，可以根据`Elision`规则自动推断，三个简单规则
## Lifetime Annotations in Method Definitions
- 类似于`generic type parameter`
## Static Lifetime

## Generic Type Parameters, Trait Bounds, and Lifetimes Together

---

# 18 Tests

Going out of order from the book to cover tests -- many of the following exercises will ask you to make tests pass!

## Further information

- [] [Writing Tests](https://doc.rust-lang.org/book/ch11-01-writing-tests.html)

# How to Write Tests
- 通过`cargo test`可以测试所有以`#[test]`标注的为`test function`的函数
- `lib crate`会创建test module

## `assert!`
## `assert_eq!`, `assert_ne!`
## `should_panic`
也是Rust中的属性`#[should_panic]`

---

# 19 Iterators

This section will teach you about Iterators.

## Further information

- [x] [Iterator](https://doc.rust-lang.org/book/ch13-02-iterators.html)
- [ ] [Iterator documentation](https://doc.rust-lang.org/stable/std/iter/)

# Processing a Series of Items with Iterators
> The iterator pattern allows you to perform some task on a sequence of items in turn.

- `iter()`方法：获得一个实现了`Iterator Trait`变量的迭代器
  - 调用next时，会得到内部数据的`immutable reference`
- `iter_mut()`方法：
  - 调用next，会得到内部数据的`mutable reference`
- `into_iter()`：会获得实现`Iterator`变量的所有权，并返回迭代器

**Hint:** Rust中的Iterator是`lazy`：
> they have no effect until you call methods that consume the iterator to use it up
- 需要对迭代器调用`consuming adaptor`，即会取走`ownership`的method
  

## The `Iterator` Trait and the `next` Method
- 实现`Iterator` Trait必须实现`next`方法
- 每次调用`next`方法会将指针依次指向下一个`Item`

## Method that Consume the Iterator
- `consuming adapter`：内部会调用`next`方法
  - 会获取Iterator的所有权，即consume iterator
  - 由于`lazy`特性，必须在`iterator`的最后调用`consuming adpater`
    - `collect()`：会收集迭代器剩下的`item`为一个`collection`类型

## Methods that Produce Other Iterators
- `iterator adapter`：内部不会调用`next`方法
  - 不会获得Iterator的所有权

## Using Closures that Capture Their Environment
许多`iterator adpater`会将`closure`作为实参



---

# 20 Smart Pointers

In Rust, smart pointers are variables that contain an address in memory and reference some other data, but they also have additional metadata and capabilities.
Smart pointers in Rust often own the data they point to, while references only borrow data.

## Further Information

- [✅] [Smart Pointers](https://doc.rust-lang.org/book/ch15-00-smart-pointers.html)
- [✅] [Shared-State Concurrency](https://doc.rust-lang.org/book/ch16-03-shared-state.html)
- [✅] [Cow Documentation](https://doc.rust-lang.org/std/borrow/enum.Cow.html)

# Smart Pointers
- Rust中的reference都是raw pointer：没有其他额外的元数据或者空间
- Rust中的Smart Pointer：有额外的元数据或者空间来完成更复杂的维护
  - 智能指针`own`数据
  - 必须实现`Deref`和`Drop`Trait
    - `Deref`使得智能指针能够像reference一样被`*`解引用
    - `Drop`定制化智能指针的销毁操作，类似于C++中只能指针的drop函数，在智能指针变量out of scope后自动将heap上数据销毁
  - 类似于C++中的智能指针
  - 例如`Vec`,`String`：图中s1即为智能指针，s则为引用
    - ![image-2](../../../../StudyField/github_repositories/rustlings/exercises/06_move_semantics/image-2.png)

reference vs. smart pointer:
- reference占用空间更小，smart pointer占用空间更大
  - reference类似于raw pointer
- reference只是对数据的引用，smart pointer则`own`数据

例如：
- `Box<T>`
- `Rc<T>`
- `Ref<T>`,`RefMut<T>`

## Using Box<T> to Point to Data on the Heap
- `Box::new()`将数据存储在Heap中，而`Box`变量存储在Stack中
- `Box`：相比其他智能指针，其能力较弱
  - indirection：`Box`变量存储在stack，而其指向的数据存储在Heap中
  - heap allocation:
- 使用场景：
  - Box类型大小固定：将一个编译时无法确认大小的类型作为`Box`的`generic type parameter`，例如递归类型
  - Box拥有所指向数据的所有权：可以Move指向的数据，而不是拷贝
  - Box有`generic type parameter`：可以指定实现了某种trait的类型作为`generic type parameter`

### Using a `Box<T>` to Store Data on the Heap
使用`Box`的`associated function`-`new`可以在Heap上创建一个指定类型的数据，并由该Box变量指向它
- 类似于C++中的`auto p = new int; auto sp = std::unique_ptr(p)`

### Enabling Recursive Types with Boxed
- 通过将递归类型作为`Box`的`generic type parameter`，可以使得Rust能够在编译时确定该类型的大小

例如：
```rust
enum List{
  Cons(i32, List),
  Nil
}
```
![img.png](img.png)

```rust
enum List{
  Cons(i32, Box<List>),
  Nil
}
```
![img_1.png](img_1.png)

## `Deref Trait`: Treating Smart Pointers Like Regular References
- 实现`Deref`Trait：能够使得`*`类型能够像`*`regular reference一样

### Following the Pointer to the Value
- regular reference：一种指针
  - 对其使用解引用操作`*`：就像是顺着指针找到真正的数据

### Using Box<T> Like a Reference
- 也可以对`Box<T>`类型的变量使用解引用`*`：也可以得到其内部真正的数据

### Treating a Type Like a Reference by Implementing the `Deref` Trait
- 实现`Deref` Trait:
  - 必须实现其method`deref`
  - ```rust
      impl<T> Deref for MyBox<T>{
        type Target = T;
        fn deref(self: &Self) -> &Self::Target{
            &self.0
        }   
      }
    ```
- 实现了`deref`便可以像`*`regular reference一样，`*`Type:
  - `* mybox` 自动转换为 `*(mybox.deref())`
- 即：对于实现了`Deref`的数据类型进行`*`解引用：
  1. 首先，调用`deref`转换为对其内部数据的regular reference
  2. 接着，对regular reference进行解引用即可得到T类型的内部数据

### `Implicit Deref Coercions` with Functions and Methods
> Deref coercion converts a reference to a type that implements the Deref trait into a reference to another type.
- 将一个对实现了`Deref`Trait的类型的引用=>对Self::Target类型的引用
  - 即`&MyBox<T>` => `&T`，`&String` => `&str`

### How Deref Coercion Interacts with Mutability
Rust does deref coercion when it finds types and trait implementations in three cases:
- From &T to &U when T: Deref<Target=U>
- From &mut T to &mut U when T: DerefMut<Target=U>
- From &mut T to &U when T: Deref<Target=U>

## `Drop Trait`: Running Code on Cleanup with the Drop Trait
- 每当实现了`Drop`Trait的类型的实例out of scope，都会自动调用`drop`方法，并对其heap上的数据进行释放，或者做其他善后工作
  - 类似于C++的析构函数
  - `CMU15-445(2023FALL)`的`Project#2`的`PageGuard`可能就是借鉴了这里的思想

### Dropping a Value Early with `std::mem::drop`
- Rust不允许手动调用`Drop`中的`drop`方法
- Rust也不允许禁止在out of scope时自动调用`drop`方法
  - 据说是为了防止`double free`
  - 但是`PageGuard`中的Drop是可以手动释放的，可能因为和内存没有很紧密的联系
- Rust提供了`std::mem::drop`来提前手动释放某个value（不必实现Drop Trait）

## Rc<T>: the Reference Counted Smart Pointer
- `reference counting`:`Rc`类型会记录，当前内部数据有多少引用
  - 类似于C++中的`std::shared_ptr`
- `Rc<T>`不是多线程安全
- `Rc<T>`只能返回内部数据的`immutable reference`
- 配合`RefCell<T>`的`borrow_mut`方法才可以获得内部数据的可变引用
  - **Hint:**`RefCell`的`reference rule`是在运行时进行的

### Using Rc<T> to Share Data
`Rc::clone(&a)`：进行浅拷贝
- 只增加Rc实例`a`的引用计数

### Cloning an Rc<T> Increases the Reference Count
- 每次对`Rc`实例调用`RC::clone`都会增加其引用计数
- 每次drop都会降低引用计数
- 对`Rc`实例的引用分为两种：weak和strong
- 通过`strong_count`可以看到其引用计数

## RefCell<T> and the Interior Mutability Pattern
- `Interior Mutability`: design pattern in Rust that allows you to mutate data even when there are immutable references to that data
  - 使用`unsafe`代码来实现
### Enforcing Borrowing Rules at Runtime with RefCell<T>
Here is a recap of the reasons to choose Box<T>, Rc<T>, or RefCell<T>:
- Rc<T> enables **multiple owners** of the same data; Box<T> and RefCell<T> have **single owner**. 
- Box<T> allows immutable or mutable borrows checked at compile time; Rc<T> allows only immutable borrows checked at compile time; RefCell<T> allows immutable or mutable borrows checked at runtime. 
- Because RefCell<T> allows mutable borrows checked at runtime, you can mutate the value inside the RefCell<T> even when the RefCell<T> is immutable.

### Interior Mutability: A Mutable Borrow to an Immutable Value
对于函数签名为`immutable reference`struct类型的情况，如果想改struct内部filed，并且不可更改函数签名：
- 将field的类型使用`RefCell`包裹：`RefCell<T>`
  - 这样在函数内部可以对`RefCell<T>`调用`borrow_mut`获得其内部数据的可变引用
  - `borrow`获得其不可变引用
- 通过`RefCell`，只在对field更改的地方时该field是`mutable`，在该函数其他部分该T仍然表现为`immutable reference`

#### Keeping Track of Borrows at Runtime with RefCell<T>
- 对于`RefCell<T>`的`reference rule`是在运行时进行检查的

### Having Multiple Owners of Mutable Data by Combining Rc<T> and RefCell<T>
- `Rc<T>`只能允许`immutable reference`
- Rc内部包裹RefCell可以通过`borrow_mut`获得可变引用

## Reference Cycles Can Leak Memory

# Shared-Stated Concurrency
- `Mutex<T>`-互斥体：确保同一时间只有一个线程访问
  - 其方法`lock`返回`smart pointer`——`MutexGuard<T>`(包裹在Result中)：
    - 类似于`RefCell<T>`，具有相同的API，并且拥有`内部可变性`
    - 实现了`Deref`，因此可以像`regular reference`一样使用`*`解引用
    - 具有解引用强制性的特点
- `Arc<T>`类似于`Rc<T>`
  - 具有相同API，对于引用计数器提供原子操作，因此是线程安全的
  - 值得注意的是`Actix-Web`中的`web::Data`内部使用`Arc<T>`来实现，因此可以对`web::Data`包裹的`AppState`进行线程安全访问
## Using Mutexes to Allow Access to Data from One Thread at a Time
## The API of Mutex<T>
## Sharing a Mutex<T> Between Multiple Threads
## Multiple Ownership with Multiple Threads
## Atomic Reference Counting with Arc<T>
## Similarities Between RefCell<T>/Rc<T> and Mutex<T>/Arc<T>

# Clone-On-Write
`CMU15-445`的`Porject#0`实现一个`COW`的`Tree`, 可能借鉴了这里的思想
> // Cow is a clone-on-write smart pointer. It can enclose and provide immutable access to 
> // borrowed data, and clone the data lazily when mutation or ownership is 
> // required. The type is designed to work with general borrowed data via the 
> // Borrow trait.

- 使用`Cow<T>`类型，只有当需要修改或者传入了所有权时，才进行Clone

---

# 21 Threads

In most current operating systems, an executed program's code is run in a process, and the operating system manages multiple processes at once.
Within your program, you can also have independent parts that run simultaneously. The features that run these independent parts are called threads.

## Further information

- [ ] [Dining Philosophers example](https://doc.rust-lang.org/1.4.0/book/dining-philosophers.html)
- [x] [Using Threads to Run Code Simultaneously](https://doc.rust-lang.org/book/ch16-01-threads.html)

# Using Threads to Run COde simultaneously
和C++中线程的使用类似
- 创建新线程：`thread::spawn`，会返回`JoinHandle`
  - 参数为`closure`会`capture`上下文中的变量
    - `move closure`会将捕获到的变量转移所有权
  - 新线程会执行closure中的内容
- `JoinHandle::join`会使等待该线程执行完
  - **Hint:** `join`会返回`Result<T>`其中`T`为线程内部返回的值

- `rust`中的`mpsc`可以实现线程安全的多生产者和单消费者模式的FIFO管道


---

# 22 Macros

Rust's macro system is very powerful, but also kind of difficult to wrap your
head around. We're not going to teach you how to write your own fully-featured
macros. Instead, we'll show you how to use and create them.

If you'd like to learn more about writing your own macros, the
[macrokata](https://github.com/tfpk/macrokata) project has a similar style
of exercises to Rustlings, but is all about learning to write Macros.

## Further information

- [] [Macros](https://doc.rust-lang.org/book/ch19-06-macros.html)
- [] [The Little Book of Rust Macros](https://veykril.github.io/tlborm/)

# Macros
- `metaprogram:` 从rust代码生成rust代码
- Rust有四种宏
  - `declarative macro`: 内部使用类似于`match`的解构实现
- `macro` vs `function`:
  - 必须先定义宏才能使用，使用`#[macro_use]`引入scope


---

# 23 Clippy

The Clippy tool is a collection of lints to analyze your code so you can catch common mistakes and improve your Rust code.

If you used the installation script for Rustlings, Clippy should be already installed.
If not you can install it manually via `rustup component add clippy`.

## Further information

- [GitHub Repository](https://github.com/rust-lang/rust-clippy).

---

# 24 Type conversions

Rust offers a multitude of ways to convert a value of a given type into another type.

The simplest form of type conversion is a type cast expression. It is denoted with the binary operator `as`. For instance, `println!("{}", 1 + 1.0);` would not compile, since `1` is an integer while `1.0` is a float. However, `println!("{}", 1 as f32 + 1.0)` should compile. The exercise [`using_as`](using_as.rs) tries to cover this.

Rust also offers traits that facilitate type conversions upon implementation. These traits can be found under the [`convert`](https://doc.rust-lang.org/std/convert/index.html) module.
The traits are the following:

- `From` and `Into` covered in [`from_into`](from_into.rs)
- `TryFrom` and `TryInto` covered in [`try_from_into`](try_from_into.rs)
- `AsRef` and `AsMut` covered in [`as_ref_mut`](as_ref_mut.rs)

Furthermore, the `std::str` module offers a trait called [`FromStr`](https://doc.rust-lang.org/std/str/trait.FromStr.html) which helps with converting strings into target types via the `parse` method on strings. If properly implemented for a given type `Person`, then `let p: Person = "Mark,20".parse().unwrap()` should both compile and run without panicking.

These should be the main ways ***within the standard library*** to convert data into your desired types.

## Further information

These are not directly covered in the book, but the standard library has a great documentation for it.

- [] [conversions](https://doc.rust-lang.org/std/convert/index.html)
- [] [`FromStr` trait](https://doc.rust-lang.org/std/str/trait.FromStr.html)

# AsRef, AsMut, From, Into, TryFrom, Try Into
- Cheap Conversion: AsRef, AsMut
  - 都是泛型Trait，实现了该Trait的类型，可以将其引用转换为泛型类型的引用
  - 至于为什么是cheap：因为只是改变了引用的类型，对于实际数据值没有改变，也没有改变其所有权
  - **Hint:** 默认对各种智能指针实现了`AsRef/AsMut`，即可以可以通过对智能指针调用`as_mut/as_ref`获得内部数据类型的引用
  - **Hint:** 实现了`Deref`或者`MutDeref`的类型（例如Box或者其他智能指针），由于`deref coercion`（即对智能指针的引用会隐式地转换为对内部数据类型的引用），因此对于实现了`AsRef/AsMut`的类型可以直接对包裹该类型的智能指针调用`as_ref/as_mut`

- Consuming/costly Conversion: From, Into, ...
  - 也都是泛型Trait，实现了该`From`Trait的类型，可以将泛型类型的值转换为该类型的值
  - consuming/costly：改变了实际数据值的底层实现，改变了所有权

## From
实现From会自动地为实现类型实现Into

- 简化错误处理：为自己的错误类型MyError实现`From`泛型参数为底层错误类型
  - 可以通过`?`语法糖，将底层错误类型自动地转换为MyError

## TryFrom
与From相近，但是调用from方法返回的是Result类型，更加安全方便，可以让程序猿自己决定如何处理两种情况

# Trait: FromStr
> 自己在写项目的时候，大多数情况下所用到的crate是没有类似于The Book很友善的教程。尝试通过[`FromStr` trait](https://doc.rust-lang.org/std/str/trait.FromStr.html)锻炼一下自己读rust 文档

- FromStr: 
  - 最顶部写了FromStr是一个Trait，并且提供了简化版的签名。
  - 点击source可以阅读源码，今后自己写crate可以参考
  - 紧接着提供了对该Trait功能的描述和例子
- Required Associated Types: 实现该Trait，也需要使用type声明一个自定义的错误类型，以关联类型的形式
- Required Methods: 实现该Trait，必须要实现的方法from_str
- Implementors：一些签名展示了实现了该Trait的类型
- Modules：FromStr所在的模块，即std::str
  - 紧接着是该模块内部的内容：
    - Struct
    - Trait
    - Function

通过阅读rustdoc，我知道了必须实现from_str方法才能实现该FromStr Trait，便可以通过str类型的parse方法隐式地将str consuming conversion为实现该trait的类型