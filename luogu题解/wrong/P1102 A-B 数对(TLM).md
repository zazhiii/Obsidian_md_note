# 暴力(TLM)
```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int N = s.nextInt();  
        int C = s.nextInt();  
  
        int res = 0;  
        //数组存储输入数据  
        int[] arr = new int[N];  
        for (int i = 0; i < N; i++) {  
            arr[i] = s.nextInt();  
            //倒序遍历寻找数值  
            for (int j = i - 1; j >= 0; j--) {  
                if (arr[j] - arr[i] == C || arr[i] - arr[j] == C) {  
                    res++;  
                }  
            }  
        }  
        System.out.println(res);  
    }  
}
```