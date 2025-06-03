
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

# 部署 MINIO

拉取镜像

启动容器
```shell
docker run -p 9000:9000 -p 9090:9090 \
  --name minio \
  -d --restart=always \
  -e "MINIO_ACCESS_KEY=minioadmin" \
  -e "MINIO_SECRET_KEY=minioadmin" \
  -v /home/minio/data:/data \
  -v /home/minio/config:/root/.minio \
  minio/minio server \
  /data --console-address ":9090" --address ":9000"
```

```shell
docker run -p 9000:9000 -p 9090:9090 --name minio -d --restart=always -e "MINIO_ACCESS_KEY=minioadmin" -e "MINIO_SECRET_KEY=minioadmin" -v E:\MINIO_DATA\data:/data -v E:\MINIO_DATA\config:/root/.minio minio/minio server /data --console-address ":9090" --address ":9000"
```


# 部署Redis


配置密码
[docker安装redis并配置密码_docker run --requirepass-CSDN博客](https://blog.csdn.net/qq_43324779/article/details/123561461)