
**元数据接口** 可以直接作为 Java Bean 使用，具有属性等特性。

**简单属性示例：**

```java
public void referenceDocument(Citation citation) {
    System.out.println(citation.getTitle());
    System.out.println(citation.getTitle().toString(Locale.FRENCH));
}
```

**集合属性示例：**

```java
System.out.println(citation.getIdentifiers());
System.out.println(citation.getAlternateTitles());
```

以这种方式使用元数据接口非常直观和简单。

#### **预定义元数据**

GeoTools 库提供了一些常见的预定义常量，例如 **Citation** 相关的组织，包括但不限于：
- **EPSG**
- **OGC**
- **Oracle**

这些组织都发布了相关文档或规范，你可以在描述自己的信息时引用它们。

**Citations 类** 提供了这些预定义常量，便于直接复用：

```java
referenceDocument(Citations.EPSG);
referenceDocument(Citations.OGC);
referenceDocument(Citations.ORACLE);
```

然而，这些常量是**不可变的**，无法修改。

#### **自定义元数据**

目前，元数据包**不提供工厂类**，因此需要直接使用实现类进行操作。
**创建元数据非常简单：**

```java
CitationImpl citation = new CitationImpl();
```

没有意外，它有一个**无参数构造函数**，就像普通的 Java Bean 一样。此外，还有一些**带参数的构造函数**，但它们只是提供了便捷方式。

**使用 setter 方法设置属性：**

```java
citation.setEditionDate(new Date()); // 设置为今天
```

有时候，需要查阅 Javadoc 以了解具体的参数要求：

```java
Collection<ResponsiblePartyImpl> parties = Collections.singleton(ResponsiblePartyImpl.GEOTOOLS);
citation.setCitedResponsibleParties(parties);
```

上面的代码会**直接替换**“cited responsible parties”属性的整个集合。如果希望**在不丢弃已有数据的情况下添加新的responsible party，可以使用以下方式：

```java
citation.getCitedResponsibleParties().add(ResponsiblePartyImpl.GEOTOOLS);
```

#### **冻结（Freeze）**

在使用 setter 方法设置元数据类后，默认情况下对象**不是线程安全的**。常见的线程安全策略有三种：
1. **不做处理**：在 Javadoc 说明中要求开发者只在单个线程中修改对象。
2. **同步（Synchronize）**：保证安全，但在多线程读取时性能较低。
3. **不可变（Immutable）**：对象在创建时配置，之后只能读取，线程安全但设置较麻烦。

考虑到这些方法的限制，GeoTools 提供了一种**折中方案**：

✅ **冻结（Freeze）**：在单个线程中完成对象设置后，将其**冻结**为只读模式。

**冻结对象的示例：**

```java
Citation f = (Citation) c.unmodifiable();
```

**注意**：原始对象 `c` **仍然可修改**，但 `f` 变成了**不可变对象**。
GeoTools 采用冻结机制，因为 OpenGIS 接口**默认不支持可变性**，很多代码都假定这些对象一旦创建就不会更改。因此，**冻结比单纯依赖开发者自觉遵守更可靠**。****

#### **元数据 WKT**

WKT 实际上是 **“Well Known Text”**（熟知文本），不要担心，第一次接触时没有人会完全理解它。

并非所有的元数据 Bean 都有 WKT 表示，通常用于定义 **CoordinateReferenceSystem** 的元数据 Bean 会有很好的表现：

```java
CoordinateReferenceSystem crs = DefaultGeographicCRS.WGS84;
System.out.println(crs.toWKT());
```

可能看起来有些复杂，实际上，**CoordinateReferenceSystem** 就是元数据——在这种情况下，它定义了我们在 GIS 系统中处理的所有坐标的意义。

#### **元数据 ISO 19115**  
元数据通常以 **ISO 19115** 标准为基础存储为 XML 文件。目前，GeoTools 并没有为这些文档提供解析器。

如果你有兴趣参与或资助这项工作，请通过开发邮件列表与我们联系。

#### **元数据数据库**  
元数据模块提供了支持与存储在数据库中的元数据条目进行交互的功能。

任何 JDBC 数据库都可以使用，详细的配置可以在 Javadoc 中找到。

再次提醒，具体的使用方式请查阅 Javadoc：

```java
Connection connection = ...;
MetadataSource source = new MetadataSource(connection);
Telephone telephone = (Telephone) source.getEntry(Telephone.class, id);
```