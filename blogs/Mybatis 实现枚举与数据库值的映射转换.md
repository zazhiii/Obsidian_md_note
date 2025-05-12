
# 1. 场景

项目中通常用数字表示一个状态字段，例如一个订单 0 表示未完成，1 表示已完成，-1 表示超时。
在数据库中我们用这些数字来存储这些信息。但是如果在 Java 实体类中我们仍然用数字来维护这些信息的话会很不优雅，代码中可能会出现魔法数字。
```java
public class Student{
	private Integer age;
	private Integer gender;
}
```

这个时候就出现了「枚举」应用的场景。

我们把`gender`字段变成枚举类
定义枚举类：
```java
public enum GenderEnum {  
    MALE(1),  
    FEMALE(2),  
    WALMART_SHOPPING_BAG(-1);  
  
    private final Integer code;  
  
    GenderEnum(int code) {  
        this.code = code;  
    }  
}
```

改造实体类：
```java
public class Student{
	private Integer age;
	private GenderEnum gender;
}
```

这样我们在写 Java 代码时就能够优雅地处理这个字段了。关于如何使用枚举、使用枚举的好处就不在这里赘述了。

这个时候新的问题出现了，我在用 Mybatis 存储 `Student` 的时候如何将枚举映射转为数字存入数据库（`WALMART_SHOPPING_BAG --> -1`），查询的时候如何将数字转换为枚举（`-1 --> WALMART_SHOPPING_BAG`）。

# 2. 实现

Mybatis有两个自带的处理器，`EnumTypeHandler` 和 `EnumOrdinalTypeHandler`，他们分别能将枚举映射成字符串（`WALMART_SHOPPING_BAG --> "WALMART_SHOPPING_BAG"`）或者映射成在枚举中的序号值。但是在这里他们没有达到我们想要的自定义效果，我们要介绍的是实现自定义的处理器，映射成如何我们想要的值。

## 2.1 定义通用枚举接口

我们想要实现自动转换的枚举都继承这个接口。
```java
public interface BaseEnum<T> {  
    T getCode();  
}
```

改造枚举，这里实现了两个方法，下面会讲在哪里会用到。
```java
public enum GenderEnum implements BaseEnum<Integer> {  
    MALE(1),  
    FEMALE(2),  
    WALMART_SHOPPING_BAG(-1);  
  
    private final Integer code;  
  
    GenderEnum(int code) {  
        this.code = code;  
    }  
  
    @Override  
    public Integer getCode() {  
        return code;  
    }  
  
    public static GenderEnum fromCode(Integer code) {  
        for (GenderEnum gender : values()) {  
            if (gender.getCode().equals(code)) {  
                return gender;  
            }  
        }  
        throw new IllegalArgumentException("Unknown gender code: " + code);  
    }  
}
```
## 2.2 构建自定义处理器

```java
public class GenericEnumTypeHandler<E extends Enum<E> & BaseEnum<T>, T> extends BaseTypeHandler<E> {  

	// 保存当前处理的枚举类型的 `Class` 对象，用于反射调用。
    private final Class<E> type;  
  
    public GenericEnumTypeHandler(Class<E> type) {  
        if (type == null) throw new IllegalArgumentException("Type argument cannot be null");  
        this.type = type;  
    }  
  
    @Override  
    public void setNonNullParameter(PreparedStatement ps, int i, E parameter, JdbcType jdbcType) throws SQLException {  
        ps.setObject(i, parameter.getCode());  
    }  
  
    @Override  
    public E getNullableResult(ResultSet rs, String columnName) throws SQLException {  
        Object value = rs.getObject(columnName);  
        return valueOf((T) value);  
    }  
  
    @Override  
    public E getNullableResult(ResultSet rs, int columnIndex) throws SQLException {  
        Object value = rs.getObject(columnIndex);  
        return valueOf((T) value);  
    }  
  
    @Override  
    public E getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {  
        Object value = cs.getObject(columnIndex);  
        return valueOf((T) value);  
    }  
  
    private E valueOf(T value) {  
        if (value == null) {  
            return null;  
        }  
        try {  
            Method method = type.getMethod("fromCode", value.getClass());  
            return (E) method.invoke(null, value);  
        } catch (Exception e) {  
            throw new RuntimeException("Cannot convert value to enum: " + value, e);  
        }  
    }  
}
```

这个类 `GenericEnumTypeHandler` 是一个 **MyBatis 通用枚举类型处理器**，用于将数据库中的值和 Java 中实现了 `BaseEnum` 接口的枚举类型互相转换。它的作用是自动处理所有遵循 `BaseEnum` 接口的枚举，不需要为每个枚举都写一个单独的 `TypeHandler`。

- `E`：代表枚举类型。
- `T`：代表数据库中对应的值类型（如 `Integer`、`String` 等）。
- `E extends Enum<E> & BaseEnum<T>`：限定 `E` 既是一个 `Enum` 枚举类，又实现了你自定义的接口 `BaseEnum<T>`。
- `extends BaseTypeHandler<E>`：继承 MyBatis 的基础类型处理器，用于自定义类型映射逻辑。

第一个重载方法在数据写入数据库时调用，存入时通过枚举的`getCode()`获取到需要存入的值。
后三个重载方法在从数据库读取值时调用，查出时通过反射调用枚举类的`fromCode()`方法，获取对应的枚举类。

>注意：这个`fromCode()`方法一定要在枚举类里静态声明

## 2.3 注册处理器

方式1：一个一个手动注册
```java
@Component  
public class MyBatisEnumConfig2 {  
  
    @Bean  
    public ConfigurationCustomizer configurationCustomizer() {  
        return new ConfigurationCustomizer() {  
            @Override  
            public void customize(Configuration configuration) {  
                TypeHandlerRegistry registry = configuration.getTypeHandlerRegistry();  
  
                // 注册你所有的枚举类型  
                registry.register(GenderEnum.class, new GenericEnumTypeHandler<>(GenderEnum.class));  
  
                // 如果有其他枚举，也一样添加  
                // registry.register(Status.class, new GenericEnumTypeHandler<>(Status.class));  
            }  
        };  
    }  
}
```

方式2：通过反射获取所有 Enum 自动注册

```java
@Component  
public class MyBatisEnumConfig {  
    private static final String BASE_PACKAGE = "com.zazhi.mybatis_enum_mapping.enums";  
  
    @Bean  
    public ConfigurationCustomizer configurationCustomizer() {  
        return new ConfigurationCustomizer() {  
            @Override  
            public void customize(Configuration configuration) {  
                TypeHandlerRegistry registry = configuration.getTypeHandlerRegistry();  
  
                Set<Class<?>> enumClasses = scanBaseEnumEnums(BASE_PACKAGE);  
  
                for (Class<?> clazz : enumClasses) {  
                    // 泛型擦除，强转需要保证正确  
                    @SuppressWarnings("unchecked")  
                    Class<? extends Enum<?>> enumClass = (Class<? extends Enum<?>>) clazz;  
                    registry.register(enumClass, new GenericEnumTypeHandler(enumClass));  
                }  
            }  
        };  
    }  
  
    private Set<Class<?>> scanBaseEnumEnums(String basePackage) {  
        ClassPathScanningCandidateComponentProvider scanner =  
                new ClassPathScanningCandidateComponentProvider(false);  
        scanner.addIncludeFilter(new AssignableTypeFilter(BaseEnum.class));  
        scanner.setResourceLoader(new DefaultResourceLoader());  
  
        Set<BeanDefinition> candidates = scanner.findCandidateComponents(basePackage);  
        Set<Class<?>> result = new java.util.HashSet<>();  
  
        for (BeanDefinition candidate : candidates) {  
            try {  
                Class<?> clazz = Class.forName(candidate.getBeanClassName());  
                if (clazz.isEnum() && BaseEnum.class.isAssignableFrom(clazz)) {  
                    result.add(clazz);  
                }  
                System.out.println("Found enum class: " + clazz.getName());  
            } catch (ClassNotFoundException e) {  
                throw new RuntimeException("Failed to load enum class", e);  
            }  
        }  
  
        return result;  
    }  
}
```

个人更喜欢后者，一劳永逸

# 3. 测试

```java
@Mapper  
public interface StudentMapper {  
  
    @Insert("insert into student(age, gender) values(#{age}, #{gender})")  
    void insert(Student student);  
  
    @Select("select * from student")  
    Student getAll();  
}
```


```java
@SpringBootTest  
class MybatisEnumMappingApplicationTests {  
    @Autowired  
    StudentMapper studentMapper;  
    @Test  
    void insert() {  
       Student student = new Student();  
       student.setAge(18);  
       student.setGender(GenderEnum.WALMART_SHOPPING_BAG);  
       studentMapper.insert(student);  
    }  
    @Test  
    void select(){  
       Student student = studentMapper.getAll();  
       System.out.println(student);  
       System.out.println(student.getGender());  
    }  
}
```

