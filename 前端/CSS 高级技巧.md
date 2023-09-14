## 1.精灵图
### 1.1为什么需要使用精灵图

- **目的**：有效减少服务器接收和发送请求的次数，提高页面的加载速度
- **核心原理**：将网页中的一些小背景图像整合到一张大图中，这样服务器就只需要一次请求就可以了 

### 1.2精灵图（sprites）的使用 (理论）
```
使用精灵图核心：
1.精灵技术主要针对于背景图片使用,将多个小背景整合到一张大图片中
2.这个大图片也被称为sprites 精灵图 或者 雪碧图
3. 移动背景图片位置，此时可以使用background-position
4. 移动距离就是这个目标图片的x和y坐标，网页中的坐标有所不同 
5. 一般情况都是往上往左移动，所以数值是负值
6. 使用精灵图的时候需要精确测量，每个小背景的大小和位置 
```
### 1.3精灵图的使用
```
选择器 {
		background: url() -x坐标px -y坐标px;
}
```
## 2.字体图标  iconfont
### 2.1字体图片的产生
```
*使用场景：主要用于显示网页中通用，常用的一些小图标
*为前端工程师提供一种方便高效的图标使用方式，展示的是图标，本质属于字体
```
### 2.2字体图标的优点
```
*轻量级：图标字体比图像小，字体记载，图标即渲染，减少服务器请求
*灵活性：本质是文字，易于更改属性
*兼容性：几乎支持所有浏览器
注意：不能代替精灵技术，仅对工作中图标部分技术的提升和优化
1.遇到结构样式简单的小图标，就用字体图标
2.遇到结构样式复杂的小图标，就用精灵图
```
### 2.3字体图标的下载
网址：
icomoon字库   			[icomoon](https://icomoon.io/)
阿里iconfont字库 		[iconfont](https://www.iconfont.cn/) 
### 2.4字体图标的引入   
```
*下载完毕之后，注意原先的文件不要删，后面会用
1.把下载包里面的fonts文件夹放入页面根目录下
2.在CSS样式中全局声明字体：即把这些字体文件通过CSS引入到我们页面中(@font-face复制到style中)
3.小框框复制到span
4.span {font-family: '';}
*一定注意字体文件路径的问题   
```
**阿里iconfont**
```
@font-face {
  font-family: 'iconfont';
  src: url("../fonts/iconfont.eot");
  src: url("../fonts/iconfont.eot?#iefix") format('embedded-opentype'),
  url("../fonts/iconfont.woff") format('woff'),
  url("../fonts/iconfont.ttf") format('truetype'),
  url("../fonts/iconfont.svg#iconfont") format('svg');
}
```
### 2.5字体图标的追加 
```
将压缩包里的selection，重新上传，然后选中自己想要新的图标，重新下载压缩包，替换原来的文件
```
## 3.CSS三角
```
div {
	width: 0;
	height:0;
	border: 50px solid transparent;
	border-left-color: pink;
}
```
## 4.用户界面样式 
### 4.1 鼠标样式	cursor
```
li {cursor: pointer; }
default		默认
pointer		小手
move		移动
text		文本
not-allowed	禁止  
```
### 4.2 轮廓线	outline 
```
给表单添加outline: 0; 或者outline: none;样式之后,就可以去掉默认边框 
input {outline: none;  }
```
### 4.3防止拖拽文本域	resize
```
textarea { resize: none; } 
```
## 5.vertical-align 属性应用
### 5.1实现行内块和文字垂直居中对齐
```
常用于设置图片或者表单（行内块元素）和文字垂直对齐
*用于设置一个元素的垂直对齐方式，但是它只针对于行内元素或者行内块元素有效
vertical-align: ...;
baseline	默认，放置在元素的基线上
top			把元素的顶端与行中最高元素的顶端对齐
middle		把此元素防止在元素的中部
bottom		把元素的顶端与行中最低的元素顶端对齐 
```
### 5.2解决图片底部默认空白缝隙问题
```
问题原因:图片默认与文字基线对齐
1.给图片添加vertical-align:middle/top/boottom(提倡使用)
2.把图片转换为块级元素	display: block;
```
## 6.溢出的文字省略号显示
### 6.1单行文字溢出显示省略号
```
满足条件：
1.先强制一行内显示文本	white-space: nowrap;(默认normal自动换行)
2.超出部分隐藏	overflow: hidden;
3.文字用省略号代替超出的部分	text-overflow: ellipsis;
```
### 6.2多行文本溢出显示省略号(了解)
```
overflow: hidden;
text-overflow: ellipsis;
弹性伸缩盒子模型显示	display: -webkit-box;
限制在一个块元素显示的文本的行数	-webkit-line-clamp: 2;
设置或检索伸缩盒对象的子元素的排列方式	-webkit-box-orient: vertical;
```
## 7.常见布局技巧
### 7.1margin负值的应用
```
1.让盒子边框重叠 实现盒子细线边框
2.鼠标经过盒子时提高层级（无定位，添加相对定位。有定位，添加z-index）
```
### 7.2文字围绕浮动元素
```
浮动元素不会压住文字
```
### 7.3行内块的巧妙运用
```
翻页脚码
```
### 7.4CSS三角强化
```
直角三角形:去掉一边的边框
```
## 8.CSS初始化
```
不同浏览器对有些标签的默认值是不同的，为了消除不同浏览器对HTML文本呈现的差异，照顾浏览器的兼容，我们需要对CSS初始化
*CSS初始化是指重设浏览器的样式（CSS reset）
```

