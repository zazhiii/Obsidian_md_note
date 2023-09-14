```
import java.util.Scanner;  
  
public class Main {  
    public static void main(String[] args) {  
        Scanner s = new Scanner(System.in);  
        int r = s.nextInt();  
        int[][] nums = new int[r][r];  
        int[][] dp = new int[r][r];  
        for (int i = 0; i <= r - 1; i++) {  
            for (int j = 0; j <= i; j++) {  
                nums[i][j] = s.nextInt();  
            }  
        }  
        //初始化dp数组  
        dp[0][0] = nums[0][0];  
        for (int i = 1; i <= r - 1; i++) {  
            dp[i][0] = nums[i][0] + dp[i - 1][0];  
        }  
        //确定遍历顺序 动态规划  
        for (int i = 1; i <= r - 1; i++) {  
            for (int j = 1; j <= r - 1; j++) {  
                dp[i][j] = nums[i][j] + Math.max(dp[i - 1][j], dp[i - 1][j - 1]);  
            }  
        }  
        int res = 0;  
        for (int i = 1; i <= r - 1; i++) {  
            if (dp[r - 1][i] > res) res = dp[r - 1][i];  
        }  
        System.out.println(res);  
    }  
}
```