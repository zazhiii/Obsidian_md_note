# 96
```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int len = s.nextInt();  
        String sentence = s.next();  
        //数组存储每个字符  
        char[] arr = new char[len];  
        int res = 0;  
        String ans = "";  
        for (int i = 0; i < len - 1; i++) {  
            String tmp = "" + sentence.charAt(i) + sentence.charAt(i + 1);  
            //判断两个一组的字符串是否满足要求 满足则后移两位 不放入数组 不满足则将i位置的字符放入数组  
            if (tmp.equals("VK")) {  
                res++;  
                i++;  
            } else {  
                arr[i] = sentence.charAt(i);  
            }  
            ans += arr[i];  
        }  
        //最后的边界  
        if ("" + sentence.charAt(len - 2) + sentence.charAt(len - 1) != "VK") {  
            arr[len - 1] = sentence.charAt(len - 1);  
            ans += arr[len - 1];  
        }  
  
        if (ans.contains("VV") || ans.contains("KK")) {  
            res++;  
        }  
        System.out.println(res);  
    }  
}
```
# 92
```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int len = s.nextInt();  
        String sentence = s.next();  
        StringBuilder sb = new StringBuilder(sentence);  
        int res = 0;  
        for (int i = 0; i < len - 1; i++) {  
            if (sentence.charAt(i) == 'V' && sentence.charAt(i + 1) == 'K') {  
                sb.replace(i, i + 1, "0");  
                res++;  
                i++;  
            }  
        }  
        sentence = sb.toString();  
        if (sentence.contains("KK") || sentence.contains("VV")) {  
            res++;  
        }  
        System.out.println(res);  
    }  
}
```
# AC
```
import java.util.Scanner;
 
public class Main {
	public static void main(String[] args) {
		Scanner cin = new Scanner (System.in);
		int n = cin.nextInt();
		String s = cin.next();
		char[] ch = s.toCharArray();
		int num = 0;
		boolean isVk = false;
		for(int i = 0; i < s.length()-1; i++) {
			if(ch[i] == 'V' && ch[i+1] == 'K') {
				num++;
				ch[i] = 'X';ch[i+1] = 'Y';
			}
		}
		for(int i = 0; i < s.length()-1; i++) {
			if(ch [i] == ch [i+1])
				isVk = true;
		}
		if(isVk)
			System.out.println(num+1);
		else
			System.out.println(num);
	}
}
```