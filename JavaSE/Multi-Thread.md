## 2. Thread 常用方法
![[Pasted image 20250215234836.png]]

## 1. 创建线程的方法

1. 继承 Thread 类
	1. 继承Thread
	2. 重写 run 方法
	3. 创建线程对象
	4. 调用 start 方法启动子线程
> 注意：
> 1. 这种方式的缺点是这个类不能继承其他类了。（Java 单继承）
> 2. 启动线程是调用 start() 方法，而不是 run 方法。
> 3. 主线程任务不要放到子线程后面

2. 实现 Runnable 接口
	1. 定义任务类实现Runnable接口
	2. 重写 run 方法
	3. 创建 MyRunnable 对象
	4. 创建 Thread 对象，传入 MyRunnable 对象
	5. 调用 Thread 的 start 方法启动线程
> 1. 优点：还可以实现其他接口继承其他类，扩展性更强
> 2. 这种方式可以用匿名内部类的写法 

3. 利用 Callable 接口、FutureTask类实现
	1. 实现Callable
	2. 重写 call 方法，**并定义返回值**
	3. 创建 callable 对象
	4. 创建 FutureTask 对象传入 callable 对象
	5. 创建 Thread 对象 传入 futureTask 对象
	6. 调用 Thread 的 start 方法启动线程
	7. **通过 futureTask 对象的 get 方法获取返回值**
> 1. 优点：这种方式可以获取线程返回的结果

## 3. 线程安全问题

线程安全问题：多个线程同时操作同一个共享资源可能会出现的业务安全问题

一个经典线程安全问题：同时取钱问题

## 4. 线程同步（解决线程安全问题）

加锁：
1. 同步代码块
```java
synchronized (//锁对象){  
    // …………
}
```
> 建议使用共享资源作为锁对象
> 对于实例方法，用 this 作为锁对象
> 对于静态方法，用字节码（类名.class）作为锁对象

2.  同步方法：在方法前加关键字 `synchronized`
>同步代码块和同步方法比较，前者锁的范围更小性能会好一些。
>后者可读性强。

3. Lock 锁
	1. 创建锁对象
	2. 访问资源前调用 lock 方法
	3. 访问结束调用 unlock 方法
> 1. 用 final 修饰锁对象
> 2. 用 try catch finally 结构，**在 finally 结构内释放锁**

## 5. 线程通信

线程通信：当多个线程共同操作共享的资源时，线程间通过某种方式告知对方自己的状态，以相互协调避免无效资源竞争。

Object 类的等待和唤醒方法
```java
void wait()
void notify()
void notifyAll()
```
注意：这些方法都应该使用同步锁对象调用

## 6. 线程池（重要）

线程池：可以复用线程的技术

> 线程池解决的问题：若线程不复用，用户每发一个请求都要创建新线程，创建新线程的开销很大并且如果请求过多会产生大量线程，这样会严重影响系统性能。

如何创建线程池？
JDK5起提供了代表线程池的「接口」：ExecutorService

如何获取线程池对象：
1. 通过实现类 ThreadPoolExecutor 自创建线程池对象
```java
//构造器，参数是重点
public ThreadPoolExecutor(
			int corePoolSize, // 核心线程数量
			int maximumPoolSize, // 最大线程数量
			long keepAliveTime, // 临时线程的存活时间
			TimeUnit unit, // 临时线程的存活时间单位
			BlockingQueue<Runnable> workQueue, // 
			ThreadFactory threadFactory,
			RejectedExecutionHandler handler
)
```