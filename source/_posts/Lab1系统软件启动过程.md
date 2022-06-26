---
title: Lab 1 系统软件启动过程
categories: 
  - uCore
tags: 
  - 操作系统
abbrlink: 32a74a00
---





# Lab 1 系统软件启动过程

[参考博客](https://www.jianshu.com/p/2f95d38afa1d)

[参考博客](https://www.git2get.com/av/102915460.html)

[toc]

# 1 实验目的

* 需要某种机制加载并运行操作系统
  * 更加简单的软件——Bootloader
  * 能完成切换到 x86 保护模式并显示字符
  * 为启动 ucore 
* 整个 Bootloader 执行代码小于512个字节，能放到硬盘的主引导扇区

分析和实现 Bootloader和ucore

* **计算机原理**
  * CPU 的编址与寻址：基于分段机制的内存管理   **【连续物理内存分配**
  * CPU 的中断机制
  * 外设：串口/并口/CGA（显示器），时钟（产生时钟中断），硬盘（读取）
* **Bootloader**
  * 编译运行 Bootloader 的过程
  * 调试的方法
  * PC 启动 Bootloader 的过程
  * ELF执行文件的格式和加载
  * 外设访问：读硬盘，在CGA上显示字符串
* **ucore OS**
  * 编译运行
  * 启动过程
  * 调试方法
  * 函数调用关系：在汇编级了解函数调用栈的结构和处理过程
  * 中断管理：与软件相关的中断处理    **【系统调用，异常**
  * 外设管理：时钟

# 2 实验内容

* lab 1 中包含一个 Bootloader 和 一个 OS
  * Bootloader 可以切换到 x86 保护模式，能够读磁盘并加载ELF执行文件格式，并显示字符
  * OS 只是一个可以处理时钟中断并显示字符的 OS



## 2.1 练习

* lab 1 提供了 6 个**基本练习**和 1 个**扩展练习**
* 完成实验报告
  * 基于markdown 格式，以文本方式为主
  * 填写各个基本练习中要求完成的报告内容
  * 完成试验后，分析 ucore_lab 提供的参考答案，并在实验报告中说明你的实现与参考答案的区别
  * 列出本实验中重要的知识点，以及对应的 OS 原理知识点，并简要说明你对二者的含义，关系，差异等方面的理解
  * 列出你认为 OS 原理中很重要，但实验中没有对应的知识点



### 练习一：理解通过 make 生成执行文件的过程

* 通过静态分析代码来了解：
  * **操作系统镜像文件** `ucore.img` 如何一步一步生成的（需要比较详细的解释Makefile 中每一条相关命令和命令参数的含义，以及说明命令导致的结果）
  * 一个被系统认为是符合规范的**硬盘主引导扇区**的特征是什么
* 补充材料：
  * 如何调试 `Makefile`
  * 当执行`make`时，一般只会显示输出，不会显示`make`执行了那些命令
  * 如想了解 `make`执行那些命令，可以执行`make V=`
  * 上网查询 make，执行`man make`



#### 报告

##### **问题一：**操作系统镜像文件 `ucore.img` 如何一步一步生成的（需要比较详细的解释Makefile 中每一条**相关命令**和**命令参数**的含义，以及说明命令导致的结果）



* **GCC** 相关编译选项：

  * > **GCC**
    >     `-g`  增加gdb的调试信息
    >     `-Wall`   显示告警信息
    >     `-O2 `    优化处理 (有 0，1，2，3，0是不优化)
    >     `-fno-builtin`   只接受以"__"开头的内建函数
    >     `-ggdb`   让gcc为gdb生成比较丰富的调试信息
    >     `-m32`    编译32位程序
    >     `-gstabs`     此选项以stabs格式生成调试信息，但是不包括gdb调试信息
    >     `-nostdinc`   不在标准系统目录中搜索头文件，只在-l指定的目录中搜索
    >     `-fstack-protector-all `  启用堆栈保护，为所有函数插入保护代码
    >     `-E`  仅做预处理，不进行编译，汇编和链接
    >     `-x c`  指明使用的语言为C语言
    >
    > **LDD Flags**
    >     `-nostdlib`   不连接系统标准启动文件和标准库文件，只把指定的文件传递给连接器
    >     `-m elf\_i386`    使用`elf_i386`模拟器
    >     `-N`      把text和data节设置为可读写，同时取消数据节的页对齐，取消对共享库的链接
    >     `-e func`     以符号`func`的位置作为程序开始运行的位置
    >     `-Ttext addr`  是连接时将初始地址重定向为`addr` （若不注明此，则程序的起始地址为0）

* **编译 bootloader**

  * 用于**加载** Kernel 操作系统

  * 先把 `bootasm.S` , `bootmain.c` 编译成相应的 **目标文件**

  * 在使用**连接器**连接到一起，使用 `start` 符号作为入口，并指定 text 段在程序中的绝对位置 是`0x7c00`

    * `0x7c00` : 是**操作系统一开始加载的地址**

  * ```bash
    //bootasm.o
    + cc boot/bootasm.S
    gcc -Iboot/ -fno-builtin  -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
    
    //生成bootmain.o
    + cc boot/bootmain.c
    gcc -Iboot/ -fno-builtin  -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
    
    //ld bin/bootblock
    ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
    
    'obj/bootblock.out' size: 468 bytes
    build 512 bytes boot sector: 'bin/bootblock' success!
    ```

* **编译 Kernel**

  * 操作系统本身

  * 先把.c文件 和 .S 汇编文件生成**目标文件**，之后使用**连接器**生成 Kernel

  * ```bash
    + cc kern/init/init.c
    gcc -Ikern/init/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/init/init.c -o obj/kern/init/init.o
    + cc kern/libs/readline.c
    gcc -Ikern/libs/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/readline.c -o obj/kern/libs/readline.o
    + cc kern/libs/stdio.c
    gcc -Ikern/libs/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/stdio.c -o obj/kern/libs/stdio.o
    + cc kern/debug/kdebug.c
    gcc -Ikern/debug/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kdebug.c -o obj/kern/debug/kdebug.o
    + cc kern/debug/kmonitor.c
    gcc -Ikern/debug/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kmonitor.c -o obj/kern/debug/kmonitor.o
    + cc kern/debug/panic.c
    gcc -Ikern/debug/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/panic.c -o obj/kern/debug/panic.o
    + cc kern/driver/clock.c
    gcc -Ikern/driver/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/clock.c -o obj/kern/driver/clock.o
    + cc kern/driver/console.c
    gcc -Ikern/driver/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/console.c -o obj/kern/driver/console.o
    + cc kern/driver/intr.c
    gcc -Ikern/driver/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/intr.c -o obj/kern/driver/intr.o
    + cc kern/driver/picirq.c
    gcc -Ikern/driver/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/picirq.c -o obj/kern/driver/picirq.o
    + cc kern/trap/trap.c
    gcc -Ikern/trap/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trap.c -o obj/kern/trap/trap.o
    + cc kern/trap/trapentry.S
    gcc -Ikern/trap/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trapentry.S -o obj/kern/trap/trapentry.o
    + cc kern/trap/vectors.S
    gcc -Ikern/trap/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/vectors.S -o obj/kern/trap/vectors.o
    + cc kern/mm/pmm.c
    gcc -Ikern/mm/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/mm/pmm.c -o obj/kern/mm/pmm.o
    + cc libs/printfmt.c
    gcc -Ilibs/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/printfmt.c -o obj/libs/printfmt.o
    + cc libs/string.c
    gcc -Ilibs/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/string.c -o obj/libs/string.o
    
    + ld bin/kernel
    ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/init.o obj/kern/libs/readline.o obj/kern/libs/stdio.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/debug/panic.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/intr.o obj/kern/driver/picirq.o obj/kern/trap/trap.o obj/kern/trap/trapentry.o obj/kern/trap/vectors.o obj/kern/mm/pmm.o  obj/libs/printfmt.o obj/libs/string.o
    
    ```

* **编译 sign**

  * 用于生成一个**符合规范** 的 **硬盘主引导扇区**

  * ```bash
    + cc tools/sign.c
    gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o
    gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign
    ```

* **生成 ucore.img**

  * **dd** - **转换和拷贝文件**

    * > `if`  代表**输入文件**。如果不指定if，默认就会从 `stdin`中读取输入。 
      > `of`  代表**输出文件**。如果不指定of，默认就会将`stdout`作为默认输出。 
      > `bs` 代表字节为单位的块大小。 
      > `count` 代表被复制的块数。 
      > `/dev/zero` 是一个字符设备，会不断返回0值字节（\0）
      > `conv=notrunc`    输入文件的时候，源文件不会被截断
      > `seek=blocks`     从输出文件开头跳过 blocks(512字节) 个块后再开始复制

  * **过程**：生成一个空的软盘镜像，然后把 bootloader 以不截断的方式填充到**开始的块**中，然后 kernel 跳过bootloader 所在的块，再填充

  * ```bash
    dd if=/dev/zero of=bin/ucore.img count=10000
    dd if=bin/bootblock of=bin/ucore.img conv=notrunc
    dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
    ```

  

**uCore.img的生成过程：**

1. **编译**所有生成 bin/**kernel** 所需的文件(.S汇编文件, .c文件)
2. **链接**生成 bin/**kernel** 
3. **编译** bootasm.S bootmain.c  sign.c
4. 根据 sign 规范**生成** obj/bootblock.o
5. 生成 **ucore.img**



* **生成 Kernel 文件**

  1. 根据 .c, .s 文件生成 .o文件
  2. 根据 `kernel.ld `文件，使用` ld `链接器，将 .o 文件链接成 kernel 文件

* **生成 Bootblock 文件**

  1. 将 `bootasm.S` , `bootmain.c `编译成各自相对应 .o 文件，并生成 .d
  2. 使用 链接器 将 .o 文件生成 bootblock.o 文件
  3. 使用 `objcopy` 将 bootblock.o 二进制拷贝至 `bootblock.out`
  4. `sign.c` 生成 `sign.o`， 再由 `sign.o `生成 sign 文件
  5. 用 `sig`n 程序，利用 `bootblock.out`生成 bootblock 文件

* **利用dd命令，使用 kernel、bootblock 生成 ucore.img**

  1. 从 `/dev/zero` 文件，获得 10000 个block（每个block 512 字节），均为空字符，输出到 ucore.img

  2. 从 bootblock 文件中获取数据，输出到 ucore.img 中的第一个block

     * `-notruct` 不对数据进行删减

  3. 从 kernel 文件获取数据，输出到 ucore.img 的第二个 block

     * `seek = 1` 跳过第一个block

       



##### **问题二：**一个被系统认为是**符合规范的 硬盘主引导扇区 的特征**是什么

* `less tools/sign.c`
  * ![image-20210405162827372](C:\Users\Light\AppData\Roaming\Typora\typora-user-images\image-20210405162827372.png)
  * 该扇区第 510 个字节是`0x55`, 第 511 个字节是 `0xAA`
  * 该扇区有 512 个字节
  * 多余空间填 0

### 练习二：使用 qemu 执行并调试 lab 1 中的软件（在报告中写出练习过程）

* **为了熟悉使用 qemu 和 gdb 进行的调试工作，小练习：**

  1. 从 CPU 加电后执行的第一条指令开始，单步跟踪 BIOS 的执行

  2. 在初始化位置设置 0x7c00 设置时地址断点，测试断点正常

  3. 从 0x7c00 开始跟踪代码运行，将单步跟踪反汇编得到的代码与 bootasm.S 和 bootblock.asm 进行比较

  4. 自己找一个 bootloader 或内核中的代码位置，设置断点并进行测试

* 提示：参考 附录“启动后第一条执行的指令”，可了解更详细的解释，以及如何单步调试并查看 BIOS 代码

* 提示：查看 `labcodes_answer/lab1_result/tools/lab1init `文件，用如下命令试试如何调试bootloader第一条指令：

  * ```
    $ cd labcodes_answer/lab1_result/
    $ make lab1-mon
    ```



* **默认的 gdb 需要进行一些额外的配置才进行 qemu 的调试**，qemu 和gdb之间使用 网络端口 1234 进行通讯
  * 打开qemu 进行模拟之后，执行gdb并输入`target remote local:1234`
  * 可连接qemu，此时qemu进入停止状态，听从 gdb 命令

* *gdb 的地址断点*：

  * `b *[地址]`：在指定内存地址设置断点，当qemu 中的 CPU 执行到指定地址时，便会将控制权交给 gdb

* *关于代码的反汇编*

  * 可能 gdb 无法正确获取 当前 qemu 执行的汇编指令，如下配置可以在每次 gdb 命令行前强制反汇编当前的指令，在 gdb 命令行或配置文件中添加：

    * ```
      define hook-stop
      x/i $pc
      end
      ```

* *gdb 的单步命令：*
  * next ： 单步到程序源代码的下一行，不进入函数
  * nexti ： 但不一条机器指令，不进入函数
  * step：单步到下一个不同的源代码行（进入函数）
  * stepi：单步一条机器指令，进入函数

#### 报告

##### 2.1 从CPU 加电后执行的第一条指令开始，单步跟踪 BIOS 的执行

* 附录：**单步调试和查看 BIOS 代码**

  1. 修改` lab1/tools/gdbinit`：

     ```
     set architecture i8086
     target remote :1234
     ```

  2. 在 lab 1 目录下，执行`make debug`

     这时，gdb 停在 BIOS 的第一条指令处：`0xffff0: ljmp $0xf000, $0xe05b`

  3. 在进入 gdb 调试界面后，执行如下命令，可以看到 BIOS 在执行了

     ```
     si
     si
     ...
     ```

  4. 此时的 `CS=0xf, IP=fff0`,如果想看 BIOS 代码

     `x /2i 0xffff0`

     可以看到：

     ```
     0xffff0: ljmp $0xf000,$0xe05b
     0xffff5: xor %dh,0x322f
     ```

     进一步执行`x /10i 0xfe05b`

     可以看到后续代码







* `gdbinit  `原内容为：对内核代码进行调试，并且将断点设置在内核代码的入口地址，即 `kern_intit`  函数

  * ```
    file bin/kernel			//对内核代码进行调试
    target remote :1234
    break kern_init			//将断点设置在kern_init
    continue
    ```

* 为了从CPU 加电后执行的第一条指令开始调试，将`gdbinit`内容改为：

  * ```
    set architecture i8086		//改动
    
    target remote :1234
    
    ```

* 执行`make debug`：弹出 QEMU 和 Terminal窗口，因为我们在 Makefile 中定义了debug的操作正是启动 QEMU、Terminal并在其中运行 gdb

  * -hda file: 硬盘选项

  * -S : 启动的时候不直接从CPU启动，需要在窗口中按 c 来继续

  * -parallel dev : 重定向虚拟**并口**到主机设备

  * -serial dev：重定向虚拟**串口**到主机设备

    * vc: 虚拟控制台
    * pty：仅仅linux有效，虚拟tty（一个虚拟伪终端会被立刻分配
    * none：没有设备被分配
    * null：无效设备

  * gdb：

    * -x ：从文件中执行 gdb 
    * -q：不要打印介绍和版权信息
    * -tui：可以将终端屏幕分成源文本窗口和控制台的多个子窗口

  * ```
    debug: $(UCOREIMG)	
        $(V)$(QEMU) -S -s -parallel stdio -hda $< -serial null &		
        $(V)sleep 2
        $(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"
    ```

* `make debug` : Terminal 窗口此时停在` 0x0000fff0 `位置，这是 eip 寄存器的值

  ​	而cs 寄存器的值为`0xf000`

  ![image-20210406205944058](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210406205944058.png)

  

* 输入 `si`，执行一步, eip 变成 `0xe05b`，而cs 不变

  * ![image-20210406210105732](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210406210105732.png)

##### 2.2 在初始化位置设置 0x7c00 设置时地址断点，测试断点正常

* `break *adress`: 在指定地址处设置断点，一般在没有源代码时使用

* 输入`break *0x7c00`
* 输入`continue`
  * ![image-20210406210223703](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210406210223703.png)

##### 2.3 从 0x7c00 开始跟踪代码运行，将单步跟踪反汇编得到的代码与 bootasm.S 和 bootblock.asm 进行比较

* `x/10i $pc`:显示程序当前位置开始往后 10 条汇编指令

* 输入`x/10i $pc`
  * ![image-20210406210251460](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210406210251460.png)

##### 2.4 自己找一个 bootloader 或内核中的代码位置，设置断点并进行测试

* 调试 bootblock 的代码

* 设置断点为 0x7c00地址 处

* 修改` tools/gdbinit `为

  * ```
    //tools/gdbinit"  
    file obj/bootblock.o 
    target remote :1234 
    set architecture i8086 
    b *0x7c00 
    continue 
    x /10i $pc
    ```

  * ![image-20210405213757021](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210405213757021.png)

  * ![image-20210405213817816](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210405213817816.png)

### 练习三：分析 bootloader 进入保护模式的过程

* **BIOS** 将通过**读取硬盘主引导扇区到内存**，并跳转到对应内存中的位置执行 bootloader 
* 分析 bootloader 如何从实模式进入保护模式
* 需要阅读：**保护模式和分段机制** 和 `lab1/boot/bootasm.S` 源码，
  * 为何开启 A20 ，以及如何开启
  * 如何初始化 GDT 表
  * 如何 使能 和 进入保护模式





#### 报告

bootloader 从实模式进入保护模式的代码 保持在`lab1/boot/bootasm.S` 中

##### 为何开启 A20 ， 如何开启A 20

* bootloader 的入口 为 start
* bootloader 会被 BIOS 加载到内存 `0x7c00` 处 `cs = 0, eip = 0x7c`

* 刚进入 bootloader 时，先执行：
  * ![image-20210407191652178](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407191652178.png)
  * 关闭中断
  * 清除 `EFLAGS` 的` DF` 位
  * 将 `ax、ds、es、ss` 初始化为0
* **为何开启 A20 :**
  * 为了使得 CPU 进入保护模式后，能充分使用 32 位的寻址能力
* **如何开启 A20：**
  * 等待 8042 控制器 Input Buffer为空
  * 发送 P2命令到Input Buffer
  * 等待 Input Buffer 为空
  * 将 P2 得到的第二个位（A20选通）置为1
  * 写回Input Buffer
* 首先，从0x64内存地址中（映射到8042的status register）中读取8042的状态，直到读取到的该字节的第二位（input buffer）为0，表示此时 input buffer中无数据
  * ![image-20210407194037024](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407194037024.png)
* 接下来向 0x64 中写入 0xd1 命令，表示修改 8042 P2 port
  * ![image-20210407194155534](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407194155534.png)
* 接下来等待 input buffer为空
  * ![image-20210407194234798](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407194234798.png)
* 接下来，向 0x60 端口写入 0xdf, 表示将 P2 port的第二个位（A20）选通，置为1
  * ![image-20210407194403140](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407194403140.png)
* 

##### 如何初始化 GDT（全局描述符表）

* 在 bootasm.S 中已经静态的描述了一个简单的 GDT
  * ![image-20210407194832302](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407194832302.png)
  * GDT 中代码段和数据段 的base均设置为了 0
  * 而 limit设置为了 2^32-1 即 4 G，使得逻辑地址等于线性地址



##### 如何 使能 和 进入保护模式

* 只需要将cr0 寄存器的PE位 置为1，即可切换至保护模式
  * A20 开启后，`lgdt gdtdesc` 可载入全局描述符表
  * ![image-20210407195211157](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407195211157.png)
* 使用长跳转指令 , 将 cs 修改为 32 位寄存器，并且跳转到 protcseg 这一32位代码入口，此时CPU进入32位模式：
  * ![image-20210407195333677](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407195333677.png)



### 练习四：分析 bootloader 加载 ELF 格式的 OS 的过程

要求：

* 通过阅读 `bootmain.c`, 了解 bootloader 如何加载 ELF 文件
* 通过分析源代码和通过 qemu 来运行 并调试bootloader和OS
  * bootloader 如何读取硬盘扇区
  * bootloader 如何加载 ELF 格式的 OS



#### 报告

##### bootloader 如何读取硬盘扇区

对 bootmain.c 中与读取硬盘扇区代码分析：

* 首先，`waitdisk`, 该函数的作用是连续不断地从`0x1f7`地址，读取磁盘的状态，直到磁盘不忙为止

  * ![image-20210407204024075](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407204024075.png)

* 接下来，`readsect`, 读取一个硬盘扇区，

  * ```c
    static void
    readsect(void *dst, uint32_t secno) {
        waitdisk(); // 等待磁盘到不忙为止
    
        outb(0x1F2, 1);             // 往0X1F2地址中写入要读取的扇区数，由于此处需要读一个扇区，因此参数为1
        outb(0x1F3, secno & 0xFF); // 输入LBA参数的0...7位；
        outb(0x1F4, (secno >> 8) & 0xFF); // 输入LBA参数的8-15位；
        outb(0x1F5, (secno >> 16) & 0xFF); // 输入LBA参数的16-23位；
        outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0); // 输入LBA参数的24-27位（对应到0-3位），第四位为0表示从主盘读取，其余位被强制置为1；
        outb(0x1F7, 0x20);                      // 向磁盘发出读命令0x20
    
        waitdisk(); // 等待磁盘直到不忙
    
        insl(0x1F0, dst, SECTSIZE / 4); // 从数据端口0x1F0读取数据，除以4是因为此处是以4个字节为单位的，这个从指令是以l(long)结尾这点可以推测出来；
    }
    ```

  * **读取磁盘扇区的过程：**
    * 等待磁盘不忙
    * 向 `0x1f2-0x1f6`中 设置读取扇区需要的参数，
      * 读取的扇区数
      * LBA 参数
    * 向`0x1f7`发送命令`0X20`——读命令
    * 等待磁盘完成读操作
    * 从数据端口`0x1f0`读取数据到指定内存中

* 另外一个与读取磁盘相关的函数`readseg`，

  * 将`readsec`进一步封装
  * 提供能够从磁盘 第二个扇区起（kernel） offset 个位置处，读取 count 个字节到指定内存
  * `readsec` 只能对整个扇区进行读取



##### bootloader 如何将 ELF 格式的 OS 加载入内存

* bootloader 加载 ELF 格式的 OS 代码位于·`bootmain.c` 中的 bootmain 函数
  * **首先，**从磁盘的第一个扇区（kernel，第零个扇区为bootloader）中读取kernel最开始的 4 KB代码，然后判断最开始的四个字节是否等于指定的 `ELF_MAGIC`, 用于判断 ELF header是否合法
    * ![image-20210407205626699](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407205626699.png)
  * **接下来**，从`ELFHDR `——ELF 头文件中获取到 `program header`**表**的位置，以及该表的入口数目，然后遍历该表每一项，并且从每一个program header中获取到 **段** 应该被加载到内存中的位置（Load Address，虚拟地址），以及段的大小，然后调用 `readseg` 函数将每一个段加载到内存中，至此完成了将 OS 加载到内存中的操作
    * ![image-20210407210008007](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407210008007.png)
  * **最后**，从`ELFHDR`——ELF 头文件中查询到 OS kernel的**入口地址**，然后使用函数调用的方式跳转到该地址
    * ![image-20210407210213172](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210407210213172.png)



### 练习五：实现函数调用堆栈跟踪函数

* 在 `lab1` 中完成 `kdebug.c` 中函数`print_stackframe`的实现

  * 可以通过该函数 跟踪函数调用堆栈中记录的返回地址

* 若能正确实现该函数，`make qemu`后：

  * ```bash
    ……
    ebp:0x00007b28 eip:0x00100992 args:0x00010094 0x00010094 0x00007b58 0x00100096
        kern/debug/kdebug.c:305: print_stackframe+22
    ebp:0x00007b38 eip:0x00100c79 args:0x00000000 0x00000000 0x00000000 0x00007ba8
        kern/debug/kmonitor.c:125: mon_backtrace+10
    ebp:0x00007b58 eip:0x00100096 args:0x00000000 0x00007b80 0xffff0000 0x00007b84
        kern/init/init.c:48: grade_backtrace2+33
    ebp:0x00007b78 eip:0x001000bf args:0x00000000 0xffff0000 0x00007ba4 0x00000029
        kern/init/init.c:53: grade_backtrace1+38
    ebp:0x00007b98 eip:0x001000dd args:0x00000000 0x00100000 0xffff0000 0x0000001d
        kern/init/init.c:58: grade_backtrace0+23
    ebp:0x00007bb8 eip:0x00100102 args:0x0010353c 0x00103520 0x00001308 0x00000000
        kern/init/init.c:63: grade_backtrace+34
    ebp:0x00007be8 eip:0x00100059 args:0x00000000 0x00000000 0x00000000 0x00007c53
        kern/init/init.c:28: kern_init+88
    ebp:0x00007bf8 eip:0x00007d73 args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8
    <unknow>: -- 0x00007d72 –
    ……
    ```

* 前置知识：函数堆栈：

  * 了解编译器如何建立**函数调用关系**
  * 查看`bootblock.asm`, 了解bootloader源码与机器码的语句和地址等对应关系
  * 查看`kernel.asm`, 了解 ucore 源码与机器码的语句和地址等对应关系
  * 完成`kern/debug/kdebug.c::print_stackframe`的实现



#### 报告

前提知识：

一般而言：`ss:[ebp+4]`为**返回地址**，`ss:[ebp+8]`为**第一个参数值（**最后一个入栈）,`ss:[ebp-4]`为第一个局部变量，`ss:[ebp]`为**上一层 ebp 值**

* **ebp 中的地址处总是上一层函数调用时 ebp 的值**
* 而每一层函数调用中，都能通过当时的 ebp 值，**向上（栈底方向）获取返回地址，参数值；向下（栈顶方向）获取函数局部变量值**
* 由此形成递归，直至到达栈底，这就是函数调用栈

我的做法：

* 尝试根据他的注释来做：

  * ![image-20210409150011984](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210409150011984.png)

  * (1) 调用 函数` read_ebp() `得到 ebp的值

  * (2) 调用函数 `read_eip()` 得到 eip的值

  * (3) 对于栈帧 `0-STACKFRAME_DEPTH`

    * 使用`cprintf`输出 ebp和eip的值

    * 有了ebp的值，需要我们打印前四个参数值，而我们知道 第一个参数值 在`ss:[ebp+8]`，可用`(uint32_t*)（ebp+8）`取得该内存地址的值

    * 使用` print_debuginfo() `打印函数名

    * *获取上一层函数的返回地址和ebp的值*

      * > 根据动态链查找当前函数的调用者(caller)的栈帧, 根据约定，caller的栈帧的base pointer存放在callee的ebp指向的内存单元，将其更新到ebp临时变量中，同时将eip(代码中对应的变量为ra)更新为调用当前函数的指令的下一条指令所在位置（return address），其根据约定存放在ebp+4所在的内存单元中；

        >  如果ebp非零并且没有达到规定的`STACKFRAME DEPTH`的上限，则跳转到2，继续循环打印栈上栈帧和对应函数的信息；

        

* **unknown：**

  * `*(uint32_t*)x`: x是一个地址，`(unint32_t*)将x强制转换成指向unint32_t的指针`
  * `read_ebp()`
  * `read_eip()`
  * `STACKFRAME_DEPTH`
  * `cprintf("\n")`
  * `print_debuginfo()`

* ```C
  void print_stackframe(void) {
  	uint32_t value_ebp = read_ebp();
  	uint32_t value_eip = read_eip();
  	for(int i = 0; i<STACKFRAME_DEPTH; i++){
  		cprintf("ebp: 0x%08x eip:0x%08x",value_ebp, value_eip);
  		cprintf("arguments: ");
  		
  		uint32_t* p = (uint32_t*)(value_ebp+8);
  		cprintf("0x%08x 0x%08x 0x%08x 0x%08x ",p[0],p[1],p[2],p[3]); 
  		//(uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]
  		
  		cprintf("\n");
  		print_debuginfo(value_eip-1);
  		
  		value_eip = *(uint32_t*)(value_ebp+4);
  		value_ebp = *(uint32_t*)(value_ebp);
  		//popup a calling stackframe
  	}
  			
      
  }
  ```

* ![image-20210409161023480](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210409161023480.png)



* 实现函数

1. 首先使用read_ebp和read_eip函数获取当前stack frame的base pointer以及`call read_eip`这条指令下一条指令的地址，存入ebp, eip两个临时变量中；

2. 接下来使用cprint函数打印出ebp, eip的数值；

3. 接下来打印出当前栈帧对应的函数可能的参数，根据c语言编译到x86汇编的约定，可以知道参数存放在ebp+8指向的内存上（栈），并且第一个、第二个、第三个...参数所在的内存地址分别为ebp+8, ebp+12, ebp+16, ...，根据要求读取出当前函数的前四个参数(用可能这些参数并不是全都存在，视具体函数而定)，并打印出来；

4. 使用print_debuginfo打印出当前函数的函数名；

5. 根据动态链查找当前函数的调用者(caller)的栈帧, 根据约定，caller的栈帧的base pointer存放在callee的ebp指向的内存单元，将其更新到ebp临时变量中，同时将eip(代码中对应的变量为ra)更新为调用当前函数的指令的下一条指令所在位置（return address），其根据约定存放在ebp+4所在的内存单元中；

6. 如果ebp非零并且没有达到规定的STACKFRAME DEPTH的上限，则跳转到2，继续循环打印栈上栈帧和对应函数的信息；

```C
void
print_stackframe(void) {
    uint32_t ebp = read_ebp();
    uint32_t ra = read_eip(); 
    for (int i = 0; i < STACKFRAME_DEPTH && ebp != 0; ++ i) {
        cprintf("ebp:0x%08x eip:0x%08x ", ebp, ra);
        uint32_t* ptr = (uint32_t *) (ebp + 8);
        cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x\n", ptr[0], ptr[1], ptr[2], ptr[3]);
        print_debuginfo(ra - 1);
        ra = *((uint32_t *) (ebp + 4));
        ebp = *((uint32_t *) ebp);
    }
}
```

* 分析最后一行输出各个数值的意义：

* ```css
  ebp:0x00007bf8 eip:0x00007d6e args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8
      <unknow>: -- 0x00007d6d --
  ```

* ![image-20210408100708052](E:\LearningNotes\TH操作系统\操作系统实验\Lab 1 系统软件启动过程.assets\image-20210408100708052.png)



##### 解释最后一行各个数值

```bash
ebp:0x00007bf8 eip:0x00007d6e args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8
    <unknow>: -- 0x00007d6d --
```

* `ebp:0x00007bf8`:第一个被调用函数栈帧的base pointer
* `eip:0x00007d6e`: 该栈帧对应函数中调用的下一个栈帧对应函数的指令的下一条指令
* `args:0xc031fcfa 0xc08ed88e 0x64e4d08e`: 传递给第一个被调用函数的参数
* `   <unknow>: -- 0x00007d6d --` : bootmain 函数调用OS kernel入口函数的该指令的地址



### 练习六：完善中断初始化和处理

1. 中断描述符表（保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码？
2. 编程完善`kern/trap/trap.c`中对中断向量表进行初始化的函数 `idt_init`, 在该函数中，依次对所有中断入口进行初始化。使用`mmu.h`中的`SETGATE`宏，填充`idt`数组内容。每个中断入口由`tools/vector.c`生成，使用`trap.c`中声明的vectors数据即可
3. 编程完善trap.c中的中断处理函数trap , 在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕打印一行文字`100 ticks`

* 注意：
  * 除了系统调用（`T_SYSCALL`）使用 **陷阱门描述符** 且权限为 **用户态权限** 以外
  * 其他中断均使用**特权级（DPL）为0**的 **中断门描述符**
  * uCore的应用程序处于特权级 3 ，需采用`int 0x80`
  * 系统调用中断`T_SYSCALL`所对应的中断门描述符中的特权级设置为 3
* 要求：
  * 完成问题2和问题3 提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程，并写出对问题1的回答
  * 完成这问题2和3要求的部分代码后，运行整个系统，可以看到大约每1秒会输出一次”100 ticks”，而按下的键也会在屏幕上显示



#### 报告

>**中断向量表调用关系**
>系统发生中断--->中断号（0~255）-->找到IDT，拿到段选择子和偏移-----> 拿着段选择子找GDT，找到段基址，再使用偏移跳转到程序入口地址

##### 第一问

> 中断描述符表（保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码？

* 中断向量表一个表项占用8字节
* 2-3字节是段选择子，0-1字节和6-7字节拼成偏移，两者联合便是中断处理程序的入口地址



##### 第二问

> 编程完善`kern/trap/trap.c`中对中断向量表进行初始化的函数 `idt_init`, 在该函数中，依次对所有中断入口进行初始化。使用`mmu.h`中的`SETGATE`宏，填充`idt`数组内容。每个中断入口由`tools/vector.c`生成，使用`trap.c`中声明的vectors数据即可



* 在idt.init函数中，依次对所有中断入口进行初始化，使用mmu.h中的SETGATE宏

  * >#define SETGATE(gate, istrap, sel, off, dpl) {            \
    >    (gate).gd_off_15_0 = (uint32_t)(off) & 0xffff;        \
    >    (gate).gd_ss = (sel);                                \
    >    (gate).gd_args = 0;                                    \
    >    (gate).gd_rsv1 = 0;                                    \
    >    (gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;    \
    >    (gate).gd_s = 0;                                    \
    >    (gate).gd_dpl = (dpl);                                \
    >    (gate).gd_p = 1;                                    \
    >    (gate).gd_off_31_16 = (uint32_t)(off) >> 16;        \
    >}
    >参数：
    >gate:
    >istrap:陷阱门设为1，中断门设为0. 
    >sel:段选择子，全局描述符表的代码段段选择子 //memlayout.h里面有宏定义GD_KTEXT
    >off:处理函数的入口地址，即__vectors[]中的内容。
    >dpl:特权级.从实验指导书中可知，ucore中的应用程序处于特权级3，内核态特权级为0.

* 根据注释：

  * ```C
    /* LAB1 YOUR CODE : STEP 2 */
         /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
          *     All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
          *     __vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
          *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
          *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
          * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
          *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
          * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
          *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
          *     Notice: the argument of lidt is idt_pd. try to find it!
          */
    ```

  * ```C
    void
    idt_init(void) {
        extern uintptr_t __vectors[];
        for(int i = 0; i < sizeof(idt)/sizeof(struct gatedesc); i++)
        {
            SETGATE(idt[i], 0, GD_KTEXT, __vectors[i]; 0);
        }
        SETGATE(idt[T_SYSCALL], 0, GD_KTEXT, __vectors[T_SYSCALL]; 3);
        lidt(&idt_pd);
    }
    ```

##### 第三问

> 编程完善trap.c中的中断处理函数trap , 在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕打印一行文字`100 ticks`

```C
case IRQ_OFFSET+IRQ_TIMER:
    ticks++;
    if (ticks % TICK_NUM == 0) {
        print_ticks();
    }
    break;
/*
    make
    make qemu
*/
```



# 3 从机器启动到操作系统运行的过程

## 3.1 BIOS 启动过程

* 计算机**加电后**，先执行**系统初始化软件**，完成**基本IO初始化**和**引导加载功能**
  * **初始化硬件设备** ， 建立系统的内存空间映射图
  * 将系统的软硬件环境带到一个合适的状态，以便最终调用操作系统内核准备好正确的环境
  * **最终引导加载程序** 把操作系统内核映像 加载到 RAM中，并将系统控制权传递给它
* 操作系统和应用软件 存放在 磁盘（硬盘/软盘）、光盘、EPROM、ROM、Flash等 可在掉电后继续保存数据的存储介质
* 计算机启动后，CPU 一开始会到一个特定的地址 开始执行指令，
  * 这个特定的地址 存放了**系统初始化软件**（Intel 80386 中是 BIOS, 其本质是一个固定在主板Flash/CMOS 上的软件），负责完成计算机的 **基本的I/O初始化**
* **系统初始化软件**：由 **BIOS** 和 位于 软盘/硬盘**引导扇区**中的 **OS Bootloader**（在ucore 中的 bootasm.S 和 bootmain.c ）一起组成
* **BIOS** ：**固定在计算机 ROM（**只读存储器） 芯片上的一个特殊软件，为上层软件提供最底层的、最直接的硬件控制与支持
  * 是 PC计算机硬件 与 上层软件程序 之间的桥梁，负责**访问和控制硬件**



* 对于 Intel 80386：
  * 计算机加电后，CPU 从物理地址`0xfffffff0`（由初始化的`CS: EIP` 确定，此时 CS 和 IP 的值分别是 `0xf000` 和 `0xfff0`）开始执行
  * 在 `0xfffffff0` 处，存放了一条**跳转指令**，通过跳转指令跳到 **BIOS 例行程序起始点**
  * BIOS 做完**计算机硬件自检和初始化**后，会选择一个启动设备（软盘、硬盘、光盘等），并且**读取该设备的第一扇区（即主引导扇区或启动扇区）到内存一个特定的地址** `0x7c00`处
  * 然后将 **CPU 控制权会转移**到那个地址继续执行
  * 至此，BIOS的初始化工作完成，进一步的工作交给 uCore 的**bootloader** 

## 3.2 Bootloader 的启动过程

* **BIOS** 将通过读取硬盘主引导扇区到内存，并跳转到对应内存中的位置执行 bootloader
* **Bootloader：**
  * 切换到**保护模式**，启用**分段机制**
  * 读磁盘中 **ELF 执行文件格式**的 uCore 操作系统到内存
  * 显示字符串信息
  * 把**控制权**交给uCore操作系统
* Bootloader 工作的实现文件 在 `lab1/boot/` 下的 asm.h, bootasm.S 和 bootmain.c

### 3.2.1 保护模式和分段机制

* Intel 80386 只有进入保护模式，才能充分发挥其强大的功能
  * 提供更好的保护机制和强大的寻址能力
* 若没有保护模式：只是一个快速的 8086 ，
  * 没有保护机制
  * 任何应用软件都可以任意访问所有的计算机资源
  * 且 分段机制 一直存在，无法屏蔽或避免
* 操作系统功能（如分页机制）是建立在 Intel 80386的保护模式上来设计的



#### 实模式

* 在 Bootloader 接手 BIOS 的工作后，PC 系统处于实模式（16位模式）运行状态
  * 这种状态下，软件可访问的物理内存空间 不能超过 1 MB
  * 无法发挥Intel 80386 以上级别的32位 CPU 的4 GB的内存管理能力
* 实模式 将整个物理内存 看成分段区域
  * 程序代码 和 数据位于不同的区域
  * 操作系统和用户程序并没有区别对待
  * 每一个指针都是指向实际的物理地址
* 通过修改 A20 地址线可以完成从实模式到保护模式的转换



#### 保护模式

* 只有在保护模式下，80386的全部 32 根地址线有效
  * 寻址能力高达 4 GB 的线性地址空间和物理地址空间
  * 可访问 64 TB （有2^14个段，每个段最带空间为 2^32 字节）的逻辑地址空间
  * 可采用分段存储管理 和 分页存储管理机制
  * 不仅为 **存储共享和保护** 提供了硬件支持，而且为**实现虚拟存储**提供了硬件支持
  * 提供了 **4个特权级**和**完善的特权检查机制** ： 既能实现 **资源共享**，又能 **保证代码数据的安全** 及 **任务的隔离**
* 保护模式下，有两个段表：都可以包含 2^13 个**描述符**，因此最多可以同时存在 2*2^13 个段
  * **GDT** **（Global Descriptor Table）**
  * **LDT** **（Local Descriptor Table）**
* 实际上，段机制 并不能扩展物理地址空间，很大程度山，各个段的地址空间是相互重叠的
  * 所谓 64 TB（2^(14+32)）逻辑地址空间只是一个理论值
  * 32 位保护模式下，真正的物理空间只有 2^32 字节



#### 分段存储管理机制

* 只能在保护模式下使用
* 分段机制：将内存划分成以 **起始地址** 和 **长度限制** 这两个二维参数表示的内存块——**段（Segment）**
  * 即编译器将源程序编译成执行程序时用到的 代码段、数据段、堆和栈等
* 分段机制：
  * **逻辑地址**
  * **段描述符**：描述段的属性
  * **段描述符表**：包含多个段描述符的 数组
  * **段选择子**：段寄存器，用于定位段描述符表中 表项的**索引**

* **逻辑地址** ——> **物理地址**
  * **分段地址转换**：**CPU** 把逻辑地址（由**段选择子 selector** 和 **段偏移 offset** 组成）
    * 将 **段选择子** 的内容 作为 **段描述符表** 的索引，找到表中对应的 **段描述符**，然后把 段描述符 中保存的 **段基址** 加上 **段偏移值**，形成 **线性地址（Linear address）**
    * 若不启动 分页存储管理机制，则线性地址 等于 物理地址
    * ![分段地址转换基本过程](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image002.png)
  * **分页地址转换**：
    * 把线性地址转换成物理地址
  * 线性地址空间 由一维的线性地址构成，线性地址空间和物理地址空间对等
    * 线性地址 32 位长，线性地址空间容量为 4 GB



##### 段描述符

* 保护模式下的分段管理机制，每个段有三个参数构成：
  
  * > 在ucore中的kern/mm/mmu.h中的struct segdesc 数据结构中有具体的定义。
    
  * **段基地址（Base Address）**：规定线性地址空间中 段的起始地址
    * 80386 保护模式下，段基地址 长 32 位
    * 与寻址地址长度相同，所以任何一个段都可以从32位线性地址空间中的任何一个字节开始，不像实模式下规定的边界必须被 16整除
  * **段界限（Limit）**：规定端的大小。
    * 80386 保护模式下，用 20 位表示
    * 段界限 可以是以 字节 为单位或以 4 K 字节为单位
  * **段属性（Attributes）**：确定段的各种性质
    * 段属性中的粒度位
    * 类型
    * 描述符特权级
    * 段存在位
    * 已访问位
  
* ![段描述符结构](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image003.png)



##### 全局描述符表

* 保存**多个段描述符的 “数组"**

* 其 起始地址 保存在 全局描述符表寄存器 GDTR

  * GDTR 长48位，高32位为基地址，低16位为段界限

* 由于 GDT 不能有 GDT 本身之内的描述符进行描述定义，所以 处理器 采用 GDTR 为 GDT 这一特殊的系统段

* 全局描述符表 中第一个段描述符设定为空段描述符

* GDTR 中的段界限以字节 为单位

  * 对于含有 N 个描述符的描述符表，段界限可设为`8*N-1`

  * > 在ucore中的boot/bootasm.S中的gdt地址处和kern/mm/pmm.c中的全局变量数组gdt[]分别有基于汇编语言和C语言的全局描述符表的具体实现



##### 选择子

* 线性地址部分的选择子：选择 段描述符表 和 在该表中索引 一个段描述符
* 选择子可以作为 指针变量的一部分
  * ![段选择子结构](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image004.png)
  * 索引 Index : 在描述符表中从 8192 个描述符中选择一个
    * 处理器自动将这个索引值 乘 8，再加上描述符表的基地址来索引描述符表，从而选择一个合适的描述符
  * 表指示位 Table Indicator（TI）：选择访问哪一个描述符表，
    * 0：GDT
    * 1：LDT
  * 请求特权级（Request Privilege Level，RPL）：保护机制

> 全局描述符表的第一项是不能被CPU使用，所以当一个段选择子的索引（Index）部分和表指示位（Table Indicator）都为0的时（即段选择子指向全局描述符表的第一项时），可以当做一个空的选择子（见mmu.h中的SEG_NULL）。当一个段寄存器被加载一个空选择子时，处理器并不会产生一个异常。但是，当用一个空选择子去访问内存时，则会产生异常

#### 保护模式下的特权级

* 保护模式下，特权级共四个：0 - 3，被称为保护环（protection ring）
  * ring 0 为最高特权级 : 内核态
  * ring 3 最低特权级：一般给 应用程序使用，用户态
* 受到保护的资源：内存，I/O端口，执行特殊机器指令的能力
* 在任意时刻，x86 CPU 都是在一个特定的特权级下运行的
  * 决定代码可以做什么，不可以做什么
* 大约 15 条机器指令被 CPU 限制只能在内核态执行
  * 若被用户模式的程序使用，会引起混乱
  * 导致一个一般保护异常（general-protection exception）
* **数据段选择子** 的整个内容可由程序直接加载到各个寄存器（SS, DS）
  * 包含了 请求特权级字段（Requested Privilege Level）
* 代码段寄存器（CS） 的内容，不能由装载指令（如 MOV）直接设置，只能被间接设置
  * CS 拥有一个由CPU 维护的当前特权级字段 （Current Privilege Level）
  * ![DS和CS的结构图](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image005.png)
* 

### 3.2.3 硬盘访问概述

* bootloader 使得CPU进入保护模式后，下一步从硬盘上加载并运行 OS
* bootloader 的访问硬盘都是 LBA 模式的 **PIO(Program IO)方式**，
  * 即**所有的 IO 操作**，都是通过 CPU **访问硬盘的 IO 地址寄存器**完成
* 一般，主板拥有 2 个 IDE通道，每个通道可以接 2 个 IDE 硬盘
  * 访问第一个硬盘的扇区，可设置 IO 地址寄存器为 `0x1f0-0x1f7`实现



* 硬盘数据是存储到硬盘扇区中，一个扇区为 512 字节
* 都一个扇区的流程在 `boot/bootmain.c`中实现：
  * 等待磁盘准备好
  * 发出读取扇区的命令
  * 等待磁盘准备好
  * 把磁盘扇区的数据读到指定内存

### ELF 格式文件概述

* **Executable and Linking Format**

  * 是 Linux 系统下的一种常用**目标文件（object file）**格式，三种主要类型
    * **用于执行的可执行文件（Executable file）**，用于提供程序的进程映像，加载的内存执行
    * **用于连接的可重定位文件（relocatable file）**，可与其他目标文件一起创建可执行文件和共享目标文件
    * **共享目标文件（shared object file）**，连接器可将他与其他可重定位文件和共享目标文件连接成其他的目标文件，动态链接器又可将它与可执行文件和其他共享目标文件结合起来创建一个进程映像

* 与本实验相关的 ELF 可执行文件

  * **ELF header**在文件开头处，描述了整个文件的组织
  * ELF 的文件头包含了整个执行文件的控制结构，其定义在 `elf.h`中

* **program header**， 仅对可执行文件 和 共享目标文件有意义

  * 描述与程序执行直接相关的*目标文件结构信息*，用于在文件中*定位各个段的映像*，同时包含其他一些用来*为程序创建进程映像所必需的信息*

* 可执行文件的程序头部是一个 program header结构的数组，每个结构描述了一个段或者系统准备程序执行所必需的其他信息

* **目标文件 的段**包含一个或者多个 **节区 （section）**，也就是 **段内容（segment contents）**

* 可执行目标文件在ELF头部的 `e_phentsize` , `e_phnum`成员中给出其自身程序头部大小

  * 程序头部的数据结构：

    * ```C
      struct proghdr {
        uint type;   // 段类型
        uint offset;  // 段相对文件头的偏移值
        uint va;     // 段的第一个字节将被放到内存中的虚拟地址
        uint pa;
        uint filesz;
        uint memsz;  // 段在内存映像中占用的字节数
        uint flags;
        uint align;
      };
      ```

* 根据 `elfhdr`, `prohdr`的结构描述，bootloader 可以完成对 ELF 格式的ucore的加载过程

## 3.3 操作系统启动过程

### 3.3.1 函数堆栈

* 理解调用栈：**栈的结构** 和 **EBP寄存器的使用**

* ebp ：基址寄存器

* esp：栈指针寄存器

* eip：程序指令指针，当前程序运行的指令

* 一个函数调用动作：

  * 0-n 个 **PUSH** 指令，一个 **CALL** 指令。**CALL** 指令内部暗含一个将**返回地址**压栈的动作
    * PUSH ： 参数入栈
    * 返回地址：CALL 指令下一条指令的地址
    * 将返回地址压栈：由硬件完成

* 几乎每个本地编译器都会在每个函数体之前插入：

  * ```assembly 
    pushl   %ebp
    movl   %esp , %ebp
    ```
  * 执行到程序的实际指令前，参数、返回地址、ebp寄存器 已按顺序入栈：

    * ```assembly
      +|  栈底方向        | 高位地址
       |    ...        |
       |    ...        |
       |  参数3        |
       |  参数2        |
       |  参数1        |
       |  返回地址        |
       |  上一层[ebp]    | <-------- [ebp]
       |  局部变量        |  低位地址
      ```
* 首先将 ebp 寄存器入栈，然后将栈顶指针 esp 赋值给 ebp
  
    * 在给 ebp 赋值前，原 ebp 值已经被压栈（位于栈顶），而新的 ebp 又恰恰指向栈顶
    * **此时 ebp 寄存器处于十分重要的地位**：ebp中存储着栈中的一个地址（原ebp入栈后的栈顶），从该地址为基准，
      * 向上（栈底方向）能获取返回地址、参数值，
      * 向下（栈顶方向）能获取到函数局部变量值，而改地址处有存储着上一层函数调用时的 ebp 值  

* 一般而言：`ss:[ebp+4]`为返回地址，`ss:[ebp+8]`为第一个参数值（最后一个入栈）,`ss:[ebp-4]`为第一个局部变量，`ss:[ebp]`为上一层 ebp 值
  * ebp 中的地址处总是上一层函数调用时 ebp 的值
  * 而每一层函数调用中，都能通过当时的 ebp 值，向上（栈底方向）获取返回地址，，参数值；向下（栈顶方向）获取函数局部变量值
  * 由此形成递归，直至到达栈底，这就是函数调用栈

### 3.3.2 中断与异常

* 操作系统需要对计算机系统中的各种外设进行管理，需要 CPU 和外设能够相互通信
* 需要 OS 和 CPU能够一起提供某种机制，让外设在需要操作系统处理外设相关事件的时候，能主动通知操作系统
  * 即打断操作系统和应用的正常执行，使得操作系统完成外设的相关处理，
  * 然后恢复OS 和应用的正常执行
  * 该机制即为中断机制
* 中断机制给操作系统提供了处理意外情况的能力，同时也是实现 进程/线程 抢占式调度的重要基石
* 三种特殊的中断事件：
  * **异步中断(asynchronous interrupt)**, 也称外部中断，简称中断
    * 由 CPU **外部设备**引起的外部事件（IO中断、时钟中断、控制台中断）是异步产生，即产生的时刻不确定，与CPU的执行无关
  * **同步中断（synchronous interrupt）**,内部中断，简称异常（exception）
    * 在 CPU **执行指令期间检测到不正常的 或 非法的条件**（除0，地址访问越界），所引起的内部事件
  * **陷入中断（trap interrupt）**，也称软中断（soft interrupt），系统调用简称trap
    * 在程序中使用 **请求系统服务的系统调用**而引发的事件

* 当 CPU 收到中断或者异常事件时，会暂停执行当前的程序或任务，通过一定的机制跳转到负责处理这个信号的相关处理例程中，完成对这个时间段的处理后在跳回到刚才被打断的程序或任务中。

  * 中断向量和中断服务例程的对应关系，主要是由 IDT（中断描述符表负责）
  * 操作系统 在IDT 中设置好各种**中断向量**对应的**中断描述符**，等 CPU 在产生中断后查询对应终端服务例程的起始地址
  * 而IDT本身的起始地址保存在 idtr中

  1. **中断描述符表（Interrupt Descriptor Table)**

     * IDT 将每个中断或异常编号 和 一个指向中断服务例程的描述符联系起来。

     * 和 GDT 一样，IDT是一个8 bit的描述符数组，但 IDT 第一项可以包含一个描述符

     * CPU 把中断（异常）编号 乘以 8 作为IDT的索引

     * IDT 可以位于内存的任意位置，CPU 通过IDT寄存器（idtr）的内容来寻找 IDT的起始地址

     * 操作 IDTR 的指令：LIDT，SIDT

       * 都有一个显示的操作数：一个6 字节表示的内存地址
       * **LIDT(Load IDT Register)：**使用一个包含线性地址 **基质和界限** 的内存操作数加载IDT。
         * 操作系统创建 IDT 时，需要执行它来设定**IDT的起始地址**
         * 该指令只能在特权级 0 执行
         * `libs/x86.h`中的lidt函数实现，是一条汇编指令
       * **SIDT(Store IDT Register)：**拷贝 IDTR 的 **基址和界限**部分到一个内存地址
         * 可在任意特权级执行
       * ![IDT和IDTR寄存器的结构和关系图](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image007.png)

     * > 在保护模式下，最多会存在256个Interrupt/**Exception Vectors**。
       >
       > 范围[0，31]内的32个向量被异常Exception和NMI使用，但当前并非所有这32个向量都已经被使用，有几个当前没有被使用的，请不要擅自使用它们，它们被保留，以备将来可能增加新的Exception。
       >
       > 范围[32，255]内的向量被保留给用户定义的Interrupts。Intel没有定义，也没有保留这些Interrupts。用户可以将它们用作外部I/O设备中断（8259A IRQ），或者系统调用（System Call 、Software Interrupts）等

  2. **IDT gate descriptors**

     * **Interrupts/Exceptions** 应该使用**Interrupt Gate**和**Trap Gate**
       * 唯一的区别：当调用Interrupt Gate时，**Interrupt会被CPU自动禁止**
         * 自动禁止：CPU 跳转到Interrupt Gate里的地址时，在将EFLAGS保存在栈上后，清除EFLAGS里的IF位，以免重复触发中断。
           * 
       * 而当调用Trap Gate时，**CPU则不会去禁止或打开中断**，而是保留他原来的样子
     * 在IDT中，可以包含3种类型的 Descriptor：
       * Task-gate descriptor
       * Interrupt-gate descriptor: 中断方式用到
       * Trap-gate descriptor：系统调用用到

  3. **中断处理中硬件负责完成的工作**

     * 中断服务例程包括具体负责处理中断（异常）的代码是操作系统的重要组成部分。

       * 硬件中断处理过程（起始）:从CPU受到中断事件后，打断当前程序或任务的执行，根据某种机制跳转到中断服务例程去执行的过程：

         * > * CPU在执行完当前程序的每一条指令后，都会去确认在执行刚才的指令过程中中断控制器（如：8259A）是否发送中断请求过来，如果有那么CPU就会在相应的时钟脉冲到来时从总线上读取中断请求对应的中断向量；
           > * CPU根据得到的中断向量（以此为索引）到IDT中找到该向量对应的中断描述符，中断描述符里保存着中断服务例程的段选择子；
           > * CPU使用IDT查到的中断服务例程的段选择子从GDT中取得相应的段描述符，段描述符里保存了中断服务例程的段基址和属性信息，此时CPU就得到了中断服务例程的起始地址，并跳转到该地址；
           > * CPU会根据CPL和中断服务例程的段描述符的DPL信息确认是否发生了特权级的转换。比如当前程序正运行在用户态，而中断程序是运行在内核态的，则意味着发生了特权级的转换，这时CPU会从当前程序的TSS信息（该信息在内存中的起始地址存在TR寄存器中）里取得该程序的内核栈地址，即包括内核态的ss和esp的值，并立即将系统当前使用的栈切换成新的内核栈。这个栈就是即将运行的中断服务程序要使用的栈。紧接着就将当前程序使用的用户态的ss和esp压到新的内核栈中保存起来；
           > * CPU需要开始保存当前被打断的程序的现场（即一些寄存器的值），以便于将来恢复被打断的程序继续执行。这需要利用内核栈来保存相关现场信息，即依次压入当前被打断程序使用的eflags，cs，eip，errorCode（如果是有错误码的异常）信息；
           > * CPU利用中断服务例程的段描述符将其第一条指令的地址加载到cs和eip寄存器中，开始执行中断服务例程。这意味着先前的程序被暂停执行，中断服务程序正式开始工作。

       * 硬件中断处理过程（结束）:每个中断服务例程在有中断处理工作完成后需要通过`iret`指令恢复被打断的程序执行：

         * > * 程序执行这条iret指令时，首先会从内核栈里弹出先前保存的被打断的程序的现场信息，即eflags，cs，eip重新开始执行；
           > * 如果存在特权级转换（从内核态转换到用户态），则还需要从内核栈中弹出用户态栈的ss和esp，这样也意味着栈也被切换回原先使用的用户态的栈了；
           > * 如果此次处理的是带有错误码（errorCode）的异常，CPU在恢复先前程序的现场时，并不会弹出errorCode。这一步需要通过软件完成，即要求相关的中断服务例程在调用iret返回之前添加出栈代码主动弹出errorCode。

  4. **中断产生后的堆栈变化**

     * 相同特权级和不同特权级情况下中断产生后的堆栈变换：
       * ![相同特权级和不同特权级情况下中断产生后的堆栈栈变化示意图](https://objectkuan.gitbooks.io/ucore-docs/content/lab1_figs/image010.png)

  5. **中断处理的特权级转换**

     * 通过门描述符（gate descriptor）和相关指令完成

     * 一个门描述符就是一个系统类型的段描述符，一共四个子类型：

       * 调用门描述符(call-gate)
       * 中断门描述符(interrupt-gate)
       * 陷阱门描述符(trap-gate)
       * 任务门描述符(task-gate)

     * 与中断处理相关：中断门描述符，陷阱门描述符

     * 这些门描述符被存储在中断描述符表（IDT）

     * CPU 把中断向量当作IDT表项的索引，指出当中断发生时，使用那一个门描述符来处理中断

     * > 门中的DPL和段选择符一起控制着访问，同时，段选择符结合偏移量（Offset）指出了中断处理例程的入口点。内核一般在门描述符中填入内核代码段的段选择子。产生中断后，CPU一定不会将运行控制从高特权环转向低特权环，特权级必须要么保持不变（当操作系统内核自己被中断的时候），或被提升（当用户态程序被中断的时候）。无论哪一种情况，作为结果的CPL必须等于目的代码段的DPL。如果CPL发生了改变，一个堆栈切换操作（通过TSS完成）就会发生。如果中断是被用户态程序中的指令所触发的（比如软件执行INT n生产的中断），还会增加一个额外的检查：门的DPL必须具有与CPL相同或更低的特权。这就防止了用户代码随意触发中断。如果这些检查失败，会产生一个一般保护异常（general-protection exception）。