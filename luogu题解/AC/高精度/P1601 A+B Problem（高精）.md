```
import java.math.BigDecimal;  
import java.util.Scanner;  
  
class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        BigDecimal A = new BigDecimal(String.valueOf(s.nextLine()));  
        BigDecimal B = new BigDecimal(String.valueOf(s.nextLine()));  
        BigDecimal C = A.add(B);  
        System.out.println(C);  
    }  
}
```