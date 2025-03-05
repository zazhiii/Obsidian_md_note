核心功能主要是 IoC 和 AOP 

# 1. Spring IoC

Inversion of Control 控制反转：将原本在程序中手动创建对象的控制权，交由 Spring 框架来管理

Bean 代指的就是那些被 IoC 容器所管理的对象。

## 1.1 Bean是线程安全的吗？
与「作用域」和「有无状态」有关。

`singleton` 无状态（没有定义可变成员变量，纯逻辑）是线程安全，**有状态是线程不安全**。
`prototype` 每次获取都会创建新的 Bean 不会资源竞争，所以是**线程安全**。

单例 Bean 线程安全问题的三种解决方法：
1. 避免可变成员变量，将 Bean 设计为无状态。
2. 使用`ThreadLocal` 传递可变成员变量。
3. 使用线程同步机制
---

将一个类声明为 Bean 的注解有哪些?
- `@Component`：通用的注解，可标注任意类为 `Spring` 组件。
- `@Repository` : 用于标识数据访问层（Dao 层）的类
- `@Service` : 对应服务层
- `@Controller` : 对应 Spring MVC 控制层
后三者只是在第一个注解的基础上起了三个新名字，作用一致。

`@Component` 和 `@Bean` 的区别？
- `@Component`：作用于类。通常通过类路径扫描侦测并装配到 `spring` 容器中。与之相关的`@ComponentScan` 定义扫描路径。
- `@Bean`：作用于方法。该方法会返回一个对象将其变成Bean。通常用于第三方类

注入 Bean 的注解？
- `@Autowired` Spring内置，优先使用「类型」去匹配 Bean 注入。
- `@Resource` JDK提供，默认使用「名称」去匹配 Bean 注入。
- `@Inject` 

DI的方式？
- 构造函数注入
- Setter方法注入
- 字段注入

选择那种注入方式？
- 官方推荐「构造函数注入」

Bean的作用域？
Bean的作用域：用于确定哪种类型的bean实例应该从Spring容器中返回给调用者
- `singleton`：单例模式。  
- `prototype`：原型模式。  
- `request`：每次请求创建一个实例。  
- `session`：每次会话创建一个实例。  
- `global session`：全局会话创建一个实例。



## Bean 的生命周期？

`BeanDefinition` Spring 容器在进行实例化时，会将 xml 中配置的 bean 标签 信息封装为一个`BeanDefinition`（通过注解的方式也类似），Spring 工具它来创建 Bean 对象，里面有描述 Bean 属性的信息。
- beanClassName：bean 的类名
- initMethodName：初始化方法的名称
- propertyValues：bean 的属性值
- scope：作用域
- lazyInit：延迟初始化

1. 通过 BeanDefinition 获取 bean 的定义信息
2. 调用构造函数实例化 bean
3. bean 的依赖注入（`@Autowired`、`@Resource`、构造函数、setter注入的对象，`@Value`注入的值）
4. 若 bean 实现了 Aware 接口，会调用对应实现的方法（`BeanNameAware`、`BeanFactoryAware`、……）
> 实现这些 Aware 接口能让 bean 获取到 Spring 容器的资源
> `BeanNameAware`：实现他的 `setBeanName()`，可以获取 bean 的名字
> `BeanFactoryAware`：实现他的`setBeanFactory`，可以获取 BeanFactory 的引用
5. 执行`postProcessBeforeInitialization()` 方法(`BeanPostProcesser`对象中)
6. 执行`afterPropertiesSet()`方法(实现`InitializingBean`接口)，执行`init-method`(自定义初始化方法)
7. 执行`postProcessAfterInitialization()` 方法(`BeanPostProcesser`对象中)
8. 销毁 Bean


5. 创建 Bean 实例：通过反射创建
6. Bean 属性赋值
7. Bean 初始化
8. 销毁 Bean 

## 循环依赖

循环依赖：Bean 对象循环引用，两个或多个对象互相持有对方的引用

Spring 允许循环依赖存在，用「三级缓存」解决大部分循环依赖
1. 一级缓存：单例池，缓存最终形态的 bean （已实例化、已属性填充、初始化）
2. 二级缓存：缓存早期 bean 对象（半成品、未填充属性）
3. 三级缓存：缓存 ObjectFactory，对象工厂，用来创建某个对象。

创建 bean 的流程
1. 先从「一级缓存」获取，存在则返回
2. 没获取到再从「二级缓存」中获取
3. 还没获取到再从「三级缓存」中获取对应 BeanFactory 创建对应 bean 对象并放入二级缓存中，删除三级缓存的该 BeanFactoy 

Spring 解决不了的循环依赖
三级缓存只能解决初始化的时候的循环依赖，构造方法注入产生的循环依赖
```java
@Component
public class A{
	private B b;
	public A(B b){
		this.b = b;
	}
}

@Component
public class B{
	private A a;
	public B(A a){
		this.a = a;
	}
}
```

通过 `@Lazy` 延迟加载，需要 bean 的时候再去创建
```java
public A(@Lazy B b){
	this.b = b;
}
```
# 2. AOP

AOP：面向切面编程，将与业务逻辑无关的重复性代码抽取出来封装成一个可重用模块，降低模块耦合

使用场景：
1. 记录日志
2. Spring 中内置的事务
3. 缓存处理
4. 权限控制

Spring 中的事务如何实现的？
本质是通过 AOP 实现，对执行方法前后进行拦截，在执行方法前开启事务，执行方法后提交事务 或 回滚事务

AOP 是通过动态代理实现的。若被代理对象实现了某个借口，AOP 会使用 JDK proxy 生成代理对象，代理对象同样实现了该接口（被代理对象和代理对象是“兄弟”关系）；若被代理对象没有实现某个接口，AOP 会使用 Cglib proxy 去创建代理对象，代理对象会继承被代理对象（被代理对象和代理对象是“父子”关系）。

Spring AOP 和 AspectJ AOP 的区别？
前者是运行时增强，后者是编译时增强。

AOP的常见通知类型
1. `Before` 方法前
2. `After` 方法后
3. `AfterReturning` 返回结果之后
4. `AfterThrowing` 触发异常之后
5. `Around` 环绕通知，可以在切入点整个方法执行的时候获取目标对象信息。

多个切面的顺序如何控制？
1. `@Order(n)` 注解，n 代表优先级，越小越高
2. 实现 `Ordered` ，重写`getOrder()`方法，它的返回值即为优先级


# 3. Spring 事务失效的场景

1. 异常捕获处理
若在事务中捕获异常并处理掉，事务通知无法知道，也就不会回滚事务。
解决办法：捕获异常之后将它抛出

2. 抛出检查异常
Spring 只会回滚非检查异常(`RuntimeException)`，若抛出检查异常（如`FileNotFoundException`) 就不会回滚
解决办法：通过设置 `Transactional(rollbackFor=Exception)`

3. 非 public 方法导致事务失效哦
Spring 为方法创建代理、添加事务通知，前提是该方法是 public 方法
解决办法：将方法改为 public 





