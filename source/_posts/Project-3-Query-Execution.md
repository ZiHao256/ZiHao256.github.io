---
title: 'Project #3: Query Execution'
toc: true
categories:
  - 学无止境
  - CMU15-445(2023FALL)
tags:
  - Database System
  - C++
  - Query Execution
  - Query Optimization
  - MVCC
date: 2024-05-16 08:59:16
---

{% note warning simple %}

**撰写本文的目的**：记录本人在不参考其他任何形式的解决方法（思路/源码）、仅靠课程提供的资源（课本/参考资料）和`Discord`中`high level`的讨论的情况下，独立完成该课程的过程。

欢迎大家和我讨论学习中所遇到的问题。

[ZiHao's Blog](https://zihao256.github.io/)

已在grade scope获得100分，~~但是性能仍有待提升~~

实际完成时间：4.6、4.24-4.30

{% endnote %}

- [ ] If you are using CLion to run the BusTub shell, please add a --disable-tty parameter to the shell, so that it works correctly in the CLion terminal.


# Task #1 - Access Method Executors



## - [✅] SeqScan

给SeqScanExecutor增加了一个iterator_字段，不知道是不是多此一举哈



## - [✅] Insert

- called_字段

![image-20240426094832982](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2024/04/image-20240426094832982.png)



## - [✅] Update

- called_字段



## - [✅] Delete





## - [✅] IndexScan





## - [✅] Optimizing SeqScan to IndexScan

```
create table t1(v1 int, v2 varchar(128), v3 int);insert into t1 values (0, '🥰', 10), (1, '🥰🥰', 11), (2, '🥰🥰🥰', 12), (3, '🥰🥰🥰🥰', 13), (4, '🥰🥰🥰🥰🥰', 14);create index t1v1 on t1(v1);
```







refs:

- [Increment/decrement operators - cppreference.com](https://en.cppreference.com/w/cpp/language/operator_incdec)
- [Direct-initialization - cppreference.com](https://en.cppreference.com/w/cpp/language/direct_initialization)
- [List-initialization (since C++11) - cppreference.com](https://en.cppreference.com/w/cpp/language/list_initialization)
- [[C++面试\]拷贝初始化与直接初始化-腾讯云开发者社区-腾讯云 (tencent.com)](https://cloud.tencent.com/developer/article/1919680)

# Task #2 - Aggregation & Join Executors

## - [✅] Aggregation

### - [✅]Simple



### - [✅]group-agg-1



### - [✅] group-agg-2





## - [✅] NestedLoopJoin

### - [✅]inner join

- last_outer_tuple

### - [✅]left join

- last_inner_tuple

# Task #3 - HashJoin Executor and Optimization

## - [✅] HashJoin





## - [✅] Optimizing NestedLoopJoin to HashJoin

### - [✅] Inner



### - [✅] left join

怪不得是对left relation进行hash table building

```
create table t1(v1 int);
insert into t1 (select * from __mock_table_123);
select * from test_simple_seq_2 t2 left join t1 on t1.v1 = t2.col1;
```



### - [✅]multi-way-hash-join

```
create table t1(v1 int);
insert into t1 values (1), (1);
select * from (t1 a inner join t1 b on a.v1 = b.v1) inner join t1 c on a.v1 = c.v1;

```



# Task #4: Sort + Limit Executors + Window Functions + Top-N Optimization

## - [✅] Sort



## - [✅] Limit Executors



## - [✅] Top-N Optimization

![image-20240429154454488](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2024/04/image-20240429154454488.png)

- optimized plan



## - [✅] Window Functions

![img](https://15445.courses.cs.cmu.edu/fall2023/project3/img/window_function_execution_model.jpg)

> `*`Split the data based on the conditions in the partition by clause. 
>
> `*`Then, in each partition, sort by the order by clause. 
>
> `*`Then, in each partition (now sorted), iterate over each tuple. For each tuple, we compute the boundary condition for the frame for that tuple. Each frame has a start and end (specified by the window frame clause). The window function is computed on the tuples in each frame, and we output what we have computed in each frame.

>  For simplicity, BusTub ensures that all window functions within a query have the same `ORDER BY` clauses.

>  You can implement the executor in the following steps:
>
> 1. Sort the tuples as indicated in `ORDER BY`.
> 2. Generate the initial value for each partition
> 3. Combine values for each partition and record the value for each row.

# Bug

```
In file included from /autograder/source/bustub/src/execution/executor_factory.cpp:22:
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:55:44: error: unknown type name 'HashKey'
  auto MakeLeftKeys(const Tuple *tuple) -> HashKey {
                                           ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:62:45: error: unknown type name 'HashKey'
  auto MakeRightKeys(const Tuple *tuple) -> HashKey {
                                            ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:77:22: error: use of undeclared identifier 'HashKey'
  std::unordered_map<HashKey, std::vector<Tuple>> ht_{};
                     ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:77:49: error: expected member name or ';' after declaration specifiers
  std::unordered_map<HashKey, std::vector<Tuple>> ht_{};
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:82:22: error: use of undeclared identifier 'HashKey'
  std::unordered_map<HashKey, bool> ht_used_{};
                     ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:83:22: error: use of undeclared identifier 'HashKey'
  std::unordered_map<HashKey, std::vector<Tuple>>::const_iterator iter_4_left_;
                     ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:83:49: error: expected member name or ';' after declaration specifiers
  std::unordered_map<HashKey, std::vector<Tuple>>::const_iterator iter_4_left_;
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:84:19: error: use of undeclared identifier 'HashKey'
  std::unique_ptr<HashKey> last_hash_key_;
                  ^
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:60:12: error: no viable conversion from returned value of type 'std::vector<Value>' to function return type 'int'
    return {keys};
           ^~~~~~
/autograder/source/bustub/src/include/execution/executors/hash_join_executor.h:67:12: error: no viable conversion from returned value of type 'std::vector<Value>' to function return type 'int'
    return {keys};
           ^~~~~~
In file included from /autograder/source/bustub/src/execution/executor_factory.cpp:38:
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:208:10: error: unknown type name 'PartKey'
      -> PartKey {
         ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:241:45: error: use of undeclared identifier 'PartKey'
      -> std::unique_ptr<std::unordered_map<PartKey, std::vector<std::pair<std::pair<Tuple, RID>, Value>>>> {
                                            ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:241:107: error: expected ';' at end of declaration list
      -> std::unique_ptr<std::unordered_map<PartKey, std::vector<std::pair<std::pair<Tuple, RID>, Value>>>> {
                                                                                                          ^
                                                                                                          ;
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:470:50: error: use of undeclared identifier 'PartKey'
  std::vector<std::unique_ptr<std::unordered_map<PartKey, std::vector<std::pair<std::pair<Tuple, RID>, Value>>>>>
                                                 ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:470:111: error: expected member name or ';' after declaration specifiers
  std::vector<std::unique_ptr<std::unordered_map<PartKey, std::vector<std::pair<std::pair<Tuple, RID>, Value>>>>>
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:86:68: error: use of undeclared identifier 'plan_'
  auto GetOutputSchema() const -> const Schema & override { return plan_->OutputSchema(); }
                                                                   ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:98:46: error: no member named 'plan_' in 'bustub::WindowFunctionExecutor'
    for (const auto &window_function : this->plan_->window_functions_) {
                                       ~~~~  ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:220:12: error: use of undeclared identifier 'PartKey'
    return PartKey{part_by_keys};
           ^
/autograder/source/bustub/src/include/execution/executors/window_function_executor.h:220:19: error: expected ';' after return statement
    return PartKey{part_by_keys};
                  ^
                  ;
fatal error: too many errors emitted, stopping now [-ferror-limit=]
20 errors generated.
```



![image-20240430170101920](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2024/04/image-20240430170101920.png)

# Debug

只能对`shell`debug

# LOG

使用自带的`LOG_DEBUG`



# Learning Note

- 多使用`const T&`提高程序性能

