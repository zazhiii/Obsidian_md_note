## 快捷键位组合键位
	- !+enter         召唤出html框架
	- ctrl+s      		保存
	-  ctrl+/  			注释/取消注释
	- ctrl+D			选中多个字符
## 小知识点
	1. 相对路径返回上一级:   . . /
	2. 当前路径: ./
---
## 二、HTML初识

### HTML初识

**「HTML」**(Hyper Text Markup Language):超文本标记语言  

**「所谓超文本，有2层含义」**

-   因为它可以加入图片、声音、动画、多媒体等内容（超越文本限制 ）
    
-   不仅如此，它还可以从一个文件跳转到另一个文件，与世界各地主机的文件连接（超级链接文本）。
    

**「HTML骨架格式」**
```
<!-- 页面中最大的标签 根标签 -->   
<html>       
	<!-- 头部标签 -->       
	<head>                
		<!-- 标题标签 -->           
		<title></title>        
	</head>       
	<!-- 文档的主体 -->       
	<body>       
	</body>   
</html>   
```


**「团队约定大小写」**

-   HTML标签名、类名、标签属性和大部分属性值统一用**小写

**「HTML元素标签分类」**

-   常规元素(双标签)
-   空元素(单标签)
```
 常规元素(双标签)  
    
 <标签名> 内容 </标签名>   比如<body>我是文字</body>  
       
 空元素(单标签)  
   
 <标签名 />  比如 <br />或<br>
```

**「HTML标签关系」**

-   嵌套关系父子级包含关系
    
-   并列关系兄弟级并列关系
    
	-   如果两个标签之间的关系是嵌套关系，子元素最好缩进一个tab键的身位（一个tab是4个空格）。如果是并列关系，最好上下对齐。

### 文档类型<!DOCTYPE >

**「文档类型」**用来说明你用的XHTML或者HTML是什么版本。<!DOCTYPE html>告诉浏览器按照HTML5标准解析页面。

### 页面语言lang

lang指定该html标签内容所用的语言

```
<html lang="en">       

en 定义语言为英语 zh-CN定义语言为中文
```
**「lang的作用」**

-   根据根据lang属性来设定不同语言的css样式，或者字体
    
-   告诉搜索引擎做精确的识别
    
-   让语法检查程序做语言识别
    
-   帮助翻译工具做识别
    
-   帮助网页阅读程序做识别

### 字符集

**「字符集」**(Character set)是多个字符的集合,计算机要准确的处理各种字符集文字，需要进行字符编码，以便计算机能够识别和存储各种文字。

-   UTF-8是目前最常用的字符集编码方式
    
-   让 html 文件是以 UTF-8 编码保存的， 浏览器根据编码去解码对应的html内容。
    
```
  <meta charset="UTF-8" />
```

**「meta viewport的用法」**  
    通常viewport是指视窗、视口。浏览器上(也可能是一个app中的webview)用来显示网页的那部分区域。在移动端和pc端视口是不同的，pc端的视口是浏览器窗口区域，而在移动端有三个不同的视口概念：布局视口、视觉视口、理想视口

    meta有两个属性name 和 http-equiv

**name属性的取值**

-   keywords(关键字) 告诉搜索引擎，该网页的关键字
    
-   description(网站内容描述) 用于告诉搜索引擎，你网站的主要内容。
    
-   viewport(移动端的窗口)
    
-   robots(定义搜索引擎爬虫的索引方式) robots用来告诉爬虫哪些页面需要索引，哪些页面不需要索引
    
-   author(作者)
    
-   generator(网页制作软件）
    
-   copyright(版权)

**http-equiv有以下参数**  

http-equiv相当于http的文件头作用，它可以向浏览器传回一些有用的信息，以帮助正确和精确地显示网页内容

-   content-Type 设定网页字符集(Html4用法，不推荐)
    
-   Expires(期限) ,可以用于设定网页的到期时间。一旦网页过期，必须到服务器上重新传输。
    
-   Pragma(cache模式),是用于设定禁止浏览器从本地机的缓存中调阅页面内容，设定后一旦离开网页就无法从Cache中再调出
    
-   Refresh(刷新),自动刷新并指向新页面。
    
-   cache-control（请求和响应遵循的缓存机制）

```
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```
### HTML标签的语义化

-   方便代码的阅读和维护，样式丢失的时候能让页面呈现清晰的结构。
    
-   有利于SEO，搜索引擎根据标签来确定上下文和各个关键字的权重。
    
-   方便其他设备解析，如盲人阅读器根据语义渲染网页
    
**「拓展」** 标签：规定页面上所有链接的默认 URL 和设置整体链接的打开状态

```
<head>  
    <base href="http://www.baidu.com" target="_blank">  
    <base target="_self">  
</head>  
<body>  
    <a href="">测试</a> 跳转到 百度  
</body>
```



























---
## 三,HTML常用标签
#### 1. 排版标签

**主要和css搭配使用，显示网页结构的标签，是网页布局最常用的标签。**
	1. < h >(h1~h6)	  		标题标签
	2. < p >		                段落标签
	3. < br >                      换行标签（单标签）
	4. <	hr >                     水平分割线标签（单）
	5. div&span                 网页布局最主要的2个盒子。

#### 2.排版标签

-   b和strong 文字以粗体显示
    
-   i和em 文字以斜体显示
    
-   s和del 文字以加删除线显示
    
-   u和ins 文字以加下划线显示

**「3. 标签属性(行内式)」**

使用HTML制作网页时，如果想让HTML标签提供更多的信息，可以使用HTML标签的属性加以设置。

3. 图片
```
<img  src=""  alt="">(src:路径  alt:供选择的路径)
```
**注意：**

-   标签可以拥有多个属性，必须写在开始标签中，位于标签名后面。
    
-   属性之间不分先后顺序，标签名与属性、属性与属性之间均以空格分开。
    
-   采取  键值对 的格式   key="value"  的格式
2. 音频
```
<audio  src=""> </audio>
```
3. 视频
```
<video  src=""> </video>
```
4. 超链接
```
<a  href="跳转地址">Name</a>（网址，文件，#，#name）
*target打开页面的方式：_blank新窗口打开，_self原窗口打开
```
5. 盒子
```
<div>大盒子     <span>小盒子   		(单标签)
```
6. 锚点链接
```
<a href="#live">生活</a>
.......
<h1 id="live">生活< /h1>				* # 加名称
 ```
### 7. ！！表格(展示数据)
```  
<table>				                        定义表格的标签
	<tr>									定义表格中的行
		<th>内容</th>(table head)			表头单元标签(加粗居中)		
		<td>内容</td>(table data)			定义表格中的单元格
	</tr>
</table>
```
##### 1. 表格结构标签
```
<table>
	<thead>						
		<tr>
			<th>......</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>......</td>
		</tr>
	</tbody>
</table>
```
##### 2. 合并单元格
```
<td colspan="合并数量"></td> 跨列合并单元格
<td rowspan="合并数量"></td> 跨行合并单元格
											*最上方或最左方为目标单元格
```
### 8.列表标签
#### 1. ！！！！！无序列表 
```
<ul>								#列表
	<li>...</li>				 	#列表项
	<li>...</li>
</ul>
											*<ul>标签中只能放<li>
											*<li>标签中可放所有标签
```
#### 2.！！！自定义列表
```
<dl>
	<dt> name1 </dt>				#定义项目名字
	<dd> name1 explain1 </dd>		#描述项目
	<dd> name1 explain1 </dd>		#描述项目
</dl>			
									*<dl>里只能包含<dt> <dd>
						
```
3. 有序列表
```
<ol>....</ol>
```
### 9.表单标签
#### 1. 表单域（将表单元素信息提交给服务器）
```
<form  action="url地址"  method="提交方式(get/post)"  name="表单域名称">
	.........(各种表单元素)
</form>
```
#### 2.表单元素
##### 1. 输入表单元素
``` 
<input  type="属性">
						*属性：单选radio 复选checkbox 
						*多个选项唯一选择起相同的表单元素名字
```
 lable标签
```
<label  for="id">内容</label>
```
##### 2.下拉表单元素
```
<select  name=""  id="">
	<option  value="">选项1</option>
	<option  value="">选项2</option>
	<option  value="">选项3</option>
</select> 				
						*<option select="selected">当前选项为默认选项
						*<option  disabled  selected  hidden>...</option>下拉菜单名字
```	
##### 3.文本域表单标签
```
<textarea  name=""  id=""  cols="30"  rows="10">
	.......内容
</textarea>								
```
# 查阅文档
百度
[W3C 简介 (w3school.com.cn)](https://www.w3school.com.cn/w3c/w3c_intro.asp)
[MDN Web Docs (mozilla.org)](https://developer.mozilla.org/zh-CN/)

