
# Docker-desktop

配置镜像：

设置 => Docker Engine

```json
{
    "registry-mirrors": [
        "https://docker.registry.cyou/",
        "https://docker-cf.registry.cyou/",
        "https://dockercf.jsdelivr.fyi/",
        "https://docker.jsdelivr.fyi/",
        "https://dockertest.jsdelivr.fyi/",
        "https://mirror.aliyuncs.com/",
        "https://dockerproxy.com/",
        "https://mirror.baidubce.com/",
        "https://docker.m.daocloud.io/",
        "https://docker.nju.edu.cn/",
        "https://docker.mirrors.sjtug.sjtu.edu.cn/",
        "https://docker.mirrors.ustc.edu.cn/",
        "https://mirror.iscas.ac.cn/",
        "https://docker.rainbond.cc/",
        "https://jq794zz5.mirror.aliyuncs.com"
    ]
}
```

# 部署 mysql

```shell
docker run \
-p 3306:3306 \
--restart=always \
--name mysql \
--privileged=true \
-v /home/mysql/log:/var/log/mysql \
-v /home/mysql/data:/var/lib/mysql \
-v /home/mysql/conf/my.cnf:/etc/mysql/my.cnf \
-e TZ=Asia/Shanghai \
-e MYSQL_ROOT_PASSWORD=a12bCd3_W45pUq6 \
-d mysql:8.3.0  
```