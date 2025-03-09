## 常见的 Fields

```java
// 默认初始容量
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16 
// 默认加载因子 扩容阈值 = 数组容量 * 加载因子
static final float DEFAULT_LOAD_FACTOR = 0.75f;
// 存放节点的数组
transient Node<K,V>[] table;
// 存放元素个数
transient int size;

static class Node<K,V> implements Map.Entry<K,V> {  
    final int hash;  
    final K key;  
    V value;  
    Node<K,V> next;  
  
    Node(int hash, K key, V value, Node<K,V> next) {  
        this.hash = hash;  
        this.key = key;  
        this.value = value;  
        this.next = next;  
    }
    // …………
}
```

## 构造函数

1. 无参构造器
>`HashMap`是懒惰加载，在创建对象时没有初始化数组
>无参构造器中设置默认加载因子为 0.75
```java
public HashMap() {  
    this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted  
}
```

## put 的流程

```java
public V put(K key, V value) {  
	// hash(key) 计算 hash 值
    return putVal(hash(key), key, value, false, true);  
}  
  
final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict) {  
    Node<K,V>[] tab; Node<K,V> p; int n, i;  
    
    // 判断 table 数组是否未初始化
    if ((tab = table) == null || (n = tab.length) == 0)  
        n = (tab = resize()).length; // 初始化
        
    // 判断 key 的 hash 值对应的位置是否有元素
    if ((p = tab[i = (n - 1) & hash]) == null)  
        tab[i] = newNode(hash, key, value, null); // 没有元素，直接添加新节点
        
    else { // 有元素的情况
        Node<K,V> e; K k;  
        // 判断该位置的 key 是否与新 key 相同
        if (p.hash == hash && ((k = p.key) == key || (key != null && key.equals(k))))  
            e = p;  
        
        // 不同，判断是否为红黑树节点
        else if (p instanceof TreeNode)  
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value); // 进行红黑树操作
	    
	    // 不同，且不是红黑树节点，证明是链表
        else {
	        // 遍历链表
            for (int binCount = 0; ; ++binCount) {  
	            // 判断是否到尾节点
                if ((e = p.next) == null) { 
	                // 将新节点放入尾部 
                    p.next = newNode(hash, key, value, null);  
                    // 判断链表长度是否大于等于 8
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st  
                        treeifyBin(tab, hash); // 转换红黑树  
                    break;  
                }  
	            // 判断是否有相同 key 的节点，有则直接覆盖该节点（修改操作）
                if (e.hash == hash &&  
                    ((k = e.key) == key || (key != null && key.equals(k))))  
                    break;  
                p = e;  
            }  
        }  
        if (e != null) { // existing mapping for key  
            V oldValue = e.value;  
            if (!onlyIfAbsent || oldValue == null)  
                e.value = value;  
            afterNodeAccess(e);  
            return oldValue;  
        }  
    }  
    // 记录节点修改次数
    ++modCount;
	// 判断数据量是否大于扩容阈值，threshold：扩容阈值
	if (++size > threshold)  
        resize();  
    afterNodeInsertion(evict);  
    return null;  
}
```

## 扩容
```java

final Node<K,V>[] resize() {  
    Node<K,V>[] oldTab = table;  
    int oldCap = (oldTab == null) ? 0 : oldTab.length;  
    int oldThr = threshold;  
    int newCap, newThr = 0;  
    
    // 判断「老容量」是否为 0，不为 0 则已经初始化
    if (oldCap > 0) {  
	    // 判断数组长度是否大于最大数组长度，若是则将扩容阈值设置为 int 最大值，即后续都不会再扩容了。
        if (oldCap >= MAXIMUM_CAPACITY) {  
            threshold = Integer.MAX_VALUE;  
            return oldTab;  
        }  
        // 「扩容」：newCap = oldCap << 1
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&  
                 oldCap >= DEFAULT_INITIAL_CAPACITY)  
            newThr = oldThr << 1; // double threshold  
    }
    else if (oldThr > 0) // initial capacity was placed in threshold  
        newCap = oldThr;  
	// 数组未初始化，容量和扩容阈值都设置为默认值
    else {               // zero initial threshold signifies using defaults  
        newCap = DEFAULT_INITIAL_CAPACITY;  
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);  
    }  
    if (newThr == 0) {  
        float ft = (float)newCap * loadFactor;  
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?  
                  (int)ft : Integer.MAX_VALUE);  
    }  
    threshold = newThr;  
    @SuppressWarnings({"rawtypes","unchecked"})  
    // 创建新数组，并赋值
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];  
    table = newTab;  
    // 判断是否不为空，不为空证明不是初始化数据
    if (oldTab != null) {  
	    // 遍历老数组，将老数组的数据转移到新数组
        for (int j = 0; j < oldCap; ++j) {  
            Node<K,V> e;  
            // 老数组的值不为 null 才转移
            if ((e = oldTab[j]) != null) {  
                oldTab[j] = null;  
                // 判断是否有下一个节点
                if (e.next == null)
	                // 没有下一个节点，直接将该位置的节点转移到新数组  
                    newTab[e.hash & (newCap - 1)] = e;  
                // 判断是否为红黑树节点
                else if (e instanceof TreeNode)  
	                // 树操作
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);  
                // 节点为链表的转移
                else { // preserve order  
                    Node<K,V> loHead = null, loTail = null;  
                    Node<K,V> hiHead = null, hiTail = null;  
                    Node<K,V> next;  
                    do {  
                        next = e.next;  
                        if ((e.hash & oldCap) == 0) {  
                            if (loTail == null)  
                                loHead = e;  
                            else  
                                loTail.next = e;  
                            loTail = e;  
                        }  
                        else {  
                            if (hiTail == null)  
                                hiHead = e;  
                            else  
                                hiTail.next = e;  
                            hiTail = e;  
                        }  
                    } while ((e = next) != null);  
                    if (loTail != null) {  
                        loTail.next = null;  
                        newTab[j] = loHead;  
                    }  
                    if (hiTail != null) {  
                        hiTail.next = null;  
                        newTab[j + oldCap] = hiHead;  
                    }  
                }  
            }  
        }  
    }  
    return newTab;  
}
```

## get
流程：通过 hash 值找到 key 在数组中的位置，进一步比对 key 是否相等来找到要找的 key
```java

public V get(Object key) {  
    Node<K,V> e;  
    return (e = getNode(hash(key), key)) == null ? null : e.value;  
}

final Node<K,V> getNode(int hash, Object key) {  
    Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
    // 判断 数组是否未初始化、key 对应的位置是否为 null
    if ((tab = table) != null && (n = tab.length) > 0 &&  
        (first = tab[(n - 1) & hash]) != null) {  
        // 第一个节点的 key 是否等于查询 key
        if (first.hash == hash && // always check first node  
            ((k = first.key) == key || (key != null && key.equals(k))))  
            return first;  
	    // 第一个节点不是要查找的节点
        if ((e = first.next) != null) {  
	        // 判断是否为红黑树节点，若是则走红黑树的查询方法
            if (first instanceof TreeNode)  
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);  
	        // 遍历链表查询
            do {  
                if (e.hash == hash &&  
                    ((k = e.key) == key || (key != null && key.equals(k))))  
                    return e;  
            } while ((e = e.next) != null);  
        }  
    }  
    return null;  
}
```