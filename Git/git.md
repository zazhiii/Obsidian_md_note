# 获取本地目录
1. 在一个目录中打开Git Bush
2. 执行`git init`
---

![[Pasted image 20230928232428.png]]
工作区->暂存区 : `git add` 
暂存区->本地仓库: `git commit -m'注释内容'`
提交日志: `git log [option]`

---
查看提交状态: `git status`
版本回退: `git reset --hard commitID` 
				其中`commitID`可以用`git-log或git log`查看
查看删除记录: `git reflog`

---
忽略文件: 名为`.gitignore`的文件即为忽略列表

# 分 支
查看分支:  `git branch`
创建分支:  `git branch 分支名`
切换分支:   `git checkout 分支名`
切换并创建分支:  `git checkout -b 分支名`
**合并分支**:  `git merge 分支名称`

#### 解决冲突
两分支存在冲突时, 需要手动处理冲突
1. 处理文件冲突地方
2. 解决完的文件加入暂存区(add)
3. 提交到仓库(commit)

#### 开发中使用分支
- master(生产)分支
	项目上线基于此分支, 线上运行应用对应的分支
- develop(开发)分支
	
- feature/xxxx分支
- hotfix/xxxx分支
![[Pasted image 20231002231911.png]]

# 远程仓库(gitee)
1. 新建仓库
2. 生成SSH密钥: `ssh-keygen -t rsa`
	不断回车
	查看密钥: `cat ~/.ssh/id_rsa.pub`
	gitee设置ssh公钥
	验证配置: `ssh -T git@gitee.com`