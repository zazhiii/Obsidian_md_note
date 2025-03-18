
# 多线程基础

## 线程和进程的区别

程序由「指令」和「数据」组成。这些指令要执行数据要读写，就需要把指令加载到 CPU，数据加载到内存。

当一个程序被运行，从磁盘加载该程序的代码到内存，这时就开启了一个「**进程**」

一个「线程」就是一个指令流，将指令流中的一条条指令按一定顺序交给 CPU 执行，一个进程可以分为多个线程。

二者对比：
- 进程是正在运行的程序实例，进程中包含了线程，每个线程中执行不同任务。
- 不同的进程使用不同的内存空间，在当前进程下的线程可以共享内存空间.
- 线程更轻量，线程上下文切换开销比进程更低（上下文切换：从一个线程切换到另一个线程）

## 并发和并行


并发：线程轮流使用一个 CPU
并行：多个 CPU 同时执行多个线程

## 创建线程的方式

1. 继承 Thread 类
2. 实现 Runnable 接口
3. 实现 Callable 接口
4. 线程池创建线程

### Runnable 和 Callable 的区别？
1. Runnable 的 run 方法没有返回值，Callable 的 call 方法有返回值，和 FutureTask 配合使用可以获取异步执行的结果
2. Callable 的 call 方法可以往外抛异常，Runnable 的 run 方法不能往外抛异常

### run 方法和 start 方法的区别
1. start 方法是通过开启一个线程去执行 run 方法的逻辑，只能调用一次。
2. 直接调用 run 方法，相当于调用一个普通方法。

## 线程的状态

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

## 新建 T1 T2 T3线程，如何保证他们顺序执行？

使用 线程中的 `join()` 方法

`join()`：等待线程运行结束

e.g. `t1.join()` 阻塞当前线程，等待`t1`线程执行结束再执行。

```java
Thread t1 = new Thread(() -> System.out.println("Thread1"));  
  
Thread t2 = new Thread(() -> {  
    try {  
        t1.join(); // 等待 t1 执行完
    } catch (InterruptedException e) {  
        e.printStackTrace();  
    }  
    System.out.println("Thread2");  
});  
  
Thread t3 = new Thread(() -> {  
    try {  
        t2.join(); // 等待 t2 执行完
    } catch (InterruptedException e) {  
        e.printStackTrace();  
    }  
    System.out.println("Thread3");  
});  
  
t1.start();  
t2.start();  
t3.start();
```

## `notify()` 和 `notifyAll()`的区别

`notify()`：随机唤醒一个和`wait`的线程
`notifyAll()`：唤醒所有`wait`的线程


## `wait()`和`sleep()`的区别

共同点：
`wait(), wait(Long time), sleep(Long time)`都是让线程放弃 CPU 的使用权，进入阻塞状态

不同点：
1. 方法归属不同
	- `sleep(Long time)`是`Thread`的静态方法
	- `wait(), wait(Long time)`是 `Object`的成员方法，每个对象都有
2. 醒来时机不同
	1. `sleep(Long time), wait(Long time)`会在等待相应时间后醒来
	2. `wait(), wait(Long time)`可以被`notify()`唤醒，不唤醒的话`wait()`会一直等待下去
	3. 都可以被打断唤醒
3. 🌟锁特性不同
	1. `wait()`的**调用前**必须获取到`wait`对象的锁，`sleep()`无此限制
	2. `wait()`方法**开始执行后**会释放对象锁，其他线程可获取锁（我让出 CPU，你们可以用）
	3. `sleep()`在`synchronized`中开始执行后，不会释放对象锁（我让出 CPU，你们不能用）

```java
// 1. 调用对象的wait()方法，必须获取到对象的锁  
private static void legalWait() throws InterruptedException {  
    synchronized(LOCK){  
        LOCK.wait();  // 正常运行
    }  
}  
private static void illegalWait() throws InterruptedException {  
    LOCK.wait();  // 报错：IllegalMonitorStateException: current thread is not owner
}


/**  
 * 执行结果：  
 * waiting...  // LOCK 调用 wait() 释放锁  
 * other thread get lock // 主线程获取到锁  
 * waiting end // 主线程释放锁之后，新线程获取到锁，继续执行  
 */  
public static void waiting() throws InterruptedException {  
    new Thread(() -> {  
        synchronized (LOCK) {  
            try {  
                System.out.println("waiting...");  
                LOCK.wait(5000);  
                System.out.println("waiting end");  
            } catch (InterruptedException e) {  
                e.printStackTrace();  
            }  
        }  
    }).start();  
  
    Thread.sleep(1000);  
  
    synchronized (LOCK) {  
        System.out.println("other thread get lock");  
    }  
}


/**  
 * 执行结果：  
 * sleep...                 // 1. LOCK 调用 sleep() 但是「不释放锁」  
 * sleep end                // 2. 5s 后，LOCK 释放锁  
 * other thread get lock    // 3. 主线程获取到锁  
 */  
public static void sleeping() throws InterruptedException {  
    new Thread(() -> {  
        synchronized (LOCK) {  
            try {  
                System.out.println("sleep...");  
                Thread.sleep(5000);  
                System.out.println("sleep end");  
            } catch (InterruptedException e) {  
                e.printStackTrace();  
            }  
        }  
    }).start();  
  
    Thread.sleep(1000);  
  
    synchronized (LOCK) {  
        System.out.println("other thread get lock");  
    }  
}
```

## 如何停止一个正在运行的线程？

1. 使用退出标志，让线程正常退出，也就是`run()`执行完后线程终止
2. 调用`stop()`强行停止（不推荐，已废弃）
3. 使用`interrupt()`方法中断线程
	1. 打断阻塞的线程，会抛出`InterruptException`异常
	2. 打断正常线程，可以根据「打断状态」标记是否退出线程 


# 线程安全

## synchronized 原理 TODO

Synchronized「对象锁」采用互斥的方式让同一时刻至多只有一个线程持有「对象锁」，其他线程再想获取这个「对象锁」时会阻塞

他是由 Monitor 实现的，Monitor 时 JVM 级别的对象（C++实现）。当线程进入 synchronized 代码块中时，将对象锁与 Monitor 关联，检查 Owner 是否为 null，若为 null 则让当前线程持有对象锁；若不为 null 则到 EntryList 中等待（Blocked 状态）。若线程调用 wait 方法，则进入 WaitSet 中。

Monitor 结构
- Owner：存储当前获取锁的线程，只能有一个线程
- EntryList：关联没有抢到锁的线程，处于 Blocked 状态的线程
- WaitSet：关联调用了 wait 方法的线程，处于 Wating 状态的线程

## JMM

Java Memory Model

定义了共享内存中多线程程序读写操作的行为规范，通过这些规则来规范对内存的读写操作从而保证指令的正确性

JMM 把内存分为两块，一块是私有线程的工作区域（工作内存），一块是所有线程的共享区域（主内存）。

线程之间互相隔离，线程之间交互需要通过主内存。

## CAS

Compare And Swap，一种「乐观锁」的思想，在无锁情况下保证线程操作共享数据的原子性。

在操作共享变量时使用自旋锁，效率更高（并没有真正加锁）


## volatile

若共享变量（类的成员变量，类的静态成员变量）被 volatile 修饰，那么有两个作用：
1. 保证线程间的可见性
	>加上 volatile 就是告诉 JIT 不要该变量做优化
2. 禁止指令重排序

volatile 使用技巧：
- 写变量让 volatile 修饰的变量在代码最后
- 读变量让 volatile 修饰的变量在代码最前

## AQS


# 线程池


## 线程池的核心参数

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

## 线程池的执行原理

1. 提交任务，判断核心线程是否已满。否，则添加任务到核心线程执行。
2. 是，则判断阻塞队列是否已满。阻塞队列没满则添加任务到阻塞队列中
3. 阻塞队列满了则在判断线程数是否小于等于最大线程数。是，则创建临时线程执行任务。
4. 若线程数也达到了最大线程数，则使用拒绝策略处理任务。

>拒绝策略：
>1. 直接抛异常（默认）
>2. 使用主线程来执行任务
>3. 丢弃阻塞队列中最前的任务，并执行当前任务
>4. 直接丢弃任务


## 线程池中有哪些常见阻塞队列

1. `ArrayBlockingQueue` 基于数组的有界阻塞队列，FIFO
2. `LinkedBlockingQueue`基于链表的有界阻塞队列，FIFO

区别：

| `ArrayBlockingQueue` | `LinkedBlockingQueue`（开发中运用更多）         |
| -------------------- | -------------------------------------- |
| 强制有界                 | 默认无界（`Integer.MAX_VALUE`），支持有界（推荐设置界限） |
| 底层是数组                | 底层是链表                                  |
| 提前初始化 Node 数组        | 是懒惰的，创建节点的时候生成 Node，添加数据               |
| 出队和入队是一把锁（效率更低）      | 出队和入队是两把锁（效率更高）                        |

## 如何确定核心线程数

IO密集型任务：核心线程数大小设置为 $2N + 1$

CPU密集型任务：核心线程数大小设置为 $N+1$


## 线程池的种类

`Executors`类中提供了许多创建线程池的静态方法，常见的四种

1. 创建使用固定线程数的线程池
核心线程数和最大线程数一致，没有临时线程
```java
public static ExecutorService newFixedThreadPool(int nThreads) {  
    return new ThreadPoolExecutor(nThreads, nThreads,  
                                  0L, TimeUnit.MILLISECONDS,  
                                  new LinkedBlockingQueue<Runnable>());  
}
```
>用于任务量已知，相对耗时的任务

2. 单线程话的线程池，只用唯一的工作线程来执行任务，保证所有任务按照指定顺序 FIFO 执行
```java
public static ExecutorService newSingleThreadExecutor() {  
    return new FinalizableDelegatedExecutorService  
        (new ThreadPoolExecutor(1, 1,  
                                0L, TimeUnit.MILLISECONDS,  
                                new LinkedBlockingQueue<Runnable>()));  
}
```

3. 可缓存线程池
没有核心线程数，最大线程数为`Integer.MAX_VALUE`。
```java
public static ExecutorService newCachedThreadPool() {  
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,  
                                  60L, TimeUnit.SECONDS,  
                                  new SynchronousQueue<Runnable>());  
}
```
>适合任务比较密集，单任务执行时间短的情况

4. 提供“延时”和“周期执行”功能的ThreadPoolExecutor
```java
ScheduledExecutorService exe3 = Executors.newScheduledThreadPool(3);

// 他的任务提交方法是schedule(Runnable command, long delay, TimeUnit unit); 而不是 submit
exe3.schedule(new Task(), 2, TimeUnit.SECONDS); // 两秒之后提交

```

## 为什么不建议用`Executors`创建线程池

【强制】线程池不允许使用 Executors 去创建，而是通过 ThreadPoolExecutor 的方式，这 样的处理方式让写的同学更加明确线程池的运行规则，规避资源耗尽的风险。 

说明：Executors 返回的线程池对象的弊端如下： 
1） FixedThreadPool 和 SingleThreadPool： 允许的请求队列长度为 Integer.MAX_VALUE，可能会堆积大量的请求，从而导致 OOM。 
2） CachedThreadPool： 允许的创建线程数量为 Integer.MAX_VALUE，可能会创建大量的线程，从而导致 OOM

# 线程池使用场景

## CountDownLatch

CountDownLatch（闭锁/倒计时锁）用来进行线程同步协作，等待所有线程完成倒计时（一个或者多个程序，等待其他多个线程完成某件事之后再执行）

- 使用构造参数初始化等待计时
```java
CountDownLatch countDownLatch = new CountDownLatch(3);
```

- `await()`用来等待计时器归零
```java
countDownLatch.await();
```

-  `countDown()`让计数减一
```java
countDownLatch.countDown();
```

应用场景：线程池 + CountDownLatch
![[Pasted image 20250316163214.png]]

将每一页的导入作为一个任务提交到线程池，有$n$页就会有$n$个导入任务，`CountDownLatch`的倒计时值同样设置为$n$。主线程调用`await()`方法，等待$n$个任务完成（倒计时值减为0）再继续执行后续逻辑。

## 数据汇总

若开发中遇到需要调用多个接口获取数据，接口之间没有依赖关系，就可以用 「线程池」+「futrue」来并行执行这些接口，提高性能。 

## 异步调用

避免下一级方法影响上一级方法，可以使用异步调用执行下一级方法（不依赖下一级方法）。

## 如何控制方法的并发访问线程的数量

`Semaphore`是一个计数信号量，用来保护一个或多个共享资源的访问

1. 创建`Semaphore`对象，可以给一个容量
```java
Semaphore semaphore = new java.util.concurrent.Semaphore(3);
```

2. 通过 acquire() 获取一个许可，release() 释放一个许可
```java
semaphore.acquire();
// do ……
semaphore.release();
```

如果许可不足，acquire() 会阻塞，直到有许可

# ThreadLocal

ThreadLocal 本质是线程内部存储类，从而让多个线程只操作自己内部的值，从而实现线程数据隔离。

## 原理：

每个线程内部维护了一个 ThreadLocalMap，他本质是一个哈希表

![[Pasted image 20250316185308.png]]

第一次添加数据：

![[Pasted image 20250316172525.png]]

取值
![[Pasted image 20250316182744.png]]

## 内存泄露问题

ThreadLocalMap 中的 key 是弱引用，值为强引用。key 会被 GC 释放内存，而关联的 value 的内存并不会释放。建议主动 `remove()`释放 key 和 value

防止内存泄露：务必`remove()`
