---
title: 'Paper Reading: Robustness metrics for relational query execution plans'
toc: true
categories:
  - 学无止境
  - Paper Reading
tags:
  - Database
abbrlink: 7091acdb
date: 2023-03-04 22:09:28
---
# 笔记

本篇文章的两个核心内容：

“three novel metrics for the robustnes” (Florian Wolf 等, 2018, p. 1360)：三个健壮性指标（关于基数估计误差），用于衡量qep的健壮性。适用性很强：

“all kinds of operators, operator implementations, query execution plan trees, and monotonically increasing and differentiable cost function” (Florian Wolf 等, 2018, p. 1361) 支持各种运算，运算的物理实现，查询执行计划树以及单调递增和可微分的代价函数

“a novel plan selection strategy that takes both, estimated cost and estimated robustness into account, when choosing a plan for execution” (Florian Wolf 等, 2018, p. 1360)：根据三个指标权衡 估计的代价 和 估计的健壮性，来选择要执行的计划。

# 2 相关工作

考虑所有的计划树，在优化时执行算法

“limit the number of robust plan candidates to the cheapest plans encountered during the initial query optimization” (Florian Wolf 等, 2018, p. 1361) 健壮性的候选计划限制为： 在查询优化初期遇到的代价最小的计划

# 3 问题阐述

定义 各种基本符号 C_err，q-error，选择一个成本公式（线性、单调递增，可微分）

“argue that choosing a robust plan can result in faster query execution times in the presence of cardinality estimation errors” (Florian Wolf 等, 2018, p. 1361) 基数估计错误不可避免，因此选择健壮性更强的计划，其执行时间更短？是否一定？也许估计的最优计划其执行时间仍然最短

“The most robust plan is the plan with the smallest cost error factor cerr **within the set of robust plan candidates.**” (Florian Wolf 等, 2018, p. 1361)

“an ideal robustness metric should fulfill the following three consistency requirements.” (Florian Wolf 等, 2018, p. 1362) 理想的健壮性指标的 一致性需求，下面得到的三个指标都应该满足

# 4 健壮性指标

第一块基石：定义 PCF

“the cost of a query execution plan or sub-plan, modeled as function of one cost parameter.” (Florian Wolf 等, 2018, p. 1363)

“the slopes of PCFs around the estimated cardinality indicate the sensitivity of a plan towards estimation errors” (Florian Wolf 等, 2018, p. 1363) PCFs （参数化成本函数）的斜率表现了 一个计划对基数估计误差的敏感度

![image-20230304221141724](https://raw.githubusercontent.com/ZiHao256/Gallery/master/uPic/2023/03/image-20230304221141724.png)
(Florian Wolf 等, 2018, p. 1364) PCF 的使用，给这篇文章提供了思路，对 m:n 连接的 PCF 建模，使得整个计划的成本可控

## 基数-斜率健壮性指标

**定义：**

“cardinality-slope value δf,e” (Florian Wolf 等, 2018, p. 1364)

“edge weighting function φ ∶ EP → [0.0, 1.0]” (Florian Wolf 等, 2018, p. 1364) 这个函数是如何得到的，如何进行映射

对每个边的运算符不同进行不同地赋权重？
可以简单的给笛卡尔积连接1，有外码的连接和基表扫描0

“The robustness value rδf of the cardinalityslope robustness metric” (Florian Wolf 等, 2018, p. 1364)

**总结：**

“Cardinality-Slope” (Florian Wolf 等, 2018, p. 1364) 组成 基数-斜率 健壮性指标的**两个基石**

1. 基数-斜率 值
2. 边权重函数

解决哪些边对总的代价影响较大的问题，也就是对于某边增加一个元组对总体成本的影响多大

主要是认为edge越深，对计划代价的影响越大

## 中选率-斜率健壮性指标

**定义：**

“selectivity-slope value δs,op” (Florian Wolf 等, 2018, p. 1366)

“The robustness value rδs of the selectivityslope robustness metric” (Florian Wolf 等, 2018, p. 1366)

**总结：**

“Selectivity-Slope” (Florian Wolf 等, 2018, p. 1366) 估计中选率，而非索引选择性
第二个指标解决 潜在 **大基数误差 delta_f** 的问题，通过将f_max考虑进入。
相比于第一个指标，该指标增加了对每个边潜在更大的 基数误差 风险的考虑，通过对每个操作符的中选率进行考虑

## 基数-积分健壮性指标

**定义：**

“cardinality-integral value ∫f,e for an edge e” (Florian Wolf 等, 2018, p. 1367)

“The robustness value r∫f of the cardinalityintegral robustness metric for a plan P” (Florian Wolf 等, 2018, p. 1367)

**总结：**

“Cardinality-Integral” (Florian Wolf 等, 2018, p. 1366) 基数-积分？

在**计划健壮性**和**估计代价**之间的权衡
认为high 比deep影响更大（对此指标来说）

## 启发：

基数-斜率 健壮性指标：

“reflects the expected difference between estimated and true cost for cardinality estimation errors on all edges” (Florian Wolf 等, 2018, p. 1367) 反映了基数估计误差导致的对成本误差的影响

“implicitly considers the potential propagation of cardinality estimation errors, and takes the potential cardinality estimation errors for different types of operators into account.” (Florian Wolf 等, 2018, p. 1367)

中选率-斜率 健壮性指标：

“considers the risk of a large absolute cardinality error ∆f on all edges” (Florian Wolf 等, 2018, p. 1367)

基数-积分 健壮性指标：

“does not purely focus on plan robustness, but also takes estimated costs into consideration” (Florian Wolf 等, 2018, p. 1367)

# 5 计划候选者和健壮性计划的选择

“PLAN CANDIDATES AND SELECTION” (Florian Wolf 等, 2018, p. 1367) 候选计划 和 计划选择

1. 使用 k-cheapest plans 枚举出 健壮性计划候选者，同时限制候选者在 基数-斜率 和 选择-斜率两个健壮性指标上接近最优计划（其代价是 估计最优代价的1.2倍）；
2. 通过对每个候选者计算 三个指标之一，来得到每个计划的健壮性值；
3. 选择最健壮的计划来执行。
