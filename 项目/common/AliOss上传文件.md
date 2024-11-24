
# 配置
application.yml
```yml
zz:  
  alioss:  
    endpoint: ${zz.alioss.endpoint}  
    access-key-id: ${zz.alioss.access-key-id}  
    access-key-secret: ${zz.alioss.access-key-secret}  
    bucket-name: ${zz.alioss.bucket-name}
```
application-dev.yml
```yml
zz:  
  alioss:  
    endpoint: oss-cn-beijing.aliyuncs.com  
    access-key-id: LTAI5tDzEcVJ43Ja7bLWBMyH  
    access-key-secret: 9j7zMZfZ7uPJBkpY2yd5D1tyiTREiB  
    bucket-name: big-eventzazhiii
```
# 属性类
```java
package com.zazhi.properties;  
  
import lombok.Data;  
import org.springframework.boot.context.properties.ConfigurationProperties;  
import org.springframework.stereotype.Component;  
  
@Component  
@ConfigurationProperties(prefix = "zz.alioss")  
@Data  
public class AliOssProperties {  
  
    private String endpoint;  
    private String accessKeyId;  
    private String accessKeySecret;  
    private String bucketName;  
  
}
```

# 工具类
```java
package com.zazhi.utils;  
  
import com.aliyun.oss.ClientException;  
import com.aliyun.oss.OSS;  
import com.aliyun.oss.OSSException;  
import com.aliyun.oss.OSSClientBuilder;  
import lombok.AllArgsConstructor;  
import lombok.Data;  
import lombok.extern.slf4j.Slf4j;  
import java.io.ByteArrayInputStream;  
  
@Data  
@AllArgsConstructor  
@Slf4j  
public class AliOssUtil {  
  
    private String endpoint;  
    private String accessKeyId;  
    private String accessKeySecret;  
    private String bucketName;  
  
    /**  
     * 文件上传  
     *  
     * @param bytes  
     * @param objectName  
     * @return  
     */  
    public String upload(byte[] bytes, String objectName) {  
  
        // 创建OSSClient实例。  
        OSS ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);  
  
        try {  
            // 创建PutObject请求。  
            ossClient.putObject(bucketName, objectName, new ByteArrayInputStream(bytes));  
        } catch (OSSException oe) {  
            System.out.println("Caught an OSSException, which means your request made it to OSS, "  
                    + "but was rejected with an error response for some reason.");  
            System.out.println("Error Message:" + oe.getErrorMessage());  
            System.out.println("Error Code:" + oe.getErrorCode());  
            System.out.println("Request ID:" + oe.getRequestId());  
            System.out.println("Host ID:" + oe.getHostId());  
        } catch (ClientException ce) {  
            System.out.println("Caught an ClientException, which means the client encountered "  
                    + "a serious internal problem while trying to communicate with OSS, "  
                    + "such as not being able to access the network.");  
            System.out.println("Error Message:" + ce.getMessage());  
        } finally {  
            if (ossClient != null) {  
                ossClient.shutdown();  
            }  
        }  
  
        //文件访问路径规则 https://BucketName.Endpoint/ObjectName        StringBuilder stringBuilder = new StringBuilder("https://");  
        stringBuilder  
                .append(bucketName)  
                .append(".")  
                .append(endpoint)  
                .append("/")  
                .append(objectName);  
  
        log.info("文件上传到:{}", stringBuilder.toString());  
  
        return stringBuilder.toString();  
    }  
}
```

# 配置类
```java
package com.zazhi.config;  
  
import com.zazhi.properties.AliOssProperties;  
import com.zazhi.utils.AliOssUtil;  
import lombok.extern.slf4j.Slf4j;  
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean; 
import org.springframework.context.annotation.Bean;  
import org.springframework.context.annotation.Configuration;  
  
/**  
 * 配置类，用于创建AliOssUtil对象  
 */  
@Configuration  
@Slf4j  
public class OssConfiguration {  
  
    @Bean  
    @ConditionalOnMissingBean    public AliOssUtil aliOssUtil(AliOssProperties aliOssProperties){  
        log.info("开始创建阿里云文件上传工具类对象：{}",aliOssProperties);  
        return new AliOssUtil(aliOssProperties.getEndpoint(),  
                aliOssProperties.getAccessKeyId(),  
                aliOssProperties.getAccessKeySecret(),  
                aliOssProperties.getBucketName());  
    }  
}
```

# 调用
先获取文件拓展名，生成uuid作其文件名防止重名覆盖。传入文件的字节数组和文件全名，返回一个文件访问地址。
```java
public String uploadFile(MultipartFile file) {  
    try {  
        //原始文件名  
        String originalFilename = file.getOriginalFilename();  
        //截取原始文件名的后缀   dfdfdf.png        String extension = null;  
        if (originalFilename != null) {  
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));  
        }  
        //构造新文件名称  
        String objectName = UUID.randomUUID().toString() + extension;  
        //文件的请求路径  
        return aliOssUtil.upload(file.getBytes(), objectName);  
    } catch (IOException e) {  
        throw new RuntimeException("上传失败");  
    }  
}
```