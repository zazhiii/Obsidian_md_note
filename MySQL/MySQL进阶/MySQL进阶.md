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

# 二. 索引(! ! !)
- 生产 测试 开发环境绝大部分用Linux版本MySQL
- # p65 5:42
- rpm安装mysql