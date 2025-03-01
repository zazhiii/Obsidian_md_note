核心功能主要是 IoC 和 AOP 

# 1. Bean是线程安全的吗？
与「作用域」和「有无状态」有关。

`singleton` 无状态（没有定义可变成员变量，纯逻辑）是线程安全，**有状态是线程不安全**。
`prototype` 每次获取都会创建新的 Bean 不会资源竞争，所以是**线程安全**。

单例 Bean 线程安全问题的三种解决方法：
1. 避免可变成员变量，将 Bean 设计为无状态。
2. 使用`ThreadLocal` 传递可变成员变量。
3. 使用线程同步机制

# Spring IoC
Inversion of Control 控制反转：将原本在程序中手动创建对象的控制权，交由 Spring 框架来管理

Bean 代指的就是那些被 IoC 容器所管理的对象。

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



Bean 的生命周期？
1. 创建 Bean 实例：通过反射创建
2. Bean 属性赋值
3. Bean 初始化
4. 销毁 Bean 