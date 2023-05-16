---
title: 'Paper Reading: TECCD: A Tree Embedding Approach for Code Clone Detection'
toc: true
categories:
  - 个人提升
  - Paper Reading
tags:
  - Code Clone Detection
  - AST
  - Machine Learning
  - Natural Language Processing
abbrlink: 42c77a0c
date: 2023-05-16 14:17:01
---
# 摘要 & 引言

“Abstract” ([Gao 等, 2019, p. 145](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=1&annotation=4FEHEQUE)) [  
**摘要——**  
**background：**  
- Code Clone Detection Techniques：自动化的检测源码中重复或者高度相似的代码片段，提高代码的维护性、可读性等。  
- 过去的技术：基于字符串匹配、语法分析以及机器学习技术。  
**what**：  
- 解决代码克隆检测  
**how**：  
- 引入tree embedding技术：  
  1. 获得AST每个intermediate node的node vector  
  2. 从所相关的node vectors集合组合出tree vector  
  3. 计算出tree vector之间的欧式几何距离，作为code clones的衡量标准  
**novelty**：  
- 首次引入tree embedding到代码克隆检测中  
]

## embedding

## term-embedding

“term-embedding” ([Gao 等, 2019, p. 145](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=1&annotation=WKIBFI2P)) 「  
**embedding**:  
- 将一组离散的文本特征（例如单词或字符）映射到一个实数域上的连续向量的过程。这些向量通常具有固定的长度，并且包含了与原始文本特征相关的语义信息  
- embedding技术是基于深度学习的方法，它可以从大规模数据集中学习到文本特征之间的关联性，并将此信息编码为低维向量。通过使用embedding技术，我们可以有效地解决机器学习中高维稀疏数据的问题，减少特征工程的复杂度，并提高模型的准确率和效率。  
**term-embedding：**  
- 将源代码语言中的单词、标识符和符号等转换为低维特征向量。  
- 这些特征向量可以在机器学习模型中使用，从而对代码进行分类或聚类等操作  
」

## tree-embedding

“tree embedding technique” ([Gao 等, 2019, p. 145](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=1&annotation=NK5S2J7A)) 「  
**tree embedding**：  
- 将代码抽象为树结构，并将其嵌入到低维空间中的技术。  
- 在本文中，作者使用了AST（抽象语法树）来表示源代码，并通过tree embedding将AST映射到低维空间中。  
 - 这种表示方法可以保留代码中的结构信息，例如语句之间的依赖关系、变量之间的关系等  
」

# 2 准备工作

## Node2vec

“Node2vec” ([Gao 等, 2019, p. 147](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=3&annotation=UHY77AZM)) 「  
Node2Vec使用一个**二阶段**的方法来生成node vector：  
1\. **Random Walk**：  
  - 在第一阶段，Node2Vec从每个节点开始执行多次随机游走，得到一系列节点序列。  
  - 通过控制参数p和q，Node2Vec可以根据需要调整游走的策略，并捕捉不同节点之间的语义相似性和结构信息。  
2\. **Skip-Gram模型**：  
  - 在第二阶段，Node2Vec使用Skip-Gram模型来训练语言模型，并生成每个节点的向量表示。  
  - 具体地，对于每个节点，Node2Vec使用其相邻节点的向量表示作为输入，并尝试预测当前节点出现在相邻节点序列中的概率。  
  - 通过优化目标函数，Node2Vec可以学习每个节点的向量表示，使得相似的节点在向量空间中更接近。  
」

# 3 方法

## A. Pre-processing

“OUR APPROACH” ([Gao 等, 2019, p. 147](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=3&annotation=ZXEZRPJ9)) [  
**TECCD的基本idea：**  
- 基于code structure信息来进行detect code clones  
  - 使用AST代表源码的结构信息  
  - 只进行method级别的检测，因此只捕获method级别的AST  
- 基于DL技术，将AST转换为Vector  
- 比较Vector之间的欧式距离  
**基本步骤：**  
- **pre- processing**：  
  - 目标：根据训练语料库中的源码，生成node-vecotr dictionary  
- **Step1**:  
  - 目标：获得目标源码中所有method对应的AST，并获得AST node集合，去除LeafNode和StopNode  
- **Step2**:  
  - 目标：通过使用sentence embedding转换为vectors  
- **Step3**:  
  - 目标：计算并比较AST vectors之间的欧式距离，据此进行代码克隆检测  
]

### 获得context信息

“Obtain context information” ([Gao 等, 2019, p. 147](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=3&annotation=8W6PAN5B)) 「  
为了能够**同时捕获AST中的context和structe信息**：  
- 需要结合BFS和DFS：即randim walk算法  
  - BFS：捕获复杂statement或expression中的structure  
  - DFS：捕获一些基于简单文法的derivation  
- 为了将random walk算法应用于tree，需要修改AST，在brother nodes之间加入directed edges，方便BFS-like traverse  
」

### Random Walk

“Random Walk” ([Gao 等, 2019, p. 148](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=4&annotation=6BSS6G9V)) 「  
**Random Walk算法**：  
- 给定一个概率分布函数P(ci\=x | ci-1\=v)，给定当前节点v，计算下一个random walk为(v, x)的概率  
- (t, v)为上次进行random walk的边  
- P函数取决于(t, x)的关系  
  - dtx\=1表示t和x为父子  
  - 否则，为brother  
- =1代表BFS  
」

### Skip-Gram模型

“training corpus projects to train a Skip-gram model and obtain the node-vector dictionary.” ([Gao 等, 2019, p. 149](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=5&annotation=R3PZXMQR)) 「  
**训练Skip-Gram模型：**  
- 通过Random Walk算法获得所有AST得Sequences后  
- 将Node Sequences作为Skip-Gram模型的输入，并获得node-vector dictionary  
」

### Result of Context Information Capturing

“Results of Context Information Capturing” ([Gao 等, 2019, p. 149](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=5&annotation=L495DK92)) 「  
最终得到的**Node-Vector Dictionary**，代表的含义：  
- 有着相似context和structure的AST Node，被映射为有着更小distance的vectors  
」

### Stop Nodes

“Stop Nodes” ([Gao 等, 2019, p. 150](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=6&annotation=MPLB67C6)) 「  
Stop Nodes：  
- 对于区分不同树结构毫无贡献的冗余节点  
」

## B. Step1: Generate Tree-Node Set

“Step 1: Generate Tree-Node Set” ([Gao 等, 2019, p. 150](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=6&annotation=QC69NZDW)) 「  
**Step1:**  
- 目标：生成Tree-Node集合  
**具体实现：**  
- 将目标源码作为ANTLR的输入，获得每个method的AST  
- 对AST进行DFS遍历，获得每个AST的Tree-Node集合  
」

## C. Step2: Generate Tree Vector

“Step 2: Generate Tree Vector” ([Gao 等, 2019, p. 150](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=6&annotation=YKLM542J)) 「  
**Step2:**  
- 目标：生成AST Vector  
**具体实现：**  
**-** 采用 sentence2vec算法，基于Node-Vector Dictionary，将AST转换为AST Vector  
」

## D. Step3: Code Clone Detection

“Step 3: Code Clone Detection” ([Gao 等, 2019, p. 150](zotero://select/library/items/9LQ2XLYP)) ([pdf](zotero://open-pdf/library/items/4RB7Y8FW?page=6&annotation=XNRT8QBQ)) 「  
**Step3：**  
- 目标：进行Code Clone Dection  
**原理：**  
  - sentence2vec还是node2vec捕获了structure信息  
  - Skip-Gram考虑了context信息  
**具体实现：**  
- 基于上述原理/属性，可以基于vector之间的欧式距离，检测代码克隆  
- 对于Type1和2，AST Vector完全一致；对于Type3，其代码结构不一定相同  
- 设置欧式距离阈值，作为判断时Type3代码克隆的判断标准  
」