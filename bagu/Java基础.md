# Java 的特点

1. 简单易学
2. 面向对象（封装、继承、多态）
3. 跨平台（ JVM 实现）
4. 支持多线程
5. 可靠性（异常处理机制、自动内存管理机制）
6. ……

Java SE、Java EE

JVM、JDK、JRE

# 什么是字节码？
JVM 可以理解的代码（.class文件）

使用字节码的好处？


# 基本数据类型
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

提前创建好
- $-128\sim 127$的`Byte, Short, Integer, Long`对象 
- $0\sim 127$的`Character`对象

## 什么是自动装箱与拆箱？原理？

装箱：基本类型转引用类型
拆箱：引用类型转基本类型

原理：
编译之后，在字节码中通过`valueOf()`实现装箱，通过`xxxValue()`实现拆箱。

# 方法
1. 重写与重载


# 面相对象

1. 三大特性
2. 接口与抽象类的区别 
3. 深拷贝、浅拷贝

# `Object`
1. ==  和 `equals()`
2. `hashCode()`有什么用
3. 为什么重写`equals()`必须重写`hashCode()`

# `String`
1. `String, StringBuilder, StringBuffer`
2. 


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