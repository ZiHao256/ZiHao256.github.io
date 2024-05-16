---
title: 'Project#2: Extendible Hash Index'
toc: true
categories:
  - 学无止境
  - CMU15-445(2023FALL)
tags:
  - Database System
  - C++
  - Container
abbrlink: 517dd8ea
date: 2023-10-30 21:56:01
---

{% note warning simple %}

**撰写本文的目的**：记录本人在不参考其他任何形式的解决方法（思路/源码）、仅靠课程提供的资源（课本/参考资料）和`Discord`中`high level`的讨论的情况下，独立完成该课程的过程。

欢迎大家和我讨论学习中所遇到的问题。

[ZiHao's Blog](https://zihao256.github.io/)

{% endnote %}

**Project #2: Extendible Hash Index**

> 先记录完成的过程，然后再总结和思考

# 准备

**Due**：四个星期左右（通过本地测试-4天左右+通过线上测试-一周左右，但由于中途有其他事情，时间跨度很大）

在开始完成该项目之前，首先确保两件事

1.  确保Project#1的代码实现是正确的，最好多提交几次，因为测试用例可能会有不同
2.  一定要先从原bustub仓库pull最新的代码，不然可能会缺少一些给定的实现

**实验环境：**

*   MacOS
*   CLion/VSCode

# Task #1-Read/Write Page Guards

*   数据成员：存储指针

    *   指向BPM
    *   指向Page对象

*   析构函数：确保当BasicPageGuard对象离开作用域的时候：自动调用`UnpinPage`

*   方法成员：除此之外，需要提供方法使得能够手动unpin

*   数据成员：writer-reader latch

    *   可以尝试调用Page中的相关方法

*   方法成员：能够在对象离开作用域时，自动释放latch

## BasicPageGuard/ReadPageGuard/WritePageGuard

可以看到每个`Guard`的拷贝操作都是默认为`delete`，只能使用默认构造器和`move`相关的操作

**对于BasicPageGuard**

*   `PageGuard(PageGuard &&that)`: Move constructor.

    *   参考C++Primer

        *   移动构造的时候从给定对象中窃取资源而非拷贝资源，即移动构造函数不分配任何新内存
        *   需要确保移后源对象销毁是安全的

*   `operator=(PageGuard &&that)`: Move assignment operator.
    *   需要处理移动赋值对象是自身的情况
        *   直接返回\*this

    *   否则，需要处理this和that
        *   直接调用this的Drop
        *   将that的内容交予this
        *   安全地将that的内容清空
            *   **Hint**：需要确保that不会对内部Page对象调用`Unpin`

*   `Drop()`: 
    *   先清空内容，再调用UnpinPage
        *   **Hint**: 确保page成员非空时

*   `~PageGuard()`: Destructor.
    *   直接调用Drop

*   `read-only`和`write data`APIs
    *   分别为`As`和`AsMut`
        *   `As`以`const`修饰符返回Page内部的data
        *   `AsMut`则不然，并且注意`AsMut`会将PageGuard的成员变量`is_dirty`置为true
    *   可以在编译时期检查`data`用法是否正确：
        *   例如，在实现Task3或Task4的`Insert`时，你可能认为某个部分仅仅是查阅了`HeaderPage`，因此以`As`返回，却没想到其实有可能在`HeaderPage`中无相应`DirectoryPage`后，会修改`HeaderPage`。~~例子可能不大恰当~~

**对于ReadPageGuard**

*   移动构造和移动赋值都可以使用std::move完成：

    *   （Update——通过`MoveTest`） **Hint：**注意，需要先对`this`调用`Drop`函数，先释放`this`指向的page所持有的锁！
    *   std::move()移动赋值时，会对赋值guard调用析构函数并调用Drop，因此不必担心赋值后移后源对象会对page造成影响
*   需要注意Drop中资源的释放顺序，需要在Drop BasicPage之前释放RLatch，
    *   否则可能会因为Unpin调用了RLatch而死锁
        *   **Hint**: 确保page非空
    *   **更重要的原因**：先UnpinPage的话，可能会被replacer evit，导致锁住的是另一个进入该Page对象的Disk Page
*   需要在析构函数中判断是否已经手动drop/移动赋值/移动构造过，避免重复Drop导致重复释放Latch

**对于WritePageGuard**：同上

## Upgrade

> guarantee that the protected page is not evicted from the buffer pool during the upgrade

- [x] `UpgradeRead()`: Upgrade to a `ReadPageGuard`

- [x] `UpgradeWrite()`: Upgrade to a `WritePageGuard`

目前这两个函数我都没有使用到，或者说是不知道该如何实现以及使用：

- ~~**如何实现**？我本以为防止evict只需要将page的pin_count_++，但是并PageGuard不是Page的friend class，无法直接访问Page的私有成员~~
- ~~**如何使用**？我能想到该函数存在的原因，是新建一个需要修改的DirectoryPage或者BucketPage，但是没有`NewWritePageGuard`和`NewReadPageGuard`函数的实现，只能 `NewPageGuard`之后立刻`Upgrade`。~~
  - ~~我认为：实际上该线程新建的`Page`目前只能该线程自己访问，并不需要使用`Guard`来保护啊~~
  - ~~因此我在`InsertToNewDirectory`和`InsertToNewBucket`中都只是用了`BasicPageGuard`并且调用了`AsMut`，而未使用`WritePageGuard`。并且这是**能够**通过本地测试的~~
- **Hint：**如何确保`Upgrade`时不会使得`pin_count`改变？
  - 调用`BasicPageGuarde`对象`Drop`之前，先将Page对象指针置空，这样就会告诉`Drop`不要调用`Unpin`
- （——Update：通过`BPMTest`）：经过gradescope的测试，必须俩函数内部来获得锁，之前以为调用该函数前用户手动获得锁


## Wrappers

*   `FetchPageBasic(page_id_t page_id)`
*   `FetchPageRead(page_id_t page_id)`
*   `FetchPageWrite(page_id_t page_id)`
*   `NewPageGuarded(page_id_t *page_id)`

注释中说明得足够清晰，不再赘述

## LocalTest-SimpleTest

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220121826.png)

## GradeScope: PageGuardTest

第一次提交未通过以下两个：

### - [✅] MoveTest

该测试不知为何，并没有Log出任何信息

- 推测和`Basic`, `Read`, `Write`的移动构造和移动赋值有关：尝试自己构造一些移动测试
  - [❎]在移动构造或者移动赋值给另一个`PageGuard`时，不应该对旧`PageGuard`调用`Unpin`
  - [❎] 完善`UpgradeRead`,`UpgradeWrite`
- [✅] **solution**：在`ReadPageGuard`和`WritePageGuard`相应的移动构造函数和移动赋值函数中，忘记在使用`std::move(basicpageguard)`之前应当先对`this`调用`Drop`函数，来释放`this`指向page所持有的锁！！！
  - 在解决`BPMTest`时通过了该测试
  

### - [✅] BPMTest

根据Log信息，该测试只使用了一个线程，但是死锁了：

```
71: [13112912036602121027] invoke BufferPoolManager: new BPM pool_size-[10] replacer_k-[2]
71: [13112912036602121027] invoke NewPageGuarded
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-0
71: invoke BasicPageGuard: page-0
71: [13112912036602121027] invoke FetchPage: page-0
71: [13112912036602121027] invoke FetchPage: page-0 has been in frame-0
71: [13112912036602121027] invoke Drop: page-0
71: [13112912036602121027] invoke UnpinPage: page-0 is_dirty-0
71: [13112912036602121027] page-0 pin_count-1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke FetchPageBasic: page-0
71: [13112912036602121027] invoke FetchPage: page-0
71: [13112912036602121027] invoke FetchPage: page-0 has been in frame-0
71: invoke BasicPageGuard: page-0
71: [13112912036602121027] invoke operator=: this-page--1 that-page-0
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: page-0
71: [13112912036602121027] invoke UnpinPage: page-0 is_dirty-1
71: [13112912036602121027] page-0 pin_count-1
71: [13112912036602121027] set page-0 dirty
71: [13112912036602121027] invoke UnpinPage: page-0 is_dirty-0
71: [13112912036602121027] page-0 pin_count-0
71: [13112912036602121027] set page-0 evictable
71: [13112912036602121027] invoke NewPageGuarded
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-1
71: invoke BasicPageGuard: page-1
71: [13112912036602121027] invoke FetchPage: page-1
71: [13112912036602121027] invoke FetchPage: page-1 has been in frame-1
71: [13112912036602121027] invoke UpgradeRead: page-1
71: invoke BasicPageGuard: page-1
71: invoke ReadPageGuard: page-1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: this-page-1
71: [13112912036602121027] invoke Drop: page-1
71: [13112912036602121027] invoke UnpinPage: page-1 is_dirty-0
71: [13112912036602121027] page-1 pin_count-1
71: [13112912036602121027] invoke FetchPageBasic: page-1
71: [13112912036602121027] invoke FetchPage: page-1
71: [13112912036602121027] invoke FetchPage: page-1 has been in frame-1
71: invoke BasicPageGuard: page-1
71: [13112912036602121027] invoke operator=: this-page--1 that-page-1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke UpgradeWrite: page-1
71: invoke BasicPageGuard: page-1
71: invoke WritePageGuard: page-1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke Drop: this-page-1
71: [13112912036602121027] invoke Drop: page-1
71: [13112912036602121027] invoke UnpinPage: page-1 is_dirty-0
71: [13112912036602121027] page-1 pin_count-1
71: [13112912036602121027] invoke UnpinPage: page-1 is_dirty-0
71: [13112912036602121027] page-1 pin_count-0
71: [13112912036602121027] set page-1 evictable
71: [13112912036602121027] invoke ~WritePageGuard: this-page--1
71: [13112912036602121027] invoke Drop: this-page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke ~ReadPageGuard: this-page--1
71: [13112912036602121027] invoke Drop: this-page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke ~BasicPageGuard: page--1
71: [13112912036602121027] invoke Drop: page--1
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-2
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-3
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-4
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-5
71: [13112912036602121027] invoke NewPage
71: [13112912036602121027] invoke NewPage: new_page-6
71: [13112912036602121027] invoke NewPage

Program exited with -1 in 35.036s (timed out after 30 secs, force kill)
```

(Update——) 在修改了`ReadPageGuard`的移动构造/赋值函数后，log没任何变化

- [x] 该测试似乎是新建page1和page2，然后反复访问两个page，后续新建多个page，来判断`pin_count`或者replcaer的运行是否正确
  - [x] 似乎是page0无法被evict
  - [x] **solution:** 之前未给`Upgrade`加log，并没有发现实际上该测试内部调用了俩升级函数。
    - [x] Hint：必须在该函数内部实现对相应Page的加锁



# Task #2-Extendible Hash Table Pages

![3-level Extendible Hash Table](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231031193833346.png)

这里主要实现三层可扩展哈希表的三个部分，如上图所示：

1. **Header Page**：
   1. 课本中的2-Level并没有该部分，该部分的max depth/prefix（例如上图中的2）是固定的
   2. 主要是用来索引能够索引到存储key的`BucketPage`位置的`Directory Page`在`Header Page`中的位置（比较拗口）
      1. 通过`HashToDirecotryIndex`实现
   3. `HeaderPage`的优点（文档中提到）：
      1. More Direcotry Pages -> More Bucket Pages -> More Keys
      2. 并且由于`Latch Crabbing`的并发策略，使得`Header Page`的`Latch`很快的被释放
2. **Directory Page**
   1. 与课本中一致
      1. **global depth = hash prefix**：三个作用
         1. 用来限制某个时刻可以使用的Directory条目数量$2^{global depth}$个
         2. 用来获得哈希值从LSB开始的global_depth个位，作为在dierctory中的索引，找到key所在的bucket
            1. `HashToBucketIndex`实现
         3. 并且在某个bucket满时，通过比较`global depth`和`local depth`来决定如何处理`split`
      2. **local depth = bucket hash prefix**
         1. 通过比较和global_depth的关系，判断指向当前bucket的指针数量，分裂时如何处理
3. **Bucket Page**
   1. 以数组的形式存储`<key, value`
   2. 注意本项目并不会处理`non-unque key`，因此对于插入相同的key直接返回false（Insert函数）

Task2中相关源码的注释并没有很详细，需要自己根据本地测试来判断该函数具体完成了什么工作

*   可以在实现`Header Pages`和`Directory Pages`的时候，通过`HeaderDirectoryPageSampleTest`来测试或者Debug
*   实现`Bucket Pages`的时候，通过`BucketPageSampleTest`测试
*   例如：`HashToDirectoryIndex`是通过hash value的`max_depth`个MSB求得的

## Hash Table Header Pages

### **成员变量：**

`directory_page_ids`：page\_id（4B）的数组

*   **元素个数**：1<<9

    *   即512个

*   **占用内存**：512\*4 = 2048

`max_depth_`: 通过page\_id(32位)哈希值的高max\_depth\_位，来判断page\_id在directory\_page\_ids\_中的位置

*   **占用内存**：4B

### **方法实现：**

\- \[✅] `HashToDirectoryIndex(uint32_t hash)`

*   通过测试可以看到，实际上该函数是将hash的高max\_depth\_位，作为directory page id在数组directory\_page\_ids\_的索引
*   将hash向右移动`32-max_depth_`位，可以获得高`max_depth_`位对应的uint32\_t表示
*   `Hint`: 考虑`max_depth_`为0的情况，实际上对于4B的整型右移`32`位是`undefined`？

\- \[✅] `MaxSize()：`Get the maximum number of directory page ids the header page could handle

*   由于directory\_page\_ids中每个条目只能存放一个page id元素，因此directory\_page\_ids\_最大能存入`HTABLE_HEADER_ARRAY_SIZE`directory page id

*   而`max_depth_`

    *   对于线性探测解决冲突的哈希表：会决定`directory_page_ids`的大小
    *   不使用线性探测解决冲突：似乎并不会影响`directory_page_ids_`的大小，

*   根据题目要求，`Header Pages`并没有使用线性探测，因此需要返回`max_depth_`能表示数的数量和`HTABLE_HEADER_ARRAY_SIZE`之中的较小值

## Hash Table Directory Pages

### **成员变量：**

`max_depth_`：

*   4B
*   Header Page的directory page id数组中，所有的directory page拥有相同的max\_depth值，代表一个directory能够用的掩码的最大位数

`global_depth_`：

*   4B

*   类似于: 课本中的bucket address table的global prefix，用来控制当前table使用条目的数量，上限是2^max\_depth

*   **简而言之**：global\_depth用来掩码hash value，以获得存储key的bucket在directory 中的索引

*   global\_depth<=max\_depth\_

`local_depth_s`：数组

*   1B \* (Size of array of Bucket page id )
*   类似于：课本中每个bucket持有的local prefix，用来按需生成bucket，进行local prefix后拥有相同值的entry指向同一个bucket
*   简而言之：local\_depth用来掩码，使得确定其在哪个bucket page中

`bucket_page_ids_`

*   存储bucket page id的数组

### **方法实现：**

\- \[✅] `Init`:

*   将global depth和local depth初始化0
*   bucket page id初始化为-1或者其他特殊标记

\- \[✅] `HashToBucketIndex`:

*   类似于`Header Page`中的`HashToDirectoryIndex`，只不过掩码长度为`global_depth_`，并且是将Hash值的低`global_depth_`位(从LSB开始)处理作为bucket在directory中的索引
*   像测试中直接`%Size()`是极好的，但是我一开始脑子没转过来，
    *   一直想用位操作。。。🐽


\- \[✅] `GetSplitImageIndex`: 

*   分两种情况：

    *   local\_depth\_ > global\_depth_：代表后续需要double directory
    *   local\_depth\_ <= global\_depth\_

*   观察得到，为了获得directory扩展后当前bucket\_idx分裂后映像的索引，只需要将bucket\_idx的第新global\_depth\_位取反即可

*   两种情况可以使用同一种位运算来解决

    *   只需要对原进行split的bucket\_idx进行如下位运算

        *   第一种情况：需要double directory
            *   第global\_depth\_位与1异或
        *   第二种情况：不需要double
            *   第global\_depth\_-1位与1异或
        *   其他位与0异或

\- \[✅] `SetLocalDepth`

*   同上，分两种情况

    1.  先根据local_dpth和global_depth的关系，获得split_bucket_idx
2.  如何将两个bucket的local_depth**同时设置为新**的即可

\- \[✅] `IncrGlobalDepth`

*   需要找到当前directory可用的条目中，local\_depth小于等于当前global\_depth的项：

    *   使得其在double后的split\_entry拥有相同的bucket page id和local\_depth
*   global_depth++
*   **Hint:** global_depth <= max_depth

\- \[✅] `DecrGlobalDepth`

*   直接将index在区间\[2^{global\_depth-1}, 2^{global\_depth}-1]的两个数组元素初始化为{-1, 0}

\- \[✅] `GetGlobalDepthMask`:

*   通过注释我们可以知道，`global_depth_`是用于生成从哈希值的`LSB`开始的`global_depth_mask`
*   而`Header Page`中的`max_depth_`则是用于生成`MSB`的掩码

\- \[✅] `GetLocalDepthMask`:

*   同理

\- \[✅] `CanShrink`

*   判断是否存在local\_depth与global\_depth相同

    *   如果没有，则说明所有\<bucket\_idx, split\_bucket\_idx>所包含的bucket page id都相同

        *   因此table可以去除冗余部分，缩小一倍

## Hash Table Bucket Page

### **成员变量：**

`size_`：The number of key-value pairs the bucket is holding

`max_size_`：The maximum number of key-value pairs the bucket can handle

`array_`：An array of bucket page local depths

### 方法实现

`Init`:

*   对max\_size\_初始化

*   对于array\_中的每一个pair\<Key, Value>进行初始化

    *   注意需要为Key和Value都指定一个特殊值，表示该部分为无效

        1.  可以直接使用构造列表，来直接构造模版类的临时对象：

            1.  Key可以使用{-1}来与测试中的i==0区别，Value可以直接使用{}因为RID的默认构造函数会使用-1来表示无效

        2.  或者使用模版参数类型构造

            1.  同理

`Lookup`:

*   （Update——SplitGrowTest）把Size()作为遍历上限，遍历其中的键值对：
    *   使用模版类对象cmp的重载函数()，来比较Key是否相同
        *   返回0表示相同


`Remove`:

- （Update——SpltGrowTest）把Size()作为遍历上限，找到对应的Key后删除
  - （Update——RemoveTest/RecursiveMergeTest）**Hint：**根据`BucketPage`默认提供的`PrintBucket`方法，在Move之后需要将数组紧凑：即将被删除元素后的元素往前移动或者拿最后一个元素补上去


注意Insert和Remove之后需要对size进行增减

## LocalTest-BucketPageSampleTest/HeaderDirectoryPageTest

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220149510.png)

## GradeScope

线上没有对可扩展哈希表的Page类进行测试

# Task #3-Extenable Hashing Implementation

课本中的实现步骤：[Extendible Hash Table](https://zihao256.github.io/p/76b71367.html)

最好也是参考着测试样例来实现

> <span style="color: rgb(13, 13, 13)">Each extendible hash table header/directory/bucket page corresponds to the content (i.e., the </span>`data_` part) of a memory page fetched by the buffer pool.
>
> **Every time you read or write a page, you must first fetch the page from the buffer pool (using its unique **`page_id`**), reinterpret cast it the corresponding type, and unpin the page after reading or writing it.**
>
> We strongly encourage you to **take advantage of the **`PageGuard`** APIs** you implemented in **<u>Task #1</u>** to achieve this.

**假设：**

*   只支持unique keys

**注意：**

*   需要使用Task2中的三种Page类和meta data（page id, global/local depth）来实现基于disk的hash table

*   不允许使用内存数据结构例如unordered\_map

*   take a `Transaction*` with default value `nullptr`.


    template <typename KeyType,
              typename ValueType,
              typename KeyComparator>

*   三种类型在Task #2的`Bucket Pages`中都见过：

    *   `KeyType`:`GenericKey`
    *   `ValueType`:`RID`
    *   `KeyComparator`: 比较两个Key的大小

## 方法实现

### Insert方法

- **Hint**：WritePageGuard只能移动赋值

- 如何获得`WritePageGuard`

  1. **对于已创建的page**：

     1. 开始就直接获得`WritePageGuard`

        ```
        auto raw_page = FetchPage(page_id)
        raw_page.WLatch()
        auto page_guard = WritePageGuard(raw_page)
        auto page = page_guard.AsMut()
        ```

     2. 先获得Basic，后续按需求，再调用`Upgrade`获得`WriteGuard`

  2. **对于新Page**：

     1. 先获得raw_page，然后使用构造函数构造：

        ```
        auto raw_page = NewPage(&page_id)
        raw_page.WLatch()
        auto page_guard = WritePageGuard(raw_page)
        auto page = page_guard.AsMut()
        ```

     2. 先获得Basci，后续按需求调用`Upgrade`获得`WriteGuard`

- 根据Page后续的读写情况决定`FetchWritePageGuard`, `NewWritePageGuard`和`As`, `AsMut`何时以及如何使用

  - **对于已存在的Page**：
    - 后续如果可能对其改动：
      - 初始化获得guard：`FetchWritePageGuard`
      - （未改动时）获得相应种类的Page：`As`
      - （需要改动前）：`AsMut`
    - 后续不会对其改动：
      - 初始化获得guard：`FetchWritePageGuard`+`As`
  - **对于新Page**：
    - 后续可能对其改动：
      - 初始化获得guard：`NewWritePageGuard`
      - （未改动时）获得相应种类的Page：`As`
      - （需要改动前）：`AsMut`
    - 后续不会改动:
      - 初始化获得guard：`NewWritePageGuard`+`As`

- **Hint:**实际上对于新建Page，只需要保证调用`AsMut`将其置为dirty即可，无人与其竞争，因此没必要使用`WriteGuard`保护

### Remove方法

### GetValue方法





## GradeScope要求的功能

> 实现**bucket splitting/merging** and **directory growing/shrinking**

### - \[✅] Empty Table

*   构造函数中新建一个Header Page，并Init
*   通过实现辅助函数`InsertToNewDirectory`和`InsertToNewBucket`来实现按需生成Buckets

### - \[✅] Header Indexing

*   Hash(key)
*   对hash value调用HashToDirectoryIndex

### - \[✅] Directory Indexing

*   Hash(key)
*   对hash value调用HashToBucketIndex

### - \[✅] Bucket Splitting

*   按照课本上的步骤来实现即可

    *   可以通过实现源码中给定的工具函数`UpdateDirectoryMapping`来辅助实现

        *   可能该函数内部调用了`MigrateEntries`函数，但是我并没有实现，直接在`UpdateDirectoryMapping`中实现了Rehash操作
        *   **Hint:**该函数如果直接在Insert中调用的话函数签名中可以自己修改并多传入两个`ExtendibleHTableBucketPage`
            *   `old_bucket_page`：需要进行分裂，并rehash的bucket
            *   `new_bucket_page`：新建的bucket
            *   这样可以不必重新`FetchPage`

### - \[✅] Bucket Merging + [✅]Directory Shrinking

这两个应该在`DiskExtendbleHTable::Remove`方法中一起实现

> Bucket Merging对应于GradeScope的`RecursiveMergeTest`

> Directory Shrinking对应于GradeScope的GrowShrinkTest：只有当dir page包含的所有bucket local depth都小于global depth时

*   Shrink只有当所有的local\_depth\_都小于global\_depth时才进行
    *   在`Task2`中实现了相关操作

根据项目文档，可以得到一个简单版本的`Merging+Shrinking`:

1. 在`ExtendibleHashTableBucketPage::Remove`成功：
   1. （Update——RecursiveMergeTest）**Hint:**首先应该判断此时两个bucket 条目是否指向相同的bucket page，若是则跳过下面的合并过程
   2. 在Bucket为空时：
      1. 判断`dir page`的`global depth`是否为0:
         1. 若是：说明此时`dir page`中没有任何键值对，可以将该dir page删除
            1. 将`dir page`中该bucket page对应的Page项置为无效
            2. 将`header page`中该`dir page`对应的Page置为无效
            3. 结束循环
         2. 若否：开始合并；（Update——GrowShrinkTest）**Hint：**对于合并情况，不需要使用到header page，参考`Crabbing`策略，应该立刻释放header page guard
            1. 删除当前`Bucket Page`
            2. 在`directory page`中将被删除bucket对应的指针/页id置为Image Bucket
            3. 判断local depth是否大于0
               1. 若是将两个Bucket 的local depth减一
                  1. **重要**：接着判断是否可以Shrink，若可以则调用`DecrGlobalDepth`
                     1. （Update——RecursiveMergeTest）：需要根据是否Shrink，来决定下一个while循环Merge的bucket page
                        1. 若需要Shrink，则需要遍历Shrink后的dir page，看是否有empty bucket，若有则while循环Merge
                        2. 若不需要Shrink，则只需要判断image bucket是否为empty bucket，若是则while循环Merge
               2. 若否，则直接跳出循环
   3. 若此时判断Image Bucket也为空，则重复上述合并过程



#### Bug

- [x] 本地测试会有死锁

  - 可以利用`DiskExtendibleHTable::PrintHT`和其他`Page`类的`Print`方法来检查
    - ![image-20231120142020823](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/11/image-20231120142020823.png)

  - [x] solution：是while循环中未设置跳出条件，需要Merging+Shrinking一起实现



### - \[✅] Directory Growing

> 对应于GradeScope的`SplitGrowTest`

- 这里实际上就是Bucket Split时，如果Local Depth大于Globa Depth则Double Directory，在Bucket Split节涉及了
- 无论是本地还是线上测试都没有对Dirctory Split进行要求



本地测试中似乎并没有测试到`Bucket Merging`, `Directory Growing`和`Directory Shrinking`，因此无法验证实现的正确性

## LocalTest-InsertTest/RemoveTest

（Update——RecursiveMergeTest）这里`RemoveTest`测试的比较简单。

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220211309.png)

## GradeScope: ExtendibleHTableTest

通过`PageGuardTest`后，仅剩下以下四个测试未通过：

### - [✅] InsertTest3

```
33: [2381364519534583625] invoke BufferPoolManager: new BPM pool_size-[50] replacer_k-[10]
33: [2381364519534583625] invoke DiskExtendibleHashTable header_max_depth-2 directory_max_depth-3 bucket_max_size-2
33: [2381364519534583625] invoke NewPage
33: [2381364519534583625] invoke NewPage: new_page-0
33: invoke BasicPageGuard: page-0
33: invoke WritePageGuard: page-0
33: invoke AsMut: page-0
33: [2381364519534583625] invoke ~WritePageGuard: this-page-0
33: [2381364519534583625] invoke Drop: this-page-0
33: [2381364519534583625] invoke Drop: page-0
33: [2381364519534583625] invoke UnpinPage: page-0 is_dirty-1
33: [2381364519534583625] page-0 pin_count-0
33: [2381364519534583625] set page-0 evictable
33: [2381364519534583625] set page-0 dirty
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Insert: key= 0 value=0
33: [2381364519534583625] invoke FetchPageWrite: page-0
33: [2381364519534583625] invoke FetchPage: page-0
33: [2381364519534583625] invoke FetchPage: page-0 has been in frame-0
33: invoke BasicPageGuard: page-0
33: invoke WritePageGuard: page-0
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: invoke As: page-0
33: invoke AsMut: page-0
33: [2381364519534583625] invoke InsertToNewDirectory
33: [2381364519534583625] invoke NewPageGuarded
33: [2381364519534583625] invoke NewPage
33: [2381364519534583625] invoke NewPage: new_page-1
33: invoke BasicPageGuard: page-1
33: invoke AsMut: page-1
33: [2381364519534583625] invoke InsertToNewBucket
33: [2381364519534583625] invoke NewPageGuarded
33: [2381364519534583625] invoke NewPage
33: [2381364519534583625] invoke NewPage: new_page-2
33: invoke BasicPageGuard: page-2
33: invoke AsMut: page-2
33: [2381364519534583625] invoke ~BasicPageGuard: page-2
33: [2381364519534583625] invoke Drop: page-2
33: [2381364519534583625] invoke UnpinPage: page-2 is_dirty-1
33: [2381364519534583625] page-2 pin_count-0
33: [2381364519534583625] set page-2 evictable
33: [2381364519534583625] set page-2 dirty
33: [2381364519534583625] invoke ~BasicPageGuard: page-1
33: [2381364519534583625] invoke Drop: page-1
33: [2381364519534583625] invoke UnpinPage: page-1 is_dirty-1
33: [2381364519534583625] page-1 pin_count-0
33: [2381364519534583625] set page-1 evictable
33: [2381364519534583625] set page-1 dirty
33: [2381364519534583625] invoke ~WritePageGuard: this-page-0
33: [2381364519534583625] invoke Drop: this-page-0
33: [2381364519534583625] invoke Drop: page-0
33: [2381364519534583625] invoke UnpinPage: page-0 is_dirty-1
33: [2381364519534583625] page-0 pin_count-0
33: [2381364519534583625] set page-0 evictable
33: [2381364519534583625] set page-0 dirty
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke GetValue
33: [2381364519534583625] invoke FetchPageRead: page-0
33: [2381364519534583625] invoke FetchPage: page-0
33: [2381364519534583625] invoke FetchPage: page-0 has been in frame-0
33: invoke BasicPageGuard: page-0
33: invoke ReadPageGuard: page-0
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~ReadPageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: invoke As: page-0
33: [2381364519534583625] invoke FetchPageRead: page-1
33: [2381364519534583625] invoke FetchPage: page-1
33: [2381364519534583625] invoke FetchPage: page-1 has been in frame-1
33: invoke BasicPageGuard: page-1
33: invoke ReadPageGuard: page-1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~ReadPageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: this-page-0
33: [2381364519534583625] invoke Drop: page-0
33: [2381364519534583625] invoke UnpinPage: page-0 is_dirty-0
33: [2381364519534583625] page-0 pin_count-0
33: [2381364519534583625] set page-0 evictable
33: invoke As: page-1
33: [2381364519534583625] invoke FetchPageRead: page-2
33: [2381364519534583625] invoke FetchPage: page-2
33: [2381364519534583625] invoke FetchPage: page-2 has been in frame-2
33: invoke BasicPageGuard: page-2
33: invoke ReadPageGuard: page-2
33: [2381364519534583625] invoke operator=: this-page--1 that-page-2
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-2
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~ReadPageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: this-page-1
33: [2381364519534583625] invoke Drop: page-1
33: [2381364519534583625] invoke UnpinPage: page-1 is_dirty-0
33: [2381364519534583625] page-1 pin_count-0
33: [2381364519534583625] set page-1 evictable
33: invoke As: page-2
33: [2381364519534583625] invoke ~ReadPageGuard: this-page-2
33: [2381364519534583625] invoke Drop: this-page-2
33: [2381364519534583625] invoke Drop: page-2
33: [2381364519534583625] invoke UnpinPage: page-2 is_dirty-0
33: [2381364519534583625] page-2 pin_count-0
33: [2381364519534583625] set page-2 evictable
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~ReadPageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~ReadPageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Insert: key= 1 value=1
。。。
33: [2381364519534583625] invoke Insert: key= 3 value=3
33: [2381364519534583625] invoke FetchPageWrite: page-0
33: [2381364519534583625] invoke FetchPage: page-0
33: [2381364519534583625] invoke FetchPage: page-0 has been in frame-0
33: invoke BasicPageGuard: page-0
33: invoke WritePageGuard: page-0
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-0
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: invoke As: page-0
33: [2381364519534583625] invoke FetchPageWrite: page-1
33: [2381364519534583625] invoke FetchPage: page-1
33: [2381364519534583625] invoke FetchPage: page-1 has been in frame-1
33: invoke BasicPageGuard: page-1
33: invoke WritePageGuard: page-1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: this-page-0
33: [2381364519534583625] invoke Drop: page-0
33: [2381364519534583625] invoke UnpinPage: page-0 is_dirty-0
33: [2381364519534583625] page-0 pin_count-0
33: [2381364519534583625] set page-0 evictable
33: invoke As: page-1
33: [2381364519534583625] invoke FetchPageWrite: page-3
33: [2381364519534583625] invoke FetchPage: page-3
33: [2381364519534583625] invoke FetchPage: page-3 has been in frame-3
33: invoke BasicPageGuard: page-3
33: invoke WritePageGuard: page-3
33: [2381364519534583625] invoke operator=: this-page--1 that-page-3
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke operator=: this-page--1 that-page-3
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: invoke AsMut: page-3
33: [2381364519534583625] invoke ~WritePageGuard: this-page-3
33: [2381364519534583625] invoke Drop: this-page-3
33: [2381364519534583625] invoke Drop: page-3
33: [2381364519534583625] invoke UnpinPage: page-3 is_dirty-1
33: [2381364519534583625] page-3 pin_count-0
33: [2381364519534583625] set page-3 evictable
33: [2381364519534583625] set page-3 dirty
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page-1
33: [2381364519534583625] invoke Drop: this-page-1
33: [2381364519534583625] invoke Drop: page-1
33: [2381364519534583625] invoke UnpinPage: page-1 is_dirty-0
33: [2381364519534583625] page-1 pin_count-0
33: [2381364519534583625] set page-1 evictable
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: [2381364519534583625] invoke ~WritePageGuard: this-page--1
33: [2381364519534583625] invoke Drop: this-page--1
33: [2381364519534583625] invoke ~BasicPageGuard: page--1
33: [2381364519534583625] invoke Drop: page--1
33: /autograder/source/bustub/test/container/disk/hash/grading_extendible_htable_test.cpp:125: Failure
33: Value of: inserted
33:   Actual: true
33: Expected: false
```

- [x] 在`Insert`函数中输出`key, value`的值，log如上

  - **分析该测试**：对于header_page_depth=2, directory_page_depth=3, bucket_size=2的哈希表，

    - 第一遍依次插入`<0,0>`,`<1,1>`, `<2,2>`,`<3,3>`, `<4,4>`，

    - 第二遍也依次插入上述键值对，插入`<3,3>`时，由于该项目默认只能插入不同key的检值对，因此理应返回`false`，但实际上返回`true`

  - **分析：**

    - 对于`BucketPage::Insert`插入失败有两种原因（桶满或者duplicate key）
    - 当前`DiskExtendibleHashTable::Insert`的错误实现：根据`BucketPage::Insert`返回类型的布尔类型无法区别，因此我仅仅在该函数返回false后又判断`bucket`是否满，
      - 若满则说明是因为满而插入失败，紧接着开始桶分裂
      - 若不满，则说明是因为重复key而失败，直接返回false
    - 上述实现忽略了：既`bucket full`又`duplicate key`的情况

  - [x] **solution:** 因此需要在`DiskExtendibleHashTable::Insert`函数中先调用`DiskExtendibleHashTable::GetValue`来判断是否为重复key，并直接返回false
    - 至于第二遍插入到`<3,3>`时才出错，这也是因为插入前三个key时错误以为是full bucket的情况，因此错误地进行了桶分裂

### - [✅] RecursiveMergeTest

- [x] **BUG**：`36 - ExtendibleHTableTest.RecursiveMergeTest (Subprocess aborted)`
  - 根据打出的日志重现测试用例：
    - 创建HTable：header_depth=1, directory_depth=2, bucket_size=2
    - 依次插入：`<4,0>`,`<5,0>`,`<6,0>`和`<14,0>`
    - 接着删除`<5>`,`<14>`, `<4>`
    - 判断`GlobalDepth == 0`
  - 果然本地运行后一直循环
  
  - [x] **solution：** 
  
    - 原来是在合并前，忘记判断此时`local_depth`是否等于`global_depth`，即此时`directory_bucket`中两个bucket条目是否分别指向不同的Page。
      - 因此需要在合并前判断，若是则不需要合并
  
    - [x] **BUG：**在完成上述代码后，GradeScope卡死
      - 分析：`Insert`中Bucket Split的逻辑有些问题，循环后插入的桶选的有问题
    - [x] **BUG：** `GlobalDepth`为2而非0
      - [x] 分析：`Merge`逻辑有问题，删除`<5>`后该如何处理？
      - [x] **solution:** 根据Merge后是否需要Shrink，来分两种情况处理：
        1. 若需要Shrink，则需要遍历Shrink后的dir page，看是否有empty bucket，若有则while循环Merge
        2. 若不需要Shrink，则只需要判断image bucket是否为empty bucket，若是则while循环Merge



### - [✅] SplitGrowTest

- [x] **BUG:**

- ```
  39: [  FAILED  ] ExtendibleHTableTest.SplitGrowTest (2055 ms)
  39: [----------] 1 test from ExtendibleHTableTest (2055 ms total)
  39: 
  39: [----------] Global test environment tear-down
  39: [==========] 1 test from 1 test suite ran. (2055 ms total)
  39: [  PASSED  ] 0 tests.
  39: [  FAILED  ] 1 test, listed below:
  39: [  FAILED  ] ExtendibleHTableTest.SplitGrowTest
  39: 
  39:  1 FAILED TEST
  1/1 Test #39: ExtendibleHTableTest.SplitGrowTest ...***Failed    2.09 sec
  
  0% tests passed, 1 tests failed out of 1
  
  Total Test time (real) =   2.13 sec
  
  The following tests FAILED:
  	 39 - ExtendibleHTableTest.SplitGrowTest (Failed)
  Errors while running CTest
  ```

  - **分析：** （Update——GrowShrinkTest）概率是插入的问题，因为日志中并没有Remove相关日志。有些很奇怪的现象：
    
    - 并且明明只需要插入512个键值对，却在日志中看到了page-651。很可能是Bucket Split的问题
    - 并且日志最后一直调用`FetchPageBasic`（大几百的page id），但是实际上DiskExtendible中并没有调用该函数
  - **复现：** 
    
    - HTable初始化：bpm-pool_size=4, header_max_depth=9, directory_max_depth=9, bucket_max_size=511
    - 依次插入: <0,0> 到 <511,511>
  - **solution**：实际上日志中**打印的行很多但是信息很少**，取消BPM和PageGuard的日志打印，只打印ETH的插入删除和查找，并且打印出ETH的初始条件
  
    ```
    39: Note: Google Test filter = ExtendibleHTableTest.SplitGrowTest
    39: [==========] Running 1 test from 1 test suite.
    39: [----------] Global test environment set-up.
    39: [----------] 1 test from ExtendibleHTableTest
    39: [ RUN      ] ExtendibleHTableTest.SplitGrowTest
    39: [12573574369822553037] invoke DiskExtendibleHashTable header_max_depth-9 directory_max_depth-9 bucket_max_size-511 pair<K,>-8
    39: [12573574369822553037] invoke Insert: key= 0 value=0
    39: [12573574369822553037] invoke GetValue: key= 0 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-0: 
    39: [12573574369822553037] invoke InsertToNewDirectory
    39: [12573574369822553037] invoke InsertToNewBucket
    39: [12573574369822553037] invoke GetValue: key= 0 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-1: 0
    39: [12573574369822553037] invoke Insert: key= 1 value=1
    39: [12573574369822553037] invoke GetValue: key= 1 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-0: 
    39: [12573574369822553037] invoke GetValue: key= 1 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-1: 1
    39: [12573574369822553037] invoke Insert: key= 2 value=2
    39: [12573574369822553037] invoke GetValue: key= 2 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-0: 
    39: [12573574369822553037] invoke GetValue: key= 2 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-1: 2
    ...
    39: [12573574369822553037] invoke GetValue: key= 139 pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511
    39: GetValue-1: 139
    39: [12573574369822553037] invoke Insert: key= 140 value=140
    39: [12573574369822553037[...(truncated)...] slot_num: 215
    39: 
    39: [12573574369822553037] invoke GetValue: key= 216 pair<K,V>-72 header_max_depth-9 directory_max_depth-9 bucket_max_size_56
    39: GetValue-1: page_id: 0 slot_num: 216
    ...
    39: [12573574369822553037] invoke GetValue: key= 255 pair<K,V>-72 header_max_depth-9 directory_max_depth-9 bucket_max_size_56
    39: GetValue-1: page_id: -1 slot_num: 0
    39: 
    39: /autograder/source/bustub/test/container/disk/hash/grading_extendible_htable_test.cpp:459: Failure
    39: Expected equality of these values:
    39:   value
    39:     Which is: page_id: 0 slot_num: 255
    39: 
    39:   res[0]
    39:     Which is: page_id: -1 slot_num: 0
    39: 
    39: 
    39: [12573574369822553037] invoke GetValue: key= 256 pair<K,V>-72 header_max_depth-9 directory_max_depth-9 bucket_max_size_56
    39: GetValue-1: page_id: 0 slot_num: 256
    ...
    39: [4066364812871771751] invoke GetValue: key= 499
    39: GetValue-1: page_id: 0 slot_num: 499
    39: 
    39: [  FAILED  ] ExtendibleHTableTest.SplitGrowTest (1642 ms)
    39: [----------] 1 test from ExtendibleHTableTest (1642 ms total)
    39: 
    39: [----------] Global test environment tear-down
    39: [==========] 1 test from 1 test suite ran. (1642 ms total)
    39: [  PASSED  ] 0 tests.
    39: [  FAILED  ] 1 test, listed below:
    39: [  FAILED  ] ExtendibleHTableTest.SplitGrowTest
    39: 
    39:  1 FAILED TEST
    1/1 Test #39: ExtendibleHTableTest.SplitGrowTest ...***Failed    1.68 sec
    ```
  
    - **分析**：此时可以看到实际上测试如下进行，分别创建了两种类型的ETH进行测试：
      - 首先，创建第一种类型的ETH：`pair<K,V>-8 header_max_depth-9 directory_max_depth-9 bucket_max_size_511`
        - 依次插入<0,0> ... <511,511>个键值对，每次插入后GetValue验证
      - 接着，创建第二种类型的ETH：`pair<K,V>-72 header_max_depth-9 directory_max_depth-9 bucket_max_size_56`
        - 通过打印的K+V大小为72，并且V类型为RID=8Bytes，可以判断K类型大小为64Bytes
        - 因此依次插入递增的<64Bytes, RID>键值对
        - 接着，又直接GetValue(499)，此时出错
    - **solution**：在本地复现上述测试
      - 分析：发现是BucektPage的Remove/Insert等方法实现有问题：
        - 遍历上限使用max_size_，并且没有在删除后对数组重新组织，也就是说对数组的维护几乎为零，因此可能遍历到初始化为默认值的键值对。
        - 这里就有个问题：当key值恰好等于默认值的数组，此时错误的以为该key存在于Bucket中
      - 因此，只需要将Bucketpage的Insert/LookUp/Remove/RemoveAt的遍历上限都设置为Size()，并且每次删除后都都数组进行调整：将当前键值赋值为默认值，然后将其与最后一个键值对swap即可



### - [✅] GrowShrinkTest

**Hint：**该测试需要注意`BufferPoolManager: new BPM pool_size-[3] replacer_k-[10]`，pool size仅仅为3，因此在并发安全的前提下需要确保同一时间持有page guard的数量，特别是在Insert函数中针对Bucket Split的情况。

- 这里我是一开始就使用了课程中提到的`Crabbing`策略，即在获得下一层的Page后立刻释放父层的Page，因此并没有遇到该问题

我的问题如下：

- [x] **BUG：**

- ```
  40: [AddressSanitizer:DEADLYSIGNAL
  40: =================================================================
  40: ==15095==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000008 (pc 0x55da00abfec1 bp 0x7fff2102aab0 sp 0x7fff2102aa90 T0)
  40: ==15095==The signal is caused by a READ memory access.
  40: ==15095==Hint: address points to the zero page.
  40:     #0 0x55da00abfec1 in bustub::Page::GetPageId() /autograder/source/bustub/src/include/storage/page/page.h:46:49
  40:     #1 0x55da00b4e13a in bustub::BasicPageGuard::BasicPageGuard(bustub::BufferPoolManager*, bustub::Page*) /autograder/source/bustub/src/include/storage/page/page_guard.h:25:5
  40:     #2 0x55da00b4e1a8 in bustub::ReadPageGuard::ReadPageGuard(bustub::BufferPoolManager*, bustub::Page*) /autograder/source/bustub/src/include/storage/page/page_guard.h:130:55
  40:     #3 0x55da00b4b0c1 in bustub::BufferPoolManager::FetchPageRead(int) /autograder/source/bustub/src/buffer/buffer_pool_manager.cpp:410:20
  40:     #4 0x55da00b7155b in bustub::DiskExtendibleHashTable<int, int, bustub::IntComparator>::Remove(int const&, bustub::Transaction*) /autograder/source/bustub/src/container/disk/hash/disk_extendible_hash_table.cpp:396:61
  40:     #5 0x55da00aaf5fc in void bustub::GrowShrinkTestCall<int, int, bustub::IntComparator>(int, int, bustub::IntComparator) /autograder/source/bustub/test/container/disk/hash/grading_extendible_htable_test.cpp:539:8
  40:     #6 0x55da00a9d1d7 in bustub::ExtendibleHTableTest_GrowShrinkTest_Test::TestBody() /autograder/source/bustub/test/container/disk/hash/grading_extendible_htable_test.cpp:608:3
  40:     #7 0x55da00c9dd2e in void testing::internal::HandleExceptionsInMethodIfSupported<testing::Test, void>(testing::Test*, void (testing::Test::*)(), char const*) /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:2670:12
  40:     #8 0x55da00c4a6cc in testing::Test::Run() /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:2687:5
  40:     #9 0x55da00c4c554 in testing::TestInfo::Run() /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:2836:11
  40:     #10 0x55da00c4dd77 in testing::TestSuite::Run() /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:3015:30
  40:     #11 0x55da00c71989 in testing::internal::UnitTestImpl::RunAllTests() /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:5920:44
  40:     #12 0x55da00ca4453 in bool testing::internal::HandleExceptionsInMethodIfSupported<testing::internal::UnitTestImpl, bool>(testing::internal::UnitTestImpl*, bool (testing::internal::UnitTestImpl::*)(), char const*) /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:2670:12
  40:     #13 0x55da00c70cc2 in testing::UnitTest::Run() /autograder/source/bustub/third_party/googletest/googletest/src/gtest.cc:5484:10
  40:     #14 0x55da00cfe2c0 in RUN_ALL_TESTS() /autograder/source/bustub/third_party/googletest/googletest/include/gtest/gtest.h:2317:73
  40:     #15 0x55da00cfe251 in main /autograder/source/bustub/third_party/googletest/googlemock/src/gmock_main.cc:71:10
  40:     #16 0x7f5e188b5d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
  40:     #17 0x7f5e188b5e3f in __libc_start_main csu/../csu/libc-start.c:392:3
  40:     #18 0x55da009ce824 in _start (/autograder/source/bustub/build/test/grading_extendible_htable_test+0x63824) (BuildId: dcdd5fa2c6c086b92a05090ca5692ce4b4af5cab)
  40: 
  40: AddressSanitizer can not provide additional info.
  40: SUMMARY: AddressSanitizer: SEGV /autograder/source/bustub/src/include/storage/page/page.h:46:49 in bustub::Page::GetPageId()
  40: ==15095==ABORTING
  1/1 Test #40: ExtendibleHTableTest.GrowShrinkTest ...***Failed    1.66 sec
  ```

  - **分析：**根据前面几行，似乎是`DiskExtendibleHTable::Remove`方法中调用`FetchReadPage`读入的Page：不存在或者是死锁
  - **复现：**
    - HTable初始化：bpm-pool_size=3, header_max_depth=9, directory_max_depth=9, bucket_max_size=511
    - 依次插入: <0,0> 到 <511,511>
    - 依次删除：<0,0> 到<511, 511>
    - 删除到496时报如上错误
    - 本地测试：删除到510会报错
      - `DiskExtendibleHTable::Remove`方法中对PageId为3的调用了`FetchPageRead`，内部调用的`fetchpage`返回为nullpter，但是实际上Page=3是创建过的
      - 紧接着`FetchPageRead`调用了`BasicGuard`、`ReadPageGuard`、`WritePageGuard`的默认构造函数，其中`PGG_LOG`使用时直接调用了传入page的GetPageId函数，忘记考虑nullptr情况

  - [x] **Solution: **
    - 一开始实现的时候就对`DiskExtendibleHTable::Remove`使用`Crabbing`策略来确保同一时间持有的page guard数量，但是疏忽了`Bucket Merge`的情形，因为针对该if分支并没有使用到header page，可以立刻释放header page。
    - 因此解决方法就是：实现`Crabbing`于`DiskExtendibleHTable`的所有方法，以确保同时拥有的page guard数量小于等于3，因为本项目实现的ExtendibleHTable就是三层级，一个线程最多持有三个层的一个Page



- [x] **BUG：**解决上述问题后变成了和`SplitGrowTest`一样的问题：

  - ```
    40: [  FAILED  ] ExtendibleHTableTest.GrowShrinkTest (13554 ms)
    40: [----------] 1 test from ExtendibleHTableTest (13554 ms total)
    40: 
    40: [----------] Global test environment tear-down
    40: [==========] 1 test from 1 test suite ran. (13555 ms total)
    40: [  PASSED  ] 0 tests.
    40: [  FAILED  ] 1 test, listed below:
    40: [  FAILED  ] ExtendibleHTableTest.GrowShrinkTest
    40: 
    40:  1 FAILED TEST
    1/1 Test #40: ExtendibleHTableTest.GrowShrinkTest ...***Failed   13.66 sec
    
    0% tests passed, 1 tests failed out of 1
    
    Total Test time (real) =  13.87 sec
    
    The following tests FAILED:
    	 40 - ExtendibleHTableTest.GrowShrinkTest (Failed)
    Errors while running CTest
    ```

  - **分析：**大概率是插入的问题，因为日志中并没有Remove相关日志，并且明明只需要插入512个键值对，却在日志中看到了page-651，这很奇怪。大概率是Bucket Split的问题
  
  - **solution**：和SplitGrowTest问题一样，都是BucketPage对bucket数组的初始化默认值+Remove/Insert/LookUp的遍历上限有问题，修复后两个测试均通过



![image-20231211142359077](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/12/image-20231211142359077.png)

# Task #4-Concurrency Control

> *   **Latch Crabbing**
>
>     *   The thread traversing the index should acquire latches on hash table pages as necessary to ensure safe concurrent operations, and should release latches on parent pages as soon as it is possible to determine that it is safe to do so.

> We recommend that you complete this task by using the `FetchPageWrite` or `FetchPageRead` buffer pool API

> **<span style="color: rgb(13, 13, 13)"><span style="background-color: #ff666680">Note</span>:</span>**<span style="color: rgb(13, 13, 13)"> You should never acquire the same read lock twice in a single thread. It might lead to deadlock.</span>
>
> **<span style="color: rgb(13, 13, 13)"><span style="background-color: #ff666680">Note</span>:</span>**<span style="color: rgb(13, 13, 13)"> You should make careful design decisions on latching.</span>
>
> *   <span style="color: rgb(13, 13, 13)">Always holding a global latch the entire hash table is probably not a good idea.</span>

## PageGuard

`Insert`

*   的BasicPage尽量替换WritePageGuard，先不用Read；

`GetValue`：

*   可以全部使用ReadGuard

`Remove`:

*   只需要对bucket page使用write guard

需要使用`Latch Crabbing`策略来尽快而又安全地释放父Page的Latch

*   **Crabbing**：（Update——GrowShrinkTest）这对于通过`GrowShrinkTest`至关重要，因为该测试中pool size只有3，因此必须确保在Insert分裂情况时，所持有的page guard数量小于等于3.
*   先获得header page的page guard
    
*   然后尝试获得directory page的page guard
    
    *   若成功获得，确保不会用到header时，再释放header page的page guard
    
*   尝试获得bucket page的page guard
    
    *   若成功获得，确保不会用到directory时，释放directory page的page guard

## LocalTest

### ExtendibleHTableTest

先尝试通过单线程，验证实现`Insert`，`Remove`和`GetValue`不会使得一个线程对同一个page死锁

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220232058.png)

### ExtendibleHTableConcurrentTest

#### InsertTest1

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220240883.png)

##### BUGs

* \- [✅] BUG

  *   在Project #1中图方便，在NewPage直接使用了一把函数粒度的递归锁lock\_guard

  *   导致有一种死锁的可能：

      *   线程一先调用Insert，并通过调用FetchWritePage获得了page0（即header page ）的WLatch

      *   线程二后调用Insert，也尝试通过调用FetchWritePage获得page0，但是进入到FetchPage后尝试获取page0的WLatch失败，只能waiting

          *   注意，此时线程二拿到了BPM的递归锁lock\_guard

      *   线程一继续完成Insert：尝试InsertToNewDirectory时，内部也尝试调用NewWritePage获得bpm的递归锁。

      *   最终导致了DeadLock

  *   **solution**: 将lock\_guard换为unique\_mutex，并手动在获得Page的Latch之前解锁，在Unlatch之后加锁

      *   \- \[✅] 新BUG

          *   **描述**：使用该方法会导致BPM的并发问题，可能是unlock之后被其他线程修改了相应的部分

          *   **solution:** 能确保BPM100分
      *   不使用递归锁，不主动unlock，
              *   只对NewPage, FetchPage和DeletePage加锁，
              *   并且在FetchPage中处理已经在bufferpool情况的分支中不对Page加锁
      
  *   <span style="background-color: #ff666680">- [✅] 新BUG</span>
          
      *   **描述：**
          
          *   线程一:Insert->WritePageGuard.Drop->guard.Drop->Unpin(is\_dirty=true)——waiting在Unpin获得BPM的latch步骤
          
          *   线程二: Insert->FetchWritePageGuard->FetchPage——正在FetchPage中尝试读出某页的数据
          
              *   报出异常，读出的位置为空数据
          
      *   <span style="background-color: #2ea8e580">尝试LogOut:</span>
          
          *   page id>50即超过了buffer pool的大小，某次新建page会导致evcit时，会有之前某个dirty page并没有flush回disk
                  *   某次NewPage时，并没有将该dirty page flush回disk，可能是UnPinPage时没有标志is\_dirty\_
          
      *   **<span style="background-color: #5fb23680">可能solution</span>**：
          
          *   不使用UpgradeWrite，该函数实现有问题，并没有在Upgrade期间对pin\_count\_++，导致drop中Unpin中不会将其的is\_dirty写入到page的metadata中
      
  *   <span style="background-color: #ff666680">- [✅] 新BUG</span>
          
      *   **描述：**
          
          *   死锁
          
      *   <span style="background-color: #2ea8e580">尝试Log Out线程编号：可以使用</span>`std::hash(std::this_thread::get_id())`返回当前线程的id（hash后）
          
          *   ![logs](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220305729.png)
          
          *   Debug过程中发现`UnpinPage`函数在unpin page0（即header page），对其内部使用Page的读写锁是多此一举的，由于判断pin\_count的目的就是判断是否有多线程正在使用该Page（读或者写）。通过BPM的线上测试也能证实这一点
          
              *   并且将Page锁去除后，该BUG消失
          
          *   这时才想起来`header_page_guard.AsMut`函数内部会访问Page的Data
          
          *   推测是两个线程在UnpinPage和AsMut中思索了？？？
          
      *   **solution**：
          
          *   去除UnpinPage内部的Page锁
  
* \- \[✅] 误以为不会有non-unique key，原先处理由non-unique key导致的插入失败，直接throw了

  * > For this semester, the hash table is intend to support only unique keys. This means that the hash table should return false if the user tries to insert duplicate keys.

  * **solution**: 返回false

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220320327.png)

#### InsertTest2

Pass in one go !

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220329961.png)

#### DeleteTest1

in one go +2 !!

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220341169.png)

#### DeleteTest2

in one go +3 !!!

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/8ENSYGV8.png)

#### MixTest1

in one go +4 !!!!

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220419956.png)

#### MixTest2

in one go +5 !!!!!

![local test](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/10/image-20231030220431772.png)



## GradeScope: ExtendibleHTableConcurrentTest

第一次提交时，便都通过了并发的相关测试

![image-20231211142421415](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/12/image-20231211142421415.png)



# Optimization

最终通过了AG，但是很明显效率很低，可能与Project#1的实现有关，等后续再对其进行优化

![image-20231211143337147](https://cdn.jsdelivr.net/gh/ZiHao256/Gallery@master/uPic/2023/12/image-20231211143337147.png)
