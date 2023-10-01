---
title: 'Project#0: C++ Primer'
toc: true
categories:
  - 个人提升
  - CMU15-445(2023FALL)
tags:
  - Database System
  - C++
abbrlink: 6fa5e9a2
date: 2023-10-01 14:44:47
---
# Task#1 - Copy-On-Write Trie
按照源码中给的提示即可完成

总体思路：use std::shared_ptr<const TrieNode> to traverse, then reuse nodes that do not need to be modified and use std::shared_ptr<TrieNode>  with Clone to build and modify memebers from the bottom up on nodes that need to be modified.

## Get
Get函数实现较为简单

## Put
1. 遍历trie，在vector中存储每个遍历过的TrieNode，判断key对应的node是否存在
   1. 若存在：
      1. 则**直接**创建一个新的TrieNodeWithValue（可能有孩子节点）
      2. 并且利用vector来自底向上依次对每个node进行翻新，只能利用Clone() const函数，
      3. 该project中操作的基本上都是const TrieNode
      4. 利用新root创建一个新的Trie并返回
   2. 若不存在：
      1. 自底向上创建多个完全新的TrieNode和一个TrieNodeWithValue（没有孩子节点）
      2. 利用vector自底向上对new_node祖宗的每个node进行复用，也只使用Clone()
      3. 利用新root创建一个新的Trie并返回


## Remove
1. 遍历Trie，在vector中存储每个遍历过的TrieNode，判断key对应的node是否存在
   1. 若不存在，则直接返回原来的Trie
   2. 若存在
      1. 判断其是否为node_with_value
         1. 若是，
            1. 判断该node是否为有children
               1. 若有，则根据cur_node创建新的trie_node（无value），并自该node向上对每个node进行Clone复用, 返回新Trie
            2. 若无，则自该node向上，直到遇到下一个node_with_value
               1. 判断是否有node_with_value
                  1. 若无，对root进行Clone，并将map中相应的部分置空，返回包含该新root的Trie
            3. 若有，
               1. 对该node_with_value进行Clone复用
               2. 并将该node所在的child置空
               3. 自新的node_with_value向上对node进行Clone复用
         2. 若不是，则不做操作，返回原Trie

## Tests
### trie_test

![image-20231001163006844](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001163006844.png)

### trie_noncopy_test

![image-20231001163527645](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001163527645.png)

# Task#2 - Concurrent Key-value Store
同上，按照源码给出的伪代码完成即可
## Get
较为简单
## Put
(0) 获得write_lock_

(1) 获得root_lock_，拿到root，然后释放root_lock_

(2) 调用Trie::Put()，判断root节点有没有更新
  - 若更新了：获得root_lock_，更新root，释放root_lock_
  - 若没有：则直接结束


(3) 释放write_lock_
## Remove
(0) 获得write_lock_

(1) 获得root_lock_，拿到root，然后释放root_lock_

(2) 调用Trie::Put()，判断root节点有没有更新
  - 若更新了：获得root_lock_，更新root，释放root_lock_
  - 若没有：则直接结束

(3) 释放write_lock_
## Tests
### trie_store_test

![image-20231001163631391](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001163631391.png)

### trie_store_noncopy_test

![image-20231001163712181](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001163712181.png)

# Task#3 - Debugging
可以使用VSCode或者Clion的CMake, Make插件直接构建、生成或者调试给定的测试代码

# Task#4 - SQL String Functions
可以在`plan_func_call.cpp`的`GetFuncCallFromFactory`函数中根据形参`func_name`和`args`返回`std::shared_ptr<StringExpression>`或者抛出异常，实参为输入的字符串和调用SQL函数的类型(`StringExpressionType::Lower`或者`Upper`)。

返回的`StringExpression`对象由`string_expression.h`中的Compute函数进行解析，并且判断类型后对输入字符串进行处理，最后返回处理后的字符串。

## Tests

![image-20231001164116523](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001164116523.png)

![image-20231001164150326](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001164150326.png)

![image-20231001164317119](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001164317119.png)



# GradeScope

![image-20231001164418561](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231001164418561.png)


# Learning Notes
- what is `COW`: ref: ([“Copy-On-Write”](zotero://select/library/items/WHDTY9QP))

## Discord上老哥对我问题的友好回复
> 在这里十分感谢`golo`的帮助
- There is a case where the TYPE of the `TrieNodeWithValue` differs from the TYPE of `TrieNode`, in which case it cannot be converted. Keep in mind `TrieNodeWithValue<std::string>` and `TrieNode<uint32_t>` are not convertable, for example.
  
- When you create `new_node`, you need to `make_shared<TrieNodeWithValue>...` instead of `make_shared<TrieNode>...`.
  
    - I think your `TrieNodeWithValue` is casted to `TrieNode` if you do `make_shared<TrieNode>...`, which you do not want
      

## Geogle Coding Format

- 双目运算符两边加空格
  
- if/else/for后面的括号两端用空格隔开
  
- 返回值之后，不应有空行
  
- 使用default constructor时，变量紧贴着括号
  
- 注意声明指针的时候`*`与类型名隔一空格
  
- 每个statement（包括注释）后面不要有多余的空格
  
- 注释不要太长
  
- 花括号之后接注释：使用两个空格连接