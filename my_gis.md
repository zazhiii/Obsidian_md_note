# 安装PostgreSQL和PostGIS

# shapefile 数据导入 PostgreSQL
将 Shapefile 数据存储到 PostgreSQL 数据库中，通常涉及到将这些数据导入到一个能够处理地理信息的数据库中。可以使用 PostGIS 扩展来增强 PostgreSQL 的空间数据处理能力。以下是将 Shapefile 数据导入 PostgreSQL 的步骤：
### 1. 确保已安装 PostGIS

首先，确保您的 PostgreSQL 数据库已安装 PostGIS 扩展。如果尚未安装，可以通过以下 SQL 命令在 PostgreSQL 中创建 PostGIS 扩展：

```sql
CREATE EXTENSION postgis;
```
### 2. 使用 `shp2pgsql` 工具

`shp2pgsql` 是 PostGIS 提供的命令行工具，可以将 Shapefile 转换为 SQL 插入命令。
#### 2.1 转换 Shapefile 为 SQL
##### 自动创建数据库表
当您使用 `shp2pgsql` 工具时，它会根据 Shapefile 的属性自动生成相应的 SQL 语句来创建表。您只需确保在运行 `shp2pgsql` 时指定表名即可。工具会根据 Shapefile 的字段和数据类型生成适当的 SQL 创建表命令。

```bash
shp2pgsql -I -s 4326 path/to/your/shapefile.shp your_table_name > output.sql
```

- `-I`：创建空间索引。
- `-s 4326`：指定 SRID（空间参考系统标识符），例如 WGS 84 是 4326。
- `path/to/your/shapefile.shp`：替换为您的 Shapefile 文件的路径。
- `your_table_name`：要在数据库中创建的表的名称。
- `output.sql`：输出的 SQL 文件。
生成的 `output.sql` 文件将包含创建表的 SQL 语句以及插入数据的语句。当您执行这个 SQL 文件时，会自动创建所需的表。
##### 手动创建数据库表

如果您需要对表的结构有更多控制，或者希望在导入前定义一些额外的约束或索引，可以提前手动创建数据库表。创建表时，确保它的列和数据类型与 Shapefile 的属性相匹配。

例如，您可以在 PostgreSQL 中创建一个表：

```sql
CREATE TABLE your_table_name (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    area NUMERIC,
    geom GEOMETRY(POLYGON, 4326)  -- 适应您的几何类型
);
```

在这种情况下，您需要确保在执行 `shp2pgsql` 时不要包含创建表的部分，而只是插入数据：

```bash
shp2pgsql -a -s 4326 path/to/your/shapefile.shp your_table_name > output.sql

```

- `-a`：以追加模式（append）导出数据，适合导入到已经存在的表中。
- `-s 4326`：指定坐标系，这里使用的是 WGS 84（EPSG:4326）。
然后执行 `output.sql` 文件将数据插入到已创建的表中。




# 底图
高德矢量底图
```text
https://webrd04.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}
```
高德卫星影像
```text
https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}
```
