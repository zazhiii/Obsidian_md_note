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

- 底层用 Object 数组实现
- 初始容量为 0，当第一次添加元素时才会初始化容量为 10
- 扩容的时候是原来的 「1.5 倍」（`newCapacity = oldCapacity + (oldCapacity >> 1)`)，扩容需要拷贝数组。
- 添加数据时 
> 判断 size + 1 是否大于底层数组的长度，若是则调用扩容方法。
> 元素添加值 size 位置，size ++。

`new ArrayList(10)`扩容几次？
0 次

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

## ArrayList 和 LinkedList 的区别

1. 底层数据结构：ArrayList是动态数组，LinkedList是双向链表

2. 操作数据效率
	1. ArrayList按下标查询时间复杂度为O(1)，LinkedList不支持按下标查询
	2. 查找某个元素：都是O(n)
	3. 新增删除：头尾都是O(1)，中间都是O(n)

3. 内存空间占用：
	1. ArrayList是连续内存，节省空间。
	2. LinkedList是双向链表，还需要存储两个指针，更占内存。

4. 线程安全
	ArrayList 和 LinkedList都不是线程安全的
	
>如何保证他们的线程安全？
>1. 在方法内使用，在方法内是局部变量，每个线程都有一份
>2. 使用线程安全的 ArrayList 和 LinkedList
```java
List<Integer> list1 = Collections.synchronizedList(new ArrayList<>());  
List<Integer> list2 = Collections.synchronizedList(new LinkedList<>());
```


# HashMap

二叉搜索树(Binary Search Tree, BST)：对于任意一个节点，满足左子节点小于该节点，右子节点大于该节点。增，删，查的时间复杂度都是$O(\log n)$。极端情况会退化成链表。

红黑树(Red Black Tree)：一种自平衡的二叉搜索树。增、删、查复杂度为$O(\log n)$
满足规则：
1. 节点要么为红色，要么为黑色
2. 根节点为黑色
3. 叶子节点都是黑色空节点
4. 红节点的子节点都是黑节点
5. 从任意节点到叶子节点所经过相同数量的黑节点

