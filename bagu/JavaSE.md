# 概念
## Java 的特点

1. **面向对象**（封装、继承、多态）
2. **跨平台**（ JVM 实现）
3. **内存管理**（垃圾回收机制）


## Java的缺点
1. 启动时间慢
2. 内存占用高

## JVM和JDK和JRE

JVM：Java 虚拟机

JVM$\in$JRE$\in$JDK
![[JVM 与 JRE 与 JDK 的关系.png]]

## 什么是字节码？## 使用字节码的好处？
JVM 可以理解的代码（.class文件）

增加可以移植性，编译之后可以随处运行

## 为什么说编译与解释并存？

编译：
1. Java 代码编译为字节码
2. JIT将热点字节码编译为机器码
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
1. 封装
合理隐藏属性，不允许直接访问，对外提供操作方法 

2. 继承
通过已有的类作为基础，创建新的类

3. 多态
同一个行为具有不同的表现形式
同一个方法的调用，由于对象不同，表现出不同的行为

## 接口与抽象类的共同点与区别 

共同点：
1. 不能直接实例化
2. 都可以包含抽象方法

区别：
1. 设计目的：接口目的是**定义一种规范**；抽象类是为了**代码复用**
2. 只能继承**一个**抽象类；可以实现**多个**接口；
3. Java 8 之前，接口只能有抽象方法（`public abstract`）。Java 8 可定义`default`，`static`方法。Java 9 可定义`private`方法；抽象类中可以有抽象方法和非抽象方法。
4. 变量：接口只能包含常量；抽象类可以包含实例变量和常量

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

## final 关键字
1. 修饰类：类不能被继承
2. 修饰方法：方法不能被重写
3. 修饰变量：变量的值不能改变
>变量指向基本类型：不能修改这个变量的值
>变量指向引用类型：不能修改变量指向其他类型，但这个引用类型的内部是可以改变的

## 深拷贝、浅拷贝、引用拷贝 

浅拷贝：
创建一个新对象，但新对象与原对象共用内部对象

深拷贝：
完全创建新对象，包括对象内部的引用。

引用拷贝：
不会创建新对象，两个不同的引用指向一个对象

# 实现深拷贝的三种方法

1. 实现`Cloneable`并重写`clone()`
要求对象和引用类型对象做这一步，在`clone`方法中递归克隆

2. 序列化和反序列化
要求对象和引用字段都实现`Serializable`，将对象序列化为字节流，再反序列化为对象。

3. 手动递归克隆
对象复杂度不高的情况

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

## `Exception`和`Error`的区别？

`Exception`：程序本身可以处理，可以用`catch`捕获

`Error`：程序无法处理的错误，一般会导致程序停止

## `Checked Exception & Unchecked Exception`

`Checked Exception`：受检查异常，不`catch`或`throws`的话，不能编译通过。

`Unchecked Exception`：不收检查异常，不处理也能编译通过。
>`RuntimeException`及其子类都属于这类异常

## `finally`中的代码一定会执行吗？

不一定

1. 虚拟机关闭
2. 线程死亡
3. CPU关闭

都会导致不去执行`finally`中的代码

# 泛型

## 什么是泛型

允许类、接口、方法中使用类型参数（“类型参数化”，即把类型作为参数传递给类、接口、方法）

## 泛型的作用

1. 增强类型安全：编译器可以通过泛型指定传入对象的类型，传不符合泛型的类型就会报错。

2. 减少强转：例如通过泛型实现`List`中取值的自动转换（`List`默认是返回`Object`类型）

3. 提高代码重用性：允许编写通用代码来处理多种类型，例如处理`Integer`、`Double`等数字的运算

## 泛型的使用方法？

1. 泛型类
```java
public class Box<T> {
    // ...
}
```

2. 泛型接口
```java
public interface Comparable<T> {
    int compareTo(T o);
}

```

3. 泛型方法
```java
    public static <T> void printArray(T[] array) {
        for (T item : array) {
            System.out.println(item);
        }
    }
```

## 泛型擦拭

泛型擦拭：泛型只在编译期间存在，运行时不会保留泛型的类型

## 泛型应用的场景？

1. 自定义接口统一返回结果：`Result<T>`


# 反射
## 什么是反射？

反射：可以在**运行时**分析类、执行类中方法。通过反射可以获取一个类的属性和方法，并可以调用

## 反射优缺点？

优点：灵活，便利

缺点：
1. 安全问题：例如绕过泛型检查（泛型检查在编译时期）
2. 性能问题：性能稍差

## 反射的应用？

1. 动态代理
2. Spring扫描创建Bean

# Java值传递机制
1. Java中只有值传递
2. 基本类型拷贝值，引用类型拷贝引用对象的地址

# 序列化
## 序列化和反序列化是什么？

序列化：将数据结构或对象转换成可以存储或传输的形式，通常是二进制字节流，也可以是JSON，XML等文本格式

反序列化：将序列化生成的数据转换为数据结构或对象

## 如何防止序列化某个字段？

1. 使用`transient`修饰字段
2. 使用`static`修饰
>`static`变量不属于如何对象

## 为什么不推荐使用 JDK 自带序列化？（3点）

1. 不支持跨语言调用
2. 性能差
3. 有安全问题