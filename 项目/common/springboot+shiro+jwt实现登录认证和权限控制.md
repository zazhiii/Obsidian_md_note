

## 前言

在我初学登录模块的时候，登录认证是通过JWT和拦截器实现的。最近在写项目时遇到接口需要权限验证，我打算用一个安全框架来实现。经过我的考察最终在SpringSecurity和Shiro中选择了Shiro，前者我感觉要复杂一些，对于我这个小项目Shiro就足够了。研究了一下，终于写出了demo。代码可以直接跑，我省去了数据库等一些操作。再次之前你需要了解「Shiro的认证流程」和「RABC权限模型」。

## 0. 项目结构

``` 
com.zazhi.shiro_demo
│── common
│   ├── Result
│   ├── JwtUtil
│
│── controller
│   ├── MyController
│
│── pojo
│   ├── User
│
│── service
│   ├── UserService
│
│── shiro
│   ├── ShiroConfig
│   ├── JwtFilter
│   ├── AccountRealm
│   ├── JwtToken
│   ├── GlobalExceptionHandler
│
│── ShiroDemoApplication
│
resources
│── application.yml
```

- `common`：通用工具类（`JwtUtil`）和返回结果封装（`Result`）。
- `controller`：`MyController` 处理请求。
- `service`：业务逻辑层（`UserService`）。
- shiro：Shiro 相关配置，包括 `ShiroConfig`、`JwtFilter`、`AccountRealm`、`JwtToken` 以及全局异常处理 `GlobalExceptionHandler`。
- `resources`：配置文件 `application.yml`。
## 1. 导入依赖

```xml
<dependencies>
		<dependency>
			<groupId>commons-logging</groupId>
			<artifactId>commons-logging</artifactId>
			<version>1.2</version>
		</dependency>
		<!--    web依赖-->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<!-- 单元测试-->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
		</dependency>
		<!-- Shiro -->
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-spring-boot-starter</artifactId>
			<classifier>jakarta</classifier>
			<version>2.0.1</version>
			<exclusions>
				<exclusion>
					<groupId>org.apache.shiro</groupId>
					<artifactId>shiro-crypto-cipher</artifactId>
				</exclusion>
				<exclusion>
					<groupId>org.apache.shiro</groupId>
					<artifactId>shiro-crypto-hash</artifactId>
				</exclusion>
				<exclusion>
					<groupId>org.apache.shiro</groupId>
					<artifactId>shiro-web</artifactId>
				</exclusion>
				<exclusion>
					<groupId>org.apache.shiro</groupId>
					<artifactId>shiro-spring</artifactId>
				</exclusion>
			</exclusions>
		</dependency>
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-web</artifactId>
			<classifier>jakarta</classifier>
			<version>2.0.1</version>
		</dependency>
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-spring</artifactId>
			<classifier>jakarta</classifier>
			<version>2.0.1</version>
		</dependency>
		<!--jwt-->
		<dependency>
			<groupId>com.auth0</groupId>
			<artifactId>java-jwt</artifactId>
			<version>4.4.0</version>
		</dependency>
		<!--knife4j-->
		<dependency>
			<groupId>com.github.xiaoymin</groupId>
			<artifactId>knife4j-openapi3-jakarta-spring-boot-starter</artifactId>
			<version>4.4.0</version>
		</dependency>
		<!--lombok依赖-->
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<version>1.18.32</version>
		</dependency>
	</dependencies>
```

其中的shiro依赖的导入我参考别人的文章，这样可以兼容SpringBoot 3.x，具体原理我也不懂。

## 2. 添加Shiro配置类

注：他们的作用在代码注释中做了简单解释。
```java

import jakarta.servlet.Filter;
import org.apache.shiro.mgt.DefaultSessionStorageEvaluator;
import org.apache.shiro.mgt.DefaultSubjectDAO;
import org.apache.shiro.spring.web.ShiroFilterFactoryBean;
import org.apache.shiro.spring.web.config.DefaultShiroFilterChainDefinition;
import org.apache.shiro.spring.web.config.ShiroFilterChainDefinition;
import org.apache.shiro.web.mgt.DefaultWebSecurityManager;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class ShiroConfig {

    @Bean
    public ShiroFilterFactoryBean shiroFilterFactoryBean(DefaultWebSecurityManager securityManager,
                                                         ShiroFilterChainDefinition shiroFilterChainDefinition,
                                                         JwtFilter jwtFilter) {
        // ShiroFilterFactoryBean 用于配置 Shiro 的拦截器链，并与 SecurityManager 关联。
        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();
        shiroFilterFactoryBean.setSecurityManager(securityManager);

        // 并将 JwtFilter 实例与之("jwt")关联。相当于给这个拦截器起了个名字
        // JwtFilter 负责处理所有请求的 JWT 认证。
        Map<String, Filter> filters = new HashMap<>();
        filters.put("jwt", jwtFilter);
        shiroFilterFactoryBean.setFilters(filters);

        // setFilterChainDefinitionMap 用来定义 URL 路径与过滤器的映射关系。所有请求都会通过 jwt 过滤器进行身份验证。
        shiroFilterFactoryBean.setFilterChainDefinitionMap(shiroFilterChainDefinition.getFilterChainMap());
        return shiroFilterFactoryBean;
    }

    // shiroFilterChainDefinition 定义了 URL 路径与过滤器的映射规则。
    // 在这个例子中，所有的请求 (/**) 都必须通过 jwt 过滤器进行身份验证
    // 如果有其他请求需要不同的权限控制，可以在这个方法中进一步调整或添加不同的过滤规则。
    @Bean
    public ShiroFilterChainDefinition shiroFilterChainDefinition() {
        DefaultShiroFilterChainDefinition chainDefinition = new DefaultShiroFilterChainDefinition();
        chainDefinition.addPathDefinition("/**", "jwt");
        return chainDefinition;
    }

    // 创建 SecurityManager 对象，并设置自定义的 AccountRealm 作为认证器。
    @Bean
    public DefaultWebSecurityManager defaultWebSecurityManager(AccountRealm accountRealm) {
        DefaultWebSecurityManager defaultWebSecurityManager = new DefaultWebSecurityManager(accountRealm);
        // 关闭session
        DefaultSubjectDAO defaultSubjectDAO = new DefaultSubjectDAO();
        DefaultSessionStorageEvaluator sessionStorageEvaluator = new DefaultSessionStorageEvaluator();
        sessionStorageEvaluator.setSessionStorageEnabled(false);
        defaultSubjectDAO.setSessionStorageEvaluator(sessionStorageEvaluator);
        defaultWebSecurityManager.setSubjectDAO(defaultSubjectDAO);
        return defaultWebSecurityManager;
    }

    // 防止 Spring 将 JwtFilter 注册为全局过滤器
    // 没有这个的话请求会被 JwtFilter 拦截两次
    @Bean
    public FilterRegistrationBean<Filter> registration(JwtFilter filter) {
        FilterRegistrationBean<Filter> registration = new FilterRegistrationBean<Filter>(filter);
        registration.setEnabled(false);
        return registration;
    }

}
```

## 3. 添加自定义Realm

Realm类的作用可以参考其他文章，有很多讲得不错的文章，这里不赘述了。
```java

import com.zazhi.shiro_demo.common.JwtUtil;
import com.zazhi.shiro_demo.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

@Slf4j
@Component
public class AccountRealm extends AuthorizingRealm {

    @Autowired
    private UserService userService;

    // 这个方法用于判断 AccountRealm 是否支持该类型的 Token。
    @Override
    public boolean supports(AuthenticationToken token) {
        return token instanceof JwtToken;
    }

    // 用于授权
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        String username = (String) principals.getPrimaryPrincipal();

        // 这里查询数据库获取用户的角色和权限
        // TODO: 这个例子中，我们模拟了从数据库中查询用户的角色和权限信息。
        //  实际项目中，你需要根据业务逻辑从数据库中查询用户的角色和权限信息。
        Set<String> roles = userService.findRolesByUsername(username); // 示例：{admin}
        Set<String> permissions = userService.findPermissionsByUsername(username); // 示例：{"user:delete", "user:update"}

        // 并使用 addRoles 和 addStringPermissions 方法将角色和权限添加到授权信息中。
        SimpleAuthorizationInfo authorizationInfo = new SimpleAuthorizationInfo();
        authorizationInfo.setRoles(roles);
        authorizationInfo.setStringPermissions(permissions);
        return authorizationInfo;
    }

    // 用于验证用户身份
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken){
        JwtToken token = (JwtToken)authenticationToken;
        String jwtToken = (String) token.getPrincipal();

        // 这里是真正验证 JwtToken 是否有效的地方
        // 如果验证失败，抛出 AuthenticationException 异常。这个请求会被认定为未认证请求。后续返回给前端
        Map<String, Object> map;
        try {
             map = JwtUtil.parseToken(jwtToken);
        } catch (Exception e) {
            throw new AuthenticationException("该token非法，可能被篡改或过期");
        }
        String username = (String)map.get("username");

        // TODO：这里可以根据业务逻辑自定义验证逻辑
        // 例如:1.根据用户名查询数据库，判断用户是否存在 2.判断用户状态是否被锁定等

        return new SimpleAuthenticationInfo(username, jwtToken, getName());
    }
}
```

## 4. 实现JwtFilter类和JwtToken类

JwtFilter

```java
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.web.filter.authc.AuthenticatingFilter;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMethod;

@Slf4j
@Component
public class JwtFilter extends AuthenticatingFilter {

    // 拦截请求之后，用于把令牌字符串封装成令牌对象
    // 该方法用于从请求中获取 JWT 并将其封装为 JwtToken（自定义的 AuthenticationToken 类）。
    @Override
    protected AuthenticationToken createToken(ServletRequest request, ServletResponse response) {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String jwtToken = httpRequest.getHeader("Authorization");
        if (!StringUtils.hasLength(jwtToken)) {
            return null;
        }
        return new JwtToken(jwtToken);
    }

    // 该方法的作用是判断当前请求是否被允许访问。它主要用于检查某些条件，决定是否允许访问或是否跳过认证过程
    // 他作用于 onAccessDenied 之前
    // 如果请求满足某些条件（例如，isAccessAllowed 返回 true），Shiro 会跳过后续的认证步骤，允许请求继续。
    // 如果返回 false，Shiro 会继续执行 onAccessDenied，进行认证或其他授权操作。
    @Override
    protected boolean isAccessAllowed(ServletRequest request, ServletResponse response, Object mappedValue) {
        // 从请求头中获取 Token
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String jwtToken = httpRequest.getHeader("Authorization");

        if (StringUtils.hasLength(jwtToken)) { // 若当前请求存在 Token，则执行登录操作
            try {
                log.info("请求路径 {} 开始认证, token: {}", httpRequest.getRequestURI(), jwtToken);
                getSubject(request, response).login(new JwtToken(jwtToken));
                log.info("{} 认证成功", httpRequest.getRequestURI());
            } catch (AuthenticationException e) {
                log.error("{} 认证失败", httpRequest.getRequestURI());
            }
        }
        // 若当前请求不存在 Token，没有认证意愿，直接放行
        // 例如，登录接口或者游客可访问的接口不需要 Token
        return true;
    }

    @Override
    protected boolean onAccessDenied(ServletRequest servletRequest, ServletResponse servletResponse) throws Exception {
        return true;
    }

    @Override
    protected boolean preHandle(ServletRequest request, ServletResponse response) throws Exception {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        res.setHeader("Access-control-Allow-Origin", req.getHeader("Origin"));
        res.setHeader("Access-control-Allow-Methods", "GET,POST,OPTIONS,PUT,DELETE");
        res.setHeader("Access-control-Allow-Headers", req.getHeader("Access-Control-Request-Headers"));
        // 跨域时会首先发送一个option请求，这里我们给option请求直接返回正常状态
        if (req.getMethod().equals(RequestMethod.OPTIONS.name())) {
            res.setStatus(HttpStatus.OK.value());
            // 返回true则继续执行拦截链，返回false则中断后续拦截，直接返回，option请求显然无需继续判断，直接返回
            return false;
        }
        return super.preHandle(request, response);
    }

}
```

JwtToken
```java

import org.apache.shiro.authc.AuthenticationToken;

/**
 * @author zazhi
 * @date 2024/12/10
 * @description: JwtToken
 */
public class JwtToken implements AuthenticationToken {

    private String token;

    public JwtToken(String token) {
        this.token = token;
    }

    @Override
    public Object getPrincipal() {
        return token;
    }

    @Override
    public Object getCredentials() {
        return token;
    }
}
```

## 5. 实现Controller和Service

Controller
```java

import com.zazhi.shiro_demo.common.Result;
import com.zazhi.shiro_demo.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.authz.annotation.RequiresAuthentication;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.apache.shiro.authz.annotation.RequiresRoles;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author zazhi
 * @date 2024/12/9
 * @description:
 */
@Slf4j
@RestController()
@RequestMapping("/api")
@Tag(name = "MyController", description = "用户接口")
public class MyController {

    @Autowired
    UserService userService;

    // 模拟登录
    @GetMapping("/login")
    public String login(String username, String password) {
        return userService.login(username, password);
    }

    // 不需要认证就能访问
    @GetMapping("/public")
    public Result<String> pub() {
        log.info("调用 pub");
        return Result.success("公共页面");
    }

    // 需要「认证」才能访问
    @RequiresAuthentication
    @GetMapping("/profile")
    public Result<String> profile() {
        return Result.success("个人信息页面");
    }

    // 需要「认证」和「特定角色」才能访问
    @RequiresAuthentication
    @RequiresRoles("admin")
    @GetMapping("/dashboard")
    public Result<String> dashboard() {
        log.info("调用 dashboard");
        return Result.success("控制面板页面");
    }

    // 需要「认证」和「特定权限」才能访问
    @RequiresAuthentication
    @RequiresPermissions("view:dashboard")
    @GetMapping("/viewDashboard")
    public Result<String> viewDashboard() {
        return Result.success("查看控制面板页面");
    }
}
```

Service

注：这里省略了从数据库获取数据，直接模拟了数据的返回。

```java
import com.zazhi.shiro_demo.common.JwtUtil;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;

/**
 * @author zazhi
 * @date 2024/12/9
 * @description: TODO
 */
@Service
public class UserService {
    public String login(String username, String password) {
        // 判断逻辑省略
        return JwtUtil.genToken(Map.of("username", username));
    }

    public Set<String> findPermissionsByUsername(String username) {
        return Set.of("user:delete", "user:update");
    }

    public Set<String> findRolesByUsername(String username) {
        // 模拟从数据库中查询用户角色
        if(username.equals("admin")){
            return Set.of("admin");
        }
        return Set.of("user");
    }
}
```

## 6. 全局异常处理类

对于认证失败、鉴权失败的情况，我们用全局异常处理器捕获相应的异常返回对应信息给前端。
```java

import com.zazhi.shiro_demo.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.authz.UnauthenticatedException;
import org.apache.shiro.authz.UnauthorizedException;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler{

    /**
     * 处理未认证异常
     * @param e
     * @return
     */
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    @ExceptionHandler(UnauthenticatedException.class)
    public Result handleUnauthenticatedException(UnauthenticatedException e){
        return Result.error("未认证或Token无效，请重新登录");
    }

    /**
     * 处理未授权异常
     * @param e
     * @return
     */
    @ResponseStatus(HttpStatus.FORBIDDEN)
    @ExceptionHandler(UnauthorizedException.class)
    public Result handleUnauthorizedException(UnauthorizedException e){
        return Result.error("未授权");
    }

    /**
     * 处理其他异常
     * @param e
     * @return
     */
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e){
        log.info("Exception: ", e);
        return Result.error(StringUtils.hasLength(e.getMessage())? e.getMessage():"操作失败");
    }
}
```

## 7. 其他类

统一返回结果类
```java

import lombok.Data;
import java.io.Serializable;
/**
 * 后端统一返回结果
 * @param <T>
 */
@Data
public class Result<T> implements Serializable {

    private Integer code; //编码：1成功，0和其它数字为失败
    private String msg; //错误信息
    private T data; //数据

    public static <T> Result<T> success() {
        Result<T> result = new Result<T>();
        result.code = 1;
        return result;
    }

    public static <T> Result<T> success(T object) {
        Result<T> result = new Result<T>();
        result.data = object;
        result.code = 1;
        return result;
    }

    public static <T> Result<T> error(String msg) {
        Result result = new Result();
        result.msg = msg;
        result.code = 0;
        return result;
    }

}
```

JWT工具类
```java

package com.zazhi.shiro_demo.common;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

import java.util.Date;
import java.util.Map;

public class JwtUtil {

    private static final String KEY = "zazhi";

    //接收业务数据,生成token并返回
    public static String genToken(Map<String, Object> claims) {
        return JWT.create()
                .withClaim("claims", claims)
                .withExpiresAt(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 24 * 7))
                .sign(Algorithm.HMAC256(KEY));
    }

    //接收token,验证token,并返回业务数据
    public static Map<String, Object> parseToken(String token) {
        return JWT.require(Algorithm.HMAC256(KEY))
                .build()
                .verify(token)
                .getClaim("claims")
                .asMap();
    }

    // 验证token是否有效
    public static boolean verifyToken(String token) {
        try {
            JWT.require(Algorithm.HMAC256(KEY))
                    .build()
                    .verify(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

}
```

## 8. SpringBoot 启动！

在 application.yml 中配置一下knife4j

```yml
springdoc:
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha
  api-docs:
    path: /v3/api-docs
  group-configs:
    - group: 'default'
      paths-to-match: '/**'
      packages-to-scan: com.zazhi.shiro_demo.controller
# knife4j的增强配置，不需要增强可以不配
knife4j:
  enable: true
  setting:
    language: zh_cn
```

启动！

在浏览器访问：localhost:8080/doc.html 就可以开始测试啦。