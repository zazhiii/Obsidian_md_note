do
- [x] 文件分片上传、秒传、断点续传
- [ ] 前端可视化tif


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