---
title: 'Project#1: Buffer Pool'
toc: true
categories:
  - 学无止境
  - CMU15-445(2023FALL)
tags:
  - Database System
  - C++
abbrlink: 1c228cd6
date: 2023-10-03 13:01:58
---

{% note warning simple %}

**撰写本文的目的**：记录本人在不参考其他任何形式的解决方法（思路/源码）、仅靠课程提供的资源（课本/参考资料）和`Discord`中`high level`的讨论的情况下，独立完成该课程的过程。



欢迎大家和我讨论学习中所遇到的问题。



由于`gradescope`中对`non-cmu students`仅开放了`Project#0`，本文方法仅通过了本地测试，极有可能有错误（并发访问）

{% endnote %}

# Task#1 - LRU-K Replacement Policy

**思路：**

- 基本可以参考源码中给出的注释，一步一步实现
- 每次`RecordAccess`一个`Frame`时，都会使得`leu_replacer`的`current_timestamp_`自增1，方便挑选被`evict`的`frame`。
- 在计算`k backwrad distance`时，使用`UINT32_MAX`代替题目中所述的`+inf`
- 由于`LRUNode`的成员变量都是私有成员，题目规定不能更改函数或者成员的`signature`，因此需要自己定义多个`setter`和`getter`方法
- 为了方便`Evict`方法的实现，可以在`LRUNode`中实现`GetKDistance`方法

## Size

直接返回维护的`curr_size_`。

## RecordAccess

- 判断frame_id是否有效
- 判断node_store中是否已经存在对应该frame_id的LRUNode
  - 若未存在，则创建临时LRUNode，并更新node的访问历史，将其插入node_store_
  - 若已经存在，则只是更新访问历史
- lru_replacer的current_timestamp自增1

## SetEvictable

按照注释一步一步实现，需要注意更新curr_size_

## Evict

- 定义两个临时变量记录最大的time stamp difference和对应的frame id
- 定义一个vector，记录所有k backward distance为+inf的frame id
- 遍历一遍frame node
- 通过最大的time stamp difference，若为+inf，则遍历vector找到earliest access history以及对应的frame id

## Remove

按照注释实现即可

## Bugs
\- [✅] 未给方法中任意位置加锁时能够通过测试，可能本地测试并没有涉及到对某个成员变量的竞争。但是加锁后测试就会卡住

- 🐽，破案了：在`SetEvictable`函数中，一开始就获得了latch，但是并没有在每个return分支释放latch

## Tests

![lru_k_replacer_test result](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231003135918493.png)

# Task#2 - Disk Scheduler

**思路：**

- 可能有多种实现方法，我的思路是`Scheduler`方法只将给定的`DiskRequest`对象`put`进`request_queue_`队列
- 自己实现一个`ProcessRequest`方法，用于对给定`request`调用`disk_manager`的读写Page方法
- 而`StartWorkerThread`则在析构函数`put`一个`std::nullopt`之前一直循环，从`request_queue_`中不断取出`request`并且通过`ProcessRequest`方法创建一个线程来完成对`request`的读写

**需要注意的是：**

- 首先，通过`cppreference`熟悉`std::promise`和`std::future`等概念
  - 主要是通过`__state`成员变量实现`shared_memory`方式的线程间异步通信
  - 需要注意的是只能对`std::promise`对象调用一次`get_future`方法
- 其次，通过类的`none-static`方法创建`thread`时，需要注意显示地给出方法地址，并且给出对象地址，接着输入参数

这里只写一下`StartWorkerThread`的实现思路

## StartWorkerThread

唯一需要注意的是，我维护了一个`std::vector<thread>`来实现对所有`thread`的`join`

0. 在DiskScheduler 析构之前：Put std::nullopt，
   1. 循环对request_queue中的request创建thread来进行process：
      1. 从 request_queue_ 中获得队伍首部的request
      2. 创建执行  WritePage/ReadPage的 thread
   2. 等待thread join

## BUGs

> `std::promise`只能被使用一次：
>
> - 只能调用一次`std::future`获得future对象

- 在对`promise1`的`future1`调用`get`函数后会报`std::abort()`
  - 不调用future2的get时也会报错
- 对第一个request创建完第一个thread后，不知为什么`WorkerThread`就卡住了，无法取得第二个request并创建第二个thread
- 似乎是因为将`request`的引用传进了子线程中，但是在主线程中随着执行出了作用域，`request`被析构了
  - \- [✅] 尝试传入this_request的移动

## Test

![disk_scheduler_test result](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231003141429096.png)

# Task#3 - Buffer Pool Manager

通过参考`Page`，`LRU K Replacement Policy`和`Disk Scheduler`的源码实现，完成时过程比较曲折，花了中秋节一下午和晚上完成，并且只通过了本地测试，并发问题肯定很严重。等`gradescope`开了再继续完善。



源码中给的提示还是比较清晰，因此实现过程虽然曲折但也还算顺利。但有一些我自己踩过的坑或bug，在最后统一写出。



给出一些比较重要的实现

## NewPage

1. 通过free_list_判断是否有frame上无page 
   1. 若free_list上无，则通过replacer判断是否有evictable frame
      1. 若replacer无evictable，则返回nullptr
      2. 若有eviictable，AllocatePage()获得新 page_id，调用replacer.Evict()获得对应frame_id，
         判断frame_id对应的page_id的Page Object是否dirty
         1. 若dirty，则将其写会Disk，将Page Object置空
         2. 若不dirty，则将Page Object置空
            将置空的Page Object与新page_id绑定，将page_id和frame_id存入page_table
            通过replacer将frame Pin（evictable false）
   2. 若free_list上有free frame for new page()
      1. 获得free_frame_id
      2. 获得新page_id
      3. 将为page_id获得Page对象
      4. 将page_id与frame_id绑定
      5. 将frame Pin

## FetchPage

0  查看buffer pool中是否有该Page，通过GetPageByPageId，

若有，则返回Page*

若无：

1. 查看buffer pool中是否有空frame，即free_list_上是否有frame_id
   1. 若buffer pool中无空frame，则通过replacer判断buffer pool上是否有evictable frame
      1. 若无evictable，则说明buffer pool中没有该Page，并且因为无evictable，也无法从disk中读入
         1. 返回null_ptr
      2. 若有evictable frame，
         1. 通过replacer evict该frame，并获得frame_id
         2. 判断frame_id对应的page_id的Page Object是否dirty
            1. 若dirty，则通过创建DiskRequest，将其写回Disk，并将PageObject置空
            2. 若不dirty，则将Page Object置空
         3. 创建DiskRequest，将page_id对应Disk Page从Disk中读出到Buffer frame中，并用Page Object管理
         4. 将page_id与frame_id绑定
         5. 通过replacer将frame pin
   2. 若buffer pool中有空frame
      1. 获得free_frame_id
      2. 从pages_上获得unused page作为读入Disk Page的管理Page
      3. 创建request将page读入，并将管理page的信息更新
      4. 将page_id与frame_id绑定
      5. Pin frame

## UnpinPage

1. 判断page_id对应的Disk Page是否在buffer中
   1. 若不在，则返回false
   2. 若在，取得该Page对象，判断pin count是否为0
      1. 若为0，则返回false
      2. 若否，则降低pin count，若降低后为0，则调用replacer设置frame为evictable
         1. 根据参数is_dirty设置Page对象的is_dirty成员
      3. 返回true

## DeletePage

1. 首先判断page_id是否在pages_中，即是否在buffer pool中
   1. 若不在，则直接返回true
   2. 若在，则判断其是否pinned
      1. 若pinned，则说明无法删除，返回false
      2. 若不是pinned，开始进行Delete：
         1. 获得其frame_id，将page_id从page_table中删除
         2. 调用replacer不再track该frame，并且将frame加入到free_list中
         3. reset其对应的Page对象
         4. 调用DeallocatePage释放Disk上的Page

## LearningNote

- 如果在if之前对mutex进行过lock，需要在每个if分支（若有return）中unlock

- 多线程在进行数据同步的时候，如若使用promise和future，一定不要忘了在指定线程中使用future对象实例的get方法，等待线程任务的完成

- DiskManager:

  - `WritePage(page_id_t page_id, const char *page_data)`
    - page_id：Disk Page的id
    - page_data：是Memory buffer pool中存储Disk Page所在frame的地址

  - `ReadPage(page_id_t page_id, char *page_data)`
    - page_id: Disk Page的id
    - page_data: 也是将Disk Page读入内存所在frame的地址


## Bugs
### - [✅] BUG：在NewPage中第二次latch_.lock()时，debug程序中断

- 查阅资料：可能是由于在一个线程中对非递归锁多次执行lock，导致异常
  - \- [❎] 尝试使用`recursive_lock`
  - \- [✅] 破案了，是因为某个函数中的一个if条件返回时忘记释放latch_



### - [✅] BUG：Flush Dirty Data之后，Fetch不到原来的数据

![🐽时刻](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/xx.png)

- [✅]emmm，从promise获得future对象后，忘记使用get方法等待Request的完成，使得主线程在子线程未将disk page content写入内存，就判断page content是否相同了



### - [✅] BUG：在做Test2时又遇到了上述问题

- 检查出一个bug：在NewPage中，如果通过evict一个frame来腾出位置，需要将原先old_page从page_tables_中删除
- [✅] 发现错因：
  - FlushPage时：写回的应该是old_page_id，而我在NewPage中对DirtyPage进行写回时，传递的实参时新读入Page的id

## Test

![buffer_pool_manager_test result](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231003143600916.png)



# Leaderboard

等到`gradescope`相应的测试开始我再继续完善`Project#1`
