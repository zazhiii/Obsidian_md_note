
源代码地址：[zazhiii/minio-upload-demo: 基于MinIO实现文件的分片上传、秒传、断点续传。包含前后端代码。 Based on MinIO, files can be uploaded in parts, in seconds, and resumably. Contains front-end and back-end code.](https://github.com/zazhiii/minio-upload-demo)

>感兴趣的可以帮我点点 star

# 分片上传（Chunked Upload）

核心思想：将大文件切割成多个小块（分片），逐个上传到服务器，最后在服务器合并成完整文件。

应用场景：
- 大文件上传
- 结合断点续传减少单次传输失败的影响

大致实现思路：
1. 上传文件时通过文件的唯一标识（MD5值）查询文件是否上传过，没有则用 MinIO 的 api 创建分片上传任务
2. 再调用 MinIO 的 api 为每个分片生成一个上传 URL 返回给前端
3. 前端通过 URL 直接上传分片文件
4. 若上传完成再调用 MinIO 的 api 将分片合并

注：这种方式也有一定弊端，比如会暴露 MinIO 服务器的地址。
# 秒传（Instant Upload）

核心思想：如果服务器已存在相同文件，则直接返回文件地址，无需重复上传

应用场景：
- 用户重复上传加速
- 节省带宽与存储

实现思路：
1. 同分片上传第1步：通过唯一标识查询文件，判断 MinIO 中是否有该文件，有则直接返回 URL

# 断点续传（Resumable Upload）

核心思想：上传中断后，下次继续上传未完成的部分，而非重新开始。

实现思路：
1. 通过 MinIO 的 api 能得到一个上传任务中上传成功的分片列表
2. 前端通过这个分片列表判断哪些分片要上传，哪些不用再上传