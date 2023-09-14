```
class Solution {  
    public String replaceSpace(String s) {  
        //数组存放单个字母  
        String[] arr = new String[s.length()];  
        String res = "";  
        for (int i = 0; i < s.length(); i++) {  
            //如果为空格则替换为%20 结束此次循环  
            if (s.charAt(i) == ' ') {  
                arr[i] = "%20";  
                res += arr[i];  
                continue;            }  
            //不是空格存入字母字符串  
            arr[i] = s.charAt(i) + "";  
            //将结果加到res  
            res += arr[i];  
        }  
        return res;  
    }  
}
```