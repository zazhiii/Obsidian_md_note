
## #{}和${}的区别

#{} 是通过 ? 占位符然后再将参数传给 ? 占位符的方式，不会有SQL注入风险

${} 是直接拼接参数的方式，有SQL注入的风险

>${}的使用场景：按照某个字段排序
>`SELECT * FROM user ORDER BY ${orderCol}`

## 常见的标签

```xml
<select>
<insert>
<delete>
<update>

<resultMap>

<!-- 动态 SQL -->
<where>
<set>
<if>


```

## Mybatis的执行流程
1. 读取 Mybatis 的配置文件，mybatis-config.xml加载运行环境和映射文件
2. 构建会话工厂 SqlSessionFactory
3. 会话工厂创建 SqlSession 对象（包含执行 SQL 语句的所有方法，每次操作一次会话，有多个）
4. 操作数据库的接口，Executor 执行器（封装 JDBC 的方法，真正操作数据库接口），同时负责查询缓存的维护
5. Executor 接口的执行方法有一个 MappedStatement 类型的参数，封装了映射信息
6. 输入参数映射
8. 输出参数映射

## Mybatis是否支持延迟加载
支持，默认关闭

什么是延迟加载？
e.g. 用户1---n订单关系
在查询用户时，把用户关联的订单也查出来，此为立即加载
在查询用户时，暂时不把订单查询出来，当需要订单时，在执行查询订单的 SQL 查询订单，此为延迟加载

原理？
「动态代理」
使用 cglib 创建目标对象的代理对象，当调用目标方法时（e.g. `user.getOrderList()`)，代理对象中 `invoke()`方法发现`user.getOrderList() == null` 那么它会在去执行关联`Order`的 SQL 把`Order`查询出来并 set 给 `user` 对象，然后再执行`user.getOrderList()`，这样就实现了延迟加载。

## Mybatis一级、二级缓存

一级缓存：
基于 PerpetualCache 的 HashMap 本地缓存，作用域为 Session，当 Session 进行 flush 或者 close 之后，该 Session 中的缓存就会清空，默认打开一级缓存

二级缓存
基于 PerpetualCache 的 HashMap 本地缓存，作用域为 namespace 和 mapper

注意：
1. 缓存更新机制：某作用域下进行了增、删、改，那么该作用域下的缓存会被清空
2. 二级缓存的数据需要实现 Serializable 接口
3. 只有会话关闭或提交之后，一级缓存才会转移到二级缓存中

