## 1. Web APIs
### 1.1 API
```
简单理解: API是给程序员提供的一种工具,以便能更轻松的实现功能
``` 
### 1.2Web API
```
Web API是浏览器提供的一套操作浏览器功能和页面元素的API(BOM和DOM)
```
## 2.DOM
```
```
### 2.1获取元素
#### 2.1.1 根据ID获取
```
getElementById(id)
	*script标签写到下面
	*驼峰命名法
	*参数id是大小写敏感的字符串
	*返回的是一个元素对象
	*console.dir 打印我们返回的元素对象 更好的查看里面的属性和方法
```
#### 2.1.2 根据标签名获取
```
getElementByTagName()
	*返回的是 获取过来的元素对象的集合 以伪数组的形式存储的
	*我们想一次打印里面的元素对象 我们可以采用遍历的方式
	*得到的对象是动态的 
```
#### 2.1.3 根据类名获取	( HTML5 新增 )
```
1. var element = document.getElementByClassName('')
2. var element = document.querySelector('')
	*返回指定选择器的第一个元素对象 里面的 选择器需要加符号
3. var element = querySelectorAll('')
	*返回指定选择器的所有元素对象
```
#### 2.1.4 获取特殊元素
```
1.获取body元素
	doucument.body
2.获取html元素
	doucument.documentElement 
```
### 2.2事件基础
#### 2.2.1事件概述
```
JS使我们有能力创建动态页面 而事件是可以被JS侦测到的行为
简单理解:触发---响应机制 
网页中的每个元素都可以产生某些可以触发JS的事件 
	1.事件是由三部分组成(事件三要素):
		(1).事件源: 事件被触发的对象
		(2).事件类型: 如何触发 什么事件
		(3).事件处理程序: 通过一个函数赋值的方式完成
```
#### 2.2.2事件执行的步骤
```
1.获取事件源
2.注册事件(绑定事件)
3.添加事件处理程序(采取函数赋值形式) 
```
### 2.3 操作元素
#### 2.3.1改变元素内容
```
1. element.innerText
2. element.innerHTML(用的最多)
	 *区别:
		1.innerText不识别html标签 
		2.两个属性是可读写的 可以获取元素里面的内容
		3.innerHTML识别标签 保留空格和换行
```
#### 2.3.2常用元素的属性操作
```
element.属性
```
#### 2.3.3表单元素的属性操作
#### 2.3.4样式属性操作
```
1. element.style.属性 = '' 		行内样式操作
		*JS 里面的样式采用驼峰命名法
		*JS 修改style样式产生的是行内样式 ,CSS权重比较高 
		*样式少 功能简单时时使用
2. element.className = ''	类名样式操作
		*适用于样式较多或者功能复杂的情况
		*className 会直接更改类名 会覆盖原来的类名
```
#### 2.3.5 自定义元素的操作
```
1.获取元素的属性值
	(1).element.属性
	(2).element.getAttribute('属性')
		*我们自己添加的属性
2.设置元素属性值
	(1).element.属性 = '值'
	(2).element.setAttribute('属性','值')
		*主要针对自定义属性
3.移除属性 
	removeAtrribute('属性')
*H5规定自定义属性由 data- 开头
4.获取H5自定义属性
	(1).兼容性获取  element.getAtrribute('data-index');
	(2).H5新增 element.dataset.index 或者 element.dataset['index']
		*dataset是一个存放所有以data开头的自定义属性
		*如果自定义属性里面有多个-链接的单词 我们获取的时候采取驼峰命名法
```
## 3.节点操作
### 3.1节点层级
```
1.父级节点
	node.parentNode
	*得到的是离元素最近的父节点
2.子节点
	parentNode.childNodes(标准) 
		*返回值包含所有的子节点
	parentNode.children(非标准)(重点掌握)
		*返回所有子元素节点 其余节点不返回
	parentNode.firstChild
		*获取第一个子节点 不管是文本节点还是元素节点
	parentNode.lastChild
	parentNode.firstElementChild
	parentNode.lastElementChild
实际开发写法 没有兼容性问题
	parentNode.children[0] 	parentNode.children[parentNode.children.length-1]
3.兄弟节点
	node.nextSibling  
		*得到下一个兄弟节点 包含所有节点
	node.nextElementSibling
	node.previousElementSibling
```
### 3.2创建节点
```
 document.creatElement('tagName')
```
### 3.3添加节点
```
node.appendChild(child)
	node 父级  child 子级	后面追加元素
node.insertBefore(child,指定元素)
```
### 3.4删除节点
```
node.removeChild(child )
```
### 3.5克隆节点
```
node.cloneNode()
*如果括号为空或false 只复制标签不复制里面的内容
```
## 4.创建元素
```
1.innerHTML
	创建多个元素效率更高(不要拼接字符串,采取数组形式拼接) 结构稍复杂
2.creatElement()
	创建多个元素效率稍低,但结构更清晰
```
## 5.DOM重点核心
### 5.1创建
```
1.document.write
2.innerHTML
3.creatElement
```
### 5.2增
```
1.appendChild
2.insertBefore
``` 
### 5.3删
```
removeChild
```
### 5.4改
```
1.修改元素属性:src,href,title等
2.修改普通元素内容:innerHTML,innerText
3.修改表单元素:value,type,disable等
4.修改元素样式:style,className
```
### 5.5查
```
1.DOM提供的API方法:getElementByld,getElementByTagName(古老用法不推荐)
2.H5提供的新方法:querySelector,querySelectorAll(提倡)
3.节点获取元素:parentNode,children,previousElementSibing,nextElementSibing
```
### 5.6属性操作
```
1.setAttribute:设置dom的属性值
2.getAttribute:得到dom的属性值
3.removeAttribute:移除属性
```
### 5.7事件操作


## 6.事件高级  
### 6.1注册事件(绑定事件)
```
1.传统方式:
	*利用on开头的事件
	*特点:注册事件的唯一性
	同一个元素同一个事件只能设置一个处理函数,最后注册的处理函数会覆盖前面注册的处理函数
2.方法监听注册方法
	*w3c标准 推荐方法
	*同一元素同一事件可以注册多个监听器
	*按注册顺序依次执行
```
```
EventTarget.addEventListener(type, listener, useCapture);
*type:事件类型字符串 如click,mouseover 不带on
*listener:事件处理函数,事件发生时会调用该监听函数
*useCapture:可选参数 是一个布尔值 默认false
```
