
# 基础

## 为什么用Redis

1. 访问速度快 -- 基于内存
2. 高并发 -- QPS 比 MySQL 高一两个数量级
>QPS：Query Per Second 每秒可查询次数
3. 功能强大 -- 缓存、分布式锁、消息队列等等

## 缓存读写策略 TODO

## Redis 的 Java 客户端

- Redission
- Jedis
- lettuce

在项目中使用 SpringDataRedis
# Redis数据类型

## 常见数据类型

String
List
Set
Hash
Zset

HyperLogLog
Bitmap
Geospatial

# 缓存

## 缓存的更新策略

主动更新 + 超时淘汰兜底

1. 更新缓存还是删除缓存？

❌更新缓存：若数据库更新多次，缓存也会更新多次，若该期间无查询，这些就是无效写
✅删除缓存：更新数据库时直接删除缓存，查询时再新建缓存

2. 如何保证缓存和数据库操作原子性？

- 单体系统：讲缓存和数据库操作放在一个事务中
- 分布式系统：分布式事务

3. 先操作缓存还是先操作数据库？

✅先更新数据库再删缓存
❌先删缓存再更新数据库
>后者操作的间隔时间可能更大（写数据库会较慢），更容易发生并发安全问题。

## 缓存穿透解决

## 缓存雪崩解决

## 缓存击穿解决