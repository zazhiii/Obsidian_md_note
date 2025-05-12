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