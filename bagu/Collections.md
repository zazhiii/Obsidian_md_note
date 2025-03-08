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
  