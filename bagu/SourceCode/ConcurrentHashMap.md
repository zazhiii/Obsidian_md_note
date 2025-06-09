# 重要属性和内部类

```java
// 默认：0
// 初始化时：-1
// 扩容时：-（1 + 扩容线程数）
// 初始化、扩容完成后：下一次扩容的阈值
private transient volatile int sizeCtl;

// 节点类
static class Node<K,V> implements Map.Entry<K,V> { …… }

// hash表
transient volatile Node<K,V>[] table;  

// 扩容时 新的 hash 表
private transient volatile Node<K,V>[] nextTable;

// 扩容时，若某个 bin 完成迁移，则用 ForwardingNode 作为旧 table bin 的头节点
// 当其他线程再来扩容这个 bin 时，能够判断出已经完成扩容，就不做操作了
// 当扩容时线程来 get 数据时，能够判断出需要去新 table 中获取数据
static final class ForwardingNode<K,V> extends Node<K,V> { …… }


```

# 构造器

```java
public ConcurrentHashMap(int initialCapacity,  
                         float loadFactor, int concurrencyLevel) {  
    if (!(loadFactor > 0.0f) || initialCapacity < 0 || concurrencyLevel <= 0)  
        throw new IllegalArgumentException();  
    if (initialCapacity < concurrencyLevel)   // Use at least as many bins  
        initialCapacity = concurrencyLevel;   // as estimated threads  
    long size = (long)(1.0 + (long)initialCapacity / loadFactor);  
    int cap = (size >= (long)MAXIMUM_CAPACITY) ?  
        MAXIMUM_CAPACITY : tableSizeFor((int)size); // 确保是 2^n
    this.sizeCtl = cap;  
}
```

# get 流程

```java
public V get(Object key) {  
    Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;  
    // 确保哈希码是正数
    int h = spread(key.hashCode());  
    if ((tab = table) != null && (n = tab.length) > 0 &&  
        (e = tabAt(tab, (n - 1) & h)) != null) {  
        // 头节点就是要找的 key
        if ((eh = e.hash) == h) {  
            if ((ek = e.key) == key || (ek != null && key.equals(ek)))  
                return e.val;  
        }  
        // hash 值为负数代表该 bin 正在扩容或者为 treebin，调用 find 方法查找 key
        else if (eh < 0)  
            return (p = e.find(h, key)) != null ? p.val : null;  
	    // 遍历链表查找 key
        while ((e = e.next) != null) {  
            if (e.hash == h &&  
                ((ek = e.key) == key || (ek != null && key.equals(ek))))  
                return e.val;  
        }  
    }  
    return null;  
}
```

>整个过程没有加锁

# put流程

```java
public V put(K key, V value) {  
    return putVal(key, value, false);  
}  
  
final V putVal(K key, V value, boolean onlyIfAbsent) {  
    if (key == null || value == null) throw new NullPointerException();  
    int hash = spread(key.hashCode());  
    int binCount = 0;  
    for (Node<K,V>[] tab = table;;) {  
        Node<K,V> f; int n, i, fh; K fk; V fv;  
        if (tab == null || (n = tab.length) == 0)  
	        // cas 初始化 table
            tab = initTable();  
        else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {  
	        // cas 创建头节点
            if (casTabAt(tab, i, null, new Node<K,V>(hash, key, value)))  
                break;                   // no lock when adding to empty bin  
        }  
        // 发现正在扩容，帮忙扩容
        else if ((fh = f.hash) == MOVED)  
            tab = helpTransfer(tab, f);  
        else if (onlyIfAbsent // check first node without acquiring lock  
                 && fh == hash  
                 && ((fk = f.key) == key || (fk != null && key.equals(fk)))  
                 && (fv = f.val) != null)  
            return fv;  
        else {  
            V oldVal = null;  
            // 锁住头节点，开始添加元素
            synchronized (f) {  
                if (tabAt(tab, i) == f) {  
                    if (fh >= 0) {  
                        binCount = 1;  
                        for (Node<K,V> e = f;; ++binCount) {  
                            K ek;  
                            if (e.hash == hash &&  
                                ((ek = e.key) == key ||  
                                 (ek != null && key.equals(ek)))) {  
                                oldVal = e.val;  
                                if (!onlyIfAbsent)  
                                    e.val = value;  
                                break;  
                            }  
                            Node<K,V> pred = e;  
                            if ((e = e.next) == null) {  
                                pred.next = new Node<K,V>(hash, key, value);  
                                break;  
                            }  
                        }  
                    }  
                    else if (f instanceof TreeBin) {  
                        Node<K,V> p;  
                        binCount = 2;  
                        if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,  
                                                       value)) != null) {  
                            oldVal = p.val;  
                            if (!onlyIfAbsent)  
                                p.val = value;  
                        }  
                    }  
                    else if (f instanceof ReservationNode)  
                        throw new IllegalStateException("Recursive update");  
                }  
            }  
            if (binCount != 0) {  
	            // 若链表长度 >= 树化阈值（8），则将链表转化为🌳
                if (binCount >= TREEIFY_THRESHOLD)  
                    treeifyBin(tab, i);  
                if (oldVal != null)  
                    return oldVal;  
                break;  
            }  
        }  
    }  
    addCount(1L, binCount);  
    return null;  
}
```

# 初始化 hash 表

```java
private final Node<K,V>[] initTable() {  
    Node<K,V>[] tab; int sc;  
    while ((tab = table) == null || tab.length == 0) {  
	    // 发现正在初始化，让出 cpu
        if ((sc = sizeCtl) < 0)  
            Thread.yield(); 
        // 将 sizeCtl cas 为 -1，成功了则正式开始初始化 table，失败了进入下一轮循环
        else if (U.compareAndSetInt(this, SIZECTL, sc, -1)) {  
            try {  
                if ((tab = table) == null || tab.length == 0) {  
                    int n = (sc > 0) ? sc : DEFAULT_CAPACITY;  
                    @SuppressWarnings("unchecked")  
                    Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];  
                    table = tab = nt;  
                    sc = n - (n >>> 2);  
                }  
            } finally {  
                sizeCtl = sc;  
            }  
            break;  
        }  
    }  
    return tab;  
}
```