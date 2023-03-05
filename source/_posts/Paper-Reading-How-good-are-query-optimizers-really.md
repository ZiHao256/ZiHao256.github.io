---
title: 'Paper Reading: How good are query optimizers, really?'
toc: true
categories:
  - 个人提升
  - Paper Reading
tags:
  - Database
  - Cardinality Estimation
  - Cost Model
  - Search Space
abbrlink: e547f891
date: 2023-03-04 22:25:09
---

# Title

“How Good Are Query Optimizers, Really?” (Leis 等, 2015, p. 204) 「
查询优化器到底有多好？
大概就是通过比较查询优化器的有无时，查询执行的性能，来得到查询优化器对性能提升的程度
」

# Abstract

“ABSTRACT” (Leis 等, 2015, p. 204) 「
摘要：

Background：
找到好的连接次序，对于查询性能的提升很重要

Why：
引入 JOB，并使用复杂、真实的查询在传统优化器架构下 实验性地 测试优化器的主要组件。

What：
如上，就是测试优化器的主要组件：

1. 基数估计器
2. 代价模型
3. 计划枚举技术：穷举动态规划算法和启发性算法


How：
通过引用 Join Order Benchmark，使用复杂真实多连接的查询

Novelty：
引入JOB新的基准测试？



Conclusion：

1. **cardinality estimators**：所有的都会出现大错误，并且如果查询引擎过于依赖他们，查询性能将不会很好
2. **cost model**：比 Cardinality estimator 对于查询性能的影响小
3. **plan enumeration**：在有次优cardinality estimates的情况下，穷举动态规划算法比启发式算法效果好。



# 1 Introduction

#    」

“INTRODUCTION” (Leis 等, 2015, p. 204) 「
引言
background：
找到一个**好的连接次序**是数据库领域研究最多的问题。

Why：
如摘要所说，使用真实复杂的工作负载，**测试传统的优化器架构中三个组件**对查询性能的提高程度。


What：
进行测试，对三个组件进行**量化**，借此来为完整的优化器设计提供思路。


How：

引入新的基准测试JOB，使用复杂真实的工作负载和查询。
文章的贡献——

1. 设计了JOB，挑战性的工作负载
2. 首次对连接次序问题提出端到端的研究
3. 量化三个组件的贡献，提供设计优化器的指导方针



Novelty：

1. 新颖的方法：能够**单独**测试出优化器每个组件对查询性能的影响
2. 专注于**越来越平凡的内存场景**：所有数据都装入了RAM



Conclusion：
如摘要中的Conclusion所示。
」

# 3 Cardinality Estimation

“CARDINALITY ESTIMATION” (Leis 等, 2015, p. 206) 「
基数估计是找到一个好的查询计划最重要的组件，没有好的基数估计，连接次序枚举和代价模型都无用。
这一小节通过比较 估计的基数 和 真实的基数，来调查关系数据库系统中的质量。
」

## 3.1 Estimates for Base Table

### Base Table?

“Base Tables” (Leis 等, 2015, p. 207) 「
基表：实际存在于数据库中的表
查询表：查询结果对应的表
视图表：由基本表和其他视图表导出的表，为虚表，不对应实际存储的数据。

基表的性质：

1. 列是同质的，即每一列中的分量都是同一类型的数据，来自同一个域



2. 不同的列可以来自同一个域，每一列又称之为属性，不同的属性要有不同的属性名



3. 列的顺序无关紧要



4. 行的顺序也无关紧要
5. 任意两个元组的候选码不能取相同的值
6. 分量必须要取原子值，即一个表中的某一项不能再拆成好几项

」



“Estimates for Base Tables” (Leis 等, 2015, p. 207) 「
基表：实际存在于数据库中的表
使用 q-error 来衡量基表基数估计的质量。公式为 ｜估计值/实际值｜，是一个大于等于1的比率值。

观察基表选择的 q-error 值，得出以下结论：
**DBMS A和Hyper——**
估计具有复杂谓词（Like） 基表选择 的基数很准，因为估计基表的选择率时，使用了样本法（1000）。但是因为样本太小，对于选择率很小（10^-5）的情况，就会导致很大的选择性估计误差。

**其他的数据库系统——**
表现更差，基于了每个属性的直方图，但是基于直方图的基数估计对于复杂的谓词并不是很有效，也无法检测出属性之间的联系。
」



## 3.2 Estimates for Joins

“Estimates for Joins” (Leis 等, 2015, p. 207) 「
本节的实验结果并不能说明相应系统的优化器不够好，因为查询的性能还依赖于优化器是如何使用和信任这些估计数据的。


**为连接做基数估计：**
背景：样本法和直方图 对于连接中间结果的估计并没有很有效。

**实验结果**：

1. 每个系统对 估计误差的 差异差不多，并且都不是很理想
2. 所有系统都倾向于 低估了多连接查询的结果大小



**改进**：

可以像 DBMS A，使用阻尼因子来减少这种低估的程度。
」



## 3.3 Estimates for TPC-H

“Estimates for TPC-H” (Leis 等, 2015, p. 208) 「
TPC-H：针对 OLAP 场景的测试

TPC-C： 针对 OLTP 的场景的测试
TPC-H 的工作负载对于系统的基数估计器并没有多大挑战，文章引入的 JOB 查询集合可以满足。
」



## 3.4 Better Statistics for PosgreSQL

“Better Statistics for PostgreSQL” (Leis 等, 2015, p. 208) 「
对照试验表明，对于 distinct counts 的估计误差对于基数估计误差的影响较小，相反由于distinct counts 的误差会导致基数估计的值更大一些，这使得 负负得正。。。
」



# 4 When do bad cardinality estimates lead to slow queries?

## 4.1 The Risk of Relying on Estimates

“The Risk of Relying on Estimates” (Leis 等, 2015, p. 209) 「
依赖基数估计的**风险：**
由于PostgreSQL的优化器纯粹基于代价**，**不考虑基数估计的内在不确定性和不同算法选择的渐近复杂。



1. 查询执行没有在合理时间内完成：由于基数低估过于频繁，导致优化器会冒着高风险来选择低收益的嵌套循环连接；
2. 还有一部分查询的执行时间比最优计划的时间多十倍：因为基数低估导致hash连接的hash表大小被低估


」



## 4.2 Good Plans Despite Bad Cardinalities

“Good Plans Despite Bad Cardinalities” (Leis 等, 2015, p. 209) 「
理论上，有着不同的连接顺序的计划的查询执行时间会在量级上不同，但是当只有主键索引并且嵌套循环连接禁止、hash冲计算启用后，大多数查询的性能会很接近最优计划的性能：
原因有二——

1. 只有主键索引，没有外键索引，这导致大多数表只能用全表扫描，这对于表连接顺序的影响很小



2. 主存足够大，装入了所有的索引和数据。。。。


」

## 4.3 Complex Access Paths

“Complex Access Paths” (Leis 等, 2015, p. 210) 「
整体性能普遍提高了，但是随着可用索引的逐渐增多，查询优化器的工作也越来越困难

」

## 4.4 Join-Crossing Correlations

## 

“Join-Crossing Correlations” (Leis 等, 2015, p. 210) 「

背景：
对于单表，对于存在有相互关系谓词的查询，使用样本可以得到较准确的技术估计。
对于多表连接，来自不同的表的连接查询有 **相互关系的谓词** 所包含的列 ，由连接来连接。

」

“DBLP case,” (Leis 等, 2015, p. 210) 「
例子：
`SELECT COUNT(*) FROM Authors, Authorship, Papers WHERE Authorship.author = Author.author AND Authorship.venue = "VLDB"`

对于这个例子，
**一般**：需要先进行表的连接，然后在进行过滤；
**特殊物理设计：**将Authorship中的物理设计根据Paper.venue进行划分，这样在连接发生之前，就可以将过滤隐性的进行。


**优点**：可以避免中间结果无关数据过多。

」

# 5 Cost Models

与Cardinality estimation error相比，cost models对性能的影响很小。。



# 6 Plan Space

“PLAN SPACE” (Leis 等, 2015, p. 212) 「
**最后一个重要的优化器组件**——一个计划枚举算法（探索 **语义等价的连接次序** 计划空间）

1. 全面探索——DP
2. 启发式


**这个章节的目的：**
找到需要**多大的搜索空间**，才能找到一个好的计划

」

## 6.1 How Important is the Join Order

“clearly illustrate the importance of the join ordering problem” (Leis 等, 2015, p. 213) 「
从这张代价分布图：

1. 最优计划的代价比最慢/中位的代价快了几个数量级
2. 不同查询的代价分布很不同
3. 外键+主键 这种索引配置的最优代价比其他配置快不少。

」

“highlight the dramatically different search spaces of the three index configurations.” (Leis 等, 2015, p. 213) 「
不同的 索引配置，其对应的搜索空间也很不同：

1. 有外键索引的配置，搜索空间更偏向于最优计划的代价（1.5X）
2. 有外键的索引配置：搜索空间的代价更宽泛


」



## 6.2 Are Bushy Trees necessary

“Are Bushy Trees Necessary?” (Leis 等, 2015, p. 213) 「
本章节要解决的问题：多枝树是否有必要？

**连接树形——**
**左深树**：

1. 连接树的每个连接算子的右子节点都一定是一个基表
2. NLJ 的连接树只可能是左深树



**右深树**：

1. 连接树的每个连接算子的左子节点都一定是一个基表
2. HJ 和 Sort-Merge Join的连接树有可能是右深树
3. 哈希连接为右深树时，会同时有多个表被做成Hash表，从而消耗过多的PGA


**锯齿形树（zig-zag trees）：**

1. 连接树的每个连接算子的左右子节点中，至少有一个基表。



**浓密树（bushy trees）：**

1. 连接树的每个连接算子的左右子节点可能都不是基表，结构为安全自由
2. 优化器无法选择其他树形时，才会选择浓密树
3. 一般当查询包含 子查询/视图，可能产生浓密树。

\---


**连接树的处理规则：**

・从**最左端的叶节点**开始处理

・左节点的处理**优先级高**于右节点

・**左节点驱动右节点**

・子节点在父节点之前进行处理

・子节点处理完获得的**数据返回给父节点。**
\---


**限制条件和连接条件——**
**注：限制条件可在连接条件之前执行**
限制条件：

1. 两个数据集通过连接条件进行连接，Where中（传统）或者From中（ANSI 标准）



连接条件：

1. 在连接返回的结果集上应用限制条件（传统和ANSI 标准）
2. 防止出现 交叉乘积连接


\---



**连接类型——**
**Nested-Loop Join ：**

1. 左子节点为外部循环，右子节点为内部循环
2. 对于左子节点的每一条记录，右子节点都要执行一次连接条件和限制条件。

2.1 外部循环只执行一次
2.2 内部循环执行多次

3. 在所有数据执行完之前，就可以获得结果集的第一条记录
4. 可以利用索引来高效连接


**Hash Join：**
1.


**Sort-Merge Join：**

1. 每个输入数据集都必须先按照连接条件的字段进行排序
2. 每个输入数据集只执行一次
3. 在所有数据执行完之后，才能获得第一条记录


」

## 6.3 Are Heuristics Good Enough

“Are Heuristics Good Enough?” (Leis 等, 2015, p. 213) 「
**启发式算法 足够好吗？**

在技术估计质量不好的情况下，比较：

1. 全面的动态规划：exhaustive dynamic programming



2. 随机化的启发式：QuickPick-1000
3. 贪婪的启发式：Greedy Operator Ordering



归一化，用真实的基数使用动态规划得到真实最优计划的代价，得到结**论**：

1. 尽管存在技术估计误差，使用 全面的动态规划 算法，来全面地检查 搜索空间 是很值得的
2. 好的 基数估计 的性能潜力，会提高性能
3. 考虑到，为 **数十个表连接的查询** 找到最优计划，是**存在 全面的枚举算法**：因此很少有需要诉诸于 **禁用浓密树和启发式算法** 的情况。

」
