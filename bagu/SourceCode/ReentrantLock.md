>JDK 1.8
## 构造器
```java
public ReentrantLock() {  
    sync = new NonfairSync();  
}
```

# 非公平锁
## 加锁
```java
// NonfairSync
final void lock() {  
    if (compareAndSetState(0, 1)) // CAS 设置 state 的值  
        setExclusiveOwnerThread(Thread.currentThread());  // 设置独占线程为「当前线程」
    else  
        acquire(1); // 加锁失败后的操作  
}
```

## 获取锁失败之后的操作
```java
// AbstractQueuedSynchronizer
public final void acquire(int arg) {  
    if (!tryAcquire(arg) &&  // 再试一次能否获取锁
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))  // 创建节点加入等待队列
        selfInterrupt();  
}

// AbstractQueuedSynchronizer
final boolean acquireQueued(final Node node, int arg) {  
    boolean failed = true;  
    try {  
        boolean interrupted = false;  
        for (;;) {  
            final Node p = node.predecessor();  
            if (p == head && tryAcquire(arg)) { // 继续尝试获取锁  
                setHead(node);  // 获取锁成功，设置当前节点为头节点
                p.next = null; // help GC  删除前面的节点
                failed = false;  
                return interrupted;  
            }  
            if (shouldParkAfterFailedAcquire(p, node) &&  // 判断获取锁失败之后是否应该阻塞
                parkAndCheckInterrupt()) // 阻塞线程
                interrupted = true;  
        }  
    } finally {  
        if (failed)  
            cancelAcquire(node);  
    }  
}
```

##  解锁
```java
// NonfairSync
public void unlock() {  
    sync.release(1);  
}
```

```java
// AbstractQueuedSynchronizer
public final boolean release(int arg) {  
    if (tryRelease(arg)) { // 尝试释放锁 
        Node h = head;  
        if (h != null && h.waitStatus != 0)  
            unparkSuccessor(h); // 唤醒头节点后面节点 
        return true;  
    }  
    return false;  
}
```

```java
// Sync
protected final boolean tryRelease(int releases) {  
    int c = getState() - releases;  
    if (Thread.currentThread() != getExclusiveOwnerThread())  
        throw new IllegalMonitorStateException();  
    boolean free = false;  
    if (c == 0) {  
        free = true;  
        setExclusiveOwnerThread(null); // 独占线程设置为 null
    }  
    setState(c); // 状态设置为 0
    return free;  
}
```

# 可重入的原理

```java
// Sync
final boolean nonfairTryAcquire(int acquires) {  
    final Thread current = Thread.currentThread();  
    int c = getState(); 
    // 锁没有被独占，尝试获取锁 
    if (c == 0) {  
        if (compareAndSetState(0, acquires)) {  
            setExclusiveOwnerThread(current);  
            return true;  
        }  
    }  
    // 锁被独占，且独占线程是当前线程，发生了「锁重入」
    else if (current == getExclusiveOwnerThread()) {  
        int nextc = c + acquires;  // state ++ 
        if (nextc < 0) // overflow  
            throw new Error("Maximum lock count exceeded");  
        setState(nextc);  
        return true;  
    }  
    return false;  
}

protected final boolean tryRelease(int releases) {  
    int c = getState() - releases; // state --
    if (Thread.currentThread() != getExclusiveOwnerThread())  
        throw new IllegalMonitorStateException();  
    boolean free = false;  
    if (c == 0) {  
        free = true;  
        setExclusiveOwnerThread(null);  
    }  
    setState(c);  
    return free;  
}
```

> 总结：通过 AQS 的 state 字段维护重入次数，重入一次 + 1，释放一次 - 1，state == 0 时真正释放锁


# 可打断原理

## 不可打断流程
```java
// NonfairSync
final void lock() {  
    if (compareAndSetState(0, 1))
        setExclusiveOwnerThread(Thread.currentThread());
    else  
        acquire(1); // into
}

// AbstractQueuedSynchronizer
public final void acquire(int arg) {  
    if (!tryAcquire(arg) &&  
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg)) // into
        selfInterrupt();  
}

// AbstractQueuedSynchronizer
final boolean acquireQueued(final Node node, int arg) {  
    boolean failed = true;  
    try {  
        boolean interrupted = false;  
        for (;;) {  
            final Node p = node.predecessor();  
            if (p == head && tryAcquire(arg)) { 
                setHead(node); 
                p.next = null;
                failed = false;  
                return interrupted;  
            }  
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt()) // into
                interrupted = true; // 判断打断之后，这里只做了赋值操作，没有停止线程
        }  
    } finally {  
        if (failed)  
            cancelAcquire(node);  
    }  
}

// AbstractQueuedSynchronizer
private final boolean parkAndCheckInterrupt() {  
    LockSupport.park(this);  
    return Thread.interrupted();  
}
```

## 可打断流程

```java
// ReentrantLock
public void lockInterruptibly() throws InterruptedException {  
    sync.acquireInterruptibly(1);  
}

// AbstractQueuedSynchronizer
public final void acquireInterruptibly(int arg)  
        throws InterruptedException {  
    if (Thread.interrupted())  
        throw new InterruptedException();  
    if (!tryAcquire(arg)) // 尝试获取锁 
        doAcquireInterruptibly(arg); // 若没获取到锁，执行「可打断」获取 
}

// AbstractQueuedSynchronizer
private void doAcquireInterruptibly(int arg)  
    throws InterruptedException {  
    final Node node = addWaiter(Node.EXCLUSIVE);  
    boolean failed = true;  
    try {  
        for (;;) {  
            final Node p = node.predecessor();  
            if (p == head && tryAcquire(arg)) {  
                setHead(node);  
                p.next = null;
                failed = false;  
                return;  
            }  
            if (shouldParkAfterFailedAcquire(p, node) &&  
                parkAndCheckInterrupt())  
                throw new InterruptedException(); // 区别在这，这里真正打断了线程
        }  
    } finally {  
        if (failed)  
            cancelAcquire(node);  
    }  
}
```

# 非公平锁原理
```java
protected final boolean tryAcquire(int acquires) {  
    return nonfairTryAcquire(acquires);  
}

final boolean nonfairTryAcquire(int acquires) {  
    final Thread current = Thread.currentThread();  
    int c = getState();  
    if (c == 0) {  
        if (compareAndSetState(0, acquires)) {  
            setExclusiveOwnerThread(current);  
            return true;  
        }  
    }  
    else if (current == getExclusiveOwnerThread()) {  
        int nextc = c + acquires;  
        if (nextc < 0) // overflow  
            throw new Error("Maximum lock count exceeded");  
        setState(nextc);  
        return true;  
    }  
    return false;  
}
```

# 公平锁原理

```java
protected final boolean tryAcquire(int acquires) {  
    final Thread current = Thread.currentThread();  
    int c = getState();  
    if (c == 0) {  
	    // 去检查了 AQS 队列是否有前驱节点，没有才去竞争
        if (!hasQueuedPredecessors() &&  // into
            compareAndSetState(0, acquires)) {  
            setExclusiveOwnerThread(current);  
            return true;  
        }  
    }  
    else if (current == getExclusiveOwnerThread()) {  
        int nextc = c + acquires;  
        if (nextc < 0)  
            throw new Error("Maximum lock count exceeded");  
        setState(nextc);  
        return true;  
    }  
    return false;  
}

public final boolean hasQueuedPredecessors() {  
    Node t = tail;
    Node h = head;  
    Node s;  
    return h != t &&  
	    // 队列中没有老二 ｜｜ 老二不是自己
        ((s = h.next) == null || s.thread != Thread.currentThread());  
}
```
> 总结：当前线程去获取锁时，需要判断等待队列中释放有**其他**优先级比自己高的线程在等待，没有的话自己才去尝试获取锁。

# 条件变量原理

## 等待

```java
// ConditionObject
public final void await() throws InterruptedException {  
    if (Thread.interrupted())  
        throw new InterruptedException();  
    Node node = addConditionWaiter(); // 添加一个等待节点
    int savedState = fullyRelease(node); // 释放掉该节点身上的锁（包括重入计数的值，全部释放）
    int interruptMode = 0;  
    while (!isOnSyncQueue(node)) {  
        LockSupport.park(this);  
        if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)  
            break;  
    }  
    if (acquireQueued(node, savedState) && interruptMode != THROW_IE)  
        interruptMode = REINTERRUPT;  
    if (node.nextWaiter != null) // clean up if cancelled  
        unlinkCancelledWaiters();  
    if (interruptMode != 0)  
        reportInterruptAfterWait(interruptMode);  
}
```

## 唤醒

```java
// ConditionObject
public final void signal() {  
    if (!isHeldExclusively())  
        throw new IllegalMonitorStateException();  
    Node first = firstWaiter;  
    if (first != null)  
        doSignal(first);  
}

// ConditionObject
private void doSignal(Node first) {  
    do {  
	    // 将节点从 ConditionObject 中的链表里断开
        if ( (firstWaiter = first.nextWaiter) == null)  
            lastWaiter = null;  
        first.nextWaiter = null;  
    } while (!transferForSignal(first) &&  // 将节点加入竞争锁的队列中
             (first = firstWaiter) != null);  
}
```