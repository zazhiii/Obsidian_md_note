# 获取本地目录
1. 在一个目录中打开Git Bush
2. 执行`git init`
---

![[Pasted image 20230928232428.png]]
工作区->暂存区 : `git add` 
暂存区->本地仓库: `git commit -m'注释内容'`
提交日志: `git log [option]`

---
版本回退: `git reset --hard commitID` 
				其中`commitID`可以用`git-log或git log`查看
查看删除记录: `git reflog`

---
忽略文件: 名为`.gitignore`的文件即为忽略列表

# 分支
