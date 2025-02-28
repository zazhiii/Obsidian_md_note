# 1. 优化

## 1.1 定位慢查询

1. 开启**慢日志查询**，设置值为 2 s，sql 执行超过 2s 就会记录到日志中
2. 使用运维工具（Skywalking)

## 1.2 如何分析慢 sql

在 SQL 语句之前加上关键字 explain / desc，他会给出 SQL 执行的一些信息

`possible_key` 当前 sql 可能会用到的索引
`key` 实际用到的索引
`key_len` 索引占用的大小，与 key二者判断是否命中索引
`Extra` 额外的优化建议
- Using where; Using Index  使用了索引，没有回表查询
- Using index condition  使用了索引，但是需要回表查询 （有优化空间）
`type` 
![[Pasted image 20250227223158.png]]

1. 通过 key 和 key_len 检查是否命中索引
2. 通过 type 字段查看是否有进一步的优化空间，是否存在全盘扫描或全索引扫描
3. 通过 extra 判断是否存在回表查询；若存在，可尝试添加索引。

# 2. 索引

## 2.1 什么是索引

索引是帮助 MySQL 高效获取数据的数据结构，

## 2.2 索引的数据结构

二叉搜索树缺点：最坏情况会形成链表，查询时间复杂度为。

红黑树缺点：当数据量过多时会导致层级过大，查询效率会降低。

B-Tree：
他是多叉树，每个节点存储 $x$ 个 key ，$x+1$ 个指针

InnoDB 引擎采用 B+ 树存储索引

B+ Tree:
- 每个节点存储 $x$ 个 key ，$x+1$ 个指针
- 数据存储在叶子节点，非叶子节点仅仅提供索引的作用
- 叶子节点形成双向链表
B+树对比B树优点：
1. 磁盘读写代价B+树更低
2. 查询效率更稳定
3. 便于扫库和区间查询（叶子节点是一个双向链表）

## 2.3 聚簇索引和非聚簇索引、回表查询

**聚集索引**：数据与索引存放在一起，索引结构的叶子节点保存行数据，有且只有一个

**非聚集索引（二级索引）**：叶子节点只存储关联的主键，可以有多个

聚集索引的选取规则：
- 若存在主键，选取主键
- 若不存在主键，选取第一个唯一（UNIQUE）索引
- 若不存在主键和唯一索引，InnoDB 会自动生成一个 rowid 作为隐藏的聚集索引

**回表查询**：通过二级索引找到行数据的主键，再用主键通过聚集索引找到行数据的过程。




## 2.4 覆盖索引、超大分页处理

覆盖索引：查询使用了索引，并且所需返回的列在该索引中已经能全部找到
`select * from tb_user where id = 1` ✅
`select id, name from tb_user where name = 'Arm'` ✅
`select id, name, gender from tb_user where name = 'Arm'` ❌

超大分页处理
在数据量很大时，limit 分页查询需要对数据排序，效率低

通过 覆盖索引 + 子查询 解决
```sql
select * from tb_user limit 9000000, 10; # ❌

# ✅
select * 
from tb_user a, 
     (select id from tb_user order by id limit 9000000, 10) b,
where a.id = b.id;
```

## 2.5 创建索引的原则

1. ==数据量较大，且查询比较频繁（单表超过10w）
2. ==作为查询条件（where）、排序（order by）、分组（group by）操作的字段
3. 选择区分度高的列作为索引，尽量建立唯一索引，区分度越高，使用索引的效率越高
4. 若是字符串类型的字段，字段的长度较长，可以针对字段的特点，建立前缀索引
5. ==尽量使用**联合索引**，减少单列索引，查询时更容易覆盖索引，避免回表。
6. ==控制索引的数量，索引越多维护索引的代价越大，会影响增删改的效率
7. 若索引列不能包括 NULL 时，建表时使用 NOT NULL 约束它，优化器知道每列是否包含 NULL 时它可以更好确定哪个索引更有效地用于查询

## 2.6 索引失效的情况

最左前缀原则：MySQL 在建立**复合索引**时会遵循最左前缀匹配原则，在检索数据时从联合索引的最左边开始匹配。

```sql
# 建表 创建了(name, gender, age) 的联合索引
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `age` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name_gender_age_INDEX` ( `name`,`gender`,`age`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8

# 插入数据
insert into user values (1, 'aaa', 1, 18);
insert into user values (2, 'bbb', 0, 18);

explain select * from user where name = 'aaa'; 
-- key：name_gender_age_INDEX
-- key_len: 768
-- ✅命中第一列索引

explain select * from user where name = 'aaa' and gender = '1';
explain select * from user where gender = '1' and name = 'aaa';
-- key: name_gender_age_INDEX
-- key_len: 773
-- ✅✅命中前两列索引

explain select * from user where name = 'aaa' and gender = '1' and age = 18;
-- key: name_gender_age_INDEX
-- key_len: 778
-- ✅✅命中三列索引

explain select * from user where name = 'aaa' and age = 18;
-- key：name_gender_age_INDEX
-- key_len: 768
-- ✅❌只有name列命中索引


explain select * from user where gender = '1' and age = 18;
-- key：name_gender_age_INDEX
-- key_len: 768
-- type: index
-- ❌ type: index 代表全索引扫描，没有通过索引查询

explain select * from user where age = 18;
-- key：name_gender_age_INDEX
-- key_len: 768
-- type: index
-- ❌ type: index 代表全索引扫描，没有通过索引查询

# 2. 范围查询右边的列不会走索引
explain select * from user where name = 'aaa' and gender > 0 and age = 18;
-- key：name_gender_age_INDEX
-- key_len: 768
-- ✅✅❌只有前两个字段走了索引（如果是 >= 则三个都会走索引）

# 3. 
explain select * from user where substring(name, 1, 1)  = 'aaa';
-- type: index
-- ❌ 没有走索引

# 4. 
explain select * from user where name = 'aaa' and gender = 1 and age = 18;
-- key：name_gender_age_INDEX
-- key_len: 768
-- ✅❌❌命中第一列索引
```
总结：只有是索引列的前缀的条件字段才会走索引，后面不是前缀的部分不会走索引。

1. 违反最左前缀法则
2. 范围查询右边的列不会走索引
3. 索引列上做运算会导致索引失效
4. 条件中字符不加引号，发生数字转字符串会导致该列和它之后的索引失效
5. 以 % 开头的模糊匹配会导致索引失效





# 事务
## 事务四大特性（`ACID`）

1. 原子性（Atomicity）：事务是不可分割的最小操作单元，要么全部成功，要么全部失败。
2. 一致性（Consistency）：事务完成时，必须使所有的数据都保持一致状态。
3. 隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发操作影响的独立 环境下运行。
4. 持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是永久的。

e.g. 转账案例
## 并发事务问题

赃读：一个事务读到另外一个事务还没有提交的数据。

不可重复读：一个事务先后读取同一条记录，但两次读取的数据不同，称之为不可重复读。

幻读：一个事务按照条件查询数据时，没有对应的数据行，但是在插入数据时，又发现这行数据 已经存在，好像出现了 "幻影"。

## 事务隔离级别

1. 读未提交 -- ✅脏读、✅不可重复度、✅幻读

2. 读已提交 -- ❌脏读、✅不可重复读、✅幻读

3. 可重复读 -- ❌脏读、❌不可重复读、✅幻读 **「MySQL默认」**

4. 串行化 -- ❌脏读、❌不可重复读、❌幻读