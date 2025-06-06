## Array

堆内存中开辟一段连续的空间存储数组元素，栈内存中存放数组的引用指向首地址。

如何获取元素呢？
`baseAddress`：数组首地址
`dataTypeSize`：数组元素所占大小（例如 int 占 4 个字节）
要获取第 i 个元素的：$a[i] = baseAddress + i \times dataTypeSize$ 

索引为什么从 0 开始而不是从 1 开始？
若索引从 1 开始，寻址公式变为$a[i] = baseAddress + (i-1) \times dataTypeSize$ 
对于 cpu 来说多了一次减法操作，会降低性能。

# ArrayList

>`ArrayList`可以存储`null`
## ArrayList 与 Array 的转换

Array => ArrayList
修改会互相影响，转换的 ArrayList 中的数组和 Array 是同一个引用
```java
Integer[] a = {1, 2, 3, 4, 5};  
List<Integer> list = Arrays.asList(a);  

System.out.println(list); // [1, 2, 3, 4, 5]  
a[0] = 100;  
System.out.println(list); // [100, 2, 3, 4, 5]
```

ArrayList => Array
修改不会互相影响，通过数组拷贝实现。
```java
ArrayList<Integer> list = new ArrayList<>();  
list.add(1);  
list.add(2);  
list.add(3);  
Integer[] a = list.toArray(new Integer[list.size()]);  
  
System.out.println(Arrays.toString(a)); // [1, 2, 3]  
list.set(0, 100);  
System.out.println(Arrays.toString(a)); // [1, 2, 3]
```

## 🌟ArrayList 和 LinkedList 的区别

1. 底层数据结构：ArrayList是`Object`数组，LinkedList是双向链表

2. 操作数据效率
	1. `ArrayList` 支持随机访问（通过下标`O(1)`访问），`LinkedList`不支持随机访问（但是有`get(int index)`方法）
	2. 查找某个元素：都是O(n)
	3. 新增删除：头部操作前者`O(n)`后者`O(1)`，尾部操作都是`O(1)`，指定位置操作都是`O(n)`

3. 内存空间占用：
	1. ArrayList是连续内存，节省空间。
	2. LinkedList是双向链表，还需要存储两个指针、节点对象，更占内存。

4. 线程安全
	ArrayList 和 LinkedList都不是线程安全的
	
>如何保证他们的线程安全？
>1. 在方法内使用，在方法内是局部变量，每个线程都有一份
>2. 使用线程安全的 ArrayList 和 LinkedList
```java
List<Integer> list1 = Collections.synchronizedList(new ArrayList<>());  
List<Integer> list2 = Collections.synchronizedList(new LinkedList<>());
```

## `ArrayList`扩容机制
- 🌟**初始容量为 0**，当第一次添加元素时才会初始化容量为 **10**
- 🌟每次扩容 **「1.5 倍」**
>`newCapacity = oldCapacity + (oldCapacity >> 1)`，扩容需要拷贝数组。

 - 添加数据时 
> 判断 size + 1 是否大于底层数组的长度，若是则调用扩容方法。
> 元素添加值 size 位置，size ++。



# `ArrayDeque`
- 不能存`null`

# `BlockingQueue`
#[[Obsidian_md_note/bagu/Multi-Thread#线程池中有哪些常见阻塞队列 | 阻塞队列]]

# HashMap

二叉搜索树(Binary Search Tree, BST)：对于任意一个节点，满足左子节点小于该节点，右子节点大于该节点。增，删，查的时间复杂度都是$O(\log n)$。极端情况会退化成链表。

红黑树(Red Black Tree)：一种自平衡的二叉搜索树。增、删、查复杂度为$O(\log n)$
满足规则：
1. 节点要么为红色，要么为黑色
2. 根节点为黑色
3. 叶子节点都是黑色空节点
4. 红节点的子节点都是黑节点
5. 从任意节点到叶子节点所经过相同数量的黑节点

## HashMap底层实现原理

数据结构：使用 hash 表数据结构（散列表），即数组 + 链表 + 红黑树
1. 当往 HashMap 中 put 值时，利用 key 的 hashCode 重新 hash 计算出当前值在数组的下标
2. 存储时，若出现相同 hash 值怎么办？
	1. 若 key 相同，则覆盖原始值
	2. 若 key 不同（hash 冲突），则将 k-v 放入链表或者红黑树中（链表长度 >= 8 且 数组长度 >= 64时，链表会转换为红黑树；扩容时，若红黑树节点 <= 6 则会退化成链表）
3. get 值时，通过 hash 值直接找到下标，进一步判断 key 是否相同，进而找到对应值

> 注意：JDK1.8 之前解决哈希冲突是采用拉链法，没有采用红黑树
> 
> 数组长度在第一次添加元素时初始化大小为 16
> 
> 数组长度在 < 64时链表长度到达 8 之后优先扩容数组，而非转换为红黑树
>
>链表转红黑树的条件（两个）：
>	1. 链表长度 $\ge$ 8
>	2. 数组长度 $\ge$ 64
>
>红黑树退化链表条件：
>	1. 数组长度 $\le$ 6
> 
> 为什么退化条件不是数组长度 $\le$ 7?    防止频繁地转换


## put的流程

源码：[[HashMap#put 的流程]]

1. 判断键值对数组 table 是否为空或 null，是则执行 resize() 扩容（初始化）
2. 根据 key 计算 hash 值，进而的到数组索引`i`
3. 判断 `table[i] == null`，若是，则直接新建节点添加
4. 若`table[i] != null`
	1. 判断`table[i]`的首个元素和新元素的 key 是否一样，是则直接用新元素直接覆盖。
	2. 判断`table[i]`是否是红黑树节点，若是则执行红黑树加入节点操作。
	3. 若前面都不满足，则`table[i]`为链表节点。遍历链表，过程中有相同的 key 则直接覆盖。若遍历到尾部，则将新节点加入尾部。最后判断链表长度是否 >= 8，是则转换为红黑树。

## 扩容

源码：[[HashMap#扩容]]
- 第一次添加数据会初始化长度为 16，之后每次达到扩容阈值（数组长度 * 扩容因子(默认 0.75））才会扩容
- 每次扩容 2 倍
- 扩容之后会创建新数组，再将老数组的数据移动到新数组中
	- 遍历老数组
	- 位置数据为`null`的不移动
	- 若为单节点，即没有 hash 冲突的位置，使用`e.hash & (newCap - 1)`重新计算索引
	- 若为红黑树节点，走红黑树的添加
	- 若为链表，遍历链表通过 hash 值重新计算在新数组的位置

## HashMap的寻址算法

> 如何通过 key 得到他应该放在数组的那个下标位置呢？

key 对象有一个属性是 hashCode，他就是用来定位查找 key 的。并且相同的 key 一定会有相同的 hashCode。

HashMap 没有直接用对象的 hashCode 来计算位置，而是用扰动算法进一步计算了一次。

1. 扰动算法，让 hash 值更加均匀，减少 hash 冲突。
```java
static final int hash(Object key) {  
    int h;  
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);  
}
```

2. 计算数组中的位置
```java
hash & (n - 1)
```
数组的默认长度为 16，每次扩容都是 2 倍，所以$n$是 2 的整数次幂。在$n$是2的整数次幂时，上面的式子等价于`hash % n`， 前者效率更高。这样就把 hash 值映射到了数组下标位置中。

## HashMap长度为什么一定是$2^n$

1. 计算索引时效率更高：`hash & (n - 1)`代替`hash % n`
2. 扩容时重新计算索引效率更高：用`hash & oldCap == 0`来决定元素留在原位`i`还是`i + oldCap`

## HashMap在 1.7 多线程死循环

1.7 多个元素在一个桶时是使用「**链表**」解决的，且插入链表是使用「**头插法**」。
在扩容的情况下，多个线程对链表进行操作，头插法会导致链表节点指向不正确，在链表中形成环。
在后续查询的时候就会导致死循环。

在1.8改成了尾插法


# `ConcurrentHashMap`
1. JDK 1.7 和 JDK 1.8 中 `ConcurrentHashMap`的区别？
2. 与 `HashTable` 的区别?
3. 为什么`key`和`value`不能为`null`？？？
4. 是否能保证复合操作的原子性？


