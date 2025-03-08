
# 成员变量
几个关键的成员变量
```java
/**  
 * Default initial capacity. 
 * 这个常量用于在 ArrayList 首次添加元素时，确定内部数组的初始大小。
 * */
private static final int DEFAULT_CAPACITY = 10;  
  
/**  
 * Shared empty array instance used for empty instances. 
 * 这是一个共享的空数组实例，用于表示空的 `ArrayList` 实例
 * 
 * 当你创建一个空的 `ArrayList` 并且指定初始容量为 0 时，`elementData` 会被初始化
 * 为 `EMPTY_ELEMENTDATA`。这样可以避免为空的 `ArrayList` 分配不必要的内存
 * */
private static final Object[] EMPTY_ELEMENTDATA = {};  
  
/**  
 * Shared empty array instance used for default sized empty instances. We 
 * distinguish this from EMPTY_ELEMENTDATA to know how much to inflate when 
 * first element is added. 
 * 这也是一个共享的空数组实例，但它用于表示使用默认初始容量的空 `ArrayList` 实例。
 * 
 * 当你创建一个空的 `ArrayList` 并且没有指定初始容量时，`elementData` 会被初始化
 * 为 `DEFAULTCAPACITY_EMPTY_ELEMENTDATA`。与 `EMPTY_ELEMENTDATA` 不同的是，当第一个元素被添加
 * 到 `ArrayList` 时，`DEFAULTCAPACITY_EMPTY_ELEMENTDATA` 会被扩展为 `DEFAULT_CAPACITY`（即 10）
 * 的大小。
 * */
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};  
  
/**  
 * The array buffer into which the elements of the ArrayList are stored. 
 * The capacity of the ArrayList is the length of this array buffer. Any 
 * empty ArrayList with elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA 
 * will be expanded to DEFAULT_CAPACITY when the first element is added. 
 * 
 * 这是 `ArrayList` 内部用于存储元素的数组缓冲区。`ArrayList` 的容量就是这个数组的长度。
 * 
 * 这个字段是非私有的（`non-private`），这是为了简化嵌套类的访问。
 * */
transient Object[] elementData; // non-private to simplify nested class access  
  
/**  
 * The size of the ArrayList (the number of elements it contains). 
 * 
 * `size` 表示 `ArrayList` 中当前有多少个元素，而不是 `elementData` 数组的容量。`size` 总是小于或等
 * 于 `elementData.length`  
 */  
private int size;
```

# 构造函数

1. 指定初始容量
```java
/**  
 * Constructs an empty list with the specified initial capacity. 
 * @param  initialCapacity  the initial capacity of the list  
 * @throws IllegalArgumentException if the specified initial capacity is negative 
 */
public ArrayList(int initialCapacity) {  
    if (initialCapacity > 0) {  
        this.elementData = new Object[initialCapacity];  
    } else if (initialCapacity == 0) {  
        this.elementData = EMPTY_ELEMENTDATA;  
    } else {  
        throw new IllegalArgumentException("Illegal Capacity: " + initialCapacity);  
    }  
}
```

2. 不指定初始容量（直接 new）
> 注意：直接 new 出来之后初始容量实际上是 0，只有第一次添加一个元素之后才会扩容到 10 (`DEFAULT_CAPACITY`)，下面再分析。
```java
/**  
 * Constructs an empty list with an initial capacity of ten. 
 * 
 * 当你创建一个空的 `ArrayList` 并且没有指定初始容量时，`elementData` 会被初始化
 * 为 `DEFAULTCAPACITY_EMPTY_ELEMENTDATA`。
 */
public ArrayList() {  
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;  
}
```

3. 传入一个集合
```java
/**  
 * Constructs a list containing the elements of the specified * collection, in the order
 * they are returned by the collection's * iterator.
 * @param c the collection whose elements are to be placed into this list  
 * @throws NullPointerException if the specified collection is null  
 */
 public ArrayList(Collection<? extends E> c) {  
    Object[] a = c.toArray();  
    if ((size = a.length) != 0) {  
        if (c.getClass() == ArrayList.class) {  
            elementData = a;  
        } else {  
            elementData = Arrays.copyOf(a, size, Object[].class);  
        }  
    } else {  
        // replace with empty array.  
        elementData = EMPTY_ELEMENTDATA;  
    }  
}
```

# 第1次添加元素

直接 new 出来的 ArrayList 会将 elementData 赋值为 DEFAULTCAPACITY_EMPTY_ELEMENTDATA（一个空数组）。
在`ensureCapacityInternal`和`calculateCapacity`中的`minCapacity`我理解为元素至少需要占用的空间。
而`ensureExplicitCapacity`和 `grow`中的`minCapacity`我理解为 Object 数组至少有多少空间。
他们只在添加 1～10 个元素时有差异。
![[Pasted image 20250308170124.png]]

# 第2～10 次添加元素
![[Pasted image 20250308172330.png]]

# 第 11 次添加元素
![[Pasted image 20250308172855.png]]