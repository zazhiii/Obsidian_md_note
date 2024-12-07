


## 大致原理
ibatis：
XxxMapper.xml(sql语句) -> mybatis-config.xml(数据库配置、XxxMapper的读取) 
通过mybatis-config.xml，能获取到一个SqlSessionFactory，再通过他获得SqlSession
SqlSession自带CRUD方法，需要传入 id(用于标识XxxMapper.xml中的sql语句，对应标签中namespace.id或id)， Object(查询参数)两个参数，实现数据库操作。
这样有一些缺点：
1. 传入的id为字符串，容易写错
2. 只能传入一个查询参数，如果有多个查询参数，还需要封装成一个对象
3. 返回值不太明确，需要开发者自己判断

mybatis：
以相同步骤获取SqlSession，再通过他能获得XxxMapper接口的动态代理对象，通过调用动态代理对象的方法，间接调用SqlSession方法并执行对应sql

mybatis是对ibatis的封装优化

大致逻辑就是找到XxxMapper.xml中的sql并执行，前者通过SqlSession调用方法中传参id查找，而后者将动态代理对象的方法和对应的sql映射了起来，通过调用对象方法来执行对应的sql，减小出错概率。

---

Mapper接口的方法不能重载

---
#{ key }: 占位符 + 赋值
${ key }: 字符串拼接
推荐使用前者，可以防止注入攻击。
前者只能代替参数值的位置，不能代替关键字、列名、表名，而后者可以实现关键字动态。
一个后者的应用场景：
```java
@Select("select * from user where ${column} = #{value}")
User findByColumn(@Param("column") String column,  @Param("value") String value);
```