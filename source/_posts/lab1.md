---
title: Lab1
categories: '-XDU OS'
tags: '-操作系统'
abbrlink: bf869091
---



# lab1

[toc]

# 1 Producer-Consumer problem

[参考博客1](https://blog.csdn.net/zhou1021jian/article/details/71514738)

[参考博客2](https://www.jianshu.com/p/a2ade02979d1)

[参考博客3](https://www.cnblogs.com/linhaostudy/p/7554942.html)

[参考博客4]()

* 也称 有限缓冲问题 `Bounded-buffer problem`

* 多线程同步的问题



## 1.1 信号量配合互斥锁

* 信号量特性：
  * 非负整数，对共享资源和线程的控制
  * 通过信号量的线程会使得信号量减一，当为零时，所有试图通过的线程等待
  * 操作：
    * Wait：线程调用该函数时
      * 要么得到资源并将信号量减一
      * 要么线程进入等待队列，直到信号量大于零
    * Release：在信号量上执行加一
      * 释放由信号量守护的资源
* Wait，Release再Linux中：
  * `int sem_wait(sem_t* sem)`
  * `int sem_post(sem_t* sem)`



* 针对该问题：
  * 设定两个信号量：
    * `empty`: 空槽的个数
    * `full`: 占有的个数
  * 生产者 向任务队列 放资源时，调用`sem_wait(&empty)` 检查队列是否已满，
    * 若满，就阻塞，直到有消费者从队列里取资源
    * 若不满，就放入资源，并通知消费者取
  * 消费者 从任务队列 取资源时，调用`sem_wait(&full)` 检查任务队列是否已空
    * 若已空，就阻塞，直到生产者向里面放入资源在苏醒
    * 若非空，就取资源，并通知生产者来放入
* 互斥锁是对任务队列进行保护



* ```C
   
  #include <stdio.h>
  #include <pthread.h>			//pthread_mutex_t, pthread_mutex_lock/unlock, pthread_t，pthread_create(), pthread_join()
  #include <semaphore.h>			//sem_wait, sem_post, sem_init
   
  #define MAX 5  //队列长度
   
  pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  sem_t full; 	//填充的个数
  sem_t empty; 	//空槽的个数
   
  int top = 0;     //队尾
  int bottom = 0;  //队头
   
  void* produce(void* arg)
  {
  	int i;
  	for ( i = 0; i < MAX*2; i++)
  	{
  		printf("producer is preparing data\n");
  		sem_wait(&empty);//若空槽个数低于0阻塞
  		
  		pthread_mutex_lock(&mutex);
  		
  		top = (top+1) % MAX;
  		printf("now top is %d\n", top);
   
  		pthread_mutex_unlock(&mutex);
  		
  		sem_post(&full);
  	}
  	return (void*)1;
  }
   
  void* consume(void* arg)
  {
  	int i;
  	for ( i = 0; i < MAX*2; i++)
  	{
  		printf("consumer is preparing data\n");
  		sem_wait(&full);//若填充个数低于0阻塞
  	
  		pthread_mutex_lock(&mutex);
  		
  		bottom = (bottom+1) % MAX;
  		printf("now bottom is %d\n", bottom);
   
  		pthread_mutex_unlock(&mutex);
  		
  		sem_post(&empty);
  	}
   
  	return (void*)2;
  }
   
  int main(int argc, char *argv[])
  {
  	pthread_t thid1;		//创建四个线程，unsigned long int
  	pthread_t thid2;
  	pthread_t thid3;
  	pthread_t thid4;
   
  	int  ret1;
  	int  ret2;
  	int  ret3;
  	int  ret4;
   
  	sem_init(&full, 0, 0);			//初始化信号量full为0
  	sem_init(&empty, 0, MAX);		//初始化信号量empty为MAX=5
   
  	pthread_create(&thid1, NULL, produce, NULL);		//
  	pthread_create(&thid2, NULL, consume, NULL);
  	pthread_create(&thid3, NULL, produce, NULL);
  	pthread_create(&thid4, NULL, consume, NULL);
   
  	pthread_join(thid1, (void**)&ret1);					//
  	pthread_join(thid2, (void**)&ret2);
  	pthread_join(thid3, (void**)&ret3);
  	pthread_join(thid4, (void**)&ret4);
   
  	return 0;
  }
  ```

  * 若将`sem_wait()`， `sem_post()`放于lock和unlock之间
  * 死锁，因为我们不能预知线程进入共享区顺序，如果消费者线程先对mutex加锁，并进入，sem_wait()发现队列为空，阻塞，而生产者在对mutex加锁时，发现已上锁也阻塞，双方永远无法唤醒对方。



* 



* `sem_init`: 长整型
  * `int sem_init(sem_t *sem, int pshared, unsigned int value);`
    * sem: 指向信号量结构的一个指针
    * pshared不为零时，信号量在进程间共享，否则只能为当前进程的线程共享
    * value为信号量的初始值



## 1.2 Pthread

* linux下用C语言开发多线程程序，Linux系统下的多线程遵循POSIX线程接口，称为pthread。

* `pthread_create()`：创建子线程
  * Linux 下创建的线程的 API 接口
  * `int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);`
  * 参数：
    * thread: 返回成功时，由 thread 指向的内存单元被设置为新创建线程的线程ID
    * attr：线程属性，默认使用NULL
    * start_routine: 新创建的线程从`start_routine`函数的地址开始运行，该函数只有一个万能参数arg，如果需要向`start_rutine`函数传递的参数不止一个，那么需要把这些参数放到一个结构中，然后把这个结构的地址作为arg的参数传入。
    * arg: 子线程处理函数的参数
  * 简单来说：
    * 第一个参数为指向线程 [标识符](http://baike.baidu.com/item/标识符)的 [指针](http://baike.baidu.com/item/指针)。
    * 第二个参数用来设置线程属性。
    * 第三个参数是线程运行函数的起始地址。
    * 最后一个参数是运行函数的参数。
  * 返回值：
    * 成功返回0，失败返回错误号
  
* `pthread_join()`: 子线程合入主线程
  * ` int pthread_join(pthread_t thread, void **retval);`
  * 主线程阻塞，等待子线程结束，然后回收子线程资源
  * 以阻塞的方式，等待thread指定的线程结束
    * 当函数返回时，被等待线程的资源被回收
    * 若线程已经结束，该函数立即返回
  * 参数：
    * thread : 线程标识符，线程id
    * retval：指向一个指向被连接线程的返回码的指针的指针
  * 返回值，0成功，错误号失败
  
* > 在很多情况下，主线程生成并起动了子线程，如果子线程里要进行大量的耗时的运算，主线程往往将于子线程之前结束，但是如果主线程处理完其他的事务后，需要用到子线程的处理结果，也就是主线程需要等待子线程执行完成之后再结束，这个时候就要用到pthread_join()方法了。
  >  即pthread_join()的作用可以这样理解：主线程等待子线程的终止。也就是在子线程调用了pthread_join()方法后面的代码，只有等到子线程结束了才能执行。

* 如果没有加pthread_join()方法，main线程里面直接就执行起走了，加了之后是等待线程执行了之后才执行的后面的代码。

![image-20210505195248476](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210505195248476.png)

![image-20210505195202511](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210505195202511.png)

# 2 用共享内存的多进程实现生产者消费者问题

## .1 前置知识

### 2.1.1 共享内存

  共享内存是不同进程间为了通信而申请的可以被不同进程共同访问的内存区域。在Linux 中，共享内存的相关API由POSIX提供。

\1. shmget函数：

函数原型：int shmget(key_t key, size_t size, int shmflg);

参数：

  Key: 用于共享内存命名，不同进程通过key进行共享内存识别;

  Size: 需要的共享内存大小；

  shmflg: 权限标志。Key标识的内存不存在时，该参数为IPC_CREAT。

 

\2. shmat 函数：创建完共享内存后，不能被进程访问，需要调用shmat启动该共享内存的访问，并把共享内存连接到当前进程的地址空间

函数原型：void *shmat(int shm_id, const void *shm_addr, int shmflg);

参数：

  Shm_id: shmget返回的描述符

  Shm_addr: 指定共享内存链接到当前进程中的地址位置，通常为空，让系统自己选择

  Shmflg: 标志位，通常为0

 

\3. shmctl 函数：控制共享内存

函数原型：int shmctl(int shm_id, int command, struct shmid_ds *buf);

参数：

  Shm_id: 同上

  Command: 要采取的操作

  Buf: 结构体指针，指向共享内存的 shmid_ds 结构。

### 2.1.2 信号量

​    信号量是一个特殊的变量，程序对其访问都是原子操作，且只允许对它进行等待（即P(信号变量))和发送（即V(信号变量))信息操作。最简单的信号量是只能取0和1的变量，这也是信号量最常见的一种形式，叫做二进制信号量。而可以取多个正整数的信号量被称为通用信号量。

Linux中对信号量的操作在我们小组的课题《Linux中信号量的实现机制》中详细讲过，接下来简单介绍：

函数semget创建一个新信号量或取得一个已有信号量；

函数semop 对信号量进行操作；

函数 semctl 控制信号量的销毁等

## 2.2 思路

  该 Task 涉及进程管理和进程间共享内存通信，可将main函数当成主进程，fork出多个子进程，并负责创建共享内存和信号量。将子进程分为两部分，生产者和消费者，通过信号量对共享内存进行互斥读写。

  生产者和消费者的操作都类似于Task1中的操作，不再赘述。



# 3 测试有名/匿名，共有/私有内存映射

## 内存映射

## .1 前置知识

​    内存映射 mmap 是Linux 内核的一个重要机制，和虚拟内存管理以及文件IO都有直接关系。

  Linux 的虚拟内存管理是基于 mmap 实现的，vm_area_struct 在mmap 创建时创建，代表了一段连续的虚拟地址，这些虚拟地址相应的映射到一个后备文件或者匿名文件的虚拟页。一个vm_area_struct映射到一组连续的页表项，页表项映射物理内存page frame，这样文件和物理内存页相映射。

### 3.1.1 mmap 和 虚拟内存管理

  Linux内核的用户进程虚拟内存管理：内核定义了mm_struct 结构表示一个用户进程的虚拟内存地址空间。

  mm**_**struct**结构**：

​                           ![image-20210507110545709](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110545709.png)    

\1.  start_code, end_code: 指定了进程的代码段的边界；

\2.  start_data, end_data: 指定了进程数据段的边界；

\3.  start_brk指定了堆的起始地址; brk指定了堆的结束位置；

\4.  start_stack: 指定了站的起始位置；

\5.  mmap_base: 指定了用户进程虚拟地址空间中 用作内存映射部分的地址的基地址，

\6.  task_size: 指定了用户进程地址空间的长度。

 

进程的mm_struct 除了包含**进程虚拟内存地址空间布局**，还包含了**虚拟内存区域**vm_area_struct信息。虚拟内存区域是内核管理用户进程虚拟地址空间的方式，数据段、代码段、共享库等都是通过vm_area_atruct管理。

vm_area_struct结构：

 ![image-20210507110550648](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110550648.png)

\1. vm_start, vm_end表示区域的开始位置和结束位置，确定了区域的边界。两个vm_area_struct不会出现交叉的情况

\2. vm_page_prot 表示这个区域的页的访问权限

\3. shared结构处理有后备文件的内存映射，和后备文件的address_space地址空间关联起来

\4. anon_vma_node, anon_vma处理匿名文件共享内存映射的情况，映射到同一物理内存页的映射都保存在一个链表中

\5. vm_pgoff, vm_file都是处理有后备文件内存映射的情况，获得该映射在文件的页偏移量，以及打开文件file实例的信息

## 3.2 mmap 的四种类型

mmap分为**后备文件的映射**和**匿名文件的映射**，这两种映射又有**私有映射和共享映射**之分，所以mmap可以创建4种类型的映射

\1. **后备文件的共享映射**，多个进程的vm_area_struct指向同一个物理内存区域，一个进程对文件内容的修改，会被其他进程可见。对文件内容的修改会被写回到后备文件。

 ![image-20210507110514289](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110514289.png)

\2. **后备文件的私有映射**，多个进程的vm_area_struct指向同一个物理内存区域，采用写时拷贝的方式，当一个进程对文件内容做修改，不会被其他进程看到。另外对文件内的修改也不会被写回到后备文件。当内存不够需要进行页回收时，私有映射的页被交换到交换区。一般用在加载共享代码库

 ![image-20210507110518143](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110518143.png)

\3. **匿名文件的共享映射**，内核创建一个初始都是0的物理内存区域，然后多个进程的vm_area_struct指向这个共享的物理内存区域，对该区域内容的修改对所有进程可见。匿名文件在页回收时被交换到交换区

 ![image-20210507110530695](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110530695.png)

\4. **匿名文件的私有映射**，内核创建一个初始都是0的物理内存区域，对该区域内容的修改只对创建者进程可见。匿名文件在页回收时被交换到交换区。malloc()底层是用了匿名文件的私有映射来分配大块内存。

 ![image-20210507110535432](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210507110535432.png)



# 4 共享库的创建和使用



## 4.1 前置知识：源代码到运行程序的过程



1. 预处理：对所有预处理指令进行处理。以#开始的语句
2. 编译：通常指 程序构建的过程，称为`compilation proper`, 将c源代码文件转换成object文件
3. 连接：将 object文件和库 串联起来，称为可执行程序
   1. 静态库已经植入程序中
   2. 共享库，只在程序中对其引用
4. 加载：加载 发生在可执行程序启动时。
   1. 首先，扫描程序，来引用共享库
   2. 然后所有引用都立即生效，对应的库也被映射到程序中



* 一个程序函数库：一个文件包含了一些编译好的代码和数据，可供其他程序使用
* 可以使得整个程序更加模块化，更容易重新编译，方便升级
* 程序函数库分为3类：
  * 静态函数库(static libraries): 在程序执行前就加入到了目标程序中
  * 共享函数库(shared libraries)：`.so`
  * 动态加载函数库(dynamically loaded libraries)：`.dll`, 与共享函数库是一样的，在l Windows 中叫动态加载函数库



## 4.2 静态函数库

### 4.2.1 生成静态函数库

* 简单的一个普通的目标文件的集合，`.a`后缀文件
* 允许程序员把程序 link 起来而不用重新编译代码，节省了重新编译代码的时间
  * 如今该优势不再那么明显
* 静态函数库对开发者来说还是很有用的，例如你想把自己提供的函数给别人使用，但是又想对函数的源代码进行保密
* 理论上说，使用ELF格式的静态库函数生成的代码可以比使用共享函数库（或者动态函数库）的程序运行速度上快一些，大概1－5％。 
* `ar rcs my_library.a file.o file1.o`



### 4.2.2 使用静态函数库

* 把它作为你编译和连接过程中的一部分用来生成你的可执行代码
* 用gcc来编译产生可执行代码的话，你可以用“-l”参数来指定这个库函数。你也可以用ld来做，使用它的“-l”和“-L”参数选项。具体用法可以参考info:gcc。 



## 4.3 共享函数库

* **作用：**共享函数库中的函数是在当一个可执行程序在启动的时候被加载
* 如果一个共享函数库正常安装，所有的程序在重新运行的时候都可以自动加载最新的函数库中的函数。对于Linux系统还有更多可以实现的功能：
  * 升级了函数库但是仍然允许程序使用老版本的函数库
  * 当执行某个特定程序的时候可以覆盖某个特定的库或者库中指定的函数
  * 可以在库函数被使用的过程中修改这些函数库

### 4.3.1 约定

* 为了编写的共享函数库支持所有有用的特性，必须遵循一系列约定

#### 4.3.1.1 命名

* 每个共享函数库的**特殊名字**, 称作`soname`
  * 以`lib`为前缀，然后是函数名
  * 以`.so`为后缀
  * 最后是版本号信息
* 特例：非常底层的C库函数都不是以lib开头命名
* 每个共享函数库都有一个**真正名字**，称为`real name`
  * 包含真正函数代码的文件
  * 真名有一个主版本号和一个发行主版号（可有可无）
    * 知道安装了什么版本的函数库
* 还有一个名字，**编译器编译时需要的函数库名字**：简单的soname，不包含任何版本号信息



## 4.4 函数库如何使用

* 基于GNU glibc的系统中，启动一个ELF格式的二进制可执行文件，会自动启动和运行一个program loader

  * 对于Linux 系统，loader的名字是`/lib/ld-linux.so.X（版本号）`
  * loader启动后，会load 其他本程序要使用的共享库

  

## 4.5 创建一个共享库

示例：

* `foo.h`: 定义接口，连接动态库

  * ![image-20210506205836103](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210506205836103-1620305918992.png)

  * ```
    #ifndef foo_h__
    #define foo_h__
    
    extern void foo(void);
    
    #endif  // foo_h__
    ```

* `foo.c`：对接口foo()的实现

  * ![image-20210506205941576](E:\4th_term\操作系统OS\Lab1\lab1.assets\image-20210506205941576.png)

  * ```
    #include <stdio.h>
     
     
    void foo(void)
    {
        puts("Hello, I'm a shared library");
    }
    ```

* `main.c`： 库的驱动程序

  * ```
    #include <stdio.h>
    #include "foo.h"
     
    int main(void)
    {
        puts("This is a shared library test...");
        foo();
        return 0;
    }
    ```

    

* 首先，编译位置无关代码，即创建object文件
  * 通过`gcc -fPIC`参数加入到共享函数库中：`PIC`: 位置无关代码
  
* 然后，将对象文件创建共享库，

* 例如：创建a.0, b.o, 然后创建一个包含a.o, b.o的共享库
  * `gcc -fPIC -g -c -Wall a.c`
  * `gcc -fPIC -g -c -Wall b.c`
  * `gcc -shared -WL -libmath.so -o  a.o b.o -lc`
  
* 通常，动态函数库的符号表里面包含了这些动态的对象的符号。这个选项在创建ELF格式的文件时候，会将所有的符号加入到动态符号表中。可以参考ld的帮助获得更详细的说明。

## 4.6 安装和使用共享库

### 方法一：将共享库拷贝入标准目录(/usr/lib或/usr/local/lib)

* 需要有权限

* 使得系统上所有用户都可以使用该共享库

方法：

* 首先，以root权限，将库放到标准位置（/usr/lib或/usr/local/lib）
  * `sudo cp /home/zihao/task4/libfoo.so /usr/lib`
* 然后，以root权限更新缓存，告诉加载器 库文件可用，
  * `sudo ldconfig`: 检查一块存在的库文件，然后创建soname符号链接到真正的函数库
  * 将创建链接到共享库，并且更新缓存以便可立即生效
  * 使用`ldconfig -p | grep foo`，核实创建了链接

* 其次，重新连接可执行程序
  * `gcc -Wall -o main.c -lfoo`
* 最后，运行程序
  * `./test`