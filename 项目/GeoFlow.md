do
- [x] 文件分片上传、秒传、断点续传
- [x] 前端可视化tif 直接返回png
- [ ] 上传压缩包，解析landsat8
- [ ] 计算ndvi，通过一定方式展示给用户


---
后端如何读取到MinIO中的文件？
```java
@Test  
void readTiffFromMinIO() throws Exception {  
    InputStream inputStream = minioClient.getObject(  
          GetObjectArgs.builder()  
                .bucket("minio-upload-demo")  
                .object("2025-03-29/c6b0d15d-ddbd-44ba-aa20-bffdf392dd01.TIF")  
                .build()
    );  
  
    GeoTiffReader reader = new GeoTiffReader(inputStream);  
    System.out.println(reader.getFormat().getName());  
    inputStream.close();  
}
```

---

上传压缩包，存储到minio

加载数据集，从minio读取数据集压缩文件
解压存储到临时文件，将这些文件上传到minio中，并关联创建的「数据集」


