# 一. MySQL概述
![[Pasted image 20230924201811.png]]
![[Pasted image 20230924203534.png]]
![[Pasted image 20230924220101.png]]
![[Pasted image 20230924220352.png]]
![[Pasted image 20230924220618.png]]

# 二. SQL(基础中最重要)

![[Pasted image 20230924220951.png]]
![[Pasted image 20230924221151.png]]
## 1. DDL
### 数据库操作
![[Pasted image 20230924221349.png]]

### 数据类型
![[Pasted image 20230926165707.png]]
![[Pasted image 20230926165749.png]]
![[Pasted image 20230926165823.png]]
### 表操作(增删改查)
![[Pasted image 20230926163750.png]]
![[Pasted image 20230926164543.png]]

 - **下列操作用图形化界面操作**
![[Pasted image 20230926171816.png]]
![[Pasted image 20230926171109.png]]
![[Pasted image 20230926171531.png]]
![[Pasted image 20230926171856.png]]
![[Pasted image 20230926171924.png]]
## 2. DML(表中数据: 增, 删, 改)
![[Pasted image 20230926222658.png]]

![[Pasted image 20230926222944.png]]

![[Pasted image 20230926224011.png]]

![[Pasted image 20230926224041.png]]

## 3. DQL(表中数据: 查询)
![[Pasted image 20230926224747.png]]
![[Pasted image 20230926224942.png]]
### 基本查询
![[Pasted image 20230926225144.png]]
`select * from ...`实际开发少用, 不直观, 影响效率
### 条件查询
![[Pasted image 20230927124914.png]]
### 聚合函数
 ![[Pasted image 20230928120204.png]]
### 分组查询
![[Pasted image 20230928124327.png]]
### 排序查询
![[Pasted image 20230928204648.png]]
### 分页查询
![[Pasted image 20230928204809.png]]
### 执行顺序
![[Pasted image 20230928210058.png]]
### 总结
![[Pasted image 20230928210147.png]]

## ~~4.DCL~~
![[Pasted image 20230928210255.png]]
### 管理用户
![[Pasted image 20230928210952.png]]
### 权限控制
![[Pasted image 20230928211117.png]]
![[Pasted image 20230928211241.png]]
![[Pasted image 20230928211330.png]]

# 三. 函数
![[Pasted image 20230928211556.png]]

## 1.字符串函数
![[Pasted image 20230928211927.png]] 
## 2.数值函数
![[Pasted image 20230928212914.png]]
## 3.日期函数
![[Pasted image 20230928213310.png]]
## 4.流程函数
![[Pasted image 20230928220908.png]]

## 5.总结
![[Pasted image 20230928221642.png]]

# 四. 约束
## 1.概述
![[Pasted image 20230928222136.png]] 
![[Pasted image 20230928223522.png]]
## 2.外键约束
![[Pasted image 20230928223720.png]]
![[Pasted image 20230928224425.png]]
- **项目推荐使用逻辑外键**

![[Pasted image 20230928224819.png]]
## 3.总结
![[Pasted image 20230928224854.png]]

# 五. 多表查询
## 1.多表关系
![[Pasted image 20231001204555.png]]
![[Pasted image 20231001204650.png]]
![[Pasted image 20231001204808.png]]
![[Pasted image 20231001205545.png]] 
## 2. 多表查询概述
![[Pasted image 20231001210349.png]]
![[Pasted image 20231001210716.png]]
## 3.内连接
- 隐式内连接
- 显式内连接
![[Pasted image 20231001210837.png]]
## 4.外连接
![[Pasted image 20231001211713.png]]
## 5.自连接
![[Pasted image 20231001212300.png]]
- 联合查询
![[Pasted image 20231001213427.png]]
## 6.子查询
![[Pasted image 20231001213606.png]]
 - 标量子查询
![[Pasted image 20231001214134.png]]
- 列子查询
![[Pasted image 20231001214224.png]]
- 行子查询
![[Pasted image 20231001215547.png]]
- 表子查询
![[Pasted image 20231001220532.png]]
- 总结
![[Pasted image 20231001225702.png]]
# 六. 事务
## 1.简介
![[Pasted image 20231002172855.png]]
## 2. 事务操作
![[Pasted image 20231003111112.png]]
![[Pasted image 20231003111720.png]]
## 3. 事务的四大特性
![[Pasted image 20231003112346.png]]
## 4.并发事务问题
![[Pasted image 20231003112833.png]]
## 5.事务隔离级别
![[Pasted image 20231003114241.png]]
- 一般用默认级别不会做修改
## 6.总结
![[Pasted image 20231003114347.png]]

# 七. 基础总结
- SQL: 开发人员重点掌握DDL, DML, DQL
![[Pasted image 20231003114757.png]]
- -->SQL优化, 分库分表.....