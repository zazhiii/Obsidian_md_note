#### 欢迎

欢迎来到栅格处理器教程。本教程假设您已完成任一快速入门教程的学习。

请确保您的IDE已配置好GeoTools Jar包访问权限（可通过Maven或Jar目录实现）。所需Maven依赖项将在前置条件章节开头列出。

本教程手册将演示如何直接对栅格对象执行常见操作——如叠加、重采样、裁剪等。

#### 影像分块应用

ImageLab教程已涵盖栅格数据的加载与渲染；本教程将展示使用CoverageProcessor等工具直接对栅格数据执行基础操作（如裁剪和缩放），并利用Arguments工具简化命令行处理。我们将创建一个实用程序，用于将栅格"分块"（为简化逻辑，仅对地理范围进行均分），并可选地对生成的分块进行缩放。
#### 前置条件

以下依赖项可能已在之前示例的pom.xml中添加，但请至少确保包含以下依赖：
```xml
<dependencies>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-shapefile</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-epsg-hsql</artifactId>
        <version>${geotools.version}</version>
    </dependency>
    <dependency>
        <groupId>org.geotools</groupId>
        <artifactId>gt-geotiff</artifactId>
        <version>${geotools.version}</version>
    </dependency>
</dependencies>
```

在包`org.geotools.tutorial.coverage`中创建文件`ImageTiler.java`，并粘贴以下包含基础导入、字段及getter/setter的代码框架：
```java
package org.geotools.tutorial.coverage;

import java.io.File;
import java.io.IOException;
import org.geotools.api.geometry.Bounds;
import org.geotools.api.parameter.ParameterValueGroup;
import org.geotools.api.referencing.crs.CoordinateReferenceSystem;
import org.geotools.coverage.grid.GridCoverage2D;
import org.geotools.coverage.grid.io.AbstractGridFormat;
import org.geotools.coverage.grid.io.GridCoverage2DReader;
import org.geotools.coverage.grid.io.GridFormatFinder;
import org.geotools.coverage.processing.CoverageProcessor;
import org.geotools.coverage.processing.Operations;
import org.geotools.gce.geotiff.GeoTiffFormat;
import org.geotools.geometry.jts.ReferencedEnvelope;
import org.geotools.util.Arguments;
import org.geotools.util.factory.Hints;

/**
 * 基于地理范围均分实现栅格数据简单分块。使用栅格处理操作。
 */
public class ImageTiler {

    private final int NUM_HORIZONTAL_TILES = 16;
    private final int NUM_VERTICAL_TILES = 8;

    private Integer numberOfHorizontalTiles = NUM_HORIZONTAL_TILES;
    private Integer numberOfVerticalTiles = NUM_VERTICAL_TILES;
    private Double tileScale;
    private File inputFile;
    private File outputDirectory;

    // ... (省略getter/setter方法)
```
>**注意**：此为部分代码片段，完整代码将在后续补充，IDE报错可暂时忽略。

#### 参数处理
为创建命令行应用，需使用GeoTools的`Arguments`类解析以下参数：
- **必选参数**：输入文件(`-f`)、输出目录(`-o`)
- **可选参数**：垂直/水平分块数(`-vtc`/`-htc`)、缩放比例(`-scale`)

```java
public static void main(String[] args) throws Exception {
    Arguments processedArgs = new Arguments(args);
    ImageTiler tiler = new ImageTiler();

    try {
        tiler.setInputFile(new File(processedArgs.getRequiredString("-f")));
        tiler.setOutputDirectory(new File(processedArgs.getRequiredString("-o")));
        tiler.setNumberOfHorizontalTiles(processedArgs.getOptionalInteger("-htc"));
        tiler.setNumberOfVerticalTiles(processedArgs.getOptionalInteger("-vtc"));
        tiler.setTileScale(processedArgs.getOptionalDouble("-scale"));
    } catch (IllegalArgumentException e) {
        System.out.println(e.getMessage());
        printUsage();
        System.exit(1);
    }

    tiler.tile();
}

private static void printUsage() {
    System.out.println("用法: -f 输入文件 -o 输出目录 [-tw 瓦片宽度<默认:256> -th 瓦片高度<默认:256>]");
    System.out.println("-htc 水平瓦片数<默认:16> -vtc 垂直瓦片数<默认:8>");
}
```

#### 加载栅格数据

通过`GridFormatFinder`和`AbstractGridFormat`抽象加载栅格数据。
注：当前GeoTiff加载存在需单独处理的特性：
```java
private void tile() throws IOException {
    AbstractGridFormat format = GridFormatFinder.findFormat(this.getInputFile());
    String fileExtension = this.getFileExtension(this.getInputFile());

    // 修复GeoTiff加载时的坐标轴顺序问题
    Hints hints = null;
    if (format instanceof GeoTiffFormat) {
        hints = new Hints(Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE);
    }

    GridCoverage2DReader gridReader = format.getReader(this.getInputFile(), hints);
    GridCoverage2D gridCoverage = gridReader.read(null);
```
#### 分割栅格数据

根据请求的水平和垂直分块数，通过计算地理范围均分瓦片尺寸，并循环进行裁剪和缩放：
```java
ReferencedEnvelope coverageEnvelope = gridCoverage.getEnvelope2D();
double coverageMinX = coverageEnvelope.getMinX();
double coverageMaxX = coverageEnvelope.getMaxX();
double coverageMinY = coverageEnvelope.getMinY();
double coverageMaxY = coverageEnvelope.getMaxY();

int htc = this.getNumberOfHorizontalTiles() != null ? this.getNumberOfHorizontalTiles() : NUM_HORIZONTAL_TILES;
int vtc = this.getNumberOfVerticalTiles() != null ? this.getNumberOfVerticalTiles() : NUM_VERTICAL_TILES;

double geographicTileWidth = (coverageMaxX - coverageMinX) / (double) htc;
double geographicTileHeight = (coverageMaxY - coverageMinY) / (double) vtc;

CoordinateReferenceSystem targetCRS = gridCoverage.getCoordinateReferenceSystem();

// 确保输出目录存在
File tileDirectory = this.getOutputDirectory();
if (!tileDirectory.exists()) {
    tileDirectory.mkdirs();
}

// 循环处理分块
for (int i = 0; i < htc; i++) {
    for (int j = 0; j < vtc; j++) {
        System.out.println("处理索引 i: " + i + ", j: " + j + " 处的瓦片");
        Bounds envelope = getTileEnvelope(coverageMinX, coverageMinY, geographicTileWidth, geographicTileHeight, targetCRS, i, j);
        GridCoverage2D finalCoverage = cropCoverage(gridCoverage, envelope);

        if (this.getTileScale() != null) {
            finalCoverage = scaleCoverage(finalCoverage);
        }

        File tileFile = new File(tileDirectory, i + "_" + j + "." + fileExtension);
        format.getWriter(tileFile).write(finalCoverage, null);
    }
}
```

#### 创建瓦片范围

根据索引和地理范围尺寸生成瓦片的地理边界：
```java
private Bounds getTileEnvelope(
        double coverageMinX,
        double coverageMinY,
        double geographicTileWidth,
        double geographicTileHeight,
        CoordinateReferenceSystem targetCRS,
        int horizontalIndex,
        int verticalIndex) {

    double envelopeStartX = (horizontalIndex * geographicTileWidth) + coverageMinX;
    double envelopeEndX = envelopeStartX + geographicTileWidth;
    double envelopeStartY = (verticalIndex * geographicTileHeight) + coverageMinY;
    double envelopeEndY = envelopeStartY + geographicTileHeight;

    return new ReferencedEnvelope(envelopeStartX, envelopeEndX, envelopeStartY, envelopeEndY, targetCRS);
}
```

#### 裁剪操作

手动创建参数并通过`CoverageProcessor`执行`CoverageCrop`操作：
```java
private GridCoverage2D cropCoverage(GridCoverage2D gridCoverage, Bounds envelope) {
    CoverageProcessor processor = CoverageProcessor.getInstance();
    final ParameterValueGroup param = processor.getOperation("CoverageCrop").getParameters();
    param.parameter("Source").setValue(gridCoverage);
    param.parameter("Envelope").setValue(envelope);
    return (GridCoverage2D) processor.doOperation(param);
}
```
#### 缩放操作

使用`Operations`类简化缩放操作，保持宽高比：
```java
/**
 * 按设定比例缩放栅格数据
 *
 * <p>相较于参数操作，Operations类提供更类型安全的方式
 */
private GridCoverage2D scaleCoverage(GridCoverage2D coverage) {
    Operations ops = new Operations(null);
    coverage = (GridCoverage2D) ops.scale(coverage, this.getTileScale(), this.getTileScale(), 0, 0);
    return coverage;
}
```
### 运行应用程序

在运行应用前需准备示例数据。推荐使用[Natural Earth]([Natural Earth » 1:50m Natural Earth II - Free vector and raster map data at 1:10m, 1:50m, and 1:110m scales](https://www.naturalearthdata.com/downloads/50m-raster-data/50m-natural-earth-2/))的50米分辨率数据集。
#### 通过IDE运行

若您已使用IDE跟随教程开发，内置的运行功能是最简便的方式。以Eclipse为例：
1. 选择菜单 **Run → Run Configurations**
2. 创建新的**Java Application**配置
![[Pasted image 20250331233214.png]]

在**参数(Arguments)**选项卡中配置：
- **输入文件路径**：指向下载的栅格数据
- **分块参数**：水平16块、垂直8块
- **输出目录**：临时文件夹
- **缩放比例**：2.0

`-f /Users/devon/Downloads/NE2_50M_SR_W/NE2_50M_SR_W.tif -htc 16 -vtc 8 -o /Users/devon/tmp/tiles -scale 2.0`

>**注意**：请替换为实际文件路径和目录。

**Eclipse路径变量技巧**：  
在运行配置中点击**Variables**，使用`file_prompt`（文件选择）和`folder_prompt`（目录选择）动态指定路径：

![[Pasted image 20250331233852.png]]

点击**Run**启动应用。可能出现的`ImageIO`相关警告信息可忽略。
其他IDE（如NetBeans/IntelliJ）的配置方式类似。

#### 通过Maven运行

若无IDE，可通过Maven的`exec`任务运行应用（参考[Maven快速入门]([Maven Quickstart — GeoTools 33-SNAPSHOT User Guide](https://docs.geotools.org/latest/userguide/tutorial/quickstart/maven.html))）。需在`pom.xml`中添加Maven Shade插件：
```java
mvn exec:java -Dexec.mainClass=org.geotools.tutorial.ImageTiler \  
-Dexec.args="-f /Users/devon/Downloads/NE2_50M_SR_W/NE2_50M_SR_W.tif -htc 16 -vtc 8 -o /Users/devon/tmp/tiles -scale 2.0"  
```

### 扩展实践

1. **探索更多栅格操作**  
    参考[栅格处理器文档](https://docs.geotools.org/latest/userguide/library/coverage/processor.html)，了解`CoverageProcessor`支持的操作（如`Resample`）。  
    **示例**：使用[`Operations`]([Operations (Geotools modules 33-SNAPSHOT API)](https://docs.geotools.org/latest/javadocs/org/geotools/coverage/processing/Operations.html))类将栅格重投影至EPSG:3587（谷歌Web墨卡托投影）。
2. **验证分块结果**
    - 将输出瓦片加载至**GeoServer [ImageMosaic](https://docs.geoserver.org/latest/en/user/data/raster/imagemosaic/index.html))存储** 
    - 或通过代码创建[`ImageMosaicReader`](https://docs.geotools.org/latest/javadocs/org/geotools/gce/imagemosaic/ImageMosaicReader.html))读取瓦片目录