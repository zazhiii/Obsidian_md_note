```
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner s = new Scanner(System.in);
        String str = s.next();
        char[] charArr = new char[13];//装含有-的char数组
        for (int i = 0; i < str.length(); i++) {
            charArr[i] = str.charAt(i);
        }
        int[] numArr = new int[10];//用于计算的int数组
        int n;//记录当前尾数
        if (str.charAt(12) == 'X') {
            n = 10;
        } else {
            n = str.charAt(12) - '0';
        }
        //计算正确尾数
        int right_n = ((str.charAt(0) - '0') + (str.charAt(2) - '0') * 2 + (str.charAt(3) - '0') * 3 + (str.charAt(4) - '0') * 4 + (str.charAt(6) - '0') * 5 + (str.charAt(7) - '0') * 6 + (str.charAt(8) - '0') * 7 + (str.charAt(9) - '0') * 8 + (str.charAt(10) - '0') * 9) % 11;
        if (n == right_n) {
            //尾数正确
            System.out.println("Right");
        } else {
            //尾数错误 重新赋值
            if (right_n == 10) {
                charArr[12] = 'X';
            } else {
                charArr[12] = (right_n + " ").charAt(0);
            }
            //生成新号码
            String rightStr = "";
            for (int i = 0; i < charArr.length; i++) {
                rightStr += charArr[i];
            }
            System.out.println(rightStr);
        }
    }
}
```