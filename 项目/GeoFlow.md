
TODO

- [x] 文件分片上传、秒传、断点续传
- [x] 前端可视化tif 直接返回png
- [x] 上传压缩包，解析landsat8
- [x] 计算ndvi，通过一定方式展示给用户

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


---
彩色合成：
1. 从MinIO读取三个文件
2. 合成写入一个 BufferedImage，再保存到临时文件（**因为文件大，不建议通过内存上传，而是先保存到临时文件**）
3. 上传MinIO、保存数据库信息，删除临时文件

7681 × 7811大小文件：

|              | 多线程                         | 单线程                  |
| ------------ | --------------------------- | -------------------- |
| 从MinIO加载3个文件 | 6592ms、6146ms，6138ms、5679ms | 8828ms、7741ms，7810ms |
| 计算RGB        | 3736ms、4000ms、3871ms、3742ms | 4760ms、4452ms、4460ms |
| 写入文件并上传      |                             | 临时文件上传~5.7s、内存上传     |
| 总时长          |                             | 18s                  |

---

 **为什么选择 MinIO 作为存储方案？对比其他对象存储（如 AWS S3、阿里云 OSS）的优缺点？**
1. 支持私有化部署
2. 开源、免费

**GeoTools 在项目中承担了什么角色？如何用它处理遥感数据？**
1. 遥感数据加载与解析：读取GeoTIFF、波段数据、元数据
2. 栅格数据操作


**如何实现分片上传、秒传、断点续传？**
1. 前端先计算文件的唯一标识（MD5）
2. 发送请求，后端检查上传任务和文件是否存在
	1. 若不存在则新建上传任务
	2. 若存在切文件也存在则直接返回（秒传）
	3. 若只上传一部分则返回已经上传的分片
3. 前端为未上传的分片请求上传地址，直接上传到文件服务器（断点续传）
4. 上传完成之后检查分片数量正确之后发送请求合并

**分片顺序性保证**：分片携带序号
**分片完整性保证**：前后端都计算 MD5 比较
**分片大小如何选择？**：通常选择 `5-10MB`。过小会导致请求数过多，过大会增加单次失败的成本