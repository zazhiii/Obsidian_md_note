```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int n = s.nextInt();  
        //计算中值  
        int mid = n / 7 / 52;  
        int k = 1;  
        int x;  
        while (true) {  
            x = mid - k * 3;  
            if (x <= 100) {  
                System.out.println(x);  
                System.out.println(k);  
                break;            }  
            k++;  
        }  
    }  
}
```