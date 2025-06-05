# 概念
## Java 的特点

1. 简单易学
2. 面向对象（封装、继承、多态）
3. 跨平台（ JVM 实现）
4. 支持多线程
5. 可靠性（异常处理机制、自动内存管理机制）
6. ……

Java SE、Java EE

## JVM和JDK和JRE

JVM：Java 虚拟机

JVM$\in$JRE$\in$JDK
![[JVM 与 JRE 与 JDK 的关系.png]]

## 什么是字节码？## 使用字节码的好处？
JVM 可以理解的代码（.class文件）

增加可以移植性，编译之后可以随处运行

## 为什么说编译与解释并存？

编译：Java 代码编译为字节码
解释：字节码由解释器解释运行

# 基本数据类型

## 基本类型和包装类型的区别

1. 存储方式：基本类型若为**局部变量**，则存放在栈内存中。若为成员变量则存放在堆内存中；而包装类型为对象，对象存放在堆内存中。
2. 占用空间：包装类型占用大，基本类型占用小。
3. 默认值：包装类型不赋值为`null`，基本类型都有默认值
4. 比较方式：包装类型用`equals()`，基本类型用`==`

## 八种基本类型
```java
byte 1bit 
short 2bit
int 4bit
long 8bit
double 8bit
float 4bit
char 2bit
boolean 通常1bit
```
## 包装内存的缓存机制

提前创建好一些对象：
- $-128\sim 127$的`Byte, Short, Integer, Long`对象 
- $0\sim 127$的`Character`对象
- `TRUE, FALSE`的`Boolean`对象
>如果我们想要创建这些范围内的对象时，他会直接返回已经创建好的对象。而不是创建新的对象。
>例如：
>`Integer x = 40;` 他并不会创建新对象，而是让 x 指向已经创建好的缓存对象
>`Integer x = new Integer(40);` 这样会创建新对象。

## 什么是自动装箱与拆箱？原理？

装箱：基本类型转引用类型
拆箱：引用类型转基本类型

原理：
编译之后，在字节码中通过`valueOf()`实现装箱，通过`xxxValue()`实现拆箱。
>`Integer x = 10;` --> `Integer x = Integer.valueOf(10);`
>`int y = x;` -->  `int y = x.intValue();`

## 为什么浮点数会精度丢失？
无限循环小数在存放时只能被截断

## 如何解决浮点数计算精度问题？

使用`BigDecimal`

## 如何表示超过 long 的数据

使用`BigInteger`

# 变量

## 成员变量和局部变量区别？
1. 成员变量在堆内存，局部变量在栈内存
2. 成员变量有默认值，局部变量没有默认值

# 方法

## 重载与重写

重写：子类对父类允许访问的方法的重新编写
>- `private/final/static`修饰的方法不能被重写
>- 构造方法不能被重写

重载：同一个类中，方法名相同传参不同

# 面相对象

## 面向对象三大特性
封装
>合理隐藏属性，不允许直接访问，对外提供操作方法

继承
>通过已有的类作为基础，创建新的类

多态
>一个对象有具有多种状态

## 接口与抽象类的共同点与区别 
共同点：
1. 不能直接实例化
2. 都可以包含抽象方法

区别：
1. 设计目的：接口目的是**定义一种规范**；抽象类是为了**代码复用**
2. 只能继承**一个**抽象类；可以实现**多个**接口；
3. Java 8 之前，接口只能有抽象方法（`public abstract`）。Java 8 可定义`default`，`static`方法。Java 9 可定义`private`方法；抽象类中可以有抽象方法和非抽象方法。

>Java 8 引入`default`方法：给出一个方法的默认实现，实现类也可重写。目的是在接口中添加新方法时不需要修改接口的实现类。如果定义抽象方法，所有实现类需要去实现新的抽象方法。
>
>Java 8 引入`static`方法，与`default`不同的是该方法不能被重写。
>
```java
public interface MyInterface {
    default void defaultMethod() {
        System.out.println("This is a default method.");
    }
    static void staticMethod() { 
	    System.out.println("This is a static method in the interface."); 
    }
}
```

>Java 9引入`private`方法，这个方法不能被实现了访问。只是为了抽取接口中的代码。

## 深拷贝、浅拷贝、引用拷贝 

浅拷贝：
创建一个新对象，但新对象与原对象共用内部对象

深拷贝：
完全创建新对象，包括对象内部的引用。

引用拷贝：
不会创建新对象，两个不同的引用指向一个对象

# `Object`

## Object常见的方法
1. `getClass()`
2. `hashCode()`
3. `eqauls(Object obj)`
4. `clone()`
5. `toString()`
6. `wait()` 三个重载方法
7. `notify() notifyAll()`
8. `finalize()` 垃圾回收时的操作

##  ==  和 `equals()`
`==` :
1. 基本类型：比较值
2. 引用类型：比较地址

`equals()`
1. 没有重写`eqauls()`：等价 `==`
2. 重写了`eqauls()`：按照重写了的逻辑来比较
>比如 String 就重写了该方法，调用时比较的是字符串是否相同


## `hashCode()`有什么用
返回对象的**哈希码**

## 为什么要有hashCode？
通过 hashCode 能够快速比较两个对象是否相同。


## 为什么重写`equals()`必须重写`hashCode()`
对象相同 hashCode 必须相同，hashCode 相同对象不一定相同。

若重写了`equals()`方法，但是不重写`hashCode()`方法，可能会出现对象相等但 hashCode 不相等的情况。


# `String`
## `String`可以被继承吗？
不能；被`final`修饰了。

## `String, StringBuilder, StringBuffer`
1. String 不可变；StringBuilder 和 StringBuffer 可变。
2. String、StringBuffer 线程安全；StringBuilder 线程不安全。

## 字符串常量池
避免重复创建字符串开辟的一块区域。

# 异常
1. `Checked Exception & Unchecked Exception`

# 泛型

1. 泛型的作用

# 反射
1. 什么是反射？
2. 反射优缺点？
3. 反射的应用？

反射：可以在运行时分析类执行类中方法。通过反射可以获取到一个类的属性和方法，并可以调用这些属性和方法
反射的应用场景？动态代理

# Java值传递机制
1. Java中只有值传递
2. 基本类型拷贝值，引用类型拷贝引用对象的地址

# 序列化
1. 序列化是什么？
2. 反序列化是什么？
3. 如何实现 JDK 自带序列化？
4. 不想序列化某个字段？
5. 为什么不推荐使用 JDK 自带序列化？（3点）