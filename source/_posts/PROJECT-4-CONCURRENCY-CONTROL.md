---
title: PROJECT
toc: true
categories:
  - 学无止境
  - CMU15-445(2023FALL)
tags:
  - Database System
  - C++
  - MVCC
  - Query Execution
date: 2024-05-16 09:01:13
---

{% note warning simple %}

**撰写本文的目的**：记录本人在不参考其他任何形式的解决方法（思路/源码）、仅靠课程提供的资源（课本/参考资料）和`Discord`中`high level`的讨论的情况下，独立完成该课程的过程。

欢迎大家和我讨论学习中所遇到的问题。

[ZiHao's Blog](https://zihao256.github.io/)

在gradescope获得80分，后续有时间再完成

实际完成时间：5.1-5.7

{% endnote %}

# Task #1 - Timestamps

## - [✅] 1.1 Timestamp Allocation

> When a transaction begins, the read timestamp will be the timestamp of the latest committed transaction, so that the transaction will be able to see everything committed before the transaction begins.

- 即，该事务能够读到，每个对象的指定版本：时间戳小于等于read stamp中最大的那个版本

> Commit timestamp is the time that a transaction commits. It is a logical counter that increases by one each time a transaction commits. 
>
> The DBMS will use a transaction's commit timestamp when it modifies tuples in the databases.

- 字面意思

> See TransactionManager::Begin and TransactionManager::Commit for more information

### Begin



### Commit

## - [✅] 1.2 Watermark

用map而非unordered_map

- std::map<timestamp_t, int> current_reads_;



# Task #2 - Storage Format and Sequential Scan

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/2-1-storage-format.png)

>1. The table heap always contains the latest data, 
>2. the transaction manager “page version info” stores the pointer to the next modification, 
>3. and inside each transaction, we store the tuples that the transaction modified, in a format called undo log.

>  To retrieve the tuple at a given read timestamp, you will need to 
>
> (1) fetch all modifications (aka. undo logs) that happen after the given timestamp, 
>
> and (2) apply the modification (“undo” the undo logs) to the latest version of the tuple to recover a past version of the tuple.

## - [✅] 2.1 Tuple Reconstruction

> Base tuples always contain full data. Undo logs, however, only contain the columns that are changed by an operation. 

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/2-2-undo-log.png)

> Base tuples always contain full data. Undo logs, however, only contain the columns that are changed by an operation. You will also need to handle the case that the tuple is removed by examining the `is_delete` flag in both undo logs an

> ReconstructTuple will always apply all modifications provided to the function WITHOUT looking at the timestamp in the metadata or undo logs. It does not need to access data other than the ones provided in the function parameter list.

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/2-4-undo-log-format.png)

## - [✅] 2.2 Sequential Scan / Tuple Retrieval

> The sequential scan executor scans the table heap, retrieves the undo logs up to the transaction read timestamp, and then reconstructs the original tuple that will be used as the output of the executor



> 1. The tuple in the table heap is the most recent data
> 2. The tuple in the table heap contains modification by the current transaction. 
>    1. a valid commit timestamp ranges from 0 to TXN_START_ID - 1.
>    2. If the highest numerical bit of a timestamp is set to 1 in the table heap, it means that the tuple is modified by a transaction and the transaction has not been committed. 
>    3.  a “transaction temporary timestamp”, which is computed by `TXN_START_ID + txn_human_readable_id = txn_id`
>    4. Undo logs will never contain transaction temporary timestamps 
> 3. The tuple in the table heap is (1) modified by another uncommitted transaction, or (2) newer than the transaction read timestamp.

- 注意txn_id和read timestamp不同
- 该扫描操作肯定是由正在运行的txn执行，read ts则是该txn的start ts

例子

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/2-3-seqscan.png)

- 先实现helper函数——`TxnMgrDbg`
  - 

# - [10/10✅] Task #3 - MVCC Executors：

## - [1/1✅] 3.1 Insert Executor 

> simply create a new tuple in the table heap.
>
> correctly set the tuple metadata for the tuple
>
> - The timestamp in the table heap should be set to the transaction temporary timestamp
>
>  do not need to modify the version link, and the next version link of this tuple should be `nullopt`
>
> add the RID to the write set.



## - [1/1✅] 3.2 Commit 

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/3-2-commit.png)

> 1. Take the commit mutex.
> 2. Obtain a commit timestamp (but not increasing the last-committed timestamp, as the content of the commit timestamp is not stabilized until the commit finishes).
> 3. Iterate through all tuples changed by this transaction (using the write set), set the timestamp of the base tuples to the commit timestamp. You will need to maintain the write set in all modification executors (insert, update, delete).
> 4. Set transaction to committed state and update the commit timestamp of the transaction.
> 5. Update `last_committed_ts`.



## - [6/6✅] 3.3 Update and Delete Executor 

> 概述 
>
> To put everything together, for update / deletes, you should:
>
> 1. Get the RID from the child executor.
> 2. Generate the updated tuple, for updates.
> 3. For self-modification, update the table heap tuple, and optionally, the undo log in the current transaction if there is one.
> 4. Otherwise, generate the undo log, and link them together.

**TIPS：**

- can implement the shared part in `execution_common.cpp`
-  find `Tuple::IsTupleContentEqual` and `Value::CompareExactlyEquals` useful when computing the undo log.

详细的流程：

1. needs to consider **self-modification**

   1. a tuple has already been modified by the current transaction：txn_id == tup_meta.ts
   2. If the tuple is newly-inserted, no undo log needs to be created：找到对应的old undolog并将其更新，然后插入到txn的原idx位置

2. check for **write-write conflict**

   1. 第一种：If a tuple is being modified by an uncommitted transaction, no other transactions are allowed to modify it
      1. a previous transaction should be aborted

   1. 第二种：when a transaction A deletes a tuple and commits, and another transaction B that starts before A and deletes the same tuple (writing to a tuple larger than read ts).
      1. 按照测试代码第二种应该是：如果txnB的时间戳**小于等于**txnA
   2. transaction state should be set to TAINTED when a write-write conflict is detected, and you will need to throw an `ExecutionException` in order to mark the SQL statement failed to execute

3. **implementing the update / delete logic.**

   - Create the undo log for the modification.
     - For deletes, generate an undo log that contains the full data of the original tuple. 
     - For updates, generate an undo log that only contains the modified columns. 
       - 使用`UpdateTupleInPlace`来原地更新
     - Store the undo log in the current transaction. If the current transaction already modified the tuple and has an undo log for the tuple, it should update the existing undo log instead of creating new ones.

   - Update the next version link of the tuple to point to the new undo log.

   - Update the base tuple and base meta in the table heap.

### Delete Executor



### Update Executor

 first scan all tuples from the child executor to a local buffer before writing any updates. After that, it should pull the tuples from the local buffer, compute the updated tuple, and then perform the updates on the table heap.



## - [2/2✅] Task 3.4 Stop-the-world Garbage Collection

> need to remove all transactions that do not contain any undo log that is visible to the transaction with the lowest read_ts (watermark).
>
> traverse the table heap and the version chain to identify undo logs that are still accessible by any of the ongoing transactions. If a transaction is committed / aborted, and does not contain any undo logs visible to the ongoing transactions, you can simply remove it from the transaction map.
>
> 仍然有用的txns：
>
> 1. 第一种：running txns，即其read_ts>=water_mark的txns
> 2. 第二种：tainted txns
> 3. 第三种：拥有ts>water_mark的undolog的txns
> 4. 第四种：如果当前版本tuple的ts>water_mark，则通过判断该undolog的ts是否是<=water_mark的第一个undolog
>    1. 该undolog的txn则为有用

![img](https://15445.courses.cs.cmu.edu/fall2023/project4/img/3-4-garbage-collection.png)

# Task #4 - Primary Key Index

>  When the primary key is specified when a table is created, BusTub will automatically create an index with its `is_primary_key` property set to true. One table will have at most one primary key index.

## 4.0 Index Scan

> When the primary key is specified when a table is created, BusTub will automatically create an index with its `is_primary_key` property set to true. One table will have at most one primary key index.



## - [✅] 4.1 Inserts

think about the case that multiple transactions are inserting the same primary key in multiple threads. Inserting with index can be done with the following steps:

1. Firstly, check if the tuple already exists in the index. If it exists, abort the transaction.
   1. You only need to set the transaction state to TAINTED in Task 4.
   2. When another transaction inserts to the same place and detects a write-write conflict, as the tuple is not cleaned up, it should still be regarded as a conflict. After setting the transaction to TAINTED state, you will also need to throw an ExecutionException so that ExecuteSql will return false and the test case will know that the transaction / SQL was aborted.
2.  create a tuple on the table heap with a transaction temporary timestamp.
3.  insert the tuple into the index.
   1. hash index should return false if the unique key constraint is violated.
   2. Between (1) and (3), it is possible that other transactions are doing the same thing, and a new entry is created in the index before the current transaction could create it. 
      1. In this case, you will need to abort the transaction, and there will be a tuple in the table heap that is not pointed by any entry in the index.

![image-20240507215548168](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2024/05/image-20240507215548168.png)

![image-20240514195655240](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2024/05/image-20240514195655240.png)





