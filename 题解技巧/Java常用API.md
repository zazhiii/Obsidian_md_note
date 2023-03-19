# 1. 输入 输出
## (1) Scanner 类
```
import java.util.Scanner;       //引入Scanner类
```
## (2) Scanner.next()
```
next()方法会一个一个读入token（来自于屏幕，文件等等），不同token之间由分隔符（_delimiter_）隔开。

next() 方法默认的token分隔符（_delimiter_）为 “空格、回车和tab”

如果输入的第一个字符就是分隔符（空格、回车和tab），则会“忽略”：
```
## (3) nextLine()
```
nextLine()是截取当前光标到当前行末尾（不包括行分隔符）的内容，并将光标移到下一行开头。
```
## (4) printf
```
System.out.printf("%4.2f", i);// "4.2"中4表示输出的长度，2表示小数点后的位数。  

System.out.printf("%d", i);// "d"表示输出十进制整数。  

%d表示打印整型的
%2d表示把整型数据打印最低两位
%02d表示把整型数据打印最低两位，如果不足两位，用0补齐
```


# 2. 快速读写
```
StreamTokenizer st = new StreamTokenizer(new BufferedReader(new InputStreamReader(System.in)));//快读
PrintWriter pw = new PrintWriter(new BufferedWriter(new OutputStreamWriter(System.out)));//快写
```
## StreamTokenizer类的使用
（1）我们在使用StreamTokenizer类时，我们要导入io包，它是io包中的类
（2）在使用这个类时，函数要抛出IOException异常（throws IOException）
（3）每一次读入之前都要用nextToken（）方法获取下一个数据
（4）读取数据的方法，sval方法读取字符串类型（以空格或者换行分隔），nval  方法读取数字类型数据。读取字符串类型的数据时，一次只能读一个字符串，读取数字类型的数据时，默认为double类型

```
import java.io.*;
public class test {
	public static void main(String args[]) throws IOException{
		StreamTokenizer st = new StreamTokenizer(new BufferedReader(new InputStreamReader(System.in))); 
		st.nextToken();
		String str = st.sval;//读取String类型数据
		st.nextToken();
		double num1 =  st.nval;//读取double类型数据
		st.nextToken();
		int num2 = (int)st.nval;//读取int类型数据
		st.nextToken();
		long num3 = (long)st.nval;//读取long类型数据
	}
}
```
## 直接写一个读类
```
//导入所有的读写包
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StreamTokenizer;

	//快速写
PrintWriter pw = new PrintWriter(new BufferedWriter(new OutputStreamWriter(System.out)));//快写

	//读类
class Read{
	StreamTokenizer st = new StreamTokenizer(new BufferedReader(new InputStreamReader(System.in)));
		//使用StreamTokenizer类抛出IOException异常
	public int nextInt() throws Exception{
		st.nextToken();
		return (int)st.nval;
	}
	public String readLine() throws Exception{	//	不推荐使用
		st.nextToken();
		return st.sval;
	}
}

```
# 3.字符串
## String (不可变字符串)
1. 初始化
```
String str = new String("XXX"); //参数可以是字符串常量，也可为字符数组
String str = "XXX"; //参数可为字符串常量，可为String.valueOf()系列的返回值
```
2. 常用方法
```
charAt(int index); //返回index位置的字符char --- O(1)
 
length(); //返回字符串长度 --- O(1)
 
substring(int beginIndex, int endIndex); //返回字符片段[beginIndex, endIndex) --- O(n)

replace(char oldChar, char newChar); //返回一个新字符串String，其oldChar全部变成newChar --- O(n)
 
toCharArray(); //返回char[]数组。把String变成字符数组 --- O(n)
 
trim(); //去除前后空格的新字符串 --- O(n)
 
toLowerCase(); //返回一个新的字符串全部转成小写 --- O(n)
toUpperCase(); //返回一个新的字符串全部转成大写 --- O(n)

public String[] split(String regex, int limit)
regex -- 正则表达式分隔符。
limit -- 分割的份数。

indexOf(String str);//返回子字符串第一次出现的索引。
indexOf(String str, int fromIndex);//同上，从指定位置查找。
lastIndexOf(String str);//返回子字符串最后一次出现的索引。
lastIndexOf(String str, int fromIndex);//同上，从指定位置查找。

valueOf(char[ ] data);//返回 char数组的字符串表示形式。
valueOf(char[ ] data,int offset, int count);//返回 char 数组参数的特定子数组的字符串表示形式。
valueOf(int i);//返回 int 参数的字符串表示形式。

```

## StringBuilder (可变字符串)
1. 构造器
```
StringBuilder​(int capacity)  构造一个字符串构建器，其中没有字符，并且具有 `capacity`参数指定的初始容量。

StringBuilder(String str)构造一个初始化为指定字符串内容的字符串构建器。
```
2. 常用方法
```
charAt(int index);            //返回index位置的char --- O(1)
 
append(String str);           //追加字符串

insert(int offset,String str) //将字符串插入此字符序列。

delete (int start,int end)    //删除此序列的子字符串中的字符。

reverse()                     //反转字符串
 
toString(); //返回一个与构建起或缓冲器内容相同的字符串 --- O(n)
```


# 4. 数组
## 排序
```
  Arrays.sort(arr);
```
## 输入时赋值
```
for (int i = 0; i < arr.length; i++) {
       Scanner scanner = new Scanner(System.in);
       arr[i] = scanner.nextInt();
 }
```


# 5. 工具类

1. java.util.Math：主要包含数学内的应用方法
```
Math.abs(参数)         //返回参数的绝对值

Math.max(参数1，参数2)，Math.min(参数1，参数2)     //返回最大最小值

Math.sqrt(参数)、Math.cbrt(参数)              //开平方,开立方,返回double

Math.pow(参数1，参数2）          //返回参数1的参数2次方

Math.log(参数），Math.log10(参数)        //取e,10为底的对数

Math.random()   //返回一个随机数，随机数范围为[0，1),返回值类型为double
```
2. java.util.Arrays：主要包含了操作数组的各种方法。
```
Arrays.toString(arr)    //返回字符串，便于打印数组内容

Arrays.sort(arr，fromIndex，toIndex)  //数组升序 从fromIndex到toIndex

Arrays.sort(arr，fromIndex，toIndex，Collections.reverseOrder()) //降序

Arrays.equals(arr1,arr2)  //比较数组中的数 默认的equals比较的是地址

Arrays.copeOf() 和Arrays.copeOfRange()  //截取数组，返回新的数组对象
```
3. 基本类型的最大值与最小值
```
MAX_VALUE，MIN_VALUE 分别保存了对应基本类型的最大值与最小值

例如:
fmax = Float.MAX_VALUE;
fmin = Float.MIN_VALUE;
dmax = Double.MAX_VALUE;
dmin = Double.MIN_VALUE;
```

# 6. 日历 (calender)
```
YEAR 指示年。 MONTH 指示月份。
DAY_OF_MONTH 指示一个月中的某天。
DAY_OF_WEEK 指示一个星期中的某天。
DAY_OF_YEAR 指示当前年中的天数。
DAY_OF_WEEK_IN_MONTH 指示当前月中的第几个星期。
DAY_OF_WEEK 星期几
HOUR指示当天中的某小时
MINUTE 指示当前小时中的某分钟
SECOND 指示当前分钟中的某秒

值得注意的是，月份是从0开始到11结束，既输入11代表的为12月而天则是从1开始；星期从1-7分表代表从星期天到星期六

1. 创建
Calendar calendar = Calendar.getInstance(); //默认是当前时间

2. 设置时间
calendar.set(calendar.YEAR, year); //年份
calendar.set(calendar.MONTH, 11); //这是12月 从0开始到11 代表1-12月
calendar.set(calendar.DAY_OF_MONTH, 31); 日
或者这样:
calendar.set(2009, 6 - 1, 12); 

3. Add设置
c1.add(Calendar.DATE, 10);
把c1对象的日期加上10，也就是c1也就表示为10天后的日期，其它所有的数值会被重新计算

c1.add(Calendar.DATE, -10);
```

# 7. 时间
```
可以用Excel来：  
1.输入两个日期，相减可以计算相差天数  
2.给一个日期，计算加上指定天数后的日期  
3.计算某天为星期几，点击fx,选择WEEKDAY函数  

计算器:
日期
进制转换
```

# 8.  BigInteger和BigDecimal
```
在Java中最多支持64位整数也就是long型，但如果要表示并且计算超过这个整数范围的数，可以使用BigInteger或者BigDecimal这两个类来解决。BigDecimal除了支持表示整数外还能进行高精度的小数运算，比如我们直接判断0.1 + 0.2 == 0.3会得到结果false，这是由于二进制无法精确的小数造成的，使用BigDecimal也可以规避小数在二进制表示上的误差。

当题目所要处理的数精读比较大，无法使用double类型处理时，可调用BigInteger,BigDecimal这两个API进行处理。其中BigInteger支持任意精度的整数，BigDecimal支持任何精度的定点数

1. 定义常量
BigInteger a = BigInteger.ONE;
BigDecimal b = BigDecimal.TEN;
这里的ONE，ZERO，TEN分别代表1，0，10

2.构造方法（参数一般使用字符串）
BigDecimal a = new BigDecimal("0.1");

  String 构造方法是完全可预知的：写入 newBigDecimal(“0.1”) 将创建一个 BigDecimal，它正好等于预期的 0.1。因此，比较而言， 通常建议优先使用String构造方法。

3. 加减乘除：
BigDecimal c = a.add(b);       a+b
BigDecimal c = a.subtract(b);  a-b
BigDecimal c = a.multiply(b);  a*b
BigDecimal c = a.divide(b);    a/b

4.取绝对值
BigDecimal c = a.abs();

5.n次幂
BigDecimal c = a.pow(n);

3.常用方法
valueOf(); //将参数转换为指定的类型 
remainder(); //取余 
gcd(); //最大公约数 
abs(); //绝对值 
negate();// 取反数 
equals(); //是否相等 

```