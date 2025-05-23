
# 字段类型

## UNSIGNED属性

表示无符号整数，会提高整数上限。

## CHAR 和 VARCHAR 的区别？

1. char 是定长的、varchar 是不定长的
2. char 适合存储长度段或者长度差不多字符串，varchar 适合存储长度不一的字符串

## DECIMAL 与 DOUBLE/FLOAT 的区别？

DECIMAL能存精确的小数，没有精度损失。

DOUBLE / FLOAT 存近似的小数，有精度损失。

>DECIMAL存储例如货币的数据；对应Java中的`BigDecimal`类型


## DATATIME 和 TIMESTAMP 的区别

DATATIME 不带时区信息；TIMESTAMP 带时区信息。

前者占 8 个字节，表示的时间范围更大

后者占 4 个字节，表示的时间范围更小

## Boolean类型如何表示

用 TINYINT 表示




# 存储引擎

>MySQL5.5.5之前默认引擎为MyISAM，之后为InnoDB

## InnoDB 和 MyISAM区别

- InnoDB 支持 **事务、外键、行级锁**；MyISAM 只支持表级锁、不支持事务和外键
- InnoDB 支持数据恢复，依靠`redo log`
- InnoDB 支持 MVCC，MyISAM不支持

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
>索引优缺点
>优点：加快查询速度，减少IO次数
>缺点：1.维护索引会影响效率    2.索引使用物理文件存储，会占内存

## 2.2 索引的数据结构

二叉搜索树缺点：最坏情况会形成链表，查询时间复杂度为。

红黑树缺点：当数据量过多时会导致层级过大，查询效率会降低。

B Tree：
他是多叉树，每个节点存储 $x$ 个 key ，$x+1$ 个指针

InnoDB 引擎采用 B+ 树存储索引

**B+ Tree**:
- 每个节点存储 $x$ 个 key ，$x+1$ 个指针
- 数据存储在叶子节点，非叶子节点仅仅提供索引的作用
- 叶子节点形成**双向链表**

B+树对比B树优点：
1. 磁盘读写代价B+树更低
2. **查询效率更稳定**
3. 便于**扫库**和**区间查询**（叶子节点是一个双向链表）

>为什么选择B+树而不是红黑树当索引？
>红黑树是二叉树，如果数据量较大可能会**导致树的高度很高**，需要多次IO才能查询到。

## 索引的种类
- B+ Tree 索引
- 哈希索引

- 聚簇索引
- 非聚簇索引

- 主键索引
- 普通索引
- 唯一索引
- 覆盖索引
- 联合索引
- 全文索引
- 前缀索引

## 主键索引
主键使用的索引，他也是聚簇索引

## 二级索引

叶子节点存储的数据为主键的值

## 聚簇索引和非聚簇索引、回表查询

聚簇索引：**数据与索引**存放在一起，索引结构的叶子节点保存行数据，**有且只有一个**
>主键就是聚簇索引

非聚集索引（二级索引）：叶子节点只存储关联的主键，可以有多个

聚集索引的选取规则：
- 若存在主键，选取主键
- 若不存在主键，选取第一个唯一（UNIQUE）索引
- 若不存在主键和唯一索引，InnoDB 会自动生成一个 rowid 作为隐藏的聚集索引

**回表查询**：通过二级索引找到行数据的主键，再用主键通过聚集索引找到行数据的过程。


## 联合索引和覆盖索引

联合索引：使用多个字段创建索引

覆盖索引：查询使用了索引，并且所需返回的列在该索引中已经能全部找到

`select * from tb_user where id = 1` ✅
`select id, name from tb_user where name = 'Arm'` ✅
`select id, name, gender from tb_user where name = 'Arm'` ❌


## 超大分页处理
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

## 最左前缀法则

在使用联合索引时，根据索引的字段，从左到右去匹配查询条件中的字段，如果能查询条件和索引的最左侧的字段相匹配，这部分字段就会走索引。

例如建立索引`(a, b, c)`

条件：`a = 1 and b = 1 and d = 1;` 
条件：`b = 1 and a = 1 and d = 1;` 
`a b`会走索引（a b顺序可以交换），`d`不会走索引。

条件：`a = 1 and c = 1;` 
`a` 会走索引，`c`不会走索引

条件：`c = 1`
条件：`b = 1 and c = 1`
缺失了索引最左侧的值`a`，整个索引都用不到

条件：`a = 1 and b > 2 and c = 1`
`a b`能走索引，`c`不走索引

条件：`a = 1 and b >= 2 and c = 1`
全部走索引

>1. 只有前缀部分走索引，后面都不走索引
>2. 前缀顺序可以交换
>3. 碰到第一个 < 或 > 停止匹配，<= 和 >= 不会打断匹配

##  创建索引的原则

1. 选择合适的字段
	1. 不为NULL的字段，NULL值数据库难以优化
	2. 被频繁查询的字段
	3. 被作为条件的字段
	4. 频繁需要排序的字段
	5. 经常被连接的字段
	6. 选择区分度高的索引（例如性别不适合做索引）
2. 频繁被更新的字段避免建索引
3. 避免索引过多
4. 考虑联合索引而非单列索引
5. 避免冗余索引（`(a, b)`和`(a)`，能命中前者就一定命中后者）
6. 字符串用前缀索引代替普通索引


7. ==数据量较大，且查询比较频繁（单表超过10w）
8. ==作为查询条件（where）、排序（order by）、分组（group by）操作的字段
9. 选择**区分度高**的列作为索引，尽量建立唯一索引，区分度越高，使用索引的效率越高
10. 若是字符串类型的字段，字段的长度较长，可以针对字段的特点，建立前缀索引
11. ==尽量使用**联合索引**，减少单列索引，查询时更容易覆盖索引，避免回表。
12. ==控制索引的数量，索引越多维护索引的代价越大，会影响增删改的效率
13. 若索引列不能包括 NULL 时，建表时使用 NOT NULL 约束它，优化器知道每列是否包含 NULL 时它可以更好确定哪个索引更有效地用于查询

## 索引失效的情况

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
-- ✅✅命中前两列索引 🌟前缀的顺序不会影响走索引

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
2. **范围查询右边**的列不会走索引
3. 索引列上**做运算**会导致索引失效
4. 条件中字符不加引号，发生**数字转字符串**会导致该列和它之后的索引失效
5. **以 % 开头的模糊匹配**（例如：`LIKE '%xyz'`）

# 3. SQL 优化的经验

1. 表设计优化
	1. 选择合适数值类型（tinyint、int、bigint）
	2. 选择合适字符串类型，char 定长，效率高；varchar 可变长，效率相对低。
2. SQL 语句优化
	1. SELECT 声明字段名称（避免 SELECT * ）
	2. 避免索引失效
	3. 尽量用 UNION ALL 代替 UNION，UNION 会多一次过滤重复值
	4. 避免在 WHERE 中对字段进行表达式操作
	5. JOIN 优化尽量使用 INNER JOIN，若需要用 LEFT JOIN 和 RIGHT JOIN ，需要以小表为驱动（小表放在外层）
3. 索引优化
4. 主从复制，读写分离
5. 分库分表



# 4. 事务

>事务就是多个对数据库的操作

## 4.1 事务四大特性（`ACID`）

1. 原子性（Atomicity）：事务是不可分割的最小操作单元，要么全部成功，要么全部失败。
2. 一致性（Consistency）：事务完成时，必须使所有的数据都保持一致状态。
3. 隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发操作影响的独立环境下运行。
4. 持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是永久的。

e.g. 转账案例

## 4.2 并发事务问题

赃读：一个事务读到另外一个事务还没有提交的数据。

不可重复读：一个事务先后读取同一条记录，但两次读取的数据不同，称之为不可重复读。

幻读：一个事务按照条件查询数据时，在第一次查询之后另一个事务插入了数据行，改事务在后续查询中出现了原先不存在的数据，好像出现了 "幻影"。

修改丢失：一个事务的修改被另一个事务覆盖



## 4.3 事务隔离级别

| 隔离级别 | 脏读  | 不可重复度 | 幻读  |               |
| :--: | :-: | :---: | :-: | :-----------: |
| 读未提交 |  ✅  |   ✅   |  ✅  |               |
| 读已提交 |  ❌  |   ✅   |  ✅  |               |
| 可重复读 |  ❌  |   ❌   |  ✅  | **「MySQL默认」** |
| 可串行化 |  ❌  |   ❌   |  ❌  |               |

## 4.4 undo log 和 redo log

**缓冲池（Buffer Pool）**：主存中的一个区域，里面可以缓存磁盘上需要经常操作的数据，在执行数据 CRUD 时，先操作缓冲池中的数据（若缓冲池没有数据，则从磁盘加载并缓存），缓冲池再以一定频率刷新到磁盘，减少磁盘 IO ，提高性能。

**数据页（Page）**：InnoDB 磁盘管理的最小单元（16kb），页中存储行数据。

### 4.4.1 redo log

>redo log 为 InnoDB 独有

**redo log**：重做日志，记录事务提交时对数据页的**物理修改**，实现事务的**持久性**

若MySQL挂了，可以通过 redo log 恢复数据

该日志文件由 redo log buffer （内存中）和 redo log file （磁盘中）组成。当事务提交时会将数据的修改信息保存到该文件中，在**刷脏页到磁盘**出现错误时，就可以用它恢复数据。

MySQL 中数据以页为单位，查询数据时先从`Buffer Pool`中查找，没有找到再去磁盘找。
然后将数据缓存在`Buffer Pool`中，更新数据也是更新`Buffer Pool`中的数据，然后将**修改**记录到`redo log buffer`中，再刷到`redo log`文件中。

![[redo log.png]]

### 为什么需要 `redo log` ？

刷脏页是**随机磁盘 IO** 效率较低，所以没有采用发生数据操作立马同步缓冲池到磁盘的方案。而发生数据操作时，将操作信息记录到 redo log buffer ，再将 redo log buffer 同步到 redo log file 是顺序磁盘 IO 效率会高一些（日志文件是追加的）。这种方式叫做 Write-Ahead Logging (先写日志)。

当缓冲池同步数据到磁盘后，redo log 记录的信息也就没用了，会定期清理 redo log file。

### `redo log`刷盘时机
1. 事务提交
2. 后台刷新线程，定期刷脏页
3. 正常关闭服务

### 4.4.2 undo log

undo log：回滚日志，作用是提供 回滚 和 MVCC，它**是逻辑日志**

当进行一个数据操作时，undo log 会记录一个与之相反的操作，当 rollback 时，就可以从 undo log 中的逻辑记录读取到相应内容，并进行回滚

它实现了事务的 **原子性** 和 **一致性**

## 4.5 MVCC

当前读：读取的是记录的最新版本，读取时保证其他并发事务不能修改当前记录，会对读取的记录加锁。
e.g. ：`select ... lock in share mode(共享锁)` 、`select ... for update` 、`update` 、`insert` 、`delete` (排他锁)。

快照读：读取的是记录的可见版本，有可能是历史数据，不加锁，是非阻塞读。简单的 `select(不加锁）`就是快照读。
- Read Committed：每次select，都生成一个快照读。 
-  Repeatable Read：开启事务后第一个select语句才是快照读的地方。 
- Serializable：快照读会退化为当前读。

**Multi-Version Concurrency Control 多版本并发控制**。维护一个数据的多个版本，使得并发事务读写数据时的一致性和隔离性

### InnoDB 对 MVCC 的实现？

MVCC 实现依赖 
1. 三个隐藏字段
2. undo log
3. readView

三个隐藏字段：
1. DB_TRX_ID：记录最近插入或更新该行数据的事务 ID
2. DB_ROLL_PTR：回滚指针，指向这行记录的上一个版本，用于配合 undo log ，指向上一个版本
3. DB_ROW_ID：隐藏主键，若表结构没有主键，会生成该字段。

undo log：
回滚日志，在 insert、update、delete 的时候产生的便于数据回滚的日志。 
当insert的时候，产生的undo log日志只在回滚时需要，在事务提交后，可被立即删除。 
而update、delete的时候，产生的undo log日志不仅在回滚时需要，在快照读时也需要，不会立即被删除。

undo log 版本链：一些事务对同一条记录进行修改，undo log 会生成一条记录版本链，链表头部是最新数据，尾部是最旧数据。这个链表是通过 DB_ROLL_PTR 实现的。

readView：快照读 SQL 执行 MVCC 提取数据的依据，他维护了当前活跃（未提交）事务的 ID
- m_ids：当前活跃的事务 ID 的集合
- min_trx_id：最小的活跃事务 ID
- max_trx_id：预分配事务 ID，最大事务 ID + 1
- creator_trx_id：ReadView 创建者的事务 ID

在 undo log 版本链中的各个版本的数据根据一些规则来决定是否**对创建 readView 的事务可见**。
换句话说，readView 的作用是判断 undo log 版本链中各个版本的数据对**当前事务**是否可见。

这个规则是由版本链中数据它们对应的事务 ID ( trx_id ) 决定的。
- trx_id == creator_trx_id ✅ 这条修改数据就是当前事务修改的，可见
- trx_id < min_trx_id ✅ 这个事务已经提交了，可见
- trx_id >= max_trx_id ❌ 这个事务是创建 readView 之后才开启的。
- min_trx_id <= trx_id < max_trx_id 且 trx_id 不在 m_ids 中，✅ 事务已经提交，可见。

不同的事务隔离级别生成 readView 的时机不同：
- READ COMMITTED ：在事务中每一次执行快照读时生成ReadView。 
- REPEATABLE READ：仅在事务中第一次执行快照读时生成ReadView，后续复用该ReadView（复用 ReadView 才能保证每次读取的数据都一致，可以这样理解）。


# 5. 主从同步原理

1. 主库将数据的改变（DDL、DML 语句）存入 **bin log** 中
2. 从库从主库的 bin log 中读取并写入到从库的 Relay log 中
3. 从库再执行一下 Relay log 中的

# 6. 分库分表
