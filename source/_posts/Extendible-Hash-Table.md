---
title: Extendible Hash Table
toc: true
categories:
  - 学无止境
  - CMU15-445(2023FALL)
tags:
  - Container
  - 数据结构
abbrlink: 76b71367
date: 2023-10-29 21:42:15
---

Extendible Hash Table

- **hash function**

  - 对于给定key生成32bit的值
- **bucket address table**

  - 对于每个32bit的hash value，都有一个table entry相对应
  - 但在某一时刻该table的实际使用大小由global prefix控制
- **global prefix：用于生成global mask**

  - 在实际使用时，global prefix用于控制当前bucket address table实际使用的大小

    - 具体为2^(global prefix)个条目
- **local prefix：用于生成local mask**

  - 不会为所有hash value都生成一个bucket，而是按需生成
  - 用于判断当前table entry指向的bucket
  - 如果local prefix == glocal prefix：

    - 则说明只有该entry拥有指向的bucket
  - 按需体现在local prefix < global prefix:

    - 拥有相同local prefix的entry指向同一个bucket

# Lookup

**for lookup：**  

1\. 对K进行hash，得到b个 bits序列  
2\. 通过b bits的leftmost prefixe i，找到对应的table entry  
3\. 遍历对应entry指向的bucket，找到对应于K的record

# Insertion

**for insertion:**

1\. 首先按照lookup步骤找到对应的bucket

2\. 查看bucket是否full

​	2.1 若非full，则处理比较简单，

​	2.2 否则，比较bucket对应的i_j，和table prefix i，做出后续两种处理方式

## i == i_j

**说明：**bucket address table中只有一个entry指向i_j对应的bucket，需要增加bucket address table中的size（可用entry 数量）和buckets数量  
**split步骤：**  
1\. **prefix ++：**使得table中可用的entry数量扩展为原先的两倍  
2\. **replace each entry with two entries:** 此时，每两个entry包含的pointer都指向同一个bucket  
3\. **allocate new bucket and set second entry to ponit to the new bucket**  
**4\. rehash all record in old buckets**  
**5\. reattempt the insertion of the new record**  

- **success：大部分情况**  
- **failure：**如果在old bucket中的record和new record的前prefix个bit仍然相同，会导致old bucket仍然overflow  
     - 需要再次split / 使用overflow buckets like static hashing


## i > i_j

**说明：**按照上述data structure的描述，说明bucket address table中有多个entries指向i_j对应的bucket。  
- **i_j:** 代表bucket address table中leftmost i_j bits相同的entries，指向j bucket  
- 代表此时database中，该buckets split的速度不是最快的，其他buckets的split导致prefix i>i_j。  



- **split 步骤：**不需要扩展prefix，因为bucket address table足够大  
  1\. **allocate new bucket_z, set i_j and i_z with (original i_j + 1)**  
  **2\. adjust the entries in the table:** 由于调整了i_j和i_z，自然entries在leftmost i_j会不同，因此entries应该按照leftmost i_j来指向两个buckets  
  3\. **rehash records in bucket_j**  
  **4\. reattempt the insert:** 可能会failure，同上处理

# Deletion

**1\. remove both search key and record。如果此时bucket empty，则将bucket删除**  
**2\. 在某种情况下，buckets可以合并，并且table size可以缩减为原来的一半**
