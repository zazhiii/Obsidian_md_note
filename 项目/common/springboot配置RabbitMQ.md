```xml
  <!--消息发送-->
  <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-amqp</artifactId>
  </dependency>
```


```yml
spring:
  rabbitmq:
    host: 192.168.150.101 # 你的虚拟机IP
    port: 5672 # 端口
    virtual-host: /hmall # 虚拟主机
    username: hmall # 用户名
    password: 123 # 密码
```

json消息转换器

```java
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;  
import org.springframework.amqp.support.converter.MessageConverter;  
import org.springframework.context.annotation.Bean;  
import org.springframework.context.annotation.Configuration;  
  
/**  
 * @author zazhi  
 * @date 2024/11/13  
 * @description: TODO  
 */  
@Configuration  
public class MessageConverterConfig {  
    @Bean  
    public MessageConverter messageConverter(){  
        // 1.定义消息转换器  
        Jackson2JsonMessageConverter jackson2JsonMessageConverter = new Jackson2JsonMessageConverter();  
        // 2.配置自动创建消息id，用于识别不同消息，也可以在业务中基于ID判断是否是重复消息  
        jackson2JsonMessageConverter.setCreateMessageIds(true);  
        return jackson2JsonMessageConverter;  
    }  
}
```