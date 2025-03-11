
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