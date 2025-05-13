在遥感图像处理系统中引入线程池机制，将图像读取与合成任务并发执行，显著提升了RGB图像合成效率

_使用 Java 开发 | 2025.03 – 至今_

- 负责实现 Landsat 遥感图像的上传、解压、波段管理与 RGB 合成展示，支持 GeoTIFF 格式文件处理。
    
- 利用 GeoTools 读取 GeoTIFF 波段数据，合成 RGB 图像并上传至对象存储（MinIO）供前端展示。
    
- **引入线程池和多线程优化波段文件的加载与图像合成过程**，平均处理时间从 3.8s 降低至 1.4s，提高图像响应速度约 63%。
    
- 使用策略模式封装不同拉伸算法（线性拉伸、直方图均衡等），支持用户自定义图像增强方式。
    
- 前后端分离架构，前端基于 Vue 实现图像选择与在线展示。


**2025.03 – 至今 | 独立开发 / 后端主导**

- 开发遥感图像处理平台，支持用户上传 Landsat 图像数据包（GeoTIFF 格式），自动解压、波段识别与 RGB 合成；
    
- 基于 **GeoTools 实现波段数据读取与图像合成逻辑**，并支持用户自定义红绿蓝波段及拉伸算法（如线性拉伸、直方图均衡）；
    
- **引入线程池和多线程优化图像处理过程**（如波段校验、文件读取、像素合成），将 RGB 合成处理时间减少约 60%，显著提升系统响应效率；
    
- **基于 MinIO 实现大文件（>500MB）上传优化**，包括：
    
    - **分片上传**：前端分片、后端合并，减少资源消耗；
        
    - **秒传机制**：利用文件哈希检测避免重复上传；
        
    - **断点续传支持**：中断恢复上传，适应复杂网络环境；
        
- 支持图像处理结果的可视化展示，采用 Vue 构建前端交互界面，并集成地图组件展示遥感合成结果

---

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

测试接口时长：18s、14s、14s
