```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        String word = s.nextLine().toLowerCase();  
        String sentence = s.nextLine().toLowerCase();  
  
        //将句子中的单词存入数组  
        String[] arr = sentence.split(" ");  
        //定义位置和出现次数  
        int res = 0;  
        int locate = -1;  
        String tmp = "";  
        for (int i = 0; i < arr.length; i++) {  
            tmp += arr[i] + " ";  
            if (arr[i].equals(word)) {  
                res++;  
                //记录 第一次出现位置  
                if (locate == -1) {  
                    locate = tmp.length() - word.length() - 1;  
                }  
            }  
        }  
        if (locate == -1) {  
            System.out.println(-1);  
        } else {  
            System.out.println(res + " " + locate);  
        }  
  
    }  
}
```