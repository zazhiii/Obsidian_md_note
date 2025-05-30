
# 线程

## 什么是线程和进程？
进程：进程是程序的一次执行过程，是系统运行程序的基本单位。
线程：线程是比进程更小的执行单位，一个进程中可以产生多个线程。
>多个线程共享进程的**堆**和**方法区**资源，每个线程有自己的**程序计数器、虚拟机栈、本地方法栈**。

## Java 线程和操作系统线程的关系？
- 现在Java的线程本质就是操作系统的线程。
- Java线程采用一对一的线程模型，一个Java线程对应一个系统内核线程。

## 线程和进程的关系、区别、优缺点？
一个进程中有多个线程，这些线程共享进程的**堆**和**方法区**。
每个线程有自己的**程序计数器、本地方法栈、虚拟机栈**

- 线程是进程划分成的更小的运行单位。
- 进程是独立的，线程可能互相影响。线程执行开销小，但不利于资源保护。进程反之

- 程序计数器：用于记录线程执行的位置，确保切换回来时能知道上一次执行到哪里了。
- 虚拟机栈：每个方法在执行前会创建一个栈帧来存储局部变量……信息。方法调用到完成就对应一个栈帧入栈到出栈的过程。
- 本地方法栈：和虚拟机栈类似。但虚拟机栈对应Java方法，本地方法栈对应本地方法（`Native`)。`HotSpot`虚拟机中二者合二为一。

- 堆：存储创建对象的内存
- 方法区：存储类信息、常量、静态变量等。

## 如何创建线程

使用代码创建线程的方式：
1. 继承Thread
2. 实现Runnable，传入Thread
3. 实现Callable，传入FutureTask，传入Thread

真正创建线程的时刻：`new Thread().start()`

## 线程状态
NEW 初始状态
RUNNABLE 可运行状态
BLOCKED 阻塞状态
WATING 等待状态
TIME_WATING 超时等待
TERMINATED 终结状态

状态的切换：
- 创建线程对象是 NEW 初始状态
- 调用 `start()` 方法转为 RUNNABLE 可运行状态
	- 没有获取到锁，进入 BLOCKED
	- 调用`wait()`进入 WATING，其他线程调用`notify()`可将它唤醒至 RUNNABLE
	- 调用`sleep(50)`进入 TIME_WATING，到时间后切换为 RUNNABLE
- 执行结束之后是 TERMINATED 终止状态

## `Thread#sleep()` 和 `Object#wait()`方法对比
[[Obsidian_md_note/bagu/Multi-Thread#`wait()`和`sleep()`的区别 ]]
- 方法归属
- 锁特性（调用前是否需要获得锁、调用后是否释放锁）

## 是否可以直接调用`Thread`的`run()`方法
[[Obsidian_md_note/bagu/Multi-Thread#run 方法和 start 方法的区别|run 方法和 start 方法的区别]]


# 多线程

## 并发与并行

## 同步与异步

## 为什么要使用多线程？

主要目的是为了**提高并发性**、**提升效率**和**响应性**，提高程序的效率和响应性

单核角度：提高程序使用CPU和IO系统的效率（IO阻塞时去处理其他任务）
多核角度：提高程序使用多核CPU的能力（多个CPU同时处理任务）

# 单核 CPU 支持多线程吗？

支持。

操作系统通过时间片轮转的方式，将 CPU 分配给不同的线程。（ CPU 在不同线程之间快速切换）

Java 线程的调度使用的是：抢占式调度。JVM 将线程的调度委托给操作系统，操作系统基于线程优先级和时间片来调度线程的执行


# 单核 CPU 运行多线程 效率一定会更高吗？

不一定。得看任务的性质。

**CPU 密集型**：单核 CPU 只能运行一个线程，多线程会导致线程间切换，增加系统开销，**降低效率**

**I/O 密集型**：CPU 在等待线程 I/O的时候可以切换到其他线程处理任务，**提高效率**

## 并发编程带来的问题

内存泄露、线程不安全、死锁……

## 如何理解线程安全和线程不安全

在多线程环境下对同一份数据的访问是否能保证正确性和一致性的描述。

# 死锁
## 什么是死锁？

两个或者多个线程在执行过程中因为竞争资源而导致的**永久性阻塞**。线程互相等待对方释放所需要的资源，由于资源被互相占用，导致线程永远不能继续执行。

## 产生死锁的条件（四个）：
1. 互斥条件：资源只能被一个线程所占有
2. 请求与保持条件：线程在请求资源而被阻塞的时候，保持资源不放。
3. 不可剥夺条件：线程在使用完资源时，不能被其他线程剥夺
4. 循环等待条件：若干线程线程一种头尾相连的等待资源关系

## 如何检测死锁？
使用`JConsole`工具

## 如何预防和避免死锁？
1. 破坏请求与保持条件：一次性申请所有的资源
2. 破坏不可剥夺条件：如果申请不到资源，主动放弃已经占有的资源
3. 破坏循环等待条件：按序申请资源

# ============

# JMM(Java Memory Model)

Java 内存模型

Java 没有复用操作系统的内存模型，而是自己提供一套内存模型屏蔽了系统差异性（跨平台）

JMM 可以看作 Java 并发编程的一种规范。他规定了**线程和主内存的关系**、规定 Java 从源代码到 CPU 指令需要遵守的规则。目的是为了避免 CPU 的某些设计导致 Java 多线程执行出现问题 。

# `volatile`

## `volatile`的作用？

保证共享变量的**可见性**

## 保证可见性的原理

通过**读写屏障**

应用：双重校验锁实现单例模式

## 可以保证原子性吗？

不能；`synchronized`可以保证可见性和原子性


# 乐观锁和悲观锁

## 什么是悲观锁？

认为线程安全问题一定会出现，每次操作资源都上锁。共享资源每次都给一个人用，其他线程阻塞，用完再转让。

## 什么是乐观锁？

认为线程安全问题**不一定**会出现，访问共享资源时不加锁；

在提交修改时验证数据在此期间是否被其他线程修改。

具体做法有**版本号机制**和**CAS算法**

>乐观锁没有真正加锁，不会阻塞线程，一定程度上性能更好。
>但是如果数据修改频繁，会导致操作频繁重试和失败，也会严重影响性能。
>
>所以理论上：
>- 悲观锁用于 **写多** 的场景
>- 乐观锁用于 **读多** 的场景

## 如何实现乐观锁？

1. 版本号机制

比对提交修改时的版本号和读取时的版本号

2. CAS算法（使用相对较多）

拿提交修改时的数据值和读取时的数据值比较，相同则没有其他线程在此期间修改变量，修改成功，否则修改失败。

## Java如何实现CAS的？

通过`Unsafe`类的本地方法（`native`方法）实现

这些方法在硬件层面实现原子性

## CAS算法有什么问题？

1. ABA问题
当一个变量在CAS期间被修改并再被修改回来时CAS是无法检测到的。可以通过版本号解决

2. CAS失败会循环重试，重试过多会导致性能问题
3. 只能保证一个共享变量的操作


# `synchronized`

## `synchronized`是什么？有什么用？

`synchronized`是一个关键字。

他能保证多线程访问资源的**同步性**

保证被他修饰的方法或代码块同一时刻只能有一个线程执行

## 如何使用

1. 修饰方法
	1. 修饰静态方法（锁当前类对象）
	2. 修饰实例方法（锁当前实例对象）
2. 修饰代码块（锁括号内的对象）

## `sychronized`原理
[[并发编程#`synchronized`简单原理]]
[[并发编程#`synchronized` 进阶原理]]

## JDK1.6 之后的 synchronized 底层做了哪些优化？锁升级原理？

- 偏向锁
- 轻量级锁
- 锁自旋
- 锁消除

锁主要存在四种状态，依次是：无锁状态、偏向锁状态、轻量级锁状态、重量级锁状态，他们会随着竞争的激烈而逐渐升级。

注意**锁可以升级不可降级**，这种策略是为了提高获得锁和释放锁的效率。

## `synchronized`和`volatile`的区别

- `volatile`保证数据可见性，不保证原子性；`synchronized`保证可见性和原子性
- `volatile`修饰变量；`synchronized`修饰方法或代码块
- `volatile`主要解决线程之间的


## `ReentrantLock`

>类似`synchronized`的可重入锁，更强大跟灵活

## `synchronized`和`ReentrantLock`对比

1. 都是可重入锁
2. `synchronized`在JVM层面实现；`ReentrantLock`是在Java层面实现的（依赖JavaAPI）
3. `ReentrantLock`增加更多功能
	1. 等待可中断
	2. 可实现公平锁
	3. 选择性通知（Condition）
	4. 超时获取锁

# ======

# `ThreadLocal`
## `ThreadLocal`作用？

为每个线程提供自己独立的变量副本

ThreadLocal 本质是线程内部存储类，从而让多个线程只操作自己内部的值，从而实现线程数据隔离。

## 原理

每个线程对象中维护了一个`ThreadLocalMap`，它可以看作一个定制版`HashMap`

![[ThreadLocal原理.png]]

当调用`ThreadLocal`的`set(T value)`时：
1. 通过`Thread.currentThread()`拿到当前线程，进而拿到当前线程维护的`ThreadLocalMap`
2. 以当前`ThreadLocal`对象作为key，将value存入`ThreadLocalMap`中

当调用`get()`时类似。

## 内存泄露是如何造成的？

`ThreadLocalMap`的 **key 是弱引用**，value是强引用。

当`ThreadLocalMap`实例没有被强引用所指向时，实例就会被GC，此时 key 变为 `null`。

但 value 仍然被`ThreadLocalMap.Entry`所指向，无法被GC

如果线程继续存活，那么就会造成内存泄露。

## 如何避免内存泄露？

用完之后调用 `remove()`

## 如何跨线程传递`ThreadLocal`的值？
JDK1.2工具：`InheritableThreadLocal`
阿里巴巴：`TransmittableThreadLocal`


# 线程池

## 如何创建线程池

1. 使用`ThreadPoolExecutor`构造函数创建（推荐）
2. 使用`Executors`创建

## 为什么不推荐使用 Executors 创建线程池

创建的线程池都有一定弊端

## 线程池的核心参数

1. 核心线程数
2. 最大线程数
3. 临时线程存活时间
4. 临时线程存活时间单位
5. 任务队列
6. 创建线程的工厂类
7. 任务拒绝策略

>通过自定义线程工厂，可以实现给线程命名

```java
//构造器，参数是重点
public ThreadPoolExecutor(
			int corePoolSize, // 核心线程数量
			int maximumPoolSize, // 最大线程数量(最大线程数 = 核心线程数 + 临时线程数)
			long keepAliveTime, // 临时线程的存活时间
			TimeUnit unit, // 临时线程的存活时间单位
			BlockingQueue<Runnable> workQueue, // 任务队列
			ThreadFactory threadFactory, // 线程工厂
			RejectedExecutionHandler handler // 任务拒绝策略
)
```

## 如何确定核心线程数

IO密集型任务：核心线程数大小设置为 $2N + 1$

CPU密集型任务：核心线程数大小设置为 $N+1$

## 线程池的拒绝策略有哪些？

1. 调用者抛异常（默认）`AbortPolicy`
2. 使用主线程来执行任务 `CallerRunsPolicy`
3. 丢弃阻塞队列中最前的任务，并执行当前任务 `DiscardOldestPolicy`
4. 直接丢弃任务 `DiscardPolicy`


## 线程池中有哪些常见阻塞队列

1. `ArrayBlockingQueue` 基于数组的有界阻塞队列，FIFO
2. `LinkedBlockingQueue`基于链表的有界阻塞队列，FIFO

区别：

| `ArrayBlockingQueue` | `LinkedBlockingQueue`（开发中运用更多）         |
| -------------------- | -------------------------------------- |
| 强制有界                 | 默认无界（`Integer.MAX_VALUE`），支持有界（推荐设置界限） |
| 底层是数组                | 底层是链表                                  |
| 提前初始化 Node 数组        | 是懒惰的，创建节点的时候生成 Node，添加数据               |
| **出队和入队是一把锁（效率更低）**  | **出队和入队是两把锁（效率更高）**                    |

## 线程池的执行原理

1. 提交任务，判断核心线程是否已满。否，则添加任务到核心线程执行。
2. 是，则判断阻塞队列是否已满。阻塞队列没满则添加任务到阻塞队列中
3. 阻塞队列满了则判断线程数是否小于等于最大线程数。是，则创建临时线程执行任务。
4. 若线程数也达到了最大线程数，则使用拒绝策略处理任务。

## 线程遇到异常之后会复用还是销毁?

- `execute()`提交的任务出现未捕获的异常则**会终止线程**
- `submit()`提交的任务会将异常封装到`Future`中，**不会终止线程**

## 如何给线程池命名？

自己实现`ThreadFactory`


# `Future`

## `Future`的作用？

使用`Future`异步去执行任务，并可以获取执行结果。

## `CompletableFutrue`的作用？

异步执行任务，获取执行结果；提供函数式编程，异步任务编排


# `AQS`

>`AbstractQueueSynchronizer` 抽象队列同步器

