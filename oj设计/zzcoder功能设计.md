

# 用户模块

学习点：

- 不同子模块之间类调用；
- 全局异常处理；
- springmvc返回时数据确保返回数据可被序列化，确保返回对象具有适当的 getter 方法和无参构造函数；
- @Validated使用细节
- 自定义异常
- @sl4j的作用
- 拦截器会将swagger的请求也拦截，需要排除

#### AuthController
##### 1. 发送邮箱验证码 
- [x] 发送六位随机验证码到邮箱
- QQ 邮箱的 SMTP 服务（发送邮件）；
- ~~防止重复发送验证码；~~
##### 2. 注册
 - [x] 用户名+密码+邮箱注册
##### 3. 登录
 - [x] 用户名 | 邮箱 | 手机号、密码登录
 - [x] 邮箱、验证码登录 
	前端传递参数：邮箱、验证码
	1. 判断用户是否存在
	2. 判断redis中是否存在对应验证码
	3. 返回token
 - [ ] ~~手机号、验证码登录
 - [ ] ~~微信扫码登录 
 - [ ] github、gitee第三方登录
##### 4. 重置密码
- [x] 通过输入原密码重置密码
	参数：旧密码+新密码（重复密码逻辑在前端实现）
	1. 通过Threadlocal获取当前用户的id（生成token id是Long，为什么从token解析出的id变成Integer了？破案了，是因为序列化和反序列化没特别区分Long和Integer）
	2. 判断旧密码是否正确，正确则更新密码
	3. 删除redis中的旧token，这里**从请求头中获取token**  `@RequestHeader`
- [x] 通过邮箱验证码重置密码
	参数：邮箱+验证码+新密码，通过邮箱重置密码不应该被拦截
	1. 判断邮箱是否存在
	2. 判断对应验证码是否正确
	3. 更新密码
##### 5. 登出
- [x] 登出
将redis中的token删除
#### UserController
##### 1. 更改邮箱
- [x] 更新邮箱地址
登录状态下验证新邮箱之后更新邮箱
##### 2.上传/修改头像
- [x] 上传头像
##### 4.查询用户详细信息
- [x] 获取当前用户基本信息
通过ThreadLocal存的id查询返回当前用户的信息
##### 5.修改用户基本信息





# 题目模块

##### 1. 分页条件查询题目
- [x] 分页条件查询
条件：关键字，标签、难度、来源
##### 2. 查看题目
- [x] 查看题目详细信息
##### 3. 添加、修改、删除题目（管理员）
- [x] 添加题目
- [x] 修改题目
采用通用更新方法
- [x] 删除题目
通过id删除题目，删除题目后需要删除题目标签关联表中的数据
##### 4.添加、删除标签 
- [x] 添加
- [x] 删除
##### 5.添加标签到题目
- [x] 添加标签到题目
在关联表中添加关联数据
 