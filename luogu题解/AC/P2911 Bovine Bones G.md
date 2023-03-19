```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int s1 = s.nextInt();  
        int s2 = s.nextInt();  
        int s3 = s.nextInt();  
        int[] resArr = new int[81];  
        for (int i = 1; i <= s1; i++) {  
            for (int j = 1; j <= s2; j++) {  
                for (int k = 1; k <= s3; k++) {  
                    resArr[i + j + k]++;  
                }  
            }  
        }  
  
        int res = 0;//结果和  
        int n = 0;//出现次数  
        for (int i = 3; i < resArr.length; i++) {  
            if (resArr[i] > n) {  
                res = i;  
                n = resArr[i];  
            }  
        }  
        System.out.println(res);  
    }  
}
```