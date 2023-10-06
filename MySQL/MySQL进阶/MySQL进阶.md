![[Pasted image 20231003134019.png]]
#### 索引最为核心! ! !

# 一. 存储引擎

## 1. MySQL体系结构
![[Pasted image 20231003134449.png]]
- 索引在引擎层, 不同引擎索引结构不同
![[Pasted image 20231003134550.png]]
## 2. 存储引擎简介
![[Pasted image 20231003134948.png]]
![[Pasted image 20231003135151.png]]
## 3.存储引擎特点
- InnoDB
![[Pasted image 20231003135506.png]]
![[Pasted image 20231003135854.png]]
- MyISAM
![[Pasted image 20231003140013.png]]
- Memory
![[Pasted image 20231003140219.png]]
--- 
- **关注InnoDB和MyISAM的区别**
- **事务, 外键, 行级锁**
![[Pasted image 20231003140349.png]]
## 4.存储引擎选择
![[Pasted image 20231003141032.png]]
## 5. 总结
![[Pasted image 20231003141212.png]]

# 二. 索引(重要 核心! ! !)
- 生产 测试 开发环境绝大部分用Linux版本MySQL
- Linux环境安装mysql, 并DataGrip成功远程连接
## 1.索引概述
![[Pasted image 20231005111542.png]]
![[Pasted image 20231005111739.png]]
- 索引并不是二叉树
![[Pasted image 20231005111922.png]]
## 2.索引结构
![[Pasted image 20231005112029.png]]
![[Pasted image 20231005230648.png]]
- 相关数据结构 
![[Pasted image 20231005230952.png]]
![[Pasted image 20231005231132.png]]
![[Pasted image 20231005231646.png]]
![[Pasted image 20231005231829.png]]
- MySQL优化了B+树
![[Pasted image 20231005231930.png]]
- 哈希索引
![[Pasted image 20231005232230.png]]
![[Pasted image 20231005232351.png]]
![[Pasted image 20231005232803.png]]
## 3.索引分类
![[Pasted image 20231005232948.png]]
![[Pasted image 20231005233238.png]]
![[Pasted image 20231005233359.png]]
![[Pasted image 20231005233646.png]]
- 思考 
![[Pasted image 20231005233953.png]]
![[Pasted image 20231005234427.png]]
## 4. 索引语法
![[Pasted image 20231005234947.png]]
## 5. SQL性能分析
 主要优化查询语句
 
- 1. 查看执行频次
![[Pasted image 20231006205645.png]]
- 2. 慢查询日志
- 此时需要借助数据库 **慢查询日志** 定位具体优化那些SQL语句
![[Pasted image 20231006210219.png]]
- 3. profile详细
![[Pasted image 20231006210800.png]]
![[Pasted image 20231006211138.png]]
- 4. explain执行计划
![[Pasted image 20231006211555.png]]
![[Pasted image 20231006213311.png]]
![[Pasted image 20231006213819.png]]
- type最重要
- possible_key, key, key_len, extra也可关注
## 6. 索引使用
![[Pasted image 20231006214948.png]]
![[Pasted image 20231006215557.png]]
![[Pasted image 20231006215956.png]]![[Pasted image 20231006220256.png]]
![[Pasted image 20231006220410.png]]
![[Pasted image 20231006220705.png]]![[Pasted image 20231006221030.png]]
- 针对没有索引的字段也创建索引
![[Pasted image 20231006221405.png]]
![[Pasted image 20231006222803.png]]
![[Pasted image 20231006223307.png]]
![[Pasted image 20231006223740.png]]
![[Pasted image 20231006223924.png]]
- 前缀索引
![[Pasted image 20231006224831.png]]
![[Pasted image 20231006225013.png]]
- 单列索引和联合索引
![[Pasted image 20231006225623.png]]
![[Pasted image 20231006225733.png]]
## 7. 索引设计原则
![[Pasted image 20231006230632.png]]
## 总结
![[Pasted image 20231006231136.png]]
![[Pasted image 20231006231321.png]]

# 3. SQL优化