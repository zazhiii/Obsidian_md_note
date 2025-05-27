核心功能主要是 IoC 和 AOP 

# Spring IoC

## 什么是IoC？

Inversion of Control 控制反转：将原本在程序中手动创建对象的控制权，交由 Spring 框架来管理

## IoC解决什么问题？

1. 对象之间的耦合和依赖降低
2. 资源更加易于管理（比如：很容易实现单例）

## 什么是Spring Bean

Bean 代指的就是那些被 IoC 容器所管理的对象。

## 将类声明为 Bean 的注解？

`@Component`
`@Controller`
`@Service`
`@Respository`
`@Configuration`
`@Mapper`

## `@Component`和`@Bean`的区别？

1. `@Component`作用于类，`@Bean`作用于方法。
2. 前者通过路径扫描创建 Bean，后者通过方法产生 Bean。
>通常第三方类我们需要通过 `@Bean`来将其声明为 Bean，因为无法在这些类上加`@Component`

## 注入Bean的注解

1. `@Autowired`
2. `@Resource`
3. `@Inject`

## `@Autowired`和`@Resource`的区别？

1. `@Autowired`是 Spring 提供的注解，`@Resource`是 JDK 提供的注解
2. `@Autowired`优先通过**类型**注入，再通过名字注入
3. `@Resource`优先通过**名称**注入，再通过类型注入
>`@Autowired`通过`@Qualifier`指定名字
>`@Resource`通过name属性指定名字

## Bean的注入方式

1. 构造函数注入
2. Setter方法注入
3. 字段注入

## Bean 的作用域

Bean的作用域：用于确定哪种类型的bean实例应该从Spring容器中返回给调用者

1. singleton
2. prototype
3. ……

## Bean是线程安全的吗？
与「作用域」和「有无状态」有关。

`singleton` 无状态（没有定义可变成员变量，纯逻辑）是线程安全，**有状态是线程不安全**。
`prototype` 每次获取都会创建新的 Bean 不会资源竞争，所以是**线程安全**。

单例 Bean 线程安全问题的三种解决方法：
1. 避免可变成员变量，将 Bean 设计为无状态。
2. 使用`ThreadLocal` 传递可变成员变量。
3. 使用线程同步机制

## Bean 的生命周期？

>概括：
>1. 创建 bean
>2. 属性赋值
>3. 初始化
>4. 销毁

`BeanDefinition` Spring 容器在进行实例化时，会将 xml 中配置的 bean 标签 信息封装为一个`BeanDefinition`（通过注解的方式也类似），Spring 工具它来创建 Bean 对象，里面有描述 Bean 属性的信息。
- beanClassName：bean 的类名
- initMethodName：初始化方法的名称
- propertyValues：bean 的属性值
- scope：作用域
- lazyInit：延迟初始化

1. **创建 Bean**：通过 BeanDefinition 获取 bean 的定义信息，通过反射调用构造函数实例化 bean
2. bean 的**依赖注入/属性填充**（`@Autowired`、`@Resource`、构造函数、setter注入的对象，`@Value`注入的值）
3. 若 bean 实现了 Aware 接口，会调用对应实现的方法（`BeanNameAware`、`BeanFactoryAware`、……）
> 实现这些 Aware 接口能让 bean 获取到 Spring 容器的资源
> `BeanNameAware`：实现他的 `setBeanName()`，可以获取 bean 的名字
> `BeanFactoryAware`：实现他的`setBeanFactory`，可以获取 BeanFactory 的引用
4. 执行`postProcessBeforeInitialization()` 方法(`BeanPostProcesser`对象中)
5. 执行`afterPropertiesSet()`方法(实现`InitializingBean`接口)，执行`init-method`(自定义初始化方法)
6. 执行`postProcessAfterInitialization()` 方法(`BeanPostProcesser`对象中)
7. 销毁 Bean

## 循环依赖和三级缓存

循环依赖：Bean 对象循环引用，两个或多个对象互相持有对方的引用

Spring 允许循环依赖存在，用「三级缓存」解决大部分循环依赖
1. 一级缓存：单例池，缓存**最终形态的 bean** （已实例化、已属性填充、初始化）
2. 二级缓存：缓存**早期 bean 对象**（半成品、未填充属性）
3. 三级缓存：缓存 ObjectFactory**对象工厂**，用来创建"原始Bean对象"或"代理对象"。

>一级缓存并不能解决循环依赖
>一级缓存 + 二级缓存才能解决循环依赖。
>
>为什么需要三级缓存？
>
>一、二级缓存只能解决普通对象的循环依赖
>
>在真正创建A时会先创建他的工厂对象放入三级缓存，若循环依赖需要A，则通过三级缓存中的工厂对象生产**A原始对象**或者**A的代理对象**放入二级缓存中。
>
>若只有二级缓存，只能在二级缓存中拿到A原始对象，而没有代理对象。

创建 bean 的流程
1. 先从「一级缓存」获取，存在则返回
2. 没获取到再从「二级缓存」中获取
3. 还没获取到再从「三级缓存」中获取对应 BeanFactory 创建对应 bean 原始对象或代理对象并放入二级缓存中，删除三级缓存的该 BeanFactoy 

流程：
发生循环依赖时，去三级缓存拿到工厂对象生成Bean的原始对象，先注入这个原始对象。将原始对象放入二级缓存中，再删除工厂对象。

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

# Spring MVC
## Spring MVC 的执行流程
![[Pasted image 20250305223926.png]]
1. 浏览器发送请求，`DispatcherServlet` 拦截请求
2. 调用`HandlerMapping`根据URL匹配handler，将相关的拦截器一起封转返回
3. 调用`HandlerAdapter`执行handler，返回ModelView给`DispatcherServlet`
4. 调用`ViewResolver` 将逻辑视图解析为真正视图
5. 将View返回给浏览器

![[Pasted image 20250305224027.png]]
1. 浏览器发送请求，`DispatcherServlet` 拦截请求
2. 调用`HandlerMapping`根据URL匹配handler，将相关的拦截器一起封转返回
3. 调用`HandlerAdapter`执行handler，将数据转为JSON并响应

## 全局异常处理如何做？

使用`@ControllerAdvice` + `@ExceptionHandler(Exception.class)`

前者加在类上，后者加在方法上

# Spring AOP

## 对AOP的理解？

AOP：面向切面编程，将与业务逻辑无关的重复性代码抽取出来封装成一个可重用模块，降低模块耦合

使用场景：
1. 记录日志
2. Spring 中内置的事务
3. 缓存处理
4. 权限控制

AOP 是通过**动态代理**实现的。
- 若被代理对象实现了某个接口，AOP 会使用 **JDK proxy** 生成代理对象，代理对象同样实现了该接口（被代理对象和代理对象是“兄弟”关系）；
- 若被代理对象没有实现某个接口，AOP 会使用 **Cglib proxy** 去创建代理对象，代理对象会继承被代理对象（被代理对象和代理对象是“父子”关系）。

## Spring 中的事务如何实现的？

本质是通过 **AOP** 实现
- 对执行方法前后进行拦截
- 在执行方法前开启事务
- 执行方法后提交事务 或 回滚事务



## Spring AOP 和 AspectJ AOP 的区别？

 Spring AOP是运行时增强，AspectJ AOP是编译时增强。

>如何选择？
>简单场景： Spring AOP
>复杂和高性能场景：AspectJ

## AOP的常见通知类型
1. `Before` 方法前
2. `After` 方法后
3. `AfterReturning` 返回结果之后
4. `AfterThrowing` 触发异常之后
5. `Around` 环绕通知，可以在切入点整个方法执行的时候获取目标对象信息。

多个切面的顺序如何控制？
1. `@Order(n)` 注解，n 代表优先级，越小越高
2. 实现 `Ordered` 接口，重写`getOrder()`方法，它的返回值即为优先级


# Spring 事务

## 声明式事务

`@Transactional`注解

## Spring 事务失效的场景

1. 异常捕获处理
若在事务中捕获异常并处理掉，事务通知无法知道，也就不会回滚事务。
解决办法：捕获异常之后将它抛出

2. 抛出检查异常
Spring 只会回滚非检查异常(`RuntimeException)`，若抛出检查异常（如`FileNotFoundException`) 就不会回滚
解决办法：通过设置 `Transactional(rollbackFor=Exception)`

3. 非 public 方法导致事务失效哦
Spring 为方法创建代理、添加事务通知，前提是该方法是 public 方法
解决办法：将方法改为 public 




# SpringBoot 自动装配原理

1. 在 SpringBoot 引导类上有一个注解`@SpringBootApplication`，这是三个注解的组合
	- `@SpringBootConfiguration`：和`@Configuration`类似，声明是配置类
	- `@ComponentScan`：组件扫描
	- `@EnableAutoConfiguration`：自动化配置核心注解

2. 其中`@EnableAutoConfiguration`是自动配置的核心注解，它通过`@Import`导入**配置选择器**`AutoConfigurationImportSelector`类。选择器读取该项目和引用 jar 包的 class path 下 META-INF/spring.factories文件所配置类的全类名。再这些配置类中所定义的 bean 会根据「条件注解」指定的条件来决定是否要将其加入 Spring 容器中

3. 条件注解例如`@ConditinalOnClass`，判断是否有对应的 class 文件（是否在 pom 文件中引入依赖），有则加载该类，将该配置类的 Bean 加入容器



## Spring常见注解

Spring
- @Component、@Controller、@Service、@Repository
- @Configuration
- ComponentScan
- @Autowired
- @Qualifier
- @Scope
- @Bean
- @Import
- @Aspect、@Before、@After、@Around、@Pointcut

SpringMVC
- @RequestMapping
- @RequestBody
- @RequestParam
- @PathViriable
- @ResponseBody
- @RequestHeader
- @RestController：@Controller + @ResponseBody

SpringBoot
@SpringBootApplication = 
- @SpringBootConfiguration
- @EnableAutoConfiguration
- @ComponentScan

